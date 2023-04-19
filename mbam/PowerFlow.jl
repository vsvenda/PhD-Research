module PowerFlow

import ..System_info: B, G, bus_type, P_meas, Q_meas, V_meas, theta_meas # I CAN IMPORT THESE FROM MY MODEL IN MATLAB
export pf_u

# form Ybus matrix based on B_ij and G_ij values
# ...
# ...
# ...

# setting inital values for vector u
u = []; # vector u initialization
for i = 1:size(Ybus,1)
    if bus_type == 0 	 # ** PQ bus **
        push!(u,1.0); # V
        push!(u,0.0); # theta
    elseif bus_type == 2 # ** PV bus **
        push!(u,0.0); # Q
        push!(u,0.0); # theta
    elseif bus_type == 1 # ** Slack bus **
        push!(u,0.0); # P
        push!(u,0.0); # Q
    end
end

# setting up P, Q, V, theta
P = []; Q = []; V = []; theta = [];
for i = 1:size(Ybus,1)
    if bus_type == 0 	 # ** PQ bus **
        push!(P,P_meas[i]);  # P
		push!(Q,Q_meas[i]);  # Q
		push!(V,u[i]); 		 # V
		push!(theta,u[i+1]); # theta
    elseif bus_type == 2 # ** PV bus **
        push!(P,P_meas[i]);  # P
		push!(Q,u[i]);  	 # Q
		push!(V,V_meas[i]);  # V
		push!(theta,u[i+1]); # theta
    elseif bus_type == 1 # ** Slack bus **
        push!(P,u[i]);    # P
		push!(Q,u[i+1]);  # Q
		push!(V,V_meas[i]); 		  # V
		push!(theta,theta_meas[i+1]); # theta
    end
end

# forming power injection (Pi/Qi) equations
Vcmplx = []; # Vcmplx array initialization
for i = 1:length(V)
	Vcmplx_temp = V[i]*(cos(theta[i])+sin(theta[i])*im);
	push!(Vcmplx, Vcmplx_temp);
end
Icmplx = Ybus*Vcmplx;
Pi = []; # Pi array initialization
Qi = []; # Qi array initialization
for i = 1:npi
	Pi_temp = real(Vcmplx[fbus[i]]*conj(Icmplx[fbus[i]]));
	push!(Pi,Pi_temp);
	Qi_temp = imag(Vcmplx[fbus[i]]*conj(Icmplx[fbus[i]]));
	push!(Qi,Qi_temp);
end

# forming the error vector (err)
err = []; # err initialization
for i = 1:size(Ybus,1)
	err_temp = P[i] - Pi[i];
	push!(err, err_temp);
end

# execute Power Flow calculations
pf_u = ParametricModels.findroot(err??, u??; ftol = 1e-12)


end # module