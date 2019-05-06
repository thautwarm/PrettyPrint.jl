using PrettyPrint
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

@testset "PrettyPrint.jl" begin

    data = S2(
        ["114514", "as we can"],
        S1(42, 9.96)
    )

    @test pformat(data) == """S2(
  s=[
    "114514",
    "as we can",
  ],
  s1=S1(
    i=42,
    f=9.96,
  ),
)"""

    @testset "extension" begin
    @test pformat([Account("van", "gd"), Account("thautwarm", "996icu")]) == """[
  Account(
    username="van",
    password="gd",
  ),
  Account(
    username="thautwarm",
    password="996icu",
  ),
]"""
    PrettyPrint.pprint_impl(io, account::Account, indent::Int, newline::Bool) = print(io, "Account($(account.username))")
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
    end

end
