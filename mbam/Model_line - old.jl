"""
Defines the line model to be used for MBAM.
It should export the following:

M_line: The number of model predictions \n
N_line: The number of model parameters \n
xi_line: A vector of initial/default parameter values \n
model_line: Models.Model{M,N} that implements the model
"""
module Model_line;

import ..System_info: yline, a, Bc, nl, nr, nbus, nbr, PFlineIndex, ImlineIndex, fbus, tbus, meas_data, meas_var, meas_type, m_outage, refbus, x_start, x_true;
export M_line, N_line, xi_line, model_line;

# import ..Model_volt_uncon: model_volt_uncon   # needed if estimated voltage values assumed
# import JSON
# import Printf: @sprintf
# result = JSON.parsefile(@sprintf("data/%s_fitresult.json", model_volt_uncon.name))
# x_volt_uncon = result["bestfit_x"] .|> Float64

# unobservable lines (unobservable admittances) of reduced network
y_oc = []; # open circuit
y_sc = []; # short circuit

# Reducing the original network **********************************************************
bus_unob = [6; 11; 12; 13]; # initial unobservable buses
#bus_unob = Array(1:nbus); 	# if entire network is to be observed

line_obs = ones(length(yline));  # vector denoting observable / unobservable lines (initially all observable)

bus_ID 		= 	Array(1:nbus); 	 # initialize bus index
line_ID 	= 	Array(1:nbr); 	 # initialize line index
neigh_bus 	= 	Int64[]; 		 # initialize neigbours to unobservable buses
# neigh_yline = 	deepcopy(yline);
# neigh_nl 	= 	deepcopy(nl);
# neigh_nr 	= 	deepcopy(nr);
# neigh_a 	= 	deepcopy(a);
# neigh_Bc 	= 	deepcopy(Bc);

for i = 1:length(yline) # denote first neighbours to unobservable buses 
	if (nl[i] in bus_unob) && !(nr[i] in bus_unob)
		push!(neigh_bus,nr[i]);
	elseif (nr[i] in bus_unob) && !(nl[i] in bus_unob)
		push!(neigh_bus,nl[i]);
	end
end
unique!(neigh_bus);

for i = 1:length(yline) # denote unobservable lines 
	if ((nl[i] in bus_unob) || (nl[i] in neigh_bus)) && ((nr[i] in bus_unob) || (nr[i] in neigh_bus))
		line_obs[i] = 0.0;
	end
end
println(line_obs)

for i = length(fbus):-1:1		# remove info about corresponding removed measurements
	if !((fbus[i] in bus_unob) || ((fbus[i] in neigh_bus) && ((tbus[i] == 0) || (tbus[i] in bus_unob))))
		deleteat!(fbus,i); deleteat!(tbus,i); 	# bus measurement indexes
		deleteat!(meas_data,i); 				# measured value
		deleteat!(meas_var,i);  				# measurement variance
		deleteat!(meas_type,i); 				# measurement type
		deleteat!(m_outage,i); 					# outaged measurement
	end
end

for i = length(yline):-1:1	# reduce network to unobservable parts
	if !(nr[i] in bus_unob) && !(nl[i] in bus_unob) # with respect to unobservable parts
		# if (nr[i] in bus_ID) && !(nr[i] in neigh_bus);
			# deleteat!(bus_ID,findall(x->x==nr[i],bus_ID))
		# end
		# if (nl[i] in bus_ID) && !(nl[i] in neigh_bus)
			# deleteat!(bus_ID,findall(x->x==nl[i],bus_ID));
		# end
		deleteat!(PFlineIndex,findall(x->x==line_ID[i],PFlineIndex)) 	# remove power flow measurements of corresponding removed line
		deleteat!(ImlineIndex,findall(x->x==line_ID[i],ImlineIndex)); 	# remove current measurements of corresponding removed line
		# deleteat!(line_ID,i); 	deleteat!(yline,i); 					# remove corresponding line (index; parameters)
		# deleteat!(nl,i); 	  	deleteat!(nr,i);						# remove leading / receving buses of corresponding removed line
		# deleteat!(Bc,i);												# remove susceptance of corresponding removed line
		# deleteat!(a,i);													# remove transformation ratio of corresponding removed line
	end
	# if (!(neigh_nl[i] in neigh_bus) || (neigh_nr[i] in bus_unob)) && (!(neigh_nr[i] in neigh_bus) || (neigh_nl[i] in bus_unob)) # with respect to neighbour buses
		# deleteat!(neigh_nl,i); deleteat!(neigh_nr,i);
		# deleteat!(neigh_yline,i);
		# deleteat!(neigh_Bc,i);												
		# deleteat!(neigh_a,i);	
	# end
