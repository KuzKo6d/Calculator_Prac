program main;
uses crt, sysutils, math;

type
  start_args = packed array of integer;

var
  (*  main block *)
  res_sign: boolean = true;
  result: double = 0;
  arg_operation: char;
  arg_sign: boolean;
  argument: double;
  fin: boolean = false;
(*  init block *)
  accuracy: double;
  out_base: start_args;

    (*  SUB FUNCTIONS // *)
(*  some functions use mainFinish and finByErr inside *)
procedure mainFinish(res_sign: boolean; result: double; accuracy: double; var out_base: start_args); forward;

procedure finByErr(result: double; accuracy: double; var arr: start_args); forward;

(*  check overflow and compute adding *)
function subAdding(res, arg: double): double;
begin
  if (res <= maxDouble - arg) then
    subAdding := res + arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range. adding)');
    halt(1);
  end;
end;

(*  check overflow and compute substraction *)
function subSubtraction(res, arg: double): double;
begin
  subSubtraction := res - arg
end;

(*  check overflow and compute multiplication *)
function subMultiplicate(res, arg: double): double;
begin
  if (arg = 0) then
  begin
    res := 0;
    res_sign := true;
  end
      (*  check overflow *)
  else if (res >= minDouble / arg) and (res <= maxDouble / arg) then
    subMultiplicate := res * arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range. multiplicate)');
    halt(1);
  end;
end;

(*  check overflow and compute division *)
function subDivision(res, arg: double): double;
begin
  (*  catch division by zero *)
  if arg = 0 then
  begin
    writeln('Division by zero.');
    writeln('(can"t divide by zero)');
    halt(1);
  end
      (*  check overflow *)
  else if (res >= minDouble * arg) and (res <= maxDouble * arg) then
    subDivision := res / arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range. division)');
    halt(1);
  end;
end;

