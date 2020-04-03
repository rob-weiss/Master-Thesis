%INTLAB affine arithmetic (affari) toolbox
%
%Affari constructors
%  affari       - Affari constructor
%  intval       - Conversion affine arithmetic to interval
%  spones       - Sparse affari of ones
%  horzcat      - Horizontal concatenation          [ , ]
%  vertcat      - Vertical concatenation            [ ; ]
%  subsasgn     - Subscripted assignment A(i,:) = 1
%  subsref      - Subscripted reference r = A(3,4)
%
%Display of affaris (rigorous)
%  display      - Command window display of affari (default)
%  disp         - Display function for pop-up windows in debugger
%  disp_        - Display with uncertainty
%  infsup       - Display infimum and supremum
%  midrad       - Display midpoint and radius
%  gradient     - Gradient to affari
%  hessian      - Hessian to affari
%  plotaffari   - Visualization of 2D or 3D affari vector
%
%Affari arithmetic operations
%  plus         - Plus                              +
%  uplus        - Unary plus                        +
%  minus        - Minus                             -
%  uminus       - Unary minus                       -
%  mtimes       - Matrix multiply                   *
%  times        - Elementwise multiply              .*
%  ldivide      - Elementwise left division         .\
%  mldivide     - Slash or left division            \
%  mrdivide     - Slash or right division           /
%  rdivide      - Elementwise right division        ./
%  mpower       - Matrix power                      ^
%  power        - Elementwise power                 .^
%  intersect    - Intersection
%  hull         - Hull or convex union
%
%Other affari operations
%  ctranspose   - Complex conjugate transpose       '
%  transpose    - Transpose                         .'
%  abs          - Absolute value, result affari
%  mag          - Absolute value, result double
%  mig          - Mignitude, result double
%  inf          - Infimum
%  sup          - Supremum
%  min          - Minimum
%  max          - Maximum
%  mid          - Midpoint
%  rad          - Radius
%  diam         - Diameter
%  trace        - Trace
%  sum          - Sum
%  prod         - Product
%  norm         - Norm
%  qdist        - Metric distance
%  relerr       - Relative error of affaris
%
%Utility routines
%  isnan        - True for Not a Number
%  isreal       - Affari is real
%  isaffari     - For completeness
%  isintval     - For completeness
%  isfinite     - Affari is finite
%  isinf        - Affari is infinite
%  isempty      - Affari is empty in Matlab sense, i.e. []
%  emptyintersect  - Check for empty intersection
%  iszero       - Affari is zero (componentwise)
%  issparse     - Affari has sparse structure
%  spy          - Spy sparse affari matrix  find         
%  find         - Find indices of nonzero elements
%  all          - Determine if all array elements are nonzero
%  any          - Determine if any array elements are nonzero
%  logical      - Convert affari values to logical
%  nnz          - Number of nonzero elements
%  nonzeros     - Vector of nonzero elements
%  numel        - Number of elements in array (default 1)
%  numels       - Number of elements in array
%  end          - Determine last index
%
%Structural operations and routines
%  band         - Extract band
%  diag         - Diagonal
%  tril         - Extract lower triangular
%  triu         - Extract upper triangular
%  bandwidth    - Bandwidth
%  length       - Length
%  size         - Size
%  dim          - Dimension of square matrix
%  reshape      - Reshape
%  repmat       - Duplicate arrays
%  sparse       - Type cast to sparse affari matrix
%  full         - Type cast to full affari matrix
%  toeplitz     - Create affari Toeplitz matrix
%  hankel       - Create affari Hankel matrix
%  circulant    - Create affari circulant matrix
%  compmat      - Ostrowski's comparison matrix
%
%Affari trigonometric functions (rigorous)
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
%Affari exponential functions
%  exp          - Exponential
%  log          - Natural logarithm
%  log2         - Logarithm to base 2
%  log10        - Logarithm to base 10
%  sqr          - Square
%  sqrt         - Square root
%
%Interval higher transcendental functions (rigorous, real)
%  erf          - Error function
%  erfc         - Complementary error function
%
%Affari Comparison
%  eq           - Equal                             ==
%  ne           - Not equal                         ~=
%  gt           - Greater than                      >
%  ge           - Greater than or equal             >=
%  lt           - Less than                         <
%  le           - Less than or equal                <=
%  in           - Contained in
%  in0          - Contained in interior
%
%Initialization of INTLAB affari package and system variables
%  affariinit   - Initialization, definition of defaults and reset of error terms
%  affarivars   - Current number of error terms
%
%Verification routines and auxiliary
%  typeadj      - Type adjustment
%  typeof       - Type for type adjustment
%
%
%Demonstration, samples
%  demoaffari   - Some examples for using INTLAB affari package
%
%
%For introduction to affine arithmetic see, for example,
%   L.H. de Figueiredo and J. Stolfi: Self-Validated Numerical Methods and 
%      Applications, Brazilian Mathematics Colloquium monograph, IMPA, 1997
%or
%   M. Kashiwagi: About affine arithmetic, http://verifiedby.me/kv/affine (in japanese)
%
%
%INTLAB implementation of affine arithmetic is based on
%
%  S.M. Rump and Kashiwagi M. Implementation and improvements of affine arithmetic. 
%    Nonlinear Theory and Its Applications, IEICE,, 2(3):1101–1119, 2015. 
%

% written  04/04/14     S.M. Rump
%

% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
