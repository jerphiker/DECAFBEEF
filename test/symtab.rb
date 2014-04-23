
class SymbolEntry < BaseVisitor
  attr_accessor :name, :origin, :length, :type, :const

  def initialize name, origin, length, type, const
    @name = name
    @origin = origin
    @length = length
    @type = type
    @const = const
  end

  def inspect
    "[#{@name},#{@origin},#{@length},#{@type},#{@const}]"
  end 

end

class SymbolTable < SymbolEntry

  attr_accessor :table, :namespace

  def initialize
    @table = Array.new
    @current_scope = @table.first
    @namespace = String.new
  end

  def openScope
    @table.push(Array.new)
    @current_scope = @table.last
  end

  def closeScope
    @table.pop
    @current_scope = @table.last
  end

  def enterSymbol name
    if !retreiveSymbol(name)
      if @namespace.include?(name)
        @current_scope.push(SymbolEntry.new(name,@namespace.index(name),name.length, false, false))
      else
        @namespace << name
      end
    end

  end

  def retreiveSymbol name
    @table.reverse_each do |scope|
      scope.each do |item|
        if item.name == name
          return true
        end
      end
    end
    false
  end

  def decalredLocally name
    @current_scope.each do |item|
      if item.name == name
        return true
      end
    end
    false
  end

  def visit_Root subject
    openScope
  end

  def visit_Decs subject
  end

  def visit_DecBody subject
  end

  def visit_States subject
  end

  def visit_Assign subject
  end

  def visit_RExpr subject
  end

  def visit_Expr subject
    # puts "#{subject.name} #{subject.attrib}"
    if subject.name == "NAME"
      enterSymbol subject.attrib
    end
  end

  def visit_IfNode subject
    openScope
  end

  def visit_Node subject
  end

end