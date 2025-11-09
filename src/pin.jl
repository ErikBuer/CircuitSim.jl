"""
Pin representation: (component, fieldname)
"""
mutable struct Pin
    comp::Any
    field::Symbol
end

pin(comp::Any, field::Symbol) = Pin(comp, field)

"""
unique pin id used in union-find:
```julia
hash( (objectid(comp), field) )
```
"""
pinid(p::Pin) = hash((objectid(p.comp), p.field))