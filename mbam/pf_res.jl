@with_kw mutable struct pf_data{T<:Real} <: ParametricModels.AbstractParameterSpace{T} @deftype T
	V_1     = 1.06
	theta_1 = 0.0
	P_2 = 0.09620000000000001
	V_2 = 1.045
	P_3 = -1.319
	V_3 = 1.01
	P_4 = -0.6692
	Q_4 = -0.056
	P_5 = -0.1064
	Q_5 = -0.0224
	P_6 = 0.1432
	V_6 = 1.07
	P_7 = 0.0
	Q_7 = 0.0
	P_8 = 0.7
	V_8 = 1.09
	P_9 = -0.413
	Q_9 = -0.2324
	P_10 = -0.126
	Q_10 = -0.0812
	P_11 = -0.049
	Q_11 = -0.0252
	P_12 = -0.0854
	Q_12 = -0.0224
	P_13 = -0.189
	Q_13 = -0.0812
	P_14 = -0.2086
	Q_14 = -0.07
	B_2_5 = 5.19344577586429
	k_2_5 = 0.3274870615296147
	B_6_12 = 3.1761384836111626
	k_6_12 = 0.480453479280688
	B_12_13 = 2.252221294093231
	k_12_13 = 1.1050525262631317
	B_6_13 = 6.101926286342139
	k_6_13 = 0.5076745970836531
	B_6_11 = 4.0940743442404415
	k_6_11 = 0.47752639517345397
	B_11_10 = 4.402468338638277
	k_11_10 = 0.4271212909942738
	B_9_10 = 10.365394127060915
	k_9_10 = 0.3764497041420118
	B_9_14 = 3.0289937658065815
	k_9_14 = 0.47004437869822485
	B_14_13 = 2.315202745564341
	k_14_13 = 0.49109195402298855
	B_7_9 = 9.090909090909092
	k_7_9 = 0.0
	B_1_2 = 15.26308652317955
	k_1_2 = 0.32753084333277
	B_3_2 = 4.781215895125198
	k_3_2 = 0.2373232323232323
	B_3_4 = 5.069469505007896
	k_3_4 = 0.39187134502923976
	B_1_5 = 4.2356590873295445
	k_1_5 = 0.24228699551569507
	B_5_4 = 21.578553981691588
	k_5_4 = 0.3170268344811209
	B_2_4 = 5.116304943858768
	k_2_4 = 0.329608621667612
	B_5_6 = 3.968253968253968
	k_5_6 = 0.0
	B_4_9 = 1.7979144192736425
	k_4_9 = 0.0
	B_4_7 = 4.782400765184122
	k_4_7 = 0.0
	B_8_7 = 5.675368898978434
	k_8_7 = 0.0
end

