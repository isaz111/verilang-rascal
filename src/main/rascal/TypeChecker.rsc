module TypeChecker

import AST;
import IO;
import Set;
import List;

list[str] checkProgram(Program p) {
  list[str] errors = [];

  if (prog(vModule(_, _, comps)) := p) {
    set[str] spaces = {"Int", "Bool", "String", "Char", "Real"};
    set[str] vars = {};
    set[str] operators = {};

    for (comp <- comps) {
      if (spaceComp(simpleSpace(n)) := comp) {
        spaces += {n};
      }
      else if (spaceComp(orderedSpace(child, _)) := comp) {
        spaces += {child};
      }
      else if (variableComp(varBlock(decls)) := comp) {
        for (varDecl(vname, _) <- decls) {
          vars += {vname};
        }
      }
      else if (operComp(operDef(opName, _)) := comp) {
        operators += {opName};
      }
    }

    for (comp <- comps) {
      if (spaceComp(orderedSpace(child, parent)) := comp) {
        if (parent notin spaces) {
          errors += [
            "Error de tipos: el espacio padre " + parent + " de " + child + " no esta definido."
          ];
        }
      }
    }

    for (comp <- comps) {
      if (exprComp(exprDecl(expr, _)) := comp) {
        errors += checkLogicExpr(expr, spaces, vars, operators);
      }
      else if (equationComp(equationDecl(left, right)) := comp) {
        errors += checkLogicExpr(left, spaces, vars, operators);
        errors += checkLogicExpr(right, spaces, vars, operators);
      }
    }

    return errors;
  }

  return ["Error de tipos: estructura de programa no reconocida."];
}

list[str] checkLogicExpr(LogicExpr expr, set[str] spaces, set[str] vars, set[str] operators) {
  list[str] errors = [];

  set[str] boundVars = collectBoundVars(expr);
  set[str] domains = collectDomains(expr);
  set[str] names = collectNames(expr);

  for (domain <- domains) {
    if (domain notin spaces) {
      errors += [
        "Error de tipos: el dominio " + domain + " usado en un cuantificador no esta definido como espacio."
      ];
    }
  }

  set[str] allowedNames = spaces + vars + operators + boundVars;

  for (name <- names) {
    if (name != "?" && name notin allowedNames) {
      errors += [
        "Error de tipos: el nombre " + name + " usado en una expresion no esta declarado."
      ];
    }
  }

  return errors;
}

set[str] collectNames(LogicExpr expr) {
  set[str] result = {};

  visit(expr) {
    case nameTerm(n): {
      result += {n};
    }
  }

  return result;
}

set[str] collectBoundVars(LogicExpr expr) {
  set[str] result = {};

  visit(expr) {
    case forallExpr(v, _, _): {
      result += {v};
    }

    case existsExpr(v, _, _): {
      result += {v};
    }
  }

  return result;
}

set[str] collectDomains(LogicExpr expr) {
  set[str] result = {};

  visit(expr) {
    case inSpace(spaceName): {
      result += {spaceName};
    }
  }

  return result;
}

void check(Program p) {
  list[str] errors = checkProgram(p);

  if (errors == []) {
    println("OK: no se encontraron errores de tipo");
  }
  else {
    for (e <- errors) {
      println(e);
    }
  }
}