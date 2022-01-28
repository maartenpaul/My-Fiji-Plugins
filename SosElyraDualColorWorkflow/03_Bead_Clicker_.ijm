
//circle Clicker 
//Click to create cirle of 300 nm
//exit script by shift clicking when the point tool is on
//
Dialog.create("SOS split");
Dialog.addNumber("Pixelsize (um)", 0.1);
Dialog.show();
SOSPpixel=Dialog.getNumber();

run("Set Scale...", "distance=1 known=5 pixel=1 unit=nm");
setTool("point");
title=getTitle();
while(isOpen(title)){
while(IJ.getToolName()=="point" ){
	getCursorLoc(x,y,z,flags);
	if(flags==16){
	
	wait(50);
	makePoint(x, y);
	run("Enlarge...", "enlarge=8 pixel");
	run("To Bounding Box");
	}
	if(flags==17){exit;}
}
}