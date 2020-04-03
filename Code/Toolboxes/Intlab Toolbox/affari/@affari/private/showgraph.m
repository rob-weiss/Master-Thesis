function showgraph(f,p,q,delta,X,mu)
% call showgraph('fun',p,q,delta,a.range)     for p*x+q +/- delta
% call showgraph('fun',p,q,delta,a.range,mu)  for p*(x-mu)+q +/- delta

% written  04/04/14    S.M. Rump
% modified 04/23/14    S.M. Rump  set/getappdata replaced by global
%

  global INTLAB_CONST

  p = mid(p);
  q = mid(q);
  x = linspace(X.inf,X.sup,1000);
  if ismember(f,{'sin(x)','cos(x)','tan(x)','cot(x)'})   % range reduction
    X = INTLAB_CONST.ORIGINAL_RANGE;
    xx = linspace(X.inf,X.sup,1000);
  else
    xx = x;
  end
  F = vectorize(inline(f));
  if nargin<6
    y = p*x + q;
    plot(xx,F(xx),xx,y,xx,y+delta,':',xx,y-delta,':')
  else
    y = p*(x-mu) + q;
    plot(xx,F(xx),xx,y,xx,y+delta,':',xx,y-delta,':')
  end
  Y = F(X);
%   INTLAB_CONST.AFFARI_TEST.DIFF = F(xx)-y;
%   INTLAB_CONST.AFFARI_TEST.DELTA = delta;
  ex = 0.04*(X.sup-X.inf);
  ey = 0.04*(Y.sup-Y.inf);
  axis([X.inf-ex X.sup+ex Y.inf-ey Y.sup+ey])
  if INTLAB_CONST.AFFARI_APPROX
    approx = 'MinRange';
  else
    approx = 'Chebyshev';
  end
  title([approx ' approximation of ' f ' on X = ' infsup(X) ])
