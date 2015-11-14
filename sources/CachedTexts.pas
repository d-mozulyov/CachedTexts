unit CachedTexts;

{******************************************************************************}
{ Copyright (c) 2014 Dmitry Mozulyov                                           }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{ repository: https://github.com/d-mozulyov/CachedTexts                        }
{                                                                              }
{ see also:                                                                    }
{ https://github.com/d-mozulyov/UniConv                                        }
{ https://github.com/d-mozulyov/CachedBuffers                                  }
{******************************************************************************}


// compiler directives
{$ifdef FPC}
  {$mode delphi}
  {$asmmode intel}
  {$define INLINESUPPORT}
  {$ifdef CPU386}
    {$define CPUX86}
  {$endif}
  {$ifdef CPUX86_64}
    {$define CPUX64}
  {$endif}
{$else}
  {$if CompilerVersion >= 24}
    {$LEGACYIFEND ON}
  {$ifend}
  {$if CompilerVersion >= 15}
    {$WARN UNSAFE_CODE OFF}
    {$WARN UNSAFE_TYPE OFF}
    {$WARN UNSAFE_CAST OFF}
  {$ifend}
  {$if CompilerVersion >= 17}
    {$define INLINESUPPORT}
  {$ifend}
  {$if CompilerVersion < 23}
    {$define CPUX86}
  {$else}
    {$define UNITSCOPENAMES}
  {$ifend}
  {$if CompilerVersion >= 21}
    {$WEAKLINKRTTI ON}
    {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$ifend}
  {$if (not Defined(NEXTGEN)) and (CompilerVersion >= 20)}
    {$define INTERNALCODEPAGE}
  {$ifend}
{$endif}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$O+}{$R-}{$I-}{$Q-}{$W-}
{$if Defined(CPUX86) or Defined(CPUX64)}
  {$define CPUINTEL}
{$ifend}
{$if Defined(CPUX64) or Defined(CPUARM64)}
  {$define LARGEINT}
{$else}
  {$define SMALLINT}
{$ifend}
{$ifdef KOL_MCK}
  {$define KOL}
{$endif}
{$ifdef INLINESUPPORT}
  {$define OPERATORSUPPORT}
{$endif}


//   {$undef INLINESUPPORT}
interface
  uses {$ifdef UNITSCOPENAMES}System.Types, System.SysConst{$else}Types, SysConst{$endif},
       {$ifdef MSWINDOWS}{$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},{$endif}
       {$ifdef POSIX}Posix.String_, Posix.SysStat, Posix.Unistd,{$endif}
       {$ifdef KOL}
         KOL, err
       {$else}
         {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif}
       {$endif},
       CachedBuffers, UniConv;

type
  // standard types
  {$ifdef FPC}
    PUInt64 = ^UInt64;
  {$else}
    {$if CompilerVersion < 15}
      UInt64 = Int64;
      PUInt64 = ^UInt64;
    {$ifend}
    {$if CompilerVersion < 19}
      NativeInt = Integer;
      NativeUInt = Cardinal;
    {$ifend}
    {$if CompilerVersion < 22}
      PNativeInt = ^NativeInt;
      PNativeUInt = ^NativeUInt;
    {$ifend}
  {$endif}
  {$if Defined(FPC) or (CompilerVersion < 23)}
  TExtended80Rec = Extended;
  PExtended80Rec = ^TExtended80Rec;
  {$ifend}
  TBytes = array of Byte;
  PBytes = ^TBytes;

  // exception class
  ECachedText = class(Exception)
  {$ifdef KOL}
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);
    constructor CreateRes(Ident: NativeUInt); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    constructor CreateResFmt(Ident: NativeUInt; const Args: array of const); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const); overload;
  {$endif}
  end;

  // CachedBuffers types
  ECachedBuffer = CachedBuffers.ECachedBuffer;
  TCachedBufferKind = CachedBuffers.TCachedBufferKind;
  TCachedBufferCallback = CachedBuffers.TCachedBufferCallback;
  TCachedBufferProgress = CachedBuffers.TCachedBufferProgress;
  TCachedBufferMemory = CachedBuffers.TCachedBufferMemory;
  PCachedBufferMemory = CachedBuffers.PCachedBufferMemory;
  TCachedBuffer = CachedBuffers.TCachedBuffer;
  TCachedReader = CachedBuffers.TCachedReader;
  TCachedWriter = CachedBuffers.TCachedWriter;
  TCachedReReader = CachedBuffers.TCachedReReader;
  TCachedReWriter = CachedBuffers.TCachedReWriter;
  TCachedFileReader = CachedBuffers.TCachedFileReader;
  TCachedFileWriter = CachedBuffers.TCachedFileWriter;
  TCachedMemoryReader = CachedBuffers.TCachedMemoryReader;
  TCachedMemoryWriter = CachedBuffers.TCachedMemoryWriter;
  {$ifdef MSWINDOWS}
  TCachedResourceReader = CachedBuffers.TCachedResourceReader;
  {$endif}

  // UniConv types
  UnicodeChar = UniConv.UnicodeChar;
  PUnicodeChar = UniConv.PUnicodeChar;
  {$ifNdef UNICODE}
  UnicodeString = UniConv.UnicodeString;
  PUnicodeString = UniConv.PUnicodeString;
  RawByteString = UniConv.RawByteString;
  PRawByteString = UniConv.PRawByteString;
  {$endif}
  {$ifdef NEXTGEN}
  AnsiChar = UniConv.AnsiChar;
  PAnsiChar = UniConv.PAnsiChar;
  AnsiString = UniConv.AnsiString;
  PAnsiString = UniConv.PAnsiString;
  UTF8String = UniConv.UTF8String;
  PUTF8String = UniConv.PUTF8String;
  RawByteString = UniConv.RawByteString;
  PRawByteString = UniConv.PRawByteString;
  WideString = UniConv.WideString;
  PWideString = UniConv.PWideString;
  ShortString = UniConv.ShortString;
  PShortString = UniConv.PShortString;
  {$endif}
  UTF8Char = UniConv.UTF8Char;
  PUTF8Char = UniConv.PUTF8Char;
  TCharCase = UniConv.TCharCase;
  PCharCase = UniConv.PCharCase;
  TBOM = UniConv.TBOM;
  PBOM = UniConv.PBOM;
  PUniConvContext = UniConv.PUniConvContext;
  TUniConvContext = UniConv.TUniConvContext;
  PUniConvSBCS = UniConv.PUniConvSBCS;
  TUniConvSBCS = UniConv.TUniConvSBCS;
  TUniConvCompareOptions = UniConv.TUniConvCompareOptions;
  PUniConvCompareOptions = UniConv.PUniConvCompareOptions;

const
  // UniConv constants
  ccOriginal = UniConv.ccOriginal;
  ccLower = UniConv.ccLower;
  ccUpper = UniConv.ccUpper;
  bomNone = UniConv.bomNone;
  bomUTF8 = UniConv.bomUTF8;
  bomUTF16 = UniConv.bomUTF16;
  bomUTF16BE = UniConv.bomUTF16BE;
  bomUTF32 = UniConv.bomUTF32;
  bomUTF32BE = UniConv.bomUTF32BE;
  bomUCS2143 = UniConv.bomUCS2143;
  bomUCS3412 = UniConv.bomUCS3412;
  bomUTF1 = UniConv.bomUTF1;
  bomUTF7 = UniConv.bomUTF7;
  bomUTFEBCDIC = UniConv.bomUTFEBCDIC;
  bomSCSU = UniConv.bomSCSU;
  bomBOCU1 = UniConv.bomBOCU1;
  bomGB18030 = UniConv.bomGB18030;
  CODEPAGE_UTF7 = UniConv.CODEPAGE_UTF7;
  CODEPAGE_UTF8 = UniConv.CODEPAGE_UTF8;
  CODEPAGE_UTF16  = UniConv.CODEPAGE_UTF16;
  CODEPAGE_UTF16BE = UniConv.CODEPAGE_UTF16BE;
  CODEPAGE_UTF32  = UniConv.CODEPAGE_UTF32;
  CODEPAGE_UTF32BE = UniConv.CODEPAGE_UTF32BE;
  CODEPAGE_UCS2143 = UniConv.CODEPAGE_UCS2143;
  CODEPAGE_UCS3412 = UniConv.CODEPAGE_UCS3412;
  CODEPAGE_UTF1 = UniConv.CODEPAGE_UTF1;
  CODEPAGE_UTFEBCDIC = UniConv.CODEPAGE_UTFEBCDIC;
  CODEPAGE_SCSU = UniConv.CODEPAGE_SCSU;
  CODEPAGE_BOCU1 = UniConv.CODEPAGE_BOCU1;
  CODEPAGE_USERDEFINED = UniConv.CODEPAGE_USERDEFINED;
  CODEPAGE_RAWDATA = UniConv.CODEPAGE_RAWDATA;
  UNKNOWN_CHARACTER = UniConv.UNKNOWN_CHARACTER;
  MAXIMUM_CHARACTER = UniConv.MAXIMUM_CHARACTER;

var
  // UniConv "constants"
  CODEPAGE_DEFAULT: Word;
  DEFAULT_UNICONV_SBCS: PUniConvSBCS;
  DEFAULT_UNICONV_SBCS_INDEX: NativeUInt;

type
  //
  TUniConvReReader = class(TCachedReReader)
  protected
    FGap: record
      Data: array[0..15] of Byte;
      Size: NativeUInt;
    end;
    FContext: PUniConvContext;
    function InternalCallback(Sender: TCachedBuffer; Data: PByte; Size: NativeUInt): NativeUInt;
  public
    constructor Create(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False; const BufferSize: NativeUInt = 0);
    property Context: PUniConvContext read FContext;
  end;

  //
  TUniConvReWriter = class(TCachedReWriter)
  protected
    FGap: record
      Data: array[0..15] of Byte;
      Size: NativeUInt;
    end;
    FContext: PUniConvContext;
    function InternalCallback(Sender: TCachedBuffer; Data: PByte; Size: NativeUInt): NativeUInt;
  public
    constructor Create(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False; const BufferSize: NativeUInt = 0);
    property Context: PUniConvContext read FContext;
  end;

type
  // CachedString types
  PCachedByteString = ^CachedByteString;
  PCachedUTF16String = ^CachedUTF16String;
  PCachedUTF32String = ^CachedUTF32String;

  ECachedString = class({$ifdef KOL}Exception{$else}EConvertError{$endif})
  public
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedByteString); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedUTF16String); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedUTF32String); overload;
  end;

  //
  CachedByteString = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Byte; SBCSIndex: ShortInt);
      2: (NativeFlags: NativeUInt);
    end;
    FChars: PAnsiChar;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSBCS: PUniConvSBCS; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetSBCS(Value: PUniConvSBCS); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUTF8(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCodePage: Word; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetCodePage(CodePageValue: Word);

    function GetAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    function GetBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function _LTrim(S: PByte; L: NativeUInt): Boolean;
    function _RTrim(S: PByte; H: NativeUInt): Boolean;
    function _Trim(S: PByte; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCaseUTF8: Cardinal;
    function _HashIgnoreCase(NF: NativeUInt): Cardinal;
    function _GetBool(S: PByte; L: NativeUInt): Boolean;
    function _GetHex(S: PByte; L: NativeInt): Integer;
    function _GetInt(S: PByte; L: NativeInt): Integer;
    function _GetInt_19(S: PByte; L: NativeUInt): NativeInt;
    function _GetHex64(S: PByte; L: NativeInt): Int64;
    function _GetInt64(S: PByte; L: NativeInt): Int64;
    function _GetFloat(S: PByte; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
  public
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;
    property Chars: PAnsiChar read FChars write FChars;
    property SBCSIndex: ShortInt read F.SBCSIndex write F.SBCSIndex;
    property SBCS: PUniConvSBCS read GetSBCS write SetSBCS;
    property UTF8: Boolean read GetUTF8 write SetUTF8;
    property CodePage: Word read GetCodePage write SetCodePage;
  public
    { basic methods }

    procedure Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP: Word = 0{$endif}); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: UTF8String); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: ShortString; const CP: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: TBytes; const CP: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function DetectAscii: Boolean;

    function LTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function RTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): CachedByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): CachedByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifNdef CPUINTEL}inline;{$endif}

    function CharPos(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: UnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToLowerAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUpperAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToLowerUTF8String(var S: UTF8String);
    procedure ToUpperUTF8String(var S: UTF8String);
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString);
    procedure ToLowerWideString(var S: WideString);
    procedure ToUpperWideString(var S: WideString);
    procedure ToUnicodeString(var S: UnicodeString);
    procedure ToLowerUnicodeString(var S: UnicodeString);
    procedure ToUpperUnicodeString(var S: UnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsLowerAnsiString: AnsiString read GetLowerAnsiString;
    property AsUpperAnsiString: AnsiString read GetUpperAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsLowerUTF8String: UTF8String read GetLowerUTF8String;
    property AsUpperUTF8String: UTF8String read GetUpperUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsLowerWideString: WideString read GetLowerWideString;
    property AsUpperWideString: WideString read GetUpperWideString;
    property AsUnicodeString: UnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsLowerUnicodeString: UnicodeString read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerWideString{$endif};
    property AsUpperUnicodeString: UnicodeString read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
    property AsLowerString: string read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerAnsiString{$endif};
    property AsUpperString: string read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperAnsiString{$endif};

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: CachedByteString): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedByteString): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedByteString): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: CachedByteString): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    { numeric conversion }

    function AsBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}

    property AsBoolean: Boolean read GetBoolean;
    property AsHex: Integer read GetHex;
    property AsInteger: Integer read GetInteger;
    property AsCardinal: Cardinal read GetCardinal;
    property AsHex64: Int64 read GetHex64;
    property AsInt64: Int64 read GetInt64;
    property AsUInt64: UInt64 read GetUInt64;
    property AsFloat: Extended read GetFloat;
    property AsDate: TDateTime read GetDate;
    property AsTime: TDateTime read GetTime;
    property AsDateTime: TDateTime read GetDateTime;
  end;

  //
  CachedUTF16String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Word);
      2: (NativeFlags: NativeUInt);
    end;
    FChars: PUnicodeChar;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    function GetBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function _LTrim(S: PWord; L: NativeUInt): Boolean;
    function _RTrim(S: PWord; H: NativeUInt): Boolean;
    function _Trim(S: PWord; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCase: Cardinal;
    function _GetBool(S: PWord; L: NativeUInt): Boolean;
    function _GetHex(S: PWord; L: NativeInt): Integer;
    function _GetInt(S: PWord; L: NativeInt): Integer;
    function _GetInt_19(S: PWord; L: NativeUInt): NativeInt;
    function _GetHex64(S: PWord; L: NativeInt): Int64;
    function _GetInt64(S: PWord; L: NativeInt): Int64;
    function _GetFloat(S: PWord; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
  public
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;
    property Chars: PUnicodeChar read FChars write FChars;
  public
    { basic methods }

    procedure Assign(const S: WideString); {$ifdef UNICODE}overload;{$endif}{$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    procedure Assign(const S: UnicodeString); overload; inline;
    {$endif}
    function DetectAscii: Boolean;

    function LTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function RTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): CachedUTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): CachedUTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: UnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToLowerAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUpperAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToLowerUTF8String(var S: UTF8String);
    procedure ToUpperUTF8String(var S: UTF8String);
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString);
    procedure ToLowerWideString(var S: WideString);
    procedure ToUpperWideString(var S: WideString);
    procedure ToUnicodeString(var S: UnicodeString);
    procedure ToLowerUnicodeString(var S: UnicodeString);
    procedure ToUpperUnicodeString(var S: UnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsLowerAnsiString: AnsiString read GetLowerAnsiString;
    property AsUpperAnsiString: AnsiString read GetUpperAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsLowerUTF8String: UTF8String read GetLowerUTF8String;
    property AsUpperUTF8String: UTF8String read GetUpperUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsLowerWideString: WideString read GetLowerWideString;
    property AsUpperWideString: WideString read GetUpperWideString;
    property AsUnicodeString: UnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsLowerUnicodeString: UnicodeString read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerWideString{$endif};
    property AsUpperUnicodeString: UnicodeString read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
    property AsLowerString: string read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerAnsiString{$endif};
    property AsUpperString: string read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperAnsiString{$endif};

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: CachedUTF16String): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedUTF16String): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedUTF16String): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: CachedUTF16String): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    { numeric conversion }

    function AsBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}

    property AsBoolean: Boolean read GetBoolean;
    property AsHex: Integer read GetHex;
    property AsInteger: Integer read GetInteger;
    property AsCardinal: Cardinal read GetCardinal;
    property AsHex64: Int64 read GetHex64;
    property AsInt64: Int64 read GetInt64;
    property AsUInt64: UInt64 read GetUInt64;
    property AsFloat: Extended read GetFloat;
    property AsDate: TDateTime read GetDate;
    property AsTime: TDateTime read GetTime;
    property AsDateTime: TDateTime read GetDateTime;
  end;



  //
  CachedUTF32String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Word);
      2: (NativeFlags: NativeUInt);
    end;
    FChars: PUCS4Char;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperAnsiString: AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUTF8String: UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    function GetWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperWideString: WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetLowerUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    function GetUpperUnicodeString: UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    function GetBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function _LTrim(S: PCardinal; L: NativeUInt): Boolean;
    function _RTrim(S: PCardinal; H: NativeUInt): Boolean;
    function _Trim(S: PCardinal; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCase: Cardinal;
    function _GetBool(S: PCardinal; L: NativeUInt): Boolean;
    function _GetHex(S: PCardinal; L: NativeInt): Integer;
    function _GetInt(S: PCardinal; L: NativeInt): Integer;
    function _GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
    function _GetHex64(S: PCardinal; L: NativeInt): Int64;
    function _GetInt64(S: PCardinal; L: NativeInt): Int64;
    function _GetFloat(S: PCardinal; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
  public
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;
    property Chars: PUCS4Char read FChars write FChars;
  public
    { basic methods }

    procedure Assign(const S: UCS4String; const NullTerminated: Boolean = True); {$ifdef INLINESUPPORT}inline;{$endif}
    function DetectAscii: Boolean;

    function LTrim: Boolean;
    function RTrim: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): CachedUTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): CachedUTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: UnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToLowerAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUpperAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToLowerUTF8String(var S: UTF8String);
    procedure ToUpperUTF8String(var S: UTF8String);
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString);
    procedure ToLowerWideString(var S: WideString);
    procedure ToUpperWideString(var S: WideString);
    procedure ToUnicodeString(var S: UnicodeString);
    procedure ToLowerUnicodeString(var S: UnicodeString);
    procedure ToUpperUnicodeString(var S: UnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsLowerAnsiString: AnsiString read GetLowerAnsiString;
    property AsUpperAnsiString: AnsiString read GetUpperAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsLowerUTF8String: UTF8String read GetLowerUTF8String;
    property AsUpperUTF8String: UTF8String read GetUpperUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsLowerWideString: WideString read GetLowerWideString;
    property AsUpperWideString: WideString read GetUpperWideString;
    property AsUnicodeString: UnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsLowerUnicodeString: UnicodeString read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerWideString{$endif};
    property AsUpperUnicodeString: UnicodeString read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
    property AsLowerString: string read {$ifdef UNICODE}GetLowerUnicodeString{$else}GetLowerAnsiString{$endif};
    property AsUpperString: string read {$ifdef UNICODE}GetUpperUnicodeString{$else}GetUpperAnsiString{$endif};

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: CachedUTF32String): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedUTF32String): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: CachedUTF32String): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: CachedUTF32String): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    { numeric conversion }

    function AsBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function AsDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryAsDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}

    property AsBoolean: Boolean read GetBoolean;
    property AsHex: Integer read GetHex;
    property AsInteger: Integer read GetInteger;
    property AsCardinal: Cardinal read GetCardinal;
    property AsHex64: Int64 read GetHex64;
    property AsInt64: Int64 read GetInt64;
    property AsUInt64: UInt64 read GetUInt64;
    property AsFloat: Extended read GetFloat;
    property AsDate: TDateTime read GetDate;
    property AsTime: TDateTime read GetTime;
    property AsDateTime: TDateTime read GetDateTime;
  end;



  //
  TCachedTextReader = class(TCachedReReader)
  private
