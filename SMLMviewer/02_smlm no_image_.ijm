requires("1.48q");
//SMLM viewer 0.71 - 15.05.2014
	print("SMLM viewer 0.71 - 15.05.2014");
//Dialog
Dialog.create("New Image");
Dialog.addString("Title:", "SMLM image #1");
Dialog.addNumber("grid size (nm)", 5);
Dialog.addCheckbox("Overlay", false);
Dialog.addCheckbox("Gauss Filter", true);
Dialog.addCheckbox("LowRes", false);
Dialog.addCheckbox("ROI", false);
Dialog.addChoice("LUT", newArray("Grays","Red","Green","royal","Red Hot", "Fire"), "Fire")
Dialog.addChoice("multiLUT", newArray("Red-Green","Green-Red"), "Red-Green")

		
Dialog.show();
	
//get variables from dialog
title = Dialog.getString();
grid = Dialog.getNumber();
overlay = Dialog.getCheckbox();
gauss = Dialog.getCheckbox();
lowres = Dialog.getCheckbox();
roi = Dialog.getCheckbox();
lut = Dialog.getChoice();
multilut = Dialog.getChoice();

//extra variables
imgchannel = 1;
dualcolor = 1;

//load .loc file, ask user for file
path = File.openDialog("open localization file");
run("Results... ", "open=["+path+"]");	
if (nResults==0) exit("No Results loaded");
	
//load settings from file
if(File.exists(path + ".settings")==1){
	set = File.openAsString(path + ".settings");
	settings = split(set,"\n");
	width=parseInt(settings[0]);
	height=parseInt(settings[1]);
	pixel = parseInt(settings[2]);
	datatype = settings[3];
	n_channel = parseInt(settings[4]);
	print(n_channel);
	if (n_channel>1){
		if (multilut=="Red-Green"){
		//---->Select the color of the channels
		ch1 = "Red";
		ch2 = "Green";
		}
		else if (multilut=="Green-Red"){
			ch1 = "Green";
			ch2 = "Red";
		}
		dualcolor = 2;
	}
}
else {
	exit("Settings file could not be found, make sure a processed .loc file is selected")
}

print("Start macro SMLM viewer");

if (roi==true){
	fullimage = getImageID();
}
else fullimage = 0;

if (dualcolor == 1){

draw_image(imgchannel, title, grid, overlay, gauss, lowres, roi, lut, fullimage);
}
else if (dualcolor ==2){
	if (roi == true){
		roiindex = roiManager("index");
		roiManager("select", roiindex);
	}
	draw_image(1, title, grid, overlay, gauss, lowres, roi, ch1, fullimage);
	if (roi == true){
		roiindex = roiManager("index");
		roiManager("select", roiindex);
	}
	run("Results... ", "open=["+path+"]");	
	draw_image(2, title, grid, overlay, gauss, lowres, roi, ch2, fullimage);
	
}
	
print("Einde macro");


//functions

function draw_image(channel, title, grid, overlay, gauss, lowres, lut, fullimage) {
	//check if roi is 
	selectImage(fullimage);
		if (selectionType()==-1){
			exit("No ROI is selected, make sure the image with ROI is selected");
		}
	//check if and how many ROI files are already available in the folder, and takes next number
		n = 1;
		while (File.exists(File.directory + "ROI_ch" + channel + "_"+ n + ".txt")==1){
			n = n+1;
		}
		Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
		roi_file = File.directory + "ROI_ch" + channel + "_" + n + ".txt";
		fullimage = getImageID();
		
	//open ROI file and write header and localization in the ROI in the text file
		f = File.open(roi_file);
	 	p = "Index" + "\t" + "X" + "\t" + "Y" + "\t" + "Precision" + "\t" + "SEM"+ "\t" + "PSF" + "\t" + "First_Frame"+ "\t" + "N_detections"+ "\t" + "Photons"+ "\t" + "Intensity"+ "\t" + "Frames_missing"+ "\t" + "Channel";
		print(f,p);
		Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
		getPixelSize(unit, pixelWidth, pixelHeight);
		getDimensions(width, height, channels, slices, frames);
		x1=sel_x*pixelWidth;
		x2=(sel_x+sel_width)*pixelWidth;
		y1=sel_y*pixelWidth;
		y2=(sel_y+sel_height)*pixelWidth;
		
		ROI_x1 = "ROI x1 " + "\t" +  x1;
		ROI_x2 = "ROI x2 " + "\t" +  x2;
		ROI_y1 = "ROI y1 " + "\t" +  y1;
		ROI_y2 = "ROI y2 " + "\t" +  y2;
		ROI_width = "ROI width " + "\t" +  x2-x1;
		ROI_height = "ROI height " + "\t" +  y2-y1;
			
	//check which localizations are within the ROI
		for(i=0; i<nResults; i++){
			if (selectionContains(getResult("X",i)/pixelWidth,getResult("Y",i)/pixelWidth)&&getResult("Channel",i)==channel) {
				p = "" + getResult("Index",i)+ "\t" + getResult("X",i) + "\t" + getResult("Y",i)+ "\t" + getResult("Precision",i)+ "\t"+ getResult("SEM",i)+ "\t" + getResult("PSF",i)+ "\t" + getResult("First_Frame",i)+ "\t" + getResult("N_detections",i)+ "\t" + getResult("Photons",i)+ "\t" + getResult("Intensity",i)+ "\t" + getResult("Frames_missing",i)+ "\t" + getResult("Channel",i);
				print(f,p);
			}
		}

			
		}
		
		//done plotting all localizations, doing some post processing

			File.append(ROI_width, roi_file);
			File.append(ROI_height, roi_file);
			File.append(ROI_x1, roi_file);
			File.append(ROI_x2, roi_file);
			File.append(ROI_y1, roi_file);
			File.append(ROI_y2, roi_file);
			File.append(channel, roi_file);
			close();
			fullimage = getImageID();
		}
}	
	
