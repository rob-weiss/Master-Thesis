%INTLAB some utility routines
%
%Factorization routines for many data types
%  solvewpp     - solve linear system with partial pivoting
%  luwpp        - LU-decomposition with partial pivoting
%  forward      - forward substitution for lower triangular matrix
%  backward     - backward substitution for upper triangular matrix
%
%Matrix routines
%  isspd        - Symmetric (Hermitian) is spd
%  isregular    - Proof regularity for extremely ill-conditioned matrices
%  compmat      - Ostrowski's comparison matrix
%  gregk...     - Some sparse test matrices from Gregory/Karney test set
%  circulant    - Circulant out of first row
%  boothroyd    - Boothroyd matrix - very ill-conditioned matrix with known inverse
%  gregk316     - Example (3.16) from Gregory/Karney
%  gregk416     - Example (4.16) from Gregory/Karney
%  gregk420     - Example (4.20) from Gregory/Karney
%  poisson      - Classical Poisson matrix
%  hilbert      - scaled (representable) Hilbert matrix
%
%Test functions
%  Brown        - Brown's almost linear function
%  Broyden      - Broyden's test function
%  Griewank     - Griewank's test function for global optimization
%  Griewanks    - Gradient of Griewank's test function
%  Fletcher     - Fletcher's test function
%  test_h       - Test function for optimization
%
%Random numbers and matrices
%  randint      - Random integers in specified range
%  random       - Random numbers uniformly distrubuted in [-1,1] or within specified range
%  randsym      - Random symmetric matrix
%  randherm     - Random Hermitian matrix
%  randomc      - Complex random numbers with real and imaginary part as random
%  randmat      - Random matrix with specified condition number
%  randorth     - Random orthogonal matrix
%  randsvd      - Random matrix with geometrically distributed singular values
%
%Floating-point related
%  pred         - Predecessor
%  succ         - Successor
%  subrealmin   - Smallest unnormalized positive floating-point number
%  realmin      - overloaded for fl-type
%  realmax      - overloaded for fl-type
%  gcdvec       - greatest common divisor of vector/matrix
%  lcmvec       - least common multiple of vector/matrix
%
%Other routines
%  funvec       - Vectorize function
%  format       - Change interval output format
%  getformat    - Current display format
%  clear        - Same as Matlab's clear, handles global variables
%  bin2vec      - Convert integer into vector of bits
%  base2vec     - Convert integer into vector of digits to base b
%  finish       - Ensure rounding mode is set to nearest after exiting Matlab
%  helpp        - Intelligent help
%  binom        - Binomial coefficient (vectorwise)
%  relerr       - Relative error
%  sqr          - Square
%  odd          - Logical integer odd
%  even         - Logical integer even
%  factors      - List of factors of an integer
%  distbits     - Distance in bits
%  collectList  - Collect overlapping or adjacent boxes
%  Fletcher     - Sample routine for nonlinear systems
%  Matlab_gradient - Solves some graphic problems
%

% written  11/30/98     S.M. Rump
% modified 12/15/01     S.M. Rump  Routine Fletcher added
% modified 11/23/05     S.M. Rump  band and bandwidth removed (already in /intval)
% modified 08/17/15     S.M. Rump  Routine funvec added
% modified 09/01/15     S.M. Rump  Routine collectList added
%
% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
