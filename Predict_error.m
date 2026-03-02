function Ss = Predict_error(param)
    Np      = param.Np;
    x_opt   = param.x_opt;
    
    err_v   = x_opt(9:11,:);
    v_err   = sum(vecnorm(err_v)) / Np;
    
    err_w   = x_opt(12:end,:);
    w_err   = sum(vecnorm(err_w)) / Np;
    
    Ss      = [v_err; w_err];
end