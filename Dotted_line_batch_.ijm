setAutoThreshold("Huang dark");
setOption("BlackBackground", false);
run("Convert to Mask");

run("Erode");
run("Erode");
run("Fill Holes");
run("Dilate");

run("Analyze Particles...", "size=1-Infinity exclude clear include add");

id = getImageID();
for(i=0; i<roiManager("Count");i++) {
	roiManager("Select",i);
	run("Interpolate", "interval=5 smooth");
	run("Dotted Line", "line=2 dash=2,2");
	
}