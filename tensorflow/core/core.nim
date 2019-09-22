## The core module implements all the necessary ground work needed to construct a computation graph interface
## with and manipulate tensors. 

import ../utils/utils
import sequtils
import typetraits
import tables
import macros
import complex
#import complex
{.hint[XDeclaredButNotUsed]:off.}

type oinvalid*     {.header: std_ops, importcpp:"tensorflow::Output".} = object
type odouble*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ofloat*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oint64*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oint32*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ouint8*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oint16*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oint8*        {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ostring*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type obool*        {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ouint16*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ouint32*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ouint64*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ocomplex64*   {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ocomplex128*  {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oqint8*       {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oquint8*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oqint32*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type obfloat16*    {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oqint16*      {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oquint16*     {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ohalf*        {.header: std_ops, importcpp:"tensorflow::Output".} = object
type oresource*    {.header: std_ops, importcpp:"tensorflow::Output".} = object
type ovariant*     {.header: std_ops, importcpp:"tensorflow::Output".} = object

type oany* = odouble | ofloat | oint64 | oint32 | ouint8 | oint16 | oint8 | ostring | 
              obool | ouint16 | ouint32 | ouint64 | ocomplex64 | ocomplex128 | oqint8 | oquint8 |
              oqint32 | obfloat16 | oqint16 | oquint16 | ohalf | oresource | ovariant

type oall* = oinvalid | odouble | ofloat | oint64 | oint32 | ouint8 | oint16 | oint8 | ostring | 
              obool | ouint16 | ouint32 | ouint64 | ocomplex64 | ocomplex128 | oqint8 | oquint8 |
              oqint32 | obfloat16 | oqint16 | oquint16 | ohalf | oresource | ovariant

converter invalidToAny*(o: oinvalid): oany {.importcpp:"#".}

converter anyToInvalid*(o: oany): oinvalid {.importcpp:"#".}

const dict* = { 
    "int"           : "oint64"       , 
    "int8"          : "oint8"       , 
    "int16"         : "oint16"      , 
    "int32"         : "oint32"      , 
    "int64"         : "oint64"      , 
    "uint"          : "ouint64"     , 
    "uint8"         : "ouint8"      , 
    "uint16"        : "ouint16"     ,  
    "uint32"        : "ouint32"     ,  
    "uint64"        : "ouint64"     ,  
    "float"         : "odouble"     ,  
    "float32"       : "ofloat"      , 
    "float64"       : "odouble"     ,  
    "bool"          : "obool"       ,
    "char"          : "ouint8"      , 
    "string"        : "ostring"     ,  
    "Complex64"     : "ocomplex64"  ,  
    "Complex128"    : "ocomplex128" ,  
    "Qint8"         : "oqint8"      ,  
    "Quint8"        : "oquint8"     ,  
    "Qint32"        : "oqint32"     ,  
    "Bfloat16"      : "obfloat16"   ,  
    "Qint16"        : "oqint16"     ,  
    "Quint16"       : "oquint16"    ,  
    "Half"          : "ohalf"       
}.toOrderedTable

const reversedict* = { 
    "oint8"       : "int8"       , 
    "oint16"      : "int16"      , 
    "oint32"      : "int32"      , 
    "oint64"      : "int64"      , 
    "ouint8"      : "uint8"      , 
    "ouint16"     : "uint16"     ,  
    "ouint32"     : "uint32"     ,  
    "ouint64"     : "uint64"     ,  
    "ofloat"      : "float32"    , 
    "odouble"     : "float64"    ,  
    "obool"       : "bool"       ,
    "ostring"     : "string"     ,  
    "ocomplex64"  : "Complex64"  ,  
    "ocomplex128" : "Complex128" ,  
    "oqint8"      : "Qint8"      ,  
    "oquint8"     : "Quint8"     ,  
    "oqint32"     : "Qint32"     ,  
    "obfloat16"   : "Bfloat16"   ,  
    "oqint16"     : "Qint16"     ,  
    "oquint16"    : "Quint16"    ,  
    "ohalf"       : "Half"       
}.toOrderedTable

type
  DType* {.header: client_session, importcpp: "tensorflow::DataType".} = enum 
    DT_INVALID = 0, DT_FLOAT = 1, DT_DOUBLE = 2, DT_INT32 = 3, ##  Int32 tensors are always in 'host' memory.
    DT_UINT8 = 4, DT_INT16 = 5, DT_INT8 = 6, DT_STRING = 7, DT_COMPLEX64 = 8, ##  Single-precision complex
    DT_INT64 = 9, DT_BOOL = 10, DT_QINT8 = 11, ##  Quantized int8
    DT_QUINT8 = 12,             ##  Quantized uint8
    DT_QINT32 = 13,             ##  Quantized int32
    DT_BFLOAT16 = 14,           ##  Float32 truncated to 16 bits.  Only for cast ops.
    DT_QINT16 = 15,             ##  Quantized int16
    DT_QUINT16 = 16,            ##  Quantized uint16
    DT_UINT16 = 17, DT_COMPLEX128 = 18, ##  Double-precision complex
    DT_HALF = 19, DT_RESOURCE = 20, DT_VARIANT = 21, DT_UINT32 = 22, DT_UINT64 = 23 

    # An Enum holding the integers corresponding to the Tensorflow DataTypes.

const
  DT_COMPLEX = DT_COMPLEX64

const typeLookUp* = {
  "float"                    : DT_DOUBLE,
  "float32"                  : DT_FLOAT,
  "float64"                  : DT_DOUBLE, 
  "int"                      : DT_INT64,
  "int32"                    : DT_INT32,
  "uint8"                    : DT_UINT8,
  "int16"                    : DT_INT16,
  "int8"                     : DT_INT8, 
  "cppstring"                : DT_STRING, 
  #"Complex[system.float64]"  : DT_COMPLEX64,
  "int64"                    : DT_INT64, 
  "bool"                     : DT_BOOL, 
  "uint16"                   : DT_UINT16, 
  "uint32"                   : DT_UINT32,
  "uint64"                   : DT_UINT64
  #DT_COMPLEX128, 
  #DT_QINT8, 
  #DT_QUINT8,           
  #DT_QINT32,           
  #DT_BFLOAT16,         .
  #DT_QINT16,           
  #DT_QUINT16,          
  #DT_HALF, 
  #DT_RESOURCE, 
  #DT_VARIANT,
}.toTable

const typeLookUpReverse* = {
  DT_DOUBLE    : "float",     
  DT_FLOAT     : "float32",  
  DT_DOUBLE    : "float64",   
  DT_INT64     : "int",  
  DT_INT32     : "int32",  
  DT_UINT8     : "uint8",  
  DT_INT16     : "int16",  
  DT_INT8      : "int8",  
  DT_STRING    : "cppstring",   
  #DT_COMPLEX64 : "Complex[system.float64]",  
  DT_INT64     : "int64",   
  DT_BOOL      : "bool",   
  DT_UINT16    : "uint16",   
  DT_UINT32    : "uint32",   
  DT_UINT64    : "uint64"                 
  #DT_COMPLEX128, 
  #DT_QINT8, 
  #DT_QUINT8,           
  #DT_QINT32,           
  #DT_BFLOAT16,         .
  #DT_QINT16,           
  #DT_QUINT16,          
  #DT_HALF, 
  #DT_RESOURCE, 
  #DT_VARIANT,
}.toTable

proc tf(dtype: typedesc): DType =
    return typeLookUp[dtype.name]

const tfdict* = { 
    "oint8"       : DT_INT8       , 
    "oint16"      : DT_INT16      , 
    "oint32"      : DT_INT32      , 
    "oint64"      : DT_INT64      , 
    "ouint8"      : DT_UINT8      , 
    "ouint16"     : DT_UINT16     ,  
    "ouint32"     : DT_UINT32     ,  
    "ouint64"     : DT_UINT64     ,  
    "ofloat"      : DT_FLOAT      , 
    "odouble"     : DT_DOUBLE     ,  
    "obool"       : DT_BOOL       ,
    "ostring"     : DT_STRING     ,  
    "ocomplex64"  : DT_COMPLEX64  ,  
    "ocomplex128" : DT_COMPLEX128 ,  
    "oqint8"      : DT_QINT8      ,  
    "oquint8"     : DT_QUINT8     ,  
    "oqint32"     : DT_QINT32     ,  
    "obfloat16"   : DT_BFLOAT16   ,  
    "oqint16"     : DT_QINT16     ,  
    "oquint16"    : DT_QUINT16    ,  
    "ohalf"       : DT_HALF       
}.toOrderedTable

const reversetfdict* = { 
    DT_INT8       : "oint8"       , 
    DT_INT16      : "oint16"      , 
    DT_INT32      : "oint32"      , 
    DT_INT64      : "oint64"      , 
    DT_UINT8      : "ouint8"      , 
    DT_UINT16     : "ouint16"     ,  
    DT_UINT32     : "ouint32"     ,  
    DT_UINT64     : "ouint64"     ,  
    DT_FLOAT      : "ofloat"      , 
    DT_DOUBLE     : "odouble"     ,  
    DT_BOOL       : "obool"       ,
    DT_STRING     : "ostring"     ,  
    DT_COMPLEX64  : "ocomplex64"  ,  
    DT_COMPLEX128 : "ocomplex128" ,  
    DT_QINT8      : "oqint8"      ,  
    DT_QUINT8     : "oquint8"     ,  
    DT_QINT32     : "oqint32"     ,  
    DT_BFLOAT16   : "obfloat16"   ,  
    DT_QINT16     : "oqint16"     ,  
    DT_QUINT16    : "oquint16"    ,  
    DT_HALF       : "ohalf"       
}.toOrderedTable

macro oT*(x: untyped): untyped =
    if not dict.hasKey($x):
        var types = ""

        for key in dict.keys:
            types &= key & ", "

        types = types[0..^3]

        raise newException(ValueError, "Type " & $x & " not supported. Use one of [" & types & "]")

    return ident(dict[$x])

macro To*(x: untyped): untyped =
    if not reversedict.hasKey($x):
        var types = ""

        for key in reversedict.keys:
            types &= key & ", "

        types = types[0..^3]

        raise newException(ValueError, "Type " & $x & " not supported. Use one of [" & types & "]")

    return ident(reversedict[$x])

macro oTF*(x: untyped): untyped = 
    if not tfdict.hasKey($x):
        var types = ""

        for key in tfdict.keys:
            types &= key & ", "

        types = types[0..^3]

        raise newException(ValueError, "Type " & $x & " not supported. Use one of [" & types & "]")

    return newLit(tfdict[$x])

## TensorShape related definitions
type
  TensorShape* {.header: tensor,
                 importcpp: "tensorflow::PartialTensorShape".} = object
    ## Type used to construct shapes for Tensors. As the PartialTensorShape is intended for in the c++ API.
    ## The "real" TensorShape Type as exsists in the c++ API isn't implemented in this interface as I see no
    ## use for it. It is only casted into on the c++ level when a Tensor is constructed. 


proc inewTensorShape(dims: openArray[int], len: int, shape: TensorShape) {.header: tensor,
                                                                           importcpp: "tensorflow::PartialTensorShape::MakePartialShape(#, #, &#)".}
  ## C++ Constructor Wrapper creating a new TensorShape.
  ##
  ## Args:
  ##  dims: Array of ints describing the dimensions of the Tensor.
  ##  len: Length of the dims Array.
  ##  shape: The Shape that is supposed to represent these dimensions.  

proc newTensorShape*(dims: openArray[int]): TensorShape =
  let tshape = TensorShape()
  inewTensorShape(dims, dims.len, tshape)
  return tshape

  ## TensorShape Constructor.
  ##
  ## Args:
  ##   dims: Array of ints describing the dimensions of the Tensor.
  ## Returns:
  ##   A new TensorShape with given dimensions.

proc toCPPStr(shape: TensorShape): cppstring {.header: "<sstream>",
                                             header: tensor,
                                             importcpp: "[&]() {std::stringstream s; s << #; return s.str(); }()".}

  ## A Method to get a cppstring representation of the TensorShape.
  ## 
  ## Args:
  ##   shape: The TensorShape it is applied on.
  ## Returns:
  ##   A new cppstring representing of the TensorShape.

proc `$`*(shape: TensorShape) : string = 
  var cppstr = toCPPStr(shape)
  var cstr = newString(cppstr.len())

  copyMem(addr(cstr[0]), cppstr.c_str(), cppstr.len())

  return cstr

  ## String conversion for TensorShapes.
  ## 
  ## Args:
  ##   shape: The TensorShape it is applied on. 
  ## Returns:
  ##   A new cppstring representing of the TensorShape.

proc `[]`*(shape: TensorShape, i: int): int {.importcpp:"#[#]".}

proc dim_size*(shape: TensorShape, i: int): int {.importcpp:"#.dim_size(#)".}

  ## Gets the size of the provided dimension.
  ## 
  ## Args:
  ##   shape: The TensorShape it is applied on. 
  ##   i: dimension index.
  ## Returns:
  ##   The size of the dimension.

proc dims*(shape: TensorShape): int {.importcpp:"#.dims()".}

  ## Gets the number of dimensions aka the rank.
  ## 
  ## Args:
  ##   shape: The TensorShape it is applied on. 
  ## Returns:
  ##   The number of dimensions.

## Tensor related definitions
type
  Tensor*[T] {.header: memory,
               header: tensorh,
               importcpp: "std::shared_ptr<tensorflow::Tensor>/*'0*/" .} = object
    ## The Tensor Type is really a shared pointer to a Tensor. This makes it a whole lot easier to work with because
    ## a Tensor constructed in one nim stackframe would be destructed at the end of that stackframe but it might have
    ## a use in a different stackframe therefore accessing freed memory and throwing a segfault. With a smart pointer 
    ## this can be avoided because it keeps the object alive as long the there is reference on it enabling the Tensor 
    ## to live across multiple stackframes.

converter tensorToAll*[T](ten: Tensor[T]): T {.importcpp:"tensorflow::Input(*#)".}

proc toValueCPPStr[T](ten: Tensor[T], len: int): cppstring {.importcpp: "#->SummarizeValue(#, true)".} 

  ## A Method to get a cppstring representation of the first 100 Values of the Tensor.
  ##
  ## Args:
  ##   ten: The Tensor it is applied on.
  ## Returns:
  ##   A new cppstring representing the first 100 Values of the Tensor.

proc toValueStr*[T](ten: Tensor[T], len: int) : string =
  return $toValueCPPStr(ten, len)

  ## A Method to get a string representation of the first 100 Values of the Tensor.
  ## 
  ## Args:
  ##   ten: The Tensor it is applied on.
  ## Returns:
  ##   A new string representing the first 100 Values of the Tensor.

proc shape*[T](ten: Tensor[T]) : TensorShape {.header: tensorh, 
                                         importcpp:"#->shape()".}

  ## A Method to get the shape of a Tensor.
  ## 
  ## Args:
  ##   ten: The Tensor it is applied on.
  ## Returns:
  ##   The Shape of the Tensor.

proc dtype*[T](ten: Tensor[T]) : DType {.header: tensorh, 
                                   importcpp:"#->dtype()".}

  ## A Method to get the dtype of a Tensor.
  ## 
  ## Args:
  ##   ten: The Tensor it is applied on.
  ## Returns:
  ##   The Dtype of the Tensor.

proc toDebugCPPStr[T](ten: Tensor[T]): cppstring {.importcpp: "#->DebugString()".} 

proc `$`*[T](ten: Tensor[T]) : string =
  return $toDebugCPPStr(ten)

  ## String conversion for Tensors.
  ## 
  ## Args:
  ##   ten: The Tensor it is applied on. 
  ## Returns:
  ##   A new string representing the Tensor.

proc slice*[T](ten: Tensor[T], start: int, stop: int): Tensor[T]
  {.header: tensorh,
    header: memory,
    importcpp:"std::make_shared<tensorflow::Tensor>(std::move(#->Slice(#, #)))".}

  ## A Method to get a slice of a Tensor along the first dimension.
  ## 
  ## Args:
  ##   ten: The Tensor it is applied on.
  ## Returns:
  ##   The slice along the first dimension.

proc itensor(dtype: DType, shape: TensorShape, T: type) : Tensor[T] {.
  header: tensorh,
                                                             importcpp: "[&](){ auto _dtype = #; auto _shape = #; tensorflow::TensorShape _tshape; _shape.AsTensorShape(&_tshape); return std::make_shared<tensorflow::Tensor>(_dtype, _tshape); }()".}

  ## Tensor Constructor.
  ## 
  ## Args:
  ##   dtype: The DType of a Tensor.
  ##   shape: The shape the Tensor is supposed to have.
  ## Returns:
  ##   A new Tensor with given dtype and shape.

proc itensor*(dtype: DType, shape: openArray[int], T: type) : Tensor[T] =
  let sh = shape(shape)
  return itensor(dtype, sh, T)

  ## Convinience Tensor Constructor constructing a Tensorshape for you.
  ## 
  ## Args:
  ##   dtype: The DType of a Tensor.
  ##   shape: The shape the Tensor is supposed to have represented by an array.
  ## Returns:
  ##   A new Tensor with given dtype and shape.

type Allocator* {.importcpp:"tensorflow::Allocator".} = object

proc itensor(alloc: ptr Allocator, dtype: DType, shape: TensorShape, T: type) : Tensor[T] {.
  header: tensorh,
  importcpp: """[&](){ 
    auto _alloc = #;
    auto _dtype = #; 
    auto _shape = #; 
    tensorflow::TensorShape _tshape; 
    _shape.AsTensorShape(&_tshape); 
    return std::make_shared<tensorflow::Tensor>(_alloc, _dtype, _tshape); 
  }()""".}

  ## Tensor Constructor.
  ## 
  ## Args:
  ##   alloc: Allocator to use.
  ##   dtype: The DType of a Tensor.
  ##   shape: The shape the Tensor is supposed to have.
  ## Returns:
  ##   A new Tensor with given dtype and shape.

proc itensor*(alloc: ptr Allocator, dtype: DType, shape: openArray[int], T: type) : Tensor[T] =
  let sh = shape(shape)
  return itensor(alloc, dtype, sh, T)

  ## Convinience Tensor Constructor constructing a Tensorshape for you.
  ## 
  ## Args:
  ##   alloc: Allocator to use.
  ##   dtype: The DType of a Tensor.
  ##   shape: The shape the Tensor is supposed to have represented by an array.
  ## Returns:
  ##   A new Tensor with given dtype and shape.

proc getShapeHelper[T](x:T, shape: var seq[int]) = 
  return

  ## A recursive method for finding the diminensions of an array. This is the last function call stopping the
  ## recursion when it is not an array anymore but a value instead.
  ## 
  ## Args:
  ##   x: A value.
  ##   shape: A sequence to which dimensions are appended.

proc getShapeHelper[N,T](arr: array[N,T], shape: var seq[int]) = 
  shape.add(arr.len)
  getShapeHelper(arr[0], shape)

  ## A recursive method for finding the diminensions of an array.
  ##   
  ## Args:
  ##   arr: The array you want to find the dimensions from.
  ##   shape: A sequence to which dimensions are appended.

proc getShape[N,T](arr: array[N,T]) : seq[int] = 
  var shape: seq[int] = @[]
  when arr.len != 0:
  getShapeHelper(arr, shape)
  return shape

  ## A recursive method for finding the diminensions of an array.
  ## 
  ## Args:
  ##   arr: The array you want to find the dimensions from.
  ## Returns:
  ##   The dimensions of the given array.

proc prod(s: openArray[int]): int =
  var res: int = 1
  for it in s:
    res *= it
  return res

  ## A method for getting the product of a sequence.
  ## 
  ## Args:
  ##   s: The sequence you want to get the product from.
  ## Returns:
  ##   The product of the given sequence.

proc getBaseEl[T](arr: T): T = arr

  ## A recursive method for getting the base type of an Array. This is the last function call stopping the
  ## recursion when it is not an array anymore but a value instead.
  ## 
  ## Args:
  ##   x: A value.
  ## Returns:
  ##   The type of the value.

proc getBaseEl[N,T](arr: array[N,T]): auto = 
  return getBaseEl(arr[0])

  ## A recursive method for getting the base element with the base type of an Array. 
  ## ([[[[0,0],[1,1]]]], array[0..0, array[0..0, array[0..1, array[0..1, int]]]] -> 0 int)
  ## 
  ## Args:
  ##   arr: The array you want the base type from.
  ## Returns:
  ##   The base type of the array.

proc num_elements*(sh: TensorShape): int {.importcpp:"#.num_elements()".}

  ## A proc that returns the product of all dimensions the shape is holding
  ## e.g: the total number of elements in a Tensor
  ## 
  ## Args:
  ##   sh: The shape it is applied on
  ## Returns:
  ##   The product of all dimensions

iterator batch*(ten: Tensor, batchSize: int, len: int): Tensor =
  var i: cint = 0
  while i <= (len div batchSize)-1:
    yield ten.slice(i * batchSize, (i + 1) * batchSize)
    inc i

  ## An iterator divinding the given Tensor into batches.
  ##
  ## Args:
  ##   ten: The Tensor to make batches from
  ##   batchSize: The size of one batch
  #    len: The length of the first dimension
  ## Returns:
  ##   A slice of the given Tensor with the given batchSize

iterator batch*(ten: Tensor, batchSize: int): Tensor =
  for slice in batch(ten, batchSize, ten.shape.dim_size(0)):
    yield slice

  ## An iterator divinding the given Tensor into batches.
  ##
  ## Args:
  ##   ten: The Tensor to make batches from
  ##   batchSize: The size of one batch
  ## Returns:
  ##   A slice of the given Tensor with the given batchSize

iterator batch*(X, Y: Tensor, batchSize: int, len: int): (Tensor, Tensor) =
  var i: cint = 0
  while i <= (len div batchSize)-1:
    let s = i * batchSize
    let e = (i + 1) * batchSize

    yield (X.slice(s, e), Y.slice(s, e))
    inc i

  ## An iterator divinding the given Tensors into batches
  ## especially useful for training.
  ##
  ## Args:
  ##   X: The X Tensor to make batches from
  ##   Y: The Y Tensor to make batches from
  ##   batchSize: The size of one batch
  #    len: The length of the first dimension
  ## Returns:
  ##   A (X, Y) Tensor tuple holding slices of the given Tensors
  ##   with the given batchSizes

iterator batch*(X, Y: Tensor, batchSize: int): (Tensor, Tensor) =
  for x, y in batch(X, Y, batchSize, X.shape.dim_size(0)):
    yield (x, y)

  ## An iterator divinding the given Tensors into batches
  ## especially useful for training.
  ##
  ## Args:
  ##   X: The X Tensor to make batches from
  ##   Y: The Y Tensor to make batches from
  ##   batchSize: The size of one batch
  ## Returns:
  ##   A (X, Y) Tensor tuple holding slices of the given Tensors
  ##   with the given batchSizes

proc copyFrom*(to: Tensor, ffrom: Tensor, shape: TensorShape): bool {.importcpp:"#->CopyFrom(*#, #)".}

proc copy*(ten: Tensor): Tensor = 
    let sh = ten.shape
    var newTen = newTensor(ten.dtype, sh)

    discard newTen.copyFrom(ten, ten.shape)

    return newTen

## Flat related definitions
type
  Flat*[T] {.header: tensorh,
             importcpp: "std::shared_ptr<tensorflow::TTypes<'0>::Flat>".} = object
    ## The Flat Type is a way of accessing the underlying memory of a tensor as flat buffer without any dimensionality.

proc iflat*[T](ten: Tensor[T], R: type): Flat[R] {.
    header: tensorh,
    importcpp:"std::make_shared<tensorflow::TTypes<'*0>::Flat>(std::move(#->flat<'*0>()))".}

  ## A method returning the flat buffer of a Tensor with the given type.
  ## 
  ## Args:
  ##   flat: A Flat variable to initalize.
  ##   ten: The tensor it is applied on.
  ## Returns:
  ##   A new Flat object "referencing" the data of the Tensor.

proc flat*[T](ten: Tensor[T]): auto =
  return ten.iflat(T.name.To)

proc len*[T](flat: Flat[T]): int {.importcpp:"#->size()".}

  ## Size method to get the number of elements in the Flat object.
  ## 
  ## Args:
  ##   flat: The Flat object it is applied on.
  ## Returns:
  ##   The number of elements.

proc asPtr*[T](flat: Flat[T]): ptr T {.importcpp:"#->data()".}

  ## Proc converting the Flat type to raw buffer.
  ## 
  ## Args:
  ##   flat: The Flat object it is applied on.
  ## Returns:
  ##   A pointer to the Flat buffer memory.

proc `[]`*[T](flat: Flat[T], i: int): T {.importcpp:"(*#)(#)".}

proc `[]=`*[T](flat: Flat[T], i: int, val: T) {.importcpp:"(*#)(#) = #".}

proc mean*[T](flat: Flat[T]) : T = 
  let size = flat.len()
  var sum: T = 0

  for i in 0..size-1:
    sum += flat[i]

  return sum / size.T 

  ## Calculates the mean of all elements in the buffer.
  ## 
  ## Args:
  ##   flat: The Flat object it is applied on.
  ## Returns:
  ##   Returns the mean.

## Matrix related definitions
type
  Matrix*[T] {.header: tensorh,
               importcpp: "std::shared_ptr<tensorflow::TTypes<'0>::Matrix>".} = object
    ## The Matrx Type is a way of accessing the underlying memory of a tensor as a Matirx.


proc matrix*[T](ten: Tensor[T]): Matrix[T] {.importcpp:"std::make_shared<tensorflow::TTypes<'*0>::Matrix>(std::move(#->matrix<'*0>()))".}

  ## A method returning the Matrix from a Tensor with the given type.
  ## 
  ## Args:
  ##   mat: A Matrix variable to initalize.
  ##   ten: The tensor it is applied on.
  ## Returns:
  ##   A new Flat object "referencing" the data of the Tensor.

proc `[]`*[T](flat: Matrix[T], i: int, j: int): T {.importcpp:"(*#)(#, #)".}

proc `[]=`*[T](flat: Matrix[T], i: int, j: int, val: T) {.importcpp:"(*#)(#, #) = #".}


## Scalar related definitions
type
  Scalar*[T] {.header: tensorh,
               importcpp: "std::shared_ptr<tensorflow::TTypes<'0>::Scalar>".} = object
    ## The Scalar Type is a way of accessing the underlying memory of a tensor as a Scalar.

proc scalar*[T](ten: Tensor[T]): Scalar[T] {.importcpp:"std::make_shared<tensorflow::TTypes<'*0>::Scalar>(std::move(#->scalar<'*0>()))".}

  ## A method returning the Scalar from a Tensor with the given type.
  ## 
  ## Args:
  ##   scal: A Scalar variable to initalize.
  ##   ten: The tensor it is applied on.
  ## Returns:
  ##   A new Scalar object "referencing" the data of the Tensor.

proc set*[T](flat: Scalar[T], val: T) {.importcpp:"(*#)(0) = #".}

proc get*[T](flat: Scalar[T]): T {.importcpp:"(*#)(0)".}

#[
## TensorMap related definitions
type
  TensorMap*[T, N] {.header: tensorh,
                  importcpp: "tensorflow::TTypes<'0, '1>::Matirx".} = object
    ## The TensorMap Type is a way of accessing the underlying memory of a tensor as a tensor.

proc tensorMap*[T, N](map: TensorMap[T, N], ten: Tensor) {.importcpp:"# = #->tensor<'0, '1>()".}

  ## A method returning the TensorMap from a Tensor with the given type.
  ## 
  ## Args:
  ##   map: A TensorMap variable to initalize.
  ##   ten: The tensor it is applied on.
  ## Returns:
  ##   A new TensorMap object "referencing" the data of the Tensor.

proc `[]`*[T, N](map: TensorMap[T, N], idxs: varargs[int]): T {.importcpp:"[](){ auto _map = #; auto _idxs = #; std::array<Eigen::DenseIndex, '1> _idx; std::copy(std::begin(_idxs), std::end(_idxs), _idx.begin()); return _map->(_idx); }()".}

proc `[]=`*[T, N](map: TensorMap[T, N], idxs: varargs[int], val: T) {.importcpp:"auto _map = #; auto _idxs = #; std::array<Eigen::DenseIndex, '1> _idx; std::copy(std::begin(_idxs), std::end(_idxs), _idx.begin()); _map->(_idx) = #;".}
]#

type 
  cArray[T] {.importcpp:"'0*".} = object

proc newCArray[T, TT](carray: cArray[T], len: int, x: TT) {.importcpp: "# = new '3[#]".}

proc cArrayFromNim[T,N,TT](c: cArray[T], nim: array[N, TT]) {.importcpp:"# = ('1)#".}

proc `[]`[T](arr: cArray[T], i: int): T {.importcpp:"#[#]".}

proc `[]=`[T](arr: cArray[T], i: int, val: T) {.importcpp:"#[#] = #".}

proc ttype(node: NimNode): NimNode {.compileTime.} =
  case node[^1].kind:
  of nnkBracketExpr:
    return node[^1].ttype
  else:
    return node[^1]

macro ttype(x: typedesc): typedesc =
  let node = x.getType

  case node[^1].kind:
  of nnkBracketExpr:
    return node.ttype
  else:
    return node[^1]

proc newTensor*[N,M](arr: array[N,M], T: type): Tensor =
  if typeLookUp.hasKey(T.name):
    let sh = getShape(arr)
    let ten = newTensor(T.tf, sh) 

    when T.name == "cppstring":
      var buf = flat[cppstring](ten, newCPPString(" "))
    else:
      var buf = flat[T](ten, 0)

    var baseElPtr: cArray[M.ttype]
    cArrayFromNim(baseElPtr, arr)

    # copy incomming data
    for i in 0..prod(sh)-1:
      buf[i] = baseElPtr[i].T
      
    return ten

  else: raise newException(OSError, "Type not supported!")

  ## Convinience Tensor Constructor copying data from an array into a Tensor and converting the data to the given type. 
  ## 
  ## Args:
  ##   arr: The array a Tensor should be constructed from.
  ##   T: The type the Tensor should have.
  ## Returns:
  ##   A new Tensor with the given data.

proc newTensor*[N,T](arr: array[N,T]): Tensor =
  if typeLookUp.hasKey(T.ttype.name):
    let sh = getShape(arr)
    let ten = newTensor(T.ttype.tf, sh) 

    when T.ttype.name == "cppstring":
      var buf = flat[cppstring](ten, newCPPString(" "))
    else:
      var buf = flat[T.ttype](ten, 0)

    var baseElPtr: cArray[T.ttype]
    cArrayFromNim(baseElPtr, arr)

    # copy incomming data
    for i in 0..prod(sh)-1:
      buf[i] = baseElPtr[i]

    return ten

  else: raise newException(OSError, "Type not supported!")

  ## Convinience Tensor Constructor copying data from an array into a Tensor. 
  ## 
  ## Args:
  ##   arr: The array a Tensor should be constructed from.
  ## Returns:
  ##   A new Tensor with the given data.

proc newTensor*(scal: string): Tensor =
  let ten = newTensor(cppstring.tf, []) 

  scalar[cppstring](ten, newCPPString("")).set(newCPPString(scal))

  return ten

  ## Convinience Tensor Constructor to create a string tensor. 
  ## 
  ## Args:
  ##   scal: A string scalar.
  ## Returns:
  ##   A new Tensor with the given string scalar.

proc newTensor*[N](scal: N, T: type): Tensor =
  if typeLookUp.hasKey(T.name):
    let ten = newTensor(T.tf, []) 

    scalar[T](ten, 0).set(scal.T)

    return ten

  else: raise newException(OSError, "Type not supported!")

  ## Convinience Tensor Constructor copying the given scalar into a Tensor and converting it to the given type. 
  ## 
  ## Args:
  ##   scal: The array a Tensor should be constructed from.
  ##   T: Type to convert to.
  ## Returns:
  ##   A new Tensor with the given data.

proc newTensor*[T](scal: T): Tensor =
  if typeLookUp.hasKey(T.name):
    let ten = newTensor(T.tf, []) 

    scalar[T](ten, 0).set(scal.T)

    return ten

  else: raise newException(OSError, "Type not supported!")

  ## Convinience Tensor Constructor copying the given scalar into a Tensor. 
  ## 
  ## Args:
  ##   scal: The array a Tensor should be constructed from.
  ## Returns:
  ##   A new Tensor with the given data.

proc readBytes*(ten: Tensor, file: string, start: int, len: static[int]) =
  var readFile: File

  if not readFile.open(file, fmRead): 
    raise newException(OSError, "Error opening file `" & file & "`!")

  readFile.setFilePos(start)

  var buf = flat[uint8](ten, 0).asPtr()
  
  echo "read " & $readFile.readBuffer(buf, len) & "b"

  ## Proc to read a byte file directly into the underlying databuffer of a Tensor. 
  ## 
  ## Args:
  ##   ten: The tensor to write to.
  ##   file: The name of the file to read.
  ##   start: The position to start reading from.
  ##   len: The number of bytes to read.
  ## Returns:
  ##   A new Tensor holding the files content.

## TensorVec related definitions
type
  TensorVec* {.header: vector,
              header: tensor,
              importcpp: "std::vector<tensorflow::Tensor>" .} = object
    ## The TensorVec Type is a wrapper around a std::vector of Tensors manly used for the output of a Session.

proc inewTensorVec(args: openArray[Tensor], len: int) : TensorVec {.header: tensor,
                                                                    header: vector,
                                                                    importcpp: "[&]() { std::vector<tensorflow::Tensor> vec; auto _args = #; auto _len = #; vec.resize(_len); for(int i = 0; i < _len; i++) vec.push_back(*_args[i]); return vec;} ()".}

  ## A private constructor for the TensorVec type copying the Tensors from an array of Tensors into a vector.
  ## 
  ## Args:
  ##   args: Array of Vectors.
  ##   len: Length of the Array.
  ## Returns:
  ##   A TensorVec with the given Tensors.

proc newTensorVec*(args: varargs[Tensor]) : TensorVec = 
  return inewTensorVec(args, args.len)

  ## Constructor for the TensorVec type copying the Tensors from an array of Tensors into a vector.
  ## 
  ## Args:
  ##   args: Array of Vectors.
  ## Returns:
  ##   A TensorVec with the given Tensors.

proc len*(tensorVec: TensorVec) : int {.importcpp: "#.size()".}

  ## Method to get the size of a TensorVec.
  ## 
  ## Args:
  ##   tensorVec: The TensorVec it is applied on.
  ## Returns:
  ##   The size of the TensorVec object.

proc `[]`*(tensorVec: TensorVec, idx: cint) : Tensor {.header: memory, 
                                                       header: tensor,
                                                       importcpp: "std::make_shared<tensorflow::Tensor>(std::move(#[#]))".}

proc add*(tensorVec: TensorVec, ten: Tensor) {.importcpp: "#.push(*#)".}

proc insert*(tensorVec: TensorVec, pos: int, ten: Tensor) {.importcpp: "#.insert(#, *#)".}

iterator items*(tens: TensorVec): Tensor =
  var i: cint = 0
  while i <= tens.len()-1:
    yield tens[i]
    inc i

  ## Iterator over the Tensor objects a TensorVec is holding.
  ## 
  ## Args:
  ##   tens: The TensorVec it is applied on.
  ## Returns:
  ##   The Tensor objects one by one.

## Output related definitions
type
  Out* {.header: std_ops,
         importcpp: "tensorflow::Output".} = object
    ## The Out Type is a pure wrapper around the c++ Output type.

proc iname(o: Out): cppstring {.importcpp:"#.name()".}

proc name*(o: Out): string =
  return $o.iname()
    
## OutList related definitions
type
  OutList* {.header: std_ops,
             importcpp: "tensorflow::OutputList".} = object
    ## The OutList Type is a wrapper around the c++ OutputList type which itself is basically a vector of Out objects.

proc inewOutList(outs: openArray[Out], len: int): OutList {.header:std_ops, 
                                                            header:vector,
                                                            importcpp:"[&]() { auto _args = (tensorflow::Output*)&#[0]; int _len = #; std::vector<tensorflow::Output> _vec(_args, _args + _len); return _vec; }()".}

  ## A private constructor for the OutList type copying the Out objects from an array into an OutList.
  ## 
  ## Args:
  ##   outs: Array of Out objects.
  ##   len: Length of the Array.
  ## Returns:
  ##   An OutList with the given Out objects.

proc newOutList*(outs: varargs[Out]): OutList =
  return inewOutList(outs, outs.len)

  ## Constructor for the OutList type copying the Out objects from an array into an OutList.
  ## 
  ## Args:
  ##   outs: Array of Out objects.
  ## Returns:
  ##   An OutList with the given Out objects.

proc `[]`*(outs: OutList, idx: int): Out {.importcpp:"#[#]".}

proc `[]=`*(outs: OutList, idx: int, val: Out) {.importcpp:"#[#] = #".}

proc len*(outs: OutList): int {.importcpp:"#.size()".}

  ## Method to get the size of an OutList.
  ## 
  ## Args:
  ##   outs: The OutList it is applied on.
  ## Returns:
  ##   The size of the OutList object.

proc add*(outs: OutList, outVal: Out) {.importcpp:"#.push_back(#)".}

  ## Proc to append to an OutList.
  ## 
  ## Args:
  ##   outs: The OutList it is applied on.
  ##   outVal: Output you want to append.

iterator items*(outs: OutList): Out =
  var i = 0
  while i <= outs.len()-1:
    yield outs[i]
    inc i

  ## Iterator over the Out objects an OutList is holding.
  ## 
  ## Args:
  ##   outs: The OutList it is applied on.
  ## Returns:
  ##   The Out objects one by one.

iterator zip*(l1: OutList, l2: OutList): (Out, Out) =
  let len = min(l1.len, l2.len)
  var i = 0
  while i <= len-1:
    yield (l1[i], l2[i])
    inc i

## InList related definitions
type
  InList* {.header: std_ops,
            header: memory,
            importcpp: "std::shared_ptr<tensorflow::InputList>".} = object

    ## The InList Type is a wrapper around the c++ InputList type which itself is basically a vector of Input objects.
    ## It is represented through a shared pointer here because it has no default constructor and therefore cannot be declared
    ## like:
    ##   InputList foo;
    ## which is excatly what the nim compiler does.

proc inewInList(tens: openArray[Tensor], len: int): InList {.header:std_ops, 
                                                             header:vector,
                                                             header:memory,
                                                             importcpp:"[&]() { auto _args = #; int _len = #; std::vector<tensorflow::Input> _vec; for(int i = 0; i < _len; i++) _vec.emplace_back(tensorflow::Input(*_args[i])); return std::make_shared<tensorflow::InputList>(_vec); }()".}

  ## A private constructor for the InList type copying the Tensor objects from an array as Inputs into an InList.
  ## 
  ## Args:
  ##   tens: Array of Tensor objects.
  ##   len: Length of the array.
  ## Returns:
  ##   An InList with the given Tensors objects.

proc newInList*(tens: varargs[Tensor]): InList =
  return inewInList(tens, tens.len)

  ## Constructor for the InList type copying the Tensor objects from an array as Inputs into an InList.
  ## 
  ## Args:
  ##   tens: Array of Tensor objects.
  ## Returns:
  ##   An InList with the given Tensors objects.

## ArraySlice related definitions

type
  ArraySlice*{.header: tensor,
               importcpp: "tensorflow::gtl::ArraySlice<'0>".}[T] = object

    ## ArraySlice is a wrapper around the tensorflow::gtl::ArraySlice class
    ## which itself is a wrapper around the absl::Span type from the abseil C++ Library. 
    ## 
    ## This particular wrapper should work with every type except for the Tensor type because
    ## with the curret Version interfacing with C++ Methods would be pretty dirty due the fact
    ## that the Tensor type exposed by this library only is a pointer to a C++ Tensor. Now given
    ## the fact that it is not needed right now it probably will not be implemented soon.
    ## 
    ## For implemention details see:
    ## https://github.com/abseil/abseil-cpp/blob/master/absl/types/span.h

proc inewArraySlice[T](data: openArray[T], len: int): ArraySlice[T] {.header: tensor,
                                                                      importcpp: "'0(#, #)".}

  ## C++ Constructor Wrapper using a hack because the imported template argument is 
  ## transformed to the whole type plus the template argument instead of only the template
  ## argument. (meaning: tensorflow::gtl::ArraySlice<float> instead of float)

proc newArraySlice*[T](data: openArray[T]): ArraySlice[T] = 
  if data is openArray[Tensor]:
    raise newException(Exception, "DataType Tensor is not allowed for ArraySlice!")

  return inewArraySlice(data, data.len)

  ## Constructor exposed to nim interface.
  ## 
  ## Args:
  ##   data: An array holding the data for the ArraySlice.
  ## Returns:
  ##   A new ArraySlice using the given data.
  ## Raises:
  ##   ValueError: when called with the Tensor type due the reason described in the type definition.

proc newArraySlice*[T](data: cArray[T], len: int): ArraySlice[T] {.importcpp:"'0(#, #)".}

proc `[]`*[T](slice: ArraySlice[T], idx: int): T {.importcpp: "#[#]".}

proc len*[T](slice: ArraySlice[T]): int {.importcpp: "#.size()".}

  ## Size method to get the number of elements.
  ## 
  ## Args:
  ##   slice: The ArraySlice it is applied on.
  ## Returns:
  ##   The number of elements.

proc asPtr*[T](slice: ArraySlice[T]): ptr T {.importcpp:"#.pointer()".}

proc `$`*[T](slice: ArraySlice[T]): string =
  var str = "["
  let sz = slice.len()

  for i in 0..sz-2:
    str &= $slice[i] & ", "

  str &= $slice[sz-1] & "]"
  return str

  ## Method for string conversion.
  ## 
  ## Args:
  ##   slice: The ArraySlice it is applied on.
  ## Returns:
  ##   A Stringrepresentation of the ArraySlice.

proc newArraySlice*[cppstring](slice: ArraySlice[string]): ArraySlice[cppstring] = 
    let size = slice.len
    var buffer: cArray[cppstring] 
    buffer.newCArray(size, newCPPString(""))

    for i in 0..size-1:
      buffer[i] = newCPPString(slice[i])

    return newArraySlice(buffer, size)
#[
  {.header: "<algorithm>",
    importcpp:"""
    [&](){    
      auto _slice = #; 
      int _len = _slice.size(); 

      std::vector<std::string> _buffer;
      _buffer.reserve(_len);
      
      for(int i = 0; i < _len; i++) {
        int size = _slice[i]->len;
        _buffer[i].reserve(size);
        std::copy_n((char*)(&_slice[i][0]), size, &_buffer[i][0]);
      } 

      return tensorflow::gtl::ArraySlice<std::string>(_buffer);
    }()
  """
  .}
]#
  ## Method for converting an ArraySlice[string] to an ArraySlice[cppstring].
  ## 
  ## Args:
  ##   slice: The ArraySlice[string] it is applied on.
  ## Returns:
  ##   A new ArraySlice[cppstring] holding the data from the input ArraySlice[string].

iterator items*[T](slice: ArraySlice[T]): T =
  var i: cint = 0
  while i <= slice.len()-1:
    yield slice[i]
    inc i

type
  Operation {.header: gradients,
              importcpp: "tensorflow::Operation".} = object

proc num_inputs(op: Operation): int {.importcpp:"#.num_inputs()".}

proc input_type(op: Operation, o: int): core.DType {.importcpp:"#.input_type(#)".}

proc input(op: Operation, i: int): Out {.importcpp:"#.input(#)".}

proc inputs(op: Operation, rng: HSlice[int, int]): OutList =
  var inputs: OutList
  
  for i in rng:
    inputs.add op.input(i)

  return inputs

proc inputs(op: Operation): OutList =
  var inputs: OutList
  
  for i in 0..op.num_inputs-1:
    inputs.add op.input(i)

  return inputs

proc num_outputs(op: Operation): int {.importcpp:"#.num_outputs()".}

proc output_type(op: Operation, o: int): core.DType {.importcpp:"#.output_type(#)".}

proc output(op: Operation, i: int): Out {.importcpp:"#.output(#)".}

proc outputs(op: Operation, rng: HSlice[int, int]): OutList =
  var outputs: OutList
  
  for i in rng:
    outputs.add op.output(i)

  return outputs

proc outputs(op: Operation): OutList =
  var outputs: OutList
  
  for i in 0..op.num_outputs-1:
    outputs.add op.output(i)

  return outputs

proc getStrAttr(op: Operation, name: cppstring): cppstring {.importcpp:"#.node()->attrs().Find(#)->s()".}

proc getStrAttr(op: Operation, name: string): string = 
  return $getStrAttr(op, newCPPString(name))

proc igetIntAttr(op: Operation, name: cppstring): int {.importcpp:"#.node()->attrs().Find(#)->i()".}

proc getIntAttr(op: Operation, name: string): int = 
  return igetIntAttr(op, newCPPString(name))

proc igetFloatAttr(op: Operation, name: cppstring): float {.importcpp:"#.node()->attrs().Find(#)->f()".}

proc getFloatAttr(op: Operation, name: string): float = 
  return igetFloatAttr(op, newCPPString(name))

proc igetBoolAttr(op: Operation, name: cppstring): bool {.importcpp:"#.node()->attrs().Find(#)->b()".}

proc getBoolAttr(op: Operation, name: string): bool = 
  return igetBoolAttr(op, newCPPString(name))

type NameAttrList {.importcpp:"tensorflow::NameAttrList".} = object
proc igetFuncAttr(op: Operation, name: cppstring): NameAttrList {.importcpp:"#.node()->attrs().Find(#)->func()".}

proc getFuncAttr(op: Operation, name: string): NameAttrList = 
  return igetFuncAttr(op, newCPPString(name))

proc igetShapeAttr(op: Operation, name: cppstring): TensorShape {.importcpp:"#.node()->attrs().Find(#)->shape()".}

proc getShapeAttr(op: Operation, name: string): TensorShape = 
  return igetShapeAttr(op, newCPPString(name))
    
proc igetTensorAttr(op: Operation, name: cppstring): Tensor {.importcpp:"std::make_shared<tensorflow::Tensor>(std::move(#.node()->attrs().Find(#)->tensor()))".}

proc getTensorAttr(op: Operation, name: string): Tensor = 
  return igetTensorAttr(op, newCPPString(name))

proc igetDataTypeAttr(op: Operation, name: cppstring): DType {.importcpp:"#.node()->attrs().Find(#)->type()".}

proc getDataTypeAttr(op: Operation, name: string): DType = 
  return igetDataTypeAttr(op, newCPPString(name))

template mutables(name: untyped, cname: string, ctype: string, dtype: untyped): untyped =
  #TODO: maybe make protobuf types to use the size methods of those and not require them manually
  proc name[N](op: Operation, name: cppstring, len: int, arr: array[N, dtype]) {.
    importcpp:"""
      auto list = #.node()->attrs().Find(#)->list();
      auto mut = list.""" & cname & """();
      auto _arr = mut->mutable_data();
      std::copy(_arr, _arr + #, #);
    """
  .}

  proc name[N](op: Operation, name: string, len: int, arr: array[N, dtype]) =
    name(op, newCPPString(name), len, arr)

  export name

mutables(getSliceAttr_b,      "mutable_b",      "tensorflow::bool",              bool)
mutables(getSliceAttr_f,      "mutable_f",      "tensorflow::float",             float)
mutables(getSliceAttr_func,   "mutable_func",   "tensorflow::NameAttrList",      NameAttrList)
mutables(getSliceAttr_i,      "mutable_i",      "int64_t",             int64)
mutables(getSliceAttr_shape,  "mutable_shape",  "tensorflow::TensorShapeProto",  TensorShape)
mutables(getSliceAttr_type,   "mutable_type",   "tensorflow::DType",             DType)
mutables(getSliceAttr_s,      "mutable_s",      "std::string",                   cppstring)

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

proc withControlDependencies(rt: Scope, control_dep: ArraySlice[Operation] | Out): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithControlDependencies(#)))".}

  ## Return a new scope. All ops created within the returned scope will have as
  ## control dependencies the union of operations in the control_deps vector
  ## and the control dependencies of the current scope.

proc withNoControlDependencies(rt: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithNoControlDependencies()))".}

  ## Return a new scope. All ops created within the returned scope will have no
  ## control dependencies on other operations.

proc iwithDevice(rt: Scope, device: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithDevice(#)))".}

proc withDevice*(rt: Scope, device: string): Scope =
  return rt.iwithDevice(newCPPString(device))

  ## Returns a scope using the given device.

proc iwithAssignedDevice(rt: Scope, assignedDevice: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithAssignedDevice(#)))".}

proc withAssignedDevice(rt: Scope, assignedDevice: string): Scope =
  return rt.iwithAssignedDevice(newCPPString(assignedDevice))
  
  ## Returns a new scope.  All ops created within the returned scope will have
  ## their assigned device set to `assigned_device`.

proc iwithXlaCluster(scope: Scope, xla_cluster: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithXlaCluster(#)))".}

proc withXlaCluster(scope: Scope, xla_cluster: string): Scope =
  return scope.iwithXlaCluster(newCPPString(xla_cluster))
  
  ## Returns a new scope.  All ops created within the returned scope will have
  ## their _XlaCluster attribute set to `xla_cluster`.

proc colocateWith(scope: Scope, op: Operation | Out): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ColocateWith(#)))".}
  
  ## Return a new scope. All ops created within the returned scope will be
  ## co-located on the device where op is placed.
  ## NOTE: This function is intended to be use internal libraries only for
  ## controlling placement of ops on to devices. Public use is not encouraged
  ## because the implementation of device placement is subject to change.

proc clearColocation(scope: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ClearColocation(#)))".}
  
  ## Clear all colocation constraints.

proc exitOnError(scope: Scope): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->ExitOnError(#)))".}
  
  ## Return a new scope. The op-constructor functions taking the returned scope
  ## as the scope argument will exit as soon as an error is detected, instead
  ## of setting the status on the scope.

proc iwithKernelLabel(scope: Scope, kernel_label: cppstring): Scope {.importcpp:"std::make_shared<tensorflow::Scope>(std::move(#->WithKernelLabel(#)))".}

proc withKernelLabel(scope: Scope, kernel_label: string): Scope =
  return scope.iwithKernelLabel(newCPPString(kernel_label))
  
  ## Return a new scope. All ops created with the new scope will have
  ## kernel_label as the value for their '_kernel' attribute;

proc igetUniqueNameForOp(scope: Scope, default_name: cppstring): cppstring {.importcpp:"#->GetUniqueNameForOp(#)".}

proc getUniqueNameForOp(scope: Scope, default_name: string): string =
  return $scope.igetUniqueNameForOp(newCPPString(default_name))

  ## Return a unique name, using default_name if an op name has not been
  ## specified.

type
  Status* {.importcpp:"tensorflow::Status".} = object

proc updateStatus(scope: Scope, s: Status) {.importcpp:"#->UpdateStatus(#)".}

  ## Update the status on this scope.
  ## Note: The status object is shared between all children of this scope.
  ## If the resulting status is not Status::OK() and exit_on_error_ is set on
  ## this scope, this function exits by calling LOG(FATAL).

proc status(scope: Scope): Status {.importcpp:"#->status()".}

  ## Get the status of the given Scope.

proc ok(): Status {.header: std_ops,
                    importcpp: "tensorflow::Status::OK()".}

proc logStatus*(scope: Scope) {.importcpp:"LOG(FATAL) << #->status().ToString();".}

proc check*(rt: Scope) = 
  if not rt.ok(): 
      rt.logStatus
      quit(1)


var supportedTypes {.compileTime}: seq[string]

static:
  for dtype in typeLookUp.keys:
    supportedTypes.add dtype

proc insertIntoCalls(scope: NimNode, body: NimNode) {.compileTime.} =
  for i,child in body:
    if child.kind == nnkCall:    
      insert(child, 1, scope)
    elif child.kind == nnkInfix:
      insert(child, 1, scope)
    elif child.kind == nnkDotExpr:
      let repr = child[1].treeRepr
      if repr.len > 7 and repr[7..^2] in supportedTypes:
        body[i] = newCall("Const", scope, child[0], child[1])
    elif child == newIdentNode("with") or child == newIdentNode("noScope"):
      return

    if child.len != 0:
      insertIntoCalls(scope, child)

macro with*(scope: Scope, body: untyped): untyped =
  if scope.kind == nnkSym:
    insertIntoCalls(newIdentNode($scope), body)
  elif scope.kind == nnkCall:
    let hash = "scope" & signatureHash(nskLet.genSym)
    let hashIdent = newIdentNode(hash)

    insertIntoCalls(hashIdent, body)
    insert(body, 0, newLetStmt(hashIdent, scope))

  return body

macro noScope(scope: untyped, ast: untyped): untyped =
  return ast
    
type 
  GraphDef* {.importcpp:"tensorflow::GraphDef".} = object

    ## Type that holds the representation of the computation graph.

proc itoGraphDef(rt: Scope, graph: GraphDef) {.importcpp:"#->ToGraphDef(&#)".}

proc toGraphDef*(rt: Scope): GraphDef =
  var graph: GraphDef
  rt.itoGraphDef(graph)
  return graph

  ## Get a graphdef from a Scope.

## Session related definitions
type
  Session* {.header: memory,
             header: client_session,
             importcpp: "std::shared_ptr<tensorflow::ClientSession>".} = object

    ## The Session Type is a wrapper around the c++ ClientSession which is the part where the actual computation happens. 
    ## It is represented through a shared pointer here because it has no default constructor and therefore cannot be declared
    ## like:
    ##   ClientSession foo;
    ## which is excatly what the nim compiler does.

proc newSession*(scope: Scope): Session {.header: memory,
                                          header: client_session,
                                          importcpp: "std::make_shared<tensorflow::ClientSession>(*#)".}

  ## Constructor for the Session type.
  ## 
  ## Args:
  ##   scope: The Scope from which a Sessino shall be created.
  ## Returns:
  ##   A Session object that can be run to perform the Computations.

macro with*(sess: Session, body: untyped): untyped =
  if sess.kind == nnkSym:
    insertIntoCalls(newIdentNode($sess), body)
  elif sess.kind == nnkCall:
    let hash = signatureHash(nskLet.genSym)
    insert(body, 0, newLetStmt(newIdentNode(hash), sess))
    insertIntoCalls(newIdentNode(hash), body)
      
  return body
  
## Gradient Related definitions
proc addSymbolicGradients*(root: Scope, outputs, inputs, gradOutputs: OutList) {.header:gradients, importcpp:"TF_CHECK_OK(tensorflow::AddSymbolicGradients(*#, #, #, &#))".}

  ## Method for getting the gradient of a sequence of operations applied to the inputs.
  ## 
  ## Args:
  ##   root: The current Scope object.
  ##   outputs: A list of outputs or single output containing the relevant ends of the compution graph.
  ##   inputs: A list of outputs or single output containing the variables a gradient should be computed for.
  ##   gradOutputs: A list of outputs containing the computed gradients.

proc addSymbolicGradients*(root: Scope, outputs: Out, inputs, gradOutputs: OutList) {.header:gradients, importcpp:"TF_CHECK_OK(tensorflow::AddSymbolicGradients(*#, {#}, #, &#))".}

proc addSymbolicGradients*(root: Scope, outputs, inputs: Out, gradOutputs: OutList) {.header:gradients, importcpp:"TF_CHECK_OK(tensorflow::AddSymbolicGradients(*#, {#}, {#}, &#))".}

type 
  SummaryWriter* {.header:memory,
                   header:writer,
                   importcpp:"std::shared_ptr<tensorflow::EventsWriter>".} = object

    ## A Object used to log your outputs to a Tensorboard readable file.

proc inewSummaryWriter(dir: cppstring): SummaryWriter {.header:memory,
                                                        header:writer,
                                                        importcpp:"std::make_shared<tensorflow::EventsWriter>(#)".}

proc newSummaryWriter*(dir: string): SummaryWriter = inewSummaryWriter(newCPPString(dir))

  ## creates a new SummaryWriter writing to the given directory

proc write_grapdef*(summaryWriter: SummaryWriter, grah: GraphDef) {.header:writer,
                                                                   importcpp:"tensorflow::Event event; auto _writer = #; event.set_graph_def(#.SerializeAsString()); _writer->WriteEvent(event);".}

  ## writes the given GraphDef to the logs.

proc iwrite_scalar(summaryWriter: SummaryWriter, wall_time: float64, step: int64, tag: cppstring, value: float32) {.header:writer,
                                                                                                                    importcpp:"tensorflow::Event event; auto _writer = #; event.set_wall_time(#); event.set_step(#); tensorflow::Summary::Value* summ_val = event.mutable_summary()->add_value(); summ_val->set_tag(#); summ_val->set_simple_value(#); _writer->WriteEvent(event);".}

proc write_scalar*(summaryWriter: SummaryWriter, wall_time: float64, step: int64, tag: string, value: float32) =
  iwrite_scalar(summaryWriter, wall_time, step, newCPPString(tag), value)

  ## Writes a Scalar to the logs.
  ## 
  ## Args:
  ##   summaryWriter: The SummaryWriter it is applied on.
  ##   wall_time: Time it is written at.
  ##   step: The step it was written at.
  ##   tag: The name of the scalar.
  ##   value: The value of the scalar.

type 
  FeedDict* {.header:"<unordered_map>",
              importcpp:"std::unordered_map<tensorflow::Output, tensorflow::Input::Initializer, tensorflow::OutputHash>".} = object

    ## A map linking a Out from a Placeholder op to an actual tensor.

proc `[]=`*(feed: FeedDict, placeholder: Out, ten: Tensor) {.importcpp:"#.insert({#, *#})".}

proc clear*(feed: FeedDict) {.importcpp:"#.clear()".}

  ## Remove all items from the dict.

proc runSession*(sess: Session, feed: FeedDict, graph: Out, operation: Operation, outputs: TensorVec) {.header: client_session,
  importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, {#}, {#}, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   operation: Interface to run an operation without an output
  ##   outputs: A TensorVec holding the result of the computations.


proc runSession*(sess: Session, feed: FeedDict, graph: Out, outputs: TensorVec) {.header: client_session,
                                                                                importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, {#}, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   outputs: A TensorVec holding the result of the computations.

proc runSession*(sess: Session, graph: Out, outputs: TensorVec) {.header: client_session,
                                                                  importcpp: "TF_CHECK_OK((*#).Run({#}, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   outputs: A TensorVec holding the result of the computations.

proc runSession*(sess: Session, feed: FeedDict, graph: OutList, operation: Operation, outputs: TensorVec) {.header: client_session,
  importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, #, {#}, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   operation: Interface to run an operation without an output
  ##   outputs: A TensorVec holding the result of the computations.

proc runSession*(sess: Session, feed: FeedDict, graph: OutList, outputs: TensorVec) {.header: client_session,
                                                                                     importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, #, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   outputs: A TensorVec holding the result of the computations.

proc runSession*(sess: Session, graph: OutList, outputs: TensorVec) {.header: client_session,
                                                                      importcpp: "TF_CHECK_OK((*#).Run(#, &#))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   outputs: A TensorVec holding the result of the computations.

proc runSession*(sess: Session, feed: FeedDict, graph: OutList | Out, operation: Operation): TensorVec =
  var outputs: TensorVec
  sess.runSession(feed, graph, operation, outputs)
  return outputs

proc runSession*(sess: Session, feed: FeedDict, graph: OutList | Out): TensorVec =
  var outputs: TensorVec
  sess.runSession(feed, graph, outputs)
  return outputs

proc runSession*(sess: Session, graph: OutList | Out): TensorVec =
  var outputs: TensorVec
  sess.runSession(graph, outputs)
  return outputs

proc runSessionVoid*(sess: Session, feed: FeedDict, graph: Out, operation: Operation) {.header: client_session,
  importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, {#}, {#}, nullptr))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   operation: Interface to run an operation without an output

proc runSessionVoid*(sess: Session, feed: FeedDict, graph: Out) {.header: client_session,
                                                                 importcpp: "TF_CHECK_OK(#->Run((tensorflow::ClientSession::FeedType)#, {#}, nullptr))".}

  ## A Method to run computations previously definied without returning the output.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.

proc runSessionVoid*(sess: Session, graph: Out) {.header: client_session,
                                                 importcpp: "TF_CHECK_OK(#->Run({#}, nullptr))".}

  ## A Method to run computations previously definied without returning the output.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   graph: The Out/ OutList representing the computations that should be performed.

proc runSessionVoid*(sess: Session, feed: FeedDict, graph: OutList, operation: Operation) {.header: client_session,
  importcpp: "TF_CHECK_OK((*#).Run((tensorflow::ClientSession::FeedType)#, #, {#}, nullptr))".}

  ## A Method to run computations previously definied.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.
  ##   operation: Interface to run an operation without an output

proc runSessionVoid*(sess: Session, feed: FeedDict, graph: OutList) {.header: client_session,
                                                                     importcpp: "TF_CHECK_OK(#->Run((tensorflow::ClientSession::FeedType)#, #, nullptr))".}

  ## A Method to run computations previously definied without returning the output.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   feed: The FeedDict linking Out and Tensor.
  ##   graph: The Out/ OutList representing the computations that should be performed.

proc runSessionVoid*(sess: Session, graph: OutList) {.header: client_session,
                                                    importcpp: "TF_CHECK_OK(#->Run(#, nullptr))".}

  ## A Method to run computations previously definied without returning the output.
  ## 
  ## Args:
  ##   sess: The Session returned from the current Scope.
  ##   graph: The Out/ OutList representing the computations that should be performed.

export TensorShape,
       newTensorShape,
       dim_size,
       dims,
       `$`,
       DType,
       Tensor,
       newTensor,
       shape,
       dtype,
       Flat,
       flat,
       mean,
       Matrix,
       matrix,
       Scalar,
       scalar,
       set,
       get,
       batch,
       num_elements,
       #TensorMap,
       #tensorMap,
       `[]=`,
       TensorVec,
       len,
       add,
       insert,
       `[]`,
       Out,
       OutList,
       newOutList,
       InList,
       newInList,
       Operation,
       num_inputs,
       input_type,
       input,
       inputs,
       num_outputs,
       output_type,
       output,
       outputs,
       getStrAttr,
       getIntAttr,
       getFloatAttr,
       getBoolAttr,
       NameAttrList,
       getFuncAttr,
       getShapeAttr,
       getTensorAttr,
       getDataTypeAttr,
       Scope,
       newRootScope,
       newSession,
       runSession,
       runSessionVoid,
       newSubScope,
       withOpName,
       withControlDependencies,
       withNoControlDependencies,
       withDevice,
       withAssignedDevice,
       withXlaCluster,
       colocateWith,
       clearColocation,
       exitOnError,
       withKernelLabel,
       getUniqueNameForOp,
       Status,
       updateStatus,
       status,
       ok,
       with,
       noScope,
       ArraySlice,
       newArraySlice,
       `$@`,
       addSymbolicGradients,
       GraphDef,
       toGraphDef,
       SummaryWriter,
       newSummaryWriter,
       write_grapdef,
       write_scalar,
       typeLookUp,
       typeLookUpReverse,
       tf,
       FeedDict,
       clear
