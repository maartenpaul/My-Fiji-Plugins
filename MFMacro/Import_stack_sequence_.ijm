setBatchMode(true);

folder = "D:\\Maarten_Eric\\";
filename = "190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002_c01_t" ;

open(folder+filename+"0001.tif");
stack = getImageID();


for (i = 2; i < 1297; i++) {
open(folder+filename+IJ.pad(i, 4)+".tif");
run("Concatenate...", "all_open open");


}

saveAs("tiff", folder+"stackCh1.tif");
close();

folder = "D:\\Maarten_Eric\\";
filename = "190312exp2_53bp1_GFP_B2WTG10_MMC_50ms_100_f488int_0002_c02_t" ;

open(folder+filename+"0001.tif");
stack = getImageID();


for (i = 2; i < 1297; i++) {
open(folder+filename+IJ.pad(i, 4)+".tif");
run("Concatenate...", "all_open open");


}

saveAs("tiff", folder+"stackCh2.tif");
close();

setBatchMode(false);