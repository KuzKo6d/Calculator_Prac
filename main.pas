program main;
uses sysutils, math;

type
  start_args = packed array of integer;

var
  // main block
  i: integer;
  result: double = 0;
// init block
  accuracy: double;
  out_base: start_args;

// init procedure. read start arguments
procedure mainReadInit(var accuracy: double; var out_base: start_args);
var
  i: integer;
  tempInt: longInt;
begin
  // init out_base array
  setlength(out_base, ParamCount);

  // check count of args (min 2, max N)
  if (ParamCount < 2) then
  begin
    writeln('Incorrect count of arguments.');
    writeln('(min: 2)');
    halt(1);
  end;

  // check if accuracy value out of condition and try to StrToFloat
  if not(TryStrToFLoat(ParamStr(1), accuracy)) or (accuracy < 0) or (accuracy > 1) then
  begin
    writeln('Unexpected accuracy value.');
    writeln('(min: 0, max: 1)');
    halt(1);
  end;

  // check if base value out of condition and try to StrToInt
  for i:=2 to ParamCount do
    if not TryStrToInt(ParamStr(i), tempInt) or (tempInt < 2) or (tempInt > 256) then
    begin
      writeln('Unexpected base value.');
      writeln('(min: 2, max: 256)');
      halt(1);
    end
        // write base value to array if it's okay
    else
      out_base[i] := tempInt;
end;

begin
  // initialize
  mainReadInit(accuracy, out_base);

  // write initialize results
  writeln('the accuracy is: ', accuracy: 0: 5);
  for i:=2 to length(out_base) do
    writeln(i - 1, ' answ base: ', out_base[i]);

  // read line
  {mainReadInputLine(result);}
end.
