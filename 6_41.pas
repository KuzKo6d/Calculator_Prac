program main;
uses crt, sysutils, math;

type DynArrInt = array of integer;

var ArrayOfAnsBases: DynArrInt;
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
i, p:integer;
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

procedure mainReadInput(var operation: char; var znak: boolean; var chislo: double; var fin: integer); //fin 0 - succesefull input, fin - 1 word 'finish' appeared, fin - 2 mistake of input 
var base, i , fin_fl, num:integer;
fl_operation, fl_znak, fl_base, fl_dot:boolean;
c, d: char;
operation_str:string;
begin
	operation_str:='+-*/';
	fl_operation:=false;
	fl_dot:=true;
	fl_znak:=true;
	fl_base:=true;
	fin_fl:=0;
	fin:=0;
	base:=0;
	chislo:=0;
	repeat
		num:=0;
		read(c);
		//check fin
		if ((ord(c) = ord('f')) and (fin_fl = 0)) then
			fin_fl:=1;
			
		if ((ord(c) = ord('i')) and (fin_fl = 1)) then
		begin
			fin_fl:=2;
			continue;
		end
		else
		begin
			fin:=2;
			fin_fl:=0;
		end;
		
		if ((ord(c) = ord('n')) and (fin_fl = 2)) then
		begin
			fin_fl:=3;
			continue;
		end
		else
		begin
			fin:=2;
			fin_fl:=0;
		end;
			
		if ((ord(c) = ord('i')) and (fin_fl = 3)) then
		begin
			fin_fl:=4;
			continue;
		end
		else
		begin
			fin:=2;
			fin_fl:=0;
		end;
			
		if ((ord(c) = ord('s')) and (fin_fl = 4)) then
			fin_fl:=5
		else
			fin:=2;
			
		if ((ord(c) = ord('h')) and (fin_fl = 5)) then
		begin
			fin:=1;
			continue;
		end
		else
		begin
			fin:=2;
			fin_fl:=0;
		end;
		
		//check backspase and skip all
		if (ord(c) = ord(' ')) then
			continue;
		
		if not(fl_operation) then //input before doubledot
			if (pos(c, operation_str) <> 0) then
			begin
				fl_operation:=true;
				fl_base:=false;
				operation:=c;
			end
			else
				fin:=2;
		
		if not(fl_base) then //input base
			if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
				base:=base*10 + (ord(c) - ord('0'))
			else
				if ord(c) = ord(':') then
				begin
					fl_base:=true;
					fl_znak:=false;
				end
				else
					fin:=2;
		
				
				
		if not(fl_znak) then //input of sign
			case c of
				'+':
				begin
					znak:=true;
					fl_znak:=true;
					fl_dot:=true;
				end;
				'-':
				begin
					znak:=false;
					fl_znak:=true;
					fl_dot:=true;
				end
			else
				fin:=2;
		end;
			//input after sign, to dot
		
		if not(fl_dot) then
		begin
		if (ord(c) = '.') then
			fl_dot:=true
		else
		begin
			read(d);
			if ((ord(c) = ord('f')) and (ord(d) = ord('i'))) then
				fin_fl:=2
			else
				fin_fl:=0;
			if (proverkana16(c) and proverkana16(d)) then
			begin
				if ((ord(c)>=ord('0')) and (ord(c)<=ord('9'))) then
					num:=16*(ord(c) - ord('0'))
				else
					num:=16*(ord(c) - ord('a'));
				if ((ord(d)>=ord('0')) and (ord(d)<=ord('9'))) then
					num:=(ord(d) - ord('0'))
				else
					num:=(ord(d) - ord('a'));
				if (num >= base) then
					fin:=2
				else
					chislo:=chislo*base+num;
			end
			else
				fin:=2;
		end;
		
		
				
				
			
		end;
					
				
		
		if (fin = 1) or ((fin = 2) and (fin_fl = 0)) then 
			exit; //exit because finish or mistake found
			
			
	until ord(c) = 10; 

end;

begin
  writeln('hello world');
  readln;
end.
