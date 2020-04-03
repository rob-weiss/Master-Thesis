function A = squeeze(A)
%SQUEEZE      Like Matlab function "squeeze" for intval
%
%Call
%
%   B = squeeze(A)
%
%Same functionality as Matlab/squeeze for intval quantity 
%

% written  12/06/05     S.M. Rump
%

  if A.complex                % complex input
    A.mid = squeeze(A.mid);
    if ~isequal(A.rad,0)
      A.rad = squeeze(A.rad);
    end
  else                        % real input
    A.inf = squeeze(A.inf);
    A.sup = squeeze(A.sup);
  end
