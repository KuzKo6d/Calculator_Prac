program main;
uses crt, sysutils, math;

type DynArrInt = array of integer;

var res_sign: boolean = true;
	res: double = 0;
	arg_operation: char;
	arg_sign: boolean;
	num: double;
	fin: boolean = false;
	epsilon: double;
	arrayOfAnsBases: DynArrInt;

procedure mainFinish(res_sign: boolean; res: double; epsilon: double; var arrayOfAnsBases: DynArrInt); forward;

{called in case of an error, outputs the last result received}
procedure finByMistake(res: double; epsilon: double; var arr: DynArrInt);
begin
	writeln('The last result received:');
	mainFinish(res_sign, res, epsilon, arr);
	halt(0);
end;

{auxiliary addition that checks for overflow}
procedure subAdding(var res: double; arg: double);
begin
	if (res <= maxDouble - arg) then  {overflow check}
		res:= res + arg
	else
	begin
		writeln('Overflow of the result, when adding the value went beyond the double type');
		finByMistake(res, epsilon, arrayOfAnsBases);
	end;
end;

{auxiliary multiplication checking for overflow}
procedure subMultiplicate(var res:double; arg: double);
begin
	if (arg=0) then
	begin
		res:=0;
		res_sign:=true;
	end
	else 
	if (res >= minDouble / arg) and (res <= maxDouble / arg) then {overflow check}
		res := res * arg
	else
	begin
		writeln('Overflow of the result, when multiplying the value went beyond the double type');
		finByMistake(res, epsilon, arrayOfAnsBases);
	end;
end;

{auxiliary division that checks overflow and the case of division by zero}
procedure subDivision(var res: double; arg: double);
begin
	if arg = 0 then {checking division by zero}
	begin
		writeln('Incorrect result, division by zero is prohibited!');
		finByMistake(res, epsilon, arrayOfAnsBases);
	end
	else 
	if (res >= minDouble * arg) and (res <= maxDouble * arg) then {overflow check}
		res := res / arg
	else
	begin
		writeln('Overflow of the result, when dividing, the value went beyond the boundaries of the double type');
		finByMistake(res, epsilon, arrayOfAnsBases);
	end;
end;

{the main addition, which performs addition or subtraction depending on the characters of the entered number and the result}
procedure mainAdding(var res: double; num: double; var res_sign: boolean; num_sign: boolean);
begin
	if (res_sign and num_sign) or (not(res_sign) and not(num_sign)) then
		subAdding(res, num)
	else
	begin
		if res > num then
		begin
			res := res - num;
			if res_sign < num_sign then
				res_sign := false;
		end
		else
		begin
			res := res - num;
			if res_sign > num_sign then
				res_sign := false;
		end;
	end;
end;

{the main multiplication, which produces addition or subtraction depending on the characters of the entered number and the result}
procedure mainMultiplicate(var res: double; num: double; var res_sign: boolean; num_sign: boolean);
begin
	if (res_sign and num_sign) or (not(res_sign) and not(num_sign)) then
		res_sign := true
	else
		res_sign := false;
	subMultiplicate(res, num);
end;

{the main division, which performs addition or subtraction depending on the characters of the entered number and the result}
procedure mainDivision(var res: double; num: double; var res_sign: boolean; num_sign: boolean);
begin
	if (res_sign and num_sign) or (not(res_sign) and not(num_sign)) then
		res_sign := true
	else
		res_sign := false;
	subDivision(res, num);
end;

{checks whether the stock is an integer}
function is_int(s:string):boolean;
var i:integer;
begin
	is_int:= true;
	if length(s) = 0 then
		is_int := false;
	for i:=1 to length(s) do
		if not((ord('0') <= ord(s[i])) and (ord('9') >= ord(s[i]))) then
		begin
			is_int:=false;
			break;
		end;
end;

