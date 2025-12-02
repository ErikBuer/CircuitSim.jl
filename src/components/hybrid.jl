"""
    Hybrid <: AbstractHybridCoupler

Hybrid coupler (90° or 180° 3dB power splitter/combiner).

A hybrid coupler is a specialized 4-port device that splits power equally
between two ports with a specific phase relationship.

# Fields
- `name::String`: Component identifier
- `n1::Int`: Port 1 (sum) node number
- `n2::Int`: Port 2 (difference/isolated) node number
- `n3::Int`: Port 3 (output 1) node number
- `n4::Int`: Port 4 (output 2) node number
- `phase::Real`: Phase difference in degrees (90 or 180) (default: 90)
- `insertion_loss::Real`: Insertion loss in dB (default: 0.5)
- `isolation::Real`: Isolation between ports in dB (default: 20)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example
```@example
using CircuitTypes
# 90 degree hybrid (quadrature hybrid)
HYB1 = Hybrid("HYB1")

# 180 degree hybrid (rat-race, magic-T)
HYB2 = Hybrid("HYB2", phase=180.0)

# Low-loss 90 degree hybrid
HYB3 = Hybrid("HYB3", insertion_loss=0.2, isolation=30.0)
```
"""
mutable struct Hybrid <: AbstractHybridCoupler
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int
    phase::Real
    insertion_loss::Real
    isolation::Real
    z0::Real

    function Hybrid(name::AbstractString;
        phase::Real=90.0,
        insertion_loss::Real=0.5,
        isolation::Real=20.0,
        z0::Real=50.0)
        (phase == 90.0 || phase == 180.0) || @warn "Hybrid phase is typically 90° or 180°, got $(phase)°"
        insertion_loss >= 0 || throw(ArgumentError("Insertion loss must be non-negative"))
        isolation >= 0 || throw(ArgumentError("Isolation must be non-negative"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, 0, 0, phase, insertion_loss, isolation, z0)
    end
end

function to_qucs_netlist(comp::Hybrid)::String
    parts = ["Hybrid:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "$(qucs_node(comp.n3))")
    push!(parts, "$(qucs_node(comp.n4))")
    push!(parts, "Phi=\"$(format_value(comp.phase))\"")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    push!(parts, "IL=\"$(format_value(comp.insertion_loss)) dB\"")
    push!(parts, "Iso=\"$(format_value(comp.isolation)) dB\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Hybrid)::String
    # SPICE model for hybrid coupler
    # 3dB split with phase relationship
    # S31 = -3dB, S41 = -3dB with phase shift

    mag = 1 / sqrt(2) * 10^(-comp.insertion_loss / 20)  # -3dB with loss
    phase_rad = deg2rad(comp.phase)

    lines = String[]
    push!(lines, "* Hybrid Coupler $(comp.name): $(comp.phase)° phase difference")
    if comp.phase == 90.0
        push!(lines, "* Quadrature (90°) Hybrid")
    elseif comp.phase == 180.0
        push!(lines, "* Rat-Race/Magic-T (180°) Hybrid")
    end
    push!(lines, "* Ports: 1=sum, 2=diff/isolated, 3=out1, 4=out2")
    push!(lines, "B$(comp.name)_3 $(comp.n3) 0 V=V($(comp.n1))*$(mag)")
    push!(lines, "B$(comp.name)_4 $(comp.n4) 0 V=V($(comp.n1))*$(mag)*exp(j*$(phase_rad))")
    push!(lines, "R$(comp.name)_1 $(comp.n1) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_2 $(comp.n2) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_3 $(comp.n3) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_4 $(comp.n4) 0 $(comp.z0)")
    return join(lines, "\n")
end

function _get_node_number(component::Hybrid, pin::Symbol)::Int
    if pin == :n1 || pin == :sum || pin == :port1
        return component.n1
    elseif pin == :n2 || pin == :diff || pin == :isolated || pin == :port2
        return component.n2
    elseif pin == :n3 || pin == :out1 || pin == :port3
        return component.n3
    elseif pin == :n4 || pin == :out2 || pin == :port4
        return component.n4
    else
        error("Invalid pin $pin for Hybrid. Use :n1-:n4 or :sum/:diff/:out1/:out2")
    end
end
