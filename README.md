# An ImageJ-based semi-automated cell counting workflow for mouse brain slices
* #### Author: Liang-Yun Wang (r06454009@ntu.edu.tw)
* #### Last update: December 2021
* #### Repository: https://github.com/WLYYYYY/Cell-counting-macros/
* #### To-be-public source: 
  __Investigating the relationship among *Rbfox3* deletion, attention-deficit/hyperactivity disorder, and anxiety.__ <br>
  doi:10.6342/NTU202104435 <br>
  (The thesis will be opened to public in November 2026.)<br><br>

## Original purpose and applicability
This workflow was originally desinged to quantify co-localized fluorescent signals of DAPI (blue) and c-Fos (red) in mouse brain slices. The images used for quantification were obtained through a conventional light microscope under 10x objective magnification. <br>
However, with proper modification, the general concept of this workflow could be applied to analyze immunofluorescent staining of different characteristics, e.g., shape, size, and color of the fluorescence. <br>
* The optimal criteria for *"Analyze Particles..."*, and the best filters/thresholding methods for each monochromatic channel could be determined by preliminary measurements of thresholded images of real samples.
* The channels one wishes to analyze can be change by modifying a few command lines in the third macro, **"3. Split channels and store.ijm"**.
* By changing operators in the *"Image Calculator..."* [1] command in the fourth macro, **"4. Cell counting macro.ijm"**, one could analyze biomarkers of different spatial distributions. 
<br><br>

## Tutorial
The input images should be composite/multi-channel 2-D images, preferably TIFF files. If quantification within certain brain regions is desired, one need to prepare transparent reference atlas (clear outlines without color fillings) before getting started.
1. To correct uneven background, a simple macro **"1. Subtract background and store.ijm"** can perform rolling ball background subtraction to all the images under the same folder. One might need to adjust the rolling ball radius according to the size of their target objects.
2. Align sample images to the reference atlas. This can be helped by the ImageJ plugin BigWarp [2].
3. Isolate brain regions of interest according to the atlas alignment. Crop and clear everyghing else, and leave a background of (0,0,0) RGB color below the brain regions of interest. This can be done with ImageJ or other image processing software such as Photoshop.
4. Macro **"2. Measure surface area.ijm"** can then measure the surface area of cropped brain regions. It is recommended to perform spatial calibration before running this macro, so that the measurments will be presented in actual spatial units rather than pixels.
5. Run macro **"3. Split channels and store.ijm"** to split the multi-channel images of cropped brain regions into individual single-channel images.
6. Macro **"4. Cell counting macro.ijm"** can now process images from different single-channel separately, and then combined and analyze the processed images from different channels, as instructed by the *"Image Calculator..."* and *"Analyze Particle..."* commands.

## Demonstration
Some of the original sample images, as well as the output images/results generated from the above-mentioned macros, are uploaded together in folder "Demo". 

## Referenes/links
[1] https://imagej.nih.gov/ij/docs/guide/146-29.html <br>
[2] https://imagej.net/plugins/bigwarp
