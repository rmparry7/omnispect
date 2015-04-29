function load_CDF_time_series(in_mat_file, pos_file, time_file, mat_file, cube_file, image_file, precision)
load(in_mat_file,'out');
save(mat_file,'out','-v7.3');
makeImageCube(mat_file,pos_file,time_file,cube_file, precision);
makeRawImage(cube_file,image_file);
