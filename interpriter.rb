require 'evaluator.rb'

#
# Commandline Interface
#
if __FILE__ == $0
  file = ARGV[0]
  src = open(file).read
  tree = Parser.new(src).parse
  Evaluator.new.eval tree
end
