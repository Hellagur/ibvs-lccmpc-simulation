%% Dynamics
function param = Dyn_ibvs(param, hist, k)
    [Ac, Bc, Ls] = Dyn_ibvs_c(param, hist, k);
    [Ad, Bd] = Dyn_ibvs_d(Ac, Bc, param.ts);

    param.Ac    = Ac;
    param.Bc    = Bc;
    param.Ls    = Ls;
    param.Ad    = Ad;
    param.Bd    = Bd;
end

function [Ac, Bc, Ls] = Dyn_ibvs_c(param, hist, k)
    sk  = hist.xs(1:8,k);
    zk  = hist.zhat(:,k);
    vc  = hist.vc(:,k);

    Gc  = param.Gc;
    A7  = param.A7fun(vc(4:6));
    Ls  = param.Lsfun(sk, zk);

    Ac  = [zeros(8,8), Ls; zeros(6,8), A7];
    Bc  = [zeros(8,6); Gc];
end

function [Ad, Bd] = Dyn_ibvs_d(Ac, Bc, ts)
    [n, m] = size(Bc);

    M   = [Ac, Bc; zeros(m, n+m)];
    phi = expm(M * ts);
    Ad  = phi(1:n, 1:n);
    Bd  = phi(1:n, n+1:n+m);
end