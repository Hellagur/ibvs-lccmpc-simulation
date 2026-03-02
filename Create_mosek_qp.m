function solver = Create_mosek_qp(nvar)
    % 不固定ncon，让update_qp动态处理
    prob.c          = zeros(nvar,1);
    prob.a          = sparse(0, nvar);  % 初始为空
    prob.blc        = [];  % 动态设置
    prob.buc        = [];
    prob.blx        = -inf(nvar,1);
    prob.bux        = inf(nvar,1);
    % 占位的 Hessian
    prob.qosubi     = [];
    prob.qosubj     = [];
    prob.qoval      = [];
    
    param.MSK_IPAR_OPTIMIZER                = 'MSK_OPTIMIZER_INTPNT';
    param.MSK_IPAR_INTPNT_MAX_ITERATIONS    = 50;
    param.MSK_IPAR_NUM_THREADS              = 1;
    param.MSK_IPAR_LOG                      = 0;  % 0=关闭日志，1=简短，2=详细
    
    solver.prob     = prob;
    solver.param    = param;
end
