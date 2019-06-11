% function DetectSaccades360File:
%
% This function detects saccades from the input file and store them in the provided
% attribute of the output file. The values of the attribute in the output 
% file are '{unassigned, saccade}'
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

function DetectSaccades360File(inputfile, outputFile, outputAtt, typeOfMotion, paramfile)
    % load gaze coordinates from arff file
    [data, metadata, attributes, relation, comments] = LoadArff(inputfile);
    
    if (nargin < 5)
        params.tolerance = 0.1;
        params.thresholdOnsetFast = 137.5;
        params.thresholdOnsetSlow = 17.1875;
        params.thresholdOffset = 17.1875;
        params.maxSpeed = 1031.25;
        params.minDuration = 15000;
        params.maxDuration = 160000;
        params.velIntegrationInterv = 4000;
        params.minConfidence = 0.25;
    else
        params = LoadParams(paramfile);
    end

    res = DetectSaccades360(data, metadata, attributes, typeOfMotion, params);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, '{unassigned,saccade}');

    SaveArff(outputFile, data, metadata, attributes, relation, comments);
end
