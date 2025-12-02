"""
Power Source component for S-parameter simulation.

In Qucs, this is the "Pac" component - a power source with a specific
internal impedance used as a port for S-parameter analysis.
"""

"""
    PowerSource <: AbstractPowerSource

Power source for S-parameter simulation (Qucs "Pac" component).

This component represents a port for S-parameter analysis with a specified
reference impedance. It injects power into the circuit and measures the
reflected/transmitted waves.

# Fields
- `name::String`: Component identifier
- `nplus::Int`: Positive terminal node number
- `nminus::Int`: Negative terminal node number  
- `num::Int`: Port number (1, 2, 3, ... for multi-port S-parameter analysis)
- `z0::Real`: Reference impedance in Ohms (default: 50.0)
- `power::Real`: Available power in dBm (default: 0 dBm = 1mW)
- `freq::Real`: Frequency in Hz (optional, for single-frequency analysis)

# Example
```julia
# Port 1 with 50Ω reference impedance
P1 = PowerSource("P1", 1)

# Port 2 with 75Ω reference impedance
P2 = PowerSource("P2", 2, z0=75.0)

# Port with specific power level
P3 = PowerSource("P3", 1, power=-10.0)  # -10 dBm
```
"""
mutable struct PowerSource <: AbstractPowerSource
    name::String
    nplus::Int
    nminus::Int
    num::Int        # Port number
    z0::Real        # Reference impedance (Ohms)
    power::Real     # Power in dBm
    freq::Real      # Frequency in Hz (0 = use analysis frequency)

    function PowerSource(name::AbstractString, num::Int;
        z0::Real=50.0,
        power::Real=0.0,
        freq::Real=0.0)
        num >= 1 || throw(ArgumentError("Port number must be >= 1"))
        z0 > 0 || throw(ArgumentError("Reference impedance must be positive"))
        new(String(name), 0, 0, num, z0, power, freq)
    end
end

function to_qucs_netlist(comp::PowerSource)::String
    parts = ["Pac:$(comp.name)"]
    push!(parts, "$(qucs_node(comp.nplus))")
    push!(parts, "$(qucs_node(comp.nminus))")
    push!(parts, "Num=\"$(comp.num)\"")
    push!(parts, "Z=\"$(format_value(comp.z0))\"")
    push!(parts, "P=\"$(format_value(comp.power)) dBm\"")
    if comp.freq > 0
        push!(parts, "f=\"$(format_value(comp.freq))\"")
    end
    return join(parts, " ")
end

function to_spice_netlist(comp::PowerSource)::String
    # SPICE doesn't have a direct equivalent - use a voltage source with internal resistance
    # V = sqrt(8 * Z0 * P) where P is in Watts
    # For S-parameter analysis in ngspice, typically use .PORT directive
    power_watts = 10^((comp.power - 30) / 10)  # Convert dBm to Watts
    v_rms = sqrt(comp.z0 * power_watts)  # RMS voltage for matched load

    # Create a Thevenin equivalent: voltage source in series with Z0
    lines = String[]
    push!(lines, "* Power Source $(comp.name) - Port $(comp.num)")
    push!(lines, "V$(comp.name) $(comp.nplus)_int $(comp.nminus) AC $(2*v_rms) 0")
    push!(lines, "R$(comp.name)_z0 $(comp.nplus)_int $(comp.nplus) $(comp.z0)")
    return join(lines, "\n")
end

function _get_node_number(component::PowerSource, pin::Symbol)::Int
    if pin == :nplus
        return component.nplus
    elseif pin == :nminus
        return component.nminus
    else
        error("Invalid pin $pin for PowerSource. Use :nplus or :nminus")
    end
end
