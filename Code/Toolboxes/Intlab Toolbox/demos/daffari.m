%% DEMOAFFARI  A demonstration of the affine arithmetic package

%% Affine arithmetic
% Ordinary interval arithmetic uses inf-sup or mid-rad representation for
% intervals. This implies well-known problems with dependencies, in
% particular the wrapping effect.
%
% A way to fight this is affine arithmetic. An affine interval X is stored as
% a midpoint x0 together with error terms x1,...,xk, and it represents
%
%   X = x0 + x1*E1 + ... + xk*Ek ,
%
% where E1,...,Ek are parameters independently varying within [-1,1]. Here
% x0,x1,...,xk are real numbers. A short notation is
%
%   X = < x0 ; x1,...,xk > .
%
% An INTLAB example is

format short intval
A = infsup(2,3)
X = affari(A)

%%
% The represented interval is  x0 +/- sum_i=1^k {abs(x_i)}, i.e. the sum of
% absolute values of the error terms is the radius to the midpoint x0. The
% different structure of ordinary intervals and affine intervals can be
% seen as follows.

struct(A)
struct(X)

%%
% When using affari quantities, INTLAB takes care of the error terms.
% Basically, with few exceptions to be mentioned, affari quantities can be
% used as ordinary intervals. 
% 

%% Fighting the wrapping effect I
% The concept of error terms can partially diminish the wrapping effect.
% For example,

ResIntval = A-A
ResAffari = X-X

%%
% So affine variables allow some cancellation. This is by principle not
% possible for interval arithmetic. This affects the estimation of the
% range of a function:

f = vectorize(inline('sqr(log2(x+1))-x*cos(x)-x*atan(x)+cosh(x)'))
X = infsup(0,1); 
x = linspace(X.inf,X.sup); 
close, plot(x,f(x))
ResIntval = f(X)
ResAffari = f(affari(X))
ratio = rad(ResAffari)/rad(ResIntval)

%%
% The radius of the range inclusion of the affari result is about half the 
% radius for ordinary
% interval arithmetic. Moreover, affine arithmetic proves that the function
% has no root in the interval X.

%% Fighting the wrapping effect II
% Affine arithmetic seems most effective for narrow input intervals and
% many dependencies (for an impressive example, see the Henon iteration below). 
% Consider

syms x
f = inline(char(expand((x-3)^8)))

%%
% The expanded formula shows many dependencies. Next we evaluate the
% expanded formula using ordinary and affine arithmetic. For narrow input, affine 
% arithmetic can cope with the dependencies better than ordinary interval arithmetic:

x = midrad(4,1e-4); 
yint = f(x)
yaff = f(affari(x))

%%
% For wide input, affine arithmetic delivers still better results, however,
% also with substantial overestimation:

x = infsup(1,2);
yint2 = f(x)
yaff2 = f(affari(x))
yacc = (x-3)^8

%%
% But also for wide input data affine arithmetic maybe superior to ordinary
% interval arithmetic. Consider the approximation of the sine by its
% truncated Taylor series:

f = inline('x - x^3/6 - sin(x)')
x = infsup(0,1)
yint = f(x)
yaff = f(affari(x))

%% Fighting the wrapping effect III
% The power of affine arithmetic can be visualized by a vector iteration.
% Define

A = 0.5*[1 2;-1 1]
rho = max(abs(eig(A)))

%%
% The matrix A is convergent, i.e. the spectral radius is less than 1.
% Hence the iteration  x_(i+1) := A*x_i  converges to zero for any starting
% vector x_0. This includes interval vectors x_0 provided power set
% multiplication is used. 
%
% When using ordinary interval arithmetic, the well-known wrapping effect
% occurs:

close, hold on 
color = [ 'b' 'g' 'r' 'c' 'm' 'y'];
clear x
x{1} = infsup(-1,1)*ones(2,1); 
for i=2:6
  x{i} = A*x{i-1}; 
