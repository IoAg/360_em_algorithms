% function DetectSaccades360.m
%
% This function detects saccades from the provided data. It is based on the
% saccade detector described in Dorr, Michael, et al. "Variability of eye
% movements when viewing dynamic natural scenes." Journal of vision 10.10
% (2010): 28-28.
%
% input:
%   data        - data from the ARFF file
%   metadata    - metadata from the ARFF file
%   attributes  - attributes from the ARFF file
%   typeOfMotion- 1 -> eye FOV, 2 -> eye+head
%   params      - parameters to use for saccade detection
%
% output:
%   result      - logical vector with the same length as data and true where a saccade is detected
%
% params format:
% params is a data structure with the following fields
% 
% params.tolerance;
% params.thresholdOnsetFast;
% params.thresholdOnsetSlow;
% params.thresholdOffset;
% params.maxSpeed;
% params.minDuration;
% params.maxDuration;
% params.velIntegrationInterv;
% params.minConfidence

function result = DetectSaccades360(data, metadata, attributes, typeOfMotion, params)

    c_tolerance = params.tolerance;
    c_thresholdOnsetFast = params.thresholdOnsetFast;
    c_thresholdOnsetSlow = params.thresholdOnsetSlow;
    c_thresholdOffset = params.thresholdOffset;
    c_maxSpeed = params.maxSpeed;
    c_minDuration = params.minDuration;
    c_maxDuration = params.maxDuration;
    c_velIntegrationInterv = params.velIntegrationInterv;
    c_minConf = params.minConfidence;

    timeInd = GetAttPositionArff(attributes, 'time');
    xInd = GetAttPositionArff(attributes, 'x');
    yInd = GetAttPositionArff(attributes, 'y');
    confInd = GetAttPositionArff(attributes, 'confidence');

    % initialize result
    result = false(size(data,1),1);

    if (size(data,1) < 10)
        return;
    end

    [eyeFovVec, eyeHeadVec, headVec] = GetCartVectors(data, metadata, attributes);
    if (typeOfMotion == 1)
        vecList = eyeFovVec;
    elseif (typeOfMotion == 2)
        vecList = eyeHeadVec;
    elseif (typeOfMotion == 3)
        vecList = headVec;
    else
        error('Uknown motion');
    end

    speed = GetSpeed(vecList, data(:,timeInd));

    % create glitch array
    glitch = zeros(size(data,1),1);
    glitch(data(:,xInd) > (1+c_tolerance)*metadata.width_px) = 1;
    glitch(data(:,xInd) < -c_tolerance*metadata.width_px) = 1;
    glitch(data(:,yInd) > (1+c_tolerance)*metadata.height_px) = 1;
    glitch(data(:,yInd) < -c_tolerance*metadata.height_px) = 1;
    glitch(data(:,confInd) < c_minConf) = 0.75;

    isSaccActive = 0;
    onsetSlowIndex = 1;

    for i=1:size(data,1)
        % not in glitch
        if (glitch(i) == 0)
            if (isSaccActive == 0)
                % if speed less than onset slow move index
                if (speed(i) < c_thresholdOnsetSlow)
                    onsetSlowIndex = i+1;
                end

                % saccade above fast threshold but below physically impossible
                if (speed(i) > c_thresholdOnsetFast && speed(i) < c_maxSpeed)
                    isSaccActive = 1;
                    
                    % allocate all samples from onset slow as saccade
                    result(onsetSlowIndex:i) = 1;
                end
            end

            % if within saccade check for termination cases otherwise make sample part of saccade
            if (isSaccActive == 1)
                % saccade termination cases
                if (speed(i) < c_thresholdOffset)
                    isSaccActive = 0;

                    % check for minDuration
                    if (data(i,timeInd)-data(onsetSlowIndex,timeInd) < c_minDuration)
                        result(onsetSlowIndex:i-1) = 0;
                    end
                    continue; % skip rest of the loop
                end

                if (data(i,timeInd)-data(onsetSlowIndex,timeInd) > c_maxDuration)
                    isSaccActive = 0;
                    continue;
                end

                % check if onset and current point are the same
                if (i-onsetSlowIndex < 1)
                    continue
                end
                meanVel = mean(speed(onsetSlowIndex:i-1));

                if (meanVel < c_thresholdOnsetSlow)
                    isSaccActive = 0;

                    % check for minDuration
                    if (data(i,timeInd)-data(onsetSlowIndex,timeInd) < c_minDuration)
                        result(onsetSlowIndex:i-1) = 0;
                    end
                    continue;
                end
                result(i) = 1;
            end
        else
            onsetSlowIndex = i+1;
        end
    end
end
