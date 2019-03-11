% DetectFixations360IDTFile.m
%
% This function detects fixations based on the I-DT algorithm. 
% The result is stored as a new attribute in the output file with values of 
% '{unassigned, fixation}'
%
% input:
%   arffFile        - file to label
%   outputfile      - ARFF file to store detected fixations
%   outputAtt       - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion    - 1 -> eye FOV, 2 -> eye+head
%   dispThres       - dispersion threshold in degrees
%   windowDur       - window duration in us

function DetectFixations360IDTFile(arffFile, outputFile, outputAtt, typeOfMotion, dispThres, windowDur)
    if (nargin < 6)
        windowDur = 100000;
    end
    if (nargin < 5)
        dispThres = 1.5;
    end

	[data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    res = DetectFixations360IDT(data, metadata, attributes, typeOfMotion, dispThres, windowDur);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, '{unassigned,fixation}');

    SaveArff(outputFile, data, metadata, attributes, relation, comments);
end
