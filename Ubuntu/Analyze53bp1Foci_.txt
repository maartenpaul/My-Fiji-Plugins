run("Gaussian Blur...", "sigma=20");
setAutoThreshold("Moments dark");
setOption("BlackBackground", true);
run("Convert to Mask");