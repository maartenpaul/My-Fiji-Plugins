//set variables
n_channel = 1;
dualcolor_1 = false;

//Create dialog
Dialog.create("Load localization file");
Dialog.addNumber("Width of image (px)", 512);
Dialog.addNumber("Heigth of image (px)", 512);
Dialog.addNumber("pixel size (nm)", 100);
Dialog.addChoice("Data type", newArray("Elyra","Excel clustered", "SOS", "SOS cluster"));
Dialog.addCheckbox("1Dual color (2 files)",false);
Dialog.addCheckbox("2Dual color (1 file (ELYRA))",false);
Dialog.addCheckbox("Run SMLM viewer", false);
	
Dialog.show();
//obtain variables from dialog
width = Dialog.getNumber();
height = Dialog.getNumber();
pixel = Dialog.getNumber();
datatype = Dialog.getChoice();
dualcolor = Dialog.getCheckbox();
dualcolor_1 = Dialog.getCheckbox();
SMLM = Dialog.getCheckbox();

print(datatype);
//open localization file
if(nResults>0) run("Clear Results");
path = File.openDialog("open localization file");
run("Results... ", "open=["+path+"]");	
path2 = File.directory + File.nameWithoutExtension + "/";
File.makeDirectory(path2);
new_file = path2 + File.nameWithoutExtension + ".loc";

//ask for overwriting file if the .loc file already exists
if(File.exists(new_file)==1){
	Dialog.create("Title");
	Dialog.addMessage("Converted localization file already exist, \n if you continue it will be overwritten."); 
	Dialog.show();
	File.delete(new_file); 
	File.delete(new_file + ".settings"); 		
}

f = File.open(new_file);

//import data to the result table
create_result_table(datatype,f,1,dualcolor_1);

//do the same for second channel if there is one
if (dualcolor == true){
	path = File.openDialog("open localization file");
	run("Results... ", "open=["+path+"]");	
	create_result_table(datatype,f,2,dualcolor_1);
	n_channel = 2;
}

//Close file and write settings file
File.close(f);
f = File.open(new_file + ".settings");
print(f,width);
print(f,height);
print(f,pixel);
print(f, datatype);
if (dualcolor_1 == true){
	print(f, 2);
}
else {
	print(f, n_channel);	
}
File.close(f);
if(nResults>0) run("Clear Results");
//SMLM = getBoolean("Run SMLM Viewer?");
if (SMLM==1) run("02 SMLM viewer");

//function to create table
function create_result_table(datatype, f,channel_n,dualcolor_1){
	if (datatype=="Excel clustered"){
		for (i=0; i<nResults; i++){
			//Index
			setResult("Index",i,getResult("new serieID",i));
			// X in nm
			setResult("X",i,getResult("X cuml avg",i)*pixel);
			// Y in nm
			setResult("Y",i,getResult("Y cuml avg",i)*pixel);
			// Precision only for Elyra
			setResult("Precision",i,0);
			// SEM
			setResult("SEM",i, getResult("SEM in nm" ,i));
			// PSF (in nm)
			setResult("PSF",i,getResult("avg sigma",i)*pixel);
			//First_frame
			setResult("First_Frame",i,getResult("Frame# of first detection",i)+1);
			//N_detections
			setResult("N_detections",i,getResult("detections per serie",i));
			//Photons only for Elyra
			setResult("Photons",i,0);
			//Intensity
			setResult("Intensity",i,getResult("avg I",i));
			//Frames_missing
			setResult("Frames_missing",i,0);
			//Channel
			setResult("Channel",i,channel_n);		
			}
			print ("Excel data loaded");
	}
	if (datatype=="Elyra"){
		for (i=0; i<nResults; i++){
			//Index
			//Index == Index
			// X
			setResult("X",i,getResult("Position X [nm]",i));
			// Y
			setResult("Y",i,getResult("Position Y [nm]",i));
			// Precision
			setResult("Precision",i,getResult("Precision [nm]",i));
			// SEM
			setResult("SEM",i, 0);
			// PSF (in nm)
			setResult("PSF",i,getResult("PSF width [nm]",i));
			//First_frame
			setResult("First_Frame",i,getResult("First Frame",i));
			//N_detections
			setResult("N_detections",i,getResult("Number Frames",i));
			//Photons
			setResult("Photons",i,getResult("Number Photons",i));
			//Intensity
			setResult("Intensity",i,0);
			//Frames_missing
			setResult("Frames_missing",i,getResult("Frames Missing",i));
			//Channel
			if (dualcolor_1 == false){
				setResult("Channel",i,channel_n);
			}
			else if (getResult("Channel",i)>n_channel){
				n_channel=(getResult("Channel",i));
			}
			
		}
		print("Elyra data loaded");
	}
	if (datatype=="SOS"){
		for (i=0; i<nResults; i++){
			//Index
			setResult("Index",i,i+1);
			// X in nm
			setResult("X",i,getResult("C1",i)*pixel);
			// Y in nm
			setResult("Y",i,getResult("C2",i)*pixel);
			// Precision only for Elyra
			setResult("Precision",i,0);
			// SEM
			setResult("SEM",i, 20);
			// PSF (in nm)
			setResult("PSF",i,getResult("C5",i)*pixel);
			//First_frame
			setResult("First_Frame",i,getResult("C3",i)+1);
			//N_detections
			setResult("N_detections",i,1);
			//Photons only for Elyra
			setResult("Photons",i,0);
			//Intensity
			setResult("Intensity",i,getResult("C4",i));
			//Frames_missing
			setResult("Frames_missing",i,0);
			//Channel
			setResult("Channel",i,channel_n);	
		}
		print ("SOS data loaded");
	}
	if (datatype=="SOScluster"){
		for (i=0; i<nResults; i++){
			// x coordinate
			setResult("x",i,round(getResult("C2",i)/grid));
			// y coordinate
			setResult("y",i,round(getResult("C3",i)/grid));
			// SEM (in nm)
			setResult("r",i,round(getResult("C7",i)/grid));
			//Channel
			setResult("Channel",i,channel_n);
				
		}
		print ("SOS data loaded");
	}
	updateResults();
	
	
	//Index	X	Y	Precision	SEM	PSF	First_Frame	N_detections	Photons	Intensity	Frames_missing	Channel
	p = "Index" + "\t" + "X" + "\t" + "Y" + "\t" + "Precision" + "\t" + "SEM"+ "\t" + "PSF" + "\t" + "First_Frame"+ "\t" + "N_detections"+ "\t" + "Photons"+ "\t" + "Intensity"+ "\t" + "Frames_missing"+ "\t" + "Channel";
	print(f,p);
	for(i=0; i<nResults; i++){	
		p = "" + getResult("Index",i)+ "\t" + getResult("X",i) + "\t" + getResult("Y",i)+ "\t" + getResult("Precision",i)+ "\t"+ getResult("SEM",i)+ "\t" + getResult("PSF",i)+ "\t" + getResult("First_Frame",i)+ "\t" + getResult("N_detections",i)+ "\t" + getResult("Photons",i)+ "\t" + getResult("Intensity",i)+ "\t" + getResult("Frames_missing",i)+ "\t" + getResult("Channel",i);
		print(f,p);
	}
}