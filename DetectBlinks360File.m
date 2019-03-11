% function DetectBlinks360File:
%
% This function detects blinks from the input file and stores them in the
% provided attribute of the output file. The values of the attribute in the
% output file are '{unassigned, blink}'
%
%
% input:
%   inputfile   - ARFF file containing gaze coordinates
%   outputfile  - ARFF file to store detected fixations
%   outputAtt   - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion- 1 -> eye FOV, 2 -> eye+head
%   paramfile   - (optional) txt file containing parameters for saccade detection (explanation below)
%
% paramfile format:
% The file is indipendent of parameter ordering and letter case. Each parameter is followed by 
% an equal sign and then the value. The available values are below
%   tolerance=
%   thresholdOnsetFast=
%   thresholdOnsetSlow=
%   thresholdOffset=
%   maxSpeed=
%   minDuration=
%   maxDuration=
%   velIntegrationInterv=
%   minConfidence=

function DetectBlinks360File(inputfile, outputFile, outputAtt, typeOfMotion, paramfile)
    % load gaze coordinates from arff file
    [data, metadata, attributes, relation, comments] = LoadArff(inputfile);
    
    if (nargin < 5)
        params.tolerance = 0.1;
        params.thresholdonsetfast = 137.5;
        params.thresholdonsetslow = 17.1875;
        params.thresholdoffset = 17.1875;
        params.maxspeed = 1031.25;
        params.minduration = 15000;
        params.maxduration = 160000;
        params.velintegrationinterv = 4000;
        params.minconfidence = 0.25;
    else
        params = LoadParams(paramfile);
    end

    res = DetectBlinks360(data, metadata, attributes, typeOfMotion, params);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, '{unassigned,blink}');

    SaveArff(outputFile, data, metadata, attributes, relation, comments);
end
