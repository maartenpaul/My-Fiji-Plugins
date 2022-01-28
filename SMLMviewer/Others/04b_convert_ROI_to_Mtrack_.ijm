macro "Elyra_Mtrack_converter" {
//convert an Elyra detection table into a Mtrack file to be visualized in ImageJ
	
	if (nResults==0){
		path = File.openDialog("open localization file");
		run("Results... ", "open=["+path+"]");
		
	}
	if (nResults==0){
		exit("No Results loaded");
	}

	
	
	print("Start macro conversion");

	f = File.open("");
	print(f,"MTrackJ 1.5.0 Data File");
	print(f, "Displaying true true true 1 1 0 0 100 24 0 0 1 1 1 0 0 true true true false");
	print(f, "Assembly 1 FF0000");
	print(f,"Cluster 1 FF0000");
	

	for(j=0; j<nResults; j++){

	print(f, "Track " +  (j+1) + " FF0000 true"); 
	print(f, "Point 1 " + (getResult("X",j)/66) + " " + (256-getResult("X",j)/66) + " 1 " + getResult("First_Frame",j) + " 1") ;
	//print(f, "Point 1 " + (getResult("Position X [nm]",j)/10) + " " + (getResult("Position Y [nm]",j)/10) + " 1 1 1") ;		
	}
	print(f,"End of MTrackJ Data File");
		print("Einde macro");

}
