module RunnerJson

import IO;
import ParseTree;
import Syntax;
import AST;
import ToAST;
import Generator;
import TypeChecker;
import String;
import List;

str esc(str s) =
  replaceAll(
    replaceAll(
      replaceAll(
        replaceAll(s, "\\", "\\\\"),
        "\"", "\\\""
      ),
      "\n", "\\n"
    ),
    "\t", "\\t"
  );

str jsonArr(list[str] items) =
  "[<intercalate(", ", ["\"<esc(i)>\"" | i <- items])>]";

str jsonResult(
  bool success,
  str modName,
  list[str] modules,
  bool parseOk,
  bool tcOk,
  bool semOk,
  list[str] tcErrs,
  list[str] semErrs,
  list[str] output,
  str err,
  str codigoFormateado,
  str resumen
) =
  "{\"success\":<success>,"
  + "\"module\":\"<esc(modName)>\","
  + "\"modules\":<jsonArr(modules)>,"
  + "\"parseOk\":<parseOk>,"
  + "\"typeCheckOk\":<tcOk>,"
  + "\"semanticOk\":<semOk>,"
  + "\"typeErrors\":<jsonArr(tcErrs)>,"
  + "\"semanticErrors\":<jsonArr(semErrs)>,"
  + "\"output\":<jsonArr(output)>,"
  + "\"error\":\"<esc(err)>\","
  + "\"codigoFormateado\":\"<esc(codigoFormateado)>\","
  + "\"resumen\":\"<esc(resumen)>\"}";

str getModuleName(Program p) {
  switch(p) {
    case prog(vModule(name, _, _)):
      return name;
  }

  return "";
}

list[str] getModules(Program p) {
  switch(p) {
    case prog(vModule(name, _, _)):
      return [name];
  }

  return [];
}

list[str] getUsings(Program p) {
  switch(p) {
    case prog(vModule(_, usings, _)):
      return usings;
  }

  return [];
}

int countComponents(Program p) {
  switch(p) {
    case prog(vModule(_, _, comps)):
      return size(comps);
  }

  return 0;
}

list[str] describeComponents(Program p) {
  list[str] result = [];

  switch(p) {
    case prog(vModule(_, _, comps)): {
      int spaces = 0;
      int operators = 0;
      int variables = 0;
      int rules = 0;
      int expressions = 0;
      int equations = 0;

      for (c <- comps) {
        switch(c) {
          case spaceComp(_): spaces += 1;
          case operComp(_): operators += 1;
          case variableComp(_): variables += 1;
          case ruleComp(_): rules += 1;
          case exprComp(_): expressions += 1;
          case equationComp(_): equations += 1;
        }
      }

      result += ["Espacios: <spaces>"];
      result += ["Operadores: <operators>"];
      result += ["Bloques de variables: <variables>"];
      result += ["Reglas: <rules>"];
      result += ["Expresiones: <expressions>"];
      result += ["Ecuaciones: <equations>"];
    }
  }

  return result;
}

loc pathToLoc(str rawPath) {
  str path = replaceAll(rawPath, "\\", "/");

  if (/^[A-Za-z]:\/.*/ := path) {
    return |file:///| + path;
  }

  if (startsWith(path, "/")) {
    return |file://| + path;
  }

  return |cwd:///| + path;
}

void main(list[str] args) {
  str src;

  try {
    loc file;

    if (isEmpty(args)) {
      file = |project://verilang-rascal/src/main/rascal/test_operator.veri|;
    } else {
      file = pathToLoc(args[0]);
    }

    src = readFile(file);
  }
  catch e: {
    println(jsonResult(
      false,
      "",
      [],
      false,
      false,
      false,
      [],
      [],
      [],
      "No se pudo leer el archivo: <e>",
      "",
      ""
    ));
    return;
  }

  Tree cst;

  try {
    cst = parse(#start[Program], src);
  }
  catch ParseError(loc at): {
    println(jsonResult(
      false,
      "",
      [],
      false,
      false,
      false,
      [],
      [],
      [],
      "Error de parsing en <at>",
      "",
      ""
    ));
    return;
  }
  catch e: {
    println(jsonResult(
      false,
      "",
      [],
      false,
      false,
      false,
      [],
      [],
      [],
      "Error de parsing: <e>",
      "",
      ""
    ));
    return;
  }

  Program ast;

  try {
    ast = toProgram(cst);
  }
  catch e: {
    println(jsonResult(
      false,
      "",
      [],
      true,
      false,
      false,
      [],
      [],
      [],
      "Error construyendo AST: <e>",
      "",
      ""
    ));
    return;
  }

  str modName = getModuleName(ast);
  list[str] modules = getModules(ast);
  list[str] usings = getUsings(ast);
  int n = countComponents(ast);

  str codigo = generateProgram(ast);

  list[str] typeErrors = checkProgram(ast);
  bool typeOk = typeErrors == [];
  bool semanticOk = typeOk;

  str typeStatus = "FAIL";
  if (typeOk) {
    typeStatus = "OK";
  }

  str modulesTxt = intercalate(", ", modules);

  list[str] output = [
    "Parser OK",
    "Type checker: <typeStatus>",
    "Modulo principal: <modName>",
    "Modulos encontrados: <modulesTxt>",
    "Usings encontrados: <size(usings)>",
    "Cantidad de componentes: <n>"
  ] + describeComponents(ast);

  str resumen;

  if (typeOk) {
    resumen =
      "El archivo VeriLang fue procesado correctamente. "
      + "Se encontro el modulo <modName> con <n> componente(s), sin errores de tipos.";
  } else {
    resumen =
      "El archivo VeriLang fue parseado correctamente, "
      + "pero se encontraron errores de tipos en el modulo <modName>.";
  }

  println(jsonResult(
    typeOk,
    modName,
    modules,
    true,
    typeOk,
    semanticOk,
    typeErrors,
    [],
    output,
    "",
    codigo,
    resumen
  ));
}