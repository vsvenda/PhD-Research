"""
The geodesic is the second step of an MBAM iteration (line).
This module performs the geodesic calculation.
The results are saved in ``data/(model_line.name)_geo.json``
"""
module Geodesic_line

import ..Model_line: model_line, xi_line, M_line, N_line

import JSON, DifferentialEquations

import Geometry.Geodesics: vi, GeodesicIntegrator, step!, solution
import Printf: @sprintf
import LinearAlgebra: norm, svd

result = JSON.parsefile(@sprintf("data/%s_fitresult.json", model_line.name))

x = result["bestfit_x"] .|> Float64
jacobian = [result["jacobian"][j][i] for i = 1:M_line, j = 1:N_line]

v = vi(x, jacobian, model_line.Avv; i = 0, forward = true)
integrator = GeodesicIntegrator(x, v, model_line.jacobian, model_line.Avv, DifferentialEquations.BS3(); use_svd = true, abstol = 1e-3, reltol=1e-3)
#λ

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
open(@sprintf("data/%s_geo.json", model_line.name), "w") do io
    JSON.print(io, geo, 2)
end

r = model_line.r(geo.xs[end,:])
@info "Fit at end of geodesic: $(norm(r))"
end # module
