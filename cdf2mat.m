function cdf2mat(cdffile,matfile)
% wrapper function for cdfread_rmp
% save the results to the matfilea
if ~exist(matfile,'file')
	out = cdfread_rmp(cdffile);
	save(matfile,'out','-v7.3');
else
	load(matfile);
end;

function out=cdfread_rmp(filename)
%uses netcdf to read a CDF file but parses only the parts important for visualization.
disp('cdfread_rmp');
x=netcdf_rmp(filename);
varstr=cat(1,{x.VarArray.Str});
for i=1:length(varstr) varstr{i} = cleanstr(varstr{i}); end;
attstr=cat(1,{x.AttArray.Str});
for i=1:length(attstr) attstr{i} = cleanstr(attstr{i}); end;


% start and stop times
disp('start and stop times');
idx=find(strcmp('scan_acquisition_time',varstr));
d=x.VarArray(idx).Data;
out.mzXML.msRun.startTime=d(1)/60;
out.mzXML.msRun.endTime=d(end)/60;
out.scan.retentionTime = d;

% number of scans
disp('number of scans');
try
	idx=find(strcmp('number_of_scans',attstr));
	out.mzXML.msRun.scanCount=double(x.AttArray(idx).Val)
catch
	idx=find(strcmp('total_intensity',varstr));
	out.mzXML.msRun.scanCount=double(length(x.VarArray(idx).Data));
end;

% parent file
disp('parent');
idx=find(strcmp('source_file_reference',attstr));
out.mzXML.msRun.parentFile.fileName=x.AttArray(idx).Val;

% instrument manufacturer
disp('manufacturer');
idx=find(strcmp('instrument_mfr',varstr));
d=x.VarArray(idx).Data;
try,d=cleanstr(d);catch;end;
out.mzXML.msRun.msInstrument.msManufacturer=d;

% instrument model
disp('instrument');
idx=find(strcmp('instrument_name',varstr));
d=x.VarArray(idx).Data;
try;d=cleanstr(d);catch;end;
out.mzXML.msRun.msInstrument.msModel=d;

% software version
disp('software');
idx=find(strcmp('instrument_sw_version',varstr));
d=x.VarArray(idx).Data;
try;d=cleanstr(d);catch;end;
out.mzXML.msRun.msInstrument.software.version=d;

% mass range min
disp('mass min');
idx=find(strcmp('mass_range_min',varstr));
d=x.VarArray(idx).Data;
if std(d)==0, d=d(1); end;
out.scan.lowMz = d;

% mass range max
disp('mass max');
idx=find(strcmp('mass_range_max',varstr));
d=x.VarArray(idx).Data;
if std(d)==0, d=d(1); end;
out.scan.highMz = d;

% peaks count
disp('peaks count');
idx=find(strcmp('point_count',varstr));
d=x.VarArray(idx).Data;
if all(d==d(1)), d=d(1); end;
out.scan.peaksCount = d;

% total ion current
disp('total ion current');
idx=find(strcmp('total_intensity',varstr));
d=x.VarArray(idx).Data;
if all(d==d(1)), d=d(1); end;
out.scan.totIonCurrent = d;

% mass values
disp('mass values');
idx=find(strcmp('mass_values',varstr));
d=x.VarArray(idx).Data;
if numel(out.scan.peaksCount)==1,
    % check that m/z are the same for every scan
    d=reshape(d,[out.scan.peaksCount out.mzXML.msRun.scanCount]);
    % approximate the median
    d2=d(:,ceil(rand(1,20)*out.mzXML.msRun.scanCount));
    m=median(d2,2);
    clear d2;
    if all(all(abs(bsxfun(@minus,d,m)<1e-2))) % all have the same mz vector
        d=m;
    else
        d=reshape(d,[out.scan.peaksCount*out.mzXML.msRun.scanCount 1]);
    end;
end;
if numel(d)>out.scan.peaksCount(1),
    c=cell(out.mzXML.msRun.scanCount,1);
    prevCount=0;
    for i=1:out.mzXML.msRun.scanCount,
        c{i}=d((1:out.scan.peaksCount(i))+prevCount);
        prevCount = prevCount+out.scan.peaksCount(i);
    end;
    d=c;
    clear c;
end;
out.scan.mz=d;

% intensity values
idx=find(strcmp('intensity_values',varstr));
d=x.VarArray(idx).Data;
dlen = length(d);
% if size(out.scan.mz,2)>1, 
if numel(out.scan.peaksCount)==1 && numel(d)>out.scan.peaksCount, 
    d=reshape(d,[out.scan.peaksCount out.mzXML.msRun.scanCount]);
    [peakIntensity, pidx]=max(d);
    peakMz=out.scan.mz(pidx);
