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


   {$undef INLINESUPPORT}
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

{ TUniConvReReader class }

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


{ TUniConvReWriter class }

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
  PByteString = ^ByteString;
  PUTF16String = ^UTF16String;
  PUTF32String = ^UTF32String;

  ECachedString = class({$ifdef KOL}Exception{$else}EConvertError{$endif})
  public
    constructor Create(const ResStringRec: PResStringRec; const Value: PByteString); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PUTF16String); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PUTF32String); overload;
  end;


{ ByteString record }

  ByteString = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PAnsiChar;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Byte; SBCSIndex: ShortInt);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetSBCS: PUniConvSBCS; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetSBCS(Value: PUniConvSBCS); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUTF8(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetEncoding: Word; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEncoding(CodePage: Word);
    function _TrimLeft(S: PByte; L: NativeUInt): Boolean;
    function _TrimRight(S: PByte; H: NativeUInt): Boolean;
    function _Trim(S: PByte; H: NativeUInt): Boolean;
    function _HashIgnoreCaseAscii: Cardinal;
    function _HashIgnoreCaseUTF8: Cardinal;
    function _HashIgnoreCase(NF: NativeUInt): Cardinal;
    function _PosIgnoreCaseUTF8(const S: ByteString; const From: NativeUInt): NativeInt;
    function _PosIgnoreCase(const S: ByteString; const From: NativeUInt): NativeInt;
    function _GetBool(S: PByte; L: NativeUInt): Boolean;
    function _GetHex(S: PByte; L: NativeInt): Integer;
    function _GetInt(S: PByte; L: NativeInt): Integer;
    function _GetInt_19(S: PByte; L: NativeUInt): NativeInt;
    function _GetHex64(S: PByte; L: NativeInt): Int64;
    function _GetInt64(S: PByte; L: NativeInt): Int64;
    function _GetFloat(S: PByte; L: NativeUInt): Extended;
    function _GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
  {todo}public
    function _CompareByteString(const S: PByteString; const CaseLookup: PUniConvWW): NativeInt;
    function _CompareUTF16String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
  public
    property Chars: PAnsiChar read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;
    property SBCSIndex: ShortInt read F.SBCSIndex write F.SBCSIndex;
    property SBCS: PUniConvSBCS read GetSBCS write SetSBCS;
    property UTF8: Boolean read GetUTF8 write SetUTF8;
    property Encoding: Word read GetEncoding write SetEncoding;

    procedure Assign(const AChars: PAnsiChar; const ALength: NativeUInt; const CodePage: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word = 0{$endif}); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: UTF8String); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: ShortString; const CodePage: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: TBytes; const CodePage: Word = 0); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function DetermineAscii: Boolean;

    function TrimLeft: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TrimRight: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): ByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): ByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifNdef CPUINTEL}inline;{$endif}

    function CharPos(const C: AnsiChar; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: AnsiChar; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: ByteString; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: AnsiString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: ByteString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: AnsiString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: ByteString): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: ByteString): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: ByteString): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: ByteString): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    // compares
    // todo
  end;


{ UTF16String record }

  UTF16String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PUnicodeChar;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Word);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function _TrimLeft(S: PWord; L: NativeUInt): Boolean;
    function _TrimRight(S: PWord; H: NativeUInt): Boolean;
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
    property Chars: PUnicodeChar read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;

    procedure Assign(const AChars: PUnicodeChar; const ALength: NativeUInt); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: WideString); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    procedure Assign(const S: UnicodeString); overload; inline;
    {$endif}
    function DetermineAscii: Boolean;

    function TrimLeft: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TrimRight: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): UTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): UTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: UTF16String; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UTF16String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UnicodeString; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: UTF16String): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: UTF16String): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: UTF16String): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: UTF16String): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    // compares
    // todo
  end;


{ UTF32String record }

  UTF32String = {$ifdef OPERATORSUPPORT}record{$else}object{$endif}
  private
    FChars: PUCS4Char;
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (Ascii, References: Boolean; Reserved: Word);
      2: (NativeFlags: NativeUInt);
    end;

    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function _TrimLeft(S: PCardinal; L: NativeUInt): Boolean;
    function _TrimRight(S: PCardinal; H: NativeUInt): Boolean;
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
  {todo}public
    function _CompareByteString(const S: PByteString; const CaseLookup: PUniConvWW): NativeInt;
    function _CompareUTF16String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
    function _CompareUTF32String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
  public
    property Chars: PUCS4Char read FChars write FChars;
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.Ascii write F.Ascii;
    property References: Boolean read F.References write F.References;
    property Flags: Cardinal read F.Flags write F.Flags;

    procedure Assign(const AChars: PUCS4Char; const ALength: NativeUInt); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure Assign(const S: UCS4String; const NullTerminated: Boolean = True); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function DetermineAscii: Boolean;

    function TrimLeft: Boolean;
    function TrimRight: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): UTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): UTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt;
    function Pos(const S: UTF32String; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Pos(const S: UCS4String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: UTF32String; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function PosIgnoreCase(const S: UCS4String; const From: NativeUInt = 0): NativeInt; overload;
  public
    function ToBoolean: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToBooleanDef(const Default: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToBoolean(out Value: Boolean): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHexDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInteger: Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToIntegerDef(const Default: Integer): Integer; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInteger(out Value: Integer): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinal: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToCardinalDef(const Default: Cardinal): Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToCardinal(out Value: Cardinal): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToHex64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToHex64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToInt64Def(const Default: Int64): Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToInt64(out Value: Int64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64: UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToUInt64Def(const Default: UInt64): UInt64; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToUInt64(out Value: UInt64): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloat: Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToFloatDef(const Default: Extended): Extended; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Single): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: Double): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToFloat(out Value: TExtended80Rec): Boolean; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDate: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDate(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTime: TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function ToDateTimeDef(const Default: TDateTime): TDateTime; {$ifdef INLINESUPPORT}inline;{$endif}
    function TryToDateTime(out Value: TDateTime): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  public
    procedure ToAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToLowerAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToUpperAnsiString(var S: AnsiString; const CodePage: Word = 0); overload;
    procedure ToAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToLowerAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUpperAnsiShortString(var S: ShortString; const CodePage: Word = 0);
    procedure ToUTF8String(var S: UTF8String); overload;
    procedure ToLowerUTF8String(var S: UTF8String); overload;
    procedure ToUpperUTF8String(var S: UTF8String); overload;
    procedure ToUTF8ShortString(var S: ShortString);
    procedure ToLowerUTF8ShortString(var S: ShortString);
    procedure ToUpperUTF8ShortString(var S: ShortString);
    procedure ToWideString(var S: WideString); overload;
    procedure ToLowerWideString(var S: WideString); overload;
    procedure ToUpperWideString(var S: WideString); overload;
    procedure ToUnicodeString(var S: UnicodeString); overload;
    procedure ToLowerUnicodeString(var S: UnicodeString); overload;
    procedure ToUpperUnicodeString(var S: UnicodeString); overload;
    procedure ToString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToLowerString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure ToUpperString(var S: string); overload; {$ifdef INLINESUPPORT}inline;{$endif}

    function ToAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperAnsiString: AnsiString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUTF8String: UTF8String; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperWideString: WideString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperUnicodeString: UnicodeString; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToLowerString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}
    function ToUpperString: string; overload; {$ifNdef CPUINTEL}inline;{$endif}

    {$ifdef OPERATORSUPPORT}
    class operator Implicit(const a: UTF32String): AnsiString; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: UTF32String): UTF8String; {$ifNdef CPUINTEL}inline;{$endif}
    class operator Implicit(const a: UTF32String): WideString; {$ifNdef CPUINTEL}inline;{$endif}
    {$ifdef UNICODE}
    class operator Implicit(const a: UTF32String): UnicodeString; {$ifNdef CPUINTEL}inline;{$endif}
    {$endif}
    {$endif}
  public
    // compares
    // todo
  end;


{ TCachedTextReader class }

  TCachedTextReader = class
  protected
    FInternalContext: TUniConvContext;
    FFileName: string;
    FReader: TCachedReader;
    FConverter: TUniConvReReader;
    FSource: TCachedReader;
    FOwner: Boolean;
    FFinishing: Boolean;
    FEOF: Boolean;
    FOverflow: PByte;
    function GetMargin: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPosition: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEOF(const Value: Boolean);
    procedure OverflowReadData(var Buffer; const Count: NativeUInt);
  {$ifNdef AUTOREFCOUNT}
  public
  {$endif}
    destructor Destroy; override;
  public
    Current: PByte;
    function Flush: NativeUInt;
    property Overflow: PByte read FOverflow;
    property Margin: NativeInt read GetMargin;
    property Finishing: Boolean read FFinishing;
    property EOF: Boolean read FEOF write SetEOF;
  public
    constructor Create(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False);
    procedure ReadData(var Buffer; const Count: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}

    property Converter: TUniConvReReader read FConverter;
    property Source: TCachedReader read FSource;
    property Owner: Boolean read FOwner write FOwner;
    property FileName: string read FFileName;
  end;


{ TByteTextReader class }

  TByteTextReader = class(TCachedTextReader)
  protected
    FSBCS: PUniConvSBCS;
    FEncoding: Word;
    FUCS2: PUniConvWB;
    FNativeFlags: NativeUInt;

    procedure SetSBCS(const Value: PUniConvSBCS);
    function FlushReadln(var S: ByteString): Boolean;
    function FlushReadChar: UCS4Char;
  public
    constructor Create(const Encoding: Word; const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const Encoding: Word; const FileName: string; const DefaultByteEncoding: Word = 0);
    constructor CreateDefault(const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateDefaultFromFile(const FileName: string; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False);

    function Readln(var S: ByteString): Boolean;
    function ReadChar: UCS4Char;

    property SBCS{nil for UTF8}: PUniConvSBCS read FSBCS;
    property Encoding: Word read FEncoding;
  end;


{ TUTF16TextReader class }

  TUTF16TextReader = class(TCachedTextReader)
  protected
    function FlushReadln(var S: UTF16String): Boolean;
    function FlushReadChar: UCS4Char;
  public
    constructor Create(const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const FileName: string; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False);

    function Readln(var S: UTF16String): Boolean;
    function ReadChar: UCS4Char;
  end;


{ TUTF32TextReader class }

  TUTF32TextReader = class(TCachedTextReader)
  protected
    function FlushReadln(var S: UTF32String): Boolean;
    function FlushReadChar: UCS4Char;
  public
    constructor Create(const Source: TCachedReader; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const FileName: string; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Source: TCachedReader; const Owner: Boolean = False);

    function Readln(var S: UTF32String): Boolean;
    function ReadChar: UCS4Char;
  end;


{ TCachedTextWriter class }

  TCachedTextWriter = class
  protected
    FInternalContext: TUniConvContext;
    FFileName: string;
    FWriter: TCachedWriter;
    FConverter: TUniConvReWriter;
    FTarget: TCachedWriter;
    FOwner: Boolean;
    FEOF: Boolean;
    FOverflow: PByte;
    function GetMargin: NativeInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPosition: Int64; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEOF(const Value: Boolean);
    procedure OverflowWriteData(var Buffer; const Count: NativeUInt);
  {$ifNdef AUTOREFCOUNT}
  public
  {$endif}
    destructor Destroy; override;
  public
    Current: PByte;
    function Flush: NativeUInt;
    property Overflow: PByte read FOverflow;
    property Margin: NativeInt read GetMargin;
    property EOF: Boolean read FEOF write SetEOF;
  public
    constructor Create(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False);
    procedure WriteData(var Buffer; const Count: NativeUInt); {$ifdef INLINESUPPORT}inline;{$endif}

    property Converter: TUniConvReWriter read FConverter;
    property Target: TCachedWriter read FTarget;
    property Owner: Boolean read FOwner write FOwner;
    property FileName: string read FFileName;
  end;


{ TByteTextWriter class }

  TByteTextWriter = class(TCachedTextWriter)
  protected
    FSBCS: PUniConvSBCS;
    FEncoding: Word;
  public
    constructor Create(const Encoding: Word; const Target: TCachedWriter; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const Encoding: Word; const FileName: string; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False);

    property SBCS{nil for UTF8}: PUniConvSBCS read FSBCS;
    property Encoding: Word read FEncoding;
  end;


{ TUTF16TextWriter class }

  TUTF16TextWriter = class(TCachedTextWriter)
  public
    constructor Create(const Target: TCachedWriter; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const FileName: string; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False);

  end;


{ TUTF32TextWriter class }

  TUTF32TextWriter = class(TCachedTextWriter)
  public
    constructor Create(const Target: TCachedWriter; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0; const Owner: Boolean = False);
    constructor CreateFromFile(const FileName: string; const BOM: TBOM = bomNone; const DefaultByteEncoding: Word = 0);
    constructor CreateDirect(const Context: PUniConvContext; const Target: TCachedWriter; const Owner: Boolean = False);

  end;


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
  {$ifdef NEXTGEN}
    PByteArray = PByte;
  {$else}
    PByteArray = PAnsiChar;
  {$endif}

  T4Bytes = array[0..3] of Byte;
  P4Bytes = ^T4Bytes;

  T8Bytes = array[0..7] of Byte;
  P8Bytes = ^T8Bytes;

  PWordArray = ^TWordArray;
  TWordArray = array[0..High(Integer) div SizeOf(Word) - 1] of Word;

  PCardinalArray = ^TCardinalArray;
  TCardinalArray = array[0..High(Integer) div SizeOf(Cardinal) - 1] of Cardinal;

  TNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
  PNativeIntArray = ^TNativeIntArray;

  PExtendedBytes = ^TExtendedBytes;
  TExtendedBytes = array[0..SizeOf(Extended)-1] of Byte;

  PUniConvSBCSEx = ^TUniConvSBCSEx;
  TUniConvSBCSEx = object(TUniConvSBCS) end;

  PUniConvContextEx = ^TUniConvContextEx;
  TUniConvContextEx = object(TUniConvContext) end;

const
  DBLROUND_CONST: Double = 6755399441055744.0;

var
  UNICONV_SUPPORTED_SBCS_HASH: array[0..High(UniConv.UNICONV_SUPPORTED_SBCS_HASH)] of Integer;
  UNICONV_UTF8CHAR_SIZE: TUniConvBB;

procedure InternalLookupsInitialize;
begin
  CODEPAGE_DEFAULT := UniConv.CODEPAGE_DEFAULT;
  DEFAULT_UNICONV_SBCS := UniConv.DEFAULT_UNICONV_SBCS;
  DEFAULT_UNICONV_SBCS_INDEX := UniConv.DEFAULT_UNICONV_SBCS_INDEX;

  Move(UniConv.UNICONV_SUPPORTED_SBCS_HASH, UNICONV_SUPPORTED_SBCS_HASH, SizeOf(UNICONV_SUPPORTED_SBCS_HASH));
  Move(UniConv.UNICONV_UTF8CHAR_SIZE, UNICONV_UTF8CHAR_SIZE, SizeOf(UNICONV_UTF8CHAR_SIZE));
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
var
  D, M: NativeInt;
begin
  PDouble(@DivMod)^ := (X64 * UN_DIGITS_8) + DBLROUND_CONST;

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

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PByteString);
var
  S: string;
  Buffer: ByteString;
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

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PUTF16String);
var
  S: string;
  Buffer: UTF16String;
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

