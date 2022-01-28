dir = getDirectory("Choose a directory");
files = getFileList(dir);

channels = newArray('647','568','488');

		getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
		print("Start  Date: ",dayOfMonth,"-",month+1,"-",year,"   Time: ",hour,":",minute,":",second);
		roiManager("Reset");
		run("Clear Results");
setOption("ShowRowNumbers", false);
		
		print("\\Clear"); //empties the Log 
		

for (i = 0; i < files.length; i++) {

	if (endsWith(files[i], "647_grouped.txt")){
	 	to_analyze = split(files[i], "_");
	 	to_analyze = to_analyze[0]+"_"+to_analyze[1];
		
			ch1= dir +to_analyze + "_" + channels[0]+"_grouped.txt";
			run("Render Elyra to TS ", "open=["+ch1+"]");
			ch1_id= getTitle;
			ch2= dir +to_analyze + "_" + channels[1]+"_grouped_aligned.txt";
		
			run("Render Elyra to TS ", "open=["+ch2+"]");
			ch2_id= getTitle;
			ch3= dir +to_analyze + "_" + channels[2]+"_grouped_aligned.txt";
		
			run("Render Elyra to TS ", "open=["+ch3+"]");
			ch3_id= getTitle;
		
		
			run("Merge Channels...", "c1="+ch1_id+" c2="+ch2_id+" c3="+ch3_id+" create");
			save(dir+to_analyze+"_Composite.tif");
			close();
	}
}