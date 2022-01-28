dir = getDirectory("Choose a directory");
list = getFileList(dir);
path1 = dir + File.separator+ "parameters.txt"
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "/")){
		file = dir+list[i]+"mask.tif";
		if(File.exists(file)){
		open(file);
		setThreshold(46, 151);
		run("Convert to Mask");
		run("Analyze Particles...", "display clear summarize");
		
		area = getResult("Area", 0);
		saveAs("Results",dir+list[i]+"Mask_results.txt");
		print(dir+list[i]+"Mask_results.txt");
		close();
		//print(area);
		}
	}
}
