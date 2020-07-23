function [ Ex_out,Ey_out ] = rot_2d( Ex,Ey,theta )
    Ex_out=Ex*cosd(theta)+Ey*sind(theta);
    Ey_out=Ey*cosd(theta)-Ex*sind(theta);
end

