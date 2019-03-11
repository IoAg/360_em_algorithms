% DetectBlinks360.m
%
% This function detects blinks by using intervals of noise in arff as well as
% saccade detection. For every noise interval searches on both direction
% (forward and backwards in time) and if it finds a saccade within a given time
% distance it labels the noise and saccade interval as blink.
%
% input:
%   data        - data from the ARFF file
%   metadata    - metadata from the ARFF file
%   attributes  - attributes from the ARFF file
%   typeOfMotion- 1 -> eye FOV, 2 -> eye+head
%   params      - parameters to use for saccade detection
%
% output:
%   result      - logical vector with same length as data and true for every sample that is part of a blink

function result = DetectBlinks360(data, metadata, attributes, typeOfMotion, params)
	% initialize search interval on both sides of the blink in us
	c_searchRange = 40000;
    c_minConf = 0.5;

    timeInd = GetAttPositionArff(attributes, 'time');
    confInd = GetAttPositionArff(attributes, 'confidence');
    
    noise = false(size(data,1),1);
    noise(data(:,confInd) < c_minConf) = 1;

    saccades = DetectSaccades360(data, metadata, attributes, typeOfMotion, params);


    % initially
    result = noise;

    % search for noise indices
    isNoiseActive = 0;
    startIndex = -1;
    endIndex = -1;
    for noiseIndex=1:size(noise,1)
        if (isNoiseActive == 0 && noise(noiseIndex) == 1)
            isNoiseActive = 1;
            startIndex = noiseIndex;
        end

        if (isNoiseActive == 1 && noise(noiseIndex) == 0)
            isNoiseActive = 0;
            endIndex = noiseIndex-1;
            UpdateResult();
        end
    end

    % function UpdateResult:
    % It searches on both sides of the noise intervals for blinks.

    function UpdateResult()
        % search backwards
        searchIndex = startIndex;
        saccadeFound = false;
        while (searchIndex > 0)
            if (data(startIndex,timeInd)-data(searchIndex,timeInd) > c_searchRange && saccadeFound==false)
                break;
            end

            if (saccades(searchIndex) && saccadeFound==false)
                saccadeFound = true;
            end

            if (~saccades(searchIndex) && saccadeFound==true)
                result(searchIndex+1:startIndex) = 1;
                break;
            end
        
            searchIndex = searchIndex-1;
        end

        % search forward
        searchIndex = endIndex;
        saccadeFound = false;
        while (searchIndex <= size(data,1))
            if (data(searchIndex,timeInd)-data(endIndex,timeInd) > c_searchRange && saccadeFound==false)
                break;
            end

            if (saccades(searchIndex) && saccadeFound==false)
                saccadeFound = true;
            end

            if (~saccades(searchIndex) && saccadeFound==true)
                result(endIndex+1:searchIndex) = 1;
                break;
            end
        
            searchIndex = searchIndex+1;
        end

    end
end
