function [img,imgX,imgY,imgZ]=makeImageCube(mat_file,pos_file,time_file,cube_file,sigma,time_offset)
% makeImageCube generates an image cube from time-series mass spectra following a predefined
%    sprayer path.
%
%    makeImageCube(mat_file,pos_file,time_file,cube_file,time_offset) generatess
%    the (x,y,m/z) image cube from time-series spectra in 'mat_file' and stage position
%    and timing information in 'pos_file' and 'time_file'.  'cube_file' contains the path
%    to the output MAT file, and the optional 'time_offset' adjusts for a delay between
%    mass spectrometer start and the stage starting.
%
%    'mat_file' contains the path to the time-series mass spectra MAT file
%    'pos_file' contains the path to the stage position information file
%    'time_file' contains the path to the stage timing information file
%    'cube_file' contains the path to the custom Matlab cube file
%    'sigma' provides the standard deviation of the Gaussian window at 
%            m/z 850.
%    'time_offset' contains an optional time offset in milliseconds
%    between the stage start and mass spectrometer start.
%
%    'img' contains the resulting image cube ((y,x),m/z);
%    'imgX' contains a vector of x-coordinates the same size as size(img,2)
%    'imgY' contains a vector of y-coordinates the same size as size(img,1)
%    'imgZ' contains a vector of m/z-values the same size as size(img,3)
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%

% default sigma
if nargin<5 || isempty(sigma),
    disp('using default sigma of m/z 0.1 at m/z 850');
    sigma = 0.1; % sigma = m/z 0.1 at m/z 850
end
% default time_offset
if nargin<6 || isempty(time_offset),
    time_offset=0;
end;

