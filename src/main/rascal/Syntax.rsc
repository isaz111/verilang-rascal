module Syntax

layout Layout = [\ \t\r]*;
lexical NL = "\n";

start syntax Program
  = Module
  ;

syntax Module
  = 'defmodule' Nombre NL
    UsingList
    ComponentSection
    'end'
  ;

syntax UsingList
  = (Using NL)*
  ;

syntax ComponentSection
  = (Component (NL Component)*)?
    NL?
  ;
syntax Using
  = 'using' Nombre
  ;


// componentes
syntax Component
  = SpaceComponent
  | OperatorComponent
  | VariableComponent
  | RuleComponent
  | ExpressionComponent
  | EquationComponent
  ;


// space
syntax SpaceComponent
  = 'defspace' Nombre Less Nombre 'end'
  | 'defspace' Nombre 'end'
  ;


//operator
syntax OperatorComponent
  = 'defoperator' Nombre ':' Type Attribute? 'end'
  ;

syntax Type
  = Nombre (Arrow Type)?
  ;


//variables necesarias 
syntax VariableComponent
  = 'defvar' VarDeclList 'end'
  ;

syntax VarDeclList
  = VarDecl (',' VarDecl)*
  ;

syntax VarDecl
  = Nombre ':' Nombre
  ;


// reglas
syntax RuleComponent
  = 'defrule' Application Arrow Application 'end'
  ;


// app
syntax Application
  = '(' Nombre Argument+ ')'
  ;

syntax Argument
  = Application
  | Nombre
  | IntLiteral
  | FloatLiteral
  ;


// expresiones
syntax ExpressionComponent
  = 'defexpression' LogicalExpression Attribute? 'end'
  ;

syntax EquationComponent
  = 'defequation' LogicalExpression Equal LogicalExpression 'end'
  ;


//attributes
syntax Attribute
  = '[' AttributeItem+ ']'
  ;

syntax AttributeItem
  = Nombre (':' AttributeValue)?
  ;

syntax AttributeValue
  = Nombre
  | IntLiteral
  | FloatLiteral
  ;


// logic
syntax LogicalExpression
  = Quantifier
  > EquivExpr
  ;

syntax Quantifier
  = ('forall' | 'exists') Nombre ('in' Nombre)? Dot LogicalExpression
  ;

syntax EquivExpr
  = ImplExpr (Equiv ImplExpr)*
  ;

syntax ImplExpr
  = OrExpr (Implies OrExpr)*
  ;

syntax OrExpr
  = AndExpr ('or' AndExpr)*
  ;

syntax AndExpr
  = UnaryExpr ('and' UnaryExpr)*
  ;

syntax UnaryExpr
  = 'neg' UnaryExpr
  | BaseExpr
  ;

syntax BaseExpr
  = '(' LogicalExpression ')'
  | Relation
  | Term
  ;


//relaciones
syntax Relation
  = Term RelOp Term
  ;

syntax RelOp
  = 'in'
  | LessEq
  | GreaterEq
  | NotEqual
  | Less
  | Greater
  | Equal
  ;


// term

syntax Term
  = Application
  | Nombre
  | IntLiteral
  | FloatLiteral
  ;


// id
syntax Nombre
  = ID
  ;

lexical ID
  = [a-zA-Z][a-zA-Z0-9\-]* !>> [a-zA-Z0-9\-]
  \ Reserved
  ;


lexical IntLiteral
  = [0-9]+ !>> [0-9]
  ;

lexical FloatLiteral
  = [0-9]+ "." [0-9]+ !>> [0-9]
  ;


// tk
// se pusieron en codigo para evitar problemas con el parser
lexical Less = "\u003C" !>> "\u003D" !>> "\u003E";
lexical Greater = "\u003E" !>> "\u003D";
lexical LessEq = "\u003C\u003D";
lexical GreaterEq = "\u003E\u003D";
lexical NotEqual = "\u003C\u003E";
lexical Equal = "\u003D" !>> "\u003E";
lexical Implies  = "\u003D\u003E";
lexical Arrow = "\u002D\u003E";
lexical Dot = "." !>> [0-9];
lexical Equiv  = "≡";


// reservadas
keyword Reserved
  = 'defmodule'
  | 'using'
  | 'defspace'
  | 'defoperator'
  | 'defvar'
  | 'defrule'
  | 'defexpression'
  | 'defequation'
  | 'end'
  | 'forall'
  | 'exists'
  | 'in'
  | 'and'
  | 'or'
  | 'neg'
  | 'defer'
  ;