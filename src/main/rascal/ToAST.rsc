module ToAST

import ParseTree;
import AST;
import Syntax;
import String;

Program toProgram(Tree t) {
  visit(t) {
    case m: appl(prod(sort("Module"), _, _), _):
      return prog(toModule(m));
  }

  throw "No se encontró Module dentro del Program";
}

VModule toModule(Tree t) {
  str txt = unparse(t);
  list[str] lines = split("\n", txt);

  str firstLine = trim(lines[0]);
  str moduleName = trim(replaceAll(firstLine, "defmodule", ""));

  return vModule(
    moduleName,
    toUsingList(t),
    toComponents(t)
  );
}


bool isUsing(Tree t) {
  return contains(unparse(t), "using");
}

list[str] toUsingList(Tree t) {
  list[str] result = [];

  visit(t) {
    case u: appl(_, _):
      if (isUsing(u)) {
        result += [unparse(u)];
      }
  }

  return result;
}

list[Component] toComponents(Tree t) {
  list[Component] result = [];

  visit(t) {
    case appl(prod(label("opDef", _), _, _), kids):
      result += [operComp(operDef(trim(unparse(kids[2])), toType(kids[6])))];
    case appl(prod(label("spaceSimple", _), _, _), kids):
      result += [spaceComp(simpleSpace(trim(unparse(kids[2]))))];
    case appl(prod(label("spaceOrdered", _), _, _), kids):
      result += [spaceComp(orderedSpace(trim(unparse(kids[2])), trim(unparse(kids[4]))))];
    case appl(prod(label("ruleDef", _), _, _), kids):
      result += [ruleComp(ruleDecl(toTerm(kids[2]), toTerm(kids[4])))];
    case appl(prod(label("varComp", _), _, _), kids):
      result += [variableComp(varBlock(toVarDecls(kids[2])))];
    case appl(prod(label("exprNoAttr", _), _, _), kids):
      result += [exprComp(exprDecl(toLogicExpr(kids[2]), []))];
    case appl(prod(label("equationDef", _), _, _), kids):
      result += [equationComp(equationDecl(toLogicExpr(kids[2]), toLogicExpr(kids[4])))];
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

  if (contains(unparse(t), "defexpression")) {
    return exprComp(toExpr(t));
  }

  if (contains(unparse(t), "defequation")) {
    return equationComp(toEquation(t));
  }

  return spaceComp(simpleSpace("temp"));
}

bool isSpace(Tree t) {
  return contains(unparse(t), "defspace");
}

bool isRule(Tree t) {
  return contains(unparse(t), "defrule");
}

SpaceDecl toSpace(Tree t) {
  switch (t) {
    case appl(_, [_, name, _]):
      return simpleSpace(unparse(name));

    case appl(_, [_, name1, _, name2, _]):
      return orderedSpace(unparse(name1), unparse(name2));
  }

  throw "No se pudo convertir SpaceComponent";
}

Term toTerm(Tree t) {
  switch (t) {
    case appl(_, [name]):
      return nameTerm(unparse(name));

    case appl(_, [intLit]):
      return intTerm(toInt(unparse(intLit)));

    case appl(_, [floatLit]):
      return realTerm(toReal(unparse(floatLit)));

    case appl(_, [_, name, args]):
      return appTerm(unparse(name), toArgs(args));
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
  str txt = unparse(t);

  if (txt == "in") {
    return inOp();
  }

  if (txt == "\u003C\u003D") {
    return lessEqOp();
  }

  if (txt == "\u003E\u003D") {
    return greaterEqOp();
  }

  if (txt == "\u003C") {
    return lessOp();
  }

  if (txt == "\u003E") {
    return greaterOp();
  }

  if (txt == "\u003C\u003E") {
    return notEqualOp();
  }

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
  return toForall(t);
  }
  
  if (isExists(t)) {
  return toExists(t);
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

  if (contains(unparse(t), "<") || contains(unparse(t), ">") ||
      contains(unparse(t), "=") || contains(unparse(t), "in")) {
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
  return contains(unparse(t), "defoperator");
}

bool isVariable(Tree t) {
  return contains(unparse(t), "defvar");
}

OperDef toOper(Tree t) {
  str raw = unparse(t);
  str sinDef = trim(replaceAll(raw, "defoperator", ""));
  str sinEnd = trim(replaceAll(sinDef, "end", ""));
  list[str] partes = split(":", sinEnd);
  if (size(partes) >= 2) {
    str nombre = trim(partes[0]);
    str tipo = trim(partes[1]);
    return operDef(nombre, simpleType(tipo));
  }

  throw "No se pudo convertir OperatorComponent";
}

VarBlock toVarBlock(Tree t) {
  return varBlock(toVarDecls(t));
}

VType toType(Tree t) {
  switch (t) {
    case appl(prod(label("arrowType", _), _, _), kids):
      return arrowType(simpleType(trim(unparse(kids[0]))), toType(kids[4]));
    case appl(prod(label("simpleType", _), _, _), kids):
      return simpleType(trim(unparse(kids[0])));
  }
  throw "No se pudo convertir Type";
}

list[VarDecl] toVarDecls(Tree t) {
  list[VarDecl] result = [];

  visit(t) {
    case d: appl(_, _):
      if (contains(unparse(d), ":")) {
        result += [toVarDecl(d)];
      }
  }

  return result;
}

VarDecl toVarDecl(Tree t) {
  switch (t) {
    case appl(_, [name, _, typ]):
      return varDecl(unparse(name), toType(typ));
  }

  throw "No se pudo convertir VarDecl";
}

bool isNeg(Tree t) {
  return contains(unparse(t), "neg");
}

bool isAnd(Tree t) {
  return contains(unparse(t), " and ");
}

bool isOr(Tree t) {
  return contains(unparse(t), " or ");
}

bool isForall(Tree t) {
  return contains(unparse(t), "forall");
}

bool isExists(Tree t) {
  return contains(unparse(t), "exists");
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

LogicExpr toForall(Tree t) {
  switch (t) {
    case appl(_, [_, var, _, body]):
      return forallExpr(unparse(var), noSpace(), toLogicExpr(body));

    case appl(_, [_, var, _, space, _, body]):
      return forallExpr(unparse(var), inSpace(unparse(space)), toLogicExpr(body));
  }

  throw "No se pudo convertir forall";
}

LogicExpr toExists(Tree t) {
  switch (t) {
    case appl(_, [_, var, _, body]):
      return existsExpr(unparse(var), noSpace(), toLogicExpr(body));

    case appl(_, [_, var, _, space, _, body]):
      return existsExpr(unparse(var), inSpace(unparse(space)), toLogicExpr(body));
  }

  throw "No se pudo convertir exists";
}