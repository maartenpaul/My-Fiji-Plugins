dir = getInfo("image.directory");
//imagename_noext = substring(getInfo("image.filename"),0,indexOf(getInfo("image.filename"), "."));
//File.makeDirectory(dir);



run("SM Create Mask From ROI");
saveAs("tiff", "" + dir+"mask-control.tif");