end	

# for i = length(fbus):-1:1		# remove info about corresponding removed measurements
	# if !(fbus[i] in bus_ID)  || (!(tbus[i] == 0) && !(tbus[i] in bus_ID)) || ((fbus[i] in neigh_bus) && (tbus[i] in neigh_bus))
		# deleteat!(fbus,i); deleteat!(tbus,i); 	# bus measurement indexes
		# deleteat!(meas_data,i); 				# measured value
		# deleteat!(meas_var,i);  				# measurement variance
		# deleteat!(meas_type,i); 				# measurement type
		# deleteat!(m_outage,i); 					# outaged measurement
	# end
# end
npi = sum(x->x==2,meas_type); 	# number of remaining power injection measurements
npf = sum(x->x==4,meas_type); 	# number of remaining power flow measurements
nim = sum(x->x==7,meas_type); 	# number of remaining current measurements
nti = sum(x->x==6,meas_type); 	# number of remaining voltage angle measurements
nvi = sum(x->x==1,meas_type); 	# number of remaining voltage magnitude measurements

# println("\nLine information:")
# for i=1:length(nl)
	# println(i , " - Line " , line_ID[i] , " Lead bus : " , nl[i] , " Rec bus : " , nr[i]);
# end
println("\nMeasurement information:")
for i=1:length(meas_data)
	println(i , " - Fbus: " , fbus[i] , " Tbus: " , tbus[i] , " Meas type: " , meas_type[i] , " Meas value: " , meas_data[i] , " Meas var : " , meas_var[i] , " Outage? " , m_outage[i]);
end
# println("Number of 1.PF meas: ",npf,"; 2.PI meas: ",npi,"; 3.IM meas: ",nim,"; 4.V meas: ",nvi,"; 5.theta meas: ",nti,)
# println(PFlineIndex)
# # re-enumerating *************
# for i = 1:length(fbus) 	 		# measurement buses    
	# fbus[i] = findfirst(x->x==fbus[i],bus_ID);
	# if tbus[i] != 0
		# tbus[i] = findfirst(x->x==tbus[i],bus_ID);
	# end
# end
# for i = 1:length(nl) 			# unobservable lines      
	# nl[i] = findfirst(x->x==nl[i],bus_ID);
	# nr[i] = findfirst(x->x==nr[i],bus_ID);
# end
# for i = 1:length(PFlineIndex) 	# PF measurements
	# PFlineIndex[i] = findfirst(x->x==PFlineIndex[i],line_ID);
# end
# for i = 1:length(ImlineIndex)	# IM measurements
	# ImlineIndex[i] = findfirst(x->x==ImlineIndex[i],line_ID);
# end
# # for i = 1:length(neigh_bus)		# neighbour buses
	# # neigh_bus[i] = findfirst(x->x==neigh_bus[i],bus_ID);
# # end
# # for i = 1:length(neigh_nl)	  	# neighbour lines  
	# # if neigh_nl[i] in bus_ID
		# # neigh_nl[i] = findfirst(x->x==neigh_nl[i],bus_ID);
	# # else
		# # neigh_nl[i] = 0;
	# # end
	# # if neigh_nr[i] in bus_ID
		# # neigh_nr[i] = findfirst(x->x==neigh_nr[i],bus_ID);
	# # else
		# # neigh_nr[i] = 0;
	# # end
# # end
# ****************************************************************************************

