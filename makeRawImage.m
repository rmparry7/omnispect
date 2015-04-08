function makeRawImage(cubefile,imagefile)
%imagefile=[target '_rawimage.png'];
%cubefile=[target '_cube.mat'];
load(cubefile,'img','imgX','imgY','imgZ');

if iscell(img),
    for i=1:size(img,1),
        for j=1:size(img,2),
            img2(i,j) = full(sum(img{i,j}));
        end
    end
    img = img2;
else,
    img=sum(img,3);
end
img=img(end:-1:1,:);
img=img/max(img(:));
imwrite(img,imagefile,'png');
