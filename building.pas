program main;
uses crt, sysutils, math;

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
(*  some functions use main finish inside *)
procedure mainFinish(res_sign: boolean; result: double; accuracy: double; var out_base: start_args); forward;

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
  if (arg=0) then
    begin
      res:=0;
      res_sign:=true;
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

    {comment for the team, the first sub function, nothing serious, just checking whether a character belongs to the hexadecimal number system, as you understand, can also be excluded for code personalization}
function proverkana16(c: char): boolean;
begin
  proverkana16 := false;
  if (((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or ((ord(c) >= ord('a')) and (ord(c) <= ord('f')))) then
    proverkana16 := true;
end;

{comment for the team, the second sub procedure that is called if we find any input error, for a normal build it is necessary to remove halt(1) from it, because halt will already be called in mainFinish}
{also, this function is a moment that can be changed to personalize the code}
procedure finByMistake(result: double; accuracy: double; var arr: start_args);
begin
  writeln('The program terminated due to an input error, the last result received:');
  mainFinish(res_sign, result, accuracy, arr);
  halt(0);
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

{this function determines how many decimal places to display}			{Для Кости и Гриши, стереть это!!!!!!!!! Тут гениальная схема Сальникова по тому сколько знаков нужно}
function after_dot_num_func(base, count: integer; accuracy, after_dot_res: double): integer;
var
  temp_accuracy, temp_num, new_num, new_acc: double;
  prev_num, prev_acc: integer;

begin
  count:=count+1;
  temp_num:=(after_dot_res*base);
  temp_accuracy:=(accuracy*base);
  prev_num:=(trunc(after_dot_res*base));
  prev_acc:=(trunc(accuracy*base));
  if (temp_num>=temp_accuracy) then
    begin
      new_num:=(temp_num-prev_num);
      new_acc:=(temp_accuracy-prev_acc);
      after_dot_num_func:=(after_dot_num_func(base, count, new_acc, new_num));
    end
 else
  begin
    after_dot_num_func:=(count+1);
  end;
end;

{conversion of a fractional part into a number system with a base 2..256} 	{Для Кости и Гриши, стереть это!!!!!!!! Переводим число после запятой в кастомную систему, а потом в [0..9][a..f] представление}
procedure after_dot_to_system(base: integer; accuracy, after_dot_res: double);
var
  after_dot_num, i: integer;

begin
  if ((after_dot_res = 0) or (after_dot_res>accuracy)) then
    begin
      write('00');
      exit
    end
  else
    after_dot_num:=after_dot_num_func(base, 0, accuracy, after_dot_res);
    for i:=1 to after_dot_num do
      begin
        after_dot_res:=(after_dot_res*base);
        to_16_system((trunc(after_dot_res)), false);
        write(' ');
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
procedure mainReadInput_head_reference(var arg_operation: char; var arg_sign: boolean; var argument: double; var fin: boolean);
begin
end;

{comment for the team, a working procedure for processing input parameters, processing all exceptional operations with spaces, finish, comments inside the input data and almost accepted by Salnikov}
procedure mainReadInput(var operation: char; var znak: boolean; var chislo: double; var fin: boolean);
var
  base, i, fin_fl, num: integer;
  fl_operation, fl_znak, fl_base, fl_dot, fl_comment: boolean;
  c, d: char;
  operation_str: string;
begin
  operation_str := '+-*/';
  fl_operation := false;
  fl_dot := true;
  fl_znak := true;
  fl_base := true;
  fl_comment := false;
  chislo := 0;
  znak := true;
  fin_fl := 0;
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
        if ord(c) = ord('f') then
        begin
          fin_fl := 1;
          continue;
        end
        else
          if ((ord(c) = ord('i')) and (fin_fl = 1)) then
          begin
            fin_fl := 2;
            continue;
          end
          else
            if ((ord(c) = ord('n')) and (fin_fl = 2)) then
            begin
              fin_fl := 3;
              continue;
            end
            else
              if ((ord(c) = ord('i')) and (fin_fl = 3)) then
              begin
                fin_fl := 4;
                continue;
              end
              else
                if ((ord(c) = ord('s')) and (fin_fl = 4)) then
                begin
                  fin_fl := 5;
                  continue;
                end
                else
                  if ((ord(c) = ord('h')) and (fin_fl = 5)) then
                  begin
                    fin := true;
                    continue;
                  end
                  else
                    finByMistake(result, accuracy, out_base);
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
        finByMistake(result, accuracy, out_base);
      if (ord(c) = ord(':')) and (base <> 0) then
      begin
        fl_base := true;
        fl_znak := false;
        read(d);
        if (ord(d) <> ord(' ')) then
          finByMistake(result, accuracy, out_base);
        continue;
      end
      else
        finByMistake(result, accuracy, out_base);
    end;


      {entering a number sign}
    if not(fl_znak) then //input of sign
      case c of
        '+':
        begin
          znak := true;
          fl_znak := true;
          fl_dot := false;
          continue;
        end;
        '-':
        begin
          znak := false;
          fl_znak := true;
          fl_dot := false;
          continue;
        end
      else
        if proverkana16(c) then
        begin
          znak := true;
          fl_znak := true;
          fl_dot := false;
        end
        else
          finByMistake(result, accuracy, out_base);
      end;

      {entering an integer part of a number}
    i := 0;

    if not(fl_dot) then
    begin
      if (proverkana16(c)) then
      begin
        while (ord(c) <> ord('.')) do
        begin
          i := i + 1;
          read(d);
          if (proverkana16(c) and proverkana16(d)) then
          begin
            if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
              num := num + 16 * (ord(c) - ord('0'))
            else
              num := num + 16 * (10 + ord(c) - ord('a'));
            if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
              num := num + (ord(d) - ord('0'))
            else
              num := num + (10 +ord(d) - ord('a'));
          end
          else
            finByMistake(result, accuracy, out_base);

          if (num >= base) then
            finByMistake(result, accuracy, out_base)
          else
          begin
            chislo := chislo * base + num;
          end;
          num := 0;
          read(c);
          if (ord(c) = ord(' ')) then
          begin
            read(c);
            continue;
          end;
          if (proverkana16(c)) then
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
        finByMistake(result, accuracy, out_base);
    end;

      {entering the fractional part of a number}
    if fl_dot and fl_operation and fl_znak and fl_base then
    begin
      if (proverkana16(c)) then
      begin
        i := 1;
        while (ord(c) <> 10) do
        begin
          read(d);
          if (proverkana16(c) and proverkana16(d)) then
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
            finByMistake(result, accuracy, out_base);

          if (num >= base) then
            finByMistake(result, accuracy, out_base)
          else
          begin
            chislo := chislo + num / exp(i * LN(base));
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
          if (proverkana16(c)) then
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
        finByMistake(result, accuracy, out_base);
      end;
    end;
  until (ord(c) = 10) or (fin = true);

end;

(*  finish procedure. finish program and writre result in all init bases *)
procedure mainFinish(res_sign: boolean; result: double; accuracy: double; var out_base: start_args);
var
  after_dot_res: double;
  before_dot_res, i: integer;

begin

  after_dot_res := (result - (trunc(result)));
  before_dot_res := trunc(result);

  {output with formatting}
  for i:=2 to ParamCount do
  begin
    if (out_base[i] <= 9) then
    begin
      write(out_base[i], '     ');
      if (res_sign = false) then
        write('-');
      to_system(out_base[i], before_dot_res);
      write(' . ');
      after_dot_to_system(out_base[i], accuracy, after_dot_res);
      writeln;
    end;
    if ((out_base[i] >= 10) and (out_base[i] <= 99)) then
    begin
      write(out_base[i], '    ');
      if (res_sign = false) then
        write('-');
      to_system(out_base[i], before_dot_res);
      write(' . ');
      after_dot_to_system(out_base[i], accuracy, after_dot_res);
      writeln;
    end;
    if (out_base[i] > 99) then
    begin
      write(out_base[i], '   ');
      if (res_sign = false) then
        write('-');
      to_system(out_base[i], before_dot_res);
      write(' . ');
      after_dot_to_system(out_base[i], accuracy, after_dot_res);
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
