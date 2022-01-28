//set variables
n_channel = 1;
datatype = "Elyra";
if(nResults>0) run("Clear Results");

//open localization file
if(nResults>0) run("Clear Results");
path = File.openDialog("open localization file");

data = File.openAsString(path);
data = split(data,"\n");
nrows = lengthOf(data);


voxx = split(data[(nrows-15)]," ");
voxx = parseFloat(voxx[2]);
resx = split(data[(nrows-11)]," ");
resx =  parseFloat(resx[2]);
sizex = split(data[(nrows-7)]," ");
sizex = parseInt(sizex[2]);

voxy = split(data[(nrows-13)]," ");
voxy = parseFloat(voxy[2]);
resy = split(data[(nrows-9)]," ");
resy =  parseFloat(resy[2]);
sizey = split(data[(nrows-5)]," ");
sizey = parseInt(sizey[2]);

width = sizex * resx;
height = sizey * resy;

run("Results... ", "open=["+path+"]");	
path2 = File.directory + File.nameWithoutExtension + "/";
File.makeDirectory(path2);
new_file = path2 + File.nameWithoutExtension + "_TS.csv";
new_img = path2 + File.nameWithoutExtension + "_TS.tif";
//ask for overwriting file if the .loc file already exists
saveTS_protocol(path2,File.nameWithoutExtension);

if(File.exists(new_file)==1){
	File.delete(new_file); 
}
f = File.open(new_file);

//import data to the result table
create_TS_table(datatype,f,1);

//Close file and write settings file
File.close(f);
if(nResults>0) run("Clear Results");


//function to create table
function create_TS_table(datatype, f,channel_n){
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
			setResult("PSF",i,getResult("PSF half width [nm]",i));
			//First_frame
			setResult("First_Frame",i,getResult("First Frame",i));
			//N_detections
			setResult("N_detections",i,getResult("Number Frames",i));
			//Photons
			setResult("Photons",i,getResult("Number Photons",i));
			//Intensity
			setResult("Intensity",i,0);
			//Background varriance
			setResult("background_STD",i,getResult("Background variance",i));
			//Frames_missing
			setResult("Frames_missing",i,getResult("Frames Missing",i));
			//Channel
			setResult("Channel",i,getResult("Channel",i));
			
		}
		
		updateResults();
	}

	//Index	X	Y	Precision	SEM	PSF	First_Frame	N_detections	Photons	Intensity	Frames_missing	Channel
		p = "\"id\",\"frame\",\"x [nm]\",\"y [nm]\",\"sigma [nm]\",\"intensity [photon]\",\"offset [photon]\",\"bkgstd [photon]\",\"uncertainty_xy [nm]\",\"detections\"";
		print(f,p);
		for(i=0; i<nResults; i++){	
			if(getResult("First_Frame",i)!=0){
				p = "" + getResult("Index",i)+ "," + getResult("First_Frame",i)+ "," + getResult("X",i) + "," + getResult("Y",i)+ "," + getResult("PSF",i)+ ","+ getResult("Photons",i)+ "," + "0" + "," + getResult("background_STD",i)+ "," + getResult("Precision",i)+ "," + getResult("N_detections",i);
				print(f,p);
			}
		}
}

function saveTS_protocol(folder,basename){
	new_file2=folder+basename+"_TS-protocol.txt";

	if(File.exists(new_file2)==1){
		File.delete(new_file2); 
	}
	e = File.open(new_file2);
	p =  "{\r\n  \"version\": \"ThunderSTORM (dev-2017-09-25)\",\r\n  \"imageInfo\": {\r\n    \"title\": \"" + basename + "\"\r\n  },\r\n  \"cameraSettings\": {\r\n    \"readoutNoise\": 0.0,\r\n    \"offset\": 1600.0,\r\n    \"quantumEfficiency\": 1.0,\r\n    \"isEmGain\": true,\r\n    \"photons2ADU\": 0.63,\r\n    \"pixelSize\": 100.0,\r\n    \"gain\": 300.0\r\n  },\r\n  \"analysisFilter\": {\r\n    \"name\": \"Wavelet filter (B-Spline)\",\r\n    \"scale\": 2.0,\r\n    \"order\": 3\r\n  },\r\n  \"analysisDetector\": {\r\n    \"name\": \"Local maximum\",\r\n    \"connectivity\": 8,\r\n    \"threshold\": \"std(Wave.F1)*2\"\r\n  },\r\n  \"analysisEstimator\": {\r\n    \"name\": \"PSF: Integrated Gaussian\",\r\n    \"fittingRadius\": 3,\r\n    \"method\": \"Maximum likelihood\",\r\n    \"initialSigma\": 1.6,\r\n    \"fullImageFitting\": false,\r\n    \"crowdedField\": {\r\n      \"name\": \"Multi-emitter fitting analysis\",\r\n      \"mfaEnabled\": false,\r\n      \"nMax\": 0,\r\n      \"pValue\": 0.0,\r\n      \"keepSameIntensity\": false,\r\n      \"intensityInRange\": false\r\n    }\r\n  },\r\n  \"is3d\": false,\r\n  \"isSet3d\": true\r\n}";
	print(e,p);
    File.close(e);

}
 