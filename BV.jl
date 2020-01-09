using Yao
using BitBasis

function BVcircuit(s::BitStr)
    n = bit_length(s)
    c = chain(n+1)
    push!(c,put(n+1,(n+1,)=>X))
    push!(c,repeat(n+1,H,1:n+1))
    for i in 1:n
        if s[i] == 1
            push!(c,control(n+1,(i,),(n+1)=>X))
        end
    end
    push!(c,repeat(n+1,H,1:n+1))
    push!(c,put(n+1,(n+1)=>X))
    c
end


using Test
@testset "BValgorithm" begin
    s = bit"1101011"
    reg = zero_state(bit_length(s)+1) |> BVcircuit(s)
    m = reg |> measure
    @test bint(m[1]) ≈ bint(s)
end
