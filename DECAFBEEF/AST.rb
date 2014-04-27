require 'securerandom'

module Visitable
  def accept(visitor, outa, outp, outir)
    visitor.visit(self, outa, outp, outir)
  end
end

class AbsNode
  attr_accessor :list, :name, :unique_id, :attrib, :ir

  include Visitable

  def initialize(desc, a, *b )
    @list = b
    @name = desc
    @unique_id = SecureRandom.uuid
    @attrib = a
    @ir = String.new
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

class Lambda < AbsNode
end

class Literal < AbsNode
end

class Ast < AbsNode
  attr_accessor :root

  def initialize(r)
    @root = r
  end

  def accept(visitor, outa, outp, outir)
    @root.accept(visitor, outa, outp, outir)
    @root.list.each do |node|
      if node != nil
        node.accept(visitor, outa, outp, outir)
        iterate(node, visitor, outa, outp, outir)
      end
    end
  end

  def iterate(node, visitor, outa, outp, outir)
    node.list.each do |next_node|
      if next_node.respond_to?(:accept)
        next_node.accept(visitor, outa, outp, outir)
        iterate(next_node, visitor, outa, outp, outir)
      else
       # next_node = AbsNode.new(next_node, nil)
       # next_node.accept visitor
      end
    end


  end
end

class AstVisitorPass1 

  def visit(subject, outa, outp, outir)
    #if subject.name == 'Lambda' then return end
    #puts "#{subject.unique_id} #{subject.name} :: #{subject.attrib} :: #{subject.class} :: #{subject.ir}"
    outa << "#{subject.unique_id} #{subject.attrib}\n"
    outp <<  "#{subject.unique_id} #{subject.attrib}\n"
  end

end

class AstVisitorPass2

  def visit(subject, outa, outp, outir)
    #if subject.name == 'Lambda' then return end
    ret = "#{subject.unique_id}" 
    subject.list.each do |child|
      if child != nil
        ret += " #{child.unique_id}"
      end
    end
    #puts ret
    outa << ret << "\n"
    outp << ret << "\n"
  end

end

class BaseVisitor
  def visit subject, outa, outp, outir
    method_name = "visit_#{subject.class}".intern
    send(method_name, subject)
  end
end
