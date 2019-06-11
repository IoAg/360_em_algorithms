% DataReprojDetection.m
%
% This function detects eye movements by reprojectinig the 360-degree
% equirectangular data and calling an external eye movement detection function.
% It woks by splitting the equirectangular input data into intervals where the
% vertical spread is no more than 45 degrees. It then reprojects them around
% the equatorial line of the sphere and creates coordinates that are equivalent
% to a monitor recorded experiment. Finally we can call the provided monitor
% designed algorithm with the new ARFF object as input. The input data should
% have the relation "gaze_360" to mark they were recorded in 360-degree
% equirectangular experiment.
%
% The eye movement detection function is provided as string in the input
% arguments. This function should have at least 3 input variables, namely
% data, metadata, and attributes as loaded from the LoadArff function. If the
% provided detection function requires more input than the 3 default arguments,
% these can be provided as extra arguments in the argument list of the current
% function. The extra arguments are placed in the order that they appear after
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

function DataReprojDetection(arffFile, outFile, outputAtt, attValues, detFuncName, varargin)
    DetectionFunction = str2func(detFuncName);
    c_maxVertDiff = 45 * pi / 180;
    [data, metadata, attributes, relation, comments] = LoadArff(arffFile);
    xInd = GetAttPositionArff(attributes, 'x');
    yInd = GetAttPositionArff(attributes, 'y');

    assert(strcmp(relation, 'gaze_360'), 'Input data should be from 360-degree recordings');

    % create metadata representing a monitor experiment
    metaMonitor = metadata;
    % ppd for 360 experiment
    ppdx = metadata.width_px / 360;
    ppdy = metadata.height_px / 180;
    metaMonitor.distance_mm = 800; % this stays fixed
    metaMonitor.width_mm = ppd2distance(ppdx, metaMonitor.width_px, metaMonitor.distance_mm);
    metaMonitor.height_mm = ppd2distance(ppdy, metaMonitor.height_px, metaMonitor.distance_mm);

    iniData = data;
    RemoveChanges();

    [~, eyeHeadVec] = GetCartVectors(data, metadata, attributes);

    labelledAtt = zeros(size(data,1),1);

    ints = GetIntervals(eyeHeadVec);
    for ind=1:size(ints,1)
        intData = data(ints(ind,1):ints(ind,2),:);
        coords = Project3dVectors(eyeHeadVec(ints(ind,1):ints(ind,2),:), metadata);
        % change x,y to the projected data
        intData(:,xInd) = coords(:,1);
        intData(:,yInd) = coords(:,2);

        if (isempty(varargin))
            labelledAtt(ints(ind,1):ints(ind,2)) = DetectionFunction(intData, metaMonitor, attributes);
        else
            labelledAtt(ints(ind,1):ints(ind,2)) = DetectionFunction(intData, metaMonitor, attributes, varargin{:});
        end
    end

    [newData, newAttributes] = AddAttArff(iniData, attributes, labelledAtt, outputAtt, attValues);
    SaveArff(outFile, newData, metadata, newAttributes, relation, comments);

    function RemoveChanges()
        confInd = GetAttPositionArff(attributes, 'confidence');
        c_minConf = 0.75;
        for i=2:size(data,1)
            if (data(i,confInd) < c_minConf)
                data(i, xInd) = data(i-1, xInd);
                data(i, yInd) = data(i-1, yInd);
            end
        end
    end


    % This function returns intervals, which have all the samples within the maximum range
    % specified by c_maxVertDiff
    function [l_ints] = GetIntervals(vectors)
        l_ints = zeros(0,2);

        startInd = 1;
        [~, minVert] = CartToSpherical(vectors(startInd,:));
        maxVert = minVert;
        for i=1:size(vectors,1)
            [hor, vert] = CartToSpherical(vectors(i,:));

            if (vert < minVert)
                minVert = vert;
            end
            if (vert > maxVert)
                maxVert = vert;
            end

            if (maxVert - minVert > c_maxVertDiff)
                l_ints = [l_ints; startInd i];
                startInd = i+1;
                if (startInd <= size(vectors,1))
                    [~, minVert] = CartToSpherical(vectors(startInd,:));
                    maxVert = minVert;
                end
            end
        end
        if (startInd <= size(vectors,1))
            l_ints = [l_ints; startInd size(vectors,1)];
        end
    end
end
