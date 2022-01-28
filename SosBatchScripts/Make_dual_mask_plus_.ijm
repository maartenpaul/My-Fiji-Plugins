
roiManager("Add");

run("SM Create Mask From ROI");
dir = File.directory; 

snap = getImageID();
run("Save", "save=["+dir+"mask_a.tif]");

run("Invert");
run("Subtract...", "value=155");
selectImage(snap);
saveAs("Tiff", dir+"mask_b.tif]");

roifile = dir + "mask_a.zip";
roiManager("save", roifile);

close();
 roiManager("reset");