"""
    OpAmp <: AbstractComponent

Operational amplifier with ideal characteristics.

# Fields

- `name::String`: Component identifier
- `g::Float64`: Open-loop voltage gain (default: 1e6)
- `umax::Float64`: Maximum output voltage (default: 15.0 V)
- `ninp::Int`: Non-inverting input node
- `ninn::Int`: Inverting input node  
- `nout::Int`: Output node

# Pins

- `:ninp`: Non-inverting input (+)
- `:ninn`: Inverting input (-)
- `:nout`: Output

# Example

```jldoctest
julia> opamp = OpAmp("OP1", g=1e5, umax=12.0)
OpAmp("OP1", 100000.0, 12.0, 0, 0, 0)
```
"""
mutable struct OpAmp <: AbstractActiveComponent
    name::String
    g::Float64
    umax::Float64
    ninp::Int
    ninn::Int
    nout::Int

    function OpAmp(name::AbstractString; g::Real=1e6, umax::Real=15.0)
        new(String(name), Float64(g), Float64(umax), 0, 0, 0)
    end
end

function to_qucs_netlist(comp::OpAmp)::String
    params = "G=\"$(comp.g)\" Umax=\"$(comp.umax)\""
    return "OpAmp:$(comp.name) $(qucs_node(comp.ninp)) $(qucs_node(comp.ninn)) $(qucs_node(comp.nout)) $params"
end

function to_spice_netlist(comp::OpAmp)::String
    "E$(comp.name) $(comp.nout) 0 $(comp.ninp) $(comp.ninn) $(comp.g)"
end

function _get_node_number(comp::OpAmp, pin::Symbol)
    if pin == :ninp
        return comp.ninp
    elseif pin == :ninn
        return comp.ninn
    elseif pin == :nout
        return comp.nout
    else
        error("Invalid pin $pin for OpAmp. Use :ninp, :ninn, or :nout")
    end
end
