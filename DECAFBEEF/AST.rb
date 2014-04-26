require 'securerandom'

module Visitable
  def accept visitor
    visitor.visit(self)
  end
end

class AbsNode
  attr_accessor :list, :name, :unique_id, :attrib

  include Visitable

  def initialize(desc, a, *b )
    @list = b
    @name = desc
    @unique_id = SecureRandom.uuid
    @attrib = a
  end

end

class Root < AbsNode
end

class Decls < AbsNode
end

class DeclList < AbsNode
end

class States < AbsNode
end

class Dec < AbsNode
end

class DirectDec < AbsNode
end

class RExpr < AbsNode
end

class Expr < AbsNode
end

class IfNode < AbsNode
end

class WhileNode < AbsNode
end

class CmpndState < AbsNode
end

class StateList < AbsNode
end


class Ast < AbsNode
  attr_accessor :root

  def initialize(r)
    @root = r
  end

  def accept visitor
    @root.accept visitor
    @root.list.each do |node|
      if node != nil
        node.accept visitor 
        iterate(node, visitor)
      end
    end
  end

  def iterate(node, visitor)
    node.list.each do |next_node|
      if next_node.respond_to?(:accept)
        next_node.accept visitor
        iterate(next_node, visitor)
      else
       # next_node = AbsNode.new(next_node, nil)
       # next_node.accept visitor
      end
    end


  end
end

class AstVisitorPass1 

  def visit subject
    puts "#{subject.unique_id} #{subject.attrib}\n"
  end

end

class AstVisitorPass2

  def visit subject
    ret = "#{subject.unique_id}" 
    subject.list.each do |child|
      if child != nil
        ret += " #{child.unique_id}"
      end
    end
    puts ret
  end

end
