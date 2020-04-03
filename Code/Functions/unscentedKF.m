function [mu, Pk] = unscentedKF(k, xkm1, ukm1, zk, Pkm1, ukf, additionalArgsSys, additionalArgsObs)

% INPUTS:     - mu             : state mean estimate at time k
%             - Pkm1           : state covariance at time k-1
%             - ukm1           : vector of control inputs
%             - zk             : observation at time k
%             - ukf.Q       : process noise covariance
%             - ukf.R       : measurement noise covariance
%             - ukf.sys         : system model function
%             - ukf.obs         : observation model function
%             - k              : time step
%             - ukf.alpha   : sigma point scaling parameter. Defaults to 1.
%             - ukf.beta    : higher order error scaling parameter. Default to 0.
%             - ukf.kappa   : scalar tuning parameter 1. Defaults to 0.
%
% OUTPUTS:    - mu             : updated estimate of state mean at time k
%             - Pk             : updated state covariance at time k

%% Calculate dimensions
nx      = size(xkm1, 1);
nz      = size(zk, 1);
nv      = nz;
nw      = 6;

nNoises = nv + nw;

%% Augment state vector and error covariance matrix
N = [ukf.Q, zeros(nw, nv); zeros(nv, nw), ukf.R];
Pkm1a = [Pkm1 zeros(nx, nNoises); zeros(nNoises, nx) N];
xkm1a = [xkm1; zeros(nNoises,1)];

%% Calculate sigma points and their weights using the scaled unscented transformation
[xSigmaPts, wSigmaPts, nsp] = scaledSymmetricSigmaPoints(xkm1a, Pkm1a, ukf.alpha, ...
    ukf.beta, ukf.kappa);

%% Transform sigma points using system and observation model, respectively

xPredSigmaPts = zeros(nx, nsp);
zPredSigmaPts = zeros(nz, nsp);
for i = 1:nsp
    xPredSigmaPts(:, i) = ukf.sys(k, xSigmaPts(1:nx, i), ukm1, xSigmaPts(nx+1:nx+nw, i), ...
        additionalArgsSys{1}, additionalArgsSys{2});
    zPredSigmaPts(:, i) = ukf.obs(k, xPredSigmaPts(1:nx, i), xSigmaPts(nx+nw+1:nx+nNoises, i), ...
        additionalArgsObs{1});
end

% If sigma point outside the search space, project it on the border of the search space.
if any(xPredSigmaPts(3, :) < inf(ukf.initialBox(3)))
    xPredSigmaPts(3, xPredSigmaPts(3, :) < inf(ukf.initialBox(3))) = inf(ukf.initialBox(3));
end

if any(xPredSigmaPts(3, :) > sup(ukf.initialBox(3)))
    xPredSigmaPts(3, xPredSigmaPts(3, :) > sup(ukf.initialBox(3))) = sup(ukf.initialBox(3));
end

% Duplicate wSigmaPts into matrix for code speedup
wSigmaPts_xmat = repmat(wSigmaPts(1:nsp), nx, 1);
wSigmaPts_zmat = repmat(wSigmaPts(1:nsp), nz, 1);

% Compute weighted mean
xPred = sum(wSigmaPts_xmat .* xPredSigmaPts, 2);
zPred = sum(wSigmaPts_zmat .* zPredSigmaPts, 2);

% Work out the covariances and the cross correlations. Note that
% the weight on the 0th point is different from the mean
% calculation due to the scaled unscented algorithm.

exSigmaPt = xPredSigmaPts(:,1) - xPred;
ezSigmaPt = zPredSigmaPts(:,1) - zPred;

PPred = wSigmaPts(nsp+1) * (exSigmaPt * exSigmaPt');
Pzz   = wSigmaPts(nsp+1) * (ezSigmaPt * ezSigmaPt');
Pxz   = wSigmaPts(nsp+1) * (exSigmaPt * ezSigmaPt');

exSigmaPt = xPredSigmaPts(:,2:nsp) - repmat(xPred,1,nsp-1);
ezSigmaPt = zPredSigmaPts(:,2:nsp) - repmat(zPred,1,nsp-1);

for i = 1:nsp-1
    PPred     = PPred + wSigmaPts(i+1) * (exSigmaPt(:,i) * exSigmaPt(:,i)');
    Pzz       = Pzz   + wSigmaPts(i+1) * (ezSigmaPt(:,i) * ezSigmaPt(:,i)');
    Pxz       = Pxz   + wSigmaPts(i+1) * (exSigmaPt(:,i) * ezSigmaPt(:,i)');
end

% Calculate Kalman gain
K  = Pxz / Pzz;

% Calculate Innovation
innovation = zk - zPred;

% update mean
mu = xPred + K * innovation;

% update covariance
Pk = PPred - K * Pzz * K';