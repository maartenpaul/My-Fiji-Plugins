#@ File (label="Select folder for ",style="directory") outputfolder
open(outputfolder);
dir = File.getDirectory(outputfolder);
file = File.getName(outputfolder);
run("Z Project...", "projection=[Max Intensity] all");
save(dir+File.separator+"MAX_"+file);