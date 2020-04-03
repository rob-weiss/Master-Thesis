function format(varargin)
% shadows builtin  format  function for easy chaning of INTLAB formats
%
%  FORMAT Set output format.
%     FORMAT with no inputs sets the output format to the default appropriate
%     for the class of the variable. For float variables, the default is
%     FORMAT SHORT.
%  
%     FORMAT does not affect how MATLAB computations are done. Computations
%     on float variables, namely single or double, are done in appropriate
%     floating point precision, no matter how those variables are displayed. 
%     Computations on integer variables are done natively in integer. Integer
%     variables are always displayed to the appropriate number of digits for
%     the class, for example, 3 digits to display the INT8 range -128:127.
%     FORMAT SHORT and LONG do not affect the display of integer variables.
%  
%     FORMAT may be used to switch between different output display formats
%     of all float variables as follows:
%       FORMAT SHORT     Scaled fixed point format with 5 digits.
%       FORMAT LONG      Scaled fixed point format with 15 digits for double
%                        and 7 digits for single.
%       FORMAT SHORT E   Floating point format with 5 digits.
%       FORMAT LONG E    Floating point format with 15 digits for double and
%                        7 digits for single.
%       FORMAT SHORT G   Best of fixed or floating point format with 5 
%                        digits.
%       FORMAT LONG G    Best of fixed or floating point format with 15 
%                        digits for double and 7 digits for single.
%       FORMAT SHORT ENG Engineering format that has at least 5 digits
%                        and a power that is a multiple of three
%       FORMAT LONG ENG  Engineering format that has exactly 16 significant
%                        digits and a power that is a multiple of three.
%  
%     FORMAT may be used to switch between different output display formats
%     of all numeric variables as follows:
%       FORMAT HEX     Hexadecimal format.
%       FORMAT +       The symbols +, - and blank are printed 
%                      for positive, negative and zero elements.
%                      Imaginary parts are ignored.
%       FORMAT BANK    Fixed format for dollars and cents.
%       FORMAT RAT     Approximation by ratio of small integers.  Numbers
%                      with a large numerator or large denominator are
%                      replaced by *.
%  
%     FORMAT may be used to affect the spacing in the display of all
%     variables as follows:
%       FORMAT COMPACT Suppresses extra line-feeds.
%       FORMAT LOOSE   Puts the extra line-feeds back in.
%  
%     Example:
%        format short, pi, single(pi)
%     displays both double and single pi with 5 digits as 3.1416 while
%        format long, pi, single(pi)
%     displays pi as 3.141592653589793 and single(pi) as 3.1415927.
%  
%        format, intmax('uint64'), realmax
%     shows these values as 18446744073709551615 and 1.7977e+308 while
%        format hex, intmax('uint64'), realmax
%     shows them as ffffffffffffffff and 7fefffffffffffff respectively.
%     The HEX display corresponds to the internal representation of the value
%     and is not the same as the hexadecimal notation in the C programming
%     language.
%  
%     See also disp, display, isnumeric, isfloat, isinteger.
% 
%     Reference page in Help browser
%        doc format
% 
%Overloaded function "Intlab\utility\format.m" for changing INTLAB variables format:
%
%FORMAT       Change of interval output format
%
%Use "infsup", "midrad", "_" together with Matlab formats freely. E.g.
%
%  format short infsup
%  format midrad long e
%  format long _
%  format bank __
%
%For the different options see 
%  help intvalinit
%
%  format intval
%  format errorterms
%
%For the different options see
%  help affariinit
%
%  format upolyvector
%  format upolysparse
%
%For the different options see
%  help polynominit
%

% written  05/09/09     S.M. Rump
% modified 03/16/10     S.M. Rump  format __ added
% modified 04/04/14     S.M. Rump  other options added
% modified 05/16/14     S.M. Rump  format adapted for Octave
% modified 05/18/14     S.M. Rump  code optimization
% modified 09/23/15     S.M. Rump  avoid get(0,... and set(0,... in Octave
% modified 02/02/17     S.M. Rump  isempty INTLAB_CONST
% modified 02/22/17     S.M. Rump  Octave format e
%

  global INTLAB_CONST
  if ~isempty(INTLAB_CONST)
    if INTLAB_CONST.OCTAVE
      if strmatch('short',lower(varargin))
        if strmatch('e',lower(varargin))
          builtin('format','short','e');
        else
          builtin('format','short');
        end
      elseif strmatch('long',lower(varargin))
        if strmatch('e',lower(varargin))
          builtin('format','long','e');
        else
          builtin('format','long');
        end
      end
    end
  end

  for i=1:10
    switch i
      case  1, str = 'infsup';
      case  2, str = 'midrad';
      case  3, str = '_';
      case  4, str = '__';
      case  5, str = 'intval';
      case  6, str = 'errorterms';
      case  7, str = 'upolyvector';
      case  8, str = 'upolysparse';
      case  9, str = 'compact';
      case 10, str = 'loose';
    end
    j = strmatch(str,lower(varargin));
    if ~isempty(j)
      if i>=9
        builtin('format',str);
      elseif i<=4
        intvalinit(['display' str],0);
      elseif ismember(i,5:6)
        affariinit(['display' str]);
      elseif ismember(i,7:8)
        polynominit(['display' str],0);
      end
      varargin = varargin([1:j-1 j+1:length(varargin)]);        
    end
  end
  try
    if ~isempty(varargin)
      builtin('format',varargin{:});
    end
  catch
    disp('INTLAB options for format: ')
    disp(' ')
    disp('Intervals:')
    disp('  _             Display with uncertainty (e.g. 3.14_) but change to inf/sup for real')
    disp('                  or to mid/rad for complex input if intervals too wide ')
    disp('  __            Display with uncertainty (e.g. 3.14_) independent of width of input')
    disp('  infsup        Display infimum/supremum (e.g. [ 3.14 , 3.15 ])')
    disp('  midrad        Display midpoint/radius (e.g. < 3.14 , 0.01 >)   ') 
    disp(' ')
    disp('Affari')
    disp('  intval        Default display is as an interval')
    disp('  errorterms    Default display is midpoint and error terms')
    disp(' ')
    disp('Polynomials:')
    disp('  upolyvector   Display univariate polynomials as vector, e.g.')
    disp('                     polynom p[x]  =')
    disp('                                  1     0    -2')
    disp('  upolysparse   Sparse display of univariate polynomials, e.g.')
    disp('                     polynom p[x] =')
    disp('                         2.0000 x^2')
    disp('                        -1.0000')
    builtin('format',varargin{:});                                   
  end