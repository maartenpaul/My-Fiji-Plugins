//Script to save ROI selection from SMLM Viewer images to indiviual files, exporting single molecule data and different visualizations
path_img = File.openDialog("select PALM/STORM image");
path = File.openDialog("open localization .loc file");
path_ROI = File.openDialog("Select ROI.zip");
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
	run("02 SMLM viewer ", "title=[SMLM image #1] grid=2 gauss roi multilut=Red-Green open=["+ path+ "]");	
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