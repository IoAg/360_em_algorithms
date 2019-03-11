An implementation of the Larsson smooth pursuit and fixation detector from [1]  for 
**360-degree** data.

This implementation is an extension to the original implementation of the authors in [2] 
which can be found in <https://www.michaeldorr.de/smoothpursuit/larsson_reimplementation.zip>

## 1. GENERAL INFORMATION

Author: Ioannis Agtzidis
Contact: ioannis.agtzidis@tum.de

If you use either this Larsson algorithm re-implementation for 360-degree equirectangular stimuli, please cite:


> \@inproceedings{agtzidis2019conversion, <br/>
>    title={Getting (More) Real: Bringing Eye Movement Classification to HMD Experiments with Equirectangular Stimuli}, <br/>
>    author={Agtzidis, Ioannis and Dorr, Michael}, <br/>
>    booktitle={Proceedings of the 2019 ACM Symposium on Eye Tracking Research \& Applications}, <br/>
>    pages={303--306}, <br/>
>    year={2019}, <br/>
>    organization={ACM} <br/>
> }

## 2. CONTENTS

The main 'interface' functions are located in 
| File | Use |
| --------- | -------- |
| DetectLarsson360.m | runs the Larsson et al. (2015) detection on loaded data and returns a column vector with the detected eye movements |
| DetectLarsson360File.m | runs the Larsson et al (2015) detection for one file |
| DetectLarsson360FileRegex.m | runs the Larsson detection for all files matched by the wildcard-regex (ex. '../GazeCom/gaze_arff/*/*.arff') |
| params_saccades.txt | file containing the parameters that are used for saccade and blink detection |
| params_larsson.txt | file containing the parameters that are used for SP and fixation detection |
| parameters.txt | file provided **only** as a reference, as well as to note the changes in default parameters made to adjust the algorithm for 250Hz data instead of 500Hz (in the original article [1]). |

In order to be able to run the above function use the *pathtool* or *addpath* functions in Matlab to add the above directory (../) in its search path.

Some examples are given below

```
DetectLarsson360File('test.arff', 'test_larsson.arff', 'larsson_fov', 1, 'params_saccades_fov.txt', 'params_larsson.txt')

DetectLarsson360File('test.arff', 'test_larsson.arff', 'larsson_eye_head', 2, 'params_saccades.txt', 'params_larsson.txt')

DetectLarsson360FileRegex('~/dataset/*.arff', '~/dataset_with_em', 'larsson_fov', 1, 'params_saccades_fov.txt', 'params_larsson.txt')
```

## 3. LICENSE

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
license - GPL.


> [1] \@article{larsson2015detection, <br/>
>        title={Detection of fixations and smooth pursuit movements in high-speed eye-tracking data}, <br/>
>        author={Larsson, Linn{\'e}a and Nystr{\"o}m, Marcus and Andersson, Richard and Stridh, Martin}, <br/>
>        journal={Biomedical Signal Processing and Control}, <br/>
>        volume={18}, <br/>
>        pages={145--152}, <br/>
>        year={2015}, <br/>
>        publisher={Elsevier} <br/>
>    } <br/>
> <br/>
> [2] \@inproceedings{agtzidis2016smooth, <br/>
>        title={Smooth pursuit detection based on multiple observers}, <br/>
>        author={Agtzidis, Ioannis and Startsev, Mikhail and Dorr, Michael}, <br/>
>        booktitle={Proceedings of the Ninth Biennial ACM Symposium on Eye Tracking Research \& Applications}, <br/>
>        pages={303--306}, <br/>
>        year={2016}, <br/>
>        organization={ACM} <br/>
>    } <br/>
