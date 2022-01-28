// Recursively lists the files in a user-specified directory.
// Open a file on the list by double clicking on it.

  dir = getDirectory("Choose a Directory ");
  count = 1;
  Calculate_moment(dir); 

  function Calculate_moment(dir) {
     list = getFileList(dir);
     print(list.length);
     for (i=0; i<list.length; i++) {
        if (endsWith(list[i], ".txt.tif")){
        	open(list[i]);
        	run("Moment Calculator", "image_name total_mass x_centre y_centre orientation cutoff=0.0000 scaling=1.0000");
        	close();
              
     }
  }
}