end
for i=5:-1:1
  plotintval(x{i},color(i))
end
axis([-1 1 -1 1]*3.5)
axis equal
hold off
x{:}

%%
% Note that the starting interval x_0 is the most inner box, that is, the
% boxes become larger in each iteration step. 
%
% The same iteration using affine arithmetic looks as follows:

close, hold on 
x = affari(infsup(-1,1)*ones(2,1)); 
plotaffari(x,color(1))
for i=2:6
  x = A*x; 
  plotaffari(x,color(i))
end
axis([-1 1 -1 1]*1.55)
axis equal
hold off
x

%%
% Now the big blue square is x_0, and the most inner box is the last iterate, 
% that is, the boxes shrink in each iteration step. 

%% Fighting the wrapping effect IV
% The same effect can be observed in larger dimensions and visualized in 3 dimensions. 
% The result of a
% matrix times affari vector (which is a box) is a polytope. Adding some
% nonlinearity makes the picture more involved:

A = [ -4  1  2 ;  4  4 -3 ; 1  0 -1 ]
X = [ infsup(0.5,1.5) ; infsup(-3.2,-2.8) ; infsup(-4.3,-3.7) ]
close, plotaffari(A*affari(X)-sin(X))

%% Fighting the wrapping effect V
% Often matrices have a dominant eigenvalue. This cannot be utilized by
% ordinary interval arithmetic, but is nicely visible in affine arithmetic.
% Define A to be the scaled Hilbert 3x3 matrix:

n = 3;
A = 0.5*hilb(n)
rho = max(abs(eig(A)))

%%
% This matrix is convergent as well, and as a positive matrix its spectral
% radius is an simple eigenvalue. Hence the iteration x_(i+1) = A*x_i
% converges to the eigenvector to that eigenvalue, the Perron vector, for
% every non-trivial positive starting vector x_0. This can be observed for the
% [-1,1]-box as starting vector by INTLAB's affari package:

close, hold on 
x = affari(infsup(-1,1)*ones(n,1)); 
plotaffari(x,'n')
for i=1:5
  x = A*x; 
  plotaffari(x,'n')
end
axis([-1 1 -1 1 -1 1]*1.5), view(-19,8)
hold off

%% The Min-Range mode and the Chebyshev mode
% There are two main modes to perform affine operations, the Min-Range mode
% and the Chebyshev mode. As the names suggest, these are different
% linearization modes for nonlinear operations and functions. The
% difference can be visualized for scalar standard functions by the extra
% second parameter:

X = infsup(2,4);
affariinit('ApproxMinRange')
YMinRange = atan(affari(X),1)

%%
% In the Min-Range mode the linearization covers the true range of the
% function. In contrast, the Chebyshev linearization minimizes the maximum
% of the error at the price of a little weaker inclusion:

affariinit('ApproxChebyshev')
YChebyhev = atan(affari(X),1)

%%
% Here is another example in the non-monotone range of a function, the
% sine function. In this example we first store the approximation mode,
% calculate the Min-Range approximation, and then restore the original
% approximation mode (messages are suppressed):

X = infsup(-1.5,1.3);
approxmode = affariinit('ApproxMode',0);
affariinit('ApproxMinRange');
YMinRange = sin(affari(X),1)
affariinit(approxmode);

%%
% The best to be done by the Min-Range approximation is equivalent to
% ordinary interval arithmetic. In contrast, Chebyshev linearization still
% adheres to the shape of the function:

YChebyhev = sin(affari(X),1)

%% Is Chebyshev always better than Min-Range?
% Note that the final inclusion is the same for both modes in both examples. 
% This is always true for a single operation or a single function. It is due to
% a special technique used by INTLAB, see the "The extra component .range" 
% below.
%
% The pictures suggest that the Chebyshev mode is always preferable when
% performing several operations. This is often true, however, there are
% also examples it the other way around:

