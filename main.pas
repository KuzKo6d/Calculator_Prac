program main;
uses sysutils, math;

type
  start_args = packed array of integer;

var
  // main block
  i: integer;
  result: double = 0;
  argument: double;
  res_sign: boolean = true;
  arg_sign: boolean;
// init block
  accuracy: double;
  out_base: start_args;

    // SUB FUNCTIONS //
// check overflow and compute adding
function subAdding(res, arg: double): double;
begin
  if (res + arg >= 5.0 * Power(10, -324)) and (res + arg <= 1.7 * Power(10, 308)) then
    subAdding := res + arg
end;

// check overflow and compute adding
function subSubtraction(res, arg: double): double;
begin
  if (res - arg >= 5.0 * Power(10, -324)) and (res - arg <= 1.7 * Power(10, 308)) then
    subSubtraction := res - arg
end;

// check overflow and compute multiplication
function subMultiplicate(res, arg: double): double;
begin
  // check overflow
  if (res * arg >= 5.0 * Power(10, -324)) and (res * arg <= 1.7 * Power(10, 308)) then
    subMultiplicate := res * arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range)');
    halt(1);
  end;
end;

// check overflow and compute division
function subDivision(res, arg: double): double;
begin
  // catch division by zero
  if arg = 0 then
  begin
    writeln('Division by zero.');
    writeln('(can"t divide by zero)');
    halt(1);
  end
      // check overflow
  else if (res / arg >= 5.0 * Power(10, -324)) and (res / arg <= 1.7 * Power(10, 308)) then
    subDivision := res / arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range)');
    halt(1);
  end;
end;

    //Uses in main\\
// adding procedure
procedure adding(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  // ++ / -- -> sum and don't change sign
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res := subAdding(res, arg)
  else
  begin
    // first > second -> first - sec
    if res > arg then
    begin
      res := subSubtraction(res, arg);
      // if result < 0
      if res_sign < arg_sign then
        res_sign := false;
    end
        // first < second -> sec - first
    else
    begin
      res := subSubtraction(arg, res);
      if res_sign > arg_sign then
        res_sign := false;
    end;
  end;
end;

// multiplicate procedure
procedure multiplicate(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  // ++, -- -> +
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res_sign := true
      // +-, -+ -> -
  else
    res_sign := false;
  // write result
  res := subMultiplicate(res, arg);
end;

// division procedure
procedure division(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  // ++, -- -> +
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res_sign := true
      // +-, -+ -> -
  else
    res_sign := false;
  // write result
  res := subDivision(res, arg);
end;


    // MAIN FUNCTIONS //
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

end.