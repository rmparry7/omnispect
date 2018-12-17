<HTML>
<HEAD>
<TITLE>omniSpect: Multispectral Image Analysis</TITLE>
<!--<BASE href="http://lateralus.cs.appstate.edu/omnispect/">-->
</HEAD>

<BODY>
<TABLE border=0 cellpadding=5>
<tr><td colspan=3 valign="top" align="center"><div id="figs" style="width: 808px; height: 75px">
        <div style="position:absolute; left:20px; top:0px;"><a href="http://www.gatech.edu/"><img src="./images/gtlogo_small.png" style="border:0px;"></a></div>
        <div style="position:absolute; left:75px; top:50px;"><a href="http://www.emory.edu/"><img src="./images/emorylogo_small.png" style="border:0px;"></a></div>
        <div style="position:absolute; left:280px; top:25px;"><a href="http://www.bio-miblab.org/"><img src="./images/biomiblab_small.png" style="border:0px;"></a></div>
        <div style="position:absolute; left:650px; top:10px;"><a href="."><img src="./images/omniSpect_logo.png" height= 75px></a></div>
</div></td></tr>
</TABLE>

<?php
	// put matlab path here:
	$matlab_path="/usr/local/bin/matlab";
	#$matlab_path="/opt/matlab2012a/bin/matlab";
	$export_display = "export DISPLAY=10:0 ; "; // do this so that the apache user can open an X window for the figures.
        $matlab=$export_display.$matlab_path;

	# make sure there's enough memory and processing time for PHP
        ini_set("memory_limit","8000000000"); // 7 GB
	ini_set("default_socket_timeout","14400"); // 4 hours
	ini_set("max_execution_time","14400"); // 4 hours
	ini_set("upload_max_filesize","8000000000");
	ini_set("post_max_size","8000000000");
	ini_set("max_input_time","300");

	putenv("HOME=/home/apache");

	# get previous analysis settings or use defaults.
	$mz = array(1=>(!isset($_POST['mz1'])? 0:$_POST['mz1']),
                    2=>(!isset($_POST['mz2'])?-1:$_POST['mz2']),
                    3=>(!isset($_POST['mz3'])?-1:$_POST['mz3']));
        $range = array(1=>(!isset($_POST['range1'])? 1:$_POST['range1']),
                       2=>(!isset($_POST['range2'])? 1:$_POST['range2']),
                       3=>(!isset($_POST['range3'])? 1:$_POST['range3']));
	$noc=(!isset($_POST['noc'])?1:$_POST['noc']); // number of non-negative components

	# setup accepted data type descriptions
	$datastrs=array(
			1=>"CDF time-series",		# CDF time-series
			2=>"mzXML time-series", 	# mzXML time-series
			3=>"imzML image cube", 		# imzML image cube 
			4=>"Analyze 7.5 image cube",	# Analyze 7.5 image cube
			5=>"MAT time-series",		# Precomputed Matlab time-series
			6=>"MAT image cube"		# Precomputed Matlab image cube
		);

	# setup expected file extensions for each data type
	$fileExts=array(1=>array( 		# CDF time-series
				1=>"CDF", 
				2=>"POS", 
				3=>"TIME"
			),
			2=>array( 		# mzXML time-series
				1=>"mzXML", 
				2=>"POS", 
				3=>"TIME"
			),
			3=>array( 		# imzML image cube 
				1=>"imzML", 
				2=>"IBD"
			),
		        4=>array(		# Analyze 7.5 image cube
				1=>"T2M", 
				2=>"DAT", 
				3=>"HDR", 
				4=>"IMG"
			),
		        5=>array(		# Matlab time-series
				1=>"MAT", 
				2=>"POS",
				3=>"TIME"
			),
		        6=>array(		# Matlab image cube
				1=>"MAT", 
			)
		  );

	# For each data type, provide acceptable MIME types (to prevent uploading file in the wrong format)
	$filetypes=array(
		1=>array(	# CDF time-series
			1=>array(
				1=>"application/octet-stream",		# Acceptable MIME types for CDF
				2=>"application/vnd.wolfram.cdf",
				3=>"text/plain",
				4=>"application/x-netcdf",
				5=>"application/x-cdf"
			), 
			2=>array(					# Acceptable MIME types for POS
				1=>"text/plain",
				2=>"application/octet-stream"
			), 
			3=>array(					# Acceptable MIME types for TIME
				1=>"text/plain",
				2=>"application/octet-stream"
			)
		),
		2=>array(	# mzXML time-series
			1=>array(
				1=>"text/plain",			# Acceptable MIME types for mzXML
				2=>"application/octet-stream"
			),
			2=>array(					
				1=>"text/plain",			# Acceptable MIME types for POS
				2=>"application/octet-stream"
			), 
			3=>array(
				1=>"text/plain",			# Acceptable MIME types for TIME
				2=>"application/octet-stream"
			)
		),
		3=>array(	# imzML image cube
			1=>array(
				1=>"application/octet-stream"		# Acceptable MIME types for imzML
			), 
			2=>array(
				1=>"application/octet-stream"		# Acceptable MIME types for IBD
			) 
		),
		4=>array(	# Analyze 7.5 image cube
			1=>array(
				1=>"application/octet-stream"		# Acceptable MIME types for T2M
			), 
			2=>array(
				1=>"chemical/x-mopac-input",		# Acceptable MIME types for DAT
				2=>"application/octet-stream"
			), 
			3=>array(
				1=>"application/octet-stream",		# Acceptable MIME types for HDR
				2=>"image/vnd.radiance"
			), 
			4=>array(
				1=>"application/octet-stream"		# Acceptable MIME types for IMG
			)
		),
		5=>array(	# Matlab time-series
			1=>array(
				1=>"application/octet-stream",		# Acceptable MIME types for MAT
                                2=>"document/unknown"
			),
			2=>array(					# Acceptable MIME types for POS
				1=>"text/plain",
				2=>"application/octet-stream"
			), 
			3=>array(					# Acceptable MIME types for TIME
				1=>"text/plain",
				2=>"application/octet-stream"
			)
		),
		6=>array(	# Matlab image cube
			1=>array(
				1=>"application/octet-stream",		# Acceptable MIME types for MAT
                                2=>"document/unknown"
			)
		)
		
	);

	# setup directory for data upload and log file.
	$filedir="upload/";

	# setup analysis method descriptions
	$analysis_methods=array(
				1=>"Individual",
				2=>"NMF"
			);

        # setup precisions
        $precisions=array(
                          1=>"0.1",
                          2=>"0.01",
                          3=>"0.001"
                         );

	# grab posted parameters from previously uploaded data
	$analysis=(!isset($_POST['analysis'])?0:$_POST['analysis']);
	$datatype=(!isset($_POST['datatype'])?1:$_POST['datatype']);
	$target=(!isset($_POST['target'])?"":$_POST['target']);
	$precision=(!isset($_POST['precision'])?1:$_POST['precision']);

