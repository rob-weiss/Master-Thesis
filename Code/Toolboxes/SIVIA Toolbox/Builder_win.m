path = mfilename('fullpath');
[pathstr,name,ext] = fileparts(path);
target_path = strcat(pathstr, '\cpp_files');
cur_path = pwd;

cd(target_path);
mex -DMATLAB_RELEASE ...
    ... % 
    "IntervalDataVisualiser.cpp" ...
    "Handlers.cpp" ...
    ... % BoxProcessor
    "BoxProcessor.cpp" ...
    ... % Composer
    "Composer.cpp" ...
    ... % DataSet
    "DataSet.cpp" ...
    "DataSetItem.cpp" ...
    ... % Exceptions
    "DataRedefinitionException.cpp" ...
    "NotAllowedOperationException.cpp" ...
    "WrongDataException.cpp" ...
    "WrongInputException.cpp" ...
    "WrongInputFormatException.cpp" ...
    ... % MatlabLayer
    "MatlabLayer.cpp" ...
    ... % Painter
    "Painter.cpp" ...
    ... % Raw Data
    "Border.cpp" ...
    "Box.cpp" ...
    "Color.cpp" ...
    "DataType.cpp" ...
    "Interval.cpp" ...
    "PBRegion.cpp" ...
    "Point.cpp" ...
    ... % Sampler
    "Sampler.cpp" ...
    ... % SetApproximer
    "SetApproximer.cpp" ...
    ... % Utilities
    "Math.cpp" ...
    "Comparers.cpp" ...
    ... % Visualiser
    "Visualiser.cpp"
cd(cur_path);