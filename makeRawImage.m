function makeRawImage(cubefile,imagefile)
%imagefile=[target '_rawimage.png'];
%cubefile=[target '_cube.mat'];
load(cubefile,'img','imgX','imgY','imgZ');
img=sum(img,3);
img=img(end:-1:1,:);
img=img/max(img(:));
imwrite(img,imagefile,'png');

