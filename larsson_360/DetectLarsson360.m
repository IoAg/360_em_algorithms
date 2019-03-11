% DetectLarsson360.m
%
% This function detect fixations, saccades, smooth pursuit and blinks. Saccades
% and blinks are detected with the DetectSaccades360 and DetectBlinks360 functions.
% The fixations and smooth pursuit are detected per the Larsson et al. 2015 paper
% "Detection of fixations and smooth pursuit movements in high-speed eye-tracking data"
%
% input:
%   data            - data from the ARFF file
%   metadata        - metadata from the ARFF file
%   attributes      - attributes from the ARFF file
%   typeOfMotion    - 1 -> eye FOV, 2 -> eye+head
%   paramSacc       - parameters to use for saccade detection. See function DetectSaccades360
%                     for details
%   paramLarsson    - parameters for fixation and saccade detection
%
% output:
%   result          - vector with the same length as data and values (0,1,2,3,4) representing
%                     {unassigned, fixation, saccade, sp, noise}
%
% paramLarsson format:
% paramLarsson is a data structure with the following fields. For an explanation 
% of each field refer to the original paper
%
% paramLarsson.preprocessVelThres;
% paramLarsson.t_window;
% paramLarsson.t_overlap;
% paramLarsson.eta_p;
% paramLarsson.t_min;
% paramLarsson.eta_d;
% paramLarsson.eta_cd;
% paramLarsson.eta_pd;
% paramLarsson.eta_maxFix;
% paramLarsson.eta_minSmp;
% paramLarsson.phi;
% paramLarsson.minConfidence;

function result = DetectLarsson360(data, metadata, attributes, typeOfMotion, paramSacc, paramLarsson)
    c_fix = 1;
    c_sacc = 2;
    c_sp = 3;
    c_noise = 4;
	attType = '{unassigned,fixation,saccade,sp,noise}';

    result = zeros(size(data,1),1);
    % detect saccades (parameters for 360 degrees)
    saccades = DetectSaccades360(data, metadata, attributes, typeOfMotion, paramSacc);
    result(saccades) = c_sacc;

    % detect blinks (parameters for 360 degrees) and merge with saccades
    blinks = DetectBlinks360(data, metadata, attributes, typeOfMotion, paramSacc);
    result(blinks) = c_noise;

    % when confidence below threshold assign noise label
    confInd = GetAttPositionArff(attributes, 'confidence');
    result(data(:,confInd) < paramLarsson.minConfidence) = c_noise;

    thd = paramLarsson.preprocessVelThres;
    result = preprocessing(data, metadata, attributes, result, thd, typeOfMotion);

    t_window = paramLarsson.t_window;
    t_overlap = paramLarsson.t_overlap;
    eta_p = paramLarsson.eta_p;
    prelSeg = preliminary_segment(data, metadata, attributes, result, typeOfMotion, t_window, t_overlap, eta_p);

    t_min = paramLarsson.t_min;
    eta_d = paramLarsson.eta_d;
    eta_cd = paramLarsson.eta_cd;
    eta_pd = paramLarsson.eta_pd;
    eta_maxFix = paramLarsson.eta_maxFix;
    eta_minSmp = paramLarsson.eta_minSmp;
    phi = paramLarsson.phi;
    result = extract_sp(data, metadata, attributes, result, typeOfMotion, prelSeg, t_min, eta_d, eta_cd, eta_pd, eta_maxFix, eta_minSmp, phi);

end
