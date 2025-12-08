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
        size_threshold=500 * 1024,  # 500 KiB threshold (default is 200 KiB)
    ),
    sitename="CircuitSim.jl",
    pages=Any[
        "index.md",
        "Sources"=>[
            "Sources/file_voltage_source.md",
            "Sources/file_current_source.md",
        ],
        "Components"=>[
            "Components/resistor.md",
            "Components/capacitor_q.md",
            "Components/attenuator.md",
            "Components/amplifier.md",
            "Components/voltage_probe.md",
            "Components/current_probe.md",
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