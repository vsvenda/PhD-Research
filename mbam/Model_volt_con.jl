"""
Defines the voltages model with contraints to be used for MBAM.
It should export the following:

M_con: The number of model predictions \n
N_con: The number of model parameters \n
xi_con: A vector of initial/default parameter values \n
model_con: Models.Model{M,N} that implements the model
"""
module Model_volt_con;

import ..System_info: Ybus, yline, a, Bc, nl, nbus, PFlineIndex, ImlineIndex, fbus, tbus, npi, npf, nim, nvi, nti, meas_data, meas_var, m_outage, refbus, x_start;
import ..Model_volt_uncon: model_volt_uncon
import JSON
import Printf: @sprintf
result = JSON.parsefile(@sprintf("data/%s_fitresult.json", model_volt_uncon.name))
x_volt_uncon = result["bestfit_x"] .|> Float64

export M_volt_con, N_volt_con, xi_volt_con, model_volt_con;

var_out = 1e3; # variance for measurements not taken into account

# unobservable states (note the unobservable state indexes)
theta_out = [];
theta_out = theta_out.-refbus;
V_out = [];

function h(x::Vector{T}) where T <: Real
	# Voltage angles/magnitude - theta/V (with constraints) **************************************************************************
	state_cnt = 1;
	theta = []; # theta array initialization
	if refbus == 1
		push!(theta,0.0);
	end
	for i = 1:(nbus-refbus)
		if in(i,theta_out)
			push!(theta,0.0);
		elseif x_volt_uncon[i] >= 0
			push!(theta,exp(x[state_cnt]));
			state_cnt+=1;
		else
			push!(theta,-exp(x[state_cnt]));
			state_cnt+=1;
		end
	end
	V = []; # V array initialization
	for i = 1:nbus
		if in(i,V_out)
			push!(V,0.0);
		else
			push!(V,exp(x[state_cnt]));
			state_cnt+=1;
		end
	end
	# *******************************************************************************************************************************

	
	# Forming equations for complex voltage (needed for calculating Pi/Qi; Pf/Qf and Im) - Vcmplx **********************************
	Vcmplx = []; # Vcmplx array initialization
	for i = 1:length(V)
		Vcmplx_temp = V[i]*(cos(theta[i])+sin(theta[i])*im);
		push!(Vcmplx, Vcmplx_temp);
	end
	# ******************************************************************************************************************************
	
	# Active/reactive power injections - Pi/Qi *************************************************************************************
	if npi != 0 # Note: power injection measurements measure both active and reactive power (Pi and Qi come in pairs). This is expected from realistic measurement instruments.
		Icmplx = Ybus*Vcmplx;
		Pi = []; # Pi array initialization
		Qi = []; # Qi array initialization
		for i = 1:npi
			Pi_temp = real(Vcmplx[fbus[i]]*conj(Icmplx[fbus[i]]));
			push!(Pi,Pi_temp);
			Qi_temp = imag(Vcmplx[fbus[i]]*conj(Icmplx[fbus[i]]));
			push!(Qi,Qi_temp);
		end
	end
	# ******************************************************************************************************************************
	
	
	# Active/reactive power flows - Pf/Qf ******************************************************************************************
	if npf != 0 # Note: again Pf and Qf measurements come in pairs.
		Pf = []; # Pf array initialization
		Qf = []; # Qf array initialization
		for i = 1:length(PFlineIndex)
			if nl[PFlineIndex[i]] == fbus[i+2*npi] # measurement sending bus of a line corresponds to sending bus defined by the network
				Pf_temp = real(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-a[PFlineIndex[i]]*Vcmplx[tbus[i+2*npi]])*yline[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)+Bc[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)*Vcmplx[fbus[i+2*npi]]));
				Qf_temp = imag(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-a[PFlineIndex[i]]*Vcmplx[tbus[i+2*npi]])*yline[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)+Bc[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)*Vcmplx[fbus[i+2*npi]]));
			else # measurement sending bus of a line does not correspond to sending bus defined by the network
				Pf_temp = real(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-Vcmplx[tbus[i+2*npi]]/a[PFlineIndex[i]])*yline[PFlineIndex[i]]+
						  Bc[PFlineIndex[i]]*Vcmplx[fbus[i+2*npi]]));
				Qf_temp = imag(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-Vcmplx[tbus[i+2*npi]]/a[PFlineIndex[i]])*yline[PFlineIndex[i]]+
						  Bc[PFlineIndex[i]]*Vcmplx[fbus[i+2*npi]]));
			end
			push!(Pf,Pf_temp);
			push!(Qf,Qf_temp);
		end
	end
	# ******************************************************************************************************************************
	
	
	# Current magnitudes - Im ******************************************************************************************************
	if nim != 0
		Im = []; # Im array initialization
		for i = 1:length(ImlineIndex)
			if nl[ImlineIndex[i]] == fbus[i+2*(npi+npf)] # measurement sending bus of a line corresponds to sending bus defined by the network
				Im_temp = abs((Vcmplx[fbus[i+2*(npi+npf)]]-a[ImlineIndex[i]]*Vcmplx[tbus[i+2*(npi+npf)]])*yline[ImlineIndex[i]]/(a[ImlineIndex[i]]^2))
			else
				Im_temp = abs((Vcmplx[fbus[i+2*(npi+npf)]]-Vcmplx[tbus[i+2*(npi+npf)]]/a[ImlineIndex[i]])*yline[ImlineIndex[i]]);
			end
			push!(Im,Im_temp);
		end
	end
	# ******************************************************************************************************************************
	
	
	# Forming output vector h(x) ***************************************************************************************************
	# Note: measurements are ordered as: [Pi Qi Pf Qf Im theta V]
	h = T[] # h vector initialization
	if npi != 0 	# power (active/reactive) injection - Pi/Qi
		for i = 1:npi
			push!(h,Pi[i])
		end
		for i = 1:npi
			push!(h,Qi[i])
		end
	end
	if  npf != 0 	# power (active/reactive) flow - Pf/Qf
		for i = 1:npf
			push!(h,Pf[i])
		end
		for i = 1:npf
			push!(h,Qf[i])
		end
	end
	if nim != 0 	# current magnitude - Im
		for i = 1:nim
			push!(h,Im[i])
		end
	end
	if nti != 0		# voltage angle - theta
		for i = 1:nti
			push!(h,theta[fbus[i+2*(npi+npf)+nim]])
		end
	end	
	if nvi != 0 	# voltage magnitude - V
		for i = 1:nvi
			push!(h,V[fbus[i+2*(npi+npf)+nim+nti]])
		end
	end
	
	# ******************************************************************************************************************************

	return h;
