# An ImageJ-based semi-automated cell counting workflow for mouse brain slices
* __Author__: Liang-Yun Wang (r06454009@ntu.edu.tw)
* __Last update__: December 2021
* __ImageJ version__: 2.3.0/1.53f
* __Repository__: https://github.com/WLYYYYY/Cell-counting-macros/
* __To-be-public source__:  Investigating the relationship among *Rbfox3* deletion, attention-deficit/hyperactivity disorder, and anxiety. doi:10.6342/NTU202104435.
  (The thesis will be opened to public in November 2026.)<br><br>

## Original purpose and applicability
This workflow was originally designed to quantify co-localized DAPI (blue) and c-Fos (red) fluorescent signals in mouse brain slices. The images used for quantification were obtained through a conventional light microscope under 10x objective magnification.  For demonstration, some of the original sample images were uploaded to the folder "Demo sample". <br>
The macros have been updated ever since. 
Quantification of biomarkers with various features (e.g., color, size, heterogenity of signal intensity, spatial distribution) are now possible. <br>
Still, this workflow has several limitations including but not limited to:
1. Only 2-D images are accepted.
2. The cell counting macro "[4. Cell counting macro.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/4.%20Cell%20counting%20macro.ijm "4. Cell counting macro.ijm")" can only handled signals from up to two channels within one run. 
3.  The ideal objects for quantification should be scattered and round in shape. Crowded objects or objects of irregular shapes might be difficult to quantify using this workflow. 
<br><br>

## Tutorial
The input images should be composite/multi-channel 2-D images, preferably TIFF files. If quantification within certain brain regions is desired, one need to prepare transparent reference atlas (clear outlines without color fillings) before getting started.
1. To correct uneven background, a simple macro "[1. Subtract background and store.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/1.%20Subtract%20background%20and%20store.ijm "1. Subtract background and store.ijm")" can perform rolling ball background subtraction [[1](https://imagej.net/plugins/rolling-ball-background-subtraction)] to all the images under the same folder. One might need to adjust the rolling ball radius according to the size of their target objects.
![Subtract background and store](/../main/Images/1.%20Subtract%20background%20and%20store.png)
2. Align sample images to the reference atlas. This can be helped by the ImageJ plugin BigWarp [[2](https://imagej.net/plugins/bigwarp)].
![Bigwarp demo](/../main/Images/2.%20BigWarp.png)
3. Isolate brain regions of interest according to the atlas alignment. Crop and clear everything else, and leave a black background (0 pixel intensity for all color channels) below the brain regions of interest. This can be done with ImageJ or other image processing software such as Photoshop.
![Cropping with ImageJ demo](/../main/Images/3.%20Cropping%20and%20clear%20outside.png)
4. Macro "[2. Measure surface area.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/2.%20Measure%20surface%20area.ijm "2. Measure surface area.ijm")" can then measure the surface area of cropped brain regions. It is recommended to perform spatial calibration before running this macro, so that the measurements will be presented in actual spatial units rather than pixels.
5. Run macro "[3. Split channels and store.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/3.%20Split%20channels%20and%20store.ijm "3. Split channels and store.ijm")" to split the multi-channel images of cropped brain regions into individual single-channel images.
6. Macro "[4. Cell counting macro.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/4.%20Cell%20counting%20macro.ijm "4. Cell counting macro.ijm")" can now process images from different single-channel separately, and then combined and analyze the processed images from different channels, as instructed by the *"Image Calculator..."* and *"Analyze Particle..."* commands.
![Macros 2+3+4](/../main/Images/4.%20Macros%202%203%204.png)
<br><br>
## Update description
* [3. Split channels and store.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/3.%20Split%20channels%20and%20store.ijm "3. Split channels and store.ijm")
	* This macro can be applied to composite images consist of any color channel splittable in ImageJ.
	* A customized suffix identifier can be added to the filename for every selected single-channel. The suffix id unique for each channel can be used to search matching images in different channel.
* [4. Cell counting macro.ijm](https://github.com/WLYYYYY/Cell-counting-macros/blob/main/IJM%20Macros/4.%20Cell%20counting%20macro.ijm "4. Cell counting macro.ijm")
	* This macro can analyze monochromatic images from 1-2 single channel(s).
	* Unique filters and thresholding methods can be applied to images of each single-channel. 
		* List of available filters in this macro (one can choose 0-2 filter(s) for each channel): 
			* (None)
			* Gaussian Blur
			* Median
			* Mean
			* Minimum
			* Maximum
			* Variance
			* Top Hat
			* Unsharp Mask
		* List of available thresholding methods:
			* Global thresholding:
				* Default
				* Huang
				* Huang2
				* Intermodes
				* IsoData
				* Li
				* MaxEntropy
				* Mean
				* MinError(I)
				* Minimum
				* Moments
				* Otsu
				* Percentile
				* RenyiEntropy
				* Shanbhag
				* Triangle
				* Yen
			* Guirado [[3](https://www.sciencedirect.com/science/article/pii/S2405844018310508)]: threshold top (1-N)% brightest pixels, where N is the value one need to decide when this method is selected.
			* Local thresholding:
				* Bernsen
				* Contrast
				* Mean 
				* Median
				* MidGrey
				* Niblack
				* Otsu
				* Phansalkar
				* Sauvola
<br><br>
## Demonstration
Some of the original sample images, as well as the output images/results generated from the above-mentioned macros, are uploaded together in folder "[Demo sample](https://github.com/WLYYYYY/Cell-counting-macros/tree/main/Demo%20sample "Demo sample")". 
<br><br>
## Referenes/links
1. https://imagej.net/plugins/rolling-ball-background-subtraction
2. https://imagej.net/plugins/bigwarp
3. [Guirado, R., et al., _Automated analysis of images for molecular quantification in immunohistochemistry._ Heliyon, 2018. **4**(6).](https://www.sciencedirect.com/science/article/pii/S2405844018310508)
