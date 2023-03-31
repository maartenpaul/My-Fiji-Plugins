#@ File[] (label="Select files for analysis",style="directories") list
setBatchMode(true)
n_files = list.length;
for (i = 0; i < n_files; i++) {
	print(list[i]);
	run("trackmate with SOSmask ","file='"+list[i]+"' intensity_threshold=80.0");
	close();
}
setBatchMode(false)