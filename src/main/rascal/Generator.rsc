module Generator

import AST;
import IO;
import String;
import List;

void runProgram(Program p) {
  println(generateProgram(p));
}

str generateProgram(Program p) {
  switch(p) {
    case prog(vModule(name, usings, comps)):
      return "Module: <name>\n"
           + generateUsings(usings)
           + generateComponents(comps);
  }
}

str generateUsings(list[str] usings) {
  str result = "";

  for(u <- usings) {
    result += "Using: <u>\n";
  }

  return result;
}

str generateComponents(list[Component] comps) {
  str result = "";

  for(c <- comps) {
    result += generateComponent(c) + "\n";
  }

  return result;
}

str generateComponent(Component c) {
  switch(c) {
    case spaceComp(simpleSpace(name)):
      return "Space: <name>";

    case spaceComp(orderedSpace(child, parent)):
      return "Space: <child> \< <parent>";

    case operComp(operDef(name, typ)):
      return "Operator: <name> : <generateType(typ)>";

    case variableComp(varBlock(vars)):
      return generateVarBlock(vars);

    case ruleComp(ruleDecl(left, right)):
      return "Rule: <generateTerm(left)> -\> <generateTerm(right)>";

    case exprComp(exprDecl(expr, attrs)):
      return "Expression: <generateLogicExpr(expr)>";

    case equationComp(equationDecl(left, right)):
      return "Equation: <generateLogicExpr(left)> = <generateLogicExpr(right)>";
  }
}

str generateType(VType t) {
  switch(t) {
    case simpleType(name):
      return name;

    case arrowType(left, right):
      return "<generateType(left)> -\> <generateType(right)>";
  }
}

str generateVarBlock(list[VarDecl] vars) {
  str result = "Variables:\n";

  for(v <- vars) {
    result += " - <generateVar(v)>\n";
  }

  return result;
}

str generateVar(VarDecl v) {
  switch(v) {
    case varDecl(name, typ):
      return "<name> : <generateType(typ)>";
  }
}

str generateTerm(Term t) {
  switch(t) {
    case nameTerm(n):
      return n;
    case intTerm(i):
      return "<i>";
    case realTerm(r):
      return "<r>";
    
    case stringTerm(s):
      return s;

    case charTerm(c):
      return c;
      
    case appTerm(name, args): {
      list[str] generatedArgs = [generateTerm(a) | a <- args];
      str argsStr = intercalate(", ", generatedArgs);
      return "<name>(<argsStr>)";
    }
  }
  return "?";
}

str generateLogicExpr(LogicExpr e) {
  switch(e) {
    case termExpr(t):
      return generateTerm(t);

    case relationExpr(left, op, right):
      return "<generateTerm(left)> <generateRelOp(op)> <generateTerm(right)>";

    case andExpr(exprs):
      return intercalate(" and ", [generateLogicExpr(x) | x <- exprs]);

    case orExpr(exprs):
      return intercalate(" or ", [generateLogicExpr(x) | x <- exprs]);


    case negExpr(inner):
      return "neg <generateLogicExpr(inner)>";

    case forallExpr(var, domain, body):
      return "forall <var><generateMaybeSpace(domain)> . <generateLogicExpr(body)>";

    case existsExpr(var, domain, body):
      return "exists <var><generateMaybeSpace(domain)> . <generateLogicExpr(body)>";

    case groupedExpr(inner):
      return "(<generateLogicExpr(inner)>)";

    
    case impliesExpr(exprs):
      return intercalate(" =\> ", [generateLogicExpr(x) | x <- exprs]);

    case equivExpr(exprs):
      return intercalate(" ≡ ", [generateLogicExpr(x) | x <- exprs]);
}
  return "?";
}

str generateMaybeSpace(MaybeSpace s) {
  switch(s) {
    case noSpace():
      return "";

    case inSpace(name):
      return " in <name>";
  }
}

str generateRelOp(RelOp op) {
  switch(op) {
    case inOp():
      return "in";

    case lessEqOp():
      return "\<=";

    case greaterEqOp():
      return "\>=";

    case notEqualOp():
      return "\<\>";

    case lessOp():
      return "\<";

    case greaterOp():
      return "\>";

    case equalOp():
      return "=";
  }
}