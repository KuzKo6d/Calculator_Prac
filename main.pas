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
{called in case of an error, outputs the last result received}
procedure finByMistake(exit_message :string);
begin
    writeln('Exit message: ', exit_message);
    writeln('The last result received:');
    mainFinish();
    halt(1);
end;

{auxiliary addition that checks for overflow}
function subAdding(result, arg :double) :double;
begin
    if (result <= maxDouble - arg) then  {overflow check}
        subAdding := result + arg
    else
        finByMistake('Overflow of the result, when adding the value went beyond the double type');
end;

{auxiliary multiplication checking for overflow}
function subMultiplicate(result, arg :double) :double;
begin
    if (arg = 0) then
    begin
        result := 0;
        res_sign := true;
    end
    else
        if (result >= minDouble / arg) and (result <= maxDouble / arg) then {overflow check}
            subMultiplicate := result * arg
        else
            finByMistake('Overflow of the result, when multiplying the value went beyond the double type');
end;

{auxiliary division that checks overflow and the case of division by zero}
function subDivision(result, arg :double) :double;
begin
    if arg = 0 then {checking division by zero}
        finByMistake('Incorrect result, division by zero is prohibited!')
    else
        if (result >= minDouble * arg) and (result <= maxDouble * arg) then {overflow check}
            subDivision := result / arg
        else
            finByMistake('Overflow of the result, when dividing, the value went beyond the boundaries of the double type');
end;

{the main addition, which performs addition or subtraction depending on the characters of the entered number and the result}
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

{the main multiplication, which produces addition or subtraction depending on the characters of the entered number and the result}
procedure mainMultiplicate(var result :double; argument :double; var res_sign :boolean; arg_sign :boolean);
begin
    if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
        res_sign := true
    else
        res_sign := false;
    result := subMultiplicate(result, argument);
end;

{the main division, which performs addition or subtraction depending on the characters of the entered number and the result}
procedure mainDivision(var result :double; argument :double; var res_sign :boolean; arg_sign :boolean);
begin
    if (res_sign and arg_sign) or (not(res_sign) and not(arg_sign)) then
        res_sign := true
    else
        res_sign := false;
    result := subDivision(result, argument);
end;

{checks whether the stock is an integer}
function is_int(s :string) :boolean;
var
    i :integer;
begin
    is_int := true;
    if length(s) = 0 then
        is_int := false;
    for i:=1 to length(s) do
        if not((ord('0') <= ord(s[i])) and (ord('9') >= ord(s[i]))) then
        begin
            is_int := false;
            break;
        end;
end;

{checks whether the stock is a real number}
function is_double(s :string) :boolean;
var
    s1, s2 :string;
    p :integer;
begin
    is_double := true;
    p := pos('.', s);
    if p = 0 then
    begin
        is_double := false;
        exit;
    end;
    s1 := copy(s, 1, pos('.', s) - 1);
    s2 := copy(s, pos('.', s) + 1, length(s) - pos('.', s));
    if not(is_int(s1) and is_int(s2)) then
        is_double := false
end;

