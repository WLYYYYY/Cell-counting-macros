// This macro apply rolling ball background subtraction to every images under the same user-specified folder.
// For more information, please refer to: https://imagej.net/plugins/rolling-ball-background-subtraction. 
// Recommended value for rolling ball radius: larger than the diameter of your objects of interest.

Dialog.create("Rolling ball background subtraction");
Dialog.addMessage("Directories for input and output images");
Dialog.addDirectory("Input images", "");
Dialog.addDirectory("Output images", "");
Dialog.addMessage("Rolling ball parameters");
Dialog.addNumber("Rolling ball radius", 30);
choice1 = newArray("Yes", "No");
Dialog.addRadioButtonGroup("Light background", choice1, 1, 2, "No");
choice2 = newArray("Yes", "No");
Dialog.addRadioButtonGroup("Disable smoothing", choice2, 1, 2, "No");
choice3 = newArray("Yes", "No");
Dialog.addRadioButtonGroup("Sliding paraboloid", choice3, 1, 2, "No");
Dialog.show();

Input = Dialog.getString();
Output = Dialog.getString();
rr = Dialog.getNumber();
lb = Dialog.getRadioButton();
ds = Dialog.getRadioButton();
sp = Dialog.getRadioButton();

if (lb=="Yes") lb="light";
else lb="";
if (sp=="Yes") sp="sliding";
else sp="";
if (ds=="Yes") ds="disable";
else ds="";
Options = " "+lb+" "+sp+" "+ds;

setBatchMode(true);

list = getFileList(Input);
for (i=0; i<list.length; i++) {
		open(Input+list[i]);
		if (bitDepth==24) run("Subtract Background...", "rolling="+rr+" separate"+Options);
		if (bitDepth!=24) run("Subtract Background...", "rolling="+rr+Options);
		saveAs("tiff", Output+list[i]);
	close();
}
