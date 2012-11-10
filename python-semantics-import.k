require "python-semantics-builtin-modules.k"
require "python-semantics-os.k"

module PYTHON-SEMANTICS-IMPORT
  imports PYTHON-SEMANTICS-BUILTIN-MODULES
  imports PYTHON-SEMANTICS-OS

  syntax K ::= bootstrap(Expression, Set) [strict(1)]
              | makeSymbol(String, Expression) [strict(2)]
              | doImportlib(Expression) [strict]

  rule importlib => doImportlib({.KeyData})
  rule <k> doImportlib(Dict:Object) => Dict["path_sep"], .Expressions := pathSeparator(OS) ~> bootstrap(Dict, SetItem("_warnings") SetItem("imp") SetItem("sys") SetItem("marshal") SetItem("_os")) ~> executeModule(codeObject(String2Id("importlib._bootstrap"), .Parameters, Importlib, true), ref("builtins"), Dict) ~> makeSymbol("__import__", Dict["__import__"]) ...</k>
       <importlib> Importlib </importlib>
       <os> OS </os>

  rule (. => Dict[S], .Expressions := ref(S)) ~> bootstrap(Dict, (SetItem(S) => .) _)
  rule bootstrap(_, .) => .

  rule <k> makeSymbol(S, O:Object) => . ...</k>
       <symbols>... . => S |-> id(O) ...</symbols>


  rule (. => moduleTarget(Module), .Expressions := doImport(Module, .ModuleAliases) ) ~> import (Module , Rest => Rest)
  rule import .ModuleAliases => .

  rule from Module:RelativeModule import Fromlist:ModuleAliases => moduleTargets(Fromlist) := tuple(importFrom(doImport(Module, Fromlist), moduleNameIds(Fromlist)))

  syntax ObjRef ::= doImport(K, K)
  rule doImport(Module, Fromlist) => ref("builtins") . String2Id("__import__") (moduleName(Module), ref("globals")(.Arguments), ref("locals")(.Arguments), test(Fromlist ==K .ModuleAliases, ref("None"), tuple(moduleNames(Fromlist))), moduleLevel(Module), .Arguments)

  syntax NAME ::= moduleTarget(K) [function]
  rule moduleTarget(_ as Name) => Name
  rule moduleTarget(Module . _) => moduleTarget(Module)
  rule moduleTarget(Name:Id) => Name

  syntax String ::= moduleName(K) [function]
  rule moduleName(Module as _) => moduleName(Module)
  rule moduleName(Module . Name) => moduleName(Module) +String "." +String Id2String(Name)
  rule moduleName(.dir) => ""
  rule moduleName(. Module) => moduleName(Module)
  rule moduleName(Name:Id) => Id2String(Name)

  syntax Int ::= moduleLevel(K) [function]
  rule moduleLevel(.dir) => 1
  rule moduleLevel(. Module) => moduleLevel(Module) +Int 1
  rule moduleLevel(_ as _) => 0
  rule moduleLevel(_:Expression) => 0

  syntax Expressions ::= moduleNames(ModuleAliases) [function]
  rule moduleNames(Module, Rest) => moduleName(Module) , moduleNames(Rest)
  rule moduleNames(.ModuleAliases) => .Expressions

  syntax Expressions ::= moduleTargets(ModuleAliases) [function]
  rule moduleTargets(Module, Rest) => moduleName(Module) , moduleTargets(Rest)
  rule moduleTargets(.ModuleAliases) => .Expressions

  syntax Expressions ::= moduleNameIds(ModuleAliases) [function]
  rule moduleNameIds(Name:Id, Rest) => Name , moduleNameIds(Rest)
  rule moduleNameIds(Name:Id as _, Rest) => Name , moduleNameIds(Rest)
  rule moduleNameIds(.ModuleAliases) => .Expressions

  syntax Expressions ::= importFrom (Expression, Expressions) [strict(1)]
  rule importFrom(O:Object, Name , Rest) => O . Name , importFrom(O, Rest)
  rule importFrom(_, .Expressions) => .Expressions

endmodule