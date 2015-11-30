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
  TIdentifierInfo = record
    Marker: UnicodeString;
    Value: UnicodeString;
    Comment: UnicodeString;
    Code: TUnicodeStrings;
  end;



function UnicodeFormat(const FmtStr: UnicodeString; const Args: array of const): UnicodeString;  
  
implementation


function UnicodeFormat(const FmtStr: UnicodeString; const Args: array of const): UnicodeString;
begin
  Result := {$ifdef UNICODE}Format{$else}WideFormat{$endif}(FmtStr, Args);
end;

end.
