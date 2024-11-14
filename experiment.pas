program experiment;
type
    start_args = packed array of integer;

procedure writeResultBeforeDot(base :int64; res_int_part :double);
var
    k, i :int64;
    sub_res, prev_res :double;
    fin_res :start_args;
begin
    sub_res := res_int_part;
    k := 0;
    (*  if result is zero *)
    if res_int_part = 0 then
    begin
        write('00 ');
        exit;
    end;

    setlength(fin_res, k);
    while sub_res <> 0 do
    begin
        fin_res[i] := sub_res mod base;
        sub_res := sub_res div base;
    end;

    for i:=k downto 1 do
    begin
        writeln('fin_res[i]: ', fin_res[i]);
    end;
end;

begin
    writeResultBeforeDot(10, 256);
    writeResultBeforeDot(2, 256);
end.