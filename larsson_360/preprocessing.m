function [ result ] = preprocessing(data, metadata, attributes, labelVec, thd, typeOfMotion)
%This function processes the intersaccadic intervals (for 1 observer)
%
%   @data from ARFF
%   @metadata of the ARFF file
%   @attributes describing data
%   @labelVec label vector to consider for intervals with value 0 (unassigned)
%   @thd denotes the velocity threshold (in deg/s, samples with speed above which from the 
%   beginning and end of each interval will be removed). Default value is 100
%   deg/s.
%   @typeOfMotion gets the values 1 -> eye FOV, 2 -> eye+head, 3 -> head
%
%   @result cleared labelVec after high velocity changes removal


%intArray = [index size(data,1)+1];
moveId = 0; % unassigned part
intArray = GetIntervalsIndex(labelVec, moveId);
% get position for time, x, y
timeInd = GetAttPositionArff(attributes, 'time');

c_speedStep = 2; % allow for a bit of filtering during speed calculation

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

speed = GetSpeed(vecList, data(:,timeInd), c_speedStep);

exceedVel = zeros(1, size(data,1)); % denotes if a pair exceeds velocity threshold

% fill exceedVel array
for i=1:size(intArray,1)
    startIndex = intArray(i,1);
    endIndex = intArray(i,2);

    exceedVel(startIndex:endIndex-1) = speed(startIndex:endIndex-1) > thd;
end

% leave high velocity assignement only at start-end of each intersaccadic interval
for i=1:size(intArray,1)
    startIndex = intArray(i,1);
    endIndex = intArray(i,2);
    PSOstart = endIndex; % just to initialize at something that doesn't break the last if
    PSOend = startIndex;

    for j=startIndex:endIndex
        if (exceedVel(j) == 0)
            PSOstart = j;
            break;
        end
    end

    for j=endIndex:-1:startIndex
        if (exceedVel(j) == 0)
            PSOend = j;
            break;
        end
    end
    
    if (PSOstart < PSOend)
        exceedVel(PSOstart:PSOend) = 0;
    end
end

% assign initial labels to result 
result = labelVec;

% where velocity exceeds threshold assign value of 4 (noise)
result(exceedVel(:)==1) = 4;
end
