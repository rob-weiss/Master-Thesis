function [matrix] = rotationMatrix(eulerAnglesYPR)
% yaw-pitch-roll: z, y′, x″-convention
% Transform coordinates from body frame to world frame.

psi = eulerAnglesYPR(1, :);
theta = eulerAnglesYPR(2, :);
phi = eulerAnglesYPR(3, :);

matrix(1,1) =  cos(theta) * cos(psi);
matrix(1,2) =  sin(phi)   * sin(theta) * cos(psi) - cos(phi) * sin(psi);
matrix(1,3) =  cos(phi)   * sin(theta) * cos(psi) + sin(phi) * sin(psi);
matrix(2,1) =  cos(theta) * sin(psi);
matrix(2,2) =  sin(phi)   * sin(theta) * sin(psi) + cos(phi) * cos(psi);
matrix(2,3) =  cos(phi)   * sin(theta) * sin(psi) - sin(phi) * cos(psi);
matrix(3,1) = -sin(theta);
matrix(3,2) =  sin(phi)   * cos(theta);
matrix(3,3) =  cos(phi)   * cos(theta);

end