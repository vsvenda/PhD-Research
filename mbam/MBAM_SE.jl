module MBAMExample

case = 1; 	# case 1 - voltage estimation
			# case 2 - line estimation
			# case 3 - both

println("Loading network parameters and measurements . . .\n")
include("System_info.jl")

if case == 1 || case == 3
# Voltage estimation ******************************************
	println(" * * * * * VOLTAGE ESTIMATION MODEL * * * * *\n")
	println("Forming the voltage model (unconstrained) . . .\n")
	include("Model_volt_uncon.jl")

	println("Fitting the voltage model (unconstrained) . . .")
	include("Fit_volt_uncon.jl")
	#sleep(60)
	
	println("\nForming the voltage model (constrained) . . .\n")
	include("Model_volt_con.jl")

	println("Fitting the voltage model (constrained) . . .")
	include("Fit_volt_con.jl")

	println("\nGeodesic calculations (voltage) . . .")
	include("Geodesic_volt.jl")

	println("\nPloting geodesics (voltage) . . .\n")
	include("PlotGeodesic_volt.jl")
# *************************************************************
end

if case == 2 || case == 3
# Line estimation *********************************************
	println(" * * * * * LINE ESTIMATION MODEL * * * * *\n")
	
	# println("\nForming the voltage model (unconstrained) . . .")
	# include("Model_volt_uncon.jl")

	# println("\nFitting the voltage model (unconstrained) . . .")
	# include("Fit_volt_uncon.jl")
	
	
	println("\nForming the line model . . .")
	include("Model_line.jl")

	println("\nFitting the line model . . .")
	include("Fit_line.jl")

	println("\nGeodesic calculations (line) . . .")
	include("Geodesic_line.jl")

	println("\nPloting geodesics (line) . . .")
	include("PlotGeodesic_line.jl")
# *************************************************************
end

end # module
