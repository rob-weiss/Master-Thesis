%% Clear memory and console, close all figures, load data and parameters

clear, clc, close all
cd '/Users/rob/Documents/Master Thesis/Code'

paramScript = 'param9Landmarks';    % Specify parameterisation script

PF                    = false;       % Particle filter estimation
UPF                   = false;       % Unscented particle filter estimation
PFC                   = true;       % Particle filter estimation with contractor
UPFC                  = false;       % Unscented particle filter estimation with contractor
PFS                   = true;       % Particle filter estimation with SIVIA
UPFS                  = true;       % Unscented particle filter estimation with SIVIA

kidnapRobot           = false;       % Kidnap robot
nRuns                 = 100;        % Number of runs

plotEstimatesLive     = true;      % Plot 3D trajectory, particles, boxes, and estimation results live
plotResizeLive        = true;      % Resize the figure automatically, zooming into the latest object plotted
plotFullscreen        = true;      % Make figure full-screen
plotFirstNSeconds     = 40;         % Plot the first n seconds after start or kidnapping at higher time resolution
pauseTime             = 5;          % Time between two consecutive updates of live plots in seconds

%% Initialise state estimation and error vectors

eval(paramScript);                  % Load parameters

% Trim data set
if kidnapRobot
    distanceMeasurements = distanceMeasurements(:, [1:kidnapFirstSample-1, kidnapLastSample+1:end]);
    velocityInputs       = velocityInputs(:, [1:kidnapFirstSample-1, kidnapLastSample+1:end]);
    eulerAnglesYPRInputs = eulerAnglesYPRInputs(:, [1:kidnapFirstSample-1, kidnapLastSample+1:end]);
    position             = position(:, [1:kidnapFirstSample-1, kidnapLastSample+1:end]);
    t                    = samplePeriod * (1:size(position, 2));
    nSamples             = length(t);
else
    distanceMeasurements = distanceMeasurements(:, t<=200);
    velocityInputs       = velocityInputs(:, t<=200);
    eulerAnglesYPRInputs = eulerAnglesYPRInputs(:, t<=200);
    position             = position(:, t<=200);
    t                    = samplePeriod * (1:size(position, 2));
    nSamples             = length(t);
    kidnapFirstSample = [];
end

nx               = 3;                          % Number of states
nz               = nLandmarks;                 % Number of observations
nw               = 6;                          % Number of elements of the process noise vector

xhPF             = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the PF
xhUPF            = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the UPF
xhPFC            = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the PFC
xhUPFC           = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the UPFC
xhPFS            = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the PFS
xhUPFS           = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the UPFS

varPF            = zeros(nRuns, nSamples);     % Matrix of particle variances of the PF
varUPF           = zeros(nRuns, nSamples);     % Matrix of particle varinaces of the UPF
varPFC           = zeros(nRuns, nSamples);     % Matrix of particle variances of the PFC
varUPFC          = zeros(nRuns, nSamples);     % Matrix of particle varinaces of the UPFC
varPFS           = zeros(nRuns, nSamples);     % Matrix of particle variances of the PFS
varUPFS          = zeros(nRuns, nSamples);     % Matrix of particle varinaces of the UPFS

errorsPF         = zeros(nRuns, nSamples);     % Matric of errors of PF
errorsUPF        = zeros(nRuns, nSamples);     % Matric of errors of UPF
errorsPFC        = zeros(nRuns, nSamples);     % Matric of errors of PFC
errorsUPFC       = zeros(nRuns, nSamples);     % Matric of errors of UPFC
errorsPFS        = zeros(nRuns, nSamples);     % Matric of errors of PFS
errorsUPFS       = zeros(nRuns, nSamples);     % Matric of errors of UPFS

rmsErrorsPF      = zeros(nRuns, 1);            % Root mean-square errors of PF
rmsErrorsUPF     = zeros(nRuns, 1);            % Root mean-square errors of UPF
rmsErrorsPFC     = zeros(nRuns, 1);            % Root mean-square errors of PFC
rmsErrorsUPFC    = zeros(nRuns, 1);            % Root mean-square errors of UPFC
rmsErrorsPFS     = zeros(nRuns, 1);            % Root mean-square errors of PFS
rmsErrorsUPFS    = zeros(nRuns, 1);            % Root mean-square errors of UPFS

nZeroWeightsPFC  = zeros(nRuns, nSamples);     % Number of weights of PFC  set to zero
nZeroWeightsUPFC = zeros(nRuns, nSamples);     % Number of weights of UPFC set to zero
nZeroWeightsPFS  = zeros(nRuns, nSamples);     % Number of weights of PFS  set to zero
nZeroWeightsUPFS = zeros(nRuns, nSamples);     % Number of weights of UPFS set to zero

