% DetectSaccade360IVT.m
%
% This function uses a simple speed threshold to detect saccades as in the I-VT
% algorithm of Salvucci, Dario D., and Joseph H. Goldberg. "Identifying
% fixations and saccades in eye-tracking protocols." Proceedings of the 2000
% symposium on Eye tracking research & applications. ACM, 2000.
%
% input:
%   data         - data from the ARFF file
%   metadata     - metadata from the ARFF file
%   attributes   - attributes from the ARFF file
%   typeOfMotion - 1 -> eye FOV, 2 -> eye+head
%   velThreshold - velocity threshold for I-Vt
%
% output:
%   result       - logical vector with same length as input data and true where a saccade was detected

function result = DetectSaccades360IVT(data, metadata, attributes, typeOfMotion, velThreshold)
    [eyeFovVec, eyeHeadVec, headVec] = GetCartVectors(data, metadata, attributes);
	if (typeOfMotion == 1)
        vecList = eyeFovVec;
    elseif (typeOfMotion == 2)
        vecList = eyeHeadVec;
    else
        error('Uknown motion');
    end

    timeInd = GetAttPositionArff(attributes, 'time');
    speed = GetSpeed(vecList, data(:,timeInd));

    result = speed > velThreshold;
end
