% ProjectEquirect2FovFile.m
%
% This function projects the gaze vectors from the equirectangular
% representation into the FOV and stores the new data in the output file. The
% change in the new file is indicated throught the relation name, which is set
% to gaze_fov.
%
%
% input:
%   arffFile    - file to process
%   outputFile  - file to store converted data

function Projectequirect2Fov(arffFile, outputFile)
    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);

    [fovData, fovMetadata, fovAttributes, fovRelation] = ProjectEquirect2Fov(data, metadata, attributes, relation);

    SaveArff(outputFile, fovData, fovMetadata, fovAttributes, fovRelation, comments);
end
