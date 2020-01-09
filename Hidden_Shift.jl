using Yao
using BitBasis
using Random

function HScircuit(shift::BitStr,f)
    n = mod(bit_length(shift),2) == 0 ? bit_length(shift) : bit_length(shift) + 1
    c = chain(n)
    push!(c,repeat(n,H,(1:n)))
    for i in 1:n
        if shift[i] == 1
            push!(c,put(n,(i,)=>X))
        end
    end
    for i in 1:Int(n/2)
        push!(c,control(n,f[2*i-1],f[2*i]=>Z))
    end
    for i in 1:n
        if shift[i] == 1
            push!(c,put(n,(i,)=>X))
        end
    end
    push!(c,repeat(n,H,(1:n)))
    for i in 1:Int(n/2)
        push!(c,control(n,f[2*i-1],f[2*i]=>Z))
    end
    push!(c,repeat(n,H,(1:n)))
    c
end

using Test
@testset "Hidden Shift algorithm" begin
    shift = bit"01110101"
    n = mod(bit_length(shift),2) == 0 ? bit_length(shift) : bit_length(shift) + 1
    f = randperm(MersenneTwister(1234), n)
    reg = zero_state(n)
    m = reg |> HScircuit(shift,f) |> measure
    @test m[1] == shift
end
