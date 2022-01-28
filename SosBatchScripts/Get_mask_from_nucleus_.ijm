dir = getDirectory("Choose a Directory ");
  
list1 = getFileList(dir);
    
	for (j=0; j<list1.length; j++) {
		if(endsWith(list1[j], "/")==true){
			//print(list1.length);
			list=getFileList(dir+list1[j]);	
			
			for (i=0; i<list.length; i++) {
		     	
		     	if (endsWith(list[i], "/")){
		     		print("subfolder2");
		     	} else {
		     		file = dir+list1[j]+list[i];
		     		if (endsWith(file, "SNAP.lsm")){
		     			//print("SNAP");
		     			roiManager("reset");
						run("Bio-Formats", "open=[" + file+ "] color_mode=Default open_files view=Hyperstack stack_order=XYCZT use_virtual_stack");
						dir2 = File.directory; 
						run("Duplicate...", " ");
						run("Gaussian Blur...", "sigma=2");
						setAutoThreshold("Huang dark");
						setOption("BlackBackground", false);
						run("Convert to Mask");
						run("Dilate");
						run("Dilate");
						run("Fill Holes");
						run("Analyze Particles...", "size=500-Infinity pixel clear add");
						if(roiManager("count")==1){
							roiManager("Select", 0);
							run("SM Create Mask From ROI");
							saveAs("Tiff", dir2 + File.separator+"mask.tif");
							close();
							roifile = dir2 +   File.separator+"mask.zip";
							roiManager("save", roifile);
							roiManager("Select", 0);
							run("Measure");
							saveAs("Results",dir2+ File.separator+"Mask_results.txt");
							IJ.deleteRows(0, 0);
							close("Results");
							roiManager("Delete");
						} else if(roiManager("count")==0){
							print("no ROIs");
						} else if(roiManager("count")>1){
							print("more than 1 ROI");
						}
						
						close();
						close();
		     		}
		     	}
		     }
	}
	}
