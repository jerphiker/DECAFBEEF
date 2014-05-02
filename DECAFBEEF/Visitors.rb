
class AstParentSiblingVisistor

  def visit subject

    # Connect parent and sibling relationship
    subject.list.each do |node|
      if node != nil
        node.parent = subject
        node.leftmost_sib = subject.list.first
      end
    end

    right = nil
    subject.list.reverse_each do |node|
      if node != nil
        node.right_sib = right
        right = node
      end
    end

  end
end

class AstGraphVisitor1

  def visit(subject)
    #if subject.name == 'Lambda' then return end
    puts "#{subject.unique_id} #{subject.name} :: #{subject.attrib} :: #{subject.class} :: #{subject.ir}"
    # puts "#{subject.unique_id} #{subject.attrib}"
    # puts "#{subject.unique_id} #{subject.class} :: #{subject.parent.class} :: #{subject.leftmost_sib.class} :: #{subject.right_sib.class}"
 
  end
end

class AstGraphVisitor2

  def visit(subject)
    #if subject.name == 'Lambda' then return end
    ret = "#{subject.unique_id}" 
    subject.list.each do |child|
      if child != nil
        ret += " #{child.unique_id}"
      end
    end
    puts ret
  end
end

class SymbolTableVisitor

  def initialize sym 
    @symbol_table = sym
  end

  def visit subject
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visit_NodeName that aren't defined
    end
  end

  def visit_Root subject
    @symbol_table.openScope
  end

  def visit_Decls subject
    if subject.attrib == "const"
      @symbol_table.constness = "const"
    else
      @symbol_table.constness = nil
    end

  end

  def visit_Dec subject
    # This makes an assumption  based on the grammar that in the constructed AST
    #  the first child(leaf) node will be the name of the declaration
    if @symbol_table.constness == "const"
      subject.attrib = "const"
    end
    @symbol_table.enterSymbol subject.list.first.attrib, subject.attrib

  end

  def visit_Expr subject
    if subject.name == "NAME"
      if @symbol_table.retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
      end
    end
    if subject.attrib == "="
        if @symbol_table.retreiveSymbol(subject.list.first.attrib) == false
          puts "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)"
        elsif @symbol_table.retreiveSymbol(subject.list.first.attrib).const == "const"
          raise ParseError.new("Error: Assignment of readonly variable " + subject.list.first.attrib)
        end
    end
  end

  def visit_CmpndState subject
    @symbol_table.openScope
  end

  def visit_Literal subject

    if subject.name == "NAME"
      if @symbol_table.retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
      end
    end
  end
end

class IRPass1 
  attr_accessor :expr_counter

  def initialize sym, ast, expr_counter
    @sym = sym
    @ast = ast
    @expr_counter = expr_counter
  end

  def visit subject
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visit_NodeName that aren't defined
    end
  end

  def visit_Expr subject

    if subject.attrib == "=" 
      subject.list.first.name = "ASSIGN"
    elsif ["==", "<=", ">=", "<", ">", "!="].include?(subject.attrib)
      subject.name = "Comparison"
    end
        
  end

  def visit_Literal subject
    if subject.name == "NAME"
      entry = @sym.retreiveSymbol(subject.attrib)
      subject.ir = "memld R9, #{entry.counter} # R#{@expr_counter} = #{subject.attrib}"
      subject.name = "REGISTER"
      subject.attrib = "R9"
      # @expr_counter += 1
    elsif subject.name == "NUM"
      subject.name = "LITERAL"
      subject.ir = "immld R9, #{subject.attrib} # R#{@expr_counter} = #{subject.attrib}"
      subject.attrib = "R9"
      # @expr_counter += 1
    end

  end
end

