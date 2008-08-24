program hello;
var
   i : Integer;
begin
   i := 1;
   while i <= 100 do
   begin
      if i % ( 3 * 5) = 0 then
	 writeln('FizzBuzz')
      else if i % 3 = 0 then
	 writeln('Fizz')
      else if i % 5 = 0 then
	 writeln('Buzz')
      else
	 writeln(i);
      
      i := i + 1;      
   end;
end