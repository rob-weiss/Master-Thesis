%STARTUP      Dummy routine to call startintlab 
%
%Insert the call to "startintlab" into your personal startup-file.
%

% written  09/10/00     S.M. Rump  
% modified 05/19/08     S.M. Rump  catch error from BLAS_VERSION
% modified 06/18/10     S.M. Rump  catch wrong directory, thanks to Kaori Nagatou
% modified 09/07/12     S.M. Rump  comment
% modified 01/20/15     S.M. Rump  redesign
%

  %%%%%%%%%% Please adapt and uncomment this line if necessary %%%%%%%%%%%
  %   cd('c:\intlab')
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  wng = warning;
  warning off
  
  try
    startintlab
  catch
    disp('========================================================================')
    disp('========================================================================')
    disp('*** Some error occurred during startup, this should not happen.         ')
    disp('*** Possible reasons:                                                   ')
    disp('***                                                                     ')
    disp('*** - There might be old .mat-files in the INTLAB directory.            ')
    disp('***     If so, please remove them.                                      ')
    disp('*** - Please adapt the line                                             ')
    disp('***     cd ''c:\intlab''                                                ')
    disp('***   in the file "startup.m" in the INTLAB directory.                  ')
    disp('*** - Another reason might be that you used INTLAB before and set the   ')
    disp('***   environment variable BLAS_VERSION.                                ')
    disp('***   In previous versions of INTLAB this was necessary because         ')
    disp('***   Intel Math Kernel Library (IMKL) did not work with my             ')
    disp('***   switching of the rounding mode.                                   ')
    disp('***   Meanwhile this is changed, IMKL should work properly. So please   ')
    disp('***   delete the environment variable BLAS_VERSION and try again.       ')
    disp('***   Sorry for inconvenience.                                          ')
    disp('***                                                                     ')
    disp('*** - If nothing helps, please go step by step through startup and      ')
    disp('***   startintlab to identify the reason.                               ')
    disp('***                                                                     ')
    disp('*** Press Enter to continue.                     .                      ')
    disp('*** !!! INTLAB is NOT yet working properly !!!                          ')
    disp('========================================================================')
    disp('========================================================================')
  end

 warning(wng);