constructor ECachedString.Create(const ResStringRec: PResStringRec; const Value: PUTF32String);
var
  S: string;
  Buffer: UTF32String;
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


{ ByteString }

function ByteString.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure ByteString.SetEmpty(Value: Boolean);
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

function ByteString.GetSBCS: PUniConvSBCS;
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

procedure ByteString.SetSBCS(Value: PUniConvSBCS);
begin
  if (Value = nil) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := Value.Index;
  end;
end;

function ByteString.GetUTF8: Boolean;
begin
  Result := Boolean(Flags shr 31);
end;

procedure ByteString.SetUTF8(Value: Boolean);
begin
  if (Value) then
  begin
    SBCSIndex := -1;
  end else
  begin
    SBCSIndex := DEFAULT_UNICONV_SBCS_INDEX;
  end;
end;

function ByteString.GetEncoding: Word;
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

procedure ByteString.SetEncoding(CodePage: Word);
var
  Index: NativeUInt;
  Value: Integer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    SBCSIndex := -1;
  end else
  begin
    Index := NativeUInt(CodePage);
    Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
    repeat
      if (Word(Value) = CodePage) or (Value < 0) then Break;
      Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[NativeUInt(Value) shr 24]);
    until (False);

    SBCSIndex := Byte(Value shr 16);
  end;
end;

procedure ByteString.Assign(const AChars: PAnsiChar;
  const ALength: NativeUInt; const CodePage: Word);
{$ifdef CPUX86}
var
  CP: Word;
{$endif}
begin
  Self.FChars := AChars;
  Self.FLength := ALength;

  {$ifdef CPUX86}
  CP := CodePage;
  {$endif}
  if ({$ifdef CPUX86}CP{$else}CodePage{$endif} = 0) or
    ({$ifdef CPUX86}CP{$else}CodePage{$endif} = CODEPAGE_DEFAULT) then
  begin
    Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
  end else
  begin
    Self.Flags := $ff000000;
    if ({$ifdef CPUX86}CP{$else}CodePage{$endif} <> CODEPAGE_UTF8) then
      SetEncoding({$ifdef CPUX86}CP{$else}CodePage{$endif});
  end;
end;

procedure ByteString.Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CodePage: Word{$endif});
var
  P: {$ifdef NEXTGEN}PNativeInt{$else}PInteger{$endif};
  {$ifdef INTERNALCODEPAGE}
  CodePage: Word;
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
    CodePage := PWord(P)^;
    {$endif}
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

procedure ByteString.Assign(const S: UTF8String);
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

procedure ByteString.Assign(const S: ShortString; const CodePage: Word);
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
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

procedure ByteString.Assign(const S: TBytes; const CodePage: Word);
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
    if (CodePage = 0) or (CodePage = CODEPAGE_DEFAULT) then
    begin
      Self.Flags := DEFAULT_UNICONV_SBCS_INDEX shl 24;
    end else
    begin
      Self.Flags := $ff000000;
      if (CodePage <> CODEPAGE_UTF8) then SetEncoding(CodePage);
    end;
  end;
end;

function ByteString.DetermineAscii: Boolean;
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

function ByteString.TrimLeft: Boolean;
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
    Result := _TrimLeft(S, L);
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
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function ByteString._TrimLeft(S: PByte; L: NativeUInt): Boolean;
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

function ByteString.TrimRight: Boolean;
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
      Result := _TrimRight(S, L);
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
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function ByteString._TrimRight(S: PByte; H: NativeUInt): Boolean;
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

function ByteString.Trim: Boolean;
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
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
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
  // TrimLeft or True
  inc ecx
  cmp byte ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp byte ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function ByteString._Trim(S: PByte; H: NativeUInt): Boolean;
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

  // TrimLeft
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // TrimRight
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

function ByteString.SubString(const From, Count: NativeUInt): ByteString;
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

function ByteString.SubString(const Count: NativeUInt): ByteString;
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

function ByteString.Offset(const Count: NativeUInt): Boolean;
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

function ByteString.Hash: Cardinal;
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

function ByteString.HashIgnoreCase: Cardinal;
{$ifNdef CPUINTEL}
var
  NF: NativeUInt;
begin
  NF := F.NativeFlags;

  if (NF and 1 <> 0) then Result := _HashIgnoreCaseAscii
  else
  if (NF >= NativeUInt($ff) shl 24) then Result := _HashIgnoreCaseUTF8
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
  cmp edx, $ff000000
  jae _HashIgnoreCaseUTF8
  jmp _HashIgnoreCase
end;
{$endif}

function ByteString._HashIgnoreCaseAscii: Cardinal;
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

function ByteString._HashIgnoreCaseUTF8: Cardinal;
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
      case UNICONV_UTF8CHAR_SIZE[Byte(X)] of
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


function ByteString._HashIgnoreCase(NF: NativeUInt): Cardinal;
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

  // Lower := inline UNICONV_SUPPORTED_SBCS[SBCSIndex].GetLowerCaseUCS2;
  SBCSLookup := Pointer(NF * SizeOf(TUniConvSBCS) + NativeUInt(@UNICONV_SUPPORTED_SBCS));
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

function ByteString.CharPos(const C: AnsiChar; const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  X, V, CharMask: NativeInt;
  P, TopCardinal, Top: PByte;
  StoredChars: PByte;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PByteArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Byte(C) <= $7f)) then goto failure;
  CharMask := Ord(C) * $01010101;

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    X := X xor CharMask;
    V := X + SUB_MASK;
    X := not X;
    X := X and V;

    if (X and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(X and $80 = 0) + Byte(X and $8080 = 0) + Byte(X and $808080 = 0)));
    goto found;
  until (False);

  CharMask := CharMask and $ff;
  Top := Pointer(@PByteArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = CharMask) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
end;

function DetectSBCSLowerUpperChars(const C: NativeInt; const SBCS: PUniConvSBCS): NativeInt;
begin
  Result := PUniConvBB(SBCS.LowerCase)[C];
  Result := (Result shl 8) + PUniConvBB(SBCS.UpperCase)[C];
end;

function ByteString.CharPosIgnoreCase(const C: AnsiChar; const From: NativeUInt): NativeInt;
label
  sbcs_lookup_chars, failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, TopCardinal, Top: PByte;
  StoredChars: PByte;
  Lookup: PUniConvBB;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PByteArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);

  U := Ord(C);
  UpperCharMask := Self.F.Flags;
  if (U <= $7f) then
  begin
    UpperCharMask := UNICONV_CHARCASE.VALUES[$10000 + U];
    LowerCharMask := UNICONV_CHARCASE.VALUES[U];
  end else
  begin
    if (UpperCharMask and 1 <> 0{Ascii}) then goto failure;
    if (Integer(UpperCharMask) < 0) then
    begin
      // UTF-8 (case sensitive)
      LowerCharMask := U;
      UpperCharMask := U;
    end else
    begin
      // SBCS
      UpperCharMask := UpperCharMask shr 24;
      UpperCharMask := UpperCharMask * SizeOf(TUniConvSBCS);
      Inc(UpperCharMask, NativeInt(@UNICONV_SUPPORTED_SBCS));
      Lookup := Pointer(PUniConvSBCSEx(UpperCharMask).FLowerCase);
      if (Lookup <> nil) then
      begin
        LowerCharMask := Lookup[U];
        Lookup := Pointer(PUniConvSBCSEx(UpperCharMask).FUpperCase);
        if (Lookup = nil) then goto sbcs_lookup_chars;
        UpperCharMask := Lookup[U];
      end else
      begin
      sbcs_lookup_chars:
        LowerCharMask := DetectSBCSLowerUpperChars(U, PUniConvSBCS(UpperCharMask));
        UpperCharMask := LowerCharMask shr 8;
        LowerCharMask := Byte(LowerCharMask);
      end;
    end;
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
    goto found;
  until (False);

  LowerCharMask := Byte(LowerCharMask);
  UpperCharMask := Byte(UpperCharMask);
  Top := Pointer(@PByteArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto found;
    if (X = UpperCharMask) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
end;

function ByteString.Pos(const S: ByteString; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, V, CharMask: NativeInt;
  P, Top, TopCardinal: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    CharMask: NativeInt;
  end;
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PAnsiChar(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  TopCardinal := Pointer(@PCharArray(P)[Self.FLength -L - (CHARS_IN_CARDINAL - 1)]);  
  Inc(P, From);

  CharMask := PChar(Store.StrChars)^;
  if (Self.Ascii > (CharMask <= $7f)) then goto failure;
  CharMask := CharMask * $01010101;

  Store.CharMask := CharMask;
  next_iteration:
    CharMask := Store.CharMask;
  repeat   
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    X := X xor CharMask;
    V := X + SUB_MASK;
    X := not X;
    X := X and V;

    if (X and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(X and $80 = 0) + Byte(X and $8080 = 0) + Byte(X and $808080 = 0)));
  char_found:
    Inc(P);
    L := Store.StrLength - 1;    
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}    
    if (L >= CHARS_IN_CARDINAL{4}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_CARDINAL);
      Inc(P1, CHARS_IN_CARDINAL);
      Inc(P2, CHARS_IN_CARDINAL);      
    end;
    {$endif}
    if (L <> 0) then
    repeat    
      if (P1^ <> P2^) then goto next_iteration;     
      Dec(L);
      Inc(P1);
      Inc(P2);            
    until (L = 0);
    
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  CharMask := CharMask and $ff;
  Top := Pointer(@PByteArray(TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = CharMask) then goto char_found;
    Inc(P);
  end; 

failure:
  Result := -1;
end;

function ByteString.Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PByteString(@Buffer)^, From);
end;

function ByteString.Pos(const S: AnsiString; const From: NativeUInt): NativeInt;
var
  P: {$ifdef NEXTGEN}PNativeUInt{$else}PCardinal{$endif};
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(P);
    Buffer.Length := P^;
    Result := Self.Pos(PByteString(@Buffer)^, From);
  end;
end;

function DetectUTF8LowerUpperChars(S: PByte; L: NativeUInt): NativeInt;
label
  done;
var
  V1, V2: NativeUInt;
  X, Y: NativeUInt;
begin
  V1 := S^;
  V2 := V1;

  X := UNICONV_UTF8CHAR_SIZE[V1];
  if (X > L) then goto done;
  case X of
    2:
    begin
      X := PWord(S)^;
      if (X and $C0E0 <> $80C0) then goto done;
      Y := X;
      X := X and $1F;
      Y := Y shr 8;
      X := X shl 6;
      Y := Y and $3F;
      Inc(X, Y);
    end;
    3:
    begin
      Inc(S);
      X := PWord(S)^;
      X := (X shl 8) + V1;
      if (X and $C0C000 <> $808000) then goto done;
      Y := (X and $0F) shl 12;
      Y := Y + (X shr 16) and $3F;
      X := (X and $3F00) shr 2;
      Inc(X, Y);
    end;
  else
    goto done;
  end;

  V1 := UNICONV_CHARCASE.VALUES[X];
  V2 := UNICONV_CHARCASE.VALUES[$10000 + X];
  begin
    if (V1 <= $7ff) then
    begin
      V1 := (V1 shr 6) + $C0;
    end else
    begin
      V1 := (V1 shr 12) + $E0;
    end;

    if (V2 <= $7ff) then
    begin
      V2 := (V2 shr 6) + $C0;
    end else
    begin
      V2 := (V2 shr 12) + $E0;
    end;
  end;
done:
  Result := (Byte(V1) shl 8) + Byte(V2);
end;

function ByteString._PosIgnoreCaseUTF8(const S: ByteString; const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    Comp: TUniConvCompareOptions;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
    case Boolean of
      False: (D: Double);
       True: (I: Integer);
  end;
begin
  Store.Comp.Length := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PAnsiChar(Store.StrChars)^, Store.Comp.Length);
    Exit;
  end;
  Store.Comp.Length_2 := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  L := Self.FLength;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[L]);
  Store.D := (Store.Comp.Length_2 * (2/3)) + DBLROUND_CONST;
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-Store.I - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, Store.Comp.Length{From});

  LowerCharMask := PChar(Store.StrChars)^;
  if (LowerCharMask <= $7f) then
  begin
    UpperCharMask := UNICONV_CHARCASE.VALUES[$10000 + LowerCharMask];
    LowerCharMask := UNICONV_CHARCASE.VALUES[LowerCharMask];
  end else
  begin
    if (Self.Ascii) then goto failure;
    LowerCharMask := DetectUTF8LowerUpperChars(Store.StrChars, Store.Comp.Length_2);
    UpperCharMask := LowerCharMask shr 8;
    LowerCharMask := TChar(LowerCharMask);
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      Store.Comp.Length := (NativeUInt(Store.SelfCharsTop) - NativeUInt(P)) or {compare flag}NativeUInt(1 shl {$ifdef LARGEINT}63{$else}31{$endif});
      U := __uniconv_utf8_compare_utf8(Pointer(P), Store.StrChars, Store.Comp);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
    Inc(P);
  end;

