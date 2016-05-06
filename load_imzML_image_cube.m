function load_imzML_image_cube(imzML_file, ibd_file, mat_file, cube_file, image_file, precision) % precision is not used but fits the interface for other load methods.
imzMLtoCube(imzML_file, ibd_file, cube_file);
makeRawImage(cube_file,image_file);

function imzMLtoCube(imzML_file, ibd_file, cube_file)
[img, imgX, imgY, imgZ] = readImzML(imzML_file, ibd_file);
img = reshape(img, length(imgY)*length(imgX), length(imgZ));
save(cube_file,'img','imgX','imgY','imgZ','-v7.3');

function [ img, imgX, imgY, imgZ ] = readImzML( imzML_file, ibd_file, continuousOptimization)
if nargin<3,
    continuousOptimization=1;
end;

tree=xmlread(imzML_file);
xml= tree.getChildNodes.item(0);

% Is the binary file continuous or processed?
isContinuous = -1;
fileDescription = look_children(xml,'fileDescription');
fileContent = look_children(fileDescription,'fileContent');
cvParams = look_children(fileContent,'cvParam');
for i=1:length(cvParams)
    cvParam = cvParams(i);
    nameValue = look_attributes(cvParam,'name');
    if strcmp(nameValue,'continuous'),
        isContinuous = 1;
    elseif strcmp(nameValue,'processed'),
        isContinuous = 0;
    end;
end;
if isContinuous == 1,
    disp('These data are in continuous mode.');
elseif isContinuous == 0
    disp('These data are in processed mode.');
else 
    error('Failed to parse binary file mode.');
end;

% What is the data type for m/z arrays and intensity arrays?
% controlled vocabulary: http://www.maldi-msi.org/download/imzml/imagingMS.obo
% MS:1000519, 32-bit integer
% MS:1000520, 16-bit float
% MS:1000521 (32-bit float)
% MS:1000522 (64-bit integer)
% MS:1000523 (64-bit float)
% IMS:1100000, 8-bit integer, "Signed 8-bit integer"
% IMS:1100001, 16-bit integer, "Signed 16-bit integer"
mzFormat='';
intensityFormat='';
referenceableParamGroupList = look_children(xml,'referenceableParamGroupList');
referenceableParamGroups = look_children(referenceableParamGroupList,'referenceableParamGroup');
for i=1:length(referenceableParamGroups),
    referenceableParamGroup = referenceableParamGroups(i);
    idValue = look_attributes(referenceableParamGroup,'id');
    if strcmp(idValue,'mzArray') || strcmp(idValue,'intensityArray'),
        % Get data type for m/z data
        currFormat='';
        cvParams = look_children(referenceableParamGroup,'cvParam');
        for j=1:length(cvParams),
            cvParam = cvParams(j);
            nameValue = look_attributes(cvParam,'name');
            switch nameValue
                case '8-bit integer'
                    currFormat = 'int8';
                    break; % break for for loop?
                case '16-bit integer'
                    currFormat = 'int16';
                    break;
                case '32-bit integer'
                    currFormat = 'int32';
                    break;
                case '64-bit integer'
                    currFormat = 'int64';
                    break;
                case '16-bit float'
                    error('16-bit floats are not supported.');
                case '32-bit float'
                    currFormat = 'float32';
                    break;
                case '64-bit float'
                    currFormat = 'float64';
                    break;
            end;
        end;
        if strcmp(idValue,'mzArray'),
            mzFormat = currFormat;
        else
            intensityFormat = currFormat;
        end;
    end;
end;
disp(['m/z data format is ' mzFormat]);
disp(['intensity data format is ' intensityFormat]);

