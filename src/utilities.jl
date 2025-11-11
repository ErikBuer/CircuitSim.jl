"""
Simple formatting helper for numeric values
"""
format_value(v::Real) = sprint(x -> begin
    show(x, v)
end)
