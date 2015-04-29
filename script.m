datadir = '/home/parryrm/Data/IMS/Martin_Paine_20150328/'
xmlfile = [datadir '20150204_DESI_Cancer_MeOH_Neg.mzXML']
timefile = [datadir '20150204_30x15.time']
posfile = [datadir '20150204_30x15.pos']
target=xmlfile(1:end-6);
matfile=[target '.mat'];
cubefile=[target '_cube.mat'];

%load(cubefile)
%plot(imgZ, squeeze(mean(mean(img,1),2)))

makeImageCube(target,posfile,timefile,cubefile);
rawimagefile=[target '_rawimage.png'];
makeRawImage(cubefile,rawimagefile);
noc = 1;
analyze_NMF(cubefile,noc);



