#@ ImagePlus (label="Select 4D stack") imp
#@ File (label="Output directory", style="directory") output_dir
#@ String (label="File format", choices={"TIFF", "PNG"}, style="radioButtonVertical") format
#@ Integer (label="Number of frames to extract (0 = all)", min=0) n_frames
#@ Boolean (label="Random frame selection") random_selection

from ij import IJ, ImagePlus, ImageStack
import os
from java.util import Random
import sys

def get_frames_to_export(total_frames, n_frames, random_selection):
    """Determine which frames to export based on user input."""
    # If n_frames is 0 or greater than total_frames, export all frames
    if n_frames == 0 or n_frames > total_frames:
        if n_frames > total_frames:
            print("Warning: Requested {} frames but only {} frames available".format(n_frames, total_frames))
            print("Exporting all frames instead")
        return range(1, total_frames + 1)
    
    if random_selection:
        # Create a list of random unique frames
        random = Random()
        frames = set()
        while len(frames) < n_frames:
            frames.add(random.nextInt(total_frames) + 1)
        return sorted(list(frames))
    else:
        # Return sequential frames
        return range(1, n_frames + 1)

def export_timepoints(imp, output_dir, format, n_frames, random_selection):
    """Export individual z-stacks from a 4D dataset."""
    
    # Get dimensions
    stack = imp.getStack()
    width = imp.getWidth()
    height = imp.getHeight()
    channels = imp.getNChannels()
    slices = imp.getNSlices()
    frames = imp.getNFrames()
    
    # Get original filename without extension
    original_filename = os.path.splitext(imp.getTitle())[0]
    
    # Create output directory if it doesn't exist
    output_path = output_dir.absolutePath
    if not os.path.exists(output_path):
        os.makedirs(output_path)
    
    # Get frames to export
    frames_to_export = get_frames_to_export(frames, n_frames, random_selection)
    
    # Create log file
    log_path = os.path.join(output_path, "export_log.txt")
    with open(log_path, "w") as log:
        log.write("Original file: {}\n".format(imp.getTitle()))
        log.write("Total frames in stack: {}\n".format(frames))
        log.write("Number of frames exported: {}\n".format(len(frames_to_export)))
        log.write("\nExported frames mapping:\n")
        
        # Loop through selected timepoints
        for t in frames_to_export:
            # Create a new stack for this timepoint
            new_stack = ImageStack(width, height)
            
            # Add all z-slices for this timepoint
            for z in range(1, slices + 1):
                # Calculate position in the original stack
                position = imp.getStackIndex(1, z, t)  # Assuming single channel
                slice = stack.getProcessor(position)
                new_stack.addSlice(slice)
            
            # Create filename with original frame number
            timepoint_string = "_orig_t{:03d}".format(t)  # Uses original frame number
            new_name = original_filename + timepoint_string
            new_imp = ImagePlus(new_name, new_stack)
            
            # Set z-dimension properties
            new_imp.setDimensions(1, slices, 1)
            if slices > 1:
                new_imp.setOpenAsHyperStack(True)
            
            # Save the stack with the original filename plus timepoint
            file_path = os.path.join(output_path, new_name)
            if format == "TIFF":
                IJ.saveAsTiff(new_imp, file_path + ".tif")
            else:
                IJ.saveAs(new_imp, "PNG", file_path + ".png")
            
            # Log the mapping
            log.write("{}.{}: Frame {} from original stack\n".format(
                new_name, format.lower(), t))
            
            # Close the temporary ImagePlus
            new_imp.close()

# Run the export function
export_timepoints(imp, output_dir, format, n_frames, random_selection)
IJ.showMessage("Export Complete", "All selected timepoints have been exported!")