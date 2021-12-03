// This macro can only measure the surface area of image with an (0, 0, 0) RGB background.
// It is recommended that all the images are spatially calibrated before running this macro.
// For instructions of how to perform spatial calibration in ImageJ/Fiji, please refer to: https://imagej.net/imaging/spatial-calibration.
Origin = getDirectory("Original Merged images"); 
Storage = getDirectory("Stored thresholded target region") // This line is optional; it's only for examination of the thresholded target regions.
list = getFileList(Origin);
setBatchMode(true);
for (i=0; i<list.length; i++) { 
	open(Origin+list[i]);
    run("8-bit");
    setThreshold(1, 255);
    setOption("BlackBackground", false);
    run("Convert to Mask");
    run("Fill Holes");
    run("Create Selection");
    run("Set Measurements...", "area display redirect=None decimal=3");
    run("Measure");		
    saveAs("tiff", Storage+list[i]);
    close();
}
       	
