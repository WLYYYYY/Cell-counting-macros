// This macro perform object quantification on 2-D images either from (1) a single channel or (2) the computed results (calculated by "Image Calculator...") from two single-channels.
// The original purpose of this macro was to count co-localized DAPI (Blue) and c-Fos (Red) signals in mouse brain slices. 
// The original sample images were obtained from a conventional microscope: Zeiss Axio Imager M1, under 10x objective magnification. 
// For demonstration, some of the original samples were uploaded to the folder "Demo sample".
// Defaults options/parameters are determined to fit the original purpose. 
// Alternative options/parameters might be neede to meet other purposes.

setBatchMode(true);
run("Set Measurements...", "area mean standard shape integrated stack display redirect=None decimal=3");

// The first popup dialog that makes some of the primary decisions for quantification analysis.
Dialog.create("Primary decisions for analysis");
Dialog.addMessage("Select the number of single-channel(s) to be analyzed."+"/n"+"This macro can only handle 1-2 channel(s) in one run.");
Number = newArray("1", "2");
Dialog.setInsets(10, 30, 20);
Dialog.addChoice("Number of channel", Number, "2");
Dialog.setInsets(10, 30, 0);
Dialog.addMessage("Particle selection (cell counting) criteria");
Dialog.addNumber("Min. size (0-Infinity)", 25, "", 7, ""); 
Dialog.addNumber("Max. size (0-Infinity)", "Infinity", "", 7, "");
Dialog.addNumber("Min. circularity (0-1)", 0.7);
Dialog.addNumber("Max. circularity (0-1)", 1);
Dialog.show();
Selection1 = Dialog.getChoice();
Size_min = Dialog.getNumber();
Size_max = Dialog.getNumber();
Cir_min = Dialog.getNumber();
Cir_max = Dialog.getNumber();
if (Size_min < 0) { 
	Size_min = 0;
}
if (Size_max <= 0) {
	Size_max = 1;
}
if (Cir_max >= 1) {
	Cir_max = 1;
}
if (Cir_max <= 0) {
	Cir_max = 0.00000000001;
}
if (Cir_min < 0) {
	Cir_min = 0;
}



