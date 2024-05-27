#@ File[] (label = "Input files", style="File") files
#@ File (label = "Output folder", style = "directory") outputFolder
#@ File (label = "ilastik project file", style="File") projectFile
#@ Integer (label = "Spheroid channel", value = 1) spheroidChannel
#@ Integer (label = "Core channel", value = 2) coreChannel
#@ Integer (label = "Background channel", value = 3) backgroundChannel
#@ Boolean (label ="save Segmentation",value = true) saveSegmentation
#@ Boolean (label ="run segmentation",value = true) runSegmentation
#@ Boolean (label ="merge Results",value = true) mergeResults

//set measurements
run("Set Measurements...", "area mean standard centroid center perimeter bounding fit feret's integrated median display redirect=None decimal=3");
roiManager("Reset");
run("Clear Results");

//run files
nrOfImages = files.length;
if(!File.exists(outputFolder)) {
 	File.makeDirectory(outputFolder);
}
if (runSegmentation){
	for (f = 0; f < nrOfImages; f++) {
		tableName = "SpheroidResults";
		Table.create(tableName);	
		print("\nProcessing file "+f+1+"/"+nrOfImages+": "+files[f] + "\n");
		processFile(f, files[f], outputFolder, projectFile,tableName,spheroidChannel,coreChannel,backgroundChannel,saveSegmentation);
	
	}
}
if (mergeResults){
	mergeTables(files,outputFolder);	
}

function processFile(current_image_nr, input, outputFolder, projectFile,tableName,spheroidChannel,coreChannel,backgroundChannel,saveSegmentation){
	run("Close All");

	open(input);
	
	//check if RGB image then convert to 8bit
	bit = bitDepth();
	if (bit != 8.0){
		run("8-bit");
		run("8-bit");
		// it appears to not always apply the conversion in one time so running the command twice seems to help
	}

	inputFileName = File.nameWithoutExtension;
	inputImage = getTitle();
	//run prediction
	run("Run Pixel Classification Prediction", "projectfilename=[" + projectFile + "] pixelclassificationtype=Probabilities");
	classImage = getTitle();
	setBatchMode(true);
	//calculate size of individual spheroids and determine core
	getSpheroid(0.5,classImage,inputImage,tableName,inputFileName,spheroidChannel,coreChannel,backgroundChannel,saveSegmentation);	

	close(classImage);
	close(inputImage);
	setBatchMode("exit and display");
}

