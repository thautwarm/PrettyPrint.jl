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

struct C
  a
  b
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

  pprint(Dict(:a=>Account("van", "gd"), :b=>Account("thautwarm", "996icu")))

    @test pformat(Dict(:a=>Account("van", "gd"), :b=>Account("thautwarm", "996icu"))) == """{
  :a : Account(van),
  :b : Account(thautwarm),
}"""

  @test pformat(1 => 2) == "1 => 2"

  @test pformat(Any[1 + 2im, 3]) == "[1 + 2im, 3]"

  @test pformat(StructArray([B(1, 2), B(2, 3)])) =="""StructArray{B,1,NamedTuple{(:a, :b),Tuple{Array{Int64,1},Array{Int64,1}}},Int64}(
    a=[1, 2],
    b=[2, 3],
  )"""


  @test pformat([]) == "[]"

  PrettyPrint.is_static_t(::Type{B}) = true

  @test pformat(StructArray([B(1, 2), B(2, 3)])) =="""StructArray{B,1,NamedTuple{(:a, :b),Tuple{Array{Int64,1},Array{Int64,1}}},Int64}(
    a=[1, 2],
    b=[2, 3],
  )"""
  
  @test pformat(['a', 'b']) == "['a', 'b']"
  @test pformat(['a', nothing]) == "['a', nothing]"

  xs = collect(1:100)
  @test pformat(xs) == 
"""
[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 
 12, 13, 14, 15, 16, 17, 18, 19, 
 20, 21, 22, 23, 24, 25, 26, 27, 
 28, 29, 30, 31, 32, 33, 34, 35, 
 36, 37, 38, 39, 40, 41, 42, 43, 
 44, 45, 46, 47, 48, 49, 50, 51, 
 52, 53, 54, 55, 56, 57, 58, 59, 
 60, 61, 62, 63, 64, 65, 66, 67, 
 68, 69, 70, 71, 72, 73, 74, 75, 
 76, 77, 78, 79, 80, 81, 82, 83, 
 84, 85, 86, 87, 88, 89, 90, 91, 
 92, 93, 94, 95, 96, 97, 98, 99, 
 100]"""

    @test pformat([1]) == "[1,]"
    @test pformat((1, )) == "(1,)"

    PrettyPrint.is_simple_t(::Type{C}) = true
    PrettyPrint.is_static_t(::Type{C}) = true
    @test is_static_t(typeof(C(1, 2))) == true
    @test pformat(C(1, 2)) == "C(a=1, b=2)"
    @test pformat(SubString("aa", 1)) == "\"aa\""

    @test is_simple_t(Int) == true
    @test is_simple_t(SubString) == true
    @test is_simple_t(Complex{Int}) == true
    @test is_simple_t(Char) == true
    @test is_simple_t(Nothing) == true
    @test is_simple(PrettyPrint.PPPair("1", "=", "3")) == true
    pprintln(true)
    
  end

end