else
    c=cell(out.mzXML.msRun.scanCount,1);
    prevCount=0;
    for i=1:out.mzXML.msRun.scanCount,
	if out.scan.peaksCount(i)+prevCount > dlen,
		error('CDF file specifies more peaks than are listed in the data');
	end;
        c{i}=d((1:out.scan.peaksCount(i))+prevCount);
        [mx,ix]=max(d((1:out.scan.peaksCount(i))+prevCount));
        if ~isempty(mx)
            peakIntensity(i)=mx;
            peakMz(i)=out.scan.mz{i}(ix);
        else
            peakIntensity(i)=0;
            peakMz(i)=0;
        end;
        prevCount = prevCount+out.scan.peaksCount(i);
    end;
    d=c;
    clear c;    
end;
out.scan.intensity=d;
out.scan.basePeakMz=peakMz;
out.scan.basePeakIntensity=peakIntensity;

% polarity
disp('polarity');
idx=find(strcmp('test_ionization_polarity',attstr));
d=x.AttArray(idx).Val;
d=cleanstr(d);
out.scan.polarity = d;


function str=cleanstr(str)
% get rid of leading underscores and prepend an 'a' if it starts with a numerical digit.
str=strrep(str,char(0),'');
while numel(str)>0 && str(1)=='_', str(1)=[]; end;
if numel(str)==0, return; end;
if int16(str(1)) >= int16('0') && int16(str(1)) <= int16('9')
    str=['a' str];
end;
return;
function S = netcdf_rmp(File)
% based on NetCDF reader by Paul Spencer: 
% http://www.mathworks.com/matlabcentral/fileexchange/15177
%
% updated to only read the parts needed (see "rmp:" in comments).
%
%
%
% Function to read NetCDF files
%   S = netcdf(File)
% Input Arguments
%   File = NetCDF file to read
% Output Arguments:
%   S    = Structure of NetCDF data organised as per NetCDF definition
% Notes:
%   Only version 1, classic 32bit, NetCDF files are supported. By default
% data are extracted into the S.VarArray().Data field for all variables.
%
% SEE ALSO
% ---------------------------------------------------------------------------
S = [];

try
    if exist(File,'file') fp = fopen(File,'r','b');
    else fp = []; error('File not found'); end
    if fp == -1   error('Unable to open file'); end

    % Read header
    Magic = fread(fp,4,'uint8=>char');
    if strcmp(Magic(1:3),'CDF') error('Not a NetCDF file'); end
    if uint8(Magic(4))~=1       error('Version not supported'); end
    S.NumRecs  = fread(fp,1,'uint32=>uint32');
    S.DimArray = DimArray(fp);
    S.AttArray = AttArray(fp);
    S.VarArray = VarArray(fp);

    % Read non-record variables
    Dim = double(cat(2,S.DimArray.Dim));
    ID  = double(cat(2,S.VarArray.Type));

    for i = 1:length(S.VarArray)
        D = Dim(S.VarArray(i).DimID+1); N = prod(D); RecID{i}=find(D==0);
        if isempty(RecID{i})
            if isempty(D) D = [1,1]; N = 1; elseif length(D)==1 D=[D,1]; end
            S.VarArray(i).Data = ReOrder(fread(fp,N,[Type(ID(i)),'=>',Type(ID(i))]),D);
            fread(fp,(Pad(N,ID(i))-N)*Size(ID(i)),'uint8=>uint8'); %rmp: skip past the padding
        else S.VarArray(i).Data = []; end
    end

    % RMP: RecID is empty for non-record variables and non-empty for records
    % D==0 means that dimension is growing with the number of records.
    bytesPerRecord=0;
    for i=1:length(S.VarArray)
        if ~isempty(RecID{i}),
            D = Dim(S.VarArray(i).DimID+1); % get dimensions of each variable
            D(RecID{i}) = 1;  % since '0' codes for a growing dimension, set to 1 to start.
            N = prod(D); % number of elements in one variable
            if length(D)==1 D=[D,1]; end
            bytesPerRecord = bytesPerRecord + N*(Size(ID(i))+(Pad(N,ID(i))-N)*Size(ID(i)));
        end;
    end;
    data = fread(fp,bytesPerRecord*double(S.NumRecs),'uint8=>uint8');
    fclose(fp);
    data = reshape(data,[bytesPerRecord S.NumRecs]);

    % Read record variables
    prevBytes=0;
    for i = 1:length(S.VarArray)
        if ~isempty(RecID{i})
            catID=RecID{i};
            D = Dim(S.VarArray(i).DimID+1);
            D(catID) = 1; % D = dimension of one variable
            N = prod(D); % number of elements in one variable
            if length(D)==1 D=[D,1]; end
            sz=Size(ID(i));
            Pad=(Pad(N,ID(i))-N)*sz;
            bytesPerVar = N*(sz+Pad);
            a = data((1:bytesPerVar)+prevBytes,:);  % a = (nbytes x nvariables)
            prevBytes=prevBytes+bytesPerVar; % account for bytes in 'data' already visited.
            a=a(end:-1:1,:);
            switch ID(i)
                case 1 % int8
                    a=typecast(a(:),'int8');
                case 2 % char
                    a=typecast(a(:),'char');
                case 3 % int16
                    a=typecast(a(:),'int16');
                case 4 % int32
                    a=typecast(a(:),'int32');
                case 5 
                    a=typecast(a(:),'single');
                case 6
                    a=typecast(a(:),'double');
                otherwise
                    a=[];
            end;
            a=reshape(a,[fliplr(D) S.NumRecs]); % a = dim3 x dim2 x dim1 x numRecs
            ndims=length(D);
            a=permute(a,[fliplr(1:ndims) ndims+1]); % a = dim1 x dim2 x dim3 x numRecs
            a=permute(a,[1:catID ndims+1 catID+1:ndims]); % a = dim1 x dim2 x numRecs x dim3
            a=reshape(a,[D(1:catID-1) D(catID)*S.NumRecs D(catID+1:end)]); % a = dim1 x dim2*numRecs x dim3
            S.VarArray(i).Data=a;
        end
    end
