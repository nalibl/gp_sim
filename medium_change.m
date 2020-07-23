function [ co_E,y ] = medium_change(E,n,f,s_polarization)
%MEDIUM_CHANGE Summary of this function goes here
%   Detailed explanation goes here
co_freq=max(f)/n; % Find cut-off frequency for birefringent medium
co_lim=abs(f)<co_freq; % Get the indices of the angles below the CO
F_E=fftshift(fft(E)); % FFT of signal at end of crystal, inside
F_E=F_E(co_lim); % Truncate CO frequencies
co_f=f(co_lim)/max(abs(f(co_lim)))*max(abs(f)); % Renormalize to new frequencies
co_f_n=co_f/max(abs(co_f)); % Sine of angle, normalized frequency
if s_polarization % Reflection coefficient for each plane wave
    t_s=2*sqrt(1-co_f_n.^2)./(sqrt(1-co_f_n.^2)+n*sqrt(1-(co_f_n/n).^2));
    F_E=F_E.*t_s;
else
    t_p=2*sqrt(1-co_f_n.^2)./(n*sqrt(1-co_f_n.^2)+sqrt(1-(co_f_n/n).^2));
    F_E=F_E.*t_p;
end
co_E=ifft(ifftshift(F_E));
% co_E=co_E*mean(abs(E).^2)/mean(abs(co_E).^2); % Power conservation
df=co_f(2)-co_f(1);
L=1/df;
dx=1/(co_f(end)-co_f(1));
y=-L/2:dx:L/2;
y=interp1(y,linspace(1,length(y),length(co_E)));
end

