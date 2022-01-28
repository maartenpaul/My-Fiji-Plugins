dir = getDirectory("Choose a directory");
files = getFileList(dir);
radius = 0.5;
channels = newArray('647','568','488');

		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print("Start  Date: ",dayOfMonth,"-",month+1,"-",year,"   Time: ",hour,":",minute,":",second);
		roiManager("Reset");
		run("Clear Results");
setOption("ShowRowNumbers", false);
		
		print("\\Clear"); //empties the Log 
		

for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], "Composite.tif")){
	 	to_analyze = split(files[i], "_");
	 	to_analyze = to_analyze[0]+"_"+to_analyze[1];

		
		ch2= dir +to_analyze +"_Composite.tif";
		
			open(ch2);
			ch2_id= getTitle;
			getPixelSize(unit, pixelWidth, pixelHeight);
			roiManager("reset");
			setTool("point");
			
			while(IJ.getToolName()=="point" ){
				getCursorLoc(x,y,z,flags);
				if(flags==16){
					wait(50);
					makePoint(x, y);
						run("Enlarge...", "enlarge="+ radius);
						roiManager("add");
					}
				if(flags==17){
					print("Clicker stopped");
					exit;
					roiManager("save", dir + to_analyze + "_manual_roi.zip");

				}
			}
			close(ch2_id);
			
			

	}
}
