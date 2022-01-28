/// SOS split v0.4.1
/// created by Martijn de Gruiter, OIC, ErasmusMC, Rotterdam, Netherlands. Uses SOS plugin (Ihor Smal, BIGR, ErasmusMC, Rotterdam, Netherlands)
/// create custom parameter file for SOS plugin
/// Prepare data according to parameters
/// split file and process seperatly via SOS Gauss Fit
/// generate combined detection files for original stack
/// generate detections.txt.mdf of combined detections.txt
/// delete substacks when done

/// NOT IN BATCH

print("SOSsplit macro started");

Dialog.create("SOS split");
Dialog.addMessage("---------------  Split stacks  ---------------");
Dialog.addNumber("number of frames per substacks", 100);
Dialog.addMessage("");
Dialog.addMessage("---------------  SOS Prepare Data  ---------------");
Dialog.addNumber("Pixelsize (um)", 0.1);
Dialog.addNumber("Frame interval (ms)", 50.0);
Dialog.addNumber("StDev in interframe displacement",0.4);
Dialog.addNumber("sc * stdev (trakcing)", 1.0);
Dialog.addNumber("Minimum I",1.0);
Dialog.addNumber("Maximum I",65536.0);
Dialog.addNumber("Minimum StDev of PSF (px)",0.3);
Dialog.addNumber("Maximum StDev of PSF (px)", 1.5);
Dialog.addNumber("Nr of prames to proccess (0=all)", 0.0);
Dialog.addNumber("Size of Gaussian fit n=", 5.0);
Dialog.addNumber("Binning n=", 1.0);
Dialog.addNumber("stdev for wavelet-filtering", 1.50);
Dialog.addCheckbox("Use mask image", false);
Dialog.addCheckbox("Create debug image", false);
Dialog.addCheckbox("Convert to 8-bit?", false);
Dialog.addNumber("Remove tracks shorter than, dt", 5.0);
Dialog.addNumber("Timegap for splitting tracks", 2.0); 
Dialog.addNumber("Step in intensity (Lookup table)", 256.0);
Dialog.addNumber("Step in Sigma (Lookup table)", 0.01);
Dialog.addMessage("---------------  SOS Gauss fit  ---------------");
Dialog.addCheckbox("#NA Perform Detections?", true);
Dialog.addCheckbox("#NA Perform Tracking?", false);
Dialog.addCheckbox("#NA Perform Clustering?", false);
Dialog.addCheckbox("Use lookup table?", true);
Dialog.addCheckbox("#NA Use multi thread mode?", false);
Dialog.show();


//get variables from dialog
aa=Dialog.getNumber();
SOSPpixel=Dialog.getNumber();
SOSPtime=Dialog.getNumber();
SOSPstdev=Dialog.getNumber();
SOSPsc=Dialog.getNumber(); 
SOSPminimumI=Dialog.getNumber(); 
SOSPmaximumI=Dialog.getNumber(); 
SOSPminimumS=Dialog.getNumber(); 
SOSPmaximumS=Dialog.getNumber(); 
SOSPno=Dialog.getNumber(); 
SOSPsize=Dialog.getNumber(); 
SOSPbinning=Dialog.getNumber(); 
SOSPstdevw=Dialog.getNumber(); 
SOSPif=Dialog.getCheckbox();
SOSPcr=Dialog.getCheckbox();
SOSPconvert=Dialog.getCheckbox();
SOSTremove=Dialog.getNumber();
SOSTtime=Dialog.getNumber();
SOSPstepI=Dialog.getNumber();
SOSPstepS=Dialog.getNumber();
SOSGd=Dialog.getCheckbox();
SOSGt=Dialog.getCheckbox();
SOSGc=Dialog.getCheckbox();
SOSGl=Dialog.getCheckbox();
SOSGm=Dialog.getCheckbox();

selectWindow("Log"); 
print("\nSelect image to procces with SOS PrepareData plugin")
print("--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---");

// open normal input file for SOS plugin
SOSimage = File.openDialog("Open an image, will be proccessed with SOS in parts");
//open(SOSimage);
run("TIFF Virtual Stack...", "open=[SOSimage]");

getDimensions(width, height, channels, slices, frames);
if (slices > 1){x = slices;
}else{	x = frames;}

