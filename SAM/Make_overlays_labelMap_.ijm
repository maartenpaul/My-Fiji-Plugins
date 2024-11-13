#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix

function processFolder(input) {
    list = getFileList(input);
    for (i = 0; i < list.length; i++) {
        if (File.isDirectory(input + File.separator + list[i]))
            processFolder(input + File.separator + list[i]);
        else if (endsWith(list[i], suffix)) 
            processFile(input, list[i]);
    }
}

function processFile(input, file) {
    // Check if it's an original image file
    if (indexOf(file, "labelIm_") < 0) {
        print("Processing: " + input + File.separator + file);
        
        // Construct label map filename
        labelFile = "labelIm_" + file;
        
        // Check if label map exists
        if (File.exists(input + File.separator + labelFile)) {
            // Open original image
            open(input + File.separator + file);
            originalID = getImageID();
            
            // Open label map
            open(input + File.separator + labelFile);
            labelID = getImageID();
            
            // Convert label map to ROIs
            run("LabelMap to ROI Manager (2D)");
            
            // Save ROIs as zip file
            roiManager("Deselect");
            roiManager("Save", input + File.separator + file + "_ROIs.zip");
            
            // Switch to original image
            selectImage(originalID);
            
            // Create overlay from ROIs
            roiManager("Show All with labels");
            run("Flatten");
            
            // Save image with overlay
            saveAs("Tiff", input + File.separator + file + "_with_overlay.tif");
            
            // Close all images
            close("*");
            
            // Clear ROI Manager
            roiManager("Reset");
        } else {
            print("Label map not found for: " + input + File.separator + file);
        }
    }
}

processFolder(input);