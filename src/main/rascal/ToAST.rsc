module ToAST

import ParseTree;
import AST;
import Syntax;
import String;

Program toProgram(Tree t) {
  return prog(toModule(t));
}

VModule toModule(Tree t) {
  return vModule(yield(t), toUsingList(t), toComponents(t));
}

bool isUsing(Tree t) {
  return contains(yield(t), "using");
}

list[str] toUsingList(Tree t) {
  list[str] result = [];

  visit(t) {
    case u: appl(_, _):
      if (isUsing(u)) {
        result += [yield(u)];
      }
  }

  return result;
}

list[Component] toComponents(Tree t) {
  list[Component] result = [];

  visit(t) {
    case c: appl(_, _):
      if (isSpace(c) || isRule(c) || isOperator(c) || isVariable(c)
          || contains(yield(c), "defexpression")
          || contains(yield(c), "defequation")) {
        result += [toComponent(c)];
      }
  }

  return result;
}

Component toComponent(Tree t) {
  if (isSpace(t)) {
    return spaceComp(toSpace(t));
  }

  if (isRule(t)) {
    return ruleComp(toRule(t));
  }

  if (isOperator(t)) {
    return operComp(toOper(t));
  }

  if (isVariable(t)) {
    return variableComp(toVarBlock(t));
  }

  if (contains(yield(t), "defexpression")) {
    return exprComp(toExpr(t));
  }

  if (contains(yield(t), "defequation")) {
    return equationComp(toEquation(t));
  }

  return spaceComp(simpleSpace("temp"));
}

bool isSpace(Tree t) {
  return contains(yield(t), "defspace");
}

bool isRule(Tree t) {
  return contains(yield(t), "defrule");
}

SpaceDecl toSpace(Tree t) {
  switch (t) {
    case appl(_, [_, name, _]):
      return simpleSpace(yield(name));

    case appl(_, [_, name1, _, name2, _]):
      return orderedSpace(yield(name1), yield(name2));
  }

  throw "No se pudo convertir SpaceComponent";
}

Term toTerm(Tree t) {
  switch (t) {
    case appl(_, [name]):
      return nameTerm(yield(name));

    case appl(_, [intLit]):
      return intTerm(toInt(yield(intLit)));

    case appl(_, [floatLit]):
      return realTerm(toReal(yield(floatLit)));

    case appl(_, [_, name, args]):
      return appTerm(yield(name), toArgs(args));
  }

  throw "No se pudo convertir Term";
}

list[Term] toArgs(Tree t) {
  list[Term] result = [];

  visit(t) {
    case a: appl(_, _):
      result += [toTerm(a)];
  }

  return result;
}

RuleDecl toRule(Tree t) {
  switch (t) {
    case appl(_, [_, left, _, right, _]):
      return ruleDecl(toTerm(left), toTerm(right));
  }

  throw "No se pudo convertir RuleComponent";
}

RelOp toRelOp(Tree t) {
  return equalOp();
}

LogicExpr toRelation(Tree t) {
  switch (t) {
    case appl(_, [left, op, right]):
      return relationExpr(toTerm(left), toRelOp(op), toTerm(right));
  }

  throw "No se pudo convertir Relation";
}

LogicExpr toLogicExpr(Tree t) {
  if (isForall(t)) {
    return forallExpr("x", noSpace(), termExpr(nameTerm("temp")));
  }

  if (isExists(t)) {
    return existsExpr("x", noSpace(), termExpr(nameTerm("temp")));
  }
  
  if (isNeg(t)) {
    return toNeg(t);
  }
  
  if (isAnd(t)) {
    return toAnd(t);
    }
    
  if (isOr(t)) {
    return toOr(t);
    }

  if (contains(yield(t), "<") || contains(yield(t), ">") ||
      contains(yield(t), "=") || contains(yield(t), "in")) {
    return toRelation(t);
  }

  return termExpr(toTerm(t));
}

ExprDecl toExpr(Tree t) {
  switch (t) {
    case appl(_, [_, expr, _, _]):
      return exprDecl(toLogicExpr(expr), []);

    case appl(_, [_, expr, _, _, _]):
      return exprDecl(toLogicExpr(expr), []);
  }

  throw "No se pudo convertir ExpressionComponent";
}

EquationDecl toEquation(Tree t) {
  switch (t) {
    case appl(_, [_, left, _, right, _]):
      return equationDecl(toLogicExpr(left), toLogicExpr(right));
  }

  throw "No se pudo convertir EquationComponent";
}

bool isOperator(Tree t) {
  return contains(yield(t), "defoperator");
}

bool isVariable(Tree t) {
  return contains(yield(t), "defvar");
}

OperDef toOper(Tree t) {
  switch (t) {
    case appl(_, [_, name, _, typ, _, _]):
      return operDef(yield(name), toType(typ), []);

    case appl(_, [_, name, _, typ, attrs, _]):
      return operDef(yield(name), toType(typ), []);
  }

  throw "No se pudo convertir OperatorComponent";
}

VarBlock toVarBlock(Tree t) {
  return varBlock(toVarDecls(t));
}

VType toType(Tree t) {
  switch (t) {
    case appl(_, [name]):
      return simpleType(yield(name));

    case appl(_, [name, _, rest]):
      return arrowType(simpleType(yield(name)), toType(rest));
  }

  throw "No se pudo convertir Type";
}

list[VarDecl] toVarDecls(Tree t) {
  list[VarDecl] result = [];

  visit(t) {
    case d: appl(_, _):
      if (contains(yield(d), ":")) {
        result += [toVarDecl(d)];
      }
  }

  return result;
}

VarDecl toVarDecl(Tree t) {
  switch (t) {
    case appl(_, [name, _, typ]):
      return varDecl(yield(name), toType(typ));
  }

  throw "No se pudo convertir VarDecl";
}

bool isNeg(Tree t) {
  return contains(yield(t), "neg");
}

bool isAnd(Tree t) {
  return contains(yield(t), " and ");
}

bool isOr(Tree t) {
  return contains(yield(t), " or ");
}

bool isForall(Tree t) {
  return contains(yield(t), "forall");
}

bool isExists(Tree t) {
  return contains(yield(t), "exists");
}

LogicExpr toNeg(Tree t) {
  switch (t) {
    case appl(_, [_, expr]):
      return negExpr(toLogicExpr(expr));
  }

  throw "No se pudo convertir neg";
}

LogicExpr toAnd(Tree t) {
  switch (t) {
    case appl(_, [left, _, right]):
      return andExpr([toLogicExpr(left), toLogicExpr(right)]);
  }

  throw "No se pudo convertir and";
}

LogicExpr toOr(Tree t) {
  switch (t) {
    case appl(_, [left, _, right]):
      return orExpr([toLogicExpr(left), toLogicExpr(right)]);
  }

  throw "No se pudo convertir or";
}