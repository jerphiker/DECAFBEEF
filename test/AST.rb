module Visitable
  def accept visitor
    visitor.visit(self)
  end
end

class Node
  attr_accessor :list, :name, :attrib
  include Visitable

  def initialize(desc, a, *b )
    @name = desc
    @attrib = a
    @list = b
  end
end

class Root < Node

end

class Decs < Node

end

class DecBody < Node

end

class States < Node

end

class Assign < Node

end

class RExpr < Node

end

class Expr < Node

end

class IfNode < Node

end

class Ast < Node
  def initialize(r)
    @root = r
  end

  def accept visitor
    @root.accept visitor
    @root.list.each do |node|
      node.accept visitor 
      iterate(node, visitor)
    end
  end

  def iterate(node, visitor)
    node.list.each do |next_node|
      if next_node.respond_to?(:accept)
        next_node.accept visitor
        iterate(next_node, visitor)
      else
       next_node = Node.new(next_node, nil)
       next_node.accept visitor
      end
    end


  end
end

class BaseVisitor
  def visit subject
    method_name = "visit_#{subject.class}".intern
    send(method_name, subject )
  end
end

class AstVisitor < BaseVisitor

  def visit_Root subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_Decs subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_DecBody subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_States subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_Assign subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_RExpr subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_Expr subject
    puts "#{subject.name} #{subject.attrib}"
  end

  def visit_IfNode subject
    puts "#{subject.name} #{subject.attrib}"

  end

  def visit_Node subject
    puts "#{subject.name} #{subject.attrib}"
  end

end
