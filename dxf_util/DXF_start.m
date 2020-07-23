% DXF_start.m   Start DXF file
%
% [fid,err]=DXF_start(filename,unitscale)
%
% filename:  text string specifying the output file name - e.g. 'design.dxf'
% unitscale: a scale factor which is multiplied by every ;ength coordinate
%            E.g., if output is to be in inches and all coordinates are specified
%            in millimetres, set unitscale = 1/25.4
% fid:       file handle returned - must be used for all other DXF functions
% err:       set to -1 if file cannot be written
%
% Note:  This function uses the file 'DXFhead.dxf' to begin the DXF file and
%        the function DXF_end (which must be called to complete the DXF file) appends
%        'DXFtail.dxf'.  Therefore, these files, or copies, must be in the working
%        directory.  These files were obtained by creating a non-dimensioned simple 
%        profile with a CAD program (actually SolidEdge) and saving it as a DXF file.
%        'DXFhead.dxf' is all sections up to the 'entities' section containing the 
%        graphics objects.  'DXFtail.dxf' is the tail of the file after the entities.
%
%
function [fid,err]=DXF_start(filename,units)
global unitscale dxfhandle

unitscale=units;
err=0;
fid = fopen(filename,'wt');
[fid,msg] = fopen(filename,'wt');
if ( fid <= 0 | length(msg)>0 )
  if ( length(msg) > 0 )
    if ( strcmp(msg(1:5),'Sorry') == 1)
	    fprintf(1,'Output file %s may already be open (%s)\n',filename,msg);
		else
	    fprintf(1,'%s\n',msg);
		end
  end
  err=-1;
  return
end

%  Open header file to put on front of DXF file
fidh = fopen('DXFhead.dxf','rt');

%  read the file
clear D;
[D,count]=fread(fidh);
fclose(fidh);

%  D is a vector of character codes (as ASCII code values)
%  By looking at D you will notice 9's (tab characters) and 10's
%  (end of line characters).  Next we convert this into a string.

fwrite(fid,D);
clear D

fprintf(fid,'0\n');
fprintf(fid,'SECTION\n');
fprintf(fid,'2\n');
fprintf(fid,'ENTITIES\n');

dxfhandle=45;  %(2D hex)