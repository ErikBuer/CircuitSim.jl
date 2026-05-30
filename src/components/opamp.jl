"""
    OpAmp <: AbstractComponent

Operational amplifier with ideal characteristics.

# Fields

- `name::String`: Component identifier
- `ninp::Int`: Non-inverting input node
- `ninn::Int`: Inverting input node  
- `nout::Int`: Output node
- `g::Float64`: Open-loop voltage gain, must be >= 1 (default: 1e6)
- `umax::Float64`: Maximum output voltage in V, must be positive (default: 15.0)

# Pins

- `:ninp`: Non-inverting input (+)
- `:ninn`: Inverting input (-)
- `:nout`: Output

# Example

```jldoctest
julia> opamp = OpAmp("OP1", g=1e5, umax=12.0)
OpAmp("OP1", 0, 0, 0, 100000.0, 12.0)
```
"""
mutable struct OpAmp <: AbstractActiveComponent
    name::String

    ninp::Int
    ninn::Int
    nout::Int

    g::Float64
    umax::Float64

    function OpAmp(name::AbstractString;
        g::Real=1e6,
        umax::Real=15.0
    )
        g >= 1 || throw(ArgumentError("Gain G must be >= 1"))
        umax > 0 || throw(ArgumentError("Maximum output voltage Umax must be positive"))
        new(String(name), 0, 0, 0, Float64(g), Float64(umax))
    end
end

function to_qucs_netlist(comp::OpAmp)::String
    params = "G=\"$(comp.g)\" Umax=\"$(comp.umax)\""
    # Node order: INM (inverting), INP (non-inverting), OUT
    return "OpAmp:$(comp.name) $(qucs_node(comp.ninn)) $(qucs_node(comp.ninp)) $(qucs_node(comp.nout)) $params"
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
