function [xhk, variance, pf, nZeroWeights] = particleFilterPrev(k, ukm1, zk, pf, EulerAngles)
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
    
    boxkm1 = narrowSearchSpace(k, ukm1, EulerAngles, zk, pf);
    
    pf.volume = [k; volume(boxkm1)];
    
    % Draw initial particles at time k = 0 from p(x0)
    [xkm1, wkm1] = drawSamples(pf.nParticles, pf.nx, boxkm1);
    
    if pf.plotEstimatesLive
        handleTrajectory = animatedline('Color', [0.8500    0.3250    0.0980], ...
            'LineWidth', 1.5, 'DisplayName', 'Estimated trajectory', ...
            'Marker', 'o', 'MarkerFaceColor', [0.3010    0.7450    0.9330]);
    end
    
    if pf.plotEstimatesLive
        plotParticles(xkm1, wkm1, 'Initial particles', pf.pauseTime, pf.resizeLive);
    end
    
else
    % Separate memory
    xkm1 = pf.particles(:, :); % Extract particles from last iteration
    wkm1 = pf.w;               % Extract weights of last iteration
    boxkm1 = pf.boxkm1;
end

xk   = zeros(size(xkm1));       % zeros(nx, pf.nParticles)
wk   = zeros(size(wkm1));       % zeros(1, pf.nParticles)
nZeroWeights = 0;


% Propagate old box.
pf.propagatedBox = propagateBox(k, boxkm1, ukm1, EulerAngles, pf);
boxk = narrowSearchSpace(k, ukm1, EulerAngles, zk, pf);

satisfiesConstraintsLogicals = ones(1, pf.nParticles);

%% Bootstrap filter algorithm

for i = 1:pf.nParticles
    
    % sample from the prior distribution: xk^i ~ p_xk_given_xkm1,ukm1
    % (propagate particles according to system model)
    xk(:,i) = pf.sys(k, xkm1(:,i), ukm1, pf.genSysNoise(), pf.samplePeriod, EulerAngles);
    
    
    % If particle outside the search space, project it on the border of the search space.
    if xk(3, i) < inf(pf.propagatedBox(3))
        xk(3, i) = inf(pf.propagatedBox(3));
    end
    if xk(3, i) > sup(pf.propagatedBox(3))
        xk(3, i) = sup(pf.propagatedBox(3));
    end
    
    %% Apply constraints and set weights to zero if particles lie outside of the constraint box
    
    satisfiesConstraintsLogicals(i) = satisfiesConstraints(k, xk(:,i), zk, pf.landmarks, pf.uncertaintyInterval);
end

nZeroWeights = sum(~satisfiesConstraintsLogicals);

     
if nZeroWeights > 0    
% Draw initial particles at time k = 0 from p(x0)
xk(:, ~satisfiesConstraintsLogicals) = drawSamples(nZeroWeights, pf.nx, boxk);
end

for i = 1:pf.nParticles
    % evaluate importance weights
    wk(i) = wkm1(i) * pf.likelihoodPDF(k, zk, xk(:,i));
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

%% Normalise weight vector
wk = wk./sumOfWeights;
% end

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
pf.boxkm1          = boxk;
variance           = norm(var(xk, wk, 2));

%% Plot

if pf.plotEstimatesLive
    addpoints(handleTrajectory, xhk(1), xhk(2), xhk(3));
    drawnow limitrate
    title(['Mean of particles -- progress: ', char(progressMsg), ' percent']);
    pause(pf.pauseTime)
end


end
