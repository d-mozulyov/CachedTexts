unit SerializeUnit;


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

  TParameterOptions = record
    Name: UnicodeString;
    Count: NativeUInt;
    O1, O2, O3: UnicodeString;
  end;


{ TSerializeParameters record }

  TSerializeParameters = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FCount: NativeUInt;
    FItems: TUnicodeStrings;
    FOutFileName: UnicodeString;
    FEnumTypeName: UnicodeString;
    FFuncParameter: UnicodeString;
    FIgnoreCase: Boolean;
    FFuncName: UnicodeString;
    FLengthParameter: UnicodeString;
    FUseFuncHeaders: Boolean;
    FEncoding: Word;
    FPrefix: UnicodeString;
    FCharsParameter: UnicodeString;

    procedure FillCharactersOptions(const AFuncParameter, ACharsParameter, ALengthParameter: UnicodeString);
    procedure FillFuncOptions(const AFuncName, AEnumTypeName, APrefix: UnicodeString);
    function ParseOptions(var Options: TParameterOptions; const S: UnicodeString): Boolean;
    procedure ParseParametersLine(const S: UTF16String);
    procedure SetEncoding(const Value: Word);
  public
    function CachedStringType: UnicodeString;
    function ParseParameter(const S: UnicodeString): Boolean;
    function Add(const S: UnicodeString): NativeUInt;
    procedure Delete(const AFrom: NativeUInt; const ACount: NativeUInt = 1);
    procedure AddFromFile(const FileName: string; const ParametersLine: Boolean);
    property Count: NativeUInt read FCount;
    property Items: TUnicodeStrings read FItems;

    property Encoding: Word read FEncoding write SetEncoding;
    property FuncParameter: UnicodeString read FFuncParameter write FFuncParameter;
    property CharsParameter: UnicodeString read FCharsParameter write FCharsParameter;
    property LengthParameter: UnicodeString read FLengthParameter write FLengthParameter;
    property FuncName: UnicodeString read FFuncName write FFuncName;
    property EnumTypeName: UnicodeString read FEnumTypeName write FEnumTypeName;
    property Prefix: UnicodeString read FPrefix write FPrefix;
    property UseFuncHeaders: Boolean read FUseFuncHeaders write FUseFuncHeaders;
    property IgnoreCase: Boolean read FIgnoreCase write FIgnoreCase;
    property OutFileName: UnicodeString read FOutFileName write FOutFileName;
  end;


{ TSerializer class }

  TSerializer = class(TObject)
  private
    FLevel: NativeUInt;
    FLines: PUnicodeStrings;
    FLinesCount: NativeUInt;
    FParameters: ^TSerializeParameters;
    FStringKind: TCachedStringKind;
    FIsFunction: Boolean;
    FIsConsts: Boolean;

    procedure IncLevel;
    procedure DecLevel;
    procedure AddLine; overload;
    procedure AddLine(const S: UnicodeString); overload;
    procedure AddLineFmt(const FmtStr: UnicodeString; const Args: array of const);
    procedure InspecParameters;
  public
    function Process(const Parameters: TSerializeParameters): TUnicodeStrings;
  end;


implementation


function UnicodeFormat(const FmtStr: UnicodeString; const Args: array of const): UnicodeString;
begin
  Result := {$ifdef UNICODE}Format{$else}WideFormat{$endif}(FmtStr, Args);
end;


{ TSerializeParameters }

function TSerializeParameters.Add(const S: UnicodeString): NativeUInt;
begin
  Result := FCount;
  Inc(FCount);
  SetLength(FItems, FCount);
  FItems[Result] := S;
end;

procedure TSerializeParameters.Delete(const AFrom, ACount: NativeUInt);
var
  L, i: NativeUInt;
