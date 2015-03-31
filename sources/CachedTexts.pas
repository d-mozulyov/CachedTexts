unit CachedTexts;

{******************************************************************************}
{ Copyright (c) 2014-2015 Dmitry Mozulyov                                      }
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
  {$mode Delphi}
  {$asmmode Intel}
{$endif}
{$if CompilerVersion >= 24}
  {$LEGACYIFEND ON}
{$ifend}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$if CompilerVersion >= 15}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
{$ifend}
{$O+}{$R-}{$I-}{$Q-}{$W-}
{$if (CompilerVersion < 23) and (not Defined(FPC))}
  {$define CPUX86}
{$ifend}
{$if (Defined(FPC)) or (CompilerVersion >= 17)}
  {$define INLINESUPPORT}
{$ifend}
{$if Defined(CPUX86) or Defined(CPUX64)}
   {$define CPUINTEL}
{$ifend}
{$if SizeOf(Pointer) = 8}
  {$define LARGEINT}
{$else}
  {$define SMALLINT}
{$ifend}
{$if CompilerVersion >= 21}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$ifend}
{$if (not Defined(FPC)) and (not Defined(NEXTGEN)) and (CompilerVersion >= 20)}
  {$define INTERNALCODEPAGE}
{$ifend}
{$ifdef KOL_MCK}
  {$define KOL}
{$endif}

 // {$define KOL}
//{$undef INLINESUPPORT}

interface
  uses //Windows{!!!},// ClipBrd{!!!}, //SysUtilsEx
       Types, SysConst, CachedBuffers, UniConv,
       {$ifdef KOL}
         KOL, err
       {$else}
         SysUtils
       {$endif};

type
  // standard types
  {$if CompilerVersion < 19}
  NativeInt = Integer;
  PNativeInt = PInteger;
  NativeUInt = Cardinal;
  PNativeUInt = PCardinal;
  {$ifend}
  {$if (not Defined(FPC)) and (CompilerVersion < 15)}
  UInt64 = Int64;
  PUInt64 = ^UInt64;
  {$ifend}
  {$if CompilerVersion < 23}
  TExtended80Rec = Extended;
  PExtended80Rec = ^TExtended80Rec;
  {$ifend}
  TBytes = array of Byte;

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
  TCachedBufferMemory = CachedBuffers.TCachedBufferMemory;
  PCachedBufferMemory = CachedBuffers.PCachedBufferMemory;
  TCachedBuffer = CachedBuffers.TCachedBuffer;
  TCachedReader = CachedBuffers.TCachedReader;
  TCachedReaderCallback = CachedBuffers.TCachedReaderCallback;
  TCachedWriter = CachedBuffers.TCachedWriter;
  TCachedWriterCallback = CachedBuffers.TCachedWriterCallback;
  TCachedReReader = CachedBuffers.TCachedReReader;
  TCachedReReaderCallback = CachedBuffers.TCachedReReaderCallback;
  TCachedReWriter = CachedBuffers.TCachedReWriter;
  TCachedReWriterCallback = CachedBuffers.TCachedReWriterCallback;
  TCachedFileReader = CachedBuffers.TCachedFileReader;
  TCachedFileWriter = CachedBuffers.TCachedFileWriter;
  TCachedMemoryReader = CachedBuffers.TCachedMemoryReader;
  TCachedMemoryWriter = CachedBuffers.TCachedMemoryWriter;
  {$ifdef MSWINDOWS}
  TCachedResourceReader = CachedBuffers.TCachedResourceReader;
  {$endif}

  // UniConv types
  TUnicodeChar = UniConv.TUnicodeChar;
  PUnicodeChar = UniConv.PUnicodeChar;
  TUnicodeString = UniConv.TUnicodeString;
  PUnicodeString = UniConv.PUnicodeString;
  TBOM = UniConv.TBOM;
  PBOM = UniConv.PBOM;
  TUniConvUnicode = UniConv.TUniConvUnicode;
  PUniConvUnicode = UniConv.PUniConvUnicode;
  TUniConvSgml = UniConv.TUniConvSgml;
  PUniConvSgml = UniConv.PUniConvSgml;
  TUniConvEncoding = UniConv.TUniConvEncoding;
  PUniConvEncoding = UniConv.PUniConvEncoding;
  TUniConvContext = UniConv.TUniConvContext;
  PUniConvContext = UniConv.PUniConvContext;
  PUniConvContextProc = UniConv.PUniConvContextProc;
  UTF8Char = UniConv.UTF8Char;
  PUTF8Char = UniConv.PUTF8Char;
  {$ifdef NEXTGEN}
  AnsiChar = UniConv.AnsiChar;
  PAnsiChar = UniConv.PAnsiChar;
  AnsiString = UniConv.AnsiString;
  PAnsiString = UniConv.PAnsiString;
  UTF8String = UniConv.UTF8String;
  PUTF8String = UniConv.PUTF8String;
  WideString = UniConv.WideString;
  PWideString = UniConv.PWideString;
  ShortString = UniConv.ShortString;
  PShortString = UniConv.PShortString;
  {$endif}

var
  CODEPAGE_DEFAULT: Word; // = UniConv.CODEPAGE_DEFAULT;
  default_lookup_sbcs: PUniConvSBCSLookup; // = UniConv.default_lookup_sbcs;
  default_lookup_sbcs_index: Integer; // = UniConv.default_lookup_sbcs_index;


type
  PCachedString = ^TCachedString;
  PCachedByteString = ^TCachedByteString;
  PCachedUTF16String = ^TCachedUTF16String;
  PCachedUTF32String = ^TCachedUTF32String;

  ECachedString = class({$ifdef KOL}Exception{$else}EConvertError{$endif})
  public
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedByteString); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedUTF16String); overload;
    constructor Create(const ResStringRec: PResStringRec; const Value: PCachedUTF32String); overload;
  end;


  //
  TCachedString = object
  protected
    FLength: NativeUInt;
    F: packed record
    case Integer of
      0: (Flags: Cardinal);
      1: (D0, D1, D2, D3: Byte);
      2: (B0, B1, B2, B3: Boolean);
      3: (NativeFlags: NativeUInt);
    end;
    function GetEmpty: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetEmpty(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
  public
    property Length: NativeUInt read FLength write FLength;
    property Empty: Boolean read GetEmpty write SetEmpty;
    property Ascii: Boolean read F.B0 write F.B0;
    property Flags: Cardinal read F.Flags write F.Flags;
  end;

  //
  TCachedByteString = object(TCachedString)
  protected
    FChars: PAnsiChar;

    function GetLookup: PUniConvSBCSLookup; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetLookup(Value: PUniConvSBCSLookup); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure SetUTF8(Value: Boolean); {$ifdef INLINESUPPORT}inline;{$endif}
    function GetCodePage: Word; {$ifdef INLINESUPPORT}inline;{$endif}
    procedure _SetCodePage(Value: Word);
    procedure SetCodePage(Value: Word);

    function GetAnsiString: AnsiString; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetWideString: WideString; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; inline;
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
    property Chars: PAnsiChar read FChars write FChars;
    property LookupIndex: Byte read F.D3 write F.D3;
    property Lookup: PUniConvSBCSLookup read GetLookup write SetLookup;
    property UTF8: Boolean read GetUTF8 write SetUTF8;
    property CodePage: Word read GetCodePage write SetCodePage;
  public
    { basic methods }

    procedure Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP: Word = 0{$endif}); overload;
    procedure Assign(const S: ShortString; const CP: Word = 0); overload;
    procedure Assign(const S: TBytes; const CP: Word = 0); overload;
    function DetectAscii: Boolean;

    function LTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function RTrim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Trim: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const From, Count: NativeUInt): TCachedByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): TCachedByteString; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifNdef CPUINTEL}inline;{$endif}

    function CharPos(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToWideString(var S: WideString);
    procedure ToUnicodeString(var S: TUnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsUnicodeString: TUnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
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
  TCachedUTF16String = object(TCachedString)
  protected
    FChars: PUnicodeChar;

    function GetAnsiString: AnsiString; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetWideString: WideString; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; inline;
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
    function SubString(const From, Count: NativeUInt): TCachedUTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): TCachedUTF16String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToWideString(var S: WideString);
    procedure ToUnicodeString(var S: TUnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsUnicodeString: TUnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
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
  TCachedUTF32String = object(TCachedString)
  protected
    FChars: PUCS4Char;

    function GetAnsiString: AnsiString; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetUTF8String: UTF8String; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetWideString: WideString; {$ifdef INLINESUPPORT}inline;{$endif}
    {$ifdef UNICODE}
    function GetUnicodeString: UnicodeString; inline;
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
    property Chars: PUCS4Char read FChars write FChars;
  public
    { basic methods }

    procedure Assign(const S: UCS4String; const NullTerminated: Boolean = True); {$ifdef INLINESUPPORT}inline;{$endif}
    function DetectAscii: Boolean;

    function LTrim: Boolean;
    function RTrim: Boolean;
    function Trim: Boolean;
    function SubString(const From, Count: NativeUInt): TCachedUTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function SubString(const Count: NativeUInt): TCachedUTF32String; overload; {$ifdef INLINESUPPORT}inline;{$endif}
    function Offset(const Count: NativeUInt): Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
    function Hash: Cardinal;
    function HashIgnoreCase: Cardinal; {$ifdef INLINESUPPORT}inline;{$endif}

    function CharPos(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPos(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt = 0): NativeInt; overload;
    function CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt = 0): NativeInt; overload;

    function Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt = 0): NativeInt; overload;
    function Pos(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt; overload;
    function PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt = 0): NativeInt;
  public
    { compares }

    // todo
  public
    { string types conversion }
    { note: To... methods is much faster than As... properties !!! }

    procedure ToAnsiString(var S: AnsiString; const CP: Word = 0);
    procedure ToUTF8String(var S: UTF8String);
    procedure ToWideString(var S: WideString);
    procedure ToUnicodeString(var S: TUnicodeString);
    procedure ToString(var S: string); {$ifdef INLINESUPPORT}inline;{$endif}

    property AsAnsiString: AnsiString read GetAnsiString;
    property AsUTF8String: UTF8String read GetUTF8String;
    property AsWideString: WideString read GetWideString;
    property AsUnicodeString: TUnicodeString read {$ifdef UNICODE}GetUnicodeString{$else}GetWideString{$endif};
    property AsString: string read {$ifdef UNICODE}GetUnicodeString{$else}GetAnsiString{$endif};
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
    function InternalCallback(Sender: TCachedReReader; Buffer: PByte; BufferSize: NativeUInt; Source: TCachedReader): NativeUInt;
    function GetEOF: Boolean; {$ifdef INLINESUPPORT}inline;{$endif}
  protected
    FContext: TUniConvContext;

    function GetIsDirect: Boolean; override;
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
    FLookup: PUniConvSBCSLookup;
    FNativeFlags: NativeUInt;
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: TCachedByteString): Boolean;

    // single byte char set encodings lookup
    // nil in UTF8 encoding case
    property Lookup: PUniConvSBCSLookup read FLookup;
  end;

 (* TCachedByteTextWriter = class(TCachedTextWriter)
  private
  protected
    FLookup: PUniConvSBCSLookup;
  public

    // single byte char set encodings lookup
    // nil in UTF8 encoding case
    property Lookup: PUniConvSBCSLookup read FLookup;
  end;
*)



  TCachedUTF16TextReader = class(TCachedTextReader)
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: TCachedUTF16String): Boolean;
  end;


(*  TCachedUTF16TextWriter = class(TCachedTextWriter)


  end;  *)


  TCachedUTF32TextReader = class(TCachedTextReader)
  public
    constructor Create(const Source: TCachedReader; const IsOwner: Boolean = False; const DefaultBOM: TBOM = bomNone);
    function Readln(var S: TCachedUTF32String): Boolean;
  end;

