import 
    ../utils/utils, buffers

from ops import Operation
from otypes import oall

## Scope related definitions
type
  Scope* {.header: memory,
           header: client_session,
           importcpp: "std::shared_ptr<tensorflow::Scope>".} = object

    ## The Scope Type is a wrapper around the c++ Scope which is basically the "region" (with its computation graph) where the 
    ## operations exsist. It is represented through a shared pointer here because it has no default constructor and therefore
    ## cannot be declared like:
    ##   Scope foo;
    ## which is excatly what the nim compiler does.

proc newRootScope*(): Scope {.header: client_session,
                              header: memory,
                              importcpp: "std::make_shared<tensorflow::Scope>(std::move(tensorflow::Scope::NewRootScope()))".}

  ## Constructor for the Scope type creating a new RootScope.
  ## 
  ## Returns:
  ##   A Scope object representing the new RootScope.

proc ok*(scope: Scope) : bool {.importcpp: "#->ok()".}

  ## Method to check if an error occured in the context of a Scope object.
  ## 
  ## Args:
  ##   scope: The Scope that should be checked.
  ## Returns:
  ##   Wether an error occured in the given Scope.

proc inewSubScope(rt: Scope, name: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->NewSubScope(#)))".}

proc newSubScope*(rt: Scope, name: string): Scope =
  return rt.inewSubScope(newCPPString(name))

  ## Returns a Subscope with the given name.
  ## This is useful for visualization in tensorboard.

proc iwithOpName(rt: Scope, name: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithOpName(#)))".}

proc withOpName*(rt: Scope, name: string): Scope =
  return rt.iwithOpName(newCPPString(name))

  ## Returns a scope applying the given name to all ops.

proc withControlDependencies*(rt: Scope, control_dep: ArraySlice[Operation[oall]] | oall): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithControlDependencies(#)))".}

  ## Return a new scope. All ops created within the returned scope will have as
  ## control dependencies the union of operations in the control_deps vector
  ## and the control dependencies of the current scope.

proc withNoControlDependencies*(rt: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithNoControlDependencies()))".}

  ## Return a new scope. All ops created within the returned scope will have no
  ## control dependencies on other operations.

proc iwithDevice(rt: Scope, device: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithDevice(#)))".}

proc withDevice*(rt: Scope, device: string): Scope =
  return rt.iwithDevice(newCPPString(device))

  ## Returns a scope using the given device.

proc iwithAssignedDevice(rt: Scope, assignedDevice: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithAssignedDevice(#)))".}

proc withAssignedDevice*(rt: Scope, assignedDevice: string): Scope =
  return rt.iwithAssignedDevice(newCPPString(assignedDevice))
  
  ## Returns a new scope.  All ops created within the returned scope will have
  ## their assigned device set to `assigned_device`.

proc iwithXlaCluster(scope: Scope, xla_cluster: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithXlaCluster(#)))".}

proc withXlaCluster*(scope: Scope, xla_cluster: string): Scope =
  return scope.iwithXlaCluster(newCPPString(xla_cluster))
  
  ## Returns a new scope.  All ops created within the returned scope will have
  ## their _XlaCluster attribute set to `xla_cluster`.

proc colocateWith*(scope: Scope, op: Operation[oall] | oall): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ColocateWith(#)))".}
  
  ## Return a new scope. All ops created within the returned scope will be
  ## co-located on the device where op is placed.
  ## NOTE: This function is intended to be use internal libraries only for
  ## controlling placement of ops on to devices. Public use is not encouraged
  ## because the implementation of device placement is subject to change.

proc clearColocation*(scope: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ClearColocation(#)))".}
  
  ## Clear all colocation constraints.

proc exitOnError*(scope: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ExitOnError(#)))".}
  
  ## Return a new scope. The op-constructor functions taking the returned scope
  ## as the scope argument will exit as soon as an error is detected, instead
  ## of setting the status on the scope.

proc iwithKernelLabel(scope: Scope, kernel_label: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithKernelLabel(#)))".}

proc withKernelLabel*(scope: Scope, kernel_label: string): Scope =
  return scope.iwithKernelLabel(newCPPString(kernel_label))
  
  ## Return a new scope. All ops created with the new scope will have
  ## kernel_label as the value for their '_kernel' attribute;

proc igetUniqueNameForOp(scope: Scope, default_name: cppstring): cppstring {.importcpp:"#->GetUniqueNameForOp(#)".}

proc getUniqueNameForOp*(scope: Scope, default_name: string): string =
  return $scope.igetUniqueNameForOp(newCPPString(default_name))

  ## Return a unique name, using default_name if an op name has not been
  ## specified.

template to_oinvalid*   (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oinvalid)).output
template to_odouble*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, odouble)).output
template to_ofloat*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ofloat)).output
template to_oint64*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oint64)).output
template to_oint32*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oint32)).output
template to_ouint8*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ouint8)).output
template to_oint16*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oint16)).output
template to_oint8*      (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oint8)).output
template to_ostring*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ostring)).output
template to_obool*      (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, obool)).output
template to_ouint16*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ouint16)).output
template to_ouint32*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ouint32)).output
template to_ouint64*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ouint64)).output
template to_ocomplex64* (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ocomplex64)).output
template to_ocomplex128*(x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ocomplex128)).output
template to_oqint8*     (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oqint8)).output
template to_oquint8*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oquint8)).output
template to_oqint32*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oqint32)).output
template to_obfloat16*  (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, obfloat16)).output
template to_oqint16*    (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oqint16)).output
template to_oquint16*   (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oquint16)).output
template to_ohalf*      (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ohalf)).output
template to_oresource*  (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, oresource)).output
template to_ovariant*   (x: untyped, scope: Scope): untyped = 
  nconst(scope, tensor(x, ovariant)).output
template to*   (x: untyped, scope: Scope, dtype: type): untyped = 
  nconst(scope, tensor(x, dtype)).output