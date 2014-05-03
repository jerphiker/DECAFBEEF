require 'securerandom'

class AbsNode
  attr_accessor :list, :name, :unique_id, :attrib, :ir, :parent, :leftmost_sib, :right_sib, :ir_count, :result_reg

  def accept(visitor)
    visitor.visit(self)
  end

  def initialize(desc, a, *b )
    @list = b
    @name = desc
    @unique_id = SecureRandom.uuid
    @attrib = a
    @ir = String.new
    @ir_count = nil
    @result_reg = nil

    @parent = nil
    @leftmost_sib = nil
    @right_sib = nil

  end

end

class Ast < AbsNode
  attr_accessor :root

  def initialize(r)
    @root = r
  end

  def accept(visitor)
    @root.accept(visitor)
    @root.list.each do |node|
      if node != nil
        node.accept(visitor)
        iterate(node, visitor)
      end
    end
  end

  def iterate(node, visitor)
    node.list.each do |next_node|
      if next_node.respond_to?(:accept)
        next_node.accept(visitor)
        iterate(next_node, visitor)
      else

      end
    end

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

class GlobalDec < AbsNode
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

class Lambda < AbsNode
end

class Literal < AbsNode
end
