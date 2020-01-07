using Yao
using BitBasis


carrygate = chain(4,control((2,3),4=>X),control((2,),3=>X),control((1,3),4=>X))

sumgate = chain(3,control((2,),3=>X),control((1,),3=>X))

function initialstate(sa::BitStr,sb::BitStr)
    n = max(bit_length(sa),bit_length(sb))
    reg = zero_state(3n+1)
    reg |> repeat(3n+1,X,[3*baddrs(sa).-1; 3*baddrs(sb)])
end

function adder(n)
    c = chain(3n+1)
    for i = 1:n
        push!(c,put(3n+1,(3i-2,3i-1,3i,3i+1)=>carrygate))
    end
    c = chain(c,control((3n-1,),(3n)=>X),put(3n+1,(3n-2,3n-1,3n)=>sumgate))
    for i = 1:n-1
        j = n - i
        c = chain(c,put(3n+1,(3j-2,3j-1,3j,3j+1)=>carrygate'),put(3n+1,(3j-2,3j-1,3j)=>sumgate))
    end
    c
end

using Test
@testset "quantum adder" begin
    sa = bit"101010"
    sb = bit"111101"
    n = max(bit_length(sa),bit_length(sb))
    reg = initialstate(sa,sb) |> adder(n)
    measure_remove!(reg,[3i-2 for i in 1:n])   #remove carry register
    measure_remove!(reg,[2i-1 for i in 1:n])   #remove a register
    @test (reg |> measure)[1] ≈ bint(sa) + bint(sb) #test a + b
    reg = initialstate(sa,sb) |> adder(n)'
    measure_remove!(reg,[3i-2 for i in 1:n])   #remove carry register
    measure_remove!(reg,[2i-1 for i in 1:n])   #remove a register
    @test (reg |> measure)[1] ≈ bint(sb) - bint(sa) #test b - a
end
