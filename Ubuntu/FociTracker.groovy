#@ImagePlus (label="Input image") imp
#@Integer (label="Foci channel", value=2) fociChannel
#@Double (label="Foci spot diameter (μm)", value=0.5) spotDiameter
#@Double (label="Foci quality threshold", value=50.0) spotQuality
#@Double (label="Foci linking max distance (μm)", value=1.0) maxDistance
#@Boolean (label="Allow foci gap closing", value=true) allowGap
#@Integer (label="Maximum foci gap (frames)", value=1) maxGap
#@File (label="Output CSV file", style="save") outputFile

import ij.IJ
import ij.measure.ResultsTable
import fiji.plugin.trackmate.Model
import fiji.plugin.trackmate.Settings
import fiji.plugin.trackmate.TrackMate
import fiji.plugin.trackmate.detection.DogDetectorFactory
import fiji.plugin.trackmate.tracking.jaqaman.SparseLAPTrackerFactory
import fiji.plugin.trackmate.Logger

class FociTracker {
    // Class to handle foci data collection
    static class FociDataCollector {
        private File outputFile
        private List buffer
        private int bufferSize
        private BufferedWriter writer
        
        FociDataCollector(String outputPath) {
            outputFile = new File(outputPath)
            buffer = []
            bufferSize = 1000
            initializeFile()
        }
        
        private void initializeFile() {
            writer = outputFile.newWriter(false)
            writer.writeLine("Movie,Frame,Nucleus_Track_ID,Nucleus_ID,Focus_Track_ID,Focus_ID," +
                            "Focus_X,Focus_Y,Focus_Intensity,Focus_Area,Focus_Quality,Original_Frame")
            writer.flush()
        }
        
        void addFocus(Map data) {
            buffer << data
            if (buffer.size() >= bufferSize) {
                writeBuffer()
            }
        }
        
        private void writeBuffer() {
            if (!buffer.isEmpty()) {
                buffer.each { data ->
                    writer.writeLine("${data.movie},${data.frame},${data.nucleus_track_id}," +
                                   "${data.nucleus_id},${data.focus_track_id},${data.focus_id}," +
                                   "${data.x},${data.y},${data.intensity},${data.area}," +
                                   "${data.quality},${data.original_frame}")
                }
                writer.flush()
                buffer.clear()
            }
        }
        
        void finalize() {
            writeBuffer()
            writer.close()
        }
    }

    // Setup foci detector
    static def setupFociDetector(settings, channel, diameter, quality) {
        settings.detectorFactory = new DogDetectorFactory()
        settings.detectorSettings = [
            DO_SUBPIXEL_LOCALIZATION: true,
            RADIUS: diameter/2,
            TARGET_CHANNEL: channel,
            THRESHOLD: quality,
            DO_MEDIAN_FILTERING: false
        ]
        return settings
    }

    // Setup foci tracker
    static def setupFociTracker(settings, maxDistance, allowGap, maxGap) {
        settings.trackerFactory = new SparseLAPTrackerFactory()
        settings.trackerSettings = settings.trackerFactory.getDefaultSettings()
        settings.trackerSettings['LINKING_MAX_DISTANCE'] = maxDistance
        settings.trackerSettings['ALLOW_GAP_CLOSING'] = allowGap
        settings.trackerSettings['MAX_FRAME_GAP'] = maxGap
        settings.trackerSettings['GAP_CLOSING_MAX_DISTANCE'] = maxDistance
        settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = false
        settings.trackerSettings['ALLOW_TRACK_MERGING'] = false
        return settings
    }

    // Main foci analysis function
    static def analyzeFociInNucleus(impStack, startFrame, nucleusTrackId, nucleusId, 
                            fociChannel, spotDiameter, spotQuality, maxDistance, allowGap, maxGap,
                            fociCollector, movieTitle) {
        // Setup TrackMate for foci detection
        def model = new Model()
        model.setLogger(Logger.IJ_LOGGER)
        def settings = new Settings(impStack)
        
        // Configure foci detection and tracking
        settings = setupFociDetector(settings, fociChannel, spotDiameter, spotQuality)
        settings = setupFociTracker(settings, maxDistance, allowGap, maxGap)
        settings.addAllAnalyzers()
        
        // Run TrackMate
        def trackmate = new TrackMate(model, settings)
        if (!trackmate.checkInput() || !trackmate.process()) {
            IJ.log("Error in foci TrackMate: ${trackmate.getErrorMessage()}")
            return [:]
        }
        
        // Map to store foci counts per frame
        def fociCountsPerFrame = [:]
        def frameOffset = startFrame
        
        // Initialize counts for all frames
        def nFrames = impStack.getNFrames()
        for (int i = 0; i < nFrames; i++) {
            fociCountsPerFrame[frameOffset + i] = 0
        }
        
        // Process foci and count per frame
        model.getTrackModel().trackIDs(true).each { trackId ->
            def track = model.getTrackModel().trackSpots(trackId)
            
            track.each { focus ->
                def stackFrame = focus.getFeature('FRAME') as int
                def originalFrame = frameOffset + stackFrame
                
                fociCountsPerFrame[originalFrame] = fociCountsPerFrame[originalFrame] + 1
                
                if (fociCollector != null) {
                    fociCollector.addFocus([
                        movie: movieTitle,
                        frame: originalFrame,
                        nucleus_track_id: nucleusTrackId,
                        nucleus_id: nucleusId,
                        focus_track_id: trackId,
                        focus_id: focus.ID(),
                        x: focus.getFeature('POSITION_X'),
                        y: focus.getFeature('POSITION_Y'),
                        intensity: focus.getFeature('MEAN_INTENSITY'),
                        area: focus.getFeature('AREA'),
                        quality: focus.getFeature('QUALITY'),
                        original_frame: originalFrame
                    ])
                }
            }
        }
        
        return fociCountsPerFrame
    }
}

// Main execution when run as standalone script
if (!this.getClass().getName().contains("FociTracker")) {
    def collector = new FociTracker.FociDataCollector(outputFile.absolutePath)
    def fociCounts = FociTracker.analyzeFociInNucleus(
        imp, 0, -1, -1,  // Default values when running standalone
        fociChannel, spotDiameter, spotQuality, 
        maxDistance, allowGap, maxGap,
        collector, imp.getTitle()
    )
    
    // Create results table with counts
    def rt = new ResultsTable()
    fociCounts.each { frame, count ->
        rt.incrementCounter()
        rt.addValue("Frame", frame)
        rt.addValue("Foci Count", count)
    }
    rt.show("Foci Counts")
    
    collector.finalize()
}