require 'securerandom'

module Visitable
  def accept(visitor, outa, outp, outir)
    visitor.visit(self, outa, outp, outir)
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

class Lambda < AbsNode
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
    puts "#{subject.unique_id} #{subject.name} :: #{subject.attrib} :: #{subject.class}\n"
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
    puts ret
    outa << ret << "\n"
    outp << ret << "\n"
  end

end

class AstVisitorPassIR
  @@visited = []
  def visit(subject, outa, outp, outir)
    if @@visited.include? subject
      return
    end
    @@visited << subject
    case subject.name
    when "Assignment"
      subject.list.each do |node|
        outir << "Assignment: #{node.attrib}\n"
        @@visited << node
      end
    when "="
      first = true
      subject.list.each do |node|
        if first
          outir << " Set #{node.attrib} = "
          @@visited << node
          first = false
        else
          self.visit(node, outa, outp, outir)
          outir << " IN EXPR "
        end
      end
      outir << "\n"
    when "Operator"
      outir << " #{subject.attrib} "
    when "NAME"
      outir << " #{subject.attrib}"
    when "NUM"
      outir << " #{subject.attrib}"
    when "Start", "Decl List", "Decls", "Statement List", "Compound Statements"
      outir << "IGNORE\n"
    else
      outir << "No condition met: #{subject.name}\n"
    end
    
  end
end
