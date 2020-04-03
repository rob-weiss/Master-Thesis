%MAKEFILESETROUND   Makefile to generate setround.oct for Octave
%

% written  01/19/15     Kai Ohlhus
%

if (exist ('setround.cc', 'file'))
  CPPFLAGS_orig = getenv('CPPFLAGS');
  setenv('CPPFLAGS', [CPPFLAGS_orig ' -std=c++11']);
  mkoctfile setround.cc;
  setenv('CPPFLAGS', CPPFLAGS_orig);
else
  CFLAGS_orig = getenv('CFLAGS');
  setenv('CFLAGS', [CFLAGS_orig ' -std=c11']);
  mkoctfile -mex setround.c;
  setenv('CFLAGS', CFLAGS_orig);
end