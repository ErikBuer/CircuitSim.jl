using CircuitTypes

# Check if qucsator_rf is installed
println("Checking for qucsator_rf installation...")
is_installed, version, path = check_qucsator()

if is_installed
    println("✓ qucsator_rf found!")
    println("  Version: $version")
    println("  Path: $path")
else
    println("✗ qucsator_rf not found in PATH")
    println("  Please install Qucs-RFlayout to run simulations")
    exit(1)
end

println("\n" * "="^60)
println("Building Simple DC Circuit (Voltage Divider)...")
println("="^60)

# Build a simple voltage divider circuit for DC analysis
# V1 -> R1 -> node1 -> R2 -> GND
c = Circuit()

V1 = DCVoltageSource("V1", 10.0)  # 10V DC source
R1 = Resistor("R1", 1e3)          # 1k ohm
R2 = Resistor("R2", 1e3)          # 1k ohm
G = Ground("GND")

add_component!(c, V1)
add_component!(c, R1)
add_component!(c, R2)
add_component!(c, G)

# Connect: V1+ -> R1 -> R2 -> V1- (GND)
@connect c V1.nplus R1.n1      # V1+ to R1
@connect c R1.n2 R2.n1         # R1 to R2 (middle node - voltage divider output)
@connect c R2.n2 V1.nminus     # R2 to V1-
@connect c V1.nminus G.n       # V1- to ground

println("\n" * "="^60)
println("Generated Qucs Netlist:")
println("="^60)
netlist = netlist_qucs(c)
println(netlist)

println("\n" * "="^60)
println("Running DC Simulation with qucsator_rf...")
println("="^60)

# Define DC analysis command
# Qucs format: .DC:InstanceName [properties]
# saveOPs="yes" saves operating point values (node voltages, branch currents)
analysis = [".DC:DC1 saveOPs=\"yes\""]

# Run the simulation using the high-level API
println("\nExecuting simulation...")
result = simulate_qucsator(c, analysis)

# Print results
println("\n" * "="^60)
println("Simulation Results:")
println("="^60)

if has_errors(result)
    println("❌ Simulation encountered errors:")
    for err in result.dataset.errors
        println("  - $err")
    end
    println("\nRaw output:")
    println(result.dataset.raw_output)
else
    print_summary(result)

    # =========================================================================
    # Access results by component pin
    # =========================================================================
    println("\n" * "="^60)
    println("Accessing Results by Component Pin:")
    println("="^60)

    # Get voltage at specific component pins
    v_supply = voltage(result, V1, :nplus)
    v_mid = voltage(result, R1, :n2)      # Same as R2.n1 - the divider output
    v_gnd = voltage(result, G, :n)

    println("\nVoltages at pins:")
    println("  voltage(result, V1, :nplus) = $v_supply V  (supply)")
    println("  voltage(result, R1, :n2)    = $v_mid V  (divider midpoint)")
    println("  voltage(result, G, :n)      = $v_gnd V  (ground)")

    # Get current through voltage source
    i_source = current(result, V1)
    println("\nCurrent through voltage source:")
    println("  current(result, V1) = $(i_source * 1000) mA")

    # =========================================================================
    # voltage_between: Measure voltage between ANY two pins
    # =========================================================================
    println("\n" * "-"^40)
    println("Voltage Between Pins (flexible measurement):")
    println("-"^40)

    # Voltage across R1 (from n1 to n2)
    v_r1 = voltage_between(result, Pin(R1, :n1), Pin(R1, :n2))
    println("  voltage_between(Pin(R1,:n1), Pin(R1,:n2)) = $v_r1 V")

    # Voltage across R2
    v_r2 = voltage_between(result, Pin(R2, :n1), Pin(R2, :n2))
    println("  voltage_between(Pin(R2,:n1), Pin(R2,:n2)) = $v_r2 V")

    # Voltage from supply to ground
    v_total = voltage_between(result, Pin(V1, :nplus), Pin(G, :n))
    println("  voltage_between(Pin(V1,:nplus), Pin(G,:n)) = $v_total V")

    # Can also use Pin for single voltage measurement
    v_mid_pin = voltage(result, Pin(R1, :n2))
    println("  voltage(result, Pin(R1,:n2)) = $v_mid_pin V")

    # Verify results
    println("\n" * "-"^40)
    println("Verification:")
    println("-"^40)

    expected_v_mid = 5.0  # 10V * 1k/(1k+1k)
    expected_i = -0.005   # 10V / 2k = 5mA (negative = into V1+)

    all_pass = true

    if abs(v_mid - expected_v_mid) < 0.001
        println("✓ Midpoint voltage correct: $v_mid V (expected $expected_v_mid V)")
    else
        println("✗ Midpoint voltage incorrect: $v_mid V (expected $expected_v_mid V)")
        all_pass = false
    end

    if abs(i_source - expected_i) < 0.0001
        println("✓ Source current correct: $(i_source*1000) mA (expected $(expected_i*1000) mA)")
    else
        println("✗ Source current incorrect: $(i_source*1000) mA (expected $(expected_i*1000) mA)")
        all_pass = false
    end

    if abs(v_r1 - 5.0) < 0.001 && abs(v_r2 - 5.0) < 0.001
        println("✓ Voltage drops correct: V_R1=$v_r1 V, V_R2=$v_r2 V (expected 5V each)")
    else
        println("✗ Voltage drops incorrect")
        all_pass = false
    end

    if all_pass
        println("\n🎉 All tests passed!")
    end
end

println("\n" * "="^60)
println("Demonstration completed!")
println("="^60)
