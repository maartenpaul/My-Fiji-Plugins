print("SOSsplit macro -- BATCH  mode -- started");
print("--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---");

Dialog.create("SOS split");
//Dialog.addMessage("---------------  Split stacks  ---------------");
//Dialog.addNumber("number of frames per substacks", 100);
//Dialog.addMessage("");
Dialog.addMessage("---------------  SOS Prepare Data  ---------------");
Dialog.addNumber("Pixelsize (um)", 0.1);
Dialog.addNumber("Frame interval (ms)", 50.0);
Dialog.addNumber("StDev in interframe displacement",0.4);
Dialog.addNumber("sc * stdev (trakcing)", 1.0);
Dialog.addNumber("Minimum I",1500.0);
Dialog.addNumber("Maximum I",65000.0);
//Dialog.addNumber("Maximum I",65536.0);
Dialog.addNumber("Minimum StDev of PSF (px)",0.8);
Dialog.addNumber("Maximum StDev of PSF (px)", 3.0);
Dialog.addNumber("Nr of prames to proccess (0 = all)", 0.0);
Dialog.addNumber("Size of Gaussian fit n=", 5.0);
Dialog.addNumber("Nr. of PSF's to multifit (0 = disable)", 0.0);
Dialog.addNumber("stdev for wavelet-filtering", 1.50);
Dialog.addCheckbox("Use mask image", false);
Dialog.addCheckbox("Create debug image", false);
//Dialog.addCheckbox("Convert to 8-bit?", false);
//Dialog.addNumber("Remove Tracks shorter than, dt", 2.0);
//Dialog.addNumber("Timegap for splitting Tracks", 5.0); 
Dialog.addNumber("Remove Clusters shorter than, dt", 1.0);
Dialog.addNumber("Timegap for splitting Clusters", 5.0);
Dialog.addNumber("Step in intensity (Lookup table)", 256.0);
Dialog.addNumber("Step in Sigma (Lookup table)", 0.1);

Dialog.addMessage("---------------  SOS Gauss fit  ---------------");
Dialog.addCheckbox("Perform Detections?", true);
Dialog.addCheckbox("Perform Tracking?", false);
Dialog.addCheckbox("Perform Clustering?", true);
Dialog.addCheckbox("Use lookup table?", false);
Dialog.addCheckbox("Use multi thread mode?", true);
Dialog.show();

//get variables from dialog
//aa=Dialog.getNumber();
SOSPpixel=Dialog.getNumber();
SOSPtime=Dialog.getNumber();
SOSCstdev=Dialog.getNumber();
SOSCsc=Dialog.getNumber(); 
SOSPminimumI=Dialog.getNumber(); 
SOSPmaximumI=Dialog.getNumber(); 
SOSPminimumS=Dialog.getNumber(); 
SOSPmaximumS=Dialog.getNumber(); 
SOSPno=Dialog.getNumber(); 
SOSPsize=Dialog.getNumber(); 
SOSPmultigaus=Dialog.getNumber(); 
SOSPstdevw=Dialog.getNumber(); 
SOSPif=Dialog.getCheckbox();
SOSPcr=Dialog.getCheckbox();
//SOSPconvert=Dialog.getCheckbox();
//SOSTremove=Dialog.getNumber();
//SOSTtime=Dialog.getNumber();
SOSCremove=Dialog.getNumber();
SOSCtime=Dialog.getNumber();
SOSPstepI=Dialog.getNumber();
SOSPstepS=Dialog.getNumber();
SOSGaussDetect=Dialog.getCheckbox();
SOSGaussTrack=Dialog.getCheckbox();
SOSGaussCluster=Dialog.getCheckbox();
SOSGaussLookup=Dialog.getCheckbox();
SOSGaussMultiThread=Dialog.getCheckbox();

dir1 = getInfo("image.directory");
imagename_noext = substring(getInfo("image.filename"),0,indexOf(getInfo("image.filename"), "."));
dir = dir1 + imagename_noext + File.separator;

File.makeDirectory(dir);


// create custom parameter file
File.saveString("// Custom version SOSsplit macro (mdg) :: parameters for the tracking: dx, dt, sigma_D, stdev_scale, I_min, I_max, s_min, s_max, T_max, masksize, binning, gaussianFilteringStdev isUseFirstMaskFrame isCreadeDebugOutput, deltaT, gapT, step_dI, step_dS\n",dir+"parameters.txt");
File.append(SOSPpixel, dir+"parameters.txt"); 
File.append(SOSPtime,dir+"parameters.txt");
File.append(SOSCstdev,dir+"parameters.txt");
File.append(SOSCsc,dir+"parameters.txt");
File.append(SOSPminimumI,dir+"parameters.txt");
File.append(SOSPmaximumI,dir+"parameters.txt");
File.append(SOSPminimumS,dir+"parameters.txt");
File.append(SOSPmaximumS,dir+"parameters.txt");
File.append(SOSPno,dir+"parameters.txt");
File.append(SOSPsize,dir+"parameters.txt");
File.append(SOSPmultigaus,dir+"parameters.txt");
File.append(SOSPstdevw,dir+"parameters.txt");
File.append(SOSPif,dir+"parameters.txt");
File.append(SOSPcr,dir+"parameters.txt");
File.append(SOSCremove,dir+"parameters.txt");
File.append(SOSCtime,dir+"parameters.txt");
File.append(SOSPstepI,dir+"parameters.txt");
File.append(SOSPstepS,dir+"parameters.txt");

saveAs("tiff", "" + dir+getInfo("image.filename"));
//open files one by one

//create folder with parameter file (use code Martijn)