program main;
uses crt, sysutils, math;

type
    start_args = packed array of integer;

var
    (*  main block *)
    res_sign :boolean = true;
    result :double = 0;
    arg_operation :char;
    arg_sign :boolean;
    argument :double;
    fin :boolean = false;
    (*  init block *)
    accuracy :double;
    out_base :start_args;

procedure mainFinish(); forward;

(*  SUB FUNCTONS *)
(*  write last result and exit the program with error *)
procedure finByMistake(exit_message :string);
begin
    writeln('Exit message: ', exit_message);
    writeln('The last result received:');
    mainFinish();
    halt(1);
end;

(*  check overflow and compute adding *)
function subAdding(result, arg :double) :double;
begin
    if (result <= maxDouble - arg) then
        subAdding := result + arg
    else
        finByMistake('Overflow of the result, when adding the value went beyond the double type');
end;

(*  check overflow and compute multiplication *)
function subMultiplicate(result, arg :double) :double;
begin
    if (arg = 0) then
    begin
        result := 0;
        res_sign := true;
    end
    else
        if (result >= minDouble / arg) and (result <= maxDouble / arg) then
            subMultiplicate := result * arg
        else
            finByMistake('Overflow of the result, when multiplying the value went beyond the double type');
end;

(*  check overflow and compute subdivision *)
function subDivision(result, arg :double) :double;
begin
    if arg = 0 then
        finByMistake('Incorrect result, division by zero is prohibited!')
    else
        if (result >= minDouble * arg) and (result <= maxDouble * arg) then
            subDivision := result / arg
        else
            finByMistake('Overflow of the result, when dividing, the value went beyond the boundaries of the double type');
end;

