function A = permute(A,order)
%PERMUTE      Rearrange dimensions of N-D gradient array
%
%  B = permute(A,order)
%
%Same functionality as Matlab's "permute" applied to 
%gradient arrays.
%

% written  02/24/15     S.M. Rump  (Thanks go JF Williams for pointing to this)
% modified 02/24/15     S.M. Rump  avoid superiorto, already in constructor
%
  
%   superiorto('intval');
%   superiorto('affari');
  
  s = size(A.x);
  index = permute(reshape(1:prod(s),s),order);
  A.x = permute(A.x,order);
  A.dx = A.dx(index(:),:);
  