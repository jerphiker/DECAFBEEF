require 'securerandom'

class AbsNode
  attr_accessor :list, :desc, :unique_id

  def initialize(desc, *b )
    @list = b
    @desc = desc
    @unique_id = SecureRandom.uuid
  end

  def get_ids(i = 0)
    #ret = "#{' ' * i}#{self.object_id} #{@desc}\n"
    ret = "#{@unique_id} #{@desc}\n"
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
