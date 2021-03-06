## This is the base Layer type everything else inherits from. It defines how all layers behave by the
## supplied methods.
##
## Example:
##
## .. code:: nim
##
##    type AddValue = ref object of Layer
##        value: float
##    
##    method `$`(layer: AddValue): string = "AddValue"
##    
##    method make(layer: AddValue, root: Scope, shape: var seq[int]): proc(rt: Scope, input: Out): Out = 
##        # in this context use root as Scope
##        # this is only the setup context preparing your computation
##        let value = root.Const(addvalue.value)
##    
##        return proc(rt: Scope, input: Out): Out = 
##                    # here use rt as Scope
##                    # this is the proc that will be used in the fit/eval methods
##                    return rt.Add(input, value)
##    
##    proc newAddOne*(model: var seq[Layer], value: float) =
##        var addvalue = new AddValue
##        
##        addvalue.value = value
##    
##        model.add(value)

import sequtils
import ../ops/ops
import ../core/core
import ../utils/utils
import ./loss
import ./optim
import ./variable
import ./model/model
{.hint[XDeclaredButNotUsed]:off.}

type Layer* = ref object of RootObj
    ## Base Layer to inherit from when creating a new Layer. If your layer contains trainable 
    ## Variables append them to the train sequence.

    train*: seq[HVariable]
    outsize*: seq[int]

method `$`*(layer: Layer): string {.base.} = "Layer"

    ## String conversion method to give your Layer a string representation when the model is printed.

method make*(layer: Layer, root: Scope, shape: var seq[int]): (proc(rt: Scope, input: oall): oall) {.base.} = 
    raise newException(ValueError, "Not Implemented. Please overload `make` for Layer " & $layer & ".")

    ## The make method is intended for all the setup of your layer like creating variables or 
    ## doing operations that require a scope. This method should be overloaded for all non JoinLayers.

method makeJoin*(layer: Layer, root: Scope, shape: var seq[seq[int]]): (proc(rt: Scope, input: olist[oall]): oall) {.base.} = 
    raise newException(ValueError, "Not Implemented. Please overload `makeJoin` for your Layer or use a Joinfunction when branching")

    ## The makeJoin method is intended for all the setup of your JoinLayer that requires a scope. 
    ## This method should be overloaded for all JoinLayers.

method isBranch(layer: Layer): bool {.base.} = false

    ## The isBranch method indicates wether a layer is a branch layer.

method isJoin*(layer: Layer): bool {.base.} = false

    ## The isJoin method is now required to be overloaded for every custom JoinLayer. This will change in the
    ## future so that this method becomes obsolete and there will instead exsist a JoinLayer to inherit from.

method getBranchSwitch(layer: Layer): bool {.base.} = 
    raise newException(ValueError, "Trying to call `getBranchSwitch` for none branchlayer")

    ## The getBranchSwitch method indicates wether a branch layer opens or closes a branch.

proc dimCheck(layer: Layer, insize: seq[int], dims: int) = 
    assert insize.len == dims, "The input shape for the layer " & $layer & " should have " & 
                                $dims & " dimensions but has " & $insize.len & "!"

proc makeBranch(branches: seq[seq[proc(rt: Scope, input: oall): oall]], 
                          joinFunc: proc(rt: Scope, input: olist[oall]): oall): proc(rt: Scope, input: oall): oall{.closure.} =

                    return proc(rt: Scope, input: oall): oall{.closure.} =
                            var branchOut: olist[oall]

                            for branch in branches:
                                var outp = branch[0](rt, input)

                                for f in branch[1..^1]:
                                    outp = rt.f(outp)

                                branchOut.add(outp)

                            return joinFunc(rt, branchOut)

    ## a mini compile method for branches

proc compile*[T,N](layers: seq[Layer], 
                 root: Scope, 
                 loss: Loss, 
                 optim: Optim[N], 
                 inputShape: openArray[int],
                 path="checkpoints/model.ckpt",
                 restore=false): Model = 
    var funcs: seq[proc(rt: Scope, input: oall): oall]
    var branchFuncs: seq[seq[proc(rt: Scope, input: oall): oall]]
    var start: seq[int] # stack to track index in branchFuncs
    var vars: seq[HVariable]
    var inShape = @[inputShape.toSeq]

    for layer in layers:
        if isBranch(layer):
            let switch = getBranchSwitch(layer)
            
            if switch:
                inShape.add(inShape[0])
                branchFuncs.add(@[])

                start.add(branchFuncs.len)
            else:
                start.delete(start.len-1, start.len-1)

        else:
            var ffunc: proc(rt: Scope, input: oall): oall

            if isJoin(layer):
                var a = 0
                if start.len != 0: a = start[^1]

                var b = branchFuncs.len-1

                # plus one because the first shape is always the base shape
                var tmp = inShape[a+1..b+1]
                ffunc = branchFuncs[a..b].makeBranch(layer.makeJoin(root, tmp))
                branchFuncs.delete(a, b)
                inShape.delete(a+1, b+1)
                inShape[^1] = tmp[0]

            else:
                ffunc = layer.make(root, inShape[^1])

            if start.len > 0:
                branchFuncs[^1].add(ffunc)
            else:
                funcs.add(ffunc)

        for i in 0..layer.train.len-1:
            vars.add(layer.train[i])

    return newModel(root, funcs, loss, optim, vars, path, restore)

    ## The compile procedure is the function that turns your model into an actual sequence of operations and returns
    ## a fit and eval method to train your model and afterward evaluate its performence. Beware this interface will
    ## recieve drastic changes.
    ##
    ## Example:
    ##
    ## .. code:: nim
    ##
    ##    var proto: seq[Layer] = @[]
    ##
    ##    proto.newDense(10, 10)
    ##    proto.newActivation(Softmax)
    ##    
    ##    let rt = newRootScope()
    ##    let model = proto.compile(rt, newMSE(), newAdam())
    ##
    ##    model.fit(X, Y, epochs)
    ##

export Layer,
       `$`,
       input,
       dimCheck,
       compile,
       Model,
       fit,
       eval