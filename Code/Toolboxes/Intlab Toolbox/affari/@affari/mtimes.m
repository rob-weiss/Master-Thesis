function r = mtimes(a,b)
%MTIMES       Affine arithmetic multiplication  a * b
%

% written  12/06/13     S.M. Rump
% modified 05/15/14     S.M. Rump  code optimization
%

  global INTLAB_CONST

  % Octave bug: does not respect operator preference, takes method for first operand 
  if INTLAB_CONST.OCTAVE
    if isa(b,'gradient')
      r = mtimes(gradient(a),gradient(b));
      return
    elseif isa(b,'hessian')
      r = mtimes(hessian(a),hessian(b));
      return
    elseif isa(b,'taylor')
      r = mtimes(taylor(a),taylor(b));
      return
    end
  end

  [ma,na] = size(a);
  [mb,nb] = size(b);
  
  if ( ma*na==1 ) || ( mb*nb==1 )    % one scalar factor
    r = a.*b;
    return
  end
  
  if na~=mb                         % check compatibility
    error('incompatible size for affari multiplication')
  end

  %VVVV  r = repmat(a(:,1),1,nb).*repmat(b(1,:),ma,1);
  s.type = '()'; 
  s.subs = {':',1}; aa = subsref(a,s); 
  s.subs = {1,':'}; bb = subsref(b,s);
  r = repmat(aa,1,nb).*repmat(bb,ma,1);
  %AAAA  Matlab bug fix
  for k=2:na
    %VVVV  r = r + a(:,k).*b(k,:);
    s.subs = {':',k}; aa = subsref(a,s); 
    s.subs = {k,':'}; bb = subsref(b,s);
    r = r + repmat(aa,1,nb).*repmat(bb,ma,1);
    %AAAA  Matlab bug fix
  end
