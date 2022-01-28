path = File.openDialog("open localization file");

fullimage = getImageID();
print(fullimage);
for (i=0; i<roiManager("count"); i++){
		roiManager("select", i)	;
		Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
		print(sel_x,sel_y,sel_width,sel_height);
		getPixelSize(unit, pixelWidth, pixelHeight);
		x1=sel_x*pixelWidth;
		x2=(sel_x+sel_width)*pixelWidth;
		y1=sel_y*pixelWidth;
		y2=(sel_y+sel_height)*pixelWidth;
		print(x1,x2,y1,y2);
		ROI_width = "Width \t" + sel_width*pixelWidth; 
		ROI_height	= "Height \t" + sel_height*pixelWidth;
		ROI_x1 = "ROI x1 " + "\t" +  x1;
		ROI_x2 = "ROI x2 " + "\t" +  x2;
		ROI_y1 = "ROI y1 " + "\t" +  y1;
		ROI_y2 = "ROI y2 " + "\t" +  y2;
		

		roi_file = File.directory + "ROI" + "_" + i + ".txt";

			File.append(ROI_width, roi_file);
			File.append(ROI_height, roi_file);
			File.append(ROI_x1, roi_file);
			File.append(ROI_x2, roi_file);
			File.append(ROI_y1, roi_file);
			File.append(ROI_y2, roi_file);
			
			
		
	
		selectImage(fullimage);
}