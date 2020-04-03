function res = lssresidual(A,x,b)
%LSSRESIDUAL    Improved inclusion of residual b-A*x or I-R*A
%Typical calls are
%
%   res = lssresidual(A,x,b)
%
%Input   A     nxn real or complex point matrix (dense or sparse)
%        x     some approximation to A\b
%        b     real or complex point or interval vector or nxk matrix
%Output  res   approximation of b-A*x
%
%or, for dense A, 
%
%   res = lssresidual(R,A,intval(speye(n)))
%
%Input   R     nxn real or complex point matrix
%        A     nxn real or complex point matrix
%Output  res   approximation of I-R*A
%
%Note that the fact that if the last parameter is of type intval causes computation of an
%inclusion of the result rather than an approximation. Also note that only the last
%parameter is allowed to be of type intval, not one of the factors.
%
%This routine can be used in verifylss to improve accuracy of inclusion. Automatic use
%can be switched on and off, see intvalinit. Basically, the factors A and x are split
%into an upper and lower part and treated seperately. Fast way of splitting is taken from
%  T.J. Dekker: A floating-point technique for extending the available precision,
%    Numerische Mathematik 18:224-242, 1971.
%For timing and improvement of accuracy of inclusion see the table below.
%
%For randomly generated full matrices of dimension n and condition number 1e8, and 
%with b=a*(2*rand(n,1)-1) the following table lists the computing time t1 w/o and 
%t2 with improved residual in seconds on my Laptop, as well as the ratio t1/t2. 
%Furthermore, the median of the radius of the inclusion is given in r1 and r2 and 
%the improvement r1/r2 in radius, respectively.
%
%     n     t1     t2      t2/t1     r1       r2      inclusion of b-A*x
%--------------------------------------------------
%   500   0.0027  0.0092    3.4   2.4e-13  4.5e-17
%  2000   0.0357  0.1395    3.9   1.9e-12  3.7e-16
%  5000   0.3249  0.8501    2.6   7.4e-12  1.5e-15
%
%Similar numbers (in seconds) for a sparse matrix of dimensions 1000, 5000 and 10000 with 
%some 20 nonzero elements per row are as follows:
%
%     n     t1     t2      t2/t1     r1       r2      inclusion of b-A*x
%--------------------------------------------------
%  5000   0.0015  0.0075    4.9   2.0e-15  2.5e-19
% 20000   0.0074  0.0387    5.2   2.0e-15  2.6e-19
% 50000   0.0188  0.0978    5.2   2.0e-15  2.6e-19
%
%Similar numbers for a random nxn matrix A, an approximate inverse R and timing for I-R*A:
%
%     n     t1     t2      t2/t1     r1       r2      inclusion of I-R*A
%--------------------------------------------------
%   500   0.0207  0.0681    3.3   9.7e-15  2.1e-18
%  2000   1.0036  3.1748    3.2   2.4e-14  4.3e-18
%  5000  14.4480 42.0160    2.9   5.9e-14  1.1e-17
%

