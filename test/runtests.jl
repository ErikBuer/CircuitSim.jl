
using Test
using CircuitSim

"""
using Documenter
# Run doctests for CircuitSim.jl

DocMeta.setdocmeta!(CircuitSim, :DocTestSetup, :(using CircuitSim); recursive=true)
Documenter.doctest(CircuitSim)
"""


using GLMakie
include("test_capacitor.jl")
include("test_ac_analysis.jl")
