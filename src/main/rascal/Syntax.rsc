module Syntax

layout Layout = [\ \t\r]*;
lexical NL = "\n";

start syntax Program
  = Module NL*
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
  = opNoAttr: 'defoperator' Nombre ':' Type 'end'
  | opAttr: 'defoperator' Nombre ':' Type Attribute? 'end'
  ;

syntax Type
  = simpleType: Nombre
  | arrowType: Nombre Arrow Type
  ;

//variables  
syntax VariableComponent
  = varComp: 'defvar' VarDeclList 'end'
  ;

syntax VarDeclList
  = oneVarDecl: VarDecl
  | manyVarDecls: VarDecl ',' VarDeclList
  ;

syntax VarDecl
  = varDecl: Nombre ':' Type
  ;

// reglas
syntax RuleComponent
  = 'defrule' Term Arrow Term 'end'
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
  = exprNoAttr: 'defexpression' LogicalExpression 'end'
  | exprAttr: 'defexpression' LogicalExpression Attribute 'end'
  ;

syntax EquationComponent
  = 'defequation' LogicalExpression Equal LogicalExpression 'end'
  ;


//attributes
syntax Attribute
  = '[' AttributeItem (',' AttributeItem)* ']'
  ;

syntax AttributeItem
  = attrPlain: Nombre
  | attrKeyVal: Nombre ':' AttributeValue
  ;


syntax AttributeValue
  = attrName: Nombre
  | attrInt: IntLiteral
  | attrFloat: FloatLiteral
  | attrEmpty: EmptySet
  ;

// logic
syntax LogicalExpression
  = logicalQuant: Quantifier
  | logicalEquiv: EquivExpr
  ;

syntax Quantifier
  = forallExpr: 'forall' Nombre ('in' Nombre)? Dot LogicalExpression
  | existsExpr: 'exists' Nombre ('in' Nombre)? Dot LogicalExpression
  ;

syntax EquivExpr
  = equivSingle: ImplExpr
  | equivChain: ImplExpr Equiv EquivExpr
  ;

syntax ImplExpr
  = implSingle: OrExpr
  | implChain: OrExpr Implies ImplExpr
  ;

syntax OrExpr
  = orSingle: AndExpr
  | orChain: AndExpr 'or' OrExpr
  ;

syntax AndExpr
  = andSingle: UnaryExpr
  | andChain: UnaryExpr 'and' AndExpr
  ;

syntax UnaryExpr
  = negExpr: 'neg' UnaryExpr
  | unaryBase: BaseExpr
  ;

syntax BaseExpr
  = baseParen: '(' LogicalExpression ')'
  | baseRelation: Relation
  | baseBoolAtom: BoolAtom
  ;

syntax BoolAtom
  = boolName: Nombre
  ;


syntax Relation
  = relIn: Term 'in' Term
  | relLessEq: Term LessEq Term
  | relGreaterEq: Term GreaterEq Term
  | relNotEqual: Term NotEqual Term
  | relLess: Term Less Term
  | relGreater: Term Greater Term
  | relEqual: Term Equal Term
  ;

//syntax RelOp
//  = 'in'
//  | LessEq
//  | GreaterEq
//  | NotEqual
//  | Less
//  | Greater
//  | Equal
//  ;


// term

syntax Term
  = termApp: Application
  | termName: Nombre
  | termInt: IntLiteral
  | termFloat: FloatLiteral
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

lexical EmptySet = "∅";

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