?>

<TABLE border=1 cellpadding=0 width=816px>
<?php
	if ($analysis==0){ // Default file upload page...
		# Create a form for selecting the data type from the options in $datastrs
  		echo "
			<form name=\"form_datatype\" enctype=\"multipart/form-data\" action=\".\" method=\"POST\">
			<tr><th rowspan=1 valign=\"top\" align=\"center\">
		\n";
		echo "<br>Data Type: <select name=\"datatype\">\n";
		foreach($datastrs as $k=>$v){
			echo "<option value=" . $k . (($k==$datatype)?" selected=\"selected\"":"") . ">" . $v . "</option>";
		}
		echo "\n</select>&nbsp;<input type=\"submit\" value=\"Update Data Type\"><br><br>\n";
		echo "</th></tr></form>\n";

		# Create data upload form
		echo "<form name=\"form_analysis\" enctype=\"multipart/form-data\" action=\".\" method=\"POST\">\n";
		echo "<tr><th rowspan=1 valign=\"top\" align=\"center\">\n";
		echo "<br>\n";
		
		# First, include file upload boxes for each expected file for the selected data type
		$array=$fileExts[$datatype];
		foreach($array as $k=>$v) {
			echo "
				Select $v file: <br>
				<input name=\"".$k."_uploaded\" type=\"file\" size=80><br>
			\n";
		}
		echo "<br>\n";

		# Second, provide a dropdown box for each analysis method in $analysis_methods array.
		echo "Analysis Method: <select name=\"analysis\">\n";
	        foreach($analysis_methods as $k=>$v){
        	        echo "<option value=" . $k . (($k==2)?" selected=\"selected\"":"") . ">" . $v . "</option>";
	        }
	        echo "\n</select>\n<br />\n";


		# Add the precision drop down if this is time-series data.
                if (strpos($datastrs[$datatype], 'time-series') !== FALSE) { 
			# Provide a dropdown box for the level of precision in the $precisions array.
			echo "Precision for Centroided Data: <i>m/z</i><select name=\"precision\">\n";
		        foreach($precisions as $k=>$v){
	        	        echo "<option value=" . $k . (($k==1)?" selected=\"selected\"":"") . ">" . $v . "</option>";
		        }
		        echo "\n</select>\n<br \>\n";
		}

		# Add upload button
		echo "
			<input type=\"submit\" value=\"Upload Data\"><br><br>
		";
		# , and hidden input that contains the datatype selection.
		echo "
			<input name=\"datatype\" type=\"hidden\" value=" . $datatype . ">
		";
		echo "
			</th>
			</tr>
			</form>
		\n";
		echo "</TABLE></BODY></HTML>\n";
	} else {
	if ($target=="") { // If the target hasn't been set, we must be uploading the data.
		// (1) check that the file types are correct
		$file_ok=1;
		$target_filetypes=$filetypes[$datatype];
		foreach($target_filetypes as $k=>$v){
			$ok=0;
			foreach($v as $l=>$w){
				if ($_FILES[$k.'_uploaded']['type']==$w){
					$ok=1;
					break;
				}
			}
			if ($ok==0) { $file_ok=0; }
		}
		if ($file_ok!=1){ // print error
			foreach($target_filetypes as $k=>$v){
				echo $fileExts[$datatype][$k]." is ".$_FILES[$k.'_uploaded']['type']."<br>\n";
			}
			exit("File formats are not okay.");
		}
	
		// Create directory to contain uploaded and result files
		// use first (main) uploaded file as basename
		$info=pathinfo($_FILES['1_uploaded']['name']);
		$filedir=$filedir.basename($_FILES['1_uploaded']['name'],".".$info['extension']);
		$filedir=str_replace(" ","_",$filedir);
		$filedir=str_replace("#","_",$filedir);
		if (!is_dir($filedir)) {
			if (!mkdir($filedir,0770,true)){
				die('Failed to create directory: '.$filedir);
			}
		}
		$target = $filedir . "/" . basename($_FILES['1_uploaded']['name'],".".$info['extension']);
		$target = str_replace(" ","_",$target);
		$target = str_replace("#","_",$target);
		
		// Upload each file for this data type
		$target_fileExts=$fileExts[$datatype]; // Expected file extensions
		foreach($target_fileExts as $k=>$v){
			$fname = $target . "." . strtolower($v);
			if (!file_exists($fname)){
				if(move_uploaded_file($_FILES[$k."_uploaded"]['tmp_name'], $fname)) { 
					chmod($fname,0660);
				} else {
					exit("Upload failed on $fname");
				}
			}
		}

		// Load data into matlab and create cube MAT file
		// Output files:
		$matfile = $target . ".mat";
                $precision_target = $target . "_sd" . $precisions[$precision];
		$cubefile = $precision_target . "_cube.mat";
		$rawImageFile = $precision_target . "_rawimage.png";
		$logfile = $precision_target . ".log";

		if (!file_exists($rawImageFile)) {
	
			$data_string = $datastrs[$datatype];
			$load_function = "load_".$data_string;
			$load_function = str_replace(" ","_",$load_function);
			$load_function = str_replace("-","_",$load_function);
			$load_function = str_replace(".","_",$load_function);
		
			$load_params = "'". $target . "." . strtolower($target_fileExts[1]) . "'";
			for ($i=2;$i<=count($target_fileExts);$i++){
				$load_params .= ",'" . $target . "." . strtolower($target_fileExts[$i]) . "'";
			}
			$load_params .= ",'" . $matfile . "','" . $cubefile . "','" . $rawImageFile . "'," . $precisions[$precision];
		
			$out=array();
			$cmd=$matlab.' -nodisplay -nodesktop -r "'.$load_function.'('.$load_params.'); exit;"'; # >> ' . $logfile . ' 2>&1';
			exec($cmd, $out, $return_var);
			if (!file_exists($cubefile)){
				echo "Error creating MAT cube file \"".$cubefile."\"<br><br>";
				echo "out = <br>" . print_r($out, true)."<br>";
				echo "ret = <br>" . $return_var."<br>";
				if (!file_exists($matfile)){
					#echo "Error creating MAT time-series file with $cmd<br><br>";
					echo "Error creating MAT time-series file \"".$matfile."\" <br><br>";
					$log_contents = file_get_contents($logfile);
					echo "log contents = \"" . $log_contents . "\"<br><br>";
					exit("Exiting.");
				}
				#echo "Error creating MAT cube file with $cmd<br><br>";
				echo "Error creating MAT cube file<br><br>";
				echo print_r($out)."<br><br>";
				$log_contents = file_get_contents($logfile);
				echo "log contents = \"" . $log_contents . "\"<br><br>";
				exit("Exiting.");
			}
		}
                $target = $precision_target;
	}

	// Now that we have a 3D data cube, run the analysis
	// Propogate previous selections in posted variables for any analysis method.
	// 1 => individual analysis
	$cubefile = $target . "_cube.mat";
	$rawImageFile = $target . "_rawimage.png";
	$logfile = $target . ".log";

	# Start form for all analyses
	echo "
		<form enctype=\"multipart/form-data\" action=\".\" method=\"POST\">
	        <tr><td rowspan=1 colspan=4 valign=\"top\" align=\"left\"><div id=\"figs\">
	\n";

	$analysis_params="";
	$fig_files=array();
	$totfigs=0;
	if ($analysis == 1){
		// Individual ion images
		$cube_file = "'" . $cubefile . "'";
		$mzs = "[";
		$ranges = "[";
		$figfiles = "{";
		$comma=false;;
		for ($i=1;$i<=3;$i++){
			if ($mz[$i] >=0) {
				if ($comma == true){
					$mzs .= ",";
					$ranges .= ",";
					$figfiles .= ",";
				}
				$totfigs++; 
				$fig_files[$totfigs]=sprintf("%s_mz%08.1f_pm%05.1f",$target,$mz[$i],$range[$i]);

				$mzs .= $mz[$i];
				$ranges .= $range[$i];
				$figfiles .= "'" . $fig_files[$totfigs] . "'";
				$comma=true;
			}
		}
		$mzs .= "]";
		$ranges .= "]";
		$figfiles .= "}";

		if ($totfigs > 1) {
			// RGB composite image
			$totfigs++;
			$fig_files[$totfigs]=sprintf("%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-",$target,$mz[1],$mz[2],$mz[3],$range[1],$range[2],$range[3]);
			$composite_image = "'" . $fig_files[$totfigs] . "'";

			// Sum image
			$totfigs++;
			$fig_files[$totfigs]=sprintf("%s_mz%08.1f-%08.1f-%08.1f-_pm%05.1f-%05.1f-%05.1f-_sum",$target,$mz[1],$mz[2],$mz[3],$range[1],$range[2],$range[3]);
			$sum_image = "'" . $fig_files[$totfigs] . "'";
		}else{
			$composite_image = "''";
			$sum_image = "''";
		}
		// make matlab parameter string
		$analysis_params = $cube_file . "," . $mzs . "," . $ranges . "," . $figfiles . "," . $sum_image . "," . $composite_image;

	} elseif ($analysis == 2){
		// NMF images
		$fig_files=array();
		$figfiles = "{";
		$comma = false;
		$k=0;
		for ($i=1; $i<=$noc; $i++) {
			if ($comma == true){
				$figfiles .= ",";
			}
			$k++;
			$fig_files[$k]=sprintf("%s_nmf%d-%d_img",$target,$noc,$i);
			$figfiles .= "'" . $fig_files[$k] . "',";
			$k++;
			$fig_files[$k]=sprintf("%s_nmf%d-%d_spec",$target,$noc,$i);
			$figfiles .= "'" . $fig_files[$k] . "'";
			$comma = true;
		}
		$figfiles .= "}";
		$totfigs = $k;

		$cube_file = "'" . $cubefile . "'";
		$analysis_params = $cube_file . "," . $noc . "," . $figfiles;

	} else {
		exit("Undefined analysis ID: " . $analysis);
	}

	// Check if the figures for this analysis already exist
	$finished=1;
	for ($i=1;$i<=$totfigs;$i++){
		if (!file_exists($fig_files[$i].".png")){
        	        $finished=0;
                        break;
                }
        }

	// If the figures do not exist...
	if ($finished != 1){
                $analysis_string = $analysis_methods[$analysis];
                $analysis_function = "analyze_".$analysis_string;
                $analysis_function = str_replace(" ","_",$analysis_function);
                $analysis_function = str_replace("-","_",$analysis_function);

                $out=array();
                $cmd=$matlab.' -nodisplay -nodesktop -r "'.$analysis_function.'('.$analysis_params.'); exit;" >> ' . $logfile . ' 2>&1';
                exec($cmd,$out);
                if (!file_exists($fig_files[count($fig_files)].".png")){
                        echo "Error running $analysis_string analysis with $cmd<br><br>";
                        echo print_r($out)."<br><br>";
                        $log_contents = file_get_contents($logfile);
                        echo "log contents = \"" . $log_contents . "\"<br><br>";
                        exit("Exiting.");
                }
	}

	
	// display images.
	for ($i=1;$i<=$totfigs;$i++){
		if (file_exists($fig_files[$i].".png")){
			echo "<a href=\"" . $fig_files[$i] . ".fig\"><img src=\"" . $fig_files[$i] . ".png\" border=\"2\" width=".(($totfigs==1)?800:400)." /></a>";
		}
	}

	// Display Controls
	if ($analysis==1){ // Single Characteristic Image or Average Image (single ion or total ion, single wavelength or total wavelength)	
		// output controls
		echo "
			</div></tr>
			<tr>
			<th width = 220px valign=\"middle\" align=\"left\">
		                <center><i>m/z<br></i></center>
		                1: <input name=\"mz1\" type=\"text\" value=\"" . $mz[1] . "\"><br>
		                2: <input name=\"mz2\" type=\"text\" value=\"" . $mz[2] . "\"><br>
		                3: <input name=\"mz3\" type=\"text\" value=\"" . $mz[3] . "\"><br>
		       	<td width = 220px valign=\"middle\" align=\"left\">
		                <center>+/-<br></center>
		                <input name=\"range1\" type=\"text\" value=\"" . $range[1] . "\"> (Blue)<br>
		                <input name=\"range2\" type=\"text\" value=\"" . $range[2] . "\"> (Green)<br>
		                <input name=\"range3\" type=\"text\" value=\"" . $range[3] . "\"> (Red)<br>
		\n";
	} elseif ($analysis ==2){
		// output controls
		 echo "
                        </div></tr>
                        <tr>
                        <th colspan=2 width = 440px valign=\"middle\" align=\"left\">
			<center>
			Number of Components<br>
			<input name=\"noc\" type=\"text\" value=\"" . $noc . "\"><br>
			</center>
                \n";
	}

	// display common controls
	echo "
		<td width = 180px valign=\"middle\" align=\"center\">
                	<input type=\"submit\" value=\"Update Visualization\"><br>
	        <td width = 180px valign=\"top\" align=\"center\">
	                <b><u>Analysis Method</u></b>
	\n";
	echo "<select name=\"analysis\">\n";
	foreach($analysis_methods as $k=>$v){
		echo "<option value=" . $k . (($analysis==$k)?" selected=\"selected\"":"") . ">" . $v . " Analysis</option>";
	}
	echo "\n</select>\n";
	echo "
		<input name=\"target\" type=\"hidden\" value=\"" . $target . "\">
		</form><br><br>
		<a href=\"" . $target . "_cube.mat\">Data Cube File</a><br>
		<a href=\"" . $rawImageFile . "\">Raw Image File</a>
	\n";
	}