(*  TCachedUTF32TextWriter = class(TCachedTextWriter)


  end;

//type

const
  STRING_ID_NONE = 0;

  PARSE_OK = 0;
  PARSE_CANCELED = 1;

type
  TCachedParser = class;
  ECachedParserStop = class(Exception);

  TCachedParser = class(TObject)
  protected
    FParseResult: Integer;
    FParseMessage: TUnicodeString;
//    FLine: PNativeUInt;
//    FStoredLineValue: NativeUInt;

    procedure DoParse(const Reader: TCachedReader); virtual;
//    function GetLine: NativeUInt; {$ifdef INLINESUPPORT}inline;{$endif}
  {$ifNdef AUTOREFCOUNT}
  public
  {$endif}
    destructor Destroy; override;
  public
    procedure Cleanup; virtual;

    function Parse(const Reader: TCachedReader): Integer; overload;
    function Parse(const FileName: string): Integer; overload;
    function Parse(const Ptr: Pointer; const Size: NativeUInt): Integer; overload;
    procedure Stop(const ParseResult: Integer; const ParseMessage: TUnicodeString = '');

//    property Line: NativeUInt read GetLine;
    property ParseResult: Integer read FParseResult;
    property ParseMessage: TUnicodeString read FParseMessage;
  end;

 // TCachedXMLParser = class;

const
  PARSE_XML_DOCUMENT = 2{todo};

type
  TCachedXMLParser = class;

  PCachedXMLElement = ^TCachedXMLElement;
  TCachedXMLElement = object
  protected
    FData: Pointer;
    FLine: NativeUInt;
    FName: TCachedByteString;
    FUserData: Pointer;

    function GetLevel: NativeUInt; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetParent: PCachedXMLElement; {$ifdef INLINESUPPORT}inline;{$endif}
    function GetPath: TUnicodeString;
  public
    property Line: NativeUInt read FLine;
    property Name: TCachedByteString read FName;
    property UserData: Pointer read FUserData write FUserData;
    property Level: NativeUInt read GetLevel;
    property Parent: PCachedXMLElement read GetParent;
    property Path: TUnicodeString read GetPath;
  end;

  PCachedXMLAttribute = ^TCachedXMLAttribute;
  TCachedXMLAttribute = object
  protected
    FElement: PCachedXMLElement;
    FName: TCachedByteString;
    FValue: TCachedByteString;
  public
    property Element: PCachedXMLElement read FElement;
    property Name: TCachedByteString read FName;
    property Value: TCachedByteString read FValue;
  end;

  TCachedXMLParser = class(TCachedParser)
  private
    FLookup: PUniConvSBCSLookup;
  //  FData: Pointer;

  protected
    FNamesStorage: TBytes;
    FNamesStorageSize: NativeUInt;
    FNamesStoragePosition: NativeUInt;

//    function StoreName(var Name: TCachedByteString): NativeInt;

//    procedure DoParse(const Reader: TCachedReader); override;

    // OnStartDocument
    // OnEndDocument

    procedure OnComment(const Parent: TCachedXMLElement; const Value: TCachedByteString); virtual;
    procedure OnElement(const Element: TCachedXMLElement); virtual;
    procedure OnAttribute(const Attribute: TCachedXMLAttribute); virtual;
    // ProcessInstruction
    // DOCTYPE
    // ENTITY???
    procedure OnElementValue(const Element: TCachedXMLElement; const Value: TCachedByteString); virtual;
    procedure OnElementFinish(const Element: TCachedXMLElement); virtual;

  public
//    procedure Cleanup; override;

    // single byte char set encodings lookup
    // nil in UTF8 encoding case
    property Lookup: PUniConvSBCSLookup read FLookup;
  end;

  TCachedXMLWriter = class(TCachedWriter)

  end;

  TCachedHTMLParser = class(TObject)

  end;

  TCachedHTMLWriter = class(TCachedWriter)

  end;

  TCachedJSONParser = class(TObject)

  end;

  TCachedJSONWriter = class(TCachedWriter)

  end;

     *)


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
    Buffer: PKOLChar;
    BufSize: Integer;
    nChars: Integer;
  end;

function EnumStringModules(Instance: NativeInt; Data: Pointer): Boolean;
begin
  with PStrData(Data)^ do
  begin
    nChars := LoadString(Instance, Ident, Buffer, BufSize);
    Result := nChars = 0;
  end;
end;

function FindStringResource(Ident: Integer; Buffer: PKOLChar; BufSize: Integer): Integer;
var
  StrData: TStrData;
begin
  StrData.Ident := Ident;
  StrData.Buffer := Buffer;
  StrData.BufSize := BufSize;
  StrData.nChars := 0;
  EnumResourceModules(EnumStringModules, @StrData);
  Result := StrData.nChars;
end;

function LoadStr(Ident: Integer): string;
var
  Buffer: array[0..1023] of KOLChar;
begin
  SetString(Result, Buffer, FindStringResource(Ident, Buffer, SizeOf(Buffer)));
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
    {$define MANY_REGS}
  {$else}
    {$undef MANY_REGS}
  {$endif}

  {$if Defined(MSWINDOWS) or Defined(FPC) or (CompilerVersion < 22)}
    {$define WIDE_STR_SHIFT}
  {$else}
    {$undef WIDE_STR_SHIFT}
  {$ifend}

type
  PAnsiWideLength = ^TAnsiWideLength;
  {$ifdef NEXTGEN}
  TAnsiWideLength = NativeInt;
  {$else}
  TAnsiWideLength = Integer;
  {$endif}

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

  PUniConvSBCSLookupEx = ^TUniConvSBCSLookupEx;
  TUniConvSBCSLookupEx = object(TUniConvSBCSLookup) end;

  PUniConvContextEx = ^TUniConvContextEx;
  TUniConvContextEx = object(TUniConvContext) end;

var
  uniconv_lookup_utf8_size: TUniConvB_B;

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
  Buffer: TCachedByteString;
begin
  Buffer := Value^;
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
  Buffer: TCachedUTF16String;
begin
  Buffer := Value^;
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
  Buffer: TCachedUTF32String;
begin
  Buffer := Value^;
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


{ TCachedString }

function TCachedString.GetEmpty: Boolean;
begin
  Result := (Length <> 0);
end;

procedure TCachedString.SetEmpty(Value: Boolean);
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


{ TCachedByteString }

function TCachedByteString.GetLookup: PUniConvSBCSLookup;
var
  Index: NativeInt;
begin
  Index := LookupIndex;

  if (Index = 0) then Result := Pointer(Index){nil}
  else
  {$ifdef CPUX86}
    Result := Pointer(@PAnsiChar(@uniconv_lookup_sbcs)[(Index-1)*SizeOf(TUniConvSBCSLookup)]);
  {$else}
    Result := @uniconv_lookup_sbcs[Index];
  {$endif}
end;

procedure TCachedByteString.SetLookup(Value: PUniConvSBCSLookup);
begin
  if (Value = nil) then LookupIndex := 0
  else LookupIndex := Value.Index;
end;

function TCachedByteString.GetUTF8: Boolean;
begin
  Result := (LookupIndex = 0);
end;

procedure TCachedByteString.SetUTF8(Value: Boolean);
begin
  if (Value) then LookupIndex := 0
  else LookupIndex := default_lookup_sbcs_index;
end;

function TCachedByteString.GetCodePage: Word;
var
  Index: NativeInt;
begin
  Index := LookupIndex;

  if (Index = 0) then Result := CODEPAGE_UTF8
  else
  {$ifdef CPUX86}
    Result := PUniConvSBCSLookup(@PAnsiChar(@uniconv_lookup_sbcs)[(Index-1)*SizeOf(TUniConvSBCSLookup)]).CodePage;
  {$else}
    Result := uniconv_lookup_sbcs[Index].CodePage;
  {$endif}
end;

procedure TCachedByteString._SetCodePage(Value: Word);
var
  SBCSLookup: PUniConvSBCSLookup;
begin
  SBCSLookup := UniConvSBCSLookup(Value);
  if (SBCSLookup = nil) then
  begin
    LookupIndex := 1;
  end else
  begin
    LookupIndex := SBCSLookup.Index;
  end;
end;

procedure TCachedByteString.SetCodePage(Value: Word);
 {$ifdef INLINESUPPORT}
begin
  if (Value = 0) or (Value = CODEPAGE_DEFAULT) then
  begin
    LookupIndex := default_lookup_sbcs_index;
  end else
  if (Value = CODEPAGE_UTF8) then
  begin
    LookupIndex := 0;
  end else
  begin
    _SetCodePage(Value);
  end;
end;
{$else .CPUX86}
asm
  test dx, dx
  je @fill_default
  cmp dx, CODEPAGE_DEFAULT
  je @fill_default
  cmp dx, CODEPAGE_UTF8
  je @fill_utf8

  jmp _SetCodePage
@fill_utf8:
  mov [EAX].TCachedByteString.F.D3, 0
  ret
@fill_default:
  mov edx, default_lookup_sbcs_index
  mov [EAX].TCachedByteString.F.D3, dl
end;
{$endif}

procedure TCachedByteString.ToAnsiString(var S: AnsiString; const CP: Word);
begin
  // todo
end;

procedure TCachedByteString.ToUTF8String(var S: UTF8String);
begin
  // todo
end;

procedure TCachedByteString.ToWideString(var S: WideString);
begin
  // todo
end;

procedure TCachedByteString.ToUnicodeString(var S: TUnicodeString);
{$ifdef UNICODE}
begin
  // todo
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure TCachedByteString.ToString(var S: string);
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.GetAnsiString: AnsiString;
{$ifdef INLINESUPPORT}
begin
  ToAnsiString(Result);
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$endif}

function TCachedByteString.GetUTF8String: UTF8String;
{$ifdef INLINESUPPORT}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86}
asm
  jmp ToUTF8String
end;
{$endif}

function TCachedByteString.GetWideString: WideString;
{$ifdef INLINESUPPORT}
begin
  ToWideString(Result);
end;
{$else .CPUX86}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
function TCachedByteString.GetUnicodeString: UnicodeString;
begin
  ToUnicodeString(Result);
end;
{$endif}

procedure TCachedByteString.Assign(const S: AnsiString{$ifNdef INTERNALCODEPAGE}; const CP: Word{$endif});
var
  P: PAnsiWideLength;
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
      Self.Flags := default_lookup_sbcs_index shl 24
    end else
    begin
      Self.Flags := 0;
      if (CP <> CODEPAGE_UTF8) then _SetCodePage(CP);
    end;
  end;
end;

procedure TCachedByteString.Assign(const S: ShortString; const CP: Word);
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
      Self.Flags := default_lookup_sbcs_index shl 24
    end else
    begin
      Self.Flags := 0;
      if (CP <> CODEPAGE_UTF8) then _SetCodePage(CP);
    end;
  end;
end;

procedure TCachedByteString.Assign(const S: TBytes; const CP: Word);
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
      Self.Flags := default_lookup_sbcs_index shl 24
    end else
    begin
      Self.Flags := 0;
      if (CP <> CODEPAGE_UTF8) then _SetCodePage(CP);
    end;
  end;
end;

