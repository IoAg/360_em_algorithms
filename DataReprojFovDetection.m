% DataReprojFovDetection.m
%
% This function detects eye movement by reprojectinig the 360-degree
% equirectangular data in the field-of-view (FOV) coordinates of the headset.
% By doing this we disentagle the head from the eye motion. On the converted data
% we can then call another eye movement detection function. The input data should
% have the relation "gaze_360" to mark they were recorded in 360-degree
% equirectangular.
%
% The eye movement detection function is provided as string in the input
% arguments. This function should have at least 3 input variables, namely
% data, metadata, and attributes as loaded from the LoadArff function. If the
% provided detection function requires more input than the 3 default arguments,
% these can be provided as extra arguments in the argument list of the
% current function. The extra arguments are placed in the provided order after
% the 3 default arguments in the detection function. The output of the
% detection function should be a vector with a unique integer value for each
% detected eye movement. These should correspond to the provided attValues
% input argument as in the case of an enumeration.
%
% input:
%   arffFile    - file to process
%   outFile     - file to store results
%   outputAtt   - name of the attribute in the output ARFF
%   attValues   - nominal values of the added attributes. They are a string in the 
%                 form '{unassigned, fixation, sacacde, sp, noise}'
%   detFuncName - detection function name
%   varargin    - required extra arguments for calling the detection function.
%                 The data, metadata, attributes are used by default in this
%                 order followed by the varargin arguments

function DataReprojFovDetection(arffFile, outFile, outputAtt, attValues, detFuncName, varargin)
    DetectionFunction = str2func(detFuncName);
    
    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    [fovData, fovMetadata, fovAttributes, fovRelation] = ProjectEquirect2Fov(data, metadata, attributes, relation);

    if (isempty(varargin))
        labelledAtt = DetectionFunction(fovData, fovMetadata, fovAttributes);
    else
        labelledAtt = DetectionFunction(fovData, fovMetadata, fovAttributes, varargin{:});
    end

    [newData, newAttributes] = AddAttArff(data, attributes, labelledAtt, outputAtt, attValues);
    SaveArff(outFile, newData, metadata, newAttributes, relation, comments);
end
