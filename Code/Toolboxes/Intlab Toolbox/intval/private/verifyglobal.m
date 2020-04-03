function ListData = verifyglobal(x0,ListData)
%VERIFYGLOBAL  working routine 
%
%used by verifynlssall, verifyglobalmin and verifyconstraintglobalmin
%

% written  02/27/17  S.M. Rump
% modified 05/01/17  S.M. Rump  correction of BoundaryBoxes, many thanks to
%                                 Mark L. Stone for pointing to this
% modified 06/07/17  S.M. Rump  max(..,[],1)
% modified 07/19/17  S.M. Rump  computation of mu
% modified 07/30/17  S.M. Rump  again mu and ifunmax
% modified 10/09/17  S.M. Rump  number of subboxes
% modified 10/10/17  S.M. Rump  zero finding for g(x)
% modified 12/06/17  S.M. Rump  check argument inside X0
% modified 12/12/17  S.M. Rump  interval iteration in ZeroInGx
%

%Supposes that INTLAB_NLSS, in particular the fields CurrentX0, DAME and
%GAMMA as well as GLOBMIN and mu for the optimization routines, are
%defined.
%Übergabe per data:
%kappa  verifizierte Nullstelle bzw. stationärer Punkt
%ismin  kappa ist Minimum (logisch)
%GAMMA  expandiertes kappa
%DAME   hier kein lokaler Löser mehr
%ListS  noch nicht entschiedene Boxen

  global INTLAB_NLSS
  
  % store warning mode
  wng = warning;
  warning off
  
  % store standard function exception mode
  RealStdFctsExcptnMode = intvalinit('RealStdFctsExcptn',0);
  intvalinit('RealStdFctsExcptnNaN',0);
  
  % ignore input out of range; NaN ~ empty [set in calling routine]
  % INTLAB_CONST.RealStdFctsExcptnIgnore = 1;
  
  N = INTLAB_NLSS.N;
  if INTLAB_NLSS.CONSTRAINT
    SIZE = 1:(N+INTLAB_NLSS.M);
  else
    SIZE = 1:N;
  end
  
  if ischar(INTLAB_NLSS.SEE)
    figure
    try
      set(gcf,'WVisual','07')       % delete if display is not OK
    end
    hold on
    X = INTLAB_NLSS.X0(1:N)*midrad(1,.1);
    if N==1
      axis([X.inf X.sup -1 1]);
    else
      axis(reshape([X.inf X.sup]',1,2*N));
    end
  end
  
  ListS = x0;     % current refinement box, initial box INTLAB_NLSS.X0
  ListSacc = [];  % accurate boxes: need no refinement for global(constraint)min
                  % and if objective function accurate enough
  
  for iter = 1:INTLAB_NLSS.NIT    % main loop
    
    if INTLAB_NLSS.SEE==1
      fprintf('Pass %d of %d, treating next %d sublists\n', ...
        iter,INTLAB_NLSS.NIT,size(ListS,2))
    end
    if isempty(ListS)             % search finished
      break
    end
    
    ListSs = ListS;
    ListS = intval([]);
    
    % bisection
    lengthListSs = size(ListSs,2);
    if ~isempty(ListSs)
      if lengthListSs>INTLAB_NLSS.MAXBOXES
        for ib=1:INTLAB_NLSS.MAXBOXES:lengthListSs
          index = ib:min(lengthListSs,ib+INTLAB_NLSS.MAXBOXES-1);
          [listL,listB] = bisection(ListSs(SIZE,index),1,intval([]),intval([]));
          if INTLAB_NLSS.GLOBOPT && ...
             ( ( ( iter>1 ) && ( mod(iter,2) == 1 ) ) || ( iter==INTLAB_NLSS.NIT ) )
            listL = NewtonTest(listL);
          end
          ListS = [ ListS listL listB];
        end
      else
        [listL,listB] = bisection(ListSs(SIZE,:),1,intval([]),intval([]));
        if INTLAB_NLSS.GLOBOPT && ...
             ( ( ( iter>1 ) && ( mod(iter,2) == 1 ) ) || ( iter==INTLAB_NLSS.NIT ) )
          listL = NewtonTest(listL);
        end
        ListS = [ listL listB ];
      end
    end
    
    if isempty(ListS)             % search finished
      break
    end

    if INTLAB_NLSS.CONSTRAINT && ( ~isempty(ListS) ) 
      if ( INTLAB_NLSS.M==1 ) || isinf(INTLAB_NLSS.GLOBMIN)
        % maybe expensive for M>1
        yf = min(ZeroInGx(ListS));       % upper bound of min(f(x)) for feasible x
        if yf<inf                        % feasible points found
          INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,yf);
          INTLAB_NLSS.feasible = 1;
        end
      end
    end
    
    % clean up listS
    if INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
      nListS = size(ListS,2);
      index = true(1,nListS);
      if ~isempty(ListS)    % discard X if inf(f(X))>GLOBMIN
       index = bsxfun(@le,ListS.inf(end,:),INTLAB_NLSS.GLOBMIN);
      end
      if ~any(index)
        if ischar(INTLAB_NLSS.SEE) && ( ~isempty(ListS) )  % fill plot discarded boxes
          plotres(ListS,INTLAB_NLSS.SEE)
        end
        ListS = intval([]);
      elseif ~all(index)
        if ischar(INTLAB_NLSS.SEE) && ( ~isempty(ListS) )    % fill plot discarded boxes
          plotres(ListS(:,~index),INTLAB_NLSS.SEE)
        end
        ListS = ListS(:,index);
      end

    end
    
    if INTLAB_NLSS.GLOBOPT
      ListS = CleanupCluster(ListS);
    end
    
    % check accuracy
    if INTLAB_NLSS.NLSSALL
      acc = 1;
    elseif INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
      mu = getmu(INTLAB_NLSS,[ListS ListSacc]);
      acc = ( diam(mu) <= INTLAB_NLSS.TOLFUN ); 
    end
    
    % if accurate or nlssall, check boxes X
    if ( acc || INTLAB_NLSS.NLSSALL ) && ( ~isempty(ListS) )
      if isinf(INTLAB_NLSS.TOLXABS) && isinf(INTLAB_NLSS.TOLXREL)
        break
      else
        indexacc = true(1,size(ListS,2));
      end
      ListSrad = ListS.rad(1:N,:);
      if ~isinf(INTLAB_NLSS.TOLXREL)
        ListSmid = abs(ListS.mid(1:N,:));
        indexacc(any(ListSrad>INTLAB_NLSS.TOLXREL*ListSmid,1)) = false;
      end
      if ~isinf(INTLAB_NLSS.TOLXABS)
        indexacc(any(ListSrad>INTLAB_NLSS.TOLXABS,1)) = false;
      end
      if any(indexacc)
        ListSacc = [ ListSacc ListS(:,indexacc) ];
        ListS(:,indexacc) = [];
      end
    end

  end  % end main loop
  
  % extract List
  ListS = [ ListS ListSacc];
  if ~isempty(INTLAB_NLSS.kappa)
    if INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
      indexBig = ( inf(INTLAB_NLSS.kappa(end,:)) > INTLAB_NLSS.GLOBMIN );
      if any(indexBig)
        INTLAB_NLSS.kappa(:,indexBig) = [];
        INTLAB_NLSS.GAMMA(:,indexBig) = [];
        INTLAB_NLSS.ismin(indexBig) = [];
      end
      % kappa completely in X0
      inX0 = all( bsxfun(@ge,INTLAB_NLSS.kappa.inf(1:N,:),INTLAB_NLSS.X0.inf(1:N)) & ...
                  bsxfun(@le,INTLAB_NLSS.kappa.sup(1:N,:),INTLAB_NLSS.X0.sup(1:N)) ,1);
      if any(inX0)
          index = inX0 & INTLAB_NLSS.ismin;
          % extract elements of ListS corresponding to kappa
          for j=find(index)
            if isempty(ListS)
              break
            end
            % all(in( ListS , INTLAB_NLSS.GAMMA(:,j) ))
            GammaInf = INTLAB_NLSS.GAMMA.inf(1:N,:);
            GammaSup = INTLAB_NLSS.GAMMA.sup(1:N,:);
            dame = ( all(bsxfun(@ge,inf(ListS(1:N,:)),GammaInf(:,j)),1) & ...
                     all(bsxfun(@le,sup(ListS(1:N,:)),GammaSup(:,j)),1) );
            ListS(:,dame) = [];
          end
      end
      notinX0 = ( ~inX0 );
      if any(notinX0)        
        lkappa = bsxfun(@max,INTLAB_NLSS.kappa(1:N,notinX0).inf,INTLAB_NLSS.CurrentX0.inf(1:N));
        rkappa = bsxfun(@min,INTLAB_NLSS.kappa(1:N,notinX0).sup,INTLAB_NLSS.CurrentX0.sup(1:N));
        val = INTLAB_NLSS.kappa(N+1:end,notinX0);
        ListS = [ ListS [ intval( lkappa,rkappa , 'infsup') ; val ] ];
        INTLAB_NLSS.kappa(:,notinX0) = [];
        INTLAB_NLSS.ismin(:,notinX0) = [];
      end
    else                    % call by verifynlssall
      % kappa completely in X0
      inX0 = all( bsxfun(@ge,INTLAB_NLSS.kappa.inf,INTLAB_NLSS.X0.inf) & ...
                  bsxfun(@le,INTLAB_NLSS.kappa.sup,INTLAB_NLSS.X0.sup) ,1);
      if any(inX0)
        % extract elements of ListS corresponding to kappa
        for j=find(inX0)
          if isempty(ListS)
            break
          end
          % all(in( ListS , INTLAB_NLSS.GAMMA(:,j) ))
          GammaInf = INTLAB_NLSS.GAMMA.inf;
          GammaSup = INTLAB_NLSS.GAMMA.sup;
          dame = any( all(bsxfun(@ge,inf(ListS),GammaInf(:,j)),1) & ...
                      all(bsxfun(@le,sup(ListS),GammaSup(:,j)),1) );
          ListS(:,dame) = [];
        end
      end
      notinX0 = ( ~inX0 );
      if any(notinX0)
        lkappa = bsxfun(@max,INTLAB_NLSS.kappa(:,notinX0).inf,INTLAB_NLSS.CurrentX0.inf);
        rkappa = bsxfun(@min,INTLAB_NLSS.kappa(:,notinX0).sup,INTLAB_NLSS.CurrentX0.sup);
        ListS = [ ListS intval( lkappa,rkappa , 'infsup') ];
        INTLAB_NLSS.kappa(:,notinX0) = []; 
      end
    end
  end
  
  if INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
    mu = getmu(INTLAB_NLSS,ListS);      % mu w.r.t. given x0
    INTLAB_NLSS.mu = min(INTLAB_NLSS.mu,mu);
    INTLAB_NLSS.GLOBMIN = min(mu.sup,INTLAB_NLSS.GLOBMIN);
  end
  
  % too slow for large lists
%   ListS = collectList(ListS);  % mu better before union

  ListData.INTLAB_NLSS = INTLAB_NLSS;   % data for refinement
  
  if  INTLAB_NLSS.NLSSALL
    ListData.kappa = INTLAB_NLSS.kappa;
    ListData.GAMMA = INTLAB_NLSS.GAMMA;
    ListData.DAME = INTLAB_NLSS.DAME;
    ListData.ListS = ListS;
  elseif INTLAB_NLSS.GLOBOPT
    % get rid of obsolete stationary points
    ListData.kappa = INTLAB_NLSS.kappa;
    ListData.ismin = logical(INTLAB_NLSS.ismin);
    ListData.GAMMA = INTLAB_NLSS.GAMMA;
    ListData.DAME = INTLAB_NLSS.DAME;
    ListData.ListS = ListS;
    ListData.mu = INTLAB_NLSS.mu;
  elseif INTLAB_NLSS.CONSTRAINT
    ListData.kappa = INTLAB_NLSS.kappa;
    ListData.ismin = logical(INTLAB_NLSS.ismin);
    ListData.GAMMA = INTLAB_NLSS.GAMMA;
    ListData.DAME = INTLAB_NLSS.DAME;
    ListData.ListS{INTLAB_NLSS.Lindex} = ListS;
    ListData.mu = INTLAB_NLSS.mu;
  else
    error('This should not happen')
  end
  
  % restore warning and exception mode
  warning(wng)
  % restore out-of-range exception mode
  intvalinit('RealStdFctsExcptn',RealStdFctsExcptnMode);
  
end  % function verifyglobal


function [listL,listB] = bisection(v,level,listL,listB,dummy)
  global INTLAB_NLSS
  global INTLAB_CONST
  
  N = INTLAB_NLSS.N;      	% number of unknowns
  if INTLAB_NLSS.CONSTRAINT
    M = INTLAB_NLSS.M;      % number of constraints
  end
  
  if ( length(INTLAB_NLSS.SEE)==2 ) && ( level>1 )
    pause       % pause plotting
  end
  
  if nargin==4
    % halve only variables for constraint optimization
    [vinf,vsup] = halve(v.inf,v.sup,INTLAB_NLSS.CONSTRAINT);
    K = size(vinf,2);        % dimension and number of boxes
    while K<INTLAB_NLSS.BOXES
      Kold = K;
      [vinf,vsup] = halve(vinf,vsup,INTLAB_NLSS.CONSTRAINT);
      K = size(vinf,2);
      if Kold==K          % there might be only point-interval boundary boxes
        break
      end
    end
    v = intval(vinf,vsup,'infsup');
  end
  
  if INTLAB_NLSS.GLOBOPT
    sizev2 = size(v,2);
    if sizev2>INTLAB_NLSS.PARALLELBOXES
      for ib=1:INTLAB_NLSS.PARALLELBOXES:sizev2
        index = ib:min(sizev2,ib+INTLAB_NLSS.PARALLELBOXES-1);
        [listL,listB] = bisection(v(:,index),level,listL,listB,1);
      end
      return
    end
  end
  
  if INTLAB_NLSS.SEE==1
    disp(['Length(L) ' sprintf('%d',size(v,2)) ...
      '    bisection depth ' sprintf('%d',INTLAB_NLSS.BISECT_DEPTH) ])
  end
  
  INTLAB_NLSS.BISECT_DEPTH = INTLAB_NLSS.BISECT_DEPTH + 1;

%   for j=1:size(INTLAB_NLSS.GAMMA,2)
%     % all(in( v , INTLAB_NLSS.GAMMA(:,j) ))
%     dame = dame | ( all(bsxfun(@ge,inf(v),inf(INTLAB_NLSS.GAMMA(:,j))),1) & ...
%                     all(bsxfun(@le,sup(v),sup(INTLAB_NLSS.GAMMA(:,j))),1) );
%   end
  dame = false(1,size(v,2));
  if ~isempty(v)
    if INTLAB_NLSS.GLOBOPT        % call verifyglobalmin
      INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,gradient(v,'matrixofvectors'));
      else
        y = feval(INTLAB_NLSS.F,gradient(v,'matrixofvectors'),INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(v,2);
      yx = y.x;
%       ydx = squeeze(y.dx)';     % problems in older Matlab versions
      if size(v,2)==1
        ydx = y.dx';
      else
        ydx = permute(y.dx,[2 3 1])'; 
      end
      [dummy,index] = sort(yx.inf);
      v = v(:,index);
      yx = yx(index);
      ydx = ydx(:,index);
      if isempty(INTLAB_NLSS.param)
        yf = feval(INTLAB_NLSS.F,intval(v.mid));
      else
        yf = feval(INTLAB_NLSS.F,intval(v.mid),INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(v,2);
      % possible improvement by midpoint rule (data is already computed)
      % careful: NaN may occur in gradient for large input, e.g.
      % h=@(x)sqr(x), x=realmax*ones(2,1), h(gradientinit(x))
      % produces [inf NaN;NaN inf] for gradient
      yxmpr = yf + sum( ydx.*(v-v.mid),1 );
      index = isnan(yxmpr);
      if any(index)
        index = ~index;
        if any(index)
          yx(index) = intersect( yx(index) , yxmpr(index) );
        end
      else
        yx = intersect( yx , yf + sum( ydx.*(v-v.mid),1 ) );
      end
%       if ismember(level/N,1:2:INTLAB_NLSS.ND)
%         v = NewtonTest(v);
%       end
      minsupyx = min(sup(yf));
      INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,minsupyx);
      dame = dame | isnan(yx) | ( inf(yx) > INTLAB_NLSS.GLOBMIN );
      if any(dame)
        if ischar(INTLAB_NLSS.SEE)
          plotres(v(:,dame),INTLAB_NLSS.SEE)       % fill boxes
        end
        index = ~dame;           % argument not out of range
        v = v(:,index);
        dame = false(1,sum(index));
        yx = yx(:,index);
        yf = yf(:,index);
        ydx = ydx(:,index);
      end
      yff = yf;
      % ~in(0,f'), box with no extremum; make sure no input out of range
      indexnoex = find( ( any(bsxfun(@gt,inf(ydx),0),1) | ...
                          any(bsxfun(@lt,sup(ydx),0),1) ) &  (  inf(yx)~=-inf ) & ...
                          ( ~INTLAB_CONST.RealStdFctsExcptnOccurred ) );
      if any(indexnoex)
        dame(indexnoex) = true;    % discard inner box without minimum, boundary boxes on listB  
        v0 = v(:,indexnoex);
        % in0(v,X0) [original X0], boundary box, only indices indexnoex
        indexb = any(bsxfun(@eq,v0.inf,INTLAB_NLSS.X0.inf),1) | ...
                 any(bsxfun(@eq,v0.sup,INTLAB_NLSS.X0.sup),1);
        if any(indexb)
          indexnoexb = indexnoex(indexb);   % boundary boxes without extremum
          v(1:N,indexnoexb) = BoundaryBoxes(v(1:N,indexnoexb),ydx(:,indexnoexb)); % shrink to boundary
          if isempty(INTLAB_NLSS.param)
            yf = feval(INTLAB_NLSS.F,v(:,indexnoexb));
          else
            yf = feval(INTLAB_NLSS.F,v(:,indexnoexb),INTLAB_NLSS.param{:});
          end
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + length(indexnoexb);
          index = ( inf(yf) <= INTLAB_NLSS.GLOBMIN ) & ( ~any(isnan(yf),1));
          if any(index)                 % function value too large
            INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,min(yf.sup(index)));
            I = indexnoexb(index);
            listB = [ listB [ v(:,I) ; yf(index) ] ];
          end
        end
      end
    elseif INTLAB_NLSS.CONSTRAINT       % call verifyconstraintglobalmin
      INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
      [y,yy,lambda] = feval(INTLAB_NLSS.Fb,INTLAB_NLSS.F,INTLAB_NLSS.G,v,-1);
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(v,2);
      v(end-M+1:end,:) = lambda;        % improved Lagrange multiplier
      % ~in(0,g(x)) or, f(x) or g(x) out of range
      index = ( any(bsxfun(@lt,yy.g.sup,0),1) | any(bsxfun(@gt,yy.g.inf,0),1) ) | ...
                any(isnan(yy.f),1) | any(isnan(yy.g),1) ;
      % function value already too large
      dame = dame | index | ( inf(yy.f) > INTLAB_NLSS.GLOBMIN );
      if any(dame)
        if ischar(INTLAB_NLSS.SEE) && ( ~isempty(v) ) && any(dame(:))
          plotres(v(:,dame),INTLAB_NLSS.SEE)       % fill boxes
        end
        index = ~dame;
        v = v(:,index);
        lambda = lambda(:,index);
        yy.f = yy.f(index);
        dame = false(1,sum(index));
      end
      if ~INTLAB_CONST.RealStdFctsExcptnOccurred
        indexnoex = find(any(isnan(lambda),1));
        if any(indexnoex)
          dame(indexnoex) = true;    % discard inner box without minimum, boundary boxes on listB
          v0 = v(1:N,indexnoex);
          % boundary boxes, only indices indexnoex
          indexb = any(bsxfun(@eq,v0.inf,INTLAB_NLSS.X0.inf(1:N)),1) | ...
            any(bsxfun(@eq,v0.sup,INTLAB_NLSS.X0.sup(1:N)),1);
          if any(indexb)
            indexnoexb = indexnoex(indexb);   % boundary boxes without extremum
            v(1:N,indexnoexb) = BoundaryBoxes(v(1:N,indexnoexb)); % shrink to boundary
            if isempty(INTLAB_NLSS.param)
              yf = feval(INTLAB_NLSS.F,v(1:N,indexnoexb));
            else
              yf = feval(INTLAB_NLSS.F,v(1:N,indexnoexb),INTLAB_NLSS.param{:});
            end
            yg = feval(INTLAB_NLSS.G,v(1:N,indexnoexb));
            INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + 2*length(indexnoexb);
            % in(0,g(x)) and not too large function value
            index = all(bsxfun(@le,yg.inf,0),1) & all(bsxfun(@ge,yg.sup,0),1) & ...
              ( inf(yf) <= INTLAB_NLSS.GLOBMIN ) & ( ~any(isnan(yf),1) );
            if any(index)                     % constraints may be satisfied
              I = indexnoexb(index);
              listB = [ listB [ v(:,I) ; yf(index) ] ];
            end
          end
        end
      end
    else                                    % call verifynlssall
      if INTLAB_NLSS.DERIV
        if isempty(INTLAB_NLSS.param)
          yx = feval(INTLAB_NLSS.F,gradient(v,'matrixofvectors'));
        else
          yx = feval(INTLAB_NLSS.F,gradient(v,'matrixofvectors'),INTLAB_NLSS.param{:});
        end
        INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(v,2);
        yx = struct(yx).dx';
      else
        if isempty(INTLAB_NLSS.param)
          yx = feval(INTLAB_NLSS.F,v);
        else
          yx = feval(INTLAB_NLSS.F,v,INTLAB_NLSS.param{:});
        end
        INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(v,2);
      end
      % any(isnan(yx))
      dame = dame | any(isnan(yx),1);       % argument out of range  
      % ~all(in(0,yx))
      dame = dame | any(bsxfun(@gt,inf(yx),0),1) | any(bsxfun(@lt,sup(yx),0),1);
    end
  end
  
  if ischar(INTLAB_NLSS.SEE) && ( ~isempty(v) ) && any(dame)
    plotres(v(:,dame),INTLAB_NLSS.SEE)       % fill boxes
  end
  
  if INTLAB_NLSS.GLOBOPT
    [dummy,index] = sort(yff.mid - sum(mag(ydx).*rad(v),1));
%     [dummy,index] = sort(yx.inf);
%     [dummy,index] = sort(inf(yff - sum(ydx.*midrad(0,rad(v)),1)));
%     [dummy,index] = sort(yff.inf - sum(mag(ydx).*rad(v),1));
    v = v(:,index);
    yx = yx(index);
    dame = dame(index);
  end
  
  if all(dame)
    INTLAB_NLSS.BISECT_DEPTH = INTLAB_NLSS.BISECT_DEPTH - 1;
    return
  elseif any(dame)
    v = v(:,~dame);
    if INTLAB_NLSS.CONSTRAINT
      yy.f = yy.f(~dame);
    elseif INTLAB_NLSS.GLOBOPT
      yx = yx(~dame);
    end
  end
  
  if ( ~INTLAB_NLSS.NLSSALL ) && ismember(level/N,1:2:INTLAB_NLSS.ND-1)
    if ~isempty(INTLAB_NLSS.kappa)
      index = discard(v,INTLAB_NLSS.GAMMA,1);
      if any(index)
        if ischar(INTLAB_NLSS.SEE)
          plotres(v(:,index),INTLAB_NLSS.SEE)       % fill boxes
        end
        v(:,index) = [];      % level ~= N*INTLAB_NLSS.ND, thus no change of yx
        if INTLAB_NLSS.CONSTRAINT
          yy.f(index) = [];
        end
      end
    end
%     if INTLAB_NLSS.GLOBOPT & ( ~isempty(v) )
%       v = NewtonTest(v);
%     end
    if isempty(v)
      return
    end
    localstrategy(v);
  end

  if ( level == N*INTLAB_NLSS.ND ) || ( INTLAB_NLSS.IFUN>INTLAB_NLSS.IFUNMAX )
    %   if level == max(N,INTLAB_NLSS.ND)
    if ~isempty(INTLAB_NLSS.kappa)
      index = discard(v,INTLAB_NLSS.GAMMA,1);
      if any(index)
        if ischar(INTLAB_NLSS.SEE)
          plotres(v(:,index),INTLAB_NLSS.SEE)       % fill boxes
        end
        v(:,index) = [];      % level ~= N*INTLAB_NLSS.ND, thus no change of yx
        if INTLAB_NLSS.CONSTRAINT
          yy.f(index) = [];
        elseif INTLAB_NLSS.GLOBOPT
          yx(index) = [];
        end
      end
    end
    if isempty(v)
      return
    end
    localstrategy(v);
    if INTLAB_NLSS.CONSTRAINT
      listL = [ listL [ v ; yy.f ] ];
    elseif INTLAB_NLSS.GLOBOPT
%       listL = NewtonTest([ v ; yx ]);
%       listL = [ [ v ; yx ] listL ];
      listL = [ listL [ v ; yx ] ];
    else                % verifynlssall
      listL = [ listL v ];
    end
  else
    [listL,listB] = bisection(v,level+1,listL,listB);
  end
  INTLAB_NLSS.BISECT_DEPTH = INTLAB_NLSS.BISECT_DEPTH - 1;
  
end  % function bisection


function localstrategy(v)
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;
  if isempty(v)
    return
  end
  
  if INTLAB_NLSS.CONSTRAINT     % take care of boxes with no extremum
    v = v(:,~any(isnan(v(N+1:end,:)),1));
  end
  
  xs = local(v);           % careful, XS are only successful indices
  if ~isempty(xs)
    
    xs(:,any(imag(xs)~=0,1)) = [];
    xs = removeDoubleEntries(xs);
    xs = discard(xs,INTLAB_NLSS.DAME);
    
    if ~isempty(xs)
      ss = JacSize;
      K = size(xs,2);
      if INTLAB_NLSS.NLSSALL
        if K<=ss
          [Gamma,kappa] = expansion(xs);
        else
          Gamma = intval([]);
          kappa = Gamma;
          for i=1:ss:K
            [Gamma1,kappa1] = expansion(xs(:,i:min(i+ss-1,K)));
            Gamma = [ Gamma Gamma1 ];
            kappa = [ kappa kappa1 ];
          end
        end
      else   % INTLAB_NLSS.GLOBOPT | INTLAB_NLSS.CONSTRAINT
        if K<=ss
          [Gamma,kappa,ismin] = expansion(xs);
        else
          Gamma = intval([]);
          kappa = Gamma;
          ismin = [];
          for i=1:ss:K
            [Gamma1,kappa1,ismin1] = expansion(xs(:,i:min(i+ss-1,K)));
            Gamma = [ Gamma Gamma1 ];
            kappa = [ kappa kappa1 ];
            ismin = logical([ ismin ismin1 ]);
          end
        end
      end
      if any(kappa)
        if INTLAB_NLSS.CONSTRAINT
          INTLAB_NLSS.feasible = 1;
        end
        if ~isempty(INTLAB_NLSS.GAMMA)  % check kappa in existing GAMMA
          index = discard(kappa,INTLAB_NLSS.GAMMA,1) | ...
            any(bsxfun(@lt,kappa.inf(1:N,:),INTLAB_NLSS.X0(1:N,:).inf),1) | ...
            any(bsxfun(@gt,kappa.sup(1:N,:),INTLAB_NLSS.X0(1:N,:).sup),1);
          Gamma(:,index) = [];
          kappa(:,index) = [];
          if INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
            ismin(index) = [];
          end
        end
        INTLAB_NLSS.kappa = [ INTLAB_NLSS.kappa kappa];
        if INTLAB_NLSS.GLOBOPT || INTLAB_NLSS.CONSTRAINT
          INTLAB_NLSS.ismin = logical([ INTLAB_NLSS.ismin ismin]);
        end
        INTLAB_NLSS.GAMMA = [ INTLAB_NLSS.GAMMA Gamma ];
        INTLAB_NLSS.DAME = [ INTLAB_NLSS.DAME Gamma*midrad(1,INTLAB_NLSS.EPS) ];
      end
      
    end
      
  end
  
end  % function localstrategy


function xsconv = local(X)
  global INTLAB_NLSS
  global INTLAB_CONST
  if isempty(X)
    xsconv = [];
    return
  end
  INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
  
  N = INTLAB_NLSS.N;    % number of unknowns
  jmax = 7;             % max. number of iterations
  
  if INTLAB_NLSS.CONSTRAINT         % call by verifyconstraintglobalmin
    
    SIZE = 1:N;
    j = 0;
    xsconv = [];
    ysconv = [];
    xs = mid(X);
    cont = true;
    factor = 1;
    while any(cont) && ( j<jmax )
      factor = 0.5*factor;
      j = j+1;
      [xs,d,ygdx] = NewtonVector(xs);
      inside = all(bsxfun(@ge,xs,INTLAB_NLSS.CurrentX0_.inf),1) & ...
               all(bsxfun(@le,xs,INTLAB_NLSS.CurrentX0_.sup),1) ;      
      notnan = ( ~any(isnan(xs),1) );
      cont = notnan & inside;   % vector of components to continue
      if j>1
        normd2 = sum(d.^2,1);
        normxs2 = sum(xs.^2,1);
        ok = cont & ( normd2 <= INTLAB_NLSS.FLPT^2*normxs2 ) | ...
          ( normxs2<1e-20 ) ;  % convergent
        % make sure xs is not outside X0 and not inf/nan
        ok = ok & notnan & inside;
        cont = cont & ( normd2 <= factor*normxs2 ) & ( ~ok );
        if any(ok)
          okfind = find(ok);
          [xsok,Index] = removeDoubleEntries(xs(:,okfind));
          supyxok = ZeroInGx(xsok(SIZE,:),ygdx(:,okfind(Index)));
          insideX0 = all(bsxfun(@ge,xsok,INTLAB_NLSS.X0.inf),1) & ...
                     all(bsxfun(@le,xsok,INTLAB_NLSS.X0.sup),1) ;
% insideX0 = insideX0 | true;
          if any(insideX0)
            minsupyxok = min(supyxok(insideX0));
            if minsupyxok<INTLAB_NLSS.GLOBMIN
              INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,minsupyxok);
              index = ( supyxok > INTLAB_NLSS.GLOBMIN+1e-12*abs(INTLAB_NLSS.GLOBMIN) );
              xsok(:,index) = [];
              supyxok(:,index) = [];
            end
          end
          [xsconv,index] = removeDoubleEntries([ xsconv xsok ]);
          ysconv = [ ysconv supyxok ];
          ysconv = ysconv(index);
        end
      end
      xs = xs(:,cont);
    end
    if ~isempty(ysconv)
      index = ( ysconv > INTLAB_NLSS.GLOBMIN+1e-12*abs(INTLAB_NLSS.GLOBMIN) );
      xsconv(:,index) = [];
    end

  elseif INTLAB_NLSS.GLOBOPT        % call by verifyglobalmin
    
    N2 = N^2;
    j = 0;
    xsconv = [];
    ysconv = [];
    xs = mid(X);
    xsh = hessian(xs,'matrixofvectors');
    cont = true;
    factor = 1;
    while any(cont) && ( j<jmax )
      factor = 0.5*factor;
      j = j+1;
      if j>1
        xsh = hessian(xs,'matrixofvectors');
      end
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,xsh);
      else
        y = feval(INTLAB_NLSS.F,xsh,INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xsh,2);
      sy = struct(y); 
      index = any(imag(sy.x)~=0,1) | any(imag(sy.dx)~=0,1) | any(imag(sy.hx)~=0,1);
      if all(index)
        xsconv = [];
        return
      end
      if any(index(:))
        xs(:,index) = [];
        y(:,index) = [];
      end
      if size(xs,2)==1
        ydx = y.dx';
      else
        ydx = permute(y.dx,[2 3 1])';
      end
      K = size(xs,2);
      yhx = reshape(squeeze(y.hx),N2,K);
      ss = JacSize;
      if K<=ss
        d = NewtonCorrection(ydx,yhx,N,K);
      else
        d = xs;
        for ii=1:ss:K
          v = ii:min(ii+ss-1,K);
          d(:,v) = NewtonCorrection(ydx(:,v),yhx(:,v),N,length(v));
        end
      end
      xs = xs - d;
      inside = all(bsxfun(@ge,xs,INTLAB_NLSS.CurrentX0_.inf),1) & ...
               all(bsxfun(@le,xs,INTLAB_NLSS.CurrentX0_.sup),1) ;
      notnan = ( ~any(isnan(xs),1) );
      cont = notnan & inside;
      if j>1
        normd2 = sum(d.^2,1);
        normxs2 = sum(xs.^2,1);
        ok = cont & ( normd2 <= INTLAB_NLSS.FLPT^2*normxs2 ) | ...
          ( normxs2<1e-20 ) ;  % convergent
        % make sure xs is not outside X0 and not inf/nan
        ok = ok & notnan & inside;
        cont = cont & ( normd2 <= factor*normxs2 ) & ( ~ok );
        if any(ok)
          xsok = removeDoubleEntries(xs(:,ok));
          if isempty(INTLAB_NLSS.param)
            supyxok = sup(feval(INTLAB_NLSS.F,xsok));
          else
            supyxok = sup(feval(INTLAB_NLSS.F,xsok,INTLAB_NLSS.param{:}));
          end
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xsok,2);
          insideX0 = all(bsxfun(@ge,xsok,INTLAB_NLSS.X0.inf),1) & ...
                     all(bsxfun(@le,xsok,INTLAB_NLSS.X0.sup),1) ;
          if any(insideX0)
            minsupyxok = min(supyxok(insideX0));
            if minsupyxok<INTLAB_NLSS.GLOBMIN
              INTLAB_NLSS.GLOBMIN = minsupyxok;
              index = ( supyxok > INTLAB_NLSS.GLOBMIN+1e-12*abs(INTLAB_NLSS.GLOBMIN) );
              xsok(:,index) = [];
              supyxok(:,index) = [];
            end
          end
          [xsconv,index] = removeDoubleEntries([ xsconv xsok ]);
          ysconv = [ ysconv supyxok ];
          ysconv = ysconv(index);
        end
      end
      xs = xs(:,cont);
    end
    if ~isempty(ysconv)
      index = ( ysconv > INTLAB_NLSS.GLOBMIN ...
                         + 1e-12*abs(INTLAB_NLSS.GLOBMIN) ...
                         + 1e-14 );
      xsconv(:,index) = [];
    end
    
  else                              % call by verifynlssall
    
    N2 = N^2;
    j = 0;
    xsconv = [];
    xs = mid(X);
    if INTLAB_NLSS.DERIV    
      xsg = hessian(xs,'matrixofvectors');
    else
      xsg = gradient(xs,'matrixofvectors');
    end
    cont = true;
    factor = 1;
    while any(cont) && ( j<jmax )
      factor = 0.5*factor;
      j = j+1;
      if j>1
        if INTLAB_NLSS.DERIV
          xsg = hessian(xs,'matrixofvectors');
        else
          xsg = gradient(xs,'matrixofvectors');
        end
      end
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,xsg);
      else
        y = feval(INTLAB_NLSS.F,xsg,INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xsg,2);
      K = size(xs,2);
      if INTLAB_NLSS.DERIV
        ydx = y.dx;
        yhx = y.hx;
        if N==1
          yhx = reshape(yhx,N2,K);
        else
          s = size(ydx);        % avoid squeeze for Octave
          if length(s)>2
            ydx = reshape(ydx,s(2:end));
          end
          ydx = ydx';
          s = size(yhx);
          if length(s)>2
            yhx = reshape(yhx,s(2:end));
          end
          yhx = reshape(yhx,N2,K);
        end
        ss = JacSize;
        if K<=ss
          d = NewtonCorrection(ydx,yhx,N,K);
        else
          d = xs;
          for ii=1:ss:K
            v = ii:min(ii+ss-1,K);
            d(:,v) = NewtonCorrection(ydx(:,v),yhx(:,v),N,length(v));
          end
        end
      else
        if N==1
          ydx = reshape(y.dx,N2,K);
        else
          ydx = reshape(permute(y.dx,[1 3 2]),N2,K);
        end
        ss = JacSize;
        if K<=ss
          d = NewtonCorrection(y.x,ydx,N,K);
        else
          d = xs;
          yx = y.x;
          for ii=1:ss:K
            v = ii:min(ii+ss-1,K);
            d(:,v) = NewtonCorrection(yx(:,v),ydx(:,v),N,length(v));
          end
        end
      end
      xs = xs - d;
      inside = all(bsxfun(@ge,xs,INTLAB_NLSS.CurrentX0_.inf),1) & ...
               all(bsxfun(@le,xs,INTLAB_NLSS.CurrentX0_.sup),1) ;
      notnan = ( ~any(isnan(xs),1) );
      cont = notnan & inside;
      if j>1
        normd2 = sum(d.^2,1);
        normxs2 = sum(xs.^2,1);
        ok = cont & ( normd2 <= INTLAB_NLSS.FLPT^2*normxs2 ) | ...
          ( normxs2<1e-20 ) ;  % convergent
        % make sure xs is not outside X and not inf/nan
        ok = ok & notnan & inside;
        cont = cont & ( normd2 <= factor*normxs2 ) & ( ~ok );
        xsconv = removeDoubleEntries([ xsconv xs(:,ok) ]);
      end
      xs = xs(:,cont);
    end
    
  end               % end case distinction on constraint, global, nlss

  xsconv = removeDoubleEntries(xsconv);
  