//    function InternalCallback(Sender: TCachedReReader; Buffer: PByte; BufferSize: NativeUInt; Source: TCachedReader): NativeUInt;
    function GetEOF: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  protected
    FContext: TUniConvContext;

//    function GetIsDirect: Boolean; override;
    function DetectBOM(const Source: TCachedReader; const DefaultBOM: TBOM): TBOM;
    procedure InternalCreate(const Source: TCachedReader; const IsOwner: Boolean);
  public
    constructor Create(const Context: TUniConvContext; const Source: TCachedReader; const IsOwner: Boolean = False);

    property EOF: Boolean read GetEOF;
    property Context: TUniConvContext read FContext;
  end;

(*  TCachedTextWriter = class(TCachedReWriter)
  private
    function InternalCallback(Sender: TCachedReWriter; Buffer: Pointer; BufferSize: NativeUInt; Destination: TCachedWriter): NativeUInt;
  protected
    FContext: TUniConvContext;
  public
    constructor Create(const Context: TUniConvContext; const Destination: TCachedWriter; const IsOwner: Boolean = False);
    class function StaticCreate(var Static: TCachedStatic; const Context: TUniConvContext; const Destination: TCachedWriter; const IsOwner: Boolean = False): TCachedTextWriter; reintroduce;

    {methods}

    property Context: TUniConvContext read FContext;
  end; *)

  TCachedByteTextReader = class(TCachedTextReader)
  private
  protected
    FLookup: PUniConvSBCS;
    FNativeFlags: NativeUInt;
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: CachedByteString): Boolean;

    // single byte char set encodings lookup
    // nil in UTF8 encoding case
    property Lookup: PUniConvSBCS read FLookup;
  end;

 (* TCachedByteTextWriter = class(TCachedTextWriter)
  private
  protected
    FLookup: PUniConvSBCS;
  public

    // single byte char set encodings lookup
    // nil in UTF8 encoding case
    property Lookup: PUniConvSBCS read FLookup;
  end;
*)



  TCachedUTF16TextReader = class(TCachedTextReader)
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: CachedUTF16String): Boolean;
  end;


(*  TCachedUTF16TextWriter = class(TCachedTextWriter)


  end;  *)


  TCachedUTF32TextReader = class(TCachedTextReader)
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: CachedUTF32String): Boolean;
  end;

(*  TCachedUTF32TextWriter = class(TCachedTextWriter)


  end; *)

implementation

{ ECachedText }

{$ifdef KOL}
constructor ECachedText.Create(const Msg: string);
begin
  inherited Create(e_Custom, Msg);
end;

constructor ECachedText.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  inherited CreateFmt(e_Custom, Msg, Args);
end;

type
  PStrData = ^TStrData;
  TStrData = record
    Ident: Integer;
    Str: string;
  end;

function EnumStringModules(Instance: NativeInt; Data: Pointer): Boolean;
var
  Buffer: array [0..1023] of Char;
begin
  with PStrData(Data)^ do
  begin
    SetString(Str, Buffer, Windows.LoadString(Instance, Ident, Buffer, sizeof(Buffer)));
    Result := Str = '';
  end;
end;

function FindStringResource(Ident: Integer): string;
var
  StrData: TStrData;
  Func: TEnumModuleFunc;
begin
  StrData.Ident := Ident;
  StrData.Str := '';
  Pointer(@Func) := @EnumStringModules;
  EnumResourceModules(Func, @StrData);
  Result := StrData.Str;
end;

function LoadStr(Ident: Integer): string;
begin
  Result := FindStringResource(Ident);
end;

constructor ECachedText.CreateRes(Ident: NativeUInt);
begin
  inherited Create(e_Custom, LoadStr(Ident));
end;

constructor ECachedText.CreateRes(ResStringRec: PResStringRec);
begin
  inherited Create(e_Custom, System.LoadResString(ResStringRec));
end;

constructor ECachedText.CreateResFmt(Ident: NativeUInt;
  const Args: array of const);
begin
  inherited CreateFmt(e_Custom, LoadStr(Ident), Args);
end;

constructor ECachedText.CreateResFmt(ResStringRec: PResStringRec;
  const Args: array of const);
begin
  inherited CreateFmt(e_Custom, System.LoadResString(ResStringRec), Args);
end;
{$endif}


  {$ifNdef CPUX86}
    {$define CPUMANYREGS}
  {$endif}

  {$if Defined(MSWINDOWS) or Defined(FPC) or (CompilerVersion < 22)}
    {$define WIDE_STR_SHIFT}
  {$else}
    {$undef WIDE_STR_SHIFT}
  {$ifend}

type
  PByteArray = ^TByteArray;
  TByteArray = array[0..0] of Byte;

  PWordArray = ^TWordArray;
  TWordArray = array[0..0] of Word;

  PCardinalArray = ^TCardinalArray;
  TCardinalArray = array[0..0] of Cardinal;

  TNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
  PNativeIntArray = ^TNativeIntArray;

  PExtendedBytes = ^TExtendedBytes;
  TExtendedBytes = array[0..SizeOf(Extended)-1] of Byte;

  PUniConvSBCSEx = ^TUniConvSBCSEx;
  TUniConvSBCSEx = object(TUniConvSBCS) end;

  PUniConvContextEx = ^TUniConvContextEx;
  TUniConvContextEx = object(TUniConvContext) end;

var
  UNICONV_SUPPORTED_SBCS_HASH: array[0..High(UniConv.UNICONV_SUPPORTED_SBCS_HASH)] of Integer;
  UNICONV_UTF8_SIZE: TUniConvBB;

procedure InternalLookupsInitialize;
begin
  CODEPAGE_DEFAULT := UniConv.CODEPAGE_DEFAULT;
  DEFAULT_UNICONV_SBCS := UniConv.DEFAULT_UNICONV_SBCS;
  DEFAULT_UNICONV_SBCS_INDEX := UniConv.DEFAULT_UNICONV_SBCS_INDEX;

  Move(UniConv.UNICONV_SUPPORTED_SBCS_HASH, UNICONV_SUPPORTED_SBCS_HASH, SizeOf(UNICONV_SUPPORTED_SBCS_HASH));
  Move(UniConv.UNICONV_UTF8_SIZE, UNICONV_UTF8_SIZE, SizeOf(UNICONV_UTF8_SIZE));
end;

type
  TGap16 = record
    Data: array[0..15] of Byte;
    Size: NativeUInt;
  end;
  PGap16 = ^TGap16;

function Gap16Clear(Data: PByte; Size: NativeUInt; Gap: PGap16): NativeUInt;
begin
  if (Size >= Gap.Size) then
  begin
    Result := Gap.Size;
    Move(Gap.Data, Data^, Result);
    Gap.Size := 0;
  end else
  // Size < Gap.Size
  begin
    Result := Size;
    Move(Gap.Data, Data^, Result);

    Move(Gap.Data[Result], Gap.Data, Gap.Size - Result);
    Dec(Gap.Size, Result);
  end;
end;

{ TUniConvReReader }

constructor TUniConvReReader.Create(const Context: PUniConvContext;
  const Source: TCachedReader; const Owner: Boolean;
  const BufferSize: NativeUInt);
begin
  FContext := Context;
  inherited Create(InternalCallback, Source, Owner, BufferSize);
end;

function TUniConvReReader.InternalCallback(Sender: TCachedBuffer; Data: PByte;
  Size: NativeUInt): NativeUInt;
var
  Context: PUniConvContext;
  Reader: TCachedReader;
  Gap: PGap16;
  R: NativeInt;
begin
  Context := Self.Context;
  Reader := Self.Source;
  Gap := PGap16(@Self.FGap);

  Result := Gap16Clear(Data, Size, Gap);
  Inc(Data, Result);
  Dec(Size, Result);

  if (Size <> 0) and (not Reader.EOF) then
  repeat
    // conversion
    Context.Destination := Data;
    Context.DestinationSize := Size;
    Context.ModeFinalize := Reader.Finishing;
    Context.Source := Reader.Current;
    Context.SourceSize := Reader.Margin;
    R := Context.Convert;

    // increment
    Inc(Data, Context.DestinationWritten);
    Dec(Size, Context.DestinationWritten);
    Inc(Result, Context.DestinationWritten);
    Inc(Reader.Current, Context.SourceRead);

    // next iteration
    if (R <= 0) then
    begin
      // reader buffer fully read
      if (Reader.Finishing) then
      begin
        Reader.EOF := True;
        Exit;
      end else
      begin
        Reader.Flush;
      end;
    end else
    // if (R > 0) then
    begin
      // destination too small
      // convert to Gap
      Context.Destination := @Gap.Data;
      Context.DestinationSize := SizeOf(Gap.Data);
      Context.Source := Reader.Current;
      Context.SourceSize := Reader.Margin;
      Context.Convert;

      // converted sizes
      Gap.Size := Context.DestinationWritten;
      Inc(Reader.Current, Context.SourceRead);

      // copy Gap bytes
      Inc(Result, Gap16Clear(Data, Size, Gap));
      Exit;
    end;
  until (False);
end;


{ TUniConvReWriter }

constructor TUniConvReWriter.Create(const Context: PUniConvContext;
  const Target: TCachedWriter; const Owner: Boolean;
  const BufferSize: NativeUInt);
begin
  FContext := Context;
  inherited Create(InternalCallback, Target, Owner, BufferSize);
end;

function TUniConvReWriter.InternalCallback(Sender: TCachedBuffer; Data: PByte;
  Size: NativeUInt): NativeUInt;
var
  Context: PUniConvContext;
  Writer: TCachedWriter;
  Gap: PGap16;
  R: NativeInt;
begin
  Context := Self.Context;
  Writer := Self.Target;
  Gap := PGap16(@Self.FGap);
  Result := 0;
  if (Writer.EOF) then Exit;

  Context.ModeFinalize := (Size < Self.Memory.Size);
  Inc(Writer.Current, Gap16Clear(Writer.Current, Gap.Size, Gap));
  if (NativeUInt(Writer.Current) >= NativeUInt(Writer.Overflow)) then Writer.Flush;

  repeat
    // conversion
    Context.Source := Data;
    Context.SourceSize := Size;
    Context.Destination := Writer.Current;
    Context.DestinationSize := Writer.Margin + 16;
    R := Context.Convert;

    // increment
    Inc(Data, Context.SourceRead);
    Dec(Size, Context.SourceRead);
    Inc(Result, Context.SourceRead);
    Inc(Writer.Current, Context.DestinationWritten);

    // next iteration
    if (R > 0) then
    begin
      // writer buffer fully written
      Writer.Flush;
    end else
    // if (R <= 0) then
    begin
      // data buffer fully read
      Move(Data^, Gap.Data, Size);
      Gap.Size := Size;
      Inc(Result, Size);
      if (NativeUInt(Writer.Current) >= NativeUInt(Writer.Overflow)) then Writer.Flush;
      Exit;
    end;
  until (False);
end;



