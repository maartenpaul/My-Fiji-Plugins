// Action Bar description file : SOS-SMLM action bar
run("Action Bar","/plugins/01 SMLM viewer/_actionbar SMLM.ijm");
exit();

<text>--------------------------------SMLM viewer--------------------------------
<line>
<button>
label=Import SML
icon=noicon
arg=<macro>
run("01 Import SML ");
</macro>

<button>
label=Batch import SML
icon=noicon
arg=<macro>
run("01 Batch Import SML ");
</macro>
</line>

<line>
<button>
label=SMLM viewer 
icon=noicon
arg=<macro>
// naam macro moet standaard naam krijgen
// extra info macro moet versie aangeven
run("02 SMLM viewer ");
</macro>
</line>

<line>
<button>
label=Flip and Scale
icon=noicon
arg=<macro>
// naam macro moet standaard naam krijgen
// extra info macro moet versie aangeven
run("flip n scale");
</macro>
</line>

<line>
<button>
label=Run Clicker MP
icon=noicon
arg=<macro>
run(" clicker MP");
</macro>
</line>

<line>
<button>
label=ROI renumber
icon=noicon
arg=<macro>
run(" roinumber");
</macro>
</line>

<line>
<button>
label=ROI analysis
icon=noicon
arg=<macro>
run(" fociROI analysis ");
</macro>
</line>

<line>
<button>
label=Close all
icon=noicon
arg=<macro>
run("Close All Windows");
</macro>
</line>

