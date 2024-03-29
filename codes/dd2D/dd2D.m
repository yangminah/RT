h=5e-2;
N = 2^7; 
% By default, every variable is in Fourier space.
% x = [Psi T S], where Psi, T, S each are columns.
% This is the default shape of our variables.
% The linear solve requires x to be flattend via (i,j) index
%[Psi(1,1) T(1,1) S(1,1) ... Psi(Nx,1) T(Nx,1) S(Nx,1)
%... Psi(1,2) T(1,2) S(1,2) ... Psi(Nx,2) T(Nx,2) S(Nx,2)
%... Psi(1,Nz) T(1,Nz) S(1,Nz) ... Psi(Nx,Nz) T(Nx,Nz) S(Nx,Nz)]'
% i.e. boxPsi      = boxify(Psi, Nx, Nz) should yield the exact physical 
%      domain with top left as the origin. 
%      Psi         = vectorize(Psibox) puts it back into a vector.
%      longx       = flatten(x) so it's suitable for linear operator
%      [Psi, T, S] = boxify3NL(x) outputs the 3 variables
%      x = boxify3(longx) shapes it into the NxNz-by-3 shape.

%% Problem Parameters 
tau = 0.01;
Pr = 1; %water: 7
Ra = 1.1;
Sc = Pr/tau;
Rrho = 1/(Ra*tau); 
pp = struct('tau', tau, 'Pr', Pr, 'Ra', Ra, 'Sc', Sc, 'Rrho', Rrho);

%% Domain
a_ratio = 1;
Nx = N; Nz = a_ratio*N; NxNz = Nx*Nz;
k_o = ( .25*(-2-Ra + Ra*sqrt(1+8/Ra)) )^(.25);
l_o = 2*pi/k_o;
vars = {'tau','Pr','Ra','Sc','Rrho'}; clear(vars{:}); clear vars;
Lx = 32*l_o; Lz = a_ratio*Lx;
x = linspace(0, Lx, Nx+1); x=x(2:end);
z = linspace(0, Lz, Nz+1); z=z(2:end);
%[xx,zz] = meshgrid(x,z);
%zzz = reshape(zz', NxNz,1);

%% Discretization parameters
dx = Lx/Nx;
ks = (2*pi/Lx)*[0:Nx/2 -Nx/2+1:-1]';
ms = (2*pi/Lz)*[0:Nz/2 -Nz/2+1:-1]';
% Nx/2,Nz/2 are not zero since these are for setting up Laplacian.
[kkk,mm] = meshgrid(ks,ms);
km = kkk.^2 + mm.^2; km = reshape(km', NxNz, 1);
%We need the not-inflated wave numbers for computing the Energy.
%In NL.m, we'll get the new wave numbers for dealiasing, and save
%it as kk.

dp = struct('Nx', Nx, 'Nz', Nz, 'NxNz', NxNz, ...
	'ks', ks, 'ms', ms, 'km', km, 'kkk', kkk, 'mm', mm, ...
	'x',x,'z',z, ...
	'Lx', Lx, 'Lz', Lz, 'l_o',l_o);
vars = {'a_ratio', 'N', 'Nx', 'Nz', 'NxNz',...
'dx', 'ks', 'ms','kkk','mm','km',...%'x','z',...
'Lx','Lz'};
clear(vars{:});clear vars;

%% Initial Condition
%xIC = randn(dp.NxNz,3)/(3*dp.NxNz);
%zeros(NxNz,3); xIC(2,1)=1/(9*NxNz^2); 
%xIC = fft2(xIC);
%[Psi, T, S] = boxify3NL(xIC);
%Psibox = boxify(Psi, Nx, Nz);
