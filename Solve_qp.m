function [uopt, info, solver] = Solve_qp(solver)
    if isfield(solver,'xx') && ~isempty(solver.xx)  % 只在有有效xx时warm-start
        solver.prob.xx = solver.xx;  % 用itr或intpnt取决于MOSEK版本，试itr
    end
    [rcode, res] = mosekopt('minimize', solver.prob, solver.param);
    if rcode == 0 && isfield(res,'sol') && isfield(res.sol,'itr')
        info = res.sol.itr.prosta;  % 用itr for QP
        uopt = res.sol.itr.xx;
        solver.xx = uopt;  % 保存用于下次
    else
        info = 'ERROR';  % 或 res.info if available
        uopt = [];  % 失败返回空
        warning('MOSEK solve failed: %s', info);
    end
end