%INTLAB fl toolbox, k-bit precision floating point arithmetic 
%
%Constructors etc.
%  fl           - fl-type constructor
%  flinit       - Initialization of fl-format
%  flround      - Rounding of double precision into k-bit
%  double       - Type cast to double
%  intval       - Intval constructor
%  infsup       - Infimum/supremum to fl-format
%  midrad       - Midpoint/radius to fl-format
%  spones       - Sparse fl-type of ones
%  horzcat      - Horizontal concatenation          [ , ]
%  vertcat      - Vertical concatenation            [ ; ]
%  subsasgn     - Subscripted assignment A(i,:) = 1
%  subsref      - Subscripted reference r = A(3,4)
%  flsequence   - The sequence of all fl-numbers between bounds
%
%Display of fl-types (rigorous)
%  display      - Command window display of fl-type (use user defined default)
%  disp         - Display function for pop-up windows in debugger
%  getbits      - Nice printing of bits for double, single and fl-type
%  infsup       - Display infimum and supremum
%  midrad       - Display midpoint and radius
%
%fl-type arithmetic operations
%  plus         - Plus                              +
%  uplus        - Unary plus                        +
%  minus        - Minus                             -
%  uminus       - Unary minus                       -
%  mtimes       - Matrix multiply                   *
%  times        - Elementwise multiply              .*
%  mrdivide     - Slash or right division           /
%  rdivide      - Elementwise right division        ./
%  mpower       - Matrix power                      ^
%  power        - Elementwise power                 .^
%  intersect    - Intersection
%  hull         - Hull or convex union
%  pred         - Predecessor of fl-type
%  succ         - Successor of fl-type
%
%Other fl-type operations
%  setround     - Set rounding mode
%  getround     - Get rounding mode
%  ctranspose   - (Conjugate) transpose             '
%  transpose    - Transpose                         .'
%  abs          - fl-type absolute value, result real fl-type interval
%  abss         - Absolute value, result double (obsolete)
%  mag          - Absolute value, result double
%  mig          - Mignitude, result double
%  inf          - Infimum
%  inf_         - Infimum (for problems with inf)
%  sup          - Supremum
%  min          - Minimum
%  max          - Maximum
%  mid          - Midpoint
%  rad          - Radius
%  diam         - Diameter
%  trace        - Trace
%  sum          - Sum
%  prod         - Product
%  qdist        - Metric distance
%  relerr       - Relative error of intervals
%
%Utility routines
%  isnan        - True for Not a Number
%  isintval     - Is of type intval
%  isfinite     - fl-type is finite
%  isinf        - fl-type is infinite
%  isempty      - fl-type is empty in Matlab sense, i.e. []
%  emptyintersect  - Check for empty intersection
%  iszero       - fl-type is zero (componentwise)
%  issparse     - fl-type has sparse structure
%  spy          - Spy sparse fl-type matrix
%  find         - Find indices of nonzero elements
%  all          - Determine if all array elements are nonzero
%  any          - Determine if any array elements are nonzero
%  logical      - Convert intval values to logical
%  nnz          - Number of nonzero elements
%  nonzeros     - Vector of nonzero elements
%  numel        - Number of elements in array (default 1)
%  numels       - Number of elements in array
%  end          - Last index
%  realmax      - Largest positive normalized fl-number
%  realmin      - Smallest positive normalized fl-number
%  subrealmin   - Smallest positive denormalized fl-number
%
%Structural operations and routines
%  band         - Extract band
%  diag         - diagonal
%  tril         - Extract lower triangular
%  triu         - Extract upper triangular
%  bandwidth    - Bandwidth
%  length       - Length
%  size         - Size
%  dim          - Dimension of square matrix
%  reshape      - Reshape
%  repmat       - Duplicate arrays
%  permute      - Permute array dimensions
%  ipermute     - Inverse permute array dimensions
%  sparse       - Type cast to sparse fl-type matrix
%  full         - Type cast to full fl-type matrix
%  spdiags      - Generate sparse matrix out of diagonals
%  toeplitz     - Create fl-type Toeplitz matrix
%  hankel       - Create fl-type Hankel matrix
%  circulant    - create fl-type circulant matrix
%  compmat      - Ostrowski's comparison matrix
%
%fl-type functions
%  sqr          - Square
%  sqrt         - Square root
%
%Interval trigonometric functions  (inherited from double)
%  sin          - Sine
%  cos          - Cosine
%  tan          - Tangent
%  cot          - Cotangent
%  sec          - Secant
%  csc          - Cosecant
%  asin         - Inverse sine
%  acos         - Inverse cosine
%  atan         - Inverse tangent
%  acot         - Inverse cotangent
%  asec         - Inverse secant
%  acsc         - Inverse cosecant
%  sinh         - Hyperbolic sine
%  cosh         - Hyperbolic cosine
%  tanh         - Hyperbolic tangent
%  coth         - Hyperbolic cotangent
%  asinh        - Inverse hyperbolic sine
%  acosh        - Inverse hyperbolic cosine
%  atanh        - Inverse hyperbolic tangent
%  acoth        - Inverse hyperbolic cotangent
%
%Interval exponential functions  (inherited from double)
%  exp          - Exponential
%  log          - Natural logarithm
%  log2         - Logarithm to base 2
%  log10        - Logarithm to base 10
%
%Interval higher transcendental functions  (inherited from double)
%  gamma        - Gamma function
%  gammaln      - Logarithmic gamma function
%  erf          - Error function
%  erfc         - Complementary error function
%
%
%fl-type Comparison
%  eq           - Equal                             ==
%  ne           - Not equal                         ~=
%  gt           - Greater than                      >
%  ge           - Greater than or equal             >=
%  lt           - Less than                         <
%  le           - Less than or equal                <=
%  in           - Contained in
%  in0          - Contained in interior
%
%Verification routines and auxiliary
%  typeadj      - Type adjustment
%  typeof       - Type for type adjustment
%
%Demonstration, samples
%  demofl       - Some examples for using INTLAB fl-package
%
%
%Implementation is based on
%  S.M. Rump: IEEE754 $k$-bit arithmetic inherited by double precision, 
%       ACM TOMS, 43(3), 2017
%

% written  11/11/13     S.M. Rump
%

% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
