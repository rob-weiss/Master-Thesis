function r = isempty(A)
%ISEMPTY      Returns 1 if input is empty, i.e. [], in the sense of Matlab
%
%   r = isempty(A)
%
%There are no empty intervals in the mathematical sense in INTLAB. For details,
%  please see Readme.txt
%

% written  11/06/13     S.M. Rump
%

  r = isempty(A.value);

