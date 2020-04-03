
%% *** Preprocessing.m ***

% Loads MORSE data from .CSV-files, plots them and saves the plots as PDF. Subsequently,
% the signals of interest are distorted by additive noise and stored as .mat-file.

%% Clear workspace and console, close all figures, switch off warnings

clear; close all; warning('off','all'); clc;

%% Basic user settings

% Control plots
plotTrajectoryBool        = true;
plotIndividualSignalsBool = true;

% Control saving of figures, TikZ-files and variables
savePlotsBool     = true;
saveVariablesBool = true;

% Set sample frequency in Hz
fSample = 10;

nThSample         = 10;

firstSample       = 1140;
lastSample        = 3170;
kidnapFirstSample = 65;
kidnapLastSample  = 132;

% Set the number of landmarks in [x, y, z]-direction. This creates an array of x * y * z landmarks,
% equally spaced along the respective coordinate axes between the min and max points specified below
lm.landmarksPerAxis = [2, 2, 1];

% Set the scaling parameter alpha >= 0 that controls the spread of the landmarks: For alpha = 0 all
% landmarks will be located in the same spot in the middle of the trajectory.
% For alpha = 1 the landmarks will be located between the respective min and max values of
% the trajectory in each coordinate direction.
% For alpha > 1 the landmarks will be spread beyond the respective min and max values of
% the trajectory in each coordinate direction.
lm.alpha = 5;

% Set mean mu and standard deviation sigma for each coordinate direction, which determine the final
% landmark positions. mu = 0 and sigmaLandmarks = 0 ensure exact placement according to the
% specifications above. mu != serves as an offset to the positions and sigma > 0 varies the positions
% of the landmarks randomly.
lm.muX    = 0;      % mean in x-direction in m
lm.sigmaX = 20;     % standard deviation in x-direction in m
lm.muY    = 0;      % mean in y-direction in m
lm.sigmaY = 20;     % standard deviation in y-direction in m
lm.muZ    = 0;   % mean in z-direction in m
lm.sigmaZ = 20;     % standard deviation in z-direction in m

% Set the mean mu and the standard deviation sigma for the additive noise that the true signals will
% be distorted with.
muDistances      = 0;               % mean in m
sigmaDistances   = 0.3;             % standard deviation in m

muVelocity       = 0;               % mean in m/s
sigmaVelocity    = 0.04;            % standard deviation in m/s

muEulerAngles    = 0;               % mean in degrees
sigmaEulerAngles = 0.1 * pi / 180 ; % standard deviation in rad

%% Specify signals in the order of the columns in the CSV files.

signals = [ ...
    "posX",  "m"; ...     % Position in x direction in metres in the world frame
    "posY",  "m"; ...     % Position in y direction in metres in the world frame
    "posZ",  "m"; ...     % Position in z direction in metres in the world frame
    ...
    "roll",   "rad"; ...   % Roll angle
    "pitch",  "rad"; ...   % Pitch angle
    "yaw",    "rad"; ...   % Yaw angle
    ...
    "dRoll",  "rad/s"; ... % Roll angle rate
    "dPitch", "rad/s"; ... % Pitch angle rate
    "dYaw",   "rad/s"; ... % Yaw angle rate
    ...
    "velX",  "m/s"; ...   % Linear velocity in x direction in the body frame
    "velY",  "m/s"; ...   % Linear velocity in y direction in the body frame
    "velZ",  "m/s"; ...   % Linear velocity in z direction in the body frame
    ...
    "accX",  "m/s^2"; ... % Linear acceleration in x direction in the body frame
    "accY",  "m/s^2"; ... % Linear acceleration in x direction in the body frame
    "accZ",  "m/s^2"; ... % Linear acceleration in x direction in the body frame
    ];

%% Compute sample period in seconds

samplePeriod = 1 / fSample;

fSample = fSample / nThSample;
samplePeriod = samplePeriod * nThSample;

%% Get file names from selection

defaultPath = '/Users/rob/Documents/Master Thesis/Data/Selected Data/Trajectory_1.csv';
fileNames = uigetfile(defaultPath, 'Select Multiple Files', 'MultiSelect', 'on');

% Convert to cell in case only a single file is selected
if ~iscell(fileNames)
    fileNames = {fileNames};
end

%% Iterate over all selected files

