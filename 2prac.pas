program main;
uses crt, sysutils, math;

type DynArrInt = array of integer;

var 
i: integer;
res_sign: boolean = true;
result: double = 0;
arg_operation: char;
arg_sign: boolean;
argument: double;
fin: boolean = false;
// init block
ArrayOfAnsBases: DynArrInt;
epsilon: double; {accuracy}

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

procedure mainFinish(sign:boolean; result: double; accuracy: double; var out_base: DynArrInt);
begin
end;

procedure mainReadInit(var A: DynArrInt; var accurasy:double);
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

function proverkana16(c:char):boolean;
begin
	proverkana16:=false;
	if (((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) or ((ord(c)>=ord('a')) and (ord(c)<=ord('f')))) then
		proverkana16:=true;
end;

procedure finByMistake(sign:boolean; result:double; accuracy:double; var arr: DynArrInt);
begin
	writeln('The program terminated due to an input error, the last result received:');
	mainFinish(sign, result, accuracy, arr);
end;

procedure mainReadInput(var operation: char; var znak: boolean; var chislo: double; var fin: boolean); 
var base, i , fin_fl, num:integer;
fl_operation, fl_znak, fl_base, fl_dot, prev_znak, fl_comment:boolean;
c, d: char;
operation_str:string;
prev_res:double;
begin
	prev_res:=chislo;
	prev_znak:=znak;
	operation_str:='+-*/';
	fl_operation:=false;
	fl_dot:=true;
	fl_znak:=true;
	fl_base:=true;
	fl_comment:=false;
	chislo:=0;
	znak:=true;
	fin_fl:=0;
	fin:=false;
	base:=0;
	repeat
		num:=0;
		read(c);
		
		{checking the line for comments}
		if ord(c) = ord('#') then
			fl_comment:=true;
			
		
		{the condition for skipping all spaces and tabs, or if its comment}
		if ((ord(c) = ord(' ')) or (ord(c) = 9) or (fl_comment)) then
			continue;
		
		{entering the operation sign or checking the first significant character of the string at the beginning of the word finish}
		if not(fl_operation) then 
		begin
			if (pos(c, operation_str) <> 0) then
			begin
				fl_operation:=true;
				fl_base:=false;
				operation:=c;
				continue;
			end
			else
			begin
				if ord(c) = ord('f') then
				begin
					fin_fl:=1;
					continue;
				end
				else
			
					if ((ord(c) = ord('i')) and (fin_fl = 1)) then
					begin
						fin_fl:=2;
						continue;
					end
					else

						if ((ord(c) = ord('n')) and (fin_fl = 2)) then
						begin
							fin_fl:=3;
							continue;
						end
						else
					
							if ((ord(c) = ord('i')) and (fin_fl = 3)) then
							begin
								fin_fl:=4;
								continue;
							end
							else
					
								if ((ord(c) = ord('s')) and (fin_fl = 4)) then
								begin
									fin_fl:=5;
									continue;
								end
								else
					
									if ((ord(c) = ord('h')) and (fin_fl = 5)) then
									begin
										fin:=true;
										continue;
									end
									else
										finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
			end;
		end;
				
		{entering the number system}
		if not(fl_base) then 
		begin
			if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
			begin
				while (ord(c) <> ord(':')) do
				begin
					base:=base*10 + (ord(c) - ord('0'));
					read(c);
					if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
						continue
					else
						break;
				end;
			end;
			if (ord(c) = ord(':')) and (base <> 0) then
			begin
				fl_base:=true;
				fl_znak:=false;
				continue;
			end
			else
				finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
		end;
		
				
		{entering a number sign}	
		if not(fl_znak) then //input of sign
			case c of
				'+':
				begin
					znak:=true;
					fl_znak:=true;
					fl_dot:=false;
					continue;
				end;
				'-':
				begin
					znak:=false;
					fl_znak:=true;
					fl_dot:=false;
					continue;
				end
			else
				finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
		end;
		
		{entering an integer part of a number}
		i:=0;
		
		if not(fl_dot) then
		begin
			if (proverkana16(c)) then
			begin
				while (ord(c) <> ord('.')) do
				begin
					i:=i+1;
					read(d);
					if (proverkana16(c) and proverkana16(d)) then
					begin
						if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
							num:=num + 16*(ord(c) - ord('0'))						
						else
							num:=num + 16*(ord(c) - ord('a'));
						if ((ord(d)>=ord('0')) and (ord(d)<=ord('9'))) then
							num:=num + (ord(d) - ord('0'))
						else
							num:=num + (ord(d) - ord('a'));
					end
					else
						finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
					
					if (num >= base) then
						finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases)
					else
					begin
						chislo:=chislo*base+num;
					end;
					num:=0;
					read(c);
					if (proverkana16(c)) then
						continue
					else
						break;
				end;
			end;
			if ((ord(c) = ord('.')) and (i <> 0)) then
			begin
				fl_dot:=true;
				i:=0;
				continue;
			end
			else
				finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
		end;
		
		{entering the fractional part of a number}
		if fl_dot and fl_operation and fl_znak and fl_base then
		begin
			if (proverkana16(c)) then
			begin
				i:=1;
				while (ord(c) <> 10) do
				begin
					read(d);
					if (proverkana16(c) and proverkana16(d)) then
					begin
						if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
							num:=num + 16*(ord(c) - ord('0'))						
						else
							num:=num + 16*(ord(c) - ord('a'));
						if ((ord(d)>=ord('0')) and (ord(d)<=ord('9'))) then
							num:=num + (ord(d) - ord('0'))
						else
							num:=num + (ord(d) - ord('a'));
					end
					else
						finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
					
					if (num >= base) then
						finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases)
					else
					begin
						chislo:=chislo + num / exp(i * LN(base));
					end;
					num:=0;
					i:=i+1;
					read(c);
					if (proverkana16(c)) then
						continue
					else
						break;
				end;
			end;
			if (ord(c) = ord('#')) then
			begin
				fl_comment:=true;
			end;
			if ((ord(c) = 10) and (i <> 0)) then
			begin
				i:=0;
				continue;
			end
			else
				finByMistake(prev_znak, prev_res, epsilon, ArrayOfAnsBases);
		end;
	until (ord(c) = 10) or (fin = true); 

end;

begin
	//fin:=true;
	mainReadInput(arg_operation,arg_sign,result,fin);
	if (fin = true) then
		writeln('finish found');
	writeln('Введеннео число ', result:5:5);
	writeln('hello world');
	readln;
end.
