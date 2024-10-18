#@ File[] (label="Select input file(s)", style="files") input_files
#@ File (label="Select output folder", style="directory") outputfolder
#@ Integer (label="Segmentation channel", value=1) segmentationChannel
#@ Integer (label="Minimum nucleus area", value=100) minNucleusArea
#@ Integer (label="Maximum nucleus area", value=10000) maxNucleusArea
#@ Integer (label="Minimum nucleus track length (frames)", value=4) minTrackLength
#@ Double (label="Downscale",min=1.0,max=10.0, value=1.0) downscale
#@ Double (label="Saturate",min=0.0,max=100.0, value=0.0) saturate
#@ Boolean (label="Register nuclei in track stacks?", value=true) registerNucleus
#@ Boolean (label="Use label map instead of StarDist?", value=false) useLabelMap

import ij.IJ
import ij.ImagePlus
import ij.WindowManager
import ij.plugin.frame.RoiManager
import ij.measure.ResultsTable
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.TrackMate
import fiji.plugin.trackmate.SelectionModel
import fiji.plugin.trackmate.Logger
import fiji.plugin.trackmate.detection.LabelImageDetectorFactory
import fiji.plugin.trackmate.stardist.StarDistDetectorFactory
import fiji.plugin.trackmate.tracking.overlap.OverlapTrackerFactory
import fiji.plugin.trackmate.gui.displaysettings.DisplaySettingsIO
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter
import fiji.plugin.trackmate.action.IJRoiExporter
import fiji.plugin.trackmate.action.LabelImgExporter
import fiji.plugin.trackmate.io.TmXmlWriter
import plugin.trackmate.examples.action.ExtractTrackStackActionMP
import fiji.plugin.trackmate.action.LabelImgExporter.LabelIdPainting


// Logging functions
def logInfo(message) {
    IJ.log("INFO: $message")
}

def logError(message) {
    IJ.log("ERROR: $message")
}

// Input validation
def validateInputs() {
    if (segmentationChannel < 1) {
        logError("Segmentation channel must be >= 1")
        return false
    }
    if (minNucleusArea >= maxNucleusArea) {
        logError("Minimum nucleus area must be less than maximum nucleus area")
        return false
    }
    if (minTrackLength < 1) {
        logError("Minimum track length must be >= 1")
        return false
    }
    if (downscale < 1.0 || downscale > 10.0) {
        logError("Downscale must be between 1.0 and 10.0")
        return false
    }
    if (saturate < 0.0 || saturate > 100.0) {
        logError("Saturate must be between 0.0 and 100.0")
        return false
    }
    return true
}

// Cleanup function
def cleanup() {
    WindowManager.getIDList().each { id ->
        def imp = WindowManager.getImage(id)
        if (imp) {
            imp.changes = false
            imp.close()
        }
    }
}

// Center ROI function
def centerRoi(imp) {
    def roi = imp.getRoi()
    def bounds = roi.getBounds()
    def width = imp.getWidth()
    def height = imp.getHeight()
    def offsetX = (width / 2) - (bounds.width / 2)
    def offsetY = (height / 2) - (bounds.height / 2)
    roi.setLocation(offsetX as int, offsetY as int)
    imp.setRoi(roi)
    return imp
}

// Process image function
def processImage(imp) {
    def impTemp
    if (useLabelMap) {
        def impPath = imp.originalFileInfo.directory
        def impName = imp.title.tokenize('.')[0]
        def labelMapPath = new File(impPath, "${impName}_prediction.tif")
        impTemp = IJ.openImage(labelMapPath.absolutePath)
        if (!impTemp) {
            logError("Label map not found at ${labelMapPath.absolutePath}")
            return null
        }
    } else {
        impTemp = imp.duplicate()
        impTemp.setC(segmentationChannel)
        if (saturate > 0.0) {
            IJ.run(impTemp, "Enhance Contrast...", "saturated=$saturate process_all")
        }
        if (downscale != 1.0) {
            def width = (impTemp.width / downscale) as int
            def height = (impTemp.height / downscale) as int
            IJ.run(impTemp, "Size...", "width=$width height=$height constrain interpolation=None")
        }
    }
    return impTemp
}

// TrackMate setup function
def setupTrackmate(imp) {
    def model = new Model()
    model.setLogger(Logger.IJ_LOGGER)
    def settings = new Settings(imp)
    
    if (useLabelMap) {
        settings.detectorFactory = new LabelImageDetectorFactory()
        settings.detectorSettings = [
            TARGET_CHANNEL: 1,
            SIMPLIFY_CONTOURS: true
        ]
    } else {
        settings.detectorFactory = new StarDistDetectorFactory()
        settings.detectorSettings = [
            TARGET_CHANNEL: segmentationChannel as Integer
        ]
    }
    
    settings.addSpotFilter(new FeatureFilter('AREA', minNucleusArea as Double, true))
    settings.addSpotFilter(new FeatureFilter('AREA', maxNucleusArea as Double, false))
    
    settings.trackerFactory = new OverlapTrackerFactory()
    settings.trackerSettings = [
        IOU_CALCULATION: "PRECISE",
        MIN_IOU: 0.5 as Double,
        SCALE_FACTOR: 1.0 as Double
    ]
    
    settings.addAllAnalyzers()
    settings.addTrackFilter(new FeatureFilter('NUMBER_SPOTS', minTrackLength, true))
    
    new TrackMate(model, settings)
}

