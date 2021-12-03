// The rolling ball radius should be set to at least the size of the largest object that is not part of the background.
// For more information, please refer to: https://imagej.net/plugins/rolling-ball-background-subtraction. 
origin = getDirectory("Original images");
results = getDirectory("Where to store the processed images");
setBatchMode(true);
list = getFileList(origin);
for (i=0; i<list.length; i++) { 
       showProgress(i+1, list.length);
       open(origin+list[i]);
		run("Subtract Background...", "rolling=30");
		saveAs("tiff", results+list[i]);
close();}
