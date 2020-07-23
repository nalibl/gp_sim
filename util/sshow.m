function [  ] = sshow( in,x,y,fignum )
%ASHOW Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    figure;imagesc(log(1+abs(fftshift(fft2(in)))));colorbar    
elseif nargin==3
    figure;imagesc(x,y,log(1+abs(fftshift(fft2(in)))));colorbar  
else
    figure(fignum);imagesc(log(1+abs(fftshift(fft2(in)))));colorbar  
end
end

