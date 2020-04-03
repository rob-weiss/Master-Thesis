function res = in(A,B)
%IN0          Implements  A in B  entrywise for fl-type intervals A, B
%
%  res = in(A,B)
%
%For details, see intval/in
%

% written  11/06/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      res = in(A.value,B.value);
    else
      res = in(A.value,B);
    end
  else
    res = in(A,B.value);
  end
      