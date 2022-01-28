
roiManager("Add");

run("SM Create Mask From ROI");
dir = File.directory; 

run("Save", "save=["+dir+"mask.tif]");

close();
roifile = dir + "mask.zip";
roiManager("save", roifile);
roiManager("Select", 0);
run("Measure");
		
saveAs("Results",dir+"Mask_results.txt");
IJ.deleteRows(0, 0);
close("Results");
roiManager("Delete");