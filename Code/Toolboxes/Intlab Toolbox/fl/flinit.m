function [res,expBias] = flinit(prec,expBias)
%FLINIT       Initialization of the fl-package
%
%k-bit IEEE754 numbers are binary of the form
%    +/- m1 . m2 m3  ... mk  * 2^e
%with prec bits in the mantissa including the leading (implicit) 1 and
%integer exponent e with -expBias+1 <= e <= expBias. For denormalized 
%numbers the leading bit m1 is zero.
%
%   flinit(prec,expBias)
%
%For IEEE754 binary32/64 (single/double precision)
%
%              single     double
%  -------------------------------
%    prec        24         53
%    expBias    127       1023
%
%Correspondingly, the call
%
%  flinit(prec,expBias)
%
%initializes the fl-toolbox according to IEEE754 arithmetic where
%  1 <= prec <= 26   and   1 <= expBias <= 484
%Moreover,
%  [prec,expBias] = flinit
%retrieves the current setting in the variables prec and expBias, and
%  flinit
%prints a text with the current setting.
%
%A warning is given if the currently specified precision and/or exponent
%range is smaller than in a previous initialization. The warning is
%suppressed if the output is suppressed.
%
%flinit controls the display mode of fl-quantities as follows:
%
%flinit('DisplayBits')      Default display is by bit representation (default)
%flinit('DisplayDouble')    Default display is as double number
%flinit('Display')          Retrieves the current display mode
%
%Moreover, flinit controls the accumulation precision of sums and dot products:
%
%flinit('AccumulateSingle') Accumulation precision same as working precision (default)
%flinit('AccumulateDouble') Accumulation precision double the working precision
%flinit('AccumulateMode')   Retrieves the current accumulation precision
%
%This applies to sum, prod and vector and matrix operations. Note that 
%for 'AccumulateDouble' the accumulation precision is 2k in case k<=13, 
%otherwise it is 53 corresponding to IEEE 754 binary64 (double precision).
%
%Floating-point operations of fl-numbers follow the IEEE 754 standard
%including the rounding modes nearest, downwards, upwards and towards zero.
%The rounding mode is changed as usual by the INTLAB-routine 'setround'.
%

% written  10/11/13     S.M. Rump
% modified 03/06/14     S.M. Rump  warning suppressed
% modified 04/23/14     S.M. Rump  set/getappdata replaced by global
% modified 05/18/14     S.M. Rump  code optimization
% modified 03/21/15     S.M. Rump  warning suppressed
% modified 02/14/16     S.M. Rump  help
%

  global INTLAB_CONST

  const = INTLAB_CONST.FL_CONST;
  
  if ( nargin==0 ) 
    if isempty(const)     % initialize fl-package
      INTLAB_CONST.FL_MODE_DISPLAY = 1;
      INTLAB_CONST.FL_MODE_ACCU = 0;
    else
      if ( nargout==2 )       % retrieve information
        res = const.prec;
        expBias = const.expBias;
      else
        fprintf('fl-format set to %d mantissa bits incl. impl. 1 and exponent range %d .. %d for normalized fl-numbers', ...
          const.prec,-const.expBias+1,const.expBias)
      end
    end

  elseif ischar(prec)
    
    if nargin==1
      see = 1;
    else
      see = expBias;
    end
    
    switch lower(prec)
      
      case 'display'
        if INTLAB_CONST.FL_MODE_DISPLAY
          res = 'DisplayBits';
        else
          res = 'DisplayDouble';
        end

      case 'displaybits'
        INTLAB_CONST.FL_MODE_DISPLAY = 1; 
        if nargout>0
          res = 'DisplayBits';
        end
        if see
          disp('===> Display fl-variables by bit representation')
        end

      case 'displaydouble'
        INTLAB_CONST.FL_MODE_DISPLAY = 0; 
        if nargout>0
          res = 'DisplayDouble';
        end
        if see
          disp('===> Display fl-variables as doubles')
        end

      case 'accumulatemode'
        if INTLAB_CONST.FL_MODE_ACCU
          res = 'AccumulateDouble';
        else
          res = 'AccumulateSingle';
        end

      case 'accumulatedouble'
        INTLAB_CONST.FL_MODE_ACCU = 1; 
        if nargout>0
          res = 'AccumulateDouble';
        end
        if see
          disp('===> fl-accumulation precision double the working precision')
        end

      case 'accumulatesingle'
        INTLAB_CONST.FL_MODE_ACCU = 0; 
        if nargout>0
          res = 'AccumulateSingle';
        end
        if see
          disp('===> fl-accumulation in working precision')
        end


      otherwise
        error('invalid call of flinit')

    end

  elseif nargin==2

    if ~isempty(const)
      
      if ( ( prec<const.prec ) || ( expBias<const.expBias ) ) && ( nargout>0 )
        warning('fl-package already initialized with wider format; mixing formats may produce wrong reaults.')
      end
      
      if ( ~isreal(prec) ) || ( prec~=round(prec) ) || ...
          ( prec<1 ) || ( prec>26 )
        error('invalid call of flinit: 1 <= prec <= 26 is required')
      end
      
      if ( ~isreal(expBias) ) || ( expBias~=round(expBias) ) || ( expBias<1 ) || ( expBias>484 )
        error('invalid call of flinit: 1 <= expBias <= 484 is required')
      end
      
    end

    const.prec = prec;
    const.expBias = expBias;
    const.subrealmin = 2^(-expBias-prec+2);
    const.realmin = 2^(-expBias+1);
    const.factor = 2^(53-const.prec);
    const.realmax = (1-2^(-prec))*2^(expBias+1);
    if isempty(INTLAB_CONST.DISPLAY_WIDTH)
      INTLAB_CONST.DISPLAY_WIDTH = 120;       % minimum 110, so columns>=1
    end
    INTLAB_CONST.FL_CONST = const;

    res = sprintf('Initialization of fl-format to %d mantissa bits incl. impl. 1 and exponent range %d .. %d for normalized fl-numbers',prec,-expBias+1,expBias);

  else
    error('invalid call of flinit')

  end
