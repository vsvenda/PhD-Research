function res(ps::IEEE_58{T}, t, u::AbstractArray{T}, du::AbstractArray{T}, err::AbstractArray{T}) where T <: Real
    
    # Transmission Network Equations
    # First calculate: Pinj = Pg  - Pp
    # Bus 01
    err[41] = p1 - PP_01
    err[42] = q1 - QP_01
    # Bus 02
    err[43] = p2 - PP_02
    err[44] = q2 - QP_02
    # Bus 03
    err[45] = p3 - PP_03
    err[46] = q3 - QP_03
    # Bus 04
    err[47] = -PP_04
    err[48] = -QP_04
    # Bus 05
    err[49] = -PP_05
    err[50] = -QP_05
    # Bus 06
    err[51] = p4 - PP_06
    err[52] = q4 - QP_06
    # Bus 07
    err[53] = -PP_07
    err[54] = -QP_07
    # Bus 08
    err[55] = p5 - PP_08
    err[56] = q5 - QP_08
    # Bus 09
    err[57] = -PP_09
    err[58] = -QP_09
    # Bus 10
    err[59] = -PP_10
    err[60] = -QP_10
    # Bus 11
    err[61] = -PP_11
    err[62] = -QP_11
    # Bus 12
    err[63] = -PP_12
    err[64] = -QP_12
    # Bus 13
    err[65] = -PP_13
    err[66] = -QP_13
    # Bus 14
    err[67] = -PP_14
    err[68] = -QP_14
    B = zeros(T, (Nbus, Nbus))
    # Not sure about signs below.
    B[1,2] = ps.B0102
    B[1,5] = ps.B0105
    B[2,3] = ps.B0203
    B[2,4] = ps.B0204
    B[2,5] = ps.B0205
    B[3,4] = ps.B0304
    B[4,5] = ps.B0405
    B[4,7] = ps.B0407
    B[4,9] = ps.B0409
    B[5,6] = ps.B0506
    B[6,11] = ps.B0611
    B[6,12] = ps.B0612
    B[6,13] = ps.B0613
    B[7,8] = ps.B0708
    B[7,9] = ps.B0709
    B[9,10] = ps.B0910
    B[9,14] = ps.B0914
    B[10,11] = ps.B1011
    B[12,13] = ps.B1213
    B[13,14] = ps.B1314
    B = B + B'
    for i = 1:Nbus
        B[i,i] = - sum(B[:,i])
    end
    
    # Short in bus 14 for from t = 1.0 to 1 = 1.25
    G = -B*0.1 # Set G proportional to B
    for i = 1:Nbus
        V_i = u[54 + i]
        θ_i = u[40 + i]
        for j = 1:Nbus
            V_j = u[54 + j]
            θ_j = u[40 + j]
            err[41 + 2*(i-1)] -= V_i*V_j*(G[i,j]*cos(θ_i - θ_j) + B[i,j]*sin(θ_i - θ_j))
            err[41 + 2*(i-1) + 1] -= V_i*V_j*(G[i,j]*sin(θ_i - θ_j) - B[i,j]*cos(θ_i - θ_j))
        end
    end
    
    # Define the zero angle and remove one of the other equations
    err[41] = u[41] # θ Bus 1
    nothing
end
