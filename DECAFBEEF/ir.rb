class BaseVisitor
  def visit subject, outa, outp, outir
    method_name = "visit_#{subject.class}".intern
    send(method_name, subject )
  end
end


class IR < BaseVisitor

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
  end

end
