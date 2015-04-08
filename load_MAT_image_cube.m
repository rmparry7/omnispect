function load_MAT_image_cube(in_cube_file, mat_file, cube_file, image_file)
load(in_cube_file);
save(cube_file,'img','imgX','imgY','imgZ','-v7.3');
makeRawImage(cube_file,image_file);

