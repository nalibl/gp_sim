function [err] = gp_element_sim(E_y)
%Periodically poled LiNbO3
addpath('.\util')
addpath('.\dxf_util')
ShowPlots=true;
dxf_out=false;
type = 'def';
%% All units are in um
% Constants
c       = (2.99792458e8)*(1e6);%in um/sec 
lambda  = 1.0642;

% Crystal geometry, in um. The real crystal axes are: [x,y,z] (sim)=>[y,z,x] (crystal)
L_x=12e3; % Re-calculated later, small difference
L_y=1e3;

L_z=0.5e3;
% Simulation grid
dy=0.5;
dy_thresh=50;%in microns
dy_thresh_pix=dy_thresh/dy;% in pixels
y=-L_y/2:dy:L_y/2-dy;% Tranversial coordiantes
ny=length(y);

% Applied field, birefringence and main axes
% E_y = V_app/L_y*(1e6); % in kV/m
E_DC = [0;E_y;0]; % input field in V/m, positive poling
% No Field applied
[ n ,~ ] = refraction_field( E_DC*0 , lambda );
n_o=n(2);
n_e=n(3);
beta = 2*pi*(n_e-n_o)/lambda; % Birefringence coefficient for positive domain
% Positive domain
[ n_eig_pos,theta_pos ] = refraction_field( E_DC , lambda );
n_o_pos=n_eig_pos(2);
n_e_pos=n_eig_pos(3);
% Negative domain
[ n_eig_neg,theta_neg ] = refraction_field( -E_DC , lambda );
n_o_neg=n_eig_neg(2);
n_e_neg=n_eig_neg(3);
% Note - beta * dz << 1
% Recalculate so that length of crystal is an integer amount of wavelengths
L_FW=abs(2*pi/beta); % Find the positive domain FW length
L_HW =L_FW/2; % Length of half waveplate
L_x=round(L_x/L_FW)*L_FW; % Corrected length of crystal to accomodate an integer amount of wavelengths
n_FW=round(L_x/L_FW); % Number of whole waveplates making up the length of the crystal
disp(['Maximal relative phase gained in propagation: ',num2str(abs(deg2rad(theta_pos-theta_neg)*2*n_FW))])
%% Create  mask
mask_size=[n_FW ny];
crystal_mask=~create_mask(mask_size,dy_thresh_pix,type);
% Insert gap by request of HCP
needed_gap = 20/2;
gap_dy = ceil(needed_gap/dy);
crystal_mask = int8(padarray(crystal_mask,[0,2*gap_dy],1));
gap_mask = circshift(crystal_mask, [0,gap_dy]) - circshift(crystal_mask, [0,-gap_dy]);
crystal_mask(gap_mask~=0) = -1;
% Fix wrong area in deflector
if isequal(type,'def')
    crystal_mask(:,1960:end) = 0; 
end

ny=size(crystal_mask,2);
L_y = ny*dy;
y=-L_y/2:dy:L_y/2-dy;% Tranversial coordiantes
% gap_mask = padarray(crystal_mask,[2,0],1,'pre') - padarray(crystal_mask,[2,0],1,'post');
% crystal_mask = int8(padarray(crystal_mask,[2,0],1,'pre'));
% crystal_mask(gap_mask==1) = -1;

n_FW=size(crystal_mask,1);
L_x=n_FW*L_FW;
if ShowPlots
    fshow(crystal_mask,y,L_FW*1e-3*(1:n_FW));title('Crystal mask profile');xlabel('y [\mum]');ylabel('x [mm]')
end
%% Spatial frequency
fy=-0.5/dy:1/L_y:0.5/dy-1/L_y;
%% Input Gaussian
input_phase = exp(-0*1i*2*pi*lambda*0.4*real(sqrt((1/lambda^2-fy.^2))));
Ex_0=y.^0; %input_phase.*exp(-(y/L_y).^2)/sqrt(2);
pol_angle = tan(0);
pol_phase = exp(1i*pi/2);
Ey_0=Ex_0*pol_angle*pol_phase;
[Ex,Ey]=rot_2d(Ex_0,Ey_0,theta_pos);% Postive domain is default
Ex=repmat(Ex,[n_FW,1]);
Ey=repmat(Ey,[n_FW,1]);
%% Propagation utilities
% Shifted TF for efficiency
TF_pos_o=ifftshift(exp(-1i*2*pi*L_HW*n_o_pos*real(sqrt((1/lambda^2-fy.^2)))));
TF_pos_e=ifftshift(exp(-1i*2*pi*L_HW*n_e_pos*real(sqrt((1/lambda^2-fy.^2)))));
TF_neg_o=ifftshift(exp(-1i*2*pi*L_HW*n_o_neg*real(sqrt((1/lambda^2-fy.^2)))));
TF_neg_e=ifftshift(exp(-1i*2*pi*L_HW*n_e_neg*real(sqrt((1/lambda^2-fy.^2)))));

