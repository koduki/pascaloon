require "interpriter.rb"

describe Interpriter, "意味解析について" do
  it "正しいセマンティクを持つコードを与えた時には例外は発生しない" do
    src = "program hello;\nvar\n   msg : String;\nbegin\n   msg := 'Hello World.';\n   writeln( msg );\nend"
    tree = Parser.new(src).parse
    lambda{ Interpriter.new.semantic_analyze(tree) }.should_not raise_error(SemanticException)    
  end

  it "String, Integer以外の型を指定すると例外を発生" do
    src = "program hello;\nvar\n   msg : Hoge;\nbegin\n   msg := 'Hello World.';\n   writeln( msg );\nend"
    tree = Parser.new(src).parse
    lambda{ Interpriter.new.semantic_analyze(tree) }.should raise_error(SemanticException)        
  end
  
  it "実行部で未宣言の変数に代入しようとすると例外を発生" do
    src = "program hello;\nbegin\n  msg := 'Hello World.';\n   writeln( msg );\nend"
    tree = Parser.new(src).parse
    lambda{ Interpriter.new.semantic_analyze(tree) }.should raise_error(SemanticException)            
  end

  it "整数型に文字列型を代入しようとすると例外を発生" do
    src = "program hello;\nvar\n   msg : Integer;\nbegin\n   msg := 'Hello World.';\n   writeln( msg );\nend"    
    tree = Parser.new(src).parse
    lambda{ Interpriter.new.semantic_analyze(tree) }.should raise_error(SemanticException)                
  end

  it "文字列型に整数型を代入しようとすると例外を発生" do
    src = "program hello;\nvar\n   msg : String;\nbegin\n   msg := 2 + 3 * (3 - 2);\n   writeln( msg );\nend"    
    tree = Parser.new(src).parse
    lambda{ Interpriter.new.semantic_analyze(tree) }.should raise_error(SemanticException)                
  end      

end


