folder = "/home/maarten/Documents/Training/pix2pix/";
//folder = "/home/maarten/Documents/pix2pix/";
stack = "001";
Stack.getDimensions(width, height, channels, slices, frames);
for (i = 1; i <= frames; i=i+1) {
    Stack.setPosition(1, 1, i);
    
	run("Duplicate...", " ");
	save(folder+"source" + File.separator+i+"stack"+stack+ ".png");
	close();

    Stack.setPosition(2, 1, i);
    // do something here;
    run("Duplicate...", " ");
    save(folder+"target" + File.separator+i+"stack"+stack + ".png");
    
	
	close();
}