% TF_pos_o=ifftshift(exp(-1i*pi*L_HW*n_o_pos*lambda*fy.^2));
% TF_pos_e=ifftshift(exp(-1i*pi*L_HW*n_e_pos*lambda*fy.^2));
% TF_neg_o=ifftshift(exp(-1i*pi*L_HW*n_o_neg*lambda*fy.^2));
% TF_neg_e=ifftshift(exp(-1i*pi*L_HW*n_e_neg*lambda*fy.^2));

prop_pos_o=@(In) ifft(TF_pos_o.*fft(In));
prop_pos_e=@(In) ifft(TF_pos_e.*fft(In));
prop_neg_o=@(In) ifft(TF_neg_o.*fft(In));
prop_neg_e=@(In) ifft(TF_neg_e.*fft(In));
%% Whole domain propagation
% Define first domain as positive
% Define x axes as ordinary
err=zeros(size(crystal_mask,3),1);
for pidx=1:size(crystal_mask,3)
    for cidx=1:(n_FW-1)
        poling_mask=crystal_mask(cidx,:,pidx);%mask along x axis
        % Principle domain - first positive domain then negative
        % Positive domain propagation along principle axes
        Ex_pos_n=prop_pos_o(Ex(cidx,:));
        Ey_pos_n=prop_pos_e(Ey(cidx,:));
        % Negative domain
        [Ex_neg,Ey_neg]=rot_2d(Ex_pos_n,Ey_pos_n,theta_neg-theta_pos);% Angle rotates from positive to negative
        % Propagate through negative domain to positive domain
        Ex_neg_n=prop_neg_o(Ex_neg);
        Ey_neg_n=prop_neg_e(Ey_neg);    
        [Ex(cidx+1,:),Ey(cidx+1,:)]=rot_2d(Ex_neg_n,Ey_neg_n,theta_pos-theta_neg);
        % Conjugated domain - first negative then positive
        [Ex_neg,Ey_neg]=rot_2d(Ex(cidx,:),Ey(cidx,:),theta_neg-theta_pos);
        Ex_neg_n=prop_neg_o(Ex_neg);
        Ey_neg_n=prop_neg_e(Ey_neg);
        [Ex_pos_n,Ey_pos_n]=rot_2d(Ex_neg_n,Ey_neg_n,theta_pos-theta_neg);
        Ex_pos_nn=prop_pos_o(Ex_pos_n);
        Ey_pos_nn=prop_pos_e(Ey_pos_n);
        % Twice positive - gap domain between to gratings according to HCP
        Ex_t_pos_nn=prop_pos_o(prop_pos_o(Ex(cidx,:)));
        Ey_t_pos_nn=prop_pos_e(prop_pos_e(Ey(cidx,:)));
        % Seperate to different regions
        Ex(cidx+1,poling_mask==1)=Ex_pos_nn(poling_mask==1);
        Ey(cidx+1,poling_mask==1)=Ey_pos_nn(poling_mask==1);        
        Ex(cidx+1,poling_mask==-1)=Ex_t_pos_nn(poling_mask==-1);
        Ey(cidx+1,poling_mask==-1)=Ey_t_pos_nn(poling_mask==-1);
        %EL=(Ex(cidx+1,:)-1i*Ey(cidx+1,:))/sqrt(2);
    end
    [Ex,Ey]=rot_2d(Ex,Ey,-theta_pos);
    %% Post process - find phase profile
    % TODO - check if another step is necessary to shift from crystal to air
    EL=(Ex-1i*Ey)/sqrt(2);
    if ShowPlots
        ashow(abs(EL).^2,y,L_FW*1e-3*(1:n_FW));title('LCP propagation inside crystal');xlabel('y [\mum]');ylabel('x [mm]')
        figure;plot(y,abs(EL(end,:).^2));title('LCP intensity at crystal output');xlabel('y [\mum]');ylabel('Intensity')
    end
    angle_EL=unwrap(angle(EL(end,:)));
