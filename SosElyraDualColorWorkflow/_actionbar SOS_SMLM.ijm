// Action Bar description file : SOS-SMLM action bar
run("Action Bar","/plugins/SOS_Elyra_dual_color_workflow/_actionbar SOS_SMLM.ijm");
exit();

<text>--------------------------------Processing--------------------------------
<line>
<button>
label=Open LSM
icon=noicon
arg=<macro>
run("01 Open LSM (Virtual) ");
</macro>
</line>

<line>
<button>
label=prepare LSM for SOS
icon=noicon
arg=<macro>
run("02 prepare LSM for SOS ");
</macro>
</line>

<line>
<button>
label=Select beads (t)
icon=noicon
arg=<macro>
run("03 Bead Clicker ");
</macro>
</line>


<line>
<button>
label=Save beads to mask
icon=noicon
arg=<macro>
run("04 save beads to mask ");
</macro>
</line>

<line>
<button>
label=Run SOS
icon=noicon
arg=<macro>
run("05 Run SOS ");
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