% written  04/02/02     S.M. Rump
% modified 04/04/04     S.M. Rump  set round to nearest for safety
% modified 04/06/05     S.M. Rump  rounding unchanged
% modified 11/20/05     S.M. Rump  faster check for rounding to nearest
% modified 05/30/07     S.M. Rump  typo
% modified 08/27/12     S.M. Rump  complex part
% modified 10/16/12     S.M. Rump  comment
% modified 07/14/13     S.M. Rump  improved results through Marko Lange's double scaling 
% modified 10/17/13     S.M. Rump  scaling only for dense matrices
% modified 11/28/13     S.M. Rump  take care of x identically zero
% modified 03/18/14     S.M. Rump  scaling
% modified 04/04/14     S.M. Rump  end function
% modified 05/15/14     S.M. Rump  code optimization
% modified 07/30/16     S.M. Rump  rounding check by getround for Matlab 2016b 
% modified 02/22/17     S.M. Rump  computing times
%

  rndold = getround;
  if rndold
    setround(0)
  end

  if isa(A,'intval')                  % A interval
    error('Input A must be no interval')
  end
  
  if isa(x,'intval')                  % x interval
    error('Input x must be no interval')
  end
  
  if isreal(A)                        % A real
    if isreal(x)                    % x real
      if b.complex                % b complex
        error('Input A and x is real, so complex b makes no sense')
      else                        % A,x,b real
        res.complex = 0;
        [res.inf,res.sup] = lssresid(A,x,b.inf,b.sup);    
        res.mid = [];
        res.rad = [];
      end
    else                            % A real, x complex
      if b.complex
        setround(-1)                % convert intval b to inf/sup
        binf = b.mid - b.rad;
        setround(1)
        bsup = b.mid + b.rad;
      else
        binf = b.inf;
        bsup = b.sup;
      end
      [resrealinf,resrealsup] = lssresid(A,real(x),real(binf),real(bsup));
      [resimaginf,resimagsup] = lssresid(A,imag(x),imag(binf),imag(bsup));
      res.complex = 1;
      res.inf = [];
      res.sup = [];
      setround(1)
      res.mid = complex( resrealinf + 0.5*(resrealsup-resrealinf) , resimaginf + 0.5*(resimagsup-resimaginf) );
      res.rad = mag(res.mid - complex( resrealinf , resimaginf ));
    end
  else                                % A complex, no interval
    if isreal(x)                    % x real
      if b.complex
        setround(-1)                % convert intval b to inf/sup
        binf = b.mid - b.rad;
        setround(1)
        bsup = b.mid + b.rad;
      else
        binf = b.inf;
        bsup = b.sup;
      end
      [resrealinf,resrealsup] = lssresid(real(A),x,real(binf),real(bsup));
      [resimaginf,resimagsup] = lssresid(imag(A),x,imag(binf),imag(bsup));
      res.complex = 1;
      res.inf = [];
      res.sup = [];
      setround(1)
      res.mid = complex( resrealinf + 0.5*(resrealsup-resrealinf) , resimaginf + 0.5*(resimagsup-resimaginf) );
      res.rad = mag(res.mid - complex( resrealinf , resimaginf ));
    else                            % A and x complex
      if b.complex
        setround(-1)                % convert intval b to inf/sup
        binf = b.mid - b.rad;
        setround(1)
        bsup = b.mid + b.rad;
      else
        binf = b.inf;
        bsup = b.sup;
      end
      [resrealinf,resrealsup] = lssresid([real(A) imag(A)],[real(x);-imag(x)],real(binf),real(bsup));
      [resimaginf,resimagsup] = lssresid([real(A) imag(A)],[imag(x);real(x)],imag(binf),imag(bsup));
      res.complex = 1;
      res.inf = [];
      res.sup = [];
      setround(1)
      res.mid = complex( resrealinf + 0.5*(resrealsup-resrealinf) , resimaginf + 0.5*(resimagsup-resimaginf) );
      res.rad = mag(res.mid - complex( resrealinf , resimaginf ));
    end
  end
  
  res = class(res,'intval');
  
  setround(rndold)
  
end  % function lssresidual
  

function [resinf,ressup] = lssresid(A,x,binf,bsup)
%Inclusion of the residual b-A*x, splits A and x and multiplies A*x in parts

  setround(0)
  factor = 2199023255553;                % heuristically good splitting 2^41+1
  [m k] = size(A);

  % avoid overflow and underflow problems
  nA = nonzeros(abs(A(:)));
  nx = nonzeros(abs(x(:)));
  nbinf = nonzeros(abs(binf(:)));
  nbsup = nonzeros(abs(bsup(:)));
  Mmax = sqrt(realmax)/(2*k);
  Mmin = sqrt(realmin)*2;
  if any(nA>Mmax) || any(nx>Mmax) || any(nbinf>Mmax) || any(nbsup>Mmax) || ...
       any(nA<Mmin) || any(nx<Mmin) || any(nbinf<Mmin) || any(nbsup<Mmin)
    setround(-1)
    resinf = binf + A*(-x);
    setround(1)
    ressup = bsup + A*(-x);
    return
  end
  
  % check possible underflow
  if any(nonzeros(abs(A(:)))<realmin) || any(nonzeros(abs(x(:)))<realmin) || ...
      any(abs(nonzeros(binf(:)))<realmin) || any(nonzeros(abs(bsup(:)))<realmin) 
    setround(-1)
    resinf = bbinf + AA*(-xx);
    setround(1)
    ressup = bbsup + AA*(-xx);
    return
  end
  
  C = factor*A;
  Abig = C - A;
  A1 = C - Abig;                          % small (upper) part from A
  A2 = A - A1;                            % A = A1+A2 exact splitting
  
  x = -x;
  y = factor*x;
  xbig = y - x;
  x1 = y - xbig;                          % small (upper) part from -x
  x2 = x - x1;                            % x = x1+x2 exact splitting
  
  setround(-1)
  resinf = (A1*x1+binf) + (A1*x2+A2*x);
  setround(1)
  ressup = (A1*x1+bsup) + (A1*x2+A2*x);

end  % function lssresid
