// This macro split the multi-channel merged images into individual single-channel images.

Dialog.create("Split composite images into single-channel images");
Dialog.addMessage("Directory of input images");
Dialog.addDirectory("Input images", "");
Dialog.addMessage("Select the single-channel(s)");
rows = 1;
columns = 7;
n = rows*columns;
Channel = newArray(n);
Default = newArray(n);
Channel[0]="Red";
Channel[1]="Green";
Channel[2]="Blue";
Channel[3]="Gray";
Channel[4]="Cyan";
Channel[5]="Magenta";
Channel[6]="Yellow";
for (i=0; i<n; i++){
	if (i==0) Default[i]=true;
	else if (i==2) Default[i]=true;
	else Default[i]=false;
}
Dialog.addCheckboxGroup(rows, columns, Channel, Default);
Dialog.show();

Input = Dialog.getString();
Red = Dialog.getCheckbox();
Green = Dialog.getCheckbox();
Blue = Dialog.getCheckbox();
Gray = Dialog.getCheckbox();
Cyan = Dialog.getCheckbox();
Magenta = Dialog.getCheckbox();
Yellow = Dialog.getCheckbox();

if (Red==1) 
	{Dialog.create("Saving output for RED channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch1");
	Dialog.show();
	fRed = Dialog.getString();
	sRed = Dialog.getString();
	}
if (Green==1) 
	{Dialog.create("Saving output for GREEN channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch2");
	Dialog.show();
	fGrn = Dialog.getString();
	sGrn = Dialog.getString();
	}
if (Blue==1)
	{Dialog.create("Saving output for BLUE channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch3");
	Dialog.show();
	fBlue = Dialog.getString();
	sBlue = Dialog.getString();
	}
if (Gray==1) 
	{Dialog.create("Saving output for GRAY channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch4");
	Dialog.show();
	fGray = Dialog.getString();
	sGray = Dialog.getString();
	}
if (Cyan==1) 
	{Dialog.create("Saving output for CYAN channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch5");
	Dialog.show();
	fCyan = Dialog.getString();
	sCyan = Dialog.getString();
	}
if (Magenta==1) 
	{Dialog.create("Saving output for MAGENTA channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch6");
	Dialog.show();
	fMag = Dialog.getString();
	sMag = Dialog.getString();
	}
if (Yellow==1) 
	{Dialog.create("Saving output for YELLOW channel");
	Dialog.addDirectory("Output directory", "");
	Dialog.addString("Add a unique suffix identifier for the channel", "_Ch7");
	Dialog.show();
	fYel = Dialog.getString();
	sYel = Dialog.getString();
	}

setBatchMode(true);

