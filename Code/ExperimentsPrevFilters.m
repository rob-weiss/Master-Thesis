%% Clear memory and console, close all figures, load data and parameters

clear, clc, close all
cd '/Users/rob/Documents/Archive/Studies/Master Thesis/Code'

addpath(genpath('Functions'));
addpath(genpath('Toolboxes'));
addpath(genpath('../Preprocessed Data'));

paramScript = 'param2Landmarks';    % Specify parameterisation script

PFCP                  = true;       % Particle filter estimation with contractor (previous)
PFSP                  = true;       % Particle filter estimation with SIVIA (previous

kidnapRobot           = true;       % Kidnap robot
nRuns                 = 100;        % Number of runs

plotEstimatesLive     = false;      % Plot 3D trajectory, particles, boxes, and estimation results live
plotResizeLive        = false;      % Resize the figure automatically, zooming into the latest object plotted
plotFullscreen        = false;      % Make figure full-screen
plotFirstNSeconds     = 40;         % Plot the first n seconds after start or kidnapping at higher time resolution
pauseTime             = 0;          % Time between two consecutive updates of live plots in seconds

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

xhPFCP           = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the PFCP -> particle filter with contractor (previous)
xhPFSP           = zeros(nx, nSamples, nRuns); % Matrix of states estimated by the PFSP -> particle filter with SIVIA (previous)

varPFCP          = zeros(nRuns, nSamples);     % Matrix of particle variances of the PFCP
varPFSP          = zeros(nRuns, nSamples);     % Matrix of particle variances of the PFSP

errorsPFCP       = zeros(nRuns, nSamples);     % Matrix of errors of PFCP
errorsPFSP       = zeros(nRuns, nSamples);     % Matrix of errors of PFSP

rmsErrorsPFCP    = zeros(nRuns, 1);            % Root mean-square errors of PFCP
rmsErrorsPFSP    = zeros(nRuns, 1);            % Root mean-square errors of PFSP

nZeroWeightsPFCP = zeros(nRuns, nSamples);     % Number of weights of PFCP  set to zero
nZeroWeightsPFSP = zeros(nRuns, nSamples);     % Number of weights of PFSP  set to zero

nRestartsPFCP    = zeros(nRuns, nSamples);     % Number of restarts of PFCP due to localisation failure
nRestartsPFSP    = zeros(nRuns, nSamples);     % Number of restarts of PFSP due to localisation failure

timesPFCP        = zeros(nRuns, 1);            % Time duration of estimation PFC
timesPFSP        = zeros(nRuns, 1);            % Time duration of estimation PFS

% Compute enclosing of the initial search space
limits = scaleInitSearchSpace * [lowerLimits; upperLimits];  % Scale initial search space
initialVolume = volume(limits);                              % Compute volume of initial search space

pf.initialBox = [infsup(limits(1, 1), limits(2, 1)), ...     % Initial box
    infsup(limits(1, 2), limits(2, 2)), infsup(limits(1, 3), limits(2, 3))];
pf.propagatedBox = pf.initialBox;

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


% Particle filter with contractor (previous)
pfcp                      = pf;
pfcp.nParticles           = nParticlesPFC;                                            % Number of particles
pfcp.likelihoodPDF        = likelihoodPDF(diag(sigmaLikelihoodPFC.^2 * ones(1, nz))); % p(y[k] | x[k])
pfcp.genSysNoise          = genSysNoise(diag(sigmaSysNoisePFC.^2));                   % Noise generator function
pfcp.constraintFiltering  = 'always';
pfcp.boundedErrorAlg      = 'contr';
pfcp.boundedErrorProp     = contr;

% Particle filter with SIVIA (previous)
pfsp                      = pf;
pfsp.nParticles           = nParticlesPFS;                                            % Number of particles
pfsp.likelihoodPDF        = likelihoodPDF(diag(sigmaLikelihoodPFS.^2 * ones(1, nz))); % p(y[k] | x[k])
pfsp.genSysNoise          = genSysNoise(diag(sigmaSysNoisePFS.^2));                   % Noise generator function
pfsp.constraintFiltering  = 'always';
pfsp.boundedErrorAlg      = 'sivia';
pfsp.boundedErrorProp     = siv;

% load old results


%% Log values of interest

logFileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
logFilePath = ['/Users/rob/Documents/Archive/Studies/Master Thesis/Results/', logFileName, '/'];
mkdir(logFilePath);

% Save current data set for repetition of experiments
copyfile(['/Users/rob/Documents/Archive/Studies/Master Thesis/Preprocessed data/', fileName, '.mat'], ...
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
fprintf(['No. of particles PFCP:     %i',              newline ],       pfcp.nParticles);
fprintf(['No. of particles PFSP :    %i',              newline2],       pfsp.nParticles);

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

fprintf(['Sigma likelihood PFCP:     %4.3f m',         newline ],       sigmaLikelihoodPFC);
fprintf(['Sigma likelihood PFS?:     %4.3f m',         newline ],       sigmaLikelihoodPFS);

fprintf(['--- Estimation Results ------------------------------------------', newline3]);

%%
load '/Users/rob/Documents/Archive/Studies/Master Thesis/Results/Kidnapping/2 Landmarks/2018-10-04-15-13-55 merged with 2018-10-24-11-42-10/2018-10-04-15-13-55.mat';
logFileName = datestr(now, 'yyyy-mm-dd-HH-MM-SS');
logFilePath = ['/Users/rob/Documents/Archive/Studies/Master Thesis/Results/', logFileName, '/'];

for runIndex = 1:nRuns
    
    fprintf(['--- Run no. %i -----------------------', newline3], runIndex);
    
    if PFCP
        fprintf(['--- Particle filter with contractor (previous) ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results particle filter with contractor (previous) run no. ', num2str(runIndex)], plotFullscreen);
        
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhPFCP(:, k, runIndex), varPFCP(runIndex, :), pfcp, ...
                nZeroWeightsPFCP(runIndex, k)] = particleFilterPrev(...
                k, velocityInputs(:,k), distanceMeasurements(:, k), pfcp, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesPFCP(runIndex) = toc;
        [rmsErrorsPFCP(runIndex, 1), errorsPFCP(runIndex, :)] = computeErrors(position, xhPFCP(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline],  timesPFCP(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsPFCP(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsPFCP(runIndex, :)), ...
            100 * sum(nZeroWeightsPFCP(runIndex, :)) / (pfcp.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsPFCP(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhPFCP(:, :, runIndex));
        end
    end
    
    if PFSP
        fprintf(['--- Particle filter with SIVIA (previous) ---', newline2]);
        
        plotTrajectory(landmarks, position, ...
            ['Results particle filter with contractor (previous) run no. ', num2str(runIndex)], plotFullscreen);
         
        diary off
        tic
        
        % State estimation
        for k = 1:nSamples
            [xhPFSP(:, k, runIndex), varPFSP(runIndex, :), pfsp, ...
                nZeroWeightsPFSP(runIndex, k)] = particleFilterPrev(...
                k, velocityInputs(:,k), distanceMeasurements(:, k), pfsp, eulerAnglesYPRInputs(:, k));
        end
        
        % Compute elapse time and errors
        timesPFSP(runIndex) = toc;
        [rmsErrorsPFSP(runIndex, 1), errorsPFSP(runIndex, :)] = computeErrors(position, xhPFSP(:, :, runIndex));
        
        diary on
        fprintf(['Elapsed time:            %3.1f sec', newline],  timesPFSP(runIndex));
        fprintf(['RMSE:                    %2.2f m  ', newline ], rmsErrorsPFSP(runIndex, 1));
        fprintf(['No. weights set to zero: %i (%3.1f %%)', newline ], sum(nZeroWeightsPFSP(runIndex, :)), ...
            100 * sum(nZeroWeightsPFSP(runIndex, :)) / (pfsp.nParticles * nSamples));
        fprintf(['Error < %1.1f m after:     %3.1f sec', newline3], convThreshold, ...
            t(find(errorsPFSP(runIndex, :) < convThreshold, 1)));
        
        if ~plotEstimatesLive
            plotEstimationResults(xhPFSP(:, :, runIndex));
        end
    end
    
        plotZeroWeights(t, [nZeroWeightsPFCP(runIndex, :); ...
            nZeroWeightsPFSP(runIndex, :)], ["PFCP", "PFSP"], ...
            ['Number of particle weights set to zero by constraints -- run no. ', num2str(runIndex)]);

   %%
    plotErrors(t, [ ...
        errorsPF(runIndex, :); errorsUPF(runIndex, :); ...
        errorsPFC(runIndex, :); errorsUPFC(runIndex, :); ...
        errorsPFS(runIndex, :); errorsUPFS(runIndex, :); ...
        errorsPFCP(runIndex, :); errorsPFSP(runIndex, :)], ...
        [rmsErrorsPF(runIndex, 1); rmsErrorsUPF(runIndex, 1); ...
        rmsErrorsPFC(runIndex, 1); rmsErrorsUPFC(runIndex, 1); ...
        rmsErrorsPFS(runIndex, 1); rmsErrorsUPFS(runIndex, 1); ...
        rmsErrorsPFCP(runIndex, 1); rmsErrorsPFSP(runIndex, 1)], ...
        [varPF(runIndex, :); varUPF(runIndex, :); ...
        varPFC(runIndex, :); varUPFC(runIndex, :); ...
        varPFS(runIndex, :); varUPFS(runIndex, :); ...
        varPFCP(runIndex, :); varPFSP(runIndex, :)], ...
        ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS", "PFCP", "PFSP"], ...
        [fileName, ' -- errors vs. time -- run no. ', num2str(runIndex)], kidnapFirstSample);
    
    savePlots2PDF(logFilePath, [logFileName, '-run-', num2str(runIndex)], true);
    
    fprintf(['--------------------------------------------------------', newline2]);
    
%     if runIndex == 2
%         break
%     end
end

%% Compute mean errors

meanErrorsPFCP        = mean(errorsPFCP, 1);
meanErrorsPFSP        = mean(errorsPFSP, 1);

meanRmsErrorPFCP      = mean(rmsErrorsPFCP, 1);
meanRmsErrorPFSP      = mean(rmsErrorsPFSP, 1);

meanVarPFCP            = mean(varPFCP, 1);
meanVarPFSP            = mean(varPFSP, 1);

meanNZeroWeightsPFCP   = round(mean(nZeroWeightsPFCP,  1), 0);
meanNZeroWeightsPFSP   = round(mean(nZeroWeightsPFSP,  1), 0);

totalNZeroWeightsPFCP  = sum(meanNZeroWeightsPFCP);
totalNZeroWeightsPFSP  = sum(meanNZeroWeightsPFSP);

relNZeroWeightsPFCP    = 100 * totalNZeroWeightsPFCP  / (nParticlesPFC  * nSamples);
relNZeroWeightsPFSP    = 100 * totalNZeroWeightsPFSP  / (nParticlesPFS  * nSamples);

relPerformancePFCP     = 100 * meanRmsErrorPFCP  / meanRmsErrorPF;
relPerformancePFSP     = 100 * meanRmsErrorPFSP  / meanRmsErrorPF;

convTimePFCP          = t(find(meanErrorsPFCP  < convThreshold, 1))  - samplePeriod;
convTimePFSP          = t(find(meanErrorsPFSP  < convThreshold, 1))  - samplePeriod;

if isempty(convTimePF)
    convTimePF = nSamples; 
end
if isempty(convTimeUPF)
    convTimeUPF = nSamples; 
end
if isempty(convTimePFC)
    convTimePFC = nSamples; 
end
if isempty(convTimeUPFC)
    convTimeUPFC = nSamples; 
end
if isempty(convTimePFS)
    convTimePFS = nSamples; 
end
if isempty(convTimeUPFS)
    convTimeUPFS = nSamples; 
end
if isempty(convTimePFCP)
    convTimePFCP = nSamples; 
end
if isempty(convTimePFSP)
    convTimePFSP = nSamples; 
end

meanTimePFCP          = mean(timesPFCP);
meanTimePFSP          = mean(timesPFSP);

relTimePF             = meanTimePF   / meanTimePF;

relTimePFCP           = meanTimePFCP / meanTimePF;
relTimePFSP           = meanTimePFSP / meanTimePF;

fprintf(['--- Overall performance ---', newline2]);

fprintf(['Mean RMSE:                  ',   newline ]);
fprintf(['PF:                        %2.2f m',   newline ],  meanRmsErrorPF);
fprintf(['UPF:                       %2.2f m',   newline ],  meanRmsErrorUPF);
fprintf(['PFC:                       %2.2f m',   newline ],  meanRmsErrorPFC);
fprintf(['UPFC:                      %2.2f m',   newline ],  meanRmsErrorUPFC);
fprintf(['PFS:                       %2.2f m',   newline ],  meanRmsErrorPFS);
fprintf(['UPFS:                      %2.2f m',   newline2],  meanRmsErrorUPFS);

fprintf(['PFCP:                      %2.2f m',   newline ],  meanRmsErrorPFCP);
fprintf(['PFSP:                      %2.2f m',   newline2],  meanRmsErrorPFSP);


fprintf(['Mean initial error:               ',   newline ]);
fprintf(['PF:                        %2.2f m',   newline ],  meanErrorsPF(1));
fprintf(['UPF:                       %2.2f m',   newline ],  meanErrorsUPF(1));
fprintf(['PFC:                       %2.2f m',   newline ],  meanErrorsPFC(1));
fprintf(['UPFC:                      %2.2f m',   newline ],  meanErrorsUPFC(1));
fprintf(['PFS:                       %2.2f m',   newline ],  meanErrorsPFS(1));
fprintf(['UPFS:                      %2.2f m',   newline2],  meanErrorsUPFS(1));

fprintf(['PFCP:                      %2.2f m',   newline ],  meanErrorsPFCP(1));
fprintf(['PFSP:                      %2.2f m',   newline2],  meanErrorsPFSP(1));

fprintf(['Error < %1.1f m after:              ', newline ],  convThreshold);
fprintf(['PF:                        %3.2f sec', newline ],  convTimePF);
fprintf(['UPF:                       %3.2f sec', newline ],  convTimeUPF);
fprintf(['PFC:                       %3.2f sec', newline ],  convTimePFC);
fprintf(['UPFC:                      %3.2f sec', newline ],  convTimeUPFC);
fprintf(['PFS:                       %3.2f sec', newline ],  convTimePFS);
fprintf(['UPFS:                      %3.2f sec', newline2],  convTimeUPFS);

fprintf(['PFCP:                      %3.2f sec', newline ],  convTimePFCP);
fprintf(['PFSP:                      %3.2f sec', newline2],  convTimePFSP);

fprintf(['Mean computation time:              ', newline ]);
fprintf(['PF:                        %4.1f sec', newline ],  meanTimePF);
fprintf(['UPF:                       %4.1f sec', newline ],  meanTimeUPF);
fprintf(['PFC:                       %4.1f sec', newline ],  meanTimePFC);
fprintf(['UPFC:                      %4.1f sec', newline ],  meanTimeUPFC);
fprintf(['PFS:                       %4.1f sec', newline ],  meanTimePFS);
fprintf(['UPFS:                      %4.1f sec', newline2],  meanTimeUPFS);

fprintf(['PFCP:                      %4.1f sec', newline ],  meanTimePFCP);
fprintf(['PFSP:                      %4.1f sec', newline2],  meanTimePFSP);

fprintf(['Computation time relative to PF:    ', newline ]);
fprintf(['PF:                        %3.2f    ', newline ],  relTimePF);
fprintf(['UPF:                       %3.2f    ', newline ],  relTimeUPF);
fprintf(['PFC:                       %3.2f    ', newline ],  relTimePFC);
fprintf(['UPFC:                      %3.2f    ', newline ],  relTimeUPFC);
fprintf(['PFS:                       %3.2f    ', newline ],  relTimePFS);
fprintf(['UPFS:                      %3.2f    ', newline2],  relTimeUPFS);

fprintf(['PFCP:                      %3.2f    ', newline ],  relTimePFCP);
fprintf(['PFSP:                      %3.2f    ', newline2],  relTimePFSP);

fprintf(['Mean no. of weights set to zero:    ', newline ]);
fprintf(['PFC:                       %2i (%3.2f %%)', newline ], totalNZeroWeightsPFC,  relNZeroWeightsPFC);
fprintf(['UPFC:                      %2i (%3.2f %%)', newline ], totalNZeroWeightsUPFC, relNZeroWeightsUPFC);
fprintf(['PFS:                       %2i (%3.2f %%)', newline ], totalNZeroWeightsPFS,  relNZeroWeightsPFS);
fprintf(['UPFS:                      %2i (%3.2f %%)', newline2], totalNZeroWeightsUPFS, relNZeroWeightsUPFS);

fprintf(['PFCP:                      %2i (%3.2f %%)', newline ], totalNZeroWeightsPFCP,  relNZeroWeightsPFCP);
fprintf(['PFSP:                      %2i (%3.2f %%)', newline2], totalNZeroWeightsPFSP,  relNZeroWeightsPFSP);

fprintf(['No. of restarts of the filter:      ', newline ]);
fprintf(['PFC:                       %2i      ', newline ],  sum(sum(nRestartsPFC,  1)));
fprintf(['UPFC:                      %2i      ', newline ],  sum(sum(nRestartsUPFC, 1)));
fprintf(['PFS:                       %2i      ', newline ],  sum(sum(nRestartsPFS,  1)));
fprintf(['UPFS:                      %2i      ', newline2],  sum(sum(nRestartsUPFS, 1)));


fprintf(['PFCP:                      %2i      ', newline ],  sum(sum(nRestartsPFCP,  1)));
fprintf(['PFSP:                      %2i      ', newline2],  sum(sum(nRestartsPFSP,  1)));

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
        meanErrorsPFS(1:index); meanErrorsUPFS(1:index);
        meanErrorsPFCP(1:index); meanErrorsPFSP(1:index);], ...
        [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC;
        meanRmsErrorPFS; meanRmsErrorUPFS; meanRmsErrorPFCP; meanRmsErrorPFSP], ...
        [meanVarPF(1:index); meanVarUPF(1:index); meanVarPFC(1:index); meanVarUPFC(1:index);
        meanVarPFS(1:index); meanVarUPFS(1:index); meanVarPFCP(1:index); meanVarPFSP(1:index)], ...
        ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS", "PFCP", "PFSP"], ...
        [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ...
        ' runs -- first ', num2str(plotFirstNSeconds), ' sec.'], []);
    
    if kidnapRobot
        kidnapIndicesPlot = kidnapFirstSample - 10:kidnapFirstSample + index - 10;
        plotErrors(t(kidnapIndicesPlot), [meanErrorsPF(kidnapIndicesPlot); meanErrorsUPF(kidnapIndicesPlot); ...
            meanErrorsPFC(kidnapIndicesPlot); meanErrorsUPFC(kidnapIndicesPlot);
            meanErrorsPFS(kidnapIndicesPlot); meanErrorsUPFS(kidnapIndicesPlot);
            meanErrorsPFCP(kidnapIndicesPlot); meanErrorsPFSP(kidnapIndicesPlot)], ...
            [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC;
            meanRmsErrorPFS; meanRmsErrorUPFS; meanRmsErrorPFCP; meanRmsErrorPFSP], ...
            [meanVarPF(kidnapIndicesPlot); meanVarUPF(kidnapIndicesPlot); meanVarPFC(kidnapIndicesPlot); meanVarUPFC(kidnapIndicesPlot);
            meanVarPFS(kidnapIndicesPlot); meanVarUPFS(kidnapIndicesPlot); meanVarPFCP(kidnapIndicesPlot); meanVarPFSP(kidnapIndicesPlot)], ...
            ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS", "PFCP", "PFSP"], ...
            [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ...
            ' runs -- first ', num2str(plotFirstNSeconds), ' sec. after kidnapping'], kidnapFirstSample);
    end
end

plotErrors(t, [meanErrorsPF; meanErrorsUPF; meanErrorsPFC; meanErrorsUPFC; meanErrorsPFS; meanErrorsUPFS; meanErrorsPFCP; meanErrorsPFSP], ...
    [meanRmsErrorPF; meanRmsErrorUPF; meanRmsErrorPFC; meanRmsErrorUPFC; meanRmsErrorPFS; meanRmsErrorUPFS; meanRmsErrorPFCP; meanRmsErrorPFSP], ...
    [meanVarPF; meanVarUPF; meanVarPFC; meanVarUPFC; meanVarPFS; meanVarUPFS; meanVarPFCP; meanVarPFSP], ...
    ["PF", "UPF", "PFC", "UPFC", "PFS", "UPFS", "PFCP", "PFSP"], ...
    [fileName, ' -- mean errors vs. time after ', num2str(nRuns), ' runs'], kidnapFirstSample);

% plotBoxPlots([timesPF, timesUPF, timesPFC, timesUPFC, timesPFS, timesUPFS, timesPFCP, timesPFSP], ...
%     [fileName, ' -- box plot of computation time after ', num2str(nRuns), ' runs']);

plotBoxPlots([errorsPF(:, 1), errorsUPF(:, 1), errorsPFC(:, 1), ...
    errorsUPFC(:, 1), errorsPFS(:, 1), errorsUPFS(:, 1), errorsPFCP(:, 1), errorsPFSP(:, 1)], ...
    [fileName, ' -- box plot of initial errors after ', num2str(nRuns), ' runs']);

if kidnapRobot
    plotBoxPlots([errorsPF(:, kidnapFirstSample), errorsUPF(:, kidnapFirstSample), errorsPFC(:, kidnapFirstSample), ...
        errorsUPFC(:, kidnapFirstSample), errorsPFS(:, kidnapFirstSample), errorsUPFS(:, kidnapFirstSample), errorsPFCP(:, kidnapFirstSample), errorsPFSP(:, kidnapFirstSample)], ...
        [fileName, ' -- box plot of kidnap errors after ', num2str(nRuns), ' runs']);
end

plotBoxPlots([meanErrorsPF; meanErrorsUPF; meanErrorsPFC; meanErrorsUPFC; meanErrorsPFS; meanErrorsUPFS; meanErrorsPFCP; meanErrorsPFSP]', ...
    [fileName, ' -- box plot of mean errors after ', num2str(nRuns), ' runs']);

plotBoxPlots([reshape(errorsPF', 1, []); reshape(errorsUPF', 1, []); reshape(errorsPFC', 1, []); ...
    reshape(errorsUPFC', 1, []); reshape(errorsPFS', 1, []); reshape(errorsUPFS', 1, []); reshape(errorsPFCP', 1, []); ...
    reshape(errorsPFSP', 1, [])]', ...
    [fileName, ' -- box plot of errors after ', num2str(nRuns), ' runs']);

savePlots2PDF(logFilePath, [logFileName, '-results'], true);

diary off

save([logFilePath, logFileName, '.mat']);

saveTables

