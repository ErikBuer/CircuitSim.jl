"""
DC operating point analysis.
"""

"""
    DCAnalysis(; save_ops=true, temp=26.85, save_all=false)

DC operating point analysis.

Computes the DC operating point of the circuit.

# Parameters
- `save_ops::Bool`: Save operating points of nonlinear devices (default: true)
- `temp::Real`: Simulation temperature in °C (default: 26.85)
- `save_all::Bool`: Save all node voltages and branch currents (default: false)
- `name::String`: Analysis name (default: "DC1")

# Example
```julia
analysis = DCAnalysis()
result = simulate(circuit, analysis)

# With custom temperature
analysis = DCAnalysis(temp=85.0)
```
"""
struct DCAnalysis <: AbstractAnalysis
    name::String
    save_ops::Bool
    temp::Real
    save_all::Bool

    function DCAnalysis(; name::String="DC1", save_ops::Bool=true, temp::Real=26.85, save_all::Bool=false)
        new(name, save_ops, temp, save_all)
    end
end

# =============================================================================
# Qucs Netlist Generation
# =============================================================================

function to_qucs_analysis(a::DCAnalysis)::String
    parts = [".DC:$(a.name)"]
    push!(parts, "saveOPs=\"$(a.save_ops ? "yes" : "no")\"")
    push!(parts, "Temp=\"$(a.temp)\"")
    push!(parts, "saveAll=\"$(a.save_all ? "yes" : "no")\"")
    return join(parts, " ")
end

# =============================================================================
# SPICE Netlist Generation
# =============================================================================

function to_spice_analysis(a::DCAnalysis)::String
    ".op"
end
