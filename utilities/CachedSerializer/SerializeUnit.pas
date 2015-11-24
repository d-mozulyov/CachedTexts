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

type
  TSerializer = class(TObject)
  private
    FFileName: string;

  protected
    function InitializeParameters(const S: UnicodeString): Boolean;
    procedure AddEntity(const S: UnicodeString);
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;

    property FileName: string read FFileName;
  end;


implementation

{ TSerializer }

constructor TSerializer.Create(const AFileName: string);
var
  Text: TUTF16TextReader;
  S: UTF16String;
begin
  inherited Create;
  FFileName := AFileName;

  Text := TUTF16TextReader.CreateFromFile(AFileName);
  try
    if (Text.Readln(S)) then
    begin
      if (not InitializeParameters(S.ToUnicodeString)) then
        AddEntity(S.ToUnicodeString);
    end;

    while (Text.Readln(S)) do
    begin
      AddEntity(S.ToUnicodeString);
    end;
  finally
    Text.Free;
  end;
end;

destructor TSerializer.Destroy;
begin

  inherited;
end;

function TSerializer.InitializeParameters(const S: UnicodeString): Boolean;
begin
  Result := False;
end;

procedure TSerializer.AddEntity(const S: UnicodeString);
begin

end;

end.
