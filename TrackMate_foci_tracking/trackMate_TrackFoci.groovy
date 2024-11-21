//@ File[] (label = "Input files", style="File") files
//@ File (label="Select folder for output",style="directory") outputFolder
//@ Integer (label="target channel",min=1,max=10, value=1) targetchannel
//@ String (label = "Segmentation method", choices={"DoG spot detector", "Ilastik segmentation"}, style="listBox") spotDetector
//@ String (value="DoG spot detector options", visibility="MESSAGE",required=false) DoGMessage
//@ Double(label="Spot diameter",value=0.5) spotDiameter
//@ Double(label="Quality threshold (spot detection)",value=50.0) spotQuality
//@ String (value="Ilastik spot detector options", visibility="MESSAGE",required=false) IlastikMessage
//@ File (label="Select Ilastik model file",style="file",default="C:/") modelFile
//@ Integer (label="Class index",min=0,max=10, value=1) classindex
//@ String (value="Tracking options", visibility="MESSAGE",required=false) TrackMessage
//@ Double(label="Linking Max Distance (um)",value=1.0) maxDistance
//@ Boolean (label = "Allow Gap Closing?", value=true) allowGap
//@ Integer(label="Maximum Gap (frames)",value=1) maxGap
//@ Double(label="Linking Max Distance (um)",value=1.0) maxGapDistance

//v2024.1.0
// Maarten Paul, Erasmus MC


// ImageJ imports
import ij.IJ
import ij.WindowManager
import ij.measure.ResultsTable
import ij.plugin.frame.RoiManager

// Java imports
import java.awt.Frame
import java.io.File
import java.util.ArrayList
import java.util.Collections

// TrackMate imports
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.TrackMate
import fiji.plugin.trackmate.SelectionModel
import fiji.plugin.trackmate.Logger
import fiji.plugin.trackmate.io.TmXmlWriter
import fiji.plugin.trackmate.io.CSVExporter
import fiji.plugin.trackmate.detection.DogDetectorFactory
import fiji.plugin.trackmate.tracking.jaqaman.LAPUtils
import fiji.plugin.trackmate.tracking.jaqaman.SparseLAPTrackerFactory
import fiji.plugin.trackmate.ilastik.IlastikDetectorFactory
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettingsIO
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettings
import fiji.plugin.trackmate.action.fit.SpotFitterController
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter
import fiji.plugin.trackmate.action.IJRoiExporter
import fiji.plugin.trackmate.action.ExportTracksToXML
import fiji.plugin.trackmate.visualization.table.TrackTableView