class IRPass2 
  attr_accessor :expr_counter

  def initialize sym, ast, expr_counter
    @sym = sym
    @ast = ast
    @expr_counter = expr_counter
  end

  def visit subject
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visis_NodeName that aren't defined
    end
  end

  def visit_Dec subject

    if subject.name == "="
      entry = @sym.retreiveSymbol(subject.list.first.attrib)
      subject.ir = "memst #{subject.list.last.attrib}, #{entry.counter} # #{subject.list[0].attrib} = #{subject.list.last.attrib}\n"
    end

  end

  def visit_Expr subject

    if subject.name == "Operator"
      subject.list.each do |child|
        if child.name == "Operator"
          return
        end
      end

      # At this point we have an expression that is NUM Operator NAME|NUM
      if subject.attrib == "="
        entry = @sym.retreiveSymbol(subject.list.first.attrib)
        subject.ir = "memst #{subject.list.last.attrib}, #{entry.counter} # #{subject.list[0].attrib} = #{subject.list.last.attrib}\n"
        return
      else # calc instructions
        if subject.list.last.name == "LITERAL"
          subject.list.last.ir = ""
        end
          subject.ir = "#{subject.attrib} R#{@expr_counter}, #{subject.list.first.attrib}, #{subject.list.last.attrib}\n"
          subject.name = "REGISTER"
          subject.attrib = "R#{@expr_counter}"
          @expr_counter += 1

          @ast.accept(IRPass2.new(@sym, @ast, @expr_counter))
        

      end
    end

  end

  def visit_IfNode subject
    if subject.name == "If"
      if subject.list.first.attrib == "=="
        subject.list.first.ir = "bneq #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      elsif subject.list.first.attrib == "!="
        subject.list.first.ir = "beq #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      elsif subject.list.first.attrib == "<="
        subject.list.first.ir = "bgt #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      elsif subject.list.first.attrib == ">="
        subject.list.first.ir = "blt #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      elsif subject.list.first.attrib == "<"
        subject.list.first.ir = "bge #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      elsif subject.list.first.attrib == ">"
        subject.list.first.ir = "ble #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
      end
    elsif subject.name == "IfElse"
      if subject.list.first.attrib == "=="
        subject.list.first.ir = "bneq #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"
      elsif subject.list.first.attrib == "!="
        subject.list.first.ir = "be1 #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"
      elsif subject.list.first.attrib == "<="
        subject.list.first.ir = "bgt #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"
      elsif subject.list.first.attrib == ">="
        subject.list.first.ir = "blt #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"
      elsif subject.list.first.attrib == "<"
        subject.list.first.ir = "bge #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"  
      elsif subject.list.first.attrib == ">"
        subject.list.first.ir = "ble #{subject.list[3].unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"  
        subject.list[2].ir = "jump #{subject.list.last.unique_id}"
      end
    end
  end

  def visit_WhileNode subject
      if subject.list.first.attrib == "=="
        subject.list.first.ir = "bneq #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      elsif subject.list.first.attrib == "!="
        subject.list.first.ir = "beq #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      elsif subject.list.first.attrib == "<="
        subject.list.first.ir = "bgt #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      elsif subject.list.first.attrib == ">="
        subject.list.first.ir = "blt #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      elsif subject.list.first.attrib == "<"
        subject.list.first.ir = "bge #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      elsif subject.list.first.attrib == ">"
        subject.list.first.ir = "ble #{subject.list.last.unique_id}, #{subject.list.first.list.first.attrib}, #{subject.list.first.list.last.attrib}"
        subject.list.last.ir = "jump #{subject.list.first.unique_id}"
      end
  end
end

class IRPass3 
  attr_accessor :expr_counter

  def initialize sym, ast, expr_counter
    @sym = sym
    @ast = ast
    @expr_counter = expr_counter
  end

  def visit subject
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visis_NodeName that aren't defined
    end
  end

  def visit_Root subject
    postOrder(subject)
  end

  def postOrder node
    if node != nil
      node.list.each do |next_node|
        postOrder(next_node)
      end
    end
    if node.respond_to?(:ir)
      if !node.ir.empty? && !node.ir.nil?
        $outir << "#{node.ir}\n"
      end

    end
  end
end