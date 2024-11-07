program main;
uses sysutils, math;

type
  start_args = packed array of integer;

var
  (*  main block *)
  i: integer;
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
(*  check overflow and compute adding *)
function subAdding(res, arg: double): double;
begin
  if (res >= minDouble + arg) and (res <= maxDouble - arg) then
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
  if (res >= minDouble + arg) and (res >= maxDouble + arg) then
    subSubtraction := res - arg
  else
  begin
    writeln('Result overflow.');
    writeln('(result out of double range. substraction)');
    halt(1);
  end;
end;

(*  check overflow and compute multiplication *)
function subMultiplicate(res, arg: double): double;
begin
  (*  check overflow *)
  if (res >= minDouble / arg) and (res <= maxDouble / arg) then
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

{conversion of a number into a number system with a base of 16} 			{Для Кости и Гриши, стереть это!!!!!  Эта функция переводит числа из следующей функции в формат [0..9][a..f]}
procedure to_16_system(res: integer; flag: boolean);
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
      new_res:=(res div 16);
      flag:=true;
      to_16_system(new_res, flag);
      to_16_system(res mod 16, flag);
    end;
end;

{conversion of trunc(res) into a number system with a base of 2..256} 		{Для Кости и Гриши, стереть это!!!!!!!!  Эта функция берет целую часть от результата и сначала переводит в кастомную систему
 счисления, а потом уже эти числа выводит в представлении [0..9][a..f]}
procedure to_system(base, res: integer);
var
  new_res: integer;

begin
  if ((res div base) = 0) then
    begin
      to_16_system(res, false);
      write(' ');
    end
  else
    begin
      new_res:=(res div base);
      to_system(base, new_res);
      to_16_system((res mod base), false);
      write(' ');
    end; 
end;

{conversion of a fractional part into a number system with a base 2..256} 	{Для Кости и Гриши, стереть это!!!!!!!! Функция готова, но я не уверен, что имелась в виду эта точность, я спрошу на праке,
 если что быстро изменю}
procedure after_dot_to_system(base: integer; after_dot_res: double);
var
  i: integer;


begin
  if (after_dot_res = 0) then
    write('00')
  else
    for i:=1 to 6 do
      begin
        after_dot_res:=(after_dot_res*base);
        to_16_system((trunc(after_dot_res)), false);
        after_dot_res:=(after_dot_res-(trunc(after_dot_res)));
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
      writeln('LOG: first - sec. sucsess.');
      (*  if result < 0 *)
      if res_sign < arg_sign then
        res_sign := false;
    end
        (*  first < second -> sec - first *)
    else
    begin
      res := subSubtraction(arg, res);
      writeln('LOG: arg - res. sucsess.');
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

(*  read input procedure. read operation and num and handle finish command *)
procedure mainReadInput(var arg_operation: char; var arg_sign: boolean; var argument: double; var fin: boolean);
begin
end;

(*  finish procedure. finish program and writre result in all init bases *)
procedure mainFinish(result: double; accuracy: double; var out_base: start_args);
var
  after_dot_res: double;

begin

  after_dot_res:=(result-(trunc(result)));

  {use of accuracy}
  if (accuracy>=0.5) then
    begin
      if (after_dot_res > accuracy) then
        begin
          result:=((trunc(result))+1);
          after_dot_res:=0;
        end
      else
        begin
          after_dot_res:=(result-(trunc(result));
          result:=trunc(result);
        end;
    end
  else
    begin
      if (after_dot_res>accuracy) then
        if (after_dot_res>(0.5)) then
          begin
            result:=((trunc(result))+1);
            after_dot_res:=0;
          end
        else
          begin
            result:=(trunc(result));
            after_dot_res:=accuracy;
          end
      else
        begin
          after_dot_res:=(result-(trunc(result)));
          result:=(trunc(result));
        end;
    end;

  {output with formatting}
  for i:=2 to ParamCount do
    begin
      if (out_base[i]<=9) then
        begin
          write(out_base[i], '     ');
          to_system(out_base[i], result);
          write(' . ');
          after_dot_to_system(out_base[i], result);
        end;
      if ((out_base[i]>=10) and (out_base[i]<=99)) then
        begin
          write(out_base[i], '    '); 
          to_system(out_base[i], result);
          write(' . ');
          after_dot_to_system(out_base[i], result);
        end;
      if (out_base[i]>99) then
        begin
          write(out_base[i], '   ');
          to_system(out_base[i], result);
          write(' . ');
          after_dot_to_system(out_base[i], result);
        end;
    end;

end;


begin
  (*  initialize *)
  mainReadInit(accuracy, out_base);

  (*  write initialize results *)
  writeln('the accuracy is: ', accuracy: 0: 5);
  for i:=2 to length(out_base) do
    writeln(i - 1, ' answ base: ', out_base[i]);

  (*  main cycle *)
  while true do
  begin
    (*  read input *)
    mainReadInput(arg_operation, arg_sign, argument, fin);
    (*  if finish command detected *)
    if fin then
      mainFinish(result, accuracy, out_base)
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
