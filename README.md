# PrettyPrint

[![Build Status](https://travis-ci.org/thautwarm/PrettyPrint.jl.svg?branch=master)](https://travis-ci.org/thautwarm/PrettyPrint.jl)
[![Codecov](https://codecov.io/gh/thautwarm/PrettyPrint.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/PrettyPrint.jl)

PrettyPrint.jl is a library for easy pretty printing in Julia.

It does not aim to provide very high extensibility and customizations(but still very rich), instead, it targets extreme simplicity and *99%* use cases when pretty printing is needed.

*99%* users exclusively use 2 functions `pprintln` and `pformat`.

- `pprint(io::IO, data)::Nothing`
- `pformat(data)::String`
- `pprintln`: add a newline after `pprint`

## Tips for `v0.1` Users

`v0.1` APIs broke because I didn't find a good approach to emit deprecation warnings when adding method overloads incorrectly. Only in this way can I prevent users continuously using `pprint_impl(io, data, indent, newline) = ...`.


**A pp extension method implementation change to `pp_impl(io, data, indent)` instead of `pprint_impl(io, data, indent, newline)`.**

Besides, the new API `pp_impl` should **return an integer** indicating the final indentation level.

Example:
```julia
function PrettyPrint.pp_impl(io, data::MyData, indent::Int)
   s = "<" * repr(data) * ">"
   print(io, s)
   return length(s) + indent
end
```


## Install

```
pkg> add PrettyPrint
```

## Basic Usage
```julia
using PrettyPrint

struct S1
    i :: Int
    f :: Float64
end

struct S2
    s  :: Vector{String}
    s1 :: S1
end

data = S2(
    ["114514", "as we can"],
    S1(42, 9.96)
)
pprintln(data) # or println(pformat(data))
```

produces

```julia
S2(
  s=["114514", "as we cam"],
  s1=S1(i=42, f=9.96),
)
```

## Extensions via `pp_impl`

```julia
using PrettyPrint
struct Account
    username :: String
    password :: String
end

@info :before_extension
pprint(
  [Account("van", "gd"), Account("thautwarm", "996icu")]
)
println()

PrettyPrint.pp_impl(io, account::Account, indent::Int) = print(io, "Account($(account.username))")

@info :after_extension
pprint(
  [Account("van", "gd"), Account("thautwarm", "996icu")]
)
println()
```

produces

```julia
[ Info: before_extension
[
  Account(username="van", password="gd"),
  Account(username="thautwarm", password="996icu"),
]
[ Info: after_extension
[
  Account(van),
  Account(thautwarm),
]
```

## Built-in Supported Datatypes

1. Vector
2. Tuple
3. Set
4. String
5. Nothing
6. Dict

Any other datatypes are also supported with a default `pp_impl`.

## `is_simple_t` Protocol

```julia
pprint([1, 2, 3])
# => [1, 2, 3]
pprint([Account("van", "gd")])
# [
    Account(username="van", password="gd")
# ]
```

What's the difference?

**Because `PrettyPrint.is_simple_t(Int) == true` while `PrettyPrint.is_simple_t(Int) == false`**.


If you want to have the following effect:

```julia
struct K
  a :: Int
end
pprint([K(1), K(2)])
# [
#  K(a=1,),
#  K(a=2,),
# ]

```

do this

```julia
PrettyPrint.is_simple_t(::Type{K}) = true
# [K(a=1,), K(a=2,)]
```

## `is_atom_t` Protocol

If you want to pp data via `repr` instead of recursively pretty printing, try

```julia
struct X
  a
  b
end
pprint(X([1, 2], 1))
# X(
#   a = [1, 2],
#   b = 1
# )
PrettyPrint.is_atom_t(::Type{X}) = true
pprint(X([1, 2], 1))
# X([1, 2], 1)
```

## Expected Maximum Column Length

This is not strict, but you can adjust the column length of PrettyPrint.jl by

```julia
PrettyPrint.MaxIndentExpected[] = 42
```