failure:
  Result := -1;
end;

procedure UpdateSBCSLowerUpperLookups(var Comp: TUniConvCompareOptions; const SBCS: PUniConvSBCS);
begin
  Comp.Lookup := SBCS.LowerCase;
  Comp.Lookup_2 := SBCS.UpperCase;
end;

function ByteString._PosIgnoreCase(const S: ByteString; const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Byte;
  PChar = ^TChar;
  TCharArray = TByteArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    Comp: TUniConvCompareOptions;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
  end;
begin
  Store.Comp.Length_2 := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PAnsiChar(Store.StrChars)^, Store.Comp.Length_2);
    Exit;
  end;
  Store.Comp.Length := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, Store.Comp.Length_2{From});

  UpperCharMask := Self.F.Flags;
  LowerCharMask := UpperCharMask;
  UpperCharMask := UpperCharMask shr 24;
  UpperCharMask := UpperCharMask * SizeOf(TUniConvSBCS);
  Inc(UpperCharMask, NativeInt(@UNICONV_SUPPORTED_SBCS));
  Store.Comp.Lookup := PUniConvSBCSEx(UpperCharMask).FLowerCase;
  Store.Comp.Lookup_2 := PUniConvSBCSEx(UpperCharMask).FUpperCase;
  if (Store.Comp.Lookup = nil) or (Store.Comp.Lookup_2 = nil) then
    UpdateSBCSLowerUpperLookups(Store.Comp, PUniConvSBCS(UpperCharMask));

  U := PChar(Store.StrChars)^;
  if (U <= $7f) then
  begin
    UpperCharMask := UNICONV_CHARCASE.VALUES[$10000 + U];
    LowerCharMask := UNICONV_CHARCASE.VALUES[U];
  end else
  begin
    if (LowerCharMask and 1 <> 0{Ascii}) then goto failure;
    UpperCharMask := PUniConvBB(Store.Comp.Lookup_2)[U];
    LowerCharMask := PUniConvBB(Store.Comp.Lookup)[U];
  end;

  LowerCharMask := LowerCharMask * $01010101;
  UpperCharMask := UpperCharMask * $01010101;
  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) + Byte(T and $808080 = 0)));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      U := __uniconv_sbcs_compare_sbcs_1(Pointer(P), Store.StrChars, Store.Comp);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
    Inc(P);
  end;

failure:
  Result := -1;
end;

function ByteString.PosIgnoreCase(const S: ByteString; const From: NativeUInt): NativeInt;
begin
  if (Integer(Self.Flags) < 0) then
  begin
    Result := Self._PosIgnoreCaseUTF8(S, From);
  end else
  begin
    Result := Self._PosIgnoreCase(S, From);
  end;
end;

