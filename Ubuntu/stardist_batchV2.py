#@ File (label="Select folder for ",style="directory") outputfolder

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
from fiji.plugin.trackmate.stardist import StarDistDetectorFactory
from fiji.plugin.trackmate.tracking import LAPUtils
from fiji.plugin.trackmate.tracking.overlap import OverlapTrackerFactory
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettings
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
import fiji.plugin.trackmate.action.IJRoiExporter as IJRoiExporter
import fiji.plugin.trackmate.action.ExportTracksToXML as ExportTracksToXML
import fiji.plugin.trackmate.action.ExtractTrackStackAction as ExtractTrackStackAction
import plugin.trackmate.examples.action.ExtractTrackStackActionMP as ExtractTrackStackActionMP
from java.util import Collections, ArrayList
import java.awt.Frame as Frame



outFile = File(outputfolder, "exportTracks.xml")
print(outFile)
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

fm = model.getFeatureModel()

trackIDs = ArrayList(model.getTrackModel().trackIDs(True))
Frame = Frame()
####create cropped and aligned nuclei movies
for trackID in trackIDs: 
	selectionModel.clearSelection()
	disp = DisplaySettings()
	track = ArrayList(model.getTrackModel().trackSpots(trackID))
	spot = track[0]
	spotID = spot.ID()
	selectionModel.addSpotToSelection(spot)
	ETSA = ExtractTrackStackActionMP()
	
	stackTrack = ETSA.execute(trackmate,selectionModel,disp,Frame)
	
#save trackstack with trackID
	stackname=str(spotID)+"stack.tif"
	file_name = File(outputfolder,stackname)
	imp= IJ.getImage()
	IJ.saveAsTiff(imp,file_name.getAbsolutePath())

#obtain ROIs from track
	rm = RoiManager.getInstance()
	if not rm:
	      rm = RoiManager()
	rm.reset()
	selectionModel.clearSelection()
	selectionModel.addSpotToSelection(track)
	spots = ArrayList(model.getTrackModel().trackSpots(trackID))
	exporter = IJRoiExporter(trackmate.getSettings().imp, model.getLogger())
	exporter.export(spots)
	rm = RoiManager.getInstance()
	rm.runCommand("Select All")
	roi_name = File(outputfolder,str(spotID)+"stack.zip")
	rm.runCommand("Save", roi_name.getAbsolutePath())
	#clean up outside the ROIs
	number_roi = rm.getCount()
	number_of_ch = imp.getDimensions()[2]
	print(number_of_ch)
	rm.runCommand("Sort")
	for i in range(number_roi):
		rm.select(i)
		slice = imp.getSlice()
		for j in range(number_of_ch):
			imp.setC(j+1)
			imp.setT(i)
			IJ.run("center roi ")
			IJ.run("Clear Outside", "slice")
	stackname=str(spotID)+"stack_masked.tif"
	file_name = File(outputfolder,stackname)
	IJ.saveAsTiff(imp,file_name.getAbsolutePath())
	imp.close()
		
####

#initiate new results table
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
        mean=spot.getFeature('MEAN_INTENSITY_CH1')
        model.getLogger().log('\tspot ID = ' + str(sid) + ','+str(x)+','+str(y)+','+str(t)+','+str(q) + ','+str(snr) + ',' + str(mean)+","+str(id))
        rt.addValue("sid",sid)
        rt.addValue("x",x)
        rt.addValue("y",y)
        rt.addValue("t",t)
        rt.addValue("q",snr)
        rt.addValue("mean",mean)
        rt.addValue("tid",id)
        rt.addRow()

rt.show("ResultsTable")

rt_file = File(outputfolder ,"NucleiTracks.txt")
rt.save(rt_file.getAbsolutePath())
rt.reset()

outFile = File(outputfolder, "exportTracks.xml")
ExportTracksToXML.export(model, settings, outFile)
outFile_TMXML= File(outputfolder, "exportXML.xml")

writer = TmXmlWriter(outFile_TMXML) #a File path object
writer.appendModel(trackmate.getModel()) #trackmate instantiate like this before trackmate = TrackMate(model, settings)
writer.appendSettings(trackmate.getSettings())
writer.writeToFile()

#rm = RoiManager.getInstance()
#if not rm:
#      rm = RoiManager()
#rm.reset()

#spots = trackmate.getModel().getSpots().iterable(True)
#exporter = IJRoiExporter(trackmate.getSettings().imp, model.getLogger())
#exporter.export(spots)
#rm = RoiManager.getInstance()
#rm.runCommand("Select All")
#roi_name = File(outputfolder,"nucleiROI.zip")
#rm.runCommand("Save", roi_name.getAbsolutePath())
