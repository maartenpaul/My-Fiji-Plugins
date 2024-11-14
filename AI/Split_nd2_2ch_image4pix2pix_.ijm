#@ File[] (label = "Input .nd files", style = "files") input_files
#@ File (label = "Output folder", style = "directory") output_folder
#@ String (label = "Source channel", value = "1") source_channel
#@ String (label = "Target channel", value = "2") target_channel

//Script written for Jente to process spinning disc data
// Create subfolders for source and target images
File.makeDirectory(output_folder + File.separator + "source");
File.makeDirectory(output_folder + File.separator + "target");

// Process each selected .nd file
for (file = 0; file < input_files.length; file++) {
    // Open the .nd file using Bio-Formats
    run("Bio-Formats Importer", "open=[" + input_files[file] + "] color_mode=Default view=Hyperstack stack_order=XYCZT");
    
    // Get the stack dimensions
    Stack.getDimensions(width, height, channels, slices, frames);
    
    // Extract the stack number from the filename (assuming it's the last part before the extension)
    filename = File.getName(input_files[file]);
    stack = substring(filename, lastIndexOf(filename, "_") + 1, lastIndexOf(filename, "."));
    
    // Process each frame and slice
    for (i = 1; i <= frames; i++) {
        for (j = 1; j <= slices; j++) {
            print("Processing frame " + i + ", slice " + j + " of file " + filename);
            
            // Process source channel
            Stack.setPosition(parseInt(source_channel), j, i);
            run("Duplicate...", " ");
            saveAs("PNG", output_folder + File.separator + "source" + File.separator + "tile_" + i + "_slice_" + j + "stack" + stack + ".png");
            close();
            
            // Process target channel
            Stack.setPosition(parseInt(target_channel), j, i);
            
            run("Duplicate...", " ");
            run("Gaussian Blur...", "sigma=2");
			run("Enhance Contrast...", "saturated=2 equalize");
            saveAs("PNG", output_folder + File.separator + "target" + File.separator + "tile_" + i + "_slice_" + j + "stack" + stack + ".png");
            close();
        }
    }
    
    // Close the current image
    close("*");
}

print("Processing complete!");