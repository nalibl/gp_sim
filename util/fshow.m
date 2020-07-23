function [  ] = fshow( in,x,y,fignum )
%ASHOW Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    figure;imagesc(in);colorbar    
elseif nargin==3
    figure;imagesc(x,y,in);colorbar  
else
    figure(fignum);imagesc(in);colorbar  
end
end

