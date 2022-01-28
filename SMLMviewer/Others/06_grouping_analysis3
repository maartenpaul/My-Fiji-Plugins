dir = getDirectory("Choose a Directory ");
list = getFileList(dir);
print(list.length);
fullimage = getImageID();
setBatchMode(true); 
 for (i=0; i<list.length; i++) {
        if (endsWith(list[i], "/")){
		
		filename = substring(list[i], 0, lengthOf(list[i])-1);
		print(filename);
		run("02 SMLM viewer v0 4 ", "title=[SMLM image #1] grid=1 gauss roi lut=[Red Hot] open=[C:\\Users\\643003\\Desktop\\grouping\\" + filename + "\\" + filename + ".loc]");        
		run("Flatten");
		saveAs("Tiff", "C:\\Users\\643003\\Desktop\\grouping\\" + filename + "\\" + filename + ".tif");
		close();
		close();
     	}
     selectImage(fullimage);	
 }
setBatchMode(false);

