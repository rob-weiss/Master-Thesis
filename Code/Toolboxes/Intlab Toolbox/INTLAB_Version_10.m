%Help file for INTLAB Version 10
%
% A substantial rewriting was necessary due to changed in new Matlab releases:
% - totally 509 routines had to be changed for correct rounding
%
% The most important new routines are of global nature:
%
%  verifynlssall       - All roots of f:R^n->R^n in a box
%  verifyglobalmin     - The global minimum of f:R^n->R^n in a box
%  verifyconstraintglobalmin - The global minumum of f:R^n->R^n in a box s.t. g(x)=0
%  verifynlssderivall  - All zeros of the gradient of a function f:R^n->R within the box
%  verifynlssparam     - Nonlinear system parameter estimation
%
% Moreover, there are other, in total 72 new routines. Among them:
%
% - psi  for intval, gradient, hessian
% - gamma, gammaln for gradients and hessians
% - permute, squeeze
% - erf, erfc for taylor 
% - isequalwithequalnans
%
% - Improvement of verifylss for general sparse matrices
%
% - The display was not working any more for 2016b and following + Matlab bug fix
%
% Redesign of the verification routines, now all beginning with "verify":
%
%Verification routines for linear systems
%  verifylss    - Verified linear system solver including
%                    rectangular and sparse systems
%  verifystructlss - Verified solution of structured linear systems
%  structure    - Specification of user-defined structured matrices
%
%Verification routines for eigenproblems
%  verifyeig    - Verified eigenvalue inclusion (simple and clusters)
%                    together with basis of invariant subspaces,
%                    ordinary and generalized eigenvalue problem
%  verifystructeig - Verified eigenvalue/vector inclusion (simple and clusters)
%                    for structured input matrix
%
%Verification routines for nonlinear systems (local nature)
%  verifynlss          - Verified nonlinear system solver
%  verifynlss2         - Verified nonlinear system solver for double roots
%  verifynlssderiv     - Verified solution of k-th derivative f^(k)=0
%  verifynlssnonsquare - Verified solution of over- or underdeterminted 
%                           nonlinear system
%
%Verification routines for nonlinear systems (global nature)
%  verifynlssall       - All roots of f:R^n->R^n in a box
%  verifynlssallset    - Set parameters for verifynlssall
%  verifynlssderivall  - Global nonlinear system solver for derivative
%  verifynlssparam     - Nonlinear system parameter estimation
%  verifynlssparamset  - Set parameters for verifynlssparam
%
%Verification for optimization problems (local nature)
%  verifylocalmin             - Verified local minimum of f:R^n->R
%  verifyconstraintlocalmin   - Verified local minimum of f:R^n->R s.t. 
%                                  g(x)=0 for g:R^m->R
%
%Verification for optimization problems (global nature)
%  verifyglobalmin           - All global minima of f:R^n->R in a box
%  verifyconstraintglobalmin - All global minima of f:R^n->R in a box 
%                                  s.t. g(x)=0 for g:R^m->R
%  verifyoptimset            - Set parameters for verifyglobalmin and 
%                                  verifyconstraintglobalmin
%
%Verified quadrature and fast Fourier transformation
%  verifyquad   - Verified quadrature
%  verifyfft    - Verified forward and backward 1-dimensional FFT
%
%
% Moreover, some auxiliary verification routines
%  cond         - p-norm condition number
%  inv          - Verified inverse of an interval square matrix
%
% 
% - inv replaced
% - ignore input out of range removed: too dangerous
% - various corrections and improvements, in particular taking care of Matlab and Octave bugs
%
% All demo routines renewed, check "demo toolbox INTLAB"
%
% New demo function: 
%  dglobal         various routines of global nature
%

