% DetectLarsson360FileRegex.m
%
% This function calls the DetectLarssonFile for all the files found with the
% regular expression
%
% input:
%   regex           - regular expression to ARFF files
%   outDir          - output directory to stire files after detection
%   outputAtt       - attribute that holds detected fixations in the output ARFF file
%   typeOfMotion    - 1 -> eye FOV, 2 -> eye+head
%   paramSaccFile   - file contining parameters to use for saccade detection.
%                     See function DetectSaccades360File for details
%   paramLarssonFile- file containing parameters for fixation and saccade detection

function DetectLarsson360FileRegex(regex, outDir, outputAtt, typeOfMotion, paramSaccFile, paramLarssonFile)
    filelist = glob(regex);
    for i=1:size(filelist,1)
        filename = filelist{i,1};
        [dir, name, ext] = fileparts(filename);
        outputfile = fullfile(outDir, [name ext]);

        DetectLarsson360File(filename, outputfile, outputAtt, typeOfMotion, paramSaccFile, paramLarssonFile);
    end
end
