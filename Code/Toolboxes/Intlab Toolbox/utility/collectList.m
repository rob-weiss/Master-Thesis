function List = collectList(List,thr)
%COLLECTLIST  Union of overlapping boxes
%
%   List = collectList(List,thr)  
%
%Parameters:
%   List    input List
%   thr     threshold for overlapping, for thr=0.0 all overlapping boxes
%           will be unified, thr=1.0 requires a 100% overlapping.
%
%The list of undecided boxes produced by verifynlssall, verifyglobalmin or
%by verifyconstraintglobalmin may be large. Union of overlapping boxes
%saves memory, however, also gives away information. 
%Moreover, collecting may be slow for many input boxes.
%
%For List being an N x K array of intervals, the output covers the union of
%boxes but collecting overlapping boxes into one box. 
%
%The process is repeated so that the union of a pair of boxes may become
%large enough to swallow the next box.
%
%As an example consider
%
%   X1 = [ infsup(0.2,1.2) infsup( 0 , 1 ) infsup(0.9,2.2)
%          infsup( 1 , 3 ) infsup(0.2,3.2) infsup( 0 , 3 ) ];
%   X2 = [ infsup( 2 , 4 ) infsup(2.4,3.8) infsup(2.5,4.2)
%          infsup(1.9, 5 ) infsup(1.7,3.7) infsup(1.6, 4 ) ];
%   X = [ X1 X2 ];
%   close all
%   subplot(1,4,1);
%   plotintval(X)
%   for index=1:3
%     subplot(1,4,index+1)
%     plotintval(collectList(X,1-.3*index))
%   end
%

% written  03/30/17     S.M. Rump
% modified 07/30/17     S.M. Rump  Comment
%

  % check input list, return if less than two entries
  if size(List,2)<2
    return
  end
  
  % default threshold is 0.5
  if nargin<2 || isempty(thr)
    thr = .5;
  end
  
  % dimension of input list
  [N,K] = size(List);
  
  % we first reorganize the intervals, sorting them according the infimum
  % in the first dimension
  [dummy,infsort] = sort(List.inf(1,:));
  List = List(:,infsort);
  
  % for a faster access we split the interval matrix in its rows using a
  % cell array, infimum and supremum are treated separately
  infC{N} = List.inf();
  supC{N} = List.sup();
  for i = 1:N
    infC{i} = infC{N}(i,:);
    supC{i} = supC{N}(i,:);
  end
  
  % boolean vector to mark elements as redundant, i.e. elements will be
  % removed after processing
  rem = false(1,K);
  
  % main loop for checking
  s = 1;    % stepsize for neighbor search
  ca = 1:K-s; % candidates that may be unified with their s-th neighbor
  while 1
    
    % Since intervals are sorted according to the infimum of theis first
    % entry, the intersection of element i and i+s can only be nonempty
    % if supC{1}(i) >= infC{1}(i+s).
    % Moreover,
    %     supC{1}(i) < infC{1}(i+s) implies supC{1}(i) < infC{1}(i+s+1).
    % Hence, only previous candidates can satisfy this condition.
    ca = ca( supC{1}(ca) >= infC{1}(ca+s) );
    
    % if no more candidates, we can stop searching
    if isempty(ca)
      break;
    end
    
    % checking nonempty intersection for all other dimensions
    ui = ca;  % candidates for unification
    for i = 2:N  % loop through remaining dimensions
      % intersection of element i and i+s is nonempty if
      % supC{1}(i) >= infC{1}(i+s) and supC{1}(i+s) >= infC{1}(i)
      ui = ui(supC{i}(ui)>=infC{i}(ui+s));
      ui = ui(infC{i}(ui)<=supC{i}(ui+s));
    end
    
    % Every element indexed by ui has a nonempty intersection with the
    % element indexed by ui+s.
    % Here we check if the overlapping is large enough
    if ~isempty(ui)
      % The relative overlap is the diameter of the intersection
      % divided by the minimum diameter of both intervals.
      % The relative overlap is computed for each dimension.
      % We check the tolerance/threshold against the mean overlap.
      q = zeros(size(ui));  % mean overlap initialization
      uis = ui+s;  % for efficiency we keep the indices of the neighbor
      for i = 1:N
        intersect = min(supC{i}(ui),supC{i}(uis)) - ...
          max(infC{i}(ui),infC{i}(uis));  % diameter of intersection
        q = q + intersect ./ min(supC{i}(ui)-infC{i}(ui),...
          supC{i}(uis)-infC{i}(uis));  % update relative overlap
      end
      % only the candidates for which the relative overlap is above the
      % tolerance are kept
      ui = ui(q>=thr*N);
    end
    
    % ui contains the indexes of all elements that should be unified with
    % their s-th neighbors
    if ~isempty(ui)
      uis = ui+s;  % for efficiency we keep the indices of the neighbor
      % First we apply the unification for each dimension and remember
      % all modified entries
      modi = false(size(ui));  % boolean vector to mark modified entries
      for i = 1:N
        modi = modi | (infC{i}(ui)>infC{i}(uis));
        infC{i}(ui) = min(infC{i}(ui),infC{i}(uis));
        modi = modi | (supC{i}(ui)<supC{i}(uis));
        supC{i}(ui) = max(supC{i}(ui),supC{i}(uis));
      end
      % then we mark the neighbors ui+s as redundant
      rem(ui+s) = true;
      % but keep modified intervals
      if any(rem(ui(modi)))
        % repeat unification procedure with same stepsize
        s = s-1;  % this is not very efficient!
        % reset modified entries which cannot be marked as redundant
        rem(ui(modi)) = false;
      end
      % Finally we remove redundant entries from the list of candidates
      ca(rem(ca)) = [];
    end
    
    % update stepsize
    s = s+1;
    
    % remove last candidate if possible neighbor lies out of range
    if ca(end)+s>K
      ca(end) = [];  % this is not very efficient!
    end
    
  end  % main loop for unification and marking redundant entries
  
  % recreate infimum and supremum matrix
  infC = vertcat(infC{:});  % vertical concatenation of rows (infimum)
  supC = vertcat(supC{:});  % the same for the supremum
  
  % removal of redundant entries
  infC(:,rem) = [];
  supC(:,rem) = [];
  
  % creating output list of intervals
  List = infsup(infC,supC);
  
end  % function collectList
