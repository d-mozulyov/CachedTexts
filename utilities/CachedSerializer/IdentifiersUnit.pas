unit IdentifiersUnit;


// compiler options
{$if CompilerVersion >= 24}
  {$LEGACYIFEND ON}
{$ifend}
{$if CompilerVersion >= 23}
  {$define UNITSCOPENAMES}
{$ifend}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$ifndef VER140}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$endif}
{$O+}{$R-}{$I-}{$Q-}{$W-}

interface
  uses {$ifdef UNITSCOPENAMES}
         System.SysUtils,
       {$else}
         SysUtils,
       {$endif}
       UniConv, CachedBuffers, CachedTexts;

type
  TUnicodeStrings = array of UnicodeString;
  PUnicodeStrings = ^TUnicodeStrings;

  PIdentifierInfo = ^TIdentifierInfo;
  TIdentifierInfo = object
  protected
    function UnpackReferences(const S: UTF16String): UnicodeString;
    function DoublePointPos(const S: UTF16String): NativeInt;
    function IncorrectDoublePoints(const S: UnicodeString): Exception;
    procedure ParseCode(const S: UnicodeString);
  public
    Value: UnicodeString;
    Comment: UnicodeString;

    Marker: UnicodeString;
    MarkerReference: Boolean;
    Code: TUnicodeStrings;

    function Parse(const S: UnicodeString): Boolean;
    function IsAscii: Boolean;
  end;

  PIdentifier = ^TIdentifier;
  TIdentifier = object
  protected
    procedure FillDataBytes(var Bytes: TBytes; var Converter: TTemporaryString; const Value: UnicodeString);
    procedure FillData(var Converter: TTemporaryString;
      const Value, Comment: UnicodeString; const Code: TUnicodeStrings;
      const IgnoreCase: Boolean);
  public
    CasesGroup: NativeUInt;
  public
    Info: TIdentifierInfo;

    DataSize: NativeUInt;
    Data1: TBytes;
    Data2: TBytes;
    DataOr: TBytes;
  end;
  TIdentifierList = array of TIdentifier;
  PIdentifierList = ^TIdentifierList;
  TIdentifierItems = array[0..High(Integer) div SizeOf(TIdentifier) - 1] of TIdentifier;
  PIdentifierItems = ^TIdentifierItems;

  // sorting
  TIdentifierComparator = function(const Id1, Id2: TIdentifier; const Offset: NativeUInt): NativeInt;
  function DefaultIdentifierComparator(const Id1, Id2: TIdentifier; const Offset: NativeUInt): NativeInt;
  function DataSizeIdentifierComparator(const Id1, Id2: TIdentifier; const Offset: NativeUInt): NativeInt;
  procedure SortIdentifiers(const Items: PIdentifierItems; L, R: NativeInt; const Offset: NativeUInt; Comp: TIdentifierComparator); overload;
  procedure SortIdentifiers(const Items: PIdentifierItems; const Count: NativeUInt; const Offset: NativeUInt; Comp: TIdentifierComparator); overload;
  procedure SortIdentifiers(var List: TIdentifierList; L, R: NativeInt; const Offset: NativeUInt; Comp: TIdentifierComparator); overload;
  procedure SortIdentifiers(var List: TIdentifierList; const Offset: NativeUInt; Comp: TIdentifierComparator); overload;

  // fill data parameters
  procedure AddIdentifier(var List: TIdentifierList; const Info: TIdentifierInfo;
    const Encoding: Word; const IgnoreCase: Boolean; const FunctionValue: UnicodeString);


const
  SHIFT_VALUES: array[TCachedStringKind] of Byte = (0, 0, 1, 2);

implementation
const
  AND_VALUES: array[1..4] of Cardinal = ($ff, $ffff, $ffffff, $ffffffff);

var
  ALTERNATIVE_CHARS: array[UnicodeChar] of UnicodeChar;

function AlternativeString(const S: UnicodeString; const UTF8: Boolean): UnicodeString;
var
  i: NativeUInt;
  Ignore: Boolean;
