program CachedSerializer;

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
  {$WARN SYMBOL_PLATFORM OFF}
{$endif}
{$O+}{$R-}{$I-}{$Q-}{$W-}

uses {$ifdef UNITSCOPENAMES}Winapi.Windows{$else}Windows{$endif},
     {$ifdef UNITSCOPENAMES}System.SysUtils{$else}SysUtils{$endif},
     UniConv,
     SerializeUnit in 'SerializeUnit.pas';


procedure SetClipboardText(const Text: UnicodeString);
var
  Size: NativeUInt;
  Handle: HGLOBAL;
  Ptr: Pointer;
begin
  OpenClipboard(0);
  try
    Size := (Length(Text) + 1) * SizeOf(WideChar);
    Handle := GlobalAlloc(GMEM_DDESHARE or GMEM_MOVEABLE, Size);
    try
      Win32Check(Handle <> 0);
      Ptr := GlobalLock(Handle);
      Win32Check(Assigned(Ptr));
      Move(PUnicodeChar(Text)^, Ptr^, Size);
      GlobalUnlock(Handle);
      SetClipboardData(CF_UNICODETEXT, Handle);
    finally
      GlobalFree(Handle);
    end;
  finally
    CloseClipboard;
  end;
end;

var
  FlagWait, FlagCopy: Boolean;
  ParamIndex, i: Integer;
  FileName, S: string;
  Parameters: TSerializeParameters;
  Serializer: TSerializer;
  List: TUnicodeStrings;
  Text: UnicodeString;
begin
  // check flags: -nowait, -nocopy
  FlagWait := True;
  FlagCopy := True;
  ParamIndex := 1;
  repeat
    S := ParamStr(ParamIndex);
    if (S = '') then Break;

    if (S = '-nowait') then FlagWait := False;
    if (S = '-nocopy') then FlagCopy := False;
  until (False);

  // load file
  FileName := ParamStr(1);
  try
    if (FileExists(FileName)) then
    begin
      Parameters.AddFromFile(FileName, True);

      // update parameters
      ParamIndex := 2;
      repeat
        S := ParamStr(ParamIndex);
        if (S = '') then Break;

        if (not Parameters.ParseParameter(S)) then
        begin
          if (S <> '-nowait') and (S <> '-nocopy') then
            Writeln('Unknown parameter "', S, '"');
        end;
      until (False);

      // serialize
      Serializer := TSerializer.Create;
      try
        List := Serializer.Process(Parameters);

        // collect list, display to the console
        for i := 0 to Length(List) - 1 do
        begin
          if (Text <> '') then Text := Text + #13#10;
          Text := Text + List[i];

          Writeln(List[i]);
        end;

        // copy to the clipboard
        if (FlagCopy) then
        begin
          SetClipboardText(Text);
          Writeln;
          Writeln('The code has been successfully copied to the clipboard');
        end;
      finally
        Serializer.Free;
      end;
    end else
    begin
      // some message todo

    end;
  except
    on EAbort do ;

    on E: Exception do
    begin
      Writeln(E.ClassName, ':');
      Writeln(E.Message);
    end;
  end;

  if (FlagWait) then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
