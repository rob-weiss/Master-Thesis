%INTLAB interval Taylor toolbox
%
%Taylor constructors
%  taylorinit   - Initialization of dependent variables
%  horzcat      - Horizontal concatenation          [ , ]
%  vertcat      - Vertical concatenation            [ ; ]
%  subsasgn     - Subscripted assignment A(i,:) = 1
%  subsref      - Subscripted reference r = A(3,4)
%  taylor       - Double to Taylor
%
%Display of Taylors and interval Taylors (rigorous)
%  display      - Command window display of Taylor
%  disp         - Display function for pop-up windows in debugger
%  realimag     - Real and Imaginary part separately
%  infsup       - Display infimum and supremum
%  midrad       - Display midpoint and radius
%  disp_        - Display in "_" notation
%
%Taylor arithmetic operations
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
%
%Other Taylor operations
%  abs          - Absolute value
%  inf          - Infimum
%  sup          - Supremum
%  mid          - Midpoint
%  rad          - Radius
%  diam         - Diameter
%  real         - Real part
%  imag         - Imaginary part
%  trace        - Trace
%  sum          - Sum
%  prod         - Product
%  ctranspose   - Complex conjugate transpose       '
%  transpose    - Transpose                         .'
%  qdist        - Metric distance
%
%Utility routines
%  isnan        - True for Not a Number
%  isreal       - Taylor is real
%  isintval     - Taylor is intval
%  isaffari     - Taylor is affari
%  isfinite     - Interval is finite
%  isinf        - Interval is infinite
%  isempty      - Taylor is empty in Matlab sense, i.e. []
%  issparse     - Taylor has sparse structure
%  find         - find indices of nonzero elements
%  all          - Determine if all array elements are nonzero
%  any          - Determine if any array elements are nonzero
%  logical      - Convert Taylor values to logical
%  nnz          - Number of nonzero elements
%  numel        - Number of elements in array (default 1)
%  numels       - Number of elements in array
%  end          - determine last index
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
%  repmat       - Duplicate arrays
%  full         - Convert to full Taylor 
%  sparse       - Convert to sparse Taylor 
%
%Taylor trigonometric functions (rigorous, real and complex)
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
%  erf          - Error function
%  erfc         - Complementary error function
%
%Taylor exponential functions (rigorous, real and complex)
%  exp          - Exponential
%  log          - Natural logarithm
%  log10        - Logarithm to base 10
%  sqr          - Square
%  sqrt         - Square root
%
%Taylor comparison of ".x" part
%  eq           - Equal                             ==
%  ne           - Not equal                         ~=
%  gt           - Greater than                      >
%  ge           - Greater than or equal             >=
%  lt           - Less than                         <
%  le           - Less than or equal                <=
%
%Verification routines and auxiliary
%  typeadj      - Type adjustment
%  typeof       - Type for type adjustment
%
%Initialization of INTLAB Taylor package and system variables
%  taylorinit   - Initialization and definition of INTLAB switches, also
%                   initialization of dependent variables
%  taylororder  - Order of Taylor evaluation
%
%Demonstration, samples
%  demotaylor   - Some examples for using INTLAB Taylor package
%  testfuntaylor -  A test function for the Taylor toolbox
%
%
%The Taylor package uses forward mode of automatic differentiation. For
%an introduction, see
%  L.B. Rall: Automatic Differentiation: Techniques and Applications,
%    Lecture Notes in Computer Science 120, Springer, 1981.
%Many thanks to George Corliss for many helpful advices.
%

% written  05/25/09     S.M. Rump
% modified 04/04/14     S.M. Rump  affari added
%
% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
