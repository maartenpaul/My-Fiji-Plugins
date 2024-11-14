#@ File[] (label = "Input files", style="File") files
#@ File (label = "Output folder", style = "directory") outputFolder
#@ Integer (label = "Number of slices for training", min=1, value=5) trainSlices
#@ Integer (label = "Number of slices for validation", min=1, value=2) validateSlices

import os
from ij import IJ, ImagePlus
from ij.io import FileSaver
import random

def log(message):
    IJ.log(message)

def save_slices(virtualStack, selectedSlices, baseFilename, subfolder):
    for sliceNum in selectedSlices:
        virtualStack.setSlice(sliceNum)
        sliceImage = ImagePlus("{0}_slice{1}".format(baseFilename, sliceNum), virtualStack.getProcessor().duplicate())
        
        outputFilename = "{0}_slice{1}.tif".format(baseFilename, sliceNum)
        outputPath = os.path.join(outputFolder.getAbsolutePath(), subfolder, outputFilename)
        
        FileSaver(sliceImage).saveAsTiff(outputPath)
        sliceImage.close()

def run():
    log("Starting script execution...")
    
    # Create train and validate subfolders
    trainFolder = os.path.join(outputFolder.getAbsolutePath(), "train")
    validateFolder = os.path.join(outputFolder.getAbsolutePath(), "validate")
    if not os.path.exists(trainFolder):
        os.makedirs(trainFolder)
        log("Created training folder: {}".format(trainFolder))
    if not os.path.exists(validateFolder):
        os.makedirs(validateFolder)
        log("Created validation folder: {}".format(validateFolder))

    totalFiles = len(files)
    for fileIndex, file in enumerate(files, 1):
        log("Processing file {0} of {1}: {2}".format(fileIndex, totalFiles, file.getName()))
        
        virtualStack = IJ.openVirtual(file.getAbsolutePath())
        totalSlices = virtualStack.getNSlices()
        log("Total slices in stack: {}".format(totalSlices))
        
        if trainSlices + validateSlices > totalSlices:
            log("Warning: Requested more slices than available. Adjusting slice counts.")
            actualTrainSlices = min(trainSlices, totalSlices)
            actualValidateSlices = min(validateSlices, totalSlices - actualTrainSlices)
        else:
            actualTrainSlices = trainSlices
            actualValidateSlices = validateSlices
        
        log("Selecting {} slices for training and {} slices for validation".format(actualTrainSlices, actualValidateSlices))

        allSlices = range(1, totalSlices + 1)
        allSlices = list(allSlices)
        random.shuffle(allSlices)
        
        trainSelectedSlices = allSlices[:actualTrainSlices]
        validateSelectedSlices = allSlices[actualTrainSlices:actualTrainSlices+actualValidateSlices]

        baseFilename = os.path.splitext(file.getName())[0]
        
        log("Saving training slices...")
        save_slices(virtualStack, trainSelectedSlices, baseFilename, "train")
        log("Saving validation slices...")
        save_slices(virtualStack, validateSelectedSlices, baseFilename, "validate")

        virtualStack.close()
        log("Finished processing {}".format(file.getName()))

    log("Script execution completed.")

run()