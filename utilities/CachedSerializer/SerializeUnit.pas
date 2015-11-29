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
       UniConv, CachedTexts;

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

    function ParseOptions(var Options: TParameterOptions; const S: UnicodeString): Boolean;
    procedure ParseParametersLine(const S: UTF16String);
  public
    function ParseParameter(const S: UnicodeString): Boolean;
    function Add(const S: UnicodeString): NativeUInt;
    procedure Delete(const AFrom: NativeUInt; const ACount: NativeUInt = 1);
    procedure AddFromFile(const FileName: string; const ParametersLine: Boolean);

    property Count: NativeUInt read FCount;
    property Items: TUnicodeStrings read FItems;
  end;


{ TSerializer class }

  TSerializer = class(TObject)
  private

  public
    function Process(const Parameters: TSerializeParameters): TUnicodeStrings;
  end;




implementation


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
var
  Options: TParameterOptions;
begin
  Result := False;
  if (not ParseOptions(S)) then Exit;






  Result := False;
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

function TSerializer.Process(
  const Parameters: TSerializeParameters): TUnicodeStrings;
begin
  Result := nil;

end;

end.
