% function LoadParams:
% load parameters from a file. Each parameter has a name at the left of the equal sign 
% and a value at the right. Also all the parameters are converted to lower case
%
% input:
%   paramfile   - file containg the parameters
%
% output:
%   params      - a struct that has the parameter names as fields

function params = LoadParams(paramfile)
    % load data
    input = importdata(paramfile,'=');

    % populate params
    for i=1:size(input.data,1);
        params.(input.textdata{i,1}) = input.data(i);
    end
end
