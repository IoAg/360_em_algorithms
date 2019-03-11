function [ result ] = extract_sp(data, metadata, attributes, labelVec, typeOfMotion, prelInt, t_min, eta_D, eta_CD, eta_PD, eta_maxFix, eta_minSmp, phi)
%Classifies intervals as fixations or SP
%   @data of gaze recordings
%   @metadata of the ARFF data
%   @attributes describing data
%   @labelVec label vector to consider for intervals with value 0 (unassigned)
%   @typeOfMotion gets the values 1 -> eye FOV, 2 -> eye+head
%   @prelInt preliminary intervals for labelVec
%
%   @t_min is the threshold for minimal fixation duration us, default is 40000us
%   @eta_D is the threshold for p_D (dispersion), default is 0.45
%   @eta_CD is the threshold for consistency of direction, default is 0.5
%   @eta_PD is the threshold for position displacement, default is 0.2
%   @eta_maxFix is the threshold for spacial range, default is 1.9 deg 
%   @eta_minSmp is the threshold for merged segments spacial range, default is
%   1.7 deg
%   @phi is the threshold for mean direction difference, default is 45 degrees
%
%   @result is the same length as labelVec with fixations and sp labelled

    if nargin < 12
        phi = 180 / 4;
    end
    if nargin < 11
        eta_minSmp = 1.7;
    end
    if nargin < 10
        eta_maxFix = 1.9;
    end
    if nargin < 9
        eta_PD = 0.2;
    end
    if nargin < 8
        eta_CD = 0.5;
    end
    if nargin < 7
        eta_D = 0.45;
    end
    if nargin < 6
        t_min = 40000;
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

    c_fix = 1;
    c_sp = 3;

    % convert minSp,maxFix to pixels
    eta_minSmp = eta_minSmp;
    eta_maxFix = eta_maxFix;

    % find position of attributes
    timeIndex = GetAttPositionArff(attributes, 'time');
   
    moveId = 0; % unassigned
    index = GetIntervalsIndex(labelVec, moveId);
    segment_class = zeros(size(prelInt,1),1); % 0 is unsure, 1 is SP, -1 if fixation
    segment_parameters = zeros(size(prelInt, 1), 7); % 4 criteria and mean direction (x,y,z)
    segment_intersacc_index = zeros(size(prelInt,1),1);
   
    segm_i = 1;
    for i = 1:size(index, 1)
    	start_ind = index(i,1);
   		end_ind = index(i,2);
		
		while segm_i < size(prelInt, 1)    	
	    	segm_begin =  prelInt(segm_i,1);
	    	segm_end = prelInt(segm_i,2);

	    	if segm_begin < start_ind || segm_end > end_ind
	    		break;
            end
            
            if segm_begin == segm_end
                segment_class(segm_i) = -1; % segment of 0 length, let's label it as a fixation
                segm_i = segm_i + 1;
                continue
            end
            if (data(segm_end, timeIndex) - data(segm_begin, timeIndex)) < t_min 
                segment_class(segm_i) = -1; % too short segment, let it be a fixation
                segm_i = segm_i + 1;
                continue
            elseif (segm_end-segm_begin < 3) %% added by ioannis for jumps in time
                segment_class(segm_i) = -1; % too short segment, let it be a fixation
                segm_i = segm_i + 1;
                continue
            end
            
	    	segment_intersacc_index(segm_i) = i;

            part = vecList(segm_begin:segm_end,:);

	    	[coeff, transformed, d_pc] = pca(part);

            maxDisp = GetMaxDispersion(part);
            
	        d_ed = GetDispersion(part(end, :), part(1, :));

            shifts = zeros(size(part,1)-1,1);
            for shiftInd=1:size(shifts,1)
                shifts(shiftInd) = GetDispersion(part(shiftInd,:), part(shiftInd+1,:));
            end
	    	traj_len = sum(shifts);

	    	sp_range = GetMaxDispersion(part);
	    
            dirs = diff(part); % vectors to the direction of gaze
            dirsTmp = dirs;
            % normalize all direction vectors in order to have same contribution to mean vector
            for dirInd=1:size(dirs,1)
                if (sum(dirs(dirInd,:)) == 0)
                    if (dirInd > 1)
                        dirs(dirInd,:) = dirs(dirInd-1,:);
                    else
                        dirs(dirInd,:) = [1 0 0];
                    end
                end
                dirs(dirInd,:) = dirs(dirInd,:) / norm(dirs(dirInd,:));
            end
            mean_dir = sum(dirs,1) / size(dirs,1);

	    	p_D = d_pc(2) / d_pc(1);
	    	p_CD = d_ed / maxDisp;
	    	p_PD = d_ed / traj_len;
	    	p_R = sp_range;

            duration = data(segm_end,timeIndex) - data(segm_begin,timeIndex);
            l_eta_maxFix = eta_maxFix * (1 + 0.05 * log2(duration)); % increase/decrease spread based on duration of segment

	    	%criteria = [-p_D, p_CD, p_PD, p_R] > [-eta_D, eta_CD, eta_PD, eta_maxFix];
	    	criteria = [-p_D, p_CD, p_PD, p_R] > [-eta_D, eta_CD, eta_PD, l_eta_maxFix];
	    	
	    	segment_parameters(segm_i, 1:4) = criteria;
	    	segment_parameters(segm_i, 5:7) = mean_dir;

    		if sum(criteria) == 4
    			segment_class(segm_i) = 1; 
    		elseif sum(criteria) == 0
    			segment_class(segm_i) = -1;
    		else
    			% uncertain segment
    			% do nothing yet
    		end

	    	segm_i = segm_i + 1;
	    end
	end

    % initialize result to the labelled input vector
    result = labelVec;

    for segm_i = 1:size(prelInt, 1)
    	if segment_class(segm_i) == 0
    		% uncertain segment
    		if segment_parameters(segm_i, 3) == 0 %similar to fixation
    			if segment_parameters(segm_i, 4) == 1
    				segment_class(segm_i) = 2; % SP, as determined on 2nd stage
    			else
    				segment_class(segm_i) = -1; % fixation
    			end
    		else % similar to SP
    			% FIXME subject to change if a typo in a paper is found around Table 1
                % Removed assertion because of adaptive eta_maxFix
    			%assert(eta_maxFix >= eta_minSmp)
    			% then if we find any SP segments within the same intersaccadic interval, it's a SP
    			target_ISI = segment_intersacc_index(segm_i);
    			for search_i = 1:size(prelInt, 1)
    				if segment_intersacc_index(search_i) < target_ISI
    					continue
    				elseif  segment_intersacc_index(search_i) > target_ISI
    					break
    				end
    				if segment_class(search_i) ~= 1
    					continue
    				end
    				% angle comparisson
                    dir1 = segment_parameters(search_i, 5:7);
                    dir2 = segment_parameters(segm_i, 5:7);
                    rel_angle = GetDispersion(dir1, dir2);
                    if (rel_angle <= phi)
    					segment_class(segm_i) = 2; % SP, as determined on 2nd stage
    				end
    			end
    			if segment_class(segm_i) == 0
    				segment_class(segm_i) = -1; % if no similar SP were found, it's a fixation
    			end
    		end
    	end

    	if segment_class(segm_i) > 0 %any of SP
		    result(prelInt(segm_i,1):prelInt(segm_i,2)) = c_sp; % assign sp
    	end

        if segment_class(segm_i) < 0 % -1 fixation
		    result(prelInt(segm_i,1):prelInt(segm_i,2)) = c_fix; % assign fixation
        end
    end
end
