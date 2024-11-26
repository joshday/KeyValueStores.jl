module KeyValueStores

export Store

#-----------------------------------------------------------------------------# AbstractKeyValueStore
abstract type AbstractKeyValueStore{T} <: AbstractDict{Symbol, T} end

dict(o::T) where {T <: AbstractKeyValueStore} = getfield(o, first(fieldnames(T)))

Base.length(o::AbstractKeyValueStore) = length(dict(o))
Base.keys(o::AbstractKeyValueStore) = keys(dict(o))
Base.values(o::AbstractKeyValueStore) = values(dict(o))
Base.iterate(o::AbstractKeyValueStore, state...) = iterate(dict(o), state...)

const KeyLike = Union{AbstractString, Symbol}

Base.getindex(o::AbstractKeyValueStore, k::KeyLike) = getindex(dict(o), Symbol(k))
Base.setindex!(o::AbstractKeyValueStore, v, k::KeyLike) = setindex!(dict(o), v, Symbol(k))
Base.get(o::AbstractKeyValueStore, k::KeyLike, default) = get(dict(o), Symbol(k), default)
Base.get!(o::AbstractKeyValueStore, k::KeyLike, default) = get!(dict(o), Symbol(k), default)
Base.haskey(o::AbstractKeyValueStore, k::AbstractString) = haskey(o, Symbol(k))

Base.delete!(o::AbstractKeyValueStore, k::KeyLike) = delete!(dict(o), Symbol(k))

Base.empty(o::T) where {T <: AbstractKeyValueStore} = T(empty(dict(o)))
Base.empty!(o::AbstractKeyValueStore) = (empty!(dict(o)); o)

Base.copy(o::T) where {T <: AbstractKeyValueStore} = T(copy(dict(o)))

Base.sort(o::T; kw...) where {T <: AbstractKeyValueStore} = T(sort(dict(o); kw...))
Base.sort!(o::AbstractKeyValueStore; kw...) = (sort!(dict(o); kw...); o)

Base.merge(o::T, x::AbstractDict...) where {T <: AbstractKeyValueStore} = T(merge(dict(o), x...))
Base.merge!(o::AbstractKeyValueStore, x::AbstractDict...) = (merge!(dict(o), x...); o)

Base.propertynames(o::AbstractKeyValueStore) = keys(dict(o))
Base.getproperty(o::AbstractKeyValueStore, k::Symbol) = getindex(o, k)
Base.setproperty!(o::AbstractKeyValueStore, k::Symbol, v) = setindex!(o, v, k)

# constructor helpers
dict_arg() = ()
dict_arg(x) = isempty(x) ? Pair{Symbol,Any}[] : (dict_arg(x) for x in x)
dict_arg(x::Pair) = Symbol(x[1]) => x[2]


#-----------------------------------------------------------------------------# Store
struct Store{T, D <: AbstractDict{Symbol, T}} <: AbstractKeyValueStore{T}
    dict::D
    Store(dict::D) where {T, D <: AbstractDict{Symbol, T}} = new{T, D}(dict)
end
Store(x...; kw...) = Store(Dict(dict_arg(x)..., dict_arg(kw)...))
Store{T}(x...; kw...) where {T} = Store(Dict{Symbol, T}(dict_arg(x)..., dict_arg(kw)...))
Store{T, D}(x...; kw...) where {T, D <: AbstractDict{Symbol, T}} = Store(D(dict_arg(x)..., dict_arg(kw)...))

#-----------------------------------------------------------------------------# prune!

"""
    prune!(x::AbstractDict)

`delete!` all empty sub-dicts from `x`.
"""
prune!(x) = x

function prune!(o::AbstractDict)
    for (k, v) in pairs(o)
        isempty(v) ? delete!(o, k) : prune!(v)
    end
end

function delete_empty!(x)
    Base.depwarn("delete_empty! is deprecated, use prune! instead", :delete_empty!; force=true)
    prune!(x)
end

end
