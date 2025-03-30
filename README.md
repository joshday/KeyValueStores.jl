# KeyValueStores

[![Build Status](https://github.com/joshday/KeyValueStores.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/joshday/KeyValueStores.jl/actions/workflows/CI.yml?query=branch%3Amain)


KeyValueStores.jl is a Julia package that provides a simple interface for working with key (`Symbol`)-value stores.

## Usage

```julia
using KeyValueStores

store = Store(x=1, y="two")

store.x == store[:x]  # true
```

```julia
using KeyValueStores

store = DefaultStore("DEFAULT", x=1, y="two")

store.zzz == "DEFAULT"  # true"
```

## `AbstractStore{T}`

An `AbstractStore{T}` is an `AbstractDict{Symbol, T}` with important differences:

- `AbstractStore{T}` is a wrapper of any other `AbstractDict{T}` (`OrderedDict{Symbol,T}` by default).
- Construction is performed via *keyword* arguments, e.g. `Store(x=1, y=2)`.
- If an `AbstractStore` has fields beyond the wrapped dictionary, those are provided as *positional* arguments.
- Properties are mapped to keys.
