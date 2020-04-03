function [xhk, variance, pf, nZeroWeights, nRestarts] = particleFilter(k, ukm1, zk, pf, EulerAngles)
% Generic particle filter
%
%% Ipf.nParticlesuts:
%  k    = iteration number
%  ukm1 = control ipf.nParticlesut at time k-1 (column vector)
%  yk   = observation vector at time k (column vector)
%  pf   = structure with the following fields
%   .pf.nParticles                   = number of particles
%   .w                    = weights   (pf.nParticles x nSamples)
%   .particles            = particles (nx x N x nSamples)
%   .initialParticles     = initial set particles
%   .gen_x0               = function handle for sampling from the initial PDF p_x0
%   .p_zk_given_xk        = function handle of the observation likelihood PDF p(y[k] | x[k])
%   .gen_sys_noise        = function handle for generating system noise samples
%   .sys                  = function handle of the process model
%   .obs                  = function handle of the observation model
%   .resampling_strategy  = resampling strategy. Possible values are
%                          'multinomial_resampling' or 'systematic_resampling'
%   .proposalDistribution = proposal distribution. Possible values are
%                           'transition_prior' or 'UKF'
%   .pauseTime            = time between two steps when plotting live
%
%% Outputs:
% xhk   = estimated state
% pf    = the same structure as in the ipf.nParticlesut but updated at iteration k
%
%% Check input arguments

if k < 1
    error('Error: k must be an integer >= 1');
end

persistent handleTrajectory;
persistent handlePosition;

%%

[~, progressMsg] = printProgress(k, pf.nSamples);

if k == 1
    
    pf.particles    = zeros(pf.nx, pf.nParticles); % Particles
    pf.w            = zeros(1, pf.nParticles);     % Weights
    
    if pf.constraintFiltering
        initSearchSpace = narrowSearchSpace(ukm1, EulerAngles, zk, pf);
        
        pf.volume = [k; volume(initSearchSpace)];
    else
        initSearchSpace = pf.initialBox;
    end
    
    % Draw initial particles at time k = 0 from p(x0)
    [xkm1, wkm1] = drawSamples(pf.nParticles, pf.nx, initSearchSpace);
    
%     if pf.plotEstimatesLive
%         handleTrajectory = animatedline('Color', [0.8500    0.3250    0.0980], ...
%             'LineWidth', 1.5, 'DisplayName', 'Estimated trajectory', ...
%             'Marker', 'o', 'MarkerFaceColor', [0.3010    0.7450    0.9330]);
%     end
    
    if pf.plotEstimatesLive
        plotParticles(xkm1, wkm1, 'Initial particles', pf.pauseTime, pf.resizeLive);
    end
    
    if strcmp(pf.propDist, 'UKF')
        pf.P = zeros(pf.nx, pf.nx, pf.nParticles);  % Error covariance matrices
        pf.P(:, :, :) = repmat(pf.P0, 1, 1, pf.nParticles);
    end
else
    % Separate memory
    xkm1 = pf.particles(:, :); % Extract particles from last iteration
    wkm1 = pf.w;               % Extract weights of last iteration
end

xk   = zeros(size(xkm1));       % zeros(nx, pf.nParticles)
wk   = zeros(size(wkm1));       % zeros(1, pf.nParticles)
nZeroWeights = 0;
nRestarts = 0;

%% Bootstrap filter algorithm

allWeightsZero = 1;

