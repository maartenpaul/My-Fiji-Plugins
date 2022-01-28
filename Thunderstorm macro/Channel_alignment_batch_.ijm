ch1 = "C:/Nik/GG1 HU/001 STORM RAD51_driftcorr.csv";
ch2 = "C:/Nik/GG1 HU/001 STORM BRCA2_driftcorr.csv";
correct =  "C:/Nik/GG1 HU/001 STORM BRCA2_driftcorr.csv";

run("Multi Channel bead selection", "maximum_gap=50 track_length=50 select_primary=["+ch1+"] select_secondary=["+ch2+"] select_x=[x [nm]] select_y=[y [nm]] select_z=none select_frame=frame select_precision=[uncertainty_xy [nm]] select_x=[x [nm]] select_y=[y [nm]] select_z=none select_frame=frame select_precision=[uncertainty_xy [nm]]");

run("Channel alignment", "select=1 select_0=2 save=[C:/Thunderstorm test/Nik/alignment/chromatic_calibration.txt]");
saveAs("Results", "C:/Nik/GG1 HU/001 Results.csv");
open(correct);

run("Apply Channel alignment ThunderSTORM", "open=[C:/Thunderstorm test/Nik/alignment/chromatic_calibration.txt]");
saveAs("Results", "C:/Nik/GG1 HU/STORM_BRCA2_1ca2.csv");