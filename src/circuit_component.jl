"""
Default implementations for AbstractCircuitComponent methods.
These provide the standard behavior for components with direct field-based pins.
SPfile and other components with virtual pins can override these.
"""

# Helper: check if field name looks like a node field
# Node field names: n, n1, n2, n3, ..., nplus, nminus, cathode, anode, gate, drain, etc.
function _is_node_field(fname::Symbol)::Bool
    s = string(fname)
    return s == "n" ||
           occursin(r"^n\d+$", s) ||
           s == "nplus" ||
           s == "nminus" ||
           s in ("ref", "cathode", "anode", "gate", "drain", "source", "collector", "base", "emitter", "input", "output", "bulk", "t1", "t2", "substrate")
end

# Register component pins in union-find (default method)
function _register_pins_in_uf!(uf::UnionFind, comp::AbstractCircuitComponent)
    for fld in fieldnames(typeof(comp))
        if getfield(comp, fld) isa Int && _is_node_field(fld)
            p = Pin(comp, fld)
            pid = pinid(p)
            uf_find(uf, pid)
        end
    end
end

# Collect roots from component pins (default method)
function _collect_roots!(rootset::Dict{UInt64,Int}, uf::UnionFind, comp::AbstractCircuitComponent)
    for fld in fieldnames(typeof(comp))
        if getfield(comp, fld) isa Int && _is_node_field(fld)
            root = uf_find(uf, pinid(Pin(comp, fld)))
            rootset[root] = 1
        end
    end
end

# Write back node numbers to component fields (default method)
function _write_node_numbers!(comp::AbstractCircuitComponent, uf::UnionFind, node_map::Dict{UInt64,Int})
    for fld in fieldnames(typeof(comp))
        if getfield(comp, fld) isa Int && _is_node_field(fld)
            root = uf_find(uf, pinid(Pin(comp, fld)))
            node = get(node_map, root, 0)
            setfield!(comp, fld, node)
        end
    end
end
