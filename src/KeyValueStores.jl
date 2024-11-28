module KeyValueStores

using OrderedCollections

export Store, DefaultStore, Default, NestedStore

#-----------------------------------------------------------------------------# AbstractStore
abstract type AbstractStore{T} <: AbstractDict{Symbol, T} end

# function Base.summary(io::IO, o::AbstractStore{T}) where {T}
#     print(io, typeof(o))
# end

dict(o::T) where {T <: AbstractStore} = getfield(o, first(fieldnames(T)))

Base.copy(o::T) where {T <: AbstractStore} = T(copy(dict(o)))
Base.iterate(o::AbstractStore, state...) = iterate(dict(o), state...)

# pass-to-dict methods
for f in (:length, :keys, :values)
    @eval Base.$f(o::AbstractStore) = $f(dict(o))
end

# Second-arg-is-a-key methods
for f in (:getindex, :haskey, :delete!)
    @eval Base.$f(o::AbstractStore, k::Symbol) = $f(dict(o), k)
    @eval Base.$f(o::AbstractStore, k::AbstractString) = $f(o, Symbol(k))
end
Base.setindex!(o::AbstractStore, v, k::Symbol) = setindex!(dict(o), v, k)
Base.setindex!(o::AbstractStore, v, k::AbstractString) = setindex!(o, v, Symbol(k))

# get/get!
for f in [:get, :get!]
    @eval Base.$f(o::AbstractStore, k::Symbol, default) = $f(dict(o), k, default)
    @eval Base.$f(o::AbstractStore, k::AbstractString, default) = $f(o, Symbol(k), default)
end

# mutating and copy-based methods
Base.empty(o::AbstractStore) = empty!(copy(o))
Base.empty!(o::AbstractStore) = (empty!(dict(o)); o)
Base.sort(o::AbstractStore; kw...) = sort!(copy(o); kw...)
Base.sort!(o::AbstractStore; kw...) = (sort!(dict(o); kw...); o)
Base.merge(o::AbstractStore, x::AbstractDict...) = merge!(copy(o), x...)
Base.merge!(o::AbstractStore, x::AbstractDict...) = (merge!(dict(o), x...); o)

# get/set property
Base.propertynames(o::AbstractStore) = keys(dict(o))
Base.getproperty(o::AbstractStore, k::Symbol) = getindex(o, k)
Base.setproperty!(o::AbstractStore, k::Symbol, v) = setindex!(o, v, k)

# constructor helpers
dict_arg() = ()
dict_arg(x) = isempty(x) ? Pair{Symbol,Any}[] : (dict_arg(x) for x in x)
dict_arg(x::Pair) = Symbol(x[1]) => x[2]

#-----------------------------------------------------------------------------# Store
struct Store{T, D <: AbstractDict{Symbol, T}} <: AbstractStore{T}
    dict::D
    Store(dict::D) where {T, D <: AbstractDict{Symbol, T}} = new{T, D}(dict)
end
Store(x...; kw...) = Store(OrderedDict(dict_arg(x)..., dict_arg(kw)...))
Store{T}(x...; kw...) where {T} = Store(OrderedDict{Symbol, T}(dict_arg(x)..., dict_arg(kw)...))
Store{T, D}(x...; kw...) where {T, D <: AbstractDict{Symbol, T}} = Store(D(dict_arg(x)..., dict_arg(kw)...))


#-----------------------------------------------------------------------------# DefaultStore
struct DefaultStore{T, D, S <: Store{T, D}, R} <: AbstractStore{Union{T, R}}
    store::S
    default::R
    DefaultStore(store::S, default::R) where {T, D, S <: Store{T, D}, R} = new{T, D, S, R}(store, default)
end
DefaultStore(default, x...; kw...) = DefaultStore(Store(x...; kw...), default)
DefaultStore{T}(default, x...; kw...) where {T} = DefaultStore(Store{T}(x...; kw...), default)
DefaultStore{T, D}(default, x...; kw...) where {T, D} = DefaultStore(Store{T, D}(x...; kw...), default)

Base.getindex(o::DefaultStore, k::Symbol) = haskey(o, k) ? dict(o)[k] : getfield(o, :default)


#-----------------------------------------------------------------------------# NestedStore
struct NestedStore{D, S <: Store{Any, D}} <: AbstractStore{Any}
    store::S
    path::Vector{Symbol}
end
NestedStore(x...; kw...) = NestedStore(Store{Any}(x...; kw...), Symbol[])
NestedStore{D}(x...; kw...) where {D} = NestedStore(Store{Any, D}(x...; kw...), Symbol[])

Base.getindex(o::NestedStore, k::Symbol) = haskey(o, k) ? dict(o)[k] : NestedStore(getfield(o, :store), [getfield(o, :path); k])

function Base.setindex!(o::NestedStore{D, S}, v, k::Symbol) where {D, S}
    obj = dict(o)
    for p in getfield(o, :path)
        obj = get!(obj, p, S())
    end
    obj[k] = v
end

end
