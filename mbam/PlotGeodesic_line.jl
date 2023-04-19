module PlotGeodesic_line

using ..Model_line
using PyPlot
import JSON
import Printf: @sprintf

geo = JSON.parsefile(@sprintf("data/%s_geo.json", model_line.name))
figure()
for i = 1:length(geo["xs"])
	#plot(geo["ts"], geo["xs"][i]) # plot xs versus ts (parameter space distance)
	plot(geo["τs"], geo["xs"][i]) # plot xs versus taus (geodesic distance)
end
show()
figure()
vf = [ geo["vs"][i][end] for i = 1:N_line]
bar(1:N_line, vf)
show()

end # module