resourcestring
  SInvalidHex = '''%s'' is not a valid hex value';

const
  TEN = 10;
  HUNDRED = TEN * TEN;
  THOUSAND = TEN * TEN * TEN;
  MILLION = THOUSAND * THOUSAND;
  BILLION = THOUSAND * MILLION;
  NINE_BB = Int64(9) * BILLION * BILLION;
  TEN_BB = Int64(-8446744073709551616); //Int64(TEN)*BILLION*BILLION;
  _HIGHU64 = Int64({1}8446744073709551615);

  DIGITS_4 = 10000;
  DIGITS_8 = 100000000;
  DIGITS_12 = Int64(DIGITS_4) * Int64(DIGITS_8);
  DIGITS_16 = Int64(DIGITS_8) * Int64(DIGITS_8);


function Decimal64R21(R2, R1: Integer): Int64; {$ifNdef CPUX86} inline;
begin
  Result := Cardinal(R1) + (Int64(Cardinal(R2)) * BILLION);
end;
{$else .CPUX86}
asm
  mov ecx, edx
  mov edx, BILLION
  mul edx
  add eax, ecx
  adc edx, 0
end;
{$endif}

{$ifNdef CPUX86}
function Decimal64VX(const V: Int64; const X: NativeUInt): Int64; inline;
begin
  Result := V * TEN;
  Inc(Result, X);
end;
{$else .CPUX86}
function Decimal64VX(var V: Int64; const X: NativeUInt): Int64;
asm
  push edx

  // Result := V;
  mov edx, [eax + 4]
  mov eax, [eax]

  // Result := Result*10 + [ESP]
  lea ecx, [edx*4 + edx]
  mov edx, 10
  mul edx
  lea edx, [edx + ecx*2]
  pop ecx
  add eax, ecx
  adc edx, 0
end;
{$endif}

type
  TTenPowers = array[0..9] of Double;
  PTenPowers = ^TTenPowers;

const
  TEN_POWERS: array[Boolean] of TTenPowers = (
    (1, 1/10, 1/100, 1/1000, 1/(10*1000), 1/(100*1000), 1/(1000*1000),
     1/(10*MILLION), 1/(100*MILLION), 1/(1000*MILLION)),
    (1, 10, 100, 1000, 10*1000, 100*1000, 1000*1000, 10*MILLION, 100*MILLION,
     1000*MILLION)
  );

function TenPower(TenPowers: PTenPowers; I: NativeUInt): Extended;
{$ifNdef CPUX86}
var
  C: NativeUInt;
  LBase: Extended;
begin
  if (I <= 9) then
  begin
    Result := TenPowers[I];
  end else
  begin
    Result := 1;

    while (True) do
    begin
      if (I <= 9) then
      begin
        Result := Result * TenPowers[I];
        break;
      end else
      begin
        C := 9;
        Dec(I, 9);
        LBase := TenPowers[9];

        while (I >= C) do
        begin
          Dec(I, C);
          C := C + C;
          LBase := LBase * LBase;
        end;

        Result := Result * LBase;
        if (I = 0) then break;
      end;
    end;
  end;
end;
{$else .CPUX86}
asm
  cmp edx, 9
  ja @1

  // Result := TenPowers[I];
  fld qword ptr [EAX + EDX*8]
  ret

@1:
  // Result := 1;
  fld1

  // while (True) do
@loop:
  cmp edx, 9
  ja @2

  // Result := Result * TenPowers[I];
  fmul qword ptr [EAX + EDX*8]
  ret

@2:
  mov ecx, 9
  sub edx, 9
  // LBase := TenPowers[9];
  fld qword ptr [EAX + 9*8]

  // while (I >= C) do
  cmp edx, ecx
  jb @3
@loop_ic:
  sub edx, ecx
  add ecx, ecx
  // LBase := LBase * LBase;
  fmul st(0), st(0)

  cmp edx, ecx
  jae @loop_ic

@3:
  // Result := Result * LBase;
  fmulp
  // if (I = 0) then break;
  test edx, edx
  jnz @loop
end;
{$endif}


const
  DT_LEN_MIN: array[1..3] of NativeUInt = (4, 4, 4+4+1);
  DT_LEN_MAX: array[1..3] of NativeUInt = (11, 15, 11+15+1);

type
  TDateTimeBuffer = record
    DT: NativeUInt;
    Bytes: array[1..11+15+1] of Byte;
    Length: NativeUInt;
    Value: PDateTime;
  end;

  TMonthInfo = packed record
    Days: Word;
    Before: Word;
  end;
  PMonthInfo = ^TMonthInfo;

  TMonthTable = array[1-1..12-1] of TMonthInfo;
  PMonthTable = ^TMonthTable;

const
  DTSP = $e0{\t, \r, \n, ' ', 'T'};
  DTS1 = $e1{-};
  DTS2 = $e2{.};
  DTS3 = $e3{/};
  DTS4 = $e4{:};

  DT_BYTES: array[0..$7f] of Byte = (
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff,DTSP,DTSP, $ff, $ff,DTSP, $ff, $ff, // 00-0f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 10-1f
    DTSP, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff,DTS1,DTS2,DTS3, // 20-2f
       0,   1,   2,   3,   4,   5,   6,   7,     8,   9,DTS4, $ff, $ff, $ff, $ff, $ff, // 30-3f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 40-4f
     $ff, $ff, $ff, $ff,DTSP, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 50-5f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, // 60-6f
     $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff,   $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  // 70-7f
  );

  STD_MONTH_TABLE: TMonthTable = (
    {01}(Days: 31; Before: 0),
    {02}(Days: 28; Before: 0+31),
    {03}(Days: 31; Before: 0+31+28),
    {04}(Days: 30; Before: 0+31+28+31),
    {05}(Days: 31; Before: 0+31+28+31+30),
    {06}(Days: 30; Before: 0+31+28+31+30+31),
    {07}(Days: 31; Before: 0+31+28+31+30+31+30),
    {08}(Days: 31; Before: 0+31+28+31+30+31+30+31),
    {09}(Days: 30; Before: 0+31+28+31+30+31+30+31+31),
    {10}(Days: 31; Before: 0+31+28+31+30+31+30+31+31+30),
    {11}(Days: 30; Before: 0+31+28+31+30+31+30+31+31+30+31),
    {12}(Days: 31; Before: 0+31+28+31+30+31+30+31+31+30+31+30)
  );

  LEAP_MONTH_TABLE: TMonthTable = (
    {01}(Days: 31; Before: 0),
    {02}(Days: 29; Before: 0+31),
    {03}(Days: 31; Before: 0+31+29),
    {04}(Days: 30; Before: 0+31+29+31),
    {05}(Days: 31; Before: 0+31+29+31+30),
    {06}(Days: 30; Before: 0+31+29+31+30+31),
    {07}(Days: 31; Before: 0+31+29+31+30+31+30),
    {08}(Days: 31; Before: 0+31+29+31+30+31+30+31),
    {09}(Days: 30; Before: 0+31+29+31+30+31+30+31+31),
    {10}(Days: 31; Before: 0+31+29+31+30+31+30+31+31+30),
    {11}(Days: 30; Before: 0+31+29+31+30+31+30+31+31+30+31),
    {12}(Days: 31; Before: 0+31+29+31+30+31+30+31+31+30+31+30)
  );


{
  Supported date formats:

  YYYYMMDD
  YYYY-MM-DD
  -YYYY-MM-DD
  DD.MM.YYYY
  DD-MM-YYYY
  DD/MM/YYYY
  DD.MM.YY
  DD-MM-YY
  DD/MM/YY

  YYYY    (YYYY-01-01)
  YYYY-MM (YYYY-MM-01)
  --MM-DD (2000-MM-DD)
  --MM--  (2000-MM-01)
  ---DD   (2000-01-DD)


  Supported time formats:

  hh:mm:ss.zzzzzz
  hh-mm-ss.zzzzzz
  hh:mm:ss.zzz
  hh-mm-ss.zzz
  hh:mm:ss
  hh-mm-ss
  hhmmss
  hh:mm
  hh-mm
  hhmm
}

function _GetDateTime(var Buffer: TDateTimeBuffer): Boolean;
label
  date, year_calculated, time, hhmmss_calculated, done, fail;
type
  TDTByteString = array[1..High(Integer)] of Byte;
const
  _2001: array[1..4] of Byte = (2, 0, 0, 1);

  DT_SPACE = DTSP;
  DT_MIN = DTS1;
  DT_CLN = DTS4;
  DT_POINT = DTS2;

  SECPERMINUTE = 60;
  SECPERHOUR = 60 * SECPERMINUTE;
  SECPERDAY = 24 * SECPERHOUR;
  MSECPERDAY = SECPERDAY * 1000 * 1.0;
  TIME_CONSTS: array[0..5] of Double = (1/SECPERDAY, 1/MSECPERDAY,
    1/(MSECPERDAY*1000), -1/SECPERDAY, -1/MSECPERDAY, -1/(MSECPERDAY*1000));
var
  S: ^TDTByteString;
  L: NativeUInt;

  B: Byte;
  pCC, pYY, pMM, pDD: ^TDTByteString;
  CC, YY, MM, DD: NativeInt;
  MonthInfo: PMonthInfo;
  MonthTable: PMonthTable;
  Days: NativeInt;

  pHH, pNN, pSS: ^TDTByteString;
  HH, NN, SS: NativeInt;

  F: record
    Value: PDateTime;
    DT: NativeInt;
  end;
  R: PDateTime;
  TimeConst: PDouble;
begin
  S := Pointer(@Buffer.Bytes);
  L := Buffer.Length;

  F.Value := Buffer.Value;
  F.Value^ := 0;
  F.DT := Buffer.DT;
  if (F.DT and 1 = 0) then goto time;

date:
  // YYYYMMDD
  // YYYY-MM-DD
  // -YYYY-MM-DD
  // DD.MM.YYYY
  // DD-MM-YYYY
  // DD/MM/YYYY
  // DD.MM.YY
  // DD-MM-YY
  // DD/MM/YY
  // YYYY    (YYYY-01-01)
  // YYYY-MM (YYYY-MM-01)
  // --MM-DD (2000-MM-DD)
  // --MM--  (2000-MM-01)
  // ---DD   (2000-01-DD)

  if (S[1] = DT_MIN) then
  begin
    // -YYYY-MM-DD
    // --MM-DD (2000-MM-DD)
    // --MM--  (2000-MM-01)
    // ---DD   (2000-01-DD)

    if (S[2] = DT_MIN) then
    begin
      // --MM-DD (2000-MM-DD)
      // --MM--  (2000-MM-01)
      // ---DD   (2000-01-DD)
      if (S[3] = DT_MIN) then
      begin
        // ---DD (2000-01-DD)
        if (L < 5) then goto fail;

        pMM := {01}Pointer(@_2001[3]);
        pDD := Pointer(@S[4]);

        Dec(L, 5);
        Inc(PByte(S), 5);
      end else
      begin
        // --MM-DD (2000-MM-DD)
        // --MM--  (2000-MM-01)
        if (L < 6) then goto fail;

        pMM := Pointer(@S[3]);

        if (S[6] = DT_MIN) then
        begin
          // --MM-- (2000-MM-01)
          pDD := {01}Pointer(@_2001[3]);
          Dec(L, 6);
          Inc(PByte(S), 6);
        end else
        begin
          // --MM-DD (2000-MM-DD)
          if (L < 7) then goto fail;
          pDD := Pointer(@S[6]);
          Dec(L, 7);
          Inc(PByte(S), 7);
        end;
      end;

      MonthTable := @LEAP_MONTH_TABLE;
      Days := 36526{01.01.2000}-1;
      goto year_calculated;
    end else
    begin
      // -YYYY-MM-DD
      if (L < 11) or (S[6] <> DT_MIN) or (S[9] <> DT_MIN) then goto fail;

      pCC := Pointer(@S[2]);
      pYY := Pointer(@S[4]);
      pMM := Pointer(@S[7]);
      pDD := Pointer(@S[10]);

      Dec(L, 11);
      Inc(PByte(S), 11);
    end;
  end else
  begin
    // YYYYMMDD
    // YYYY-MM-DD
    // DD.MM.YYYY
    // DD-MM-YYYY
    // DD/MM/YYYY
    // DD.MM.YY
    // DD-MM-YY
    // DD/MM/YY
    // YYYY (YYYY-01-01)
    // YYYY-MM (YYYY-MM-01)

    if (S[3] <= 9) then
    begin
      // YYYYMMDD
      // YYYY-MM-DD
      // YYYY (YYYY-01-01)
      // YYYY-MM (YYYY-MM-01)
      PCC := Pointer(@S[1]);
      pYY := Pointer(@S[3]);

      if (L < 5) or (S[5] = DT_SPACE) then
      begin
        // YYYY (YYYY-01-01)
        pMM := {01}Pointer(@_2001[3]);
        pDD := {01}Pointer(@_2001[3]);

        Dec(L, 4);
        Inc(PByte(S), 4);
      end else
      if (S[5] <= 9) then
      begin
        // YYYYMMDD
        if (L < 8) then goto fail;

        pMM := Pointer(@S[5]);
        pDD := Pointer(@S[7]);

        Dec(L, 8);
        Inc(PByte(S), 8);
      end else
      begin
        // YYYY-MM-DD
        // YYYY-MM (YYYY-MM-01)
        if (S[5] <> DT_MIN) then goto fail;

        pMM := Pointer(@S[6]);

        if (L < 8) or (S[8] = DT_SPACE) then
        begin
          // YYYY-MM (YYYY-MM-01)
          pDD := {01}Pointer(@_2001[3]);
          Dec(L, 7);
          Inc(PByte(S), 7);
        end else
        begin
          // YYYY-MM-DD
          if (L < 10) then goto fail;
          pDD := Pointer(@S[9]);
          Dec(L, 10);
          Inc(PByte(S), 10);
        end;
      end;
    end else
    begin
      // DD.MM.YYYY
      // DD-MM-YYYY
      // DD/MM/YYYY
      // DD.MM.YY
      // DD-MM-YY
      // DD/MM/YY

      B := S[3];
      if (L < 8) or (B <> S[6]) or (B < DTS1) or (B > DTS3) then goto fail;

      pDD := Pointer(@S[1]);
      pMM := Pointer(@S[4]);

      if (L < 9) or (S[9] = DT_SPACE) then
      begin
        // DD.MM.YY
        // DD-MM-YY
        // DD/MM/YY
        pCC := {20}Pointer(@_2001[1]);
        pYY := Pointer(@S[7]);
        Dec(L, 8);
        Inc(PByte(S), 8);
      end else
      begin
        // DD.MM.YYYY
        // DD-MM-YYYY
        // DD/MM/YYYY
        if (L < 10) then goto fail;

        pCC := Pointer(@S[7]);
        pYY := Pointer(@S[9]);
        Dec(L, 10);
        Inc(PByte(S), 10);
      end;
    end;
  end;

  CC := NativeInt(pCC[1])*10 + NativeInt(pCC[2]);
  YY := NativeInt(pYY[1])*10 + NativeInt(pYY[2]);
  if (CC > 99) or (YY > 99) or ((CC = 0) and (YY = 0)) then goto fail;

  // Year := CC*100 + YY;
  // I := Year - 1;
  // Days := (I * 365) - (I div 100) + (I div 400) + (I div 4);
  Days := CC*(100*365) - 365 + YY*365; // Days = I*365 = (CC*100 + YY - 1)*365;
  MonthTable := @STD_MONTH_TABLE;
  if (YY = 0) then
  begin
    if (CC and 3 = 0) then MonthTable := @LEAP_MONTH_TABLE;
    Dec(CC);
    YY := 99;
  end else
  begin
    if (YY and 3 = 0) then MonthTable := @LEAP_MONTH_TABLE;
    Dec(YY);
  end;
  Days := Days - {I div 100}CC + ({I div 400}CC shr 2);
  // Days := Days + {I div 4}((CC*25) + YY shr 2) - DateDelta;
  Days := Days - 693594 + YY shr 2;
  Days := Days + CC*25;

year_calculated:
  // MM := NativeInt(pMM[1])*10 + NativeInt(pMM[2]) - 1;
  pCC := pMM;
  YY := NativeInt(pCC[1]);
  MM := NativeInt(pCC[2]) - 1;
  MM := YY*10 + MM;
  if (MM < 0) or (MM > 11)  then goto fail;

  // DD := NativeInt(pDD[1])*10 + NativeInt(pDD[2]);
  pYY := pDD;
  DD := NativeInt(pYY[2]) + NativeInt(pYY[1])*10;
  MonthInfo := @MonthTable[MM];
  if (DD = 0) or (DD > MonthInfo.Days) then goto fail;

  // Date value
  Days := (DD + Days) + MonthInfo.Before;
  F.Value^ := Days;

  if (F.DT and 2 = 0) then
  begin
    if (L <> 0) then goto fail;
    goto done;
  end;

  if (S[1] <> DT_SPACE) then goto fail;
  Dec(L);
  Inc(PByte(S));
  if (L < 4{MIN}) then goto fail;

time:
  // hh:mm:ss.zzzzzz
  // hh-mm-ss.zzzzzz
  // hh:mm:ss.zzz
  // hh-mm-ss.zzz
  // hh:mm:ss
  // hh-mm-ss
  // hhmmss
  // hh:mm
  // hh-mm
  // hhmm

  pHH := Pointer(@S[1]);
  pNN := Pointer(@S[4]);
  pSS := Pointer(@S[7]);

  if (S[3] <= 9) then
  begin
    // hhmmss
    // hhmm
    Dec(PByte(pNN));
    if (L = 4) then
    begin
      pSS := {00}Pointer(@_2001[2]);
      Dec(L, 4);
      Inc(PByte(S), 4);
    end else
    begin
      if (L <> 6) then goto fail;
      Dec(PByte(pSS), 2);
      Dec(L, 6);
      Inc(PByte(S), 6);
    end;
  end else
  begin
    // hh:mm:ss.zzzzzz
    // hh-mm-ss.zzzzzz
    // hh:mm:ss.zzz
    // hh-mm-ss.zzz
    // hh:mm:ss
    // hh-mm-ss
    // hh:mm
    // hh-mm

    case S[3] of
      DT_MIN: if (L > 5) then
              begin
                if (L < 8) or (S[6] <> DT_MIN) then goto fail;
                Dec(L, 8);
                Inc(PByte(S), 8);
                goto hhmmss_calculated;
              end;
      DT_CLN: if (L > 5) then
              begin
                if (L < 8) or (S[6] <> DT_CLN) then goto fail;
                Dec(L, 8);
                Inc(PByte(S), 8);
                goto hhmmss_calculated;
              end;
    else
      goto fail;
    end;

    // hh:mm
    // hh-mm
    pSS := {00}Pointer(@_2001[2]);
    Dec(L, 5);
    Inc(PByte(S), 5);
  end;

hhmmss_calculated:
  HH := NativeInt(pHH[1])*10 + NativeInt(pHH[2]);
  NN := NativeInt(pNN[1])*10 + NativeInt(pNN[2]);
  SS := NativeInt(pSS[1])*10 + NativeInt(pSS[2]);
  if (HH > 23) or (NN > 59) or (SS > 59) then goto fail;

  SS := SS + SECPERHOUR * HH;
  SS := SS + SECPERMINUTE * NN;

  // Time value
  R := F.Value;
  TimeConst := @TIME_CONSTS[0];
  if (TPoint(R^).Y < 0) then Inc(TimeConst, 3);
  R^ := R^ + TimeConst^ * SS;

  // Milliseconds
  if (L <> 0) then
  begin
    Inc(TimeConst);
    Dec(L);
    if (S[1] <> DT_POINT) then goto fail;
    Inc(PByte(S));

    if (L = 6) then Inc(TimeConst)
    else
    if (L <> 3) then goto fail;

    SS := 0;
    repeat
      HH := S[1];
      SS := SS * 10;
      if (HH >= 10) then goto fail;

      Dec(L);
      SS := SS + HH;
      Inc(PByte(S));
    until (L = 0);
    R^ := R^ + TimeConst^ * SS;
  end;

  goto done;
fail:
  Result := False;
  Exit;
done:
  Result := True;
end;


type
  TCardinalDivMod = packed record
    D: Cardinal;
    M: Cardinal;
  end;

// ----------------- CARDINAL -----------------

// universal ccbbbbaaaa ==> cc bbbb aaaa
function SeparateCardinal(P: PNativeInt; X: NativeUInt{Cardinal}): PNativeInt;
label
  _58;
var
  Y: NativeUInt;
  {$ifdef CPUX86}
    Param: NativeUInt;
  {$endif}
begin
  if (X >= DIGITS_4) then
  begin
    if (X >= DIGITS_8) then
    begin
      //_910:
      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $55E63B89) shr 57;
      {$elseif Defined(CPUX86)}
      Param := X;
      asm
        mov eax, $55E63B89
        mul Param
        shr edx, (57 - 32)
        mov Param, edx
      end;
      Y := Param;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_8;
      {$ifend}

      P^ := Y;
      Inc(P);
      X := X - (Y * DIGITS_8);
      goto _58;
    end else
    begin
    _58:
      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $68DB8BB) shr 40;
      {$elseif Defined(CPUX86)}
      Param := X;
      asm
        mov eax, $68DB8BB
        mul Param
        shr edx, (40 - 32)
        mov Param, edx
      end;
      Y := Param;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_4;
      {$ifend}
      P^ := Y;
      PNativeIntArray(P)^[1] := NativeInt(X) + (NativeInt(Y) * -DIGITS_4); // X - (NativeInt(Y) * DIGITS_4);

      Result := @PNativeIntArray(P)^[2];
    end;
  end else
  begin
    P^ := X;
    Result := @PNativeIntArray(P)^[1];
  end;
end;


// ----------------- UINT64 -----------------

// DivMod.D := X64 div DIGITS_8;
// DivMod.M := X64 mod DIGITS_8;
procedure DivideUInt64_8({$ifdef SMALLINT}var{$endif} X64: Int64; var DivMod: TCardinalDivMod);
const
  UN_DIGITS_8: Double = (1 / DIGITS_8);
{$if Defined(CPUX86)}
asm
  { [X64]: eax, [DivMod]: edx }

  // DivMod.D := Round(X64 * UN_DIGITS_8)
  fild qword ptr [eax]
  fmul UN_DIGITS_8
  fistp dword ptr [edx]

  // M := X64 + (D * -DIGITS_8);
  mov ecx, [edx]
  imul ecx, -DIGITS_8
  add ecx, [eax]

  // if (M < 0) then
  jns @done
    add ecx, DIGITS_8
    sub [edx], 1

@done:
  mov [edx + 4], ecx
end;
{$elseif Defined(CPUX64)}
asm
  { X64: rcx, [DivMod]: rdx }

  // D := Round(X64 * UN_DIGITS_8)
  cvtsi2sd xmm0, rcx
  mulsd xmm0, UN_DIGITS_8
  cvtsd2si rax, xmm0

  // M := X64 - D * DIGITS_8;
  imul r8, rax, DIGITS_8
  sub rcx, r8

  // if (M < 0) then
  jge @done
    add rcx, DIGITS_8
    sub rax, 1

@done:
  // DivMod.D := D;
  // DivMod.M := M;
  shl rcx, 32
  add rax, rcx
  mov [rdx], rax
end;
{$else .CPUARM}
  ROUND_CONST: Double = 6755399441055744.0;
var
  D, M: NativeInt;
begin
  PDouble(@DivMod)^ := (X64 * UN_DIGITS_8) + ROUND_CONST;

  D := DivMod.D;
  {$ifdef LARGEINT}
    M := X64 - (D * DIGITS_8);
  {$else .CPUARM .SMALLINT}
    M := PInteger(@X64)^ + (D * -DIGITS_8);
  {$endif}

  if (M < 0) then
  begin
    Inc(M, DIGITS_8);
    DivMod.D := D - 1;
  end;

  DivMod.M := M;
end;
{$ifend}



// universal UInt64 separate (20 digits maximum)
function SeparateUInt64(P: PNativeInt; X64: {U}Int64): PNativeInt;
label
  _1316, _58;
var
  X, Y: NativeUInt;
  Buffer: TCardinalDivMod;
begin
  {$ifdef LARGEINT}
  if (NativeUInt(X64) > High(Cardinal)) then
  {$else .SMALLINT}
  Y := TPoint(X64).Y;
  X := TPoint(X64).X;
  if (Y <> 0) then
  {$endif}
  begin
    // 17..20
    {$ifdef LARGEINT}
    if (NativeUInt(X64) >= NativeUInt(DIGITS_16)) then
    {$else .SMALLINT}
    if (Y >= $002386f2) and
       ((Y > $002386f2) or (X >= $6fc10000)) then
    {$endif}
    begin
      {$ifdef SMALLINT}
      // if (UInt64(X64) >= NINE_BB) then
      if (Y >= $7ce66c50) and
         ((Y > $7ce66c50) or (X >= $e2840000)) then
      begin
        // if (UInt64(X64) >= TEN_BB) then
        if (Y >= $8ac72304) and
           ((Y > $8ac72304) or (X >= $89e80000)) then
        begin
          Y := ((X64 - TEN_BB) div DIGITS_16) + 1000;
        end else
        begin
          Y := ((X64 - NINE_BB) div DIGITS_16) + 900;
        end;
      end else
      {$endif}
      begin
        {$ifdef LARGEINT}
          Y := NativeUInt(X64) div NativeUInt(DIGITS_16);
        {$else .SMALLINT}
          Y := X64 div DIGITS_16;
        {$endif}
      end;

      P^ := Y;
      X64 := X64 - (Y * DIGITS_16);
      Inc(P);
      goto _1316;
    end;

    // 9..16
    {$ifdef LARGEINT}
    if (NativeUInt(X64) >= NativeUInt(DIGITS_12)) then
    {$else .SMALLINT}
    if (Y >= $000000e8) and
       ((Y > $000000e8) or (X >= $d4a51000)) then
    {$endif}
    begin
      // 13..16
    _1316:
      DivideUInt64_8(X64, Buffer);
      X := Buffer.D;

      {$if Defined(LARGEINT)}
        Y := (NativeInt(X) * $68DB8BB) shr 40;
      {$elseif Defined(CPUX86)}
      asm
        mov eax, $68DB8BB
        mul Buffer.D
        shr edx, (40 - 32)
        mov Buffer.D, edx
      end;
      Y := Buffer.D;
      {$else .CPUARM .SMALLINT}
        Y := X div DIGITS_4;
      {$ifend}

      P^ := Y;
      PNativeIntArray(P)^[1] := NativeInt(X) + (NativeInt(Y) * -DIGITS_4); // X - (NativeInt(Y) * DIGITS_4);
      Inc(P, 2);

      X := Buffer.M;
    end else
    begin
      // 9..12
      DivideUInt64_8(X64, Buffer);
      P^ := Buffer.D;
      Inc(P);
      X := Buffer.M;
    end;

    goto _58;
  end else
  begin
    {$ifdef LARGEINT}
    X := X64;
    {$endif}

    if (X >= DIGITS_4) then
    begin
      if (X >= DIGITS_8) then
      begin
        //_910:
        {$if Defined(LARGEINT)}
          Y := (NativeInt(X) * $55E63B89) shr 57;
        {$elseif Defined(CPUX86)}
        Buffer.D := X;
        asm
          mov eax, $55E63B89
          mul Buffer.D
          shr edx, (57 - 32)
          mov Buffer.D, edx
        end;
        Y := Buffer.D;
        {$else .CPUARM .SMALLINT}
          Y := X div DIGITS_8;
        {$ifend}

        P^ := Y;
        Inc(P);
        X := X - (Y * DIGITS_8);
        goto _58;
      end else
      begin
      _58:
        {$if Defined(LARGEINT)}
          Y := (NativeInt(X) * $68DB8BB) shr 40;
        {$elseif Defined(CPUX86)}
        Buffer.D := X;
        asm
          mov eax, $68DB8BB
          mul Buffer.D
          shr edx, (40 - 32)
          mov Buffer.D, edx
        end;
        Y := Buffer.D;
        {$else .CPUARM .SMALLINT}
          Y := X div DIGITS_4;
        {$ifend}

        P^ := Y;
        PNativeIntArray(P)^[1] := NativeInt(X) + (NativeInt(Y) * -DIGITS_4); // X - (NativeInt(Y) * DIGITS_4);

        Result := @PNativeIntArray(P)^[2];
      end;
    end else
    begin
      P^ := X;
      Result := @PNativeIntArray(P)^[1];
    end;
  end;
end;


// ----------------- ASCII -----------------

const
  DIGITS_LOOKUP_ASCII: array[0..99] of Word = (
    $3030, $3130, $3230, $3330, $3430, $3530, $3630, $3730, $3830, $3930,
    $3031, $3131, $3231, $3331, $3431, $3531, $3631, $3731, $3831, $3931,
    $3032, $3132, $3232, $3332, $3432, $3532, $3632, $3732, $3832, $3932,
    $3033, $3133, $3233, $3333, $3433, $3533, $3633, $3733, $3833, $3933,
    $3034, $3134, $3234, $3334, $3434, $3534, $3634, $3734, $3834, $3934,
    $3035, $3135, $3235, $3335, $3435, $3535, $3635, $3735, $3835, $3935,
    $3036, $3136, $3236, $3336, $3436, $3536, $3636, $3736, $3836, $3936,
    $3037, $3137, $3237, $3337, $3437, $3537, $3637, $3737, $3837, $3937,
    $3038, $3138, $3238, $3338, $3438, $3538, $3638, $3738, $3838, $3938,
    $3039, $3139, $3239, $3339, $3439, $3539, $3639, $3739, $3839, $3939);

function WriteDigitsAscii(P: PByte; Digits, TopDigits: PNativeInt): PByte;
const
  SHIFTS: array[0..3] of Byte = (24, 16, 8, 0);
var
  X, V, L: NativeInt;
begin
  X := Digits^;
  Inc(Digits);
  V := (X * $147B) shr 19; // V := X div 100;
  V := (DIGITS_LOOKUP_ASCII[X - (V * 100){X mod 100}] shl 16) + DIGITS_LOOKUP_ASCII[V];

  L := Byte(Byte(X > 9) + Byte(X > 99) + Byte(X > 999));
  PCardinal(P)^ := V shr SHIFTS[L];
  Inc(P, L + 1);

  while (Digits <> TopDigits) do
  begin
    X := Digits^;
    Inc(Digits);

    V := (X * $147B) shr 19; // V := X div 100;
    X := X - (V * 100); // X := X mod 100;

    // Values
    V := DIGITS_LOOKUP_ASCII[V];
    PCardinal(P)^ := (DIGITS_LOOKUP_ASCII[X] shl 16) + V;
    Inc(P, 4);
  end;

  Result := P;
end;

// ----------------- UTF16 -----------------

const
  DIGITS_LOOKUP_UTF16: array[0..99] of Cardinal = (
    $00300030, $00310030, $00320030, $00330030, $00340030, $00350030,
    $00360030, $00370030, $00380030, $00390030, $00300031, $00310031,
    $00320031, $00330031, $00340031, $00350031, $00360031, $00370031,
    $00380031, $00390031, $00300032, $00310032, $00320032, $00330032,
    $00340032, $00350032, $00360032, $00370032, $00380032, $00390032,
    $00300033, $00310033, $00320033, $00330033, $00340033, $00350033,
    $00360033, $00370033, $00380033, $00390033, $00300034, $00310034,
    $00320034, $00330034, $00340034, $00350034, $00360034, $00370034,
    $00380034, $00390034, $00300035, $00310035, $00320035, $00330035,
    $00340035, $00350035, $00360035, $00370035, $00380035, $00390035,
    $00300036, $00310036, $00320036, $00330036, $00340036, $00350036,
    $00360036, $00370036, $00380036, $00390036, $00300037, $00310037,
    $00320037, $00330037, $00340037, $00350037, $00360037, $00370037,
    $00380037, $00390037, $00300038, $00310038, $00320038, $00330038,
    $00340038, $00350038, $00360038, $00370038, $00380038, $00390038,
    $00300039, $00310039, $00320039, $00330039, $00340039, $00350039,
    $00360039, $00370039, $00380039, $00390039);

function WriteDigitsUtf16(P: PWord; Digits, TopDigits: PNativeInt): PWord;
label
  one, two, three, four, start;
type
  TLowHigh = packed record
    Low: Word;
    High: Word;
  end;
var
  X, V: NativeInt;
begin
  X := Digits^;
  if (X > 999) then goto four;
  if (X > 99) then goto three;
  if (X > 9) then goto two;
one:
  P^ := TLowHigh(DIGITS_LOOKUP_UTF16[X]).High;
  Inc(Digits);
  Inc(P);
  goto start;
three:
  V := (X * $147B) shr 19; // V := X div 100;
  X := X - (V * 100); // X := X mod 100;
  P^ := TLowHigh(DIGITS_LOOKUP_UTF16[V]).High;
  Inc(P);
two:
  PCardinal(P)^ := DIGITS_LOOKUP_UTF16[X];
  Inc(Digits);
  Inc(P, 2);

start:
  while (Digits <> TopDigits) do
  begin
    X := Digits^;
  four:
    Inc(Digits);

    V := (X * $147B) shr 19; // V := X div 100;
    X := X - (V * 100); // X := X mod 100;

    // Values
    V := DIGITS_LOOKUP_UTF16[V];
    X := DIGITS_LOOKUP_UTF16[X];
    {$ifdef LARGEINT}
      PNativeInt(P)^ := V + (X shl 32);
      Inc(P, 4);
    {$else}
      PNativeInt(P)^ := V;
      Inc(P, 2);
      PNativeInt(P)^ := X;
      Inc(P, 2);
    {$endif}
  end;

  Result := P;
end;



{ ECachedString }

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PCachedByteString);
var
  S: string;
  Buffer: CachedByteString;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < 16) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := 16;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt({$ifdef KOL}e_Convert,{$endif}LoadResString(ResStringRec), [S]);
end;

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PCachedUTF16String);
var
  S: string;
  Buffer: CachedUTF16String;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < 16) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := 16;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt({$ifdef KOL}e_Convert,{$endif}LoadResString(ResStringRec), [S]);
end;

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PCachedUTF32String);
var
  S: string;
  Buffer: CachedUTF32String;
begin
  Buffer := Value^;
  Buffer.Ascii := False;
  if (Buffer.Chars <> nil) and (Buffer.Length > 0) then
  begin
    if (Buffer.Length < 16) then
    begin
      Buffer.ToString(S);
    end else
    begin
      Buffer.Length := 16;
      Buffer.ToString(S);
      S := S + '...';
    end;
  end;

  inherited CreateFmt({$ifdef KOL}e_Convert,{$endif}LoadResString(ResStringRec), [S]);
end;


{ CachedByteString }

function CachedByteString.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure CachedByteString.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

function CachedByteString.GetSBCS: PUniConvSBCS;
var
  Index: NativeInt;
begin
  Index := SBCSIndex;

  if (Index < 0) then
  begin
    Inc(Index){Result := nil};
  end else
  begin
    Index := Index * SizeOf(TUniConvSBCS);
    Inc(Index, NativeInt(@UNICONV_SUPPORTED_SBCS));
  end;

  Result := Pointer(Index);
end;

procedure CachedByteString.SetSBCS(Value: PUniConvSBCS);
begin
  if (Value = nil) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := Value.Index;
  end;
end;

function CachedByteString.GetUTF8: Boolean;
begin
  Result := Boolean(Flags shr 31);
end;

procedure CachedByteString.SetUTF8(Value: Boolean);
begin
  if (Value) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := DEFAULT_UNICONV_SBCS_INDEX;
  end;
end;

function CachedByteString.GetCodePage: Word;
var
  Index: NativeInt;
begin
  Index := SBCSIndex;

  if (Index < 0) then
  begin
    Result := CODEPAGE_UTF8;
  end else
  begin
    Index := Index * SizeOf(TUniConvSBCS);
    Inc(Index, NativeInt(@UNICONV_SUPPORTED_SBCS));
    Result := PUniConvSBCS(Index).CodePage;
  end;
end;

procedure CachedByteString.SetCodePage(CodePageValue: Word);
var
  Index: NativeUInt;
  Value: Integer;
begin
  if (CodePageValue = CODEPAGE_UTF8) then
  begin
    SBCSIndex := -1;
  end else
  begin
    Index := NativeUInt(CodePageValue);
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePageValue) or (Value < 0) then Break;
      Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);

    SBCSIndex := Byte(Value shr 16);
  end;
end;

procedure CachedByteString.ToAnsiString(var S: AnsiString; const CP: Word);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then goto copy_characters;

      Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
      Converter := DestSBCS.FromSBCS(Pointer(Index));
      Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
      Pointer(S) := Dest;
      sbcs_from_sbcs(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf8(Dest, Pointer(Src), L, Converter));
    end;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    Move(Src^, Dest^, L);
  end;
end;

procedure CachedByteString.ToLowerAnsiString(var S: AnsiString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccLower);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccLower);
      end;

      Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
      Pointer(S) := Dest;
      sbcs_from_sbcs_lower(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf8_lower(Dest, Pointer(Src), L, Converter));
    end;
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    {ascii}UniConv.utf8_from_utf8_lower(Dest, Src, L);
  end;
end;

procedure CachedByteString.ToUpperAnsiString(var S: AnsiString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FUpperCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccUpper);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccUpper);
      end;

      Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
      Pointer(S) := Dest;
      sbcs_from_sbcs_upper(Dest, Src, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

      Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf8_upper(Dest, Pointer(Src), L, Converter));
    end;
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    {ascii}UniConv.utf8_from_utf8_upper(Dest, Src, L);
  end;
end;

procedure CachedByteString.ToAnsiShortString(var S: ShortString; const CP: Word);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then goto copy_characters;

      Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
      Converter := DestSBCS.FromSBCS(Pointer(Index));

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf8;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    Move(Context.Source^, Dest^, L);
  end;
end;

procedure CachedByteString.ToLowerAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccLower);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccLower);
      end;

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs_lower(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf8_lower;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedByteString.ToUpperAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  Index := Self.Flags;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> SBCS
      Index := Index shr 24;
      if (Index = DestSBCS.Index) then
      begin
        Converter := DestSBCS.FLowerCase;
        if (Converter = nil) then Converter := DestSBCS.FromSBCS(DestSBCS, ccUpper);
      end else
      begin
        Index := NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS);
        Converter := DestSBCS.FromSBCS(Pointer(Index), ccUpper);
      end;

      Dest := Context.Destination;
      if (L > Context.DestinationSize) then L := Context.DestinationSize;
      Dec(Dest);
      Dest^ := L;
      Inc(Dest);
      sbcs_from_sbcs_upper(Pointer(Dest), Context.Source, L, Converter);
    end else
    begin
      // UTF8 --> SBCS
      // converter
      Converter := DestSBCS.FVALUES;
      if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf8_upper;
      if (Context.convert_sbcs_from_utf8 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
      begin
        Inc(Context.FDestinationWritten);
        Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
      end;
      Dest := Context.Destination;
      Dec(Dest);
      Dest^ := Context.DestinationWritten;
    end;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedByteString.ToUTF8String(var S: UTF8String);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then goto copy_characters;

    // converter
    Index := Index shr 24;
    SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
    Converter := SrcSBCS.FUTF8.Original;
    if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Original, ccOriginal);

    // conversion
    Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
    AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_sbcs(Dest, Pointer(Src), L, Converter));
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    Move(Src^, Dest^, L);
  end;
end;

procedure CachedByteString.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Dest := AnsiStringAlloc(Pointer(S), (L * 3) shr 1, CODEPAGE_UTF8 or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_utf8_lower(Dest, Pointer(Src), L));
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Lower, ccLower);

      // conversion
      Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_sbcs_lower(Dest, Pointer(Src), L, Converter));
    end;
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    {ascii}UniConv.utf8_from_utf8_lower(Dest, Src, L);
  end;
end;

procedure CachedByteString.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Dest := AnsiStringAlloc(Pointer(S), (L * 3) shr 1, CODEPAGE_UTF8 or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_utf8_upper(Dest, Pointer(Src), L));
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Upper, ccUpper);

      // conversion
      Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
      AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_sbcs_upper(Dest, Pointer(Src), L, Converter));
    end;
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    {ascii}UniConv.utf8_from_utf8_upper(Dest, Src, L);
  end;
end;

procedure CachedByteString.ToUTF8ShortString(var S: ShortString);
label
  copy_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then goto copy_characters;

    // converter
    Index := Index shr 24;
    SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
    Converter := SrcSBCS.FUTF8.Original;
    if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Original, ccOriginal);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_sbcs;
    Context.convert_utf8_from_sbcs;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
  copy_characters:
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    Move(Context.Source^, Dest^, L);
  end;
end;

procedure CachedByteString.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_utf8_lower;
      Context.convert_utf8_from_utf8;
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Lower, ccLower);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_sbcs_lower;
      Context.convert_utf8_from_sbcs;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedByteString.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Index := Self.Flags;
  Context.Source := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) < 0) then
    begin
      // UTF8 --> UTF8
      Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_utf8_upper;
      Context.convert_utf8_from_utf8;
    end else
    begin
      // SBCS --> UTF8
      // converter
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUTF8.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUTF8(SrcSBCS.FUTF8.Upper, ccUpper);
      Context.FCallbacks.Converter := Converter;

      // conversion
      Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_sbcs_upper;
      Context.convert_utf8_from_sbcs;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii}utf8_from_utf8_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedByteString.ToWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Original;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Original, ccOriginal);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WideStringAlloc(Pointer(S), L, -1);
    WideStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs(Dest, Src, L, Converter);
  end;
end;

procedure CachedByteString.ToLowerWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Lower, ccLower);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WideStringAlloc(Pointer(S), L, -1);
    WideStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8_lower(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs_lower(Dest, Src, L, Converter);
  end;
end;

procedure CachedByteString.ToUpperWideString(var S: WideString);
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Upper, ccUpper);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := WideStringAlloc(Pointer(S), L, -1);
    WideStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8_upper(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs_upper(Dest, Src, L, Converter);
  end;
end;

procedure CachedByteString.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Original;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Original, ccOriginal);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UnicodeStringAlloc(Pointer(S), L, -1);
    UnicodeStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs(Dest, Src, L, Converter);
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure CachedByteString.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Lower;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Lower, ccLower);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UnicodeStringAlloc(Pointer(S), L, -1);
    UnicodeStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8_lower(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs_lower(Dest, Src, L, Converter);
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure CachedByteString.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
label
  copy_samelength_characters;
var
  L: NativeUInt;
  Index: NativeInt;
  SrcSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Index := Self.Flags;
  Src := Self.Chars;
  if (Index and 1 = 0{not Ascii}) then
  begin
    if (Integer(Index) >= 0) then
    begin
      // SBCS --> UTF16
      Index := Index shr 24;
      SrcSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
      Converter := SrcSBCS.FUCS2.Upper;
      if (Converter = nil) then Converter := SrcSBCS.AllocFillUCS2(SrcSBCS.FUCS2.Upper, ccUpper);
      goto copy_samelength_characters;
    end;

    // UTF8 --> UTF16
    Dest := UnicodeStringAlloc(Pointer(S), L, -1);
    UnicodeStringFinish(Pointer(S), Dest, UniConv.utf16_from_utf8_upper(Dest, Pointer(Src), L));
  end else
  begin
    // Ascii chars
    Converter := nil;
  copy_samelength_characters:
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    utf16_from_sbcs_upper(Dest, Src, L, Converter);
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure CachedByteString.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure CachedByteString.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure CachedByteString.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function CachedByteString.GetAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function CachedByteString.GetLowerAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function CachedByteString.GetUpperAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function CachedByteString.GetUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function CachedByteString.GetLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function CachedByteString.GetUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function CachedByteString.GetWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function CachedByteString.GetLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function CachedByteString.GetUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

{$ifdef UNICODE}
function CachedByteString.GetUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}

function CachedByteString.GetLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUnicodeString
end;
{$endif}

function CachedByteString.GetUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUnicodeString
end;
{$endif}
{$endif}

{$ifdef OPERATORSUPPORT}
class operator CachedByteString.Implicit(const a: CachedByteString): AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator CachedByteString.Implicit(const a: CachedByteString): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator CachedByteString.Implicit(const a: CachedByteString): WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator CachedByteString.Implicit(const a: CachedByteString): UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}


procedure CachedByteString.Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP: Word{$endif});
var
  P: {$ifdef NEXTGEN}PNativeInt{$else}PInteger{$endif};
  {$ifdef INTERNALCODEPAGE}
  CP: Word;
  {$endif}
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
    Self.F.NativeFlags := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^;
    {$ifdef INTERNALCODEPAGE}
    Dec(P, 2);
    CP := PWord(P)^;
    {$endif}
    if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CP <> CODEPAGE_UTF8) then SetCodePage(CP);
    end;
  end;
end;

procedure CachedByteString.Assign(const S: UTF8String);
var
  P: {$ifdef NEXTGEN}PNativeInt{$else}PInteger{$endif};
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
    Self.F.NativeFlags := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^;
    Self.Flags := $ff000000;
  end;
end;

procedure CachedByteString.Assign(const S: ShortString; const CP: Word);
var
  L: NativeUInt;
begin
  L := PByte(@S)^;
  Self.FLength := L;
  if (L = 0) then
  begin
    Self.FChars := Pointer(L){nil};
    Self.F.NativeFlags := L{0};
  end else
  begin
    Self.FChars := Pointer(@S[1]);
    if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CP <> CODEPAGE_UTF8) then SetCodePage(CP);
    end;
  end;
end;

procedure CachedByteString.Assign(const S: TBytes; const CP: Word);
var
  P: PNativeInt;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
    Self.F.NativeFlags := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^{$ifdef FPC}+1{$endif};
    if (CP = 0) or (CP = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CP <> CODEPAGE_UTF8) then SetCodePage(CP);
    end;
  end;
end;

function CachedByteString.DetectAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Byte);  
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);  
var
  P: PByte;
  L: NativeUInt;
  {$ifdef CPUMANYREGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($7f7f7f7f);
  {$endif}  
begin
  P := Pointer(FChars);
  L := FLength;
  
  {$ifdef CPUMANYREGS}
  MASK := not NativeUInt({$ifdef LARGEINT}$7f7f7f7f7f7f7f7f{$else}$7f7f7f7f{$endif});
  {$endif}    
  
  while (L >= CHARS_IN_NATIVE) do  
  begin  
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;   
    Dec(L, CHARS_IN_NATIVE);
    Inc(P, CHARS_IN_NATIVE);
  end;  
  {$ifdef LARGEINT}
  if (L >= CHARS_IN_CARDINAL) then
  begin
    if (PCardinal(P)^ and MASK <> 0) then goto fail; 
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);    
  end;
  {$endif}
  if (L >= 2) then
  begin
    if (PWord(P)^ and Word(not $7f7f) <> 0) then goto fail; 
    // Dec(L, 2);
    Inc(P, 2);      
  end;
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;
  
  Ascii := True;
  Result := True;  
  Exit;
fail:
  Ascii := False;
  Result := False;  
end;

function CachedByteString.LTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _LTrim(S, L);
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jz @1
  xor eax, eax
  ret
@1:
  cmp byte ptr [edx], 32
  jbe _LTrim
  mov al, 1
end;
{$ifend}

function CachedByteString._LTrim(S: PByte; L: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  TopS: PByte;
begin  
  TopS := @PCharArray(S)[L];

  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);
  
  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS); 
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};  
  Result := False; 
end;

function CachedByteString.RTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _RTrim(S, L);
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:    
  cmp byte ptr [edx + ecx], 32
  jbe _RTrim
  mov al, 1
end;
{$ifend}

function CachedByteString._RTrim(S: PByte; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  TopS: PByte;
begin  
  TopS := @PCharArray(S)[H];
  
  Dec(S);
  repeat
    Dec(TopS);  
    if (S = TopS) then goto fail;    
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS);
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedByteString.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PByte;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      // LTrim or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _LTrim(S, L+1);
        Exit;
      end;
    end else
    begin
      // RTrim or Trim
      if (S^ > 32) then
      begin
        Result := _RTrim(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp byte ptr [edx + ecx], 32
  jbe @2
  // LTrim or True
  inc ecx
  cmp byte ptr [edx], 32
  jbe _LTrim
  mov al, 1
  ret
@2:
  // RTrim or Trim
  cmp byte ptr [edx], 32
  ja _RTrim
  jmp _Trim
end;
{$ifend}

function CachedByteString._Trim(S: PByte; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  TopS: PByte;
begin  
  if (H = 0) then goto fail;  
  TopS := @PCharArray(S)[H];      

  // LTrim
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // RTrim
  Dec(S);
  repeat
    Dec(TopS);  
  until (TopS^ > 32);    
  
  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS); 
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedByteString.SubString(const From, Count: NativeUInt): CachedByteString;
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PCharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end; 

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedByteString.SubString(const Count: NativeUInt): CachedByteString;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedByteString.Offset(const Count: NativeUInt): Boolean;
type
  TCharArray = array[0..0] of Byte;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PCharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PCharArray(FChars)[Count]);
    Result := True;
  end;
end;

function CachedByteString.Hash: Cardinal;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
var
  L, L_High: NativeUInt;
  P: PByte;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := (L shl (32-9));
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L, CHARS_IN_CARDINAL);
    Inc(Result, PCardinal(P)^);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 2 <> 0) then
  begin
    Inc(Result, PWord(P)^);
    V := Result shr 5;
    Inc(P, 2);
    Result := Result xor V;
  end;

  if (L and 1 <> 0) then
  begin
    V := Result shr 5;
    Inc(Result, P^);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedByteString.HashIgnoreCase: Cardinal;
{$ifNdef CPUINTEL}
var
  NF: NativeUInt;
begin
  NF := F.NativeFlags;

  if (NF and 1 <> 0) then Result := _HashIgnoreCaseAscii
  else
  if (NF < (1 shl 24)) then Result := _HashIgnoreCaseUTF8
  else
  Result := _HashIgnoreCase(NF);
end;
{$else}
asm
  {$ifdef CPUX86}
  mov edx, [EAX].F.Flags
  {$else .CPUX64}
  mov edx, [RCX].F.Flags
  {$endif}
  test edx, 1
  jnz _HashIgnoreCaseAscii
  cmp edx, $01000000
  jb _HashIgnoreCaseUTF8
  jmp _HashIgnoreCase
end;
{$endif}

function CachedByteString._HashIgnoreCaseAscii: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
var
  L, L_High: NativeUInt;
  P: PByte;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := (L shl (32-9));
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    X := X or ((X and $40404040) shr 1);
    Dec(L, CHARS_IN_CARDINAL);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L <> 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        Inc(L, 3);
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        Inc(L, 2);
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      Inc(L);
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedByteString._HashIgnoreCaseUTF8: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  MASKS: array[1..3] of Cardinal = ($ffffff, $ffff, $ff);
var
  L: NativeUInt;
  P: PByte;
  X, V: Cardinal;
  N: NativeUInt;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PUniConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@UNICONV_CHARCASE.LOWER);
  Result := L;
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
    if (X and $80 <> 0) then
    begin
      case UNICONV_UTF8_SIZE[Byte(X)] of
        2: begin
             // X := ((X and $1F) shl 6) or ((X shr 8) and $3F);
             V := X;
             X := X and $1F;
             V := V shr 8;
             X := X shl 6;
             V := V and $3F;
             Inc(L, 2);
             Inc(X, V);
             Dec(P, 2);
             X := lookup_utf16_lower[X];
           end;
        3: begin
             // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
             V := (X and $0F) shl 12;
             V := V + (X shr 16) and $3F;
             X := (X and $3F00) shr 2;
             Inc(L);
             Inc(X, V);
             Dec(P);
             X := lookup_utf16_lower[X];
           end;
        4: begin
             // X := (X&07)<<18 | (X&3f00)<<4 | (X>>10)&0fc0 | (X>>24)&3f;
             V := (X and $07) shl 18;
             V := V + (X and $3f00) shl 4;
             V := V + (X shr 10) and $0fc0;
             X := (X shr 24) and $3f;
             Inc(X, V);
           end;
      else
        // fail UTF8 character
        Inc(L, 3);
        Dec(P, 3);
        X := Byte(X);
      end;
    end else
    begin
      if (X and Integer($80808080) <> 0) then
      begin
        N := (4-1) - (Byte(X and $8000 = 0) + Byte(X and $808000 = 0));

        X := X and MASKS[N];
        Inc(L, N);
        Dec(P, N);
      end;

      X := X or ((X and $40404040) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + {$ifdef CPUX86}S.{$endif}L_High;
end;


function CachedByteString._HashIgnoreCase(NF: NativeUInt): Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  MASKS: array[1..3] of Cardinal = ($ffffff, $ffff, $ff);
var
  L: NativeUInt;
  P: PByte;
  X, V: Cardinal;
  N: NativeUInt;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  SBCSLookup: PUniConvSBCSEx;
  Lower: PUniConvWB;
begin
  L := FLength;
  P := Pointer(FChars);
  NF := NF shr 24;

  if (L = 0) then
  begin
    Result := 0;
    Exit;
  end;

  // SBCSLookup := Pointer(@uniconv_lookup_sbcs[NF]);
  {$ifdef CPUX86}
    SBCSLookup := nil;//Pointer(@uniconv_lookup_sbcs);
    Inc(SBCSLookup, NF-1);
  {$else}
    SBCSLookup := nil;//Pointer(@uniconv_lookup_sbcs[NF]);
  {$endif}
  // Lower := inline SBCSLookup.GetLowerCaseUCS2;
  Lower := Pointer(SBCSLookup.FUCS2.Lower);
  if (Lower = nil) then Lower := Pointer(SBCSLookup.AllocFillUCS2(SBCSLookup.FUCS2.Lower, ccLower));

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  Result := L;
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);
    if (X and $80 <> 0) then
    begin
      X := Lower[X];
      Inc(L, CHARS_IN_CARDINAL-1);
      Dec(P, CHARS_IN_CARDINAL-1);
    end else
    begin
      if (X and Integer($80808080) <> 0) then
      begin
        N := (4-1) - (Byte(X and $8000 = 0) + Byte(X and $808000 = 0));

        X := X and MASKS[N];
        Inc(L, N);
        Dec(P, N);
      end;

      X := X or ((X and $40404040) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    case L of
      1:
      begin
        X := P^;
        goto include_x;
      end;
      2:
      begin
        X := PWord(P)^;
        goto include_x;
      end;
    else
      X := PWord(P)^;
      Inc(P, 2);
      X := X or P^;
      goto include_x;
    end;
  end;

  Result := (Result and (-1 shr 9)) + {$ifdef CPUX86}S.{$endif}L_High;
end;

function CachedByteString.CharPos(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.Pos(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.PosIgnoreCase(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedByteString.TryAsBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function CachedByteString.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedByteString(@Default)._GetBool(Pointer(Chars), Length);
end;

function CachedByteString.GetBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function CachedByteString._GetBool(S: PByte; L: NativeUInt): Boolean;
label
  fail;
type
  TStrAsData = packed record
  case Integer of
    0: (Bytes: array[0..High(Integer) - 1] of Byte);
    1: (Words: array[0..High(Integer) div 2 - 1] of Word);
    2: (Dwords: array[0..High(Integer) div 4 - 1] of Cardinal);
  end;
var
  Marker: NativeInt;
  Buffer: CachedByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  with TStrAsData(Pointer(Buffer.Chars)^) do
  case L of
   1: case (Bytes[0]) of
        $30:
        begin
          // "0"
          Result := False;
          Exit;
        end;
        $31:
        begin
          // "1"
          Result := True;
          Exit;
        end;
      end;
   2: if (Words[0] or $2020 = $6F6E) then
      begin
        // "no"
        Result := False;
        Exit;
      end;
   3: if (Words[0] + Bytes[2] shl 16 or $202020 = $736579) then
      begin
        // "yes"
        Result := True;
        Exit;
      end;
   4: if (Dwords[0] or $20202020 = $65757274) then
      begin
        // "true"
        Result := True;
        Exit;
      end;
   5: if (Dwords[0] or $20202020 = $736C6166) and (Bytes[4] or $20 = $65) then
      begin
        // "false"
        Result := False;
        Exit;
      end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
    Result := False;
  end;
end;

function CachedByteString.TryAsHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedByteString.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedByteString(@Default)._GetHex(Pointer(Chars), Length);
end;

function CachedByteString.GetHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function CachedByteString._GetHex(S: PByte; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: CachedByteString;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedByteString.TryAsCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedByteString.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedByteString(@Default)._GetInt(Pointer(Chars), Length);
end;

function CachedByteString.GetCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedByteString.TryAsInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedByteString.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedByteString(@Default)._GetInt(Pointer(Chars), -Length);
end;

function CachedByteString.GetInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedByteString._GetInt(S: PByte; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedByteString;
  HexRet: record
    Value: Integer;
  end;    
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedByteString(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedByteString(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedByteString.TryAsHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedByteString.AsHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function CachedByteString.GetHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function CachedByteString._GetHex64(S: PByte; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: CachedByteString;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedByteString.TryAsUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedByteString.AsUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedByteString.GetUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedByteString.TryAsInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedByteString.AsInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedByteString.GetInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedByteString(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedByteString._GetInt64(S: PByte; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedByteString;
  HexRet: record
    Value: Integer;
  end;  
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PCachedByteString(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PCachedByteString(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PCachedByteString(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedByteString._GetInt_19(S: PByte; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PByte;
  end;
  {$else}
  _S: PByte;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
end;

function CachedByteString.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedByteString.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedByteString.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function CachedByteString.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedByteString(@Default)._GetFloat(Pointer(Chars), Length);
end;

function CachedByteString.GetFloat: Extended;
begin
  Result := PCachedByteString(0)._GetFloat(Pointer(Chars), Length);
end;

function CachedByteString._GetFloat(S: PByte; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: CachedByteString;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PCachedByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedByteString(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PCachedByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedByteString(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PCachedByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedByteString(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PCachedByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedByteString(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PCachedByteString(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef CPUX86}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedByteString.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function CachedByteString.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function CachedByteString.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedByteString.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function CachedByteString.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function CachedByteString.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedByteString.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function CachedByteString.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function CachedByteString.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedByteString._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PByte;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := CachedTexts._GetDateTime(Buffer);
end;


{ CachedUTF16String }

function CachedUTF16String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure CachedUTF16String.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

procedure CachedUTF16String.ToAnsiString(var S: AnsiString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf16(Dest, Src, L, Converter));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    {ascii}utf8_from_utf16(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToLowerAnsiString(var S: AnsiString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf16_lower(Dest, Src, L, Converter));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    {ascii}utf8_from_utf16_lower(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToUpperAnsiString(var S: AnsiString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);

    Dest := AnsiStringAlloc(Pointer(S), L, Integer(DestSBCS.CodePage) or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.sbcs_from_utf16_upper(Dest, Src, L, Converter));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
    Pointer(S) := Dest;
    {ascii}utf8_from_utf16_upper(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf16;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedUTF16String.ToLowerAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf16_lower;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16_lower(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedUTF16String.ToUpperAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));

  L := Self.Length;
  if (L = 0) then
  begin
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := L;
    Exit;
  end;

  Context.Source := Self.Chars;
  if (not Self.Ascii) then
  begin
    // converter
    Converter := DestSBCS.FVALUES;
    if (Converter = nil) then Converter := DestSBCS.AllocFillVALUES(DestSBCS.FVALUES);
    Context.FCallbacks.Converter := Converter;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.sbcs_from_utf16_upper;
    if (Context.convert_sbcs_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    {ascii} utf8_from_utf16_upper(Pointer(Dest), Context.Source, L);
  end;
end;

procedure CachedUTF16String.ToUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_utf16(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    utf8_from_utf16(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_utf16_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    utf8_from_utf16_lower(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L * 3, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    AnsiStringFinish(Pointer(S), Dest, UniConv.utf8_from_utf16_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    utf8_from_utf16_upper(Dest, Src, L)
  end;
end;

procedure CachedUTF16String.ToUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_utf16;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure CachedUTF16String.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_utf16_lower;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16_lower(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure CachedUTF16String.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest, Src: PByte;
  Context: TUniConvContextEx;
begin
  Context.DestinationSize := NativeUInt(High(S));
  L := Self.Length;
  if (L = 0) then
  begin
    PByte(@S)^ := L;
    Exit;
  end;
  Context.Destination := @S[1];

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    Context.Source := Src;
    Context.SourceSize := L + L;

    // conversion
    Context.FCallbacks.ReaderWriter := @UniConv.utf8_from_utf16_upper;
    if (Context.convert_utf8_from_utf16 < 0) and (Context.DestinationWritten <> Context.DestinationSize) then
    begin
      Inc(Context.FDestinationWritten);
      Byte(PByteArray(Context.Destination)[Context.DestinationWritten]) := UNKNOWN_CHARACTER;
    end;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    Dest := Context.Destination;
    if (L > Context.DestinationSize) then L := Context.DestinationSize;
    Dec(Dest);
    Dest^ := L;
    Inc(Dest);
    utf8_from_utf16_upper(Pointer(Dest), Pointer(Src), L)
  end;
end;

procedure CachedUTF16String.ToWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WideStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  Move(Src^, Dest^, L + L);
end;

procedure CachedUTF16String.ToLowerWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WideStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  utf16_from_utf16_lower(Dest, Src, L);
end;

procedure CachedUTF16String.ToUpperWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  Src := Self.Chars;
  Dest := WideStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  utf16_from_utf16_upper(Dest, Src, L);
end;

procedure CachedUTF16String.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Src := Self.Chars;
  Dest := UnicodeStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  Move(Src^, Dest^, L + L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure CachedUTF16String.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Src := Self.Chars;
  Dest := UnicodeStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  utf16_from_utf16_lower(Dest, Src, L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure CachedUTF16String.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  Src := Self.Chars;
  Dest := UnicodeStringAlloc(Pointer(S), L, 0);
  Pointer(S) := Dest;
  utf16_from_utf16_upper(Dest, Src, L);
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure CachedUTF16String.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure CachedUTF16String.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure CachedUTF16String.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function CachedUTF16String.GetAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function CachedUTF16String.GetLowerAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function CachedUTF16String.GetUpperAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function CachedUTF16String.GetUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function CachedUTF16String.GetLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function CachedUTF16String.GetUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function CachedUTF16String.GetWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function CachedUTF16String.GetLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function CachedUTF16String.GetUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

{$ifdef UNICODE}
function CachedUTF16String.GetUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}

function CachedUTF16String.GetLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUnicodeString
end;
{$endif}

function CachedUTF16String.GetUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUnicodeString
end;
{$endif}
{$endif}

{$ifdef OPERATORSUPPORT}
class operator CachedUTF16String.Implicit(const a: CachedUTF16String): AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator CachedUTF16String.Implicit(const a: CachedUTF16String): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator CachedUTF16String.Implicit(const a: CachedUTF16String): WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator CachedUTF16String.Implicit(const a: CachedUTF16String): UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}

procedure CachedUTF16String.Assign(const S: WideString);
var
  P: {$ifdef NEXTGEN}PNativeInt{$else}PInteger{$endif};
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  Self.F.NativeFlags := 0;
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^{$ifdef WIDE_STR_SHIFT} shr 1{$endif};
  end;
end;

{$ifdef UNICODE}
procedure CachedUTF16String.Assign(const S: UnicodeString);
var
  P: PInteger;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  Self.F.NativeFlags := 0;
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^;
  end;
end;
{$endif}

function CachedUTF16String.DetectAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Word);  
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);  
var
  P: PWord;
  L: NativeUInt;
  {$ifdef CPUMANYREGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($007f007f);
  {$endif}  
begin
  P := Pointer(FChars);
  L := FLength;
         
  {$ifdef CPUMANYREGS}
  MASK := not NativeUInt({$ifdef LARGEINT}$007f007f007f007f{$else}$007f007f{$endif});
  {$endif}    
  
  while (L >= CHARS_IN_NATIVE) do  
  begin  
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;   
    Dec(L, CHARS_IN_NATIVE);
    Inc(P, CHARS_IN_NATIVE);
  end;  
  {$ifdef LARGEINT}
  if (L >= CHARS_IN_CARDINAL) then
  begin
    if (PCardinal(P)^ and MASK <> 0) then goto fail; 
    // Dec(L, CHARS_IN_CARDINAL);
    Inc(P, CHARS_IN_CARDINAL);    
  end;
  {$endif}
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;
  
  Ascii := True;
  Result := True;  
  Exit;
fail:
  Ascii := False;
  Result := False;  
end;

function CachedUTF16String.LTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _LTrim(S, L);
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jz @1
  xor eax, eax
  ret
@1:
  cmp word ptr [edx], 32
  jbe _LTrim
  mov al, 1
end;
{$ifend}

function CachedUTF16String._LTrim(S: PWord; L: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  TopS: PWord;
begin  
  TopS := @PCharArray(S)[L];

  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);
  
  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 1; 
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};  
  Result := False; 
end;

function CachedUTF16String.RTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _RTrim(S, L);
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:    
  cmp word ptr [edx + ecx*2], 32
  jbe _RTrim
  mov al, 1
end;
{$ifend}

function CachedUTF16String._RTrim(S: PWord; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  TopS: PWord;
begin  
  TopS := @PCharArray(S)[H];
  
  Dec(S);
  repeat
    Dec(TopS);  
    if (S = TopS) then goto fail;    
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 1;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedUTF16String.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PWord;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      // LTrim or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _LTrim(S, L+1);
        Exit;
      end;
    end else
    begin
      // RTrim or Trim
      if (S^ > 32) then
      begin
        Result := _RTrim(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp word ptr [edx + ecx*2], 32
  jbe @2
  // LTrim or True
  inc ecx
  cmp word ptr [edx], 32
  jbe _LTrim
  mov al, 1
  ret
@2:
  // RTrim or Trim
  cmp word ptr [edx], 32
  ja _RTrim
  jmp _Trim
end;
{$ifend}

function CachedUTF16String._Trim(S: PWord; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  TopS: PWord;
begin  
  if (H = 0) then goto fail;  
  TopS := @PCharArray(S)[H];      

  // LTrim
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // RTrim
  Dec(S);
  repeat
    Dec(TopS);  
  until (TopS^ > 32);    
  
  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 1; 
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedUTF16String.SubString(const From, Count: NativeUInt): CachedUTF16String;
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PCharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end;

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedUTF16String.SubString(const Count: NativeUInt): CachedUTF16String;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedUTF16String.Offset(const Count: NativeUInt): Boolean;
type
  TCharArray = array[0..0] of Word;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PCharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PCharArray(FChars)[Count]);
    Result := True;
  end;
end;

function CachedUTF16String.Hash: Cardinal;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  L, L_High: NativeUInt;
  P: PWord;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L, CHARS_IN_CARDINAL);
    Inc(Result, PCardinal(P)^);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 1 <> 0) then
  begin
    V := Result shr 5;
    Inc(Result, P^);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedUTF16String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86}
asm
  cmp byte ptr [EAX].F.B0, 0
  jnz _HashIgnoreCaseAscii
  jmp _HashIgnoreCase
end;
{$ifend}

function CachedUTF16String._HashIgnoreCaseAscii: Cardinal;
label
  include_x;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  L, L_High: NativeUInt;
  P: PWord;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
  include_x:
    X := X or ((X and $00400040) shr 1);
    Dec(L, CHARS_IN_CARDINAL);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P, CHARS_IN_CARDINAL);
    Result := Result xor V;
  until (L < CHARS_IN_CARDINAL);

  if (L and 1 <> 0) then
  begin
    X := P^;
    Inc(L);
    goto include_x;
  end;

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedUTF16String._HashIgnoreCase: Cardinal;
label
  include_ascii, x_calculated;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  MASK = not Cardinal($007f007f);
  MASK_FIRST = not Cardinal($ffff007f);
var
  L: NativeUInt;
  P: PWord;
  X, V: Cardinal;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PUniConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@UNICONV_CHARCASE.LOWER);
  if (L >= CHARS_IN_CARDINAL) then
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := PCardinal(P)^;
    Dec(L);
    Inc(P);
    if (X and MASK <> 0) then
    begin
      if (X and MASK_FIRST = 0) then
      begin
        X := Word(X);
        goto include_ascii;
      end else
      begin
        X := Word(X);
        if (X >= $d800) and (X < $dc00) then
        begin
          Dec(L);
          Inc(P);
          goto x_calculated;
        end;

        X := lookup_utf16_lower[X];
        goto x_calculated;
      end;
    end else
    begin
      Dec(L);
      Inc(P);
    include_ascii:
      X := X or ((X and $00400040) shr 1);
    end;

  x_calculated:
    V := Result shr 5;
    Inc(Result, X);

    Result := Result xor V;
  until (NativeInt(L) < CHARS_IN_CARDINAL);

  if (NativeInt(L) > 0) then
  begin
    X := P^;
    if (X > $7f) then
    begin
      X := lookup_utf16_lower[X];
    end else
    begin
      X := X or ((X and $0040) shr 1);
    end;
    V := Result shr 5;
    Inc(Result, X);
    Result := Result xor V;
  end;

  Result := (Result and (-1 shr 9)) + ({$ifdef CPUX86}S.{$endif}L_High);
end;

function CachedUTF16String.CharPos(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.Pos(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.PosIgnoreCase(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF16String.TryAsBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function CachedUTF16String.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedUTF16String(@Default)._GetBool(Pointer(Chars), Length);
end;

function CachedUTF16String.GetBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function CachedUTF16String._GetBool(S: PWord; L: NativeUInt): Boolean;
label
  fail;
type
  TStrAsData = packed record
  case Integer of
    0: (Words: array[0..High(Integer) div 2 - 1] of Word);
    1: (Dwords: array[0..High(Integer) div 4 - 1] of Cardinal);
  end;
var
  Marker: NativeInt;
  Buffer: CachedByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  with TStrAsData(Pointer(Buffer.Chars)^) do
  case L of
   1: case (Words[0]) of
        $0030:
        begin
          // "0"
          Result := False;
          Exit;
        end;
        $0031:
        begin
          // "1"
          Result := True;
          Exit;
        end;
      end;
   2: if (Dwords[0] or $00200020 = $006F006E) then
      begin
        // "no"
        Result := False;
        Exit;
      end;
   3: if (Dwords[0] or $00200020 = $00650079) and (Words[2] or $0020 = $0073) then
      begin
        // "yes"
        Result := True;
        Exit;
      end;
   4: if (Dwords[0] or $00200020 = $00720074) and
         (Dwords[1] or $00200020 = $00650075) then
      begin
        // "true"
        Result := True;
        Exit;
      end;
   5: if (Dwords[0] or $00200020 = $00610066) and
         (Dwords[1] or $00200020 = $0073006C) and
         (Words[4] or $0020 = $0065) then
      begin
        // "false"
        Result := False;
        Exit;
      end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
    Result := False;
  end;
end;

function CachedUTF16String.TryAsHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF16String.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF16String(@Default)._GetHex(Pointer(Chars), Length);
end;

function CachedUTF16String.GetHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function CachedUTF16String._GetHex(S: PWord; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: CachedUTF16String;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF16String.TryAsCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF16String.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedUTF16String(@Default)._GetInt(Pointer(Chars), Length);
end;

function CachedUTF16String.GetCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedUTF16String.TryAsInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF16String.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF16String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function CachedUTF16String.GetInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedUTF16String._GetInt(S: PWord; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedUTF16String;
  HexRet: record
    Value: Integer;
  end;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF16String.TryAsHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF16String.AsHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function CachedUTF16String.GetHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function CachedUTF16String._GetHex64(S: PWord; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: CachedUTF16String;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF16String.TryAsUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF16String.AsUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedUTF16String.GetUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedUTF16String.TryAsInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF16String.AsInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedUTF16String.GetInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF16String(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedUTF16String._GetInt64(S: PWord; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedUTF16String;
  HexRet: record
    Value: Integer;
  end;  
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PCachedUTF16String(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PCachedUTF16String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PCachedUTF16String(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF16String._GetInt_19(S: PWord; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PWord;
  end;
  {$else}
  _S: PWord;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
  Result := (Result shr 1) or Low(NativeInt);
end;

function CachedUTF16String.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF16String.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF16String.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function CachedUTF16String.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedUTF16String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF16String.GetFloat: Extended;
begin
  Result := PCachedUTF16String(0)._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF16String._GetFloat(S: PWord; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: CachedUTF16String;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PCachedUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedUTF16String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PCachedUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedUTF16String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PCachedUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedUTF16String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PCachedUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedUTF16String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PCachedUTF16String(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef CPUX86}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF16String.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function CachedUTF16String.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function CachedUTF16String.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF16String.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function CachedUTF16String.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function CachedUTF16String.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF16String.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function CachedUTF16String.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function CachedUTF16String.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF16String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PWord;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := CachedTexts._GetDateTime(Buffer);
end;


{ CachedUTF32String }

function CachedUTF32String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure CachedUTF32String.SetEmpty(Value: Boolean);
var
  V: NativeUInt;
begin
  if (Value) then
  begin
    V := 0;
    FLength := V;
    F.NativeFlags := V;
  end;
end;

procedure ascii_from_utf32(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
begin
  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Src^;
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Src^;
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure ascii_from_utf32_lower(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
  Converter: PUniConvWW;
begin
  Converter := Pointer(@UNICONV_CHARCASE.LOWER);

  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure ascii_from_utf32_upper(Dest: Pointer; Src: PCardinal; Count: NativeInt);
var
  i: NativeInt;
  Converter: PUniConvWW;
begin
  Converter := Pointer(@UNICONV_CHARCASE.UPPER);

  if (Count < 0) then
  begin
    Count := -Count;
    for i := 0 to Count - 1 do
    begin
      PWord(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Word));
    end;
  end else
  begin
    for i := 0 to Count - 1 do
    begin
      PByte(Dest)^ := Converter[Src^];
      Inc(Src);
      Inc(NativeUInt(Dest), SizeOf(Byte));
    end;
  end;
end;

procedure CachedUTF32String.ToAnsiString(var S: AnsiString; const CP: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
  Pointer(S) := Dest;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;
      if (X > $7f) then
      begin
        if (X > $ffff) then X := UNKNOWN_CHARACTER;
        X := PUniConvBW(Converter)[X];
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32(Dest, Src, L)
  end;
end;

procedure CachedUTF32String.ToLowerAnsiString(var S: AnsiString; const CP: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
  Pointer(S) := Dest;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := UNICONV_CHARCASE.VALUES[X];
        if (X > $7f) then X := PUniConvBW(Converter)[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32_lower(Dest, Src, L)
  end;
end;

procedure CachedUTF32String.ToUpperAnsiString(var S: AnsiString; const CP: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);

  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  DestSBCS := Pointer(NativeUInt(Index) * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
  StoredDestSBCS := DestSBCS;
  Dest := AnsiStringAlloc(Pointer(S), L, DestSBCS.CodePage);
  Pointer(S) := Dest;

  Src := Self.Chars;
  if (not Self.Ascii) then
  begin
    Converter := StoredDestSBCS.FVALUES;
    if (Converter = nil) then Converter := StoredDestSBCS.AllocFillVALUES(StoredDestSBCS.FVALUES);

    {$ifdef CPUX86}
    Dest := Pointer(S);
    {$endif}

    repeat
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := UNICONV_CHARCASE.VALUES[$10000 + X];
        if (X > $7f) then X := PUniConvBW(Converter)[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dec(L);
      PByte(Dest)^ := X;
      Inc(NativeUInt(Src), SizeOf(Cardinal));
      Inc(NativeUInt(Dest), SizeOf(Byte));
    until (L = 0)
  end else
  begin
    ascii_from_utf32_upper(Dest, Src, L)
  end;
end;

type
  TSBCSConv = record
    CP: Word;
    Length: NativeInt;
    CaseLookup: PUniConvWW;
  end;

procedure sbcs_from_utf32(Dest: PByte; Src: PCardinal; const SBCSConv: TSBCSConv);
var
  i, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  CaseLookup: PUniConvWW;
begin
  // DestSBCS
  Index := NativeUInt(SBCSConv.CP);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SBCSConv.CP) or (Value < 0) then Break;
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
  until (False);
  Index := Byte(Value shr 16);
  Index := Index * SizeOf(TUniConvSBCS) + NativeInt(@UNICONV_SUPPORTED_SBCS);

  // converter (Index)
  if (PUniConvSBCSEx(Index).FVALUES <> nil) then
  begin
    Index := NativeUInt(PUniConvSBCSEx(Index).FVALUES);
  end else
  begin
    Index := NativeUInt(PUniConvSBCSEx(Index).AllocFillVALUES(PUniConvSBCSEx(Index).FVALUES));
  end;

  CaseLookup := Pointer(SBCSConv.CaseLookup);
  if (CaseLookup <> nil) then
  begin
    for i := 1 to SBCSConv.Length do
    begin
      X := PCardinal(Src)^;

      if (X <= $ffff) then
      begin
        X := CaseLookup[X];
        if (X > $7f) then X := PUniConvBW(Index){Converter}[X];
      end else
      begin
        X := UNKNOWN_CHARACTER;
      end;

      Dest^ := X;
      Inc(Src);
      Inc(Dest);
    end;
  end else
  begin
    for i := 1 to SBCSConv.Length do
    begin
      X := PCardinal(Src)^;

      if (X > $7f) then
      begin
        if (X > $ffff) then X := UNKNOWN_CHARACTER;
        X := PUniConvBW(Index){Converter}[X];
      end;

      Dest^ := X;
      Inc(Src);
      Inc(Dest);
    end;
  end;
end;

procedure CachedUTF32String.ToAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CP := CP;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := nil;
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32(Pointer(@S[1]), Src, L)
  end;
end;

procedure CachedUTF32String.ToLowerAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CP := CP;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := Pointer(@UNICONV_CHARCASE.LOWER);
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32_lower(Pointer(@S[1]), Src, L)
  end;
end;

procedure CachedUTF32String.ToUpperAnsiShortString(var S: ShortString; const CP: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CP = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CP := CP;

  L := Self.Length;
  if (L > NativeUInt(High(S))) then L := High(S);
  PByte(@S)^ := L;
  if (L = 0) then Exit;

  Src := Pointer(Self.Chars);
  if (not Self.Ascii) then
  begin
    SBCSConv.Length := L;
    SBCSConv.CaseLookup := Pointer(@UNICONV_CHARCASE.UPPER);
    sbcs_from_utf32(Pointer(@S[1]), Src, SBCSConv);
  end else
  begin
    ascii_from_utf32_upper(Pointer(@S[1]), Src, L)
  end;
end;

function utf8_from_utf32(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
begin
  StoredDest := Dest;

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

function utf8_from_utf32_lower(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
  Converter: PUniConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@UNICONV_CHARCASE.LOWER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          X := Converter[X];
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          X := Converter[X];
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      X := Converter[X];
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

function utf8_from_utf32_upper(Dest: PByte; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PByte;
  Converter: PUniConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@UNICONV_CHARCASE.UPPER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X > $7f) then
    begin
      case X of
        $80..$7ff:
        begin
          X := Converter[X];
          // X := (X shr 6) + ((X and $3f) shl 8) + $80C0;
          Y := X;
          X := (X shr 6) + $80C0;
          Y := (Y and $3f) shl 8;
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
        end;
        $800..$ffff:
        begin
          X := Converter[X];
          // X := (X shr 12) + ((X and $0fc0) shl 2) + ((X and $3f) shl 16) + $8080E0;
          Y := X;
          X := (X and $0fc0) shl 2;
          Inc(X, (Y and $3f) shl 16);
          Y := (Y shr 12);
          Inc(X, $8080E0);
          Inc(X, Y);

          PWord(Dest)^ := X;
          Inc(Dest, 2);
          X := X shr 16;
          PByte(Dest)^ := X;
          Inc(Dest);
        end;
        $10000..MAXIMUM_CHARACTER:
        begin
          //X := (X shr 18) + ((X and $3f) shl 24) + ((X and $0fc0) shl 10) +
          //     ((X shr 4) and $3f00) + Integer($808080F0);
          Y := (X and $3f) shl 24;
          Y := Y + ((X and $0fc0) shl 10);
          Y := Y + (X shr 18);
          X := (X shr 4) and $3f00;
          Inc(Y, Integer($808080F0));
          Inc(X, Y);

          PCardinal(Dest)^ := X;
          Inc(Dest, 4);
        end;
      else
        PByte(Dest)^ := UNKNOWN_CHARACTER;
        Inc(Dest);
      end;
    end else
    begin
      X := Converter[X];
      PByte(Dest)^ := X;
      Inc(Dest);
    end;
  end;

  Result := NativeUInt(Dest) - NativeUInt(StoredDest);
end;

procedure CachedUTF32String.ToUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L shl 2, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    Src := Self.Chars;
    AnsiStringFinish(Pointer(S), Dest, utf8_from_utf32(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, L);
  end;
end;

procedure CachedUTF32String.ToLowerUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L shl 2, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    Src := Self.Chars;
    AnsiStringFinish(Pointer(S), Dest, utf8_from_utf32_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, L);
  end;
end;

procedure CachedUTF32String.ToUpperUTF8String(var S: UTF8String);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      AnsiStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := AnsiStringAlloc(Pointer(S), L shl 2, CODEPAGE_UTF8 or (1 shl 31));
    Pointer(S) := Dest;
    Src := Self.Chars;
    AnsiStringFinish(Pointer(S), Dest, utf8_from_utf32_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := AnsiStringAlloc(Pointer(S), L, CODEPAGE_UTF8);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, L);
  end;
end;

procedure CachedUTF32String.ToUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TUniConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + (1 shl 24);
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32(Dest, Pointer(Self.Chars), L);
  end;
end;

procedure CachedUTF32String.ToLowerUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TUniConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + Ord(ccLower) shl 16;
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32_lower(Dest, Pointer(Self.Chars), L);
  end;
end;

procedure CachedUTF32String.ToUpperUTF8ShortString(var S: ShortString);
var
  L: NativeUInt;
  Dest: PByte;
  Context: TUniConvContextEx;
begin
  Dest := Pointer(@S);
  L := Self.Length;
  if (L = 0) then
  begin
    Dest^ := L;
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Inc(Dest);
    Context.Destination := Dest;
    Context.DestinationSize := NativeUInt(High(S));
    Context.SourceSize := L shl 2;
    Context.Source := Self.Chars;

    // conversion
    Context.F.Flags := Ord(bomUTF32) + Ord(bomUTF8) shl (32 - 5) + Ord(ccUpper) shl 16;
    Context.convert_universal;
    Dest := Context.Destination;
    Dec(Dest);
    Dest^ := Context.DestinationWritten;
  end else
  begin
    // Ascii chars
    if (L > NativeUInt(High(S))) then L := NativeUInt(High(S));
    Dest^ := L;
    Inc(Dest);
    ascii_from_utf32_upper(Dest, Pointer(Self.Chars), L);
  end;
end;

function utf16_from_utf32(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
begin
  StoredDest := Dest;

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := X;

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

function utf16_from_utf32_lower(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
  Converter: PUniConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@UNICONV_CHARCASE.LOWER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := Converter[X];

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);

      {$ifdef CPUX86}
      Converter := Pointer(@UNICONV_CHARCASE.LOWER);
      {$endif}
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

function utf16_from_utf32_upper(Dest: PWord; Src: PCardinal; Count: NativeUInt): NativeUInt;
var
  X, Y, i: NativeUInt;
  StoredDest: PWord;
  Converter: PUniConvWW;
begin
  StoredDest := Dest;
  Converter := Pointer(@UNICONV_CHARCASE.UPPER);

  for i := 1 to Count do
  begin
    X := Src^;
    Inc(Src);

    if (X <= $ffff) then
    begin
      if (X shr 11 = $1B) then Dest^ := $fffd
      else Dest^ := Converter[X];

      Inc(Dest);
    end else
    begin
      Y := (X - $10000) shr 10 + $d800;
      X := (X - $10000) and $3ff + $dc00;
      X := (X shl 16) + Y;

      PCardinal(Dest)^ := X;
      Inc(Dest, 2);

      {$ifdef CPUX86}
      Converter := Pointer(@UNICONV_CHARCASE.UPPER);
      {$endif}
    end;
  end;

  Result := (NativeUInt(Dest) - NativeUInt(StoredDest)) shr 1;
end;

procedure CachedUTF32String.ToWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WideStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    WideStringFinish(Pointer(S), Dest, utf16_from_utf32(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, -L)
  end;
end;

procedure CachedUTF32String.ToLowerWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WideStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    WideStringFinish(Pointer(S), Dest, utf16_from_utf32_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, -L)
  end;
end;

procedure CachedUTF32String.ToUpperWideString(var S: WideString);
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
      WideStringClear(S);
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := WideStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    WideStringFinish(Pointer(S), Dest, utf16_from_utf32_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := WideStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, -L)
  end;
end;

procedure CachedUTF32String.ToUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UnicodeStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    UnicodeStringFinish(Pointer(S), Dest, utf16_from_utf32(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure CachedUTF32String.ToLowerUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UnicodeStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    UnicodeStringFinish(Pointer(S), Dest, utf16_from_utf32_lower(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_lower(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure CachedUTF32String.ToUpperUnicodeString(var S: UnicodeString);
{$ifdef UNICODE}
var
  L: NativeUInt;
  Dest, Src: Pointer;
begin
  L := Self.Length;
  if (L = 0) then
  begin
    if (Pointer(S) <> nil) then
    {$ifNdef NEXTGEN}
      AnsiStringClear(S);
    {$else}
      UnicodeStringClear(S);
    {$endif}
    Exit;
  end;

  if (not Self.Ascii) then
  begin
    Dest := UnicodeStringAlloc(Pointer(S), L shl 1, -1);
    Pointer(S) := Dest;
    Src := Self.Chars;
    UnicodeStringFinish(Pointer(S), Dest, utf16_from_utf32_upper(Dest, Src, L));
  end else
  begin
    // Ascii chars
    Dest := UnicodeStringAlloc(Pointer(S), L, 0);
    Pointer(S) := Dest;
    Src := Self.Chars;
    ascii_from_utf32_upper(Dest, Src, -L)
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure CachedUTF32String.ToString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUnicodeString(S);
  {$else}
     ToAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$ifend}

procedure CachedUTF32String.ToLowerString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToLowerUnicodeString(S);
  {$else}
     ToLowerAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToLowerAnsiString
end;
{$ifend}

procedure CachedUTF32String.ToUpperString(var S: string);
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  {$ifdef UNICODE}
     ToUpperUnicodeString(S);
  {$else}
     ToUpperAnsiString(S);
  {$endif}
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToUpperAnsiString
end;
{$ifend}

function CachedUTF32String.GetAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

function CachedUTF32String.GetLowerAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToLowerAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToLowerAnsiString
end;
{$endif}

function CachedUTF32String.GetUpperAnsiString: AnsiString;
{$ifNdef CPUINTEL}
begin
  ToUpperAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToUpperAnsiString
end;
{$endif}

function CachedUTF32String.GetUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function CachedUTF32String.GetLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function CachedUTF32String.GetUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function CachedUTF32String.GetWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function CachedUTF32String.GetLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function CachedUTF32String.GetUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

{$ifdef UNICODE}
function CachedUTF32String.GetUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}

function CachedUTF32String.GetLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUnicodeString
end;
{$endif}

function CachedUTF32String.GetUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUnicodeString
end;
{$endif}
{$endif}

{$ifdef OPERATORSUPPORT}
class operator CachedUTF32String.Implicit(const a: CachedUTF32String): AnsiString;
{$ifNdef CPUINTEL}
begin
  ToAnsiString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef CPUX86}
  xor ecx, ecx
  {$else .CPUX64}
  xor r8, r8
  {$endif}
  jmp ToAnsiString
end;
{$endif}

class operator CachedUTF32String.Implicit(const a: CachedUTF32String): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator CachedUTF32String.Implicit(const a: CachedUTF32String): WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
class operator CachedUTF32String.Implicit(const a: CachedUTF32String): UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUnicodeString
end;
{$endif}
{$endif}
{$endif}

procedure CachedUTF32String.Assign(const S: UCS4String; const NullTerminated: Boolean);
var
  P: PNativeInt;
begin
  P := Pointer(S);
  Self.FChars := Pointer(P);
  if (P = nil) then
  begin
    Self.FLength := NativeUInt(P){0};
    Self.F.NativeFlags := NativeUInt(P){0};
  end else
  begin
    Dec(P);
    Self.FLength := P^ - Ord(NullTerminated){$ifdef FPC}+1{$endif};
    Self.F.NativeFlags := 0;
  end;
end;

function CachedUTF32String.DetectAscii: Boolean;
label
  fail;
var
  P: PCardinal;
  L: NativeUInt;
  {$ifdef LARGEINT}
  MASK: NativeUInt;
  {$endif}  
begin
  P := Pointer(FChars);

  {$ifdef LARGEINT}
  MASK := not NativeUInt($7f0000007f);
  L := FLength;
  while (L > 1) do  
  begin  
    if (PNativeUInt(P)^ and MASK <> 0) then goto fail;   
    Dec(L, 2);
    Inc(P, 2);
  end;  
  if (L and 1 <> 0) and (P^ > $7f) then goto fail;
  {$else}
  for L := 1 to FLength do
  begin
    if (P^ > $7f) then goto fail;   
    Inc(P);
  end;      
  {$endif}    
  
  Ascii := True;
  Result := True;  
  Exit;
fail:
  Ascii := False;
  Result := False;  
end;

function CachedUTF32String.LTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  if (S^ > 32) then
  begin
    Result := True;
    Exit;
  end else
  begin
    Result := _LTrim(S, L);
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  test ecx, ecx
  jz @1
  xor eax, eax
  ret
@1:
  cmp dword ptr [edx], 32
  jbe _LTrim
  mov al, 1
end;
{$ifend}

function CachedUTF32String._LTrim(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  TopS: PCardinal;
begin  
  TopS := @PCharArray(S)[L];

  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);
  
  FChars := Pointer(S);
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 2; 
  Result := True;
  Exit;
fail:
  L := 0;
  FLength := L{0};  
  Result := False; 
end;

function CachedUTF32String.RTrim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      Result := True;
      Exit;
    end else
    begin
      Result := _RTrim(S, L);
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:    
  cmp dword ptr [edx + ecx*4], 32
  jbe _RTrim
  mov al, 1
end;
{$ifend}

function CachedUTF32String._RTrim(S: PCardinal; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  TopS: PCardinal;
begin  
  TopS := @PCharArray(S)[H];
  
  Dec(S);
  repeat
    Dec(TopS);  
    if (S = TopS) then goto fail;    
  until (TopS^ > 32);

  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 2;
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedUTF32String.Trim: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  S: PCardinal;
begin
  L := Length;
  S := Pointer(FChars);
  if (L = 0) then
  begin
    Result := False;
    Exit;
  end else
  begin
    Dec(L);
    if (PCharArray(S)[L] > 32) then
    begin
      // LTrim or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _LTrim(S, L+1);
        Exit;
      end;
    end else
    begin
      // RTrim or Trim
      if (S^ > 32) then
      begin
        Result := _RTrim(S, L);
        Exit;
      end else
      begin
        Result := _Trim(S, L);
      end;
    end;
  end;
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  sub ecx, 1
  jge @1
  xor eax, eax
  ret
@1:
  cmp dword ptr [edx + ecx*4], 32
  jbe @2
  // LTrim or True
  inc ecx
  cmp dword ptr [edx], 32
  jbe _LTrim
  mov al, 1
  ret
@2:
  // RTrim or Trim
  cmp dword ptr [edx], 32
  ja _RTrim
  jmp _Trim
end;
{$ifend}

function CachedUTF32String._Trim(S: PCardinal; H: NativeUInt): Boolean;
label
  fail;
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  TopS: PCardinal;
begin  
  if (H = 0) then goto fail;  
  TopS := @PCharArray(S)[H];      

  // LTrim
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // RTrim
  Dec(S);
  repeat
    Dec(TopS);  
  until (TopS^ > 32);    
  
  // Result
  Dec(NativeUInt(TopS), NativeUInt(S));   
  FLength := NativeUInt(TopS) shr 2; 
  Result := True;
  Exit;
fail:
  H := 0;
  FLength := H{0};  
  Result := False; 
end;

function CachedUTF32String.SubString(const From, Count: NativeUInt): CachedUTF32String;
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  Result.F.NativeFlags := Self.F.NativeFlags;
  Result.FChars := Pointer(@PCharArray(Self.FChars)[From]);

  L := Self.FLength;
  Dec(L, From);
  if (NativeInt(L) <= 0) then
  begin
    Result.FLength := 0;
    Exit;
  end;

  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedUTF32String.SubString(const Count: NativeUInt): CachedUTF32String;
var
  L: NativeUInt;
begin
  Result.FChars := Self.FChars;
  Result.F.NativeFlags := Self.F.NativeFlags;
  L := Self.FLength;
  if (L < Count) then
  begin
    Result.FLength := L;
  end else
  begin
    Result.FLength := Count;
  end;
end;

function CachedUTF32String.Offset(const Count: NativeUInt): Boolean;
type
  TCharArray = array[0..0] of Cardinal;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
begin
  L := FLength;
  if (L <= Count) then
  begin
    FChars := Pointer(@PCharArray(FChars)[L]);
    FLength := 0;
    Result := False;
  end else
  begin
    Dec(L, Count);
    FLength := L;
    FChars := Pointer(@PCharArray(FChars)[Count]);
    Result := True;
  end;
end;

function CachedUTF32String.Hash: Cardinal;
var
  L, L_High: NativeUInt;
  P: PCardinal;
  V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  repeat
    // Result := (Result shr 5) xor (P^ + Result);
    // Dec(L);/Inc(P);
    V := Result shr 5;
    Dec(L);
    Inc(Result, P^);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedUTF32String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86}
asm
  cmp byte ptr [EAX].F.B0, 0
  jnz _HashIgnoreCaseAscii
  // todo
  jmp _HashIgnoreCase
end;
{$ifend}

function CachedUTF32String._HashIgnoreCaseAscii: Cardinal;
var
  L, L_High: NativeUInt;
  P: PCardinal;
  X, V: Cardinal;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  L_High := L shl (32-9);
  if (L > 255) then L_High := NativeInt(L_High) or (1 shl 31);
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := P^;
    X := X or ((X and $40) shr 1);
    Dec(L);
    V := Result shr 5;
    Inc(Result, X);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + (L_High);
end;

function CachedUTF32String._HashIgnoreCase: Cardinal;
var
  L: NativeUInt;
  P: PCardinal;
  X, V: Cardinal;
  {$ifdef CPUX86}
  S: record
    L_High: NativeUInt;
  end;
  {$else}
  L_High: NativeUInt;
  {$endif}
  lookup_utf16_lower: PUniConvWW;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  lookup_utf16_lower := Pointer(@UNICONV_CHARCASE.LOWER);
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := P^;
    Dec(L);
    if (X > $7f) then
    begin
      if (X <= High(Word)) then
        X := lookup_utf16_lower[X];
    end else
    begin
      X := X or ((X and $40) shr 1);
    end;

    V := Result shr 5;
    Inc(Result, X);
    Inc(P);
    Result := Result xor V;
  until (L = 0);

  Result := (Result and (-1 shr 9)) + ({$ifdef CPUX86}S.{$endif}L_High);
end;

function CachedUTF32String.CharPos(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.Pos(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.PosIgnoreCase(const S: UnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function CachedUTF32String.TryAsBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetBool
  pop edx
  pop ecx
  mov [ecx], al
  xchg eax, edx
end;
{$ifend}

function CachedUTF32String.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedUTF32String(@Default)._GetBool(Pointer(Chars), Length);
end;

function CachedUTF32String.GetBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function CachedUTF32String._GetBool(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
type
  TStrAsData = packed record
    Dwords: array[0..High(Integer) div 4 - 1] of Cardinal;
  end;
var
  Marker: NativeInt;
  Buffer: CachedByteString;
begin
  Buffer.Chars := Pointer(S);
  Buffer.Length := L;

  with TStrAsData(Pointer(Buffer.Chars)^) do
  case L of
   1: case (Dwords[0]) of
        Ord('0'):
        begin
          // "0"
          Result := False;
          Exit;
        end;
        Ord('1'):
        begin
          // "1"
          Result := True;
          Exit;
        end;
      end;
   2: if (Dwords[0] or $20 = Ord('n')) and (Dwords[1] or $20 = Ord('o')) then
      begin
        // "no"
        Result := False;
        Exit;
      end;
   3: if (Dwords[0] or $20 = Ord('y')) and (Dwords[1] or $20 = Ord('e')) and
         (Dwords[2] or $20 = Ord('s')) then
      begin
        // "yes"
        Result := True;
        Exit;
      end;
   4: if (Dwords[0] or $20 = Ord('t')) and (Dwords[1] or $20 = Ord('r')) and
         (Dwords[2] or $20 = Ord('u')) and (Dwords[3] or $20 = Ord('e')) then
      begin
        // "true"
        Result := True;
        Exit;
      end;
   5: if (Dwords[0] or $20 = Ord('f')) and (Dwords[1] or $20 = Ord('a')) and
         (Dwords[2] or $20 = Ord('l')) and (Dwords[3] or $20 = Ord('s')) and
         (Dwords[4] or $20 = Ord('e')) then
      begin
        // "false"
        Result := False;
        Exit;
      end;
  end;

fail:
  Marker := NativeInt(@Self);
  if (Marker = 0) then
  begin
    Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidBoolean), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PBoolean(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
    Result := False;
  end;
end;

function CachedUTF32String.TryAsHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF32String.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF32String(@Default)._GetHex(Pointer(Chars), Length);
end;

function CachedUTF32String.GetHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function CachedUTF32String._GetHex(S: PCardinal; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: CachedUTF32String;
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;
  Result := 0;

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      Result := Result shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      Result := Result shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(Result, X);
  until (L = 0);

  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF32String.TryAsCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF32String.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedUTF32String(@Default)._GetInt(Pointer(Chars), Length);
end;

function CachedUTF32String.GetCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedUTF32String.TryAsInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt
  pop edx
  pop ecx
  mov [ecx], eax
  xchg eax, edx
end;
{$ifend}

function CachedUTF32String.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF32String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function CachedUTF32String.GetInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetInt(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function CachedUTF32String._GetInt(S: PCardinal; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedUTF32String;
  HexRet: record
    Value: Integer;
  end;  
  X: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L >= 10{high(Result)}) then
  begin
    Dec(L);
    Marker := Marker or 2;
    if (L > 10-1) then goto fail;
  end;
  Result := 0;

  repeat
    X := NativeUInt(S^) - Ord('0');
    Result := Result * 10;
    Dec(L);
    Inc(Result, X);
    Inc(S);
    if (X >= 10) then goto fail;
  until (L = 0);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        case Cardinal(Result) of
          0..High(Cardinal) div 10 - 1: ;
          High(Cardinal) div 10:
          begin
            if (X > High(Cardinal) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end else
      begin
        case Cardinal(Result) of
          0..High(Integer) div 10 - 1: ;
          High(Integer) div 10:
          begin
            if (X > (NativeUInt(Marker) shr 2) + High(Integer) mod 10) then goto fail;
          end;
        else
          goto fail;
        end;
      end;

      Result := Result * 10;
      Inc(Result, X);
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInteger(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF32String.TryAsHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetHex64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF32String.AsHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function CachedUTF32String.GetHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function CachedUTF32String._GetHex64(S: PCardinal; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: CachedUTF32String;
  X: NativeUInt;
  R1, R2: NativeUInt;
  Marker: NativeInt;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);

  X := S^;
  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 2*SizeOf(Result)) then goto fail;

  R1 := 0;
  R2 := 0;

  if (L > 8) then
  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R2 := R2 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R2 := R2 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R2, X);
  until (L = 8);

  repeat
    X := S^;
    Dec(L);
    Inc(S);
    if (X >= Ord('A')) then
    begin
      X := X or $20;
      Dec(X, Ord('a') - 10);
      R1 := R1 shl 4;
      if (X >= 16) then goto fail;
    end else
    begin
      Dec(X, Ord('0'));
      R1 := R1 shl 4;
      if (X >= 10) then goto fail;
    end;

    Inc(R1, X);
  until (L = 0);

  {$ifdef SMALLINT}
  with PPoint(@Result)^ do
  begin
    X := R1;
    Y := R2;
  end;
  {$else .LARGEINT}
  Result := (R2 shl 32) + R1;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@SInvalidHex), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF32String.TryAsUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF32String.AsUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedUTF32String.GetUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedUTF32String.TryAsInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  push edx
  push 1
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  neg ecx
  sub eax, esp
  call _GetInt64
  mov ecx, [esp+4]
  mov [ecx], eax
  mov [ecx+4], edx
  mov eax, [esp]
  add esp, 8
end;
{$ifend}

function CachedUTF32String.AsInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(@Default)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function CachedUTF32String.GetInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PCachedUTF32String(0)._GetInt64(Pointer(Chars), -Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  neg ecx
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function CachedUTF32String._GetInt64(S: PCardinal; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: CachedUTF32String;
  HexRet: record
    Value: Integer;
  end;  
  X: NativeUInt;
  Marker: NativeInt;
  R1, R2: Integer;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  Marker := 0;
  if (L >= 0) then
  begin
    if (L = 0) then goto fail;
  end else
  begin
    L := -L;
    Inc(Marker);
  end;

  X := S^;
  Buffer.Length := L;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Marker := Marker or 4;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  case X of
    Ord('0'):
    begin
      Inc(S);
      if (L = 1) then goto zero;
      X := S^;
      Dec(L);
      if (X or $20 = Ord('x')) then goto hex;

      if (X = Ord('0')) then
      repeat
        Inc(S);
        if (L = 1) then goto zero;
        X := S^;
        Dec(L);
      until (X <> Ord('0'));
    end;
    Ord('$'):
    begin
    hex:
      Inc(S);
      if (L = 1) then goto fail;
      Dec(L);

      HexRet.Value := 1;
      if (Marker and 4 = 0) then
      begin
        Result := PCachedUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PCachedUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PCachedUTF32String(nil)._GetInt_19(S, L);
    if (R1 < 0) then goto fail;

    if (Marker and 4 <> 0) then R1 := -R1;
    Result := R1;
    Exit;
  end else
  if (L >= 19) then
  begin
    if (L = 19) then
    begin
      Marker := Marker or 2;
      Dec(L);
    end else
    if (L = 20) and (Marker and 1 = 0) then
    begin
      Marker := Marker or (2 or 4{TEN_BB});
      if (S^ <> $31{Ord('1')}) then goto fail;
      Dec(L, 2);
      Inc(S);
    end else
    goto fail;
  end;

  Dec(L, 9);
  R2 := PCachedUTF32String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PCachedUTF32String(nil)._GetInt_19(S, 9);
  Inc(S, 9);
  if (R1 < 0) then goto fail;

  Result := Decimal64R21(R2, R1);

  if (Marker > 1) then
  begin
    if (Marker and 2 <> 0) then
    begin
      X := NativeUInt(S^) - Ord('0');
      if (X >= 10) then goto fail;

      if (Marker and 1 = 0) then
      begin
        // UInt64
        if (Marker and 4 = 0) then
        begin
          Result := Decimal64VX(Result, X);
        end else
        begin
          if (Result >= _HIGHU64 div 10) then
          begin
            if (Result = _HIGHU64 div 10) then
            begin
              if (X > NativeUInt(_HIGHU64 mod 10)) then goto fail;
            end else
            begin
              goto fail;
            end;
          end;

          Result := Decimal64VX(Result, X);
          Inc(Result, TEN_BB);
        end;

        Exit;
      end else
      begin
        // Int64
        if (Result >= High(Int64) div 10) then
        begin
          if (Result = High(Int64) div 10) then
          begin
            if (X > (NativeUInt(Marker) shr 2) + NativeUInt(High(Int64) mod 10)) then goto fail;
          end else
          begin
            goto fail;
          end;
        end;

        Result := Decimal64VX(Result, X);
      end;
    end;

    if (Marker and 4 <> 0) then Result := -Result;
  end;
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidInteger), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PInt64(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF32String._GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
label
  fail, _1, _2, _3, _4, _5, _6, _7, _8, _9;
var
  {$ifdef CPUX86}
  Store: record
    _R: PNativeInt;
    _S: PCardinal;
  end;
  {$else}
  _S: PCardinal;
  {$endif}
  _R: PNativeInt;
begin
  {$ifdef CPUX86}Store.{$endif}_R := Pointer(@Self);
  {$ifdef CPUX86}Store.{$endif}_S := S;

  Result := 0;
  case L of
    9:
    begin
    _9:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      if (L >= 10) then goto fail;
      Inc(Result, L);
      goto _8;
    end;
    8:
    begin
    _8:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _7;
    end;
    7:
    begin
    _7:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _6;
    end;
    6:
    begin
    _6:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _5;
    end;
    5:
    begin
    _5:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _4;
    end;
    4:
    begin
    _4:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _3;
    end;
    3:
    begin
    _3:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _2;
    end;
    2:
    begin
    _2:
      L := NativeUInt(S^) - Ord('0');
      Inc(S);
      Result := Result * 2;
      if (L >= 10) then goto fail;
      Result := Result * 5;
      Inc(Result, L);
      goto _1;
    end
  else
  _1:
    L := NativeUInt(S^) - Ord('0');
    Inc(S);
    Result := Result * 2;
    if (L >= 10) then goto fail;
    Result := Result * 5;
    Inc(Result, L);
    Exit;
  end;

fail:
  {$ifdef CPUX86}
  _R := Store._R;
  {$endif}
  Result := Result shr 1;
  if (_R <> nil) then _R^ := Result;

  Result := NativeInt({$ifdef CPUX86}Store.{$endif}_S);
  Dec(Result, NativeInt(S));
  Result := (Result shr 2) or (Low(NativeInt) or (Low(NativeInt) shr 1));
end;

function CachedUTF32String.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF32String.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF32String.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function CachedUTF32String.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedUTF32String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF32String.GetFloat: Extended;
begin
  Result := PCachedUTF32String(0)._GetFloat(Pointer(Chars), Length);
end;

function CachedUTF32String._GetFloat(S: PCardinal; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: CachedUTF32String;
  Store: record
    V: NativeInt;
    Sign: Byte;
  end;
  X: NativeUInt;
  Marker: NativeInt;

  V: NativeInt;
  Base: Double;
  TenPowers: PTenPowers;
begin
  Buffer.F.NativeFlags := NativeUInt(@Self);
  Buffer.Chars := Pointer(S);
  if (L = 0) then goto fail;

  X := S^;
  Buffer.Length := L;
  Store.Sign := 0;
  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      Store.Sign := $80;
      goto skipsign;
    end;
    Ord('+'):
    begin
    skipsign:
      Inc(S);
      if (L = 1) then goto fail;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto zero;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  // integer part
  begin
    if (L > 9) then
    begin
      V := PCachedUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedUTF32String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      V := not V;
      Result := Integer(Store.V);
      Dec(L, V);
      Inc(S, V);
    end else
    begin
      Result := Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      repeat
        if (L > 9) then
        begin
          V := PCachedUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedUTF32String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result * TEN_POWERS[True][X] + Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Result := Result * TEN_POWERS[True][X] + Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  case S^ of
    Ord('.'), Ord(','): goto frac;
    Ord('e'), Ord('E'):
    begin
      if (S <> Pointer(Buffer.Chars)) then goto exp;
      goto fail;
    end
  else
    goto fail;
  end;

frac:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // frac part
  begin
    if (L > 9) then
    begin
      V := PCachedUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PCachedUTF32String(@Store.V)._GetInt_19(S, L);
      X := L;
    end;

    if (V < 0) then
    begin
      X := not V;
      Result := Result + TEN_POWERS[False][X] * Integer(Store.V);
      Dec(L, X);
      Inc(S, X);
    end else
    begin
      Result := Result + TEN_POWERS[False][X] * Integer(V);
      if (X = L) then goto done;
      Dec(L, X);
      Inc(S, X);

      Base := TEN_POWERS[False][9];
      repeat
        if (L > 9) then
        begin
          V := PCachedUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PCachedUTF32String(@Store.V)._GetInt_19(S, L);
          X := L;
        end;

        if (V < 0) then
        begin
          X := not V;
          Result := Result + Base * TEN_POWERS[False][X] * Integer(Store.V);
          Dec(L, X);
          Inc(S, X);
          break;
        end else
        begin
          Base := Base * TEN_POWERS[False][X];
          Result := Result + Base * Integer(V);
          if (X = L) then goto done;
          Dec(L, X);
          Inc(S, X);
        end;
      until (False);
    end;
  end;

  if (S^ or $20 <> $65{Ord('e')}) then goto fail;
exp:
  if (L = 1) then goto done;
  Inc(S);
  Dec(L);

  // exponent part
  X := S^;
  TenPowers := @TEN_POWERS[True];

  if (X <= Ord('-')) then
  case X of
    Ord('-'):
    begin
      TenPowers := @TEN_POWERS[False];
      goto skipexpsign;
    end;
    Ord('+'):
    begin
    skipexpsign:
      Inc(S);
      if (L = 1) then goto done;
      X := S^;
      Dec(L);
    end;
  end;

  if (X = Ord('0')) then
  repeat
    Inc(S);
    if (L = 1) then goto done;
    X := S^;
    Dec(L);
  until (X <> Ord('0'));

  if (L > 3) then goto fail;
  if (L = 1) then
  begin
    X := NativeUInt(S^) - Ord('0');
    if (X >= 10) then goto fail;
    Result := Result * TenPowers[X];
  end else
  begin
    V := PCachedUTF32String(nil)._GetInt_19(S, L);
    if (V < 0) or (V > 300) then goto fail;
    Result := Result * TenPower(TenPowers, V);
  end;
done:
  {$ifdef CPUX86}
    Inc(PExtendedBytes(@Result)[High(TExtendedBytes)], Store.Sign);
  {$else}
    if (Store.Sign <> 0) then Result := -Result;
  {$endif}
  Exit;
fail:
  Marker := Buffer.F.NativeFlags;
  if (Marker = 0) then
  begin
    //Buffer.Flags := 0;
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidFloat), @Buffer);
  end else
  if (Marker > 0) then
  begin
    Result := PExtended(Marker)^;
  end else
  begin
    PBoolean(-Marker)^ := False;
  zero:
    Result := 0;
  end;
end;

function CachedUTF32String.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function CachedUTF32String.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function CachedUTF32String.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF32String.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    Result := Default;
end;

function CachedUTF32String.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function CachedUTF32String.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF32String.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function CachedUTF32String.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function CachedUTF32String.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$ifend}

function CachedUTF32String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
label
  fail;
var
  L, X: NativeUInt;
  Dest: PByte;
  Src: PCardinal;
  Buffer: TDateTimeBuffer;
begin
  Buffer.Value := @Value;
  L := Self.Length;
  Buffer.Length := L;
  Buffer.DT := DT;
  if (L < DT_LEN_MIN[DT]) or (L > DT_LEN_MAX[DT]) then
  begin
  fail:
    Result := False;
    Exit;
  end;

  Src := Pointer(FChars);
  Dest := Pointer(@Buffer.Bytes);
  repeat
    X := Src^;
    Inc(Src);
    if (X > High(DT_BYTES)) then goto fail;
    Dest^ := DT_BYTES[X];
    Dec(L);
    Inc(Dest);
  until (L = 0);

  Result := CachedTexts._GetDateTime(Buffer);
end;


{ TCachedTextReader }

constructor TCachedTextReader.Create(const Context: TUniConvContext;
  const Source: TCachedReader; const IsOwner: Boolean);
begin
  FContext := Context;
  InternalCreate(Source, IsOwner);
end;

procedure TCachedTextReader.InternalCreate(const Source: TCachedReader; const IsOwner: Boolean);
begin
//  inherited Create(InternalCallback, Source, IsOwner);
end;

(*function TCachedTextReader.GetIsDirect: Boolean;
begin
  Result := (@FContext.ConvertProc = @TUniConvContextEx.convert_copy);
end;*)

function TCachedTextReader.DetectBOM(const Source: TCachedReader; const DefaultBOM: TBOM): TBOM;
var
  S: NativeInt;
begin
  if (Source.Margin < 4) and (not Source.EOF) then Source.Flush;

  Result := UniConv.DetectBOM(Source.Current, Source.Margin);
  if (Result <> bomNone) then
  begin
    S := BOM_INFO[Result].Size;
    Inc(Source.Current, S);
//    Dec(Source.Margin, S);
  end else
  begin
    Result := DefaultBOM;
  end;
end;

(*function TCachedTextReader.InternalCallback(Sender: TCachedReReader;
  Buffer: PByte; BufferSize: NativeUInt; Source: TCachedReader): NativeUInt;
var
  I: NativeInt;
  Count: NativeUInt;
begin
  Result := 0;

  repeat
    // actualize source buffer
    if (Source.Margin <= 0) then
    begin
//      if (not Source.Flush) then Exit;
    end;

    // Convert
    FContext.ModeFinalize := Source.EOF;
    I := Context.Convert(Buffer, BufferSize + 16, Source.Current, Source.Margin);

    // Offset
    Count := Context.DestinationWritten;
    Inc(Result, Count);
    Inc(Buffer, Count);
    Dec(BufferSize, Count);
    Source.Skip(Context.SourceRead);
  until (I >= 0);
end;  *)

function TCachedTextReader.GetEOF: Boolean;
begin
  if (Self.Margin > 0) then Result := False
  else Result := Self.EOF;
end;


 { TCachedByteTextReader }

constructor TCachedByteTextReader.Create(const Source: TCachedReader;
  const IsOwner: Boolean; const DefaultBOM: TBOM);
var
  BOM: TBOM;
begin
  BOM := DetectBOM(Source, DefaultBOM);

  if (BOM = bomNone) then
  begin
    FContext.Init(bomNone, bomNone);
//    FLookup := default_lookup_sbcs;
//    FNativeFlags := default_lookup_sbcs_index shl 24;
  end else
  begin
    FContext.Init(bomUtf8, BOM);
  end;
  
  InternalCreate(Source, IsOwner);
end;

function TCachedByteTextReader.Readln(var S: CachedByteString): Boolean;
label
  small, check_x, done_, done;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  CR_XOR_MASK = $0d0d0d0d; // \r
  LF_XOR_MASK = $0a0a0a0a; // \n
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
  ASCII_MASK = Integer($80808080);
var
  P: PByte;
  X, T, V, U, Flags, M: NativeInt;
  L: NativeUInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PCachedByteString;
    Top: PByte;
  end;
  _Self: Pointer;
  _S: PCachedByteString;
  {$endif}
begin
  {$ifdef CPUX86}
  Store.Self := Pointer(Self);
  Store.S := @S;
  {$endif}

  Flags := Self.Margin;
  if (Flags < SizeOf(P^)) then
  begin
//    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
    begin
      Result := False;
      Exit;
    end;
    Flags := Self.Margin;
  end;

  P := Pointer(Self.Current);
  L := Flags{Margin};
  {$ifdef CPUX86}
  Store.Top := @PByteArray(P)[L];
  {$endif}
  S.FChars := Pointer(P);
  Flags := 0;

  if (L < CHARS_IN_CARDINAL) then
  begin
  small:
    V := L;
    {$ifNdef CPUX86}
    L := 0;
    {$endif}
    case V of
      1: begin
           X := P^ shl 24;
           Inc(P);
         end;
      2: begin
           X := PWord(P)^;
           Inc(P, 2);
         end;
    else
      // 3:
      X := PCardinal(P)^ shl 8;
      Inc(P, 3);
    end;
    goto check_x;
  end else
  repeat
    X := PCardinal(P)^;
    {$ifNdef CPUX86}
    Dec(L, CHARS_IN_CARDINAL);
    {$endif}
    Inc(P, CHARS_IN_CARDINAL);

  check_x:
    T := (X xor CR_XOR_MASK);
    U := (X xor LF_XOR_MASK);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then
    begin
      {$ifdef CPUX86}
      L := NativeUInt(Store.Top);
      Dec(L, NativeUInt(P));
      {$endif}
      Flags := Flags or X;
      if (L >= CHARS_IN_CARDINAL) then continue;
      if (L <> 0) then goto small;
      goto done_;
    end;

    Dec(P, CHARS_IN_CARDINAL);
    L := Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0));
    Inc(P, L);
    L := L shl 3;
    Flags := Flags or (X shl L);
    {$ifdef CPUX86}_Self := Store.Self;{$endif}
    X := X shr L;
    {$ifdef CPUX86}_S := Store.S;{$endif}

    {$ifdef CPUX86}with TCachedByteTextReader(_Self) do{$endif}
    begin
      {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := FNativeFlags + Byte(Flags and ASCII_MASK = 0);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
      {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount};
      M := Margin - Flags{BytesCount};

      Inc(P);
      Dec(M, SizeOf(P^));
      if (Byte(X) <> $0a) then
      begin
        if (M >= SizeOf(P^)) then
        begin
          if (P^ = $0a) then
          begin
            Inc(P);
//            Dec(M, SizeOf(P^));
          end;
        end else
        if (not FEOF) then
        begin
          Flush;
          {$ifdef CPUX86}
          Result := TCachedByteTextReader(Store.Self).Readln(Store.S^);
          {$else}
          Result := Readln(S);
          {$endif}
          Exit;
        end;
      end;

      Current := Pointer(P);
//      Margin := M;
    end;
    goto done;
  until (False);

done_:
  {$ifdef CPUX86}
  _Self := Store.Self;
  _S := Store.S;
  with TCachedByteTextReader(_Self) do
  {$endif}
  begin
    {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := FNativeFlags + Byte(Flags and ASCII_MASK = 0);
    Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
    {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount};
//    M := Margin - Flags{BytesCount};

    if (not FEOF) then
    begin
      Flush;
      {$ifdef CPUX86}
      Result := TCachedByteTextReader(Store.Self).Readln(Store.S^);
      {$else}
      Result := Readln(S);
      {$endif}
      Exit;
    end;

    Current := Pointer(P);
//    Margin := M;
  end;

done:
  Result := True;
end;


{ TCachedUTF16TextReader }

constructor TCachedUTF16TextReader.Create(const Source: TCachedReader;
  const IsOwner: Boolean; const DefaultBOM: TBOM);
var
  BOM: TBOM;
begin
  BOM := DetectBOM(Source, DefaultBOM);
  FContext.Init(bomUtf16, BOM);

  InternalCreate(Source, IsOwner);
end;

function TCachedUTF16TextReader.Readln(var S: CachedUTF16String): Boolean;
label
  small, check_x, done_, done;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  CR_XOR_MASK = $000d000d; // \r
  LF_XOR_MASK = $000a000a; // \n
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
  ASCII_MASK = Integer($ff80ff80);
var
  P: PWord;
  X, T, V, U, Flags, M: NativeInt;
  L: NativeUInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PCachedUTF16String;
    Top: PByte;
  end;
  _Self: Pointer;
  _S: PCachedUTF16String;
  {$endif}
begin
  {$ifdef CPUX86}
  Store.Self := Pointer(Self);
  Store.S := @S;
  {$endif}

  Flags := Self.Margin;
  if (Flags < SizeOf(P^)) then
  begin
//    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
    begin
      Result := False;
      Exit;
    end;
    Flags := Self.Margin;
  end;

  P := Pointer(Self.Current);
  L := Flags{Margin} and -SizeOf(P^);
  {$ifdef CPUX86}
  Store.Top := @PByteArray(P)[L];
  {$endif}
  S.FChars := Pointer(P);
  Flags := 0;

  if (L < SizeOf(Cardinal)) then
  begin
  small:
    X := P^;
    Inc(P);
    {$ifNdef CPUX86}
    L := 0;
    {$endif}
    goto check_x;
  end else
  repeat
    X := PCardinal(P)^;
    {$ifNdef CPUX86}
    Dec(L, SizeOf(Cardinal));
    {$endif}
    Inc(P, CHARS_IN_CARDINAL);

  check_x:
    T := (X xor CR_XOR_MASK);
    U := (X xor LF_XOR_MASK);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then
    begin
      {$ifdef CPUX86}
      L := NativeUInt(Store.Top);
      Dec(L, NativeUInt(P));
      {$endif}
      Flags := Flags or X;
      if (L >= SizeOf(Cardinal)) then continue;
      if (L <> 0) then goto small;
      goto done_;
    end;

    Dec(P, CHARS_IN_CARDINAL);
    if (T and (OVERFLOW_MASK and $ffff) = 0) then
    begin
      X := X shr 16;
      Inc(P);
    end;
    {$ifdef CPUX86}_Self := Store.Self;{$endif}
    X := Word(X);
    {$ifdef CPUX86}_S := Store.S;{$endif}
    Flags := Flags or X;

    {$ifdef CPUX86}with TCachedUTF16TextReader(_Self) do{$endif}
    begin
      {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := Byte(Flags and ASCII_MASK = 0);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
      {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount} shr 1;
      M := Margin - Flags{BytesCount};

      Inc(P);
      Dec(M, SizeOf(P^));
      if (X <> $0a) then
      begin
        if (M >= SizeOf(P^)) then
        begin
          if (P^ = $0a) then
          begin
            Inc(P);
//            Dec(M, SizeOf(P^));
          end;
        end else
        if (not FEOF) then
        begin
          Flush;
          {$ifdef CPUX86}
          Result := TCachedUTF16TextReader(Store.Self).Readln(Store.S^);
          {$else}
          Result := Readln(S);
          {$endif}
          Exit;
        end;
      end;

      Current := Pointer(P);
//      Margin := M;
    end;
    goto done;
  until (False);

done_:
  {$ifdef CPUX86}
  _Self := Store.Self;
  _S := Store.S;
  with TCachedUTF16TextReader(_Self) do
  {$endif}
  begin
    {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := Byte(Flags and ASCII_MASK = 0);
    Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
    {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount} shr 1;
//    M := Margin - Flags{BytesCount};

    if (not FEOF) then
    begin
      Flush;
      {$ifdef CPUX86}
      Result := TCachedUTF16TextReader(Store.Self).Readln(Store.S^);
      {$else}
      Result := Readln(S);
      {$endif}
      Exit;
    end;

    Current := Pointer(P);
//    Margin := M;
  end;

done:
  Result := True;
end;


{ TCachedUTF32TextReader }

constructor TCachedUTF32TextReader.Create(const Source: TCachedReader;
  const IsOwner: Boolean; const DefaultBOM: TBOM);
var
  BOM: TBOM;
begin
  BOM := DetectBOM(Source, DefaultBOM);
  FContext.Init(bomUtf32, BOM);
  
  InternalCreate(Source, IsOwner);
end;

function TCachedUTF32TextReader.Readln(var S: CachedUTF32String): Boolean;
label
  loop, done_, done;
var
  P, Top: PCardinal;
  X, Flags{, M}: NativeInt;
begin
  Flags := Self.Margin;
  if (Flags < SizeOf(P^)) then
  begin
//    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
    begin
      Result := False;
      Exit;
    end;
    Flags := Self.Margin;
  end;

  P := Pointer(Self.Current);
  Flags := Flags shr 2;
  Top := @PCardinalArray(P)[Flags];
  S.FChars := Pointer(P);
  Flags := 0;

loop:
  X := P^;
  Inc(P);
  Flags := Flags or X;

  if (X > $0d) then
  begin
    if (P <> Top) then goto loop;
    goto done_;
  end else
  if (X = $0d) or (X = $0a) then
  begin
    Dec(P);
    S.F.NativeFlags := Byte(Flags <= $7f);
    Flags{BytesCount} := NativeUInt(P) - NativeUInt(S.FChars);
    S.Length := Flags{BytesCount} shr 2;
//    M := Self.Margin - Flags{BytesCount};

    {$ifdef CPUX86}
    X := P^;
    {$endif}
    Inc(P);
//    Dec(M, SizeOf(P^));

    if (X = $0d) then
    begin
      if (P <> Top) then
      begin
        if (P^ = $0a) then
        begin
          Inc(P);
//          Dec(M, SizeOf(P^));
        end;
      end else
      if (not FEOF) then
      begin
        Flush;
        Result := Readln(S);
        Exit;
      end;
    end;

    Current := Pointer(P);
//    Margin := M;
    goto done;
  end;
  if (P <> Top) then goto loop;

done_:
  S.F.NativeFlags := Byte(Flags <= $7f);
  Flags{BytesCount} := NativeUInt(P) - NativeUInt(S.FChars);
  S.Length := Flags{BytesCount} shr 2;
//  M := Self.Margin - Flags{BytesCount};

  if (not FEOF) then
  begin
    Flush;
    Result := Readln(S);
    Exit;
  end;

  Current := Pointer(P);
//  Margin := M;
done:
  Result := True;
end;


(*
{ TCachedTextWriter }

constructor TCachedTextWriter.Create(const Context: TUniConvContext;
  const Destination: TCachedWriter; const IsOwner: Boolean);
begin
  FContext := Context;
  inherited Create(InternalCallback, Destination, IsOwner);
end;

class function TCachedTextWriter.StaticCreate(var Static: TCachedStatic;
  const Context: TUniConvContext; const Destination: TCachedWriter;
  const IsOwner: Boolean): TCachedTextWriter;
begin
  Result := TCachedTextWriter(StaticInstance(Static));
  Result.Create(Context, Destination, IsOwner);
end;

function TCachedTextWriter.InternalCallback(Sender: TCachedReWriter;
  Buffer: Pointer; BufferSize: NativeUInt; Destination: TCachedWriter): NativeUInt;
begin
  Result := 0;
  // todo
end;



{ TCachedByteTextReader }

constructor TCachedByteTextReader.Create(const Context: TUniConvContext;
  const Source: TCachedReader; const IsOwner: Boolean);
begin
  // todo
end;

constructor TCachedByteTextReader.Create(const Source: TCachedReader;
  const IsOwner: Boolean);
begin
  // todo
end;


class function TCachedByteTextReader.StaticCreate(var Static: TCachedStatic;
  const Context: TUniConvContext; const Source: TCachedReader;
  const IsOwner: Boolean): TCachedByteTextReader;
begin
  Result := TCachedByteTextReader(StaticInstance(Static));
  Result.Create(Context, Source, IsOwner);
end;

class function TCachedByteTextReader.StaticCreate(var Static: TCachedStatic;
  const Source: TCachedReader; const IsOwner: Boolean): TCachedByteTextReader;
begin
  Result := TCachedByteTextReader(StaticInstance(Static));
  Result.Create(Source, IsOwner);
end;


//  ECachedString = class({$ifdef KOL}Exception{$else}EConvertError{$endif})
//  public  *)


initialization
  InternalLookupsInitialize;

end.