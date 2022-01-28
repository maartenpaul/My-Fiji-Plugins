//input = newArray("D:\Stack\Genetics\171219 Halo BRCA2 alpha tracks\Halo-BRCA2 WT F4\001 30ms","D:\Stack\Genetics\171219 Halo BRCA2 alpha tracks\Halo-BRCA2 WT F4\002 30ms");
input = newArray();
path = "D://files.txt";
file = File.openAsString(path); 
input =split(file,"\n");

//run(“SM Gauss Fit (BATCH)”, “imagefolder= dotracking=false doclustering=true dodetection=true uselut=true usemultithreading=true”);
 for (i=0; i<input.length; i++) {
	print("Processing: " + input[i]);

      run("SM Gauss (multithread and mixture, BATCH)", "imagefolder='"+input[i]+"' dotracking=true doclustering=false dodetection=true");
  
   }
