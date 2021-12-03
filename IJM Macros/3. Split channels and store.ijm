// This macro split the multi-channel merged images into component monochromatic images.
// Images from the green channel are discarded in this case. 
// If users desire to keep the green channel images, please delete all the "//" in the command lines below:

Merged = getDirectory("Original Merged images"); 
list = getFileList(Merged);
Ch1 = getDirectory("Storage site of Ch1 (DAPI) images");
//Ch2 = getDirectory("Storage site of Ch2 (GFP) images");
Ch3 = getDirectory("Storage site of Ch3 (cFos) images"); 
setBatchMode(true);
for (i=0; i<list.length; i++) {
	Name_with_format = list[i];
	Name_wo_format = replace(Name_with_format, ".tif", "");
	open(Merged+Name_with_format);
	run("Split Channels");
    saveAs("Tiff", Ch1+Name_wo_format+"_Ch1");
    close();
    //saveAs("Tiff", Ch2+Name_wo_format+"_Ch2");
    close();  
    saveAs("Tiff", Ch3+Name_wo_format+"_Ch3");
    close();
}