end

# Initial/default parameter values ***********************
# flat start - theta = 0.0; V = 1.0
# xi_volt_con = [0.0];
# for i = 2:(nbus-length(theta_out)-refbus)
	# push!(xi_volt_con,0.0);
# end
# for i = 1:(nbus-length(V_out))
	# push!(xi_volt_con,1.0);
# end

# previous time instance start 
# FIX THIS WHEN OUTAGES ARE CONSIDERED
if x_start[1]>=0
	xi_volt_con = [log(x_start[1])];
else
	xi_volt_con = [log(-x_start[1])];
end
for i = 2:(nbus-refbus)
	if x_start[i]>=0
		push!(xi_volt_con,log(x_start[i]))
	else
		push!(xi_volt_con,log(-x_start[i]))
	end
end
for i = 1:nbus
	push!(xi_volt_con,log(x_start[nbus+i]))
end

# Measured values (data) *******************************
data = [];
for i = 1:length(meas_data)
	push!(data,meas_data[i]);
end
# ******************************************************


# Measurement variances (weights) **********************
weights = [];
for i = 1:length(meas_var)
	if m_outage[i] == 1 #|| in(i,theta_out) || in(i,V_out.+size(Ybus,1))
		push!(weights,(1/sqrt(var_out))); # measurement instrument outage occured
	else
		push!(weights,(1/sqrt(meas_var[i])));
	end
end
# ******************************************************

"""
Residual function
Inputs same as y(x)
outputs: (data - model)*weights
"""
function r(x)
    return weights.*(data - h(x))
end

import Models
M_volt_con = length(data) 		 # Number of model outputs
N_volt_con = length(xi_volt_con) # Number of model inputs (parameters)

# This will create a model using automatic differentiation (generally preferred)
model_volt_con = Models.Model(M_volt_con,N_volt_con,r,Val(true),"VoltageEstimation_constrained")
# println("Evaluating the voltage model at the initial point (constrainted)")
# println("Residuals = ",model_volt_con.r(xi_volt_con))  		#evaluating model (residual)
# println("Jacobian = ",model_volt_con.jacobian(xi_volt_con))   #evaluating model (residual)

# This will create a model using finite difference derivatives with Richardson Extrapolation
# Generally, the automatic differentiation is preferred
# modelFD_con = Models.Model(M_volt_con,N_volt_con,r,Val(false),"StateEstimation_constrained")

end # module
