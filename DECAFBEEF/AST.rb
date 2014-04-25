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

  def get_ids(i = 0)
    #ret = "#{' ' * i}#{self.object_id} #{@desc}\n"
    ret = "#{@unique_id} #{@name}\n"
    @list.each do |child|
      if child == nil
        next
      elsif child.respond_to?(:get_ids)
        child.get_ids(i + 1)
      else
        #ret += "#{' ' * i} #{child.object_id} #{child}\n"
        #ret += "#{child.object_id} #{child.to_s}\n"
      end
    end
    puts ret
  end
  
  def get_children()
    if @list.select { |x| x.respond_to?(:get_ids) }.empty?
      return
    end
    ret = "#{@unique_id}" 
    @list.each do |child|
      if child == nil
        next
      elsif child.respond_to?(:get_ids)
        ret += " #{child.unique_id}"
        child.get_children()
      end
    end
    puts ret 
  end

end

class Root < AbsNode
end

class Decs < AbsNode
end

class DecBody < AbsNode
end

class States < AbsNode
end

class Assign < AbsNode
end

class RExpr < AbsNode
end

class Expr < AbsNode
end

class IfNode < AbsNode
end

class Ast < AbsNode
  attr_accessor :root

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
       next_node = AbsNode.new(next_node, nil)
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