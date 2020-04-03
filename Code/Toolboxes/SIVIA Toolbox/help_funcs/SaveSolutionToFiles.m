function SaveSolutionToFiles (T, U ,F, path, name) 
%SAVESOLUTIONTOFILES
% T ~ true, U ~ unknown, F ~ false
% name of file is path+name+type+'.txt', where type is '_t', '_u', '_f' or
% if name is '' then type is 't', 'u', 'f'
% each line of file looks like 'inf_x sup_x inf_y sup_y'

if (not (isa(path, 'char')))
    error('path must be string');
end

if (not (isa(name, 'char')))
    error('name must be string');
end

if (strcmp(name, ''))
    true_name = strcat(name, 't');
    unknown_name = strcat(name, 'u');
    false_name = strcat(name, 'f');
else
    true_name = strcat(name, '_t');
    unknown_name = strcat(name, '_u');
    false_name = strcat(name, '_f');
end

SaveBoxesToFile(T, path, true_name);
SaveBoxesToFile(U, path, unknown_name);
SaveBoxesToFile(F, path, false_name);

end