{checks whether a character is a hexadecimal number}
function checkingFor16(c :char) :boolean;
begin
    checkingFor16 := false;
    if (((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or ((ord(c) >= ord('a')) and (ord(c) <= ord('f')))) then
        checkingFor16 := true;
end;

{converting a number to a hexadecimal number system}
procedure transferTo16(result :int64);
var
    first, second :char;
begin
    if (result > 16) then
    begin
        if (result div 16 < 9) then
            first := chr(ord('0') + (result div 16))
        else
            first := chr(ord('a') + (result div 16) - 10);
        if (result mod 16 <= 9) then
            second := chr(ord('0') + (result mod 16))
        else
            second := chr(ord('a') + (result mod 16) - 10);
    end
    else
    begin
        first := '0';
        //writeln('result mod 16: ', result mod 16);
        if (result mod 16 <= 9) then
            second := chr(ord('0') + (result mod 16))
        else
            second := chr(ord('a') + (result mod 16) - 10);
        //writeln(ord(second));
    end;
    write(first, second, ' ');
end;

{converting a number to the required number system with a base from 2 to 256 and output in the required form}
procedure transferToCustom(result :double; base :int64);
var
    k, i :int64;
    sub_res, prev_res :double;
    fin_res :start_args;
begin
    sub_res := result;
    k := 0;
    if result = 0 then
        k := 1;
    while (sub_res > 0) do
    begin
        sub_res := int(sub_res / base);
        k := k + 1;
    end;
    sub_res := result;
    setlength(fin_res, k);
    for i:=k downto 1 do
    begin
        prev_res := sub_res;
        sub_res := int(prev_res / base); {div}
        fin_res[i] := trunc(prev_res - sub_res * base); {mod}
    end;
    for i:=1 to k do
    begin
        transferTo16(fin_res[i]);
    end;

end;

{determining the number of decimal places depending on the entered precision}
procedure checkingTheAccuracy(base :int64; var count :int64; accuracy, fractionalPartRes :double);
var
    temp_res, temp_epsilon :double;
begin
    temp_res := (base - 1) + base * fractionalPartRes - int(base * fractionalPartRes);
    temp_epsilon := accuracy * base;
    count := 1;
    while temp_res > temp_epsilon do
    begin
        count := count + 1;
        temp_res := (base - 1) + base * temp_res - int(base * temp_res);
        temp_epsilon := temp_epsilon * base;
    end;
end;

{converting the fractional part of a number into a number system with a base from 2 to 256 and output in the required form}
procedure transferToCustomAfterDot(base :integer; accuracy, fractionalPartRes :double);
var
    count, i :int64;
begin
    count := 0;
    if (fractionalPartRes = 0)  then //or (fractionalPartRes < accuracy))
    begin
        write('00');
        exit;
    end
    else
    begin
        checkingTheAccuracy(base, count, accuracy, fractionalPartRes); {counting the number of digits in the fractional part}
    end;
    for i:=1 to count do
    begin
        fractionalPartRes := (fractionalPartRes * base);
        transferTo16((trunc(fractionalPartRes)));
        write(' ');
        fractionalPartRes := (fractionalPartRes - (int(fractionalPartRes)));
    end;
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
    operation_str, fin_str :string;
    arg_local :double;
begin
    operation_str := '+-*/';
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
            (*  check if operation *)
            if (pos(c, operation_str) <> 0) then
            begin
                fl_operation := true;
                fl_base := false;
                arg_operation := c;
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

{ends the program if it encounters the word finish or an error}
procedure mainFinish();
var
    integerPartRes, fractionalPartRes :double;
    i :int64;
begin
    fractionalPartRes := result - (int(result));
    integerPartRes := int(result);
    (*  write output wit formatting *)
    for i:=2 to ParamCount do
    begin
        write(out_base[i]: 3, ':  ');
        if (res_sign = false) then
            write('-');
        transferToCustom(integerPartRes, out_base[i]);
        write('. ');
        transferToCustomAfterDot(out_base[i], accuracy, fractionalPartRes);
        writeln;
    end;
end;

begin
    {processing command line parameters}
    mainReadInit(accuracy, out_base);
    {cycle until you find an error or the word finish}
    while true do
    begin
        mainReadInput(arg_operation, arg_sign, argument, fin);
        {The word finish has been found}
        if fin then
        begin
            mainFinish();
            writeln;
            halt(0);
        end
                {performing the operation}
        else
            case arg_operation of
                '+' :mainAdding(result, argument, res_sign, arg_sign);
                '*' :mainMultiplicate(result, argument, res_sign, arg_sign);
                '/' :mainDivision(result, argument, res_sign, arg_sign);
                '-' :
                begin
                    {let's change the sign of the input number and write the subtraction through addition}
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