function TCachedByteString.DetectAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Byte);  
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Byte);  
var
  P: PByte;
  L: NativeUInt;
  {$ifdef MANY_REGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($7f7f7f7f);
  {$endif}  
begin
  P := Pointer(FChars);
  L := FLength;
  
  {$ifdef MANY_REGS}
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

function TCachedByteString.LTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._LTrim(S: PByte; L: NativeUInt): Boolean;
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

function TCachedByteString.RTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._RTrim(S: PByte; H: NativeUInt): Boolean;
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

function TCachedByteString.Trim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._Trim(S: PByte; H: NativeUInt): Boolean;
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

function TCachedByteString.SubString(const From, Count: NativeUInt): TCachedByteString;
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

function TCachedByteString.SubString(const Count: NativeUInt): TCachedByteString;
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

function TCachedByteString.Offset(const Count: NativeUInt): Boolean;
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

function TCachedByteString.Hash: Cardinal;
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

function TCachedByteString.HashIgnoreCase: Cardinal;
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

function TCachedByteString._HashIgnoreCaseAscii: Cardinal;
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

function TCachedByteString._HashIgnoreCaseUTF8: Cardinal;
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
  uniconv_lookup_ucs2_lower: PUniConvW_W;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  uniconv_lookup_ucs2_lower := @UniConv.uniconv_lookup_ucs2_lower;
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
      case uniconv_lookup_utf8_size[Byte(X)] of
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
             X := uniconv_lookup_ucs2_lower[X];
           end;
        3: begin
             // X := ((X & 0x0f) << 12) | ((X & 0x3f00) >> 2) | ((X >> 16) & 0x3f);
             V := (X and $0F) shl 12;
             V := V + (X shr 16) and $3F;
             X := (X and $3F00) shr 2;
             Inc(L);
             Inc(X, V);
             Dec(P);
             X := uniconv_lookup_ucs2_lower[X];
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


function TCachedByteString._HashIgnoreCase(NF: NativeUInt): Cardinal;
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
  SBCSLookup: PUniConvSBCSLookupEx;
  Lower: PUniConvW_B;
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
    SBCSLookup := Pointer(@uniconv_lookup_sbcs);
    Inc(SBCSLookup, NF-1);
  {$else}
    SBCSLookup := Pointer(@uniconv_lookup_sbcs[NF]);
  {$endif}
  // Lower := inline SBCSLookup.GetLowerCaseUCS2;
  Lower := SBCSLookup.FLowerCaseUCS2;
  if (Lower = nil) then Lower := SBCSLookup.FillUCS2(uccLower, SBCSLookup.FLowerCaseUCS2);

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

function TCachedByteString.CharPos(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.Pos(const AChars: PAnsiChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.Pos(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedByteString.TryAsBoolean(out Value: Boolean): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedByteString(@Default)._GetBool(Pointer(Chars), Length);
end;

function TCachedByteString.GetBoolean: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._GetBool(S: PByte; L: NativeUInt): Boolean;
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
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidBoolean), @Buffer);
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

function TCachedByteString.TryAsHex(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedByteString(@Default)._GetHex(Pointer(Chars), Length);
end;

function TCachedByteString.GetHex: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._GetHex(S: PByte; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: TCachedByteString;
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

function TCachedByteString.TryAsCardinal(out Value: Cardinal): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedByteString(@Default)._GetInt(Pointer(Chars), Length);
end;

function TCachedByteString.GetCardinal: Cardinal;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.TryAsInteger(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedByteString(@Default)._GetInt(Pointer(Chars), -Length);
end;

function TCachedByteString.GetInteger: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._GetInt(S: PByte; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedByteString.TryAsHex64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsHex64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.GetHex64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._GetHex64(S: PByte; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: TCachedByteString;
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

function TCachedByteString.TryAsUInt64(out Value: UInt64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsUInt64Def(const Default: UInt64): UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.GetUInt64: UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.TryAsInt64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.AsInt64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString.GetInt64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedByteString._GetInt64(S: PByte; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedByteString._GetInt_19(S: PByte; L: NativeUInt): NativeInt;
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

function TCachedByteString.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedByteString.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedByteString.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedByteString(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function TCachedByteString.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedByteString(@Default)._GetFloat(Pointer(Chars), Length);
end;

function TCachedByteString.GetFloat: Extended;
begin
  Result := PCachedByteString(0)._GetFloat(Pointer(Chars), Length);
end;

function TCachedByteString._GetFloat(S: PByte; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidFloat), @Buffer);
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

function TCachedByteString.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function TCachedByteString.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDate), @Self);
end;

function TCachedByteString.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedByteString.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function TCachedByteString.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidTime), @Self);
end;

function TCachedByteString.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedByteString.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function TCachedByteString.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDateTime), @Self);
end;

function TCachedByteString.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedByteString._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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


{ TCachedUTF16String }

procedure TCachedUTF16String.ToAnsiString(var S: AnsiString; const CP: Word);
begin
  // todo
end;

procedure TCachedUTF16String.ToUTF8String(var S: UTF8String);
begin
  // todo
end;

procedure TCachedUTF16String.ToWideString(var S: WideString);
begin
  // todo
end;

procedure TCachedUTF16String.ToUnicodeString(var S: TUnicodeString);
{$ifdef UNICODE}
begin
  // todo
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure TCachedUTF16String.ToString(var S: string);
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.GetAnsiString: AnsiString;
{$ifdef INLINESUPPORT}
begin
  ToAnsiString(Result);
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$endif}

function TCachedUTF16String.GetUTF8String: UTF8String;
{$ifdef INLINESUPPORT}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86}
asm
  jmp ToUTF8String
end;
{$endif}

function TCachedUTF16String.GetWideString: WideString;
{$ifdef INLINESUPPORT}
begin
  ToWideString(Result);
end;
{$else .CPUX86}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
function TCachedUTF16String.GetUnicodeString: UnicodeString;
begin
  ToUnicodeString(Result);
end;
{$endif}

procedure TCachedUTF16String.Assign(const S: WideString);
var
  P: PAnsiWideLength;
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
procedure TCachedUTF16String.Assign(const S: UnicodeString);
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

function TCachedUTF16String.DetectAscii: Boolean;
label
  fail;
const
  CHARS_IN_NATIVE = SizeOf(NativeUInt) div SizeOf(Word);  
  CHARS_IN_CARDINAL = SizeOf(Cardinal) div SizeOf(Word);  
var
  P: PWord;
  L: NativeUInt;
  {$ifdef MANY_REGS}
  MASK: NativeUInt;
  {$else}
const
  MASK = not NativeUInt($007f007f);
  {$endif}  
begin
  P := Pointer(FChars);
  L := FLength;
         
  {$ifdef MANY_REGS}
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

function TCachedUTF16String.LTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._LTrim(S: PWord; L: NativeUInt): Boolean;
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

function TCachedUTF16String.RTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._RTrim(S: PWord; H: NativeUInt): Boolean;
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

function TCachedUTF16String.Trim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._Trim(S: PWord; H: NativeUInt): Boolean;
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

function TCachedUTF16String.SubString(const From, Count: NativeUInt): TCachedUTF16String;
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

function TCachedUTF16String.SubString(const Count: NativeUInt): TCachedUTF16String;
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

function TCachedUTF16String.Offset(const Count: NativeUInt): Boolean;
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

function TCachedUTF16String.Hash: Cardinal;
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

function TCachedUTF16String.HashIgnoreCase: Cardinal;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._HashIgnoreCaseAscii: Cardinal;
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

function TCachedUTF16String._HashIgnoreCase: Cardinal;
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
  uniconv_lookup_ucs2_lower: PUniConvW_W;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  uniconv_lookup_ucs2_lower := @UniConv.uniconv_lookup_ucs2_lower;
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

        X := uniconv_lookup_ucs2_lower[X];
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
      X := uniconv_lookup_ucs2_lower[X];
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

function TCachedUTF16String.CharPos(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.Pos(const AChars: PUnicodeChar; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.Pos(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF16String.TryAsBoolean(out Value: Boolean): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedUTF16String(@Default)._GetBool(Pointer(Chars), Length);
end;

function TCachedUTF16String.GetBoolean: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._GetBool(S: PWord; L: NativeUInt): Boolean;
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
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidBoolean), @Buffer);
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

function TCachedUTF16String.TryAsHex(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF16String(@Default)._GetHex(Pointer(Chars), Length);
end;

function TCachedUTF16String.GetHex: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._GetHex(S: PWord; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: TCachedUTF16String;
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

function TCachedUTF16String.TryAsCardinal(out Value: Cardinal): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedUTF16String(@Default)._GetInt(Pointer(Chars), Length);
end;

function TCachedUTF16String.GetCardinal: Cardinal;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.TryAsInteger(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF16String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function TCachedUTF16String.GetInteger: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._GetInt(S: PWord; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedUTF16String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedUTF16String.TryAsHex64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsHex64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.GetHex64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._GetHex64(S: PWord; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: TCachedUTF16String;
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

function TCachedUTF16String.TryAsUInt64(out Value: UInt64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsUInt64Def(const Default: UInt64): UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.GetUInt64: UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.TryAsInt64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.AsInt64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String.GetInt64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF16String._GetInt64(S: PWord; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedUTF16String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedUTF16String._GetInt_19(S: PWord; L: NativeUInt): NativeInt;
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

function TCachedUTF16String.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF16String.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF16String.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedUTF16String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function TCachedUTF16String.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedUTF16String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF16String.GetFloat: Extended;
begin
  Result := PCachedUTF16String(0)._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF16String._GetFloat(S: PWord; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: TCachedUTF16String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidFloat), @Buffer);
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

function TCachedUTF16String.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function TCachedUTF16String.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDate), @Self);
end;

function TCachedUTF16String.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF16String.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    Result := Default;
end;

function TCachedUTF16String.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 2{Time})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidTime), @Self);
end;

function TCachedUTF16String.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF16String.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function TCachedUTF16String.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDateTime), @Self);
end;

function TCachedUTF16String.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF16String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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


{ TCachedUTF32String }

procedure TCachedUTF32String.ToAnsiString(var S: AnsiString; const CP: Word);
begin
  // todo
end;

procedure TCachedUTF32String.ToUTF8String(var S: UTF8String);
begin
  // todo
end;

procedure TCachedUTF32String.ToWideString(var S: WideString);
begin
  // todo
end;

procedure TCachedUTF32String.ToUnicodeString(var S: TUnicodeString);
{$ifdef UNICODE}
begin
  // todo
end;
{$else .NONUNICODE_CPUX86}
asm
  jmp ToWideString
end;
{$endif}

procedure TCachedUTF32String.ToString(var S: string);
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.GetAnsiString: AnsiString;
{$ifdef INLINESUPPORT}
begin
  ToAnsiString(Result);
end;
{$else .NONUNICODE_CPUX86}
asm
  xor ecx, ecx
  jmp ToAnsiString
end;
{$endif}

function TCachedUTF32String.GetUTF8String: UTF8String;
{$ifdef INLINESUPPORT}
begin
  ToUTF8String(Result);
end;
{$else .CPUX86}
asm
  jmp ToUTF8String
end;
{$endif}

function TCachedUTF32String.GetWideString: WideString;
{$ifdef INLINESUPPORT}
begin
  ToWideString(Result);
end;
{$else .CPUX86}
asm
  jmp ToWideString
end;
{$endif}

{$ifdef UNICODE}
function TCachedUTF32String.GetUnicodeString: UnicodeString;
begin
  ToUnicodeString(Result);
end;
{$endif}

procedure TCachedUTF32String.Assign(const S: UCS4String; const NullTerminated: Boolean);
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

function TCachedUTF32String.DetectAscii: Boolean;
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

function TCachedUTF32String.LTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._LTrim(S: PCardinal; L: NativeUInt): Boolean;
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

function TCachedUTF32String.RTrim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._RTrim(S: PCardinal; H: NativeUInt): Boolean;
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

function TCachedUTF32String.Trim: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._Trim(S: PCardinal; H: NativeUInt): Boolean;
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

function TCachedUTF32String.SubString(const From, Count: NativeUInt): TCachedUTF32String;
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

function TCachedUTF32String.SubString(const Count: NativeUInt): TCachedUTF32String;
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

function TCachedUTF32String.Offset(const Count: NativeUInt): Boolean;
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

function TCachedUTF32String.Hash: Cardinal;
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

function TCachedUTF32String.HashIgnoreCase: Cardinal;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._HashIgnoreCaseAscii: Cardinal;
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

function TCachedUTF32String._HashIgnoreCase: Cardinal;
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
  uniconv_lookup_ucs2_lower: PUniConvW_W;
begin
  L := FLength;
  P := Pointer(FChars);

  Result := L;
  if (L = 0) then Exit;

  V := L shl (32-9);
  if (L > 255) then V := NativeInt(V) or (1 shl 31);
  {$ifdef CPUX86}S.{$endif}L_High := V;

  uniconv_lookup_ucs2_lower := @UniConv.uniconv_lookup_ucs2_lower;
  repeat
    // Result := (Result shr 5) xor (Lower(P^) + Result);
    // Dec(L);/Inc(P);
    X := P^;
    Dec(L);
    if (X > $7f) then
    begin
      if (X <= High(Word)) then
        X := uniconv_lookup_ucs2_lower[X];
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

function TCachedUTF32String.CharPos(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.CharPos(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.CharPosIgnoreCase(const C: TUnicodeChar; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.CharPosIgnoreCase(const C: UCS4Char; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.Pos(const AChars: PUCS4Char; const ALength: NativeUInt; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.Pos(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.PosIgnoreCase(const S: TUnicodeString; const From: NativeUInt): NativeInt;
begin
  Result := -1{todo};
end;

function TCachedUTF32String.TryAsBoolean(out Value: Boolean): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsBooleanDef(const Default: Boolean): Boolean;
begin
  Result := PCachedUTF32String(@Default)._GetBool(Pointer(Chars), Length);
end;

function TCachedUTF32String.GetBoolean: Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._GetBool(S: PCardinal; L: NativeUInt): Boolean;
label
  fail;
type
  TStrAsData = packed record
    Dwords: array[0..High(Integer) div 4 - 1] of Cardinal;
  end;
var
  Marker: NativeInt;
  Buffer: TCachedByteString;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidBoolean), @Buffer);
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

function TCachedUTF32String.TryAsHex(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsHexDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF32String(@Default)._GetHex(Pointer(Chars), Length);
end;

function TCachedUTF32String.GetHex: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._GetHex(S: PCardinal; L: NativeInt): Integer;
label
  fail, zero;
var
  Buffer: TCachedUTF32String;
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

function TCachedUTF32String.TryAsCardinal(out Value: Cardinal): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsCardinalDef(const Default: Cardinal): Cardinal;
begin
  Result := PCachedUTF32String(@Default)._GetInt(Pointer(Chars), Length);
end;

function TCachedUTF32String.GetCardinal: Cardinal;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.TryAsInteger(out Value: Integer): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsIntegerDef(const Default: Integer): Integer;
begin
  Result := PCachedUTF32String(@Default)._GetInt(Pointer(Chars), -Length);
end;

function TCachedUTF32String.GetInteger: Integer;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._GetInt(S: PCardinal; L: NativeInt): Integer;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedUTF32String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedUTF32String.TryAsHex64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsHex64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.GetHex64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._GetHex64(S: PCardinal; L: NativeInt): Int64;
label
  fail, zero;
var
  Buffer: TCachedUTF32String;
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

function TCachedUTF32String.TryAsUInt64(out Value: UInt64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsUInt64Def(const Default: UInt64): UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.GetUInt64: UInt64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.TryAsInt64(out Value: Int64): Boolean;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.AsInt64Def(const Default: Int64): Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String.GetInt64: Int64;
{$ifdef INLINESUPPORT}
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
{$endif}

function TCachedUTF32String._GetInt64(S: PCardinal; L: NativeInt): Int64;
label
  skipsign, hex, fail, zero;
var
  Buffer: TCachedUTF32String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidInteger), @Buffer);
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

function TCachedUTF32String._GetInt_19(S: PCardinal; L: NativeUInt): NativeInt;
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

function TCachedUTF32String.TryAsFloat(out Value: Single): Boolean;
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF32String.TryAsFloat(out Value: Double): Boolean;
begin
  Result := True;
  Value := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF32String.TryAsFloat(out Value: TExtended80Rec): Boolean;
begin
  Result := True;
  {$if SizeOf(Extended) = 10}
    PExtended(@Value)^ := PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length);
  {$else}
    Value := TExtended80Rec(PCachedUTF32String(-NativeInt(@Result))._GetFloat(Pointer(Chars), Length));
  {$ifend}
end;

function TCachedUTF32String.AsFloatDef(const Default: Extended): Extended;
begin
  Result := PCachedUTF32String(@Default)._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF32String.GetFloat: Extended;
begin
  Result := PCachedUTF32String(0)._GetFloat(Pointer(Chars), Length);
end;

function TCachedUTF32String._GetFloat(S: PCardinal; L: NativeUInt): Extended;
label
  skipsign, frac, exp, skipexpsign, done, fail, zero;
var
  Buffer: TCachedUTF32String;
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
    raise ECachedString.Create(Pointer(@SysConst.SInvalidFloat), @Buffer);
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

function TCachedUTF32String.AsDateDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    Result := Default;
end;

function TCachedUTF32String.GetDate: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Date})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDate), @Self);
end;

