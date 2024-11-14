#@ File (label="Select file",style="directory") file
#@ Double (value=80.0, persist=false) intensity_threshold

#Fiji Jython script
import sys
import os
from ij import IJ
from ij import WindowManager
from java.io import File
from ij.plugin.frame import RoiManager
from ij.measure import ResultsTable
from fiji.plugin.trackmate.io import TmXmlWriter
from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import DogDetectorFactory
from fiji.plugin.trackmate.tracking.jaqaman import SparseLAPTrackerFactory
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettings
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
import fiji.plugin.trackmate.action.LabelImgExporter as LabelImgExporter
from java.util import Collections, ArrayList
import java.awt.Frame as Frame

folder = file.getName()
outputfolder=file.getAbsolutePath()

IJ.run("Bio-Formats", "open=[" + file.getAbsolutePath() + "/" + file.getName()+".tif] color_mode=Default open_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT use_virtual_stack")
imp = WindowManager.getCurrentImage()


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
settings.detectorFactory = DogDetectorFactory()
settings.detectorSettings = {
    'DO_SUBPIXEL_LOCALIZATION' : True,
    'RADIUS' : 0.25,
    'TARGET_CHANNEL' : 1,
    'THRESHOLD' : intensity_threshold,
    'DO_MEDIAN_FILTERING' : False,
    
    
}  

# Configure spot filters - Classical filter on quality

# Configure tracker - We want to allow merges and fusions
settings.trackerFactory = SparseLAPTrackerFactory()
settings.trackerSettings = settings.trackerFactory.getDefaultSettings() # almost good enough
settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = False
settings.trackerSettings['ALLOW_TRACK_MERGING'] = False
settings.trackerSettings['ALLOW_GAP_CLOSING'] = True
settings.trackerSettings['LINKING_MAX_DISTANCE'] = 1.0
settings.trackerSettings['MAX_FRAME_GAP'] = 1
settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = 1.0

# Add ALL the feature analyzers known to TrackMate. They will 
# yield numerical features for the results, such as speed, mean intensity etc.
settings.addAllAnalyzers()

# Configure track filters - We want to get rid of the two immobile spots at
# the bottom right of the image. Track displacement must be above 10 pixels.

if os.path.exists(file.getAbsolutePath() + "mask.zip") is True:
	rm = RoiManager.getInstance()
	if not rm:
	      rm = RoiManager()
	rm.reset()
	roi_file = file.getAbsolutePath() + "//mask.zip"
	print(roi_file)
	rm.runCommand("Open", roi_file)
	print(rm.getCount())
	r=rm.getSelectedRoisAsArray()
	 
	settings.setRoi(r[0])
	
# Add ALL the feature analyzers known to TrackMate. They will 
# yield numerical features for the results, such as speed, mean intensity etc.
settings.addAllAnalyzers()
 

filter2 = FeatureFilter('NUMBER_SPOTS', 5, True)
settings.addTrackFilter(filter2)
 
 
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
rt = ResultsTable()
# Iterate over all the tracks that are visible.
for id in model.getTrackModel().trackIDs(True):
 
    # Fetch the track feature from the feature model. 
	# Get all the spots of the current track.
	# write to resultsTable
    track = model.getTrackModel().trackSpots(id)
    for spot in track:
        sid = spot.ID()
        x=spot.getFeature('POSITION_X')
        y=spot.getFeature('POSITION_Y')
        t=spot.getFeature('FRAME')
        q=spot.getFeature('QUALITY')
        snr=spot.getFeature('SNR_CH1')
       	total_ch1=spot.getFeature('TOTAL_INTENSITY_CH1')
        total_ch2=spot.getFeature('TOTAL_INTENSITY_CH2')
        total_ch3=spot.getFeature('TOTAL_INTENSITY_CH3')
        mean_ch1=spot.getFeature('MEAN_INTENSITY_CH1')
        mean_ch2=spot.getFeature('MEAN_INTENSITY_CH2')
        mean_ch3=spot.getFeature('MEAN_INTENSITY_CH3')
        area=spot.getFeature('AREA')
        radius=spot.getFeature('RADIUS')
        model.getLogger().log('\tspot ID = ' + str(sid) + ','+str(x)+','+str(y)+','+str(t)+','+str(q) + ','+str(snr) + ',' + str(mean_ch1)+","+str(id))
        rt.addValue("sid",sid)
        rt.addValue("x",x)
        rt.addValue("y",y)
        rt.addValue("frame",t)
        rt.addValue("q",snr)
        rt.addValue("total_ch1",total_ch1)
        rt.addValue("total_ch2",total_ch1)
        rt.addValue("total_ch3",total_ch1)
        rt.addValue("mean_ch1",mean_ch1)
        rt.addValue("mean_ch2",mean_ch2)
        rt.addValue("mean_ch3",mean_ch3)
        rt.addValue("area",area)
        rt.addValue("radius",radius)
        rt.addValue("trajectory",id)
        rt.addRow()

print(rt.size())
rt.deleteRow(rt.size()-1)

rt.show("ResultsTable")

rt_file = File(outputfolder ,"Tracks.csv")
rt.save(rt_file.getAbsolutePath())
rt.reset()
 
# A selection.
selectionModel = SelectionModel( model )
 
# Read the default display settings.
ds = DisplaySettingsIO.readUserDefault()
 
outFile_TMXML= File(outputfolder, "export.xml")

writer = TmXmlWriter(outFile_TMXML) #a File path object
writer.appendModel(trackmate.getModel()) #trackmate instantiate like this before trackmate = TrackMate(model, settings)
writer.appendSettings(trackmate.getSettings())
writer.writeToFile()


