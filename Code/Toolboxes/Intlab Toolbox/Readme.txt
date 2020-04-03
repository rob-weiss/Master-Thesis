A short overview how to use INTLAB (see also file FAQ):
=======================================================

I started to develop INTLAB with the introduction of the operator concept into Matlab. 
It is continuously developed since the first version in 1998. 

The inventor and only developer is Siegfried M. Rump, head of the 
Institute for Reliable Computing at the Hamburg University of Technology. 
In any publication or other material using INTLAB please cite

S.M. Rump: INTLAB - INTerval LABoratory. In Tibor Csendes, editor, 
Developments in Reliable Computing, pages 77-104. Kluwer Academic Publishers, Dordrecht, 1999.
@incollection{Ru99a,
   author = {Rump, {S.M.}},
   title = {{INTLAB - INTerval LABoratory}},
   editor = {Tibor Csendes},
   booktitle = {{Developments~in~Reliable Computing}},
   publisher = {Kluwer Academic Publishers},
   address = {Dordrecht},
   pages = {77--104},
   year = {1999},
   url = {http://www.ti3.tuhh.de/rump/}
}


***** INSTALLATION *****

The easiest way to start is create a file startup.m (or to replace the content 
of the existing one) in the Matlab path \toolbox\local by

   cd ... insert the INTLAB path ...
   startintlab

Then the startintlab.m file is started and should do the rest. For
some user-specific options you may adjust the file startintlab.m  .

For Octave, download the current version from the net or from my homepage. For Octave
the routine "setround" for changing the rounding mode is generated automatically. 
The Octave people do indeed an amazing job. Note, however, that it is a non-commercial
enterprise, so bare with little inconveniences. In any case, the Octave people are 
very eager to fix possible bugs. 

**********************************************************************************

The documentation is included in every routine. INTLAB-code, i.e.
Matlab-code, is (hopefully) self-explaining. INTLAB stays to the
philosophy to implement everything in Matlab.

INTLAB is successfully tested under several Matlab versions, starting
with version 5.3 until to date. 

INTLAB is entirely written in Matlab. There is no system dependency. 
This is because the Mathworks company was so kind to add into the 
routine "system_dependent" a possibility to change the rounding mode 
(my dear thanks to Cleve).

The progress in the different INTLAB versions can be viewed using help, 
for example

   help INTLAB_version_10


INTLAB supports

     - interval scalars, vectors and matrices, real and complex,
     - full and sparse matrices,
     - interval standard functions, real and complex,
     - and a number of toolboxes for intervals, affine arithmetic, gradients, hessians, taylor,
         fl-type, slopes, polynomials, multi-precision arithmetic and more.


There are several demo-routines to get acquainted with INTLAB, please enter

   demo toolbox intlab .


INTLAB results are verified to be correct including I/O and standard functions. 


For the homo ludens in you, try

   intlablogo                .

If you have comments, suggestions, found bugs or similar, contact

    rump(at) tuhh.de       .



DISCLAIMER:   Extensive tests have been performed to ensure reliability
===========   of the algorithms. However, neither an error-free processor
              nor an error-free program can be guaranteed.


INTLAB LICENSE INFORMATION
==========================


Copyright (c) 1998 - 2017 Siegfried M. Rump
                          Institute for Scientific Computing
                          Hamburg University of Technology
                          Germany
                                       

All rights reserved.

===> There are three ways to use INTLAB:

1) Private or academic use, where "academic" means working in a degree 
   granting institution. Research laboratories with no degree program 
   are considered "industrial." Companies associated with universities 
   do not qualify.

2) Industrial use for research and development, where INTLAB or parts of
   INTLAB are not part of any product.

3) Industrial use for research and development such that INTLAB or parts
   of INTLAB are necessary for a product to work properly.

In case 1) and 2) there is a one-time charge. This is for one individual 
to use INTLAB unlimited time. 
In case 3) an explicit license is required, please contact me  rump[at]tuhh.de .

In any case, proper acknowledgement is required that INTLAB has been 
developed by Siegfried M. Rump, head of the Institute for Scientific Computing
at the Hamburg University of Technology, Germany. This is done by citing
the paper [Ru99a] mentioned above.

===> Neither the name of the university nor the name of the author may be used 
to endorse or promote products derived with or from this software without specific 
prior written permission. 

THIS SOFTWARE IS PROVIDED AS IS AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, 
INCLUDING, WITHOUT LIMITATIONS, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND 
FITNESS FOR A PARTICULAR PURPOSE. 

