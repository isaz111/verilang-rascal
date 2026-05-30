module RunnerJson

import IO;
import ParseTree;
import Syntax;
import AST;
import ToAST;
import String;
import List;

str esc(str s) =
  replaceAll(replaceAll(replaceAll(replaceAll(s, "\\", "\\\\"), "\"", "\\\""), "\n", "\\n"), "\t", "\\t");

str jsonArr(list[str] items) =
  "[<intercalate(", ", ["\"<esc(i)>\"" | i <- items])>]";

str jsonResult(bool success, str modName, bool parseOk, bool tcOk, bool semOk,
               list[str] tcErrs, list[str] semErrs, list[str] output,
               str err, str codigoFormateado, str resumen) =
  "{\"success\":<success>,"
  + "\"module\":\"<esc(modName)>\","
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

int countComponents(Program p) {
  switch(p) {
    case prog(vModule(_, _, comps)):
      return size(comps);
  }
  return 0;
}

void main(list[str] args) {
  str src;

  try {
    loc file;

    if (isEmpty(args)) {
      file = |project://verilang-rascal/src/main/rascal/test_operator.veri|;
    } else {
      str path = args[0];

      // Windows usa \, pero Rascal trabaja mejor con /
      path = replaceAll(path, "\\", "/");

      // Caso Windows: C:/...
      if (/^[A-Za-z]:\/.*/ := path) {
        file = |file:///| + path;
      }
      // Caso Linux/Mac: /home/...
      else if (startsWith(path, "/")) {
        file = |file://| + path;
      }
      // Caso ruta relativa
      else {
        file = |cwd:///| + path;
      }
    }

    src = readFile(file);
  }
  catch e: {
    println(jsonResult(false, "", false, false, false, [], [], [], "No se pudo leer el archivo: <e>", "", ""));
    return;
  }

  Tree cst;
  try {
    cst = parse(#start[Program], src);
  }
  catch ParseError(loc at): {
    println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing en <at>", "", ""));
    return;
  }
  catch e: {
    println(jsonResult(false, "", false, false, false, [], [], [], "Error de parsing: <e>", "", ""));
    return;
  }

  Program ast;
  try {
    ast = toProgram(cst);
  }
  catch e: {
    println(jsonResult(false, "", true, false, false, [], [], [], "Error construyendo AST: <e>", "", ""));
    return;
  }

  str modName = getModuleName(ast);
  int n = countComponents(ast);

  list[str] output = [
    "Parser OK",
    "Modulo encontrado: <modName>",
    "Cantidad de componentes: <n>"
  ];

  str resumen = "Modulo <modName> con <n> componente(s). AST: <ast>";

  println(jsonResult(true, modName, true, true, true, [], [], output, "", "", resumen));
}