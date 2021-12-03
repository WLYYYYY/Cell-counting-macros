// The original purpose of this macro was to count co-localized DAPI (Blue) and c-Fos (Red) nuclei in brain slice images (50 uM in thickness) acquired from a traditional light microscope under a 10x objective magnification. 
// The parameters and thresholding methods were chosen to fit the original purpose.
// However, some modifications can be made to meet other purposes.


// Select the folders to store monochromatic images obtained from macro "3. Split channels and store.ijm".
Ch1_images = getDirectory("Location of the Ch1 images");
Ch3_images = getDirectory("Location of the Ch3 images");
// Select the folder to store thresholded binary images for individual single-channel.
Ch1_binary = getDirectory("Where to save Ch1 binary images");
Ch3_binary = getDirectory("Where to save Ch3 binary images"); 
// Select the folder to store processed images generated from the ImageJ built-in function "Image Calculator..." 
Results = getDirectory("Co-occurence results");

setBatchMode(true);

// Images from different channels are processed separately. Different filters and thresholding methods could be apply for each channel.
list = getFileList(Ch1_images);
for (i=0; i<list.length; i++) { 
		Ch1_Name_with_format = list[i];
		Ch1_Name_wo_format = replace(Ch1_Name_with_format, ".tif", "");
		Ch3_Name_with_format = replace(Ch1_Name_with_format, "_Ch1.tif", "_Ch3.tif");
		Ch3_Name_wo_format = replace(Ch3_Name_with_format, ".tif", "");
		if (File.exists(Ch3_images+Ch3_Name_with_format)) {
			// This section decides the filter and thresholding method for Ch1 (DAPI) images.
			open(Ch1_images+Ch1_Name_with_format);
			title = getTitle;
 			if (endsWith(title, "_Ch1.tif")) {
  				setBackgroundColor(0, 0, 0);
  				run("Gaussian Blur...", "sigma=3");
	    		run("Auto Threshold", "method=IsoData ignore_black");
	    		run("Convert to Mask");
				run("Watershed"); 
    			saveAs("tiff", Ch1_binary+Ch1_Name_wo_format);
				close();
			}
			// This section decides the filter and thresholding method for Ch3 (cFos) images.
			// Below is the thresholding method described by Guirado et al., 2018. (doi: 10.1016/j.heliyon.2018.e00669.)
			open(Ch3_images+Ch3_Name_with_format);	
			title = getTitle;
 			if (endsWith(title, "_Ch3.tif")) {
  				setBackgroundColor(0, 0, 0);
  				run("Gaussian Blur...", "sigma=2");
				tissueThreshPerc = 99.93; // User-defined N-value; Only top (1-N)% brightest pixels (as decided by the histogram) will be kept.
				nBins = 255;
				getHistogram(values, count, nBins);
				cumSum = getWidth() * getHeight();
				tissueValue = cumSum * tissueThreshPerc / 100;
				cumSumValues = count;
				for (l = 1; l<count.length; l++)
					{cumSumValues[l] += cumSumValues[l-1];}
				for (l = 1; l<cumSumValues.length; l++) 
  				if (cumSumValues[l-1] <= tissueValue && tissueValue <= cumSumValues[l])
  				   {setThreshold(l,255);
  					setOption("BlackBackground", false);
  					run("Convert to Mask");}	
					run("Watershed"); 
    				saveAs("tiff", Ch3_binary+ Ch3_Name_wo_format);
					close();
				 }
		}
}


// Binary images from different channels are now combined together via "Image Calculator...".
for (i=0; i<list.length; i++) {
	Ch1_mask = list[i]; 
	Ch3_mask = replace(Ch1_mask, "_Ch1", "_Ch3"); 
	Name = replace(Ch1_mask, "_Ch1", "");
	if (File.exists(Ch3_binary + Ch3_mask)); { 
		open(Ch1_binary+Ch1_mask);
		open(Ch3_binary+Ch3_mask);
		rename(Name);
		id = getImageID();
		selectImage(id);
		imageCalculator("and create",id, id+1); // For more information/application about Image Calculator, please refer to: https://imagej.nih.gov/ij/docs/guide/146-29.html.
		run("Convert to Mask");
		run("Watershed"); 
		run("Analyze Particles...", "size=25-Infinity circularity=0.8-1 summarize add"); // User-defined cell counting criteria. A rather stringent circularity threshold was set in this example, because both DAPI and cFos stain nuclei, which are rather round in shape.
		saveAs("tiff", Results+Name);
		roiManager("save", Results+Name+".zip");
		roiManager("reset");
		close();
		close();
		close();
	}
}