begin
  L := FCount;
  if (AFrom < L) and (ACount <> 0) then
  begin
    Dec(L, AFrom);
    if (L <= ACount) then
    begin
      L := AFrom;
    end else
    begin
      Inc(L, AFrom);
      Dec(L, ACount);

      for i := 0 to (L - AFrom - 1) do
        FItems[AFrom + i] := FItems[AFrom + ACount + i];
    end;

    FCount := L;
    SetLength(FItems, L);
  end;
end;

procedure TSerializeParameters.SetEncoding(const Value: Word);
begin
  if (Value <> CODEPAGE_UTF8) and (Value <> CODEPAGE_UTF16) and
    (Value <> CODEPAGE_UTF32) then
  begin
    if (not UniConvIsSBCS(Value)) then
      raise Exception.CreateFmt('Unsupported encoding "%d"', [Value]);
  end;

  FEncoding := Value;
end;

function TSerializeParameters.CachedStringType: UnicodeString;
begin
  case FEncoding of
    CODEPAGE_UTF16: Result := 'UTF16String';
    CODEPAGE_UTF32: Result := 'UTF32String';
  else
    Result := 'ByteString';
  end;
end;

procedure TSerializeParameters.FillCharactersOptions(const AFuncParameter,
  ACharsParameter, ALengthParameter: UnicodeString);
begin
  FuncParameter := AFuncParameter;
  CharsParameter := ACharsParameter;
  LengthParameter := ALengthParameter;
end;

procedure TSerializeParameters.FillFuncOptions(const AFuncName, AEnumTypeName,
  APrefix: UnicodeString);
begin
  FuncName := AFuncName;
  EnumTypeName := AEnumTypeName;
  Prefix := APrefix;
end;

function TSerializeParameters.ParseOptions(var Options: TParameterOptions;
  const S: UnicodeString): Boolean;
var
  P: NativeInt;
  Str: UTF16String;

  function ParseOption(var O: UnicodeString): Boolean;
  begin
    Result := True;

    P := Str.CharPos(':');
    if (P = 0) then
    begin
      Result := False;
      Exit;
    end;

    Inc(Options.Count);
    if (P < 0) then
    begin
      O := Str.ToUnicodeString;
      Str.Length := 0;
      Exit;
    end;

    O := Str.SubString(P).ToUnicodeString;
    Str.Offset(P + 1);
  end;
begin
  Result := False;
  Options.Count := 0;
  Str.Assign(S);

  P := Str.CharPos('"');
  if (P < 0) then
  begin
    Options.Name := Str.ToUnicodeString;
    Result := True;
    Exit;
  end else
  begin
    if (P = 0) then Exit;
    Options.Name := Str.SubString(0, P).ToUnicodeString;

    Str.Offset(P);
    P := Str.CharPos('"');
    if (P < 0) or (NativeUInt(P) <> Str.Length - 1) then Exit;
    Str.Length := Str.Length - 1;

    if (not ParseOption(Options.O1)) then Exit;
    if (Str.Length <> 0) then
    begin
      if (not ParseOption(Options.O2)) then Exit;

      if (Str.Length <> 0) then
      begin
        if (not ParseOption(Options.O3)) then Exit;
        if (Str.Length <> 0) then Exit;
      end;
    end;

    Result := True;
  end;
end;

function TSerializeParameters.ParseParameter(const S: UnicodeString): Boolean;
label
  func_options;
var
  Options: TParameterOptions;
  A: AnsiString;
  Enc: Integer;
