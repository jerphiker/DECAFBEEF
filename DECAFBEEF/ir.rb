
class IRPass1 
  attr_accessor :expr_counter

  def initialize outa, outp, outir, sym, ast, expr_counter
    @sym = sym
    @@outa = outa
    @@outp = outp
    @@outir = outir
    @ast = ast

    @expr_counter = expr_counter
  end

  def visit subject, outa, outp, outir
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visis_NodeName that aren't defined
    end
  end


  def visit_Expr subject

    if subject.attrib == "=" 
      subject.list.first.name = "ASSIGN"
    end

    if ["==", "<=", ">=", "<", ">", "!="].include?(subject.attrib)
      subject.name = "Comparison"
    end
        
  end

  def visit_Literal subject
    if subject.name == "NAME"
      entry = @sym.retreiveSymbol(subject.attrib)
      subject.ir = "memld R#{@expr_counter}, #{entry.counter} # R#{@expr_counter} = #{subject.attrib}"
      subject.name = "REGISTER"
      subject.attrib = "R#{@expr_counter}"
      @expr_counter += 1
    elsif subject.name == "NUM"
      subject.ir = "immld R#{@expr_counter}, #{subject.attrib} # R#{@expr_counter} = #{subject.attrib}"
      subject.name = "REGISTER"
      subject.attrib = "R#{@expr_counter}"
      @expr_counter += 1
    end

  end

end


class IRPass2 
  attr_accessor :expr_counter

  def initialize outa, outp, outir, sym, ast, expr_counter
    @sym = sym
    @@outa = outa
    @@outp = outp
    @@outir = outir
    @ast = ast

    @expr_counter = expr_counter
  end

  def visit subject, outa, outp, outir
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
      else
        subject.ir = "calc R#{@expr_counter}, {#{subject.list.first.attrib} #{subject.attrib} #{subject.list.last.attrib}}\n"
        subject.name = "REGISTER"
        subject.attrib = "R#{@expr_counter}"
        @expr_counter += 1

        @ast.accept(IRPass2.new(@@outa, @@outp, @@outir, @sym, @ast, @expr_counter), @@outa, @@outp, @@outir)
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

  def initialize outa, outp, outir, sym, ast, expr_counter
    @sym = sym
    @@outa = outa
    @@outp = outp
    @@outir = outir
    @ast = ast

    @expr_counter = expr_counter
  end

  def visit subject, outa, outp, outir
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

  def postOrder(node)
    if node != nil
      node.list.each do |next_node|
        postOrder(next_node)
      end
    end
    if node.respond_to?(:ir)
      if !node.ir.empty? && !node.ir.nil?
        @@outir << "#{node.ir}\n"
      end

    end
  end

end
