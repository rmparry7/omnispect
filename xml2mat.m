function xml2mat(xmlfile,matfile);
out=mzxmlread(xmlfile);
% check if the data is centroided
nscans=length(out.scan);
centroided=false;
for i=1:nscans,
	if i==1,
		mz=out.scan(i).peaks.mz(1:2:end);
		pks=out.scan(i).peaks.mz(2:2:end);
		peaksCount=out.scan(i).peaksCount;
	end;
	if peaksCount ~= out.scan(i).peaksCount,
		centroided=true;
		disp('peaksCount not the same for every scan');
		break;
	end;
	if max(abs(mz-out.scan(i).peaks.mz(1:2:end)))>1e-1,
		centroided=true;
		disp('m/z are not the same for every scan');
		break;
	end;
end;

if ~centroided, % 
    disp('not centroided');
	% combine scans into data matrix
	mz=out.scan(1).peaks.mz(1:2:end);
	intensity=zeros(length(mz),nscans);
	retentionTime=zeros(nscans,1);
	peaksCount=out.scan(1).peaksCount;
	totIonCurrent=zeros(nscans,1);
	basePeakMZ=zeros(nscans,1);
	basePeakIntensity=zeros(1,nscans);
	polarity=out.scan(1).polarity;
	for i=1:nscans,
		intensity(:,i)=out.scan(i).peaks.mz(2:2:end);
		totIonCurrent(i)=out.scan(i).totIonCurrent;
		try 
			basePeakMZ(i)=out.scan(i).basePeakMZ;
		catch
			basePeakMZ(i)=out.scan(i).basePeakMz;
		end;
		basePeakIntensity(i)=out.scan(i).basePeakIntensity;
		retentionTime(i)=sscanf(out.scan(i).retentionTime,'PT%fS');
	end;
	out.scan=out.scan(1);
	out.scan.retentionTime=retentionTime;
	out.scan.totIonCurrent=totIonCurrent;
	out.scan.mz=mz;
	out.scan.intensity=intensity;
	out.scan.basePeakMZ=basePeakMZ;
	out.scan.basePeakIntensity=basePeakIntensity;
	out.scan.polarity=polarity;
elseif ~exist('out.scan.intensity'),
%     out2.mzXML = out.mzXML;
    disp('no out.scan.intensity');
    eval(['out2.scan.retentionTime=[' strrep(strrep(cat(2,out.scan.retentionTime),'PT',''),'S',',') ']'';']);
    out2.scan.lowMz=cat(1,out.scan.lowMz);
    out2.scan.highMz=cat(1,out.scan.highMz);
    out2.scan.peaksCount = cat(1,out.scan.peaksCount);
    out2.scan.totIonCurrent = cat(1,out.scan.totIonCurrent);
    out2.scan.mz = cell(nscans,1);
    out2.scan.intensity = cell(nscans,1);
    for i=1:nscans,
        mz = out.scan(i).peaks.mz(1:2:end);
        pks = out.scan(i).peaks.mz(2:2:end);
        out2.scan.mz{i} = mz;
        out2.scan.intensity{i} = pks;
    end;
    out2.scan.basePeakMz = cat(1,out.scan.basePeakMz);
    out2.scan.basePeakIntensity = cat(1,out.scan.basePeakIntensity);
    out = out2;
    clear out2;
end;
disp('writing MAT file');
save(matfile,'out','-v7.3');

