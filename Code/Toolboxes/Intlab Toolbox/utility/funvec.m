function fvec = funvec(f,x0,x,param)
%FUNVEC       Vectorize expression
%
%   F = funvec(f,X)
%
%The routines verifynlssall, verifyglobalmin, verifyconstraintglobalmin, 
%verifynlssderivall and verifynlssparam make extensive use of vectorized 
%versions of the input function to speed up computations. Input X is a
%possible input (interval) argument.
%
%The objective is that for f:R^n->R^m, the results of 
%
%   [ f(x1) f(x2) ]   and   F([x1 x2])
%
%should be identical. To that goal, operations o are replaced by .o [using
%ideas from Matlab's vectorize function], and varible access x(&) is 
%replaced by x(&,:). The function f must depend on one (vector) variable.
%The default is 'x'; for another variable name, say 'y', call
%
%   F = funvec(f,X,'y')
%

% written  08/17/15  S.M. Rump
% modified 07/06/17  S.M. Rump  Final check for vectorization: f = @(x) g(g(x))
%                                 may fail (thanks to Thomas Wanner)
%
% uses Matlab's VECTORIZE idea

  global INTLAB_CONST
    
  try               % avoid unpleasant surprises
    
    if ( nargin<3 ) || isempty(x)
      x = 'x';
    end
    if ( nargin<4 ) || isempty(param)
      param = {};
    else
      param = param{:};
    end
    
    % Octave inline function is function handle
    handle = isa(f,'function_handle');
    
    % discard empty function
    try
      v = char(f);
      if INTLAB_CONST.OCTAVE
        handle = false;
      end
    catch
      v = func2str(f);
    end
    if isempty(v)==1
      fvec = f;
      return
    end
    
    % function handles only if one-line function definition
    if handle
      if ~isequal(v(1),'@')
        fvec = f;
        return
      end
    end
    
    % remove blanks
    v(v==' ') = [];
    
    % vectorize
    for k = fliplr(find((v=='^') | (v=='*') | (v=='/')))
      v = [v(1:k-1) '.' v(k:end)];
    end
    v(strfind(v,'..')) = []; % Remove any possible ..*, ../, etc.
    
    % replace x(&) by x(&,:)
    fleft = findstr(v,'(');
    fright = findstr(v,')');
    i = 0;
    J = [];
    lenfleft = length(fleft);
    while i<lenfleft
      i = i+1;
      k = fleft(i);
      if ( k==1 ) || ( v(k-1)~=x )
        continue
      end
      j = 1;
      fright(fright<k) = [];
      while ( i<lenfleft) && ( fleft(i+1)<fright(j) )
        i = i+1;
        j = j+1;
      end
      J = [J fright(j)];
      fright = fright(j+1:end);
    end
    for k=J(end:-1:1)
      v = [ v(1:k-1) ',:' v(k:end) ];
    end
    
    % prepare function handle
    if handle
      eval(['fvec = ' v ';'])
    else
      fvec = inline(v);
    end
    
    % last check for vectorization
    if isempty(param)
      y = f(x0);
      yvec = fvec(x0);
    else
      y = f(x0,param);
      yvec = fvec(x0,param);
    end
    if ~isequal(y,yvec)
      fvec = f;
    end
    
  catch
    
    fvec = f;
    
  end
  
end  % function funvec
