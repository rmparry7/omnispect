function load_Analyze_7_5_image_cube(t2m_file,dat_file,hdr_file,img_file, mat_file, cube_file, image_file, precision) % precision is not used but fits the interface for other load methods.
disp(1);
[img,imgX,imgY,imgZ]=readT2M(t2m_file,hdr_file);
disp(2);
img = reshape(img, length(imgY)*length(imgX), length(imgZ));
disp(3);
save(cube_file,'img','imgX','imgY','imgZ','-v7.3');
disp(4);
makeRawImage(cube_file,image_file);
disp(5);

function [X,imgX,imgY,imgZ]=readT2M(t2m_file,hdr_file)
disp(6);
hdr_data = analyze75info(hdr_file, 'ByteOrder', 'ieee-le');
disp(7);
X = analyze75read(hdr_data);
disp(8);
fidt2m = fopen(t2m_file, 'r', 'l');
disp(9);
imgZ = fread(fidt2m, 'single');
disp(10);
fclose(fidt2m);
disp(11);
X=permute(X,[3 1 2]);
disp(12);
imgX=(0:size(X,2)-1)*hdr_data.PixelDimensions(1);
disp(13);
imgY=(0:size(X,1)-1)*hdr_data.PixelDimensions(2);
disp(14);

