function initconstants
% Kopie in verifyglobalrefine für Octave, das private files nicht von private aufruft
  % initialize constants for verifynlssall, verifyglobalmin and verifyconstraintglobalmin
  global INTLAB_NLSS
  
  INTLAB_NLSS.MAXBOXES = 2^14;
  INTLAB_NLSS.PARALLELBOXES = 2^10;
  INTLAB_NLSS.BISECTIONS = 0;
  INTLAB_NLSS.BISECT_DEPTH = 0;
  INTLAB_NLSS.itermax = 2;
  
  INTLAB_NLSS.FLPT = 1e-12;
  INTLAB_NLSS.EPS = 1e-8;
  INTLAB_NLSS.DELTAB = 4;
  INTLAB_NLSS.ISTART = 3;
  
  INTLAB_NLSS.PLOTlimit = 0.0005;     % below that ratio in radius, boxes are not printed
  
end  % function initconstants
