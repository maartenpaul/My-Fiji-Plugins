#@ File[] (label = "Input files", style="File") files

run("Close All");
setBatchMode(true);
nrOfImages = files.length;
for (f = 0; f < nrOfImages; f++) {
	if (endsWith(files[f], ".tif")){
		print("\nProcessing file "+f+1+"/"+nrOfImages+": "+files[f] + "\n");
		directory = File.getDirectory(files[f]);
		filename = File.getName(files[f]);
		filenameArray = split(filename, "_");
		if (filenameArray[2] == "Crop001"){
			channel1 = files[f];		
			channel2 = directory+filenameArray[0]+"_"+filenameArray[1]+"_Crop002_"+filenameArray[3];
			channel3 = directory+filenameArray[0]+"_"+filenameArray[1]+"_Crop003_"+filenameArray[3];
			open(channel1);
			run("8-bit");
			channel1ID = getTitle();
			open(channel2);
			run("8-bit");
			channel2ID = getTitle();
			open(channel3);
			run("8-bit");
			channel3ID = getTitle();
			run("Merge Channels...", "c1=["+channel1ID+"] c2=["+channel2ID+"] c3=["+channel3ID+"] create");
			save(directory+filenameArray[0]+"_"+filenameArray[1]+"_merged_"+filenameArray[3]);
			close();
		}
	}
}
setBatchMode("exit and display");
