function [ B ] = LoadBoxesFromFile( file_name )
%LOADBOXESFROMFILE load previously saved boxes

vect = importdata(file_name);

if (mod(length(vect),4) ~= 0)
    error('not possible to convert into boxes');
end

len = length(vect) / 4;

B = midrad(zeros(len,2),0);
for i=1:len
    B(i,1) = infsup(vect(i), vect(i + len));
    B(i,2) = infsup(vect(i + 2*len), vect(i + 3*len));
end

end

