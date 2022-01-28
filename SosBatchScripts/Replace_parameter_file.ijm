dir = getDirectory("Choose a directory");
list = getFileList(dir);
path1 = dir + File.separator+ "parameters.txt"
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], "/")){
	path2 = dir+list[i] +  File.separator+ "parameters.txt";
	File.copy(path1, path2);
	}
}
