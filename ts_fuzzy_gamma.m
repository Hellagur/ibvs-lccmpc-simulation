function gamma = ts_fuzzy_gamma(param, hist, k)
    
    % Input range (for saturation, match the FIS range.)
    v_min   = param.Ss_min(1);  % 0.2
    v_max   = param.Ss_max(1);  % 0.5
    w_min   = param.Ss_min(2);  % 0.045
    w_max   = param.Ss_max(2);  % 0.095
    
    % Saturation input
    v_err   = hist.Ss(1,k);
    w_err   = hist.Ss(2,k);
    v_err   = max(v_min, min(v_err, v_max));
    w_err   = max(w_min, min(w_err, w_max));
    
    % Using FIS to compute fuzzy output
    gamma_fuzzy = evalfis([v_err w_err], param.fis_gamma);
    
    % Saturate to [bias, 1.0] (if FIS Low = 0 but bias > 0, enforce here)
    gamma_fuzzy = max(param.Ss_bias, min(gamma_fuzzy, 1.0));
    
    % Temporal smoothing
    gamma_p = hist.gamma(k);
    gamma   = (1-param.Ss_alpha)*gamma_fuzzy + param.Ss_alpha*gamma_p;
end