"""
using Test
using Documenter
using CircuitSim

# Run doctests for CircuitSim.jl

DocMeta.setdocmeta!(CircuitSim, :DocTestSetup, :(using CircuitSim); recursive=true)
Documenter.doctest(CircuitSim)
"""