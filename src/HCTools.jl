module HCTools

using HomotopyContinuation, Gadfly


"""
    plot_step_sizes(tracker, x, t₁::Real, t₀::Real; kwargs...)
"""
function plot_step_sizes(tracker, x, t₁::Real, t₀::Real; kwargs...)
    PathTracking.setup!(tracker, x, t₁, t₀; kwargs...)
    last_t_dt = nothing
    t_dt_values = Vector{NTuple{2, Float64}}()
    rejections = Vector{NTuple{2, Float64}}()
    t = real(PathTracking.currt(tracker))
    Δt = abs(PathTracking.currΔt(tracker))
    last_t_dt = (t, Δt)
    PathTracking.step!(tracker)
    for _ in tracker
        t = real(PathTracking.currt(tracker))
        Δt = abs(PathTracking.currΔt(tracker))
        if t == last_t_dt[1] # still same t -> last step was rejected
            push!(rejections, last_t_dt)
        else
            push!(t_dt_values, last_t_dt)
        end
        last_t_dt = (t, Δt)
    end

    l1 = layer(x=map(first, t_dt_values), y=map(last, t_dt_values), Stat.step(direction=:vh),
        Geom.line)
    l2 = layer(x=map(first, rejections), y=map(last, rejections), Geom.point, color=[colorant"red"], shape=[Shape.xcross])
    Gadfly.with_theme(:default) do
        plot(l2, l1, Guide.xlabel("t"), Guide.ylabel("|Δt|"))
    end
end

end # module