// Global variables for this macro.
Thresholding_method = newArray("Default", "Huang", "Huang2", "Intermodes", "IsoData", "Li", "MaxEntropy", "Mean (Global)", "MinError(I)", "Minimum", "Moments", "Otsu (Global)", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen", "Guirado", "Bernsen", "Contrast", "Mean (Local)", "Median", "MidGrey", "Niblack", "Otsu (Local)", "Phansalkar", "Sauvola");
Global_threshold = newArray("Default", "Huang", "Huang2", "Intermodes", "IsoData", "Li", "MaxEntropy", "Mean (Global)", "MinError(I)", "Minimum", "Moments", "Otsu (Global)", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen");
Local_threshold = newArray("Bernsen", "Contrast", "Mean (Local)", "Median", "MidGrey", "Niblack", "Otsu (Local)", "Phansalkar", "Sauvola");
Filtering_method = newArray("(None)", "Gaussian Blur", "Median", "Mean", "Minimum", "Maximum", "Variance", "Top Hat", "Unsharp Mask");



// Major alternative route #1: if only one single-channel is selected.
if (Selection1=="1") {
	Dialog.create("Analysis settings");
	Dialog.addMessage("Image directories");
	Dialog.addDirectory("Original images", "");
	Dialog.addDirectory("Processed images", "");
	Dialog.addMessage("Parameters for image processing");
	Dialog.addChoice("Thresholding method", Thresholding_method, "Default");
	Dialog.addChoice("1st Filter", Filtering_method, "Gaussian Blur");
	Dialog.addChoice("2nd Filter", Filtering_method, "(None)");
	Dialog.show();
	Original = Dialog.getString();
	Processed = Dialog.getString();
	sThreshold = Dialog.getChoice();
	sFilter1 = Dialog.getChoice();
	sFilter2 = Dialog.getChoice();
	
	// Decides the options for selected thresholding method.
	for (i=0; i<Global_threshold.length; i++) {
		if (sThreshold==Global_threshold[i]) {
			rows = 1;
			columns = 3;
			n = rows* columns;
			Options = newArray(n);
			Default = newArray(n);
			Options[0]="Ignore black";
			Options[1]="Ignore white";
			Options[2]="White object on black background";
			for (j=0; j<n; j++){
				if (j==0) Default[j]=true;
				else Default[j]=false;
			}
			Dialog.create("Options for global tresholding");
			Dialog.addCheckboxGroup(rows, columns, Options, Default);
			Dialog.show();
			Ignore_black = Dialog.getCheckbox();
			Ignore_white = Dialog.getCheckbox();
			White_object_Global = Dialog.getCheckbox();
			if (Ignore_black==true)
				ib = " ignore_black";
			else ib = "";
			if (Ignore_white==true)
				iw = " ignore_white";
			else iw = "";
			if (White_object_Global==true)
				wobj = " white";
			else wobj = "";
			threshold_option = ib+iw+wobj;
		}
	}
	if (sThreshold=="Guirado") {
		Guirado_p = getNumber("Background percentage", 99.35);
	}
	for (i=0; i<Local_threshold.length; i++) {
		if (sThreshold==Local_threshold[i]) {
			Dialog.create("Parameteres and options for local thresholding");
			Dialog.addNumber("Radius", 100);
			Dialog.addNumber("Parameter 1", 0);
			Dialog.addNumber("Parameter 2", 0);
			Dialog.addCheckbox("White object on black background" , true);
			Dialog.show();
			Local_radius = Dialog.getNumber();
			Para1 = Dialog.getNumber();
			Para2 = Dialog.getNumber();
			White_object_Local = Dialog.getCheckbox();
			if (White_object_Local==true)
				threshold_option = "white";
			else threshold_option = "";
		}
	}
	
	// Decides the parameters and options for the first filter.
	if (sFilter1!="(None)" && sFilter1!="Gaussian Blur" && sFilter1!="Unsharp Mask" && sFilter1!="Top Hat") { 
		f_rad_1 = getNumber("1st filter radius", 2);
		f_option_1 = "";
	}
	if (sFilter1=="Gaussian Blur") {
		Dialog.create("Options for 1st filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_1 = Dialog.getNumber();
		Gaussian_option_1 = Dialog.getCheckbox();
		if (Gaussian_option_1==true) {
			f_option_1 = " scaled";}
		else f_option_1 = "";
	}
	if (sFilter1=="Unsharp Mask") {
		Dialog.create("Options for 1st filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_1 = Dialog.getNumber();
		Mask_weight_1 = Dialog.getNumber();
		f_option_1 = " mask="+Mask_weight_1;
	}
	if (sFilter1=="Top Hat") {
		Dialog.create("Options for 1st filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 50);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_1 = Dialog.getNumber();
		dont_sub_1 = Dialog.getCheckbox();
		th_light_1 = Dialog.getCheckbox();
		if (dont_sub_1==true)
			thd_1 = "don't";
		else thd_1 = "";
		if (th_light_1==true)
			thl_1 = "light";
		else thl_1 = "";
		f_option_1 = " "+thl_1+" "+thd_1;
	}
	
	// Decides the parameters and options for the second filter.
	if (sFilter2!="(None)" && sFilter2!="Gaussian Blur" && sFilter2!="Unsharp Mask" && sFilter2!="Top Hat") { 
		f_rad_2 = getNumber("2nd filter radius", 2);
		f_option_2 = "";
	}
	if (sFilter2=="Gaussian Blur") {
		Dialog.create("Options for 2nd filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_2 = Dialog.getNumber();
		Gaussian_option_2 = Dialog.getCheckbox();
		if (Gaussian_option_2==true) {
			f_option_2 = " scaled";}
		else f_option_2 = "";
	}
	if (sFilter2=="Unsharp Mask") {
		Dialog.create("Options for 2nd filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_2 = Dialog.getNumber();
		Mask_weight_2 = Dialog.getNumber();
		f_option_2 = " mask="+Mask_weight_2;
	}
	if (sFilter2=="Top Hat") {
		Dialog.create("Options for 2nd filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 50);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_2 = Dialog.getNumber();
		dont_sub_2 = Dialog.getCheckbox();
		th_light_2 = Dialog.getCheckbox();
		if (dont_sub_2==true)
			thd_2 = "don't";
		else thd_2 = "";
		if (th_light_2==true)
			thl_2 = "light";
		else thl_2 = "";
		f_option_2 = " "+thl_2+" "+thd_2;
	}

	// Cell counting commands.
	list = getFileList(Original);
	for (i=0; i<list.length; i++) { 
		Original_Name_with_format = list[i];
		Original_Name_wo_format = replace(Original_Name_with_format, ".tif", "");
		open(Original+Original_Name_with_format);
	  	setBackgroundColor(0, 0, 0);
	  	if (sFilter1!="(None)")
			run(sFilter1+"...", "radius="+f_rad_1+f_option_1);
		if (sFilter2!="(None)") 
			run(sFilter2+"...", "radius="+f_rad_2+f_option_2);
		for (k=0; k<Global_threshold.length; k++) {
			if (sThreshold==Global_threshold[k]) {
				if (sThreshold=="Mean (Global)")
					sThreshold = "Mean";
				if (sThreshold=="Otsu (Global)")
					sThreshold = "Otsu";
				run("Auto Threshold", "method="+sThreshold+threshold_option);
			}
		}
		// The thresholding method below is developed by Guirado et al. (2018, doi: 10.1016/j.heliyon.2018.e00669). 
		if (sThreshold=="Guirado") {
			background_percentage = Guirado_p;
			nBins = 255;
			getHistogram(values, count, nBins);
			cumSum = getWidth() * getHeight();
			backgroundValue = cumSum * background_percentage / 100;
			cumSumValues = count;
			for (k = 1; k<count.length; k++)
				{cumSumValues[k] += cumSumValues[k-1];}
			for (k = 1; k<cumSumValues.length; k++) 
	  			if (cumSumValues[k-1] <= backgroundValue && backgroundValue <= cumSumValues[k])
	  				{setThreshold(k,255);
	  				setOption("BlackBackground", false);
				}
		}
		for (k=0; k<Local_threshold.length; k++) {
			if (sThreshold==Local_threshold[k]) {
				if (sThreshold=="Mean (Local)")
					sThreshold = "Mean";
				if (sThreshold=="Otsu (Local)")
					sThreshold = "Otsu";
				run("Auto Local Threshold", "method="+sThreshold+" radius="+Local_radius+" parameter_1="+Para1+" parameter_2="+Para2+" "+threshold_option);
			}
		}
	  	run("Convert to Mask");
	  	run("Watershed"); 
		run("Analyze Particles...", "size="+Size_min+"-"+Size_max+" circularity="+Cir_min+"-"+Cir_max+" summarize add");
		saveAs("tiff", Processed+Original_Name_wo_format);
		roiManager("save", Processed+Original_Name_wo_format+".zip");
		roiManager("reset");
		close();
	}	
}



// Major alternative route #2: if two single-channels are selected.
if (Selection1=="2") {
	// The first dialog popup in this route decides the directories for inputs, outputs (binary images processed by filters and thresholding), calculated results (generated from "Image Calculator...".
	// The suffix identifiers unique for each single-channel are also provided in order to find match files (having the same file name except the suffix id) between the two folders, each storing with images from a single channel.
	Dialog.create("Files and directories");
	Dialog.addMessage("Directories for ORIGINAL images");
	Dialog.addDirectory("Channel A original images", "");
	Dialog.addDirectory("Channel B original images", "");
	Dialog.addMessage("Directories for PROCESSED images");
	Dialog.addDirectory("Channel A processed images", "");
	Dialog.addDirectory("Channel B processed images", "");
	Dialog.addMessage("Directories for RESULTS calculated from processed images");
	Dialog.addDirectory("Results", "");
	Dialog.addMessage("The unique suffix identifiers for the two single-channel."+"\n"+"i.e., the suffix attached to the output images generated from macro \"3. Split channels and store.ijm\".");
	Dialog.addString("Suffix id for Channel A", "_Ch1");
	Dialog.addString("Suffix id for Channel B", "_Ch2");
	Dialog.show();
	Original_A = Dialog.getString();
	Original_B = Dialog.getString();
	Processed_A = Dialog.getString();
	Processed_B = Dialog.getString();
	cResults = Dialog.getString();
	id_A = Dialog.getString();
	id_B = Dialog.getString();
	
	// The second dialog decides how images from the two channels should be processed and calculated.
	Dialog.create("Image processing and calculating options");
	Dialog.addMessage("Parameters for image processing - Channel A");
	Dialog.addChoice("Thresholding method", Thresholding_method, "Guirado");
	Dialog.addChoice("1st filter for channel A", Filtering_method, "Gaussian Blur");
	Dialog.addChoice("2nd filter for channel A", Filtering_method, "Top Hat");
	Dialog.addMessage("Parameters for image processing - Channel B");
	Dialog.addChoice("Thresholding method", Thresholding_method, "Default");
	Dialog.addChoice("1st filter for channel B", Filtering_method, "Gaussian Blur");
	Dialog.addChoice("1st filter for channel B", Filtering_method, "(None)");
	Dialog.addMessage("Determine the operator for \"Image Calculator...\"."+"\n"+"Operator should be chosen according to the goal of your analysis, or the spatial relations between signals of the two single-channels.");
	Relations = newArray("And (overlapping A & B)", "Or (either A or B)", "Subtract (B minus A)", "XOR (mutually exclusive)");
	Dialog.addRadioButtonGroup("Relations between signal A & B", Relations, 2, 3, "And (overlapping A & B)");
	Dialog.show();
	sThreshold_A = Dialog.getChoice();
	sFilter1_A = Dialog.getChoice();
	sFilter2_A = Dialog.getChoice();
	sThreshold_B = Dialog.getChoice();
	sFilter1_B = Dialog.getChoice();
	sFilter2_B = Dialog.getChoice();
	sRelat = Dialog.getRadioButton();
	if (sRelat=="And (overlapping A & B)")
		imgcalop = "and";
	if (sRelat=="Or (either A or B)")
		imgcalop = "or";
	if (sRelat=="Subtract (B minus A)")
		imgcalop = "subtract";
	if (sRelat=="XOR (mutually exclusive)")
	imgcalop = "xor";
	// Decides the options for thresholding method for images from channel A.
	for (i=0; i<Global_threshold.length; i++) {
		if (sThreshold_A==Global_threshold[i]) {
			rows = 1;
			columns = 3;
			n = rows* columns;
			Options = newArray(n);
			Default = newArray(n);
			Options[0]="Ignore black";
			Options[1]="Ignore white";
			Options[2]="White object on black background";
			for (j=0; j<n; j++){
				if (j==0) Default[j]=true;
				else Default[j]=false;
			}
			Dialog.create("Channel A: options for global tresholding");
			Dialog.addCheckboxGroup(rows, columns, Options, Default);
			Dialog.show();
			Ignore_black_A = Dialog.getCheckbox();
			Ignore_white_A = Dialog.getCheckbox();
			White_object_Global_A = Dialog.getCheckbox();
			if (Ignore_black_A==true)
				ib = " ignore_black";
			else ib = "";
			if (Ignore_white_A==true)
				iw = " ignore_white";
			else iw = "";
			if (White_object_Global_A==true)
				wobj = " white";
			else wobj = "";
			threshold_option_A = ib+iw+wobj;
		}
	}
	if (sThreshold_A=="Guirado") {
		Dialog.create("Channel A: select signal intensity cutoff");
		Dialog.addNumber("Background percentage", 99.5);
		Dialog.show();
		Guirado_p_A = Dialog.getNumber();
	}
	for (i=0; i<Local_threshold.length; i++) {
		if (sThreshold_A==Local_threshold[i]) {
			Dialog.create("Channel A: parameteres and options for local thresholding");
			Dialog.addNumber("Radius", 100);
			Dialog.addNumber("Parameter 1", 0);
			Dialog.addNumber("Parameter 2", 0);
			Dialog.addCheckbox("White object on black background" , true);
			Dialog.show();
			Local_radius_A = Dialog.getNumber();
			Para1_A = Dialog.getNumber();
			Para2_A = Dialog.getNumber();
			White_object_Local_A = Dialog.getCheckbox();
			if (White_object_Local_A==true)
				threshold_option_A = "white";
			else threshold_option_A = "";
		}
	}
	
	// Decides the options for thresholding method for images from channel B.
	for (i=0; i<Global_threshold.length; i++) {
		if (sThreshold_B==Global_threshold[i]) {
			rows = 1;
			columns = 3;
			n = rows* columns;
			Options = newArray(n);
			Default = newArray(n);
			Options[0]="Ignore black";
			Options[1]="Ignore white";
			Options[2]="White object on black background";
			for (j=0; j<n; j++){
				if (j==0) Default[j]=true;
				else Default[j]=false;
			}
			Dialog.create("Channel B: options for global tresholding");
			Dialog.addCheckboxGroup(rows, columns, Options, Default);
			Dialog.show();
			Ignore_black_B = Dialog.getCheckbox();
			Ignore_white_B = Dialog.getCheckbox();
			White_object_Global_B = Dialog.getCheckbox();
			if (Ignore_black_B==true)
				ib = " ignore_black";
			else ib = "";
			if (Ignore_white_B==true)
				iw = " ignore_white";
			else iw = "";
			if (White_object_Global_B==true)
				wobj = " white";
			else wobj = "";
			threshold_option_B = ib+iw+wobj;
		}
	}
	if (sThreshold_B=="Guirado") {
		Dialog.create("Channel B: select signal intensity cutoff");
		Dialog.addNumber("Background percentage", 99.5);
		Dialog.show();
		Guirado_p_B = Dialog.getNumber();
	}
	for (i=0; i<Local_threshold.length; i++) {
		if (sThreshold_B==Local_threshold[i]) {
			Dialog.create("Channel B: parameteres and options for local thresholding");
			Dialog.addNumber("Radius", 100);
			Dialog.addNumber("Parameter 1", 0);
			Dialog.addNumber("Parameter 2", 0);
			Dialog.addCheckbox("White object on black background" , true);
			Dialog.show();
			Local_radius_B = Dialog.getNumber();
			Para1_B = Dialog.getNumber();
			Para2_B = Dialog.getNumber();
			White_object_Local_B = Dialog.getCheckbox();
			if (White_object_Local_B==true)
				threshold_option_B = "white";
			else threshold_option_B = "";
		}
	}
	
	// Decides the parameters and options for the first filter in channel A.
	if (sFilter1_A!="(None)" && sFilter1_A!="Gaussian Blur" && sFilter1_A!="Unsharp Mask" && sFilter1_A!="Top Hat") { 
		f_rad_1_A = getNumber("Channel A - 1st filter radius", 2);
		f_option_1_A = "";
	}
	if (sFilter1_A=="Gaussian Blur") {
		Dialog.create("Channel A 1st filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_1_A = Dialog.getNumber();
		Gaussian_option_1_A = Dialog.getCheckbox();
		if (Gaussian_option_1_A==true) 
			f_option_1_A = " scaled";
		else f_option_1_A = "";
	}
	if (sFilter1_A=="Unsharp Mask") {
		Dialog.create("Channel A 1st filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_1_A = Dialog.getNumber();
		Mask_weight_1_A = Dialog.getNumber();
		f_option_1_A = " mask="+Mask_weight_1_A;
	}
	if (sFilter1_A=="Top Hat") {
		Dialog.create("Channel A 1st filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 50);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_1_A = Dialog.getNumber();
		dont_sub_1_A = Dialog.getCheckbox();
		th_light_1_A = Dialog.getCheckbox();
		if (dont_sub_1_A==true) 
			thd_1_A = "don't";
		else thd_1_A = "";
		if (th_light_1_A==true) 
			thl_1_A = "light";
		else thl_1_A = "";
		f_option_1_A = " "+thl_1_A+" "+thd_1_A;

	}
	
	// Decides the parameters and options for the second filter in channel A.
	if (sFilter2_A!="(None)" && sFilter2_A!="Gaussian Blur" && sFilter2_A!="Unsharp Mask" && sFilter2_A!="Top Hat") { 
		f_rad_2_A = getNumber("Channel A - 2nd filter radius", 2);
		f_option_2_A = "";
	}
	if (sFilter2_A=="Gaussian Blur") {
		Dialog.create("Channel A 2nd filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_2_A = Dialog.getNumber();
		Gaussian_option_2_A = Dialog.getCheckbox();
		if (Gaussian_option_2_A==true) 
			f_option_2_A = " scaled";
		else f_option_2_A = "";
	}
	if (sFilter2_A=="Unsharp Mask") {
		Dialog.create("Channel A 2nd filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_2_A = Dialog.getNumber();
		Mask_weight_2_A = Dialog.getNumber();
		f_option_2_A = " mask="+Mask_weight_2_A;
	}
	if (sFilter2_A=="Top Hat") {
		Dialog.create("Channel A 2nd filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 100);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_2_A = Dialog.getNumber();
		dont_sub_2_A = Dialog.getCheckbox();
		th_light_2_A = Dialog.getCheckbox();
		if (dont_sub_2_A==true) 
			thd_2_A = "don't";
		else thd_2_A = "";
		if (th_light_2_A==true) 
			thl_2_A = "light";
		else thl_2_A = "";
		f_option_2_A = " "+thl_2_A+" "+thd_2_A;
	}

	// Decides the parameters and options for the first filter in Channel B.
	if (sFilter1_B!="(None)" && sFilter1_B!="Gaussian Blur" && sFilter1_B!="Unsharp Mask" && sFilter1_B!="Top Hat") { 
		f_rad_1_B = getNumber("Channel B - 1st filter radius", 2);
		f_option_1_B = "";
	}
	if (sFilter1_B=="Gaussian Blur") {
		Dialog.create("Channel B 1st filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_1_B = Dialog.getNumber();
		Gaussian_option_1_B = Dialog.getCheckbox();
		if (Gaussian_option_1_B==true) 
			f_option_1_B = " scaled";
		else f_option_1_B = "";
	}
	if (sFilter1_B=="Unsharp Mask") {
		Dialog.create("Channel B 1st filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_1_B = Dialog.getNumber();
		Mask_weight_1_B = Dialog.getNumber();
		f_option_1_B = " mask="+Mask_weight_1_B;
	}
	if (sFilter1_B=="Top Hat") {
		Dialog.create("Channel B 1st filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 50);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_1_B = Dialog.getNumber();
		dont_sub_1_B = Dialog.getCheckbox();
		th_light_1_B = Dialog.getCheckbox();
		if (dont_sub_1_B==true) 
			thd_1_B = "don't";
		else thd_1_B = "";
		if (th_light_1_B==true) 
			thl_1_B = "light";
		else thl_1_B = "";
		f_option_1_B = " "+thl_1_B+" "+thd_1_B;
	}
	
	// Decides the parameters and options for the second filter in Channel B.
	if (sFilter2_B!="(None)" && sFilter2_B!="Gaussian Blur" && sFilter2_B!="Unsharp Mask" && sFilter2_B!="Top Hat") { 
		f_rad_2_B = getNumber("Channel B - 2nd filter radius", 2);
		f_option_2_B = "";
	}
	if (sFilter2_B=="Gaussian Blur") {
		Dialog.create("Channel B 2nd filter: Gaussian filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                            ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 3);
		Dialog.addCheckbox("Scaled unit", true);
		Dialog.show();
		f_rad_2_B = Dialog.getNumber();
		Gaussian_option_2_B = Dialog.getCheckbox();
		if (Gaussian_option_2_B==true) 
			f_option_2_B = " scaled";
		else f_option_2_B = "";
	}
	if (sFilter2_B=="Unsharp Mask") {
		Dialog.create("Channel B 2nd filter: Unsharp Mask filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                               ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius (sigma)", 50);
		Dialog.addNumber("Mask weight (0.1-0.9)", 0.4);
		Dialog.show();
		f_rad_2_B = Dialog.getNumber();
		Mask_weight_2_B = Dialog.getNumber();
		f_option_2_B = " mask="+Mask_weight_2_B;
	}
	if (sFilter2_B=="Top Hat") {
		Dialog.create("Channel B 2nd filter: Top Hat filter");
		Dialog.setInsets(-10, 30, 10);
		Dialog.addMessage("                                                             ");
		Dialog.setInsets(-10, 30, 20);
		Dialog.addNumber("Radius", 50);
		Dialog.addCheckbox("Don't subtract (grayscale open)", false);
		Dialog.addCheckbox("Light background", false);
		Dialog.show();
		f_rad_2_B = Dialog.getNumber();
		dont_sub_2_B = Dialog.getCheckbox();
		th_light_2_B = Dialog.getCheckbox();
		if (dont_sub_2_B==true) 
			thd_2_B = "don't";
		else thd_2_B = "";
		if (th_light==true) 
			thl_2_B = "light";
		else thl_2_B = "";
		f_option_2_B = " "+thl_2_B+" "+thd_2_B;
	}

	// Processing of original images from the two single-channels.
	list = getFileList(Original_A);
	for (i=0; i<list.length; i++) { 
		Original_A_Name_with_format = list[i];
		Original_A_Name_wo_format = replace(Original_A_Name_with_format, ".tif", "");
		Original_B_Name_with_format = replace(Original_A_Name_with_format, id_A+".tif", id_B+".tif");
		Original_B_Name_wo_format = replace(Original_B_Name_with_format, ".tif", "");
		if (File.exists(Original_B+Original_B_Name_with_format)) {
			open(Original_A+Original_A_Name_with_format);
			title = getTitle;
	 		if (endsWith(title, id_A+".tif")) { // Processing of channel A images.
	  			setBackgroundColor(0, 0, 0);
	  			if (sFilter1_A!="(None)") 
					run(sFilter1_A+"...", "radius="+f_rad_1_A+f_option_1_A);
				if (sFilter2_A!="(None)") 
					run(sFilter2_A+"...", "radius="+f_rad_2_A+f_option_2_A);
				for (k=0; k<Global_threshold.length; k++) {
					if (sThreshold_A==Global_threshold[k]) {
						if (sThreshold_A=="Mean (Global)")
							sThreshold_A = "Mean";
						if (sThreshold_A=="Otsu (Global)")
							sThreshold_A = "Otsu";
					run("Auto Threshold", "method="+sThreshold_A+threshold_option_A);
					}
				}
				if (sThreshold_A=="Guirado") {
					background_percentage = Guirado_p_A;
					nBins = 255;
					getHistogram(values, count, nBins);
					cumSum = getWidth() * getHeight();
					backgroundValue = cumSum * background_percentage / 100;
					cumSumValues = count;
					for (k = 1; k<count.length; k++)
						{cumSumValues[k] += cumSumValues[k-1];}
					for (k = 1; k<cumSumValues.length; k++) 
			  			if (cumSumValues[k-1] <= backgroundValue && backgroundValue <= cumSumValues[k]) {
			  				setThreshold(k,255);
			  				setOption("BlackBackground", false);
						}
				}
				for (k=0; k<Local_threshold.length; k++) {
					if (sThreshold_A==Local_threshold[k]) {
						if (sThreshold_A=="Mean (Local)")
							sThreshold_A = "Mean";
						if (sThreshold_A=="Otsu (Local)")
							sThreshold_A = "Otsu";
						run("Auto Local Threshold", "method="+sThreshold_A+" radius="+Local_radius_A+" parameter_1="+Para1_A+" parameter_2="+Para2_A+" "+threshold_option_A);
					}
				}
			    run("Convert to Mask");
				run("Watershed"); 
		    	saveAs("tiff", Processed_A+Original_A_Name_wo_format);
				close();
				}
				open(Original_B+Original_B_Name_with_format);	// Processing of Channel B images.
				title = getTitle;
		 		if (endsWith(title, id_B+".tif")) {
		  			setBackgroundColor(0, 0, 0);
		  			if (sFilter1_B!="(None)") 
						run(sFilter1_B+"...", "radius="+f_rad_1_B+f_option_1_B);
					if (sFilter2_B!="(None)") 
						run(sFilter2_B+"...", "radius="+f_rad_2_B+f_option_2_B);
					for (k=0; k<Global_threshold.length; k++) {
						if (sThreshold_B==Global_threshold[k]) {
							if (sThreshold_B=="Mean (Global)")
								sThreshold_B = "Mean";
							if (sThreshold_B=="Otsu (Global)")
								sThreshold_B = "Otsu";
						run("Auto Threshold", "method="+sThreshold_B+threshold_option_B);
						}
					}
					if (sThreshold_B=="Guirado") {
						background_percentage = Guirado_p_B;
						nBins = 255;
						getHistogram(values, count, nBins);
						cumSum = getWidth() * getHeight();
						backgroundValue = cumSum * background_percentage / 100;
						cumSumValues = count;
						for (k = 1; k<count.length; k++)
							{cumSumValues[k] += cumSumValues[k-1];}
						for (k = 1; k<cumSumValues.length; k++) 
				  			if (cumSumValues[k-1] <= backgroundValue && backgroundValue <= cumSumValues[k]) {
				  				setThreshold(k,255);
				  				setOption("BlackBackground", false);
							}
					}
					for (k=0; k<Local_threshold.length; k++) {
						if (sThreshold_B==Local_threshold[k]) {
							if (sThreshold_B=="Mean (Local)")
								sThreshold_B = "Mean";
							if (sThreshold_B=="Otsu (Local)")
								sThreshold_B = "Otsu";
							run("Auto Local Threshold", "method="+sThreshold_B+" radius="+Local_radius_B+" parameter_1="+Para1_B+" parameter_2="+Para2_B+" "+threshold_option_B);
						}
					}
				    run("Convert to Mask");
					run("Watershed"); 
			    	saveAs("tiff", Processed_B+Original_B_Name_wo_format);
					close();
					}
		}
	}
	
	// Image calculation and cell counting.
	list = getFileList(Processed_A);
	for (i=0; i<list.length; i++) {
		A_mask = list[i]; 
		B_mask = replace(A_mask, id_A, id_B); 
		Name = replace(A_mask, id_A, "");
		if (File.exists(Processed_B+B_mask)); { 
			open(Processed_A+A_mask);
			open(Processed_B+B_mask);
			rename(Name);
			id = getImageID();
			selectImage(id);
			imageCalculator(imgcalop+" create",id, id+1); // For more information/application about Image Calculator, please refer to: https://imagej.nih.gov/ij/docs/guide/146-29.html.
			run("Convert to Mask");
			run("Watershed"); 
			run("Analyze Particles...", "size="+Size_min+"-"+Size_max+" circularity="+Cir_min+"-"+Cir_max+" summarize add");
			saveAs("tiff", cResults+Name);
			roiManager("save", cResults+Name+".zip");
			roiManager("reset");
			close();
			close();
			close();
		}
	}
}