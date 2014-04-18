
require 'nameInterface.rb'
require 'SymbolTable.rb'

root = NameInterface.new("root", nil, SymbolTable.new)
child1 = root.addChild("child1", SymbolTable.new)
child2 = root.addChild("child2", SymbolTable.new)
childOf1 = child1.addChild("childOf", SymbolTable.new)

puts "Putting x in root"
root.getSymTab.add("x")
puts "Putting y in child1"
child1.getSymTab.add("y")
puts "Putting x in child2"
child2.getSymTab.add("x")
puts "Putting z in childOf1"
childOf1.getSymTab.add("z")

puts

puts "Looking for x in root"
root.getVar("x")
puts "Looking for x in child1"
child1.getVar("x")
puts "Looking for x in childOf1"
childOf1.getVar("x")
puts "Looking for x in child2"
child2.getVar("x")
puts "Looking for z in child2"
child2.getVar("z")
puts "Looking for z in childOf1"
childOf1.getVar("z")


