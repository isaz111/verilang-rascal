module TypeChecker

import analysis::typepal::TypePal;
import Syntax;
import ParseTree;
import IO;

void checkProgram(loc file) {
  start[Program] pt = parse(#start[Program], file);
  println("Parsed OK: <file>");
  println("TypePal ready for type checking");
}