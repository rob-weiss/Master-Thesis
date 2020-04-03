function ListData = verifyglobalrefine(ListData)
%VERIFYGLOBALREFINE  working routine for refinement
%
%used by verifynlssall, verifyglobalmin and verifyconstraintglobalmin
%

% written  07/17/15     S.M. Rump
%

  global INTLAB_NLSS
  
  % store warning mode
  wng = warning;
  warning off
  
  % store standard function exception mode
  RealStdFctsExcptnMode = intvalinit('RealStdFctsExcptn',0);
  intvalinit('RealStdFctsExcptnNaN',0);
  
  % ignore input out of range; NaN ~ empty [set in calling routine]
  % INTLAB_CONST.RealStdFctsExcptnIgnore = 1;
  
  initconstants;

  if INTLAB_NLSS.NLSSALL
    currentListS = ListData.ListS;
    K = size(currentListS,2);
    dK = INTLAB_NLSS.MAXBOXES;
    newListS = [];
    for i=1:dK:K                  % restrict number of boxes to ensure bisection
      if dK>=K
        INTLAB_NLSS.CurrentX0 = currentListS;
      else
        INTLAB_NLSS.CurrentX0 = currentListS(:,i:min(i+dK-1,K));
      end
      % INTLAB_NLSS is updated by verifyglobal
      ListData = verifyglobal(INTLAB_NLSS.CurrentX0);
      newListS = [ newListS ListData.ListS ];
    end
%     ListS = collectList(ListS);   % not much merit    
    ListData.ListS = newListS;
  elseif INTLAB_NLSS.GLOBOPT
    currentListS = ListData.ListS;
    K = size(currentListS,2);
    dK = INTLAB_NLSS.MAXBOXES;
    newListS = [];
    for i=1:dK:K                  % restrict number of boxes to ensure bisection
      if dK>=K
        INTLAB_NLSS.CurrentX0 = currentListS(1:end-1,:);
      else
        INTLAB_NLSS.CurrentX0 = currentListS(1:end-1,i:min(i+dK-1,K));
      end
      % INTLAB_NLSS is updated by verifyglobal
      ListData = verifyglobal(INTLAB_NLSS.CurrentX0);
      newListS = [ newListS ListData.ListS ];
    end
    ListData.ListS = newListS;
    % ListData.ListS = collectList(ListS);   % not much merit
  elseif INTLAB_NLSS.CONSTRAINT    
    currentListS = ListData.ListS{INTLAB_NLSS.Lindex};
    K = size(currentListS,2);
    if K>0                          % make sure mu is computed
      dK = INTLAB_NLSS.MAXBOXES;
      newListS = [];
      mu = intval(inf);
      for i=1:dK:K                  % restrict number of boxes to ensure bisection
        if dK>=K
          INTLAB_NLSS.CurrentX0 = currentListS(1:end-1,:);
        else
          INTLAB_NLSS.CurrentX0 = currentListS(1:end-1,i:min(i+dK-1,K));
        end
        ListData = verifyglobal(INTLAB_NLSS.CurrentX0,ListData);
        newListS = [ newListS ListData.ListS{INTLAB_NLSS.Lindex} ];
        mu = min(mu,ListData.mu);
      end
      ListData.ListS{INTLAB_NLSS.Lindex} = newListS;
      ListData.mu = mu;
      % ListData.ListS{INTLAB_NLSS.Lindex} = collectList(ListS);   % not much merit
    end
  else
    error('That should not happen');
  end
    
  % restore warning mode
  warning(wng);

  % store standard function exception mode
  intvalinit(RealStdFctsExcptnMode,0);

end  % function verifyglobalrefine


function initconstants
% Kopie für Octave, das private files nicht von private aufruft
  % initialize constants for verifynlssall, verifyglobalmin and verifyconstraintglobalmin
  global INTLAB_NLSS
  
  INTLAB_NLSS.MAXBOXES = 2^14;
  INTLAB_NLSS.PARALLELBOXES = 2^10;
  INTLAB_NLSS.BISECTIONS = 0;
  INTLAB_NLSS.BISECT_DEPTH = 0;
  INTLAB_NLSS.itermax = 2;
  
  INTLAB_NLSS.FLPT = 1e-12;
  INTLAB_NLSS.EPS = 1e-8;
  INTLAB_NLSS.DELTAB = 4;
  INTLAB_NLSS.ISTART = 3;
  
  INTLAB_NLSS.PLOTlimit = 0.0005;     % below that ratio in radius, boxes are not printed
  
end  % function initconstants


function [List,brem] = joinList(List,knownval)
% Für Octave: nicht in @private Ordner! 
% Identische Kopie in verifyglobal

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
