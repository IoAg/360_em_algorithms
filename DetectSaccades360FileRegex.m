% DetectSaccades360FileRegex.m
%
% This function calls the CombineViews functino for all the files in the regular
% expression
%
% input:
%   regex       - regular expression to ARFF files
%   outDir      - output directory
%   typeOfMotion - 1 -> eye FOV, 2 -> eye+head
%   paramfile   - file containing saccade detection parameters
%
% ex. DetectSaccades360Regex('/mnt/syno8/data/VideoGaze360/gaze/labelled_ioannis/*.arff', '/mnt/scratch/VideoGaze360_buffer/labelled_files_algorithm/', 1, 'params_saccades_fov.txt')
                                                                                

function DetectSaccades360FileRegex(regex, outDir, outputAtt, typeOfMotion, paramfile)
    c_outAtt = 'saccades';
    filelist = glob(regex);

    for i=1:size(filelist,1)
        filename = filelist{i,1};
        disp(filename);
        [path, name, ext] = fileparts(filename);

        outFile = fullfile(outDir, [name ext]);

        DetectSaccades360File(filename, outFile, c_outAtt, typeOfMotion, paramfile);
    end
end
