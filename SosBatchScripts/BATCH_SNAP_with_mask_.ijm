for (j=0;j<list1.length; j++){
			
			list=getFileList(dir+list1[j]);	
			
			for (i=0; i<list.length; i++) {
		     	if (endsWith(list[i], "/")){
		     		print("subfolder2");
		     	} else {
		     		file = dir+list1[j]+list[i];

		     		

		     		if (endsWith(file, "SNAP.lsm")){
		     			else if (endsWith(file, ".lsm")){
							run("Bio-Formats", "open=[" + file+ "] color_mode=Default open_files display_rois rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack");
							File.makeDirectory(dir+list1[j]+File.nameWithoutExtension+ File.separator);
							saveAs("Tiff", dir + list1[j]+File.nameWithoutExtension+ File.separator+File.nameWithoutExtension+".tif");
							
							run("SM Create Mask From ROI");
														
							run("Save", "save=["+dir+"mask.tif]");
							
							close();
							roifile = dir + "mask.zip";
							roiManager("save", roifile);
							roiManager("Select", 0);
							run("Measure");
									
							saveAs("Results",dir+"Mask_results.txt");
							IJ.deleteRows(0, 0);
							close("Results");
							roiManager("Delete");
						
		     		}
		     		}
		     	}
		     }


