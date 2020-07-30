using PrettyPrint
using StructArrays
using Test
struct Account
    username :: String
    password :: String
end

struct S1
  i :: Int
  f :: Float64
end

struct S2
  s  :: Vector{String}
  s1 :: S1
end

struct B
  a :: Int
  b :: Int
end

@testset "PrettyPrint.jl" begin

    data = S2(
        ["114514", "as we can"],
        S1(42, 9.96)
    )
    pprint(data)
    println()
    @test pformat(data) == """S2(
  s=["114514", "as we can"],
  s1=S1(i=42, f=9.96),
)"""

    @testset "extension" begin
    @test pformat([Account("van", "gd"), Account("thautwarm", "996icu")]) == """[
  Account(username="van", password="gd"),
  Account(username="thautwarm", password="996icu"),
]"""
    PrettyPrint.pp_impl(io, account::Account, indent::Int) = begin
      repr = "Account($(account.username))"
      print(io, repr)
      length(repr) + indent
    end

    @test pformat([Account("van", "gd"), Account("thautwarm", "996icu")]) == """[
  Account(van),
  Account(thautwarm),
]"""
    @test pformat(Set([Account("van", "gd")])) == """{
  Account(van),
}"""
    @test pformat((Account("van", "gd"), Account("thautwarm", "996icu"))) == """(
  Account(van),
  Account(thautwarm),
)"""

  pprint(Dict(:a=>Account("van", "gd"), :b=>Account("thautwarm", "996icu")))

    @test pformat(Dict(:a=>Account("van", "gd"), :b=>Account("thautwarm", "996icu"))) == """{
  :a : Account(van),
  :b : Account(thautwarm),
}"""

  pprint(Set([Account("van", "gd"), Account("thautwarm", "996icu")]))
  @test pformat(Set([Account("van", "gd"), Account("thautwarm", "996icu")])) == """{
  Account(thautwarm),
  Account(van),
}"""

  @test pformat(1 => 2) == "1 => 2"

  @test pformat(Any[1 + 2im, 3]) == "[1 + 2im, 3]"

  @test pformat(StructArray([B(1, 2), B(2, 3)])) =="""StructArray{B,1,NamedTuple{(:a, :b),Tuple{Array{Int64,1},Array{Int64,1}}},Int64}(
    a=[1, 2],
    b=[2, 3],
  )"""
  
  end

end