(*  check if char in 16th base alphabet *)
function checkingFor16(c :char) :boolean;
begin
    if (((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or ((ord(c) >= ord('a')) and (ord(c) <= ord('f')))) then
        checkingFor16 := true
    else
        checkingFor16 := false;
end;

(*  write num in correct base in 16 output *)
procedure writeIn16thBase(result :int64);
var
    first, second :char;
begin
    (*  if num biger then one dight *)
    if (result > 16) then
    begin
        (*  first of pair *)
        if (result div 16 < 9) then
            first := chr(ord('0') + (result div 16))
        else
            first := chr(ord('a') + (result div 16) - 10);
        (*  second of pair *)
        if (result mod 16 <= 9) then
            second := chr(ord('0') + (result mod 16))
        else
            second := chr(ord('a') + (result mod 16) - 10);
    end
    else
    begin
        first := '0';
        if (result mod 16 <= 9) then
            second := chr(ord('0') + (result mod 16))
        else
            second := chr(ord('a') + (result mod 16) - 10);
    end;
    write(first, second, ' ');
end;

(*  determining count of signs after dot using accuracy value *)
procedure checkingTheAccuracy(base :int64; var count :int64; accuracy, fractionalPartRes :double);
var
    temp_res, temp_accuracy, changed_num, shifted_num :double;
begin
    shifted_num := 0;
    changed_num := int(base * fractionalPartRes);
    temp_res := (base - 1) + base * fractionalPartRes - int(base * fractionalPartRes);
    temp_accuracy := accuracy * base;
    count := 1;
    while (temp_res > temp_accuracy) do
    begin
        count := count + 1;
        shifted_num := shifted_num + base * changed_num;
        changed_num := int(base * (temp_res - base + 1)) - shifted_num * base;
        temp_res := (base - 1) + base * temp_res - int(base * temp_res) + shifted_num;
        temp_accuracy := temp_accuracy * base;
    end;
end;

(*  convert result before dot to needed base and use writeIn16thBase *)
procedure writeResultBeforeDot(base :int64; res_int_part :double);
var
    len, i :int64;
    sub_res, prev_res :double;
    fin_res :start_args;
begin
    sub_res := res_int_part;
    len := 0;
    (*  if result is zero *)
    if res_int_part = 0 then
    begin
        write('00 ');
        exit;
    end;
    (*  counting output vector length *)
    while (sub_res > 0) do
    begin
        sub_res := int(sub_res / base);
        len := len + 1;
    end;
    sub_res := res_int_part;

    setlength(fin_res, len);
    (*  make answ vector in needed base by sign *)
    for i:=len downto 1 do
    begin
        prev_res := sub_res;
        sub_res := int(prev_res / base);
        fin_res[i] := trunc(prev_res - sub_res * base);
    end;
    (*  write by writeIn16thBase *)
    for i:=1 to len do
    begin
        writeIn16thBase(fin_res[i]);
    end;
end;

(*  convet fractional part of result to base, round by accuracy and write by writeIn16thBase *)
procedure writeResultAfterDot(base :integer; accuracy, fractionalPartRes :double);
var
    count, i :int64;
begin
    count := 0;
    (*  if fractional is zero *)
    if (fractionalPartRes = 0)  then
    begin
        write('00');
        exit;
    end
    else
    begin
        checkingTheAccuracy(base, count, accuracy, fractionalPartRes);
    end;
    (*  write fractional part by writeIn16thBase *)
    for i:=1 to count do
    begin
        fractionalPartRes := (fractionalPartRes * base);
        writeIn16thBase((trunc(fractionalPartRes)));
        write(' ');
        fractionalPartRes := (fractionalPartRes - (int(fractionalPartRes)));
    end;
end;

(*  MAIN FUNCTIONS *)
(*  adding procedure *)
procedure mainAdding(var result :double; argument :double; var res_sign :boolean; arg_sign :boolean);
begin
    if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
        result := subAdding(result, argument)
    else
    begin
        if result > argument then
        begin
            result := result - argument;
            if res_sign < arg_sign then
                res_sign := false;
        end
        else
        begin
            result := result - argument;
            if res_sign > arg_sign then
                res_sign := false;
        end;
    end;
end;

(*  multiplicate procedure *)
procedure mainMultiplicate(var result :double; argument :double; var res_sign :boolean; arg_sign :boolean);
begin
    if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
        res_sign := true
    else
        res_sign := false;
    result := subMultiplicate(result, argument);
end;

(*  division procedure *)
procedure mainDivision(var result :double; argument :double; var res_sign :boolean; arg_sign :boolean);
begin
    if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
        res_sign := true
    else
        res_sign := false;
    result := subDivision(result, argument);
end;

(*  init procedure. read start arguments *)
procedure mainReadInit(var accuracy :double; var out_base :start_args);
var
    i :integer;
    tempInt :longInt;
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
    if not(TryStrToFLoat(ParamStr(1), accuracy)) or (accuracy <= 0) or (accuracy > 1) then
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

{reads the input data, splits it into the required parts and handles all exceptional situations}
procedure mainReadInput(var arg_operation :char; var arg_sign :boolean; var argument :double; var fin :boolean);
var
    base, i :int64;
    fl_operation, fl_znak, fl_base, fl_dot, fl_comment :boolean;
    c, d :char;
    fin_str :string;
    arg_local :double;
begin
    fl_operation := false;
    fl_dot := true;
    fl_znak := true;
    fl_base := true;
    fl_comment := false;
    argument := 0;
    arg_sign := true;
    fin := false;
    base := 0;
    repeat
        arg_local := 0;
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

            (*  read start of string *)
        if not(fl_operation) then
        begin
            (*  check if is operation *)
            if (c = '+') or (c = '-') or (c = '*') or (c = '/') then
            begin
                fl_operation := true;
                fl_base := false;
                arg_operation := c;
                continue;
            end
                    (*  else: try to catch finish command *)
            else
            begin
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
                        finByMistake('Incorrect input. Can"t start with letter.');
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
                finByMistake('Input error, the number system must represent an integer from 2 to 256');
            if (ord(c) = ord(':')) and (base <> 0) then
            begin
                fl_base := true;
                fl_znak := false;
                read(d);
                if (ord(d) <> ord(' ')) then
                    finByMistake('Input error, a space is required after the colon');
                continue;
            end
            else
                finByMistake('Input error, the number system must represent an integer from 2 to 256');
        end;


            {entering a number sign}
        if not(fl_znak) then
        begin
            case c of
                '+' :
                begin
                    arg_sign := true;
                    fl_znak := true;
                    fl_dot := false;
                    continue;
                end;
                '-' :
                begin
                    arg_sign := false;
                    fl_znak := true;
                    fl_dot := false;
                    continue;
                end
            else
                if checkingFor16(c) then
                begin
                    arg_sign := true;
                    fl_znak := true;
                    fl_dot := false;
                end
                else
                    finByMistake('Input error, the number sign is entered incorrectly');
            end;
        end;

            {entering an integer part of a number}
        i := 0;

        if not(fl_dot) then
        begin
            if (checkingFor16(c)) then
            begin
                while (ord(c) <> ord('.')) do
                begin
                    i := i + 1;
                    read(d);
                    if (checkingFor16(c) and checkingFor16(d)) then
                    begin
                        if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
                            arg_local := arg_local + 16 * (ord(c) - ord('0'))
                        else
                            arg_local := arg_local + 16 * (10 + ord(c) - ord('a'));
                        if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
                            arg_local := arg_local + (ord(d) - ord('0'))
                        else
                            arg_local := arg_local + (10 + ord(d) - ord('a'));
                    end
                    else
                        finByMistake('Input error, incorrect input of an integer part of a number');

                    if (arg_local >= base) then

                        finByMistake('Input error, overflow of the digit in the integer part of the number')
                    else
                    begin
                        if (argument * base >= maxDouble - arg_local) or (argument >= maxDouble / base) then
                            finByMistake('Input Error, overflow when entering, too large number is entered');
                        argument := argument * base + arg_local;
                    end;
                    arg_local := 0;
                    read(c);
                    if (ord(c) = ord(' ')) then
                    begin
                        read(c);
                        continue;
                    end;
                    if (checkingFor16(c)) then
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
                finByMistake('Input error, there must be a dot after the integer part of the number');
        end;

            {entering the fractional part of a number}
        if fl_dot and fl_operation and fl_znak and fl_base then
        begin
            if (checkingFor16(c)) then
            begin
                i := 1;
                while (ord(c) <> 10) do
                begin
                    read(d);
                    if (checkingFor16(c) and checkingFor16(d)) then
                    begin
                        if ((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) then
                            arg_local := arg_local + 16 * (ord(c) - ord('0'))
                        else
                            arg_local := arg_local + 16 * (10 + ord(c) - ord('a'));
                        if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
                            arg_local := arg_local + (ord(d) - ord('0'))
                        else
                            arg_local := arg_local + 10 + (ord(d) - ord('a'));
                    end
                    else
                        finByMistake('Input error, incorrect input of the fractional part of a number');

                    if (arg_local >= base) then
                        finByMistake('Input error, overflow of the digit in the fractional part of the number')
                    else
                    begin
                        argument := argument + arg_local / exp(i * LN(base));
                    end;
                    arg_local := 0;
                    i := i + 1;
                    read(c);
                    if (ord(c) = ord(' ')) then
                        while (ord(c) = ord(' ')) do
                            read(c);
                    if (ord(c) = ord('#')) then
                    begin
                        fl_comment := true;
                        break;
                    end;
                    if (checkingFor16(c)) then
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
                finByMistake('Input error, the fractional part of the number is not entered');
        end;
    until (ord(c) = 10) or (fin = true);
end;

(*  write result with formatting to output *)
procedure mainFinish();
var
    integerPartRes, fractionalPartRes :double;
    i :int64;
begin
    (*  take before and after dot result parts *)
    integerPartRes := int(result);
    fractionalPartRes := result - integerPartRes;
    (*  write output wit formatting *)
    for i:=2 to ParamCount do
    begin
        write(out_base[i]:3, ':  ');
        if (res_sign = false) then
            write('-');
        writeResultBeforeDot(out_base[i], integerPartRes);
        write('. ');
        writeResultAfterDot(out_base[i], accuracy, fractionalPartRes);
        writeln;
    end;
end;

begin
    (*  read initialize parameters *)
    mainReadInit(accuracy, out_base);
    (*  main cycle of program *)
    while true do
    begin
        mainReadInput(arg_operation, arg_sign, argument, fin);
        (*  if finish command found *)
        if fin then
        begin
            mainFinish();
            writeln;
            halt(0);
        end
                (*  processing operations *)
        else
            case arg_operation of
                '+' :mainAdding(result, argument, res_sign, arg_sign);
                '*' :mainMultiplicate(result, argument, res_sign, arg_sign);
                '/' :mainDivision(result, argument, res_sign, arg_sign);
                '-' :
                begin
                    (*  poor the water out of kettle. change sign for add use *)
                    if arg_sign = false then
                        arg_sign := true
                    else
                        arg_sign := false;
                    mainAdding(result, argument, res_sign, arg_sign);
                end;
            end;
    end;
    writeln;
end.