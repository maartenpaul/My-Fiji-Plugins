dir = getDirectory("Choose a directory");
list = getFileList(dir);
print(list.length);
for (i=0; i<list.length; i++) {
	
	if (endsWith(list[i], "/")){
	
		
		image1 = dir+list[i] + File.getName(dir+list[i])+".tif";
		open(image1);
		image1_id = getImageID();

		selectImage(image1_id);
		run("SM Simple Tracking", "detections_name=detections.filtered.txt");
		run("Close");
	
		
		
		selectImage(image1_id);
		close();
		
	}
}