list = getFileList(Input);
for (i=0; i<list.length; i++) {
	Name_with_format = list[i];
	Name_wo_format = replace(Name_with_format, ".tif", "");
	open(Input+Name_with_format);
	title = getTitle(); 
	run("Split Channels"); 
	titleyel = getTitle();
		if (Yellow==1 && (startsWith(titleyel, "C7") || startsWith(titleyel, "Ch7") || startsWith(titleyel, "CH7") ||startsWith(titleyel, "(yellow)") || endsWith(titleyel, "(yellow)") || endsWith(titleyel, "Yellow") || endsWith(titleyel, "yellow") || endsWith(titleyel, "CH7") ||endsWith(titleyel, "(C7)")))
			{
				saveAs("Tiff", fYel+Name_wo_format+sYel);
				close();
			}
		else if (Yellow==0 && (startsWith(titleyel, "C7") || startsWith(titleyel, "Ch7") || startsWith(titleyel, "CH7") ||startsWith(titleyel, "(yellow)") || endsWith(titleyel, "(yellow)") || endsWith(titleyel, "Yellow") || endsWith(titleyel, "yellow") || endsWith(titleyel, "CH7") ||endsWith(titleyel, "(C7)")))
			close();
		else if (Yellow==1)
			{
				print("Something went wrong with the yellow channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains yellow channel.");
			}
	titlemag = getTitle();
		if (Magenta==1 && (startsWith(titlemag, "C6") || startsWith(titlemag, "Ch6") || startsWith(titlemag, "CH6") ||startsWith(titlemag, "(magenta)") || endsWith(titlemag, "(magenta)") || endsWith(titlemag, "Magenta") || endsWith(titlemag, "magenta") || endsWith(titlemag, "CH6") ||endsWith(titlemag, "(C6)")))
			{
				saveAs("Tiff", fMag+Name_wo_format+sMag);
				close();
			}
		else if (Magenta==0 && (startsWith(titlemag, "C6") || startsWith(titlemag, "Ch6") || startsWith(titlemag, "CH6") ||startsWith(titlemag, "(magenta)") || endsWith(titlemag, "(magenta)") || endsWith(titlemag, "Magenta") || endsWith(titlemag, "magenta") || endsWith(titlemag, "CH6") ||endsWith(titlemag, "(C6)")))
			close();
		else if (Magenta==1)
			{
				print("Something went wrong with the magenta channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains magenta channel.");
			}
	titlecy = getTitle();
		if (Cyan==1 && (startsWith(titlecy, "C5") || startsWith(titlecy, "Ch5") || startsWith(titlecy, "CH5") ||startsWith(titlecy, "(cyan)") || endsWith(titlecy, "(cyan)") || endsWith(titlecy, "Cyan") || endsWith(titlecy, "cyan") || endsWith(titlecy, "CH5") ||endsWith(titlecy, "(C5)")))
			{
				saveAs("Tiff", fCyan+Name_wo_format+sCyan);
				close();
			}
		else if (Cyan==0 && (startsWith(titlecy, "C5") || startsWith(titlecy, "Ch5") || startsWith(titlecy, "CH5") ||startsWith(titlecy, "(cyan)") || endsWith(titlecy, "(cyan)") || endsWith(titlecy, "Cyan") || endsWith(titlecy, "cyan") || endsWith(titlecy, "CH5") ||endsWith(titlecy, "(C5)")))
			close();
		else if (Cyan==1)
			{
				print("Something went wrong with the cyan channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains cyan channel.");
			}
	titlegray = getTitle();
		if (Gray==1 && (startsWith(titlegray, "C4") || startsWith(titlegray, "Ch4") || startsWith(titlegray, "CH4") ||startsWith(titlegray, "(gray)") || endsWith(titlegray, "(gray)") || endsWith(titlegray, "Gray") || endsWith(titlegray, "gray") || endsWith(titlegray, "CH4") ||endsWith(titlegray, "(C4)")))
			{
				saveAs("Tiff", fGray+Name_wo_format+sGray);
				close();
			}
		else if (Gray==0 && (startsWith(titlegray, "C4") || startsWith(titlegray, "Ch4") || startsWith(titlegray, "CH4") ||startsWith(titlegray, "(gray)") || endsWith(titlegray, "(gray)") || endsWith(titlegray, "Gray") || endsWith(titlegray, "gray") || endsWith(titlegray, "CH4") ||endsWith(titlegray, "(C4)")))
			close();
		else if (Gray==1)
			{
				print("Something went wrong with the gray channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains gray channel.");
			}
	titleblue = getTitle();
		if (Blue==1 && (startsWith(titleblue, "C3") || startsWith(titleblue, "Ch3") || startsWith(titleblue, "CH3") ||startsWith(titleblue, "(blue)") || endsWith(titleblue, "(blue)") || endsWith(titleblue, "Blue") || endsWith(titleblue, "blue") || endsWith(titleblue, "CH3") ||endsWith(titleblue, "(C3)")))
			{
				saveAs("Tiff", fBlue+Name_wo_format+sBlue);
				close();
			}
		else if (Blue==0 && (startsWith(titleblue, "C3") || startsWith(titleblue, "Ch3") || startsWith(titleblue, "CH3") ||startsWith(titleblue, "(blue)") || endsWith(titleblue, "(blue)") || endsWith(titleblue, "Blue") || endsWith(titleblue, "blue") || endsWith(titleblue, "CH3") ||endsWith(titleblue, "(C3)")))
				close();
		else if (Blue==1)
			{
				print("Something went wrong with the blue channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains blue channel.");
			}
	titlegreen = getTitle();	
		if (Green==1 && (startsWith(titlegreen, "C2") || startsWith(titlegreen, "Ch2") || startsWith(titlegreen, "CH2") ||startsWith(titlegreen, "(green)") || endsWith(titlegreen, "(green)") || endsWith(titlegreen, "Green") || endsWith(titlegreen, "green") || endsWith(titlegreen, "CH2") ||endsWith(titlegreen, "(C2)")))
			{
				saveAs("Tiff", fGrn+Name_wo_format+sGrn);
				close();
			}
		else if (Green==0 && (startsWith(titlegreen, "C2") || startsWith(titlegreen, "Ch2") || startsWith(titlegreen, "CH2") ||startsWith(titlegreen, "(green)") || endsWith(titlegreen, "(green)") || endsWith(titlegreen, "Green") || endsWith(titlegreen, "green") || endsWith(titlegreen, "CH2") ||endsWith(titlegreen, "(C2)")))
			close();
		else if (Green==1)
			{
				print("Something went wrong with the green channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains green channel.");
			}
	titlered = getTitle();		
		if (Red==1 && (startsWith(titlered, "C1") || startsWith(titlered, "Ch1") || startsWith(titlered, "CH1") ||startsWith(titlered, "(red)") || endsWith(titlered, "(red)") || endsWith(titlered, "Red") || endsWith(titlered, "red") || endsWith(titlered, "CH1") ||endsWith(titlered, "(C1)")))
			{
				saveAs("Tiff", fRed+Name_wo_format+sRed);
				close();
			}
		else if (Red==0 && (startsWith(titlered, "C1") || startsWith(titlered, "Ch1") || startsWith(titlered, "CH1") ||startsWith(titlered, "(red)") || endsWith(titlered, "(red)") || endsWith(titlered, "Red") || endsWith(titlered, "red") || endsWith(titlered, "CH1") ||endsWith(titlered, "(C1)")))
			close();
		else if (Red==1)
			{
				print("Something went wrong with the red channel in image: "+title+"."+"\n"+"You might want to check if this composite image contains red channel.");	
			}
}