begin
  Result := False;
  if (not ParseOptions(Options, S)) then Exit;

  with TMemoryItems(Pointer(S)^) do
  case Length(S) of
   2: case (Cardinals[0] or $00200000) of
        $0066002D:
        begin
          // "-f"
          UseFuncHeaders := True;
          goto func_options;
        end;
        $0069002D: IgnoreCase := True; // "-i"
        $006F002D:
        begin
          // "-o"
          case Options.Count of
            1: OutFileName := Options.O1;
            2: OutFileName := Options.O1 + Options.O2;
          else
            Exit;
          end;
        end;
        $0070002D:
        begin
          // "-p"
          case Options.Count of
            1: FillCharactersOptions('const ' + Options.O1 + ': ' + CachedStringType, Options.O1 + '.Chars', Options.O1 + '.Length');
            2: FillCharactersOptions('const Unknown', Options.O1, Options.O2);
          else
            Exit;
          end;
        end;
      end;
   3: if (Cardinals[0] or $00200000 = $0066002D) and (Words[2] or $0020 = $006E) then
      begin
        // "-fn"
        UseFuncHeaders := False;
        func_options:
        case Options.Count of
          2: FillFuncOptions(Options.O1, '', Options.O2);
          3: FillFuncOptions(Options.O1, Options.O2, Options.O3);
        else
          Exit;
        end;
      end;
  else
    A := AnsiString(S);
    Enc := -1;

    with TMemoryItems(Pointer(A)^) do
    case Length(A) of
     4: case (Cardinals[0] and $ffffff) of
          $36382D: if (Bytes[3] = $36) then Enc := 866; // "-866"
          $37382D: if (Bytes[3] = $34) then Enc := 874; // "-874"
          $61722D,$61522D,$41722D,$41522D: if (Bytes[3] or $20 = $77) then Enc := CODEPAGE_RAWDATA; // "-raw"
        end;
     5: case (Cardinals[0] and $ffffff) of
          $32312D: // "-1250","-1251","-1252","-1253","-1254","-1255","-1256","-1257","-1258"
          case (Cardinals1[1]) of
            $3035: Enc := 1250; // "-1250"
            $3135: Enc := 1251; // "-1251"
            $3235: Enc := 1252; // "-1252"
            $3335: Enc := 1253; // "-1253"
            $3435: Enc := 1254; // "-1254"
            $3535: Enc := 1255; // "-1255"
            $3635: Enc := 1256; // "-1256"
            $3735: Enc := 1257; // "-1257"
            $3835: Enc := 1258; // "-1258"
          end;
          $6E612D,$6E412D,$4E612D,$4E412D: if (Words1[1] or $2020 = $6973) then Enc := 0; // "-ansi"
          $73752D,$73552D,$53752D,$53552D: if (Words1[1] or $2020 = $7265) then Enc := CODEPAGE_USERDEFINED; // "-user"
          $74752D,$74552D,$54752D,$54552D: if (Words1[1] or $0020 = $3866) then Enc := CODEPAGE_UTF8; // "-utf8"
        end;
     6: case (Cardinals[0] and $ffffff) of
          $30312D: // "-10000","-10007"
          case (Cardinals2[0] shr 8) of
            $303030: Enc := 10000; // "-10000"
            $373030: Enc := 10007; // "-10007"
          end;
          $30322D: if (Cardinals2[0] shr 8 = $363638) then Enc := 20866; // "-20866"
          $31322D: if (Cardinals2[0] shr 8 = $363638) then Enc := 21866; // "-21866"
          $38322D: // "-28592","-28593","-28594","-28595","-28596","-28597","-28598","-28600","-28603","-28604","-28605","-28606"
          case (Cardinals2[0] shr 8) of
            $323935: Enc := 28592; // "-28592"
            $333935: Enc := 28593; // "-28593"
            $343935: Enc := 28594; // "-28594"
            $353935: Enc := 28595; // "-28595"
            $363935: Enc := 28596; // "-28596"
            $373935: Enc := 28597; // "-28597"
            $383935: Enc := 28598; // "-28598"
            $303036: Enc := 28600; // "-28600"
            $333036: Enc := 28603; // "-28603"
            $343036: Enc := 28604; // "-28604"
            $353036: Enc := 28605; // "-28605"
            $363036: Enc := 28606; // "-28606"
          end;
          $74752D,$74552D,$54752D,$54552D: // "-utf16","-utf32"
          case (Cardinals2[0] shr 8 or $000020) of
            $363166: Enc := CODEPAGE_UTF16; // "-utf16"
            $323366: Enc := CODEPAGE_UTF32; // "-utf32"
          end;
        end;
    end;

    if (Enc < 0) then Exit;
    Encoding := Enc;
  end;

  Result := True;
