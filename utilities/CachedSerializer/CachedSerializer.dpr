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
{$endif}
{$O+}{$R-}{$I-}{$Q-}{$W-}

uses {$ifdef UNITSCOPENAMES}
       System.SysUtils,
     {$else}
       SysUtils,
     {$endif}
     SerializeUnit in 'SerializeUnit.pas';

var
  Serializer: TSerializer;
  ParamIndex: Integer;
  FileName, S: string;

begin
  try
    FileName := ParamStr(1);

    if (not FileExists(FileName)) then
    begin
      // some message todo
    end else
    begin
      Serializer := TSerializer.Create(FileName);
      try
        // update parameters
        ParamIndex := 2;
        repeat
          S := ParamStr(ParamIndex);
          if (S = '') then Break;

          // todo
        until (False);

        // process serializing
        // todo
      finally
        Serializer.Free;
      end;
    end;
  except
    on EAbort do ;

    on E: Exception do
    begin
      Writeln(E.ClassName, ':');
      Writeln(E.Message);
    end;
  end;

  if (ParamStr(ParamCount) <> '-nowait') then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.
