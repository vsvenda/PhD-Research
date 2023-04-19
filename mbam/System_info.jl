"""
Details of the examined test system are defined here.
"""
module System_info

using MAT

# IEEE Networks
file = matopen("C:\\Users\\Vanja\\Documents\\Tufts\\Tufts Research\\MATLAB Code\\LF-SE-EKF_v3-MBAM\\Julia_networkInfo.mat")
# Matpower 2746wp Network
#file = matopen("C:\\Users\\Vanja\\Documents\\Tufts\\Tufts Research\\MATLAB Code\\SE_2746wp\\Julia_networkInfo.mat")


# Bus admittance matrix
Ybus = read(file,"Ybus")

# Line (branch) admittance
yline = read(file,"yline")
if length(yline) > 1
	yline = vec(yline)	# converting to column vector
elseif isempty(yline)
	yline = [];
else
	yline = [yline];
end

# Transformer ratio
a = read(file,"a")
if length(a) > 1
	a = vec(a)			# converting to column vector
elseif isempty(a)
	a = [];
else
	a = [a];
end

# Line (branch) susceptance 
Bc = read(file,"Bc")
if length(Bc) > 1
	Bc = vec(Bc)		# converting to column vector
elseif isempty(Bc)
	Bc = [];
else
	Bc = [Bc];
end

# sending bus of each line as defined by the network
nl = read(file,"nl")
nl = Int.(nl) 		# converting to Int
if length(nl) > 1
	nl = vec(nl)		# converting to column vector
elseif isempty(nl);
	nl = [];
else
	nl = [nl];
end

# receiving bus of each line as defined by the network
nr = read(file,"nr")
nr = Int.(nr) 		# converting to Int
if length(nr) > 1
	nr = vec(nr)	 	# converting to column vector
elseif isempty(nr);
	nr = [];
else
	nr = [nr];
end

# number of network buses
nbus = read(file,"nbus")
nbus = trunc.(Int,nbus) # converting to Int

# number of network branches
nbr = read(file,"nbr")
nbr = trunc.(Int,nbr) # converting to Int

# sending bus of each line as defined by the network
refbus = read(file,"opt6")
refbus = trunc.(Int,refbus) # converting to Int

close(file)	

# IEEE Networks
file = matopen("C:\\Users\\Vanja\\Documents\\Tufts\\Tufts Research\\MATLAB Code\\LF-SE-EKF_v3-MBAM\\Julia_measInfo.mat")
# Matpower 2746wp Network
#file = matopen("C:\\Users\\Vanja\\Documents\\Tufts\\Tufts Research\\MATLAB Code\\SE_2746wp\\Julia_measInfo.mat")

# PF measurement line (branch) indexes
PFlineIndex = read(file,"PFlineIndex")
PFlineIndex = trunc.(Int,PFlineIndex) 	# converting to Int (as they are used as index values)
if length(PFlineIndex) > 1
	PFlineIndex = vec(PFlineIndex)			# converting to column vector
elseif isempty(PFlineIndex);
	PFlineIndex = [];
else
	PFlineIndex = [PFlineIndex];
end

# Current measurement line (branch) indexes
ImlineIndex = read(file,"ImlineIndex")
ImlineIndex = trunc.(Int,ImlineIndex)
if length(ImlineIndex) > 1
	ImlineIndex = vec(ImlineIndex)			# converting to column vector
elseif isempty(ImlineIndex)
	ImlineIndex = [];
else
	ImlineIndex = [ImlineIndex];
end

# Sending buses
fbus = read(file,"fbus")
fbus = trunc.(Int,fbus)
if length(fbus) > 1
	fbus = vec(fbus)	# converting to column vector
elseif isempty(fbus);
	fbus = [];
else
	fbus = [fbus];
end

# Receiving buses
tbus = read(file,"tbus")
tbus = trunc.(Int,tbus)
if length(tbus) > 1
	tbus = vec(tbus)	# converting to column vector
elseif isempty(tbus)
	tbus = [];
else
	tbus = [tbus];
end

# Number of power injection measurements
npi = read(file,"npi")
npi = trunc.(Int,npi)

# Number of power flow measurements
npf = read(file,"npf")
npf = trunc.(Int,npf)

# Number of current magnitude measurements
nim = read(file,"nim")
nim = trunc.(Int,nim)

# Number of voltage magnitude measurements
nvi = read(file,"nvi")
nvi = trunc.(Int,nvi)

# Number of voltage angle measurements
nti = read(file,"nti")
nti = trunc.(Int,nti)

# Measurement values
meas_data = read(file,"meas_data")
if length(meas_data) > 1
	meas_data = vec(meas_data)	# converting to column vector
elseif isempty(meas_data)
	meas_data = [];
else
	meas_data = [meas_data];
end

# Measurement type
meas_type = read(file,"meas_type")
if length(meas_type) > 1
	meas_type = vec(meas_type)	# converting to column vector
elseif isempty(meas_type)
	meas_type = [];
else
	meas_type = [meas_type];
end

# Measurements variances
meas_var = read(file,"meas_var")
if length(meas_var) > 1
	meas_var = vec(meas_var)	# converting to column vector
elseif isempty(meas_var)
	meas_var = [];
else
	meas_var = [meas_var];
end

# Outaged measurement instruments
m_outage = read(file,"m_outage")
if length(m_outage) > 1
	m_outage = vec(m_outage)	# converting to column vector
elseif isempty(m_outage)
	m_outage = [];
else
	m_outage = [m_outage];
end

# Voltage values from previous time instance
x_start = read(file,"E_start")
x_start = vec(x_start)	# converting to column vector


close(file)

end # module
