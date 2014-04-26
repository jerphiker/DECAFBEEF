class BaseVisitor
  def visit subject
    method_name = "visit_#{subject.class}".intern
    send(method_name, subject )
  end
end

class SymbolEntry < BaseVisitor
  attr_accessor :name, :origin, :type, :const

  def initialize name, origin, type, const
    @name = name
    @origin = origin
    @type = type
    @const = const
  end

  def inspect
    "[#{@name},#{@origin},#{@type},#{@const}]"
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
    if !decalredLocally(name)
        if @namespace.include?(name)
          @current_scope.push(SymbolEntry.new(name,@namespace.index(name), nil, nil))
        else
          @current_scope.push(SymbolEntry.new(name,@namespace.length, nil, nil))
          @namespace << name
        end
    else
      puts "Error: '" + name + "' previously declared somewhere"
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

  def visit_Decls subject
  end

  def visit_DeclList subject
  end

  def visit_States subject
  end

  def visit_Dec subject
    # This makes an assumption  based on the grammar that in the constructed AST
    #  the first child(leaf) node will be the name of the declaration
    # p subject.list
    enterSymbol subject.list.first.attrib
  end

  def visit_DirectDec subject
  end

  def visit_RExpr subject
  end

  def visit_Expr subject
    if subject.name == "NAME"
      if retreiveSymbol(subject.attrib) == false
        puts "Error: '" + subject.attrib + "' undeclared (First use in this function)"
      end
    end
  end

  def visit_IfNode subject
  end

  def visit_AbsNode subject
  end

  def visit_WhileNode subject
  end

  def visit_StateList subject
  end

  def visit_CmpndState subject
    openScope
  end

end