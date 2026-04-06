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
      if (isSpace(c) || isRule(c)) {
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

