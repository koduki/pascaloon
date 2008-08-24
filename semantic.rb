require "utils.rb"

class SemanticAnalzer

  def analyze tree
    analyze_declist tree[4][1]
    analyze_statlist tree[6]
  end

  def analyze_declist tree
    tree.each do |dec|
      name = dec[0].value
      type = dec[2].value
      unless (type == "String" or type == "Integer")
        raise SemanticException.new("Unknown Type '#{ type }'") 
      end
      define name, type
    end
  end

  def match ident, value
    @env[ident].type == value.type
  end    
  
  def check_initialize ident
    unless @env.has_key?(ident)
      raise SemanticException.new("uninitialize valiable '#{ident}'")  
    end
  end

  def check_sameType ident, value
    unless match(ident, value)
      raise SemanticException.new("can't cast from '#{value.type}' to '#{ @env[ident].type }'")
    end
  end

  def analyze_statlist tree, env
    tree.each do |stmt|
      analyze_statlist(stmt, env) if stmt.class == Array
      check_uninitialize ident if stmt.type == :IDENT

      if stmt[0].type == :_= then
        ident = stmt[1].value
        value = stmt[2]
        
        call_func(value, env) if value.class == Array
        check_sameType ident, value
      end
    end
  end


end
