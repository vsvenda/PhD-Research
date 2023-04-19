"""
The fit is the first step of an MBAM iteration (line).
The model parameters are adjusted to minimize the error to the nominal values.
This module performs this function
The results are saved in ``data/(model.name)_fitresult.json``
"""
module Fit_line

import ..Model_line: model_line, xi_line, N_line
#export result
import ModularLM, Models, JSON
import Printf: @sprintf
result = Models.fit!(model_line, xi_line, ModularLM.ModularLMAlgorithm())

open(@sprintf("data/%s_fitresult.json", model_line.name), "w") do io
    JSON.print(io, result, 2)
end

print(result)
end # module