"""
    Coupler <: AbstractCoupler

Directional coupler (4-port device).

A directional coupler splits power with specified coupling factor.
Ports: 1=input, 2=through, 3=coupled, 4=isolated

# Fields
- `name::String`: Component identifier
- `n1::Int`: Port 1 (input) node number
- `n2::Int`: Port 2 (through) node number
- `n3::Int`: Port 3 (coupled) node number
- `n4::Int`: Port 4 (isolated) node number
- `coupling::Real`: Coupling factor in dB (e.g., 3 for 3dB coupler, 10 for 10dB coupler)
- `isolation::Real`: Isolation in dB (default: 20)
- `insertion_loss::Real`: Insertion loss (through path) in dB (default: 0.5)
- `z0::Real`: Reference impedance in Ohms (default: 50)

# Example
```@example
using CircuitTypes
# 3 dB (50/50) directional coupler
DC1 = Coupler("DC1", 3.0)

# 10 dB directional coupler (10% coupling)
DC2 = Coupler("DC2", 10.0)

# 20 dB directional coupler with high isolation
DC3 = Coupler("DC3", 20.0, isolation=30.0)
```
"""
mutable struct Coupler <: AbstractCoupler
    name::String
    n1::Int
    n2::Int
    n3::Int
    n4::Int
    coupling::Real
    isolation::Real
    insertion_loss::Real
    z0::Real

    function Coupler(name::AbstractString, coupling::Real;
        isolation::Real=20.0,
        insertion_loss::Real=0.5,
        z0::Real=50.0)
        coupling >= 0 || throw(ArgumentError("Coupling must be non-negative"))
        isolation >= 0 || throw(ArgumentError("Isolation must be non-negative"))
        insertion_loss >= 0 || throw(ArgumentError("Insertion loss must be non-negative"))
        z0 > 0 || throw(ArgumentError("Impedance must be positive"))
        new(String(name), 0, 0, 0, 0, coupling, isolation, insertion_loss, z0)
    end
end

function to_qucs_netlist(comp::Coupler)::String
    parts = ["Coupler:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.n1))")
    push!(parts, "$(qucs_node(comp.n2))")
    push!(parts, "$(qucs_node(comp.n3))")
    push!(parts, "$(qucs_node(comp.n4))")
    push!(parts, "k=\"$(format_value(comp.coupling)) dB\"")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    push!(parts, "Iso=\"$(format_value(comp.isolation)) dB\"")
    push!(parts, "IL=\"$(format_value(comp.insertion_loss)) dB\"")
    return join(parts, " ")
end

function to_spice_netlist(comp::Coupler)::String
    # SPICE model using controlled sources
    # Power split: coupled port gets -coupling dB, through port gets remainder
    # For a lossless coupler: |S21|^2 + |S31|^2 = 1
    # Through port: sqrt(1 - 10^(-coupling/10)) - insertion_loss
    # Coupled port: 10^(-coupling/20)

    coupled_factor = 10^(-comp.coupling / 20)  # Voltage ratio
    through_power = 1 - 10^(-comp.coupling / 10)  # Power ratio
    through_factor = sqrt(through_power) * 10^(-comp.insertion_loss / 20)

    lines = String[]
    push!(lines, "* Directional Coupler $(comp.name): $(comp.coupling)dB coupling")
    push!(lines, "* Port 1=input, 2=through, 3=coupled, 4=isolated")
    push!(lines, "B$(comp.name)_thru $(comp.n2) 0 V=V($(comp.n1))*$(through_factor)")
    push!(lines, "B$(comp.name)_coup $(comp.n3) 0 V=V($(comp.n1))*$(coupled_factor)")
    push!(lines, "R$(comp.name)_1 $(comp.n1) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_2 $(comp.n2) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_3 $(comp.n3) 0 $(comp.z0)")
    push!(lines, "R$(comp.name)_4 $(comp.n4) 0 $(comp.z0)")
    return join(lines, "\n")
end

function _get_node_number(component::Coupler, pin::Symbol)::Int
    if pin == :n1 || pin == :input || pin == :port1
        return component.n1
    elseif pin == :n2 || pin == :through || pin == :port2
        return component.n2
    elseif pin == :n3 || pin == :coupled || pin == :port3
        return component.n3
    elseif pin == :n4 || pin == :isolated || pin == :port4
        return component.n4
    else
        error("Invalid pin $pin for Coupler. Use :n1-:n4 or :input/:through/:coupled/:isolated")
    end
end
