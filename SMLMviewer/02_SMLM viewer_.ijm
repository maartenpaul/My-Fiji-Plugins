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

//save ID of original image while prociessing ROI
if (roi==true){
	fullimage = getImageID();
}
else fullimage = 0;

//check if single (1) or dual color data is provided, for dual color draw two images
if (dualcolor == 1){
	draw_image(imgchannel, title, grid, overlay, gauss, lowres, roi, lut, fullimage);
} else if (dualcolor ==2){
	if (roi == true){
		roiindex = roiManager("index");
		roiManager("select", roiindex);
	}
	draw_image(1, title, grid, overlay, gauss, lowres, roi, ch1, fullimage);
	run("Results... ", "open=["+path+"]");	
	if (roi == true){
		selectImage(fullimage);
		roiManager("select", roiindex);
	}
	draw_image(2, title, grid, overlay, gauss, lowres, roi, ch2, fullimage);	
}
print("Einde macro");


//functions

function draw_image(channel, title, grid, overlay, gauss, lowres, roi, lut, fullimage) {
	print (channel);
	//create new image if no ROI is drawn
	if (roi==false) {
		newImage(title, "16-bit", width*(pixel/grid), height*(pixel/grid), 1, 1, 1);
	} else if (roi==true){	
		selectImage(fullimage);
		//stop if no selection is made
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
		x1=sel_x*pixelWidth;
		x2=(sel_x+sel_width)*pixelWidth;
		y1=sel_y*pixelWidth;
		y2=(sel_y+sel_height)*pixelWidth;
		
		ROI_x1 = "ROI x1 " + "\t" +  x1;
		ROI_x2 = "ROI x2 " + "\t" +  x2;
		ROI_y1 = "ROI y1 " + "\t" +  y1;
		ROI_y2 = "ROI y2 " + "\t" +  y2;
			
		//check which localizations are within the ROI
		

		for(i=0; i<nResults; i++){
			if (selectionContains(getResult("X",i)/pixelWidth,getResult("Y",i)/pixelWidth)&&getResult("Channel",i)==channel) {
				p = "" + getResult("Index",i)+ "\t" + getResult("X",i) + "\t" + getResult("Y",i)+ "\t" + getResult("Precision",i)+ "\t"+ getResult("SEM",i)+ "\t" + getResult("PSF",i)+ "\t" + getResult("First_Frame",i)+ "\t" + getResult("N_detections",i)+ "\t" + getResult("Photons",i)+ "\t" + getResult("Intensity",i)+ "\t" + getResult("Frames_missing",i)+ "\t" + getResult("Channel",i);
				print(f,p);
			}
		}
	//Open localization file in a result file
		File.close(f);
		run("Results... ", "open=["+roi_file+"]");
			
		overlay = true;
		//add molecule overlay
		Overlay.remove;
		//create empty image to draw ROI image
		newImage(title, "16-bit", (x2-x1)/grid, (y2-y1)/grid, 1);
		run("Overlay Options...", "stroke=green width=0.1 apply");
		setColor("green");
		run("Set... ", "zoom=1600");
				
	}
		
		
		spot = 0;
		gauss_width = 0;
		run("Set Scale...", "distance=1 known="+ grid + " pixel=1 unit=nm");
		
		if (roi==false) {
			for(j=0; j<nResults; j++){
				if (getResult("X",j)!=0&&getResult("Y",j)!=0&&getResult("Channel",j)==channel) {
					plot_molecule(getResult("X",j)/grid,getResult("Y",j)/grid);
					
					if (gauss==true&&datatype=="Elyra") {
						gauss_width = gauss_width+getResult("Precision",j);	
					}
					if (overlay==true) {
						overlay_molecule(round(getResult("X",j))/grid, round(getResult("Y",j))/grid, 1, "green");
					}
					spot = spot + 1;
				}
			}
		}
		//if roi is selected draw image with boundaries of ROI
		else if (roi==true) {
			for(j=0; j<nResults; j++){
				if (getResult("X",j)!=0&&getResult("Y",j)!=0) {
					plot_molecule((getResult("X",j)-x1)/grid,(getResult("Y",j)-y1)/grid);
					
					if (gauss==true&&datatype=="Elyra") {
						gauss_width = gauss_width+getResult("Precision",j);	
					}
					if (overlay==true) {
						overlay_molecule(round(getResult("X",j)-x1)/grid-0.5, round(getResult("Y",j)-y1)/grid-0.5, 1, "green");
					}
					
					spot = spot + 1;			
				}
			}

			getDimensions(width, height, channels, slices, frames);
			ROI_width = "ROI width " + "\t" +  (width * grid);
			ROI_height = "ROI height " + "\t" +  (height * grid);
			
			
		}
		
		//done plotting all localizations, doing some post processing
		
		if (overlay == true){
			Overlay.show;
			run("Overlay Options...", "stroke=green width=0.1 apply");
			run("Set... ", "zoom=100");	
		}
		
		//normalize image
		run("Enhance Contrast...", "saturated=0 normalize");
		//apply LUT
		run(lut);
		
		//if gauss is true, apply gaussian filtre with average precision		
		if (gauss==true) {
			gauss_width = round(gauss_width/spot);	
			if (gauss_width == 0) gauss_width=10;
			print("Gauss filter with sigma " + gauss_width + " nm applied");
			run("Gaussian Blur...", "sigma="+0.5*gauss_width/grid);
		}
		
		//adjust constrast
		getStatistics(area, mean, min, max, std, histogram);
		setMinAndMax(min, max);	
		updateDisplay();
		
		if (roi==true){
			saveAs("Tiff",roi_file + ".tif");
			//***//begin new code
			saveAs("Jpeg",roi_file + ".jpg");
			//***//end new code
			
		  	//run("Moment Calculator", "image_name total_mass x_centre y_centre orientation cutoff=0.0000 scaling=1.0000");
			//***//begin new code
			text = "Orientation " + "\t"+ 0;
			File.append(text, roi_file);
			File.append(ROI_width, roi_file);
			File.append(ROI_height, roi_file);
			File.append(ROI_x1, roi_file);
			File.append(ROI_x2, roi_file);
			File.append(ROI_y1, roi_file);
			File.append(ROI_y2, roi_file);
			File.append(channel, roi_file);
			close();
			fullimage = getImageID();
			roiindex = roiManager("index");
			Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
			getDimensions(width, height, channels, slices, frames);
			makeRectangle(sel_x,sel_y,sel_width,sel_height);
			getDimensions(width, height, channels, slices, frames);
			run("Duplicate...", " duplicate channels=1-"+channels);
			saveAs("Tiff",roi_file + ".original.tif");
			close();
			selectImage(fullimage);
			roiManager("select", roiindex);
		}
}	

function plot_molecule(x,y) {
	value=getPixel(round(x),round(y));
	value=value + 1000;
	if (value>65000) {
		setPixel(round(x),round(y),65000);
	}
	else {
		setPixel(round(x),round(y),value);
	}
}
function gauss_molecule(x,y,sigma){
	grid = round(sigma*1.5);
	for (i=0;i<grid;i++){
		for(j=0;j<grid;j++){
				
			}
		}
	}
	
function overlay_molecule(x,y,r,color) {
	setColor(color);
	setLineWidth(0.1);
	Overlay.drawEllipse(x, y, r, r);
}