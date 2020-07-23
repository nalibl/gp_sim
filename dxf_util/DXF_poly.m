% DXF_poly.m
%
% DXF_poly(fid,x,y,n,linecolour,linetype)
%
% Polyline: a sequence of straight line segments
%
% fid: file handle from DXF_start
% x,y: vectors of vertex point coordinates
% n:   number of vertex points
% linecolour, linetype: see DXF_line
%

function DXF_poly(fid,x,y,n,linecolour,linetype)
global unitscale

fprintf(fid,'0\n');
fprintf(fid,'LWPOLYLINE\n');
DXF_pinc(fid);
fprintf(fid,'100\n');
fprintf(fid,'AcDbEntity\n');
fprintf(fid,'8\n');  % layer
fprintf(fid,'DEFAULT\n');  % 0
DXF_lint(fid,linetype);
fprintf(fid,'62\n');
fprintf(fid,'%d\n',linecolour);
fprintf(fid,'100\n');
fprintf(fid,'AcDbPolyline\n');
fprintf(fid,'90\n');  % no. of points
fprintf(fid,'%d\n',n);  % 

for i=1:n
  
  fprintf(fid,'10\n');  % x coord code
  fprintf(fid,'%14.8f\n',x(i)*unitscale);
  fprintf(fid,'20\n');  % y coord code
  fprintf(fid,'%14.8f\n',y(i)*unitscale);  % 0
  fprintf(fid,'30\n');  % z coord code
  fprintf(fid,'0.0\n'); 

end