program fibonacci;

function fib(n :Integer ):Integer;
begin
   if n = 0 then
      result := 1
   else if n = 1 then
      result := 2
   else
   begin
      result := fib(n-1) + fib(n-2);
   end;
end

begin
   writeln( fib(3) );
end