{checks whether the stock is a real number}
function is_double(s:string):boolean;
var s1, s2: string;
p:integer;
begin
	is_double:= true;
	p:=pos('.', s);
	if p = 0 then
	begin
		is_double:=false;
		exit;
	end;
	s1:=copy(s, 1, pos('.', s) - 1);
	s2:=copy(s, pos('.', s)+1, length(s) - pos('.', s));
	if not(is_int(s1) and is_int(s2)) then
		is_double:=false
end;

{enters a command line parameter and handles all exceptional scenarios}
procedure mainReadInit(var accurasy:double; var A: DynArrInt);
var kol, i :integer; 
begin
	kol:=ParamCount();
	if kol < 2 then
	begin
		writeln('Incorrect number of parameters. There must be more than 1 parameters!');
		halt(1);
	end;
	if not(is_double(ParamStr(1))) then
	begin
		writeln('Incorrect type of first parameter. The first parameter must be a real number!');
		halt(1);
	end
	else
		accurasy:=strtofloat(ParamStr(1));
	if (accurasy < 0) or (accurasy>=1) then
	begin
		writeln('Incorrect value of epsilon. Epsilon must be begger than 0 and lower than 1');
		halt(1);
	end;
	for i:=2 to kol do
	begin
		if not(is_int(ParamStr(i))) then
		begin
			writeln('Incorrect type of parameter. All parameters after the first must be integers!');
			halt(1);
		end;
	end;
	SetLength(A, kol-1);
	for i:=2 to kol do
		A[i]:=StrToInt(ParamStr(i));
end;

{checks whether a character is a hexadecimal number}
function checkingFor16(c: char): boolean;
begin
	checkingFor16 := false;
	if (((ord(c) >= ord('0')) and (ord(c) <= ord('9'))) or ((ord(c) >= ord('a')) and (ord(c) <= ord('f')))) then
		checkingFor16 := true;
end;

{reads the input data, splits it into the required parts and handles all exceptional situations}
procedure mainReadInput(var operation: char; var res_sign: boolean; var res_num: double; var fin: boolean);
var
	base, i, fin_fl: int64;
	fl_operation, fl_znak, fl_base, fl_dot, fl_comment: boolean;
	c, d: char;
	operation_str: string;
	num:double;
