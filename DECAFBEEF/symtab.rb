class SymbolEntry
  attr_accessor :name, :origin, :type, :const, :constness, :counter, :is_global

  def initialize name, origin, type, const, c, is_global
    @name = name
    @origin = origin
    @type = type
    @const = const
    @constness
    @counter = c
    @is_global = is_global
  end

  def inspect
    "[#{@name}, #{@origin}, #{@type}, #{@constness}, #{@counter}, #{@is_global}]"
  end 

  def alias
    (@is_global ? 'global' : 'local') + ' ' + @counter.to_s
  end
end

class SymbolTable < SymbolEntry

  attr_accessor :table, :namespace, :num_globals

  def initialize
    @table = Array.new
    @counters = []
    @current_scope = @table.first
    @namespace = String.new
    @nodemap = {}
    @counter = 0
    @num_globals = 0
  end

  def openScope node
    @table.push(Array.new)
    @current_scope = @table.last
    @nodemap[node.unique_id] = @current_scope

    @counters.push @counter
    if @counters.length == 2
      # Just left global scope, switch to locals counter
      @counter = 0
    end
  end

  def closeScope
    @table.pop
    @current_scope = @table.last
    @counter = @counters.pop
  end

  def gotoFirstScope
    @current_scope = @table.first
  end

  def gotoNextScope
    @current_scope = @table.index(@current_scope+1)
  end

  def enterSymbol name, a
    if !decalredLocally(name)
      if isGlobal(name)
        # raise ParseError.new( "Error: '" + name + "' already exists as a global")
      else
        global = @table.length == 1
        if @namespace.include?(name)
          @current_scope.push(SymbolEntry.new(name,@namespace.index(name), nil, a, @counter, global))
          @counter += 1
        else
          @current_scope.push(SymbolEntry.new(name,@namespace.length, nil, a, @counter, global))
          @counter += 1
          @namespace << name
        end
        if global then @num_globals += 1 end
      end
    else
      raise ParseError.new( "Error: '" + name + "' previously declared in this scope")
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

  def retreiveSymbolAt name, node
    while node != nil
      scope = @nodemap[node.unique_id]
      if scope != nil
        scope.each do |item|
          if item.name == name
            return item
          end
        end
      end

      node = node.parent
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
