# Substrate

```@example substrate
using CircuitSim

fr4 = Substrate("FR4", er=4.5, h=1.6e-3, t=35e-6, tand=0.02)
ro4003c = Substrate("RO4003C", er=3.55, h=0.508e-3, t=17e-6, tand=0.0027)
duroid = Substrate("Duroid", er=2.2, h=0.787e-3, t=35e-6, tand=0.0009)

println("Common substrate materials:")
println("\nFR4:")
println("  εr = ", fr4.er)
println("  h = ", fr4.h*1e3, " mm")
println("  t = ", fr4.t*1e6, " μm")
println("  tanδ = ", fr4.tand)

println("\nRogers RO4003C:")
println("  εr = ", ro4003c.er)
println("  h = ", ro4003c.h*1e3, " mm")
println("  t = ", ro4003c.t*1e6, " μm")
println("  tanδ = ", ro4003c.tand)

println("\nRogers Duroid:")
println("  εr = ", duroid.er)
println("  h = ", duroid.h*1e3, " mm")
println("  t = ", duroid.t*1e6, " μm")
println("  tanδ = ", duroid.tand)
```