push!(LOAD_PATH, "../src/")

using Documenter

# Running `julia --project docs/make.jl` can be very slow locally.
# To speed it up during development, one can use make_local.jl instead.
# The code below checks wether its being called from make_local.jl or not.
const LOCAL = get(ENV, "LOCAL", "false") == "true"

if LOCAL
    include("../src/CircuitSim.jl")
    using .CircuitSim
else
    using CircuitSim
    ENV["GKSwstype"] = "100"
end

DocMeta.setdocmeta!(CircuitSim, :DocTestSetup, :(using CircuitSim); recursive=true)


makedocs(
    modules=[CircuitSim],
    format=Documenter.HTML(
        size_threshold=600 * 1024,  # 600 KiB threshold (increased for source examples)
    ),
    sitename="CircuitSim.jl",
    pages=Any[
        "index.md",
        "Sources"=>[
            "Sources/file_voltage_source.md",
            "Sources/file_current_source.md",
            "Sources/voltage_pulse_source.md",
            "Sources/current_pulse_source.md",
            "Sources/voltage_rectangular_source.md",
            "Sources/current_rectangular_source.md",
            "Sources/voltage_exponential_source.md",
            "Sources/current_exponential_source.md",
            "Sources/voltage_noise_source.md",
            "Sources/current_noise_source.md",
            "Sources/current_controlled_current_source.md",
            "Sources/current_controlled_voltage_source.md",
            "Sources/voltage_controlled_current_source.md",
            "Sources/voltage_controlled_voltage_source.md",
            "Sources/voltage_am_source.md",
            "Sources/voltage_pm_source.md",
            "Sources/current_current_noise_source.md",
            "Sources/current_voltage_noise_source.md",
            "Sources/voltage_voltage_noise_source.md",
        ],
        "Components"=>[
            "Components/resistor.md",
            "Components/capacitor.md",
            "Components/capacitor_q.md",
            "Components/inductor.md",
            "Components/inductor_q.md",
            "Components/ground.md",
            "Components/open.md",
            "Components/substrate.md",
            "Components/bond_wire.md",
            "Components/bias_tee.md",
            "Components/dc_block.md",
            "Components/dc_feed.md",
            "Components/attenuator.md",
            "Components/amplifier.md",
            "Components/opamp.md",
            "Components/phase_shifter.md",
            "Components/circulator.md",
            "Components/isolator.md",
            "Components/coupler.md",
            "Components/hybrid.md",
            "Components/gyrator.md",
            "Components/spiral_inductor.md",
            "Components/circular_loop.md",
            "Components/transmission_line.md",
            "Components/coaxial_line.md",
            "Components/ideal_transformer.md",
            "Components/mutual_inductor.md",
            "Components/spfile.md",
            "Components/microstrip_line.md",
            "Components/microstrip_gap.md",
            "Components/microstrip_step.md",
            "Components/microstrip_corner.md",
            "Components/microstrip_coupled.md",
            "Components/microstrip_cross.md",
            "Components/microstrip_tee.md",
            "Components/microstrip_open.md",
            "Components/microstrip_via.md",
            "Components/microstrip_radial_stub.md",
            "Components/microstrip_mitered_bend.md",
            "Components/microstrip_lange.md",
            "Components/voltage_probe.md",
            "Components/current_probe.md",
            "Components/power_probe.md",
        ],
        "Devices"=>[
            "Devices/diode.md",
            "Devices/tunnel_diode.md",
            "Devices/jfet.md",
            "Devices/diac.md",
            "Devices/mosfet.md",
            "Devices/thyristor.md",
            "Devices/triac.md",
            "Devices/bjt.md",
            "Devices/equation_defined.md",
        ],
        "Examples"=>[
            "Examples/lowpass_filter.md",
            "Examples/dc_divider.md",
            "Examples/ac_divider.md",
            "Examples/pin_current.md",
        ],
        "api_reference.md",
    ],
    doctest=true,
)

deploydocs(
    repo="github.com/ErikBuer/CircuitSim.jl.git",
    push_preview=true,
)