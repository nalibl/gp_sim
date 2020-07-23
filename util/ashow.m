function [  ] = ashow( in,x,y,fignum )
%ASHOW Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    figure;imagesc(abs(in));colorbar    
elseif nargin==3
    figure;imagesc(x,y,abs(in));colorbar  
else
    figure(fignum);imagesc(abs(in));colorbar  
end
end

