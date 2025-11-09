using CircuitTypes

# A helper function to create a small example circuit (RLC series)
function example_series_rlc()
    c = Circuit()
    r = Resistor("1", 1e3)
    l = Inductor("1", 1e-3)
    cc = Capacitor("1", 1e-9)
    v = DCVoltageSource("1", 5.0)
    g = Ground("GND")
    add_component!(c, r)
    add_component!(c, l)
    add_component!(c, cc)
    add_component!(c, v)
    add_component!(c, g)
    # connect using the high-level API:
    # nodes: v.+ -> r.n1, r.n2 -> l.n1, l.n2 -> c.n1, c.n2 -> v.-, and ground
    connect!(c, Pin(v, :nplus), Pin(r, :n1))
    connect!(c, Pin(r, :n2), Pin(l, :n1))
    connect!(c, Pin(l, :n2), Pin(cc, :n1))
    connect!(c, Pin(cc, :n2), Pin(v, :nminus))
    # tie v.nminus to ground
    connect!(c, Pin(v, :nminus), Pin(g, :n))
    return c
end
