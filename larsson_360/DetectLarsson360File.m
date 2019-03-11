% DetectLarsson360File.m
%
% This function detect fixations, saccades, smooth pursuit and blinks and
% stores them to the output file. Saccades and blinks are detected with the
% DetectSaccades360 and DetectBlinks360 functions.  The fixations and smooth
% pursuit are detected per the Larsson et al. 2015 paper "Detection of
% fixations and smooth pursuit movements in high-speed eye-tracking data"
%
% input:
%   inputfile       - ARFF file containing gaze coordinates
%   outputfile      - ARFF file to store detected fixations
%   outputAtt       - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion    - 1 -> eye FOV, 2 -> eye+head
%   paramSaccFile   - file contining parameters to use for saccade detection.
%                     See function DetectSaccades360File for details
%   paramLarssonFile- file containing parameters for fixation and saccade detection
%
% paramLarssonFile format:
% paramLarsson is a data structure with the following fields. For an
% explanation of each field refer to the original paper. The file is
% indipendent of parameter ordering and letter case. Each parameter is followed
% by an equal sign and then the value. The available values are givenbelow
%
% preprocessVelThres=100.0
% t_window=44000 
% t_overlap=12000
% eta_p=0.01
% t_min=32000
% eta_d=0.45
% eta_cd=0.5
% eta_pd=0.2
% eta_maxFix=1.9
% eta_minSmp=1.1
% phi=45
% minConfidence=0.75

function DetectLarsson360File(inputfile, outputfile, outputAtt, typeOfMotion, paramSaccFile, paramLarssonFile)
    c_fix = 1;
    c_sacc = 2;
    c_sp = 3;
    c_noise = 4;
	attType = '{unassigned,fixation,saccade,sp,noise}';

    [data, metadata, attributes, relation, comments] = LoadArff(inputfile);

    paramSacc = LoadParams(paramSaccFile);
    paramLarsson = LoadParams(paramLarssonFile);

    res = DetectLarsson360(data, metadata, attributes, typeOfMotion, paramSacc, paramLarsson);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, attType);

    SaveArff(outputfile, data, metadata, attributes, relation, comments);
end
