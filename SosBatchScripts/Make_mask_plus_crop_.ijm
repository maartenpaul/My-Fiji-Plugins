
roiManager("Add");

run("SM Create Mask From ROI");
dir = File.directory; 

run("Canvas Size...", "width=256 height=120 position=Center");

run("Save", "save=["+dir+"mask.tif]");

close();
roifile = dir + "mask.zip";
roiManager("save", roifile);
roiManager("Select", 0);

roiManager("Delete");