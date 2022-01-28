// Action Bar description file : SOS-SMLM action bar
run("Action Bar","/plugins/01 SMLM viewer/_actionbar SOS-SMLM.ijm");
exit();

<text>-------------------------------------SOS-------------------------------------

<line>
<button>
label=SOS Prepare Data
icon=noicon
arg=<macro>
run("SM PrepareData");
</macro>

<button>
label=SOS PrepareData (BATCH)
icon=noicon
arg=<macro>
run("SM PrepareData (BATCH)");
</macro>
</line>

<line>
<button>
label=Create Mask From ROI
icon=noicon
arg=<macro>
run("SM Create Mask From ROI");
</macro>
</line>

<line>
<button>
label=Gauss Fit
icon=noicon
arg=<macro>
run("SM Gauss Fit");
</macro>

<button>
label=Gauss Fit (BATCH)
icon=noicon
arg=<macro>
run("SM Gauss Fit (BATCH) ");
</macro>
</line>

<line>
<button>
label=Track Drift
icon=noicon
arg=<macro>
run("SM Track Drift");
</macro>
</line>

<line>
<button>
label=Create Parameter Histogram
icon=noicon
arg=<macro>
run("SM Create Parameter Histogram");
</macro>
</line>

<line>
<button>
label=Filter Results using ROI
icon=noicon
arg=<macro>
run("SM Filter Results using ROI");
</macro>

<button>
label=Filter Results using Thresholds
icon=noicon
arg=<macro>
run("SM Filter Results using Thresholds");
</macro>
</line>

<line>
<button>
label=Simple Tracking
icon=noicon
arg=<macro>
run("SM Simple Tracking");
</macro>

<button>
label=Simple Clustering
icon=noicon
arg=<macro>
run("SM Simple Clustering");
</macro>
</line>

<line>
<button>
label=Histogram of Track Lengths and Intensity (BATCH)
icon=noicon
arg=<macro>
run("SM Histogram of Track Lengths and Intensity (BATCH) ");
</macro>
</line>

<line>
<button>
label=PSF Estimator
icon=noicon
arg=<macro>
run("SM PSF Estimator");
</macro>

<button>
label=Simulate Image
icon=noicon
arg=<macro>
run("SM Simulate Image");
</macro>

<button>
label=Manual
icon=noicon
arg=<macro>
run("SM Manual");
</macro>

<button>
label=About
icon=noicon
arg=<macro>
run("SM About");
</macro>
</line>


<text>--------------------------------SMLM viewer--------------------------------
<line>
<button>
label=Import SML
icon=noicon
arg=<macro>
run("01 Import SML ");
</macro>

<button>
label=Import SML dual
icon=noicon
arg=<macro>
run("01b Import Dual SML ");
</macro>
</line>

<line>
<button>
label=SMLM viewer v0.6.0
icon=noicon
arg=<macro>
// naam macro moet standaard naam krijgen
// extra info macro moet versie aangeven
run("02 SMLM viewer v0 6.0 ");
</macro>
</line>

<line>
<button>
label=ROI Analysis
icon=noicon
arg=<macro>
run("03 ROI analysis ");
</macro>
</line>

<line>
<button>
label=convert Elyra to MTrackJ
icon=noicon
arg=<macro>
run("04 convert Elyra to Mtrack ");
</macro>

<button>
label=convert SMLM to MTrackJ beta
icon=noicon
arg=<macro>
run("04 convert SMLM to Mtrack beta20130618");
</macro>
</line>

<line>
<button>
label=Random PALM Image Generator
icon=noicon
arg=<macro>
run("05 Random PALM image generator");
</macro>
</line>


