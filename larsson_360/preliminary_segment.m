function [ prelIntArray ] = preliminary_segment(data, metadata, attributes, labelVec, typeOfMotion, t_wind, t_overlap, eta_p)
%This funcation performs Larsson's preliminary segmentation
%   @data to use
%   @metadata of the ARFF data
%   @attributes describing the data
%   @labelVec label vector to consider for intervals with value 0 (unassigned)
%   @typeOfMotion gets the values 1 -> eye FOV, 2 -> eye+head, 3 -> head
%
%   @t_wind is window size in us, default is 22000
%   @t_overlap is overlp size in us, default is 6000
%   @eta_p - threshold for average p-value of Reyleigh test for each sample,
%   default value (from paper) is 0.01
%   
%   @prelIntArray preliminary segmentation of labelVec intervals

if nargin < 3
    error('At least 3 arguments are needed');
end
if nargin < 4
    t_wind = 22000; % us
end
if nargin < 5
    t_overlap = 6000; % us
end 
if nargin < 6
    eta_p = 0.01;
end

% get position of attributes in data
timeIndex = GetAttPositionArff(attributes, 'time');

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

moveId = 0; % unassigned
intArray = GetIntervalsIndex(labelVec, moveId);

% calculate direction of motion as difference between vector positions in 3D
dirList = zeros(size(vecList));
for i=1:size(intArray,1)
    startIndex = intArray(i,1);
    endIndex = intArray(i,2);

    for j=startIndex:endIndex-1
        dirList(j,:) = vecList(j+1,:) - vecList(j,:);
        if (sum(dirList(j,:)) == 0)
            if (j > startIndex)
                dirList(j,:) = dirList(j-1,:);
            end
        else
            % nomalize directions to unit vectors
            dirList(j,:) = dirList(j,:)/norm(dirList(j,:));
        end;
    end
    % assing same value to the last entry as the penultimate
    if (endIndex-startIndex > 1)
        dirList(endIndex,:) = dirList(endIndex-1,:);
    end
end

% calculate P mean
Pmean = zeros(1, size(data,1));
N = zeros(1, size(data,1));

for i=1:size(intArray,1)
    startIndex = intArray(i,1);
    endIndex = intArray(i,2);

    j=startIndex;
    startInterval = startIndex;
    newStartInterval = -1;
    while (j<=endIndex)
        if (data(j,timeIndex) > data(startInterval,timeIndex) + t_overlap && newStartInterval < 0)
            newStartInterval = j;
        end

        if (data(j,timeIndex) < data(startInterval,timeIndex) + t_wind)
            j = j + 1; % just move to next
        else
            % get r for all values
            p = Rtest(dirList(startInterval:j-1,:));
            Pmean(startInterval:j-1) = Pmean(startInterval:j-1) + p;
            N(startInterval:j-1) = N(startInterval:j-1) + 1;
            startInterval = newStartInterval;
            j = newStartInterval;
            newStartInterval = -1;
        end
    end

    % get last entries of intersaccadic interval
    p = Rtest(dirList(startInterval:endIndex,:));
    Pmean(startInterval:j-1) = Pmean(startInterval:endIndex) + p;
    N(startInterval:j-1) = N(startInterval:endIndex) + 1;

end

Pmean = Pmean./N;

% convert Pmean to 0 1 array
Pmean(Pmean(:) < eta_p) = 0;
Pmean(Pmean(:) ~= 0) = 1;

prelIntArray = zeros(0,2);

for i=1:size(intArray,1)
    startIndex = intArray(i,1);
    endIndex = intArray(i,2);

    intStart = startIndex;
    for j=startIndex+1:endIndex
        if (Pmean(j) ~= Pmean(j-1))
            prelIntArray = [prelIntArray; intStart j-1];
            intStart = j;
        end
    end

    % add last part of interval
    if (intStart ~= endIndex)
        prelIntArray = [prelIntArray; intStart endIndex];
    end
end

% Function that returns mean Reyleigh-R
%
%   @l_velList nomalized vector list for 3D points in 360 deg videos
function R = meanR(l_vecList)
    R = sum(l_vecList,1);
    R = norm(R) / size(l_vecList,1);
end

% This function returns the p-value calculated from the Reyleigh test
function pval = Rtest(l_vecList)
    r = meanR(l_vecList);
    n = size(l_vecList,1);

    R = n*r;

    pval = exp(sqrt(1 + 4*n + 4*(n^2 - R^2)) - (1 + 2*n));
end
end
