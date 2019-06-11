% ProjectEquirect2Fov.m
%
% This function projects the gaze from the equirectangular representation into
% the FOV and returns the new data. The change is indicated throught the
% relation name, which is set to gaze_fov.
%
% input:
%   data        - data from the ARFF file
%   metadata    - metadata from the ARFF file
%   attributes  - attributes from the ARFF file
%   relation    - relation from the ARFF file
%
% output:
%   fovData        - converted data to fov
%   fovMetadata    - new metadata describing the experiment
%   fovAttributes  - new attributes describing the data
%   fovRelation    - new relation set to gaze_fov

function [fovData, fovMetadata, fovAttributes, fovRelation] = ProjectEquirect2Fov(data, metadata, attributes, relation)
    assert(strcmp(relation, 'gaze_360'), 'Data do not come from equirectangular experiment');

    % Proccess the FOV vectors
    [eyeFovVec] = GetCartVectors(data, metadata, attributes); % rotation at (-1,0,0) point

    widthFovDeg = str2num(GetMetaExtraValueArff(metadata, 'fov_width_deg'));
    widthFovRads = widthFovDeg * pi / 180;
    heightFovDeg = str2num(GetMetaExtraValueArff(metadata, 'fov_height_deg'));
    heightFovRads = heightFovDeg * pi / 180;

    widthFovPx = str2num(GetMetaExtraValueArff(metadata, 'fov_width_px'));
    heightFovPx = str2num(GetMetaExtraValueArff(metadata, 'fov_height_px'));

    xFov = zeros(size(data,1),1);
    yFov = zeros(size(data,1),1);
    for i=1:size(data,1)
        [horRads, verRads] = CartToSpherical(eyeFovVec(i,:));
        if (horRads < 0)
            horRads = 2*pi + horRads;
        end

        horRads = horRads - pi; % reference vector at (-1,0,0)
        verRads = verRads - pi/2;

        xFov(i) = widthFovPx * (horRads + widthFovRads / 2) / widthFovRads;
        yFov(i) = heightFovPx * (verRads + heightFovRads / 2) / heightFovRads;
    end
    
   
    fovMetadata.width_px = widthFovPx;
    fovMetadata.height_px = heightFovPx;
    fovMetadata.distance_mm = 80;
    ppdx = fovMetadata.width_px / widthFovDeg;
    fovMetadata.width_mm = ppd2distance(ppdx, fovMetadata.width_px, fovMetadata.distance_mm);
    ppdy = fovMetadata.height_px / heightFovDeg;
    fovMetadata.height_mm = ppd2distance(ppdy, fovMetadata.height_px, fovMetadata.distance_mm);
    fovMetadata.extra = {};

    fovAttributes = {};
    fovData = zeros(size(data,1),0);
    timeInd = GetAttPositionArff(attributes, 'time');
    [fovData, fovAttributes] = AddAttArff(fovData, fovAttributes, data(:,timeInd), attributes{timeInd,1}, attributes{timeInd,2});
    [fovData, fovAttributes] = AddAttArff(fovData, fovAttributes, xFov, 'x', 'Numeric');
    [fovData, fovAttributes] = AddAttArff(fovData, fovAttributes, yFov, 'y', 'Numeric');
    confInd = GetAttPositionArff(attributes, 'confidence');
    [fovData, fovAttributes] = AddAttArff(fovData, fovAttributes, data(:,confInd), attributes{confInd,1}, attributes{confInd,2});

    fovRelation = 'gaze_fov';
end
