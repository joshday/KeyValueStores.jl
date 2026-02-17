[![CI](https://github.com/joshday/KeyValueStores.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/joshday/KeyValueStores.jl/actions/workflows/CI.yml)
[![Docs Build](https://github.com/joshday/KeyValueStores.jl/actions/workflows/Docs.yml/badge.svg)](https://github.com/joshday/KeyValueStores.jl/actions/workflows/Docs.yml)
[![Stable Docs](https://img.shields.io/badge/docs-stable-blue)](https://joshday.github.io/KeyValueStores.jl/stable/)
[![Dev Docs](https://img.shields.io/badge/docs-dev-blue)](https://joshday.github.io/KeyValueStores.jl/dev/)

# KeyValueStores



KeyValueStores.jl provides a simple interface for working with key (`Symbol`)-value stores.

## Usage

```julia
using KeyValueStores

store = Store(x=1, y="two")
store.x == store[:x]  # true

store = DefaultStore("DEFAULT", x=1, y="two")
store.zzz == "DEFAULT"  # true"
```


## `AbstractStore{T}`

An `AbstractStore{T}` is an `AbstractDict{Symbol, T}` with important differences:

- `AbstractStore{T}` is a wrapper of any other `AbstractDict{Symbol, T}` (`OrderedDict{Symbol,T}` by default).
- Pairs are passed to the constructor via *keyword* arguments, e.g. `Store(x=1, y=2)`.
- If an `AbstractStore` has fields beyond the wrapped dictionary, those are provided as *positional* arguments.
- Properties are mapped to keys.
