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
    Marker: UnicodeString;
    Value: UnicodeString;
    Comment: UnicodeString;
    Code: TUnicodeStrings;

    MarkerReference: Boolean;
    CodeDefined: Boolean;

    function Parse(const S: UnicodeString): Boolean;
  end;

  PIdentifier = ^TIdentifier;
  TIdentifier = object
  protected
    procedure FillData(const Converter: TTemporaryString; const Value: UnicodeString; const IgnoreCase: Boolean);
  public
    Info: TIdentifierInfo;

    DataLength: NativeUInt;
    Data1: TBytes;
    Data2: TBytes;
    DataOr: TBytes;
  end;
  TIdentifierList = array of TIdentifier;
  PIdentifierList = ^TIdentifierList;

  TIdentifierComparator = function(const Id1, Id2: TIdentifier): NativeInt;

  // fill data parameters
  procedure AddIdentifier(var List: TIdentifierList; const Info: TIdentifierInfo;
    const Encoding: Word; const IgnoreCase: Boolean; const FunctionValue: UnicodeString);

implementation

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
  i: NativeUInt;
  Dest, Src: PUnicodeChar;
begin
  SetLength(Result, S.Length);

  Dest := Pointer(Result);
  Src := S.Chars;
  for i := 1 to S.Length do
  begin
    Dest^ := Src^;

    if (Src^ = '\') then
    begin
      Inc(Src);

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
        Str.Offset(i + 2);
      end else
      begin
        Str.Offset(i + 1);
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
  end else
  begin
    Sub := Str.SubString(P);
    Self.Comment := '"' + Sub.ToUnicodeString + '"';
    Self.Value := UnpackReferences(Sub);

    Str.Offset(P + 1);
    if (not Str.TrimLeft) then raise IncorrectDoublePoints(S);

    P := DoublePointPos(Str);
    if (P < 0) then
    begin
      MarkerReference := True;
      Self.Marker := UnpackReferences(Str);
    end else
    begin
      MarkerReference := False;
      Sub := Str.SubString(P);
      Self.Marker := UnpackReferences(Sub);
      Str.Offset(P + 1);

      Str.TrimLeft;
      if (DoublePointPos(Str) >= 0) then raise IncorrectDoublePoints(S);

      if (Str.Length <> 0) then
        Parse(UnpackReferences(Str));
    end;
  end;

  Self.CodeDefined := (Self.Code <> nil);
  Result := True;
end;


{ TIdentifier }

procedure TIdentifier.FillData(const Converter: TTemporaryString;
  const Value: UnicodeString; const IgnoreCase: Boolean);
begin
//  Converter.C
end;

function AddIdentifierItem(var List: TIdentifierList): PIdentifier;
var
  Count: NativeUInt;
begin
  Count := Length(List);
  SetLength(List, Count + 1);

  Result := @List[Count];
  Result^.DataLength := 0;
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
    Code[1] := 'Result := ' + FunctionValue + ';';
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
  if (DifficultUTF8CharIndexes = nil) then
  begin
    // todo
  end else
  begin
    // todo
  end;
end;




initialization
  InitializeAlternativeChars;

end.