nRestartsPFC     = zeros(nRuns, nSamples);     % Number of restarts of PFC due to localisation failure
nRestartsUPFC    = zeros(nRuns, nSamples);     % Number of restarts of UPFC due to localisation failure
nRestartsPFS     = zeros(nRuns, nSamples);     % Number of restarts of PFS due to localisation failure
nRestartsUPFS    = zeros(nRuns, nSamples);     % Number of restarts of UPFS due to localisation failure

timesPF           = zeros(nRuns, 1);            % Time duration of estimation PF
timesUPF          = zeros(nRuns, 1);            % Time duration of estimation UPF
timesPFC          = zeros(nRuns, 1);            % Time duration of estimation PFC
timesUPFC         = zeros(nRuns, 1);            % Time duration of estimation UPFC
timesPFS          = zeros(nRuns, 1);            % Time duration of estimation PFS
timesUPFS         = zeros(nRuns, 1);            % Time duration of estimation UPFS

% Compute enclosing of the initial search space
limits = scaleInitSearchSpace * [lowerLimits; upperLimits];  % Scale initial search space
initialVolume = volume(limits);                              % Compute volume of initial search space

pf.initialBox = [infsup(limits(1, 1), limits(2, 1)), ...     % Initial box
    infsup(limits(1, 2), limits(2, 2)), infsup(limits(1, 3), limits(2, 3))];

% Define likelihood PDF p(y[k] | x[k]) to be zero-mean Gaussian with covariance 'covMatrix'
likelihoodPDF = @(covMatrix) @(k, zk, xk) mvnpdf(zk - hFun(k, xk, 0, landmarks), 0, covMatrix);

% Define transition prior PDF p(x[k] | x[k-1], u[k-1]) to be zero-mean Gaussian with covariance 'covMatrix'
transitionPriorPDF = @(covMatrix) @(k, xk, xkm1, ukm1, Ts, eulerAnglesYPR) ...
    mvnpdf(xk - phiFun(k, xkm1, ukm1, zeros(nw, 1), Ts, eulerAnglesYPR), 0, covMatrix);

% Define function to draw system noise samples from zero-mean Gaussian with covariance 'covMatrix'
genSysNoise   = @(covMatrix) @() mvnrnd(zeros(nw, 1), covMatrix)';

%% Initialise particle filter structures

pf.nx                    = nx;                       % Number of elements of state vector
pf.nSamples              = nSamples;                 % Number of samples
pf.sys                   = @phiFun;                  % Process equation
pf.obs                   = @hFun;                    % Observation equation
pf.propDist              = 'transition_prior';       % Transition prior PDF as proposal distribution
pf.resamplingStrategy    = 'systematic_resampling';  % Resampling strategy
pf.samplePeriod          = samplePeriod;
pf.sigmaVelocity         = sigmaVelocity;
pf.sigmaEulerAngles      = sigmaEulerAngles;
pf.landmarks             = landmarks;
pf.uncertaintyInterval   = uncertaintyIntConstr;
pf.plotEstimatesLive     = plotEstimatesLive;
pf.resizeLive            = plotResizeLive;
pf.pauseTime             = pauseTime;
pf.position              = position;

% Particle filter
pf.nParticles            = nParticlesPF;                                            % Number of particles
pf.likelihoodPDF         = likelihoodPDF(diag(sigmaLikelihoodPF.^2 * ones(1, nz))); % p(y[k] | x[k])
pf.genSysNoise           = genSysNoise(diag(sigmaSysNoisePF.^2));                   % Noise generator function
pf.constraintFiltering   = false;
pf.boundedErrorEst       = 'none';

% Particle filter with contractor
pfc                      = pf;
pfc.nParticles           = nParticlesPFC;                                            % Number of particles
pfc.likelihoodPDF        = likelihoodPDF(diag(sigmaLikelihoodPFC.^2 * ones(1, nz))); % p(y[k] | x[k])
pfc.genSysNoise          = genSysNoise(diag(sigmaSysNoisePFC.^2));                   % Noise generator function
pfc.constraintFiltering  = true;
pfc.boundedErrorAlg      = 'contr';
pfc.boundedErrorProp     = contr;

% Particle filter with SIVIA
pfs                      = pf;
pfs.nParticles           = nParticlesPFS;                                            % Number of particles
pfs.likelihoodPDF        = likelihoodPDF(diag(sigmaLikelihoodPFS.^2 * ones(1, nz))); % p(y[k] | x[k])
pfs.genSysNoise          = genSysNoise(diag(sigmaSysNoisePFS.^2));                   % Noise generator function
pfs.constraintFiltering  = true;
pfs.boundedErrorAlg      = 'sivia';
pfs.boundedErrorProp     = siv;

%% Initialise unscented particle filter structures

