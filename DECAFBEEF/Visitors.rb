require 'set'
require "./GetNextReg.rb"

COMPARISON_OPERATORS = Set.new %w{== != <= >= < >}

class BaseVisitor
  def visit subject
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      # Do nothing with any visit_NodeName that aren't defined
    end
  end

  def preAndPostOrder subject
    if subject == nil then return end

    method_name = "pre_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      if respond_to?(:pre, subject)
        send(:pre, subject)
      end
    end

    subject.list.each do |next_node|
      preAndPostOrder(next_node)
    end

    method_name = "post_#{subject.class}".intern
    if respond_to?(method_name, subject)
      send(method_name, subject)
    else
      if respond_to?(:post, subject)
        send(:post, subject)
      end
    end
  end
end

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

# INCOHERENT RAGE
class SymbolTableVisitor < BaseVisitor

  def initialize sym 
    @symbol_table = sym
  end

  def visit_Root subject
    preAndPostOrder(subject)
  end

  def pre_Root subject
    @symbol_table.openScope subject
  end

  def post_Root subject
    @symbol_table.closeScope
  end

  def pre_Decls subject
    if subject.attrib == "const"
      @symbol_table.constness = "const"
    else
      @symbol_table.constness = nil
    end

  end

  def pre_Dec subject
    # This makes an assumption  based on the grammar that in the constructed AST
    #  the first child(leaf) node will be the name of the declaration
    if @symbol_table.constness == "const"
      subject.attrib = "const"
    end
    @symbol_table.enterSymbol subject.list.first.attrib, subject.attrib

  end

  def pre_Expr subject
    if subject.name == "NAME"
      if @symbol_table.retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
      end
    end
    if subject.attrib == "="
        if @symbol_table.retreiveSymbol(subject.list.first.attrib) == false
          raise ParseError.new("Error: '" + subject.list.first.attrib + "' undeclared (First use in this function)")
        elsif @symbol_table.retreiveSymbol(subject.list.first.attrib).const == "const"
          raise ParseError.new("Error: Assignment of readonly variable " + subject.list.first.attrib)
        end
    end
  end

  def pre_CmpndState subject
    @symbol_table.openScope subject
  end

  def post_CmpndState subject
    @symbol_table.closeScope
  end

  def pre_Literal subject
    if subject.name == "NAME"
      if @symbol_table.retreiveSymbol(subject.attrib) == false
        raise ParseError.new( "Error: '" + subject.attrib + "' undeclared (First use in this function)")
      end
    end
  end
end

class CalcExprVisitor < BaseVisitor
  def initialize sym, ast
    @sym = sym
    @ast = ast
    @getReg = GetNextReg.new
    #@registers = ['R9', 'R10', 'R11', 'R1', 'R2', 'R3', 'R4', 'R5', 'R6', 'R7', 'R8']
  end

  def visit_Root subject
    preAndPostOrder(subject)
  end

  def get_needs subject
    if subject.class == Literal
      if subject.name == 'NAME' and subject.parent.attrib == '='
        return 0
      else
        return 1
      end
    end

    left_count = get_needs subject.list.first
    right_count = get_needs subject.list.last

    if left_count == right_count
      return left_count + 1
    else
      return left_count > right_count ? left_count : right_count
    end
  end

  def calc_tree subject
  #def calc_tree subject, registers
    subject.result_reg = @getReg.getNext
    #subject.result_reg = registers.first
    if subject.class == Literal
      return
    end

    left_count = get_needs subject.list.first
    right_count = get_needs subject.list.last

    if left_count >= right_count
      calc_tree subject.list.first
      calc_tree subject.list.last
      #calc_tree subject.list.first, registers
      #calc_tree subject.list.last, registers.drop(1)
    else
      calc_tree subject.list.last
      calc_tree subject.list.first
      #calc_tree subject.list.last, registers
      #calc_tree subject.list.first, registers.drop(1)
    end
  end

  def pre_Expr subject
    if subject.parent.class != Expr
      calc_tree subject
      #calc_tree subject, @registers
    end
  end

  def pre_Dec subject
    if subject.list.last.class != Expr
      subject.list.last.result_reg = @getReg.getNext
      @getReg.free(subject.list.last.result_reg)
      #subject.list.last.result_reg = @registers.first
    end
  end
end

OP_BRANCH_INSTS = {
  "==" => "bneq",
  "!=" => "beq",
  "<=" => "bgt",
  ">=" => "blt",
  "<" => "bge",
  ">" => "ble",
}

OP_BRANCH_NOT_INSTS = {
  "==" => "bneq",
  "!=" => "beq",
  "<=" => "bgt",
  ">=" => "blt",
  "<" => "bge",  
  ">" => "ble",
}

