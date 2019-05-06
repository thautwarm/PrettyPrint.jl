module PrettyPrint
export pprint, pformat, pprint_impl

function pprint_for_seq(io, left, right, seq :: Union{Vector, Tuple}, indent, newline)
    print(io, left)
    n = length(seq)
    is_empty = n === 0
    if !is_empty
        print(io, '\n')
        print(io, repeat(" ", indent + 2))
        head = seq[1]
        range = 2:n
        pprint(io, head, indent + 2, false)
        print(io, ',')
    else
        range = []
    end
    for i in range
        each = seq[i]
        pprint(io, each, indent + 2, true)
        print(io, ",")
    end
    if !is_empty
        print(io, "\n")
        print(io, repeat(" ", indent))
    end
    print(io, right)
end

"""
The implementation of `pprint` and `pformat`.

You can extend pretty print support via such boilerplate:
```
    function PrettyPrint.pprint_impl(io, data::YourType, indent::Int, newline::Bool)
        print(io, data)
    end
```
"""
function pprint_impl(io, seq::Vector, indent, newline)
    pprint_for_seq(io, '[', ']', seq, indent, newline)
end

function pprint_impl(io, seq::Tuple, indent, newline)
    pprint_for_seq(io, '(', ')', seq, indent, newline)
end

function pprint_impl(io, seq::Set, indent, newline)
    pprint_for_seq(io, '{', '}', collect(seq), indent, newline)
end

function pprint_impl(io, ::Nothing, indent, newline)
    print(io, "nothing")
end

@generated function pprint_impl(io, data, indent, newline)
    head = string(data) * "(\n"
    fields = fieldnames(data)
    if isempty(fields)
        return quote print(io, data) end
    end
    expr_seqs = map(fields) do field
        quote
            print(io, repeat(" ", indent + 2))
            print(io, $(QuoteNode(field)))
            print(io, "=")
            pprint(io, data.$field, indent + 2, false)
            print(io, ",\n")
        end
    end
    quote
        print(io, $head)
        $(expr_seqs...)
        print(io, repeat(" ", indent))
        print(io, ")")
    end
end


"""
pretty print to IO.
"""
function pprint(io, data, indent, newline)
    if newline
        print(io, "\n")
        print(io, repeat(" ", indent))
    end
    pprint_impl(io, data, indent, newline)
end

function pprint(io, data)
    pprint(io, data, 0, false)
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

pprint_impl(io, s :: String, indent, newline) = show(io, s)

end # module
