mutable struct BJT <: AbstractBipolarJunctionTransistor
    name::String

    base::Int
    collector::Int
    emitter::Int
    substrate::Int

    Type::String
    Is::Real
    Nf::Real
    Nr::Real
    Ikf::Real
    Ikr::Real
    Vaf::Real
    Var::Real
    Ise::Real
    Ne::Real
    Isc::Real
    Nc::Real
    Bf::Real
    Br::Real
    Rbm::Real
    Irb::Real
    Rc::Real
    Re::Real
    Rb::Real
    Cje::Real
    Vje::Real
    Mje::Real
    Cjc::Real
    Vjc::Real
    Mjc::Real
    Xcjc::Real
    Cjs::Real
    Vjs::Real
    Mjs::Real
    Fc::Real
    Vtf::Real
    Tf::Real
    Xtf::Real
    Itf::Real
    Tr::Real
    Temp::Real
    Kf::Real
    Af::Real
    Ffe::Real
    Kb::Real
    Ab::Real
    Fb::Real
    Ptf::Real
    Xtb::Real
    Xti::Real
    Eg::Real
    Tnom::Real
    Area::Real

    function BJT(name::String;
        Type::String="npn",
        Is::Real=1e-15,
        Nf::Real=1.0,
        Nr::Real=1.0,
        Ikf::Real=0,
        Ikr::Real=0,
        Vaf::Real=0,
        Var::Real=0,
        Ise::Real=0,
        Ne::Real=1.5,
        Isc::Real=0,
        Nc::Real=2.0,
        Bf::Real=100,
        Br::Real=1.0,
        Rbm::Real=0,
        Irb::Real=0,
        Rc::Real=0,
        Re::Real=0,
        Rb::Real=0,
        Cje::Real=0,
        Vje::Real=0.75,
        Mje::Real=0.33,
        Cjc::Real=0,
        Vjc::Real=0.75,
        Mjc::Real=0.33,
        Xcjc::Real=1.0,
        Cjs::Real=0,
        Vjs::Real=0.75,
        Mjs::Real=0.0,
        Fc::Real=0.5,
        Vtf::Real=0,
        Tf::Real=0,
        Xtf::Real=0,
        Itf::Real=0,
        Tr::Real=0,
        Temp::Real=26.85,
        Kf::Real=0,
        Af::Real=1.0,
        Ffe::Real=1.0,
        Kb::Real=0,
        Ab::Real=1.0,
        Fb::Real=1.0,
        Ptf::Real=0,
        Xtb::Real=0,
        Xti::Real=3.0,
        Eg::Real=1.11,
        Tnom::Real=26.85,
        Area::Real=1.0)

        if !(Type in ["npn", "pnp"])
            error("BJT Type must be \"npn\" or \"pnp\", got: $Type")
        end

        new(name, 0, 0, 0, 0, Type, Is, Nf, Nr, Ikf, Ikr, Vaf, Var, Ise, Ne, Isc, Nc,
            Bf, Br, Rbm, Irb, Rc, Re, Rb, Cje, Vje, Mje, Cjc, Vjc, Mjc, Xcjc,
            Cjs, Vjs, Mjs, Fc, Vtf, Tf, Xtf, Itf, Tr, Temp, Kf, Af, Ffe, Kb, Ab, Fb,
            Ptf, Xtb, Xti, Eg, Tnom, Area)
    end
end

function get_nodes(bjt::BJT)
    return [bjt.base, bjt.collector, bjt.emitter, bjt.substrate]
end

function connect!(bjt::BJT, base::Int, collector::Int, emitter::Int, substrate::Int)
    bjt.base = base
    bjt.collector = collector
    bjt.emitter = emitter
    bjt.substrate = substrate
end

function to_qucs_netlist(bjt::BJT)::String
    props = String[]

    push!(props, "Type=\"$(bjt.Type)\"")
    push!(props, "Is=\"$(bjt.Is)\"")
    push!(props, "Nf=\"$(bjt.Nf)\"")
    push!(props, "Nr=\"$(bjt.Nr)\"")
    push!(props, "Ikf=\"$(bjt.Ikf)\"")
    push!(props, "Ikr=\"$(bjt.Ikr)\"")
    push!(props, "Vaf=\"$(bjt.Vaf)\"")
    push!(props, "Var=\"$(bjt.Var)\"")
    push!(props, "Ise=\"$(bjt.Ise)\"")
    push!(props, "Ne=\"$(bjt.Ne)\"")
    push!(props, "Isc=\"$(bjt.Isc)\"")
    push!(props, "Nc=\"$(bjt.Nc)\"")
    push!(props, "Bf=\"$(bjt.Bf)\"")
    push!(props, "Br=\"$(bjt.Br)\"")
    push!(props, "Rbm=\"$(bjt.Rbm)\"")
    push!(props, "Irb=\"$(bjt.Irb)\"")
    push!(props, "Rc=\"$(bjt.Rc)\"")
    push!(props, "Re=\"$(bjt.Re)\"")
    push!(props, "Rb=\"$(bjt.Rb)\"")
    push!(props, "Cje=\"$(bjt.Cje)\"")
    push!(props, "Vje=\"$(bjt.Vje)\"")
    push!(props, "Mje=\"$(bjt.Mje)\"")
    push!(props, "Cjc=\"$(bjt.Cjc)\"")
    push!(props, "Vjc=\"$(bjt.Vjc)\"")
    push!(props, "Mjc=\"$(bjt.Mjc)\"")
    push!(props, "Xcjc=\"$(bjt.Xcjc)\"")
    push!(props, "Cjs=\"$(bjt.Cjs)\"")
    push!(props, "Vjs=\"$(bjt.Vjs)\"")
    push!(props, "Mjs=\"$(bjt.Mjs)\"")
    push!(props, "Fc=\"$(bjt.Fc)\"")
    push!(props, "Vtf=\"$(bjt.Vtf)\"")
    push!(props, "Tf=\"$(bjt.Tf)\"")
    push!(props, "Xtf=\"$(bjt.Xtf)\"")
    push!(props, "Itf=\"$(bjt.Itf)\"")
    push!(props, "Tr=\"$(bjt.Tr)\"")
    push!(props, "Temp=\"$(bjt.Temp)\"")
    push!(props, "Kf=\"$(bjt.Kf)\"")
    push!(props, "Af=\"$(bjt.Af)\"")
    push!(props, "Ffe=\"$(bjt.Ffe)\"")
    push!(props, "Kb=\"$(bjt.Kb)\"")
    push!(props, "Ab=\"$(bjt.Ab)\"")
    push!(props, "Fb=\"$(bjt.Fb)\"")
    push!(props, "Ptf=\"$(bjt.Ptf)\"")
    push!(props, "Xtb=\"$(bjt.Xtb)\"")
    push!(props, "Xti=\"$(bjt.Xti)\"")
    push!(props, "Eg=\"$(bjt.Eg)\"")
    push!(props, "Tnom=\"$(bjt.Tnom)\"")
    push!(props, "Area=\"$(bjt.Area)\"")

    props_str = join(props, " ")
    return "BJT:$(bjt.name) $(bjt.base) $(bjt.collector) $(bjt.emitter) $(bjt.substrate) $props_str"
end