% What are the image properties (number of pixels and pixel sizes)?
maxCountOfPixelX = -1;
maxCountOfPixelY = -1;
maxDimensionX = -1;
maxDimensionXUnit = -1;
maxDimensionY = -1;
maxDimensionYUnit = -1;
pixelSizeX = -1;
pixelSizeXUnit = -1;
pixelSizeY = -1;
pixelSizeYUnit = -1;
scanSettingsList = look_children(xml,'scanSettingsList');
scanSettings = look_children(scanSettingsList,'scanSettings');
% potentially more than one scanSettings in list, check all of them for
% each parameter.  The last occurence is used.
for i=1:length(scanSettings),
    scanSetting = scanSettings(i);
    cvParams = look_children(scanSetting,'cvParam');
    for j=1:length(cvParams),
        cvParam = cvParams(j);
        name = look_attributes(cvParam,'name');
        value = look_attributes(cvParam,'value');
        switch name,
            case 'max count of pixel x'
                disp([name ' : ' value]);
                maxCountOfPixelX = str2double(value);
            case 'max count of pixel y'
                disp([name ' : ' value]);
                maxCountOfPixelY = str2double(value);
            case 'max dimension x'
                disp([name ' : ' value]);
                maxDimensionX = str2double(value);
                maxDimensionXUnit = look_attributes(cvParam,'unitName');
                disp(['max dimension x unit : ' num2str(maxDimensionXUnit)]);
            case 'max dimension y'
                disp([name ' : ' value]);
                maxDimensionY = str2double(value);
                maxDimensionYUnit = look_attributes(cvParam,'unitName');
                disp(['max dimension y unit : ' num2str(maxDimensionYUnit)]);
            case 'pixel size x'
                disp([name ' : ' value]);
                pixelSizeX = str2double(value);
                pixelSizeXUnit = look_attributes(cvParam,'unitName');
                disp(['pixel size x unit : ' num2str(pixelSizeXUnit)]);
            case 'pixel size y'
                disp([name ' : ' value]);
                pixelSizeY = str2double(value);
                pixelSizeYUnit = look_attributes(cvParam,'unitName');
                disp(['pixel size y unit : ' num2str(pixelSizeYUnit)]);
            case 'pixel size'
                disp([name ' : ' value]);
                pixelSizeX = str2double(value);
                pixelSizeXUnit = look_attributes(cvParam,'unitName');
                pixelSizeY = pixelSizeX;
                pixelSizeYUnit = pixelSizeXUnit;
                disp(['pixel size x : ' num2str(pixelSizeX)]);
                disp(['pixel size x unit : ' num2str(pixelSizeXUnit)]);
                disp(['pixel size y : ' num2str(pixelSizeY)]);
                disp(['pixel size y unit : ' num2str(pixelSizeYUnit)]);
               
        end;
    end;
end;

% check imzML for the max x/y index used to compute max count of pixel x/y.
run = look_children(xml,'run');
spectrumList = look_children(run,'spectrumList');
spectra = look_children(spectrumList,'spectrum');
maxXindex = -1;
maxYindex = -1;
for i=1:length(spectra),
    spectrum = spectra(i);
    scanList = look_children(spectrum,'scanList');
    scan = look_children(scanList,'scan');
    cvParams = look_children(scan,'cvParam');
    xIndex = -1;
    yIndex = -1;
    for j=1:length(cvParams),
        cvParam = cvParams(j);
        name = look_attributes(cvParam,'name');
        switch name
            case 'position x'
                xIndex = str2double(look_attributes(cvParam,'value'));
            case 'position y'
                yIndex = str2double(look_attributes(cvParam,'value'));
            otherwise
                % ignore.
        end;
    end;
    maxXindex = max(maxXindex, xIndex);
    maxYindex = max(maxYindex, yIndex);
end

disp(['max x index : ' num2str(maxXindex)])
disp(['max y index : ' num2str(maxYindex)])

if maxXindex ~= maxCountOfPixelX || maxYindex ~= maxCountOfPixelY,
    if maxXindex ~= maxCountOfPixelX,
        warning(sprintf('max scan "position x" (%d) does not match "max count of pixel x" (%d), using %d.\n', maxXindex, maxCountOfPixelX, maxXindex));
        maxCountOfPixelX = maxXindex;
    end
    if maxYindex ~= maxCountOfPixelY,
        warning(sprintf('max scan "position y" (%d) does not match "max count of pixel y" (%d), using %d.\n', maxYindex, maxCountOfPixelY, maxYindex));
        maxCountOfPixelY = maxYindex;
    end
