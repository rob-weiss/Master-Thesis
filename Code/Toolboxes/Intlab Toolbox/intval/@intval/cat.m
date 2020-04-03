function c = cat(dim,varargin)
%CAT          Implements  cat(DIM,A1,A2,...)  for intervals
%
%The call
%  B = cat(DIM,A1,A2,A3,A4,...) 
%concatenates the input arrays A1, A2, etc. along the dimension DIM.
%

% written  12/11/13     S.M. Rump  On request by Eugeny Kolesnikov
% modified 05/15/14     S.M. Rump  code optimization
%

  c = [];
  N = length(varargin);

  if dim==1
    for i=1:N
      c = vertcat(c,varargin{i});
    end
  elseif dim==2
    for i=1:N
      c = horzcat(c,varargin{i});
    end
  else                      % dim>=3
    sizeargs = size(varargin{1});
    lensizeargs = length(sizeargs);
    s.type = '()';
    s.subs = num2cell(sizeargs);
    if dim>lensizeargs      % new dimension added
      s.subs = [ s.subs ones(1,dim-lensizeargs-1) N ];
      %VVVV  c(sizeargs,1,...,1,N) = 1
      c = subsasgn(intval([]),s,1);
      %AAAA  Matlab bug fix
      for i=1:lensizeargs
        s.subs{i} = ':';
      end
      for i=1:N
        A = varargin{i};
        if ~isequal(sizeargs,size(A))
          error('incompatible size')
        end
        %VVVV  c(:,:,1,...,1,i) = varargin{i]
        s.subs{dim} = i;
        c = subsasgn(c,s,A);
        %AAAA  Matlab bug fix
      end
    else                    % existing dimension extended
      DimNew = 0;
      for i=1:N
        DimNew = DimNew + size(varargin{i},dim);
      end
      s.subs{dim} = DimNew;
      %VVVV  c(extended sizeargs) = 1
      c = subsasgn(intval([]),s,1);
      %AAAA  Matlab bug fix
      for i=1:lensizeargs
        s.subs{i} = ':';
      end
      I = 0;
      for i=1:N
        A = varargin{i};
        k = size(varargin{i},dim);
        %VVVV  c(extended sizeargs) = varargin{i]
        s.subs{dim} = (I+1):(I+k);
        c = subsasgn(c,s,A);
        %AAAA  Matlab bug fix
        I = I + k;
      end
    end
  end
  