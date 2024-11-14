// **Important Prerequisites:**
// * Have one image open in ImageJ
// * Have multiple ROIs defined in the ROI Manager

// **Step 1: Get the directory to save images**
dir = getDirectory("Choose saving directory");

// **Step 2: Start Processing**
nROIs = roiManager("Count"); 
original =  getImageID();
for (i=0; i<nROIs; i++) { 
  print("ROI ID: " + i);
  selectImage(original);
  roiManager("Select", i); 

  // **Step 3: Create image with ROI visible **
  run("Duplicate...", "title=[ROI_visible] duplicate"); 
  run("Make Composite"); 
  cropImage = getImageID();
  run("Flatten"); // Keep the ROI overlay
  saveAs("Tiff", dir + "ROI_" + IJ.pad(i, 3) + "_visible.tiff"); // Save as TIFF
  close();

  // **Step 4: Create image without ROI visible **
  selectImage(cropImage);
  run("Select None"); 

  saveAs("Tiff", dir + "ROI_" + IJ.pad(i, 3) + "_no_roi.tiff"); // Save as TIFF
  close();
  
  

}

// Convenience function for zero-padding ROI numbers
//function pad(num, size) {
//  var s = num + ""; // Convert number to string
//  while (getStringWidth(s) < size) { // Use ImageJ's function for string width
//     s = "0" + s;
//  }
//  return s;
//}