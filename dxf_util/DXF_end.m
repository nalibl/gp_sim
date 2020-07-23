%  DXF_end.m    finish DXF file
%
%  DXF_end(fid)
%
%  fid: file handle from DXF_start
%
function DXF_end(fid)

fprintf(fid,'0\n');
fprintf(fid,'ENDSEC\n');

%  Open trailer file to put on back of DXF file
fidt = fopen('DXFtail.dxf','rt');

%  read the file
clear D
[D,count]=fread(fidt);
fclose(fidt);

%  D is a vector of character codes (as ASCII code values)
%  By looking at D you will notice 9's (tab characters) and 10's
%  (end of line characters).  Next we convert this into a string.

fwrite(fid,D);
clear D

fclose(fid);