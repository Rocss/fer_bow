function [data] = importTable(path, endRow)
disp('Importing data.. \n');

delimiter = ',';
startRow = 2;

%% Format for each line of text:
%   column1: double (%f)
%	column2: text (%s)
%   column3: categorical (%C)
formatSpec = '%f%s%C%[^\n\r]';

%% Open the text file.
fileID = fopen(path,'r');
dataArray = textscan(fileID, formatSpec, endRow-startRow+1, 'Delimiter', delimiter, 'TextType', 'string', 'HeaderLines', startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Create output variable
data = table(dataArray{1:end-1}, 'VariableNames', {'emotion','pixels','Usage'});
data = table2cell(data);

%% Clear temporary variables
clearvars filename delimiter startRow endRow formatSpec fileID dataArray ans;
disp('Import success');

end