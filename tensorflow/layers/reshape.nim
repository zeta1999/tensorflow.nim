import options
import ../ops/ops
import ../core/core
import ./layer
{.hint[XDeclaredButNotUsed]:off.}

type Reshape*[N,T] = ref object of Layer
    shape*: array[N,T]

method `$`*[N,T](layer: Reshape[N,T]): string = "Reshape(shape:" & $layer.shape & ")"

method make[N,T](layer: Reshape[N,T], root: Scope): proc(rt: Scope, input: Out): Out = 
        let shape = root.Const(layer.shape)

        return proc(rt: Scope, input: Out): Out = 
                    return rt.Reshape(input, shape)

proc newReshape[N,T](model: var seq[Layer], shape: array[N,T]) =
    var reshape = new Reshape[N,T]

    reshape.shape = shape    

    model.add(reshape)

export Reshape,
       `$`,
       newReshape,
       make