using KeyValueStores
using Test
using OrderedCollections

#-----------------------------------------------------------------------------# Store
@testset "Store" begin
    @test_nowarn Store()
    @test_nowarn Store(Dict{Symbol, Any}; x=1,y="two")
    @test_nowarn Store(Dict{Symbol, Any}(:x => 1, :y => "two"))

    @test Store(Dict{Symbol, Any}; x=1,y="two") == Store(Dict{Symbol, Any}(:x => 1, :y => "two"))
end
#-----------------------------------------------------------------------------# DefaultStore
@testset "DefaultStore" begin
    @test_nowarn DefaultStore()
    @test_nowarn DefaultStore(Dict{Symbol, Any}; x=1,y="two")
    @test_nowarn DefaultStore(Dict{Symbol, Any}(:x => 1, :y => "two"))

    @test DefaultStore(Dict{Symbol, Any}; x=1,y="two") == DefaultStore(Dict{Symbol, Any}(:x => 1, :y => "two"))
end

#-----------------------------------------------------------------------------# Base methods
@testset "Base methods" begin
    o = Store(x=1,y="two")
    odef = DefaultStore(x=1,y="two")

    @test o == odef

    @test o[:x] == odef[:x] == o.x == odef.x
    @test o[:y] == odef[:y] == o.y == odef.y
    @test get(o, :z, nothing) === odef[:z] === odef.z === nothing
    @test get(odef, :z, 3) == 3  # With `get`, default argument is used, not DefaultStore default
    @test collect(o) == collect(odef) == [:x => 1, :y => "two"]
    @test length(o) == length(odef) == 2
    @test pop!(o) == pop!(odef) == (:y => "two")
    @test length(o) == length(odef) == 1
    empty!(o)
    empty!(odef)
    @test length(o) == length(odef) == 0

    o[:x] = 3
    odef[:x] = 3
    @test o[:x] == o.x == odef[:x] == odef.x == 3

    o.y = "four"
    odef.y = "four"
    @test o[:y] == o.y == odef[:y] == odef.y == "four"

    o_copy = copy(o)
    odef_copy = copy(odef)
    @test o_copy isa Store
    @test odef_copy isa DefaultStore
    @test o_copy[:x] == odef_copy[:x] == o.x == odef.x == 3
    @test o_copy[:y] == odef_copy[:y] == o.y == odef.y == "four"

    o_copy.z = 5
    odef_copy.z = 5
    @test o_copy == odef_copy
    @test o_copy != o

    push!(o, :z => 5)
    push!(odef, :z => 5)
    @test o == odef == o_copy == odef_copy

    @test freeze(o) == freeze(odef) == o_copy == odef_copy
end
