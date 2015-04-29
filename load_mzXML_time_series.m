function load_CDF_time_series(xml_file, pos_file, time_file, mat_file, cube_file, image_file, precision)
xml2mat(xml_file,mat_file);
makeImageCube(mat_file,pos_file,time_file,cube_file,precision);
makeRawImage(cube_file,image_file);
