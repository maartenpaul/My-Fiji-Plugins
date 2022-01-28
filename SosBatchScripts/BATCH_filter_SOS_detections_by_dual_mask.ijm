dir = getDirectory("Choose a directory");
list = getFileList(dir);
print(list.length);
for (i=0; i<list.length; i++) {
	
	if (endsWith(list[i], "/")){
	
		mask = dir+list[i] + "mask_a.tif";
		open(mask);
		mask_image = getImageID();
	
		
		file = dir+list[i] + "detections.txt";
		run("Results... ", "open=[" + file + "]");
		
		new_file = File.getParent(file)+ File.separator + "detections_a.txt";
		//all_file = File.getParent(file)+ File.separator + "detections_all.txt";
		
				f = File.open(new_file);
			
				for(j=0; j<nResults; j++){
					if (getPixel(floor(getResult("C1", j)), floor(getResult("C2", j)))==100) {
						p = "" + getResult("C1",j)+ "\t"+ getResult("C2",j)+ "\t"+ getResult("C3",j)+ "\t"+ getResult("C4",j)+ "\t"+ getResult("C5",j)+ "\t"+ getResult("C6",j)+ "\t"+ getResult("C7",j)+ "\t"+ getResult("C8",j)+ "\t"+ getResult("C9",j)+ "\t"+ getResult("C10",j);
						print(f,p);
					}
				}
			
				File.close(f);
		
		//File.rename(file, all_file);		
		//File.rename(new_file,file);		
		
		
		if (isOpen("Results")) {
			selectWindow("Results");
			run("Close");
		}
		selectImage(mask_image);
		close();

		//b
		mask = dir+list[i] + "mask_b.tif";
		open(mask);
		mask_image = getImageID();
	
		
		file = dir+list[i] + "detections.txt";
		run("Results... ", "open=[" + file + "]");
		
		new_file = File.getParent(file)+ File.separator + "detections_b.txt";
		//all_file = File.getParent(file)+ File.separator + "detections_all.txt";
		
				f = File.open(new_file);
			
				for(j=0; j<nResults; j++){
					if (getPixel(floor(getResult("C1", j)), floor(getResult("C2", j)))==100) {
						p = "" + getResult("C1",j)+ "\t"+ getResult("C2",j)+ "\t"+ getResult("C3",j)+ "\t"+ getResult("C4",j)+ "\t"+ getResult("C5",j)+ "\t"+ getResult("C6",j)+ "\t"+ getResult("C7",j)+ "\t"+ getResult("C8",j)+ "\t"+ getResult("C9",j)+ "\t"+ getResult("C10",j);
						print(f,p);
					}
				}
			
				File.close(f);
		
		//File.rename(file, all_file);		
		//File.rename(new_file,file);		
		
		
		if (isOpen("Results")) {
			selectWindow("Results");
			run("Close");
		}
		selectImage(mask_image);
		close();
	}
}