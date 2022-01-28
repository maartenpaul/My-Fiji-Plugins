run("Clear Results");
roiManager("reset");
run("Find Maxima...", "noise=50 output=[Single Points]");
run("Analyze Particles...", "add");
close();
for (j = 0; j < roiManager("count"); j++) {
	roiManager("select", j);
	run("Enlarge...", "enlarge=0.5");
	run("Measure");
	//Should deal with ROI's on the border
}