begin
  Result := S;
  UniqueString(Result);

  for i := 1 to Length(Result) do
  begin
    Ignore := False;

    if (UTF8) then
    case Result[i] of
      #$023A, #$2C65, #$023E, #$2C66, #$2C6F, #$0250, #$2C6D,
      #$0251, #$2C62, #$026B, #$2C6E, #$0271, #$2C64, #$027D:
      begin
        Ignore := True;
      end;
    end;

    if (not Ignore) then
      Result[i] := ALTERNATIVE_CHARS[Result[i]];
  end;
end;

procedure InitializeAlternativeChars;
var
  i, L, U: UnicodeChar;
begin
  for i := Low(UnicodeChar) to High(UnicodeChar) do
  begin
    L := UNICONV_CHARCASE.LOWER[i];
    U := UNICONV_CHARCASE.UPPER[i];

    if (i = L) then
    begin
      ALTERNATIVE_CHARS[i] := U;
    end else
    begin
      ALTERNATIVE_CHARS[i] := L;
    end;
  end;
end;


{ TIdentifierInfo }

function TIdentifierInfo.UnpackReferences(const S: UTF16String): UnicodeString;
var
  SrcLength: NativeInt;
  Dest, Src: PUnicodeChar;
begin
  SetLength(Result, S.Length);
  Dest := Pointer(Result);
  Src := S.Chars;

  SrcLength := S.Length;
  while (SrcLength > 0) do
  begin
    Dest^ := Src^;

    if (Src^ = '\') then
    begin
      Inc(Src);
      Dec(SrcLength);

      case Src^ of
        '\': ;
        'n': Dest^ := #10;
        'r': Dest^ := #13;
        ':': Dest^ := ':';
        't': Dest^ := #9;
        's': Dest^ := #32;
      else
        raise Exception.CreateFmt('Incorrect character "\%s" in "%s"', [Src^, S.ToUnicodeString]);
      end;
    end;

    Inc(Src);
    Dec(SrcLength);
    Inc(Dest);
  end;

  SetLength(Result, (NativeUInt(Dest) - NativeUInt(Pointer(Result))) shr 1);
end;

function TIdentifierInfo.DoublePointPos(const S: UTF16String): NativeInt;
begin
  for Result := 0 to NativeInt(S.Length) - 1 do
  if (S.Chars[Result] = ':') and
    ((Result = 0) or (S.Chars[Result - 1] <> '\')) then Exit;

  Result := -1;
end;

function TIdentifierInfo.IncorrectDoublePoints(
  const S: UnicodeString): Exception;
begin
  Result := Exception.CreateFmt('Incorrect count of '':'' in "%s"', [S]);
end;

procedure TIdentifierInfo.ParseCode(const S: UnicodeString);
var
  Count, i: NativeUInt;
  Str, Sub: UTF16String;
begin
  Str.Assign(S);
  Count := Length(Code);

  while (Str.Length <> 0) do
  begin
    Sub := Str;
    for i := 0 to Str.Length - 1 do
    if (Str.Chars[i] = #13) or (Str.Chars[i] = #10) then
    begin
      Sub := Str.SubString(i);

      if (Str.Chars[i] = #13) and (i <> Str.Length - 1) and (Str.Chars[i + 1] = #10) then
      begin
        Str.Skip(i + 2);
      end else
      begin
        Str.Skip(i + 1);
      end;

      Break;
    end;
    if (Sub.Length = Str.Length) then
       Str.Length := 0;

    Inc(Count);
    SetLength(Code, Count);
    Code[Count - 1] := Sub.ToUnicodeString;
  end;
end;

function TIdentifierInfo.Parse(const S: UnicodeString): Boolean;
var
  Str, Sub: UTF16String;
  P: NativeInt;
begin
  Result := False;
  Str.Assign(S);
  if (not Str.Trim) then Exit;

  Self.Marker := '';
  Self.Value := '';
  Self.Comment := '';
  Self.Code := nil;

  P := DoublePointPos(Str);
  if (P < 0) then
  begin
    Self.Comment := '"' + Str.ToUnicodeString + '"';
    Self.Value := UnpackReferences(Str);
    Self.MarkerReference := False;
  end else
  begin
    Sub := Str.SubString(P);
    Sub.TrimRight;
    Self.Comment := '"' + Sub.ToUnicodeString + '"';
    Self.Value := UnpackReferences(Sub);

    Str.Skip(P + 1);
    if (not Str.TrimLeft) then raise IncorrectDoublePoints(S);

    P := DoublePointPos(Str);
    if (P < 0) then
    begin
      Self.MarkerReference := True;
      Self.Marker := UnpackReferences(Str);
    end else
    begin
      Self.MarkerReference := False;
      Sub := Str.SubString(P);
      Sub.TrimRight;
      Self.Marker := UnpackReferences(Sub);
      Str.Skip(P + 1);

      Str.TrimLeft;
      if (DoublePointPos(Str) >= 0) then raise IncorrectDoublePoints(S);

      if (Str.Length <> 0) then
        ParseCode(UnpackReferences(Str));
    end;
  end;

  Result := True;
end;

function TIdentifierInfo.IsAscii: Boolean;
var
  i: NativeUInt;
begin
  Result := True;

  for i := 1 to Length(Value) do
  if (Value[i] > #127) then
  begin
    Result := False;
    Exit;
  end;
end;

{ TIdentifier }

procedure TIdentifier.FillDataBytes(var Bytes: TBytes;
  var Converter: TTemporaryString; const Value: UnicodeString);
var
  i: NativeUInt;
  SBCSValues: PUniConvSBCSValues;
begin
  Converter.Length := 0;
  Converter.Append(Value);

  Self.DataSize := Converter.Length shl SHIFT_VALUES[Converter.StringKind];
  SetLength(Bytes, Self.DataSize + SizeOf(Cardinal){Gap});
  Move(Converter.Chars^, Pointer(Bytes)^, Self.DataSize);
  PCardinal(@Bytes[Self.DataSize])^ := 0{Gap};

  if (Value <> '') and (Converter.SBCSIndex >= 0) then
  begin
    SBCSValues := UNICONV_SUPPORTED_SBCS[Converter.SBCSIndex].VALUES;

    for i := 0 to Self.DataSize - 1 do
    if (SBCSValues.UCS2[AnsiChar(Bytes[i])] <> Value[i + 1]) then
      raise Exception.CreateFmt('Identifier "%s" can not be encoded in cp%d', [Value, Converter.Encoding]);
  end;
end;

procedure TIdentifier.FillData(var Converter: TTemporaryString;
  const Value, Comment: UnicodeString; const Code: TUnicodeStrings;
  const IgnoreCase: Boolean);
var
  Buf: UnicodeString;
  L: NativeUInt;
  D1, D2, DOr, DOrTop: PByte;
  OrMask: Cardinal;
  Kind: TCachedStringKind;
begin
  Self.Info.Value := Value;
  Self.Info.Comment := Comment;
  Self.Info.Marker := '';
  Self.Info.MarkerReference := False;
  Self.Info.Code := Code;

  if (not IgnoreCase) then
  begin
    Buf := Value;
  end else
  begin
    Buf := AlternativeString(Value, Converter.Encoding = CODEPAGE_UTF8);
  end;

  // data
  FillDataBytes(Data1, Converter, Value);
  FillDataBytes(Data2, Converter, Buf);

  // or mask
  SetLength(DataOr, DataSize + SizeOf(Cardinal));
  if (not IgnoreCase) then
  begin
    FillChar(Pointer(DataOr)^, DataSize + SizeOf(Cardinal), 0);
  end else
  begin
    D1 := Pointer(Data1);
    D2 := Pointer(Data2);
    DOr := Pointer(DataOr);
    DOrTop := DOr;
    Inc(DOrTop, DataSize);

    Kind := Converter.StringKind;
    if (Converter.Encoding = CODEPAGE_UTF8) then Kind := csNone{UTF8 Alias};

    while (DOr <> DOrTop) do
    begin
      case Kind of
         csByte: L := SizeOf(Byte);
        csUTF16: L := SizeOf(UnicodeChar);
        csUTF32: L := SizeOf(UCS4Char);
      else
        // UTF8
        L := UNICONV_UTF8CHAR_SIZE[D1^];
      end;

      // calculate mask
      OrMask := (PCardinal(D1)^ xor PCardinal(D2)^) and AND_VALUES[L];
      if (OrMask and (OrMask - 1) = 0) then
      begin
        PCardinal(DOr)^ := OrMask;
      end;

      // next
      Inc(D1, L);
      Inc(D2, L);
      Inc(DOr, L);
    end;
  end;
end;

function AddIdentifierItem(var List: TIdentifierList): PIdentifier;
var
  Count: NativeUInt;
begin
  Count := Length(List);
  SetLength(List, Count + 1);

  Result := @List[Count];
  Result^.DataSize := 0;
end;

// fill data parameters
procedure AddIdentifier(var List: TIdentifierList; const Info: TIdentifierInfo;
  const Encoding: Word; const IgnoreCase: Boolean; const FunctionValue: UnicodeString);
var
  i, Count: NativeUInt;
  Found: Boolean;
  Code: TUnicodeStrings;
  Converter: TTemporaryString;
  DifficultUTF8CharIndexes: array of NativeUInt;
  DifficultUTF8CharBooleans: array of Boolean;
  Buffer: UnicodeString;
  Item: PIdentifier;
begin
  // duplicates
  if (List <> nil) then
  for i := 0 to Length(List) - 1 do
  begin
    if (not IgnoreCase) then
    begin
      Found := utf16_equal_utf16(List[i].Info.Value, Info.Value);
    end else
    begin
      Found := utf16_equal_utf16_ignorecase(List[i].Info.Value, Info.Value);
    end;

    if (Found) then
      raise Exception.CreateFmt('Identifier duplicate "%s"', [Info.Value]);
  end;

  // marker/function
  Code := Info.Code;
  if (Info.MarkerReference) then
  begin
    Found := False;

    if (List <> nil) then
    for i := 0 to Length(List) - 1 do
    begin
      Found := utf16_equal_utf16_ignorecase(List[i].Info.Marker, Info.Marker);

      if (Found) then
      begin
        Code := List[i].Info.Code;
        Break;
      end;
    end;

    if (not Found) then
      raise Exception.CreateFmt('Marker "%s" not found', [Info.Marker]);
  end else
  if (Code = nil) and (FunctionValue <> '') then
  begin
    SetLength(Code, 1);
    Code[0] := 'Result := ' + FunctionValue + ';';
  end;

  DifficultUTF8CharIndexes := nil;
  Count := 0;
  if (Encoding = CODEPAGE_UTF8) and (IgnoreCase) then
  for i := 1 to Length(Info.Value) do
  case Info.Value[i] of
    #$023A, #$2C65, #$023E, #$2C66, #$2C6F, #$0250, #$2C6D,
    #$0251, #$2C62, #$026B, #$2C6E, #$0271, #$2C64, #$027D:
    begin
      SetLength(DifficultUTF8CharIndexes, Count + 1);
      DifficultUTF8CharIndexes[Count] := i;
      Inc(Count);
    end;
  end;

  // data
  case Encoding of
    CODEPAGE_UTF16: Converter.InitUTF16String;
    CODEPAGE_UTF32: Converter.InitUTF32String;
  else
    Converter.InitByteString(Encoding);
  end;

  // list items
  Item := AddIdentifierItem(List);
  Item.FillData(Converter, Info.Value, Info.Comment, Code, IgnoreCase);
  Item.Info.Marker := Info.Marker;
  Item.Info.MarkerReference := Info.MarkerReference;

  if (DifficultUTF8CharIndexes <> nil) then
  begin
    Count := Length(DifficultUTF8CharIndexes);
    SetLength(DifficultUTF8CharBooleans, Count);
    for i := 0 to Count - 1 do
      DifficultUTF8CharBooleans[i] := False;

    repeat
      // increment boolean bits state
      Found := False;
      for i := 0 to Count - 1 do
      if (not DifficultUTF8CharBooleans[i]) then
      begin
        DifficultUTF8CharBooleans[i] := True;
        Found := True;
        Break;
      end else
      begin
        DifficultUTF8CharBooleans[i] := False;
      end;
      if (not Found) then Break;

      // make identifier
      Buffer := Info.Value;
      UniqueString(Buffer);
      for i := 0 to Count - 1 do
      if DifficultUTF8CharBooleans[i] then
        Buffer[i] := ALTERNATIVE_CHARS[Buffer[i]];

      // add identifier
      Item := AddIdentifierItem(List);
      Item.FillData(Converter, Buffer, Info.Comment, Code, IgnoreCase);
    until (False);
  end;
end;

function DefaultIdentifierComparator(const Id1, Id2: TIdentifier; const Offset: NativeUInt): NativeInt;
var
  i, S1, S2: NativeUInt;
begin
  if (@Id1 = @Id2) then
  begin
    Result := 0;
    Exit;
  end;

  S1 := Id1.DataSize;
  S2 := Id2.DataSize;
  if (S1 = S2) then
  begin
    Result := 0;
  end else
  if (S1 < S2) then
  begin
    Result := -1;
  end else
  begin
    S1 := S2;
    Result := 1;
  end;

  for i := Offset to S1 - 1 do
  if (Id1.Data1[i] <> Id2.Data1[i]) then
  begin
    Result := NativeInt(Id1.Data1[i]) - NativeInt(Id2.Data1[i]);
    Exit;
  end;
end;

function DataSizeIdentifierComparator(const Id1, Id2: TIdentifier; const Offset: NativeUInt): NativeInt;
begin
  Result := NativeInt(Id1.DataSize) - NativeInt(Id2.DataSize);
  if (Result = 0) then
    Result := DefaultIdentifierComparator(Id1, Id2, Offset);
end;

procedure SortIdentifiers(const Items: PIdentifierItems; L, R: NativeInt; const Offset: NativeUInt; Comp: TIdentifierComparator);
type
  TBuffer = array[1..SizeOf(TIdentifier)] of Byte;
var
  I, J: NativeInt;
  P, T: TBuffer;
begin
  repeat
    I := L;
    J := R;
    P := TBuffer(Items[(L + R) shr 1]);
    repeat
      while Comp(Items[I], TIdentifier(P), Offset) < 0 do Inc(I);
      while Comp(Items[J], TIdentifier(P), Offset) > 0 do Dec(J);
      if (I <= J) then
      begin
        if (I <> J) then
        begin
          T := TBuffer(Items[I]);
          TBuffer(Items[I]) := TBuffer(Items[J]);
          TBuffer(Items[J]) := T;
        end;
        Inc(I);
        Dec(J);
      end;
    until (I > J);
    if (L < J) then
      SortIdentifiers(Items, L, J, Offset, Comp);
    L := I;
  until (I >= R);
end;

procedure SortIdentifiers(const Items: PIdentifierItems; const Count: NativeUInt; const Offset: NativeUInt; Comp: TIdentifierComparator);
begin
  if (Count > 1) then
  SortIdentifiers(Items, 0, Count - 1, Offset, Comp);
end;

procedure SortIdentifiers(var List: TIdentifierList; L, R: NativeInt; const Offset: NativeUInt; Comp: TIdentifierComparator);
begin
  SortIdentifiers(PIdentifierItems(List), L, R, Offset, Comp);
end;

procedure SortIdentifiers(var List: TIdentifierList; const Offset: NativeUInt; Comp: TIdentifierComparator);
var
  Count: NativeInt;
begin
  Count := Length(List);

  if (Count > 1) then
  SortIdentifiers(List, 0, Count - 1, Offset, Comp);
end;


initialization
  InitializeAlternativeChars;

end.
