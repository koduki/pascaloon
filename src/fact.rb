program hello;

function fact(n :Integer ):Integer;
begin
  if n = 1 then
    result := n
  else
    result := n * fact(n-1);
end

begin 
   writeln( fact(5) );
end
