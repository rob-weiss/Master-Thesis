%Reference implementations for accurate summation and dot product algorithms
%
%Generation of extremely ill-conditioned sums and dot products
%  GenSum       - Generation of extremely ill-conditioned sums
%  GenDot       - Generation of extremely ill-conditioned dot products
%
%New summation, dot product and related routines: high accuracy
%  FastAccSum    - Faithful rounding of sum(p_i)
%  AccSum        - Faithful rounding of sum(p_i)
%  AccSumHugeN   - Faithful rounding of sum(p_i) for large dimension
%  AccSumK       - K-fold faithful rounding of sum(p_i)
%  AccDot        - Accurate dot product with faithful, to nearest or K-fold rounding
%  AccSign       - Sign of sum(p_i)
%  PrecSum       - Accurate and fast up to large condition number
%  FastPrecSum   - Accurate and fast up to large condition number
%  NearSum       - Sum(p_i) rounded to nearest
%  DownSum       - Sum(p_i) rounded downwards
%  UpSum         - Sum(p_i) rounded upwards
%
%
%New summation, dot product and related routines: high precision
%  Sum2          - Summation with quad precision
%  SumK          - Summation with K-fold precision
%  SumKL         - Dot product computed in K-fold precision, result stored in L parts
%  Sum_          - Summation in K-fold precision
%  Dot2          - Dot product with quad precision
%  Dot2Err       - Dot2 with rigorous error bounds without directed rounding
%  DotK          - Dot product with K-fold precision
%  ProdKL        - Matrix product in approximately K-fold precision stored in L results
%  Dot_          - Easy to use dot product for vectors and matrices
%
%
%Error-free transformations
%  TwoSum        - Transformation of a+b into x+y with x=fl(a+b)
%  FastTwoSum    - TwoSum provided input is ordered in absolute value
%  VecSum        - Error-free vector transformation
%  TwoProduct    - Transformation of a*b into x+y with x=fl(a*b)
%  Split         - Transformation of a into two 'halves' x+y
%  ExtractVector - Extract higher and lower part of vector
%  Transform     - Transformation of vector into high part and low order vector
%
%
%Utility routines for new summation and dot product routines
%  NextPowerTwo  - Next power of 2 of integer without branch
%  ufp           - Unit in the first place
%
%
%Reference implementations of competitors
%  SumXBLAS      - Summation as in XBLAS
%  DotXBLAS      - Dot product as in XBLAS
%  PriestSum     - Priest's doubly compensated summation
%  ZDSum         - Zielke/Drygalla summation
%
%
%Application program
%  InvIllco      - Inverse of extremely ill-conditioned matrices
%

% written  10/27/08     S.M. Rump
%

%
%New algorithms based on
%
%Accurate summation and dot product with specified precision
%  T. Ogita, S.M. Rump, and S. Oishi. Accurate Sum and Dot Product, 
%     SIAM Journal on Scientific Computing (SISC), 26(6):1955-1988, 2005.
%
%Accurate summation and dot product with specified accuracy
%  S.M. Rump, T. Ogita, S. Oishi: Accurate Floating-point Summation I: 
%    Faithful Rounding, SIAM J. Sci. Comput., 31(1):189-224, 2008.
%  S.M. Rump, T. Ogita, S. Oishi: Accurate Floating-point Summation II: 
%    Sign, K-fold Faithful and Rounding to Nearest, Siam J. Sci. Comput., 
%    31(2):1269-1302, 2008.
%
%Fast and high precision summation and dot products
%  S.M. Rump, T. Ogita, and S. Oishi. Fast high precision summation. 
%    Nonlinear Theory and Its Applications (NOLTA), IEICE, 1(1), 2010. 
%    [received the "NOLTA Best Paper Award" by the IEICE Engineering Sciences
%    Society]. 
%

%
% Copyright (c) Siegfried M. Rump, head of the Institute for Reliable Computing, 
%               Hamburg University of Technology