for fileIndex = 1 : length(fileNames)
    %% Read file and map signals to individual variables
    
    % Extract and display current file name
    fileName = fileNames{fileIndex};
    disp(['Current file: ', fileName, newline]);
    
    % Read data from CSV file and store them in a cell array
    data = dlmread(strcat('../Data/Selected Data/', fileName), ';', 1, 0);
    
    % Take only every nth sample
    data = data(firstSample:nThSample:lastSample, :);
    
    % Compute number of samples
    nSamples = size(data, 1);
    
    % Define time vector
    t = samplePeriod * (1:nSamples);
    
    % Assign data to the individual variables
    nSignals = size(signals, 1);
    for l = 1:nSignals
        currentSignalName = char(signals(l, 1));
        eval([currentSignalName, ' = data(1:end, ', num2str(l) ,')'';']);
    end
    
    %% Compute landmark positions
    
    [landmarks, ~, lowerLimits, upperLimits] = computeLandmarkPositions([posX; posY; posZ], lm);
    lowerLimits = [-300, -300, -300];
    upperLimits = [300, 300, 0];
    nLandmarks = size(landmarks, 1);
    
    % Clear file extension for further processing and add number of landmarks
    fileName = [fileName(1:end-4), '_with_', num2str(nLandmarks), '_landmarks'];
    fileNameClean = strrep(fileName, '_' , ' ');
    
    %% Constitute signals of interest to matrices
    
    % Constitute vector of position, linear velocity and orientation angles
    position = [posX; posY; posZ];
    velocity = [velX; velY; velZ];
    eulerAnglesYPR = [yaw; pitch; roll];
    
    % Add noise to velocity and Euler angles
    velocityInputs = velocity + normrnd(muVelocity, sigmaVelocity, size(velocity));
    eulerAnglesYPRInputs = eulerAnglesYPR + normrnd(muEulerAngles, sigmaEulerAngles, size(eulerAnglesYPR));
    
    % Compute distance to each landmark using measurement model
    distances = zeros(nLandmarks, nSamples);
    for is = 1:nSamples
        distances(:, is) = hFun(is, position(:, is), 0, landmarks);
    end
    
    % Add noise to distance measurements
    distanceMeasurements = distances + normrnd(muDistances, sigmaDistances, size(distances));
    
    % Compute trajectory length and duration
    trajectoryLength = 0;
    differences = diff(position, 1, 2);
    for p = 1:length(differences)
        trajectoryLength = trajectoryLength + norm(differences(:, p));
    end
    
    trajectoryDuration = t(end);
    
    disp(['Length of trajectory: ', num2str(trajectoryLength), ' m']);
    disp(['Duration of trajectory: ', num2str(trajectoryDuration / 60), ' min']);
    disp(['Average velocity: ', num2str(trajectoryLength / trajectoryDuration), ' m/s', newline]);
    
    %% Plot landmarks, landmark numbers, 3D trajectory, and auxiliary lines
    
    if plotTrajectoryBool
        
        plotTrajectory(landmarks, position, [], false, [kidnapFirstSample, kidnapLastSample]);
        
        if savePlotsBool
            
            % Save 3D plots to file
            figurePath = ['../Figures/', fileName];
            figureFileName = [fileName, '_1_3D'];
            mkdir(figurePath);
            mkdir('../Figures/All trajectories');
            
            % Save 3D plots to Tikz file
            savePlot2TIKZ([figurePath, '/TikZ/'], figureFileName(1:end-5), gcf);
            
            savePlot2PDF(figurePath, figureFileName, gcf);
            savePlot2PDF(['../Figures/', 'All trajectories'], fileName, gcf);
            
            % Close figure
            close gcf
        end
    end
    
    %% Plot indicidual signals
    
    if plotIndividualSignalsBool
        
        % Iterate over all individual signals
        for index = 1:nSignals
            
            currentSignalName = char(signals(index));
            currentSignalUnit = char(signals(index, 2));
            
            figure(1)
            plot(t / 60, eval(currentSignalName));
            title([fileNameClean, ' – ', currentSignalName, ' vs. time']);
            xlabel('Time in min');
            ylabel([currentSignalName, ' in ', currentSignalUnit]);
            
            if savePlotsBool
                
                figurePath = ['../Figures/', fileName];
                figureFileName = [fileName, '_', num2str(index), '_', currentSignalName];
                mkdir(figurePath);
                savePlot2PDF(figurePath, figureFileName, gcf);
                
                % Close figure
                close gcf
            end
        end
        
        % Plot distances and noise
        for index = 1:size(distances, 1)
            
            figure()
            plot(t / 60, distances(index, :));
            hold on
            plot(t / 60, distanceMeasurements(index, :));
            
            title([fileNameClean, ' – distance to landmark ', num2str(index), ...
                ' vs. time - sigma = ', num2str(sigmaDistances), ' m']);
            xlabel('Time in min');
            ylabel(['$d_', num2str(index), '$']);
            legend('True distance', 'Noisy measurement');
            
            if savePlotsBool
                
                figurePath = ['../Figures/', fileName];
                figureFileName = [fileName, '_', num2str(index + nSignals), '_d_', num2str(index)];
                mkdir(figurePath);
                
                savePlot2PDF(figurePath, figureFileName, gcf);
                
                % Close figure
                close gcf
            end
        end
    end
    
    if saveVariablesBool
        
        % Save workspace variables to file
        mkdir('../Preprocessed data/');
        save(['../Preprocessed data/',  fileName, '.mat'], '-regexp', ...
            ['^(?!(', ... % Exclude variables used for preprocessing
            'accX|accY|accZ|currentSignalName|currentSignalUnit|dPitch|dRoll|dYaw|data|', ...
            'defaultPath|differences|distances|figureFileName|figurePath|fileIndex|', ...
            'fileNames|il|index|is|l|lm|nSignals|p|pitch|plotIndividualSignalsBool|', ...
            'plotTrajectoryBool|posX|posY|posZ|roll|savePlotsBool|saveTikzBool|', ...
            'saveVariablesBool|signals|trajectoryDuration|trajectoryLength|v|', ...
            'velX|velY|velZ|yaw', ...
            ')$).'])
        
        % Save current script for repetition of experiments
        newbackup = ['../Preprocessed data/',  fileName, '-', mfilename, '.m'];
        newpath = [mfilename('fullpath'), '.m'];
        copyfile(newpath, newbackup);
    end
end
