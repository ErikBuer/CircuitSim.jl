"""
Circuit representation: collection of components and connections
"""
mutable struct Circuit
    components::Vector{Any}
    uf::UnionFind
    # optional cache of assigned node numbers
    _node_map::Dict{UInt64,Int}  # root-pinid => node number
    Circuit() = new(Any[], UnionFind(), Dict{UInt64,Int}())
end

"""
Add a component to the circuit (if not already added)
"""
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

"""
Connect two pins in the circuit. The components will be added if not present.
"""
function connect!(c::Circuit, p1::Pin, p2::Pin)
    add_component!(c, p1.comp)
    add_component!(c, p2.comp)
    uf_union!(c.uf, pinid(p1), pinid(p2))
    return nothing
end

"""
A convenience overload that accepts component + symbol pairs:
"""
function connect!(c::Circuit, a_comp::Any, a_field::Symbol, b_comp::Any, b_field::Symbol)
    connect!(c, Pin(a_comp, a_field), Pin(b_comp, b_field))
end

"""
Macro to connect using dot syntax: @connect circ a.pin b.pin
"""
macro connect(circ, a_expr, b_expr)
    # expect a_expr and b_expr to be of form :(. a field)
    if !(a_expr.head === :(.)) || !(b_expr.head === :(.))
        throw(ArgumentError("@connect usage: @connect circ a.pin b.pin"))
    end
    a_obj = a_expr.args[1]
    a_field = a_expr.args[2]
    b_obj = b_expr.args[1]
    b_field = b_expr.args[2]

    # Extract the symbols from QuoteNode if needed
    a_sym = a_field isa QuoteNode ? a_field.value : a_field
    b_sym = b_field isa QuoteNode ? b_field.value : b_field

    return :(connect!($(esc(circ)), Pin($(esc(a_obj)), $(QuoteNode(a_sym))), Pin($(esc(b_obj)), $(QuoteNode(b_sym)))))
end

