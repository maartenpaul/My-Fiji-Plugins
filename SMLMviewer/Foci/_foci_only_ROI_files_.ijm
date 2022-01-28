path = File.openDialog("open localization file");

fullimage = getImageID();
print(fullimage);

roi_file = File.directory + "ROI_list.txt";
for (i=0; i<roiManager("count"); i++){
		roiManager("select", i)	;
		Roi.getBounds(sel_x,sel_y,sel_width,sel_height);
		//print(sel_x,sel_y,sel_width,sel_height);
		getPixelSize(unit, pixelWidth, pixelHeight);
		x1=sel_x*pixelWidth;
		x2=(sel_x+sel_width)*pixelWidth;
		y1=sel_y*pixelWidth;
		y2=(sel_y+sel_height)*pixelWidth;
		
		ROI_x1 = "ROI x1 " + "\t" +  x1;
		ROI_x2 = "ROI x2 " + "\t" +  x2;
		ROI_y1 = "ROI y1 " + "\t" +  y1;
		ROI_y2 = "ROI y2 " + "\t" +  y2;

		boundaries = "" + x1 + "\t" + x2+ "\t" + y1+ "\t" + y2 ;
		File.append(boundaries, roi_file);
		selectImage(fullimage);
}