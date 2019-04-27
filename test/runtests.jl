using PrettyPrint
using Test

@testset "PrettyPrint.jl" begin
    # Write your own tests here.
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
        ["114514", "as we cam"],
        S1(42, 9.96)
    )
    pprint(data) # or print(pformat(data))
    println()
    print(pformat(data))
    println()

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
    pprint_impl(io, account::Account, indent::Int, newline::Bool) = print(io, "Account($(account.username))")

    @info :after_extension
    pprint(
            [Account("van", "gd"), Account("thautwarm", "996icu")]
    )
    println()
end
