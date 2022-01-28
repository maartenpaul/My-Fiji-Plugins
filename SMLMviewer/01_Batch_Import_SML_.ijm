dir = getDirectory("Choose a directory");
list = getFileList(dir);

for (i=0; i<list.length; i++) {
	if(endsWith(list[i],".txt")){
		run("01 Import SML ", "width=512 heigth=512 pixel=100 data=Elyra 2dual open=[" + dir+list[i]+"]");
	}
}