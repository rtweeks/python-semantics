require "python-semantics-slicing.k"

module PYTHON-SEMANTICS-LISTS
  imports PYTHON-SEMANTICS-SLICING

  syntax K ::= setValue(Object)

  rule invokeBuiltin(obj("add_list",_), ListItem(O:Object) ListItem(O2:Object), .) => test(and(istype(O, ref("list")), istype(O2, ref("list"))), mutable(list(listvalue(O) listvalue(O2)),ref("list")), raiseInternal("TypeError", "can only concatenate list to list"))

  rule invokeBuiltin(obj("getitem_list",_), ListItem(O:Object) ListItem(O2:Object), .) => test(istype(O2, ref("slice")), ref("list")(slice(O, O2)), getitemList(O, ref("index")(O2, .Arguments)))

  syntax ObjRef ::= getitemList(Exp, Exp) [strict]
  rule getitemList(O:Object, O2:Object) => test(intvalue(O2) >=Int 0 -Int lengthList listvalue(O) andBool intvalue(O2) <Int lengthList listvalue(O), test(intvalue(O2) >=Int 0, get(listvalue(O), intvalue(O2)), get(listvalue(O), lengthList listvalue(O) +Int intvalue(O2))), raiseInternal("IndexError", "list index out of range"))

  rule invokeBuiltin(obj("len_list",_), ListItem(O), .) => lengthList listvalue(O)

  rule invokeBuiltin(obj("new_list",_), ListItem(O) _, .) => newHelper(O, ref("list"), .) ~> mutable(list(.), O)
  rule invokeBuiltin(obj("init_list",_), ListItem(_:Object), .) => ref("None")
  rule invokeBuiltin(obj("init_list",_), ListItem(O) ListItem(O2), .) => iterate(O2, .) ~> setValue(O)

  rule <k> list(L:List) ~> setValue(obj(B:ObjId,_)) => ref("None") ...</k>
       <object>...
         <id>B</id>
         <oattrs>... "__value__" |-> (_ => list(Refify(Idify(L)))) ...</oattrs>
       ...</object>

  rule invokeBuiltin(obj("eq_list",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "list", "list", (ref("bool") (equalList(listvalue(O), (listvalue(O2))))))
  rule invokeBuiltin(obj("ne_list",_), ListItem(O) ListItem(O2), .) => binaryOp(O, O2, "list", "list", not equalList(listvalue(O), listvalue(O2)))

  syntax ObjRef ::= "equalList" "(" List "," List ")"

  rule equalList(ListItem(B) L, ListItem(B2) L2:List) => B == B2 and equalList(L, L2)
  rule equalList(ListItem(_) _, .) => ref("False")
  rule equalList(., ListItem(_) _) => ref("False")
  rule equalList(.,.) => ref("True")

  rule invokeBuiltin(obj("extend_list",_), ListItem(O:Object) ListItem(O2:Object), .) => iterate(O2, .) ~> extendList(O)
  syntax ObjRef ::= extendList(Object)
  rule list(L:List) ~> extendList(O:Object) => setattr(id(O), "__value__", list(getl(getattr(O, "__value__")) Refify(Idify(L)))) ~> ref("None")

  rule invokeBuiltin(obj("append_list",_), ListItem(O:Object) ListItem(O2:Object), .) => setattr(id(O), "__value__", list(getl(getattr(O, "__value__")) ListItem(ref(id(O2))))) ~> ref("None")

  rule invokeBuiltin(obj("setitem_list",_), ListItem(O) ListItem(Key) ListItem(Value), .) => test(istype(Key, ref("slice")), ?Slice:Exp, setitemList(O, ref("index")(Key:Object), Value))
  syntax Exp ::= setitemList(Exp, Exp, Exp) [strict]
  rule setitemList(O:Object, Key:Object, Value:Object) => test(intvalue(Key) >=Int 0 -Int lengthList listvalue(O) andBool intvalue(Key) <Int lengthList listvalue(O), test(intvalue(Key) >=Int 0, setattr(id(O), "__value__", list(get(listvalue(O), 0, intvalue(Key)) ListItem(Value) get(listvalue(O), intvalue(Key) +Int 1, lengthList(listvalue(O))))), setattr(id(O), "__value__", list(get(listvalue(O), 0, lengthList listvalue(O) +Int intvalue(Key)) ListItem(Value) get(listvalue(O), lengthList listvalue(O) +Int intvalue(Key) +Int 1, lengthList(listvalue(O)))))), raiseInternal("IndexError", "list assignment index out of range")) ~> ref("None")

endmodule
