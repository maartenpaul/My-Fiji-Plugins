originalImage = getImageID();

getDimensions(width, height, channels, slices, frames);

run("Duplicate...", "duplicate frames=1");
sliceImage = getImageID();
run("Run Pixel Classification Prediction", "projectfilename=/home/maarten/mSG_R51_decon.ilp pixelclassificationtype=Probabilities");
probImage = getImageID();
selectImage(sliceImage);
close();
selectImage(probImage);

run("Duplicate...", "duplicate channels=1");
probImageC1 = getImageID();
selectImage(probImage);
close();
selectImage(probImageC1);
setAutoThreshold("Default dark no-reset");
//run("Threshold...");
setThreshold(0.500, 1000000000000000000000000000000.0000);
setOption("BlackBackground", true);
run("Convert to Mask", "background=Dark black");
rename("mask_stack");

for (i = 2; i < frames; i++) {
	selectImage(originalImage);
	run("Duplicate...", "duplicate frames="+i+"");
	sliceImage = getImageID();
	run("Run Pixel Classification Prediction", "projectfilename=/home/maarten/mSG_R51_decon.ilp pixelclassificationtype=Probabilities");
	probImage = getImageID();
	selectImage(sliceImage);
	close();
	selectImage(probImage);
	run("Duplicate...", "duplicate channels=1");
	probImageC1 = getImageID();
	selectImage(probImage);
	close();
	setAutoThreshold("Default dark no-reset");
	//run("Threshold...");
	setThreshold(0.500, 1000000000000000000000000000000.0000);
	setOption("BlackBackground", true);
	run("Convert to Mask", "background=Dark black");
	rename("mask_image");
	save("/home/maarten/Documents/tempp/mSG"+File.separator +IJ.pad(i, 3)+".tif");
	run("Concatenate...", "open image1=mask_stack image2=mask_image image4=[-- None --]");
	rename("mask_stack");
}


