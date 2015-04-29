function h=analyze_NMF(cube_file,noc,fig_files)
% ANALYZE_NMF runs nonnegative matrix factorization (NMF) and generates figures for each component.
%
%    ANALYZE_NMF(cube_file,noc) runs NMF using 'noc' components and generates
%    the images for each component.
%
%    ANALYZE_NMF(cube_file,noc,fig_files) additionally specifies the base output file names for 
%    each component image (excluding extension).
%
%    'cube_file' contains the path to the custom Matlab cube file
%    'noc' the number of components to extract with NMF
%    'fig_files' contains the path to one extensionless file name for each component image
%
%    Written by R. Mitchell Parry, 2012/10/15
%    $Revision: 1.00 $
%
if nargin < 1,
	error('Usage: analyze_NMF(cube_file,noc)');
end;

% handle default parameters and output files
target = cube_file(1:end-9); % expected to end with '_cube.mat' for default figure files
if nargin < 2,
	noc = 1;
end;
if nargin < 3,
	k=1;
	for i=1:noc,
		fig_files{k} = sprintf('%s_nmf%d-%d_img',target,noc,i);
		k=k+1;
		fig_files{k} = sprintf('%s_nmf%d-%d_spec',target,noc,i);
		k=k+1;
	end;
end;

% load 
load(cube_file,'img','imgX','imgY','imgZ');
if ndims(img) > 2,
    img = reshape(img, length(imgY)*length(imgX), length(imgZ));
end


if ~issparse(img),
    % img is [imgY x imgX x imgZ];
    imgX=single(imgX(1:size(img,2)));
    imgY=single(imgY(1:size(img,1)));
    imgZ=single(imgZ(1:size(img,3)));
    img = single(img);
end

size(img)

% Store the results of NMF locally.
% If this is the first time, run NMF.
nmf_file = sprintf('%s_nmf%d.mat',target,noc);
if ~exist(nmf_file,'file'),
	disp('running nmf');
	[H,W]=nmf_omniSpect_v3(img',noc);
	W=W';
	H=H';
	% sort by total intensity
	tot=sqrt(sum(W.^2).*sum(H'.^2));
	[srt,srti]=sort(tot,'descend');
	W=W(:,srti);
	H=H(srti,:);
	tot=tot(srti);
	W=reshape(W,[length(imgY) length(imgX) noc]);
	save(nmf_file,'imgX','imgY','imgZ','W','H','tot','-v7.3');
else,
	load(nmf_file);
end;

% generate a histogram or scatter plot if at most 3 components
k=1;
for i=1:noc,
	disp(num2str(i));

	% Generate image figure
	h(k)=figure(k); clf;
	imagesc(imgX,imgY,W(:,:,i));
	try
		axis xy image;
	catch
	end;
	[pathstr, fname]=fileparts(target);
	title({fname,['NMF ' num2str(i) ' : Sum of squares = ' sprintf('%g',tot(i))]},'interpreter','none');
	xlabel('X (microns)');
	ylabel('Y (microns)');
	colorbar;
	polish;
	figname = fig_files{k};
	saveas(gcf,[figname '.fig']);
	saveas(gcf,[figname '.png']);
	k=k+1;

	% Generate spectrum figure
	h(k)=figure(k); clf;
	plot(imgZ,H(i,:));
	title({fname,['NMF ' num2str(i) ' : Sum of squares = ' sprintf('%g',tot(i))]},'interpreter','none');
	xlabel('m/z','FontAngle','italic');
	ylabel('Intensity (arbitrary unit)');
	polish;
	figname = fig_files{k};
	saveas(gcf,[figname '.fig']);
	saveas(gcf,[figname '.png']);
	k=k+1;
end;

function [A,X]=nmf_omniSpect_v3(Y,r,A,b)
% Y is the stack of images (m x n)
% r = number of components (r)
% A = initial A matrix (m x s).
% b = flag to allow modification of templates in 'A'. (1 x s vector)
[m,n]=size(Y);
niter_selected = 1000;     % maximum number of iterations for the selected sample (can be adjusted)
epsil_normA = 1E-4; % tolerance for alternating
updateEps=1e6*eps;

% Declaration for A and X
if nargin<3 || isempty(A),
    A = zeros(m,r);
    init = true(r,1); % randomly init all templates
    b = true(r,1); % and modify them
else % A predefined
    s = size(A,2);
    if nargin<4,
        b = false(s,1); % fix all templates
    end;
    A = [A zeros(m,r-s)];
    init = false(s,1); % do not randomly init input templates.
    init = [init(:); true(r-s,1)]; % randomly init 
    b = [b(:); true(r-s,1)]; % and modify extra unknown templates
end;

norm_A = 10;
rinit=sum(init);
m_sx = 1:m; r_sx = 1:rinit;

% Initialize A and X
A(:,init) = abs(repmat(.1*sin(2*pi*.1*m_sx'),1,rinit) + repmat(.1*cos(2*pi*.1*r_sx),m,1) + repmat(cos(2*pi*.471*m_sx'),1,rinit) + repmat(sin(2*pi*.471*r_sx),m,1));

% Normalization of initial guess
A(:,b) = A(:,b)*diag(1./sum(A(:,b),1));
k = 0;
while ((k <= niter_selected)&&(norm_A > epsil_normA))
    k = k + 1;
%         X = max(updateEps,A\Y);
    X = max(updateEps,pinv(A'*A)*A'*Y);
    
    Ap = A;
    %         A = max(updateEps, Y/X);
    A(:,b) = max(updateEps, Y*X(b,:)'*pinv(X(b,:)*X(b,:)'));
    A(:,b) = A(:,b)*diag(1./sum(A(:,b),1));
    
    if mod(k,50)==0
        norm_A = norm(A(:,b) - Ap(:,b),'fro');
        fprintf(1, '%d-th alternating step, norm=%g\n',k,norm_A);
    end
end % while (k)

