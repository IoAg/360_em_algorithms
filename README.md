Here we provide the source code for 5 popular eye movement classification algorithms. These
algorithms have been converted in order to work with **360-degree equirectangular** gaze recordings.

Moreover we provide a function that reprojects the **360-degree equirectangular data** 
around the equator of the sphere (area with the lowest distortions) and then applies
the original algorithms that were developed for monitor based experiments.

## 1. CONTENT

Before starting using the provided algorithms of this repository you should
first clone (or download) the repository that offers utilities that allow as to
handle ARFF files from [here](https://github.com/IoAg/matlab_utils). We also
need to clone the repository that offers utilities for handling 360-degree
utilities from [here](https://github.com/IoAg/matlab_360_utils). Then add the 
previous folders to the search path of Matlab with the *pathtool* or *addpath*
commands.

### 1.1 Converted Algorithms

The algorithms that have word *File* at the end take a file as an input and store the
result as a new attributes at the output file. The algorithms with the same basename 
work on preloaded data. The algorithms that require few parameters, they are provided
directly as input arguments. For the more complex algorithms the parameters are stored 
in a file and are loaded from it. For all the algorithms we provide default parameters 
which were provided by the original authors except for one parameter in the Larsson
et al. (2015) algorithm which is explained in our paper.

Another distinct functionality of the eye movement classification algorithms
that are provided here is their ability to distinguish between eye together
gaze motion (E+H) eye in head gaze motion (field-of-view, FOV). This can be set
in the *typeOfMotion* parameter.

The 360-degree ware implementation of the Larsson et al. (2015) is provided in its own
directory and the algorithm names follow the same convention.

The list of available algorithms is given below

| File | Use |
| --------- | -------- |
| DetectSaccades360.m |  runs the saccade detector from Dorr et al. (2010) on loaded data and returns a logical vector with true where a saccade was detected |
| DetectSaccades360IVT.m |  runs the I-VT saccade detector from Salvucci and Goldberg (2000) on loaded data and returns a logical vector with true where a saccade was detected |
| DetectFixations360.m |  runs the fixation detector from Dorr et al. (2010) on loaded data and returns a logical vector with true where a fixation was detected |
| DetectSaccades360IDT.m |  runs the I-DT saccade detector from Salvucci and Goldberg (2000) on loaded data and returns a logical vector with true where a fixation was detected |
| DetectBlinks360.m |  detects blinks based on noise intervals and the distance of saccade intervals from them and returns a logical vector with true where a blink was detected |
| larsson360/DetectLarsson360.m | runs the Larsson et al (2015)detection on loaded data and returns a column vector with the detected eye movements |
| DetectSaccades360File.m |  runs the saccade detector from Dorr et al. (2010) for one file and stores the result in another one |
| DetectSaccades360IVTFile.m |  runs the I-VT saccade detector from Salvucci and Goldberg (2000) for one file and stores the result in another one |
| DetectFixations360File.m |  runs the fixation detector from Dorr et al. (2010) for one file and stores the result in another one |
| DetectSaccades360IDTFile.m |  runs the I-DT saccade detector from Salvucci and Goldberg (2000) for one file and stores the result in another one |
| DetectBlinks360File.m |  runs the above blink detector for one file and stores the result in another one |
| larsson_360/DetectLarsson360File.m | runs the Larsson et al. (2015) detection for one file and stores the result in another one |
| larsson360/DetectLarsson360FileRegex.m | runs the Larsson detection for all files matched by the wildcard-regex (ex. '../GazeCom/gaze_arff/*/*.arff') |
| params_saccades_equirect.txt | file containing the parameters that are used for saccade and blink detection per Dorr et al. (2010). The speed thresholds where for the eye+head representation |
| params_saccades_fov.txt | file containing the parameters that are used for saccade and blink detection er Dorr et al. (2010). The speed thresholds were optimized for eye within head representation |
| params_fixation.txt | file containing the parameters that are used for fixation detection per Dorr et al. (2010) |
| larsson_360/params_larsson.txt | file containing the parameters that are used for SP and fixation detection per Larsson et al. (2015) |

### 1.2 Data Reprojection

If the conversion of an algorithm is not easy because it is either very complex
or it will be applied to small amount of data, we can reproject the
equirectangular data to areas with low distortions and apply the original
algorithms directly. Here we also offer the possibility of distinguishing
between E+H and FOV gaze motion as in the case of the converted algorithms with
the *DataReprojDetection.m* and *DataReprojFovDetection.m* functions.

The main idea behind reprojection is to provide the eye movement detection
implementation function name as input to the reprojection detection functions
and then call them with converted data as input. The detection functions should
take as input at least the *data, metadata, and attributes* as returned from *LoadArff.m*.
All the extra arguments can provided through the *varargin* input argument. Their output
comprises of a column vector with integer when an eye movement is detected.

A more detailed explanation of the input arguments is given below

| Input arguments | Use |
| --------- | -------- |
| arffFile | ARFF file to process |
| outFile | file name to store result |
| outputAtt | name of the attribute in the output ARFF that holds detected eye movements |
| attValues | nominal values of the added attributes as returned from eye movement detection algorithm. They are a string in the form '{unassigned, fixation}' if the detection algorithm returns 0 for unassigned and 1 for fixations |
| detFuncName | detection function name as string. Ex. 'DetectSaccadesIVVT' |
| varargin | required extra arguments for calling the detection function. The data, metadata, attributes are passed to the detection function by default in this order followed by the varargin arguments |


The list of used files for data reprojection is given below

| File | Use |
| --------- | -------- |
| DataReprojDetection.m | (main function) calls the provided eye movement detection function on E+H (eye and head) motion data |
| DataReprojFovDetection.m | (main function) calls the provided eye movement detection function on FOV (eye within head) motion data |
| ProjectEquirect2Fov.m | projects data to the field-of-view |
| ProjectEquirect2FovFile.m | projects data to the field-of-view and stores it to a file |

## 2. DATA FORMAT

All the function use the ARFF data format for input and output to the disk. The initial
ARFF format was extended as described in Agtzidis et al. (2016) and was further expanded 
for 360-degree gaze data.

Here the "@relation" is set to gaze_360 to distinguish the recordings from
plain gaze recordings. We also make use of the "%@METADATA" special comments
which describe the field of view of the used headset. Apart from the default
metadata *width_px, height_px, distance_mm, width_mm, height_mm* we also use
the extra metadata *fov_width_px, fov_width_deg, fov_height_px, fov_height_deg* 
that describe the headset properties. 

### 2.1. ARFF example

```
@RELATION gaze_360

%@METADATA distance_mm 0.00
%@METADATA height_mm 0.00
%@METADATA height_px 1080
%@METADATA width_mm 0.00
%@METADATA width_px 1920

%@METADATA fov_height_deg 100.00
%@METADATA fov_height_px 1440
%@METADATA fov_width_deg 100.00
%@METADATA fov_width_px 1280

@ATTRIBUTE time INTEGER
@ATTRIBUTE x NUMERIC
@ATTRIBUTE y NUMERIC
@ATTRIBUTE confidence NUMERIC
@ATTRIBUTE x_head NUMERIC
@ATTRIBUTE y_head NUMERIC
@ATTRIBUTE angle_deg_head NUMERIC
@ATTRIBUTE labeller_1 {unassigned,fixation,saccade,SP,noise,VOR,OKN}


@DATA
0,960.00,540.00,1.00,960.00,540.00,1.22,fixation
5000,959.00,539.00,1.00,959.00,539.00,1.23,fixation
13000,959.00,539.00,1.00,959.00,539.00,1.23,fixation
18000,959.00,539.00,1.00,959.00,539.00,1.23,fixation
29000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
34000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
45000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
49000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
61000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
66000,959.00,539.00,1.00,959.00,539.00,1.24,fixation
77000,959.00,539.00,1.00,959.00,540.00,1.24,fixation
82000,959.00,539.00,1.00,959.00,540.00,1.24,fixation
94000,959.00,539.00,1.00,960.00,540.00,1.24,fixation
99000,959.00,539.00,1.00,960.00,540.00,1.24,fixation
110000,959.00,539.00,1.00,960.00,540.00,1.25,fixation
114000,959.00,539.00,1.00,960.00,540.00,1.25,fixation
125000,958.00,538.00,1.00,960.00,540.00,1.26,saccade
129000,956.00,537.00,1.00,960.00,540.00,1.27,saccade
141000,948.00,530.00,1.00,960.00,540.00,1.28,saccade
```

## 3. GENERAL INFORMATION

Author: Ioannis Agtzidis
Contact: ioannis.agtzidis@tum.de

If you use any algorithm re-implementation for 360-degree equirectangular stimuli, please cite:


> \@inproceedings{agtzidis2019conversion, <br/>
>    title={Getting (More) Real: Bringing Eye Movement Classification to HMD Experiments with Equirectangular Stimuli}, <br/>
>    author={Agtzidis, Ioannis and Dorr, Michael}, <br/>
>    booktitle={Proceedings of the 2019 ACM Symposium on Eye Tracking Research \& Applications}, <br/>
>    pages={303--306}, <br/>
>    year={2019}, <br/>
>    organization={ACM} <br/>
> }

## 4. REFERENCES

> Ioannis Agtzidis, Mikhail Startsev, and Michael Dorr. 2016. In the pursuit of (ground)
> truth: A hand-labelling tool for eye movements recorded during dynamic scene
> viewing. In 2016 IEEE Second Workshop on Eye Tracking and Visualization (ETVIS).
> 65–68. https://doi.org/10.1109/ETVIS.2016.7851169
> 
> Michael Dorr, Thomas Martinetz, Karl R Gegenfurtner, and Erhardt Barth. 2010.
> Variability of eye movements when viewing dynamic natural scenes. Journal of
> Vision 10, 10 (2010), 28–28
> 
> Linnéa Larsson, Marcus Nyström, Richard Andersson, and Martin Stridh. 2015.
> Detection of fixations and smooth pursuit movements in high-speed eye-tracking
> data.  Biomedical signal processing and control 18 (2015), 145–152.
> <http://dx.doi.org/10.  1016/j.bspc.2014.12.008> 
