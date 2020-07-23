function [ out ] = prop( in,prop )
%PROP Summary of this function goes here
%   Detailed explanation goes here
[Nx,Ny]=size(in);
kx=linspace(-1/2,1/2,Nx);
ky=linspace(-1/2,1/2,Ny);
[Kx,Ky]=meshgrid(ky,kx);
[~,rho]=cart2pol(Kx,Ky);
prop_tranfer=exp(-1i*prop*sqrt(1-rho.^2));
out=IF2(prop_tranfer.*F2(in));
end

