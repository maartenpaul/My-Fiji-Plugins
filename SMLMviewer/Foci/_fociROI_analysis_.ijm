path = File.openDialog("open localization file");

fullimage = getImageID();
print(fullimage);
for (i=0; i<roiManager("count"); i++){
	roiManager("select", i)	;
	//Enlarge selection
	//run("Enlarge...", "enlarge=300");
	run("02 SMLM viewer ", "title=[SMLM image #1] grid=2 gauss roi open=["+ path+ "]");
	
	selectImage(fullimage);
}