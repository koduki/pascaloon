program hello;

function say_B():String;
begin
   writeln(test);   
   writeln(msg);
end

function say_A():String;
var
   msg	: String;
begin
   msg := 'Say1';
   say_B();
end

var
   test	: String;
begin
   test := 'global';
   say_A();
   say_B();
end

