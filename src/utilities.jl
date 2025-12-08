"""
Simple formatting helper for numeric values
"""
format_value(v::Real) = sprint(x -> begin
    show(x, v)
end)

using StaticArrays

"""
    s2z(S::Matrix, z0=50.0) -> Matrix

Convert S-parameter matrix to Z-parameter matrix for a two-port network.

# Arguments

- `S`: 2x2 S-parameter matrix
- `z0`: Reference impedance (default: 50.0 Ω)

# Returns

- 2x2 Z-parameter matrix

# Note

This conversion uses the standard formula Z = z0*(I+S)*(I-S)⁻¹.
For certain ideal passive networks (e.g., perfect series elements at DC),
the matrix (I-S) becomes singular, making Z-parameters undefined.
This is a fundamental limitation of the parameter representation, not a
numerical issue.

# Examples

```jldoctest
julia> using CircuitTypes

julia> z_load = 75.0 + 0.0im;  # 75 Ω resistive load

julia> z0 = 50.0;

julia> gamma = (z_load - z0) / (z_load + z0);  # Reflection coefficient

julia> S = [gamma 0.0; 0.0 0.0];  # One-port (shunt load)

julia> Z = s2z(S, z0);

julia> abs(Z[1,1] - z_load) < 1e-10  # Verify Z11 matches load impedance
true
```
"""
function s2z(S::AbstractMatrix, z0=50.0)
    # Identity matrix
    I = @SMatrix [1.0 0.0; 0.0 1.0]

    # Convert S to SMatrix if needed
    S_static = S isa SMatrix ? S : SMatrix{2,2}(S)

    # Z = z0 * (I + S) * inv(I - S)
    Z = z0 * (I + S_static) * inv(I - S_static)

    return Z
end

"""
    s2z_series(S::Matrix, z0=50.0) -> ComplexF64

Extract series impedance from S-parameter matrix for a symmetric two-port network.

This function uses the S→ABCD conversion approach, which is more robust for
series elements than the direct Z-parameter conversion. For a series element,
the impedance is the B parameter of the ABCD matrix.

# Arguments

- `S`: 2x2 S-parameter matrix
- `z0`: Reference impedance (default: 50.0 Ω)

# Returns

- Series impedance (complex number)

# Note

For a perfect open circuit (S21 = 0), this function returns Inf+0im,
representing infinite impedance. This avoids singularity issues that occur
with direct Z-parameter conversion for open circuits.

# Examples

```jldoctest
julia> using CircuitTypes

julia> z0 = 50.0;

julia> z_series = 0.0 - 100.0im;  # 100 Ω capacitive reactance

julia> A, B, C, D = 1.0+0.0im, z_series, 0.0+0.0im, 1.0+0.0im;  # ABCD for series element

julia> denom = A + B/z0 + C*z0 + D;

julia> s11 = (A + B/z0 - C*z0 - D) / denom;

julia> s21 = 2.0 / denom;

julia> S = [s11 s21; s21 s11];  # Symmetric

julia> z_extracted = s2z_series(S, z0);

julia> abs(z_extracted - z_series) < 1e-10  # Verify extracted impedance matches original
true
```
"""
function s2z_series(S::AbstractMatrix, z0=50.0)::ComplexF64
    # Use S-parameter to ABCD conversion for robustness
    # For a series element: A=1, B=Z_series, C=0, D=1
    # The series impedance is the B parameter

    s11, s12, s21, s22 = S[1, 1], S[1, 2], S[2, 1], S[2, 2]

    # Handle perfect open circuit (S21 = 0)
    if abs(s21) < 1e-15
        return complex(Inf, 0.0)
    end

    # S to ABCD conversion:
    # B = z0 * ((1+S11)*(1+S22) - S12*S21) / (2*S21)
    B = z0 * ((1 + s11) * (1 + s22) - s12 * s21) / (2 * s21)

    return B
end