//prepare stack
run("SM PrepareData", "no.=0 if(SOSPif==true){if} if(SOSPcr==true){create} if(SOSPconvert==true){convert}");
//run("SM PrepareData", "no.=SOSPno if(SOSPif==true){if} if(SOSPcr==true){create} if(SOSPconvert==true){convert}");
//run("SM PrepareData", "pixel=SOSPpixel time=SOSPtime stdev=SOSPstdev sc=SOSPsc minimum=SOSPminimumI maximum=SOSPmaximumI minimum=SOSPminimumS maximum=SOSPmaximumS no.=SOSPno size=SOSPsize binning=SOSPbinning stdev=SOSPstdevw if(SOSPif==true){if} if(SOSPcr==true){create} if(SOSPconvert==true){convert} remove=SOSTremove time=SOSTtime step=SOSPstepI step=SOSPstepS");
//run("SM PrepareData", "SOSPpixel SOSPtime SOSPstdev SOSPsc SOSPminimumI SOSPmaximumI SOSPminimumS SOSPmaximumS SOSPno SOSPsize SOSPbinning SOSPstdevw if(SOSPif==true){if} if(SOSPcr==true){create} if(SOSPconvert==true){convert} SOSTremove SOSTtime if(SOSGl==true){SOSPstepI SOSPstepS}");

//get info from SOS prepared stack
name=getTitle;
dotIndex = indexOf(name, "."); 
title = substring(name, 0, dotIndex); 
dir=getDirectory("image");
close(name);

//save substacks in folder (same name) 
//together with adjusted parameter file 
//add SOSsplit.txt to distinguish between stack and substack folder further on in macro

// create custom parameter file
File.delete(dir+"\\parameters.txt");
File.saveString("// Version custom MdG :: parameters for the tracking: dx, dt, sigma_D, stdev_scale, I_min, I_max, s_min, s_max, T_max, masksize, binning, gaussianFilteringStdev isUseFirstMaskFrame isCreadeDebugOutput, deltaT, gapT, step_dI, step_dS\n",dir+"\\parameters.txt");
File.append(SOSPpixel, dir+"\\parameters.txt"); 
File.append(SOSPtime,dir+"\\parameters.txt");
File.append(SOSPstdev,dir+"\\parameters.txt");
File.append(SOSPsc,dir+"\\parameters.txt");
File.append(SOSPminimumI,dir+"\\parameters.txt");
File.append(SOSPmaximumI,dir+"\\parameters.txt");
File.append(SOSPminimumS,dir+"\\parameters.txt");
File.append(SOSPmaximumS,dir+"\\parameters.txt");
File.append(SOSPno,dir+"\\parameters.txt");
File.append(SOSPsize,dir+"\\parameters.txt");
File.append(SOSPbinning,dir+"\\parameters.txt");
File.append(SOSPstdevw,dir+"\\parameters.txt");
File.append(SOSPif,dir+"\\parameters.txt");
File.append(SOSPcr,dir+"\\parameters.txt");
File.append(SOSTremove,dir+"\\parameters.txt");
File.append(SOSTtime,dir+"\\parameters.txt");
File.append(SOSPstepI,dir+"\\parameters.txt");
File.append(SOSPstepS,dir+"\\parameters.txt");

//open SOS prepared stack (virtual)
run("TIFF Virtual Stack...", "open=["+dir+name+"]");

//create substack from SOS prepared main stack
for(z=1;z<x;z+=aa){
	b=z+aa-1;
	selectWindow(name); //SOS prepared stack name
	run("Make Substack...", "  slices="+z+"-"+b+"");
	subname=getTitle;
	getDimensions(width, height, channels, slices, frames);
		if(slices==aa){run("Properties...", "slices=1 frames=aa");}	
	
	//save substack to subfolder and save additional text files there
	pathsplit=dir + subname;
	File.makeDirectory(pathsplit);
	save(pathsplit+"\\"+subname+".tif");
	File.copy(dir + "parameters.txt", pathsplit + "\\"+"parameters.txt");
	File.copy(dir + "report.txt", pathsplit + "\\"+"report.txt");
	File.saveString("substack directory", pathsplit + "\\"+ "SOSsplit.txt") //file to recognise folder with substack tiffs
	
	//close substack and	
	close(subname);
	if(z==1){firstdir=pathsplit;} //get directory wit first detections.txt file
}
close(name); //close virual loaded sos prepared main stack

//get substack folder list	
list = getFileList(dir); 	
L=lengthOf(list);	
print("list");
Array.print(list);

