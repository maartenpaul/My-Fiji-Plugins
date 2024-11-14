// Set input directory
dir = getDirectory("Choose a folder containing CZI files");
setBatchMode(true); // Process all files in the directory without pop-ups

// Function to process a single CZI file
function processFile(cziPath) {
  // Open the .czi file
  //open(cziPath);
  run("Bio-Formats", "open=["+cziPath+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");

  // Get title for later result file naming
  originalTitle = getTitle(); 

  run("Duplicate...", "duplicate channels=1");
  run("Size...", "width=512 height=512 depth=1 constrain average interpolation=Bilinear");
  ch1Title = getTitle(); 
  // Segment nuclei (channel 1) using StarDist
  //run("StarDist 2D", "'modelChoice'='Versatile (fluorescent nuclei)' normalize_input percentile_bottom=1.0 percentile_top=99.8 output_type=ROI Manager");
  run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'" + ch1Title + "', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.5', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
  close();
  // Select channel 2
  selectWindow(originalTitle);
  Stack.setChannel(2);
  RoiManager.scale(2.0, 2.0, false);
  // Measure intensity within nuclei ROIs
  setOption("BlackBackground", false); 
  run("Set Measurements...", "area mean integrated redirect=None decimal=3");
  roiManager("Show All");
  roiManager("Measure");

  // Save the results table
  resultsTableTitle = originalTitle + "_results.csv";
  resultsFilePath = dir + resultsTableTitle;
  saveAs("Results", resultsFilePath);

  // Clean up for the next file
  roiManager("reset");
  run("Close All");
  run("Clear Results");
}

// Main processing loop
list = getFileList(dir);

for (i = 0; i < list.length; i++) {
  if (endsWith(list[i], ".czi")) {
      filePath = dir + list[i];
      processFile(filePath);
  }
}

print("Processing complete!");
