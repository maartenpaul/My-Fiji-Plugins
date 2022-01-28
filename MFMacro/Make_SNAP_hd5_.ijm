//select folder
folder = "E://20190312//Deconvolution//"
File.makeDirectory(folder+"SNAP");

//load H5 file, take the 50th slice

list=getFileList(folder);

for(i=0;i<list.length;i++){
	print(list[i]);

	if(endsWith(list[i],"__Ch2.h5")&&!(indexOf(list[i], "SNAP")>0)){

		run("Scriptable load HDF5...", "load=" + folder+ list[i] + " datasetnames=/time0050 nframes=1 nchannels=1");
		file = list[i];
		file2 = split(file,'.');
		file2 = file2[0];
		saveAs("Tiff",folder+"SNAP//" + file2+"_substack.tif");
		close();

	}		
}
print("Done");