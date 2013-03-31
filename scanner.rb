class Token
  attr_accessor :type, :value

  def initialize type, value
    @type = type
    @value = value
  end  
  
  def to_s
    "type => #{@type}, value => #{@value}"
  end
  
  def == other
    other != nil and @value == other.value and @type == other.type
  end
  
  def eql? other
    @value.eql?(other.value) and @type.eql?(other.type)
  end

  def hash
    @type.hash + @value.hash
  end
end

def Token value
    case value 
    when 'program' 
        Token.new(:PROGRAM, value)
    when 'function'
        Token.new(:FUNCTION, value)      
    when 'var'
        Token.new(:VAR, value)      
    when 'begin'
        Token.new(:BEGIN, value)
    when 'end'
        Token.new(:END, value)
    when 'if'
        Token.new(:IF, value)
    when 'then'
        Token.new(:THEN, value)
    when 'else'
        Token.new(:ELSE, value)
    when 'while'
        Token.new(:WHILE, value)
    when 'do'
        Token.new(:DO, value)
    when '('
        Token.new(:OPEN, value)
    when ')'
        Token.new(:CLOSE, value)
    when ':'
        Token.new(:COLON, value)      
    when ';'
        Token.new(:SEMICOLON, value)
    when '.'
        Token.new(:DOT, value)
    when ','
        Token.new(:COMMA, value)
    when ':='
        Token.new(:ASSIGN, value)
    when '='
        Token.new(:REL_OP, value)
    when '>='
        Token.new(:REL_OP, value)
    when '<='
        Token.new(:REL_OP, value)
    when '<'
        Token.new(:REL_OP, value)
    when '>'
        Token.new(:REL_OP, value)
    when '<>'
        Token.new(:REL_OP, value)            
    when '+'
        Token.new(:ADD_OP, value)
    when '-'
        Token.new(:ADD_OP, value)
    when '*'
        Token.new(:MUL_OP, value)
    when '/'
        Token.new(:MUL_OP, value)
    when '%'
        Token.new(:MUL_OP, value)
    when /'.*'/
        Token.new(:String, value.slice(1, value.size - 2))
    when /\D\W*/
        Token.new(:IDENT, value)
    when /\d/
        Token.new(:Integer, value.to_i)        
    else
      Token.new(:UNDEFINE, value)
    end
end

class Scanner
  def initialize src
    @tokens = split(src.strip)
    @index = -1
  end

  def split src
    tokens = []
    idx = -1

    _next = lambda do src.slice(idx+=1, 1).to_s end
    _has_next = lambda do idx < (src.length - 1) end
    _next_word = lambda do
      x = _next[]
      case x
      when "/"
        if _next[] == "/"
          until((y = _next[]) == "\n") do end
          _next_word[]
        else
          idx -=1
          x
        end
      when "'"
        y = ""
        while(true)
          x += y          
          break if (y = _next[]) == "'"
        end
        x += y
      when /\s/ 
          _next_word[]
      when /\W/
        if _has_next[]
          y = _next[] 
          case
          when (x == ':' and y == '=')
             x += y
          when (x == '>' and y == '=')
             x += y 
          when (x == '<' and y == '=')
             x += y
          when (x == '<' and y == '>')
             x += y                     
          else
            idx -= 1
            x
          end
        else
          x
        end
      when /\w/
        while(true)
          break unless (y = _next[]) =~ /\w/
          x += y
        end
        idx -= 1
        x
      end
    end
    
    while( idx < (src.length - 1))
      tokens << Token(_next_word[])
    end
    tokens
  end

  def next
    @tokens[@index += 1]
  end

  def has_next?
    @index < @tokens.length - 1
  end

  def prev
    token = @tokens[@index]
    @index -= 1
    token
  end
end
