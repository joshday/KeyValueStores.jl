module KeyValueStores

using OrderedCollections

export Store, DefaultStore

#-----------------------------------------------------------------------------# AbstractStore
abstract type AbstractStore{T} <: AbstractDict{Symbol, T} end

dict(o::AbstractStore) = getfield(o, :dict)

# functions that pass through to dict
for f in (:length, :keys, :values, :iterate, :getindex, :setindex!, :get, :get!, :pop!)
    @eval Base.$f(o::AbstractStore, x...) = $f(dict(o), x...)
end

Base.empty!(o::AbstractStore) = (empty!(dict(o)); o)
Base.push!(o::AbstractStore{T}, x::Pair{Symbol, T}) where {T} = (push!(dict(o), x); o)
Base.copy(o::T) where {T <: AbstractStore} = T(copy(dict(o)), (getfield(o, x) for x in setdiff(fieldnames(T), (:dict,)))...)
Base.merge(o::AbstractStore{T}, x::AbstractDict{Symbol, T}) where {T} = (merge!(copy(o), x); o)
Base.merge!(o::AbstractStore{T}, x::AbstractDict{Symbol, T}) where {T} = (merge!(dict(o), x); o)

# properties map to keys
Base.propertynames(o::AbstractStore) = keys(o)
Base.getproperty(o::AbstractStore, x::Symbol) = getindex(o, x)
Base.setproperty!(o::AbstractStore, x::Symbol, v) = setindex!(o, v, x)


#-----------------------------------------------------------------------------# Store
struct Store{T, D <: AbstractDict{Symbol, T}} <: AbstractStore{T}
    dict::D
end
Store(T::Type = OrderedDict{Symbol, Any}; kw...) = Store(T(kw))

#-----------------------------------------------------------------------------# DefaultStore
struct DefaultStore{T, D <: AbstractDict{Symbol, T}, R} <: AbstractStore{Union{T, R}}
    dict::D
    default::R
    DefaultStore(dict::D, default::R=nothing) where {T, D <: AbstractDict{Symbol, T}, R} = new{T, D, R}(dict, default)
    DefaultStore{T,D,R}(dict, default) where {T,D,R} = new{T,D,R}(dict, default)
end
DefaultStore(T::Type = OrderedDict{Symbol, Any}, default=nothing; kw...) = DefaultStore(T(kw), nothing)
Base.getindex(o::DefaultStore, k::Symbol) = get(dict(o), k, getfield(o, :default))

# #-----------------------------------------------------------------------------# defaults
# struct NoDefault end
# Base.show(io::IO, o::NoDefault) = print(io, "NoDefault")

# struct Nested
#     path::Vector{Symbol}
# end
# Nested() = Nested(Symbol[])
# Base.show(io::IO, o::Nested) = print(io, "Nested")

# #-----------------------------------------------------------------------------# references
# struct NoRef end
# Base.show(io::IO, o::NoRef) = print(io, "NoRef")
# check_key(default, ::NoRef, ::Symbol) = true
# check_value(default, ::NoRef, ::Symbol, ::Any) = true





# #-----------------------------------------------------------------------------# Store
# struct Store{T, D <: AbstractDict{Symbol, T}, R, S} <: AbstractDict{Symbol, T}
#     dict::D
#     default::S
#     ref::R

#     function Store(dict::D, default::S = NoDefault(), ref::R = NoRef()) where {T, D <: AbstractDict{Symbol, T}, R, S}
#         new{T, D, R, S}(dict, default, ref)
#     end
# end

# Store(T::Type = Dict{Symbol, Any}, default=NoDefault(), ref=NoRef(); kw...) = Store(T(kw), default, ref)

# dict(o::Store) = getfield(o, :dict)
# default(o::Store) = getfield(o, :default)
# ref(o::Store) = getfield(o, :ref)

# check_key(o::Store, k::Symbol) = check_key(default(o), ref(o), k)
# check_value(o::Store, k::Symbol, v::Any) = check_key(default(o), ref(o), v, k)

# function Base.summary(io::IO, o::Store{T}) where T
#     print(io, styled"Store({bright_cyan:$(default(o)), $(ref(o)), $T})")
# end

# #-----------------------------------------------------------------------------#
# for f in (:length, :keys, :values, :get, :iterate)
#     @eval Base.$f(o::Store, x...) = $f(dict(o), x...)
# end

# #-----------------------------------------------------------------------------# getindex
# function Base.getindex(o::Store{T,D,R,S}, k::Symbol) where {T,D,R,S}
#     check_key(o, k) || throw(ArgumentError("Store with `ref::$R` does not allow key :$k"))
#     dict(o)[k]
# end

# #-----------------------------------------------------------------------------# setindex!
# function Base.setindex!(o::Store{T,D,R,S}, v, k::Symbol) where {T,D,R,S}
#     check_key(o, k) || throw(ArgumentError("Store with `ref::$R` does not allow key :$k"))
#     check_value(o, k, v) || throw(ArgumentError("Store with `ref::$R` does not allow value $v for key :$k"))
#     setindex!(dict(o), v, k)
# end
# function Base.get!(o::Store{T,D,R,S}, k::Symbol, default) where {T,D,R,S}
#     check_key(o, k) || throw(ArgumentError("Store with `ref::$R` does not allow key :$k"))
#     haskey(o, k) ? o[k] : default
# end

# #-----------------------------------------------------------------------------# properties
# Base.propertynames(o::Store) = keys(o)
# Base.getproperty(o::Store, x::Symbol) = getindex(o, x)
# Base.setproperty!(o::Store, x::Symbol, v) = setindex!(o, v, x)

end
