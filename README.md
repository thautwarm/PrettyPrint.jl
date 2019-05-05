# PrettyPrint

[![Build Status](https://travis-ci.org/thautwarm/PrettyPrint.jl.svg?branch=master)](https://travis-ci.org/thautwarm/PrettyPrint.jl)
[![Codecov](https://codecov.io/gh/thautwarm/PrettyPrint.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/thautwarm/PrettyPrint.jl)

## Install

```
pkg> add https://github.com/thautwarm/PrettyPrint.jl#master
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
pprint(data) # or print(pformat(data))
```

produces

```julia
S2(
  s=[
    "114514",
    "as we cam",
  ],
  s1=S1(
    i=42,
    f=9.96,
  ),
)
```

## Pretty print extension for any other type

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
PrettyPrint.pprint_impl(io, account::Account, indent::Int, newline::Bool) = print(io, "Account($(account.username))")

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
  Account(
    username="van",
    password="gd",
  ),
  Account(
    username="thautwarm",
    password="996icu",
  ),
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

Any other datatypes are also supported with a default `pprint_impl`.