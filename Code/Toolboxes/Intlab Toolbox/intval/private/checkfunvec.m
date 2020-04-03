function m = checkfunvec(f,x,param)
% Kopie in verifyglobal für Octave, das private files nicht von private aufruft
%CHECKFUN     check parallelization of function
%output: dimension of image space
%

% written  07/17/15     S.M. Rump
%

  if nargin<3
    param = [];
  end
  
  % randomize x
  x = midrad(mid(x),1e-2*rand(size(x)).*rad(x));

  mx = mid(x); 
  xinf = x.inf;
  xsup = x.sup;
  
  % take care of inifinite components
  index = isinf(x.inf);
  if any(index)
    xinf(index) = -1;
  end
  index = isinf(x.sup);
  if any(index)
    xsup(index) = 1;
  end
  index = isinf(xinf) & isinf(xsup);
  if any(index(:))
    xinf(index) = -1;
    xsup(index) = 1;
    mx(index) = 0;
  end
  x = [ infsup(xinf,mx) infsup(mx,xsup) xinf mx xsup];
  
  if isempty(param)
    y = f(x);
  else
    y = f(x,param{:});
  end
  if ~isequal(size(x,2),size(y,2))
    error('The input function seems to be not parallelized. Please use "funvec" or ensure that f([x x])=[f(x) f(x)].');
  end
  
  m = size(y,1);
  y1 = intval([]);
  if isempty(param)
    for i=1:size(x,2)
      y1 = [y1 f(x(:,i))];
    end
  else
    for i=1:size(x,2)
      y1 = [y1 f(x(:,i),param{:})];
    end
  end
  if any(relerr(y,y1)>1e-10)
    error('The input function seems to be not parallelized. Please use "funvec" or ensure that f([x x])=[f(x) f(x)].');
  end
    
end  % function checkfunvec    
    