"""
The geodesic is the second step of an MBAM iteration (voltage).
This module performs the geodesic calculation.
The results are saved in ``data/(model_volt.name)_geo.json``
"""
module Geodesic_volt

import ..Model_volt_con: model_volt_con, xi_volt_con, M_volt_con, N_volt_con

import JSON, DifferentialEquations

import Geometry.Geodesics: vi, GeodesicIntegrator, step!, solution
import Printf: @sprintf
import LinearAlgebra: norm, svd

result = JSON.parsefile(@sprintf("data/%s_fitresult.json", model_volt_con.name))

x = result["bestfit_x"] .|> Float64
jacobian = [result["jacobian"][j][i] for i = 1:M_volt_con, j = 1:N_volt_con]

v = vi(x, jacobian, model_volt_con.Avv; i = 0, forward = true)
integrator = GeodesicIntegrator(x, v, model_volt_con.jacobian, model_volt_con.Avv, DifferentialEquations.BS3(); use_svd = true, abstol = 1e-3, reltol=1e-3)

Vnorm = norm(jacobian*v)

finished = false
while !finished
	
    step!(integrator)

    # Adjust stopping criterion for the geodesic here
    geo = solution(integrator)   
	@info "Geodesic step: $(length(geo.ts))"	
    dτdt = (geo.τs[end] - geo.τs[end-1])/(geo.ts[end] - geo.ts[end-1])
    if dτdt/Vnorm < 0.01
        global finished
        finished = true
    end
end    

step!(integrator)

geo = solution(integrator)
open(@sprintf("data/%s_geo.json", model_volt_con.name), "w") do io
    JSON.print(io, geo, 2)
end

r = model_volt_con.r(geo.xs[end,:])
@info "Fit at end of geodesic: $(norm(r))"
end # module
