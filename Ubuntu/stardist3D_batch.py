#@ File (label="Select folder for ",style="file") file

import sys
import os
from ij import IJ
from ij import WindowManager
from java.io import File
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.stardist import StarDistDetectorFactory
from fiji.plugin.trackmate.tracking.overlap import OverlapTrackerFactoryfrom fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettings
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
import fiji.plugin.trackmate.action.LabelImgExporter as LabelImgExporter
from java.util import Collections, ArrayList
import java.awt.Frame as Frame


# IJ.run("Split Channels");
# selectWindow("C1-001 LSM.czi");

folder = file.getParentFile()
filename = file.getName()
filename = filename[:-4]
print(filename)

IJ.run("Bio-Formats", "open=[" + file.getAbsolutePath() + "] color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack")
IJ.run("Split Channels")
imp = WindowManager.getCurrentImage()

saveFilename = "C2-"+filename+".tif"
saveFile = File(folder,saveFilename)
IJ.save(imp,saveFile.getAbsolutePath())
imp.close()
imp = WindowManager.getCurrentImage()
saveFilename = "C1-"+filename+".tif"
saveFile = File(folder,saveFilename)
IJ.save(saveFile.getAbsolutePath())
#imp.close()


#IJ.run("Bio-Formats", "open=[" + file.getAbsolutePath() + "] color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack")

imp = WindowManager.getCurrentImage()
height=imp.getDimensions()[3]


IJ.run("Enhance Contrast...", "saturated=10 process_all use")
IJ.run("Re-order Hyperstack ...", "channels=[Channels (c)] slices=[Frames (t)] frames=[Slices (z)]")
IJ.run("Size...", "width=512 height=512 depth="+ str(height) + " constrain average interpolation=Bilinear")



# We have to do the following to avoid errors with UTF8 chars generated in 
# TrackMate that will mess with our Fiji Jython.
reload(sys)
sys.setdefaultencoding('utf-8')
# Get currently selected image
imp = WindowManager.getCurrentImage()

#----------------------------
# Create the model object now
#----------------------------
 
# Some of the parameters we configure below need to have
# a reference to the model at creation. So we create an
# empty model now.
 
model = Model()
 
# Send all messages to ImageJ log window.
model.setLogger(Logger.IJ_LOGGER)

#------------------------
# Prepare settings object
#------------------------
 
settings = Settings(imp)
 
# Configure detector - We use the Strings for the keys
settings.detectorFactory = StarDistDetectorFactory()
settings.detectorSettings = {

    'TARGET_CHANNEL' : 2,
    
}  

# Configure spot filters - Classical filter on quality
filter1 = FeatureFilter('AREA', 100, True)
settings.addSpotFilter(filter1)
 
# Configure tracker - We want to allow merges and fusions
settings.trackerFactory = OverlapTrackerFactory()
#settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap() # almost good enough
settings.trackerSettings['IOU_CALCULATION'] = "PRECISE"
settings.trackerSettings['MIN_IOU'] = 0.1
settings.trackerSettings['SCALE_FACTOR'] = 1.0
 
# Add ALL the feature analyzers known to TrackMate. They will 
# yield numerical features for the results, such as speed, mean intensity etc.
settings.addAllAnalyzers()
 
 
#-------------------
# Instantiate plugin
#-------------------
 
trackmate = TrackMate(model, settings)
 
#--------
# Process
#--------
 
ok = trackmate.checkInput()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))
 
ok = trackmate.process()
if not ok:
    sys.exit(str(trackmate.getErrorMessage()))

 #----------------
# Display results
#----------------
 
# A selection.
selectionModel = SelectionModel( model )
 
# Read the default display settings.
ds = DisplaySettingsIO.readUserDefault()
 
displayer =  HyperStackDisplayer( model, selectionModel, imp, ds )
displayer.render()
displayer.refresh()

# Echo results with the logger we set at start:
model.getLogger().log( str( model ) )

image = LabelImgExporter.createLabelImagePlus(trackmate,False,True,False,model.getLogger())

image.show()
IJ.run("Size...", "width=1024 height=1024 depth="+ str(height) +" constrain average interpolation=Bilinear");
saveFilename = "C0-"+filename+".tif"
saveFile = File(folder,saveFilename)
IJ.save(image,saveFile.getAbsolutePath())

