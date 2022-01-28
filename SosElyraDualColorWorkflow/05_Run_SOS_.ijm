

dir1 = getInfo("image.directory");
//imagename_noext = substring(getInfo("image.filename"),0,indexOf(getInfo("image.filename"), "."));
dir = dir1+ File.separator + getInfo("image.filename");
close();
print(dir);
run("SOS (multithread and mixture)", "select="+ dir);