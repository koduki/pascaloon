program hello;
var
   flg : Integer;
   msg : String;
begin
   flg := 0;
   if flg = 1 then msg := 'Hello World' else msg := '>_<';
   writeln( msg );

   flg := 1;
   if flg = 1 then msg := 'Hello World' else msg := '>_<';
   writeln( msg );   
end