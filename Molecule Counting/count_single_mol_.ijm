Dialog.create("Set slices for quantification");
Dialog.addNumber("first slice", 1);
Dialog.addNumber("last slice", 2);
Dialog.show(); 

first = Dialog.getNumber();
last = Dialog.getNumber();

stack_id = getImageID();
dir = getInfo("image.directory");
filename = getInfo("image.filename");
filename = split(filename, ".");
filename = filename[0];
roiManager("reset");
roiManager("add");
roiManager("save", dir+File.separator+filename+"_nucleus.roi");
run("Select None");
run("Duplicate...", "duplicate range=" +first + "-"+last+"");
roiManager("select",0);
substack_id = getImageID();
selectImage(substack_id);
Stack.getStatistics(voxelCount, meanbg);
close();
selectImage(stack_id);
run("Select None");
run("32-bit");
run("Subtract...", "value="+ meanbg+" stack");
roiManager("select",0);
run("Duplicate...", "duplicate range=" +first + "-"+last+"");
run("Clear Results");

for (i = 0; i <  nSlices; i++) {
	setSlice(i+1);
roiManager("reset");
run("Select None");
run("Find Maxima...", "noise=400 output=[Single Points]");
run("Analyze Particles...", "add");
close();
for (j = 0; j < roiManager("count"); j++) {
	roiManager("select", j);
	run("Enlarge...", "enlarge=0.5");
	run("Measure");
	//Should deal with ROI's on the border
}

}

//Do gaussian Fit get mean value
intensities = Table.getColumn('IntDen');
Plot.create("Title", "X-axis Label", "Y-axis Label");
 Plot.addHistogram(intensities, 25);
 Plot.show();
  Plot.getValues(xpoints, ypoints);
Fit.doFit('Gaussian', xpoints, ypoints);
Fit.plot();
mean = Fit.p(2);
print(mean);
//Take histogram, get mode

selectImage(stack_id);
run("Select None");
run("Duplicate...", "duplicate range=1-1");
run("Divide...", "value=" + mean +" stack");
run("Save", "save=["+dir+File.separator+filename+"_normalized.tif]");