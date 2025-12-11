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
    # Helper to parse expression - returns (object, pin_symbol)
    function parse_pin_expr(expr)
        if isa(expr, Symbol)
            # Just a bare symbol (e.g., gnd) - default to :n pin
            return (expr, :n)
        elseif expr.head === :(.)
            # Normal case: component.pin
            obj = expr.args[1]
            field = expr.args[2]
            sym = field isa QuoteNode ? field.value : field
            return (obj, sym)
        else
            # Fallback: treat as component with :n pin
            return (expr, :n)
        end
    end

    a_obj, a_sym = parse_pin_expr(a_expr)
    b_obj, b_sym = parse_pin_expr(b_expr)

    return :(connect!($(esc(circ)), Pin($(esc(a_obj)), $(QuoteNode(a_sym))), Pin($(esc(b_obj)), $(QuoteNode(b_sym)))))
end

"""
Walk all components, examine their integer fields (node fields), and assign canonical node numbers (small consecutive integers). Ground is node 0.
After calling assign_nodes!, the components' node fields are filled with integers suitable for netlisting.

Node fields are identified by name pattern: n, n1, n2, nplus, nminus, etc.
Other Int fields (like port numbers) are left unchanged.
"""
function assign_nodes!(c::Circuit)
    # build an index of all pin-ids that belong to node-like fields
    rootset = Dict{UInt64,Int}() # root-pinid => temporary index
    c._node_map = Dict{UInt64,Int}()  # final mapping root -> node number

    # helper: treat any field whose value is an Int and whose name looks like a node field
    # Node field names: n, n1, n2, n3, ..., nplus, nminus, cathode, anode, gate, drain, etc.
    function is_node_field(fname::Symbol)::Bool
        s = string(fname)
        # Match standard patterns: n, n1-n99, nplus, nminus
        # Plus semantic names: cathode, anode, gate, drain, source, collector, base, emitter, input, output, bulk, t1, t2
        return s == "n" ||
               occursin(r"^n\d+$", s) ||
               s == "nplus" ||
               s == "nminus" ||
               s in ("cathode", "anode", "gate", "drain", "source", "collector", "base", "emitter", "input", "output", "bulk", "t1", "t2")
    end

    for comp in c.components
        for fld in fieldnames(typeof(comp))
            # filter to fields that are Int AND have node-like names
            if getfield(comp, fld) isa Int && is_node_field(fld)
                p = Pin(comp, fld)
                # If the pin currently has value 0 and is connected to nothing, leave as 0 (unconnected)
                pid = pinid(p)
                # ensure it's present in union-find so uf_find works
                uf_find(c.uf, pid)
            end
        end
    end

    # collect roots
    for comp in c.components
        for fld in fieldnames(typeof(comp))
            if getfield(comp, fld) isa Int && is_node_field(fld)
                root = uf_find(c.uf, pinid(Pin(comp, fld)))
                # we still register the root even if it's isolated (it will be its own root)
                rootset[root] = 1
            end
        end
    end

    # If there is a Ground in components, any root belonging to a Ground pin gets node 0
    ground_roots = Set{UInt64}()
    for comp in c.components
        if comp isa Ground
            # assume field for ground is :n
            root = uf_find(c.uf, pinid(Pin(comp, :n)))
            push!(ground_roots, root)
        end
    end

    # Assign node numbers: reserve 0 for ground if present, otherwise start at 1
    next_node = 1
    for root in keys(rootset)
        if root in ground_roots
            c._node_map[root] = 0
        else
            c._node_map[root] = next_node
            next_node += 1
        end
    end

    # write back numeric node numbers into component fields
    for comp in c.components
        for fld in fieldnames(typeof(comp))
            if getfield(comp, fld) isa Int && is_node_field(fld)
                root = uf_find(c.uf, pinid(Pin(comp, fld)))
                # If the pin wasn't part of any union-find root mapping (shouldn't happen), set to 0
                node = get(c._node_map, root, 0)
                setfield!(comp, fld, node)
            end
        end
    end

    return nothing
end