while allWeightsZero
    
    for i = 1:pf.nParticles
        
        switch pf.propDist
            
            case 'transition_prior'
                % sample from the prior distribution: xk^i ~ p_xk_given_xkm1,ukm1
                % (propagate particles according to system model)
                xk(:,i) = pf.sys(k, xkm1(:,i), ukm1, pf.genSysNoise(), pf.samplePeriod, EulerAngles);
                
                % evaluate importance weights
                wk(i) = wkm1(i) * pf.likelihoodPDF(k, zk, xk(:,i));
                
            case 'UKF'
                % sample from proposal distribution: xk^i ~ p_xk^i_given_Zk,Ukm1
                % (propagate particles using unscented Kalman filter)
                [muk, Pk] = unscentedKF(k, xkm1(:,i), ukm1, zk, pf.P(:, :, i), pf, ...
                    {pf.samplePeriod, EulerAngles}, {pf.landmarks});
                
                % Make matrix symmetric;
                Pk = (Pk + Pk.') / 2;
                % Check if positive definite
                [~, nposdef] = chol(Pk, 'lower');
                
                if nposdef
                    % Make it positive definite
                    Pk = topdm(Pk);
                end
                
                % Sample from distribution
                xk(:,i) = mvnrnd(muk, Pk);
                
                % evaluate importance weights
                likelihood = pf.likelihoodPDF(k, zk, xk(:,i));
                prior      = pf.transitionPriorPDF(k, xk(:,i), xkm1(:, i), ukm1, pf.samplePeriod, EulerAngles);
                proposal   = mvnpdf(xk(:,i), muk, Pk);
                wk(i)      = likelihood * prior / proposal;
                
                pf.P(:, :, i) = Pk;
        end
        
        % If particle outside the search space, project it on the border of the search space.
        if xk(3, i) < inf(pf.initialBox(3))
            xk(3, i) = inf(pf.initialBox(3));
        end
        if xk(3, i) > sup(pf.initialBox(3))
            xk(3, i) = sup(pf.initialBox(3));
        end
        
        %% Apply constraints and set weights to zero if particles lie outside of the constraint box
        
        if pf.constraintFiltering && ~satisfiesConstraints(k, xk(:,i), zk, pf.landmarks, pf.uncertaintyInterval)
            wk(i) = 0;
            nZeroWeights = nZeroWeights + 1;
        end
    end
    
    if pf.plotEstimatesLive
        delete(handlePosition)
        hold on;
        handlePosition = scatter3(pf.position(1,k),  pf.position(2,k),  pf.position(3,k), 300, ...
            'filled', 'DisplayName', 'Current position', 'MarkerEdgeColor', 'k', ...
            'MarkerFaceColor', [0.9290    0.6940    0.1250]);
        hold off;
        
        plotParticles(xk, wkm1, 'Propagated particles', pf.pauseTime, pf.resizeLive);
        plotParticles(xk, wk, 'Weighted particles', pf.pauseTime, pf.resizeLive);
    end
    
    sumOfWeights = sum(wk);
    
    if nZeroWeights == pf.nParticles
        if pf.constraintFiltering
            newSearchSpace = narrowSearchSpace(ukm1, EulerAngles, zk, pf);
            
            %pf.volume = [pf.volume, k; volume(newSearchSpace)];
            
            % Draw new particles at time k-1 from p(xkm1)
            [xkm1, wkm1] = drawSamples(pf.nParticles, pf.nx, newSearchSpace);
            
            nZeroWeights = 0;
            nRestarts = nRestarts + 1;
        else
            wk = 1/pf.nParticles * ones(1, pf.nParticles);
            allWeightsZero = 0;
        end
    else
        %% Normalise weight vector
        wk = wk./sumOfWeights;
        allWeightsZero = 0;
    end
end

%% Plot

if pf.plotEstimatesLive
    delete(handlePosition)
    hold on;
    handlePosition = scatter3(pf.position(1,k),  pf.position(2,k),  pf.position(3,k), 300, ...
        'filled', 'DisplayName', 'Current position', 'MarkerEdgeColor', 'k', ...
        'MarkerFaceColor', [0.9290    0.6940    0.1250]);
    hold off;
    
    plotParticles(xk, wkm1, 'Propagated particles', pf.pauseTime, pf.resizeLive);
    plotParticles(xk, wk, 'Weighted particles', pf.pauseTime, pf.resizeLive);
end

%% Resampling

[xk, wk, idx] = resampleParticles(xk, wk, pf.resamplingStrategy);

%% Plot

if pf.plotEstimatesLive
    plotParticles(xk, wk, 'Resampled particles', pf.pauseTime, pf.resizeLive);
end

%% Compute estimated state given by weighted sample mean

xhk = sum(wk.*xk, 2);

%% Store new weights and particles

pf.w               = wk;
pf.particles(:,:)  = xk;
variance           = norm(var(xk, wk, 2));
if strcmp(pf.propDist, 'UKF')
    pf.P(:, :, :) = pf.P(:, :, idx);
end

%% Plot

% if pf.plotEstimatesLive
%     addpoints(handleTrajectory, xhk(1), xhk(2), xhk(3));
%     drawnow limitrate
%     title(['Mean of particles -- progress: ', char(progressMsg), ' percent']);
%     pause(pf.pauseTime)
% end


end
