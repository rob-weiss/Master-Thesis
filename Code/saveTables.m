
clear input;

%% Landmarks

input.data                 = [(1:nLandmarks)', landmarks];
input.tableCaption         = ['Landmark positions ', fileName];
input.tableLabel           = ['landmark_positions_', fileName(12)];
input.tableColLabels       = {'Landmark', '$x$ in m', '$y$ in m', '$z$ in m'};
input.dataFormat           = {'$%i$', 1, '$%3.3f$', 3};
input.tableColumnAlignment = 'r';
input.tableBorders         = 0;

latex{1} = latexTable(input);

%% Parameters

input.data                 = [ ...
    sigmaSysNoisePF(1), NaN, sigmaSysNoisePFC(1), NaN, NaN, NaN;
    sigmaSysNoisePF(4) * 180 / pi, NaN, sigmaSysNoisePFC(4) * 180 / pi, NaN, NaN, NaN;
    sigmaLikelihoodPF, sigmaLikelihoodUPF, sigmaLikelihoodPFC, sigmaLikelihoodUPFC, sigmaLikelihoodPFS, sigmaLikelihoodUPFS;
    NaN, sigmaTransPriorUPF, NaN, sigmaTransPriorUPFC, NaN, sigmaTransPriorUPFS;
    NaN, sigmaP0UPF, NaN sigmaP0UPFC, NaN, sigmaP0UPFS;
    NaN, sigmaQUPF(1),  NaN sigmaQUPFC(1),  NaN, sigmaQUPFS(1);
    NaN, sigmaQUPF(4)  * 180 / pi,  NaN sigmaQUPFC(4)  * 180 / pi,  NaN, sigmaQUPFS(4)  * 180 / pi;
    NaN, sigmaRUPF,  NaN sigmaRUPFC,  NaN, sigmaRUPFS;
    ];
input.tableCaption         = ['Parameters ', fileName];
input.tableLabel           = ['landmark_positions_', fileName(12)];
input.tableColLabels       = {'PF', 'UPF', 'PFC', 'UPFC', 'PFS', 'UPFS'};
input.tableRowLabels       = { ...
    '$\sigma_{v}$ in \unitfrac[]{m}{s}', ...
    '$\sigma_{YPR}$ in °', ...
    '$\sigma_{Lik}$ in m', ...
    '$\sigma_{Trans}$ in m', ...
    '$\sigma_{P_0}$ in m', ...
    '$\sigma_{v_Q}$ in \unitfrac[]{m}{s}', ...
    '$\sigma_{YPR_Q}$ in °', ...
    '$\sigma_{R}$ in m', ...
    };
input.dataFormat           = {'$%3.2f$'};
input.tableColumnAlignment = 'r';
input.tableBorders         = 0;

latex{2} = latexTable(input);

%% Results

input.data                 = [ ...
    meanRmsErrorPF, meanRmsErrorUPF, meanRmsErrorPFC, meanRmsErrorUPFC, meanRmsErrorPFS, meanRmsErrorUPFS;
    meanErrorsPF(1), meanErrorsUPF(1), meanErrorsPFC(1), meanErrorsUPFC(1), meanErrorsPFS(1), meanErrorsUPFS(1);
    convTimePF, convTimeUPF, convTimePFC, convTimeUPFC, convTimePFS, convTimeUPFS;
    relTimePF, relTimeUPF, relTimePFC, relTimeUPFC, relTimePFS, relTimeUPFS;
    NaN, NaN, totalNZeroWeightsPFC, totalNZeroWeightsUPFC, totalNZeroWeightsPFS, totalNZeroWeightsUPFS
    NaN, NaN, relNZeroWeightsPFC, relNZeroWeightsUPFC, relNZeroWeightsPFS, relNZeroWeightsUPFS
    ];
input.tableCaption         = ['Results ', fileName];
input.tableLabel           = ['landmark_positions_', fileName(12)];
input.tableColLabels       = {'PF', 'UPF', 'PFC', 'UPFC', 'PFS', 'UPFS'};
input.tableRowLabels       = { ...
    'Mean root-mean-square error in m', ...
    'Mean initial error in m', ...
    'Mean convergence time in s', ...
    'Mean computation time relative to PF', ...
    'Number of weights set to zero', ...
    'Rel. no. of weights set to zero in \%' ...
    };
input.dataFormatMode       = 'row';
input.dataFormat           = {'$%3.2f$', 4, '$%i$', 1, '$%3.2f$', 1};
input.tableColumnAlignment = 'r';
input.tableBorders         = 0;

latex{3} = latexTable(input);


%% Save tables to file

% save LaTex code as file
fid = fopen([logFilePath, logFileName, '.tex'], 'w');

for tab = 1:length(latex)
    currentTab = latex{tab};
    for row = 1:size(currentTab, 1)
        fprintf(fid, '%s\n', currentTab{row,:});
    end
end

fclose(fid);

