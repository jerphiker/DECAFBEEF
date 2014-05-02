

class SymbolEntry
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
    "[#{@name}, #{@origin}, #{@type}, #{@constness}, #{@counter}]"
  end 

end

class SymbolTable < SymbolEntry

  attr_accessor :table, :namespace

  def initialize
    @table = Array.new
    @current_scope = @table.first
    @namespace = String.new
    @counter = 0
  end

  def openScope
    @table.push(Array.new)
    @current_scope = @table.last
  end

  def closeScope
    @table.pop
    @current_scope = @table.last
  end

  def gotoFirstScope
    @current_scope = @table.first
  end

  def gotoNextScope
    puts @current_scope
    @current_scope = @table.index(@current_scope+1)
  end

  def enterSymbol name, a
    if !decalredLocally(name)
      if !isGlobal(name)
        if @namespace.include?(name)
          @current_scope.push(SymbolEntry.new(name,@namespace.index(name), nil, a, @counter))
          @counter += 4
        else
          @current_scope.push(SymbolEntry.new(name,@namespace.length, nil, a, @counter))
          @counter += 4
          @namespace << name
        end
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

  def isGlobal name
    @table.first.each do |item|
      if item.name == name
        return true
      end
    end
    false
  end

  

end
