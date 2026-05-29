module TypeChecker

import AST;
import IO;
import Set;
import List;

void check(Program p) {
  if (prog(vModule(name, _, comps)) := p) {
    set[str] spaces = {"Int", "Bool", "String", "Char", "Real"};
    set[str] vars = {};
    list[str] errors = [];

    for (comp <- comps) {
      if (spaceComp(simpleSpace(n)) := comp) spaces += {n};
      if (spaceComp(orderedSpace(child, _)) := comp) spaces += {child};
    }

    for (comp <- comps) {
      if (variableComp(varBlock(decls)) := comp) {
        for (varDecl(n, _) <- decls) vars += {n};
      }
    }

    for (comp <- comps) {
      if (operComp(operDef(name, typ)) := comp) {
        for (str t <- collectTypeNames(typ)) {
          if (t notin spaces) {
            errors += ["Error: tipo \'<t>\' en operador \'<name>\' no esta definido como espacio"];
          }
        }
      }
      if (variableComp(varBlock(decls)) := comp) {
        for (varDecl(vname, typ) <- decls) {
          for (str t <- collectTypeNames(typ)) {
            if (t notin spaces) {
              errors += ["Error: tipo \'<t>\' en variable \'<vname>\' no esta definido como espacio"];
            }
          }
        }
      }
    }

    for (comp <- comps) {
      if (exprComp(exprDecl(expr, _)) := comp) {
        for (str v <- collectVarNames(expr)) {
          if (v notin vars && v notin spaces) {
            errors += ["Error: variable \'<v>\' en expresion no esta declarada"];
          }
        }
      }
    }
    for (comp <- comps) {
      if (spaceComp(orderedSpace(child, parent)) := comp) {
        if (parent notin spaces) {
          errors += ["Error: espacio padre \'<parent>\' de \'<child>\' no esta definido"];
          }
        }
      }

    if (errors == []) {
      println("OK: no se encontraron errores de tipo");
    } else {
      for (e <- errors) println(e);
    }
  }
}

list[str] collectTypeNames(VType t) {
  switch(t) {
    case simpleType(name): return [name];
    case arrowType(left, right): return collectTypeNames(left) + collectTypeNames(right);
  }
  return [];
}

set[str] collectVarNames(LogicExpr e) {
  set[str] result = {};
  visit(e) {
    case termExpr(nameTerm(n)): result += {n};
    case relationExpr(nameTerm(l), _, nameTerm(r)): { result += {l}; result += {r}; }
  }
  return result;
}