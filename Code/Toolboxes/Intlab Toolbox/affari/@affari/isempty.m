function r = isempty(a)
%ISEMPTY      Returns 1 if input is empty, i.e. [], in the sense of Matlab
%
%   r = isempty(a)
%
%There are no empty intervals in the mathematical sense in INTLAB. For details,
%  please see Readme.txt
%

% written  10/03/14  S.M. Rump
%

  r = isempty(a.mid);
