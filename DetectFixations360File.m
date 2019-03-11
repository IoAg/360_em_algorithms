% DetectFixations360File.m
%
% This function detects fixations in input ARFF file. 
% The result is stored as a new attribute in the output file with values of
% '{unassigned, fixation}'
%
% NOTE: It requires that the ARFF file has saccades already detected.
%
% input:
%   inputfile   - ARFF file containing gaze coordinates
%   outputfile  - ARFF file to store detected fixations
%   outputAtt   - attribute that holds detected fixations in the output ARFF file 
%   saccAtt     - saccade attribute name
%   saccValue   - integer value representing saccades
%	typeOfMotion- 1 -> eye FOV, 2 -> eye+head, 3 -> head
%   paramfile   - (optional) txt file containing parameters for saccade detection (explanation below)
%
% paramfile format:
% The file is indipendent of parameter ordering and letter case. Each parameter is followed by 
% an equal sign and then the value. The available values are below
%	minfixationdurus=
%	maxdistancedeg=
%	velthresholddegsec=
%	intersaccadicdist=
%	intersaccadiclength=
%   minConfidence=

function DetectFixations360File(inputfile, outputFile, outputAtt, saccAtt, saccValue, typeOfMotion, paramfile)
	% load gaze coordinates from ARFF file
    [data, metadata, attributes, relation, comments] = LoadArff(inputfile);

    if (nargin < 7)
        params.minFixationDur = 100000;
        params.maxDistanceDeg = 0.35;
        params.velThresholdDegSec = 5;
        params.intersaccadicDist = 10.0;
        params.intersaccadicLength = 500000;
        params.minConfidence = 0.25;
    else
        params = LoadParams(paramfile);
    end

    res = DetectFixations360(data, metadata, attributes, saccAtt, saccValue, typeOfMotion, params);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, '{unassigned,fixation}');

    SaveArff(outputFile, data, metadata, attributes, relation, comments);
end
