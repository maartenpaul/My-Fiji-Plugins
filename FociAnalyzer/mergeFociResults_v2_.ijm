#@ File (label = "Output folder", style = "directory") outputFolder
files = getFileList(outputFolder);
run("Close All");
tableName = "FociResults";
Table.create(tableName);
nrOfImages = files.length;
for (f = 0; f < nrOfImages; f++) {
	k = 0;
	//print("\nProcessing file "+f+1+"/"+nrOfImages+": "+files[f] + "\n");
	if (endsWith(files[f], ".tsv")&&!endsWith(files[f], "FociResults.tsv")){
		open(files[f]);
		resultName = File.name;
		
		if (k==0){
			k = 1;
			tableHeadingsStr=Table.headings;
			tableHeadings=split(tableHeadingsStr,"\t");
			nHeadings = tableHeadings.length;		
			print(nHeadings);
			for (i =0; i < nHeadings; i++) {
				column= Table.getColumn(tableHeadings[i],resultName);
				Table.setColumn(tableHeadings[i], column,tableName); 
			}
			ImageColumn=newArray(column.length);
			for(j=0; j <ImageColumn.length;j++){
				ImageName = File.nameWithoutExtension;
				ImageName= split(ImageName, "(__)");
				ImageName = ImageName[0];
				ImageColumn[j] = ImageName;
			}
			Table.setColumn("imageName",ImageColumn,tableName);
		} else {
			for (i =0; i < nHeadings; i++) {
				column1 = Table.getColumn(tableHeadings[i],tableName);
				column2 = Table.getColumn(tableHeadings[i],resultName);
				columnMerge=Array.concat(column1,column2);
				Table.setColumn(tableHeadings[i],columnMerge ,tableName); 
			}
			ImageColumn=newArray(column2.length);
			for(j=0; j <ImageColumn.length;j++){
				ImageName = File.nameWithoutExtension;
				ImageName= split(ImageName, "(__)");
				ImageName = ImageName[0];
				ImageColumn[j] = ImageName;
			}
			column1 = Table.getColumn("imageName",tableName);
			columnMerge=Array.concat(column1,ImageColumn);
			Table.setColumn("imageName",columnMerge,tableName);
		}
		close(resultName);
}
}
Table.save(outputFolder+File.separator+"FociResults.tsv",tableName);