function TCachedUTF32String.TryAsDate(out Value: TDateTime): Boolean;
const
  DT = 1{Date};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF32String.AsTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    Result := Default;
end;

function TCachedUTF32String.GetTime: TDateTime;
begin
  if (not _GetDateTime(Result, 1{Time})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidTime), @Self);
end;

function TCachedUTF32String.TryAsTime(out Value: TDateTime): Boolean;
const
  DT = 2{Time};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF32String.AsDateTimeDef(const Default: TDateTime): TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    Result := Default;
end;

function TCachedUTF32String.GetDateTime: TDateTime;
begin
  if (not _GetDateTime(Result, 3{DateTime})) then
    raise ECachedString.Create(Pointer(@SysConst.SInvalidDateTime), @Self);
end;

function TCachedUTF32String.TryAsDateTime(out Value: TDateTime): Boolean;
const
  DT = 3{DateTime};
{$ifdef INLINESUPPORT}
begin
  Result := _GetDateTime(Value, DT);
end;
{$else .CPUX86}
asm
  mov ecx, DT
  jmp _GetDateTime
end;
{$endif}

function TCachedUTF32String._GetDateTime(out Value: TDateTime; DT: NativeUInt): Boolean;
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
  inherited Create(InternalCallback, Source, IsOwner);
end;

function TCachedTextReader.GetIsDirect: Boolean;
begin
  Result := (@FContext.ConvertProc = @TUniConvContextEx.convert_copy);
end;

function TCachedTextReader.DetectBOM(const Source: TCachedReader; const DefaultBOM: TBOM): TBOM;
var
  S: NativeInt;
begin
  if (Source.Margin < 4) and (not Source.IsFinishing) then Source.Flush;

  Result := UniConv.DetectBOM(Source.Current, Source.Margin);
  if (Result <> bomNone) then
  begin
    S := BOM_INFO[Result].Size;
    Inc(Source.Current, S);
    Dec(Source.Margin, S);
  end else
  begin
    Result := DefaultBOM;
  end;
end;

