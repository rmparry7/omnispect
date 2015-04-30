function load_Analyze_7_5_image_cube(t2m_file,dat_file,hdr_file,img_file, mat_file, cube_file, image_file, precision) % precision is not used but fits the interface for other load methods.
[img,imgX,imgY,imgZ]=readT2M(t2m_file,hdr_file);
img = reshape(img, length(imgY)*length(imgX), length(imgZ));
save(cube_file,'img','imgX','imgY','imgZ','-v7.3');
makeRawImage(cube_file,image_file);

function [X,imgX,imgY,imgZ]=readT2M(t2m_file,hdr_file)
hdr_data = analyze75info(hdr_file, 'ByteOrder', 'ieee-le');
X = analyze75read(hdr_data);
fidt2m = fopen(t2m_file, 'r', 'l');
imgZ = fread(fidt2m, 'single');
fclose(fidt2m);
X=permute(X,[3 1 2]);
imgX=(0:size(X,2)-1)*hdr_data.PixelDimensions(1);
imgY=(0:size(X,1)-1)*hdr_data.PixelDimensions(2);