?>
</TABLE>
<TABLE border=0 cellpadding=0>
<tr><td colspan=3 valign="top" align="center"><div id="figs" style="width: 808px">
      <a href="http://www.appstate.edu/"><img src="./images/ASUbird_logo_blackandgoldbird_RGB_600x168_60px.png" style="border:0px;"></a>
</div></td></tr>
<tr><td colspan=1 valign="top" align="left"><div style="width: 808px">
<H3>Source code</H3>
<!--<a href="http://cs.appstate.edu/~rmp/omnispect.zip">http://cs.appstate.edu/~rmp/omnispect.zip</a><br>-->
<a href="https://github.com/rmparry7/omnispect/">http://github.com/rmparry7/omnispect/</a><br>
<H3>Publication:</H3>
<b><a href="http://doi.org/10.1007/s13361-012-0572-y">OmniSpect: An Open MATLAB-Based Tool for Visualization and Analysis of Matrix-Assisted Laser Desorption/Ionization and Desorption Electrospray Ionization Mass Spectrometry Images</a></b><br />
Parry RM, Galhena AS, Gamage CM, Bennett RV, Wang MD, Fernandez FM.<br />
<i>Journal of The American Society for Mass Spectrometry</i>, 24(4), pp. 646-649, 2013.</i><br />
</div></td></tr>
</TABLE>
</BODY>
</HTML>