function pf_error(ps::pf_data{T}, u) where T <: Real
	err = zero(u)
	P_1 = u[1]
	Q_1 = u[2]
	Q_2     = u[3]
	theta_2 = u[4]
	Q_3     = u[5]
	theta_3 = u[6]
	V_4     = u[7]
	theta_4 = u[8]
	V_5     = u[9]
	theta_5 = u[10]
	Q_6     = u[11]
	theta_6 = u[12]
	V_7     = u[13]
	theta_7 = u[14]
	Q_8     = u[15]
	theta_8 = u[16]
	V_9     = u[17]
	theta_9 = u[18]
	V_10     = u[19]
	theta_10 = u[20]
	V_11     = u[21]
	theta_11 = u[22]
	V_12     = u[23]
	theta_12 = u[24]
	V_13     = u[25]
	theta_13 = u[26]
	V_14     = u[27]
	theta_14 = u[28]
	V_1     = ps.V_1
	theta_1 = ps.theta_1
	P_2 = ps.P_2
	V_2 = ps.V_2
	P_3 = ps.P_3
	V_3 = ps.V_3
	P_4 = ps.P_4
	Q_4 = ps.Q_4
	P_5 = ps.P_5
	Q_5 = ps.Q_5
	P_6 = ps.P_6
	V_6 = ps.V_6
	P_7 = ps.P_7
	Q_7 = ps.Q_7
	P_8 = ps.P_8
	V_8 = ps.V_8
	P_9 = ps.P_9
	Q_9 = ps.Q_9
	P_10 = ps.P_10
	Q_10 = ps.Q_10
	P_11 = ps.P_11
	Q_11 = ps.Q_11
	P_12 = ps.P_12
	Q_12 = ps.Q_12
	P_13 = ps.P_13
	Q_13 = ps.Q_13
	P_14 = ps.P_14
	Q_14 = ps.Q_14
	B_2_5 = ps.B_2_5
	k_2_5 = ps.k_2_5
	B_6_12 = ps.B_6_12
	k_6_12 = ps.k_6_12
	B_12_13 = ps.B_12_13
	k_12_13 = ps.k_12_13
	B_6_13 = ps.B_6_13
	k_6_13 = ps.k_6_13
	B_6_11 = ps.B_6_11
	k_6_11 = ps.k_6_11
	B_11_10 = ps.B_11_10
	k_11_10 = ps.k_11_10
	B_9_10 = ps.B_9_10
	k_9_10 = ps.k_9_10
	B_9_14 = ps.B_9_14
	k_9_14 = ps.k_9_14
	B_14_13 = ps.B_14_13
	k_14_13 = ps.k_14_13
	B_7_9 = ps.B_7_9
	k_7_9 = ps.k_7_9
	B_1_2 = ps.B_1_2
	k_1_2 = ps.k_1_2
	B_3_2 = ps.B_3_2
	k_3_2 = ps.k_3_2
	B_3_4 = ps.B_3_4
	k_3_4 = ps.k_3_4
	B_1_5 = ps.B_1_5
	k_1_5 = ps.k_1_5
	B_5_4 = ps.B_5_4
	k_5_4 = ps.k_5_4
	B_2_4 = ps.B_2_4
	k_2_4 = ps.k_2_4
	B_5_6 = ps.B_5_6
	k_5_6 = ps.k_5_6
	B_4_9 = ps.B_4_9
	k_4_9 = ps.k_4_9
	B_4_7 = ps.B_4_7
	k_4_7 = ps.k_4_7
	B_8_7 = ps.B_8_7
	k_8_7 = ps.k_8_7
	B_5_2 =  B_2_5
	G_2_5 = -k_2_5*B_2_5
	G_5_2 = -k_2_5*B_5_2
	B_12_6 =  B_6_12
	G_6_12 = -k_6_12*B_6_12
	G_12_6 = -k_6_12*B_12_6
	B_13_12 =  B_12_13
	G_12_13 = -k_12_13*B_12_13
	G_13_12 = -k_12_13*B_13_12
	B_13_6 =  B_6_13
	G_6_13 = -k_6_13*B_6_13
	G_13_6 = -k_6_13*B_13_6
	B_11_6 =  B_6_11
	G_6_11 = -k_6_11*B_6_11
	G_11_6 = -k_6_11*B_11_6
	B_10_11 =  B_11_10
	G_11_10 = -k_11_10*B_11_10
	G_10_11 = -k_11_10*B_10_11
	B_10_9 =  B_9_10
	G_9_10 = -k_9_10*B_9_10
	G_10_9 = -k_9_10*B_10_9
	B_14_9 =  B_9_14
	G_9_14 = -k_9_14*B_9_14
	G_14_9 = -k_9_14*B_14_9
	B_13_14 =  B_14_13
	G_14_13 = -k_14_13*B_14_13
	G_13_14 = -k_14_13*B_13_14
	B_9_7 =  B_7_9
	G_7_9 = -k_7_9*B_7_9
	G_9_7 = -k_7_9*B_9_7
	B_2_1 =  B_1_2
	G_1_2 = -k_1_2*B_1_2
	G_2_1 = -k_1_2*B_2_1
	B_2_3 =  B_3_2
	G_3_2 = -k_3_2*B_3_2
	G_2_3 = -k_3_2*B_2_3
	B_4_3 =  B_3_4
	G_3_4 = -k_3_4*B_3_4
	G_4_3 = -k_3_4*B_4_3
	B_5_1 =  B_1_5
	G_1_5 = -k_1_5*B_1_5
	G_5_1 = -k_1_5*B_5_1
	B_4_5 =  B_5_4
	G_5_4 = -k_5_4*B_5_4
	G_4_5 = -k_5_4*B_4_5
	B_4_2 =  B_2_4
	G_2_4 = -k_2_4*B_2_4
	G_4_2 = -k_2_4*B_4_2
	B_6_5 =  B_5_6
	G_5_6 = -k_5_6*B_5_6
	G_6_5 = -k_5_6*B_6_5
	B_9_4 =  B_4_9
	G_4_9 = -k_4_9*B_4_9
	G_9_4 = -k_4_9*B_9_4
	B_7_4 =  B_4_7
	G_4_7 = -k_4_7*B_4_7
	G_7_4 = -k_4_7*B_7_4
	B_7_8 =  B_8_7
	G_8_7 = -k_8_7*B_8_7
	G_7_8 = -k_8_7*B_7_8
	B_1_1 = - B_2_1 - B_5_1
	G_1_1 = - G_2_1 - G_5_1
	B_2_2 = - B_5_2 - B_4_2 - B_1_2 - B_3_2
	G_2_2 = - G_5_2 - G_4_2 - G_1_2 - G_3_2
	B_3_3 = - B_2_3 - B_4_3
	G_3_3 = - G_2_3 - G_4_3
	B_4_4 = - B_9_4 - B_7_4 - B_3_4 - B_5_4 - B_2_4
	G_4_4 = - G_9_4 - G_7_4 - G_3_4 - G_5_4 - G_2_4
	B_5_5 = - B_4_5 - B_6_5 - B_2_5 - B_1_5
	G_5_5 = - G_4_5 - G_6_5 - G_2_5 - G_1_5
	B_6_6 = - B_12_6 - B_13_6 - B_11_6 - B_5_6
	G_6_6 = - G_12_6 - G_13_6 - G_11_6 - G_5_6
	B_7_7 = - B_9_7 - B_4_7 - B_8_7
	G_7_7 = - G_9_7 - G_4_7 - G_8_7
	B_8_8 = - B_7_8
	G_8_8 = - G_7_8
	B_9_9 = - B_10_9 - B_14_9 - B_7_9 - B_4_9
	G_9_9 = - G_10_9 - G_14_9 - G_7_9 - G_4_9
	B_10_10 = - B_11_10 - B_9_10
	G_10_10 = - G_11_10 - G_9_10
	B_11_11 = - B_10_11 - B_6_11
	G_11_11 = - G_10_11 - G_6_11
	B_12_12 = - B_13_12 - B_6_12
	G_12_12 = - G_13_12 - G_6_12
	B_13_13 = - B_12_13 - B_6_13 - B_14_13
	G_13_13 = - G_12_13 - G_6_13 - G_14_13
	B_14_14 = - B_13_14 - B_9_14
	G_14_14 = - G_13_14 - G_9_14
	Pinj_1 =  V_1^2*G_1_1 + V_1*V_2*(G_1_2*cos(theta_1 - theta_2) + B_1_2*sin(theta_1 - theta_2)) + V_1*V_5*(G_1_5*cos(theta_1 - theta_5) + B_1_5*sin(theta_1 - theta_5))
	Qinj_1 = -V_1^2*B_1_1 + V_1*V_2*(G_1_2*sin(theta_1 - theta_2) - B_1_2*cos(theta_1 - theta_2)) + V_1*V_5*(G_1_5*sin(theta_1 - theta_5) - B_1_5*cos(theta_1 - theta_5))
	Pinj_2 =  V_2^2*G_2_2 + V_2*V_5*(G_2_5*cos(theta_2 - theta_5) + B_2_5*sin(theta_2 - theta_5)) + V_2*V_4*(G_2_4*cos(theta_2 - theta_4) + B_2_4*sin(theta_2 - theta_4)) + V_2*V_1*(G_2_1*cos(theta_2 - theta_2) + B_2_1*sin(theta_2 - theta_1)) + V_2*V_3*(G_2_3*cos(theta_2 - theta_2) + B_2_3*sin(theta_2 - theta_3))
	Qinj_2 = -V_2^2*B_2_2 + V_2*V_5*(G_2_5*sin(theta_2 - theta_5) - B_2_5*cos(theta_2 - theta_5)) + V_2*V_4*(G_2_4*sin(theta_2 - theta_4) - B_2_4*cos(theta_2 - theta_4)) + V_2*V_1*(G_2_1*sin(theta_2 - theta_2) - B_2_1*cos(theta_2 - theta_1)) + V_2*V_3*(G_2_3*sin(theta_2 - theta_2) - B_2_3*cos(theta_2 - theta_3))
	Pinj_3 =  V_3^2*G_3_3 + V_3*V_2*(G_3_2*cos(theta_3 - theta_2) + B_3_2*sin(theta_3 - theta_2)) + V_3*V_4*(G_3_4*cos(theta_3 - theta_4) + B_3_4*sin(theta_3 - theta_4))
	Qinj_3 = -V_3^2*B_3_3 + V_3*V_2*(G_3_2*sin(theta_3 - theta_2) - B_3_2*cos(theta_3 - theta_2)) + V_3*V_4*(G_3_4*sin(theta_3 - theta_4) - B_3_4*cos(theta_3 - theta_4))
	Pinj_4 =  V_4^2*G_4_4 + V_4*V_9*(G_4_9*cos(theta_4 - theta_9) + B_4_9*sin(theta_4 - theta_9)) + V_4*V_7*(G_4_7*cos(theta_4 - theta_7) + B_4_7*sin(theta_4 - theta_7)) + V_4*V_3*(G_4_3*cos(theta_4 - theta_4) + B_4_3*sin(theta_4 - theta_3)) + V_4*V_5*(G_4_5*cos(theta_4 - theta_4) + B_4_5*sin(theta_4 - theta_5)) + V_4*V_2*(G_4_2*cos(theta_4 - theta_4) + B_4_2*sin(theta_4 - theta_2))
	Qinj_4 = -V_4^2*B_4_4 + V_4*V_9*(G_4_9*sin(theta_4 - theta_9) - B_4_9*cos(theta_4 - theta_9)) + V_4*V_7*(G_4_7*sin(theta_4 - theta_7) - B_4_7*cos(theta_4 - theta_7)) + V_4*V_3*(G_4_3*sin(theta_4 - theta_4) - B_4_3*cos(theta_4 - theta_3)) + V_4*V_5*(G_4_5*sin(theta_4 - theta_4) - B_4_5*cos(theta_4 - theta_5)) + V_4*V_2*(G_4_2*sin(theta_4 - theta_4) - B_4_2*cos(theta_4 - theta_2))
	Pinj_5 =  V_5^2*G_5_5 + V_5*V_4*(G_5_4*cos(theta_5 - theta_4) + B_5_4*sin(theta_5 - theta_4)) + V_5*V_6*(G_5_6*cos(theta_5 - theta_6) + B_5_6*sin(theta_5 - theta_6)) + V_5*V_2*(G_5_2*cos(theta_5 - theta_5) + B_5_2*sin(theta_5 - theta_2)) + V_5*V_1*(G_5_1*cos(theta_5 - theta_5) + B_5_1*sin(theta_5 - theta_1))
	Qinj_5 = -V_5^2*B_5_5 + V_5*V_4*(G_5_4*sin(theta_5 - theta_4) - B_5_4*cos(theta_5 - theta_4)) + V_5*V_6*(G_5_6*sin(theta_5 - theta_6) - B_5_6*cos(theta_5 - theta_6)) + V_5*V_2*(G_5_2*sin(theta_5 - theta_5) - B_5_2*cos(theta_5 - theta_2)) + V_5*V_1*(G_5_1*sin(theta_5 - theta_5) - B_5_1*cos(theta_5 - theta_1))
	Pinj_6 =  V_6^2*G_6_6 + V_6*V_12*(G_6_12*cos(theta_6 - theta_12) + B_6_12*sin(theta_6 - theta_12)) + V_6*V_13*(G_6_13*cos(theta_6 - theta_13) + B_6_13*sin(theta_6 - theta_13)) + V_6*V_11*(G_6_11*cos(theta_6 - theta_11) + B_6_11*sin(theta_6 - theta_11)) + V_6*V_5*(G_6_5*cos(theta_6 - theta_6) + B_6_5*sin(theta_6 - theta_5))
	Qinj_6 = -V_6^2*B_6_6 + V_6*V_12*(G_6_12*sin(theta_6 - theta_12) - B_6_12*cos(theta_6 - theta_12)) + V_6*V_13*(G_6_13*sin(theta_6 - theta_13) - B_6_13*cos(theta_6 - theta_13)) + V_6*V_11*(G_6_11*sin(theta_6 - theta_11) - B_6_11*cos(theta_6 - theta_11)) + V_6*V_5*(G_6_5*sin(theta_6 - theta_6) - B_6_5*cos(theta_6 - theta_5))
	Pinj_7 =  V_7^2*G_7_7 + V_7*V_9*(G_7_9*cos(theta_7 - theta_9) + B_7_9*sin(theta_7 - theta_9)) + V_7*V_4*(G_7_4*cos(theta_7 - theta_7) + B_7_4*sin(theta_7 - theta_4)) + V_7*V_8*(G_7_8*cos(theta_7 - theta_7) + B_7_8*sin(theta_7 - theta_8))
	Qinj_7 = -V_7^2*B_7_7 + V_7*V_9*(G_7_9*sin(theta_7 - theta_9) - B_7_9*cos(theta_7 - theta_9)) + V_7*V_4*(G_7_4*sin(theta_7 - theta_7) - B_7_4*cos(theta_7 - theta_4)) + V_7*V_8*(G_7_8*sin(theta_7 - theta_7) - B_7_8*cos(theta_7 - theta_8))
	Pinj_8 =  V_8^2*G_8_8 + V_8*V_7*(G_8_7*cos(theta_8 - theta_7) + B_8_7*sin(theta_8 - theta_7))
	Qinj_8 = -V_8^2*B_8_8 + V_8*V_7*(G_8_7*sin(theta_8 - theta_7) - B_8_7*cos(theta_8 - theta_7))
	Pinj_9 =  V_9^2*G_9_9 + V_9*V_10*(G_9_10*cos(theta_9 - theta_10) + B_9_10*sin(theta_9 - theta_10)) + V_9*V_14*(G_9_14*cos(theta_9 - theta_14) + B_9_14*sin(theta_9 - theta_14)) + V_9*V_7*(G_9_7*cos(theta_9 - theta_9) + B_9_7*sin(theta_9 - theta_7)) + V_9*V_4*(G_9_4*cos(theta_9 - theta_9) + B_9_4*sin(theta_9 - theta_4))
	Qinj_9 = -V_9^2*B_9_9 + V_9*V_10*(G_9_10*sin(theta_9 - theta_10) - B_9_10*cos(theta_9 - theta_10)) + V_9*V_14*(G_9_14*sin(theta_9 - theta_14) - B_9_14*cos(theta_9 - theta_14)) + V_9*V_7*(G_9_7*sin(theta_9 - theta_9) - B_9_7*cos(theta_9 - theta_7)) + V_9*V_4*(G_9_4*sin(theta_9 - theta_9) - B_9_4*cos(theta_9 - theta_4))
	Pinj_10 =  V_10^2*G_10_10 + V_10*V_11*(G_10_11*cos(theta_10 - theta_11) + B_10_11*sin(theta_10 - theta_11)) + V_10*V_9*(G_10_9*cos(theta_10 - theta_9) + B_10_9*sin(theta_10 - theta_9))
	Qinj_10 = -V_10^2*B_10_10 + V_10*V_11*(G_10_11*sin(theta_10 - theta_11) - B_10_11*cos(theta_10 - theta_11)) + V_10*V_9*(G_10_9*sin(theta_10 - theta_9) - B_10_9*cos(theta_10 - theta_9))
	Pinj_11 =  V_11^2*G_11_11 + V_11*V_10*(G_11_10*cos(theta_11 - theta_10) + B_11_10*sin(theta_11 - theta_10)) + V_11*V_6*(G_11_6*cos(theta_11 - theta_11) + B_11_6*sin(theta_11 - theta_6))
	Qinj_11 = -V_11^2*B_11_11 + V_11*V_10*(G_11_10*sin(theta_11 - theta_10) - B_11_10*cos(theta_11 - theta_10)) + V_11*V_6*(G_11_6*sin(theta_11 - theta_11) - B_11_6*cos(theta_11 - theta_6))
	Pinj_12 =  V_12^2*G_12_12 + V_12*V_13*(G_12_13*cos(theta_12 - theta_13) + B_12_13*sin(theta_12 - theta_13)) + V_12*V_6*(G_12_6*cos(theta_12 - theta_12) + B_12_6*sin(theta_12 - theta_6))
	Qinj_12 = -V_12^2*B_12_12 + V_12*V_13*(G_12_13*sin(theta_12 - theta_13) - B_12_13*cos(theta_12 - theta_13)) + V_12*V_6*(G_12_6*sin(theta_12 - theta_12) - B_12_6*cos(theta_12 - theta_6))
	Pinj_13 =  V_13^2*G_13_13 + V_13*V_12*(G_13_12*cos(theta_13 - theta_12) + B_13_12*sin(theta_13 - theta_12)) + V_13*V_6*(G_13_6*cos(theta_13 - theta_6) + B_13_6*sin(theta_13 - theta_6)) + V_13*V_14*(G_13_14*cos(theta_13 - theta_14) + B_13_14*sin(theta_13 - theta_14))
	Qinj_13 = -V_13^2*B_13_13 + V_13*V_12*(G_13_12*sin(theta_13 - theta_12) - B_13_12*cos(theta_13 - theta_12)) + V_13*V_6*(G_13_6*sin(theta_13 - theta_6) - B_13_6*cos(theta_13 - theta_6)) + V_13*V_14*(G_13_14*sin(theta_13 - theta_14) - B_13_14*cos(theta_13 - theta_14))
	Pinj_14 =  V_14^2*G_14_14 + V_14*V_13*(G_14_13*cos(theta_14 - theta_13) + B_14_13*sin(theta_14 - theta_13)) + V_14*V_9*(G_14_9*cos(theta_14 - theta_14) + B_14_9*sin(theta_14 - theta_9))
	Qinj_14 = -V_14^2*B_14_14 + V_14*V_13*(G_14_13*sin(theta_14 - theta_13) - B_14_13*cos(theta_14 - theta_13)) + V_14*V_9*(G_14_9*sin(theta_14 - theta_14) - B_14_9*cos(theta_14 - theta_9))
	err[1] = P_1 - Pinj_1
	err[2] = Q_1 - Qinj_1
	err[3] = P_2 - Pinj_2
	err[4] = Q_2 - Qinj_2
	err[5] = P_3 - Pinj_3
	err[6] = Q_3 - Qinj_3
	err[7] = P_4 - Pinj_4
	err[8] = Q_4 - Qinj_4
	err[9] = P_5 - Pinj_5
	err[10] = Q_5 - Qinj_5
	err[11] = P_6 - Pinj_6
	err[12] = Q_6 - Qinj_6
	err[13] = P_7 - Pinj_7
	err[14] = Q_7 - Qinj_7
	err[15] = P_8 - Pinj_8
	err[16] = Q_8 - Qinj_8
	err[17] = P_9 - Pinj_9
	err[18] = Q_9 - Qinj_9
	err[19] = P_10 - Pinj_10
	err[20] = Q_10 - Qinj_10
	err[21] = P_11 - Pinj_11
	err[22] = Q_11 - Qinj_11
	err[23] = P_12 - Pinj_12
	err[24] = Q_12 - Qinj_12
	err[25] = P_13 - Pinj_13
	err[26] = Q_13 - Qinj_13
	err[27] = P_14 - Pinj_14
	err[28] = Q_14 - Qinj_14
	return err
end

function pf_guess(ps::pf_data{T}) where T <: Real
    u = zeros(T, 2Nbus)
    n = 1
    for i = 1:Nbus
        if buses[:bus_type][i] == "PQ"
            u[n] = 1.0          # V
            u[n+1] = 0.0        # theta
            n += 2
        elseif buses[:bus_type][i] == "PV"
            u[n] = 0.0          # Q
            u[n+1] = 0.0        # theta
            n += 2
        elseif buses[:bus_type][i] == "SL"
            u[n] = 0.0          # P
            u[n+1] = 0.0        # Q
            n += 2
        end
    end
    return u
end

@info "Solving for steady state power flow"
pf_u = ParametricModels.findroot(pf_data(), pf_error, pf_guess; ftol = 1e-12)
@info "Finished"
