% annulus formed by two concentric circles
circles = curve({'x^2+y^2-16 <= 0', 'x^2+y^2-9 >= 0'});

% http://www.nucalc.com/Examples/LikePacMan/
pacman = curve({'(x^2+y^2-9)*(1/3*x-y^2)-1/2 >= 0', '(y-2)^2+(x-1)^2-1/7 >= 0'});

% http://mathworld.wolfram.com/Lemniscate.html
infty = curve({'(x^2+y^2)^2 - 2*2^2*(x^2-y^2) <= 0'});

% http://mathworld.wolfram.com/SwastikaCurve.html
swastika = curve({'y^4-x^4-x*y = 0'});

% http://mathworld.wolfram.com/Trifolium.html
trifolium = curve({'(x^2+y^2)^2-2*(x^3-3*x*y^2) <= 0'});

% http://mathworld.wolfram.com/Scarabaeus.html
scarabaeus = curve({'(x^2+y^2)*(x^2+y^2+3*x)^2-4^2*(x^2-y^2)^2 <= 0'});

% http://mathworld.wolfram.com/Bicorn.html
bicorn = curve({'y^2*(5^2-x^2)-(x^2+2*5*y-5^2)^2 >= 0'});

% http://mathworld.wolfram.com/KnotCurve.html
knot = curve({'(x^2-1)^2-y^2*(3+2*y) = 0'});

% http://www-sop.inria.fr/coprin/logiciels/ALIAS/Benches/
chemk = curve({'x^2 - y = 0', 'w^2 - z = 0', '2.177*10^7*y - 1.697*10^7*y*w + 0.55*x*w + 0.45*x - w = 0', '1.585*10^14*y*w + 4.126*10^7*x*z - 8.282*10^6*x*w + 2.284*10^7*z*w - 1.918*10^7*z + 48.4*w - 27.73 = 0'});

% http://www-sop.inria.fr/coprin/logiciels/ALIAS/Benches/
trig = curve({'-sin(y)*cos(y)-2*cos(x)*sin(y) >= 0', '-cos(x)*sin(y)-2*sin(x)*cos(y) >= 0'});

% http://www-sop.inria.fr/coprin/logiciels/ALIAS/Benches/
box3 = curve({'e^(-0.1*x) - e^(-0.1*y) - z*(e^(-0.1) - e^(-10*0.1) = 0', 'e^(-0.2*x) - e^(-0.2*y) - z*(e^(-0.2) - e^(-10*0.2) = 0', 'e^(-0.3*x) - e^(-0.3*y) - z*(e^(-0.3) - e^(-10*0.3) = 0'});