(*  check if num is in 16 base *)
function checkIf16(c: char): boolean;
begin
  checkIf16 := false;
  if (((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or ((ord(c) >= ord('a')) and (ord(c) <= ord('f')))) then
    checkIf16 := true;
end;

(* finish program with exitcode 1 and write last result *)
procedure finByErr(result: double; accuracy: double; var arr: start_args);
begin
  writeln('The program terminated due to an input error, the last result received:');
  mainFinish(res_sign, result, accuracy, arr);
  halt(1);
end;

{conversion of a number into a number system with a base of 16}
procedure convertTo16(res: integer; flag: boolean);
var
  new_res: integer;

begin
  if ((res div 16) = 0) then
  begin
    if (flag = false) then
      write('0');
    case res of
      0: write('0');
      1..9: write(res);
      10: write('a');
      11: write('b');
      12: write('c');
      13: write('d');
      14: write('e');
      15: write('f');
    end;
  end
  else
  begin
    new_res := (res div 16);
    flag := true;
    convertTo16(new_res, flag);
    convertTo16(res mod 16, flag);
  end;
end;

{conversion of trunc(res) into a number system with a base of 2..256}
procedure beforeDotToSys(base: integer; res: longint);
var
  new_res: longint;

begin
  if ((res div base) = 0) then
  begin
    convertTo16(res, false);
    write(' ');
  end
  else
  begin
    new_res := (res div base);
    beforeDotToSys(base, new_res);
    convertTo16((res mod base), false);
    write(' ');
  end;
end;

{this function determines how many decimal places to display}
function afterDotLength(base, count: integer; accuracy, after_dot_res: double): integer;
var
  temp_accuracy, temp_num, new_num, new_acc: double;
  prev_num, prev_acc: integer;

begin
  count := count + 1;
  temp_num := (after_dot_res * base);
  temp_accuracy := (accuracy * base);
  prev_num := (trunc(after_dot_res * base));
  prev_acc := (trunc(accuracy * base));
  if (temp_num >= temp_accuracy) then
  begin
    new_num := (temp_num - prev_num);
    new_acc := (temp_accuracy - prev_acc);
    afterDotLength := (afterDotLength(base, count, new_acc, new_num));
  end
  else
  begin
    afterDotLength := (count + 1);
  end;
end;

{conversion of a fractional part into a number system with a base 2..256}
procedure afterDotToSys(base: integer; accuracy, after_dot_res: double);
var
  after_dot_num, i: integer;

begin
  if ((after_dot_res = 0) or (after_dot_res > accuracy)) then
  begin
    write('00');
    exit
  end
  else
    after_dot_num := afterDotLength(base, 0, accuracy, after_dot_res);
  for i:=1 to after_dot_num do
  begin
    after_dot_res := (after_dot_res * base);
    convertTo16((trunc(after_dot_res)), false);
    write(' ');
    after_dot_res := (after_dot_res - (trunc(after_dot_res)));
  end;
end;


    (* Uses in main\\ *)
(*  adding procedure *)
procedure mainAdding(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  (*  ++ / -- -> sum and don't change sign *)
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res := subAdding(res, arg)
  else
  begin
    (*  first > second -> first - sec *)
    if res > arg then
    begin
      res := subSubtraction(res, arg);
      (*  if result < 0 *)
      if res_sign < arg_sign then
        res_sign := false;
    end
        (*  first < second -> sec - first *)
    else
    begin
      res := subSubtraction(arg, res);
      if res_sign > arg_sign then
        res_sign := false;
    end;
  end;
end;

(*  multiplicate procedure *)
procedure mainMultiplicate(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  (*  ++, -- -> + *)
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res_sign := true
      (*  +-, -+ -> - *)
  else
    res_sign := false;
  (*  write result *)
  res := subMultiplicate(res, arg);
end;

(*  division procedure *)
procedure mainDivision(var res: double; arg: double; var res_sign: boolean; arg_sign: boolean);
begin
  (*  ++, -- -> + *)
  if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
    res_sign := true
      (*  +-, -+ -> - *)
  else
    res_sign := false;
  (*  write result *)
  res := subDivision(res, arg);
end;


    (*  MAIN FUNCTIONS // *)
(*  init procedure. read start arguments *)
procedure mainReadInit(var accuracy: double; var out_base: start_args);
var
  i: integer;
  tempInt: longInt;
begin
  (*  init out_base array *)
  setlength(out_base, ParamCount);

  (*  check count of args (min 2, max N) *)
  if (ParamCount < 2) then
  begin
    writeln('Incorrect count of arguments.');
    writeln('(min: 2)');
    halt(1);
  end;

  (*  check if accuracy value out of condition and try to StrToFloat *)
  if not(TryStrToFLoat(ParamStr(1), accuracy)) or (accuracy < 0) or (accuracy > 1) then
  begin
    writeln('Unexpected accuracy value.');
    writeln('(min: 0, max: 1)');
    halt(1);
  end;

  (*  check if base value out of condition and try to StrToInt *)
  for i:=2 to ParamCount do
    if not TryStrToInt(ParamStr(i), tempInt) or (tempInt < 2) or (tempInt > 256) then
    begin
      writeln('Unexpected base value.');
      writeln('(min: 2, max: 256)');
      halt(1);
    end
        (*  write base value to array if it's okay *)
    else
      out_base[i] := tempInt;
end;

(*  read input line. detect finish and komments *)
procedure mainReadInput(var operation: char; var sign: boolean; var argument: double; var fin: boolean);
var
  base, i, fin_fl, num: integer;
  fl_operation, fl_sign, fl_base, fl_dot, fl_comment: boolean;
  c, d: char;
  operation_str, fin_str: string;
begin
  operation_str := '+-*/';
  fl_operation := false;
  fl_dot := true;
  fl_sign := true;
  fl_base := true;
  fl_comment := false;
  argument := 0;
  sign := true;
  fin := false;
  base := 0;
  repeat
    num := 0;
    read(c);

      {checking the line for comments}
    if ord(c) = ord('#') then
    begin
      fl_comment := true;
      continue;
    end;

      {the condition for skipping all spaces and tabs, or if its comment}
    if ((ord(c) = ord(' ')) or (ord(c) = 9) or (fl_comment)) then
      continue;

      {entering the operation sign or checking the first significant character of the string at the beginning of the word finish}
    if not(fl_operation) then
    begin
      if (pos(c, operation_str) <> 0) then
      begin
        fl_operation := true;
        fl_base := false;
        operation := c;
        continue;
      end
      else
      begin
        (*  try to catch finish command *)
        if ord(c) = ord('f') then
        begin
          (* read the word *)
          fin_str := 'f';
          for i:=1 to 5 do
          begin
            read(c);
            fin_str := fin_str + c;
          end;
          (*  check if finish *)
          if fin_str = 'finish' then
          begin
            fin := true;
            continue;
          end
          else
            finByErr(result, accuracy, out_base);
        end;
      end;
    end;

      {entering the number system}
    if not(fl_base) then
    begin
      if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
      begin
        while (ord(c) <> ord(':')) do
        begin
          base := base * 10 + (ord(c) - ord('0'));
          read(c);
          if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
            continue
          else
            break;
        end;
      end;
      if ((base > 256) or (base < 2)) then
        finByErr(result, accuracy, out_base);
      if (ord(c) = ord(':')) and (base <> 0) then
      begin
        fl_base := true;
        fl_sign := false;
        read(d);
        if (ord(d) <> ord(' ')) then
          finByErr(result, accuracy, out_base);
        continue;
      end
      else
        finByErr(result, accuracy, out_base);
    end;


      {entering a number sign}
    if not(fl_sign) then //input of sign
      case c of
        '+':
        begin
          sign := true;
          fl_sign := true;
          fl_dot := false;
          continue;
        end;
        '-':
        begin
          sign := false;
          fl_sign := true;
          fl_dot := false;
          continue;
        end
      else
        if checkIf16(c) then
        begin
          sign := true;
          fl_sign := true;
          fl_dot := false;
        end
        else
          finByErr(result, accuracy, out_base);
      end;

      {entering an integer part of a number}
    i := 0;

    if not(fl_dot) then
    begin
      if (checkIf16(c)) then
      begin
        while (ord(c) <> ord('.')) do
        begin
          i := i + 1;
          read(d);
          if (checkIf16(c) and checkIf16(d)) then
          begin
            if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
              num := num + 16 * (ord(c) - ord('0'))
            else
              num := num + 16 * (10 + ord(c) - ord('a'));
            if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
              num := num + (ord(d) - ord('0'))
            else
              num := num + (10 + ord(d) - ord('a'));
          end
          else
            finByErr(result, accuracy, out_base);

          if (num >= base) then
            finByErr(result, accuracy, out_base)
          else
          begin
            argument := argument * base + num;
          end;
          num := 0;
          read(c);
          if (ord(c) = ord(' ')) then
          begin
            read(c);
            continue;
          end;
          if (checkIf16(c)) then
            continue
          else
            break;
        end;
      end;
      if ((ord(c) = ord('.')) and (i <> 0)) then
      begin
        fl_dot := true;
        i := 0;
        continue;
      end
      else
        finByErr(result, accuracy, out_base);
    end;

      {entering the fractional part of a number}
    if fl_dot and fl_operation and fl_sign and fl_base then
    begin
      if (checkIf16(c)) then
      begin
        i := 1;
        while (ord(c) <> 10) do
        begin
          read(d);
          if (checkIf16(c) and checkIf16(d)) then
          begin
            if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
              num := num + 16 * (ord(c) - ord('0'))
            else
              num := num + 16 * (10 + ord(c) - ord('a'));
            if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
              num := num + (ord(d) - ord('0'))
            else
              num := num + 10 + (ord(d) - ord('a'));
          end
          else
            finByErr(result, accuracy, out_base);

          if (num >= base) then
            finByErr(result, accuracy, out_base)
          else
          begin
            argument := argument + num / exp(i * LN(base));
          end;
          num := 0;
          i := i + 1;
          read(c);
          if (ord(c) = ord(' ')) then
          begin
            while (ord(c) = ord(' ')) do
            begin
              read(c);
            end;
          end;
          if (ord(c) = ord('#')) then
          begin
            fl_comment := true;
            break;
          end;
          if (checkIf16(c)) then
            continue
          else
            break;
        end;
      end;
      if (fl_comment = true) then
        continue;
      if ((ord(c) = 10) and (i <> 0)) then
      begin
        i := 0;
        continue;
      end
      else
      begin
        writeln('here');
        finByErr(result, accuracy, out_base);
      end;
    end;
  until (ord(c) = 10) or (fin = true);

end;

(*  finish procedure. finish program and writre result in all init bases *)
procedure mainFinish(res_sign: boolean; result: double; accuracy: double; var out_base: start_args);
var
  after_dot_res: double;
  before_dot_res: longint;
  i: integer;

begin
  after_dot_res := (result - (trunc(result)));
  before_dot_res := trunc(result);

  (*  output with formatting *)
  for i:=2 to ParamCount do
  begin
    write(out_base[i]: 3, ':  ');
    if (res_sign = false) then
      write('-');
    beforeDotToSys(out_base[i], before_dot_res);
    write('. ');
    afterDotToSys(out_base[i], accuracy, after_dot_res);
    writeln;
  end;

end;


begin
  (*  initialize *)
  mainReadInit(accuracy, out_base);

  (*  write initialize results *)
{  writeln('the accuracy is: ', accuracy: 0: 5);
  for i:=2 to length(out_base) do
    writeln(i - 1, ' answ base: ', out_base[i]);}

  (*  main cycle *)
  while true do
  begin
    (*  read input *)
    mainReadInput(arg_operation, arg_sign, argument, fin);
    (*  if finish command detected *)
    if fin then
    begin
      mainFinish(res_sign, result, accuracy, out_base);
      halt(0);
    end
        (*  process operation *)
    else
      case arg_operation of
        '+': mainAdding(result, argument, res_sign, arg_sign);
        '*': mainMultiplicate(result, argument, res_sign, arg_sign);
        '/': mainDivision(result, argument, res_sign, arg_sign);
        '-':
        begin
          (*  argumen sign * (-1) *)
          if arg_sign = false then
            arg_sign := true
          else
            arg_sign := false;
          (*  simple adding *)
          mainAdding(result, argument, res_sign, arg_sign);
        end;
      end;
  end;

end.