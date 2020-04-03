function restore
  % clean up function for sudden death or error
  global INTLAB_CONST
  INTLAB_CONST.RealStdFctsExcptnIgnore = 0;
end  % function restore
