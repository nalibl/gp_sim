function [ out ] = F2( in )
%FT Summary of this function goes here
%   Detailed explanation goes here
out=fftshift(fftshift(fft2(in),1),2)/sqrt(size(in,1)*size(in,2));
end

