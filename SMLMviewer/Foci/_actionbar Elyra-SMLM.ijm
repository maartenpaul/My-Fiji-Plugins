// Action Bar description file : Elyra-SMLM action bar
run("Action Bar","/plugins/01 SMLM viewer/Foci/_actionbar Elyra-SMLM.ijm");
exit();




<text>--------------------------------SMLM viewer--------------------------------
<line>
<button>
label=1) Import SML file
icon=noicon
arg=<macro>
run("01 Import SML ");
</macro>
</line>

<line>
<button>
label=2) SMLM viewer 
icon=noicon
arg=<macro>
// naam macro moet standaard naam krijgen
// extra info macro moet versie aangeven
run("02 SMLM viewer ");
</macro>
</line>

<line>
<button>
label=3) Clicker MP
icon=noicon
arg=<macro>
run(" clicker_MP");
</macro>
</line>

<line>
<button>
label=4b) ROI Analysis
icon=noicon
arg=<macro>
run(" fociROI analysis ");
</macro>
<button>
label=4a) ROI Analysis + StackMaker
icon=noicon
arg=<macro>
run(" fociROI plusStackMaker ");
</macro>
</line>