def trackFoci(outputFolder, filename, imp, spotDetector) {
    println "Starting trackFoci for file: $filename"
    fileOutputFolder = new File(outputFolder,filename)
    fileOutputFolder.mkdirs()
    // Create the model object
    def model = new Model()
    model.setLogger(Logger.IJ_LOGGER)
    
    // Prepare settings object
    def settings = new Settings(imp)
    
    // Configure detector based on selection
    if (spotDetector == "DoG spot detector") {
        println "Using DoG detector"
        settings = detectFociDoG(settings)
    } else if (spotDetector == "Ilastik segmentation") {
        println "Using Ilastik detector"
        settings = detectFociIlastik(settings)
    }
    
    // Configure tracker
    settings.trackerFactory = new SparseLAPTrackerFactory()
    settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
    
    // Only modify specific settings
    settings.trackerSettings['LINKING_MAX_DISTANCE'] = maxDistance
    settings.trackerSettings['ALLOW_GAP_CLOSING'] = allowGap
    settings.trackerSettings['MAX_FRAME_GAP'] = maxGap
    settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = maxGapDistance
    settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = false
    settings.trackerSettings['SPLITTING_MAX_DISTANCE'] = 1.0d
    settings.trackerSettings['ALLOW_TRACK_MERGING'] = false
    settings.trackerSettings['MERGING_MAX_DISTANCE'] = 1.0d
    
    // Add all analyzers
    settings.addAllAnalyzers()
    
    // Create and process TrackMate instance
    def trackmate = new TrackMate(model, settings)
    
    println "Checking TrackMate input"
    if (!trackmate.checkInput()) {
        println "TrackMate input check failed: ${trackmate.getErrorMessage()}"
        return
    }
    
    println "Processing TrackMate"
    if (!trackmate.process()) {
        println "TrackMate processing failed"
        return
    }
    
    // Create selection model
    def selectionModel = new SelectionModel(model)
    def ds = DisplaySettingsIO.readUserDefault()
    
    // Process results
    def rt = new ResultsTable()
    
    // Process all tracks
    model.getTrackModel().trackIDs(true).each { id ->
        def track = model.getTrackModel().trackSpots(id)
        
        track.each { spot ->
            def sid = spot.ID()
            def x = spot.getFeature('POSITION_X')
            def y = spot.getFeature('POSITION_Y')
            def t = spot.getFeature('FRAME')
            def q = spot.getFeature('QUALITY')
            def snr = spot.getFeature('SNR_CH1')
            def mean = spot.getFeature('MEAN_INTENSITY_CH1')
            def mean_ch3 = spot.getFeature('MEAN_INTENSITY_CH3')
            def radius = spot.getFeature('RADIUS')
            
            // Add to results table
            rt.addValue("sid", sid)
            rt.addValue("x", x)
            rt.addValue("y", y)
            rt.addValue("t", t)
            rt.addValue("q", snr)
            rt.addValue("mean", mean)
            rt.addValue("mean_ch3", mean_ch3)
            rt.addValue("radius", radius)
            rt.addValue("tid", id)
            rt.addRow()
        }
    }
    
    // Save results
    def rt_file = new File(fileOutputFolder, filename + "FociTracks.txt")
    rt.save(rt_file.absolutePath)
    rt.reset()
    
    
    
     // Continue with table exports
    def spotTable = TrackTableView.createSpotTable(model, ds)
    spotTable.exportToCsv(new File(fileOutputFolder, "foci_track_spots.csv"))
    
	def only_visible = false
	// If you set this flag to False, it will include all the spots,
	// the ones not in tracks, and the ones not visible.
	CSVExporter.exportSpots( new File(fileOutputFolder, "foci_unfiltered_spots.csv").absolutePath, model, only_visible )

    def trackTable = TrackTableView.createTrackTable(model, ds)
    trackTable.exportToCsv(new File(fileOutputFolder, "foci_tracks.csv"))
    
    // Save TrackMate XML
    def outFile_TMXML = new File(fileOutputFolder, "foci_trackmate.xml")
	def writer = new TmXmlWriter(outFile_TMXML) //a File path object
	writer.appendModel(trackmate.getModel()) //trackmate instantiate like this before trackmate = TrackMate(model, settings)
	writer.appendSettings(trackmate.getSettings())
	writer.writeToFile()
    
    // Handle ROIs
    def rm = RoiManager.getInstance() ?: new RoiManager()
    rm.reset()
    
    def spots = trackmate.getModel().getSpots().iterable(true)
    def exporter = new IJRoiExporter(trackmate.getSettings().imp, model.getLogger())
    exporter.export(spots)
    rm = RoiManager.getInstance()
    rm.runCommand("Select All")
    def roi_name = new File(fileOutputFolder, "foci_ROIs.zip")
    rm.runCommand("Save", roi_name.absolutePath)
    
    println "Completed processing for file: $filename"
}

def detectFociIlastik(settings) {
    println "Configuring Ilastik detector"
    println "Model file path: ${modelFile.absolutePath}"
    println "Target channel: ${targetchannel}"
    println "Class index: ${classindex}"
    
    settings.detectorFactory = new IlastikDetectorFactory()
    settings.detectorSettings = [
        'CLASSIFIER_FILEPATH': modelFile.absolutePath,
        'TARGET_CHANNEL': targetchannel as int,
        'CLASS_INDEX': classindex as int,
        'PROBA_THRESHOLD': 0.3d
    ] as Map
    
    println "Ilastik detector settings configured"
    return settings
}

def detectFociDoG(settings) {
    println "Configuring DoG detector"
    println "Spot diameter: ${spotDiameter}"
    println "Target channel: ${targetchannel}"
    println "Quality threshold: ${spotQuality}"
    
    settings.detectorFactory = new DogDetectorFactory()
    settings.detectorSettings = [
        'DO_SUBPIXEL_LOCALIZATION': true,
        'RADIUS': spotDiameter/2,
        'TARGET_CHANNEL': targetchannel as int,
        'THRESHOLD': spotQuality,
        'DO_MEDIAN_FILTERING': false
    ] as Map
    
    println "DoG detector settings configured"
    return settings
}

// Main execution
println "Starting script execution"
println "Total files to process: ${files.size()}"

def imageN = 0
def totalN = files.size()

files.each { file ->
    imageN++
    println "Processing file ${imageN} of ${totalN}: ${file.name}"
    
    IJ.showStatus("Detecting foci in image ${imageN} of a total of ${totalN}")
    IJ.showProgress(imageN, totalN)
    
    def filename = file.getName()
    def filenameParts = filename.split("\\.")
    def baseFilename = filenameParts[0]
    println "Base filename: ${baseFilename}"
    
    def imp = IJ.openImage(file.absolutePath)
    if (imp == null) {
        println "Failed to open image: ${file.absolutePath}"
        return
    }
    imp.show()
    trackFoci(outputFolder, baseFilename, imp, spotDetector)
    
    imp.changes = false
    imp.close()
    
    println "Completed processing file ${imageN} of ${totalN}"
}

// Clean up ROI Manager
def rm = RoiManager.getInstance()
if (rm != null) {
    rm.reset()
    rm.close()
}

println "Script execution completed"