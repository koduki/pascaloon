require "scanner.rb"

class ParseException < Exception;end

class Parser

  def initialize input = nil
    @sc = Scanner.new(input) unless input == nil
  end

  def match? type
    token = @sc.next
    @sc.prev
    token.type == type
  end
  
  def take type
    token = @sc.next
    unless token.type == type
      raise ParseException.new("expected\t: #{ type.to_s }\ngot\t\t: #{token.type.to_s + ", " + token.value.to_s}")
    end
    token
  end

  def parse
    b_program
  end

  def b_program
    [take(:PROGRAM),
     b_ident,
     take(:SEMICOLON),
     b_funclist,
     b_declist,
     take(:BEGIN),
     b_statlist,
     take(:END)]     
  end

  def b_funclist
    r = [ ]
    while match?(:FUNCTION)
      r << b_funcdef
    end
    r
  end

  def b_func_params
    params = []
    while match?(:IDENT)
      arg = []
      arg  << b_ident
      take(:COLON)
      arg << b_ident
      params << arg
      break unless match?(:COMMA)
      take(:COMMA)
    end
    params
  end
  
  def b_funcdef
    r = [take(:FUNCTION), take(:IDENT)]
    take(:OPEN)
    r << b_func_params
    take(:CLOSE)
    take(:COLON)
    r << b_ident
    take(:SEMICOLON)
    r << b_declist
    take(:BEGIN)
    r << b_statlist
    take(:END)
    
    r
  end

  def b_declist
    r = (match? :VAR) ? [take(:VAR), []] : [Token("var"), []]
    until match?(:BEGIN)
      r[1] << [b_ident, take(:COLON), b_ident, take(:SEMICOLON)]
    end
    r
  end

  def b_statlist
    result = []
    until match?(:END)
      result << b_statement
      take(:SEMICOLON)
    end
    result
  end

  def b_statement
    if match?(:IDENT)
      ident = b_ident
      case
      when match?(:OPEN) : b_funccall ident
      when match?(:ASSIGN) : b_assign ident
      end
    else
      case
      when match?(:BEGIN) : b_block
      when match?(:IF) : b_if
      when match?(:WHILE) : b_while
      end
    end
  end

  def b_assign ident
    take(:ASSIGN)
    value = b_expression
    result = [Token.new(:_=, '_='), ident, value]    
  end

  def b_funccall ident
    r = [ident]
    take(:OPEN)
    r << b_expression
    take(:CLOSE)
    r
  end

  def b_while
    [take(:WHILE), b_relation, take(:DO), b_statement]
  end
  
  def b_if
    [take(:IF), b_relation, take(:THEN), b_statement, take(:ELSE), b_statement]
  end
  
  def b_block
    [take(:BEGIN), b_statlist, take(:END)]
  end
  
  def b_ident
    take(:IDENT)
  end

  def b_literal
    case
    when match?(:IDENT) : b_ident      
    when match?(:String): b_string
    when match?(:Integer): b_number
    when match?(:ADD_OP): [take(:ADD_OP), b_number]
    else
      Token.new(:NIL, nil)
    end
  end

  def b_number
    take(:Integer)
  end
  
  def b_string
     take(:String)
  end

  def b_relation
    arg1 = b_expression
    op = take(:REL_OP)
    arg2 = b_expression
    [op, arg1, arg2]
  end
  
  def b_expression
    exp = b_term
    while match?(:ADD_OP)
      exp = case take(:ADD_OP).value
            when '+' : [Token.new(:add, "add"), exp, b_term]
            when '-' : [Token.new(:sub, "sub"), exp, b_term]
            end
    end
    exp
  end  

  def b_term
    term = b_fuctor
    while match?(:MUL_OP)
      term = case take(:MUL_OP).value
             when '*' : [Token.new(:mul, "mul"), term, b_fuctor]
             when '/' : [Token.new(:div, "div"), term, b_fuctor]
             when '%' : [Token.new(:mod, "mod"), term, b_fuctor]               
             end
    end
    term
  end
  
  def b_fuctor
    case
    when match?(:OPEN)
      take(:OPEN)      
      r = b_expression
      take(:CLOSE)
      r
    when match?(:IDENT)
      ident = b_ident
      if match?(:OPEN)
        take(:OPEN)
        r = [ident, b_expression]
        take(:CLOSE)
        r
      else
        ident
      end
    else
      literal = b_literal
      if match?(:DOT)
        [literal, take(:DOT), take(:IDENT)]
      else
        literal
      end
    end
    
  end
  
end