begin
	operation_str := '+-*/';
	fl_operation := false;
	fl_dot := true;
	fl_znak := true;
	fl_base := true;
	fl_comment := false;
	res_num := 0;
	res_sign := true;
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
		if ((ord(c) = ord(' ')) or (ord(c) = 9) or (fl_comment) or (ord(c) = 10)) then
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
									begin
										writeln('An input error, an incorrect character was encountered');
										finByMistake(res, epsilon, arrayOfAnsBases);
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
			begin
				writeln('Input error, the number system must represent an integer from 2 to 256');
				finByMistake(res, epsilon, arrayOfAnsBases);
			end;
			if (ord(c) = ord(':')) and (base <> 0) then
			begin
				fl_base := true;
				fl_znak := false;
				read(d);
				if (ord(d) <> ord(' ')) then
				begin
					writeln('Input error, a space is required after the colon');
					finByMistake(res, epsilon, arrayOfAnsBases);
				end;
				continue;
			end
			else
			begin
				writeln('Input error, the number system must represent an integer from 2 to 256');
				finByMistake(res, epsilon, arrayOfAnsBases);
			end;
		end;


		{entering a number sign}
		if not(fl_znak) then 
		begin
			case c of
				'+':
				begin
					res_sign := true;
					fl_znak := true;
					fl_dot := false;
					continue;
				end;
				'-':
				begin
					res_sign := false;
					fl_znak := true;
					fl_dot := false;
					continue;
				end
			else
				if checkingFor16(c) then
				begin
					res_sign := true;
					fl_znak := true;
					fl_dot := false;
				end
				else
				begin
					writeln('Input error, the number sign is entered incorrectly');
					finByMistake(res, epsilon, arrayOfAnsBases);
				end;
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
					if ((ord(c) = ord(' ')) or (ord(c) = 10) or (ord(c) = 9)) then
					begin
						read(c);
						continue;
					end;
					i := i + 1;
					read(d);
					if (checkingFor16(c) and checkingFor16(d)) then
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
					begin
						writeln('Input error, incorrect input of an integer part of a number');
						finByMistake(res, epsilon, arrayOfAnsBases);
					end;

					if (num >= base) then
					begin
						writeln('Input error, overflow of the digit in the integer part of the number');
						finByMistake(res, epsilon, arrayOfAnsBases);
					end
					else
					begin
						if (res_num * base >= exp(40 * LN(10)) - num) or (res_num >= exp(40 * LN(10)) / base) then
						begin
							writeln('Input Error, overflow when entering, too large number is entered');
							finByMistake(res, epsilon, arrayOfAnsBases);
						end;
						res_num := res_num * base + num;
					end;
					num := 0;
					read(c);
					if ((ord(c) = ord(' ')) or (ord(c) = 10) or (ord(c) = 9)) then
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
			begin
				writeln('Input error, there must be a dot after the integer part of the number');
				finByMistake(res, epsilon, arrayOfAnsBases);
			end;
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
							num := num + 16 * (ord(c) - ord('0'))
						else
							num := num + 16 * (10 + ord(c) - ord('a'));
						if ((ord(d) >= ord('0')) and (ord(d) <= ord('9'))) then
							num := num + (ord(d) - ord('0'))
						else
							num := num + 10 + (ord(d) - ord('a'));
					end
					else
					begin
						writeln('Input error, incorrect input of the fractional part of a number');
						finByMistake(res, epsilon, arrayOfAnsBases);
					end;

					if (num >= base) then
					begin
						writeln('Input error, overflow of the digit in the fractional part of the number');
						finByMistake(res, epsilon, arrayOfAnsBases);
					end
					else
					begin
						res_num := res_num + num / exp(i * LN(base));
					end;
					num := 0;
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
			begin
				writeln('Input error, the fractional part of the number is not entered');
				finByMistake(res, epsilon, arrayOfAnsBases);
			end;
		end;
	until ((ord(c) = 10) and (fl_dot and fl_operation and fl_znak and fl_base)) or (fin = true);
end;

{converting a number to a hexadecimal number system}
procedure transferTo16(res:int64);
var first, second: char;
begin
	if (res > 16) then
	begin
		if (res div 16 < 9) then
			first:=chr(ord('0') + (res div 16))
		else
			first:=chr(ord('a') + (res div 16) - 10);
		if (res mod 16 <= 9) then
			second:=chr(ord('0') + (res mod 16))
		else
			second:=chr(ord('a') + (res mod 16) - 10);
	end
	else
	begin
		first:='0';
		if (res mod 16 <= 9) then
			second:=chr(ord('0') + (res mod 16))
		else
			second:=chr(ord('a') + (res mod 16) - 10);
	end;	
	write(first, second, ' ');
end;

{converting a number to the required number system with a base from 2 to 256 and output in the required form}
procedure transferToCustom(res:double; base:int64);
var k, i:int64;
sub_res, prev_res:double;
fin_res:DynArrInt;
begin
	sub_res:=res;
	k:=0;
	if res = 0 then
		k:=1;
	while (sub_res > 0) do
	begin
		sub_res:=int(sub_res/base); 
		k:=k+1;
	end;
	sub_res:=res;
	setlength(fin_res, k);
	for i:=k downto 1 do
	begin
		prev_res:=sub_res;
		sub_res:=int(prev_res/base); {div}
		fin_res[i]:=trunc(prev_res-sub_res*base); {mod}
	end;
	for i:=1 to k do
	begin
		transferTo16(fin_res[i]);
	end;
	
end;

