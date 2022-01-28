macro "Random_PALM_image_generator" {
	print ("Start");
	newImage("Untitled", "16-bit Black", 5120, 5120, 10);
	for (i=0; i<10; i+=1){
		setSlice(i+1);
		for (i=0; i<100; i+=1){
			x = random()*5120;
			y = random()*5120;
			setPixel(x,y,30000+20000*random());
			print(x,y);
			}
				
	}
	run("Gaussian Blur...", "sigma=10 stack");
	run("Size...", "width=512 height=512 constrain interpolation=None");
	run("RandomJ Poisson", "mean=10 insertion=additive");
	print("Done");
	run("16-bit");
	run("8-bit");	
}
