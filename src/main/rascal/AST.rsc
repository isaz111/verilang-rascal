module AST

data AttrValue
  = attrName(str text)
  | attrInt(int number)
  | attrReal(real decimal)
  ;

data AttrItem
  = flagAttr(str attrNameText)
  | valuedAttr(str attrKey, AttrValue attrVal)
  ;

data VType
  = simpleType(str typeName)
  | arrowType(VType fromType, VType toType)
  ;

data RelOp
  = inOp()
  | lessEqOp()
  | greaterEqOp()
  | notEqualOp()
  | lessOp()
  | greaterOp()
  | equalOp()
  ;

data MaybeSpace
  = noSpace()
  | inSpace(str spaceName)
  ;

data Term
  = appTerm(str funcName, list[Term] arguments)
  | nameTerm(str identifier)
  | intTerm(int intValue)
  | realTerm(real realValue)
  | stringTerm(str stringValue)
  | charTerm(str charValue)
  ;

data LogicExpr
  = forallExpr(str variable, MaybeSpace domain, LogicExpr bodyExpr)
  | existsExpr(str variable, MaybeSpace domain, LogicExpr bodyExpr)
  | equivExpr(list[LogicExpr] expressions)
  | impliesExpr(list[LogicExpr] expressions)
  | orExpr(list[LogicExpr] expressions)
  | andExpr(list[LogicExpr] expressions)
  | negExpr(LogicExpr innerExpr)
  | relationExpr(Term leftTerm, RelOp operator, Term rightTerm)
  | termExpr(Term singleTerm)
  | groupedExpr(LogicExpr grouped)
  ;

data SpaceDecl
  = simpleSpace(str spaceName)
  | orderedSpace(str childSpace, str parentSpace)
  ;

data OperDef
  = operDef(str operName, VType operType)
  ;

data VarDecl
  = varDecl(str varName, VType varType)
  ;

data VarBlock
  = varBlock(list[VarDecl] declarations)
  ;

data RuleDecl
  = ruleDecl(Term leftSide, Term rightSide)
  ;

data ExprDecl
  = exprDecl(LogicExpr expression, list[AttrItem] attributes)
  ;

data EquationDecl
  = equationDecl(LogicExpr leftExpr, LogicExpr rightExpr)
  ;

data Component
  = spaceComp(SpaceDecl spaceDecl)
  | operComp(OperDef operDef)
  | variableComp(VarBlock varBlock)
  | ruleComp(RuleDecl ruleDecl)
  | exprComp(ExprDecl exprDecl)
  | equationComp(EquationDecl equationDecl)
  ;

data VModule
  = vModule(str moduleName, list[str] usingNames, list[Component] componentList)
  ;

data Program
  = prog(VModule mainModule)
  ;