// Process single file
def processFile(file) {
    logInfo("Processing file: ${file.absolutePath}")
    
    def imp = IJ.openImage(file.absolutePath)
    if (!imp) {
        logError("Failed to open image: ${file.absolutePath}")
        return
    }
    
    imp.show()
    
    try {
        def impTemp = processImage(imp)
        if (!impTemp) {
            logError("Failed to process image: ${file.absolutePath}")
            return
        }
        
        def trackmate = setupTrackmate(impTemp)
        
        if (!trackmate.checkInput() || !trackmate.process()) {
            logError("Error in TrackMate: ${trackmate.getErrorMessage()}")
            return
        }
        
        def model = trackmate.getModel()
        
        // Display results
        def selectionModel = new SelectionModel(model)
        def ds = DisplaySettingsIO.readUserDefault()
        def displayer = new HyperStackDisplayer(model, selectionModel, imp, ds)
        displayer.render()
        
        // Export results
        logInfo("Exporting results...")
        
        // Create a subfolder for this file's results
        def fileName = file.name.tokenize('.')[0]
        def fileOutputFolder = new File(outputfolder, fileName)
        fileOutputFolder.mkdirs()
        
        // Save label image
        def labelImp = LabelImgExporter.createLabelImagePlus(trackmate, false, true, false)
        labelImp.show()
        IJ.run(labelImp, "Size...", "width=${imp.width} height=${imp.height} constrain interpolation=None")
        IJ.saveAsTiff(labelImp, new File(fileOutputFolder, "labelmap.tif").absolutePath)
        
        // Process tracks
        def trackIDs = model.getTrackModel().trackIDs(true)
        
        logInfo("Processing ${trackIDs.size()} tracks...")
        trackIDs.each { trackID ->
            def track = model.getTrackModel().trackSpots(trackID)
            def spot = track.iterator().next()
            def spotID = spot.ID()
            
            // Extract track stack
            def ETSA = new ExtractTrackStackActionMP()
            def stackTrack = ETSA.execute(trackmate, selectionModel, ds, null)
            
            // Save track stack
            IJ.saveAsTiff(IJ.getImage(), new File(fileOutputFolder, "${spotID}stack.tif").absolutePath)
            
	        // Process ROIs
	        def rm = RoiManager.getInstance() ?: new RoiManager()
	        rm.reset()
	        
	        new IJRoiExporter(trackmate.getSettings().imp, Logger.IJ_LOGGER).export(track)
	        rm.runCommand("Select All")
	        rm.runCommand("Save", new File(fileOutputFolder, "${spotID}stack.zip").absolutePath)
        
            
            // Clean up and register if needed
            def impStack = IJ.getImage()
            (1..impStack.nFrames).each { t ->
                (1..impStack.nChannels).each { c ->
                    impStack.position(c, 1, t)
                    centerRoi(impStack)
                    IJ.run("Clear Outside", "slice")
                }
            }
            
            IJ.saveAsTiff(impStack, new File(fileOutputFolder, "${spotID}stack_masked.tif").absolutePath)
            
            if (registerNucleus) {
                def channels = (0..<impStack.nChannels).collect { "channel_$it" }.join(' ')
                IJ.run(impStack, "HyperStackReg ", "transformation=[Rigid Body] channel $channels")
                IJ.saveAsTiff(IJ.getImage(), new File(fileOutputFolder, "${spotID}stack_masked_registered.tif").absolutePath)
            }
        }
        
        // Save track data
        def rt = new ResultsTable()
        model.getTrackModel().trackIDs(true).each { id ->
            model.getTrackModel().trackSpots(id).each { spot ->
                rt.incrementCounter()
                rt.addValue("Track ID", id)
                rt.addValue("Spot ID", spot.ID())
                rt.addValue("Frame", spot.getFeature('FRAME'))
                rt.addValue("X", spot.getFeature('POSITION_X'))
                rt.addValue("Y", spot.getFeature('POSITION_Y'))
                rt.addValue("Z", spot.getFeature('POSITION_Z'))
                rt.addValue("Quality", spot.getFeature('QUALITY'))
                rt.addValue("Intensity", spot.getFeature('MEAN_INTENSITY'))
            }
        }
        
        rt.save(new File(fileOutputFolder, "NucleiTracks.csv").absolutePath)
        
        // Save TrackMate XML
        def writer = new TmXmlWriter(new File(fileOutputFolder, "TrackMate.xml"))
        writer.appendModel(model)
        writer.appendSettings(trackmate.getSettings())
        writer.writeToFile()
        
        logInfo("Processing complete for file: ${file.absolutePath}")
    
    } finally {
        cleanup()
    }
}

// Main execution
if (validateInputs()) {
    try {
        input_files.each { file ->
            processFile(file)
        }
        
        logInfo("All files processed. Results saved in ${outputfolder.absolutePath}")
    
    } catch (Exception e) {
        logError("An error occurred: ${e.message}")
        e.printStackTrace()
    } finally {
        cleanup()
    }
} else {
    IJ.error("Invalid inputs")
}