format infsup
f = inline('sin(x-sqr(x))')
x = affari(infsup(0.5,0.6)); 
affariinit('ApproxMinRange');
yminrange = f(x)
affariinit('ApproxChebyshev');
ychebyshev = f(x)

%% Error terms
% Only thick interval quantities converted into affari quantities create 
% new and individual error terms for each component. Moreover,
% operations on affari variables create new error terms as well. The number
% of current error terms is visible by "affarivars":

n1 = affarivars
N = 10;
a = affari(midrad(randn(N),rand(N)));
n2 = affarivars

%%
% Note that for double quantities converted into affari no error terms are
% needed:

n3 = affarivars
N = 10;
a = affari(randn(N));
n4 = affarivars

%%
% The affari toolbox in INTLAB stores the error terms in sparse mode, so
% the total number of error terms has some, but not too strong effect on the
% performance. 

%% Resetting error terms
% The number of error terms can be resetted by

affariinit
affarivars

%%
% However, this should be handled very carefully! After reset by
% affariinit,
% previously defined affari variables cannot be used any longer without 
% jeopardizing the rigor of computed results. This is because, after 
% resetting, new variables may carry new error terms which already used by 
% other variables. The same applies to save and load of affari variables.
% Unfortunately, I cannot control such a misuse, it is the user's
% responsibility. 

%% Using affine arithmetic
% When using affine arithmetic, some care is necessary. We just mentioned 
% that it is hazardous to reset the number of error terms and to continue 
% to use existing variables.
%
% Unexpected though not wrong results are possible when using
% affine variables not appropriately. A well-known property of affine
% arithmetic is the possibility of cancellation:

X = infsup(2,3)
intDiff = X - X
A = affari(X)
affariDiff = A - A

%%
% However, one might try the following:

X = infsup(2,3)
WrongDiff = affari(X) - affari(X)

%%
% As can be seen the result is the same as of ordinary interval arithmetic.
% The reason is that the two calls "affari(X)" create individual, i.e.
% independent variables. They do not share error terms, and the idea of
% affine arithmetic is spoiled.

%% The internal structure
% The default display is to see the interval represented by the affari
% quantity: 

X = midrad(randn(2,3),rand(2,3));
A = affari(X);
format intval
A

%%
% The internal structure of affine variables can be inspected as follows:

format errorterms
A

%% The extra component .range
% Affari variables in INTLAB carry another structure component, the range.
% This proved to be important to reduce the range of the final result in
% several ways:
%
% A freshly defined affari interval carries exactly one nonzero error term,
% namely its radius:

n1 = affarivars
A = affari(infsup(1,3))
n2 = affarivars

%%
% Thus A*A in affari arithmetic is the same as the multiplication using
% midpoint-radius form. In the example the result is
%
%  A = [1,3] = <2,1>    and therefore
%
%  A*A = <2,1> * <2,1> = <4,2+2+1> = <4,5> = [-1,9] .

%%
% This effect of overestimation is well-known. It follows that, without
% proper action, the result of affari arithmetic is worse that ordinary
% interval arithmetic. 
%
% If in the example the reciprocal of A*A is taken, this leads toan
% unnecessary division by zero. In contrast, ordinary interval multiplication yields A*A =
% [1,9] with no problems taking the reciprocal.

%%
% The remedy in INTLAB's affari toolbox is to take the intersection of the
% affari range and the range obtained by ordinary interval arithmetic. With
% this method the affari result is never worse than ordinary interval
% arithmetic.

A2 = A*A

%%
% Note that the error terms sum up to 5, as for midpoint-radius arithmetic,
% so without the range-trick the result would be [-1,9].
% Now the reciprocal is safely computed as well:

R = intval(1/A2)

