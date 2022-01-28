dir = getDirectory("Choose a directory");
list = getFileList(dir);
print(list.length);
for (i=0; i<list.length; i++) {
	
	if (endsWith(list[i], "/")){
	
		
		
		image1 = dir+list[i] + File.getName(dir+list[i])+".tif";
		open(image1);
		image1_id = getImageID();

		histogram = dir+list[i] + "parameters.histogram.tif";
		open(histogram);
		histogram_id = getImageID();
		selectImage(histogram_id);
		roiManager("reset");
		 roiManager("open", dir+list[i]+ "histogram.roi");
		 

	selectImage(image1_id);
	run("SM Filter Results using ROI");

	
		
		
		selectImage(histogram_id);
		close();
		selectImage(image1_id);
		close();
		 roiManager("reset");
	}
}