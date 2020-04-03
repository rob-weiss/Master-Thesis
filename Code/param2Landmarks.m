%% Basic user settings

load('Trajectory_4_with_2_landmarks.mat');  % Load data

nParticlesPF          = 10000;       % Number of particles generic   particle filter
nParticlesUPF         = 100;       % Number of particles unscented particle filter
nParticlesPFC         = 10000;       % Number of particles generic   particle filter with contractor
nParticlesUPFC        = 100;       % Number of particles unscented particle filter with contractor
nParticlesPFS         = 10000;       % Number of particles generic   particle filter with SIVIA
nParticlesUPFS        = 100;       % Number of particles generic   particle filter with SIVIA

scaleInitSearchSpace  = 1;          % Controls the size of the initial search space
convThreshold         = 1;          % If error in m is less than convThreshold the filter has converged

uncertaintyIntConstr  = 20 * sigmaDistances; % Uncertainty interval used for constraint filtering

contr.maxNContr       = 2;                 % Maximum number of contractions
contr.threshold       = 10000;              % Stop contracting when the reduction in volume is less than thresholdContr
contr.epsilon         = 1;                  % Epsilon for iterative contractors: 'newt', 'comb', 'mohc'
contr.contrType       = 'fbprop';           % Contractor type: 'fbprop', 'boxnar', 'boxnarnewt', 'newt', 'comb', 'mohc'
contr.uncertaintyInt  = 5 * sigmaDistances; % Uncertainty interval used for contractor

siv.epsilon         = 10;
siv.contrType       = 'fbprop';           % Contractor type: 'fbprop', 'boxnar', 'boxnarnewt', 'newt', 'comb', 'mohc'
siv.uncertaintyInt  = 5 * sigmaDistances; % Uncertainty interval used for SIVIA

% Standard deviation of the noise generator function and the likelihood and transition prior PDFs
sigmaSysNoisePF       = 0.1 * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaSysNoisePFC      = 0.1 * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaSysNoisePFS      = 0.1 * 100  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];

sigmaLikelihoodPF     = 10  * 10   * sigmaDistances;
sigmaLikelihoodPFC    = 10  * 10   * sigmaDistances;
sigmaLikelihoodPFS    = 10  * 10   * sigmaDistances;

sigmaLikelihoodUPF    = 10 * 10   * sigmaDistances;
sigmaLikelihoodUPFC   = 10 * 10   * sigmaDistances;
sigmaLikelihoodUPFS   = 10 * 10 * sigmaDistances;

sigmaTransPriorUPF    = 1 * 1000 * (sigmaVelocity + sigmaEulerAngles);
sigmaTransPriorUPFC   = 1 * 1000 * (sigmaVelocity + sigmaEulerAngles);
sigmaTransPriorUPFS   = 1 * 1000 * (sigmaVelocity + sigmaEulerAngles);

sigmaP0UPF            = 1;
sigmaP0UPFC           = 1;
sigmaP0UPFS           = 1;
sigmaQUPF             = 0.5  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaQUPFC            = 0.5  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaQUPFS            = 0.5  * [sigmaVelocity * ones(1,3), sigmaEulerAngles * ones(1,3)];
sigmaRUPF             = 0.1 * sigmaDistances;
sigmaRUPFC            = 0.1 * sigmaDistances;
sigmaRUPFS            = 0.1 * sigmaDistances;