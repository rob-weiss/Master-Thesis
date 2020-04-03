function res = isequalwithequalnans(varargin)
%ISEQUALWITHEQUALNANS  Functionality as Matlab's isequalwithequalnans
%

% written  08/30/15     S.M. Rump
%

  if length(varargin)>2
    res = isequalwithequalnans(varargin{2:end});    
  else
    res = 1;
  end
  a = varargin{1};
  index = isnan(varargin{1});  
  %VVVV  a(index) = 1;
  s.type = '()'; s.subs = {index}; a = subsasgn(a,s,1);
  %AAAA  Matlab bug fix
  b = varargin{2};
  index = isnan(varargin{2});
  %VVVV  b(index) = 1;
  s.type = '()'; s.subs = {index}; b = subsasgn(b,s,1);
  %AAAA  Matlab bug fix

  res = res && isequal(a,b);
