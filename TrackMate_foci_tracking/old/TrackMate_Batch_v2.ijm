root_folder = "/media/DATA/Maarten/OneDrive/Data2/220208_ExpMP2202_002_R51_B2_dBD_timelapse//Analysis//"

list = getFileList(root_folder);
print(list[0]);

for (i=0; i<list.length(); i++) {

        if (endsWith(list[i], "tif")){

        	open(root_folder+list[i]);
        	directory = getDir("image");
			filename = File.getNameWithoutExtension(getInfo("image.filename"));
			File.makeDirectory(directory+filename);
			//write_folder = directory;
			
			
			write_folder= root_folder+filename;

			//nuclei tracking
			run("Duplicate...", "duplicate channels=2");
//			//enhance contrast to improve segmentation by Stardist
			run("Enhance Contrast...", "saturated=10 process_all");
			run("stardist batch","outputfolder="+ write_folder+"");
			close();

			//foci tracking
//			run("Duplicate...", "duplicate channels=1");
			save(write_folder+File.separator+filename+".tif");
			run("Gaussian Blur...", "sigma=0.70 stack");
		
			run("TrackFoci batch ","outputfolder="+ write_folder+"");
			//close();

			//close original stack
			close();
        }
}