%% Rounding errors
% Enevitably, floating-point operations are afflicted with rounding errors.
% To produce rigorous results, interval bounds are rounded outwards.
%
% The affari toolbox solves this problem by carrying, besides the midpoint
% and range, an extra component for the rounding error. Independently, 
% M. Kashiwagi from Waseda University had the same idea. The user does not
% have to care about that. However, Kashiwagi gave the important advice to
% allow the possibility to put not only quadratic terms but also rounding 
% errors in extra error terms. This is controlled as follows:

affariinit('RoundingErrorsToRnderr')
n1 = affarivars
B1 = A*A
n2 = affarivars
affariinit('RoundingErrorsToErrorTerm')
B2 = A*A
n3 = affarivars

%%
% As can be seen the rounding errors in the second example are zero, they
% are put into an extra error term. This method proves useful as by the
% following striking example. 

%% Example 1: The Henon map
% The Henon map is described by the discrete dynamical system
%
%  x_i+1 = 1 - a*x_i^2 + y_i
%  y_i+1 = b*x_i
%
% It is known that this map is nearly chaotic for b=0.3 and a=1.05, the map
% is chaotic for b=0.3 and a>=1.06. 
% 
% We first try ordinary interval arithmetic for a=1.05, a non-chaotic mapping. 
% The initial state is x0 = y0 = midrad(0,1e-5).

format _
tic
a = 1.05; b = 0.3;
X = midrad(0,1e-5)*ones(2,1);
for k=1:50
  X = [ 1-a*X(1)^2+X(2) ; b*X(1) ];
  if mod(k,10)==0
    X
  end
end
Tintval = toc
  
%%
% As expected, data dependencies cause an exponential growth of the radius.
% Now the result using INTLAB's affari variables:

format intval
tic
a = 1.05; b = 0.3;
X = affari(midrad(0,1e-5)*ones(2,1));
for k=1:50
  X = [ 1-a*X(1)^2+X(2) ; b*X(1) ];
  if mod(k,10)==0
    X
  end
end
Taffari = toc

%%
% Affine arithmetic needs considerably more computing time, however, the
% result is achieved without any specific analysis whatsoever. 
%
% Next we approach the chaotic Henon map. We also make sure to use the 
% true specified parameters a and b by initializing them as enclosing intervals.
%
% We perform 500 iterations and display the radii of every 100th iterate.
% Notice that the initial values are afflicted with an error 1e-5.

format long
affariinit
affariinit('RoundingErrorsToErrorTerm')
a = intval('1.057'); b = intval('0.3');
X = affari(midrad(0,1e-5)*ones(2,1));
K = 500;
y = zeros(1,K);
for k=1:K
  X = [ 1-a*X(1)^2+X(2) ; b*X(1) ];
  y(k) = max(rad(X));
end
n1 = affarivars
close, semilogy(1:K,y), title('maximum radii of 500 Henon iterates with a=1.057 and b=0.3')
X

%% Example 2: Systems of linear equations
% Usually affine arithmetic shows its power when evaluating nonlinear
% functions. Nevertheless we test it on solving systems of linear
% equations. The following matrix is randomly generated with relative
% errors 1e-8 in each component and random right hand side. Note that the
% matrix is well-conditioned.
%

n = 20;
A = randn(n).*midrad(1,1e-8);
b = randn(n,1);

%%
% The routine  solvewpp  is a general routine solving linear systems by
% Gaussian elimination with partial pivoting, and subsequent forward and
% backward substitution. When called with interval matrix, the operations
% are performed in ordinary interval arithmetic; called with affine matrix,
% affine arithmetic is used. 

affariinit
affariinit('RoundingErrorsToRnderr')
tic
Xint = solvewpp(A,b);
Tint = toc
tic
Xaff = solvewpp(affari(A),b);
Taff = toc
n1 = affarivars

v = [1:2 n-1:n];
Xintv = Xint(v)
Xaffv = Xaff(v)
med = median(rad(Xint)./rad(Xaff))

