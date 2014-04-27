class ArithmeticVisitor

  def initialize
  end

  def visit subject, outa, outp, outir
    method_name = "visit_#{subject.class}".intern
    if respond_to?(method_name, subject) # if visit_NodeName is a method
      send(method_name, subject)
    else  # visit_NodeName is not a method, so apply default actions
      
    end
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

  def visit_Lambda subject
  end
end