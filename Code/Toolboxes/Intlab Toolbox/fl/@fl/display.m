function display(A)
%DISPLAY      Command window display for fl-type
%

% written  10/21/13     S.M. Rump
%

  global INTLAB_CONST

  if isa(A.value,'intval')
    disp(['fl-type intval ' inputname(1) ' ='])
  else
    disp(['fl-type ' inputname(1) ' ='])
  end

  const = INTLAB_CONST.FL_CONST;

  if INTLAB_CONST.FL_MODE_DISPLAY
    
    if INTLAB_CONST.OCTAVE
      loose = false;
    else
      loose = strcmp(get(0,'FormatSpacing'),'loose');
    end

    INTLAB_DISPLAY_WIDTH = INTLAB_CONST.DISPLAY_WIDTH;    % minimum 110, so columns>=1
    L = const.prec + 13;      % % length of one element in current format
    columns = floor((INTLAB_DISPLAY_WIDTH+1)/(L+1));
    A = A.value;
    if isa(A,'intval')
      iv = 1;
      Ainf = A.inf;
      Asup = A.sup;
    else
      iv = 0;
    end
    
    if nargout            % output string
      outstr = '';
      for i=1:numels(A)
        if iv
          outstr = [ outstr getbits_(Ainf(i),Asup(i),const,L) ];
        else
          str = getbits(A(i),-const.prec);
          outstr = [ outstr str blanks(L-length(str)) ];
        end
      end
      
    elseif issparse(A)    % sparse output
      [I,J] = find(A);
      for i=1:length(I)
        str = sprintf('  (%d,%d)',I(i),J(i));
        if iv
          str = [ str blanks(5) getbits_(full(Ainf(I(i),J(i))),full(Asup(I(i),J(i))),const,L) ];
        else
          str = [ str blanks(L-length(str)) ];
          str = [ str getbits(full(A(I(i),J(i))),-const.prec) ];
        end
        disp( str )
      end
      
    else                  % full output
      [m,n] = size(A);
      for jj=1:ceil(n/columns)
        j1 = (jj-1)*columns+1;
        if jj*columns<n
          j2 = jj*columns;
        else
          j2 = n;
        end
        if n>columns
          if j1~=j2
            disp(['  Columns ' sprintf('%d',j1) ' through ' sprintf('%d',j2)]);
          else
            disp(['  Column ' sprintf('%d',j1)]);
          end
          if loose, disp(' '); end
        end
        for i=1:m
          s = '';
          for j = j1:j2
            if iv
              s = [ s getbits_(Ainf(i,j),Asup(i,j),const,L) ];
            else
              str = getbits(A(i,j),-const.prec);
              s = [ s str blanks(L-length(str)) ];
            end
          end
          disp(s)
        end
        if loose, disp(' '); end
      end
    end
    
  else                  % display as double numbers
    disp(A.value)
  end
  
end  % function display

  
function str = getbits_(Xinf,Xsup,const,L)
% output string for interval fl-type
  strinf = getbits(Xinf,-const.prec);
  strinf = [ strinf(2:end) blanks(L-length(strinf)-1) ];
  strsup = getbits(Xsup,-const.prec);
  strsup = [ strsup(2:end) blanks(L-length(strsup)-1) ];
  str = [ ' [ ' strinf ' , ' strsup ' ] ' ];
end  % function getbits_
