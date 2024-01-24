#@ File[] (label = "Input files", style="File") files
#@ File (label = "Output folder", style = "directory") outputFolder

run("Close All");
tableName = "FociResults";
Table.create(tableName);
nrOfImages = files.length;
for (f = 0; f < nrOfImages; f++) {
	//print("\nProcessing file "+f+1+"/"+nrOfImages+": "+files[f] + "\n");

	open(files[f]);
	resultName = File.name;
	
	if (f==0){
		tableHeadingsStr=Table.headings;
		tableHeadings=split(tableHeadingsStr,"\t");
		print(tableHeadings[1]);
		nHeadings = tableHeadings.length;		
		print(nHeadings);
	

		for (i =0; i < nHeadings; i++) {

			column= Table.getColumn(tableHeadings[i],resultName);

			Table.setColumn(tableHeadings[i], column,tableName); 

		}
		ImageColumn=newArray(column.length);
		for(j=0; j <ImageColumn.length;j++){
			ImageColumn[j] = File.nameWithoutExtension;
		}
		Table.setColumn("imageName",ImageColumn,tableName);
	} else {
		for (i =0; i < nHeadings; i++) {
			print(tableHeadings[i]);
			column1 = Table.getColumn(tableHeadings[i],tableName);
			print(column1.length);
			column2 = Table.getColumn(tableHeadings[i],resultName);
			print(column2.length);
			columnMerge=Array.concat(column1,column2);
			print(columnMerge.length);
			Table.setColumn(tableHeadings[i],columnMerge ,tableName); 
		}
		ImageColumn=newArray(column2.length);
		for(j=0; j <ImageColumn.length;j++){
			ImageColumn[j] = File.nameWithoutExtension;
		}
		column1 = Table.getColumn("imageName",tableName);
		print(column1.length);
		columnMerge=Array.concat(column1,ImageColumn);
		Table.setColumn("imageName",columnMerge,tableName);
	}
	close(resultName);
}
Table.save(outputFolder+File.separator+"FociResults.tsv",tableName);
