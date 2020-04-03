function c = vertcat(varargin)
%HORZCAT      Implements  [a(1) ; a(2) ; ...]  for fl-type
%

% written  10/21/13     S.M. Rump
%

  a = fl(varargin{1});
  c = a;

  for i=2:length(varargin)
    a = fl(varargin{i});
    c.value = [ c.value ; a.value ];
  end
