#@ File[] (label="Select files for analysis",style="files") list


for (i=0; i<list.length; i++) {
	
 	if (endsWith(list[i], "tif")){
    	open(list[i]);
    	directory = getDir("image");
		filename = File.getNameWithoutExtension(getInfo("image.filename"));
    	run("Enhance Contrast...", "saturated=0 process_all");
    	save(directory+File.separator+filename+"_norm.tif"); 	
    	close();
}