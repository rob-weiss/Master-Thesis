function demointlab
%DEMOINTLAB   Wrapper routine to call INTLAB demos
%
%A selection of INTLAB demos, call
%
%  demointlab
%

% written  10/13/12     S.M. Rump  
% modified 11/07/12     S.M. Rump  INTLAB_larger added
% modified 04/04/14     S.M. Rump  end function
% modified 05/13/14     S.M. Rump  new demos
% modified 01/21/15     S.M. Rump  error if no web available
%

  if ~exist('web','file')
    error(['Command "web" not supported. ', ...
           'To see INTLAB demo-files please display the corresponding ' ...
           'html-files in directory demos/html directly by some browser.     '])
  end    

  d = which('demointlab');
  wng = warning;
  warning off
  addpath([ d(1:end-13) '\html' ])
  warning(wng)
  
  clc
  disp('Welcome to INTLAB, the Matlab toolbox for reliable computing.')
  disp(' ')
  disp('The current version consists of more than 1200 .m-functions with more ')
  disp('  than 46 thousand lines of Matlab-code (more than 80 KLOC with comments). ')
  disp('The test suite for INTLAB consists of another 82 KLOC. ')
  disp(' ')
  while 1
    displaycomments
    str = input('select demo ','s');
    switch lower(str)
      case '1', web('dintlab.html');
      case '2', web('dintlab_larger.html');
      case '3', web('dintval.html');
      case '4', web('darithmetic.html');
      case '5', web('daccsumdot.html');
      case '6', web('daffari.html');
      case '7', web('dglobal.html');
      case '8', web('dfl.html');
      case '9', web('dutility.html');
      case 'a', web('dstdfcts.html');
      case 'b', web('dgradient.html');
      case 'c', web('dhessian.html');
      case 'd', web('dtaylor.html');
      case 'e', web('dslope.html');
      case 'f', web('dpolynom.html');
      case 'g', web('dlong.html');
      case '0', break;
    end
  end
  
  disp(' ')
  disp('Enjoy INTLAB. Comments and suggestions always welcome to rump (at) tuhh.de .')
  disp(' ')
  
end  % function demointlab

  
  
function displaycomments
  disp(' ')
  disp('This is a wrapper routine to call several INTLAB demos, selected by numbers. ')
  disp(' ')
  disp('1  A general demo of some features of INTLAB')
  disp('2  Some larger examples with INTLAB')
  disp('3  Some examples of interval computations')
  disp('4  Details about interval arithmetic')
  disp('5  Accurate summation and dot products')
  disp('6  Affine interval arithmetic')
  disp('7  All roots of nonlinear functions and global optimization')
  disp('8  fl-numbers: k-bit point and interval arithmetic')
  disp('9  Utility routines')
  disp('a  Accurate standard functions')
  disp('b  The gradient toolbox (gradients of multivariate functions)')
  disp('c  The Hessian toolbox (Hessians of multivariate functions)')
  disp('d  The Taylor toolbox (taylor expansion of univariate functions)')
  disp('e  The slope toolbox (slope of multivariate functions')
  disp('f  The polynomial toolbox (univariate and multivariate polynomials')
  disp('g  The long number toolbox (a rudemantary implementation, originally for internal use)')
  disp(' ')
  disp('0  exit this wrapper')
  disp(' ')
end  % function displaycomments
