mutable struct TunnelDiode <: AbstractTunnelDiode
    name::String

    cathode::Int
    anode::Int

    # Required properties
    Ip::Real    # Peak current
    Iv::Real    # Valley current
    Vv::Real    # Valley voltage
    Cj0::Real   # Zero-bias junction capacitance
    M::Real     # Grading coefficient
    Vj::Real    # Junction potential

    # Optional properties
    Wr::Real    # Resonance energy
    eta::Real   # Eta parameter
    dW::Real    # Delta W
    Tmax::Real  # Maximum temperature
    de::Real    # Electron density
    dv::Real    # Valley density
    nv::Real    # Valley index
    te::Real    # Electron temperature
    Temp::Real  # Simulation temperature
    Area::Real  # Area scaling factor

    function TunnelDiode(name::String;
        Ip::Real=4.0e-3,
        Iv::Real=0.6e-3,
        Vv::Real=0.8,
        Cj0::Real=80e-15,
        M::Real=0.5,
        Vj::Real=0.5,
        Wr::Real=2.83e-20,
        eta::Real=1.73,
        dW::Real=0.3e-3,
        Tmax::Real=1.05e-10,
        de::Real=0.9,
        dv::Real=2.0,
        nv::Real=16.0,
        te::Real=0.5e-12,
        Temp::Real=26.85,
        Area::Real=1.0
    )
        new(name, 0, 0, Ip, Iv, Vv, Cj0, M, Vj, Wr, eta, dW, Tmax, de, dv, nv, te, Temp, Area)
    end
end

const RTD = TunnelDiode

function to_qucs_netlist(d::TunnelDiode)::String
    parts = ["RTD:$(d.name)"]

    # Nodes (cathode first, then anode)
    push!(parts, qucs_node(d.cathode))
    push!(parts, qucs_node(d.anode))

    # Required properties
    push!(parts, "Ip=\"$(format_value(d.Ip))\"")
    push!(parts, "Iv=\"$(format_value(d.Iv))\"")
    push!(parts, "Vv=\"$(d.Vv)\"")
    push!(parts, "Cj0=\"$(format_value(d.Cj0))\"")
    push!(parts, "M=\"$(d.M)\"")
    push!(parts, "Vj=\"$(d.Vj)\"")

    # Optional properties (include only if non-default)
    d.Wr != 2.83e-20 && push!(parts, "Wr=\"$(format_value(d.Wr))\"")
    d.eta != 1.73 && push!(parts, "eta=\"$(d.eta)\"")
    d.dW != 0.3e-3 && push!(parts, "dW=\"$(format_value(d.dW))\"")
    d.Tmax != 1.05e-10 && push!(parts, "Tmax=\"$(format_value(d.Tmax))\"")
    d.de != 0.9 && push!(parts, "de=\"$(d.de)\"")
    d.dv != 2.0 && push!(parts, "dv=\"$(d.dv)\"")
    d.nv != 16.0 && push!(parts, "nv=\"$(d.nv)\"")
    d.te != 0.5e-12 && push!(parts, "te=\"$(format_value(d.te))\"")
    d.Temp != 26.85 && push!(parts, "Temp=\"$(d.Temp)\"")
    d.Area != 1.0 && push!(parts, "Area=\"$(d.Area)\"")

    return join(parts, " ")
end