end;

procedure TSerializeParameters.ParseParametersLine(const S: UTF16String);
var
  Str: UTF16String;
  Buf: UnicodeString;
  L: NativeUInt;
begin
  Str := S;
  while (not Str.Trim) do
  begin
    L := 0;
    while (L < Str.Length) and (Str.Chars[L] <= ' ') do
    begin
      Inc(L);
    end;

    Buf := Str.SubString(L).ToUnicodeString;
    if (not ParseParameter(Buf)) then
      raise Exception.CreateFmt('Unknown file parameter "%s"', [Buf]);

    Str.Offset(L);
  end;
end;

procedure TSerializeParameters.AddFromFile(const FileName: string;
  const ParametersLine: Boolean);
var
  Text: TUTF16TextReader;
  S: UTF16String;
begin
  Text := TUTF16TextReader.CreateFromFile(FileName);
  try
    if (ParametersLine) and (Text.Readln(S)) then
      ParseParametersLine(S);

    while (Text.Readln(S)) do
      Add(S.ToUnicodeString);
  finally
    Text.Free;
  end;
end;


{ TSerializer }

procedure TSerializer.IncLevel;
begin
  Inc(FLevel);
end;

procedure TSerializer.DecLevel;
begin
  if (FLevel = 0) then
    raise Exception.Create('Level is already null');

  Dec(FLevel);
end;

procedure TSerializer.AddLine;
begin
  AddLine('');
end;

procedure TSerializer.AddLine(const S: UnicodeString);
var
  Index: NativeUInt;
  Buf: UnicodeString;
begin
  if (FLevel <> 0) then
  begin
    SetLength(Buf, FLevel * 2);
    for Index := 1 to FLevel * 2 do
      Buf[Index] := #32;
  end;

  Buf := Buf + S;
  Index := FLinesCount;
  Inc(FLinesCount);
  SetLength(FLines^, FLinesCount);
  FLines^[Index] := Buf;
end;

procedure TSerializer.AddLineFmt(const FmtStr: UnicodeString;
  const Args: array of const);
begin
  AddLine(UnicodeFormat(FmtStr, Args));
end;

procedure TSerializer.InspecParameters;
begin
  FStringKind := csByte;
  case FParameters.Encoding of
    CODEPAGE_UTF16: FStringKind := csUTF16;
    CODEPAGE_UTF32: FStringKind := csUTF32;
  end;
  FIsFunction := (FParameters.FuncName <> '');
  FIsConsts := (FIsFunction) and (FParameters.EnumTypeName = '');

  if (FParameters.FCharsParameter = '') then
    raise Exception.Create('CharsParameter not defined');

  if (FParameters.FLengthParameter = '') then
    raise Exception.Create('LengthParameter not defined');


end;

function TSerializer.Process(
  const Parameters: TSerializeParameters): TUnicodeStrings;
var
  i: NativeUInt;
  Text: TUTF16TextWriter;
  DefaultByteEncoding: Word;
begin
  Result := nil;
  FLines := @Result;
  FLinesCount := 0;
  FParameters := @Parameters;
  InspecParameters;

  // todo

  // save lines to file
  if (Parameters.OutFileName <> '') then
  begin
    DefaultByteEncoding := 0;
    if (FStringKind = csByte) then DefaultByteEncoding := Parameters.Encoding;
    Text := TUTF16TextWriter.CreateFromFile(Parameters.OutFileName, bomUTF8, DefaultByteEncoding);
    try
      for i := 1 to FLinesCount do
      begin
        if (i <> 1) then Text.CRLF;
        Text.WriteData(Pointer(Result[i - 1])^, Length(Result[i - 1]) * SizeOf(UnicodeChar));
      end;
    finally
      Text.Free;
    end;
  end;
end;


end.
