# CachedTexts

Cached Texts is a powerful and compact cross-platform library aimed at parsing and generating of text data with the maximum possible performance. The library is characterized by the following:
* Code stored in the module "CachedTexts.pas" and depends on the two other libraries: [CachedBuffers](https://github.com/d-mozulyov/CachedBuffers) and [UniConv](https://github.com/d-mozulyov/UniConv).
* There are declared the classes `TUniConvReReader` and `TUniConvReWriter` which allow to process sequential conversion of text from one encoding to another "on-the-fly".
* There are 3 possible basic encodings for parsing and generation of the text: 
Byte-encoding, UTF-16 and UTF-32. Each of them has its advantages and disadvantages. UTF-16 is the most common encoding. In Delphi it matches such types as `string`/`UnicodeString` and `WideString`. However, it is not the fastest and it requires additional logic to handle surrogate characters. UTF-32 is the most universal, but at the same time the slowest encoding. Byte-encodings is understood as the UTF-8 or any of the supported SBCS (Ansi). This kind of interface is the fastest and it is universal for ASCII-characters, but it can be difficult at the identification of used encoding.
* **There are 3 types of its own strings used when parsing**: `ByteString`, `UTF16String` and `UTF32String`. The peculiarity of these strings lies in the fact that for keeping data they do not give memory in the heap, but they refer to data in CachedBuffer, which significantly increases the productivity. The peculiarity of these strings lies in the fact that for keeping data they do not take memory in the heap, but they refer to data in `CachedBuffer`, which significantly increases the performance. All `"CachedString"`-types have the same interface, which consists of properties, functions and overloaded operators, allowing to carry out a wide range of tasks along with the standard string types. Furthermore they are faster than standard counterparts. To convert from one `"CachedString"`-type to another there is a `TCachedStringConverter` type (*not yet implemented*).
* For parsing and generation of texts there are standard classes: `TByteTextReader`/`TUTF16TextReader`/`TUTF32TextReader` and 
`TByteTextWriter`/`TUTF16TextWriter`/`TUTF32TextWriter` (*not yet implemented*).
* (*Not yet implemented*) There are standard classes for popular markup languages: XML, HTML and JSON. For low level Simple-API interfaces (like "MSXMLSAX2") it is used Byte-encodings. For the Document Object Model (DOM) it is used `UnicodeString`.
* Despite the fact that `"CachedString"`-types quite quickly compare with 
string constants, the problem of identification of strings (such as serialization) is quite demanding to resources. Many people use solutions based on binary-trees or hash-tables, however, CachedTexts library contains the `CachedSerializer`-utility, allowing to achieve maximum performance at the expense of code generation (*not yet implemented*).

**Currently, the library is in the unofficial release.**

##### Text parsing example
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
      S.Offset(P);
      P := S.CharPos('"');
      if (P < 0) then Continue;
      S.Offset(P + 1);
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

##### "CachedStrings": ByteString/UTF16String/UTF32String
```pascal
type
  ByteString/UTF16String/UTF32String = record
  public
    property Chars: PChar read/write
    property Length: NativeUInt read/write
    property Ascii: Boolean read/write
    property References: Boolean read/write (*useful for &amp;-like character references*) 
    property Empty: Boolean read/write
    
    procedure Assign(AChars: PChar; ALength: NativeUInt);
    procedure Assign(const S: string);
    function DetermineAscii: Boolean;
    
    function TrimLeft: Boolean;
    function TrimRight: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): CachedString;
    function SubString(const Count: NativeUInt): CachedString;
    function Offset(const Count: NativeUInt): Boolean;
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal;
    
    function CharPos(const C: Char; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: Char; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: CachedString; const From: NativeUInt = 0): NativeInt; overload;
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

##### Inspiring bonus: my photo from modern town Delphi in Greece :blush:
![](https://pp.vk.me/c624529/v624529659/2fbda/94Bls0F-XMQ.jpg)