upf                     = pf;        % Use the same parameters as in the PF and extend by UPF parameters
upf.alpha               = 0.01;      % Point scaling parameter
upf.beta                = 2;         % Scaling parameter for higher order terms of Taylor series expansion
upf.kappa               = 0;         % Sigma point selection scaling parameter
upf.propDist            = 'UKF';     % Use unscented Kalman filter as proposal distribution

% Unscented particle filter
upf.nParticles           = nParticlesUPF;                       % Number of particles
upf.Q                    = diag(sigmaQUPF.^2);                  % Process noise
upf.R                    = diag(sigmaRUPF.^2  * ones(nz, 1));   % Measurement noise covariance matrix
upf.P0                   = diag(sigmaP0UPF.^2 * ones(nx, 1));   % Initial error covariance matrix
upf.likelihoodPDF        = likelihoodPDF(diag(sigmaLikelihoodUPF.^2 * ones(1, nz)));      % p(y[k]|x[k])
upf.transitionPriorPDF   = transitionPriorPDF(diag(sigmaTransPriorUPF.^2 * ones(nx, 1))); % p(x[k]|x[k-1],u[k-1])
upf.constraintFiltering  = false;
upf.boundedErrorAlg      = 'none';

% Unscented particle filter with contractor
upfc                     = upf;
upfc.nParticles          = nParticlesUPFC;                      % Number of particles
upfc.Q                   = diag(sigmaQUPFC.^2);                 % Process noise
upfc.R                   = diag(sigmaRUPFC.^2  * ones(nz, 1));  % Measurement noise covariance matrix
upfc.P0                  = diag(sigmaP0UPFC.^2 * ones(nx, 1));  % Initial error covariance matrix
upfc.likelihoodPDF       = likelihoodPDF(diag(sigmaLikelihoodUPFC.^2 * ones(1, nz)));      % p(y[k]|x[k])
upfc.transitionPriorPDF  = transitionPriorPDF(diag(sigmaTransPriorUPFC.^2 * ones(nx, 1))); % p(x[k]|x[k-1],u[k-1])
upfc.constraintFiltering = true;
upfc.boundedErrorAlg     = 'contr';
upfc.boundedErrorProp    = contr;

% Unscented particle filter with SIVIA
upfs                     = upf;
upfs.nParticles          = nParticlesUPFS;                      % Number of particles
upfs.Q                   = diag(sigmaQUPFS.^2);                 % Process noise
upfs.R                   = diag(sigmaRUPFS.^2  * ones(nz, 1));  % Measurement noise covariance matrix
upfs.P0                  = diag(sigmaP0UPFS.^2 * ones(nx, 1));  % Initial error covariance matrix
upfs.likelihoodPDF       = likelihoodPDF(diag(sigmaLikelihoodUPFS.^2 * ones(1, nz)));      % p(y[k]|x[k])
upfs.transitionPriorPDF  = transitionPriorPDF(diag(sigmaTransPriorUPFS.^2 * ones(nx, 1))); % p(x[k]|x[k-1],u[k-1])
upfs.constraintFiltering = true;
upfs.boundedErrorAlg     = 'sivia';
upfs.boundedErrorProp    = siv;

%% Log values of interest

logFileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
logFilePath = ['/Users/rob/Documents/Master Thesis/Results/', logFileName, '/'];
mkdir(logFilePath);

% Save current data set for repetition of experiments
copyfile(['/Users/rob/Documents/Master Thesis/Preprocessed data/', fileName, '.mat'], ...
    [logFilePath, 'Data_', fileName, '.mat']);
fileName    = strrep(fileName, '_' , ' ');
diary([logFilePath, logFileName, '.log']);

% Save current script for repetition of experiments
newbackup = sprintf('%s-%s.m', [logFilePath, mfilename], logFileName);
mFilePath = [mfilename('fullpath'), '.m'];
copyfile(mFilePath, newbackup);
newbackup = sprintf('%s-%s.m', [logFilePath, paramScript], logFileName);
mFilePath = [paramScript, '.m'];
copyfile(mFilePath, newbackup);

newline2 = [newline, newline];
newline3 = [newline, newline2];

fprintf(['Date:                      %sh',             newline ],       datestr(now, 'dd mmm yyyy, HH:MM:SS'));
fprintf(['Script:                    %s.m',            newline3],       mfilename);

fprintf(['--- Data Set ----------------------------------------------', newline2]);
fprintf(['File name:                 %s',              newline2],       fileName);
fprintf(['Sigma velocity:            %3.3f m/s',       newline ],       sigmaVelocity);
fprintf(['Sigma Euler angles:        %3.3f °',         newline2],       sigmaEulerAngles * 180 / pi);
fprintf(['Landmarks:                       x         y         z ',     newline]);
fprintf(['                           % 7.1f m  % 7.1f m  % 7.1f m',     newline], landmarks);
fprintf(newline2);
fprintf(['--- General Settings --------------------------------------', newline2]);
fprintf(['No. of runs:               %i',              newline2],       nRuns);
fprintf(['No. of particles PF:       %i',              newline ],       pf.nParticles);
fprintf(['No. of particles UPF:      %i',              newline ],       upf.nParticles);
fprintf(['No. of particles PFC:      %i',              newline ],       pfc.nParticles);
fprintf(['No. of particles UPFC:     %i',              newline ],       upfc.nParticles);
fprintf(['No. of particles PFS:      %i',              newline ],       pfs.nParticles);
fprintf(['No. of particles UPFS:     %i',              newline2],       upfs.nParticles);

