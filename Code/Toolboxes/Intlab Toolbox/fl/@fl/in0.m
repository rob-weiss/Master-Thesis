function res = in0(A,B)
%IN0          Implements  A in int(B)  entrywise for fl-type intervals A, B
%
%  res = in0(A,B)
%
%For details, see intval/in0
%

% written  11/06/13     S.M. Rump
%

  if isa(A,'fl')
    if isa(B,'fl')
      res = in0(A.value,B.value);
    else
      res = in0(A.value,B);
    end
  else
    res = in0(A,B.value);
  end
      