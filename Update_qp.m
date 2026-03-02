function solver = Update_qp(solver, Hqp, fqp, Aqp, bqp)
    % Linear term
    solver.prob.c = fqp;
    % Constraints: 动态设置尺寸
    ncon = size(Aqp,1);
    solver.prob.a = sparse(Aqp);
    solver.prob.blc = -inf(ncon,1);  % 假设所有约束 <= bqp，如果有==或>=，需调整
    solver.prob.buc = bqp;
    % Quadratic term: 修复索引为1-based
    [i,j,v] = find(tril(Hqp));
    solver.prob.qosubi = i;  % 1-based
    solver.prob.qosubj = j;  % 1-based
    solver.prob.qoval = v;
end