end

[maxDimensionX, maxDimensionXUnit, maxCountOfPixelX, pixelSizeX, pixelSizeXUnit]
[maxDimensionY, maxDimensionYUnit, maxCountOfPixelY, pixelSizeY, pixelSizeYUnit]

[maxDimensionX, maxDimensionXUnit, maxCountOfPixelX, pixelSizeX, pixelSizeXUnit] = ...
    clean_pixel_stats(maxDimensionX, maxDimensionXUnit, maxCountOfPixelX, pixelSizeX, pixelSizeXUnit);
[maxDimensionY, maxDimensionYUnit, maxCountOfPixelY, pixelSizeY, pixelSizeYUnit] = ...
    clean_pixel_stats(maxDimensionY, maxDimensionYUnit, maxCountOfPixelY, pixelSizeY, pixelSizeYUnit);
   
if maxDimensionX<0 || maxDimensionY<0 || pixelSizeX<0 || pixelSizeY<0 || maxCountOfPixelX<0 || maxCountOfPixelY<0,
    error('Failed to parse pixel information.');
end
% convert to microns
maxDimensionX=convertToMicrons(maxDimensionX,maxDimensionXUnit);
maxDimensionY=convertToMicrons(maxDimensionY,maxDimensionYUnit);
pixelSizeX=convertToMicrons(pixelSizeX,pixelSizeXUnit);
pixelSizeY=convertToMicrons(pixelSizeY,pixelSizeYUnit);
disp(['The image is ' num2str(maxCountOfPixelY) 'x' num2str(maxCountOfPixelX) ' pixels, covering ' num2str(maxDimensionY) 'x' num2str(maxDimensionX) ' microns']);
disp(['Each pixel is ' num2str(pixelSizeY) 'x' num2str(pixelSizeX) ' microns']);
if (abs(maxDimensionY / maxCountOfPixelY - pixelSizeY) > 1e-9) || ...
   (abs(maxDimensionX / maxCountOfPixelX - pixelSizeX) > 1e-9),
    error('pixel dimensions are not consistent');
end;

% use format information to read from binary file
binaryFilename = ibd_file;
fid = fopen(binaryFilename,'rb');
% How many spectra?
run = look_children(xml,'run');
spectrumList = look_children(run,'spectrumList');
count = str2double(look_attributes(spectrumList,'count'));
if maxCountOfPixelX * maxCountOfPixelY ~= count,
    w_str = sprintf('width=%d, height=%d, num_pixels=%d, num_spectra=%d\n', ...
        maxCountOfPixelX, maxCountOfPixelY, ...
        maxCountOfPixelX*maxCountOfPixelY, count);
    warning(['Number of scans does not equal the number of pixels.\n' w_str]); %#ok<*WNTAG>
end;

intensityImage = cell(maxCountOfPixelY,maxCountOfPixelX);
mzImage = cell(maxCountOfPixelY,maxCountOfPixelX);

if isContinuous && continuousOptimization,
    % only look at the first spectrum to find mzArray and the starting
    % address of the intensity data.
    spectra = look_children(spectrumList,'spectrum',1);
else
    spectra = look_children(spectrumList,'spectrum');
