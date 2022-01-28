id=getImageID();
roiManager("reset");
run("Clear Results");
dir = getInfo("image.directory");
filename = getInfo("image.filename");
filename = split(filename,".");
filename =filename[0];


//Duplicate DAPI image, set threshold, select Nuclei
run("Duplicate...", "duplicate channels=1");
run("Gaussian Blur...", "sigma=1");
setAutoThreshold("IsoData dark no-reset");
run("Analyze Particles...", "size=100-350 exclude clear include add slice");
close();
run("Select All");
roiManager("Save", dir+File.separator+filename+"_ROI.zip");
//Select original BRCA2 images and measure intensity in nuclei
selectImage(id);
setSlice(2);
roiManager("multi-measure");
saveAs("Results", dir+File.separator+filename+"measurements.txt");
run("Clear Results");
run("Select None");
run("Duplicate...", "duplicate channels=2");
run("Gaussian Blur...", "sigma=2");
getRawStatistics(nPixels, mean, min, max, std, histogram);
minInt = mean+4*std;
setThreshold(minInt, 65535);
setOption("BlackBackground", true);
run("Convert to Mask");
id2 = getImageID();
for(i=0; i<roiManager("Count");i++) {
roiManager("Select",i);
j=i+1;
roiManager("Rename",j);
}

for (i=0 ; i<roiManager("count"); i++) {
    selectImage(id2);
    roiManager("select", i);
    run("Analyze Particles...", "size=0.01-100.00 display exclude include summarize");
}
	selectImage(id2);
	close();
  selectWindow("Summary");
  saveAs("Text",  dir+File.separator+filename+"_Foci_Summary.txt");
