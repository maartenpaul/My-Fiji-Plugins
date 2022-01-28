//Script to save ROI selection from SMLM Viewer images to indiviual files, exporting single molecule data and different visualizations
path_img = File.openDialog("select PALM/STORM image");
path_ROI = File.openDialog("Select ROI.zip");
path = File.openDialog("open localization .loc file");

flip = getBoolean("Is Elyra image already flipped?");


//run("01 Import SML ", "image=512 image=512 pixel=100 data=Elyra dual open=["+ path + "]");

if (roiManager("count")!=0){
roiManager("Delete");	
}

roiManager("Open", path_ROI);

open(path_img);
fullimage = getImageID();
if (flip==false){
	run("Flip Vertically");
}


//setBatchMode('hide');

//print(fullimage);
selectImage(fullimage);
run("Set Scale...", "distance=1 known=5 pixel=1 unit=nm");
//run("Save");

roi_number = roiManager("count");

//print(roi_number);

for (i=0; i<roi_number; i++){

	roiManager("select", i)	;
	//Enlarge selection
	//run("Enlarge...", "enlarge=300");
	
	get_roi_localizations(1,path);
	get_roi_localizations(2,path);

	
	
	selectImage(fullimage);
}




//path = File.openDialog("open localization file");
roi_number = roiManager("count");
loc = File.getParent(path);
loc = loc + '\\';

//PALM images
open(loc + "ROI_ch1_1.txt.tif");
open(loc + "ROI_ch2_1.txt.tif");
run("Merge Channels...", "c1=ROI_ch1_1.txt.tif c2=ROI_ch2_1.txt.tif create");
rename(11);

open(loc + "ROI_ch1_2.txt.tif");
open(loc + "ROI_ch2_2.txt.tif");
run("Merge Channels...", "c1=ROI_ch1_2.txt.tif c2=ROI_ch2_2.txt.tif create");
rename(22);

run("Concatenate...", "  title=[Concatenated Stacks] image1=11 image2=22");



for (i=3; i<=roi_number; i++){
	open(loc + "ROI_ch1_"+ i+ ".txt.tif");
	open(loc + "ROI_ch2_"+ i+ ".txt.tif");
	run("Merge Channels...", "c1=ROI_ch1_"+ i+ ".txt.tif c2=ROI_ch2_"+ i+ ".txt.tif create");
	
	run("Concatenate...", "  title=[Concatenated Stacks] image1=[Concatenated Stacks] image2=Composite image3=[-- None --]");
}
saveAs("Tiff", loc + "concatenate_PALM.tif");
close();
//original
open(loc + "ROI_ch1_1.txt.original.tif");
open(loc + "ROI_ch1_2.txt.original.tif");
//run("Merge Channels...", "c1=ROI_ch1_1.txt.tif c2=ROI_ch2_.tif create");


run("Concatenate...", "  title=[Concatenated Stacks] image1=ROI_ch1_1.txt.original.tif image2=ROI_ch1_2.txt.original.tif image3=[-- None --]");

for (i=3; i<=roi_number; i++){
	open(loc + "ROI_ch1_"+ i+ ".txt.original.tif");
	run("Concatenate...", "  title=[Concatenated Stacks] image1=[Concatenated Stacks] image2=ROI_ch1_"+ i + ".txt.original.tif image3=[-- None --]");
}
saveAs("Tiff", loc + "concatenate_original.tif");
close();
setBatchMode(false);

function get_roi_localizations(channel,path) {
	//check if roi is selected
	
	run("Results... ", "open=["+path+"]");	

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
	print(x1,x2,y1,y2);
	//***//begin nieuwe code
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

	File.append(ROI_width, roi_file);
	File.append(ROI_height, roi_file);
	File.append(ROI_x1, roi_file);
	File.append(ROI_x2, roi_file);
	File.append(ROI_y1, roi_file);
	File.append(ROI_y2, roi_file);
	File.append(channel, roi_file);
	File.close(f);
}


