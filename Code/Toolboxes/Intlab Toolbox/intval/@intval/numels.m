function n = numels(a)
%NUMELS        number of elements for type intval
%

% written  12/12/15     S.M. Rump
%

  if a.complex
    n = numel(a.mid);
  else
    n = numel(a.inf);
  end
end  % function numels