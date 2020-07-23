function [  ] = pshow( in,x,y,fignum )
%PSHOW Summary of this function goes here
%   Detailed explanation goes here
if nargin==1
    figure;imagesc(angle(in));colorbar    
elseif nargin==3
    figure;imagesc(x,y,angle(in));colorbar  
else
    figure(fignum);imagesc(angle(in));colorbar  
end
end

