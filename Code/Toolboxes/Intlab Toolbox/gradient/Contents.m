%INTLAB interval gradient toolbox
%
%Gradient constructors
%  gradientinit - Initialization of dependent variables
%  horzcat      - Horizontal concatenation          [ , ]
%  vertcat      - Vertical concatenation            [ ; ]
%  subsasgn     - Subscripted assignment A(i,:) = 1
%  subsref      - Subscripted reference r = A(3,4)
%  gradient     - Double to gradient
%
%Display of gradients and interval gradients (rigorous)
%  display      - Command window display of gradient
%  disp         - Display function for pop-up windows in debugger
%  realimag     - Real and Imaginary part separately
%  infsup       - Display infimum and supremum
%  midrad       - Display midpoint and radius
%  disp_        - Display in "_" notation
%
%Gradient arithmetic operations
%  plus         - Plus                              +
%  uplus        - Unary plus                        +
%  minus        - Minus                             -
%  uminus       - Unary minus                       -
%  mtimes       - Matrix multiply                   *
%  times        - Elementwise multiply              .*
%  mrdivide     - Slash or right division           /
%  mldivide     - Backslash or left division        \
%  rdivide      - Elementwise right division        ./
%  ldivide      - Elementwise left division         .\
%  mpower       - Matrix power                      ^
%  power        - Elementwise power                 .^
%  intersect    - Intersection
%
%Other gradient operations
%  abs          - Absolute value
%  mag          - Absolute value, result double
%  mig          - Mignitude, result double
%  inf          - Infimum
%  sup          - Supremum
%  mid          - Midpoint
%  rad          - Radius
%  min          - Minimum
%  max          - Maximum
%  diam         - Diameter
%  real         - Real part
%  imag         - Imaginary part
%  trace        - Trace
%  sum          - Sum
%  prod         - Product
%  newton       - Data for Newton correction
%  ctranspose   - Complex conjugate transpose       '
%  transpose    - Transpose                         .'
%  sparsegradient - Number of unknowns from which gradients are stored sparse
%
%Utility routines
%  isnan        - True for Not a Number
%  isreal       - Gradient is real
%  isintval     - Gradient is intval
%  isaffari     - Gradient is affari
%  isfinite     - Interval is finite
%  isinf        - Interval is infinite
%  isempty      - Gradient is empty in Matlab sense, i.e. []
%  emptyintersect - detect empty intersections
%  issparse     - Gradient has sparse structure
%  find         - find indices of nonzero elements
%  all          - Determine if all array elements are nonzero
%  any          - Determine if any array elements are nonzero
%  logical      - Convert gradient values to logical
%  nnz          - number of nonzero elements
%  numel        - Number of elements in array (default 1)
%  numels       - Number of elements in array
%  end          - determine last index
%  qdist        - Metric distance
%
%Structural operations
%  band         - Extract band
%  diag         - Extract diagonal
%  tril         - Extract lower triangular
%  triu         - Extract upper triangular
%  bandwidth    - Bandwidth
%  length       - Length
%  size         - Size
%  dim          - Dimension of square matrix
%  reshape      - Reshape
%  permute      - Rearrange dimensions of N-D gradient array
%  repmat       - Duplicate arrays
%  full         - Convert to full gradient 
%  sparse       - Convert to sparse gradient 
%
%Gradient trigonometric functions (rigorous, real and complex)
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
%Gradient exponential functions (rigorous, real and complex)
%  exp          - Exponential
%  log          - Natural logarithm
%  log2         - Logarithm to base 2
%  log10        - Logarithm to base 10
%  sqr          - Square
%  sqrt         - Square root
%
%Interval higher transcendental functions (rigorous, real)
%  gamma        - Gamma function
%  gammaln      - Logarithmic Gamma function
%  psi          - Psi function
%  erf          - Error function
%  erfc         - Complementary error function
%
%Gradient comparison of ".x" part
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
%Initialization of INTLAB gradient package and system variables
%  gradientinit - Initialization and definition of INTLAB switches, also
%                   initialization of dependent variables
%
%Demonstration, samples
%  demogradient - Some examples for using INTLAB gradient package
%
%
%The gradient package uses forward mode of automatic differentiation. For
%an introduction, see
%  L.B. Rall: Automatic Differentiation: Techniques and Applications,
%    Lecture Notes in Computer Science 120, Springer, 1981.
%

% written  11/30/98     S.M. Rump
% modified 04/04/14     S.M. Rump  affari added
%
% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