catch
    Err = lasterror; fprintf('%s\n',Err.message);
    if ~isempty(fp) && fp ~= -1 fclose(fp); end
end

% ---------------------------------------------------------------------------------------
% Utility functions

function S = Size(ID)
% Size of NetCDF data type, ID, in bytes
S = subsref([1,1,2,4,4,8],struct('type','()','subs',{{ID}}));

function T = Type(ID)
% Matlab string for CDF data type, ID
T = subsref({'int8','char','int16','int32','single','double'},...
    struct('type','{}','subs',{{ID}}));

function N = Pad(Num,ID)
% Number of elements to read after padding to 4 bytes for type ID
N = (double(Num) + mod(4-double(Num)*Size(ID),4)/Size(ID)).*(Num~=0);

function S = String(fp)
% Read a CDF string; Size,[String,[Padding]]
S = fread(fp,Pad(fread(fp,1,'uint32=>uint32'),1),'uint8=>char').';

function A = ReOrder(A,S)
% Rearrange CDF array A to size S with matlab ordering
A = permute(reshape(A,fliplr(S)),fliplr(1:length(S)));

function S = DimArray(fp)
% Read DimArray into structure
if fread(fp,1,'uint32=>uint32') == 10 % NC_DIMENSION
    for i = 1:fread(fp,1,'uint32=>uint32')
        S(i).Str = String(fp);
        S(i).Dim = fread(fp,1,'uint32=>uint32');
    end
else fread(fp,1,'uint32=>uint32'); S = []; end

function S = AttArray(fp)
% Read AttArray into structure
if fread(fp,1,'uint32=>uint32') == 12 % NC_ATTRIBUTE
    for i = 1:fread(fp,1,'uint32=>uint32')
        S(i).Str = String(fp);
        ID       = fread(fp,1,'uint32=>uint32');
        Num      = fread(fp,1,'uint32=>uint32');
        S(i).Val = fread(fp,Pad(Num,ID),[Type(ID),'=>',Type(ID)]).';
    end
else fread(fp,1,'uint32=>uint32'); S = []; end

function S = VarArray(fp)
% Read VarArray into structure
if fread(fp,1,'uint32=>uint32') == 11 % NC_VARIABLE
    for i = 1:fread(fp,1,'uint32=>uint32')
        S(i).Str      = String(fp);
        Num           = double(fread(fp,1,'uint32=>uint32'));
        S(i).DimID    = double(fread(fp,Num,'uint32=>uint32'));
        S(i).AttArray = AttArray(fp);
        S(i).Type     = fread(fp,1,'uint32=>uint32');
        S(i).VSize    = fread(fp,1,'uint32=>uint32');
        S(i).Begin    = fread(fp,1,'uint32=>uint32'); % Classic 32 bit format only
    end
else fread(fp,1,'uint32=>uint32'); S = []; end