function ByteString.PosIgnoreCase(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  if (Integer(Self.Flags) < 0) then
  begin
    Result := Self._PosIgnoreCaseUTF8(PByteString(@Buffer)^, From);
  end else
  begin
    Result := Self._PosIgnoreCase(PByteString(@Buffer)^, From);
  end;
end;

function ByteString.PosIgnoreCase(const S: AnsiString; const From: NativeUInt = 0): NativeInt;
var
  P: {$ifdef NEXTGEN}PNativeUInt{$else}PCardinal{$endif};
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(P);
    Buffer.Length := P^;
    if (Integer(Self.Flags) < 0) then
    begin
      Result := Self._PosIgnoreCaseUTF8(PByteString(@Buffer)^, From);
    end else
    begin
      Result := Self._PosIgnoreCase(PByteString(@Buffer)^, From);
    end;
  end;
end;

function ByteString.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
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

function ByteString.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PByteString(@Default)._GetBool(Pointer(Chars), Length);
end;

function ByteString.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function ByteString._GetBool(S: PByte; L: NativeUInt): Boolean;
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
  Buffer: ByteString;
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

function ByteString.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
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

function ByteString.ToHexDef(const Default: Integer): Integer;
begin
  Result := PByteString(@Default)._GetHex(Pointer(Chars), Length);
end;

function ByteString.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function ByteString._GetHex(S: PByte; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: ByteString;
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

function ByteString.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
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

function ByteString.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PByteString(@Default)._GetInt(Pointer(Chars), Length);
end;

function ByteString.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function ByteString.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
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

function ByteString.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PByteString(@Default)._GetInt(Pointer(Chars), -Length);
end;

function ByteString.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt(Pointer(Chars), -Length);
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

function ByteString._GetInt(S: PByte; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: ByteString;
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
        Result := PByteString(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PByteString(-NativeInt(@HexRet))._GetHex(S, L);
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

function ByteString.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
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

function ByteString.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function ByteString.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function ByteString._GetHex64(S: PByte; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: ByteString;
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

function ByteString.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
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

function ByteString.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function ByteString.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function ByteString.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
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

function ByteString.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(@Default)._GetInt64(Pointer(Chars), -Length);
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

function ByteString.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PByteString(0)._GetInt64(Pointer(Chars), -Length);
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

function ByteString._GetInt64(S: PByte; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: ByteString;
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
        Result := PByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PByteString(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PByteString(nil)._GetInt_19(S, L);
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
  R2 := PByteString(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PByteString(nil)._GetInt_19(S, 9);
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

function ByteString._GetInt_19(S: PByte; L: NativeUInt): NativeInt;
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

function ByteString.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function ByteString.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function ByteString.TryToFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function ByteString.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PByteString(@Default)._GetFloat(Pointer(Chars), Length);
end;

function ByteString.ToFloat: Extended;
begin
  Result := PByteString(0)._GetFloat(Pointer(Chars), Length);
end;

function ByteString._GetFloat(S: PByte; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: ByteString;
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
      V := PByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PByteString(@Store.V)._GetInt_19(S, L);
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
          V := PByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PByteString(@Store.V)._GetInt_19(S, L);
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
      V := PByteString(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PByteString(@Store.V)._GetInt_19(S, L);
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
          V := PByteString(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PByteString(@Store.V)._GetInt_19(S, L);
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
    V := PByteString(nil)._GetInt_19(S, L);
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

function ByteString.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function ByteString.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function ByteString.TryToDate(out Value: TDateTime): Boolean;
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

function ByteString.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function ByteString.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function ByteString.TryToTime(out Value: TDateTime): Boolean;
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

function ByteString.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function ByteString.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function ByteString.TryToDateTime(out Value: TDateTime): Boolean;
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

function ByteString._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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

procedure ByteString.ToAnsiString(var S: AnsiString; const CodePage: Word);
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
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToAnsiShortString(var S: ShortString; const CodePage: Word);
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
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToLowerAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToUpperAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure ByteString.ToUTF8String(var S: UTF8String);
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

procedure ByteString.ToLowerUTF8String(var S: UTF8String);
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

procedure ByteString.ToUpperUTF8String(var S: UTF8String);
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

procedure ByteString.ToUTF8ShortString(var S: ShortString);
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

procedure ByteString.ToLowerUTF8ShortString(var S: ShortString);
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

procedure ByteString.ToUpperUTF8ShortString(var S: ShortString);
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

procedure ByteString.ToWideString(var S: WideString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs(Dest, Src, L, Converter);
    end
  end;
end;

procedure ByteString.ToLowerWideString(var S: WideString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8_lower(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_lower(Dest, Src, L, Converter);
    end;
  end;
end;

procedure ByteString.ToUpperWideString(var S: WideString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8_upper(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_upper(Dest, Src, L, Converter);
    end;
  end;
end;

procedure ByteString.ToUnicodeString(var S: UnicodeString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure ByteString.ToLowerUnicodeString(var S: UnicodeString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8_lower(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_lower(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToLowerWideString
end;
{$endif}

procedure ByteString.ToUpperUnicodeString(var S: UnicodeString);
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
    if (Converter = nil) then
    begin
      utf16_from_utf8_upper(Dest, Src, L);
    end else
    begin
      utf16_from_sbcs_upper(Dest, Src, L, Converter);
    end;
  end;
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToUpperWideString
end;
{$endif}

procedure ByteString.ToString(var S: string);
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

procedure ByteString.ToLowerString(var S: string);
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

procedure ByteString.ToUpperString(var S: string);
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

function ByteString.ToAnsiString: AnsiString;
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

function ByteString.ToLowerAnsiString: AnsiString;
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

function ByteString.ToUpperAnsiString: AnsiString;
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

function ByteString.ToUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function ByteString.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function ByteString.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function ByteString.ToWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function ByteString.ToLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function ByteString.ToUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

function ByteString.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function ByteString.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function ByteString.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function ByteString.ToString: string;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function ByteString.ToLowerString: string;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function ByteString.ToUpperString: string;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator ByteString.Implicit(const a: ByteString): AnsiString;
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

class operator ByteString.Implicit(const a: ByteString): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator ByteString.Implicit(const a: ByteString): WideString;
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
class operator ByteString.Implicit(const a: ByteString): UnicodeString;
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

function ByteString._CompareByteString(const S: PByteString; const CaseLookup: PUniConvWW): NativeInt;
label
  diffsbcs_compare, binary_compare, same_modify;
var
  F, F1, F2: NativeUInt;
  CharCase: NativeUInt;
  Comp: TUniConvCompareOptions;
  Store: record
    SelfChars: Pointer;
    SChars: Pointer;
    SameLength: NativeUInt;
    SameModifier: NativeUInt;
  end;
begin
  Comp.Lookup := CaseLookup;
  Store.SelfChars := Self.FChars;
  Store.SChars := S.FChars;

  // lengths
  F1 := Self.Length;
  F2 := S.Length;
  Comp.Length := F1;
  Comp.Length_2 := F2;
  if (F1 <= F2) then
  begin
    Store.SameLength := F1;
    Store.SameModifier := (-(F2 - F1)) shr {$ifdef SMALLINT}31{$else}63{$endif};
  end else
  begin
    Store.SameLength := F2;
    Store.SameModifier := NativeUInt(-1);
  end;

  // flags, SBCS
  F1 := Self.Flags;
  F2 := S.Flags;
  F := ((F1 shr 29) and 4) + ((F2 shr 30) and 2) + NativeUInt(Comp.Lookup <> nil);
  F1 := F1 shr 24;
  F2 := F2 shr 24;
  F1 := F1 * SizeOf(TUniConvSBCS);
  F2 := F2 * SizeOf(TUniConvSBCS);
  Inc(F1, NativeUInt(@UNICONV_SUPPORTED_SBCS));
  Inc(F2, NativeUInt(@UNICONV_SUPPORTED_SBCS));
  case F of
    6:
    begin
      // utf8-utf8 sensitive
      goto binary_compare;
    end;
    7:
    begin
      // utf8-utf8 insensitive
      Result := __uniconv_utf8_compare_utf8(Store.SelfChars, Store.SChars, Comp);
    end;
    4, 5:
    begin
      // utf8-sbcs sensitive/insensitive
      CharCase := NativeUInt(Comp.Lookup <> nil);
      Comp.Lookup_2 := PUniConvSBCSEx(F2).FUCS2.NumericItems[CharCase];
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PUniConvSBCSEx(F2).AllocFillUCS2(PUniConvSBCSEx(F2).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
      Result := __uniconv_utf8_compare_sbcs(Store.SelfChars, Store.SChars, Comp);
    end;
    2, 3:
    begin
      // sbcs-utf8 sensitive/insensitive
      CharCase := NativeUInt(Comp.Lookup <> nil);
      Comp.Lookup_2 := PUniConvSBCSEx(F1).FUCS2.NumericItems[CharCase];
      if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PUniConvSBCSEx(F1).AllocFillUCS2(PUniConvSBCSEx(F1).FUCS2.NumericItems[CharCase], TCharCase(CharCase));
      F1 := Comp.Length;
      F2 := Comp.Length_2;
      Comp.Length := F1;
      Comp.Length_2 := F2;
      Result := __uniconv_utf8_compare_sbcs(Store.SChars, Store.SelfChars, Comp);
      Result := -Result;
    end;
    0:
    begin
      // sbcs-sbcs sensitive
      if (F1 = F2) then goto binary_compare;
      goto diffsbcs_compare;
    end;
    1:
    begin
      // sbcs-sbcs insensitive
      if (F1 = F2) then
      begin
        Comp.Lookup := PUniConvSBCSEx(F1).FLowerCase;
        if (Comp.Lookup = nil) then Comp.Lookup := PUniConvSBCS(F1).FromSBCS(PUniConvSBCS(F1), ccLower);
        Result := __uniconv_sbcs_compare_sbcs_1(Store.SelfChars, Store.SChars, Comp);
      end else
      begin
      diffsbcs_compare:
        Comp.Lookup := PUniConvSBCSEx(F1).FUCS2.Items[ccLower];
        if (Comp.Lookup = nil) then Comp.Lookup := PUniConvSBCSEx(F1).AllocFillUCS2(PUniConvSBCSEx(F1).FUCS2.Items[ccLower], ccLower);
        Comp.Lookup_2 := PUniConvSBCSEx(F2).FUCS2.Items[ccLower];
        if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PUniConvSBCSEx(F2).AllocFillUCS2(PUniConvSBCSEx(F2).FUCS2.Items[ccLower], ccLower);
        Result := __uniconv_sbcs_compare_sbcs_2(Store.SelfChars, Store.SChars, Comp);
      end;
      goto same_modify;
    end;
  else
  binary_compare:
    Result := __uniconv_compare_bytes(Store.SelfChars, Store.SChars, Store.SameLength);
  same_modify:
    Inc(Result, Result);
    Dec(Result, Store.SameModifier);
  end;
end;

function ByteString._CompareUTF16String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
var
  F, CharCase: NativeUInt;
  Comp: TUniConvCompareOptions;
begin
  Comp.Lookup := CaseLookup;
  F := Self.Flags;
  if (Integer(F) < 0) then
  begin
    // utf8-utf16
    Comp.Length := Self.Length;
    Comp.Length_2 := S.Length;
    Result := __uniconv_utf8_compare_utf16(Pointer(Self.FChars), Pointer(S.FChars), Comp);
  end else
  begin
    // sbcs-utf16
    F := F shr 24;
    F := F * SizeOf(TUniConvSBCS);
    Inc(F, NativeUInt(@UNICONV_SUPPORTED_SBCS));

    CharCase := NativeUInt(Comp.Lookup = nil);
    Comp.Lookup_2 := PUniConvSBCSEx(F).FUCS2.NumericItems[CharCase];
    if (Comp.Lookup_2 = nil) then Comp.Lookup_2 := PUniConvSBCSEx(F).AllocFillUCS2(PUniConvSBCSEx(F).FUCS2.NumericItems[CharCase], TCharCase(CharCase));

    Comp.Length := S.Length;
    Comp.Length_2 := Self.Length;
    Result := __uniconv_utf16_compare_sbcs(Pointer(S.FChars), Pointer(Self.FChars), Comp);
    Result := -Result;
  end;
end;


{ UTF16String }

function UTF16String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure UTF16String.SetEmpty(Value: Boolean);
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

procedure UTF16String.Assign(const AChars: PUnicodeChar; const ALength: NativeUInt);
begin
  Self.FChars := AChars;
  Self.FLength := ALength;
  Self.F.NativeFlags := 0;
end;

procedure UTF16String.Assign(const S: WideString);
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
procedure UTF16String.Assign(const S: UnicodeString);
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

function UTF16String.DetermineAscii: Boolean;
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

function UTF16String.TrimLeft: Boolean;
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
    Result := _TrimLeft(S, L);
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
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function UTF16String._TrimLeft(S: PWord; L: NativeUInt): Boolean;
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

function UTF16String.TrimRight: Boolean;
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
      Result := _TrimRight(S, L);
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
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function UTF16String._TrimRight(S: PWord; H: NativeUInt): Boolean;
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

function UTF16String.Trim: Boolean;
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
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
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
  // TrimLeft or True
  inc ecx
  cmp word ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp word ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function UTF16String._Trim(S: PWord; H: NativeUInt): Boolean;
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

  // TrimLeft
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // TrimRight
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

function UTF16String.SubString(const From, Count: NativeUInt): UTF16String;
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

function UTF16String.SubString(const Count: NativeUInt): UTF16String;
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

function UTF16String.Offset(const Count: NativeUInt): Boolean;
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

function UTF16String.Hash: Cardinal;
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

function UTF16String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86}
asm
  cmp byte ptr [EAX].F.Ascii, 0
  jnz _HashIgnoreCaseAscii
  jmp _HashIgnoreCase
end;
{$ifend}

function UTF16String._HashIgnoreCaseAscii: Cardinal;
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

function UTF16String._HashIgnoreCase: Cardinal;
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

function UTF16String.CharPos(const C: UnicodeChar; const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
var
  X: Cardinal;
  CValue: Word;
  P, TopCardinal, Top: PWord;
  StoredChars: PWord;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PWordArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;
  CValue := Ord(C);

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    if (Word(X) = CValue) then goto found;
    Inc(P);
    X := X shr 16;
    if (Word(X) = CValue) then goto found;
    Inc(P);
  until (False);

  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) and (P^ = CValue) then goto found;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 1;
end;

function UTF16String.CharPosIgnoreCase(const C: UnicodeChar; const From: NativeUInt): NativeInt;
label
  failure, found;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
var
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, TopCardinal, Top: PWord;
  StoredChars: PWord;
begin
  P := Pointer(FChars);
  TopCardinal := Pointer(@PWordArray(P)[FLength - CHARS_IN_CARDINAL]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  LowerCharMask := Ord(UNICONV_CHARCASE.LOWER[C]);
  UpperCharMask := Ord(UNICONV_CHARCASE.UPPER[C]);
  LowerCharMask := LowerCharMask + LowerCharMask shl 16;
  UpperCharMask := UpperCharMask + UpperCharMask shl 16;

  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(T and $8000 = 0));
    goto found;
  until (False);

  LowerCharMask := Word(LowerCharMask);
  UpperCharMask := Word(UpperCharMask);
  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) then
  begin
    X := P^;
    if (X = LowerCharMask) then goto found;
    if (X = UpperCharMask) then goto found;
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 1;
end;

function UTF16String.Pos(const S: UTF16String; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Word;
  PChar = ^TChar;
  TCharArray = TWordArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
var
  L, X: NativeUInt;
  CValue: Word;
  P, Top, TopCardinal: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    CValue: Word;
  end;  
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PUnicodeChar(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  TopCardinal := Pointer(@PCharArray(P)[Self.FLength -L - (CHARS_IN_CARDINAL - 1)]);  
  Inc(P, From);

  CValue := PChar(Store.StrChars)^;
  if (Self.Ascii > (CValue <= $7f)) then goto failure;
  Store.CValue := CValue;

  next_iteration:
    CValue := Store.CValue;   
  repeat
    if (NativeUInt(P) > NativeUInt(TopCardinal)) then Break;
    X := PCardinal(P)^;
    if (Word(X) = CValue) then goto char_found;
    Inc(P);
    X := X shr 16;
    Inc(P);    
    if (Word(X) <> CValue) then Continue;
    Dec(P);
  char_found:
    Inc(P);
    L := Store.StrLength - 1;    
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}    
    if (L >= CHARS_IN_CARDINAL{2}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_CARDINAL);
      Inc(P1, CHARS_IN_CARDINAL);
      Inc(P2, CHARS_IN_CARDINAL);      
    end;
    {$endif}
    if (L <> 0) then
    begin
      if (P1^ <> P2^) then goto next_iteration;     
    end;
    
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 1;
    Exit;    
  until (False);

  Top := Pointer(@PWordArray(TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) and (P^ = CValue) then goto char_found;  

failure:
  Result := -1;  
end;

function UTF16String.Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PUTF16String(@Buffer)^, From);
end;

function UTF16String.Pos(const S: UnicodeString; const From: NativeUInt): NativeInt;
var
  P: PInteger;
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  if (P = nil) then
  begin
    Result := -1;
  end else
  begin
    Dec(P);
    Buffer.Length := P^{$if Defined(WIDE_STR_SHIFT) and not Defined(UNICODE)} shr 1{$ifend};
    Result := Self.Pos(PUTF16String(@Buffer)^, From);
  end;
end;

function UTF16String.PosIgnoreCase(const S: UTF16String; const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Word;
  PChar = ^TChar;
  TCharArray = TWordArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(TChar);
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
var
  L: NativeUInt;
  X, T, V, U, LowerCharMask, UpperCharMask: NativeInt;
  P, Top{$ifNdef CPUX86},TopCardinal{$endif}: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    {$ifdef CPUX86}TopCardinal: Pointer;{$endif}
    UpperCharMask: NativeInt;
  end;
begin
  UpperCharMask := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PUnicodeChar(Store.StrChars)^, UpperCharMask);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  {$ifdef CPUX86}Store.{$endif}TopCardinal := Pointer(@PCharArray(Store.SelfCharsTop)[-L - (CHARS_IN_CARDINAL - 1)]);
  Inc(P, UpperCharMask{From});

  U := PChar(Store.StrChars)^;
  if (Self.Ascii > (U <= $7f)) then goto failure;
  LowerCharMask := UNICONV_CHARCASE.VALUES[U];
  UpperCharMask := UNICONV_CHARCASE.VALUES[$10000 + U];
  LowerCharMask := LowerCharMask + LowerCharMask shl 16;
  UpperCharMask := UpperCharMask + UpperCharMask shl 16;

  repeat
    if (NativeUInt(P) > NativeUInt({$ifdef CPUX86}Store.{$endif}TopCardinal)) then Break;
    X := PCardinal(P)^;
    Inc(P, CHARS_IN_CARDINAL);

    T := (X xor LowerCharMask);
    U := (X xor UpperCharMask);
    V := T + SUB_MASK;
    T := not T;
    T := T and V;
    V := U + SUB_MASK;
    U := not U;
    U := U and V;

    T := T or U;
    if (T and OVERFLOW_MASK = 0) then Continue;
    Dec(P, CHARS_IN_CARDINAL);
    Inc(P, Byte(T and $8000 = 0));
  char_found:
    Store.UpperCharMask := UpperCharMask;
      U := __uniconv_utf16_compare_utf16(Pointer(P), Store.StrChars, Store.StrLength);
    UpperCharMask := Store.UpperCharMask;
    Inc(P);
    if (U <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 1;
    Exit;
  until (False);

  LowerCharMask := TChar(LowerCharMask);
  UpperCharMask := TChar(UpperCharMask);
  Top := Pointer(@PCharArray({$ifdef CPUX86}Store.{$endif}TopCardinal)[CHARS_IN_CARDINAL]);
  if (NativeUInt(P) < NativeUInt(Top)) then
  begin
    X := P^;
    if (X = LowerCharMask) then goto char_found;
    if (X = UpperCharMask) then goto char_found;
  end;

failure:
  Result := -1;
end;

function UTF16String.PosIgnoreCase(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.PosIgnoreCase(PUTF16String(@Buffer)^, From);
end;

function UTF16String.PosIgnoreCase(const S: UnicodeString; const From: NativeUInt): NativeInt;
var
  P: PInteger;
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  P := Pointer(S);
  Buffer.Chars := P;
  Dec(P);
  Buffer.Length := P^{$if Defined(WIDE_STR_SHIFT) and not Defined(UNICODE)} shr 1{$ifend};
  Result := Self.PosIgnoreCase(PUTF16String(@Buffer)^, From);
end;

function UTF16String.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
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

function UTF16String.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PUTF16String(@Default)._GetBool(Pointer(Chars), Length);
end;

function UTF16String.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function UTF16String._GetBool(S: PWord; L: NativeUInt): Boolean;
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
  Buffer: ByteString;
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

function UTF16String.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
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

function UTF16String.ToHexDef(const Default: Integer): Integer;
begin
  Result := PUTF16String(@Default)._GetHex(Pointer(Chars), Length);
end;

function UTF16String.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function UTF16String._GetHex(S: PWord; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: UTF16String;
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

function UTF16String.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
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

function UTF16String.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PUTF16String(@Default)._GetInt(Pointer(Chars), Length);
end;

function UTF16String.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF16String.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
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

function UTF16String.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PUTF16String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function UTF16String.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt(Pointer(Chars), -Length);
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

function UTF16String._GetInt(S: PWord; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF16String;
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
        Result := PUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF16String(-NativeInt(@HexRet))._GetHex(S, L);
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

function UTF16String.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
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

function UTF16String.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function UTF16String.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function UTF16String._GetHex64(S: PWord; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: UTF16String;
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

function UTF16String.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
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

function UTF16String.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF16String.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF16String.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
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

function UTF16String.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(@Default)._GetInt64(Pointer(Chars), -Length);
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

function UTF16String.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF16String(0)._GetInt64(Pointer(Chars), -Length);
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

function UTF16String._GetInt64(S: PWord; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF16String;
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
        Result := PUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF16String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PUTF16String(nil)._GetInt_19(S, L);
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
  R2 := PUTF16String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PUTF16String(nil)._GetInt_19(S, 9);
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

function UTF16String._GetInt_19(S: PWord; L: NativeUInt): NativeInt;
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

function UTF16String.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF16String.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF16String.TryToFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function UTF16String.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PUTF16String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function UTF16String.ToFloat: Extended;
begin
  Result := PUTF16String(0)._GetFloat(Pointer(Chars), Length);
end;

function UTF16String._GetFloat(S: PWord; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: UTF16String;
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
      V := PUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, L);
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
          V := PUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, L);
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
      V := PUTF16String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF16String(@Store.V)._GetInt_19(S, L);
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
          V := PUTF16String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF16String(@Store.V)._GetInt_19(S, L);
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
    V := PUTF16String(nil)._GetInt_19(S, L);
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

function UTF16String.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function UTF16String.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function UTF16String.TryToDate(out Value: TDateTime): Boolean;
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

function UTF16String.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function UTF16String.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function UTF16String.TryToTime(out Value: TDateTime): Boolean;
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

function UTF16String.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function UTF16String.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function UTF16String.TryToDateTime(out Value: TDateTime): Boolean;
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

function UTF16String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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

procedure UTF16String.ToAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToLowerAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToUpperAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS: PUniConvSBCSEx;
  Dest: PByte;
  Converter: Pointer;
  Context: TUniConvContextEx;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  Context.Destination := @S[1];
  Context.DestinationSize := NativeUInt(High(S));

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF16String.ToUTF8String(var S: UTF8String);
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

procedure UTF16String.ToLowerUTF8String(var S: UTF8String);
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

procedure UTF16String.ToUpperUTF8String(var S: UTF8String);
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

procedure UTF16String.ToUTF8ShortString(var S: ShortString);
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

procedure UTF16String.ToLowerUTF8ShortString(var S: ShortString);
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

procedure UTF16String.ToUpperUTF8ShortString(var S: ShortString);
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

procedure UTF16String.ToWideString(var S: WideString);
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

procedure UTF16String.ToLowerWideString(var S: WideString);
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

procedure UTF16String.ToUpperWideString(var S: WideString);
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

procedure UTF16String.ToUnicodeString(var S: UnicodeString);
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

procedure UTF16String.ToLowerUnicodeString(var S: UnicodeString);
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

procedure UTF16String.ToUpperUnicodeString(var S: UnicodeString);
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

procedure UTF16String.ToString(var S: string);
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

procedure UTF16String.ToLowerString(var S: string);
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

procedure UTF16String.ToUpperString(var S: string);
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

function UTF16String.ToAnsiString: AnsiString;
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

function UTF16String.ToLowerAnsiString: AnsiString;
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

function UTF16String.ToUpperAnsiString: AnsiString;
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

function UTF16String.ToUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function UTF16String.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function UTF16String.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function UTF16String.ToWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function UTF16String.ToLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function UTF16String.ToUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

function UTF16String.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function UTF16String.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function UTF16String.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function UTF16String.ToString: string;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function UTF16String.ToLowerString: string;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function UTF16String.ToUpperString: string;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator UTF16String.Implicit(const a: UTF16String): AnsiString;
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

class operator UTF16String.Implicit(const a: UTF16String): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator UTF16String.Implicit(const a: UTF16String): WideString;
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
class operator UTF16String.Implicit(const a: UTF16String): UnicodeString;
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


{ UTF32String }

function UTF32String.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure UTF32String.SetEmpty(Value: Boolean);
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

procedure UTF32String.Assign(const AChars: PUCS4Char; const ALength: NativeUInt);
begin
  Self.FChars := AChars;
  Self.FLength := ALength;
  Self.F.NativeFlags := 0;
end;

procedure UTF32String.Assign(const S: UCS4String; const NullTerminated: Boolean);
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

function UTF32String.DetermineAscii: Boolean;
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

function UTF32String.TrimLeft: Boolean;
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
    Result := _TrimLeft(S, L);
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
  jbe _TrimLeft
  mov al, 1
end;
{$ifend}

function UTF32String._TrimLeft(S: PCardinal; L: NativeUInt): Boolean;
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

function UTF32String.TrimRight: Boolean;
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
      Result := _TrimRight(S, L);
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
  jbe _TrimRight
  mov al, 1
end;
{$ifend}

function UTF32String._TrimRight(S: PCardinal; H: NativeUInt): Boolean;
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

function UTF32String.Trim: Boolean;
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
      // TrimLeft or True
      if (S^ > 32) then
      begin
        Result := True;
        Exit;
      end else
      begin
        Result := _TrimLeft(S, L+1);
        Exit;
      end;
    end else
    begin
      // TrimRight or Trim
      if (S^ > 32) then
      begin
        Result := _TrimRight(S, L);
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
  // TrimLeft or True
  inc ecx
  cmp dword ptr [edx], 32
  jbe _TrimLeft
  mov al, 1
  ret
@2:
  // TrimRight or Trim
  cmp dword ptr [edx], 32
  ja _TrimRight
  jmp _Trim
end;
{$ifend}

function UTF32String._Trim(S: PCardinal; H: NativeUInt): Boolean;
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

  // TrimLeft
  repeat
    Inc(S);  
    if (S = TopS) then goto fail;    
  until (S^ > 32);  
  FChars := Pointer(S);

  // TrimRight
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

function UTF32String.SubString(const From, Count: NativeUInt): UTF32String;
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

function UTF32String.SubString(const Count: NativeUInt): UTF32String;
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

function UTF32String.Offset(const Count: NativeUInt): Boolean;
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

function UTF32String.Hash: Cardinal;
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

function UTF32String.HashIgnoreCase: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  if (Self.Ascii) then Result := _HashIgnoreCaseAscii
  else Result := _HashIgnoreCase;
end;
{$else .CPUX86}
asm
  cmp byte ptr [EAX].F.Ascii, 0
  jnz _HashIgnoreCaseAscii
  jmp _HashIgnoreCase
end;
{$ifend}

function UTF32String._HashIgnoreCaseAscii: Cardinal;
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

function UTF32String._HashIgnoreCase: Cardinal;
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

function UTF32String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
label
  failure, found;
var
  P, Top: PCardinal;
  StoredChars: PCardinal;
begin
  P := Pointer(FChars);
  Top := Pointer(@PCardinalArray(P)[FLength]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    if (P^ = C) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 2;
end;

function UTF32String.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
label
  failure, found;
var
  X, LowerChar, UpperChar: NativeInt;
  P, Top: PCardinal;
  StoredChars: PCardinal;
begin
  P := Pointer(FChars);
  Top := Pointer(@PCardinalArray(P)[FLength]);
  StoredChars := P;
  Inc(P, From);
  if (Self.Ascii > (Ord(C) <= $7f)) then goto failure;

  LowerChar := Ord(C);
  UpperChar := LowerChar;
  if (LowerChar <= $ffff) then
  begin
    LowerChar := UNICONV_CHARCASE.VALUES[LowerChar];
    UpperChar := UNICONV_CHARCASE.VALUES[UpperChar + $10000];
  end;

  while (NativeUInt(P) < NativeUInt(Top)) do
  begin
    X := P^;
    if (X = LowerChar) then goto found;
    if (X = UpperChar) then goto found;
    Inc(P);
  end;

failure:
  Result := -1;
  Exit;
found:
  Result := NativeInt(P);
  Dec(Result, NativeInt(StoredChars));
  Result := Result shr 2;
end;

function utf32_compare_utf32(S1, S2: PCardinal; L: NativeUInt): NativeInt;
label
  make_result;
var
  X, Y, i: NativeUInt;
begin
  for i := 1 to L do
  begin
    X := S1^;
    Y := S2^;
    Inc(S1);
    Inc(S2);
    if (X <> Y) then goto make_result;
  end;

  Result := 0;
  Exit;

  // warnings off
  X := 0;
  Y := 0;    
  
make_result:
  Result := Ord(X > Y)*2 - 1;
end;

function UTF32String.Pos(const S: UTF32String; const From: NativeUInt): NativeInt;
label
  next_iteration, failure, char_found;
type
  TChar = Cardinal;
  PChar = ^TChar;
  TCharArray = TCardinalArray;
  PCharArray = ^TCharArray;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(TChar);
  CHARS_IN_CARDINAL = SizeOf(CARDINAL) div SizeOf(TChar);
var
  L, X: NativeUInt;
  P, Top: PChar;
  P1, P2: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    X: NativeUInt;
  end;  
begin
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPos(PUCS4Char(Store.StrChars)^, From);
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Top := Pointer(@PCharArray(P)[Self.FLength -L + 1]);
  Inc(P, From);
  
  X := PChar(Store.StrChars)^;
  if (Self.Ascii > (X <= $7f)) then goto failure;
  Store.X := X;
  
  repeat
  next_iteration:
    X := Store.X;  
    if (NativeUInt(P) < NativeUInt(Top)) then
    repeat
      if (P^ = TChar(X)) then goto char_found;
      Inc(P);
    until (NativeUInt(P) = NativeUInt(Top));
    Break;

  char_found:
    Inc(P);
    L := Store.StrLength - 1;    
    P2 := Store.StrChars;
    P1 := P;
    Inc(P2);
    if (L >= CHARS_IN_NATIVE) then
    repeat
      if (PNativeUInt(P1)^ <> PNativeUInt(P2)^) then goto next_iteration;
      Dec(L, CHARS_IN_NATIVE);
      Inc(P1, CHARS_IN_NATIVE);
      Inc(P2, CHARS_IN_NATIVE);
    until (L < CHARS_IN_NATIVE);
    {$ifdef LARGEINT}    
    if (L >= CHARS_IN_CARDINAL{1}) then
    begin
      if (PCardinal(P1)^ <> PCardinal(P2)^) then goto next_iteration;
    end;
    {$endif}
        
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 2;
    Exit;
  until (False);  
  
failure:
  Result := -1{todo};
end;

function UTF32String.Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.Pos(PUTF32String(@Buffer)^, From);
end;

function UTF32String.Pos(const S: UCS4String; const From: NativeUInt): NativeInt;
var
  L: NativeUInt;
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  L := NativeUInt(Pointer(S));
  if (L = 0{nil}) then
  begin
    Result := -1;
  end else
  begin
    Buffer.Chars := Pointer(S);
    Dec(L, SizeOf(NativeUInt));
    L := PNativeUInt(L)^;
    {$ifNdef FPC}Dec(L);{$endif}
    Inc(L, Byte(S[L] <> 0));
    Buffer.Length := L;
    Result := Self.Pos(PUTF32String(@Buffer)^, From);
  end;
end;

function utf32_compare_utf32_ignorecase(S1, S2: PCardinal; L: NativeUInt): NativeInt;
label
  make_result;
var
  X, Y: NativeUInt;
  CaseLookup: PUniConvWW;
begin
  CaseLookup := Pointer(@UNICONV_CHARCASE.LOWER);

  repeat
    if (L = 0) then Break;
    X := S1^;
    Y := S2^;
    Dec(L);
    Inc(S1);
    Inc(S2);

    if (X = Y) then Continue;
    if (X or Y > $ffff) then goto make_result;
    X := CaseLookup[X];
    Y := CaseLookup[Y];
    if (X <> Y) then goto make_result;
  until (False);

  Result := 0;
  Exit;

  // warnings off
  X := 0;
  Y := 0;    
  
make_result:
  Result := Ord(X > Y)*2 - 1;
end;

function UTF32String.PosIgnoreCase(const S: UTF32String; const From: NativeUInt): NativeInt;
label
  failure, char_found;
type
  TChar = Cardinal;
  PChar = ^TChar;
  TCharArray = TCardinalArray;
  PCharArray = ^TCharArray;
var
  L: NativeUInt;
  X, LowerChar, UpperChar: NativeInt;
  P, Top: PChar;
  Store: record
    StrLength: NativeUInt;
    StrChars: Pointer;
    SelfChars: Pointer;
    SelfCharsTop: Pointer;
    Top: Pointer;
    UpperChar: NativeInt;
  end;
begin
  UpperChar := From{store};
  Store.StrChars := S.Chars;
  L := S.Length;
  if (L <= 1) then
  begin
    if (L = 0) then goto failure;
    Result := Self.CharPosIgnoreCase(PUCS4Char(Store.StrChars)^, UpperChar{From});
    Exit;
  end;
  Store.StrLength := L;
  P := Pointer(Self.FChars);
  Store.SelfChars := P;
  Store.SelfCharsTop := Pointer(@PCharArray(P)[Self.FLength]);
  Top := Pointer(@PCharArray(Store.SelfCharsTop)[-L + 1]);
  Inc(P, UpperChar{From});

  LowerChar := PChar(Store.StrChars)^;
  if (Self.Ascii > (LowerChar <= $7f)) then goto failure;
  UpperChar := LowerChar;
  if (LowerChar <= $ffff) then
  begin
    LowerChar := UNICONV_CHARCASE.VALUES[LowerChar];
    UpperChar := UNICONV_CHARCASE.VALUES[UpperChar + $10000];
  end;

  repeat
    while (NativeUInt(P) < NativeUInt(Top)) do
    begin
      X := P^;
      if (X = LowerChar) then goto char_found;
      if (X = UpperChar) then goto char_found;
      Inc(P);
    end;
    Break;

  char_found:
    Store.Top := Top;
    Store.UpperChar := UpperChar;
      X := utf32_compare_utf32_ignorecase(Pointer(P), Store.StrChars, Store.StrLength);
    UpperChar := Store.UpperChar;
    Top := Store.Top;  
    Inc(P);
    if (X <> 0) then Continue;
    Dec(P);
    Pointer(Result) := P;
    Dec(Result, NativeInt(Store.SelfChars));
    Result := Result shr 2;
    Exit;
  until (False);

failure:
  Result := -1;
end;

function UTF32String.PosIgnoreCase(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
var
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  Buffer.Chars := AChars;
  Buffer.Length := ALength;
  Result := Self.PosIgnoreCase(PUTF32String(@Buffer)^, From);
end;

function UTF32String.PosIgnoreCase(const S: UCS4String; const From: NativeUInt): NativeInt;
var
  L: NativeUInt;
  Buffer: record
    Chars: Pointer;
    Length: NativeUInt;
  end;
begin
  L := NativeUInt(Pointer(S));
  if (L = 0{nil}) then
  begin
    Result := -1;
  end else
  begin
    Buffer.Chars := Pointer(S);
    Dec(L, SizeOf(NativeUInt));
    L := PNativeUInt(L)^;
    {$ifNdef FPC}Dec(L);{$endif}
    Inc(L, Byte(S[L] <> 0));
    Buffer.Length := L;
    Result := Self.PosIgnoreCase(PUTF32String(@Buffer)^, From);
  end;
end;

function UTF32String.TryToBoolean(out Value: Boolean): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetBool(Pointer(Chars), Length);
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

function UTF32String.ToBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PUTF32String(@Default)._GetBool(Pointer(Chars), Length);
end;

function UTF32String.ToBoolean: Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetBool(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetBool
end;
{$ifend}

function UTF32String._GetBool(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
type
  TStrAsData = packed record
    Dwords: array[0..High(Integer) div 4 - 1] of Cardinal;
  end;
var
  Marker: NativeInt;
  Buffer: ByteString;
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

function UTF32String.TryToHex(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetHex(Pointer(Chars), Length);
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

function UTF32String.ToHexDef(const Default: Integer): Integer;
begin
  Result := PUTF32String(@Default)._GetHex(Pointer(Chars), Length);
end;

function UTF32String.ToHex: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetHex(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex
end;
{$ifend}

function UTF32String._GetHex(S: PCardinal; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: UTF32String;
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

function UTF32String.TryToCardinal(out Value: Cardinal): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), Length);
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

function UTF32String.ToCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PUTF32String(@Default)._GetInt(Pointer(Chars), Length);
end;

function UTF32String.ToCardinal: Cardinal;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt
end;
{$ifend}

function UTF32String.TryToInteger(out Value: Integer): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt(Pointer(Chars), -Length);
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

function UTF32String.ToIntegerDef(const Default: Integer): Integer;
begin
  Result := PUTF32String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function UTF32String.ToInteger: Integer;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt(Pointer(Chars), -Length);
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

function UTF32String._GetInt(S: PCardinal; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF32String;
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
        Result := PUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF32String(-NativeInt(@HexRet))._GetHex(S, L);
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

function UTF32String.TryToHex64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetHex64(Pointer(Chars), Length);
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

function UTF32String.ToHex64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetHex64
end;
{$ifend}

function UTF32String.ToHex64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetHex64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetHex64
end;
{$ifend}

function UTF32String._GetHex64(S: PCardinal; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: UTF32String;
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

function UTF32String.TryToUInt64(out Value: UInt64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), Length);
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

function UTF32String.ToUInt64Def(const Default: UInt64): UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  lea eax, Default
  call _GetInt64
end;
{$ifend}

function UTF32String.ToUInt64: UInt64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt64(Pointer(Chars), Length);
end;
{$else .CPUX86}
asm
  mov ecx, [EAX].FLength
  mov edx, [EAX].FChars
  xor eax, eax
  jmp _GetInt64
end;
{$ifend}

function UTF32String.TryToInt64(out Value: Int64): Boolean;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetInt64(Pointer(Chars), -Length);
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

function UTF32String.ToInt64Def(const Default: Int64): Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(@Default)._GetInt64(Pointer(Chars), -Length);
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

function UTF32String.ToInt64: Int64;
{$if Defined(INLINESUPPORT) or not Defined(CPUX86)}
begin
  Result := PUTF32String(0)._GetInt64(Pointer(Chars), -Length);
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

function UTF32String._GetInt64(S: PCardinal; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: UTF32String;
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
        Result := PUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end else
      begin
        Result := -PUTF32String(-NativeInt(@HexRet))._GetHex64(S, L);
        if (HexRet.Value = 0) then goto fail;
      end;

      Exit;
    end;
  end;

  if (Marker and (4 + 1) = 4) then goto fail;

  if (L <= 9) then
  begin
    R1 := PUTF32String(nil)._GetInt_19(S, L);
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
  R2 := PUTF32String(nil)._GetInt_19(S, L);
  Inc(S, L);
  if (R2 < 0) then goto fail;

  R1 := PUTF32String(nil)._GetInt_19(S, 9);
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

function UTF32String._GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
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

function UTF32String.TryToFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF32String.TryToFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function UTF32String.TryToFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function UTF32String.ToFloatDef(const Default: Extended): Extended;
begin
  Result := PUTF32String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function UTF32String.ToFloat: Extended;
begin
  Result := PUTF32String(0)._GetFloat(Pointer(Chars), Length);
end;

function UTF32String._GetFloat(S: PCardinal; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: UTF32String;
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
      V := PUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, L);
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
          V := PUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, L);
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
      V := PUTF32String(@Store.V)._GetInt_19(S, 9);
      X := 9;
    end else
    begin
      V := PUTF32String(@Store.V)._GetInt_19(S, L);
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
          V := PUTF32String(@Store.V)._GetInt_19(S, 9);
          X := 9;
        end else
        begin
          V := PUTF32String(@Store.V)._GetInt_19(S, L);
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
    V := PUTF32String(nil)._GetInt_19(S, L);
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

function UTF32String.ToDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function UTF32String.ToDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDate), @Self);
end;

function UTF32String.TryToDate(out Value: TDateTime): Boolean;
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

function UTF32String.ToTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    Result := Default;
end;

function UTF32String.ToTime: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidTime), @Self);
end;

function UTF32String.TryToTime(out Value: TDateTime): Boolean;
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

function UTF32String.ToDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function UTF32String.ToDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@{$ifdef UNITSCOPENAMES}System.{$endif}SysConst.SInvalidDateTime), @Self);
end;

function UTF32String.TryToDateTime(out Value: TDateTime): Boolean;
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

function UTF32String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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

procedure UTF32String.ToAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF32String.ToLowerAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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

procedure UTF32String.ToUpperAnsiString(var S: AnsiString; const CodePage: Word);
var
  L, X: NativeUInt;
  Index: NativeInt;
  Value: Integer;
  DestSBCS, StoredDestSBCS: PUniConvSBCSEx;
  Converter: Pointer;
  Dest, Src: Pointer;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8String(UTF8String(S));
    Exit;
  end;

  Index := NativeUInt(CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = CodePage) or (Value < 0) then Break;
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
    CodePage: Word;
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
  Index := NativeUInt(SBCSConv.CodePage);
  Value := Integer(UNICONV_SUPPORTED_SBCS_HASH[Index and High(UNICONV_SUPPORTED_SBCS_HASH)]);
  repeat
    if (Word(Value) = SBCSConv.CodePage) or (Value < 0) then Break;
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

procedure UTF32String.ToAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePage := CodePage;

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

procedure UTF32String.ToLowerAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToLowerUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePage := CodePage;

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

procedure UTF32String.ToUpperAnsiShortString(var S: ShortString; const CodePage: Word);
var
  L: NativeUInt;
  Src: Pointer;
  SBCSConv: TSBCSConv;
begin
  if (CodePage = CODEPAGE_UTF8) then
  begin
    ToUpperUTF8ShortString(S);
    Exit;
  end;
  SBCSConv.CodePage := CodePage;

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

procedure UTF32String.ToUTF8String(var S: UTF8String);
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

procedure UTF32String.ToLowerUTF8String(var S: UTF8String);
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

procedure UTF32String.ToUpperUTF8String(var S: UTF8String);
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

procedure UTF32String.ToUTF8ShortString(var S: ShortString);
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

procedure UTF32String.ToLowerUTF8ShortString(var S: ShortString);
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

procedure UTF32String.ToUpperUTF8ShortString(var S: ShortString);
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

procedure UTF32String.ToWideString(var S: WideString);
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

procedure UTF32String.ToLowerWideString(var S: WideString);
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

procedure UTF32String.ToUpperWideString(var S: WideString);
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

procedure UTF32String.ToUnicodeString(var S: UnicodeString);
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

procedure UTF32String.ToLowerUnicodeString(var S: UnicodeString);
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

procedure UTF32String.ToUpperUnicodeString(var S: UnicodeString);
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

procedure UTF32String.ToString(var S: string);
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

procedure UTF32String.ToLowerString(var S: string);
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

procedure UTF32String.ToUpperString(var S: string);
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

function UTF32String.ToAnsiString: AnsiString;
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

function UTF32String.ToLowerAnsiString: AnsiString;
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

function UTF32String.ToUpperAnsiString: AnsiString;
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

function UTF32String.ToUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

function UTF32String.ToLowerUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToLowerUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerUTF8String
end;
{$endif}

function UTF32String.ToUpperUTF8String: UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUpperUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperUTF8String
end;
{$endif}

function UTF32String.ToWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToWideString
end;
{$endif}

function UTF32String.ToLowerWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToLowerWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToLowerWideString
end;
{$endif}

function UTF32String.ToUpperWideString: WideString;
{$ifNdef CPUINTEL}
begin
  ToUpperWideString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUpperWideString
end;
{$endif}

function UTF32String.ToUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    jmp ToWideString
  {$endif}
end;
{$endif}

function UTF32String.ToLowerUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    jmp ToLowerWideString
  {$endif}
end;
{$endif}

function UTF32String.ToUpperUnicodeString: UnicodeString;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    jmp ToUpperWideString
  {$endif}
end;
{$endif}

function UTF32String.ToString: string;
{$ifNdef CPUINTEL}
begin
  ToUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToAnsiString
  {$endif}
end;
{$endif}

function UTF32String.ToLowerString: string;
{$ifNdef CPUINTEL}
begin
  ToLowerUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToLowerUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToLowerAnsiString
  {$endif}
end;
{$endif}

function UTF32String.ToUpperString: string;
{$ifNdef CPUINTEL}
begin
  ToUpperUnicodeString(Result);
end;
{$else .CPUX86/CPUX64}
asm
  {$ifdef UNICODE}
    jmp ToUpperUnicodeString
  {$else}
    xor ecx, ecx
    jmp ToUpperAnsiString
  {$endif}
end;
{$endif}

{$ifdef OPERATORSUPPORT}
class operator UTF32String.Implicit(const a: UTF32String): AnsiString;
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

class operator UTF32String.Implicit(const a: UTF32String): UTF8String;
{$ifNdef CPUINTEL}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86/CPUX64}
asm
  jmp ToUTF8String
end;
{$endif}

class operator UTF32String.Implicit(const a: UTF32String): WideString;
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
class operator UTF32String.Implicit(const a: UTF32String): UnicodeString;
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

function UTF32String._CompareByteString(const S: PByteString; const CaseLookup: PUniConvWW): NativeInt;
begin
  Result := -1{todo};
end;

function UTF32String._CompareUTF16String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
begin
  Result := -1{todo};
end;

function UTF32String._CompareUTF32String(const S: PUTF16String; const CaseLookup: PUniConvWW): NativeInt;
begin
  Result := -1{todo};
end;


{ TCachedTextReader }

function DetectSBCS(const CodePage: Word; const UTF8Compatible: Boolean = True): PUniConvSBCS;
begin
  if (CodePage = CODEPAGE_UTF8) and (UTF8Compatible) then
  begin
    Result := nil;
  end else
  begin
    Result := UniConvSBCS(CodePage);
    if (CodePage <> 0) and (Result.CodePage <> CodePage) then
      raise ECachedText.CreateFmt('CP%d is not byte encoding', [CodePage]);
  end;
end;

function DetectBOM(const Source: TCachedReader): TBOM;
begin
  if (Source.Margin < 4) and (not Source.EOF) then Source.Flush;

  Result := UniConv.DetectBOM(Source.Current, Source.Margin);
  if (Result <> bomNone) then
    Inc(Source.Current, BOM_INFO[Result].Size);
end;

constructor TCachedTextReader.Create(const Context: PUniConvContext;
  const Source: TCachedReader; const Owner: Boolean);
begin
  inherited Create;

  FSource := Source;
  FOwner := Owner;
  if (Context <> nil) and
    (@PUniConvContextEx(Context).FConvertProc <> @TUniConvContextEx.convert_copy) then
  begin
    FConverter := TUniConvReReader.Create(Context, Source);
    FReader := FConverter;
  end else
  begin
    FReader := Source;
  end;

  Current := FReader.Current;
  FOverflow := FReader.Overflow;
  FFinishing := FReader.Finishing;
  FEOF := FReader.EOF;
end;

destructor TCachedTextReader.Destroy;
begin
  FReader := nil;

  if (FConverter <> nil) then
  begin
    FOwner := FOwner or FConverter.Owner;
    FConverter.Owner := False;
    FConverter.Free;
  end;

  if (FOwner) then FSource.Free;
  inherited;
end;

function TCachedTextReader.GetMargin: NativeInt;
var
  P: NativeInt;
begin
  // Result := NativeInt(FOverflow) - NativeInt(Current);
  P := NativeInt(Current);
  Result := NativeInt(FOverflow);
  Dec(Result, P);
end;

function TCachedTextReader.GetPosition: Int64;
begin
  Result := FReader.Position;
end;

procedure TCachedTextReader.SetEOF(const Value: Boolean);
begin
  if (Value) and (FEOF <> Value) then
  begin
    FReader.EOF := True;

    Current := FReader.Current;
    FOverflow := FReader.Overflow;
    FFinishing := FReader.Finishing;
    FEOF := FReader.EOF;
  end;
end;

function TCachedTextReader.Flush: NativeUInt;
begin
  Result := FReader.Flush;

  Current := FReader.Current;
  FOverflow := FReader.Overflow;
  FFinishing := FReader.Finishing;
  FEOF := FReader.EOF;
end;

procedure TCachedTextReader.OverflowReadData(var Buffer; const Count: NativeUInt);
begin
  FReader.Current := Current;
  FReader.Read(Buffer, Count);

  Current := FReader.Current;
  FOverflow := FReader.Overflow;
  FFinishing := FReader.Finishing;
  FEOF := FReader.EOF;
end;

procedure TCachedTextReader.ReadData(var Buffer; const Count: NativeUInt);
var
  P: PByte;
begin
  P := Current;
  Inc(P, Count);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowReadData(Buffer, Count);
  end else
  begin
    Current := P;
    Dec(P, Count);
    NcMove(P^, Buffer, Count);
  end;
end;


{ TByteTextReader }

procedure TByteTextReader.SetSBCS(const Value: PUniConvSBCS);
begin
  FSBCS := Value;

  if (Value = nil) then
  begin
    FEncoding := CODEPAGE_UTF8;
    FNativeFlags := $ff000000;
  end else
  begin
    FEncoding := Value.CodePage;
    FUCS2 := Pointer(Value.UCS2);
    FNativeFlags := NativeUInt(Value.Index) shl 24;
  end;
end;

constructor TByteTextReader.Create(const Encoding: Word;
  const Source: TCachedReader; const DefaultByteEncoding: Word;
  const Owner: Boolean);
var
  BOM: TBOM;
  SBCS, DefaultSBCS: PUniConvSBCS;
  Context: PUniConvContext;
begin
  BOM := DetectBOM(Source);
  SBCS := DetectSBCS(Encoding);
  DefaultSBCS := DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;

  if (BOM = bomNone) and (DefaultByteEncoding = CODEPAGE_UTF8) then
    BOM := bomUTF8;

  if (SBCS = nil) then
  begin
    if (BOM = bomUTF8) then
    begin
      Context := nil;
    end else
    begin
      Context.Init(bomUTF8, BOM, DefaultByteEncoding);
    end;
  end else
  if (BOM = bomNone) then
  begin
    if (SBCS = DefaultSBCS) then
    begin
      Context := nil;
    end else
    begin
      Context.InitSBCSFromSBCS(SBCS.CodePage, DefaultSBCS.CodePage);
    end;
  end else
  begin
    Context.Init(bomNone, BOM, Encoding);
  end;

  SetSBCS(SBCS);
  inherited Create(Context, Source, Owner);
end;

constructor TByteTextReader.CreateFromFile(const Encoding: Word;
  const FileName: string; const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(Encoding, TCachedFileReader.Create(FileName), DefaultByteEncoding, True);
end;

constructor TByteTextReader.CreateDefault(const Source: TCachedReader;
  const DefaultByteEncoding: Word; const Owner: Boolean);
var
  BOM: TBOM;
  SBCS: PUniConvSBCS;
  Context: PUniConvContext;
begin
  BOM := DetectBOM(Source);
  SBCS := DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;

  if (BOM = bomNone) then
  begin
    Context := nil;
  end else
  if (BOM = bomUTF8) then
  begin
    SBCS := nil;
    Context := nil;
  end else
  begin
    if (SBCS = nil) then
    begin
      Context.Init(bomUTF8, BOM);
    end else
    begin
      Context.Init(bomNone, BOM, DefaultByteEncoding);
    end;
  end;

  SetSBCS(SBCS);
  inherited Create(Context, Source, Owner);
end;

constructor TByteTextReader.CreateDefaultFromFile(const FileName: string;
  const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  CreateDefault(TCachedFileReader.Create(FileName), DefaultByteEncoding, True);
end;

constructor TByteTextReader.CreateDirect(const Context: PUniConvContext;
  const Source: TCachedReader; const Owner: Boolean);
var
  SBCS: PUniConvSBCS;
begin
  SBCS := nil{UTF-8};
  if (Context <> nil) then SBCS := DetectSBCS(Context.DestinationCodePage);

  SetSBCS(SBCS);
  inherited Create(Context, Source, Owner);
end;

function TByteTextReader.FlushReadChar: UCS4Char;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.ReadChar;
end;

function TByteTextReader.ReadChar: UCS4Char;
label
  buffer_too_small;
var
  P: PByte;
  X, Y: NativeUInt;
  UCS2: PUniConvWB;
begin
  P := Self.Current;

  X := P^;
  Inc(P);
  if (NativeUInt(P) <= NativeUInt(FOverflow)) then
  begin
    if (X <= $7f) then
    begin
      Self.Current := P;
      Result := X;
      Exit;
    end;

    UCS2 := Self.FUCS2;
    if (UCS2 <> nil) then
    begin
      X := UCS2[X];
      Self.Current := P;
      Result := X;
      Exit;
    end;

    X := UNICONV_UTF8CHAR_SIZE[X];
    Inc(P, X);
    Dec(P, Byte(X <> 0));
    if (NativeUInt(P) > NativeUInt(FOverflow)) then goto buffer_too_small;
    Self.Current := P;

    Dec(P, X);
    Y := X;
    X := PCardinal(P)^;
    case Y of
      2: if (X and $C0E0 = $80C0) then
         begin
           // X := ((X and $1F) shl 6) or ((X shr 8) and $3F);
           Y := X;
           X := X and $1F;
           Y := Y shr 8;
           X := X shl 6;
           Y := Y and $3F;
           Result := X + Y;
           Exit;
         end;
      3: if (X and $C0C000 = $808000) then
         begin
            // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
           Y := (X and $0F) shl 12;
           Y := Y + (X shr 16) and $3F;
           X := (X and $3F00) shr 2;
           Result := X + Y;
           Exit;
         end;
      4: if (X and $C0C0C000 = $80808000) then
         begin
           // X := (X&07)<<18 | (X&3f00)<<4 | (X>>10)&0fc0 | (X>>24)&3f;
           Y := (X and $07) shl 18;
           Y := Y + (X and $3f00) shl 4;
           Y := Y + (X shr 10) and $0fc0;
           X := (X shr 24) and $3f;
           Result := X + Y;
           Exit;
         end;
    end;

    // unknown:
    Result := UNKNOWN_CHARACTER;
    Exit;
  end else
  begin
  buffer_too_small:
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TByteTextReader.FlushReadln(var S: ByteString): Boolean;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.Readln(S);
end;

function TByteTextReader.Readln(var S: ByteString): Boolean;
type
  TSelf = TByteTextReader;
label
  next_cardinal, retrieve_top, done, done_one, flush_recall;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);
  CR_XOR_MASK = $0d0d0d0d; // \r
  LF_XOR_MASK = $0a0a0a0a; // \n
  SUB_MASK  = Integer(-$01010101);
  OVERFLOW_MASK = Integer($80808080);
  ASCII_MASK = Integer($80808080);
var
  P, Top: PByte;
  X, T, V, U, Flags: NativeInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PByteString;
  end;
  _S: PByteString;
  {$endif}
begin
  S.F.NativeFlags := Self.FNativeFlags;
  P := Pointer(Self.Current);
  PByte(S.FChars) := P;
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  {$ifdef CPUX86}
    Store.Self := Pointer(Self);
    Store.S := @S;
  {$endif}

  if (NativeInt(Flags) >= SizeOf(AnsiChar)) then
  begin
    Top := P;
    Inc(Top, Flags);
    Flags := 0;

    repeat
      Dec(Top, CHARS_IN_CARDINAL);
    next_cardinal:
      X := PCardinal(P)^;

      if (NativeUInt(P) <= NativeUInt(Top{Cardinal})) then
      begin
        Inc(P, CHARS_IN_CARDINAL);
        Flags := Flags or X;

        T := (X xor CR_XOR_MASK);
        U := (X xor LF_XOR_MASK);
        V := T + SUB_MASK;
        T := not T;
        T := T and V;
        V := U + SUB_MASK;
        U := not U;
        U := U and V;

        T := T or U;
        if (T and OVERFLOW_MASK = 0) then goto next_cardinal;
        Dec(P, CHARS_IN_CARDINAL);
        Inc(P, Byte(Byte(T and $80 = 0) + Byte(T and $8080 = 0) +
          Byte(T and $808080 = 0)));
        goto retrieve_top;
      end else
      begin
      retrieve_top:
        Inc(Top, CHARS_IN_CARDINAL);
        if (P = Top) then goto done;
      end;

      X := P^;
      Flags := Flags or X;
      Inc(P);
      if (X <> $0a) then
      begin
        if (X <> $0d) then
        begin
          if (P <> Top) then Continue;
        done:
          if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
          {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
          Inc(P);
        end else
        begin
          // #13
          if (P = Top) then
          begin
            if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
            goto done_one;
          end else
          begin
            if (P^ <> $0a) then goto done_one;
            Inc(P);
            {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
            Dec(P);
          end;
        end;
      end else
      begin
        // #10
      done_one:
        {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
      end;

      Dec(P);
      {$ifdef CPUX86}_S := Store.S;{$endif}
      {$ifdef CPUX86}_S{$else}S{$endif}.F.Ascii := (Flags and ASCII_MASK = 0);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
      {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount};
      Result := True;
      Exit;
    until (False);
  end else
  begin
    if ({$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FlushReadln(
        {$ifdef CPUX86}Store.S^{$else}S{$endif});
    end;
  end;
end;


{ TUTF16TextReader }

constructor TUTF16TextReader.Create(const Source: TCachedReader;
  const DefaultByteEncoding: Word; const Owner: Boolean);
var
  BOM: TBOM;
  Context: PUniConvContext;
begin
  BOM := DetectBOM(Source);
  {Check}DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;

  if (BOM = bomUTF16) then
  begin
    Context := nil;
  end else
  begin
    if (BOM = bomNone) and (DefaultByteEncoding = CODEPAGE_UTF8) then
      BOM := bomUTF8;

    Context.Init(bomUTF16, BOM, DefaultByteEncoding);
  end;

  inherited Create(Context, Source, Owner);
end;

constructor TUTF16TextReader.CreateFromFile(const FileName: string;
  const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(TCachedFileReader.Create(FileName), DefaultByteEncoding, True);
end;

constructor TUTF16TextReader.CreateDirect(const Context: PUniConvContext;
  const Source: TCachedReader; const Owner: Boolean);
begin
  inherited Create(Context, Source, Owner);
end;

function TUTF16TextReader.FlushReadChar: UCS4Char;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.ReadChar;
end;

function TUTF16TextReader.ReadChar: UCS4Char;
label
  buffer_too_small, unknown, done;
var
  X, Y: NativeUInt;
begin
  Y{P} := NativeUInt(Self.Current);

  X := PWord(Y{P})^;
  Inc(Y{P}, SizeOf(UnicodeChar));
  if (Y{P} <= NativeUInt(FOverflow)) then
  begin
    if (X < $d800) then
    begin
    done:
      Self.Current := Pointer(Y{P});
      Result := X;
      Exit;
    end;
    if (X >= $e000) then goto done;
    if (X >= $dc00) then goto unknown;

    Inc(Y{P}, SizeOf(UnicodeChar));
    if (Y{P} > NativeUInt(FOverflow)) then goto buffer_too_small;
    Self.Current := Pointer(Y{P});

    Dec(Y{P}, SizeOf(UnicodeChar));
    Y := PWord(Y{P})^;
    Dec(Y, $dc00);
    Dec(X, $d800);
    if (Y >= ($e000-$dc00)) then goto unknown;
    X := X shl 10;
    Inc(Y, $10000);
    Inc(X, Y);
    Result := X;
    Exit;

  unknown:
    X := UNKNOWN_CHARACTER;
    goto done;
  end else
  begin
  buffer_too_small:
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TUTF16TextReader.FlushReadln(var S: UTF16String): Boolean;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.Readln(S);
end;

function TUTF16TextReader.Readln(var S: UTF16String): Boolean;
type
  TSelf = TUTF16TextReader;
label
  next_cardinal, retrieve_top, done, done_one, flush_recall;
const
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);
  CR_XOR_MASK = $000d000d; // \r
  LF_XOR_MASK = $000a000a; // \n
  SUB_MASK  = Integer(-$00010001);
  OVERFLOW_MASK = Integer($80008000);
  ASCII_MASK = Integer($ff80ff80);
var
  P, Top: PWord;
  X, T, V, U, Flags: NativeInt;

  {$ifdef CPUX86}
  Store: record
    Self: Pointer;
    S: PUTF16String;
  end;
  _S: PUTF16String;
  {$endif}
begin
  P := Pointer(Self.Current);
  PWord(S.FChars) := P;
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  {$ifdef CPUX86}
    Store.Self := Pointer(Self);
    Store.S := @S;
  {$endif}

  if (NativeInt(Flags) >= SizeOf(UnicodeChar)) then
  begin
    Flags := Flags shr 1;
    Top := @PWordArray(P)[Flags];
    Flags := 0;

    repeat
      Dec(Top, CHARS_IN_CARDINAL);
    next_cardinal:
      X := PCardinal(P)^;

      if (NativeUInt(P) <= NativeUInt(Top{Cardinal})) then
      begin
        Inc(P, CHARS_IN_CARDINAL);
        Flags := Flags or X;

        T := (X xor CR_XOR_MASK);
        U := (X xor LF_XOR_MASK);
        V := T + SUB_MASK;
        T := not T;
        T := T and V;
        V := U + SUB_MASK;
        U := not U;
        U := U and V;

        T := T or U;
        if (T and OVERFLOW_MASK = 0) then goto next_cardinal;
        Dec(P, CHARS_IN_CARDINAL);
        Inc(P, Byte(T and $8000 = 0));
        goto retrieve_top;
      end else
      begin
      retrieve_top:
        Inc(Top, CHARS_IN_CARDINAL);
        if (P = Top) then goto done;
      end;

      X := P^;
      Flags := Flags or X;
      Inc(P);
      if (X <> $0a) then
      begin
        if (X <> $0d) then
        begin
          if (P <> Top) then Continue;
        done:
          if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
          {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
          Inc(P);
        end else
        begin
          // #13
          if (P = Top) then
          begin
            if (not {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Finishing) then goto flush_recall;
            goto done_one;
          end else
          begin
            if (P^ <> $0a) then goto done_one;
            Inc(P);
            {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
            Dec(P);
          end;
        end;
      end else
      begin
        // #10
      done_one:
        {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.Current := Pointer(P);
      end;

      Dec(P);
      {$ifdef CPUX86}_S := Store.S;{$endif}
      {$ifdef CPUX86}_S{$else}S{$endif}.F.NativeFlags := Byte(Flags and ASCII_MASK = 0);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt({$ifdef CPUX86}_S{$else}S{$endif}.FChars);
      {$ifdef CPUX86}_S{$else}S{$endif}.Length := Flags{BytesCount} shr 1;
      Result := True;
      Exit;
    until (False);
  end else
  begin
    if ({$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := {$ifdef CPUX86}TSelf(Store.Self){$else}Self{$endif}.FlushReadln(
        {$ifdef CPUX86}Store.S^{$else}S{$endif});
    end;
  end;
end;


{ TUTF32TextReader }

constructor TUTF32TextReader.Create(const Source: TCachedReader;
  const DefaultByteEncoding: Word; const Owner: Boolean);
var
  BOM: TBOM;
  Context: PUniConvContext;
begin
  BOM := DetectBOM(Source);
  {Check}DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;

  if (BOM = bomUTF32) then
  begin
    Context := nil;
  end else
  begin
    if (BOM = bomNone) and (DefaultByteEncoding = CODEPAGE_UTF8) then
      BOM := bomUTF8;

    Context.Init(bomUTF32, BOM, DefaultByteEncoding);
  end;

  inherited Create(Context, Source, Owner);
end;

constructor TUTF32TextReader.CreateFromFile(const FileName: string;
  const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(TCachedFileReader.Create(FileName), DefaultByteEncoding, True);
end;

constructor TUTF32TextReader.CreateDirect(const Context: PUniConvContext;
  const Source: TCachedReader; const Owner: Boolean);
begin
  inherited Create(Context, Source, Owner);
end;

function TUTF32TextReader.FlushReadChar: UCS4Char;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.ReadChar;
end;

function TUTF32TextReader.ReadChar: UCS4Char;
var
  P: PCardinal;
  X: NativeUInt;
begin
  P := Pointer(Self.Current);

  X := P^;
  Inc(P);
  if (NativeUInt(P) <= NativeUInt(FOverflow)) then
  begin
    Self.Current := Pointer(P);
    Result := X;
    Exit;
  end else
  begin
    if (Self.EOF) then Result := 0
    else
    Result := FlushReadChar;
  end;
end;

function TUTF32TextReader.FlushReadln(var S: UTF32String): Boolean;
begin
  if (Self.Finishing) then Self.EOF := True
  else Self.Flush;

  Result := Self.Readln(S);
end;

function TUTF32TextReader.Readln(var S: UTF32String): Boolean;
label
  done_one, flush_recall;
var
  P, Top: PCardinal;
  X, Flags: NativeUInt;
begin
  P := Pointer(Self.Current);
  S.Chars := Pointer(P);
  Flags := NativeUInt(Self.Overflow);
  Dec(Flags, NativeUInt(P));

  if (NativeInt(Flags) >= SizeOf(UCS4Char)) then
  begin
    Flags := Flags shr 2;
    Top := @PCardinalArray(P)[Flags];
    Flags := 0;

    repeat
      X := P^;
      Inc(P);
      Flags := Flags or X;

      if (X <> $0a) then
      begin
        if (X <> $0d) then
        begin
          if (P <> Top) then Continue;
          if (not Self.Finishing) then goto flush_recall;
          Self.Current := Pointer(P);
          Inc(P);
        end else
        begin
          // #13
          if (P = Top) then
          begin
            if (not Self.Finishing) then goto flush_recall;
            goto done_one;
          end else
          begin
            if (P^ <> $0a) then goto done_one;
            Inc(P);
            Self.Current := Pointer(P);
            Dec(P);
          end;
        end;
      end else
      begin
        // #10
      done_one:
        Self.Current := Pointer(P);
      end;

      Dec(P);
      S.F.NativeFlags := Byte(Flags <= $7f);
      Flags{BytesCount} := NativeUInt(P) - NativeUInt(S.FChars);
      S.Length := Flags{BytesCount} shr 2;
      Result := True;
      Exit;
    until (False);
  end else
  begin
    if (Self.EOF) then
    begin
      Result := False;
    end else
    begin
    flush_recall:
      Result := FlushReadln(S);
    end;
  end;
end;


{ TCachedTextWriter }

constructor TCachedTextWriter.Create(const Context: PUniConvContext;
  const Target: TCachedWriter; const Owner: Boolean);
begin
  inherited Create;

  FTarget := Target;
  FOwner := Owner;
  if (Context <> nil) and
    (@PUniConvContextEx(Context).FConvertProc <> @TUniConvContextEx.convert_copy) then
  begin
    FConverter := TUniConvReWriter.Create(Context, Target);
    FWriter := FConverter;
  end else
  begin
    FWriter := Target;
  end;

  Current := FWriter.Current;
  FOverflow := FWriter.Overflow;
  FEOF := FWriter.EOF;
end;

destructor TCachedTextWriter.Destroy;
begin
  FWriter := nil;

  if (FConverter <> nil) then
  begin
    FOwner := FOwner or FConverter.Owner;
    FConverter.Owner := False;
    FConverter.Free;
  end;

  if (FOwner) then FTarget.Free;
  inherited;
end;

function TCachedTextWriter.GetMargin: NativeInt;
var
  P: NativeInt;
begin
  // Result := NativeInt(FOverflow) - NativeInt(Current);
  P := NativeInt(Current);
  Result := NativeInt(FOverflow);
  Dec(Result, P);
end;

function TCachedTextWriter.GetPosition: Int64;
begin
  Result := FWriter.Position;
end;

procedure TCachedTextWriter.SetEOF(const Value: Boolean);
begin
  if (Value) and (FEOF <> Value) then
  begin
    FWriter.EOF := True;

    Current := FWriter.Current;
    FOverflow := FWriter.Overflow;
    FEOF := FWriter.EOF;
  end;
end;

function TCachedTextWriter.Flush: NativeUInt;
begin
  Result := FWriter.Flush;

  Current := FWriter.Current;
  FOverflow := FWriter.Overflow;
  FEOF := FWriter.EOF;
end;

procedure TCachedTextWriter.OverflowWriteData(var Buffer; const Count: NativeUInt);
begin
  FWriter.Current := Current;
  FWriter.Write(Buffer, Count);

  Current := FWriter.Current;
  FOverflow := FWriter.Overflow;
  FEOF := FWriter.EOF;
end;

procedure TCachedTextWriter.WriteData(var Buffer; const Count: NativeUInt);
var
  P: PByte;
begin
  P := Current;
  Inc(P, Count);

  if (NativeUInt(P) > NativeUInt(Self.FOverflow)) then
  begin
    OverflowWriteData(Buffer, Count);
  end else
  begin
    Current := P;
    Dec(P, Count);
    NcMove(Buffer, P^, Count);
  end;
end;


{ TByteTextWriter }

constructor TByteTextWriter.Create(const Encoding: Word; const Target: TCachedWriter;
  const BOM: TBOM; const DefaultByteEncoding: Word; const Owner: Boolean);
var
  Context: PUniConvContext;
  DefaultSBCS: PUniConvSBCS;
  SrcBOM, DestBOM: TBOM;
begin
  Context := @FInternalContext;
  Target.Write(BOM_INFO[BOM].Data, BOM_INFO[BOM].Size);

  FSBCS := DetectSBCS(Encoding);
  DefaultSBCS := DetectSBCS(DefaultByteEncoding);
  if (FSBCS = nil) then
  begin
    FEncoding := CODEPAGE_UTF8;
    SrcBOM := bomUTF8;
  end else
  begin
    FEncoding := FSBCS.CodePage;
    SrcBOM := bomNone;
  end;
  DestBOM := BOM;
  if (DestBOM = bomNone) and (DefaultByteEncoding = CODEPAGE_UTF8) then DestBOM := bomUTF8;

  if (SrcBOM = DestBOM) then
  begin
    if (FSBCS = DefaultSBCS) then
    begin
      Context := nil;
    end else
    begin
      Context.InitSBCSFromSBCS(FSBCS.CodePage, DefaultSBCS.CodePage);
    end;
  end else
  if (SrcBOM = bomNone) then
  begin
    Context.Init(DestBOM, bomNone, Encoding);
  end else
  begin
    Context.Init(DestBOM, bomUTF8, DefaultByteEncoding);
  end;

  inherited Create(Context, Target, Owner);
end;

constructor TByteTextWriter.CreateFromFile(const Encoding: Word; const FileName: string;
  const BOM: TBOM; const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(Encoding, TCachedFileWriter.Create(FileName), BOM, DefaultByteEncoding, True);
end;

constructor TByteTextWriter.CreateDirect(const Context: PUniConvContext;
  const Target: TCachedWriter; const Owner: Boolean);
begin
  if (Context = nil) or (Context.SourceCodePage = CODEPAGE_UTF8) then
  begin
    FSBCS := nil;
    FEncoding := CODEPAGE_UTF8;
  end else
  begin
    FSBCS := DetectSBCS(Context.SourceCodePage);
    FEncoding := FSBCS.CodePage;
  end;

  inherited Create(Context, Target, Owner);
end;


{ TUTF16TextWriter }

constructor TUTF16TextWriter.Create(const Target: TCachedWriter;
  const BOM: TBOM; const DefaultByteEncoding: Word; const Owner: Boolean);
var
  Context: PUniConvContext;
begin
  {Check}DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;
  Target.Write(BOM_INFO[BOM].Data, BOM_INFO[BOM].Size);

  if (BOM = bomUTF16) then
  begin
    Context := nil;
  end else
  begin
    Context.Init(BOM, bomUTF16, DefaultByteEncoding);
  end;

  inherited Create(Context, Target, Owner);
end;

constructor TUTF16TextWriter.CreateFromFile(const FileName: string;
  const BOM: TBOM; const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(TCachedFileWriter.Create(FileName), BOM, DefaultByteEncoding, True);
end;

constructor TUTF16TextWriter.CreateDirect(const Context: PUniConvContext;
  const Target: TCachedWriter; const Owner: Boolean);
begin
  inherited Create(Context, Target, Owner);
end;


{ TUTF32TextWriter }

constructor TUTF32TextWriter.Create(const Target: TCachedWriter;
  const BOM: TBOM; const DefaultByteEncoding: Word; const Owner: Boolean);
var
  Context: PUniConvContext;
begin
  {Check}DetectSBCS(DefaultByteEncoding);
  Context := @FInternalContext;
  Target.Write(BOM_INFO[BOM].Data, BOM_INFO[BOM].Size);

  if (BOM = bomUTF32) then
  begin
    Context := nil;
  end else
  begin
    Context.Init(BOM, bomUTF32, DefaultByteEncoding);
  end;

  inherited Create(Context, Target, Owner);
end;

constructor TUTF32TextWriter.CreateFromFile(const FileName: string;
  const BOM: TBOM; const DefaultByteEncoding: Word);
begin
  FFileName := FileName;
  Create(TCachedFileWriter.Create(FileName), BOM, DefaultByteEncoding, True);
end;

constructor TUTF32TextWriter.CreateDirect(const Context: PUniConvContext;
  const Target: TCachedWriter; const Owner: Boolean);
begin
  inherited Create(Context, Target, Owner);
end;


initialization
  InternalLookupsInitialize;

end.