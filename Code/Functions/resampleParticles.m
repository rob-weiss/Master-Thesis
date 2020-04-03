function [xk, wk, idx] = resampleParticles(xk, wk, resampling_strategy)
% Resampling function

Np = length(wk);  % number of particles

switch resampling_strategy
    case 'multinomial_resampling'
        with_replacement = true;
        idx = randsample(1:Np, Np, with_replacement, wk);
        %{
      THIS IS EQUIVALENT TO:
      edges = min([0 cumsum(wk)'],1); % protect against accumulated round-off
      edges(end) = 1;                 % get the upper edge exact
      % this works like the inverse of the empirical distribution and returns
      % the interval where the sample is to be found
      [~, idx] = histc(sort(rand(Ns,1)), edges);
        %}
    case 'systematic_resampling'
        % this is performing latin hypercube sampling on wk
        edges = min([0 cumsum(wk)],1); % protect against accumulated round-off
        edges(end) = 1;                 % get the upper edge exact
        u1 = rand/Np;
        % this works like the inverse of the empirical distribution and returns
        % the interval where the sample is to be found
        [~, idx] = histc(u1:1/Np:1, edges);
        % case 'regularized_pf'      TO BE IMPLEMENTED
        % case 'stratified_sampling' TO BE IMPLEMENTED
        % case 'residual_sampling'   TO BE IMPLEMENTED
    otherwise
        error('Resampling strategy not implemented')
end

xk = xk(:,idx);                    % extract new particles
wk = 1/Np * ones(1, Np);         % now all particles have the same weight

end

