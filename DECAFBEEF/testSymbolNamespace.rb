
require 'nameInterface.rb'
require 'SymbolTable.rb'

root = NameInterface.new("root", nil, SymbolTable.new)
child1 = root.addChild("child1", SymbolTable.new)
child2 = root.addChild("child2", SymbolTable.new)
childOf1 = child1.addChild("childOf", SymbolTable.new)

root.getSymTab.add("x")
child1.getSymTab.add("y")
child2.getSymTab.add("x")
childOf1.getSymTab.add("z")

root.getVar("x")
child1.getVar("x")
childOf1.getVar("x")
child2.getVar("x")
child2.getVar("z")
childOf1.getVar("z")


