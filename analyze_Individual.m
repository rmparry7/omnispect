function h=analyze_Individual(cube_file,masses,ranges,fig_files,sum_file,composite_file)
% ANALYZE_INDIVIDUAL generates ion images from image cube files.
%
%    ANALYZE_INDIVIDUAL(cube_file,masses,ranges) generates 
%    the images for each m/z in 'masses' by summing the ion content with +/-
%    the corresponding index in 'ranges'.  One image is generated per mass.
%    In addition, a composite image that puts one image in the R, G, and B
%    channels, and a sum image displays the total number of ions in all three 
%    mass ranges.
%
%    ANALYZE_INDIVIDUAL(cube_file,masses,ranges,fig_files,sum_file,composite_file)
%    specifies the output file names for the ion images, sum image, and composite image.
%
%    'cube_file' contains the path to the custom Matlab cube file
%    'masses' contains an array of center m/z values
%    'ranges' contains an array of the m/z range that are combined to render an ion image
%    'fig_files' contains the path to one extensionless file name for each ion image
%    'sum_file' contains the path to one extensionless file name for the sum image
%    'composite_file' contains the path to one extensionless file name for the composite image
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%


if nargin < 1, 
    error('Usage: analyze_Individual(cube_file,masses,ranges,fig_files,sum_file,composite_file)');
end;

target = cube_file(1:end-9);

% handle default values for input and output.
if nargin < 2,
	masses=[0 -1 -1];
end;
nmasses=numel(masses);
if nargin < 3,
	ranges=ones(1,nmasses);
end;
if nargin < 4,
	fig_files={};
	for i=1:nmasses,
		if masses(i)>=0,
			fig_files{end+1} = sprintf('%s_mz%08.1f_pm%05.1f',target,mz(i),pm(i));
		end;
	end;
end;
if nargin < 5,
	sum_image = sprintf('%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-_sum',...
	                        target,mz(1),mz(2),mz(3),pm(1),pm(2),pm(3));
end;
if nargin < 6,
	composite_image = sprintf('%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-_sum',...
        			target,mz(1),mz(2),mz(3),pm(1),pm(2),pm(3));
end;



% read scans for this file
disp('Reading scans');
load(cube_file);
img=reshape(img, length(imgY)*length(imgX), length(imgZ));
X=img; clear img;


h=[];
disp('do masses');
total_done=0;
kmasses=false(nmasses,1);
for i=1:nmasses,
    % handle bad inputs for mass
    if masses(i)>0,
        mxmass=masses(i)+ranges(i);
        mnmass=masses(i)-ranges(i);
        idx=imgZ>=mnmass & imgZ<=mxmass;
        img(:,i)=sum(X(:,idx),2);
        kmasses(i)=true;
    elseif total_done==1,
        kmasses(i)=false;
        continue;
    else
        img(:,i)=sum(X,2); % total ion count
        total_done=1;
        kmasses(i)=true;
    end;
    % make figure.
    h(end+1)=figure;
    imagesc(imgX,imgY,reshape(img(:,i),length(imgY), length(imgX)));
    colormap(jet);
    axis xy equal;
    [pathstr, fname]=fileparts(target);
    if masses(i)<=0,
        str='Total Ion Current';
    else
        str=sprintf('m/z %.1f +/- %.1f',masses(i),ranges(i));
    end;
    title({fname,str},'interpreter','none');
    xlabel('X (microns)');
    ylabel('Y (microns)');
    colorbar;
    polish;

    % save figure
    fig_files
    if masses(i) >= 0,
        figname = fig_files{i};
        saveas(h(end),[figname '.fig']);
        print(h(end),'-dpng','-r300',[figname '.png']);
    end;
end;
%if ndims(img) > 2,
    img = reshape(img, length(imgY), length(imgX), size(img,2));
%end
% handle bad masses
masses=masses(kmasses);
ranges=ranges(kmasses);
nmasses=length(masses);

% create sum and composite image
colors=[0 0 1; 0 1 0; 1 0 0; 0.7 0 0.7; 0 0.7 0.7; 0.7 0.7 0]; % = [B G R M C Y]
colors=colors(1:nmasses,:);
disp('do multiple ion image');
if nmasses>1, 
    % Making Sum Image
    % add sum image (across all selected ions before normalization)
    img(:,:,masses<0)=0;
    h(end+1)=figure;
    imagesc(imgX,imgY,sum(img,3));
    colormap(jet);
    axis xy equal;
    [pathstr, fname]=fileparts(target);
    str='Selected Ion Sum';
    title({fname,str},'interpreter','none');
    xlabel('X (microns)');
    ylabel('Y (microns)');
    colorbar;
    polish;
    % Save sum image
    saveas(h(end),[sum_file '.fig']);
    print(h(end),'-dpng','-r300',[sum_file '.png']);

    % Making Composite Image
    % normalize each image to sum to one
    img=bsxfun(@rdivide,img,max(sum(sum(img,1),2),1));
    img(:,:,masses<0)=0;
    sz=size(img);
    img=reshape(reshape(img,[sz(1)*sz(2) sz(3)])*colors,[sz(1) sz(2) 3]);
    img=img./max(img(:)); % Scale so that maximum RGB contribution == 1.
    h(end+1)=figure;
    image(imgX,imgY,img);
    axis xy equal;
    title({fname,'Composite Image'},'interpreter','none');
    xlabel('X (microns)');
    ylabel('Y (microns)');
    polish;
    % Save composite image
    saveas(h(end),[composite_file '.fig']);
    print(h(end),'-dpng','-r300',[composite_file '.png']);

end;