function getSpheroid(threshold,classImage,inputImage,tableName,inputFileName,spheroidChannel,coreChannel,backgroundChannel,saveSegmentation){
	close("Roi Manager");
	close("Results");
	//extract individual spheroids using the background channel
	run("Duplicate...", "duplicate channels="+backgroundChannel+"");
	rename(inputFileName+"_prediction");
	channelImage = getTitle();
	setAutoThreshold("Default dark no-reset");
	setThreshold(threshold, 1000000000000000000000000000000.0000);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Invert");
	run("Erode");
	run("Erode");
	run("Dilate");
	run("Dilate");
	run("Fill Holes");

	run("Analyze Particles...", "size=2000-Infinity display exclude add");
	roiManager("save", outputFolder+File.separator+"Rois_"+inputFileName+".zip");
	if (saveSegmentation){
		selectImage(classImage);
		run("Duplicate...", "  channels="+coreChannel+"");
		subsetImage = getTitle();
		run("Select All");
		roiManager("Set Color", "red");
		roiManager("OR");
		run("Clear Outside");
	
		setThreshold(threshold, 1000000000000000000000000000000.0000);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		run("Fill Holes");
		run("Analyze Particles...", "size=2000-Infinity exclude add");
		selectImage(inputImage);
		roiManager("show all with labels");
		run("Flatten");
		save(outputFolder+File.separator+"masks_"+inputFileName+".tif");
		close();
		selectImage(subsetImage);	
		close();
		roiManager("save", outputFolder+File.separator+"Rois_all_"+inputFileName+".zip");
		roiManager("reset");
		roiManager("open", outputFolder+File.separator+"Rois_"+inputFileName+".zip");
	}
	selectWindow("Results");
	Table.showRowIndexes(false);	
	//copy results to new table

	tableHeadingsStr=Table.headings;
	tableHeadings=split(tableHeadingsStr,"\t");
	nHeadings = tableHeadings.length;
	//print(nHeadings);
	resultName = "Results";
	
	for (i =0; i < nHeadings; i++) {
		column= Table.getColumn(tableHeadings[i],resultName);
		Table.setColumn(tableHeadings[i], column,tableName); 

	}

	
	for (i = 0; i < roiManager("size"); i++) {
		print(i);
		run("Clear Results");
		selectImage(classImage);
		roiManager("Select", i);
		//duplicate core to measure its size
		run("Duplicate...", "  channels="+coreChannel+"");
		rename(inputFileName+"_prediction_core");
		setAutoThreshold("Default dark no-reset");
		//run("Threshold...");
		setThreshold(threshold, 1000000000000000000000000000000.0000);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Erode");
		run("Erode");
		run("Dilate");
		run("Dilate");
		run("Fill Holes");
		cropImage=getTitle();
		setOption("Changes", false);
		run("Analyze Particles...", "size=2000-Infinity display exclude");	
		selectWindow("Results");
		Table.showRowIndexes(false);
		numberParticles = Table.size;
		//check if a spheroid core is found and if more ROIs are found pick the largest
		if (numberParticles==0){
			print("no core found");
		} else if (numberParticles>1){
			ParticleArea=Table.getColumn("Area");
			rankPosArr = Array.rankPositions(ParticleArea);
			rankPosArr = Array.reverse(rankPosArr);
			largestObject = rankPosArr[0];
		} else {
			largetstObject= 0;
		}
		if (numberParticles!=0){ 
			tableHeadingsStr=Table.headings;
			tableHeadings=split(tableHeadingsStr,"\t");
			nHeadings = tableHeadings.length;
			for (j =0; j < nHeadings; j++) {
				column= Table.getColumn(tableHeadings[j],resultName);
				headingName = "Core_"+ tableHeadings[j];
				print(headingName);

				Table.set(headingName, i,column[largetstObject],tableName); 
			}
		}
		close(cropImage);
		selectWindow(tableName);
		Table.update;
	}
	roiManager("reset");
	close(channelImage);
	run("Clear Results");
	selectWindow(tableName);
	Table.save(outputFolder+File.separator+"Results_"+inputFileName+".txt");
	close(tableName);

	
}
function mergeTables(files,outputfolder){
	run("Close All");
	tableName = "mergeResults";
	Table.create(tableName);
	nrOfImages = files.length;
	for (f = 0; f < nrOfImages; f++) {

		fileTable = File.getName(files[f]);
		fileTable = split(fileTable, ".");
		fileTable = fileTable[0];	
		fileTablePath = outputFolder+File.separator+"Results_"+fileTable+".txt";
		///open(fileTable);
		
		Table.open(fileTablePath);
		resultName = "Results_"+fileTable+".txt";
		selectWindow(resultName);


		
		if (f==0){

			tableHeadingsStr=Table.headings;
			print(tableHeadingsStr);
			tableHeadings=split(tableHeadingsStr,"\t");

			nHeadings = tableHeadings.length;		
			print(nHeadings);
			print(tableHeadings[1]);
	
			for (i =1; i < nHeadings; i++) {
				print(tableHeadings[i]);
				column= Table.getColumn(tableHeadings[i],resultName);
	
				Table.setColumn(tableHeadings[i], column,tableName); 
	
			}
			ImageColumn=newArray(column.length);
			for(j=0; j <ImageColumn.length;j++){
				ImageColumn[j] = File.nameWithoutExtension;
			}
			Table.setColumn("imageName",ImageColumn,tableName);
		} else {
			for (i =1; i < nHeadings; i++) {
				print(tableHeadings[i]);
				column1 = Table.getColumn(tableHeadings[i],tableName);
				print(column1.length);
				column2 = Table.getColumn(tableHeadings[i],resultName);
				print(column2.length);
				columnMerge=Array.concat(column1,column2);
				print(columnMerge.length);
				Table.setColumn(tableHeadings[i],columnMerge ,tableName); 
			}
			ImageColumn=newArray(column2.length);
			for(j=0; j <ImageColumn.length;j++){
				ImageColumn[j] = File.nameWithoutExtension;
			}
			column1 = Table.getColumn("imageName",tableName);
			print(column1.length);
			columnMerge=Array.concat(column1,ImageColumn);
			Table.setColumn("imageName",columnMerge,tableName);
	}
	close(resultName);

}
Table.save(outputFolder+File.separator+"AllResults.txt",tableName);
close(tableName);

	
}



