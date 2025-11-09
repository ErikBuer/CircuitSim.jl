using CircuitTypes

# build circuit
c = Circuit()
R1 = Resistor("R1", 1e3)
L1 = Inductor("L1", 1e-3)
C1 = Capacitor("C1", 1e-9)
V1 = DCVoltageSource("V1", 5.0)
G = Ground("GND")

add_component!(c, R1)
add_component!(c, L1)
add_component!(c, C1)
add_component!(c, V1)
add_component!(c, G)

# connect with the macro (dot-syntax)
@connect c V1.nplus R1.n1
@connect c R1.n2 L1.n1
@connect c L1.n2 C1.n1
@connect c C1.n2 V1.nminus
@connect c V1.nminus G.n

println(netlist_qucs(c))