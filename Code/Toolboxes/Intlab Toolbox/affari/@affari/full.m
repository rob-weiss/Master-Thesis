function a = full(a)
%FULL         type cast to full affari matrix
%
%   c = full(a)
%
%Functionality as in Matlab.
%

% written  04/25/14     S.M. Rump 
%

  a.mid = full(a.mid);
  a.rnderr = full(a.rnderr);
  a.range = full(a.range);
  