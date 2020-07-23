function [ n_eig,theta ] = refraction_field( E_const , lambda )
%REFRACTION_FIELD Calculate the refractive indices of LiNbO3 crystal given the applied field.
%   Inputs:
%       E_const - the vector of the applied constant electric field, in V/m
%       units.
%       lambda - wavelength is microns.
%   Outputs:
%       n_eig - Matrix of the refractive indices along the principle axes.
%       theta - angle between new and old principle axes
%Written with accordance to Fundamentals of Photonics 2nd edition, p.
%180,851 and Nonlinear Optics 3rd edition, p. 517

%Sellmeier equations for LiNbO3
n_o = sqrt(2.392+2.5112*lambda^2/(lambda^2-0.217^2)+7.1333*lambda^2/(lambda^2-16.502^2));
n_e = sqrt(2.3247+2.2565*lambda^2/(lambda^2-0.21^2)+14.503*lambda^2/(lambda^2-25.915^2));
n_0 = [n_o,n_o,n_e];

r13=9.6e-12;%All coefficients are given in [m/V]
r22=6.8e-12;
r33=30.9e-12;
r51=32.6e-12;
R=[0,       -r22,       r13;
    0,       r22,        r13;
    0,       0,          r33;
    0,       r51,        0;
    r51,     0,          0;
    -r22,    0,          0];
d_n2_vec=R*E_const;
d_n2_mat=[  d_n2_vec(1),  d_n2_vec(6),    d_n2_vec(5);
            d_n2_vec(6),  d_n2_vec(2),    d_n2_vec(4);
            d_n2_vec(5),  d_n2_vec(4),    d_n2_vec(3)];

theta=0.5*atand(2*r51*E_const(2)/(n_o^(-2)-n_e^(-2)+r22*E_const(2)));
rot_mat = [1,0,0;0,cosd(theta),sind(theta);0,sind(-theta),cosd(theta)];
n2_mat=diag(n_0.^(-2));
n2_mat=n2_mat+d_n2_mat;
eig_mat = rot_mat * n2_mat * rot_mat';
n_eig=diag(eig_mat).^(-0.5);
% disp(['Angle between new and previous principle axes for Ey(degrees):',num2str(theta,10)]);
end