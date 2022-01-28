dir = getInfo("image.directory");
print(dir);
filename = getInfo("image.filename");
filename = split(filename, ".");
filename = filename[0];
print(filename);
run("Z Project...", "projection=[Max Intensity] all");
im_id = getImageID();
Stack.getDimensions(width, height, channels, slices, frames) ;
print(frames);
for (i = 1; i <= frames; i++) {
	run("Duplicate...", "duplicate frames="+i+"");
	run("Save", "save=["+dir+File.separator+filename+"_"+ i +".tif]");
	close();
	selectImage(im_id);
}
