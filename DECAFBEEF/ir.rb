class BaseVisitor
  def visit subject, outa, outp, outir
    method_name = "visit_#{subject.class}".intern
    send(method_name, subject)
  end
end


class IR < BaseVisitor

  def initialize outir, sym
    @sym = sym
    @@outir = outir
    @expr_counter = 0
  end

  def visit_Root subject
  end

  def visit_Decls subject
  end

  def visit_DeclList subject
  end

  def visit_States subject
  end

  def visit_Dec subject
  end

  def visit_DirectDec subject
  end

  def visit_RExpr subject
  end

  def visit_Expr subject
    unless subject.attrib == '=' then return end

    gen_Expr subject.list[0]
    entry = @sym.retreiveSymbol(subject.list[1].attrib)
    outir << "memst R42, #{entry.counter}\n"
  end

  def visit_IfNode subject
    gen_Expr subject.list[0]

    if subject.name == "IfElse"
      @@outir << "bfalse #{subject.list[2].unique_id}, R42\n"
      gen_CmpndState subject.list[1]
      @@outir << "jump #{subject.list.last.unique_id}, R42\n"
      gen_CmpndState subject.list[2]
    else
      @@outir << "bfalse #{subject.list.last.unique_id}, R42\n"
      gen_CmpndState subject.list[1]
    end
  end

  def visit_AbsNode subject
  end

  def visit_WhileNode subject
  end

  def visit_StateList subject
  end

  def visit_CmpndState subject
  end

  def visit_Lambda subject
  end



  def gen_Root subject
  end

  def gen_Decls subject
  end

  def gen_DecList subject
  end

  def gen_States subject
  end

  def gen_Dec subject
  end

  def gen_DirectDec subject
  end

  def gen_RExpr subject
  end

  def gen_Expr subject
    @@outir << "calc R42, N#{@expr_counter}\n"
    @expr_counter += 1
  end

  def gen_IfNode subject
  end

  def gen_AbsBide subject
  end

  def gen_WhileNode subject
  end

  def gen_StateList subject
  end

  def gen_CmpndState subject
  end

end
