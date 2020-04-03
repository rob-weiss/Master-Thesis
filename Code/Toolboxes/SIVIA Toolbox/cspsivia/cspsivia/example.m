% constraints as strings
eps = 0.25;
ix = [infsup(-5, 5), infsup(-5, 5)];
f = {'x^2 + y^2 <= 25', 'x >= 0', 'y <= 0'};
[iS, iN, iB] = cspsivia(f, ix, eps);
plotboxes(iS, iN, iB);

% using the forward-backward contractor
eps = 0.25;
ix = [infsup(-5, 5), infsup(-5, 5)];
f = {'x^2 + y^2 <= 25', 'x >= 0', 'y <= 0'};
[iS, iN, iB] = cspsivia(f, ix, eps, 'fbprop');
plotboxes(iS, iN, iB);

% using the boxnarrow contractor
eps = 0.25;
ix = [infsup(-5, 5), infsup(-5, 5)];
f = {'x^2 + y^2 <= 25', 'x >= 0', 'y <= 0'};
[iS, iN, iB] = cspsivia(f, ix, eps, 'boxnarnewt');
plotboxes(iS, iN, iB);

% using a round robin strategy for dividing the box into 3 parts
eps = 0.25;
ix = [infsup(-5, 5), infsup(-5, 5)];
f = {'x^2 + y^2 <= 16', 'x^2 + y^2 >= 9'};
[iS, iN, iB] = cspsivia(f, ix, eps, 'none', 3, 'rr');
plotboxes(iS, iN, iB);

% constraints as anonymous functions
eps = 0.25;
ix = [infsup(-5, 5), infsup(-5, 5)];
f = {@(x,y)(x^2 + y^2 <= 16), @(x,y)(x^2 + y^2 >= 9), @(y)(y >= 0)};
[iS, iN, iB] = cspsivia(f, ix, eps);
plotboxes(iS, iN, iB);

% plot a curve from the database
cspdb;
eps = 0.25;
ix = [infsup(-5, 5), infsup(0, 10)];
bicorn.plotcurve(ix, eps);