//perform SOS gauss fit to all made substacks
for (r=0;r<L;r++){
 if (endsWith(list[r], "/")){
	if(File.exists(dir + list[r] + "\\" + "SOSsplit.txt")){
		SOSlist = getFileList(dir + list[r]);
		T= lengthOf(SOSlist);
		for (u=0;u<T;u++){
			if(SOSlist[u]!="parameters.txt" && SOSlist[u]!="report.txt" && SOSlist[u]!="SOSsplit.txt"){
				print("opened tif file:  "+ SOSlist[u]);
				//open(dir + list[r] + SOSlist[u]);
				run("TIFF Virtual Stack...", "open=["+dir + list[r] + "\\" + SOSlist[u]+"]");
				subname=getTitle;			
				if(SOSGl==true){
					run("SM Gauss Fit", "do use");}
					else{run("SM Gauss Fit", "do");}
//				run("SM Gauss Fit", "I_min=SOSPminimumI I_max=SOSPmaximumI s_min=SOSPminimumS s_max=SOSPmaximumS no.=SOSPno size=SOSPsize number=SOSPbinning stdev=SOSPstdevw if(SOSGl==true){use} step_dI=SOSPstepI step_dS=SOSPstepS");
//				run("SM Gauss Fit", "I_min=SOSPminimumI I_max=SOSPmaximumI s_min=SOSPminimumS s_max=SOSPmaximumS no.=SOSPno size=SOSPsize number=SOSPbinning stdev=SOSPstdevw if(SOSPif==true){if} if(SOSPcr==true){create} if(SOSGl==true){use step_dI=SOSPstepI step_dS=SOSPstepS}");
//				run("SM Gauss Fit", "if(SOSGd==true){do} if(SOSGt==true){do} if(SOSGc==true){do} if(SOSGl==true){use} if(SOSGm==true){use}");
//				run("SM Gauss Fit", "if(SOSGd==true){do} if(SOSGt==true){do} if(SOSGc==true){do} if(SOSGl==true){use}");
				close(subname); // close substack
				run("Close"); //close MTrackJ
			}else{} //end if statement: ise file not equal to parameters.txt or report.txt perform SOS gauss fit
		}//ends for loop: perform gauss fit in folders
	}else{} //ends if statement: search for folders with SOSsplit.txt
 }//ends if statement: contains "/" for selecting folders
}//ends for loop: go through all folders and files in SOS folder of complete stack

	
// copy detections.txt from first substack to orignal SOS stack folder
pathdetect=dir + "detections.txt";
File.copy(firstdir + "\\"+ "detections.txt", pathdetect);
//File.copy(dir + list[0] + "\\"+ "detections.txt", pathdetect);
File.copy(pathsplit + "\\"+"report.txt",dir + "report.txt");	//copy (by SOS) altered report back to main dir

//combine detections.txt
//check for detections.txt in folder
//read data and add max frame number from previous (sumnmed) txt file or from first file
//save all data to first detections.txt which is copied first to main stack folder

dc=0; // proccessed detections.txt counter

for (j=0;j<L;j++){
 if (endsWith(list[j], "/")){
	if(File.exists(dir+ list[j] + "\\" + "detections.txt")){
		dc=dc+1;
		if(nResults>0) run("Clear Results");
		run("Results... ", "open=["+dir + list[j] + "\\"  + "detections.txt"+"]");
		if(dc>1){	//don't add frames in first substack
			for (k=0; k<nResults; k++){setResult("C3",k,getResult("C3",k)+m);} 
			updateResults();
			for (k=0; k<nResults; k++){
				o = 	""   + getResult("C1",k) +
					"\t" + getResult("C2",k) + 
					"\t" + getResult("C3",k) + 
					"\t" + getResult("C4",k) + 
					"\t" + getResult("C5",k) + 
					"\t" + getResult("C6",k) + 
					"\t" + getResult("C7",k) + 
					"\t" + getResult("C8",k) + 
					"\t" + getResult("C9",k) + 
					"\t" + getResult("C10",k); 
				File.append(o,pathdetect);
			}
			m=getResult("C3",nResults-1)+1; //1 is added to prevent counting errors (each file starts with 0 for frame 1)
		}else{m=getResult("C3",nResults-1)+1; 
		      }//end if/else statement: check if first stack is used
	}//ends if statement: file is detections
 }//ends if statement: contains "/" for selecting folders
}//ends forloop

selectWindow("Results"); 
run("Close"); 

//Delete subfolders, first the files then the folders
for (n=0;n<L;n++){
	sublist = getFileList(dir + list[n]);	// get list of files in subfolder
	Q=lengthOf(sublist);
	if(File.exists(dir + list[n] + "\\" + "SOSsplit.txt")){
		for (p=0 ; p<Q ; p++){ //deletes all files in substack-folder
			File.delete(dir + list[n] + "\\" + sublist[p]);
		}
		File.delete(dir + list[n]);	// delete substack folder after files are deleted
	}else{}//end if statement: does folder contains detections.txt
}//end loop for deleting files

////create MtrackJ file of detections.txt
//selectWindow("Log"); 
//print("### ### ### ### ### ### ### ### ### ### ### ##");
//print("just press OK");
//print("MtrackJ file is made this way");
//print("### ### ### ### ### ### ### ### ### ### ### ##");

run("TIFF Virtual Stack...", "open=["+dir + title + ".tif"+"]");
run("SM Filter Results using Thresholds", "SOSPminimumI SOSPmaximumI SOSPminimumS SOSPmaximumS");
File.delete(dir + "\\"+ "detections.filtered.txt");	

selectWindow("Log"); 
print("SOSsplit macro finished: combined detections and MTrackJ file are in");
print(dir);