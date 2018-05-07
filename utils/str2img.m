function [ image ] = str2img( string )
    % split string by space resulting a string array
    newStr = split(string,' ');
    
    % reshape string array into a uint8 matrix
    imgMatrix = uint8(str2double(reshape(newStr, [48,48])));
    
    % get the right angle 
    image = imrotate(imgMatrix, -90);
end