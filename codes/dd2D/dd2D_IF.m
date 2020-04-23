run dd2D
%Time-stepping 
T = 100;
h = 5e-2;
M = T/h;
x = xIC;
every = 100;

%parpool
%linear operator
workers = 8; %3*Nx*Nz = 3(2^{2p+log_2(aspectratio)}) i.e. aspect ratio = 2, p = 7 --> 3NxNz = 3(2^{15})
blocksize = 3*2^6; % 15 - 3 = 12
L = genL(ks, ms, Rrho, Sc, tau, Nx, Nz);
%xf = IFRK(xIC, M, h, Nx, Nz, ks, ms, km, every, "RK3", Rrho, Sc, tau, L, workers, blocksize);
