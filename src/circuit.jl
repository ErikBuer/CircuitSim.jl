mutable struct Circuit
    components::Vector{Any}
    uf::UnionFind
    # optional cache of assigned node numbers
    _node_map::Dict{Int,Int}  # root-pinid => node number
    Circuit() = new(Any[], UnionFind(), Dict{Int,Int}())
end

# add a component to the circuit (if not already added)
function add_component!(c::Circuit, comp::Any)
    # naive check: by identity (objectid)
    for ex in c.components
        if objectid(ex) == objectid(comp)
            return comp
        end
    end
    push!(c.components, comp)
    return comp
end

# connect two pins in the circuit. The components will be added if not present.
function connect!(c::Circuit, p1::Pin, p2::Pin)
    add_component!(c, p1.comp)
    add_component!(c, p2.comp)
    uf_union!(c.uf, pinid(p1), pinid(p2))
    return nothing
end

# a convenience overload that accepts component + symbol pairs:
function connect!(c::Circuit, a_comp::Any, a_field::Symbol, b_comp::Any, b_field::Symbol)
    connect!(c, Pin(a_comp, a_field), Pin(b_comp, b_field))
end

# Macro to connect using dot syntax: @connect circ a.pin b.pin
# Expands to connect!(circ, Pin(a, :pin), Pin(b, :pin))
macro connect(circ, a_expr, b_expr)
    # expect a_expr and b_expr to be of form :(. a field)
    if !(a_expr.head === :(.)) || !(b_expr.head === :(.))
        throw(ArgumentError("@connect usage: @connect circ a.pin b.pin"))
    end
    a_obj = a_expr.args[1]
    a_field = a_expr.args[2]
    b_obj = b_expr.args[1]
    b_field = b_expr.args[2]
    return :(connect!($circ, Pin($a_obj, $(QuoteNode(a_field))), Pin($b_obj, $(QuoteNode(b_field)))))
end

