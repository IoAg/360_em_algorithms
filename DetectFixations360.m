% DetectFixations360.m
%
% This function detects fixations from the provided data. It is based on the
% fixation detector desctibed in Dorr, Michael, et al. "Variability of eye
% movements when viewing dynamic natural scenes." Journal of vision 10.10
% (2010): 28-28.
%
% NOTE: It requires that saccades have already been detected.
%
% input:
%   data        - data from the ARFF file
%   metadata    - metadata from the ARFF file
%   attributes  - attributes from the ARFF file
%   saccAtt     - saccade attribute name
%   saccValue   - integer value representing saccades
%	typeOfMotion- 1 -> eye FOV, 2 -> eye+head, 3 -> head
%   params      - parameters to use for fixation detection
%
% output:
%   result      - logical vector with the same length as data in inputfile and true where a fixation is detected
%
% params format:
% params is a data structure with the following fields
%
% params.minDixationDur;
% params.maxDistanceDeg;
% params.velThresholdDdegDsec;
% params.intersaccadicDist;
% params.intersaccadicLength;
% params.minConfidence;

function m_result = DetectFixations360(data, metadata, attributes, saccAtt, saccValue, typeOfMotion, params)

    c_minFixationDurUs = params.minFixationDur;
    c_maxDistanceDeg = params.maxDistanceDeg;
    c_velThresholdDegSec = params.velThresholdDegSec;
    c_intersaccadicDist = params.intersaccadicDist;
    c_intersaccadicLength = params.intersaccadicLength;
    c_minConf = params.minConfidence;

	timeInd = GetAttPositionArff(attributes, 'time');
    xInd = GetAttPositionArff(attributes, 'x');
    yInd = GetAttPositionArff(attributes, 'y');
    confInd = GetAttPositionArff(attributes, 'confidence');

    % initialize return result
    m_result = false(size(data,1),1);

    if (size(data,1)<10)
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

    % get inter-sacacdic intervals and start processing them
    intersaccInts = GetIntersaccadicIntervals();

    % member  variables
    m_left = 0; % used in AnnotateFixation and the other local functions
    m_right = 0;

    % process each interval
    for intersaccIndex=1:size(intersaccInts,1)
        AnnotateFixation(intersaccInts(intersaccIndex,1), intersaccInts(intersaccIndex,2));
    end

    % remove noise from fixations
    m_result(data(:,confInd) < c_minConf) = 0;


    %-----------------------------------------------------------------------------------
    % local functions
    %-----------------------------------------------------------------------------------

    % function GetIntersaccadicIntervals:
    % Get the inter-saccadic intervals for the saccadic attribute of the ARFF file.
    function [l_intersaccInts] = GetIntersaccadicIntervals()
        [l_saccIndex] = GetAttPositionArff(attributes, saccAtt);

        l_intersaccInts = zeros(0,2);
        l_startOfInt = 1;
        l_isSaccActive = false;

        for l_i=1:size(data,1);
            % end of fixation interval found
            if (data(l_i,l_saccIndex) == saccValue && l_isSaccActive == false)
                l_isSaccActive = true;
                l_intersaccInts = [l_intersaccInts; l_startOfInt l_i-1];
            end

            if (data(l_i,l_saccIndex) ~= saccValue && l_isSaccActive == true)
                l_isSaccActive = false;
                l_startOfInt = l_i;
            end
        end
        
        % check for last interval
        if (data(end,l_saccIndex) ~= saccValue)
            l_intersaccInts = [l_intersaccInts; l_startOfInt size(data,1)];
        end
    end

    % function AnnotateFixation:
    % Processes the samples between the start and end indices.

    function AnnotateFixation(startIndex, endIndex)
        % if interval is too long check for its diplacement
        if (endIndex-startIndex > 1 && data(endIndex,timeInd)-data(startIndex,timeInd) > c_intersaccadicLength)
			l_maxDisp = GetMaxDispersion(vecList(startIndex:endIndex,:));

            % do not process if distance is too big
            if (l_maxDisp > c_intersaccadicDist)
                return;
            end
        end

        % continue processing
        m_left = startIndex;
        m_right = startIndex;

        while (DetermineSearchWindow(startIndex, endIndex))
            if (IsFixation())
                ExtendFixationWindow(startIndex, endIndex);

                m_left = m_right;
            else
                m_left = m_left+1;
            end
        end


    end

    % function DetermineSearchWindow:
    % Move m_right to accomodate the minimum fixation duration. If it can't return false.
    function l_result = DetermineSearchWindow(startIndex, endIndex)
        l_result = true;

        if (m_left > endIndex)
            l_result = false;
            return;
        end

        while (m_right <= endIndex && (data(m_right,timeInd)-data(m_left,timeInd)) < c_minFixationDurUs)
            m_right = m_right+1;
        end

        if (m_right > endIndex)
            l_result = false;
            return;
        end
    end

    % function ExtendFixationWindow:
    % Extend m_right until we reach end of interval of stops to be a fixation.
    function ExtendFixationWindow(startIndex, endIndex)
        while (true)
            m_right = m_right+1;
            if (m_right > endIndex || IsFixation()==false)
                break;
            end
        end

        % result of main function
        m_result(m_left:m_right-1) = 1;
    end

    % function IsFixation:
    % Determines from m_left, m_right if the interval is a valid fixation.
    function l_result = IsFixation()
        l_result = true;
		% get distance between first and last vector in list
        l_distance = GetDispersion(vecList(m_left,:), vecList(m_right,:));
        l_speed = 1000000*l_distance/(data(m_right,timeInd)-data(m_left,timeInd));

        if (l_speed > c_velThresholdDegSec)
            l_result = false;
            return;
        end

		meanVec = sum(vecList(m_left:m_right,:),1) / (m_right - m_left + 1);

        l_duration = data(m_right,timeInd) - data(m_left,timeInd);
        l_duration = (l_duration - c_minFixationDurUs)/1000 + 1;

        % increase threshold depending on fixation duration
        l_dispThres = c_maxDistanceDeg*(1+0.05*log2(l_duration));

		l_disp = GetDispersion(meanVec, vecList(m_left:m_right,:));
		if (l_disp > l_dispThres)
			l_result = false;
		end
    end
end
