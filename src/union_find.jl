mutable struct UnionFind
    parent::Dict{Int,Int}
    UnionFind() = new(Dict{Int,Int}())
end

function uf_find(uf::UnionFind, x::Int)
    p = uf.parent
    if !haskey(p, x)
        p[x] = x
        return x
    end
    # path compression
    while p[x] != x
        p[x] = p[p[x]]
        x = p[x]
    end
    return x
end

function uf_union!(uf::UnionFind, a::Int, b::Int)
    ra = uf_find(uf, a)
    rb = uf_find(uf, b)
    if ra == rb
        return ra
    end
    uf.parent[rb] = ra
    return ra
end