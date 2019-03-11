% DetectSaccade360IVTFile.m
%
% This function uses a simple speed threshold as in I-VT to detect saccades. 
% The result is stored as a attribute in the output file with values of 
% '{unassigned, saccade}'
%
% input:
%   arffFile     - file to label
%   outputfile   - ARFF file to store detected fixations
%   outputAtt    - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion - 1 -> eye FOV, 2 -> eye+head
%   velThreshold - velocity threshold for I-Vt

function DatectSaccades360IVT(arffFile, outputFile, outputAtt, typeOfMotion, velThreshold)
    if (nargin < 5)
        velThreshold = 100;
    end

    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    res = DetectSaccades360IVT(data, metadata, attributes, typeOfMotion, velThreshold);
    [data, attributes] = AddAttArff(data, attributes, res, outputAtt, '{unassigned,saccade}');

    SaveArff(outputFile, data, metadata, attributes, relation, comments);
 end
