# CachedTexts

Cached Texts is a powerful and compact cross-platform library aimed at parsing and generating of text data with the maximum possible performance. The library is characterized by the following:
* Code stored in the module "CachedTexts.pas" and depends on the two other libraries: [CachedBuffers](https://github.com/d-mozulyov/CachedBuffers) and [UniConv](https://github.com/d-mozulyov/UniConv).
* There are declared the classes `TUniConvReReader` and `TUniConvReWriter` which allow to process sequential conversion of text from one encoding to another "on-the-fly".
* There are 3 possible basic encodings for parsing and generation of the text: 
Byte-encoding, UTF-16 and UTF-32. Each of them has its advantages and disadvantages. UTF-16 is the most common encoding. In Delphi it matches such types as `string`/`UnicodeString` and `WideString`. However, it is not the fastest and it requires additional logic to handle surrogate characters. UTF-32 is the most universal, but at the same time the slowest encoding. Byte-encodings is understood as the UTF-8 or any of the supported SBCS (Ansi). This kind of interface is the fastest and it is universal for ASCII-characters, but it can be difficult at the identification of used encoding.
* **There are 3 types of its own strings used when parsing**: `ByteString`, `UTF16String` and `UTF32String`. The peculiarity of these strings lies in the fact that for keeping data they do not take memory in the heap, but they refer to text data (`TCachedBuffer`), which significantly increases the performance. All [CachedString](https://github.com/d-mozulyov/CachedTexts#cachedstrings-bytestringutf16stringutf32string)-types have the same interface, which consists of properties, functions and overloaded operators, allowing to carry out a wide range of tasks along with the system string types. Furthermore they are faster than system counterparts. To convert from one [CachedString](https://github.com/d-mozulyov/CachedTexts#cachedstrings-bytestringutf16stringutf32string)-type to another there is a [TTemporaryString](https://github.com/d-mozulyov/CachedTexts#ttemporarystring) type.
* For parsing and generation of texts there are standard classes: [CachedTextReaders](https://github.com/d-mozulyov/CachedTexts#cachedtextreaders-tbytetextreadertutf16textreadertutf32textreader) (`TByteTextReader`, `TUTF16TextReader`, `TUTF32TextReader`) and [CachedTextWriters](https://github.com/d-mozulyov/CachedTexts#cachedtextwriters-tbytetextwritertutf16textwritertutf32textwriter) (`TByteTextWriter`, `TUTF16TextWriter`, `TUTF32TextWriter`).
* (*Not yet implemented*) There are standard classes for popular markup languages: XML, HTML and JSON. For low level Simple-API interfaces (like "MSXMLSAX2") it is used Byte-encodings. For the Document Object Model (DOM) it is used `UnicodeString`.
* Despite the fact that [CachedString](https://github.com/d-mozulyov/CachedTexts#cachedstrings-bytestringutf16stringutf32string)-types quite quickly compare with 
string constants, the problem of identification of strings (such as serialization) is quite demanding to resources. Many people use solutions based on binary-trees or hash-tables, however, CachedTexts library contains the [CachedSerializer](https://github.com/d-mozulyov/CachedTexts#cachedserializer)-utility, allowing to achieve maximum performance at the expense of code generation.

[Demo.zip]( http://dmozulyov.ucoz.net/CachedTexts/Demo.zip)
![](http://dmozulyov.ucoz.net/CachedTexts/ScreenShots.png)

##### CachedTextReaders: TByteTextReader/TUTF16TextReader/TUTF32TextReader
There are several classes for sequential reading of text data: `TByteTextReader`, `TUTF16TextReader` and `TUTF32TextReader`. You can choose any class for parsing in dependence which encoding is more comfortable to use. In case the encoding of the source text data is different, the conversion will be executed automatically, but it might significantly slow down the application execution. The most of text files are in the byte-encoding, so it is recommended to use the `TByteTextReader`-class for parts of a code which are demanding for performance, because the automatic conversion of text will not be made and `ByteString` is the fastest string type.

Every `TCachedTextReader`-class has two main constructors: `Create` and `CreateFromFile`. In both cases the source encoding is determined by the BOM. If the BOM is absent, it will be considered the parameter `DefaultByteEncoding`. This parameter may be equal to CODEPAGE_UTF8 or one of SBCS-encoding. The constructor `CreateDirect` can be used when the source encoding and the conversion context are directly defined and BOM is not considered.

The functionality of the `TCachedTextReader`-class has much in common with the functionality of the `TCachedReader`-class. In both classes an access can be carried out with properties `Current`, `Overflow`, `Margin` and the function `Flush`. There are also high-level functions: `ReadData`, `Skip`, `ReadChar` and two kinds of `Readln`. It is strongly recommended to use `Readln` function for text data consisting of many lines.
```pascal
type
  TByteTextReader/TUTF16TextReader/TUTF32TextReader = class(TCachedTextReader)
  public
    constructor Create({Encoding for TByteTextReader,} const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile({Encoding for TByteTextReader,} const FileName: string; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False);
    {for TByteTextReader:} constructor CreateDefault(const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    {for TByteTextReader:} constructor CreateDefaultFromFile(const FileName: string; const DefaultByteEncoding: Word = 0);
  
    procedure ReadData(var Buffer; const Count: NativeUInt); 
    procedure Skip(const Count: NativeUInt);
    function Flush: NativeUInt;
    function Readln(var S: ByteString/UTF16String/UTF32String): Boolean;
    function Readln(var S: UnicodeString): Boolean;
    function ReadChar: UCS4Char; 

    property Current: PByte read/write
    property Overflow: PByte read
    property Margin: NativeInt read
    property Finishing: Boolean read
    property EOF: Boolean read/write
    property Converter: TUniConvReReader read
    property Source: TCachedReader read
    property Owner: Boolean read/write
    property FileName: string read
  end;
```
Text parsing example:
```pascal
const
  URL_ID = '<a href=';
  URL_ID_LENGTH = Length(URL_ID);

// standard (slow) way to parse text file
procedure ParseStd(const FileName: string);
var
  Text: TextFile;
  S, URL: string;
  P: Integer;
begin
  AssignFile(Text, FileName);
  Reset(Text);
  while (not EOF(Text)) do
  begin
    Readln(Text, S);

    // find '<a href='
    P := Pos(URL_ID, S);
    if (P = 0) then Continue;

    // parse URL
    Delete(S, 1, P + URL_ID_LENGTH - 1);
    P := Pos('"', S);
    if (P = 0) then Continue;
    Delete(S, 1, P);
    P := Pos('"', S);
    if (P <> 0) then
    begin
      URL := Copy(S, 1, P - 1);
      Writeln(URL); // display URL to the console
    end;
  end;
  CloseFile(Text);
end;

// cached (extremely fast) way to parse text file
procedure Parse(const FileName: string);
var
  Text: TUTF16TextReader;
  S, URL: CachedTexts.UTF16String;
  P: Integer;
begin
  Text := TUTF16TextReader.CreateFromFile(FileName);
  try
    while (Text.Readln(S)) do
    begin
      // find '<a href='
      P := S.Pos(URL_ID);
      if (P < 0) then Continue;

      // parse URL
      S.Skip(P);
      P := S.CharPos('"');
      if (P < 0) then Continue;
      S.Skip(P + 1);
      P := S.CharPos('"');
      if (P >= 0) then
      begin
        URL := S.SubString(0, P);
        Writeln({Implicit operator}string(URL)); // display URL to the console
      end;
    end;
  finally
    Text.Free;
  end;
end;
```

##### CachedStrings: ByteString/UTF16String/UTF32String
CachedString - is a simple structure that contains a pointer to the characters, string length and a set of flags. The peculiarity of these strings lies in the fact that for keeping data they do not take memory in the heap, but they refer to text data (`CachedBuffer`), which significantly increases the performance
```pascal
type
  ByteString/UTF16String/UTF32String = record
  public
    property Chars: PChar read/write
    property Length: NativeUInt read/write
    property Ascii: Boolean read/write
    property References: Boolean read/write (*useful for &amp;-like character references*) 
    property Tag: Byte read/write
    property Empty: Boolean read/write
    
    procedure Assign(AChars: PChar; ALength: NativeUInt);
    procedure Assign(const S: string);
    procedure Delete(const From, Count: NativeUInt);
    
    function DetermineAscii: Boolean;
    function TrimLeft: Boolean;
    function TrimRight: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): CachedString;
    function SubString(const Count: NativeUInt): CachedString;
    function Skip(const Count: NativeUInt): Boolean;
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal;
    
    function CharPos(const C: Char; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: Char; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: CachedString; const From: NativeUInt = 0): NativeInt;
    function Pos(const AChars: PChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: string; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const S: CachedString; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const AChars: PChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
    function PosIgnoreCase(const S: string; const From: NativeUInt = 0): NativeInt;
  public
    function ToBoolean: Boolean;
    function ToBooleanDef(const Default: Boolean): Boolean;
    function TryToBoolean(out Value: Boolean): Boolean;
    function ToHex: Integer;
    function ToHexDef(const Default: Integer): Integer;
    function TryToHex(out Value: Integer): Boolean;
    function ToInteger: Integer;
    function ToIntegerDef(const Default: Integer): Integer;
    function TryToInteger(out Value: Integer): Boolean;
    function ToCardinal: Cardinal;
    function ToCardinalDef(const Default: Cardinal): Cardinal;
    function TryToCardinal(out Value: Cardinal): Boolean;
    function ToHex64: Int64;
    function ToHex64Def(const Default: Int64): Int64;
    function TryToHex64(out Value: Int64): Boolean;
    function ToInt64: Int64;
    function ToInt64Def(const Default: Int64): Int64;
    function TryToInt64(out Value: Int64): Boolean;
    function ToUInt64: UInt64;
    function ToUInt64Def(const Default: UInt64): UInt64;
    function TryToUInt64(out Value: UInt64): Boolean;
    function ToFloat: Extended;
    function ToFloatDef(const Default: Extended): Extended;
    function TryToFloat(out Value: Single): Boolean;
    function TryToFloat(out Value: Double): Boolean;
    function TryToFloat(out Value: TExtended80Rec): Boolean;
    function ToDate: TDateTime;
    function ToDateDef(const Default: TDateTime): TDateTime;
    function TryToDate(out Value: TDateTime): Boolean;
    function ToTime: TDateTime;
    function ToTimeDef(const Default: TDateTime): TDateTime;
    function TryToTime(out Value: TDateTime): Boolean;
    function ToDateTime: TDateTime;
    function ToDateTimeDef(const Default: TDateTime): TDateTime;
    function TryToDateTime(out Value: TDateTime): Boolean; 
  public
    procedure ToAnsiString/ToLowerAnsiString/ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0);
    procedure ToAnsiShortString/ToLowerAnsiShortString/ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String/ToLowerUTF8String/ToUpperUTF8String(var S: UTF8String);
    procedure ToUTF8ShortString/ToLowerUTF8ShortString/ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString/ToLowerWideString/ToUpperWideString(var S: WideString);
    procedure ToUnicodeString/ToLowerUnicodeString/ToUpperUnicodeString(var S: UnicodeString);
    procedure ToString/ToLowerString/ToUpperString(var S: string); 

    function ToAnsiString/ToLowerAnsiString/ToUpperAnsiString: AnsiString;
    function ToUTF8String/ToLowerUTF8String/ToUpperUTF8String: UTF8String;
    function ToWideString/ToLowerWideString/ToUpperWideString: WideString;
    function ToUnicodeString/ToLowerUnicodeString/ToUpperUnicodeString: UnicodeString;
    function ToString/ToLowerString/ToUpperString: string;
    class operator Implicit(const a: CachedString): string;  
  public
    function Equal/EqualIgnoreCase(const S: CachedString/AnsiString/UTF8String/WideString/UnicodeString): Boolean; 
    function Compare/CompareIgnoreCase(const S: CachedString/AnsiString/UTF8String/WideString/UnicodeString): NativeInt; 
    function Equal/EqualIgnoreCase(const AChars: PAnsiChar/PUTF8Char; const ALength: NativeUInt; const CodePage: Word): Boolean;
    function Compare/CompareIgnoreCase(const AChars: PAnsiChar/PUTF8Char; const ALength: NativeUInt; const CodePage: Word): NativeInt;
    function Equal/EqualIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const CodePage: Word): Boolean;
    function Compare/CompareIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const CodePage: Word): NativeInt;

    class operator Equal/NotEqual/GreaterThan/GreaterThanOrEqual/LessThan/LessThanOrEqual(const S: CachedString/AnsiString/UTF8String/WideString/UnicodeString): Boolean;  
  end;
```
*Supported date formats*: `YYYYMMDD`, `YYYY-MM-DD`, `-YYYY-MM-DD`, `DD.MM.YYYY`, `DD-MM-YYYY`, `DD/MM/YYYY`, `DD.MM.YY`, `DD-MM-YY`, `DD/MM/YY`, `YYYY` (YYYY-01-01), `YYYY-MM` (YYYY-MM-01), `--MM-DD` (2000-MM-DD), `--MM--` (2000-MM-01), `---DD` (2000-01-DD).

*Supported time formats*: `hh:mm:ss.zzzzzz`, `hh-mm-ss.zzzzzz`, `hh:mm:ss.zzz`, `hh-mm-ss.zzz`, `hh:mm:ss`, `hh-mm-ss`, `hhmmss`, `hh:mm`, `hh-mm`, `hhmm`.

##### CachedTextWriters: TByteTextWriter/TUTF16TextWriter/TUTF32TextWriter
There are several classes for sequential writeing of text data: `TByteTextWriter`, `TUTF16TextWriter` and `TUTF32TextWriter`. The functionality of the `TCachedTextWriter`-class has much in common with the functionality of the `TCachedWriter`-class. In both classes an access can be carried out with properties `Current`, `Overflow`, `Margin` and the function `Flush`. The function `WriteData` can be used to direct text data writing. Regardless of `TCachedTextWriter`-class encoding, the text data can be automatically convert to any other encoding - to do this you should specify the `BOM`-parameter in `Create`/`CreateFromFile` constructors, or `Context`-parameter in `CreateDirect` constructor.

`TCachedTextWriter`-classes allow you to write not only string lypes, also other common types: Booleans, Ordinals, Floats, DateTimes and Variants; functions `WriteFormat`, `WriteFormatUTF8` and `WriteFormatUnicode` are used for the text formatting. It is important to know that all these functions work faster than their SysUtils-analogues. Float and DateTime write parameters set in fields `FloatSettings` and `DateTimeSettings`.
```pascal
type
  TByteTextWriter/TUTF16TextWriter/TUTF32TextWriter = class(TCachedTextWriter)
  public
    constructor Create({Encoding for TByteTextWriter,} const Target: TCachedWriter; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile({Encoding for TByteTextWriter,} const FileName: string; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False);
    procedure WriteData(const Buffer; const Count: NativeUInt);
    function Flush: NativeUInt;

    property Current: PByte read/write
    property Overflow: PByte read
    property Margin: NativeInt read
    property EOF: Boolean read/write
    property Converter: TUniConvReWriter read
    property Target: TCachedWriter read
    property Owner: Boolean read/write
    property FileName: string read
  public
    FloatSettings: TFloatSettings;
    DateTimeSettings: TDateTimeSettings;

    procedure WriteCRLF;
    procedure WriteAscii(const AChars: PAnsiChar; const ALength: NativeUInt);
    procedure WriteUnicodeAscii(const AChars: PUnicodeChar; const ALength: NativeUInt);
    procedure WriteUCS4Ascii(const AChars: PUCS4Char; const ALength: NativeUInt);
    procedure WriteAnsiChars(const AChars: PAnsiChar; const ALength: NativeUInt; const CodePage: Word);
    procedure WriteUTF8Chars(const AChars: PUTF8Char; const ALength: NativeUInt);
    procedure WriteUnicodeChars(const AChars: PUnicodeChar; const ALength: NativeUInt);
    procedure WriteUCS4Chars(const AChars: PUCS4Char; const ALength: NativeUInt);
    
    procedure WriteByteString(const S: ByteString);
    procedure WriteUTF16String(const S: UTF16String);
    procedure WriteUTF32String(const S: UTF32String);
    
    procedure WriteAnsiString(const S: AnsiString);
    procedure WriteShortString(const S: ShortString; const CodePage: Word = 0);
    procedure WriteUTF8String(const S: UTF8String);
    procedure WriteWideString(const S: WideString);
    procedure WriteUnicodeString(const S: UnicodeString);
    procedure WriteUCS4String(const S: UCS4String; const NullTerminated: Boolean = True);
    
    procedure WriteFormat(const FmtStr: AnsiString; const Args: array of const);
    procedure WriteFormatUTF8(const FmtStr: UTF8String; const Args: array of const);
    procedure WriteFormatUnicode(const FmtStr: UnicodeString; const Args: array of const);
  public
    procedure WriteBoolean(const Value: Boolean);
    procedure WriteBooleanOrdinal(const Value: Boolean);
    procedure WriteInteger(const Value: Integer; const Digits: NativeUInt = 0);
    procedure WriteHex(const Value: Integer; const Digits: NativeUInt = 0);
    procedure WriteCardinal(const Value: Cardinal; const Digits: NativeUInt = 0);
    procedure WriteInt64(const Value: Int64; const Digits: NativeUInt = 0);
    procedure WriteHex64(const Value: Int64; const Digits: NativeUInt = 0);
    procedure WriteUInt64(const Value: UInt64; const Digits: NativeUInt = 0);
    procedure WriteFloat(const Value: Extended; const Settings: TFloatSettings);
    procedure WriteFloat(const Value: Extended);
    procedure WriteDate(const Value: TDateTime; const Settings: TDateTimeSettings);
    procedure WriteDate(const Value: TDateTime);
    procedure WriteTime(const Value: TDateTime; const Settings: TDateTimeSettings);
    procedure WriteTime(const Value: TDateTime);
    procedure WriteDateTime(const Value: TDateTime; const Settings: TDateTimeSettings);
    procedure WriteDateTime(const Value: TDateTime);
    procedure WriteVariant(const Value: Variant; const FloatSettings: TFloatSettings; const DateTimeSettings: TDateTimeSettings);
    procedure WriteVariant(const Value: Variant);
  end;
```  
##### TTemporaryString
Memory manager operations and reference counting can take almost all the time during the parsing. All the system string types are served by intenal System.pas module functions and they produce several difficult operations for redistribution of allocated memory, which has a bad influence on performance during such prevalent operations as initialization, concatenation and finalization. Because of this the major emphasis in CachedTexts library is based on static-memory strings: ByteString, UTF16String and UTF32String. There are some goals though difficult to be solved without dynamic memory allocation, e.g. unpacking XML-string, which contains character references, or converting ByteString to UTF16String. Special for such tasks there is `TTemporaryString` type based on dynamic array of byte and memory reserve principle, which means that memory is meant to be never or rarely reallocated. `TTemporaryString` can keep only one of three data types at the same time: ByteString, UTF16String or UTF32String. `InitByteString`, `InitUTF16String` or `InitUTF32String` methods can be caused anytime. Data filling, converting and concatenation are executed due to `Append` methods. Data is added to the end of string or converted to necessary encoding previously.
One of the most important feature of `TTemporaryString` is an opportunity of system string types “emulation”. In this case special system header (which allows compiler Delphi using `TTemporaryString` as “constant system strings”) is added to character data. It might be useful if your algorithms or functions use system strings, e.g. `Writeln`, `ExtractFileName` or `StrToDate(FormatSettings)`. However be careful, because emulated string lifetime is restricted by `TTemporaryString` data lifetime. Emulated string use as a temporary string constant is highly recommended. For using real system strings choose `CachedString.ToString`-methods or `UniqueString` after string variable assignment.
```pascal
program Produce;
var
  Temp: TTemporaryString;
  P: PUnicodeString;
  S: UnicodeString;
begin
  // initialization
  Temp.InitUTF16String;

  // concatenation and automatic conversion
  Temp.Append(UnicodeString('Delphi'));
  Temp.Append(AnsiString(' is the way to build applications for'));
  Temp.Append(UTF8String(' Windows 10, Mac,'), ccUpper);
  Temp.Append(WideString(' Mobile and more.'), ccLower);

  // system string
  Writeln(Temp.CastUTF16String.ToUnicodeString);

  // constant system string emulation
  P := Temp.EmulateUnicodeString;
  Writeln(P^);

  // copying the constant system string
  S := P^;
  UniqueString(S);
  Writeln(S);

  // reinitialization
  Temp.InitByteString(CODEPAGE_DEFAULT);
  Temp.Append(UTF8String('Delphi is the best.'));
  Writeln(Temp.EmulateAnsiString^);

  Readln;
end.
```
Output:
```
Delphi is the way to build applications for WINDOWS 10, MAC, mobile and more.
Delphi is the way to build applications for WINDOWS 10, MAC, mobile and more.
Delphi is the way to build applications for WINDOWS 10, MAC, mobile and more.
Delphi is the best.
```
##### CachedSerializer
Utility `CachedSerializer` works for the one and only aim - to identificate string data with the maximum performance. You can build the project from the source in folder "utilities/CachedSerializer" or download [binary]( http://dmozulyov.ucoz.net/CachedTexts/CachedSerializer.zip) with examples. As the first argument of command line utility gets the path of a text file, which contains options and identifiers. It’s necessary to have the following options for serialization:
* `-<encoding>`. "-utf16", "-utf8", "-utf32" and the other code page encodings can act as an encoding option, e.g. "-1250" (you can see the whole list of SBCS-encodings in [UniConv](https://github.com/d-mozulyov/UniConv#supported-encodings) library description). "-raw" means `CODEPAGE_RAWDATA`, "-user" means `CODEPAGE_USERDEFINED`, "-ansi" means `CODEPAGE_DEFAULT`. "-ansi" is a default encoding. If your `ByteString` identifier contains only ASCII-characters, then encoding is unnecessary, you can specify "-ansi" or don't do this at all.
* `-p"<variable_name>"` or `-p"<pointer_name>:<length_name>"` or `-p"<pointer_name>:<length_name>:<code_indent>"`. Serialization goes for 2 parameters: character pointer and character length. If your identifier is stored in `CachedString`, then use `<variable_name>`, so that serialization will be going for parameters `<Name>.Chars` and `<Name>.Length`. Default value is `"S"`. Default code indent is `0`.
* `-i`. This option tells that serialization will be insensitive.
* `-f"<Name(-SType)>:<Prefix>"` or `-f"<Name(-SType)>:<Prefix>:<TypeName>"`. Option `-f` helps to generate function `<Name>` with string parameter `S`. If `-SType` not defined - `CachedString` will be used. Ordinal constant (`<PREFIX>IDENTIFIERN = N`) or enumerate values (`<TypeName> = <prefix>Identifier1, <prefix>Identifier2, …)` will be generated for each identifier.
* `-fn"<Name(-SType)>:<Prefix>"` or `-fn"<Name(-SType)>:<Prefix>:<TypeName>"`. Option `-fn` meaning is the same as `-f`, but only serialization code will be generated.
* `-s"FileName"`. This option allows you to save the generated code into a file.

Each of these options can be mentioned as a command line argument. Besides, the following options are permitted:
* `-nolog`. Don't display the generated code in the console.
* `-nocopy`. Don't copy the generated code to the clipboard.
* `-nowait`. Don't wait for press Enter after code generation.

Each text file line can be introduced in several formats:
* `<identifier>`
* `<identifier>::<implementation>`
* `<identifier>:<marker>:<implementation>`
* `<identifier>:<marker>`

Besides `<identifier>` there's an important code  `<implementation>`, which is called for `<identifier>` case. If options `-f`  or `-fn` are mentioned, then `<implementation>` will be made automatically. If there's a situation where the same `<implementation>` must be used for several `<identifier>` define `<marker>` - some string constant. For writing `<identifier>`, `<marker>` or `<implementation>` the following special symbols are permitted: `"\:"`, `"\\"`, `"\n"`, `"\r"`, `"\t"` (tab), `"\s"` (space).

File an example serialization ("examples/simple1.txt"):
```
-ansi -f"ValueToID-AnsiString:ID_" -p"S:Length(S)"
sheet
row
cell
data
value
style
```
Output:
```pascal
const
  ID_UNKNOWN = 0;
  ID_CELL = 1;
  ID_DATA = 2;
  ID_ROW = 3;
  ID_SHEET = 4;
  ID_STYLE = 5;
  ID_VALUE = 6;

function ValueToID(const S: AnsiString): Cardinal;
begin
  // default value
  Result := ID_UNKNOWN;

  // byte ascii
  with PMemoryItems(S)^ do
  case Length(S) of 
    3: if (Words[0] + Bytes[2] shl 16 = $776F72) then Result := ID_ROW; // "row"
    4: case (Cardinals[0]) of // "cell", "data"
         $6C6C6563: Result := ID_CELL; // "cell"
         $61746164: Result := ID_DATA; // "data"
       end;
    5: case (Cardinals[0]) of // "sheet", "style", "value"
         $65656873: if (Bytes[4] = $74) then Result := ID_SHEET; // "sheet"
         $6C797473: if (Bytes[4] = $65) then Result := ID_STYLE; // "style"
         $756C6176: if (Bytes[4] = $65) then Result := ID_VALUE; // "value"
       end;
  end;
end;
```
Change options line to `-f"ValueToEnum:tk:TTagKind"` ("examples/simple2.txt"):
```pascal
type
  TTagKind = (tkUnknown, tkCell, tkData, tkRow, tkSheet, tkStyle, tkValue);

function ValueToEnum(const S: ByteString): TTagKind;
begin
  // default value
  Result := tkUnknown;

  // byte ascii
  with PMemoryItems(S.Chars)^ do
  case S.Length of 
    3: if (Words[0] + Bytes[2] shl 16 = $776F72) then Result := tkRow; // "row"
    4: case (Cardinals[0]) of // "cell", "data"
         $6C6C6563: Result := tkCell; // "cell"
         $61746164: Result := tkData; // "data"
       end;
    5: case (Cardinals[0]) of // "sheet", "style", "value"
         $65656873: if (Bytes[4] = $74) then Result := tkSheet; // "sheet"
         $6C797473: if (Bytes[4] = $65) then Result := tkStyle; // "style"
         $756C6176: if (Bytes[4] = $65) then Result := tkValue; // "value"
       end;
  end;
end;
```
##### Inspiring bonus: my photo from modern town Delphi in Greece :blush:
![](https://pp.vk.me/c624529/v624529659/2fbda/94Bls0F-XMQ.jpg)