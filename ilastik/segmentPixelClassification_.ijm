#@ File[] (label = "Input files", style="File") files
#@ File (label = "Output folder", style = "directory") outputFolder
#@ File (label = "ilastik project file", style="File") project

type = "Probabilities";
//set measurements
run("Set Measurements...", "area mean standard centroid center perimeter bounding fit feret's integrated median display redirect=None decimal=3");
roiManager("Reset");
run("Clear Results");
//run files
//setBatchMode(true);
nrOfImages = files.length;
if(!File.exists(outputFolder)) {
 	File.makeDirectory(outputFolder);
}
for (f = 0; f < nrOfImages; f++) {
	print("\nProcessing file "+f+1+"/"+nrOfImages+": "+files[f] + "\n");
	processFile(f, files[f], outputFolder, project);
}
saveAs("Results", outputFolder + File.separator + "Results.csv");
run("Clear Results");

function processFile(current_image_nr, input, outputFolder, project){
	run("Close All");
	//run prediction
	open(input);
	inputImage = getImageID();
	run("Run Pixel Classification Prediction", "projectfilename=[" + project + "] pixelclassificationtype=[" + type + "]");
	classImage = getImageID();
	//run segmentation on single channel 
	run("Duplicate...", "duplicate channels=1");
	processProbabilityImage(0.5,1);
	selectImage(classImage);
	run("Duplicate...", "duplicate channels=2");
	processProbabilityImage(0.5,2);
	selectImage(classImage);
	close(classImage);
	close(inputImage);
}

function processProbabilityImage(threshold,channel){
	channelImage = getImageID();
	rename(current_image_nr+"_"+channel);
	setAutoThreshold("Default dark no-reset");
//run("Threshold...");
	setThreshold(threshold, 1000000000000000000000000000000.0000);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Erode");
	run("Erode");
	run("Dilate");
	run("Dilate");
	run("Fill Holes");
	run("Analyze Particles...", "size=2000-Infinity display exclude add");
	saveAs("Results", outputFolder + File.separator + "Results"+ current_image_nr+"_"+channel+".csv");
	//run("Flatten");
	//saveAs("Tiff", outputFolder + File.separator + "Results"+ current_image_nr+"_"+channel+".tif");
	//close();
	close(channelImage);

}

