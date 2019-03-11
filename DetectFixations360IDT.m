% DetectFixations360IDT.m
%
% This function detects fixations based on the I-DT algorithm of Salvucci,
% Dario D., and Joseph H. Goldberg. "Identifying fixations and saccades in
% eye-tracking protocols." Proceedings of the 2000 symposium on Eye
% tracking research & applications. ACM, 2000.
%
% input:
%   data            - data from the ARFF file
%   metadata        - metadata from the ARFF file
%   attributes      - attributes from the ARFF file
%   typeOfMotion    - 1 -> eye FOV, 2 -> eye+head
%   dispThres       - dispersion threshold in degrees
%   windowDur       - window duration in us
%
% output:
%   result          - logical vector with same length as input and true where a 
%                     fixaton was detected

function result = DetectFixations360IDT(data, metadata, attributes, typeOfMotion, dispThres, windowDur)
    [eyeFovVec, eyeHeadVec] = GetCartVectors(data, metadata, attributes);
    if (typeOfMotion == 1)
        vecList = eyeFovVec;
    elseif (typeOfMotion == 2)
        vecList = eyeHeadVec;
    else
        error('Uknown motion');
    end

    timeInd = GetAttPositionArff(attributes, 'time');
    startInd = 1;
    result = false(size(data,1),1);
    endInd = FindEndInd();
    while (endInd > 0)
        dispersion = GetMaxDispersion(vecList(startInd:endInd,:));
        if (dispersion > dispThres)
            startInd = startInd + 1;
            endInd = FindEndInd();
            continue;
        end

        while(dispersion < dispThres && endInd <= size(data,1))
            newDisp = GetDispersion(vecList(endInd,:), vecList(startInd:endInd,:));
            dispersion = max([newDisp dispersion]);
            endInd = endInd + 1;
        end
        result(startInd:endInd-1) = 1;
        startInd = endInd;
        endInd = FindEndInd();
    end

    function l_endInd = FindEndInd()
        l_endInd = -1;
        for l_ind=startInd:size(data,1)
            if (data(l_ind, timeInd) - data(startInd,timeInd) > windowDur)
                break;
            end
            l_endInd = l_ind;
        end
    end
end
