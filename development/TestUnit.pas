unit TestUnit;

{$i crystal_options.inc}

interface
  uses {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
       {$ifdef MSWINDOWS}{$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},{$endif}
       CachedBuffers,
       UniConv,
       CachedTexts;



procedure RUN;
procedure ShowMessage(const S: string); overload;
procedure ShowMessage(const StrFmt: string; const Args: array of const); overload;

implementation


procedure RUN;
var
  Text: TUTF16TextReader;
  S: CachedUTF16String;
begin

  Text := TUTF16TextReader.CreateFromFile('TEST.txt');
  try
    while Text.Readln(S) do
      ShowMessage('"' + string(S) + '"');

  finally
    Text.Free;
  end;

  ShowMessage('Done'{'Test'});
end;

procedure ShowMessage(const S: string);
var
  BreakPoint: string;
begin
  BreakPoint := S;

  {$ifdef MSWINDOWS}
    if ({$ifdef UNITSCOPENAMES}Winapi.{$endif}Windows.MessageBox(GetForegroundWindow,
      PChar(BreakPoint), 'Сообщение:', MB_OKCANCEL) = IDCANCEL) then Halt;
  {$else}
    Halt;
  {$endif}
end;

procedure ShowMessage(const StrFmt: string; const Args: array of const);
begin
  ShowMessage(Format(StrFmt, Args));
end;






initialization


end.