%% Change of medium 
[ Ex_o,o_yaxis_new ] = medium_change(Ex(end,:),n_o,fy,false);
[ Ey_o,e_yaxis_new ] = medium_change(Ey(end,:),n_e,fy,true);
if length(o_yaxis_new)<length(e_yaxis_new)
    Ey_o=interp1(e_yaxis_new,Ey_o,o_yaxis_new);
    y_new=o_yaxis_new;
else
    Ex_o=interp1(o_yaxis_new,Ex_o,e_yaxis_new);
    y_new=e_yaxis_new;
end
EL_o=(Ex_o-1i*Ey_o)/sqrt(2);
angle_EL_o=unwrap(angle(EL_o));
if ShowPlots
    figure;plot(y_new,abs(EL_o).^2);title('LCP intensity outside crystal');xlabel('y [\mum]');ylabel('Intensity')
    figure;plot(y_new,angle_EL_o);title('LCP angle outside crystal');xlabel('y [\mum]');ylabel('Radians')
end
%% Propagate to focal plane
EL_o=padarray(EL_o,[0,length(EL_o)]);
dy_new=y_new(2)-y_new(1);
L_new=length(EL_o)*dy_new;
fy_fs=-0.5/dy_new:1/L_new:0.5/dy_new-1/L_new;
TF_fs=ifftshift(exp(-1i*2*pi*real(sqrt((1/lambda^2-fy_fs.^2)))));
% TF_fs=ifftshift(exp(1i*pi*lambda*fy_fs.^2));
prop_fs=@(In,z) ifft((TF_fs.^z).*fft(In));
sqr_fac=polyfit(y_new,angle_EL_o,2);f_dist=pi/(lambda*sqr_fac(1));
I_f=abs(prop_fs(EL_o,f_dist)).^2;
%% Propagate
delta_z=300;% In microns
prop_size=600; % Cycles to run outside crystal
% EL_op=repmat(padarray(EL_o,[0,size(EL_o,2)]),[prop_size,1]);
% Lens at exit
% EL_op0=EL_o.*exp(-1i*40*linspace(-1,1,length(EL_o)).^2);
EL_op0=EL_o;
EL_op=repmat(EL_op0,[prop_size,1]);
% EL_op1=repmat([EL_op0(1:floor(end/2)),zeros(1,length(EL_op0(ceil(end/2):end)))],[prop_size,1]);
% EL_op2=repmat([zeros(1,length(EL_op0(1:floor(end/2)))),EL_op0(ceil(end/2):end)],[prop_size,1]);
for idx=1:prop_size-1
%     EL_op(idx,:)=prop_fs(EL_op(1,:),delta_z*idx);
%     EL_op1(idx,:)=prop_fs(EL_op1(1,:),delta_z*idx);
%     EL_op2(idx,:)=prop_fs(EL_op2(1,:),delta_z*idx);
%     EL_op(idx,round(end/2)-50:round(end/2)+50)=0;
    EL_op(idx+1,:)=prop_fs(EL_op(idx,:),delta_z);
%     EL_op(idx+1,round(end/2)-30:round(end/2)+30)=0;
end
% EL_op=[EL_op1(:,1:floor(end/2)),EL_op2(:,ceil(end/2):end)];
if ShowPlots
    ashow(abs(EL_op).^2,y_new,prop_size*1e-3*(1:prop_size));title('LCP propagation outside crystal');xlabel('y [\mum]');ylabel('x [mm]')
%     figure;plot(abs(EL_op(200,round(5373*0.2):round(5373*0.8))).^2);
end
%     figure;plot(y,unwrap(angle(Ex(end,:))),y,unwrap(angle(Ey(end,:))));
%     ashow(abs(Ex).^2);
%% Output DXF file
if dxf_out
    file_name = ['D:\NON-backup\PPLN_mask_' type '_s'];
    dxf_mask_out( crystal_mask ,file_name,L_HW,L_y,L_x,dy);
end
end