Microarray analysis toolbox
---------------------------

Welcome to the Microarray analysis toolbox!

This toolbox contains code to align images of protein antibody arrays with 
a corresponding template. The code currently works primarily with arrays 
from R&D Systems.

The toolbox will allow you to:
- Crop individual membrane images from a large image (if necessary)
- Align the image to a template
- Measure the intensity of each spot
- Normalize the intensities* from individual images

*The images are normalized to the top left-most positive control.

This code was developed in collaboration with the Lynch lab.

## Usage

1. Run the ``cropMembraneImages`` function to assist with cropping single 
   membranes from a larger image. 

   ```matlab
   cropMembraneImages
   ```

2. Once you have individual images of membranes, run the function 
   ``measureArray`` to perform the measurements.

   ```matlab
      measureArray(TEMPLATE, IMGDIR, OUTPUTDIR)
   ```

   TEMPLATE - Filepath to template data
   IMGDIR - a cell array with paths to directories containing cropped images
   OUTPUTDIR - full file to save data

## Help

Additional help is provided in each function. You may also contact the 
ALMC at biof-imaging@colorado.edu.

## Author

This code was developed by [Dr. Jian Wei Tay](mailto:jian.tay@colorado.edu).

