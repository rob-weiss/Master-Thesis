function plotsmallboxes(List,ListS)
  global INTLAB_NLSS
  if ischar(INTLAB_NLSS.SEE)     % special plot of narrow solution boxes
    for j=1:2       % white circle: true (local) minimum, yellow: stationary point
      if j==1
        L = ListS;
        c = 'y';
      else
        L = List;
        c = 'w';
      end
      if ~isempty(L)
        if size(L,1)==1           % 1-dimensional
          scatter(L.mid,zeros(1,size(L,2)),c,'filled')
        elseif size(L,1)==2       % 2-dimensional
          scatter(L.mid(1,:),L.mid(2,:),c,'filled')
        end
      end
    end
  end
end  % function plotsmallboxes
  