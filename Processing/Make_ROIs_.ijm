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
		

for (i = 25; i < files.length; i++) {
	if (endsWith(files[i], "Composite.tif")){
	 	to_analyze = split(files[i], "_");
	 	to_analyze = to_analyze[0]+"_"+to_analyze[1];

		
		ch2= dir +to_analyze +"_Composite.tif";
		
			open(ch2);
			ch2_id= getTitle;
			getPixelSize(unit, pixelWidth, pixelHeight);
			
			waitForUser("Make a ROI");
			 roiManager("reset");
			roiManager("add");
			roiManager("save", dir+to_analyze + ".roi");
			run("Select None");
			run("Duplicate...", "duplicate channels=2");
			roiManager("select", 0);
			setAutoThreshold("Otsu dark");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			roiManager("select", 0);
			run("Set Measurements...", "area mean min centroid redirect=None decimal=3");
			run("Analyze Particles...", "size=0.005-Infinity display clear");
			roiManager("reset");
			for (j = 0; j <  nResults; j++) {
				x = getResult("X", j)/pixelWidth;
				y = getResult("Y", j)/pixelWidth;
				makePoint(x, y);
				run("Enlarge...", "enlarge="+ radius);
				roiManager("add");
			}
			roiManager("save", dir + to_analyze + "_roi.zip");
			close();
			close(ch2_id);
			
			

	}
}
