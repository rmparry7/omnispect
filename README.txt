If you use this for research, please cite the following paper:
http://doi.org/10.1007/s13361-012-0572-y


README file for running omniSpect GUI in Matlab:

from the Matlab command line: 
>> omnispect

opens the GUI

(1) select file type by clicking radio buttons: 
    (a) Time series (CDF)
    (b) Time series (mzXML)
    (c) Image cube (Analyze 7.5)
    (d) Image cube (imzML)

(2) Browse for input files
    (a) CDF: CDF, time file, position file
    (b) mzXML: mzXML, time file, position file
    (c) Analyze 7.5: Header (HDR), Image (IMG), and T2M file
    (d) imzML: imzML, IBD file

(3) NMF analysis:
    (a) Type the "Number of Components" into the text box.
    (b) Click "Plot NMF"
    (c) omniSpect loads the data, runs NMF, and plots:
        (1) the distribution of spectra along each component axis:
            (a) for 1D, a histogram
            (b) for 2D and 3D a scatter plot
            (c) for larger numbers of components, no distribution is plotted.
        (2) each component image
        (3) each component spectrum

(4) Single Ion analysis:
    (a) Select up to 3 ions of interest by their m/z (left column)
    (b) Select a range of m/z values around each ion's m/z to accumulate in each image (right column)
    (c) Click "Plot Ions"
    (d) omniSpect loads the data and plots:
        (1) each ion image
        (2) a composite RGB image where each ion determines the intensity of each color.
        (3) the total ion image from the selected ions

(5) Clicking "Plot NMF" or "Plot ions" will load the data and convert it to an image cube (MAT file).  Once loaded omniSpect does not recompute the data cube on subsequent analyses.

(6) Questions or comments?  Please contact parryrm@appstate.edu

