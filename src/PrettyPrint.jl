module PrettyPrint
export pprint, pprintln, pformat, is_simple, is_simple_t, is_atom_t, is_static_t, pp_impl, pp_impl_dynamic, pp_impl_static, MaxIndentExpected


struct PPPair{FieldName, FieldContent}
    name :: FieldName
    sep :: String
    content :: FieldContent
end

struct PPMetaSymbol{S}
    s :: S
end

Base.show(io::IO, p::PPMetaSymbol) = Base.print(io, p.s)

is_simple_t(a) = isprimitivetype(a)
is_simple_t(::Type{<:Number}) = true
is_simple_t(::Type{<:AbstractString}) = true
is_simple_t(::Type{<:AbstractChar}) = true
is_simple_t(::Type{<:Symbol}) = true
is_simple_t(::Type{<:Complex}) = true
is_simple_t(::Type{<:PPMetaSymbol}) = true
is_simple_t(::Type{Nothing}) = true
is_simple_t(::Type{PPPair{A1, A2}}) where {A1, A2} = is_simple_t(A1) && is_simple_t(A2)
is_simple(::T) where T = is_simple_t(T)

is_atom_t(_) = false
is_atom_t(::Type{<:Number}) = true
is_atom_t(::Type{<:AbstractString}) = true
is_atom_t(::Type{<:AbstractChar}) = true
is_atom_t(::Type{<:Symbol}) = true
is_atom_t(::Type{<:Complex}) = true
is_atom_t(::Type{<:PPMetaSymbol}) = true
is_atom_t(::Type{Nothing}) = true
is_atom(::T) where T = is_atom_t(T)

is_static_t(a) = isprimitivetype(a)
is_static_t(::Type{String}) = true
is_static_t(::Type{Symbol}) = true
is_static_t(::Type{<:Complex}) = true


const Indentation = Int
const MaxIndentExpected = Ref{Int}(30)

print_repeat(n::Int, io::IO, e) = for i = 1:n
    print(io, e)
end

function pprint_for_seq(io, left::String, right::String, seq :: Union{Vector, Tuple}, indent::Int)::Indentation
    print(io, left)
    n = length(seq)
    is_empty = n === 0
    if is_empty
        print(io, right)
        return indent + length(left) + length(right)
    end
    
    if all(is_simple(e) for e in seq)
        indent += length(left)
        indent′ = indent
        max_indent = MaxIndentExpected[]
        indent′ = pp_impl(io, seq[1], indent)
        if n == 1
            print(io, ",")
            indent′ += 2
        end    
        for i in 2:n
            e = seq[i]
            print(io, ", ")
            
            if indent′ > max_indent
                print(io, '\n')
                indent′ = indent
                print_repeat(indent, io, ' ')
            else
                indent′ += 2
            end
            
            indent′ = pp_impl(io, e, indent′)
        end

        print(io, right)
        indent′ += length(right)

        return indent′
    end

    print(io, '\n')
    indent′ = indent + 2
    for e in seq
        print_repeat(indent′, io, ' ')
        pp_impl(io, e, indent′)
        print(io, ',')
        print(io, '\n')
    end
    print_repeat(indent, io, ' ')
    print(io, right)
    return indent + length(right)
end

"""
The implementation of `pprint` and `pformat`.

You can extend pretty print support via such boilerplate:
```
    function PrettyPrint.pp_impl(io, data::YourType, indent::Int)
        print(io, data)
    end
```
"""
function pp_impl(io, seq::Vector, indent::Indentation)::Indentation
    pprint_for_seq(io, "[", "]", seq, indent)
end

function pp_impl(io, seq::Tuple, indent::Indentation)::Indentation
    pprint_for_seq(io, "(", ")", seq, indent)
end

function pp_impl(io, seq::AbstractSet, indent::Indentation)::Indentation
    pprint_for_seq(io, "{", "}", collect(seq), indent)
end

function pp_impl(io, seq::AbstractDict, indent::Indentation)::Indentation
    pprint_for_seq(io, "{", "}", [PPPair(k, " : ", v) for (k, v) in seq], indent)
end

function pp_impl(io, p::PPPair{K, V}, indent)::Indentation where {K, V}
    indent = pp_impl(io, p.name, indent)
    print(io, p.sep)
    indent += length(p.sep)
    pp_impl(io, p.content, indent)
end

function pp_impl(io, p::Pair, indent::Indentation)::Indentation
    pp_impl(io, PPPair(p.first, " => ", p.second), indent)
end

pp_impl(io, p, indent)::Indentation =
    if is_static_t(typeof(p))
        pp_impl_static(io, p, indent)
    else
        pp_impl_dynamic(io, p, indent)
    end

@generated function pp_impl_static(io, data::T, indent)::Indentation where T
    if is_atom_t(T)
        return quote s = repr(data); print(io, s); length(s) + indent  end
    end
    fields = fieldnames(T)
    exp = Expr(:tuple)
    for field in fields    
        push!(exp.args, Expr(:call, PPPair, PPMetaSymbol(field), "=", :(data.$field)))
    end
    left = string(T) * "("
    right = ")"
    :(pprint_for_seq(io, $left, $right, $exp, indent))
end

function pp_impl_dynamic(io, data, indent)::Indentation    
    if is_atom(data)
        s = repr(data)
        print(io, s)
        return length(s) + indent 
    end

    fields = propertynames(data)
    left = string(typeof(data)) * "("
    right = ")"
    seq = [PPPair(PPMetaSymbol(field), "=", getproperty(data, field)) for field in fields]
    pprint_for_seq(io, left, right, seq, indent)
end


"""
pretty print to IO.
"""
function pprint(io, data, indent)
    pp_impl(io, data, indent)
    nothing
end

function pprint(io, data)
    pprint(io, data, 0)
end

function pprint(data)
    pprint(stdout, data)
end

"""
return pretty formatted string
"""
function pformat(data)
    io = IOBuffer()
    pprint(io, data)
    String(take!(io))
end

pp_impl(io, s :: String, indent) = begin
    s = repr(s)
    print(io, s)
    length(s) + indent
end

pprintln(io, s) = begin
    pprint(io, s)
    print(io, '\n')
end

pprintln(s) = pprintln(stdout, s)

@deprecate pprint(io, data, indent, newline) pprint(io, data, indent)
@deprecate pp_impl(io, data, indent, newline) pp_impl(io, data, indent)

end # module
