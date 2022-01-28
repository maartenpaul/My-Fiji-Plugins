dir=getDirectory("Select the input directory");
filepths=getFileList(dir);
Array.sort(filepths);
run("Camera setup", "offset=1600.0 quantumefficiency=1.0 isemgain=true photons2adu=0.63 gainem=300.0 pixelsize=100.0");

for (i=0; i<filepths.length; i++){
	if(endsWith(filepths[i],".czi")){
		filepth = dir+filepths[i];
		filename = File.getName(filepth);
		filename = split(filename, '.');
		filename = filename[0];
		run("Bio-Formats", "open=["+ dir+File.separator+filename+".czi] color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
		rawImage = getImageID();
		//2x threshold for BRCA2 images, 3x threshold for RAD51 images
		if(endsWith(filename,"Atto488")){
			run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=1.5*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=6 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Normalized Gaussian] dxforce=false magnification=20.0 colorize=false dx=20.0 threed=false dzforce=false repaint=50");
		}
		else{
			run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=2*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=6 method=[Weighted Least squares]  full_image_fitting=false mfaenabled=false renderer=[Normalized Gaussian] dxforce=false magnification=20.0 colorize=false dx=20.0 threed=false dzforce=false repaint=50");
		}
		//export uncorrected results
		run("Export results", "floatprecision=5 filepath=["+ dir+File.separator +filename+"_uncorrected.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false chi2=false uncertainty_xy=true frame=true");
		//apply drift correction
		run("Show results table", "action=drift smoothingbandwidth=0.25 method=[Fiducial markers] ontimeratio=0.3 distancethr=50.0 save=false");
		list = getList("image.titles");
		for (j=0; j<list.length; j++){
			if (list[j]=="Drift"){
	        	selectWindow("Drift");
				saveAs("Tiff", dir+File.separator+ filename + "Drift.tif");
				close();
			}
  		}
  		//export drift corrected results
		run("Export results", "floatprecision=5 filepath=["+ dir+File.separator + filename+"_driftcorr.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true chi2=false id=false uncertainty_xy=true frame=true");
		//do merge to find beads
		run("Show results table", "action=merge zcoordweight=0.1 offframes=10 dist=40.0 framespermolecule=0");
		run("Show results table", "action=filter formula=[detections > 200]");
		run("Export results", "floatprecision=5 filepath=["+ dir+File.separator + filename+"_beads.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=false chi2=false id=false uncertainty_xy=false frame=true detections=true");

		//do drift correction again
		run("Show results table", "action=reset");
	    run("Export results", "floatprecision=5 filepath=["+ dir+File.separator + filename+"_driftcorr.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true chi2=false id=false uncertainty_xy=true frame=true");	
		//merge normal way
		run("Show results table", "action=merge zcoordweight=0.1 offframes=1 dist=40.0 framespermolecule=0");
		run("Show results table", "action=filter formula=uncertainty_xy<50");
		run("Export results", "floatprecision=5 filepath=["+ dir+File.separator + filename+"_driftcorr_merged.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true chi2=false id=false uncertainty_xy=true frame=true");
		run("Visualization", "imleft=0.0 imtop=0.0 imwidth=350.0 imheight=350.0 renderer=[Normalized Gaussian] dxforce=false magnification=20.0 colorize=false dx=20.0 threed=false dzforce=false");
		saveAs("Tiff", dir+File.separator+filename +"Normalized Gaussian.tif");
		close();
		close();
		close(rawImage);
	}
}

		
		//run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] ccsmoothingbandwidth=0.25 save=false steps=5 showcorrelations=false");
		

//run("Bio-Formats", "open=[E:\\170207 BRCA2 dDBD+CTD_Halo STORM\\004 dSTORM with beads in agar.lsm] color_mode=Default view=Hyperstack stack_order=XYCZT");
//print("Input directory: "+dir);
//fileNames=getFileList(dir);
//Array.sort(fileNames);

//run("Run analysis", "filter=[Wavelet filter (B-Spline)] scale=2.0 order=3 detector=[Local maximum] connectivity=8-neighbourhood threshold=1*std(Wave.F1) estimator=[PSF: Integrated Gaussian] sigma=1.6 fitradius=6 method=[Weighted Least squares] full_image_fitting=false mfaenabled=false renderer=[Normalized Gaussian] dxforce=false magnification=20.0 colorize=false dx=20.0 threed=false dzforce=false repaint=50");
//run("Export results", "floatprecision=5 filepath=[E:\\170207 BRCA2 dDBD+CTD_Halo STORM\\004.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true offset=true saveprotocol=true x=true y=true bkgstd=true id=false uncertainty_xy=true frame=true");

//run("Show results table", "action=merge zcoordweight=0.1 offframes=1 dist=20.0 framespermolecule=0");

//run("Show results table", "action=drift smoothingbandwidth=0.25 method=[Fiducial markers] ontimeratio=0.1 distancethr=40.0 save=false");
//selectWindow("Drift");
//run("Show results table", "action=reset");
//run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] ccsmoothingbandwidth=0.25 save=false steps=5 showcorrelations=false");
//run("Show results table", "action=drift magnification=5.0 method=[Cross correlation] ccsmoothingbandwidth=0.25 save=false steps=2 showcorrelations=false");
//selectWindow("Drift");
//run("Export results", "floatprecision=5 filepath=[D:\\Stack\\Genetics\\160711 ES and U2oS IR and alpha tracks\\IB10 PALB2GFP alpha tracks 1_5h arad51_gfp647\\data.csv] fileformat=[CSV (comma separated)] sigma=true intensity=true chi2=true offset=true saveprotocol=true x=true y=true bkgstd=true id=true uncertainty_xy=true frame=true");