class GenIRVisitor
  def initialize sym, ast
    @sym = sym
    @ast = ast
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
      entry = @sym.retreiveSymbolAt(subject.list.first.attrib, subject)
      subject.ir = "memst #{subject.list.last.result_reg}, <<#{entry.alias}>> # #{subject.list[0].attrib} = #{subject.list.last.result_reg}"
    end

  end

  def visit_Expr subject
    if COMPARISON_OPERATORS.include? subject.attrib then return end

    if subject.attrib == "return"
      subject.ir = "jump +0"
    elsif subject.attrib == "="
      entry = @sym.retreiveSymbolAt(subject.list.first.attrib, subject)
      subject.ir = "memst #{subject.list.last.result_reg}, <<#{entry.alias}>> # #{subject.list[0].attrib} = #{subject.list.last.result_reg}"
    else # calc instructions
      if subject.list.first.name == "NUM"
        subject.ir = "#{subject.attrib} #{subject.result_reg}, #{subject.list.first.attrib}, #{subject.list.last.result_reg}"
        subject.list.first.ir.clear
      elsif subject.list.last.name == "NUM"
        subject.ir = "#{subject.attrib} #{subject.result_reg}, #{subject.list.first.result_reg}, #{subject.list.last.attrib}"
        subject.list.last.ir.clear
      else
        subject.ir = "#{subject.attrib} #{subject.result_reg}, #{subject.list.first.result_reg}, #{subject.list.last.result_reg}"
      end
    end
  end

  def visit_Literal subject
    if subject.name == 'NAME'
      if subject.parent.attrib == '=' then return end
      entry = @sym.retreiveSymbolAt(subject.attrib, subject)
      subject.ir = "memld #{subject.result_reg}, <<#{entry.alias}>> # #{subject.result_reg} = #{subject.attrib}"
    elsif subject.name == 'NUM'
      subject.ir = "immld #{subject.result_reg}, #{subject.attrib} # #{subject.result_reg} = #{subject.attrib}"
    end
  end

  def visit_IfNode subject
    comparison = subject.list.first
    if subject.name == "If"
      subject.list.first.ir = "#{OP_BRANCH_INSTS[comparison.attrib]} <<sibling-inst 0 2>>, #{subject.list.first.list.first.result_reg}, #{subject.list.first.list.last.result_reg}"
    elsif subject.name == "IfElse"
      subject.list.first.ir = "#{OP_BRANCH_NOT_INSTS[comparison.attrib]} <<sibling-inst 0 3>>, #{subject.list.first.list.first.result_reg}, #{subject.list.first.list.last.result_reg}"
      subject.list[2].ir = "jump <<sibling-inst 2 4>>"
    end
  end

  def visit_WhileNode subject
    comparison = subject.list.first
    subject.list.first.ir = "#{OP_BRANCH_NOT_INSTS[comparison.attrib]} <<sibling-inst 0 3>>, #{subject.list.first.list.first.result_reg}, #{subject.list.first.list.last.result_reg}"
    subject.list.last.ir = "jump <<sibling-inst 2 0>>"
  end
end

# Counts the number of IR instructions contained within each node
class CountIRVisitor < BaseVisitor
  def initialize sym, ast
    @sym = sym
    @ast = ast
  end

  def visit_Root subject
    preAndPostOrder(subject)
  end

  def pre subject
    if !subject.ir.nil? && !subject.ir.empty? then subject.ir_count = subject.ir_count || 1 end
  end

  def post subject
    subject.ir_count = (subject.ir_count || 0) + subject.list.reduce(0) { |sum, node| sum + ((node && node.ir_count) ? node.ir_count : 0) }
  end
end

# Actually outputs the IR and resolves symbol locations and relative jumps
class OutputIRVisitor
  def initialize sym, ast
    @sym = sym
    @ast = ast
    @globals_start = @ast.root.ir_count * 4
    @locals_start = @globals_start + @sym.num_globals * 4
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
      if !node.ir.nil? && !node.ir.empty?
        $outir << node.ir.gsub(/<<([a-z-]+) (\d+)(?: (\d+))?>>/) do |match|
          loc = 0
          if $1 == 'global'
            loc = @globals_start + $2.to_i * 4
          elsif $1 == 'local'
            loc = @locals_start + $2.to_i * 4
          elsif $1 == 'sibling-inst'
            start = $2.to_i
            finish = $3.to_i

            if finish > start
              loc = node.parent.list[(start+1)..(finish - 1)].reduce(0) { |sum, subnode| sum + (subnode ? (subnode.ir_count || 0) : 1) } + 1
            else
              loc = -node.parent.list[finish..(start - 1)].reduce(0) { |sum, subnode| sum + (subnode.ir_count || 0) }
            end

            loc = sprintf "%+d", loc
          end

          loc.to_s
        end

        $outir << "\n"
      end
    end
  end
end
