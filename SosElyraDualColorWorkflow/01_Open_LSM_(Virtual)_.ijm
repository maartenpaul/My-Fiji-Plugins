file = File.openDialog("Open");
run("Bio-Formats", "open=["+file+"] color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");