fprintf(['Scale  init. search space: %1.1f',           newline ],       scaleInitSearchSpace);
fprintf(['Volume init. search space: %1.6f * 10^6 m^3',      newline ],       initialVolume / 1000000);
fprintf(['Lower and upper bounds:         x         y         z',       newline]);
fprintf(['                           % 6.1f m  % 6.1f m  % 6.1f m',     newline], limits(1,:));
fprintf(['                           % 6.1f m  % 6.1f m  % 6.1f m',     newline], limits(2,:));
fprintf(newline);
fprintf(['Sigma sys. n. vel. PF:     %2.3f m',         newline ],       sigmaSysNoisePF(1));
fprintf(['Sigma sys. n. vel. PFC:    %2.3f m',         newline ],       sigmaSysNoisePFC(1));
fprintf(['Sigma sys. n. ang. PF:     %2.3f °',         newline ],       sigmaSysNoisePF(4)  * 180 / pi);
fprintf(['Sigma sys. n. ang. PFC:    %2.3f °',         newline2],       sigmaSysNoisePFC(4) * 180 / pi);

fprintf(['Sigma likelihood PF:       %4.3f m',         newline ],       sigmaLikelihoodPF);
fprintf(['Sigma likelihood UPF:      %4.3f m',         newline ],       sigmaLikelihoodUPF);
fprintf(['Sigma likelihood PFC:      %4.3f m',         newline ],       sigmaLikelihoodPFC);
fprintf(['Sigma likelihood UPFC:     %4.3f m',         newline ],       sigmaLikelihoodUPFC);
fprintf(['Sigma likelihood PFS:      %4.3f m',         newline ],       sigmaLikelihoodPFS);
fprintf(['Sigma likelihood UPFS:     %4.3f m',         newline2],       sigmaLikelihoodUPFS);

fprintf(['Sigma trans. prior: UPF:   %4.3f m',         newline ],       sigmaTransPriorUPF);
fprintf(['Sigma trans. prior: UPFC:  %4.3f m',         newline ],       sigmaTransPriorUPFC);
fprintf(['Sigma trans. prior: UPFS:  %4.3f m',         newline2],       sigmaTransPriorUPFS);

fprintf(['Sigma P0 UPF:              %4.3f m',         newline ],       sigmaP0UPF);
fprintf(['Sigma P0 UPFC:             %4.3f m',         newline ],       sigmaP0UPFC);
fprintf(['Sigma P0 UPFS:             %4.3f m',         newline2],       sigmaP0UPFS);

fprintf(['Sigma Q  UPF:              %4.3f m  %4.3f °',newline ],       sigmaQUPF(1),  sigmaQUPF(4)  * 180 / pi);
fprintf(['Sigma Q  UPFC:             %4.3f m  %4.3f °',newline ],       sigmaQUPFC(1), sigmaQUPFC(4) * 180 / pi);
fprintf(['Sigma Q  UPFS:             %4.3f m  %4.3f °',newline2],       sigmaQUPFS(1), sigmaQUPFS(4) * 180 / pi);

fprintf(['Sigma R  UPF:              %4.3f m',         newline ],       sigmaRUPF);
fprintf(['Sigma R  UPFC:             %4.3f m',         newline ],       sigmaRUPFC);
fprintf(['Sigma R  UPFS:             %4.3f m',         newline3],       sigmaRUPFS);

fprintf(['--- Estimation Results ------------------------------------------', newline3]);

%%

