requires("1.48q");
path = File.openDialog("open localization file");

fullimage = getImageID();
print(fullimage);
if(roiManager("count")<1){
	exit(exit("No ROIs present in roiManager");
}

for (i=0; i<roiManager("count"); i++){
	roiManager("select", i)	;
	run("02 SMLM viewer ", "title=[SMLM image #1] grid=5 gauss roi open=["+ path+ "]");
	selectImage(fullimage);
}