require "parser.rb"

def test tree, expected
  exp = expected.flatten
  tree.flatten.each do |t|
    exp.shift.should == t
  end
end

ASSIGN_TKN = Token.new(:_=, '_=')
ADD_TKN = Token.new(:add, "add")
 
describe Parser, "正しいソースコードを読み込んだ時." do
  before do

  end

  it "Hello Worldをパースできる" do
    src = "program hello;\nbegin\n   writeln('Hello World.');\nend"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [] ],                
                Token("begin"),
                [
                 [Token("writeln"), Token("'Hello World.'")]
                ],
                Token("end")
               ]
    
    tree.should == expected
  end

  it "変数扱ったコードをパースできる" do
    src = "program hello;\nvar\n   msg : String;\nbegin\n   msg := 'Hello World.';\n   writeln( msg );\nend"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [
                                [Token("msg"), Token(":"), Token("String"), Token(";")]
                               ]
                ],
                Token("begin"),
                [
                 [ASSIGN_TKN, Token("msg"), Token("'Hello World.'")],
                 [Token("writeln"), Token("msg")]
                ],
                Token("end")
               ]
    
    tree.should == expected

  end

  it "数式を扱ったコードをパースできる" do
    src = "program hello;\nvar\n   num : Integer;\nbegin\n   num := 3 * (2 + 1);\n   writeln(num);   \nend"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [
                                [Token("num"), Token(":"), Token("Integer"), Token(";")]
                               ]
                ],
                Token("begin"),
                [
                 [ASSIGN_TKN, Token("num"), [Token.new(:mul, "mul"), Token("3"), [ADD_TKN, Token("2"), Token("1")]]],
                 [Token("writeln"), Token("num")]
                ],
                Token("end")
               ]
    
    tree.should == expected

  end

    it "代入式の右辺での関数呼び出しを扱ったコードをパースできる" do
    src = "program hello;\nvar\n   x : Integer;\nbegin\n   x := f(3);end"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [
                                [Token("x"), Token(":"), Token("Integer"), Token(";")]
                               ]
                ],
                Token("begin"),
                [
                 [ASSIGN_TKN, Token("x"), [Token("f"), Token("3")]]
                ],
                Token("end")
               ]
    test tree, expected
    tree.should == expected
  end

  it "ifを扱ったコードをパースできる" do
    src = "program hello;var flg:Integer; msg : String; begin flg:= 0; if flg = 1 then msg := 'Hello World' else msg := '>_<'; writeln( msg ); end"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [
                                [Token("flg"), Token(":"), Token("Integer"), Token(";")],
                                [Token("msg"), Token(":"), Token("String"), Token(";")]                                
                               ]
                ],
                Token("begin"),
                [
                 [ASSIGN_TKN, Token("flg"), Token("0")],
                 [Token('if'), [Token('='), Token("flg"), Token("1")], Token("then"),
                  [ASSIGN_TKN, Token("msg"), Token("'Hello World'")],
                  Token("else"),
                  [ASSIGN_TKN, Token("msg"), Token("'>_<'")]
                 ],
                 [Token("writeln"), Token("msg")]
                ],
                Token("end")
               ]
    
    test tree, expected        
    tree.should == expected
  end

  it "ブロックを扱ったコードをパースできる" do
    src = "program hello;\nbegin\n   begin\n      writeln('Hello');\n      writeln('World');\n   end;\nend"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [] ],
                Token("begin"),
                [
                 [Token("begin"),
                  [
                   [Token("writeln"), Token("'Hello'")],
                   [Token("writeln"), Token("'World'")]                  
                  ],
                  Token("end")]
                ],
                Token("end")
               ]
    test tree, expected
    tree.should == expected    
  end

  it "whileを扱ったコードをParseできる" do
    src = "program hello;\nvar\n   i : Integer; begin i := 0;\n   while i < 10 do\n   begin i := i + 1;  writeln(i);  end;end"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), [
                                [Token("i"), Token(":"), Token("Integer"), Token(";")]
                               ]
                ],                
                Token("begin"),
                [
                 [ASSIGN_TKN, Token("i"), Token("0")],                 
                 [Token('while'), [Token('<'), Token("i"), Token("10")], Token("do"),
                  [Token("begin"),
                   [
                    [ASSIGN_TKN, Token("i"), [ADD_TKN, Token("i"), Token("1")]],
                    [Token("writeln"), Token("i")]                  
                   ],
                   Token("end")]
                 ]
                ],
                Token("end")
               ]
    test tree, expected
    tree.should == expected    
  end
  
  it "functionを扱ったコードをParseできる" do
    src = "program hello;  function echo(msg:String):String;var i:Integer; begin i:= 123;writeln(i); end begin echo('hello world.'); end"

    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [
                 [Token("function"), Token("echo"), [[Token("msg"), Token("String")]], Token("String"),
                  [Token("var"), [
                                  [Token("i"), Token(":"), Token("Integer"), Token(";")]
                                 ]
                  ],
                  [
                   [ASSIGN_TKN, Token("i"), Token("123")],                   
                   [Token("writeln"), Token("i")]
                  ]
                 ]
                ],
                [Token("var"), [] ],
                Token("begin"),
                [
                 [Token("echo"), Token("'hello world.'")]
                ],
                Token("end")
               ]
    test tree, expected
    tree.should == expected    
  end          
=begin
     
  it "String DOT IDENT をパースできる" do
    src = "program hello;\nbegin\n 'Hello World.'.length;\n   writeln( msg );\nend"
    tree = Parser.new(src).parse
    expected = [Token("program"), Token("hello"), Token(";"),
                [],
                [Token("var"), []
                ],
                Token("begin"),
                [
                 [Token("'Hello World.'"), Token("'.'"), Token("length")],
                ],
                Token("end")
               ]
    
    tree.should == expected

  end
=end
  it "ParseExceptionは発生しない" do
    src = "program hello;\nvar\n   num : Integer;\nbegin\n   num := 3 * (2 + 1);\n   writeln(num);   \nend"
    lambda{ Parser.new(src).parse }.should_not raise_error( ParseException )
  end  

end

describe Parser, "構文エラーのあるソースを読み込んだ時" do
  before do

  end

  it "ParseExceptionが発生する" do
    lambda{
      src = "program hello\nbegin\n   writenln('Hello World.')\nend"
      Parser.new(src).parse
    }.should raise_error( ParseException )

    lambda{
      src = "program hello\nbegin\n   writenln('Hello World.');\n"
      Parser.new(src).parse
    }.should raise_error( ParseException )
  end  

end

