function c = horzcat(varargin)
%HORZCAT      Implements  [a(1) a(2) ...]  for affari
%

% written  03/08/14     S.M. Rump
% modified 05/21/14     S.M. Rump  All zero sparse: 1-by-1
%

  a = affari(varargin{1});
  c.mid = a.mid;
  c.err = a.err;
  c.rnderr = a.rnderr;
  c.range = a.range;

  for i=2:length(varargin)
    a = affari(varargin{i});
    c.mid = [ c.mid , a.mid ];
    % take care of "All zero sparse: 1-by-1": do not use 'isempty'
    if ~nnz(a.err)
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(c.err)
        c.err(1,length(c.rnderr)+length(a.rnderr)) = 0;
      end
    else
      % take care of "All zero sparse: 1-by-1": do not use 'isempty'
      if nnz(c.err)
        ec = size(c.err,1);             % adapt number of error terms
        ea = size(a.err,1);
        if ea<ec
          a.err(ec,1) = 0;
        elseif ec<ea
          c.err(ea,1) = 0;
        end
        c.err = [ c.err , a.err ];     % uses that arrays are stored columnwise
      else
        c.err = [ sparse([],[],[],size(a.err,1),length(c.rnderr)) a.err ];
      end
    end
    c.rnderr = [ c.rnderr , a.rnderr ]; 
    c.range = [ c.range , a.range ];
  end

  c = class(c,'affari');
