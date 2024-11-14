//--- Settings (You might need to change these) ---
channels = 1;  // Number of channels to process 
numClasses = 7; // Number of desired classes
histogramSize = 256; // Size of the histogram

original = getTitle();

for (slice=1; slice<=channels; slice++) {
  selectWindow(original);
  setSlice(slice);

  // Get image histogram (excluding zero pixels)
  histogram = newArray(histogramSize); 
  for (x=0; x<getWidth(); x++) {
    for (y=0; y<getHeight(); y++) {
      pixel = getPixel(x, y);
      if (pixel > 0) { 
        histogram[pixel]++;   
      }
    }
  }

  // Calculate cumulative percentage for each intensity
  totalPixels = 0;
  for (i=0; i<histogram.length; i++) {
    totalPixels += histogram[i]; 
  }
  cumulativePercent = 0;
  thresholds = newArray(numClasses-1);  
  step = 100 / numClasses;
  thresholdIndex = 0;
  for (i=0; i<histogramSize; i++) { 
    cumulativePercent +=  histogram[i] / totalPixels * 100;
    if (cumulativePercent > step && thresholds[thresholdIndex] == 0) { 
      thresholds[thresholdIndex] = i;
      step += 100/numClasses;
      thresholdIndex++;
    }
  }
}

  // Loop through thresholds and create binary images
  for (i=0; i<numClasses; i++) {
    selectWindow(original);
    run("Duplicate...", " ");
    if (i == 0) {
      setThreshold(1, thresholds[0]); 
    } else if (i == numClasses-1) {
      setThreshold(thresholds[i-1] + 1, 255); 
    } else {
      setThreshold(thresholds[i-1] + 1, thresholds[i]);
    }
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Rename...", "title=Class_" + (i+1));
  }

  // Create the output image stack
  run("Images to Stack", "  title=Class_ use");

  
}

selectWindow("Stack");


  selectWindow(original);
  setSlice(slice);
  run("Duplicate...", " ");
  measureImage = getTitle();
// Loop through classes and measure mean in the other image
for (i=1; i<=numClasses; i++) {
  selectWindow("Stack");
  setSlice(i);
  run("Select None");
	run("Create Selection");
	
	roiManager("Add");
 
 
}
selectWindow(measureImage);
roiManager("multi-measure measure_all");

// Close unnecessary windows 
selectWindow("Classified stack");
close();

