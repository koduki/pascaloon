require 'parser.rb'
require 'utils.rb'

class SemanticException < Exception; end

class Evaluator

  def initialize 
    @func = {
      'add' => lambda{ |args, env| r = args[0] + args[1]; Token.new(:Integer, r)},
      'sub' => lambda{ |args, env| r = args[0] - args[1]; Token.new(:Integer, r)},
      'mul' => lambda{ |args, env| r = args[0] * args[1]; Token.new(:Integer, r)},
      'div' => lambda{ |args, env| r = args[0] / args[1]; Token.new(:Integer, r)},
      'mod' => lambda{ |args, env| r = args[0] % args[1]; Token.new(:Integer, r)},
      '>' => lambda{ |args, env| args[0] > args[1] },
      '<' => lambda{ |args, env| args[0] < args[1] },
      '<=' => lambda{ |args, env| args[0] <= args[1] },
      '>=' => lambda{ |args, env| args[0] >= args[1] },
      '<>' => lambda{ |args, env| args[0] != args[1] },
      '=' => lambda{ |args, env| args[0] == args[1] },
      'writeln' => lambda{ |args, env| puts args[0] },
      'write' => lambda{ |args, env| print args[0] },
      'readln' => lambda{ |args, env| s = STDIN.gets;Token.new(:String, s) }
    }
    @env = {}
  end

  def assign args, env
    name = args[0].value
    env.find { |e| e.has_key?(name) }[name].value = get(args[1], env)
  end

  def call_func tree, env
    return tree unless tree.class == Array
    
    name = tree.first.value
    args = eval_args tree.tail, env

    if ( name == '_=')
      assign(args, env)
    else
      @func[name].call(args.map{ |x| get(x, env) }, env)
    end
  end

  def eval_args args, env
    args.map do |arg|
      if (arg.class == Array) then call_func(arg, env) else arg end
    end
  end  
  
  def get_type type
    case type
    when "String" : Token.new(:String, nil)
    when "Integer" : Token.new(:Integer, nil)
    end
  end
  
  def define name, type, env
    env[0][ name ] = get_type type
  end

  def get token, env
    if token.type == :IDENT
      env.find { |e| e.has_key?(token.value) }[token.value].value
    else
      token.value
    end
  end

  def to_stmts stmt
    (stmt[0].type == :BEGIN ) ? stmt[1] : [ stmt ] 
  end


  def eval tree
    eval_funcdef tree[3]
    eval_declist tree[4][1], [@env]
    eval_statlist tree[6], [@env]
  end

  def eval_statlist tree, env
    tree.each do |statement|
      case statement[0].type
      when :IF : eval_if statement, env
      when :WHILE : eval_while statement, env
      when :BEGIN : eval_statlist statement[1], env
      else
        call_func(statement, env)
      end
    end
  end
  
  def eval_declist tree, env
    tree.each do |dec|
      name = dec[0].value
      type = dec[2].value
      define name, type, env
    end
  end

  def eval_if statement, env
    rel = call_func(statement[1], env)
    tstmt = to_stmts statement[3] 
    fstmt = to_stmts statement[5]
    
    eval_statlist(((rel) ? tstmt : fstmt), env)
  end

  def eval_while statement, env
    rel = lambda { call_func(statement[1], env) }
    stmt = to_stmts statement[3]
    while rel.call do eval_statlist(stmt, env) end    
  end
  
  def eval_funcdef tree
    tree.each do |statement|
      name = statement[1].value
      vargs = statement[2].map{|xs| xs[0].value }
      args_type = statement[2].map{|xs| xs[1].value.intern }
      result_type = get_type statement[3].value
      detects = statement[4][1]
      stmt = statement[5]
      
      @func[name] = lambda{|rargs, penv|
        env = {}
        (0..vargs.size-1).each do |i|
          env[vargs[i]] = Token.new(args_type[0], rargs[i])
        end
        env["result"] = result_type.clone
        env = [env] + penv       
        eval_declist detects, env
#p env.map{|xs| xs.to_a.map{|x| "#{x[0]}=#{x[1].value} ##{x[1].hash}" }}; puts "+++"
        eval_statlist stmt, env
#p env.map{|xs| xs.to_a.map{|x| "#{x[0]}=#{x[1].value} ##{x[1].hash}" }}; puts "---"
        env[0]["result"]                       
      }
    end
  end

end
