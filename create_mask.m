function [ crystal_mask ] = create_mask( mask_size,thresh,type)
%CREATE_MASK Summary of this function goes here
%   Inputs:
%       mask_size - first dimension is propagation, second is transversial
%% 3 close designs
% shape_1_x=linspace(-1,1,floor(mask_size(2)/3));
% shape_1=2-2*shape_1_x.^2;
% shape_2_x=linspace(-1,1,floor(mask_size(2)*2/3)-ceil(mask_size(2)/3)+1);
% shape_2=1+shape_2_x;
% shape_3_x=linspace(-1,1,mask_size(2)-ceil(mask_size(2)*2/3)+1);
% shape_3=1-shape_3_x.^3;
% shape=[shape_1,shape_2,shape_3]/2;
% ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% crystal_mask=flipud(ref_mask<shape_rep);
%% 2 Seperated designs
% len_1=floor(mask_size(2)/2.1);
% len_3=len_1;
% len_2=mask_size(2)-2*len_1;
% shape_1_x=linspace(-1,1,len_1);
% shape_1=2-2*shape_1_x.^2;
% shape_2_x=linspace(-1,1,len_2);
% shape_2=0*shape_2_x;
% shape_3_x=linspace(-1,1,len_3);
% shape_3=1+shape_3_x;
% shape=[shape_1,shape_2,shape_3]/2;
% ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% crystal_mask=flipud(ref_mask<shape_rep);
%% 2 Seperated designs, gaps on edges and middle
% len_1=floor(mask_size(2)/3);
% len_gap=round((mask_size(2)-2*len_1)/3);
% len_2=mask_size(2)-len_1-3*len_gap;
% shape_1_x=linspace(-1,1,len_1);
% shape_1=2*sqrt(1-shape_1_x.^2);
% shape_2_x=linspace(-1,1,len_2);
% shape_2=1+shape_2_x;
% shape_gap=zeros(1,len_gap);
% shape_fill=2*ones(1,len_gap);
% shape=[shape_gap,shape_1,shape_gap,shape_2,shape_fill]/2;
% ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% crystal_mask=flipud(ref_mask<=shape_rep);
%% 3 Seperated designs, gaps on edges and middle
% len_1=floor(mask_size(2)/4);
% len_gap=round((mask_size(2)-3*len_1)/4);
% len_2=len_1;
% len_3=mask_size(2)-2*len_1-4*len_gap;
% shape_1_x=linspace(-1,1,len_1);
% shape_1=2*sqrt(1-shape_1_x.^2);
% shape_2_x=linspace(-1,1,len_2);
% shape_2=1+shape_2_x;
% shape_3=2*ones(1,len_3)*2/5; % HG
% shape_3(round(end/2):end)=0;
% shape_gap=zeros(1,len_gap);
% shape_fill=2*ones(1,len_gap);
% % shape=[shape_gap,shape_1,shape_gap,shape_2,shape_fill,shape_3,shape_gap]/2;
% shape=[shape_1,shape_gap,shape_gap,shape_3,shape_gap,shape_2,shape_fill]/2;
% ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% crystal_mask=flipud(ref_mask<shape_rep);
%% 3 Seperated designs, gaps on edges and middle
% len_1=floor(mask_size(2)/3);
% len_gap=round((mask_size(2)-2*len_1)/6);
% shape_1_x=linspace(-1,1,len_1);
% shape_1=2*sqrt(1-shape_1_x.^2);
% shape_3_x=linspace(-1,1,len_1);
% shape_3=1+shape_3_x;
% shape_gap=zeros(1,len_gap);
% shape_2=2*ones(1,mask_size(2)-2*len_1-2*len_gap)*2/5; % HG
% shape_2(round(end/2):end)=0;
% shape=[shape_1,shape_gap,shape_2,shape_gap,shape_3]/2;
% ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% crystal_mask=flipud(ref_mask<=shape_rep);
%% 2 Seperated designs, gaps on edges and middle - new
% len_1=floor(mask_size(2)*2/7);
% len_gap=round((mask_size(2)-2*len_1)/3);
% len_2=mask_size(2)-len_1-3*len_gap;
% shape_1_x=linspace(-1,1,len_1);
% shape_1=2*sqrt(1-shape_1_x.^2);
% shape_2_x=linspace(-1,1,len_2);
% shape_2=1+shape_2_x;
% shape_gap=zeros(1,len_gap);
% shape=[shape_gap,shape_1,shape_gap,shape_2,shape_gap]/2;
% % Filter sub-threshold regions
% ref_mask_1=repmat((1:mask_size(1))',[1,length(shape_1)]);%grid for shape_1
% shape_rep_1=mask_size(1)*repmat(0.5*shape_1,[mask_size(1),1]);%threshold for shape_1
% mask_1=(ref_mask_1<=shape_rep_1);%2D shape_1
% mask_1=[mask_1(:,1:(round(end/2)-1)),mask_1(:,round(end/2)),mask_1(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
% mask_1(sum(mask_1,2)<(thresh+1),:)=false;%cut sub-threshold features
% ref_mask_2=repmat((1:mask_size(1))',[1,length(shape_2)]);
% shape_rep_2=mask_size(1)*repmat(0.5*shape_2,[mask_size(1),1]);
% mask_2=(ref_mask_2<=shape_rep_2);
% mask_2=[mask_2(:,1:(round(end/2)-1)),mask_2(:,round(end/2)),mask_2(:,round(end/2):end)];
% mask_2(sum(mask_2,2)<(thresh+1),:)=false;
% mask_gap=false(mask_size(1),len_gap);
% crystal_mask=flipud([mask_gap,mask_1,mask_gap(:,1:end-2),mask_2,mask_gap]);
% % ref_mask=repmat((1:mask_size(1))',[1,mask_size(2)]);
% % shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);
% % crystal_mask=flipud(ref_mask<=shape_rep);
% %% 13//6/19 Only deflector mask
% shape=linspace(0,1,mask_size(2));
% % Filter sub-threshold regions
% ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
% shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
% mask=(ref_mask<=shape_rep);%2D shape_1
% % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
% mask(sum(mask,2)<(thresh+1),:)=false;%cut sub-threshold features
% crystal_mask=flipud(mask);
% if 0
% %% 13//6/19 Only lens mask
%     shape_x=linspace(-1,1,mask_size(2));
%     shape=sqrt(1-shape_x.^2);
%     % Filter sub-threshold regions
%     ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
%     shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
%     mask=(ref_mask<=shape_rep);%2D shape_1
%     % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
%     mask(sum(mask,2)<(thresh+1),:)=false;%cut sub-threshold features
%     crystal_mask=flipud(mask);
% elseif 0
% %% 13//6/19 Only deflector mask
%     shape=linspace(0,1,mask_size(2));
%     % Filter sub-threshold regions
%     ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
%     shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
%     mask=(ref_mask<=shape_rep);%2D shape_1
%     % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
%     mask(sum(mask,2)<(thresh+1),:)=[];%cut sub-threshold features
%     crystal_mask=flipud(mask);
% elseif 0
%     crystal_mask=true(mask_size);
%     crystal_mask(:,1:round(end/2))=false;
if isequal(type,'len')
%% 15/8/19 Only lens with truncated regions
    rel_thresh=1-thresh/mask_size(2)*2;
    shape_x=linspace(-1,1,mask_size(2))/rel_thresh;
    shape=sqrt(1-shape_x.^2);
    % Filter sub-threshold regions
    ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
    shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
    mask=(ref_mask<=shape_rep);%2D shape_1
    % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
    mask(sum(mask,2)<(thresh+1),:)=[];%cut sub-threshold features
%     mask((sum(~mask,2)/2)<(thresh+1),:)=[];%divide by 2 due to symmetry
    crystal_mask=flipud(mask);
% elseif 0
% %% 16/8/19 Only deflector mask
%     rel_thresh=1-thresh/mask_size(2);
%     shape=linspace(-1+rel_thresh,rel_thresh,mask_size(2));
%     % Filter sub-threshold regions
%     ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
%     shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
%     mask=(ref_mask<=shape_rep);%2D shape_1
%     % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
%     mask(sum(mask,2)<(thresh+1),:)=[];%cut sub-threshold features
%     crystal_mask=flipud(mask);
else
%% 31/10/19 Only deflector mask, try predefined length
    shape=linspace(0,1,mask_size(2)-2*thresh);
    % Filter sub-threshold regions
    ref_mask=repmat((1:mask_size(1))',[1,length(shape)]);%grid for shape_1
    shape_rep=mask_size(1)*repmat(shape,[mask_size(1),1]);%threshold for shape_1
    mask=(ref_mask<=shape_rep);%2D shape_1
    % mask=[mask(:,1:(round(end/2)-1)),mask(:,round(end/2)),mask(:,round(end/2):end)];%pad middle pixel, cut in BW boundaries
    crystal_mask=flipud(mask);
    crystal_mask=[false([size(crystal_mask,1),thresh]),crystal_mask,true([size(crystal_mask,1),thresh])];
    crystal_mask=crystal_mask(2:end-1,:);%DEBUG - match length of lens
end
end