end;
disp('read binary file');
for i=1:length(spectra),if (rem(i,1000)==0), fprintf('.'); end;
    spectrum = spectra(i);
    
    % get (x,y) indices
    xIndex=-1;
    yIndex=-1;
    scanList = look_children(spectrum,'scanList');
    scan = look_children(scanList,'scan');
    cvParams = look_children(scan,'cvParam');
    for j=1:length(cvParams),
        cvParam = cvParams(j);
        name = look_attributes(cvParam,'name');
        switch name
            case 'position x'
                xIndex = str2double(look_attributes(cvParam,'value'));
            case 'position y'
                yIndex = str2double(look_attributes(cvParam,'value'));
            otherwise
                % ignore.
        end;
    end;
    if (xIndex<0) || (yIndex<0) || (xIndex > maxCountOfPixelX) || (yIndex > maxCountOfPixelY),
        e_str = sprintf('xIndex=%d yIndex=%d, maxCountOfPixelX=%d, maxCountOfPixelY=%d\n', xIndex, yIndex, maxCountOfPixelX, maxCountOfPixelY);
        warning(['Failed to find (x,y) index for scan ' num2str(i) '\n' e_str]);
    end;
    
    % binary data
    binaryDataArrayList = look_children(spectrum,'binaryDataArrayList');
    binaryDataArrays = look_children(binaryDataArrayList,'binaryDataArray');
    for j=1:length(binaryDataArrays), 
        binaryDataArray = binaryDataArrays(j);
        referenceableParamGroupRef = look_children(binaryDataArray,'referenceableParamGroupRef');
        ref = look_attributes(referenceableParamGroupRef,'ref');
        if strcmp(ref,'mzArray') || strcmp(ref,'intensityArray'),
            externalArrayLength=-1;
            externalOffset=-1;
            externalEncodedLength=-1;
            binaryDataArray = binaryDataArrays(j);
            cvParams = look_children(binaryDataArray,'cvParam');
            for k=1:length(cvParams),
                cvParam = cvParams(k);
                name = look_attributes(cvParam,'name');
                switch name,
                    case 'external array length'
                        externalArrayLength = str2double(look_attributes(cvParam,'value'));
                    case 'external offset'
                        externalOffset = str2double(look_attributes(cvParam,'value'));
                    case 'external encoded length'
                        externalEncodedLength = str2double(look_attributes(cvParam,'value'));
                    otherwise
                        warning(['Failed to parse binaryDataArray field: ' name]);
                end;
            end;
            if externalArrayLength<0 || externalOffset<0 || externalEncodedLength<0,
                error('Failed to parse binaryDataArray fields.');
            end;
            
            fseek(fid,externalOffset,'bof');
            if strcmp(ref,'mzArray'),
                mzArray = fread(fid,externalArrayLength,mzFormat);
                mzImage{yIndex,xIndex}=mzArray;
            else %if strcmp(ref,'intensityArray'),
                if isContinuous && continuousOptimization,
                    % read all intensity data at once.
                    disp('read all intensity data at once');
                    intensityArray = fread(fid,externalArrayLength * count,intensityFormat);
                else
                    intensityArray = fread(fid,externalArrayLength,intensityFormat);
                    intensityImage{yIndex,xIndex}=intensityArray;
                end;
            end;
        elseif ~strcmp(ref,'mzArray') && ~strcmp(ref,'intensityArray'),
            warning(['Not parsing binary array data: ' ref]);
        end;
    end;
    if isContinuous && continuousOptimization,
        break;
    end;
end;
fclose(fid);