function h(x::Vector{T}) where T <: Real
	# Line susceptance **************************************************************************************************************
	state_cnt = 1;
	yline_B = []; 		# line susceptance array initializaiton
	# nl_sc = [];	nr_sc = [];		# short circuit leading / receiving buses initialization
	# sort!(y_sc, rev = true);
	# for i = 1:length(y_sc)
		# push!(nl_sc,nl[y_sc[i]]);
		# push!(nr_sc,nr[y_sc[i]]);
		# if nr[y_sc[i]] in bus_ID
			# deleteat!(bus_ID,findall(x->x==y_sc[i],bus_ID));
		# end
		# deleteat!(yline,y_sc[i]); # short circuit (branch does not exist)
		# deleteat!(nl,y_sc[i]); 
		# deleteat!(nr,y_sc[i]);	
	# end
	for i = 1:length(yline)
		if line_obs[i] == 1.0
			push!(yline_B,imag(yline[i]));
		else
			if in(i,y_oc)
				push!(yline_B,0.0); # open circuit (branch tehnicaly exists but with Z->inf)
			else
				push!(yline_B,-exp(x[state_cnt])); # line susceptance will always be negative?
				state_cnt+=1;
			end
		end
	end
	# ******************************************************************************************************************************
	
	# Line admittance **************************************************************************************************************
	yline_est = []; 	# estimated yline array initialization
	for i = 1:length(yline)
		yline_c = real(yline[i])/imag(yline[i]);
		yline_est_temp = yline_c*yline_B[i]+yline_B[i]*im;
		push!(yline_est,yline_est_temp);
	end	
	# ******************************************************************************************************************************
	
	# Admittance matrix (Ybus) *****************************************************************************************************
	Ybus_est = zeros(Complex,length(bus_ID),length(bus_ID));     # initialize Ybus to zero        
	for i = 1:length(yline)	# forming off diagonal elements
		if a[i] <= 0
			a[i] = 1;
		end	
		# if !isempty(nl_sc) && ((nr[i] in nr_sc) || (nl[i] in nr_sc)) # short circuit branches (merge buses)
			# for k = 1:length(nr_sc)
				# if nr[i] == nr_sc[k]
					# Ybus_est[nl[i],nl_sc[k]] = Ybus_est[nl[i],nl_sc[k]]-yline_est[i]/a[i];
					# Ybus_est[nl_sc[k],nl[i]] = Ybus_est[nl[i],nl_sc[k]];
				# elseif nl[i] == nr_sc[k]
					# Ybus_est[nr[i],nl_sc[k]] = Ybus_est[nr[i],nl_sc[k]]-yline_est[i]/a[i];
					# Ybus_est[nl_sc[k],nr[i]] = Ybus_est[nr[i],nl_sc[k]];
				# end
			# end
		# else
			Ybus_est[nl[i],nr[i]] = Ybus_est[nl[i],nr[i]]-yline_est[i]/a[i];
			Ybus_est[nr[i],nl[i]] = Ybus_est[nl[i],nr[i]];
		# end
	end 	
	for i = 1:length(bus_ID)	# forming main diagonal elements
        for k = 1:length(yline)
			# if !isempty(nl_sc) && (bus_ID[i] in nl_sc) && ((nr[k] in nr_sc) || (nl[k] in nr_sc)) # short circuit branches (merge buses)
				# for j = 1:length(nr_sc)
					# if nr[k] == nr_sc[j] && bus_ID[i] == nl_sc[j]
						# if bus_ID[i] <= nl[k]
							# Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]/(a[k]^2)+Bc[k];
						# else
							# Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]+Bc[k];
						# end
					# elseif nl[k] == nr_sc[j] && bus_ID[i] == nl_sc[j]
						# if bus_ID[i] <= nr[k]
							# Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]/(a[k]^2)+Bc[k];
						# else
							# Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]+Bc[k];					
						# end
					# end
				# end
			if nl[k] == i
				Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]/(a[k]^2)+Bc[k];
            elseif nr[k] == i
				Ybus_est[i,i] = Ybus_est[i,i]+yline_est[k]+Bc[k];
            end
        end
	end
	# for i = 1:length(neigh_bus) # adding neighbouring lines to main diagonal
		# for k = 1:length(neigh_yline)
			# if neigh_nl[k] == neigh_bus[i]
				# Ybus_est[neigh_bus[i],neigh_bus[i]] = Ybus_est[neigh_bus[i],neigh_bus[i]]+neigh_yline[k]/(neigh_a[k]^2)+neigh_Bc[k];
			# elseif neigh_nr[k] == neigh_bus[i]
				# Ybus_est[neigh_bus[i],neigh_bus[i]] = Ybus_est[neigh_bus[i],neigh_bus[i]]+neigh_yline[k]+neigh_Bc[k];
			# end
		# end
	# end
	# ******************************************************************************************************************************
	
	# Voltage angles/magnitude - theta/V  ******************************************************************************************
	theta = []; V = [] # theta and V array initialization
	for i = 1:length(bus_ID)
		push!(theta, x_true[bus_ID[i]]);
		push!(V, x_true[bus_ID[i]+nbus]);
		#push!(theta,1.0*x_volt_uncon[bus_ID[i]]);
		#push!(V,1.0*x_volt_uncon[bus_ID[i]+nbus]);
	end	
	# ******************************************************************************************************************************

	# Forming equations for complex voltage (needed for calculating Pi/Qi; Pf/Qf and Im) - Vcmplx **********************************
	Vcmplx = []; # Vcmplx array initialization
	for i = 1:length(V)
		Vcmplx_temp = V[i]*(cos(theta[i])+sin(theta[i])*im);
		push!(Vcmplx, Vcmplx_temp);
	end
	# ******************************************************************************************************************************
	
	# Active/reactive power injections - Pi/Qi *************************************************************************************
	if npi != 0  # Note: power injection measurements measure both active and reactive power (Pi and Qi come in pairs). This is expected from realistic measurement instruments.
		Icmplx = Ybus_est*Vcmplx;
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
				Pf_temp = real(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-a[PFlineIndex[i]]*Vcmplx[tbus[i+2*npi]])*yline_est[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)+Bc[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)*Vcmplx[fbus[i+2*npi]]));
				Qf_temp = imag(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-a[PFlineIndex[i]]*Vcmplx[tbus[i+2*npi]])*yline_est[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)+Bc[PFlineIndex[i]]/(a[PFlineIndex[i]]^2)*Vcmplx[fbus[i+2*npi]]));
			else # measurement sending bus of a line does not correspond to sending bus defined by the network
				Pf_temp = real(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-Vcmplx[tbus[i+2*npi]]/a[PFlineIndex[i]])*yline_est[PFlineIndex[i]]+
						  Bc[PFlineIndex[i]]*Vcmplx[fbus[i+2*npi]]));
				Qf_temp = imag(Vcmplx[fbus[i+2*npi]]*conj((Vcmplx[fbus[i+2*npi]]-Vcmplx[tbus[i+2*npi]]/a[PFlineIndex[i]])*yline_est[PFlineIndex[i]]+
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
				Im_temp = abs((Vcmplx[fbus[i+2*(npi+npf)]]-a[ImlineIndex[i]]*Vcmplx[tbus[i+2*(npi+npf)]])*yline_est[ImlineIndex[i]]/(a[ImlineIndex[i]]^2))
			else
				Im_temp = abs((Vcmplx[fbus[i+2*(npi+npf)]]-Vcmplx[tbus[i+2*(npi+npf)]]/a[ImlineIndex[i]])*yline_est[ImlineIndex[i]]);
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
	# if nti != 0		# voltage angle - theta		% NOTE : Voltage measurement disregarded (cannot be presented as functions of line parameters)
		# for i = 1:nti
			# push!(h,theta[fbus[i+2*(npi+npf)+nim]])
		# end
	# end	
	# if nvi != 0 	# voltage magnitude - V
		# for i = 1:nvi
			# push!(h,V[fbus[i+2*(npi+npf)+nim+nti]])
		# end
	# end	
	
	# ******************************************************************************************************************************

	return h;
end

# Initial/default parameter values ***********************
# true values from yline taken
# xi_line = [imag(yline[1])];
# for i = 2:length(yline)
	# push!(xi_line,imag(yline[i]));
# end
# flat start - line_B = 1.0
xi_line = [1.0];
for i = 2:length(yline)-length(y_oc)-length(y_sc)
	push!(xi_line,1.0);
end

# Measured values (data) *******************************
data = [];
for i = 1:(2*npi+2*npf+nim) # Voltage measurements are stored last in meas_data
	push!(data,meas_data[i]);
end
# ******************************************************

# Measurement variances (weights) **********************
weights = [];
for i = 1:(2*npi+2*npf+nim)	# Voltage measurements variances are stored last in meas_var
	if m_outage[i] == 1
		push!(weights,(1/sqrt(1e2))); # measurement instrument outage occured
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
M_line = length(data) 	 # Number of model outputs
N_line = length(xi_line) # Number of model inputs (parameters)

# This will create a model using automatic differentiation (generally preferred)
model_line = Models.Model(M_line,N_line,r,Val(true),"LineEstimation_unconstrained")
# println("Evaluating the line model at the initial point")
# println("Residuals = ",model_line.r(xi_line))  		#evaluating model (residual)
# println("Jacobian = ",model_line.jacobian(xi_line))   #evaluating model (residual)

# This will create a model using finite difference derivatives with Richardson Extrapolation
# Generally, the automatic differentiation is preferred
# modelFD_uncon = Models.Model(M_line,N_line,r,Val(false),"StateEstimation_unconstrained")

end # module
