#@ File[] (label = "Input files", style="File") files

// This script processes multiple selected .lif files and creates numbered maximum intensity projections
// Numbering resets for each .lif file

// Initialize Bio-Formats Macro Extensions
run("Bio-Formats Macro Extensions");

// Get the directory of the first selected file (assuming all files are in the same directory)
dir = File.getDirectory(files[0]);

// Loop through each selected file
for (fileIndex = 0; fileIndex < files.length; fileIndex++) {
    path = files[fileIndex];
    if (endsWith(path, ".lif")) {
        // Extract the file name without extension
        fileName = File.getName(path);
        baseFileName = substring(fileName, 0, lastIndexOf(fileName, "."));
        
        // Use Bio-Formats Importer to open the .lif file
        Ext.setId(path);
        Ext.getSeriesCount(seriesCount);
        
        // Reset the counter for each .lif file
        fileCounter = 0;
        
        // Loop through each series (hyperstack) in the .lif file
        for (series = 0; series < seriesCount; series++) {
            run("Bio-Formats Importer", "open=[" + path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_" + (series + 1));
            
            // Get the title of the current image
            // Get the title of the current image
			title = getTitle();
			subTitle = split(title, " - ");
			if (subTitle.length == 2) {
			    subTitle = subTitle[1];
			} else if (subTitle.length > 2) {
			    // Join all parts after the first dash
			    temp = "";
			    for (i = 1; i < subTitle.length; i++) {
			        if (i > 1) temp = temp + " - ";
			        temp = temp + subTitle[i];
			    }
			    subTitle = temp;
			} else {
			    // If there's no dash, use the full title
			    subTitle = title;
			}
            // Create a new title for the maximum intensity projection
            //newTitle = IJ.pad(fileCounter + 1, 3) + "_MAX_" + baseFileName;
            newTitle = IJ.pad(fileCounter + 1, 3) + "_MAX_" + subTitle;            
            print(newTitle);
            fileCounter++;
            
            if (newTitle.contains("/")) {
                print("Title contains file separator");
                splitTitle = split(newTitle, "/");
                newTitle = String.join(splitTitle);
            }
            
            // Create the maximum intensity projection
            run("Z Project...", "projection=[Max Intensity]");
            
            // Save the maximum intensity projection with the new title
            saveAs("Tiff", dir + newTitle + ".tif");
            
            // Close the maximum intensity projection and the original image
            close();
            selectImage(title);
            close();
        }
        
        print("Processed " + fileCounter + " series from " + fileName);
    } else {
        print("Skipping non-LIF file: " + fileName);
    }
}

print("Processing complete. All files were saved in " + dir);