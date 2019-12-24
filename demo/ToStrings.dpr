program ToStrings;

{$APPTYPE CONSOLE}

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

uses {$ifdef UNITSCOPENAMES}
       Winapi.Windows, System.SysUtils,
     {$else}
       Windows, SysUtils,
     {$endif}
     CachedTexts;

// native ordinal types
{$if (not Defined(FPC)) and (CompilerVersion < 22)}
type
  {$if CompilerVersion < 21}
  NativeInt = Integer;
  NativeUInt = Cardinal;
  {$ifend}
  PNativeInt = ^NativeInt;
  PNativeUInt = ^NativeUInt;
{$ifend}

type
  TSysUtilsProc = procedure(var S: string);
  TCachedTextsProc = procedure(var S: TTemporaryString);

const
  CONST_BOOLEAN: Boolean = True;
  CONST_INTEGER: Integer = 123456;
  CONST_INT64: Int64 = 9876543210;
  CONST_HEX: Integer = $abcdef;
  CONST_HEX64: Int64 = $012345abcdef;
  CONST_FLOAT: Extended = 768.645;
  CONST_DATE: TDateTime = 42094{2015-03-31};
  CONST_TIME: TDateTime = 0.524259259259259{12:34:56};
  CONST_DATETIME: TDateTime = 42094.524259259259259;

  ITERATIONS_COUNT = 7 * 1000000;


procedure SysUtilsBoolean(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := BoolToStr(CONST_BOOLEAN, True);
  end;
end;

procedure CachedTextsBoolean(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendBoolean(CONST_BOOLEAN);
  end;
end;

procedure SysUtilsInteger(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToStr(CONST_INTEGER);
  end;
end;

procedure CachedTextsInteger(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendInteger(CONST_INTEGER);
  end;
end;

procedure SysUtilsHex(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToHex(CONST_HEX, 0);
  end;
end;

procedure CachedTextsHex(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendHex(CONST_HEX);
  end;
end;

procedure SysUtilsInt64(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToStr(CONST_INT64);
  end;
end;

procedure CachedTextsInt64(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendInt64(CONST_INT64);
  end;
end;

procedure SysUtilsHex64(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := IntToHex(CONST_HEX64, 0);
  end;
end;

procedure CachedTextsHex64(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendHex64(CONST_HEX64);
  end;
end;

procedure SysUtilsFloat(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := FloatToStr(CONST_FLOAT);
  end;
end;

procedure CachedTextsFloat(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendFloat(CONST_FLOAT);
  end;
end;

procedure SysUtilsDate(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := DateToStr(CONST_DATE);
  end;
end;

procedure CachedTextsDate(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendDate(CONST_DATE);
  end;
end;

procedure SysUtilsTime(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := TimeToStr(CONST_TIME);
  end;
end;

procedure CachedTextsTime(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendTime(CONST_TIME);
  end;
end;

procedure SysUtilsDateTime(var S: string);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S := '';
    S := DateTimeToStr(CONST_DATETIME);
  end;
end;

procedure CachedTextsDateTime(var S: TTemporaryString);
var
  i: Integer;
begin
  for i := 1 to ITERATIONS_COUNT do
  begin
    S.Length := 0;
    S.AppendDateTime(CONST_DATETIME);
  end;
end;


procedure RunTest(const Description: string; const SysUtilsProc: TSysUtilsProc;
  const CachedTextsProc: TCachedTextsProc);
const
  STRINGTYPES: array[1..3] of string = ('ByteString', 'UTF16String', 'UTF32String');
var
  i: Integer;
  Time: Cardinal;
  Str: string;
  Temp: TTemporaryString;
begin
  Writeln(Description, '...');

  Write('SysUtils', ': ');
  Time := GetTickCount;
    SysUtilsProc(Str);
  Time := GetTickCount - Time;
  Write(Time:5, 'ms; ');

  for i := 1 to 3 do
  begin
    case i of
      1: Temp.InitByteString(CODEPAGE_UTF8);
      2: Temp.InitUTF16String;
      3: Temp.InitUTF32String;
    end;

    Write(STRINGTYPES[i], ': ');
    Time := GetTickCount;
      CachedTextsProc(Temp);
    Time := GetTickCount - Time;
    Write(Time:3, 'ms; ');
  end;

  Writeln;
end;

begin
  try
    Writeln('The benchmark shows how to convert Booleans, Ordinals, Floats and DateTimes');
    Writeln('to strings (TTemporaryString) by analogy with SysUtils-functions.');

    // initialize the same (default) format settings
    FormatSettings.ThousandSeparator := #32;
    FormatSettings.DecimalSeparator := '.';
    FormatSettings.DateSeparator := '-';
    FormatSettings.TimeSeparator := ':';
    FormatSettings.ShortDateFormat := 'yyyy-mm-dd';
    FormatSettings.LongTimeFormat := 'hh:mm:ss';

    // run conversion tests
    Writeln;
    RunTest('BooleanToStr', SysUtilsBoolean, CachedTextsBoolean);
    RunTest('IntegerToStr', SysUtilsInteger, CachedTextsInteger);
    RunTest('HexToStr', SysUtilsHex, CachedTextsHex);
    RunTest('Int64ToStr', SysUtilsInt64, CachedTextsInt64);
    RunTest('Hex64ToStr', SysUtilsHex64, CachedTextsHex64);
    RunTest('FloatToStr', SysUtilsFloat, CachedTextsFloat);
    RunTest('DateToStr', SysUtilsDate, CachedTextsDate);
    RunTest('TimeToStr', SysUtilsTime, CachedTextsTime);
    RunTest('DateTimeToStr', SysUtilsDateTime, CachedTextsDateTime);

  except
    on EAbort do ;

    on E: Exception do
    Writeln(E.ClassName, ': ', E.Message);
  end;

  if (ParamStr(1) <> '-nowait') then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