if isContinuous && continuousOptimization,
    % assumes that the order of pixels in the imzML is row-wise (cycles
    % through all x-coordinates for y=1 first, then for y=2, etc.
    img = reshape(intensityArray,[],maxCountOfPixelX*maxCountOfPixelY);
    img = reshape(img,[size(img,1),maxCountOfPixelX,maxCountOfPixelY]);
    img = permute(img,[3 2 1]);
    imgZ = mzArray;
elseif isContinuous,
    img = zeros(maxCountOfPixelY,maxCountOfPixelX,length(mzImage{1,1}));
    for y=1:maxCountOfPixelY,
        for x=1:maxCountOfPixelX,
            img(y,x,:)=intensityImage{y,x};
        end;
    end;
    imgZ = mzImage{1,1};
else % processed data %isContinuous == 0,
    % find min and max m/z
    minMZ=inf;
    maxMZ=-inf;
    for y=1:maxCountOfPixelY,
        for x=1:maxCountOfPixelX,
            minMZ = min([minMZ; mzImage{y,x}]);
            maxMZ = max([maxMZ; mzImage{y,x}]);
        end;
    end;
    N=17000;
    len=ceil((log(maxMZ)-log(minMZ))/(log(N+1)-log(N)));
    imgZ=minMZ.*((N+1)/N).^(0:len)';
    
    % insert peaks into profile
    img = zeros(maxCountOfPixelY,maxCountOfPixelX,length(imgZ));
    for y=1:maxCountOfPixelY,
        for x=1:maxCountOfPixelX,
            idx=round(log(mzImage{y,x}/minMZ)/log((N+1)/N))+1;
            img(y,x,idx)=intensityImage{y,x};
        end;
    end;
    
    % smooth peaks with Gaussian
    m=11;
    % zero-pad
    img=cat(3,zeros(maxCountOfPixelY,maxCountOfPixelX,m-1),img,zeros(maxCountOfPixelY,maxCountOfPixelX,m-1));
    imgZ=minMZ.*((N+1)/N).^(-m+1:len+m-1)';
    % convolve
    h=window(@gausswin,m); h=h/sum(h);
    img=filter(h,1,img,[],3);
end;
imgX = ((1:maxCountOfPixelX)-0.5)*pixelSizeX;
imgY = ((1:maxCountOfPixelY)-0.5)*pixelSizeY;



return;

function childNode = look_children(theNode,theName,maxChildren)
if nargin<3, maxChildren=inf; end;
childNode=[];
if theNode.hasChildNodes,
    theChildren = theNode.getChildNodes;
    for i=1:theChildren.getLength,
        theChild = theChildren.item(i-1);
        if strcmp(theChild.getNodeName,theName),
            childNode=[childNode; theChild];
            if length(childNode) >= maxChildren,
                break;
            end;
        end;
    end;
end;

function theValue = look_attributes(theNode,theName)
theValue = [];
if theNode.hasAttributes,
    theAttributes = theNode.getAttributes;
    for i=1:theAttributes.getLength,
        theAttribute = theAttributes.item(i-1);
        if strcmp(char(theAttribute.getName),theName),
            theValue = [theValue; char(theAttribute.getValue)];
        end;
    end;
end;

function stepsize=convertToMicrons(stepsize,units)
switch units
    case {'meter','m'}
        stepsize = stepsize*1e6;
    case {'decimeter','dm'}
        stepsize = stepsize*1e5;
    case {'centimeter','cm'}
        stepsize = stepsize*1e4;
    case {'millimeter','mm'}
        stepsize = stepsize*1e3;
    case {'micrometer','um'}
    case {'nanometer','nm'}
        stepsize = stepsize*1e-3;
    case {'picometer','pm'}
        stepsize = stepsize*1e-6;
    otherwise
        % do nothing (use user defined units.
end;

function [maxDim, maxDimUnit, maxCount, pixelSize, pixelSizeUnit] = ...
    clean_pixel_stats(maxDim, maxDimUnit, maxCount, pixelSize, pixelSizeUnit)
if any([maxDim, maxCount, pixelSize] < 0)
    if sum([maxDim, maxCount, pixelSize] < 0) == 1
        if maxDim < 0,
            maxDim = maxCount * pixelSize;
            maxDimUnit = pixelSizeUnit;
        elseif maxCount < 0,
            maxCount = maxDim / pixelSize;
        else
            pixelSize = maxDim / maxCount;
            pixelSizeUnit = maxDimUnit;
        end
    elseif maxCount >= 0
        pixelSize = 1;
        maxDim = maxCount;
        maxDimUnit = 'pixels';
        pixelSizeUnit = 'pixels';
        warning('imzML file does not provide size information: using arbitrary ''pixel'' units');
    else
        error('imzML file does not provide enough pixel information');
    end;
end;
    
