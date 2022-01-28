dir = getDirectory("Select folder with tracking data");
file = "D:\\files.txt"
//f = File.open(file);
	 	
list1 = getFileList(dir);
     for (i=0; i<list1.length; i++) {
		if(endsWith(list1[i], "/")==true){
			p = dir + File.separator + list1[i];
			File.append(p, file) 		
		}
     }
//File.close(f);