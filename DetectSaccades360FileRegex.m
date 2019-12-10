% DetectSaccades360FileRegex.m
%
% This function calls the saccades detector of the Dorr et al. 2010 for the provided
% files in the regular expression
%
% input:
%   regex       - regular expression to ARFF files
%   outDir      - output directory
%   outputAtt   - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion - 1 -> eye FOV, 2 -> eye+head
%   paramfile   - file containing saccade detection parameters
%
% ex. DetectSaccades360FileRegex('/mnt/syno8/data/VideoGaze360/gaze/labelled_ioannis/*.arff', '/mnt/scratch/VideoGaze360_buffer/labelled_files_algorithm/', 'saccades', 1, 'params_saccades_fov.txt')
                                                                                

function DetectSaccades360FileRegex(regex, outDir, outputAtt, typeOfMotion, paramfile)
    filelist = glob(regex);

    for i=1:size(filelist,1)
        filename = filelist{i,1};
        disp(filename);
        [path, name, ext] = fileparts(filename);

        outFile = fullfile(outDir, [name ext]);

        DetectSaccades360File(filename, outFile, outputAtt, typeOfMotion, paramfile);
    end
end
