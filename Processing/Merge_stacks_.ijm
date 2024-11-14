//Merge multiple stack
dir = getDir("Choose a Directory");

Dialog.create("Title");
Dialog.addNumber("Number of positions:", 9);
Dialog.addNumber("Number of folders:", 2);
Dialog.show();
n_pos = Dialog.getNumber();
n_folder = Dialog.getNumber();
for (i = 1; i < n_pos+1; i++) {
	n_pos_string=toString(i);
	open(dir+"/MAX_Mark_and_Find Position"+IJ.pad(n_pos_string, 3)+".tif");
}
