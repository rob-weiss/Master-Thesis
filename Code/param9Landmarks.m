%% Basic user settings

load('Trajectory_4_with_9_landmarks.mat');  % Load data

nParticlesPF          = 100;       % Number of particles generic   particle filter
nParticlesUPF         = 10;       % Number of particles unscented particle filter
nParticlesPFC         = 100;       % Number of particles generic   particle filter with contractor
nParticlesUPFC        = 10;       % Number of particles unscented particle filter with contractor
nParticlesPFS         = 100;       % Number of particles generic   particle filter with SIVIA
nParticlesUPFS        = 10;       % Number of particles generic   particle filter with SIVIA

scaleInitSearchSpace  = 1;          % Controls the size of the initial search space
convThreshold         = 1;          % If error in m is less than convThreshold the filter has converged

uncertaintyIntConstr  = 10 * sigmaDistances; % Uncertainty interval used for constraint filtering

contr.maxNContr       = 5;                  % Maximum number of contractions
contr.threshold       = 1000;               % Stop contracting when the reduction in volume is less than thresholdContr
contr.epsilon         = 1;                  % Epsilon for iterative contractors: 'newt', 'comb', 'mohc'
contr.contrType       = 'fbprop';           % Contractor type: 'fbprop', 'boxnar', 'boxnarnewt', 'newt', 'comb', 'mohc'
contr.uncertaintyInt  = 5 * sigmaDistances; % Uncertainty interval used for contractor

siv.epsilon         = 1;
siv.contrType       = 'fbprop';           % Contractor type: 'fbprop', 'boxnar', 'boxnarnewt', 'newt', 'comb', 'mohc'
siv.uncertaintyInt  = 5 * sigmaDistances; % Uncertainty interval used for SIVIA

% Standard deviation of the noise generator function and the likelihood and transition prior PDFs
sigmaSysNoisePF       = 1   * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaSysNoisePFC      = 0.2 * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaSysNoisePFS      = 0.2 * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];

sigmaLikelihoodPF     = 5   * 10   * sigmaDistances;
sigmaLikelihoodPFC    = 0.5 * 10   * sigmaDistances;
sigmaLikelihoodPFS    = 0.5 * 10   * sigmaDistances;

sigmaLikelihoodUPF    = 1   * 10   * sigmaDistances;
sigmaLikelihoodUPFC   = 0.1 * 10   * sigmaDistances;
sigmaLikelihoodUPFS   = 0.1 * 10   * sigmaDistances;

sigmaTransPriorUPF    = 1   * 1000 * (sigmaVelocity + sigmaEulerAngles);
sigmaTransPriorUPFC   = 0.5 * 1000 * (sigmaVelocity + sigmaEulerAngles);
sigmaTransPriorUPFS   = 0.5 * 1000 * (sigmaVelocity + sigmaEulerAngles);

sigmaP0UPF            = 100;
sigmaP0UPFC           = 1;
sigmaP0UPFS           = 1;
sigmaQUPF             = 1     * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaQUPFC            = 0.5   * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaQUPFS            = 0.5   * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaRUPF             = 0.1 * sigmaDistances;
sigmaRUPFC            = 0.1 * sigmaDistances;
sigmaRUPFS            = 0.1 * sigmaDistances;