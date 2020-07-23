function [ out ] = IF2( in )
%IF2 Summary of this function goes here
%   Detailed explanation goes here
out=ifft2(ifftshift(ifftshift(in,1),2))*sqrt(size(in,1)*size(in,2));
end

