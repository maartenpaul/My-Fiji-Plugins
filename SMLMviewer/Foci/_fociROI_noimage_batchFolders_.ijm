newImage("Untitled", "8-bit white", 10240, 10240, 1);
fullimage = getImageID();

dir = getDirectory("Choose a directory");
list = getFileList(dir);
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "/")){
	
	
	//Script to save ROI selection from SMLM Viewer images to indiviual files, exporting single molecule data and different visualizations
	
	path_ROI = dir+list[i] + File.getName(list[i]) + ".zip";
	path = dir+list[i] + File.getName(list[i]) + ".loc";
	
	if (roiManager("count")!=0){
	roiManager("reset") 
	}
	
	roiManager("Open", path_ROI);
	run("Results... ", "open=["+path+"]");	
	
	selectImage(fullimage);
	run("Set Scale...", "distance=1 known=5 pixel=1 unit=nm");
	
	
	roi_number = roiManager("count");
	
	for (j=0; j<roi_number; j++){
		roiManager("select", j)	;
		get_roi_localizations(1,path);
		get_roi_localizations(2,path);
		selectImage(fullimage);
	}
	}
}
close();
			
function get_roi_localizations(channel,path) {
		//check if roi is selected
		
		//run("Results... ", "open=["+path+"]");	
	
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
			
		f = File.open(roi_file);
		p = "Index" + "\t" + "X" + "\t" + "Y" + "\t" + "Precision" + "\t" + "SEM"+ "\t" + "PSF" + "\t" + "First_Frame"+ "\t" + "N_detections"+ "\t" + "Photons"+ "\t" + "Intensity"+ "\t" + "Frames_missing"+ "\t" + "Channel";
		print(f,p);
		Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
		
		getPixelSize(unit, pixelWidth, pixelHeight);
		x1=sel_x*pixelWidth;
		x2=(sel_x+sel_width)*pixelWidth;
		y1=sel_y*pixelWidth;
		y2=(sel_y+sel_height)*pixelWidth;
		//***//begin nieuwe code
		Orientation = "Orientation " + "\t" + 1;
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
		//Open localization file in a result file
		//done plotting all localizations, doing some post processing
		print(f,Orientation);
		print(f,ROI_width);
		print(f,ROI_height);
		print(f,ROI_x1);
		print(f,ROI_x2);
		print(f,ROI_y1);
		print(f,ROI_y2);
		print(f,channel);
		File.close(f);
}

	
