% DetectOKN360.m
%
% This function detects optokinetic nystagmus for 360 degrees data. It uses a 
% two step process. In the first step it detects points were the direction 
% difference around a point is greater than 90 degrees. In the second step
% it compares the FOV speed of the intervals. If it is above a threshold then
% it is considered as OKN
%
% NOTE: OKN is calculated only in FOV representation. Also saccades have to be
% annotated in advance.
%
% input:
%   arffFile    - file with ARFF data
%   saccAttName - name of the saccade attribute
%   saccValue   - integer value representing saccades
%
% output:
%   result      - a logical vector of the same size as the data in the ARFF with true value
%                 when OKN occurs

function result = DetectOKN360(arffFile, saccAttName, saccValue)
    c_minIntAngle = 90; % minimum angle between saccade and subsequent interval
    c_maxIntSaccAngle = 70; % maximum angle between saccades
    c_minIntSpeed = 10; % degrees/sec
    c_saccAttVal = saccValue;
    c_OKNlabel = 1;

    [data, metadata, attributes] = LoadArff(arffFile);
    timeInd = GetAttPositionArff(attributes, 'time');

    [eyeFovVec, eyeHeadVec, headVec] = GetCartVectors(data, metadata, attributes);

    saccInts = GetIntervalsIndexArff(data, attributes, saccAttName, c_saccAttVal);

    result = zeros(size(data,1),1);
    attInd = GetAttPositionArff(attributes, saccAttName);
    %result(data(:,attInd) == c_saccAttVal) = c_OKNlabel;
    for ind=1:size(saccInts,1)-1
        saccDir1 = eyeFovVec(saccInts(ind,2),:) - eyeFovVec(saccInts(ind,1),:);
        saccDir2 = eyeFovVec(saccInts(ind+1,2),:) - eyeFovVec(saccInts(ind+1,1),:);

        % inter-saccadic direction
        intSaccDir = eyeFovVec(saccInts(ind+1,1)-1,:) - eyeFovVec(saccInts(ind,2)+1,:);

        if (sum(saccDir1) == 0 || sum(saccDir2) == 0 || sum(intSaccDir) == 0)
            continue;
        end

        saccDir1 = saccDir1 / norm(saccDir1);
        saccDir2 = saccDir2 / norm(saccDir2);
        intSaccDir = intSaccDir / norm(intSaccDir);

        relDirSacc = GetDispersion(saccDir1, saccDir2);
        relDirIntSacc1 = GetDispersion(saccDir1, intSaccDir);
        relDirIntSacc2 = GetDispersion(saccDir2, intSaccDir);
        dur = data(saccInts(ind+1,1)-1, timeInd) - data(saccInts(ind,2)+1, timeInd);
        dur = dur / 1000000;
        ampl = GetDispersion(eyeFovVec(saccInts(ind+1,1)-1,:), eyeFovVec(saccInts(ind,2)+1,:));
        speed = ampl / dur;

        if (relDirSacc < c_maxIntSaccAngle && ...
            relDirIntSacc1 > c_minIntAngle && ...
            relDirIntSacc2 > c_minIntAngle && ...
            speed > c_minIntSpeed)
        %if ((relDirIntSacc1 > c_minIntAngle || ...
        %    relDirIntSacc2 > c_minIntAngle) && ...
        %    speed > c_minIntSpeed)
            result(saccInts(ind,2)+1:saccInts(ind+1,1)-1) = c_OKNlabel;
        end
    end

    % Iterate again through saccade intervals and make sure that at least two
    % OKN intervals exist continuously.
    for ind=2:size(saccInts,1)-1
        if (result(saccInts(ind,2)+1) == c_OKNlabel)
            if (result(saccInts(ind,1) -1) ~= c_OKNlabel && ... % previous interval
                    result(saccInts(ind+1,2)+1) ~= c_OKNlabel) % next interval
                result(saccInts(ind,2)+1:saccInts(ind+1,1)-1) = 0;
            end
        end
        % assign OKN label to saccades between OKN intervals
        if (result(saccInts(ind,1) -1) == c_OKNlabel && ... 
                result(saccInts(ind,2)+1) == c_OKNlabel) 
            result(saccInts(ind,1):saccInts(ind,2)) = c_OKNlabel;
        end
   end

    confInd = GetAttPositionArff(attributes, 'confidence');
    result(data(:,confInd) < 1) = 0;

    result = logical(result);
end
