// Select the directory containing all model folders
#@ File (label="Select main directory", style="directory") main_dir

// Start batch mode
setBatchMode(true);

// Define model identifiers
models = newArray("CS1-2", "CS2A", "CS2B", "CS5");
// Define days and treatments
days = newArray(0, 4, 7);
treatments = newArray(1, 2, 3, 4);

mainDir = main_dir + File.separator;
modelFolders = getFileList(mainDir);

// Process each model folder
for (m = 0; m < modelFolders.length; m++) {
    modelDir = mainDir + modelFolders[m];
    if (File.isDirectory(modelDir)) {
        // Create Montage folder inside the model directory
        montageDir = modelDir + "Montage" + File.separator;
        File.makeDirectory(montageDir);

        // First create the general montage (Montage_all.tif)
        image_paths = newArray(12);
        index = 0;
        
        // Loop through treatments first (rows)
        for (t = 0; t < treatments.length; t++) {
            treatment = treatments[t];
            // Loop through days (columns)
            for (d = 0; d < days.length; d++) {
                day = days[d];
                folder = modelDir + "d" + day + " " + treatment + File.separator;
                if (File.exists(folder)) {
                    // Get first file ending with _with_overlay.tif
                    list = getFileList(folder);
                    for (i = 0; i < list.length; i++) {
                        if (endsWith(list[i], "tif_with_overlay.tif")) {
                            image_paths[index] = folder + list[i];
                            print(image_paths[index]);  // Debug print
                            index++;
                            break;
                        }
                    }
                }
            }
        }
        
        // Create Montage_all if images were found
        if (index > 0) {
            // Open all images
            for (i = 0; i < image_paths.length; i++) {
                if (image_paths[i] != "") {
                    open(image_paths[i]);
                }
            }
            
            if (nImages > 0) {
                run("Images to Stack", "name=Stack title=[] use");
                run("Make Montage...", "columns=3 rows=4 scale=1");
                saveAs("Tiff", montageDir + "Montage_all.tif");
                close("*");
            }
        }
        
        // Now create model-specific montages
        for (mod = 0; mod < models.length; mod++) {
            model = models[mod];
            image_paths = newArray(12);
            index = 0;
            
            // Loop through treatments first (rows)
            for (t = 0; t < treatments.length; t++) {
                treatment = treatments[t];
                // Loop through days (columns)
                for (d = 0; d < days.length; d++) {
                    day = days[d];
                    folder = modelDir + "d" + day + " " + treatment + File.separator;
                    if (File.exists(folder)) {
                        list = getFileList(folder);
                        for (i = 0; i < list.length; i++) {
                            if (endsWith(list[i], model + "_with_overlay.tif")) {
                                image_paths[index] = folder + list[i];
                                print(image_paths[index]);
                                index++;
                                break;
                            }
                        }
                    }
                }
            }
            
            // Create model-specific montage if images were found
            if (index > 0) {
                for (i = 0; i < image_paths.length; i++) {
                    if (image_paths[i] != "") {
                        open(image_paths[i]);
                    }
                }
                
                if (nImages > 0) {
                    run("Images to Stack", "name=Stack title=[] use");
                    run("Make Montage...", "columns=3 rows=4 scale=1");
                    saveAs("Tiff", montageDir + "Montage_" + model + ".tif");
                    close("*");
                }
            }
        }
    }
}

// Exit batch mode
setBatchMode(false);