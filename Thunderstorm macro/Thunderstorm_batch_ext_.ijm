dir = getDirectory("Choose a directory");
to_analyze = newArray('001','002','003');
channels = newArray('647','568','488');
overwrite = false;


setOption("ShowRowNumbers", false);

print("\\Clear"); //empties the Log 

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Start  Date: ",dayOfMonth,"-",month+1,"-",year,"   Time: ",hour,":",minute,":",second);
roiManager("Reset");
run("Clear Results");

for (i=0; i<to_analyze.length; i++) {
	TS_file_beads_ch1= "";
	TS_file_beads_ch2= "";
	TS_file_beads_ch3= "";
	alignment_file= "";
	TS_file ="";
	TS_file_beads = "";
	renderfile = "";
	file = "";
	
	
	//find beads in ch1
	file = dir + to_analyze[i] + "_" + channels[0]+"_ungrouped.txt";
	TS_file = dir + to_analyze[i] + "_" + channels[0]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[0]+"_ungrouped_TS.csv";
	TS_file_beads = dir + to_analyze[i] + "_" + channels[0]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[0]+"_ungrouped_TS_beads.csv";
	TS_file_beads_ch1 = TS_file_beads;
	
	print(file);

	if (File.exists(TS_file)&&File.exists(TS_file_beads)&&!overwrite){
		print("TS files already exists");
	} else {
		run("Convert Elyra to TS ", "open=["+file+"]");
		if (File.exists(TS_file)){
			run("Import results", "detectmeasurementprotocol=true filepath=["+TS_file+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");
			run("Show results table", "action=merge zcoordweight=0.1 offframes=500 dist=50.0 framespermolecule=0");
			run("Show results table", "action=filter formula=detections>1000");
			run("Show results table", "action=merge zcoordweight=0.1 offframes=12000 dist=100.0 framespermolecule=0");
			run("Export results", "floatprecision=5 filepath=["+ TS_file_beads +"] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false chi2=false uncertainty_xy=true frame=true");
		} else {
			print("File " + TS_file +" does not exist (problem with import).");
			continue; 
		}
	}
	//find beads in ch2
	file = dir + to_analyze[i] + "_" + channels[1]+"_ungrouped.txt";
	print(file);
	
	TS_file = dir + to_analyze[i] + "_" + channels[1]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[1]+"_ungrouped_TS.csv";
	TS_file_beads = dir + to_analyze[i] + "_" + channels[1]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[1]+"_ungrouped_TS_beads.csv";
	TS_file_beads_ch2 = TS_file_beads;

	if (File.exists(TS_file)&&File.exists(TS_file_beads)&&!overwrite){
		print("TS files already exists");
	} else {
		run("Convert Elyra to TS ", "open=["+file+"]");
		if (File.exists(TS_file)){
			run("Import results", "detectmeasurementprotocol=true filepath=["+TS_file+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");
			run("Show results table", "action=merge zcoordweight=0.1 offframes=500 dist=50.0 framespermolecule=0");
			run("Show results table", "action=filter formula=detections>1000");
			run("Show results table", "action=merge zcoordweight=0.1 offframes=12000 dist=100.0 framespermolecule=0");
			run("Export results", "floatprecision=5 filepath=["+ TS_file_beads +"] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false chi2=false uncertainty_xy=true frame=true");
		} else {
			print("File " + TS_file +" does not exist (problem with import).");
			continue; 
		}
	}

	//align channel 1 and 2
	run("Multi Channel beads ThunderSTORM", "select_primary=["+TS_file_beads_ch1+"] select_secondary=["+TS_file_beads_ch2+"]");
	alignment_file = dir+to_analyze[i] + "_"+ channels[0] + "_"+channels[1]+"_alignment.txt";
	print(alignment_file);
	run("Channel alignment", "select=1 select_0=2 save=["+alignment_file+"]");
		
	if (!File.exists(alignment_file)){
		print("Alignment"+to_analyze[i] + "between"+channels[0]+"_"+channels[1]+" was unsuccesful");
	} else {
		saveAs("Results", dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[1]+"_beads_alignment.txt");	
		run("Clear Results");
		file_align = dir + to_analyze[i] + "_" + channels[1]+"_grouped.txt";
		run("Clear Results"); 
		run("Results... ", "open=["+file_align+"]");
		setOption("ShowRowNumbers",false);
	  	updateResults;
		IJ.deleteRows(getValue("results.count")-16, getValue("results.count"));	
		run("Apply Channel alignment", "open=[" + alignment_file+"]");
		saveAs("Results", dir + to_analyze[i] + "_" + channels[1]+"_grouped_aligned.txt");
		run("Clear Results");		

		//restore the footer of the Elyra localization file
		data = File.openAsString(file_align);
		data = split(data,"\n");
		nrows = lengthOf(data);
		data = Array.slice(data,(nrows-17),nrows);
		for (j = 0; j < data.length; j++) {
			p = data[j];
			File.append(p, dir + to_analyze[i] + "_" + channels[1]+"_grouped_aligned.txt");
		}
		
		//do also for ungrouped file
		file_align = dir + to_analyze[i] + "_" + channels[1]+"_ungrouped.txt";
		run("Clear Results"); 
		run("Results... ", "open=["+file_align+"]");
		setOption("ShowRowNumbers",false);
	  	updateResults;
		IJ.deleteRows(getValue("results.count")-16, getValue("results.count"));	
		run("Apply Channel alignment", "open=[" + alignment_file+"]");
		saveAs("Results", dir + to_analyze[i] + "_" + channels[1]+"_ungrouped_aligned.txt");		
		run("Clear Results");
		//restore the footer of the Elyra localization file
		data = File.openAsString(file_align);
		data = split(data,"\n");
		nrows = lengthOf(data);
		data = Array.slice(data,(nrows-17),nrows);
		for (j = 0; j < data.length; j++) {
			p = data[j];
			File.append(p, dir + to_analyze[i] + "_" + channels[1]+"_ungrouped_aligned.txt");
		}
		
		//render files
		renderfile = dir + to_analyze[i] + "_" + channels[0]+"_ungrouped.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		run("Results... ", "open=["+dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[1]+"_beads_alignment.txt]");
		
		run("Results Table to ROI");
		imID = getImageID();

		if(roiManager("count")>0){
			roiManager("Delete");
		}
		run("To ROI Manager");
		run("Select All");
		roiManager("Save", dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[1]+"_alignment_ROI.zip");
		if(roiManager("count")>0){
			roiManager("Delete");
		}
		close(imID);
		renderfile = dir + to_analyze[i] + "_" + channels[0]+"_grouped.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		close();
		renderfile = dir + to_analyze[i] + "_" + channels[1]+"_ungrouped_aligned.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		close();
		renderfile = dir + to_analyze[i] + "_" + channels[1]+"_grouped_aligned.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		close();
	}

	//apply alignment
	
	//if 3rd channel present find also beads there
	if (channels.length==3){
		file = dir + to_analyze[i] + "_" + channels[2]+"_ungrouped.txt";
		TS_file = dir + to_analyze[i] + "_" + channels[2]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[2]+"_ungrouped_TS.csv";
		TS_file_beads = dir + to_analyze[i] + "_" + channels[2]+"_ungrouped" + File.separator + to_analyze[i] + "_" + channels[2]+"_ungrouped_TS_beads.csv";
		TS_file_beads_ch3 = TS_file_beads;
	
		print(file);
		if (File.exists(TS_file)&&File.exists(TS_file_beads)&&!overwrite){
			print("TS files already exists");
		} else {
			run("Convert Elyra to TS ", "open=["+file+"]");
			if (File.exists(TS_file)){
				run("Import results", "detectmeasurementprotocol=true filepath=["+TS_file+"] fileformat=[CSV (comma separated)] livepreview=false rawimagestack= startingframe=1 append=false");
				run("Show results table", "action=merge zcoordweight=0.1 offframes=12000 dist=50.0 framespermolecule=0");
				run("Show results table", "action=filter formula=detections>2000");
				run("Export results", "floatprecision=5 filepath=["+ TS_file_beads +"] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false chi2=false uncertainty_xy=true frame=true");
			} else {
				print("File " + TS_file +" does not exist (problem with import).");
				continue; 
			}
		}
		//align channel 1 and 3
		run("Multi Channel beads ThunderSTORM", "select_primary=["+TS_file_beads_ch1+"] select_secondary=["+TS_file_beads_ch3+"]");
		alignment_file = dir+to_analyze[i] + "_"+ channels[0] + "_"+channels[2]+"_alignment.txt";
		run("Channel alignment", "select=1 select_0=2 save=["+alignment_file+"]");
		if (!File.exists(alignment_file)){
			print("Alignment"+to_analyze[i] + "between"+channels[0]+"_"+channels[2]+" was unsuccesful");
		} else {
			saveAs("Results", dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[2]+"_beads_alignment.txt");		
			file_align = dir + to_analyze[i] + "_" + channels[2]+"_grouped.txt";
			run("Clear Results"); 
			run("Results... ", "open=["+file_align+"]");
			setOption("ShowRowNumbers",false);
	  		updateResults;
			IJ.deleteRows(getValue("results.count")-16, getValue("results.count"));	
			run("Apply Channel alignment", "open=[" + alignment_file +"]");
			saveAs("Results", dir + to_analyze[i] + "_" + channels[2]+"_grouped_aligned.txt");	
			//restore the footer of the Elyra localization file
			data = File.openAsString(file_align);
			data = split(data,"\n");
			nrows = lengthOf(data);
			data = Array.slice(data,(nrows-17),nrows);
			for (j = 0; j < data.length; j++) {
				p = data[j];
				File.append(p, dir + to_analyze[i] + "_" + channels[2]+"_grouped_aligned.txt");
			}	
			file_align = dir + to_analyze[i] + "_" + channels[2]+"_ungrouped.txt";
			run("Clear Results"); 
			run("Results... ", "open=["+file_align+"]");
			IJ.deleteRows(getValue("results.count")-16, getValue("results.count"));	
			run("Apply Channel alignment", "open=[" + alignment_file +"]");
			saveAs("Results", dir + to_analyze[i] + "_" + channels[2]+"_ungrouped_aligned.txt");	
			//restore the footer of the Elyra localization file
			data = File.openAsString(file_align);
			data = split(data,"\n");
			nrows = lengthOf(data);
			data = Array.slice(data,(nrows-17),nrows);
			for (j = 0; j < data.length; j++) {
				p = data[j];
				File.append(p, dir + to_analyze[i] + "_" + channels[2]+"_ungrouped_aligned.txt");
			}
			//render files
		renderfile = dir + to_analyze[i] + "_" + channels[2]+"_ungrouped_aligned.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		run("Results... ", "open=["+dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[2]+"_beads_alignment.txt]");
		
		run("Results Table to ROI");
		imID = getImageID();

		if(roiManager("count")>0){
			roiManager("Delete");
		}
		run("To ROI Manager");
		run("Select All");
		roiManager("Save", dir + to_analyze[i] + "_"+ channels[0] + "_"+channels[2]+"_alignment_ROI.zip");
		if(roiManager("count")>0){
			roiManager("Delete");
		}
		close(imID);
		
		renderfile = dir + to_analyze[i] + "_" + channels[2]+"_grouped_aligned.txt";
		run("Render Elyra to TS ", "open=[" + renderfile + "]");
		close();	
		}
	}
}

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("Finished Time: ",hour,":",minute,":",second);
print("Done");
selectWindow("Log");  //select Log-window
saveAs("Text", dir+File.separator + "batch.txt"); 
