module Parser

import ParseTree;
import Syntax;
import ToAST;
import Generator;
import TypeChecker;
import IO;
import AST;

void main() {
  loc file = |project://verilang-rascal/src/main/rascal/test.veri|;
  Tree t = parse(#start[Program], file);
  AST::Program p = toProgram(t);
  runProgram(p);
  println("---");
  println("Type checking...");
  check(p);
}