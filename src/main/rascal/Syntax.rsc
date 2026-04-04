module Syntax

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r];
lexical WhitespaceAndComment = [\ \t\n\r];

keyword Reserved
  = "defmodule"
  | "using"
  | "defspace"
  | "defoperator"
  | "defvar"
  | "defrule"
  | "defexpression"
  | "defer"
  | "end"
  | "forall"
  | "exists"
  | "in"
  | "or"
  | "and"
  | "neg"
  ;

@category="identifier"
lexical Nombre = ([a-z][a-z0-9\-]* !>> [a-z0-9\-]) \ Reserved;

@category="number"
lexical IntLiteral = [0-9]+;

@category="number"
lexical FloatLiteral = [0-9]+ '.' [0-9]+;

start syntax Program
  = program: Module
  ;

syntax Module
  = module: 'defmodule' Nombre Using* Component* 'end'
  ;

syntax Using
  = using: 'using' Nombre
  ;

syntax Component
  = space: Space
  | operator: Operator
  | variable: Variable
  | rule: Rule
  | expression: Expression
  | equation: Equation
  | relation: Relation
  | attribute: Attribute
  ;

syntax Space
  = spaceDecl: 'defspace' Nombre ('<' Nombre)? 'end'
  ;

syntax Operator
  = operatorDecl: 'defoperator' Nombre ':' Type 'end'
  ;

syntax Type
  = typeDecl: Nombre ('->' Nombre)+
  ;

syntax Attribute
  = attribute: '[' AttributeItem+ ']'
  ;

syntax AttributeItem
  = attributeItem: Nombre (':' AttributeValue)?
  ;

syntax AttributeValue
  = nombreVal: Nombre
  | symbolVal: Symbol
  | intVal: IntLiteral
  | floatVal: FloatLiteral
  ;

syntax Variable
  = variableDecl: 'defvar' VarDeclList 'end'
  ;

syntax VarDeclList
  = varDeclList: VarDecl (',' VarDecl)*
  ;

syntax VarDecl
  = varDecl: Nombre ':' Nombre
  ;

syntax Rule
  = ruleDecl: 'defrule' Application '->' Application 'end'
  ;

syntax Application
  = app: '(' Nombre Argument+ ')'
  ;

syntax Argument
  = appArg: Application
  | termArg: Term
  ;

syntax Term
  = nombreTerm: Nombre
  | symbolTerm: Symbol
  | appTerm: Application
  ;

syntax Expression
  = expressionDecl: 'defexpression' LogicalExpression Attribute? 'end'
  ;

syntax LogicalExpression
  = quantifierExpr: Quantifier
  | binaryExpr: BinaryExpression
  ;

syntax Equation
  = equationDecl: LogicalExpression '=' LogicalExpression
  ;

syntax Quantifier
  = quantifier: ('forall' | 'exists') Nombre ('in' Nombre)? '.' LogicalExpression
  ;

syntax BinaryExpression
  = binary: UnaryExpression (('≡' | '=>' | 'or' | 'and') UnaryExpression)*
  ;

syntax UnaryExpression
  = negExpr: 'neg' UnaryExpression
  | baseExpr: Base
  ;

syntax Base
  = parenExpr: '(' BinaryExpression ')'
  | relationExpr: Relation
  | termExpr: Term
  ;

syntax Relation
  = relopRelation: Term Relop Term
  | namedRelation: Term Nombre Term
  ;

syntax Relop
  = inOp: 'in'
  | ltOp: '<'
  | gtOp: '>'
  | lteOp: '<='
  | gteOp: '>='
  | eqOp: '='
  | neqOp: '<>'
  ;

syntax Symbol
  = mulSym: '*'
  | divSym: '/'
  | subSym: '-'
  | addSym: '+'
  | powSym: '**'
  | modSym: '%'
  | ltSym: '<'
  | gtSym: '>'
  | lteSym: '<='
  | gteSym: '>='
  | neqSym: '<>'
  | eqSym: '='
  | implSym: '=>'
  | equivSym: '≡'
  ;