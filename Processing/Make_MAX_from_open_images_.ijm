//This script is made by Bing Chat

// Get the directory of the current image
dir = getDirectory("image");

// Get the list of open images
list = getList("image.titles");
iterator = 1;
// Loop over each image in the list
for (i = 0; i < list.length; i++) {

    // Set the current image to the ith image in the list
    selectImage(list[i]);

    // Get the title of the current image
    title = getTitle();
    
	
    // Create a new title for the maximum intensity projection

    
    if (title.contains("/")){
    	print("Title contains file seperator");
    	splitTitle = split(title, "/");
    	title= String.join(splitTitle);
    }
    if (File.exists(dir + title+".tif")){
    	title = title + "_"+IJ.pad(iterator, 3);
    	iterator = iterator + 1;
    } else {
    	iterator = 1;
    }
    

    newTitle = "MAX_" + title;
    // Create the maximum intensity projection
    run("Z Project...", "projection=[Max Intensity]");

    // Save the maximum intensity projection with the new title
    saveAs("Tiff", dir + newTitle);

    // Close the maximum intensity projection
    close();
    saveAs("Tiff", dir + title);
    close();
}