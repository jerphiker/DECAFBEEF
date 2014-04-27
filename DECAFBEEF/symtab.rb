

class SymbolEntry < BaseVisitor
  attr_accessor :name, :origin, :type, :const, :constness, :counter

  def initialize name, origin, type, const, c
    @name = name
    @origin = origin
    @type = type
    @const = const
    @constness
    @counter = c
  end

  def inspect
    "[#{@name},#{@origin},#{@type},#{@const}, #{@counter}]"
  end 

end

class SymbolTable < SymbolEntry

  attr_accessor :table, :namespace

  def initialize
    @table = Array.new
    @current_scope = @table.first
    @namespace = String.new
    @counter = 20000
  end

  def openScope
    @table.push(Array.new)
    @current_scope = @table.last
  end

  def closeScope
    @table.pop
    @current_scope = @table.last
  end

  def enterSymbol name, a
    if !decalredLocally(name)
        if @namespace.include?(name)
          @counter += 4
          @current_scope.push(SymbolEntry.new(name,@namespace.index(name), nil, a, @counter))
          
        else
          @counter += 4
          @current_scope.push(SymbolEntry.new(name,@namespace.length, nil, a, @counter))
          @namespace << name
        end
    else
      raise ParseError.new( "Error: '" + name + "' previously declared somewhere")
    end

  end

  def retreiveSymbol name
    @table.reverse_each do |scope|
      scope.each do |item|
        if item.name == name
          return item
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
    if subject.attrib == "const"
      @constness = "const"
    else
      @constness = nil
    end

  end

  def visit_DeclList subject
  end

  def visit_States subject
  end

  def visit_Dec subject
    # This makes an assumption  based on the grammar that in the constructed AST
    #  the first child(leaf) node will be the name of the declaration
    # p subject.list
    if @constness == "const"
      subject.attrib = "const"
    end
    enterSymbol subject.list.first.attrib, subject.attrib

  end

  def visit_DirectDec subject

  end

  def visit_RExpr subject
  end

  def visit_Expr subject
    if subject.name == "NAME"
      if retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
      end

    end
    if subject.attrib == "="
        if retreiveSymbol(subject.list.first.attrib) == false
          puts "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)"
        elsif retreiveSymbol(subject.list.first.attrib).const == "const"
          raise ParseError.new("Error: Assignment of readonly variable " + subject.list.first.attrib)

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

  def visit_Lambda subject
  end

  def visit_Literal subject

    if subject.name == "NAME"
      if retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
      end

    end
    
  end

end