%%
% As can be seen the radius of the result is improved by about 5 orders of
% magnitude using the affari package. However, in particular due to
% interpretation overhead, this approach is much slower. 
%
% Also note that we did not use extra error terms for rounding errors which
% is important for the Henon iteration. In case of linear systems
% there is almost no difference - except increasing the number of error
% terms:

affariinit
affariinit('RoundingErrorsToErrorTerm')
Xint = solvewpp(A,b);
Xaff = solvewpp(affari(A),b);
n2 = affarivars

v = [1:2 n-1:n];
Xintv = Xint(v)
Xaffv = Xaff(v)
med = median(rad(Xint)./rad(Xaff))

%%
% In this example no nonlinear functions are involved, thus it makes no
% difference to use Min-Range or Chebyshev approximation. 

%% Example 3: Excluding boxes in global optimization
% Global optimization problems lead to finding all zeros of a system of
% nonlinear equations (the Jacobi-matrix) in a given box. It is known that
% the hard problem is to exclude boxes: Indeed for conventional numerical
% algorithms this is almost impossible - at least rigorously.
%
% However, ordinary interval computations suffer from overestimations and the
% wrapping effect. Sometimes affine arithmetic can improve the situation.
% In the following we do a brute-force binary search by dividing an
% initial box into K parts in each dimension, thus producing K^n subboxes 
% for dimension n. Then we count how many subboxes can be excluded, that 
% means, at least one component of the function value does not include zero. 
%
% We consider Branin's test function, a well-known example in global
% optimization. 

% Branin test function
f = @(x)((x(2) - x(1)^2*5.1/(4*pi^2) + 5*x(1)/pi - 6)^2 + 10*(1-1/(8*pi))*cos(x(1)) + 10);
X = infsup(-10,10)*ones(2,1);   % initial box as given in the literature
K = 16;                         % 16^2 = 256 subboxes
s = 0;                          % subboxes excluded by interval arithmetic
t = 0;                          % subboxes excluded by affine arithmetic
for i=1:K
  for j=1:K
    XX = gradientinit([ 
      infsup( X(1).inf+(i-1)*diam(X(1))/K , X(1).inf+i*diam(X(1))/K ) ; ...
      infsup( X(2).inf+(j-1)*diam(X(2))/K , X(2).inf+j*diam(X(2))/K ) ]); 
    y = f(XX);
    Y = f(affari(XX));
    s = s + any(~in(0,y.dx(:)));
    t = t + any(~in(0,Y.dx(:)));  
  end
end
disp(' ')
disp(['Ordinary interval arithmetic could exclude ' int2str(s) ' out of ' ...
  int2str(K^2) ' subboxes.'])
disp(' ')
disp(['Affari arithmetic could exclude ' int2str(t) ' out of ' ...
  int2str(K^2) ' subboxes.'])

%%
% In such a case a strategy may be to use ordinary interval arithmetic
% first, and to use affine arithmetic for the cases which are not decided.

%% Example 4: Verification of a local minimum
% It is known that near [9;2] there is a local minimum of Branin's
% function. This can be verified as usual:

X = verifylocalmin(f,[9;2])    % inclusion of a local minimum

%%
% It has been verified that for every x in X the Hessian of f is symmetric
% positive definite, in particular for the stationary point included by X.
% It follows that indeed there is a local minimum of Branin's function in X. 
%
% The applicability of that approach can be tested by intentionally
% widening the box X. Then it is seen that for wider radii the Hessian
% computed by affine arithmetic can be verified to be s.p.d.

format short
for r=1.05:0.05:1.25
  XX = X+midrad(0,r);
  Y = f(hessianinit(XX)); IntLocalMin = isspd(Y.hx);
  Y = f(affari(hessianinit(XX))); AffLocalMin = isspd(Y.hx);
  Res = [ r IntLocalMin AffLocalMin ]
end

%% Enjoy INTLAB
% INTLAB was designed and written by S.M. Rump, head of the Institute for Reliable Computing,
% Hamburg University of Technology. Suggestions are always welcome to rump (at) tuhh.de
