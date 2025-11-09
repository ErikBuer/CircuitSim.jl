

"""
Walk all components, examine their integer fields (node fields), and assign canonical node numbers (small consecutive integers). Ground is node 0.
After calling assign_nodes!, the components' node fields are filled with integers suitable for netlisting.
"""
function assign_nodes!(c::Circuit)
    # build an index of all pin-ids that belong to node-like fields
    rootset = Dict{UInt64,Int}() # root-pinid => temporary index
    c._node_map = Dict{UInt64,Int}()  # final mapping root -> node number

    # helper: treat any field whose value is an Int and whose name looks like n or n1/n2/nplus etc.
    for comp in c.components
        for fld in fieldnames(typeof(comp))
            # filter to fields that are Int (we treat them as node fields)
            if getfield(comp, fld) isa Int
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
            if getfield(comp, fld) isa Int
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
            if getfield(comp, fld) isa Int
                root = uf_find(c.uf, pinid(Pin(comp, fld)))
                # If the pin wasn't part of any union-find root mapping (shouldn't happen), set to 0
                node = get(c._node_map, root, 0)
                setfield!(comp, fld, node)
            end
        end
    end

    return nothing
end

"""
Simple formatting helper for numeric values
"""
format_value(v::Real) = sprint(x -> begin
    show(x, v)
end)
