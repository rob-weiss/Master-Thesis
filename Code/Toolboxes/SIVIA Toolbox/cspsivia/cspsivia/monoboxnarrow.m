function ix = monoboxnarrow(ix, func, fmax, fmin, vars, monovars, ig, eps)
% MONOBOXNARROW A variant of the BoxNarrow contractor exploiting the
% monotonicity of the functions in the constraints.
%
%   ix         - an interval box (variable domains)
%   func       - a constraint represented by an anonymous function
%   fmax, fmin - func with monotonic variables replaced by their bounds
%   vars       - indices of variables used in the constraint
%   monovars   - indices of monotonic variables used in the constraint
%   ig         - gradient of the function
%   eps        - desired precision

    iy = ix(monovars); % domains of monotonic variable with multiple occurrences
    notmonovars = ismember(vars, monovars) == 0;
    iz = ix(notmonovars); % domains of other variables
    notmonovars = find(notmonovars);
    
    minvalue = intval(zeros(1, length(vars)));
    maxvalue = intval(zeros(1, length(vars)));

    fmin = str2anon(fmin);
    fmax = str2anon(fmax);
    
    for i=1:length(monovars)
        if ig(i) > 0 % increasing
            minvalue(monovars(i)) = inf(iy(i));
            maxvalue(monovars(i)) = sup(iy(i));
        elseif ig(i) < 0 % decreasing
            minvalue(monovars(i)) = sup(iy(i));
            maxvalue(monovars(i)) = inf(iy(i));
        end
    end
    
    for i=1:length(notmonovars)
        minvalue(notmonovars(i)) = iz(i);
        maxvalue(notmonovars(i)) = iz(i);
    end
    
    iz = num2cell(iz, 1);
    for i=1:length(monovars) % do for each monotonic variable with multiple occurrences  
        if fmin(iz{:}) < 0
            y0 = num2cell(maxvalue(1:monovars(i)-1), 1);
            y1 = num2cell(maxvalue(monovars(i)+1:end), 1);
            fimax = @(x)(func(y0{:}, x, y1{:}));
            if ig(i) > 0        % increasing, improve left bound
                iy(i) = leftnarrow(iy(i), fimax, ig(i), eps, 'max');
            elseif ig(i) < 0    % decreasing, improve right bound
                iy(i) = rightnarrow(iy(i), fimax, ig(i), eps, 'max');
            end
        end
        
        if fmax(iz{:}) > 0 
            y0 = num2cell(minvalue(1:monovars(i)-1), 1);
            y1 = num2cell(minvalue(monovars(i)+1:end), 1);
            fimin = @(x)(func(y0{:}, x, y1{:}));
            if ig(i) > 0        % increasing, improve right bound
                iy(i) = rightnarrow(iy(i), fimin, ig(i), eps, 'min');
            elseif ig(i) < 0    % decreasing, improve left bound
                iy(i) = leftnarrow(iy(i), fimin, ig(i), eps, 'min');
            end
        end
        
        ix(monovars(i)) = iy(i);   % update domains
    end
end

function ix = leftnarrow(ix, f, ig, eps, minmax)
    il = ix;
    izl = f(intval(ix.inf));
    
    if izl.sup < 0
       size = eps * 2*rad(il);
       while ~isnan(il) && 2*rad(il) > size
           xm = intval(mid(il));
           if strcmp(minmax, 'min') % a call of leftnarrowmin
               zm = inf(f(xm));
           else % a call of leftnarrowmax
               zm = sup(f(xm));
           end
           ill = xm - zm/ig; % Newton step
           if ~emptyintersect(il, ill)
               il = intersect(il, ill);           
           else
               return;
           end
       end
       ix = infsup(il.inf, ix.sup);
    end
end

function ix = rightnarrow(ix, f, ig, eps, minmax)
    il = ix;
    izl = f(intval(ix.sup));
    
    if izl.inf > 0
       size = eps * 2*rad(il);
       while ~isnan(il) && 2*rad(il) > size
           xm = intval(mid(il));
           if strcmp(minmax, 'min') % a call of rightnarrowmin
               zm = inf(f(xm));
           else % a call of rightnarrowmax
               zm = sup(f(xm));
           end
           ill = xm - zm/ig; % Newton step
           if ~emptyintersect(il, ill)
               il = intersect(il, ill);
           else
               return;
           end
       end
       ix = infsup(ix.inf, il.sup);
    end
end