{determining the number of decimal places depending on the entered precision}
procedure checkingTheAccuracy(base:int64;var count:int64; epsilon, fractionalPartRes:double);
var temp_res, temp_epsilon, changed_num, shifted_num:double;
begin
	shifted_num:=0;
	changed_num:=int(base * fractionalPartRes);
	temp_res:=(base - 1) + base * fractionalPartRes - int(base * fractionalPartRes);
	temp_epsilon:=epsilon * base;
	count:=1;
	while (temp_res > temp_epsilon) do
	begin
		count:=count + 1;
		shifted_num:=shifted_num + base*changed_num;
		changed_num:=int(base * (temp_res - base +1)) - shifted_num*base;
		temp_res:=(base - 1) + base * temp_res - int(base * temp_res) + shifted_num;
		temp_epsilon:=temp_epsilon * base;
	end;	
end;

{converting the fractional part of a number into a number system with a base from 2 to 256 and output in the required form}
procedure transferToCustomAfterDot(base: integer; epsilon, fractionalPartRes: double);
var count, i: int64;
begin
	count:=0;
	if (fractionalPartRes = 0) or (fractionalPartRes > epsilon)  then
	begin
		write('00');
		exit;
	end
	else
	begin
		checkingTheAccuracy(base, count, epsilon, fractionalPartRes); {counting the number of digits in the fractional part}
	end;
	for i:=1 to count do
	begin
		fractionalPartRes:=(fractionalPartRes*base);
		transferTo16((trunc(fractionalPartRes)));
		write(' ');
		fractionalPartRes:=(fractionalPartRes-(int(fractionalPartRes)));
	end;
end;

{ends the program if it encounters the word finish or an error}
procedure mainFinish(res_sign: boolean; res: double; epsilon: double; var arrayOfAnsBases: DynArrInt);
var
	integerPartRes, fractionalPartRes: double;
	i: int64;
begin
	fractionalPartRes := res - (int(res));
	integerPartRes := int(res);
	{output with formatting}
	for i:=2 to ParamCount do
	begin
		if (arrayOfAnsBases[i] <= 9) then
		begin
			write(arrayOfAnsBases[i], '     ');
			if (res_sign = false) then
				write('-');
			transferToCustom(integerPartRes, arrayOfAnsBases[i]);
			write(' . ');
			transferToCustomAfterDot(arrayOfAnsBases[i], epsilon, fractionalPartRes);
			writeln;
		end;
		if ((arrayOfAnsBases[i] >= 10) and (arrayOfAnsBases[i] <= 99)) then
		begin
			write(arrayOfAnsBases[i], '    ');
			if (res_sign = false) then
				write('-');
			transferToCustom(integerPartRes, arrayOfAnsBases[i]);
			write(' . ');
			transferToCustomAfterDot(arrayOfAnsBases[i], epsilon, fractionalPartRes);
			writeln;
		end;
		if (arrayOfAnsBases[i] > 99) then
		begin
			write(arrayOfAnsBases[i], '   ');
			if (res_sign = false) then
				write('-');
			transferToCustom(integerPartRes, arrayOfAnsBases[i]);
			write(' . ');
			transferToCustomAfterDot(arrayOfAnsBases[i], epsilon, fractionalPartRes);
			writeln;
		end;
	end;
end;

begin
	{processing command line parameters}
	mainReadInit(epsilon, arrayOfAnsBases);
	{cycle until you find an error or the word finish}
	while true do
	begin
		mainReadInput(arg_operation, arg_sign, num, fin);
		{The word finish has been found}
		if fin then
		begin
			mainFinish(res_sign, res, epsilon, arrayOfAnsBases);
			writeln;
			halt(0);
		end
		{performing the operation}
		else
			case arg_operation of
				'+': mainAdding(res, num, res_sign, arg_sign);
				'*': mainMultiplicate(res, num, res_sign, arg_sign);
				'/': mainDivision(res, num, res_sign, arg_sign);
				'-':
				begin
				{let's change the sign of the input number and write the subtraction through addition}
					if arg_sign = false then
						arg_sign := true
					else
						arg_sign := false;
					mainAdding(res, num, res_sign, arg_sign);
				end;
			end;
	end;
	writeln;
end.
