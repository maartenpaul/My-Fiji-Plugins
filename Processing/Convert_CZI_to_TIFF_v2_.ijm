   dir = getDirectory("Choose a Directory ");
  
     list1 = getFileList(dir);
     files = 0;
	for (i=0; i<list1.length; i++) {
		if(endsWith(list1[i], "/")!=true&&endsWith(list1[i], "JPG")!=true&&endsWith(list1[i], "txt")!=true){
			files++;
			print("plus");
		} else {
			print("folder");
		}
	}
	print("number of files: " + files+ "and length " + list1.length);
	
	if(list1.length!=0&&files==0){
		
		for (j=0;j<list1.length; j++){
			
			list=getFileList(dir+list1[j]);	
			
			for (i=0; i<list.length; i++) {
		     	if (endsWith(list[i], "/")){
		     		print("subfolder2");
		     	} else {
		     		file = dir+list1[j]+list[i];
		     		if (endsWith(file, "SNAP.czi")){
		     			//print("SNAP");
		     		} else if (endsWith(file, ".czi")){
						run("Bio-Formats", "open=[" + file+ "] color_mode=Default open_files view=Hyperstack stack_order=XYCZT use_virtual_stack");
						file_name = File.nameWithoutExtension;
						File.makeDirectory(dir+list1[j]+File.nameWithoutExtension+ File.separator);
						saveAs("Tiff", dir + list1[j]+File.nameWithoutExtension+ File.separator+File.nameWithoutExtension+".tif");
						close();
						snapfile =  split(file_name, " ");
						
						snapfile_path = dir+list1[j]+snapfile[0] + " SNAP.czi";
						
						if (File.exists(snapfile_path)){
							run("Bio-Formats", "open=[" + snapfile_path+ "] color_mode=Default open_files view=Hyperstack stack_order=XYCZT use_virtual_stack");
							saveAs("Tiff", dir + list1[j]+ file_name+ File.separator+snapfile[0] + " SNAP.tif");
							close();
						}
		     		}
		     	}
		     }
	}
		
	} else if (files!=0){
     	list = list1;
	     for (i=0; i<list.length; i++) {
	     	if (endsWith(list[i], "/")){
	     		print("subfolder");
	     	} else {
	     		file = dir+list[i];
	     		if (endsWith(file, "SNAP.czi")){
	     			print("SNAP");
	     		} else{
					run("Bio-Formats", "open=[" + file+ "] color_mode=Default open_files view=Hyperstack stack_order=XYCZT use_virtual_stack");
					file_name = File.nameWithoutExtension;
					File.makeDirectory(dir+File.nameWithoutExtension+ File.separator);
					saveAs("Tiff", dir + File.nameWithoutExtension+ File.separator+File.nameWithoutExtension+".tif");
					close();
					snapfile =  split(file_name, " ");
						
						snapfile_path = dir+snapfile[0] + " SNAP.czi";
						
						if (File.exists(snapfile_path)){
							run("Bio-Formats", "open=[" + snapfile_path+ "] color_mode=Default open_files view=Hyperstack stack_order=XYCZT use_virtual_stack");
							saveAs("Tiff", dir + file_name+ File.separator+snapfile[0] + " SNAP.tif");
							close();
						}
	     		}
	     	}
	     }
	}