% if the cube_file doesn't exist, create it.
if ~exist(cube_file,'file'),
    disp('make image cube');
    % load the time-series mass spectrometer data
    load(mat_file);
    scantimes=out.scan.retentionTime;
    if iscell(out.scan.intensity)
        targetMZ = 850;
        N = targetMZ / sigma * 2;
        window_width = 11;
        
        target = mat_file(1:end-4);
        % If the data are centroided, convert them into a full data vector form.
        disp('Centroided data!');
        % find the full range of reported m/z values
        minMZ=inf; maxMZ=0;
        disp('find min and max m/z');
        for i=1:length(out.scan.mz)
            minMZ=min([minMZ; out.scan.mz{i}(:)]);
            maxMZ=max([maxMZ; out.scan.mz{i}(:)]);
        end;
        
        % generate vector of inferred m/z values with logarithmic spacing where the factor between
        % adjacent m/z is selected to be (N+1)/N
        len=ceil((log(maxMZ)-log(minMZ))/(log(N+1)-log(N)));
        imgZ=minMZ.*((N+1)/N).^(0:len)';
        disp(['imgZ: [min, max, N] = [' num2str(min(imgZ)) ',' num2str(max(imgZ)) ',' num2str(length(imgZ)) ']'])
        
        % place peaks in the nearest m/z bin.
        disp('inserting peaks into profile');
        intensities=sparse(length(imgZ),length(out.scan.intensity), 10000000);
        %intensities=zeros(length(imgZ),length(out.scan.intensity),'single');
        tic;
        fprintf('%5.1f%% in %6.1f seconds', 0, toc);
        b = repmat(char(8), 1, 24);
        total_peaks = sum(cellfun(@numel, out.scan.intensity));
        ii = nan(total_peaks,1);
        jj = nan(total_peaks,1);
        ss = nan(total_peaks,1);
        mm = length(imgZ);
        nn = length(out.scan.intensity);
        k=0;
        for i=1:length(out.scan.intensity),
            if mod(i,10) == 0,
                fprintf('%s%5.1f%% in %6.1f seconds', b, 100 * (i-1) / length(out.scan.intensity), toc);
            end
            idx=round(log(out.scan.mz{i}/minMZ)/log((N+1)/N))+1;
            %intensities(idx,i)=out.scan.intensity{i};
            index = k+1:k+length(idx);
            ii(index) = idx;
            jj(index) = i;
            ss(index) = out.scan.intensity{i};
            k = k + length(idx);
        end;
        
        intensities = sparse(ii, jj, ss, mm, nn);
        clear ii jj ss
        fprintf('%s%5.1f%% in %6.1f seconds\n', b, 100, toc);
        
        %disp(['bins with at least on peak: ' num2str(sum(any(intensities~=0,2)))]);
        fprintf('%d / %d = %f%% entries are nonzero.\n', nnz(intensities), prod(size(intensities)), 100 * nnz(intensities) / prod(size(intensities)))
        
        % smooth peaks with a Gaussian to spread them across multiple m/z bins.
        % convolve with Guassian
        disp('smoothing peaks with Gaussian window');
        % zero-pad
        disp('zero pad')
        tic;
        intensities=[intensities;zeros(window_width-1,size(intensities,2))];
        toc;
        imgZ=minMZ.*((N+1)/N).^(-(window_width-1)/2:len+(window_width-1)/2)';
        % convolve
        h=window(@gausswin,window_width); h=h/sum(h);
        %intensities=filter(h,1,intensities)';
        tic;
        ii = nan(total_peaks*window_width,1);
        jj = nan(total_peaks*window_width,1);
        ss = nan(total_peaks*window_width,1);
        fprintf('%5.1f%% in %6.1f seconds', 0, toc);
        b = repmat(char(8), 1, 24);
        k = 0;
        for i=1:size(intensities,2),
            if mod(i,10) == 0,
                fprintf('%s%5.1f%% in %6.1f seconds', b, 100 * (i-1) / length(out.scan.intensity), toc);
            end
            a = filter(h,1,full(intensities(:,i)));
            idx = a > 0;
            num = sum(idx);
            % intensities(idx, i) = a(idx);
            index = k+1:k+num;
            ii(index) = find(idx);
            jj(index) = i;
            ss(index) = a(idx);
            k = k + num;
        end
        idx = find(~isnan(ii), 1, 'last');
        ii(idx+1:end) = [];
        jj(idx+1:end) = [];
        ss(idx+1:end) = [];
        intensities = sparse(jj, ii, ss, nn, mm + window_width - 1);
        clear ii jj ss
        fprintf('%s%5.1f%% in %6.1f seconds\n', b, 100, toc);
        fprintf('%d / %d = %f%% entries are nonzero.\n', nnz(intensities), prod(size(intensities)), 100 * nnz(intensities) / prod(size(intensities)))
    else
        % If the mass spectra are not centroided, just load them in.
        intensities=single(out.scan.intensity');
        imgZ=out.scan.mz;
    end
    
    clear out;
    
    % find the (scanx,scany) positions of each scan
    [scanx,scany,ylines]=getScanPositions(scantimes,pos_file,time_file,time_offset);
    % find which ones are during a left-to-right or right-to-left motion.
    [L,R]=getScansLR(scanx,scany);
    
    % check to see which x-direction is scanned first (left or right).
    i=2; while(scanx(i)==scanx(i-1)), i=i+1; end;
    if scanx(i)>scanx(i-1), % right
        D=~L;
    else % left
        D=~R;
    end;
    
    % create the image using only the first pass over the sample (not the return pass)
    [img,imgX,imgY]=makeImage(scanx(D),scany(D),intensities(D,:),ylines);
    
    save(cube_file,'img','imgX','imgY','imgZ','-v7.3');
else
    load(cube_file);
end;

function [img,X,Y]=makeImage(x,y,intensity,ylines,Xsize)
% makeImage generates an image cube from mass spectra collected at differen (x,y) positions.
%
%    makeImage(x,y,intensity,ylines,Xsize) generatess an image cube from mass spectra
%    collected at a series of (x,y) positions.
%
%    'x' contains a vector of x-positions (M x 1) for the time-series mass spectra
%    'y' contains a vector of y-positions (M x 1) for the time-series mass spectra
%    'intensity' contains a matrix (M x N) of M scans and N m/z bins per scan.
%    'ylines' contains the unique y-positions for each line of the stage path.
%    'Xsize' contains the optional width of a pixel in micrometers.
%
%    'img' contains the resulting image cube ((y,x),m/z);
%    'X' contains a vector of x-coordinates the same size as size(img,2)
%    'Y' contains a vector of y-coordinates the same size as size(img,1)
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%

% the number of lines, scans, and m/z bins in the comb sprayer path
nlines=length(ylines);
[nscans,nmasses]=size(intensity);

% Compute the number of pixels per line and optionally the width of each pixel ('Xsize')
if nargin< 5 || isempty(Xsize),
    % If the width of each pixel is not specified, use the median number of scans
    % per line to determine the number of pixels per line and compute the corresponding
    % width.
    lineScans=zeros(nlines,1);
    for i=1:nlines,
        lineScans(i)=sum(y==ylines(i));
    end;
    scansPerLine=median(lineScans);
    Xsize = (max(x)-min(x))/(scansPerLine-1);
else
    scansPerLine = floor((max(x)-min(x))/Xsize) + 1;
end;

% For each line of the image, linearly interpolate the ion intensitites between scans to
% fill in the image.
X=min(x):Xsize:max(x);
Y=ylines;
if issparse(intensity),
    tic;
    b = repmat(char(8), 1, 24);
    
    img = cell(nlines,length(X));
    num_nonzero = nnz(intensity);
    buffer_size = num_nonzero * 4;
    fprintf('number of nonzeros: %d\n', num_nonzero);
    fprintf('buffer size: %d\n', buffer_size);
    
    
    ii = nan(buffer_size, 1);
    jj = nan(buffer_size, 1);
    ss = nan(buffer_size, 1);
    k=0;
    fprintf('%5.1f%% in %6.1f seconds', 0, toc);
    for i=1:nlines,
        fprintf('%s%5.1f%% in %6.1f seconds', b, 100 * (i-1) / nlines, toc);
        j=y==ylines(i) & x>min(x)+1 & x<max(x)-1;
        nz = any(intensity(j,:)>0);
        a = zeros(length(X), nmasses);
        a(:,nz)=interp1(x(j),full(intensity(j,nz)),X,'linear',0);
        [I,J,V] = find(a);
        num = length(I);
        index = k+1:k+num;
        ii(index) = (I-1)*nlines + i;
        jj(index) = J;
        ss(index) = V;
        k = k + num;
    end
    idx = find(~isnan(ii),1,'last');
    if idx > buffer_size,
        warning(sprintf('number of nonzeros in image (%d) exceed buffer_size (%d)', idx, buffer_size));
    end;
    ii(idx+1:end)=[];
    jj(idx+1:end)=[];
    ss(idx+1:end)=[];
    img = sparse(ii,jj,ss,nlines*scansPerLine, nmasses);
    fprintf('%s%5.1f%% in %6.1f seconds\n', b, 100, toc);
else,
    img=zeros(nlines,scansPerLine,nmasses);
    for i=1:nlines,
        j=y==ylines(i) & x>min(x)+1 & x<max(x)-1;
        img(i,:,:)=interp1(x(j),intensity(j,:),X,'linear',0);
    end;
    % flatten cube into matrix
    img = reshape(img, nlines*scansPerLine, nmasses);
end

function [scanx,scany,ylines]=getScanPositions(scan_times,pos_file,time_file,time_offset)
% getScanPositions estimates x- and y-coordinates for scans collected at different times
% along a predetermined path.
%
%    getScanPositions(scan_times,pos_file,time_file,time_offset)
%    Given the path and timing information of data acquisition in the 'pos_file' and 'time_file'
%    interpolate positions for each of the times in 'scan_times'.
%
%    'scan_times' contains a vector of times in seconds since the mass spectrometer started
%    'pos_file' contains the path to a text file containing position information for the acquisition path
%    'time_file' contains the path to a text file containing timing information for the acquisiton path
%    'time_offset' provides an optionsl time offset between when the mass spectrometer starts and the
%     stage begins to move.
%
%    'pos_file' contains the positions of the stage following a 'comb' shaped pattern.  Each line contains
%    six tab delimitted numbers:
%
%        y_i	x_i	y_i+1	x_i+1	y_i+2	x_i+2
%
%    containing the x- and y-coordinates in micrometers following the pattern.  The y-coordinates for each row
%    do not change such that y_i = y_i+1 = y_i+2, and x_i = x_i+2 represent the left most position and x_i+1
%    represents the right most position.  An excerpt from a sample position file might look like the following:
%
%        6713.840	62190.250	6713.840	53190.250	6713.840	62191.250
%        6513.840	62191.250	6513.840	53191.250	6513.840	62192.012
%
%    'time_file' contains the timing information for each leg of the path.  Each line contains three tab
%    delimited numbers:
%
%        t_i	t_i+1	t_i+2
%
%    containing the time in milliseconds it took the stage to move from the previous position to the current
%    position.  For example, t_i contains the time it took to move from (x_i-1,y_i-1) to (x_i,y_i).  An
%    excerpt from an sample time file might look like the following:
%
%        1512.000	60193.000	60206.000
%        1513.000	60201.000	60199.000
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%

% default time_offset
if nargin<4,
    time_offset=0;
end;

% read the scanner path position file
x=dlmread(pos_file,'\t');
% check for the right number of columns
if size(x,2)~=6,
    error('Position file should have only six columns');
end;
x=x';
x=x(:);
y=x(1:2:end);
x=x(2:2:end);
ylines=unique(y);

% read scanner path time file
t=dlmread(time_file,'\t');
% check for the right number of columns
if size(t,2)~=3,
    error('Time file should have only three columns');
end;
t=t/1000;
t=t';
t=t(:);
t=cumsum(t);

if max(scan_times) > max(t),
    warning('MS scans exceed the sprayer path.\nAdditional scans ignored.');
    %scan_times(scan_times>max(t))=[];
end;

% make sure x,y, and t are same length
if length(x) ~= length(y) || length(x) ~= length(t),
    error('error: getScanPositions: input vectors different lengths');
end;


% linearly interpolate the x and y scan positions between the known position and time information for the stage.
scanx=interp1(t,x,scan_times+time_offset,'linear',nan);
scany=interp1(t,y,scan_times+time_offset,'linear',nan);

% ignore lines that don't actually have data.
ylines(ylines<min(scany))=[];
ylines(ylines>max(scany))=[];

function [L,R]=getScansLR(x,y)
% getScansLR determines which scans were taken during the right-to-left or left-to-right part
%  of the comb shaped path.
%
%    getScansLR(x,y) generates a boolean vector indicating the indices of positions
%    ('x','y') that were colletced during a right-to-left or left-to-right posrtion
%    of the stage path.
%
%    'x' contains the time-series of x-ccordinates of scan positions
%    'y' contains the time-series of y-coordinates of scan positions
%
%    'L' provides the right-to-left scan indices
%    'R' provides the left-to-right scan indices
%
%    [x(L), y(L)] provides the positions of right-to-left scans
%    [x(R), y(R)] provides the positions of left-to-right scans
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%

% the difference between neighbors in 'x' and 'y'
dx=diff(x); dy=diff(y);

% The direction is left-to-right when the previous point is to the left,
% the next point is to the right and the y-coordinate doesn't change.
R=(dx(1:end-1)>0 & dx(2:end)>0 & abs(dy(1:end-1)) < 1e-6);

% The direction is right-to-left when the previous point is to the right,
% the next point is to the left and the y-coordinate doesn't change.
L=(dx(1:end-1)<0 & dx(2:end)<0 & abs(dy(1:end-1)) < 1e-6);

% pad with 'false'
R=[false;R;false];
L=[false;L;false];

