"""
The fit is the first step of an MBAM iteration (voltage constrained).
The model parameters are adjusted to minimize the error to the nominal values.
This module performs this function
The results are saved in ``data/(model_volt_con.name)_fitresult.json``
"""
module Fit_volt_con

import ..Model_volt_con: model_volt_con, xi_volt_con, N_volt_con
#export result
import ModularLM, Models, JSON
import Printf: @sprintf
result = Models.fit!(model_volt_con, xi_volt_con, ModularLM.ModularLMAlgorithm(), stopcheckers = ModularLM.StopCheckers(maxdfev = -1, maxd2fev = -1, cgoal = 1e-6), callbacks = Function[ModularLM.print_state_summary, ModularLM.print_summary])

open(@sprintf("data/%s_fitresult.json", model_volt_con.name), "w") do io
    JSON.print(io, result, 2)
end

print(result)
end # module