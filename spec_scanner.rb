require "scanner.rb"

describe Token,"Tokenの同値比較について" do
  it "token(:String, abc) == token(:String, abc) should be true" do
    Token("'abc'").should == Token.new(:String, "abc")
  end

  it "token(:String, abc) == token(:Integer, 123) should be false" do
    Token("'abc'").should_not == Token("123")
  end
  
  it "token(:String, abc) == token(:IDENT, abc) should be false" do
    Token("'abc'").should_not == Token("abc")
  end
end

describe Token,"Tokenメソッドの変換する時" do
  it "identは文字列から始まる英数文字" do
    Token("test2") .should == Token.new(:IDENT, "test2")
  end

end

describe Scanner do
  it "test := 2; # test, :=, 2" do
    sc = Scanner.new('test := 2')
    sc.next.value .should == "test"
    sc.next.value .should == ":="
    sc.next.value .should == 2    
  end

  it "(1+2)-3; # (, 1, +, 2, ), -, 3,;" do
    sc = Scanner.new('(1+2)-3;')
    sc.next.value .should == "("
    sc.next.value .should == 1
    sc.next.value .should == "+"
    sc.next.value .should == 2
    sc.next.value .should == ")"
    sc.next.value .should == "-"
    sc.next.value .should == 3
    sc.next.value .should == ";"
  end

  it "has_next?は次のTokenが無い時にfalse, それ以外でtrue" do
    sc = Scanner.new('test := 2')
    sc.has_next? .should == true
    sc.next
    sc.has_next? .should == true    
    sc.next
    sc.has_next? .should == true    
    sc.next
    sc.has_next? .should == false    
  end

  it "preveを使えば一つ前のTokenに戻る" do
    sc = Scanner.new('test := 2')
    sc.has_next? .should == true
    sc.next
    sc.has_next? .should == true    
    sc.next
    sc.has_next? .should == true    
    sc.next.value.should == 2
    sc.has_next? .should == false
    sc.prev.value.should == 2
    sc.has_next? .should == true
    sc.next.value.should == 2    
  end

  it "コメント行(//)は無視する" do
    sc = Scanner.new("test 2//Hello World ; test\nfoobar")
    sc.next.value .should == "test"
    sc.next.value .should == 2
    sc.next.value .should == "foobar"
  end
end

