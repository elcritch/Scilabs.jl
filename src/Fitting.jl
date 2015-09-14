module Fitting

using Distributions
using Optim

export fit_weibul, simple_fit, r2, min_sqerror_with

function fit_weibul(data)


    y = log(sort(data))
    rank = 1:length(data)  # ranks = {1, 2, 3, ... 10}
    median_rank = (rank - 0.3)/(length(rank) + 0.4)
    x = log(-log(1 - median_rank))

    intercept, slope = linreg(x,y)

    shape = 1/slope
    x_intercept = - intercept / shape
    scale = exp(-x_intercept/slope)

#     @show(shape, scale)
    return Weibull(shape, scale)
end

function simple_fit(x, y)

    fit = GLM.lm([ones(x) x], y)
    b,a = fit.pp.beta0;

    fit_r2 = r2(y, fit);

    return { :fit => fit, :r2 => fit_r2, :a => a, :b => b, :f => (x -> a*x + b),
        :fstr => "\$$( ff(a,1)) \\,x + $(ff(b,1))\$"  }
end

function r2(ydata, fit)
    1-sumabs2(GLM.residuals(fit))/sumabs2(ydata - mean(ydata)) # or 1-var(residuals(mod))/var(y)
end


function min_sqerror_with(func::Function, x, y)
    function sqerror(C)
        err = 0.0
        for i in 1:length(x)
            ŷ = func(x[i], C)
            err += (y[i] - ŷ)^2
        end
        return err
    end

    return sqerror
end

function optimize(func::Function, x::Array, y::Array, params)
    return optimize(min_sqerror_with(func, x, y), Float64[params...])
end

end
