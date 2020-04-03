function a = reshape(a,varargin)
%RESHAPE      Reshape for affari vectors/matrices
%
%  c = reshape(a,m,n)  or  c = reshape(a,size)
%

% written  09/03/14     S.M. Rump
%

  a.mid = reshape(a.mid,varargin{:});
  a.range = reshape(a.range,varargin{:});