function TCachedTextReader.InternalCallback(Sender: TCachedReReader;
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
      if (not Source.Flush) then Exit;
    end;

    // Convert
    Context.ModeFinalize := Source.IsFinishing;
    I := Context.Convert(Buffer, BufferSize + 16, Source.Current, Source.Margin);

    // Offset
    Count := Context.DestinationWritten;
    Inc(Result, Count);
    Inc(Buffer, Count);
    Dec(BufferSize, Count);
    Source.Seek(Context.SourceRead);
  until (I >= 0);
end;

function TCachedTextReader.GetEOF: Boolean;
begin
  if (Self.Margin > 0) then Result := False
  else Result := Self.IsFinishing;
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
    FContext.Initialize(bomNone, bomNone);
    FLookup := default_lookup_sbcs;
    FNativeFlags := default_lookup_sbcs_index shl 24;
  end else
  begin
    FContext.Initialize(bomUtf8, BOM);
  end;
  
  InternalCreate(Source, IsOwner);
end;

function TCachedByteTextReader.Readln(var S: TCachedByteString): Boolean;
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
    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
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
            Dec(M, SizeOf(P^));
          end;
        end else
        if (not FIsFinishing) then
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
      Margin := M;
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
    M := Margin - Flags{BytesCount};

    if (not FIsFinishing) then
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
    Margin := M;
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
  FContext.Initialize(bomUtf16, BOM);

  InternalCreate(Source, IsOwner);
end;

function TCachedUTF16TextReader.Readln(var S: TCachedUTF16String): Boolean;
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
    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
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
            Dec(M, SizeOf(P^));
          end;
        end else
        if (not FIsFinishing) then
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
      Margin := M;
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
    M := Margin - Flags{BytesCount};

    if (not FIsFinishing) then
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
    Margin := M;
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
  FContext.Initialize(bomUtf32, BOM);
  
  InternalCreate(Source, IsOwner);
end;

function TCachedUTF32TextReader.Readln(var S: TCachedUTF32String): Boolean;
label
  loop, done_, done;
var
  P, Top: PCardinal;
  X, Flags, M: NativeInt;
begin
  Flags := Self.Margin;
  if (Flags < SizeOf(P^)) then
  begin
    if (not Self.Flush) or (Self.Margin < SizeOf(P^)) then
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
    M := Self.Margin - Flags{BytesCount};

    {$ifdef CPUX86}
    X := P^;
    {$endif}
    Inc(P);
    Dec(M, SizeOf(P^));

    if (X = $0d) then
    begin
      if (P <> Top) then
      begin
        if (P^ = $0a) then
        begin
          Inc(P);
          Dec(M, SizeOf(P^));
        end;
      end else
      if (not FIsFinishing) then
      begin
        Flush;
        Result := Readln(S);
        Exit;
      end;
    end;

    Current := Pointer(P);
    Margin := M;
    goto done;
  end;
  if (P <> Top) then goto loop;

done_:
  S.F.NativeFlags := Byte(Flags <= $7f);
  Flags{BytesCount} := NativeUInt(P) - NativeUInt(S.FChars);
  S.Length := Flags{BytesCount} shr 2;
  M := Self.Margin - Flags{BytesCount};

  if (not FIsFinishing) then
  begin
    Flush;
    Result := Readln(S);
    Exit;
  end;

  Current := Pointer(P);
  Margin := M;
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




(*

{ TCachedXMLElement }

function TCachedXMLElement.GetLevel: NativeUInt;
const
  {$ifdef LARGEINT}
    MAGIC = $336;
  {$else .SMALLINT}
    MAGIC = $66C;
  {$endif}  
var
  Data: NativeUInt;
begin
  // Result := (NativeUInt(@Self) - NativeUInt(Data)) siv SizeOf(TCachedXMLElement);
  Data := NativeUInt(FData);
  {$ifdef CPUX64}
    Dec(Data, NativeUInt(@Self));
    Result := (NativeInt(Data) * -MAGIC) shr 16;
  {$else}
    Result := NativeUInt(@Self) - NativeUInt(Data);
    Result := (Result * MAGIC) shr 16;
  {$endif}
end;

function TCachedXMLElement.GetParent: PCachedXMLElement;
begin
  if (@Self = Pointer(FData)) then Result := nil
  else
  begin
    Result := @Self;
    Dec(Result);
  end;
end;

function TCachedXMLElement.GetPath: TUnicodeString;
var
  Data, Element: PCachedXMLElement;
begin
  Element := @Self;
  Result := {$ifdef UNICODE}Format{$else}WideFormat{$endif}
            ('%s[%d]', [Element.Name.AsUnicodeString, Element.Line]);

  Data := Element.FData;
  while (Element <> Data) do
  begin
    Dec(Element);
    Result := {$ifdef UNICODE}Format{$else}WideFormat{$endif}
              ('%s[%d] - %s', [Element.Name.AsUnicodeString, Element.Line, Result]);
  end;
end; *)


(*
	// Tree node types
	enum xml_node_type
	{
		node_null,			// Empty (null) node handle
		node_document,		// A document tree's absolute root
		node_element,		// Element tag, i.e. '<node/>'
		node_pcdata,		// Plain character data, i.e. 'text'
		node_cdata,			// Character data, i.e. '<![CDATA[text]]>'
		node_comment,		// Comment tag, i.e. '<!-- text -->'
		node_pi,			// Processing instruction, i.e. '<?name?>'
		node_declaration,	// Document declaration, i.e. '<?xml version="1.0"?>'
		node_doctype		// Document type declaration, i.e. '<!DOCTYPE doc>'
	};
*)


(*
	// Parsing status, returned as part of xml_parse_result object
	enum xml_parse_status
	{
		status_ok = 0,				// No error

		status_file_not_found,		// File was not found during load_file()
		status_io_error,			// Error reading from file/stream
		status_out_of_memory,		// Could not allocate memory
		status_internal_error,		// Internal error occurred

		status_unrecognized_tag,	// Parser could not determine tag type

		status_bad_pi,				// Parsing error occurred while parsing document declaration/processing instruction
		status_bad_comment,			// Parsing error occurred while parsing comment
		status_bad_cdata,			// Parsing error occurred while parsing CDATA section
		status_bad_doctype,			// Parsing error occurred while parsing document type declaration
		status_bad_pcdata,			// Parsing error occurred while parsing PCDATA section
		status_bad_start_element,	// Parsing error occurred while parsing start element tag
		status_bad_attribute,		// Parsing error occurred while parsing element attribute
		status_bad_end_element,		// Parsing error occurred while parsing end element tag
		status_end_element_mismatch,// There was a mismatch of start-end tags (closing tag had incorrect name, some tag was not closed or there was an excessive closing tag)

		status_append_invalid_root,	// Unable to append nodes since root type is not node_element or node_document (exclusive to xml_node::append_buffer)

		status_no_document_element	// Parsing resulted in a document without element nodes
	};
*)

(*

	enum chartype_t
	{
		ct_parse_pcdata = 1,	// \0, &, \r, <
		ct_parse_attr = 2,		// \0, &, \r, ', "
		ct_parse_attr_ws = 4,	// \0, &, \r, ', ", \n, tab
		ct_space = 8,			// \r, \n, space, tab
		ct_parse_cdata = 16,	// \0, ], >, \r
		ct_parse_comment = 32,	// \0, -, >, \r
		ct_symbol = 64,			// Any symbol > 127, a-z, A-Z, 0-9, _, :, -, .
		ct_start_symbol = 128	// Any symbol > 127, a-z, A-Z, _, :
	};

	static const unsigned char chartype_table[256] =
	{
		55,  0,   0,   0,   0,   0,   0,   0,      0,   12,  12,  0,   0,   63,  0,   0,   // 0-15
		0,   0,   0,   0,   0,   0,   0,   0,      0,   0,   0,   0,   0,   0,   0,   0,   // 16-31
		8,   0,   6,   0,   0,   0,   7,   6,      0,   0,   0,   0,   0,   96,  64,  0,   // 32-47
		64,  64,  64,  64,  64,  64,  64,  64,     64,  64,  192, 0,   1,   0,   48,  0,   // 48-63
		0,   192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 64-79
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 0,   0,   16,  0,   192, // 80-95
		0,   192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 96-111
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 0, 0, 0, 0, 0,           // 112-127

		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 128+
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
		192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192
	};

	enum chartypex_t
	{
		ctx_special_pcdata = 1,   // Any symbol >= 0 and < 32 (except \t, \r, \n), &, <, >
		ctx_special_attr = 2,     // Any symbol >= 0 and < 32 (except \t), &, <, >, "
		ctx_start_symbol = 4,	  // Any symbol > 127, a-z, A-Z, _
		ctx_digit = 8,			  // 0-9
		ctx_symbol = 16			  // Any symbol > 127, a-z, A-Z, 0-9, _, -, .
	};

	static const unsigned char chartypex_table[256] =
	{
		3,  3,  3,  3,  3,  3,  3,  3,     3,  0,  2,  3,  3,  2,  3,  3,     // 0-15
		3,  3,  3,  3,  3,  3,  3,  3,     3,  3,  3,  3,  3,  3,  3,  3,     // 16-31
		0,  0,  2,  0,  0,  0,  3,  0,     0,  0,  0,  0,  0, 16, 16,  0,     // 32-47
		24, 24, 24, 24, 24, 24, 24, 24,    24, 24, 0,  0,  3,  0,  3,  0,     // 48-63

		0,  20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 64-79
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 0,  0,  0,  0,  20,    // 80-95
		0,  20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 96-111
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 0,  0,  0,  0,  0,     // 112-127

		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 128+
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
		20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20
	};

	#define PUGI__IS_CHARTYPE_IMPL(c, ct, table) (table[static_cast<unsigned char>(c)] & (ct))

	#define PUGI__IS_CHARTYPE(c, ct) PUGI__IS_CHARTYPE_IMPL(c, ct, chartype_table)
	#define PUGI__IS_CHARTYPEX(c, ct) PUGI__IS_CHARTYPE_IMPL(c, ct, chartypex_table)


  function IsCharType(c, type: byte): Boolean; inline;
  begin
    Result := (chartype_table[c] and type <> 0);
  end;

  function IsCharTypex(c, type: byte): Boolean; inline;
  begin
    Result := (chartypex_table[c] and type <> 0);
  end;

	#define PUGI__SKIPWS()			{ while (PUGI__IS_CHARTYPE(*s, ct_space)) ++s; }
	#define PUGI__OPTSET(OPT)			( optmsk & (OPT) )
	#define PUGI__PUSHNODE(TYPE)		{ cursor = append_node(cursor, alloc, TYPE); if (!cursor) PUGI__THROW_ERROR(status_out_of_memory, s); }
	#define PUGI__POPNODE()			{ cursor = cursor->parent; }
	#define PUGI__SCANFOR(X)			{ while (*s != 0 && !(X)) ++s; }
	#define PUGI__SCANWHILE(X)		{ while ((X)) ++s; }
	#define PUGI__ENDSEG()			{ ch = *s; *s = 0; ++s; }
	#define PUGI__THROW_ERROR(err, m)	return error_offset = m, error_status = err, static_cast<char_t*>(0)
	#define PUGI__CHECK_ERROR(err, m)	{ if (*s == 0) PUGI__THROW_ERROR(err, m); }


*)

(*
	PUGI__FN char_t* strconv_escape(char_t* s, gap& g)
	{
		char_t* stre = s + 1;

		switch (*stre)
		{
			case '#':	// &#...
			{
				unsigned int ucsc = 0;

				if (stre[1] == 'x') // &#x... (hex code)
				{
					stre += 2;

					char_t ch = *stre;

					if (ch == ';') return stre;

					for (;;)
					{
						if (static_cast<unsigned int>(ch - '0') <= 9)
							ucsc = 16 * ucsc + (ch - '0');
						else if (static_cast<unsigned int>((ch | ' ') - 'a') <= 5)
							ucsc = 16 * ucsc + ((ch | ' ') - 'a' + 10);
						else if (ch == ';')
							break;
						else // cancel
							return stre;

						ch = *++stre;
					}

					++stre;
				}
				else	// &#... (dec code)
				{
					char_t ch = *++stre;

					if (ch == ';') return stre;

					for (;;)
					{
						if (static_cast<unsigned int>(static_cast<unsigned int>(ch) - '0') <= 9)
							ucsc = 10 * ucsc + (ch - '0');
						else if (ch == ';')
							break;
						else // cancel
							return stre;

						ch = *++stre;
					}

					++stre;
				}

			#ifdef PUGIXML_WCHAR_MODE
				s = reinterpret_cast<char_t*>(wchar_writer::any(reinterpret_cast<wchar_writer::value_type>(s), ucsc));
			#else
				s = reinterpret_cast<char_t*>(utf8_writer::any(reinterpret_cast<uint8_t*>(s), ucsc));
			#endif

				g.push(s, stre - s);
				return stre;
			}

			case 'a':	// &a
			{
				++stre;

				if (*stre == 'm') // &am
				{
					if (*++stre == 'p' && *++stre == ';') // &amp;
					{
						*s++ = '&';
						++stre;

						g.push(s, stre - s);
						return stre;
					}
				}
				else if (*stre == 'p') // &ap
				{
					if (*++stre == 'o' && *++stre == 's' && *++stre == ';') // &apos;
					{
						*s++ = '\'';
						++stre;

						g.push(s, stre - s);
						return stre;
					}
				}
				break;
			}

			case 'g': // &g
			{
				if (*++stre == 't' && *++stre == ';') // &gt;
				{
					*s++ = '>';
					++stre;

					g.push(s, stre - s);
					return stre;
				}
				break;
			}

			case 'l': // &l
			{
				if (*++stre == 't' && *++stre == ';') // &lt;
				{
					*s++ = '<';
					++stre;

					g.push(s, stre - s);
					return stre;
				}
				break;
			}

			case 'q': // &q
			{
				if (*++stre == 'u' && *++stre == 'o' && *++stre == 't' && *++stre == ';') // &quot;
				{
					*s++ = '"';
					++stre;

					g.push(s, stre - s);
					return stre;
				}
				break;
			}

			default:
				break;
		}

		return stre;
	}

	// Utility macro for last character handling
	#define ENDSWITH(c, e) ((c) == (e) || ((c) == 0 && endch == (e)))

	PUGI__FN char_t* strconv_comment(char_t* s, char_t endch)
	{
		gap g;

		while (true)
		{
			while (!PUGI__IS_CHARTYPE(*s, ct_parse_comment)) ++s;

			if (*s == '\r') // Either a single 0x0d or 0x0d 0x0a pair
			{
				*s++ = '\n'; // replace first one with 0x0a

				if (*s == '\n') g.push(s, 1);
			}
			else if (s[0] == '-' && s[1] == '-' && ENDSWITH(s[2], '>')) // comment ends here
			{
				*g.flush(s) = 0;

				return s + (s[2] == '>' ? 3 : 2);
			}
			else if (*s == 0)
			{
				return 0;
			}
			else ++s;
		}
	}

	PUGI__FN char_t* strconv_cdata(char_t* s, char_t endch)
	{
		gap g;

		while (true)
		{
			while (!PUGI__IS_CHARTYPE(*s, ct_parse_cdata)) ++s;

			if (*s == '\r') // Either a single 0x0d or 0x0d 0x0a pair
			{
				*s++ = '\n'; // replace first one with 0x0a

				if (*s == '\n') g.push(s, 1);
			}
			else if (s[0] == ']' && s[1] == ']' && ENDSWITH(s[2], '>')) // CDATA ends here
			{
				*g.flush(s) = 0;

				return s + 1;
			}
			else if (*s == 0)
			{
				return 0;
			}
			else ++s;
		}
	}

	typedef char_t* (*strconv_pcdata_t)(char_t* );

	template <typename opt_trim, typename opt_eol, typename opt_escape> struct strconv_pcdata_impl
	{
		static char_t* parse(char_t* s)
		{
			gap g;

			char_t* begin = s;

			while (true)
			{
				while (!PUGI__IS_CHARTYPE(*s, ct_parse_pcdata)) ++s;

				if (*s == '<') // PCDATA ends here
				{
					char_t* end = g.flush(s);

					if (opt_trim::value)
						while (end > begin && PUGI__IS_CHARTYPE(end[-1], ct_space))
							--end;

					*end = 0;

					return s + 1;
				}
				else if (opt_eol::value && *s == '\r') // Either a single 0x0d or 0x0d 0x0a pair
				{
					*s++ = '\n'; // replace first one with 0x0a

					if (*s == '\n') g.push(s, 1);
				}
				else if (opt_escape::value && *s == '&')
				{
					s = strconv_escape(s, g);
				}
				else if (*s == 0)
				{
					char_t* end = g.flush(s);

					if (opt_trim::value)
						while (end > begin && PUGI__IS_CHARTYPE(end[-1], ct_space))
							--end;

					*end = 0;

					return s;
				}
				else ++s;
			}
		}
	};

	PUGI__FN strconv_pcdata_t get_strconv_pcdata(unsigned int optmask)
	{
		PUGI__STATIC_ASSERT(parse_escapes == 0x10 && parse_eol == 0x20 && parse_trim_pcdata == 0x0800);

		switch (((optmask >> 4) & 3) | ((optmask >> 9) & 4)) // get bitmask for flags (eol escapes trim)
		{
		case 0: return strconv_pcdata_impl<opt_false, opt_false, opt_false>::parse;
		case 1: return strconv_pcdata_impl<opt_false, opt_false, opt_true>::parse;
		case 2: return strconv_pcdata_impl<opt_false, opt_true, opt_false>::parse;
		case 3: return strconv_pcdata_impl<opt_false, opt_true, opt_true>::parse;
		case 4: return strconv_pcdata_impl<opt_true, opt_false, opt_false>::parse;
		case 5: return strconv_pcdata_impl<opt_true, opt_false, opt_true>::parse;
		case 6: return strconv_pcdata_impl<opt_true, opt_true, opt_false>::parse;
		case 7: return strconv_pcdata_impl<opt_true, opt_true, opt_true>::parse;
		default: assert(false); return 0; // should not get here
		}
	}

	typedef char_t* (*strconv_attribute_t)(char_t*, char_t);

	template <typename opt_escape> struct strconv_attribute_impl
	{
		static char_t* parse_wnorm(char_t* s, char_t end_quote)
		{
			gap g;

			// trim leading whitespaces
			if (PUGI__IS_CHARTYPE(*s, ct_space))
			{
				char_t* str = s;

				do ++str;
				while (PUGI__IS_CHARTYPE(*str, ct_space));

				g.push(s, str - s);
			}

			while (true)
			{
				while (!PUGI__IS_CHARTYPE(*s, ct_parse_attr_ws | ct_space)) ++s;

				if (*s == end_quote)
				{
					char_t* str = g.flush(s);

					do *str-- = 0;
					while (PUGI__IS_CHARTYPE(*str, ct_space));

					return s + 1;
				}
				else if (PUGI__IS_CHARTYPE(*s, ct_space))
				{
					*s++ = ' ';

					if (PUGI__IS_CHARTYPE(*s, ct_space))
					{
						char_t* str = s + 1;
						while (PUGI__IS_CHARTYPE(*str, ct_space)) ++str;

						g.push(s, str - s);
					}
				}
				else if (opt_escape::value && *s == '&')
				{
					s = strconv_escape(s, g);
				}
				else if (!*s)
				{
					return 0;
				}
				else ++s;
			}
		}

		static char_t* parse_wconv(char_t* s, char_t end_quote)
		{
			gap g;

			while (true)
			{
				while (!PUGI__IS_CHARTYPE(*s, ct_parse_attr_ws)) ++s;

				if (*s == end_quote)
				{
					*g.flush(s) = 0;

					return s + 1;
				}
				else if (PUGI__IS_CHARTYPE(*s, ct_space))
				{
					if (*s == '\r')
					{
						*s++ = ' ';

						if (*s == '\n') g.push(s, 1);
					}
					else *s++ = ' ';
				}
				else if (opt_escape::value && *s == '&')
				{
					s = strconv_escape(s, g);
				}
				else if (!*s)
				{
					return 0;
				}
				else ++s;
			}
		}

		static char_t* parse_eol(char_t* s, char_t end_quote)
		{
			gap g;

			while (true)
			{
				while (!PUGI__IS_CHARTYPE(*s, ct_parse_attr)) ++s;

				if (*s == end_quote)
				{
					*g.flush(s) = 0;

					return s + 1;
				}
				else if (*s == '\r')
				{
					*s++ = '\n';

					if (*s == '\n') g.push(s, 1);
				}
				else if (opt_escape::value && *s == '&')
				{
					s = strconv_escape(s, g);
				}
				else if (!*s)
				{
					return 0;
				}
				else ++s;
			}
		}

		static char_t* parse_simple(char_t* s, char_t end_quote)
		{
			gap g;

			while (true)
			{
				while (!PUGI__IS_CHARTYPE(*s, ct_parse_attr)) ++s;

				if (*s == end_quote)
				{
					*g.flush(s) = 0;

					return s + 1;
				}
				else if (opt_escape::value && *s == '&')
				{
					s = strconv_escape(s, g);
				}
				else if (!*s)
				{
					return 0;
				}
				else ++s;
			}
		}
	};
*)

(*
// DOCTYPE consists of nested sections of the following possible types:
		// <!-- ... -->, <? ... ?>, "...", '...'
		// <![...]]>
		// <!...>
		// First group can not contain nested groups
		// Second group can contain nested groups of the same type
		// Third group can contain all other groups
		char_t* parse_doctype_primitive(char_t* s)
		{
			if (*s == '"' || *s == '\'')
			{
				// quoted string
				char_t ch = *s++;
				PUGI__SCANFOR(*s == ch);
				if (!*s) PUGI__THROW_ERROR(status_bad_doctype, s);

				s++;
			}
			else if (s[0] == '<' && s[1] == '?')
			{
				// <? ... ?>
				s += 2;
				PUGI__SCANFOR(s[0] == '?' && s[1] == '>'); // no need for ENDSWITH because ?> can't terminate proper doctype
				if (!*s) PUGI__THROW_ERROR(status_bad_doctype, s);

				s += 2;
			}
			else if (s[0] == '<' && s[1] == '!' && s[2] == '-' && s[3] == '-')
			{
				s += 4;
				PUGI__SCANFOR(s[0] == '-' && s[1] == '-' && s[2] == '>'); // no need for ENDSWITH because --> can't terminate proper doctype
				if (!*s) PUGI__THROW_ERROR(status_bad_doctype, s);

				s += 4;
			}
			else PUGI__THROW_ERROR(status_bad_doctype, s);

			return s;
		}

		char_t* parse_doctype_ignore(char_t* s)
		{
			assert(s[0] == '<' && s[1] == '!' && s[2] == '[');
			s++;

			while (*s)
			{
				if (s[0] == '<' && s[1] == '!' && s[2] == '[')
				{
					// nested ignore section
					s = parse_doctype_ignore(s);
					if (!s) return s;
				}
				else if (s[0] == ']' && s[1] == ']' && s[2] == '>')
				{
					// ignore section end
					s += 3;

					return s;
				}
				else s++;
			}

			PUGI__THROW_ERROR(status_bad_doctype, s);
		}

		char_t* parse_doctype_group(char_t* s, char_t endch, bool toplevel)
		{
			assert((s[0] == '<' || s[0] == 0) && s[1] == '!');
			s++;

			while (*s)
			{
				if (s[0] == '<' && s[1] == '!' && s[2] != '-')
				{
					if (s[2] == '[')
					{
						// ignore
						s = parse_doctype_ignore(s);
						if (!s) return s;
					}
					else
					{
						// some control group
						s = parse_doctype_group(s, endch, false);
						if (!s) return s;

						// skip >
						assert(*s == '>');
						s++;
					}
				}
				else if (s[0] == '<' || s[0] == '"' || s[0] == '\'')
				{
					// unknown tag (forbidden), or some primitive group
					s = parse_doctype_primitive(s);
					if (!s) return s;
				}
				else if (*s == '>')
				{
					return s;
				}
				else s++;
			}

			if (!toplevel || endch != '>') PUGI__THROW_ERROR(status_bad_doctype, s);

			return s;
		}

		char_t* parse_exclamation(char_t* s, xml_node_struct* cursor, unsigned int optmsk, char_t endch)
		{
			// parse node contents, starting with exclamation mark
			++s;

			if (*s == '-') // '<!-...'
			{
				++s;

				if (*s == '-') // '<!--...'
				{
					++s;

					if (PUGI__OPTSET(parse_comments))
					{
						PUGI__PUSHNODE(node_comment); // Append a new node on the tree.
						cursor->value = s; // Save the offset.
					}

					if (PUGI__OPTSET(parse_eol) && PUGI__OPTSET(parse_comments))
					{
						s = strconv_comment(s, endch);

						if (!s) PUGI__THROW_ERROR(status_bad_comment, cursor->value);
					}
					else
					{
						// Scan for terminating '-->'.
						PUGI__SCANFOR(s[0] == '-' && s[1] == '-' && ENDSWITH(s[2], '>'));
						PUGI__CHECK_ERROR(status_bad_comment, s);

						if (PUGI__OPTSET(parse_comments))
							*s = 0; // Zero-terminate this segment at the first terminating '-'.

						s += (s[2] == '>' ? 3 : 2); // Step over the '\0->'.
					}
				}
				else PUGI__THROW_ERROR(status_bad_comment, s);
			}
			else if (*s == '[')
			{
				// '<![CDATA[...'
				if (*++s=='C' && *++s=='D' && *++s=='A' && *++s=='T' && *++s=='A' && *++s == '[')
				{
					++s;

					if (PUGI__OPTSET(parse_cdata))
					{
						PUGI__PUSHNODE(node_cdata); // Append a new node on the tree.
						cursor->value = s; // Save the offset.

						if (PUGI__OPTSET(parse_eol))
						{
							s = strconv_cdata(s, endch);

							if (!s) PUGI__THROW_ERROR(status_bad_cdata, cursor->value);
						}
						else
						{
							// Scan for terminating ']]>'.
							PUGI__SCANFOR(s[0] == ']' && s[1] == ']' && ENDSWITH(s[2], '>'));
							PUGI__CHECK_ERROR(status_bad_cdata, s);

							*s++ = 0; // Zero-terminate this segment.
						}
					}
					else // Flagged for discard, but we still have to scan for the terminator.
					{
						// Scan for terminating ']]>'.
						PUGI__SCANFOR(s[0] == ']' && s[1] == ']' && ENDSWITH(s[2], '>'));
						PUGI__CHECK_ERROR(status_bad_cdata, s);

						++s;
					}

					s += (s[1] == '>' ? 2 : 1); // Step over the last ']>'.
				}
				else PUGI__THROW_ERROR(status_bad_cdata, s);
			}
			else if (s[0] == 'D' && s[1] == 'O' && s[2] == 'C' && s[3] == 'T' && s[4] == 'Y' && s[5] == 'P' && ENDSWITH(s[6], 'E'))
			{
				s -= 2;

				if (cursor->parent) PUGI__THROW_ERROR(status_bad_doctype, s);

				char_t* mark = s + 9;

				s = parse_doctype_group(s, endch, true);
				if (!s) return s;

				assert((*s == 0 && endch == '>') || *s == '>');
				if (*s) *s++ = 0;

				if (PUGI__OPTSET(parse_doctype))
				{
					while (PUGI__IS_CHARTYPE(*mark, ct_space)) ++mark;

					PUGI__PUSHNODE(node_doctype);

					cursor->value = mark;

					PUGI__POPNODE();
				}
			}
			else if (*s == 0 && endch == '-') PUGI__THROW_ERROR(status_bad_comment, s);
			else if (*s == 0 && endch == '[') PUGI__THROW_ERROR(status_bad_cdata, s);
			else PUGI__THROW_ERROR(status_unrecognized_tag, s);

			return s;
		}

		char_t* parse_question(char_t* s, xml_node_struct*& ref_cursor, unsigned int optmsk, char_t endch)
		{
			// load into registers
			xml_node_struct* cursor = ref_cursor;
			char_t ch = 0;

			// parse node contents, starting with question mark
			++s;

			// read PI target
			char_t* target = s;

			if (!PUGI__IS_CHARTYPE(*s, ct_start_symbol)) PUGI__THROW_ERROR(status_bad_pi, s);

			PUGI__SCANWHILE(PUGI__IS_CHARTYPE(*s, ct_symbol));
			PUGI__CHECK_ERROR(status_bad_pi, s);

			// determine node type; stricmp / strcasecmp is not portable
			bool declaration = (target[0] | ' ') == 'x' && (target[1] | ' ') == 'm' && (target[2] | ' ') == 'l' && target + 3 == s;

			if (declaration ? PUGI__OPTSET(parse_declaration) : PUGI__OPTSET(parse_pi))
			{
				if (declaration)
				{
					// disallow non top-level declarations
					if (cursor->parent) PUGI__THROW_ERROR(status_bad_pi, s);

					PUGI__PUSHNODE(node_declaration);
				}
				else
				{
					PUGI__PUSHNODE(node_pi);
				}

				cursor->name = target;

				PUGI__ENDSEG();

				// parse value/attributes
				if (ch == '?')
				{
					// empty node
					if (!ENDSWITH(*s, '>')) PUGI__THROW_ERROR(status_bad_pi, s);
					s += (*s == '>');

					PUGI__POPNODE();
				}
				else if (PUGI__IS_CHARTYPE(ch, ct_space))
				{
					PUGI__SKIPWS();

					// scan for tag end
					char_t* value = s;

					PUGI__SCANFOR(s[0] == '?' && ENDSWITH(s[1], '>'));
					PUGI__CHECK_ERROR(status_bad_pi, s);

					if (declaration)
					{
						// replace ending ? with / so that 'element' terminates properly
						*s = '/';

						// we exit from this function with cursor at node_declaration, which is a signal to parse() to go to LOC_ATTRIBUTES
						s = value;
					}
					else
					{
						// store value and step over >
						cursor->value = value;
						PUGI__POPNODE();

						PUGI__ENDSEG();

						s += (*s == '>');
					}
				}
				else PUGI__THROW_ERROR(status_bad_pi, s);
			}
			else
			{
				// scan for tag end
				PUGI__SCANFOR(s[0] == '?' && ENDSWITH(s[1], '>'));
				PUGI__CHECK_ERROR(status_bad_pi, s);

				s += (s[1] == '>' ? 2 : 1);
			}

			// store from registers
			ref_cursor = cursor;

			return s;
		}

char_t* parse_tree(char_t* s, xml_node_struct* root, unsigned int optmsk, char_t endch)
{
	strconv_attribute_t strconv_attribute = get_strconv_attribute(optmsk);
	strconv_pcdata_t strconv_pcdata = get_strconv_pcdata(optmsk);

	char_t ch = 0;
	xml_node_struct* cursor = root;
	char_t* mark = s;

	while (*s != 0)
	{
		if (*s == '<')
		{
			++s;

		    LOC_TAG:
			if (PUGI__IS_CHARTYPE(*s, ct_start_symbol)) // '<#...'
			{
			    /*  обычный элемент, начинающийся с правильного символа */
				PUGI__PUSHNODE(node_element); // Append a new node to the tree.

				cursor->name = s;

				PUGI__SCANWHILE(PUGI__IS_CHARTYPE(*s, ct_symbol)); // Scan for a terminator.
				PUGI__ENDSEG(); // Save char in 'ch', terminate & step over.

				if (ch == '>')
				{
					// end of tag
				}
				else
                if (PUGI__IS_CHARTYPE(ch, ct_space))
				{
				LOC_ATTRIBUTES:
					while (true)
					{
						PUGI__SKIPWS(); // Eat any whitespace.

						if (PUGI__IS_CHARTYPE(*s, ct_start_symbol)) // <... #...
						{
							xml_attribute_struct* a = append_attribute_ll(cursor, alloc); // Make space for this attribute.
							if (!a) PUGI__THROW_ERROR(status_out_of_memory, s);

							a->name = s; // Save the offset.

							PUGI__SCANWHILE(PUGI__IS_CHARTYPE(*s, ct_symbol)); // Scan for a terminator.
							PUGI__CHECK_ERROR(status_bad_attribute, s); //$ redundant, left for performance

							PUGI__ENDSEG(); // Save char in 'ch', terminate & step over.
							PUGI__CHECK_ERROR(status_bad_attribute, s); //$ redundant, left for performance

							if (PUGI__IS_CHARTYPE(ch, ct_space))
							{
								PUGI__SKIPWS(); // Eat any whitespace.
								PUGI__CHECK_ERROR(status_bad_attribute, s); //$ redundant, left for performance

								ch = *s;
								++s;
							}

							if (ch == '=') // '<... #=...'
							{
								PUGI__SKIPWS(); // Eat any whitespace.

								if (*s == '"' || *s == '\'') // '<... #="...'
								{
									ch = *s; // Save quote char to avoid breaking on "''" -or- '""'.
									++s; // Step over the quote.
									a->value = s; // Save the offset.

									s = strconv_attribute(s, ch);

									if (!s) PUGI__THROW_ERROR(status_bad_attribute, a->value);

									// After this line the loop continues from the start;
									// Whitespaces, / and > are ok, symbols and EOF are wrong,
									// everything else will be detected
									if (PUGI__IS_CHARTYPE(*s, ct_start_symbol)) PUGI__THROW_ERROR(status_bad_attribute, s);
								}
								else PUGI__THROW_ERROR(status_bad_attribute, s);
							}
							else PUGI__THROW_ERROR(status_bad_attribute, s);
						}
						else if (*s == '/')
						{
							++s;

							if (*s == '>')
							{
								PUGI__POPNODE();
								s++;
								break;
							}
							else if (*s == 0 && endch == '>')
							{
								PUGI__POPNODE();
								break;
							}
							else PUGI__THROW_ERROR(status_bad_start_element, s);
						}
						else if (*s == '>')
						{
							++s;

							break;
						}
						else if (*s == 0 && endch == '>')
						{
							break;
						}
						else PUGI__THROW_ERROR(status_bad_start_element, s);
					}

					// !!!
				}
				else if (ch == '/') // '<#.../'
				{
					if (!ENDSWITH(*s, '>')) PUGI__THROW_ERROR(status_bad_start_element, s);

					PUGI__POPNODE(); // Pop.

					s += (*s == '>');
				}
				else if (ch == 0)
				{
					// we stepped over null terminator, backtrack & handle closing tag
					--s;

					if (endch != '>') PUGI__THROW_ERROR(status_bad_start_element, s);
				}
				else PUGI__THROW_ERROR(status_bad_start_element, s);
			}
			/*  либо ошибка, либо необычный элемент (по крайней мере начинается не с правильного символа) */
			else if (*s == '/')
			{
			    // закрывающийся тег!
				++s;

				// сравнение закрывающегося тега с текущим
				char_t* name = cursor->name;
				if (!name) PUGI__THROW_ERROR(status_end_element_mismatch, s);
				while (PUGI__IS_CHARTYPE(*s, ct_symbol))
				{
					if (*s++ != *name++) PUGI__THROW_ERROR(status_end_element_mismatch, s);
				}
				if (*name)
				{
					if (*s == 0 && name[0] == endch && name[1] == 0) PUGI__THROW_ERROR(status_bad_end_element, s);
					else PUGI__THROW_ERROR(status_end_element_mismatch, s);
				}

				// Pop.
				PUGI__POPNODE();

				// пропустить все пробелы
				PUGI__SKIPWS();

				if (*s == 0)
				{
					if (endch != '>') PUGI__THROW_ERROR(status_bad_end_element, s);
				}
				else
				{
					if (*s != '>') PUGI__THROW_ERROR(status_bad_end_element, s);
					++s;
				}
			}
			else
			if (*s == '?') // '<?...'
			{
			    // типа process instruction
				s = parse_question(s, cursor, optmsk, endch);
				if (!s) return s;

				assert(cursor);
				if ((cursor->header & xml_memory_page_type_mask) + 1 == node_declaration) goto LOC_ATTRIBUTES;
			}
			else
			if (*s == '!') // '<!...'
			{
			    // комментарий
				s = parse_exclamation(s, cursor, optmsk, endch);
				if (!s) return s;
			}
			else if (*s == 0 && endch == '?') PUGI__THROW_ERROR(status_bad_pi, s);
			else PUGI__THROW_ERROR(status_unrecognized_tag, s);
		}
		else /* не '<' */
		{
			mark = s; // Save this offset while searching for a terminator.

			PUGI__SKIPWS(); // Eat whitespace if no genuine PCDATA here.

			if (*s == '<' || !*s)
			{
				// We skipped some whitespace characters because otherwise we would take the tag branch instead of PCDATA one
				assert(mark != s);

				if (!PUGI__OPTSET(parse_ws_pcdata | parse_ws_pcdata_single) || PUGI__OPTSET(parse_trim_pcdata))
				{
					continue;
				}
				else if (PUGI__OPTSET(parse_ws_pcdata_single))
				{
					if (s[0] != '<' || s[1] != '/' || cursor->first_child) continue;
				}
			}

			if (!PUGI__OPTSET(parse_trim_pcdata))
				s = mark;

			if (cursor->parent || PUGI__OPTSET(parse_fragment))
			{
				PUGI__PUSHNODE(node_pcdata); // Append a new node on the tree.
				cursor->value = s; // Save the offset.

				s = strconv_pcdata(s);

				PUGI__POPNODE(); // Pop since this is a standalone.

				if (!*s) break;
			}
			else
			{
				PUGI__SCANFOR(*s == '<'); // '...<'
				if (!*s) break;

				++s;
			}

			// We're after '<'
			goto LOC_TAG;
		} /* '<' или не '<' */
	} // цикл заканчивается когда значение = 0

	// check that last tag is closed
	if (cursor != root) PUGI__THROW_ERROR(status_end_element_mismatch, s);

	return s;
} // parse_tree
*)




(*

{ TCachedParser }

destructor TCachedParser.Destroy;
begin
  Cleanup;
  inherited;
end;

procedure TCachedParser.Cleanup;
begin
  FParseResult := PARSE_OK;
  FParseMessage := '';
end;

procedure TCachedParser.DoParse(const Reader: TCachedReader);
begin
end;

procedure TCachedParser.Stop(const ParseResult: Integer; const ParseMessage: TUnicodeString);
begin
  FParseResult := ParseResult;
  FParseMessage := ParseMessage;
  raise ECachedParserStop.Create({$ifdef KOL}e_Custom,{$endif}'');
end;

function TCachedParser.Parse(const Reader: TCachedReader): Integer;
begin
  Cleanup;

  try
    DoParse(Reader);
    FParseResult := PARSE_OK;
    FParseMessage := '';
  except
    on E: ECachedParserStop do ;
  end;

  Result := FParseResult;
end;

function TCachedParser.Parse(const FileName: string): Integer;
var
  Reader: TCachedFileReader;
begin
  Reader := TCachedFileReader.Create(FileName);
  try
    Result := Parse(Reader);
  finally
    Reader.Free;
  end;
end;

function TCachedParser.Parse(const Ptr: Pointer;
  const Size: NativeUInt): Integer;
var
  Static: TCachedStatic;
  Reader: TCachedReader;
begin
  Reader := TCachedReader.StaticCreate(Static, Ptr, Size);
  try
    Result := Parse(Reader);
  finally
    Reader.Free;
  end;
end;


{ TCachedXMLParser }

procedure TCachedXMLParser.OnComment(const Parent: TCachedXMLElement; const Value: TCachedByteString);
begin
end;

procedure TCachedXMLParser.OnElement(const Element: TCachedXMLElement);
begin
end;

procedure TCachedXMLParser.OnAttribute(const Attribute: TCachedXMLAttribute);
begin
end;

procedure TCachedXMLParser.OnElementValue(const Element: TCachedXMLElement; const Value: TCachedByteString);
begin
end;

procedure TCachedXMLParser.OnElementFinish(const Element: TCachedXMLElement);
begin
end;

//const
//  MAX_SAX_LEVEL = 16;

(*type
  PSAXData = ^TSAXData;

  // TCachedXMLElement alias
  TSAXElement = object
    Data: PSAXData;
    Line: NativeUInt;
    Name: TCachedByteString;
    UserData: Pointer;
    Align: array[1..128-SizeOf(TCachedXMLElement)] of Byte;
  end;
  PSAXElement = ^TSAXElement;

  // TCachedXMLAttribute alias
  TSAXAttribute = object
    Element: PSAXElement;
    Name: TCachedByteString;
    Value: TCachedByteString;
  end;

  //
  TSAXInfo = record
    Self: Pointer; //TCachedXMLParser;
    Reader: Pointer; //TCachedByteTextReader;
//    TopCurrent: PAnsiChar;?

    case Integer of
    0:
    (
      OnComment: procedure(const Self: Pointer; const Parent: TCachedXMLElement; const Value: TCachedByteString);
      OnElement: procedure(const Self: Pointer; const Element: TCachedXMLElement);
      OnAttribute: procedure(const Self: Pointer; const Attribute: TCachedXMLAttribute);
      OnElementValue: procedure(const Self: Pointer; const Element: TCachedXMLElement; const Value: TCachedByteString);
      OnElementFinish: procedure(const Self: Pointer; const Element: TCachedXMLElement);
    );
    1:
    (
      PtrComment: Pointer;
      PtrElement: Pointer;
      PtrAttribute: Pointer;
      PtrElementValue: Pointer;
      PtrElementFinish: Pointer;
    );
  end;

  // данные должны состоять из:
  //  - буфер элементов (8)
  //  - указатель на бывшие данные
  //  - рабочие данные: линия,
  //  - общая информация (Self, калбеки, ридер, topCurrent)
  //  - информация для потенциальной ошибки
  TSAXData = record
    Elements: array[0..16-1] of TSAXElement; // TCachedXMLElement
    Parent: PSAXData;

    Line: NativeUInt;
    Attribute: TSAXAttribute;

    Storage: record
      Current: PAnsiChar;
      Element: PSAXElement;
      TopCurrent: PAnsiChar;
      Error: Integer;
    end;
    Info: TSAXInfo;
  end;

procedure SAXDataFill(var Data: TSAXData;
  const Self: TCachedXMLParser; const Reader: TCachedByteTextReader);
var
  Line: NativeUInt;
  Current: PAnsiChar;
  FOnComment: procedure(const Parent: TCachedXMLElement; const Value: TCachedByteString) of object;
  FOnElement: procedure(const Element: TCachedXMLElement) of object;
  FOnAttribute: procedure(const Attribute: TCachedXMLAttribute) of object;
  FOnElementValue: procedure(const Element: TCachedXMLElement; const Value: TCachedByteString) of object;
  FOnElementFinish: procedure(const Element: TCachedXMLElement) of object;
begin
  Line := Data.Line;
  Current := Reader.Current;
  FillChar(Data, sizeof(Data), 0);
  Data.Self := Pointer(Self);
  Data.Reader := Reader;
  Data.TopCurrent := Pointer(@Current[Reader.Margin-1]);
  Data.Line := Line;
//  Data.Name.Parser := Pointer(Self);
//  Data.Value.Parser := Pointer(Self);

  FOnComment := Self.OnComment;
  FOnElement := Self.OnElement;
  FOnAttribute := Self.OnAttribute;
  FOnElementValue := Self.OnElementValue;
  FOnElementFinish := Self.OnElementFinish;

  Data.PtrComment := TMethod(FOnComment).Code;
  Data.PtrElement := TMethod(FOnElement).Code;
  Data.PtrAttribute := TMethod(FOnAttribute).Code;
  Data.PtrElementValue := TMethod(FOnElementValue).Code;
  Data.PtrElementFinish := TMethod(FOnElementFinish).Code;
end;

const
  ct_parse_pcdata = 1;    // \0, and, \r, <
  ct_parse_attr = 2;      // \0, and, \r, ', "
  ct_parse_attr_ws = 4;   // \0, and, \r, ', ", \n, tab
  ct_space = 8;           // \r, \n, space, tab
  ct_parse_cdata = 16;    // \0, ], >, \r
  ct_parse_comment = 32;  // \0, -, >, \r
  ct_symbol = 64;         // Any symbol > 127, a-z, A-Z, 0-9, _, :, -, .
  ct_start_symbol = 128;  // Any symbol > 127, a-z, A-Z, _, :

  chartype_table: array[0..255] of Byte = (
    55,  0,   0,   0,   0,   0,   0,   0,      0,   12,  12,  0,   0,   63,  0,   0,   // 0-15
    0,   0,   0,   0,   0,   0,   0,   0,      0,   0,   0,   0,   0,   0,   0,   0,   // 16-31
    8,   0,   6,   0,   0,   0,   7,   6,      0,   0,   0,   0,   0,   96,  64,  0,   // 32-47
    64,  64,  64,  64,  64,  64,  64,  64,     64,  64,  192, 0,   1,   0,   48,  0,   // 48-63
    0,   192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 64-79
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 0,   0,   16,  0,   192, // 80-95
    0,   192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 96-111
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 0, 0, 0, 0, 0,           // 112-127

    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192, // 128+
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192,
    192, 192, 192, 192, 192, 192, 192, 192,    192, 192, 192, 192, 192, 192, 192, 192
  );

  ctx_special_pcdata = 1; // Any symbol >= 0 and < 32 (except \t, \r, \n), and, <, >
  ctx_special_attr = 2;   // Any symbol >= 0 and < 32 (except \t), and, <, >, "
  ctx_start_symbol = 4;   // Any symbol > 127, a-z, A-Z, _
  ctx_digit = 8;          // 0-9
  ctx_symbol = 16;        // Any symbol > 127, a-z, A-Z, 0-9, _, -, .

  chartypex_table: array[0..255] of Byte = (
    3,  3,  3,  3,  3,  3,  3,  3,     3,  0,  2,  3,  3,  2,  3,  3,     // 0-15
    3,  3,  3,  3,  3,  3,  3,  3,     3,  3,  3,  3,  3,  3,  3,  3,     // 16-31
    0,  0,  2,  0,  0,  0,  3,  0,     0,  0,  0,  0,  0, 16, 16,  0,     // 32-47
    24, 24, 24, 24, 24, 24, 24, 24,    24, 24, 0,  0,  3,  0,  3,  0,     // 48-63

    0,  20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 64-79
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 0,  0,  0,  0,  20,    // 80-95
    0,  20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 96-111
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 0,  0,  0,  0,  0,     // 112-127

    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,    // 128+
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20,
    20, 20, 20, 20, 20, 20, 20, 20,    20, 20, 20, 20, 20, 20, 20, 20
  );

var{const todo}
  sax_chartype_first: array[Byte] of Byte;

{
	// Parsing status, returned as part of xml_parse_result object
	enum xml_parse_status
	{
		status_unrecognized_tag,	// Parser could not determine tag type

		status_bad_pi,				// Parsing error occurred while parsing document declaration/processing instruction
		status_bad_comment,			// Parsing error occurred while parsing comment
		status_bad_cdata,			// Parsing error occurred while parsing CDATA section
		status_bad_doctype,			// Parsing error occurred while parsing document type declaration
		status_bad_pcdata,			// Parsing error occurred while parsing PCDATA section
		status_bad_start_element,	// Parsing error occurred while parsing start element tag
		status_bad_attribute,		// Parsing error occurred while parsing element attribute
		status_bad_end_element,		// Parsing error occurred while parsing end element tag
		status_end_element_mismatch,// There was a mismatch of start-end tags (closing tag had incorrect name, some tag was not closed or there was an excessive closing tag)

		status_append_invalid_root,	// Unable to append nodes since root type is not node_element or node_document (exclusive to xml_node::append_buffer)

		status_no_document_element	// Parsing resulted in a document without element nodes
	};

  }

{
	PUGI__FN const char* xml_parse_result::description() const
	{
		switch (status)
		{
		case status_no_document_element: return "No document element found";
		case status_unrecognized_tag: return "Could not determine tag type";

		case status_bad_pi: return "Error parsing document declaration/processing instruction";
		case status_bad_comment: return "Error parsing comment";
		case status_bad_cdata: return "Error parsing CDATA section";
		case status_bad_doctype: return "Error parsing document type declaration";
		case status_bad_pcdata: return "Error parsing PCDATA section";
		case status_bad_start_element: return "Error parsing start element tag";
		case status_bad_attribute: return "Error parsing element attribute";
		case status_bad_end_element: return "Error parsing end element tag";
		case status_end_element_mismatch: return "Start-end tags mismatch";



		}
	}
}

type
  // todo синхронизировать со стандартными константами ParseResult
  // скорее всего будет не TSAXError, а Integer
  TSAXError = (seNoDocument, seUnrecognized, seBadPi, seBadComment,
               seBadCData, seBadDocType, seBadPCData, seStartElement,
               seAttribute, seEndElement, seElementMitmatch);



//	#define PUGI__THROW_ERROR(err, m)	return error_offset = m, error_status = err, static_cast<char_t*>(0)
// ошибки

procedure InternalSAXThrow(var Data: TSAXData; Element: PSAXElement; Error: TSAXError);
const
  ERROR_MESSAGES: array[TSAXError] of TUnicodeString = (
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  );
begin
  TCachedXMLParser(Data.Self).Stop(Ord(Error),
    PCachedXMLElement(Element).Path + ':'#13#10 + ERROR_MESSAGES[Error]
          );
 //PCachedXMLElement

end;

function InternalSAXFlush(var Data: TSAXData; Element: PSAXElement; Current: Pointer): PAnsiChar;
const
  LT = Ord('<');
  GT = Ord('>');
  QT = Ord('"');
  AP = Ord('''');
  OB = Ord('[');
  CB = Ord(']');
  MN = Ord('-');
  QS = Ord('?');
var
  Reader: TCachedByteTextReader;
  Offset: NativeInt;
  TopCurrent: PAnsiChar;
begin
  Reader := TCachedByteTextReader(Data.Reader);
  if (Reader.Finishing) then
  begin
    Result := nil;
    Exit;
  end;

  Offset := NativeInt(Current) - NativeInt(Reader.Current);
  Inc(NativeInt(Reader.Current), Offset);
  Dec(Reader.Margin, Offset);

  Reader.Flush;
  if (Reader.Margin <= 0) then
  begin
    Result := nil;
    Exit;
  end;

  // todo

  Result := Reader.Current;
  TopCurrent := Pointer(@Result[Reader.Margin-1]);
  Data.TopCurrent := TopCurrent;
  PInteger(@TopCurrent[1])^ := (LT shl 0) +
                               (GT shl 8) +
                               (QT shl 16) +
                               (AP shl 24);
  PInteger(@TopCurrent[5])^ := (OB shl 0) +
                               (CB shl 8) +
                               (MN shl 16) +
                               (QS shl 24);
end;

function InternalSAXQuestion(var Data: TSAXData; Element: PSAXElement; Current: PAnsiChar): PAnsiChar;
begin

end;

function InternalSAXExclamation(var Data: TSAXData; Element: PSAXElement; Current: PAnsiChar): PAnsiChar;
begin

end;





procedure InternalSAXParse(const ALine: NativeUInt; const AParser: TCachedXMLParser;
  const AByteTextReader: TCachedByteTextReader);
// Data.OnComment(Data.Self, Data.Value);
// Data.OnElement(Data.Self, Data.Name);
// Data.OnAttribute(Data.Self, Data.Name, Data.Value);
// Data.OnElementValue(Data.Self, Data.Value);
// Data.OnElementFinish(Data.Self);
label
  node_loop, node_pop;
const
  TEST_MASKS: array[0..SizeOf(Integer)-1] of NativeInt = ($80, $8000, $800000, Integer($80000000));
const
  LT_XOR_MASK = $3c3c3c3c; // <
  LF_XOR_MASK = $0a0a0a0a; // \n


var
  Current, TopCurrent: PAnsiChar;
  T, V, X: NativeInt;
  B: Byte;
  Data: TSAXData;
begin
  {$ifdef undef}{$REGION 'basic variables initialization'}{$endif}
  Data.Line := ALine;
  SAXDataFill(Data, AParser, AByteTextReader);

  Current := TCachedByteTextReader(Data.Reader).Current;
  TopCurrent := Data.TopCurrent;
  {$ifdef undef}{$ENDREGION}{$endif}

node_loop:
  {$ifdef undef}{$REGION 'find ''<'', increase Line value on ''\n'' character'}{$endif}
  T := PCardinal(Current)^;
  Inc(Current);
  //V := (T xor LT_XOR_MASK);
  //T := (T xor LF_XOR_MASK);
  V := T;
  T := (T xor LF_XOR_MASK);
  V := (V xor LT_XOR_MASK);
  //T := (T - $01010101) and (not T);
  //V := (V - $01010101) and (not V);
  X := T + Integer(-$01010101);
  T := not T;
  T := T and X;
  X := V + Integer(-$01010101);
  V := not V;
  V := V and X;
  // if ((V or T) and Integer($80808080) = 0) then
  V := V or T;
  if (V and Integer($80808080) = 0) then
  begin
    Inc(Current, SizeOf(Integer) - 1);
    goto node_loop;
  end else
  begin
    B := Ord(V and $80 = 0) + Ord(V and $8080 = 0) + Ord(V and $808080 = 0);
    V := B;
    Inc(Current, V);
    if (T and TEST_MASKS[V] <> 0) then
    begin
      Inc(Data.Line);
      goto node_loop;
    end;
  end;
  {$ifdef undef}{$ENDREGION}{$endif}

  {$ifdef undef}{$REGION 'parse non-opened element'}{$endif}
  // case sax_chartype_first[Byte(Current^)] of
  T := sax_chartype_first[Byte(Current^)];
  if (T < 4) then
  if (T = 0) then goto node_pop
  else
  case (T) of
    3: {'exception'}
       begin
         TCachedXMLParser(Data.Self).Stop(100500, 'msg');
         Exit;
   {0:}node_pop: {'/'}

         InternalSAXFlush(Data, nil, nil);
         goto node_loop;
       end;
    1: {'!'}
       begin
         case Byte(Current[1]) of
           Ord('['): {CDATA}
           begin

//             Data.OnElementValue(Data.Self, Data.Value);
             goto node_loop;
           end;
           Ord('-'): {Comment}
           begin

//             Data.OnComment(Data.Self, Data.Value);
             goto node_loop;
           end;
         else
           {Some}
           InternalSAXFlush(Data, nil, nil);
           Exit;
         end;
       end;
    2: {'?'}
       begin
         Inc(Data.Line);
         goto node_loop;
       end;
  end;
  {$ifdef undef}{$ENDREGION}{$endif}

  if (Current >= TopCurrent) then
  begin
    if (InternalSAXFlush(Data, nil, nil) = nil) then goto node_loop
    else
    if (Data.Line = 5) then
    raise Exception.Create('');
  end;


//  TCachedXMLParser(Data.Self).FStoredLineValue := Data.Line;
end;




procedure TCachedXMLParser.DoParse(const Reader: TCachedReader);
var
  Context: TUniConvContext;
  Static: TCachedStatic;
  ByteTextReader: TCachedByteTextReader;
begin
  // todo Context

  ByteTextReader := TCachedByteTextReader.StaticCreate(Static, Context, Reader);
  try
    InternalSAXParse(0, Self, ByteTextReader);
  finally
    ByteTextReader.Free;
  end;
end;

procedure TCachedXMLParser.Cleanup;
begin
  FNamesStoragePosition := 0;
end;

function TCachedXMLParser.StoreName(var Name: TCachedParserLiteral): NativeInt;
begin
  Result := 0;
  // todo
end;    *)



(*procedure TestMAGIC;
var
  i: integer;
  BEST_MAGIC, MAGIC: NativeUInt;
  DIF, V: NativeUInt;
  done: boolean;
  S: string;
begin
  BEST_MAGIC := 0;

  for MAGIC := 0 to High(Word) do
  begin
    done := true;

    for i := 0 to High(TSAXData(nil^).Elements) do
    begin
      DIF := i*SizeOf(TCachedXMLElement);

      V := (DIF * MAGIC) shr 16;
      if (i <> V) then
      begin
        done := false;
        break;
      end;
    end;

    if (done) then  BEST_MAGIC := MAGIC;
  end;

  if (BEST_MAGIC <> 0) then
  begin
    S := {$ifdef CPUX64}'x64'{$else}'x86'{$endif} + ' MAGIC = $' + IntToHex(BEST_MAGIC, 0);
    Clipboard.AsText := S;
    MessageBox(0, PChar(S), '', 0);
  end else
  raise Exception.Create('Fail');
end;

procedure TestElement();
var
  Data: TSAXData;
  i, L: NativeInt;
begin
  for i := 0 to High(TSAXData(nil^).Elements) do
  begin
    Data.Elements[i].Data := @Data;

    L := PCachedXMLElement(@Data.Elements[i]).Level;
    if (L <> i) then
    raise Exception.CreateFmt('I = %d, L = %d', [i, L]);
  end;

  MessageBox(0, 'Всё ништяк!', '', 0);
end;
      *)




initialization
  CODEPAGE_DEFAULT := UniConv.CODEPAGE_DEFAULT;
  default_lookup_sbcs := UniConv.default_lookup_sbcs;
  default_lookup_sbcs_index := UniConv.default_lookup_sbcs_index;
  uniconv_lookup_utf8_size := UniConv.uniconv_lookup_utf8_size;

end.