end  % function local


function [xs,d,ygdx] = NewtonVector(xs)
% One Newton step for vector input xs
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;
  M = INTLAB_NLSS.M;
  K = size(xs,2);
  N2 = N^2;
  SIZE = 1:N;
  xsh = hessian(xs(SIZE,:),'matrixofvectors');
  if isempty(INTLAB_NLSS.param)
    yf = feval(INTLAB_NLSS.F,xsh);
  else
    yf = feval(INTLAB_NLSS.F,xsh,INTLAB_NLSS.param{:});
  end
  yg = feval(INTLAB_NLSS.G,xsh);
  INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + 2*size(xsh,2);
  if INTLAB_NLSS.M==1           % one constraint
    fun = getfunindex;
    if K==1
      yfdx = yf.dx';
      ygdx = yg.dx';
    else
      yfdx = permute(yf.dx,[2 3 1])';
      ygdx = permute(yg.dx,[2 3 1])';
    end
    yfhx = reshape(squeeze(yf.hx),N2,K);
    yghx = reshape(squeeze(yg.hx),N2,K);
    ygx = yg.x;
    d = xs;
%     if fun==1     % not much improvement
%       J = repmat(1:N,N,1);
%       I = J';
%       NK = (N+1)*(0:(K-1));
%       Is = bsxfun(@plus,I(:),NK);
%       Js = bsxfun(@plus,J(:),NK);
%       M = sparse(Is,Js,yfhx+bsxfun(@times,xs(end,:),yghx),(N+1)*K,(N+1)*K);
%       Is = bsxfun(@plus,(1:N)',NK);
%       Js = bsxfun(@plus,repmat(N+1,N,1),NK);
%       M = M + sparse(Is,Js,ygdx,(N+1)*K,(N+1)*K) + ...
%         sparse(Js,Is,ygdx,(N+1)*K,(N+1)*K);
%       rhs = [ yfdx + bsxfun(@times,xs(end,:),ygdx) ; ygx ];
%       d = M \ rhs(:);
%     else
%       J = repmat(1:N,N,1);
%       I = J';
%       NK = (N+1)*(0:(K-1));
%       Is = bsxfun(@plus,I(:),NK);
%       Js = bsxfun(@plus,J(:),NK);
%       M = sparse(Is,Js,bsxfun(@times,xs(end,:),yfhx)+yghx,(N+1)*K,(N+1)*K);
%       Is = bsxfun(@plus,(1:N)',NK);
%       Js = bsxfun(@plus,repmat(N+1,N,1),NK);
%       M = M + sparse(Is,Js,yfdx,(N+1)*K,(N+1)*K) + ...
%         sparse(Js,Is,yfdx,(N+1)*K,(N+1)*K);
%       rhs = [ bsxfun(@times,xs(end,:),yfdx) + ygdx ; ygx ];
%       d = M \ rhs(:);
%     end
%     d = reshape(d,size(xs));
    if fun==1  	 % first system
      for k=1:K
        ygdx_k = ygdx(:,k);
        d(:,k) = [ reshape(yfhx(:,k),N,N)+xs(end,k)*reshape(yghx(:,k),N,N) ygdx_k ; ygdx_k' 0 ] ...
          \ [ yfdx(:,k)+xs(end,k)*ygdx_k ; ygx(k) ];
      end
    else
      for k=1:K
        yfdx_k = yfdx(:,k);
        xsk = xs(end,k);
        d(:,k) = [ xsk*reshape(yfhx(:,k),N,N)+reshape(yghx(:,k),N,N) yfdx_k ; yfdx_k' 0 ] ...
          \ [ xsk*yfdx_k+ygdx(:,k) ; ygx(k) ];
      end
    end
  else                          % M constraints
    [I,J] = getfunindex;
    if K==1
      yfdx = yf.dx';
      % reshape(ygdx(:,k),N,M) is the gradient for x_k
      ygdx = yg.dx';
      ygdx = ygdx(:);
    else
      yfdx = permute(yf.dx,[2 3 1])';
      yfdx = yfdx(:);
      % reshape(ygdx(:,k),N,M) is the gradient for x_k
      ygdx = reshape(permute(yg.dx,[3 1 2]),N*M,K);
    end
    ygdx1 = reshape(permute(yg.dx,[3 2 1]),N*K,M);
    lambda = xs(N+1:end,:);
    if isempty(J)
      f_part = yfdx;
    else
      factor_f = repmat(prod(lambda(J,:),1),N,1);
      f_part = factor_f(:).*yfdx;
    end
    factor = lambda;
    factor(J,:) = 1;
    if isempty(factor)
      g_part = sum(ygdx1,2);
    else
      factor_g = reshape(repmat(factor,N,1),M,N*K)';
      g_part = sum(ygdx1.*factor_g,2);
    end
    y = [ reshape(f_part+g_part,N,K); yg.x ];
    % reshape(yfhx(:,k),N,N) is the Jacobian of f for x_k
    yfhx = reshape(yf.hx,N^2,K);
    % reshape(yghx(:,i,k),N,N) is the Jacobian of g_i for x_k
    yghx = reshape(yg.hx,N^2,M,K);
    d = xs;
    for k=1:K           % Newton step for single x_i
      if isempty(J)
        Jac = yfhx(:,k);
      else
        Jac = prod(lambda(J,k))*yfhx(:,k);
      end
      for i=1:M
        if ismember(i,I)
          Jac = Jac + yghx(:,i,k)*lambda(i,k);
        else
          Jac = Jac + yghx(:,i,k);
        end
      end
      ygdxk = reshape(ygdx(:,k),N,M);
      Jacb = [ reshape(Jac,N,N) ygdxk ; ygdxk' zeros(M) ];
      d(:,k) = Jacb\y(:,k);
    end
  end
  xs = xs - d;
end  % function NewtonVector 


function d = NewtonCorrection(ydx,yhx,N,K)
  [II,JJ] = sparseindex(N,K);
  if isa(yhx,'intval')
    d = reshape(full(sparse(II,JJ,yhx))\ydx(:),N,K);
  else
    d = reshape(sparse(II,JJ,yhx)\ydx(:),N,K);
  end
end  % function NewtonCorrection


function [Gamma,kappa,ismin,fkappa,rr,ok] = expansion(xs,refine,fxs)
  global INTLAB_NLSS
  global INTLAB_CONST
  INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
  Gamma = [];
  kappa = [];
  ismin = [];
  if nargin<7
    fkappa = [];
  end
  rr = inf(size(xs));
  [N,K] = size(xs);
  if nargin==1          % first call from localstrategy
    refine = 0;
    fxs = getFunctionValue(intval(xs));
    Index = any( isnan(fxs) | isinf(fxs) , 1);
    if any(Index(:))
      if all(Index)
        return
      end
      xs(:,Index) = [];
      fxs(:,Index) = [];
      K = K - length(find(Index));
    end
  end
  if nargin==3          % increased refine level
    if refine==1
      rho = repmat(1e-10*max(abs(xs),[],1)+1e-10,N,1);
    elseif refine==2
      rho = repmat(1e-2*max(abs(xs),[],1)+1e-5,N,1);
    end
  else                  % refine level 0
    rho = repmat(1e-14*max(abs(xs),[],1)+1e-20,N,1);
  end
  X = midrad(xs,rho);
  if INTLAB_NLSS.NLSSALL
    Jac = getJacobian(X);
  elseif INTLAB_NLSS.GLOBOPT
    [Jac,fkappa] = getJacobian(X);
  else
    [Jac,fkappa,Jg,J] = getJacobian(X);
  end
  if INTLAB_CONST.RealStdFctsExcptnOccurred
    return
  end  
  Index = any(isnan(Jac) | isinf(Jac),1);
  if all(Index)
    return
  end
  if any(Index)
    xs(:,Index) = [];
    fxs(:,Index) = [];
    X(:,Index) = [];
    rho(:,Index) = [];
    Jac(:,Index) = [];
    if INTLAB_NLSS.GLOBOPT
      fkappa(Index) = [];
    elseif INTLAB_NLSS.CONSTRAINT
      fkappa(Index) = [];
      Jg(:,Index) = [];
      J(:,Index) = [];
    end
    K = K - length(find(Index));
  end
  [R,C] = nlssJacobian(N,K,Jac);
  Z = mag(R*fxs(:));
  setround(1)
  rr = reshape(Z + full(sum(C,2)).*rho(:),N,K);
  setround(0)
  ok = all( rr < rho ,1) & ( ~INTLAB_CONST.RealStdFctsExcptnOccurred );
  notok = ~ok;
  if ( any(notok) ) && ( refine<2 )
    [G,k,i] = expansion(xs(:,notok),refine+1,fxs(:,notok));
    if ~isempty(G)
      Gamma = [Gamma G];
      kappa = [kappa k];
      ismin = logical([ismin i]);
    end
  end
  if all(notok)
    return
  elseif any(notok)
    xs(:,notok) = [];
    rr(:,notok) = [];
    X(:,notok) = [];
    Jac(:,notok) = [];
    if INTLAB_NLSS.GLOBOPT
      fkappa(notok) = [];
    elseif INTLAB_NLSS.CONSTRAINT
      fkappa(notok) = [];
      Jg(:,notok) = [];
      J(:,notok) = [];
    end
    K = K - length(find(notok));
  end
  if INTLAB_NLSS.NLSSALL
    kappa = midrad(xs,rr);
  elseif INTLAB_NLSS.GLOBOPT
    kappa = [ midrad(xs,rr) ; fkappa ];
    ismin = isMinimum(N,Jac);
    % redefine GLOBMIN for boxes inside X0
    index = all( bsxfun(@ge,kappa.inf(1:N,:),INTLAB_NLSS.X0.inf) & ...
                 bsxfun(@le,kappa.sup(1:N,:),INTLAB_NLSS.X0.sup) ,1);
    if any(index)
      INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,min(kappa.sup(end,index)));
    end
  elseif INTLAB_NLSS.CONSTRAINT
    kappa = [ midrad(xs,rr) ; fkappa ];
    ismin = isMinimum(N,Jg,J);
    % kappa(end,:) is inclusion of bordered system, thus constraints are satisfied
    % redefine GLOBMIN for boxes inside X0
    index = all( bsxfun(@ge,kappa.inf(1:N,:),INTLAB_NLSS.X0.inf(1:N)) & ...
                 bsxfun(@le,kappa.sup(1:N,:),INTLAB_NLSS.X0.sup(1:N)) ,1);
    if any(index)
      INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,min(kappa.sup(end,index)));
    end
    index = ( ~index );     % minimum requires kappa to be x0
    if any(index)
      ismin(index) = false;
    end
  end
  rr = rad(X);
  r1 = zeros(size(rr));     % mid +/- 10^r1*rr is ok
  r2 = 16 + r1;             % mid +/- 10^r2*rr supposedly not ok
  % expansion radius
  rel = 0.01;
  index = 1:size(r1,2);
  while ~isempty(index)
    INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
    rm = r1(:,index) + 0.5*(r2-r1(:,index));
    X = midrad(xs(:,index),(10.^rm).*rr(:,index));
    Jac = getJacobian(X);
    reg = nlssJacobian(N,size(rm,2),Jac) & ( ~INTLAB_CONST.RealStdFctsExcptnOccurred );
    r1(:,index(reg)) = rm(:,reg);
    r2(:,~reg) = rm(:,~reg);
    acc = all(r2-r1(:,index)<rel*(r1(:,index)+r2),1);
    index(acc) = [];
    r2(:,acc) = [];
  end
  Gamma = midrad(xs,(10.^r1).*rr);
end  % function expansion


function fxs = getFunctionValue(xs)
  global INTLAB_NLSS
  if INTLAB_NLSS.NLSSALL
    if INTLAB_NLSS.DERIV
      if isempty(INTLAB_NLSS.param)
        fxs = feval(INTLAB_NLSS.F,intval(gradient(xs,'matrixofvectors')));
      else
        fxs = feval(INTLAB_NLSS.F,intval(gradient(xs,'matrixofvectors')),INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xs,2);
      fxs = struct(fxs).dx';
    else
      if isempty(INTLAB_NLSS.param)
        fxs = feval(INTLAB_NLSS.F,intval(xs));
      else
        fxs = feval(INTLAB_NLSS.F,intval(xs),INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xs,2);
    end
  elseif INTLAB_NLSS.GLOBOPT
    xsg = gradient(intval(xs),'matrixofvectors');
    if isempty(INTLAB_NLSS.param)
      y = feval(INTLAB_NLSS.F,xsg);
    else
      y = feval(INTLAB_NLSS.F,xsg,INTLAB_NLSS.param{:});
    end
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xsg,2);
    if size(xs,2)==1
      fxs = y.dx';
    else
      fxs = permute(y.dx,[2 3 1])';
    end
  else                          % constraint optimization
    N = INTLAB_NLSS.N;
    K = size(xs,2);
    SIZE = 1:N;
    xsg = gradient(xs(SIZE,:),'matrixofvectors');
    if isempty(INTLAB_NLSS.param)
      yf = feval(INTLAB_NLSS.F,xsg);
    else
      yf = feval(INTLAB_NLSS.F,xsg,INTLAB_NLSS.param{:});
    end
    yg = feval(INTLAB_NLSS.G,xsg);
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + 2*size(xsg,2);
    if INTLAB_NLSS.M==1           % one constraint
      fun = getfunindex;
      if K==1
        yfdx = yf.dx';
        ygdx = yg.dx';
      else
        yfdx = permute(yf.dx,[2 3 1])';
        ygdx = permute(yg.dx,[2 3 1])';
      end
      if fun==1  	 % first system
        fxs = [ yfdx+repmat(xs(end,:),N,1).*ygdx ; yg.x ];
      else
        fxs = [ repmat(xs(end,:),N,1).*yfdx+ygdx ; yg.x ];
      end
    else                    % M constraints
      M = INTLAB_NLSS.M;
      %   yfdx = squeeze(yf.dx)'; % problems in older Matlab versions
      %   ygdx = squeeze(yg.dx)';
      if K==1
        yfdx = yf.dx';
        ygdx = yg.dx';
      else
        yfdx = permute(yf.dx,[2 3 1])';
        yfdx = yfdx(:);
        ygdx = reshape(permute(yg.dx,[3 2 1]),N*K,M);
      end
      lambda = xs(end-M+1:end,:);
      [I,J] = getfunindex;
      factor_f = repmat(prod(lambda(J,:),1),N,1);
      f_part = factor_f(:).*yfdx;
      factor = lambda;
      factor(J,:) = 1;
      factor_g = reshape(repmat(factor,N,1),M,N*K)';
      g_part = sum(ygdx.*factor_g,2);
      fxs = [ reshape(f_part+g_part,N,K); yg.x ];
    end
  end
end  % function getFunctionValue


function [J,fX,ygdx,J1] = getJacobian(X)
  % column vector of Jac(:)
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;
  K = size(X,2);
  if INTLAB_NLSS.NLSSALL
    if INTLAB_NLSS.DERIV
      XX = hessian(X,'matrixofvectors');
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,XX);
      else
        y = feval(INTLAB_NLSS.F,XX,INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(XX,2);
      J = reshape(reshape(y.hx,[N,K*N])',[N,K,N]);
    else
      XX = gradient(X,'matrixofvectors');
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,XX);
      else
        y = feval(INTLAB_NLSS.F,XX,INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(XX,2);
      J = y.dx;
    end
    J = reshape(permute(J,[1 3 2]),N^2,K);  
  elseif INTLAB_NLSS.GLOBOPT
    XX = hessian(X,'matrixofvectors');
    if isempty(INTLAB_NLSS.param)
      y = feval(INTLAB_NLSS.F,XX);
    else
      y = feval(INTLAB_NLSS.F,XX,INTLAB_NLSS.param{:});
    end
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(XX,2);
    fX = y.x;
    INTLAB_NLSS.GLOBMIN = min(INTLAB_NLSS.GLOBMIN,min(fX.sup));
    J = reshape(y.hx,N^2,K);
  else                      % constraint optimization
    M = INTLAB_NLSS.M;
    N2 = N^2;
    SIZE = 1:N;
    xsh = hessian(X(SIZE,:),'matrixofvectors');
    if isempty(INTLAB_NLSS.param)
      yf = feval(INTLAB_NLSS.F,xsh);
    else
      yf = feval(INTLAB_NLSS.F,xsh,INTLAB_NLSS.param{:});
    end
    yg = feval(INTLAB_NLSS.G,xsh);
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + 2*size(xsh,2);
    if INTLAB_NLSS.M==1           % one constraint
      fun = getfunindex;
      if K==1
        yfdx = yf.dx';
        ygdx = yg.dx';
      else
        yfdx = permute(yf.dx,[2 3 1])';
        ygdx = permute(yg.dx,[2 3 1])';
      end    
      yfhx = reshape(squeeze(yf.hx),N2,K);
      yghx = reshape(squeeze(yg.hx),N2,K);
      lambda = reshape(repmat(X(end,:),N*N,1),N,N*K);
      fX = yf.x;
      if fun==1  	 % first system
        J1 = reshape(yfhx,N,N*K) + lambda.*reshape(yghx,N,N*K);
        J = [ reshape([reshape(J1,N*N,K);ygdx],N,(N+M)*K) ; ...
              reshape([ ygdx ; zeros(1,K) ],M,(N+M)*K) ];
      else
        J1 = lambda.*reshape(yghx,N,N*K) + reshape(yfhx,N,N*K);
        J = [ reshape([reshape(J1,N*N,K);yfdx],N,(N+M)*K) ; ...
              reshape([ ygdx ; zeros(1,K) ],M,(N+M)*K) ];
      end
      J = reshape(J,(N+M)^2,K);
      J1 = reshape(J1,N^2,K);
    else                    % M constraints
      fX = yf.x;
      if K==1
        ygdx = yg.dx(:);
      else
        ygdx = reshape(permute(yg.dx,[1 3 2]),N*M,K);
      end
      J = intval(zeros((N+M)^2,K));
      J1 = intval(zeros(N^2,K));
      Xinf = X.inf;
      Xsup = X.sup;
      for k=1:K        
        [dummy1,dummy2,dummy3,Jb,Jk] = ...
          feval(INTLAB_NLSS.Fb,INTLAB_NLSS.F,INTLAB_NLSS.G, ...
            intval(Xinf(:,k),Xsup(:,k),'infsup'),0);
        J(:,k) = Jb(:);
        J1(:,k) = Jk(:);
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + K;
    end
  end
end  % function getJacobian
  
  
function [R,C] = nlssJacobian(N,K,ydx,dummy)
  limit = 200;
  if K<=limit
    [II,JJ] = sparseindex(N,K);
    J = reshape(sparse(II,JJ,ydx),N*K,N*K);
    R = inv(J.mid);
    C = mag(speye(N*K) - R*J);
  else
    N2 = N^2;
    if nargout==1               % only success
      R = false(1,K);
    else
      R = sparse([],[],[],N*K,N*K,N2*K);
      C = R;
    end
    for i=1:limit:K
      i1 = i;
      i2 = min(i+limit-1,K);    % matrices from i1 to i2
      if nargout==1
        v = i1:i2;
        R(v) = nlssJacobian(N,i2-i1+1,ydx(:,v),1);
      else
        v = (i-1)*N+1:min((i+limit-1)*N,K*N);
        [R(v,v),C(v,v)] = nlssJacobian(N,i2-i1+1,ydx(:,i1:i2),1);
      end
    end
    return
  end
  if nargout==1
    % check non-singularity
    R = all(reshape(full(sum(C))<1,N,K),1);
  end
end  % function nlssJacobian  


function ismin = isMinimum(N,Jac,D)
  global INTLAB_NLSS
  K = size(Jac,2);
  if INTLAB_NLSS.CONSTRAINT
    N = INTLAB_NLSS.N;
    M = INTLAB_NLSS.M;
    Jg = Jac;
    J = D;
    ismin = false(1,K);
    JgInf = Jg.inf;
    JgSup = Jg.sup;
    JInf = J.inf;
    JSup = J.sup;
    for k=1:K
      ismin(k) = islocalmin(reshape(intval(JgInf(:,k),JgSup(:,k),'infsup'),N,M)', ...
                            reshape(intval(JInf(:,k),JSup(:,k),'infsup'),N,N));
    end
    return
  end
  % reshape(Jac(:,k),N,N) is k-th Jacobian
  if nargin==2          % first call
    % check positive diagonal
    D = Jac(1:N+1:N^2,:);
    index = any( D<=0 ,1);
    if any(index)         % not s.p.d.
      ismin = false(1,K);
      index = ~index;     % diag(Jac)>0, maybe s.p.d.
      if any(index)
        ismin(index) = isMinimum(Jac(:,index),D);
        return
      end
    end
  end
  % Try simple diagonal transformation
  D = 1./sqrt(D);
  DD = repmat(D,N,1);
  J = reshape(Jac(:).*DD(:),N^2,K);
  DD = repmat(D(:)',N,1);
  J = reshape(J(:).*DD(:),N^2,K);
  J(1:N+1:N^2,:) = 0;
  index = ( sum(abs(reshape(J,N,N*K)),1)<1 );
  ismin = all(reshape(index,N,K),1);
  index = find(~ismin);  % simple check failed, try final check
  JacInf = Jac.inf;
  JacSup = Jac.sup;
  for k=index
    ismin(k) = isspd(reshape(intval(JacInf(:,k),JacSup(:,k),'infsup'),N,N),[],[],1);
  end
end  % function isMinumum


function supyxok = ZeroInGx(xs,ygdx)
  % prove zero in g(X) for X near xs to improve global optimum (for
  % constraintglobalmin)
  % result supyxok is upper bound for f(xs) if g(xs)=0, otherwise inf
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;            % number of unknowns
  M = INTLAB_NLSS.M;            % number of constraints
  K = size(xs,2);               % number of trial points
  SIZE = 1:N;
  X0 = INTLAB_NLSS.X0(SIZE);    % feasible region
  xs = xs(SIZE,:);
  supyxok = inf(1,K);
  if nargin==1                  % try to find g(x)=0, interval input
    yg = feval(INTLAB_NLSS.G,gradient(xs.mid,'matrixofvectors'));
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xs,2);
    if INTLAB_NLSS.M==1           % one constraint
      if K==1
        ygdx = yg.dx';
      else
        ygdx = permute(yg.dx,[2 3 1])';
      end
      x = xs.inf;
      index = ( ygdx > 0 );
      x(index) = xs.sup(index);
      y1 = feval(INTLAB_NLSS.G,intval(x));
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(x,2);
      x = xs.sup;
      x(index) = xs.inf(index);
      y2 = feval(INTLAB_NLSS.G,intval(x));
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(x,2);
      index = all(y1.*y2<=0,1);
      if any(index)        
        if isempty(INTLAB_NLSS.param)
          supyxok(index) = sup(feval(INTLAB_NLSS.F,xs(:,index)));
        else
          supyxok(index) = sup(feval(INTLAB_NLSS.F,xs(:,index),INTLAB_NLSS.param{:}));
        end
        INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + length(index);
      end
      return
    else                        % several constraints
      yg = feval(INTLAB_NLSS.G,gradient(xs.mid,'matrixofvectors'));
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xs,2);
      if K==1
        % reshape(ygdx(:,k),N,M) is the gradient for x_k
        ygdx = yg.dx';
        ygdx = ygdx(:);
      else
        % reshape(ygdx(:,k),N,M) is the gradient for x_k
        ygdx = reshape(permute(yg.dx,[3 1 2]),N*M,K);
      end
      iterate = true;
    end
  else
    iterate = false;
  end
  if M==1                       % one constraint, xs already iterated
    % choose best index based on ygdx(:,i), the gradient of g at x(:,i)
    Index = 1:K;
    [dummy,maxindex] = max(abs(ygdx),[],1);    
    delta = max(abs(xs),[],1) + 1e-20;  % expansion of iterated xs
    for e=10.^[-16:-14 -12:2:-8]
      Indexold = Index;
      X = intval(xs);
      index = maxindex+(0:length(Index)-1)*N;
      X(index) = midrad(xs(index),e*delta); % direct index access
      % intersect with X0, intersection must be nonempty
      Xinf = bsxfun(@max,X.inf,X0.inf);
      Xsup = bsxfun(@min,X.sup,X0.sup);
      index0 = ( feval(INTLAB_NLSS.G,intval(Xinf)) .* ...
                 feval(INTLAB_NLSS.G,intval(Xsup)) <= 0 );
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(Xinf,2);     
      if any(index0)
        if isempty(INTLAB_NLSS.param)
          supyxok(Index(index0)) = sup(feval(INTLAB_NLSS.F,intval(X(:,index0))));
        else
          supyxok(Index(index0)) = sup(feval(INTLAB_NLSS.F,intval(X(:,index0)),INTLAB_NLSS.param{:}));
        end
        INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + length(index0);
        Index(index0) = [];
      end
      if isempty(Index)         % finish if zero in g(x(:,k)) for all indices k
        return
      end
      if ~isequal(Index,Indexold)
        restindex = ( ~index0 );
        xs = xs(:,restindex);
        maxindex = maxindex(restindex);
        delta = delta(restindex);
      end
    end
  else                          % several constraints
    itermax = 3;                % at most kmax iterations
    for k=1:K
      finished = false;
      [dummyL,dummyU,p] = lu(reshape(ygdx(:,k),N,M),'vector');
      J = sort(p(1:M));         % choose M out of N indices
      xsJ = xs(J,k);      
      if iterate
        % floating point Newton iteration
        Xs = xs.mid(:,k);      
        XsJ = Xs(J);
        dXsJ = zeros(size(XsJ));
        dXsJnew = abs(XsJ);
        iter = 0;
        cont = 1;
        while cont && ( ( any(abs(dXsJnew)<.5*dXsJ) && ( norm(dXsJnew)>=1e-14*norm(XsJ,inf) ) && iter<10 ) || ( iter<2 ) )
          iter = iter+1;            % at most 10, at least 2 iterations performed
          dXsJ = dXsJnew;
          yg = feval(INTLAB_NLSS.G,gradientinit(Xs));
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(Xs,2);
          dXsJnew = yg.dx(:,J)\yg.x;
          XsJ = XsJ - dXsJnew;
          cont = all(in(XsJ,xsJ));  % do not leave input interval
        end
        if ~cont                    % next index k
          continue
        end
        Xs(J) = XsJ;
      else
        Xs = xs(:,k);            
      end
      delta = abs(Xs(J)) + 1e-20*norm(Xs(J));   % convergent, try to expand and verify
      X = intval(Xs);
      for ee=10.^[-16:-14 -12:2:-2]
        X(J) = midrad(Xs(J),ee*delta);
        [e,dummy] = emptyintersect(X(J),xsJ);
        if any(e)        % empty intersection, new index 
          break
        end
        for iter=1:itermax
          yg = feval(INTLAB_NLSS.G,gradientinit(X));
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(X,2);
          A = yg.dx(:,J);
          R = inv(mid(A));
          E = eye(M)-R*A;
          normE = norm(E,inf);
          if normE>=1
            return
          end
          Y = R*feval(INTLAB_NLSS.G,intval(Xs));  % Careful, interval
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(Xs,2);
          Y = Xs(J) - Y + midrad(0,mag(norm(E*Y,inf)/(1-normE)));
          if all(in(Y,X(J)))
            X(J) = Y;
            if isempty(INTLAB_NLSS.param)
              supyxok(k) = sup(feval(INTLAB_NLSS.F,X));
            else
              supyxok(k) = sup(feval(INTLAB_NLSS.F,X,INTLAB_NLSS.param));
            end
            INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(X,2);
            finished = true;
            break
          end
          [e,X(J)] = emptyintersect(X(J),Y);
          if any(e)
            break
          end
          Xs = mid(X);
        end
        if finished
          break
        end
      end
    end
  end
end  % function ZeroInGx


function res = islocalmin(Jg,H)
  % verify stationary point is local minimum
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;        % number of unknowns
  M = INTLAB_NLSS.M;        % number of constraints
  if N==1
    res = true;             % a nonlinear system, no optimization
  else
    if M==1
      % older Matlab versions do not accept [~,...] = ...
      [dummy,p] = max(abs(mid(Jg))); % choose pivot
      % Compute basis of null space
      T = eye(N-M);
      T = [ T(1:p-1,:) ; -Jg([1:p-1 p+1:N])/Jg(p) ; T(p:N-M,:) ];
      res = isspd(T'*H*T,[],[],1);   % no sym check
    else
      if M>=N
        res = false;
        return
      end
      [dummyL,dummyU,p] = lu(Jg.mid','vector');
      I = p(1:M);
      J = 1:N;
      J(I) = [];
      % Compute basis of null space
      T = intval(zeros(N,N-M));
      T(I,:) = -Jg(:,I)\Jg(:,J);    % solve interval linear system
      T(J,:) = eye(N-M);
      res = isspd(T'*H*T,[],[],1);  % no sym check
    end
  end
end  % function islocalmin


function v = BoundaryBoxes(v,ydx)
% shrink boundary boxes, v is N x K
  global INTLAB_NLSS
  X0 = INTLAB_NLSS.X0(1:INTLAB_NLSS.N);
  if ischar(INTLAB_NLSS.SEE)
    plotres(v,INTLAB_NLSS.SEE) % fill in red before shrinking
  end
  if nargin==1
    % shrink boundary boxes
    indexleft = bsxfun(@eq,inf(v),inf(X0)) & bsxfun(@ne,sup(v),inf(X0));
    indexright = bsxfun(@eq,sup(v),sup(X0)) & bsxfun(@ne,inf(v),sup(X0));
    index = indexleft & ( ~indexright );
    if any(index(:))              % box on left boundary
      v(index) = inf(v(index));
    end
    index = ( ~indexleft ) & indexright;
    if any(index(:))              % box on right boundary
      v(index) = sup(v(index));
    end
  end
  if nargin==2          % shrink when derivative nonzero
    index = ( ydx>0 );
    if any(index(:))
      v(index) = v.inf(index);
    end
    index = ( ydx<0 );
    if any(index(:))
      v(index) = v.sup(index);
    end
  end
end  % function BoundaryBoxes


function plotres(x,color)
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;        % number of unknowns
  x = x(1:N,:);
  % do not plot very small 3d-boxes
  if N==3
    index = any( diam(x)./repmat(INTLAB_NLSS.X0rad,1,size(x,2)) < 0.01 ,1);
    if all(index)
      return
    end
    if any(index)
      x(:,index) = [];
    end
  end
  if nargin==2
    plotintval(x,color(1),[],1)
  else
    plotintval(x)
  end
  shg
  pause(0.1)
end  % function plotres


function L = JacSize
  global INTLAB_NLSS
  L = max( 10 , ceil(1000/INTLAB_NLSS.N) );
end  % function JacSize


function [I,J] = sparseindex(n,K)
% if ydx(:,k) is k-th Jacobian, then sparse(I,J,ydx(:),n*K,n*K) is
% block-diagonal consisting of the Jacobians
  I = n*ones(K,n^2);
  I(1,:) = repmat((1:n),1,n);
  I = cumsum(I,1)';
  J = repmat(1:K*n,n,1);
end  % function sparseindex


function [x,Index] = removeDoubleEntries(x)
  % x given, eliminate common points
  % Index: remaining indices
  if isempty(x)
    Index = [];
    return
  end
  [n,K] = size(x);
  rel = 1e-6;
  if K>0            % seems superior
    J = 1:K;
    i = 0;
    while i<size(x,2)
      i = i+1;
      xx = x(:,i);
      d = bsxfun(@minus,xx,x);
      index = find( all(abs(d)<rel,1) );
      if length(index)>1
        I = index(2:end);
        x(:,I) = [];
        J(I) = [];
      end
    end
    Index = false(1,K);
    Index(J) = true;
  else
    Q = true;
    for i=1:n
      M = repmat(x(i,:),K,1);
      Q = Q & ( abs(M-M')<rel );
    end
    Q(1:K+1:K^2) = false;
    Index = false(1,K);
    I = find(any(Q));
    while ~isempty(I)
      i = I(1);
      j = find(Q(i,:));
      Index(j) = true;
      Q(i,:) = false;
      Q(j,:) = false;
      I = find(any(Q));
    end
    x(:,Index) = [];
    Index = ~Index;
  end
end  % function removeDoubleEntries


function X = NewtonOperator(X,Xmid,fxs,Jac,N,K)
  [II,JJ] = sparseindex(N,K);
  J = sparse(II,JJ,Jac);
  R = inv(J.mid);
  A = R*J;
  b = R*fxs(:);
  D = 1./diag(A);
  A(1:N*K+1:(N*K)^2) = 0;
  X = Xmid - reshape( D .* ( b + A*rad(X(:)) ) , N,K);
end  % function NewtonOperator

 
function L = NewtonTest(L,dummy)
  global INTLAB_NLSS 
  global INTLAB_CONST
  if isempty(L)
    return
  end
  INTLAB_CONST.RealStdFctsExcptnOccurred = 0;
  N = INTLAB_NLSS.N;
  K = size(L,2);
  LL = L(1:N,:);
  if nargin==1
    index0 = all( bsxfun(@lt,INTLAB_NLSS.X0.inf,LL.inf) & bsxfun(@lt,LL.sup,INTLAB_NLSS.X0.sup) , 1);
    if ~any(index0)
      return
    end
    L = [ L(:,~index0) NewtonTest(L(:,index0),1)];
    return
  end
  LLmid = LL.mid;
  if isempty(INTLAB_NLSS.param)
    y = feval(INTLAB_NLSS.F,gradient(intval(LLmid),'matrixofvectors'));
  else
    y = feval(INTLAB_NLSS.F,gradient(intval(LLmid),'matrixofvectors'), ...
      INTLAB_NLSS.param{:});
  end
  INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(LLmid,2);
  if K==1
    ydx = y.dx';
  else
    ydx = permute(y.dx,[2 3 1])';
  end
  if isempty(INTLAB_NLSS.param)
    y = feval(INTLAB_NLSS.F,hessian(LL,'matrixofvectors'));
  else
    y = feval(INTLAB_NLSS.F,hessian(LL,'matrixofvectors'), ...
      INTLAB_NLSS.param{:});
  end
  INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(LL,2);
  if INTLAB_CONST.RealStdFctsExcptnOccurred
    return
  end
  yhx = reshape(squeeze(y.hx),N^2,K);
  D = yhx(1:N+1:N^2,:);
  omit = any( D<0 , 1 );    % boxes in0(X) and not positive semidefinite
  if any(omit)
    D(:,omit) = [];
    if ischar(INTLAB_NLSS.SEE)
      plotres(L(:,omit),INTLAB_NLSS.SEE)
    end
    L(:,omit) = [];
    LL(:,omit) = [];
    LLmid(:,omit) = [];
    ydx(:,omit) = [];
    yhx(:,omit) = [];
  end
  sing = any(in(0,D),1) | any(isnan(yhx) | isinf(yhx),1);
  if all(sing)
    return
  elseif any(sing)
    LL(:,sing) = [];
    LLmid(:,sing) = [];
    ydx(:,sing) = [];
    yhx(:,sing) = [];
  end
  reg = find(~sing);
  K = size(LL,2);
  ss = max( 10 , ceil(200/INTLAB_NLSS.N) );
  if K<=ss
    LLnew = NewtonOperator(LL,LLmid,ydx,yhx,N,K);
  else
    LLnew = LL;
    for ii=1:ss:K
      v = ii:min(ii+ss-1,K);
      LLnew(:,v) = NewtonOperator(LL(:,v),LLmid(:,v),ydx(:,v),yhx(:,v),N,length(v));
    end
  end
  indexnan = any(isnan(LLnew),1);
  if any(indexnan)
    LL(:,indexnan) = [];
    LLnew(:,indexnan) = [];
    reg = reg(~indexnan);
  end
  if ~isempty(LLnew)
    [e,Lreg] = emptyintersect(LLnew,LL);
    index = ( ~ any(e,1) );                   % non-empty intersection
    if ischar(INTLAB_NLSS.SEE)
      plotres(LL,INTLAB_NLSS.SEE)             % discard all
      plotres(Lreg(:,index),'w')              % regain those with nonempty intersection
    end
    L(1:N,reg) = Lreg;
    L(:,reg(~index)) = [];
  end
end  % function NewtonTest


function [I,J] = getfunindex
% Kopie für Octave, das private files nicht von private aufruft
% indices for constraint function
  global INTLAB_NLSS
  I = INTLAB_NLSS.Lindex;    % this is fun
  if nargout==1
    return
  end
  M = INTLAB_NLSS.M;
  base2 = dec2bin(I-1,M)-48; % choose function g
  I = find(~base2);  % fun=1 corresponds to original system
  J = find(base2);
end  % function getfunindex


function L = CleanupCluster(L)
  global INTLAB_NLSS 
  len = 5;              % minimal cluster length
  rel = 1e-2;           % maximal relative distance
  clustermin = inf;     % possible new minimum
  Lmid = L.mid(1:end-1,:);
  [SP,index] = sort(sum(Lmid.^2,1)/size(L,2));
  d = diff(SP);
  K = size(L,2);
  v = 1:K-1; 
  r = d(v)./(SP(:,v)+SP(:,v+1));
  rr = ( r < rel );
  I = [0 find([rr 0]==0)];
  J = find(diff(I)>=len+1); 
  istart = I(J)+1;      % start and end of sequence
  iend = I(J+1);
  for i=1:length(istart)
    v = istart(i):iend(i);
    C = Lmid(:,index(v));
    x = sum(C,2)/(iend(i)-istart(i)+1);
    indexc = all(bsxfun(@minus,x,C)<rel,1);
    if ~any(indexc)
      continue
    elseif ~all(indexc)
      x = sum(Lmid(:,index(v(indexc))),2)/sum(indexc);
    end
    % start cluster iteration
    boundaryinf = ( abs( ( x - INTLAB_NLSS.X0.inf ) ./ ( x + INTLAB_NLSS.X0.inf ) ) < 1e-12 );
    boundarysup = ( abs( ( x - INTLAB_NLSS.X0.sup ) ./ ( x + INTLAB_NLSS.X0.sup ) ) < 1e-12 );
    boundary = any( boundaryinf | boundarysup );
    if boundary         % keep boundary values
      X0inf = INTLAB_NLSS.X0.inf(boundaryinf);
      X0sup = INTLAB_NLSS.X0.inf(boundarysup);
      xnew(boundaryinf) = X0inf;
      xnew(boundarysup) = X0sup;
    end
    factor = 0.1;
    fold = realmax;
    iter = 0;
    itermax = 50;
    while 1
      if ~all(in(x,INTLAB_NLSS.X0))
        break
      end
      iter = iter+1;
      if isempty(INTLAB_NLSS.param)
        y = feval(INTLAB_NLSS.F,hessianinit(x));
      else
        y = feval(INTLAB_NLSS.F,hessianinit(x),INTLAB_NLSS.param{:});
      end
      INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(x,2);
      xnew = x - y.hx\y.dx';
      if boundary
        xnew(boundaryinf) = X0inf;
        xnew(boundarysup) = X0sup;
      end
      if any(isnan(xnew)) || any(imag(xnew)~=0)
        break
      else
        if isnan(y.x) || ( y.x > fold - factor*abs(fold) ) || ( iter>itermax )
          if isempty(INTLAB_NLSS.param)
            fnew = feval(INTLAB_NLSS.F,xnew);
          else
            fnew = feval(INTLAB_NLSS.F,xnew,INTLAB_NLSS.param{:});
          end
          INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(xnew,2);
          if y.x>fold
            x = xold;
            if fnew<fold
              x = xnew;
            end
          else
            if fnew<y.x
              x = xnew;
            end
          end
          break
        else
          xold = x;
          fold = y.x;
          x = xnew;
        end
      end
      if any(isnan(x)) || any(imag(x)~=0)
        break
      end
    end
    if ~all(in(x,INTLAB_NLSS.X0))
      continue
    end
    if isempty(INTLAB_NLSS.param)
      y = feval(INTLAB_NLSS.F,intval(x));
    else
      y = feval(INTLAB_NLSS.F,intval(x),INTLAB_NLSS.param{:});
    end
    INTLAB_NLSS.IFUN = INTLAB_NLSS.IFUN + size(x,2);
    clustermin = min(y.sup,clustermin);
  end
  if clustermin<INTLAB_NLSS.GLOBMIN
    INTLAB_NLSS.GLOBMIN = clustermin;
    index = ( L.inf(end,:) > INTLAB_NLSS.GLOBMIN );
    L(:,index) = [];
  end
end  % function CleanupCluster


function [xinf,xsup] = halve(xinf,xsup,constraint)
% Wg. Octave identische Kopie in verifynlssparam
% (kein Aufruf von private Funktionen aus private Funktionen)
  % Simple choice to bisect component with largest diameter; other choices
  % like maximal f'*rad(x) are possible, however, with mixed results:
  % sometimes significantly better, sometimes significantly worse.
  % Number of boxes is doubled
  
  global INTLAB_NLSS

  [n,K] = size(xinf);
  
  if constraint         % For constraint optimization, only variables are halved
    M = INTLAB_NLSS.M;
    xxinf = xinf(1:n-M,:);
    xxsup = xsup(1:n-M,:);
    lastrowinf = xinf(end-M+1:end,:);
    lastrowsup = xsup(end-M+1:end,:);
    xinf = xxinf;       % original variables
    xsup = xxsup;
  else
    xxinf = xinf;
    xxsup = xsup;
  end
  xxinf(isinf(xxinf)) = -realmax;
  xxsup(isinf(xxsup)) = realmax;
  mx = 0.5*xxinf + 0.5*xxsup;     % is finite
  rx = mx - xxinf;
  
  [dummy,index] = max(rx,[],1);
  if constraint
    Index = index + (0:K-1)*(n-M);
  else
    Index = index + (0:K-1)*n;
  end
  
  xiinf = xxinf(Index);
  xisup = xxsup(Index);
  midx = mx(Index);
  radx = rx(Index);
  
%   if constraint
%     diamxi = xisup-xiinf;
%   end
  % mx = mid(x(i)); take care of infinite intervals
  % do not take exact midpoint; do not use sign(xi.mid), it may be zero 
  magic = 0.0303195520061965;
  midx = midx + magic*(2*(xiinf>0)-1).*radx;
  narrow = ( radx <= 1e-12*max(abs(xiinf),abs(xisup)) );
  
  % take care of wide intervals
  wide = ( radx > 100 );    % => 10<sqrt(radx)<radx
  if any(wide)
    factor = 1/200;
    xwinf = xiinf(wide);
    xwsup = xisup(wide);
    midwx = midx(wide);    
    radwx = radx(wide);    
    index = ( xwinf>-10 );  % almost positive wide interval
    if any(index)
      rx = radwx(index);
      a = 2/pi*atan(factor*rx);
      midwx(index) = xwinf(index) + (1-a).*rx + a.*sqrt(rx) + magic;
    end
    index = ( xwsup<10 );   % almost negative wide interval
    if any(index)
      rx = radwx(index);
      a = 2/pi*atan(factor*rx);
      midwx(index) = xwsup(index) - (1-a).*rx - a.*sqrt(rx) - magic;
    end    
    index = ( xwinf<-1 ) & ( xwsup>1 );  % e.g. [-2,realmax]
    if any(index)         % wide zero interval
      midwx(index) = magic;
    end
    midx(wide) = midwx;
  end

  if all(narrow)    % do not bisect small diameter or point boxes
    if constraint
      xinf(n-M+1:n,:) = lastrowinf;
      xsup(n-M+1:n,:) = lastrowsup;
    end
    return
  elseif any(narrow)
    % append new halved boxes but not narrow
    x1inf = xinf;
    x1sup = xsup;
    x1inf(Index) = midx;
    notnarrow = ~narrow;
    x1sup(Index(notnarrow)) = midx(notnarrow);
    xinf = [ xinf x1inf(:,notnarrow) ];
    xsup = [ x1sup xsup(:,notnarrow) ];
    if constraint
      xinf(n-M+1:n,:) = [ lastrowinf lastrowinf(:,notnarrow) ];
      xsup(n-M+1:n,:) = [ lastrowsup lastrowsup(:,notnarrow) ];
    end
  else
    % append new halved boxes
    x1inf = xinf;
    x1sup = xsup;
    x1inf(Index) = midx;
    x1sup(Index) = midx;
    xinf = [ xinf x1inf ];
    xsup = [ x1sup xsup ];
    if constraint
      xinf(n-M+1:n,:) = [ lastrowinf lastrowinf ];
      xsup(n-M+1:n,:) = [ lastrowsup lastrowsup ];
    end
  end
end  % function halve


function List = discard(List,GAMMA,dummy)  
%discard L(1:N,i) already in GAMMA; usually GAMMA shorter
% This fast method is due to Marko Lange, thanks a lot
  global INTLAB_NLSS
  N = INTLAB_NLSS.N;

  if isempty(GAMMA) || isempty(List)
    if nargin==3
      List = false(1,size(List,2));
    end
    return
  end
  if size(List,1)==N
    Ls = List;
  else
    Ls = List(1:N,:);
  end
  if size(GAMMA,1)==N
    G = GAMMA;
  else
    G = GAMMA(1:N,:);
  end
  
  nLs = size(Ls,2);
  nG = size(G,2);
  if max(nLs,nG)<=1000  % Treat short lists conventionally
    index = false(1,nLs);
    if isintval(Ls)
      Lsinf = Ls.inf;
      Lssup = Ls.sup;
    else
      Lsinf = Ls;
      Lssup = Ls;
    end
    Ginf = G.inf;
    Gsup = G.sup;
    if nLs<nG
      for i=1:nLs
        index(i) = any( all(bsxfun(@ge,Lsinf(:,i),Ginf),1) & ...
                        all(bsxfun(@le,Lssup(:,i),Gsup),1) );
      end
    else
      for i=1:nG
        index = index | ( all(bsxfun(@ge,Lsinf,Ginf(:,i)),1) & ...
                          all(bsxfun(@le,Lssup,Gsup(:,i)),1) );
      end
    end
    if nargin==2
      List(:,index) = [];
    else
      List = index;
    end
    return
  end
  
  if isintval(Ls)
    LG = [ Ls.inf, G.inf ];
    UG = [ Ls.sup, G.sup ];
  else
    LG = [ Ls, G.inf ];
    UG = [ Ls, G.sup ];
  end
  MG = .5 * ( LG + UG );
  
  [ N, K ] = size( MG );
  
  % choice of row for ordering
  [dummy,j] = max(std(diff(MG,[],2),[],2));

  % row for ordering
  [ m, isort ] = sort( MG(j,:), 'ascend' );
  
  % separate and transpose for faster access
  L{N} = LG(:,isort)';
  U{N} = UG(:,isort)';
  for i = 1 : N
    L{i} = L{N}(:,i);
    U{i} = U{N}(:,i);
  end
  m = m';
  
  % check every s-th neighbor
  idxa = find(isort>nLs);
  idxd = idxa;
  
  indexDiscard = false(1,K);
  for s = 1 : K
    
    % check dimension limits
    if( any( idxa ) && idxa(end) > K - s )
      idxa(end) = [];
    end
    if( any( idxd ) && idxd(1) <= s )
      idxd(1) = [];
    end
    
    % reduce pairings in ascending direction
    idxa = idxa( U{j}(idxa) >= m(idxa+s) );
    
    % reduce pairings in descending direction
    idxd = idxd( L{j}(idxd) <= m(idxd-s) );
    
    % no possible pairings left
    if( ~any( idxa ) && ~any( idxd ) )
      break;
    end
    
    % indices for matching pairing
    inda = idxa;
    indd = idxd;
    for i = [  1 : j - 1, j + 1 : N, j ]
      inda = inda( U{i}(inda) >= U{i}(inda+s) );
      inda = inda( L{i}(inda) <= L{i}(inda+s) );
      indd = indd( U{i}(indd) >= U{i}(indd-s) );
      indd = indd( L{i}(indd) <= L{i}(indd-s) );
    end
    % remove all L_i included in some other interval
    indexDiscard(isort([indd-s,inda+s])) = true;
    
  end  

  % do cleanup
  if nargin==3
    List = indexDiscard(1:size(List,2));
  else
    List(:,indexDiscard(1:size(List,2))) = [];
  end

end  % function discard


function mu = getmu(INTLAB_NLSS,ListS)
% extract value of mu with respect to kappa ans ListS
  if isempty(INTLAB_NLSS.kappa)
    mu = intval(inf);
  else
    mu = intval( min(INTLAB_NLSS.kappa.inf(end,:)) , ...
                 min(INTLAB_NLSS.kappa.sup(end,:)) , 'infsup' );
  end
  if isempty(ListS)    % ListS.inf>GLOBMIN already discarded
    mu = min( mu , INTLAB_NLSS.GLOBMIN );
  else    
    mu = min( mu , intval(min(ListS.inf(end,:)),INTLAB_NLSS.GLOBMIN,'infsup') );
  end
end  % function getmu


function [List,brem] = joinList(List,knownval)
% Für Octave: nicht in @private Ordner! 
% Identische Kopie in verifyglobalrefine

  % join List: intersection of overlapping boxes
  % boxes with List(end,:)>knownval are discarded
  % brem: discarded indices
  % This fast method due to Marko Lange, thanks a lot
  global INTLAB_NLSS
  if isempty(List)
    brem = [];
    return
  end
  N = INTLAB_NLSS.N;
  SIZE = 1:INTLAB_NLSS.N;
  
  if ( nargin>1 ) && ( size(List,2)>1 )
    index = ( inf(List(end,:))>knownval );
    if any(index)
      List(:,index) = [];
    end
  end
  K = size(List,2);
  
  % choice of row for ordering
  [dummy,j] = max(std(diff(List.inf(SIZE,:),[],2),[],2));
  
  [ dummy , isort ] = sort( List.inf(j,:), 'ascend' );
  
  % separate and transpose for faster access
  L{N} = List.inf(SIZE,:);
  L{N} = L{N}(:,isort)';
  U{N} = List.sup(SIZE,:);
  U{N} = U{N}(:,isort)';
  for i = 1 : N
    L{i} = L{N}(:,i);
    U{i} = U{N}(:,i);
  end
  
  % check every s-th neighbor
  idx = 1 : ( K - 1 );  % index vector for possible pairings
  brem = false( K, 1 );  % boolean index vector for discarded elements
  
  for s = 1 : K
    
    % stop if no possible pairing left
    if ~any( idx )
      break;
    end
    
    % remove impossible pairings
    idx = idx( U{j}(idx) >= L{j}(idx+s) );
    
    % stop if no possible pairing left
    if ~any( idx )
      break;
    end
    
    % matching pairing indices
    ind = idx;
    for i = [ 1 : j - 1, j + 1 : N ]
      ind = ind( U{i}(ind) >= L{i}(ind+s) );
      ind = ind( U{i}(ind+s) >= L{i}(ind) );
    end
    if any(ind)
      % update suprema to reduce search width
      U{j}(ind) = min( U{j}(ind), U{j}(ind+s) );
      U{j}(ind+s) = U{j}(ind);
      % replace right pairing member by intersection of both
      inds = isort(ind+s);
      ind = isort(ind);
      Listinf = max( List.inf(:,ind), List.inf(:,inds) );
      Listsup = min( List.sup(:,ind), List.sup(:,inds) );
      List(:,inds) = intval(Listinf,Listsup,'infsup');
      % mark left pairing member for removal
      brem(ind) = true;
    end
    
    if( idx(end) >= K - s - 1 )
      idx(end) = [];
    end
    
  end
  
  % remove all left pairing members
  List(:,brem) = [];

end  % function joinList
