function SaveBoxesToFile (boxes, path, name) 
%SAVEBOXESTOFILES Function will save boxes (k * 2 of intervals) into file
% path must have \ or / on as the last character (depending on OS) or name must have \ or / as the first character (depending on OS)
% output name of file is path+name+'.txt'
% each line of file looks like 'inf_x sup_x inf_y sup_y'

if (nargin ~= 3)
    error('wrong number of parameters');
end

if (not (isa(path, 'char')))
    error('path must be string');
end

if (not (isa(name, 'char')))
    error('name must be string');
end

%   x1 = infimum of x 
%   x2 = supremum of x
%   y1 = infimum of y 
%   y2 = supremum of y
x1 = inf(boxes(:,1));
x2 = sup(boxes(:,1));
y1 = inf(boxes(:,2));
y2 = sup(boxes(:,2));
res = [x1; x2; y1; y2];

total_name = strcat(path, name, '.txt');
fid=fopen(total_name,'wt');
fprintf(fid,'%d\n',res);
fclose(fid);

end

