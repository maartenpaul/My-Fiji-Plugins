run("Duplicate...", " ");
run("Gaussian Blur...", "sigma=2");
setAutoThreshold("Huang dark");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Dilate");
run("Dilate");
run("Fill Holes");
run("Analyze Particles...", "size=500-Infinity pixel clear add");