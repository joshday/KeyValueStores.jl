using KeyValueStores
using Test

@testset "KeyValueStores.jl" begin
    @testset "Store" begin
        @testset "Constructors" begin
            # empty
            @test Store() isa Store{Any, Dict{Symbol, Any}}
            @test Store{Int}() isa Store{Int, Dict{Symbol, Int}}
            @test Store{Int, Dict{Symbol, Int}}() isa Store{Int, Dict{Symbol, Int}}

            # keyword
            @test Store(x=1) isa Store{Int}
            @test Store{Int}(x=1) isa Store{Int}
            @test Store{Int, Dict{Symbol, Int}}(x=1) isa Store{Int, Dict{Symbol, Int}}

            # pair
            @test Store(:x => 1) isa Store{Int}
            @test Store{Int}(:x => 1) isa Store{Int}
            @test Store{Int, Dict{Symbol, Int}}(:x => 1) isa Store{Int, Dict{Symbol, Int}}

            # pairs
            @test Store(:x => 1, :y => 2) isa Store{Int}
            @test Store{Int}(:x => 1, :y => 2) isa Store{Int}
            @test Store{Int, Dict{Symbol, Int}}(:x => 1, :y => 2) isa Store{Int}

            # dict
            @test Store(Dict(:x => 1)) isa Store{Int}
            @test Store{Int}(Dict(:x => 1)) isa Store{Int}
            @test Store{Int, Dict{Symbol, Int}}(Dict(:x => 1)) isa Store{Int, Dict{Symbol, Int}}
        end
        @testset "Base functions" begin
            o = Store(x=1, y=2)
            @test sort!(collect(keys(o))) == [:x, :y]
            @test sort!(collect(propertynames(o))) == [:x, :y]
            @test get(o, :z, 3) == 3
            @test !haskey(o, :z)
            @test get!(o, :z, 3) == 3
            @test haskey(o, :z)
            delete!(o, :z)
            @test !haskey(o, :z)
            @test o.x == o[:x] == o["x"] == 1
            @test o.y == o[:y] == o["y"] == 2
            o.z = 3
            o[:z] = 3
            o["z"] = 3
            @test o.z == o[:z] == o["z"] == 3
        end
    end
end
