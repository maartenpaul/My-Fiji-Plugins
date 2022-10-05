getDimensions(width, height, channels, slices, frames);
dir = getDirectory("image");
dir = "/home/maarten/Documents/tempp/N2V_3D/";
for (i = 0; i < frames; i++) {
	run("Duplicate...", "duplicate frames="+i+"");
	save(dir+File.separator+IJ.pad(i,3)+".tif");
	close();
}