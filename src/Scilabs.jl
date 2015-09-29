module Scilabs

using Compat
using DataStructures
using Distributions
using GLM
using Formatting
using MAT
using Glob
using Match
using Pipe

# using Compose
# using Memoize

export Web, writemime, load_md_table, glob, @pipe, @ls, filter, @_, gpath, load_csv_table

# if VERSION > v"0.3"
#
#     using Base.HTML
#
#     HTML(s::String) = new(s)
#
#     HTML(s) = new(stringmime("text/html",s))
#
# else


    type Web
       content::String

       Web(s::String) = new(s)

       Web(s) = new(stringmime("text/html",s))
    end

    import Base.writemime

    function writemime(io::IO, ::MIME"text/html", x::Web)
        write(io, x.content);
    end

# end

function gpath(xs; path=".")
    res = glob(xs, path)
    isempty(res) && error("File not found for pattern: `$xs` in path: `$(path |> realpath)`")
    res |> first
end

macro ls()
    :( readdir() )
end

import Base.filter

function contains(s::String)
    function containsCurry(xs)
        return contains(xs, s)
    end
    return containsCurry
end

function filter(foo::Function)
    function filterCurry(xs)
        return filter(foo, xs)
    end
    return filterCurry
end

macro _(xs)
    :( _ -> $(xs) )
end

## Array indexes
import Base.(.==)
import Base.∪

≈(x,y::Real) = isapprox(x, y)
≈(x,yt::Tuple) = isapprox(x, yt[1], atol=yt[2])
≈(xs::Array,y::Int) = find(x-> trunc(x) == y, xs)
≈(xs::Array,y::Real) = find(x->isapprox(x, y), xs)
≈(xs::Array,yt::FloatRange) = find(x->isapprox(x, yt.start, atol=yt.step), xs)

±(x,y) = range(x,y,0)
.==(arr::Array,y::FloatRange) = [ isapprox(x,y.start, atol=y.step) for x in arr ]

⊂(x::String, xs::String) = contains(xs, x)
⊂(x::String, name::Symbol) = xs -> contains(xs, x)

export ⊂, ±, .==, ≈, ∪, ⊂

## Dictionary Handling ##

markdownsplitter(x::String) = @pipe x |> strip(_) |> strip(_,'|') |> split(_,'|') |> map(strip,_)
dictFromArray(fields) = x -> OrderedDict(zip(fields,x))
arrayFromDictKeyArray(d::Dict, keys::Array, exclude...) = [ d[k] for k in filter(x-> !(x in exclude),keys) ]


⊂(d::Dict, keys::Array) = Dict( [ k=>v for (k,v) in filter((x,y)-> in(x,Set(keys)),d) ] )
∪(u::Dict, v::Dict) = Dict( concat(u ⊂ collect(keys(v)),v) )


## Matrix Helpers

simplify_mat(d::Dict{ASCIIString, Any}) = Dict{Symbol, Any}( [ symbol(string(k)) => simplify_mat(v) for (k,v) in d ] )
simplify_mat(arr::Array{Float64,2}) = arr[:] # slicing???
simplify_mat(o::Any) = o

## Markdown Helpers

function load_md_table_raw(testfile; f::Function=(x)->x)
    tests = open("$testfile") do f readlines(f) end
    headers = tests[1] |> markdownsplitter |> xs->map(lowercase, xs) |> xs->map(symbol, xs)
    @show headers

    @pipe( tests[3:end]
        |> map(markdownsplitter,_)
        |> filter( l -> any(  x -> !isempty(x), l), _)
        |> map(f,_)
        |> map(dictFromArray(headers),_)
    )
end

function load_md_table(testfile)

    function parser(x)
        asint(i) = try parse(Int, i) catch () end
        asfloat(i) = try parse(Float, i) catch () end
        y = ()
        if (isempty(y)) y = asint(x) end
        if (isempty(y)) y = asfloat(x) end
        if (isempty(y)) y = x end
        return y
    end

    load_md_table_raw(testfile, f= x->map(parser,x))
end

function load_csv_table(testfile; usesymbols=false)
    dataMat = readcsv(testfile)
    
    if usesymbols
        headers = Symbol[ symbol(d) for d in dataMat[1,:] ]
    else
        headers = String[ string(d) for d in dataMat[1,:] ]
    end
    
    makeRow = dictFromArray(headers)    
    @show(headers, size(dataMat))
    
    dat = Any[ ]
    for i in 2:size(dataMat)[1]
        row = dataMat[i,:]
        push!(dat, makeRow(row))
    end
    
    return dat
end


include("Fitting.jl")


end
