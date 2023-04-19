"""
The fit is the first step of an MBAM iteration (voltage unconstrained).
The model parameters are adjusted to minimize the error to the nominal values.
This module performs this function
The results are saved in ``data/(model_volt_uncon.name)_fitresult.json``
"""
module Fit_volt_uncon

import ..Model_volt_uncon: model_volt_uncon, xi_volt_uncon, N_volt_uncon
#export result
import ModularLM, Models, JSON
import Printf: @sprintf
result = Models.fit!(model_volt_uncon, xi_volt_uncon, ModularLM.ModularLMAlgorithm(), stopcheckers = ModularLM.StopCheckers(maxdfev = -1, maxd2fev = -1, cgoal = 1e-4), callbacks = Function[ModularLM.print_state_summary, ModularLM.print_summary])

open(@sprintf("data/%s_fitresult.json", model_volt_uncon.name), "w") do io
    JSON.print(io, result, 2)
end

print(result)
end # module