for runIndex = 1:nRuns
    
    fprintf(['--- Run no. %i -----------------------', newline3], runIndex);
    
    if PF
        fprintf(['--- Particle filter ---', newline2]);
        
        plotTrajectory(landmarks, position, ['Results particle filter run no. ', num2str(runIndex)], ...
            plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhPF(:, k, runIndex), varPF(runIndex, :), pf] = particleFilter(k, velocityInputs(:,k), ...
                distanceMeasurements(:, k), pf, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesPF(runIndex) = toc;
        [rmsErrorsPF(runIndex, 1), errorsPF(runIndex, :)] = computeErrors(position, xhPF(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline ], timesPF(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsPF(runIndex, 1));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsPF(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhPF(:, :, runIndex));
        end
    end
    
    if UPF
        fprintf(['--- Unscented particle filter ---', newline2]);
        
        plotTrajectory(landmarks, position, ['Results unscented particle filter run no. ', num2str(runIndex)], ...
            plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhUPF(:, k, runIndex), varUPF(runIndex, :), upf] = particleFilter(k, velocityInputs(:, k), ...
                distanceMeasurements(:, k), upf, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesUPF(runIndex) = toc;
        [rmsErrorsUPF(runIndex, 1), errorsUPF(runIndex, :)] = computeErrors(position, xhUPF(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline ], timesUPF(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsUPF(runIndex, 1));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsUPF(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhUPF(:, :, runIndex));
        end
    end
    
    if PFC
        fprintf(['--- Particle filter with contractor ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results particle filter with contractor run no. ', num2str(runIndex)], plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhPFC(:, k, runIndex), varPFC(runIndex, :), pfc, nZeroWeightsPFC(runIndex, k), ...
                nRestartsPFC(runIndex, k)] = particleFilter(...
                k, velocityInputs(:,k), distanceMeasurements(:, k), pfc, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesPFC(runIndex) = toc;
        [rmsErrorsPFC(runIndex, 1), errorsPFC(runIndex, :)] = computeErrors(position, xhPFC(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline],  timesPFC(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsPFC(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsPFC(runIndex, :)), ...
            100 * sum(nZeroWeightsPFC(runIndex, :)) / (pfc.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsPFC(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhPFC(:, :, runIndex));
        end
    end
    
    if UPFC
        fprintf(['--- Unscented particle filter with contractor ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results unscented particle filter with contractor run no. ', num2str(runIndex)], ...
            plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhUPFC(:, k, runIndex), varUPFC(runIndex, :), upfc, nZeroWeightsUPFC(runIndex, k), ...
                nRestartsUPFC(runIndex, k)] = ...
                particleFilter(k, velocityInputs(:, k), distanceMeasurements(:, k), upfc, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesUPFC(runIndex) = toc;
        [rmsErrorsUPFC(runIndex, 1), errorsUPFC(runIndex, :)] = computeErrors(position, xhUPFC(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline], timesUPFC(runIndex));
        fprintf(['RMSE:                    %2.2f m       ', newline ], rmsErrorsUPFC(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsUPFC(runIndex, :)), ...
            100 * sum(nZeroWeightsUPFC(runIndex, :)) / (upfc.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec   ', newline3], convThreshold, ...
            t(find(errorsUPFC(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhUPFC(:, :, runIndex));
        end
    end
    
    if PFS
        fprintf(['--- Particle filter with SIVIA ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results particle filter with SIVIA run no. ', num2str(runIndex)],  plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhPFS(:, k, runIndex), varPFS(runIndex, :), pfs, nZeroWeightsPFS(runIndex, k), ...
                nRestartsPFS(runIndex, k)] = ...
                particleFilter(k, velocityInputs(:,k), ...
                distanceMeasurements(:, k), pfs, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesPFS(runIndex) = toc;
        [rmsErrorsPFS(runIndex, 1), errorsPFS(runIndex, :)] = computeErrors(position, xhPFS(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline], timesPFS(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsPFS(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsPFS(runIndex, :)), ...
            100 * sum(nZeroWeightsPFS(runIndex, :)) / (pfc.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsPFS(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhPFS(:, :, runIndex));
        end
    end
    
    if UPFS
        fprintf(['--- Unscented particle filter with SIVIA ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results unscented particle filter with SIVIA run no. ', num2str(runIndex)], ...
            plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhUPFS(:, k, runIndex), varUPFS(runIndex, :), upfs, nZeroWeightsUPFS(runIndex, k), ...
                nRestartsUPFS(runIndex, k)] = ...
                particleFilter(k, ...
                velocityInputs(:, k), distanceMeasurements(:, k), upfs, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesUPFS(runIndex) = toc;
        [rmsErrorsUPFS(runIndex, 1), errorsUPFS(runIndex, :)] = computeErrors(position, xhUPFS(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline], timesUPFS(runIndex));
        fprintf(['RMSE:                    %2.2f m       ', newline ], rmsErrorsUPFS(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsUPFS(runIndex, :)), ...
            100 * sum(nZeroWeightsUPFS(runIndex, :)) / (upfc.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec   ', newline3], convThreshold, ...
            t(find(errorsUPFS(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhUPFS(:, :, runIndex));
        end
    end
    
    if PFC || UPFC || PFS || UPFS
        plotZeroWeights(t, [nZeroWeightsPFC(runIndex, :); nZeroWeightsUPFC(runIndex, :); ...
            nZeroWeightsPFS(runIndex, :); nZeroWeightsUPFS(runIndex, :)], ["PFC", "UPFC", "PFS", "UPFS"], ...
            ['Number of particle weights set to zero by constraints -- run no. ', num2str(runIndex)]);
    end
    
    plotErrors(t, [ ...
        errorsPF(runIndex, :); errorsUPF(runIndex, :); ...
        errorsPFC(runIndex, :); errorsUPFC(runIndex, :); ...
        errorsPFS(runIndex, :); errorsUPFS(runIndex, :)], ...
        [rmsErrorsPF(runIndex, 1); rmsErrorsUPF(runIndex, 1); ...
        rmsErrorsPFC(runIndex, 1); rmsErrorsUPFC(runIndex, 1); ...
        rmsErrorsPFS(runIndex, 1); rmsErrorsUPFS(runIndex, 1)], ...
        [varPF(runIndex, :); varUPF(runIndex, :); ...
        varPFC(runIndex, :); varUPFC(runIndex, :); ...
        varPFS(runIndex, :); varUPFS(runIndex, :)], ...
        ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS"], ...
        [fileName, ' -- errors vs. time -- run no. ', num2str(runIndex)], kidnapFirstSample);
    
    savePlots2PDF(logFilePath, [logFileName, '-run-', num2str(runIndex)], true);
    
    fprintf(['--------------------------------------------------------', newline2]);
end

%% Compute mean errors

meanErrorsPF          = mean(errorsPF, 1);
meanErrorsUPF         = mean(errorsUPF, 1);
meanErrorsPFC         = mean(errorsPFC, 1);
meanErrorsUPFC        = mean(errorsUPFC, 1);
meanErrorsPFS         = mean(errorsPFS, 1);
meanErrorsUPFS        = mean(errorsUPFS, 1);

meanRmsErrorPF       = mean(rmsErrorsPF, 1);
meanRmsErrorUPF      = mean(rmsErrorsUPF, 1);
meanRmsErrorPFC      = mean(rmsErrorsPFC, 1);
meanRmsErrorUPFC     = mean(rmsErrorsUPFC, 1);
meanRmsErrorPFS      = mean(rmsErrorsPFS, 1);
meanRmsErrorUPFS     = mean(rmsErrorsUPFS, 1);

meanVarPF             = mean(varPF, 1);
meanVarUPF            = mean(varUPF, 1);
meanVarPFC            = mean(varPFC, 1);
meanVarUPFC           = mean(varUPFC, 1);
meanVarPFS            = mean(varPFS, 1);
meanVarUPFS           = mean(varUPFS, 1);

meanNZeroWeightsPFC   = round(mean(nZeroWeightsPFC,  1), 0);
meanNZeroWeightsUPFC  = round(mean(nZeroWeightsUPFC, 1), 0);
meanNZeroWeightsPFS   = round(mean(nZeroWeightsPFS,  1), 0);
meanNZeroWeightsUPFS  = round(mean(nZeroWeightsUPFS, 1), 0);

totalNZeroWeightsPFC  = sum(meanNZeroWeightsPFC);
totalNZeroWeightsPFS  = sum(meanNZeroWeightsPFS);
totalNZeroWeightsUPFC = sum(meanNZeroWeightsUPFC);
totalNZeroWeightsUPFS = sum(meanNZeroWeightsUPFS);

relNZeroWeightsPFC    = 100 * totalNZeroWeightsPFC  / (nParticlesPFC  * nSamples);
relNZeroWeightsPFS    = 100 * totalNZeroWeightsPFS  / (nParticlesPFS  * nSamples);
relNZeroWeightsUPFC   = 100 * totalNZeroWeightsUPFC / (nParticlesUPFC * nSamples);
relNZeroWeightsUPFS   = 100 * totalNZeroWeightsUPFS / (nParticlesUPFS * nSamples);

relPerformanceUPF     = 100 * meanRmsErrorUPF  / meanRmsErrorPF;
relPerformancePFC     = 100 * meanRmsErrorPFC  / meanRmsErrorPF;
relPerformanceUPFC    = 100 * meanRmsErrorUPFC / meanRmsErrorPF;
relPerformancePFS     = 100 * meanRmsErrorPFS  / meanRmsErrorPF;
relPerformanceUPFS    = 100 * meanRmsErrorUPFS / meanRmsErrorPF;

convTimePF            = t(find(meanErrorsPF   < convThreshold, 1))  - samplePeriod;
convTimeUPF           = t(find(meanErrorsUPF  < convThreshold, 1))  - samplePeriod;
convTimePFC           = t(find(meanErrorsPFC  < convThreshold, 1))  - samplePeriod;
convTimeUPFC          = t(find(meanErrorsUPFC < convThreshold, 1))  - samplePeriod;
convTimePFS           = t(find(meanErrorsPFS  < convThreshold, 1))  - samplePeriod;
convTimeUPFS          = t(find(meanErrorsUPFS < convThreshold, 1))  - samplePeriod;

meanTimePF            = mean(timesPF);
meanTimeUPF           = mean(timesUPF);
meanTimePFC           = mean(timesPFC);
meanTimeUPFC          = mean(timesUPFC);
meanTimePFS           = mean(timesPFS);
meanTimeUPFS          = mean(timesUPFS);

relTimePF             = meanTimePF   / meanTimePF;
relTimeUPF            = meanTimeUPF  / meanTimePF;
relTimePFC            = meanTimePFC  / meanTimePF;
relTimeUPFC           = meanTimeUPFC / meanTimePF;
relTimePFS            = meanTimePFS  / meanTimePF;
relTimeUPFS           = meanTimeUPFS / meanTimePF;

fprintf(['--- Overall performance ---', newline2]);

fprintf(['Mean RMSE:                  ',   newline ]);
fprintf(['PF:                        %2.2f m',   newline ],  meanRmsErrorPF);
fprintf(['UPF:                       %2.2f m',   newline ],  meanRmsErrorUPF);
fprintf(['PFC:                       %2.2f m',   newline ],  meanRmsErrorPFC);
fprintf(['UPFC:                      %2.2f m',   newline ],  meanRmsErrorUPFC);
fprintf(['PFS:                       %2.2f m',   newline ],  meanRmsErrorPFS);
fprintf(['UPFS:                      %2.2f m',   newline2],  meanRmsErrorUPFS);

fprintf(['Mean initial error:               ',   newline ]);
fprintf(['PF:                        %2.2f m',   newline ],  meanErrorsPF(1));
fprintf(['UPF:                       %2.2f m',   newline ],  meanErrorsUPF(1));
fprintf(['PFC:                       %2.2f m',   newline ],  meanErrorsPFC(1));
fprintf(['UPFC:                      %2.2f m',   newline ],  meanErrorsUPFC(1));
fprintf(['PFS:                       %2.2f m',   newline ],  meanErrorsPFS(1));
fprintf(['UPFS:                      %2.2f m',   newline2],  meanErrorsUPFS(1));

fprintf(['Error < %1.1f m after:              ', newline ],  convThreshold);
fprintf(['PF:                        %3.2f sec', newline ],  convTimePF);
fprintf(['UPF:                       %3.2f sec', newline ],  convTimeUPF);
fprintf(['PFC:                       %3.2f sec', newline ],  convTimePFC);
fprintf(['UPFC:                      %3.2f sec', newline ],  convTimeUPFC);
fprintf(['PFS:                       %3.2f sec', newline ],  convTimePFS);
fprintf(['UPFS:                      %3.2f sec', newline2],  convTimeUPFS);

fprintf(['Mean computation time:              ', newline ]);
fprintf(['PF:                        %4.1f sec', newline ],  meanTimePF);
fprintf(['UPF:                       %4.1f sec', newline ],  meanTimeUPF);
fprintf(['PFC:                       %4.1f sec', newline ],  meanTimePFC);
fprintf(['UPFC:                      %4.1f sec', newline ],  meanTimeUPFC);
fprintf(['PFS:                       %4.1f sec', newline ],  meanTimePFS);
fprintf(['UPFS:                      %4.1f sec', newline2],  meanTimeUPFS);

fprintf(['Computation time relative to PF:    ', newline ]);
fprintf(['PF:                        %3.2f    ', newline ],  relTimePF);
fprintf(['UPF:                       %3.2f    ', newline ],  relTimeUPF);
fprintf(['PFC:                       %3.2f    ', newline ],  relTimePFC);
fprintf(['UPFC:                      %3.2f    ', newline ],  relTimeUPFC);
fprintf(['PFS:                       %3.2f    ', newline ],  relTimePFS);
fprintf(['UPFS:                      %3.2f    ', newline2],  relTimeUPFS);

fprintf(['Mean no. of weights set to zero:    ', newline ]);
fprintf(['PFC:                       %2i (%3.2f %%)', newline ], totalNZeroWeightsPFC,  relNZeroWeightsPFC);
fprintf(['UPFC:                      %2i (%3.2f %%)', newline ], totalNZeroWeightsUPFC, relNZeroWeightsUPFC);
fprintf(['PFS:                       %2i (%3.2f %%)', newline ], totalNZeroWeightsPFS,  relNZeroWeightsPFS);
fprintf(['UPFS:                      %2i (%3.2f %%)', newline2], totalNZeroWeightsUPFS, relNZeroWeightsUPFS);

fprintf(['No. of restarts of the filter:      ', newline ]);
fprintf(['PFC:                       %2i      ', newline ],  sum(sum(nRestartsPFC,  1)));
fprintf(['UPFC:                      %2i      ', newline ],  sum(sum(nRestartsUPFC, 1)));
fprintf(['PFS:                       %2i      ', newline ],  sum(sum(nRestartsPFS,  1)));
fprintf(['UPFS:                      %2i      ', newline2],  sum(sum(nRestartsUPFS, 1)));

if PFS || UPFS
    %plotVolumes(t, [volumesContr; volumesSIVIA], ["Contractor", "SIVIA"]);
    plotZeroWeights(t, [meanNZeroWeightsPFC; meanNZeroWeightsUPFC; ...
        meanNZeroWeightsPFS; meanNZeroWeightsUPFS], ["PFC", "UPFC", "PFS", "UPFS"], ...
        ['Mean number of particle weights set to zero by constraints after ', ...
        num2str(nRuns), ' runs']);
end

if plotFirstNSeconds
    index = find(t > plotFirstNSeconds, 1) - 1;
    plotErrors(t(1:index), [meanErrorsPF(1:index); meanErrorsUPF(1:index); ...
        meanErrorsPFC(1:index); meanErrorsUPFC(1:index);
        meanErrorsPFS(1:index); meanErrorsUPFS(1:index)], ...
        [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC;
        meanRmsErrorPFS; meanRmsErrorUPFS], ...
        [meanVarPF(1:index); meanVarUPF(1:index); meanVarPFC(1:index); meanVarUPFC(1:index);
        meanVarPFS(1:index); meanVarUPFS(1:index)], ...
        ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS"], ...
        [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ...
        ' runs -- first ', num2str(plotFirstNSeconds), ' sec.'], []);
    
    if kidnapRobot
        kidnapIndicesPlot = kidnapFirstSample - 10:kidnapFirstSample + index - 10;
        plotErrors(t(kidnapIndicesPlot), [meanErrorsPF(kidnapIndicesPlot); meanErrorsUPF(kidnapIndicesPlot); ...
            meanErrorsPFC(kidnapIndicesPlot); meanErrorsUPFC(kidnapIndicesPlot);
            meanErrorsPFS(kidnapIndicesPlot); meanErrorsUPFS(kidnapIndicesPlot)], ...
            [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC;
            meanRmsErrorPFS; meanRmsErrorUPFS], ...
            [meanVarPF(kidnapIndicesPlot); meanVarUPF(kidnapIndicesPlot); meanVarPFC(kidnapIndicesPlot); meanVarUPFC(kidnapIndicesPlot);
            meanVarPFS(kidnapIndicesPlot); meanVarUPFS(kidnapIndicesPlot)], ...
            ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS"], ...
            [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ...
            ' runs -- first ', num2str(plotFirstNSeconds), ' sec. after kidnapping'], kidnapFirstSample);
    end
end

plotErrors(t, [meanErrorsPF; meanErrorsUPF; meanErrorsPFC; meanErrorsUPFC; meanErrorsPFS; meanErrorsUPFS], ...
    [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC; meanRmsErrorPFS; meanRmsErrorUPFS], ...
    [meanVarPF; meanVarUPF; meanVarPFC; meanVarUPFC; meanVarPFS; meanVarUPFS], ...
    ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS"], ...
    [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ' runs'], kidnapFirstSample);

plotBoxPlots([timesPF, timesUPF, timesPFC, timesUPFC, timesPFS, timesUPFS], ...
    [fileName, ' -- box plot of computation time after ', num2str(nRuns), ' runs']);

plotBoxPlots([errorsPF(:, 1), errorsUPF(:, 1), errorsPFC(:, 1), ...
    errorsUPFC(:, 1), errorsPFS(:, 1), errorsUPFS(:, 1)], ...
    [fileName, ' -- box plot of initial errors after ', num2str(nRuns), ' runs']);

if kidnapRobot
    plotBoxPlots([errorsPF(:, kidnapFirstSample), errorsUPF(:, kidnapFirstSample), errorsPFC(:, kidnapFirstSample), ...
        errorsUPFC(:, kidnapFirstSample), errorsPFS(:, kidnapFirstSample), errorsUPFS(:, kidnapFirstSample)], ...
        [fileName, ' -- box plot of kidnap errors after ', num2str(nRuns), ' runs']);
end
%%
plotBoxPlots([meanErrorsPF; meanErrorsUPF; meanErrorsPFC; meanErrorsUPFC; meanErrorsPFS; meanErrorsUPFS]', ...
    [fileName, ' -- box plot of mean errors after ', num2str(nRuns), ' runs']);
%%
plotBoxPlots([reshape(errorsPF', 1, []); reshape(errorsUPF', 1, []); reshape(errorsPFC', 1, []); ...
    reshape(errorsUPFC', 1, []); reshape(errorsPFS', 1, []); reshape(errorsUPFS', 1, [])]', ...
    [fileName, ' -- box plot of errors after ', num2str(nRuns), ' runs']);

savePlots2PDF(logFilePath, [logFileName, '-results'], true);
%%
diary off

save([logFilePath, logFileName, '.mat']);

saveTables

