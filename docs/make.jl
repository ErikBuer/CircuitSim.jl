push!(LOAD_PATH, "../src/")

using Documenter

# Running `julia --project docs/make.jl` can be very slow locally.
# To speed it up during development, one can use make_local.jl instead.
# The code below checks wether its being called from make_local.jl or not.
const LOCAL = get(ENV, "LOCAL", "false") == "true"

if LOCAL
    include("../src/CircuitTypes.jl")
    using .CircuitTypes
else
    using CircuitTypes
    ENV["GKSwstype"] = "100"
end

DocMeta.setdocmeta!(CircuitTypes, :DocTestSetup, :(using CircuitTypes); recursive=true)


makedocs(
    modules=[CircuitTypes],
    format=Documenter.HTML(
        size_threshold=500 * 1024,  # 500 KiB threshold (default is 200 KiB)
    ),
    sitename="CircuitTypes.jl",
    pages=Any[
        "index.md",
        "api_reference.md",
    ],
    doctest=true,
)

deploydocs(
    repo="github.com/ErikBuer/CircuitTypes.jl.git",
    push_preview=true,
)