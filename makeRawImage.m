function makeRawImage(cubefile,imagefile)
%imagefile=[target '_rawimage.png'];
%cubefile=[target '_cube.mat'];
load(cubefile,'img','imgX','imgY','imgZ');
if ndims(img) > 2,
    img = reshape(img, length(imgY)*length(imgX), length(imgZ));
end

img = reshape(full(sum(img, 2)),length(imgY), length(imgX));

img=img(end:-1:1,:);
img=img/max(img(:));
imwrite(img,imagefile,'png');
