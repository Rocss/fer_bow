table_length = 32298;
data = importTable('/Users/manoleroxana/Documents/Licenta/Project/data/fer2013.csv', table_length);
ferPlus = importNew('/Users/manoleroxana/Documents/Licenta/Project/data/fer2013new.csv');

disp('everything imported');

for i = 1:size(data, 1)
    disp(i);
    row = data(i,:);
    pixels = row(1,2);
    type = table2cell(ferPlus(i, 'Usage'));
    
    img = str2img(pixels{1,1});

    order = ["neutral", "happiness", "surprise", "sadness", "anger", "disgust", "fear", "contempt", "unknown", "NF"];

    annotations = cell2mat(table2cell(ferPlus(i, 3:12)));
    [value, index] = max(annotations);
    emotion = order(index);
    
    if emotion ~= "contempt" && emotion ~= "unknown" && emotion ~= "NF"
        path = 'data/';
        if type{1} == 'Training'
            path = strcat(path, 'training/');
        elseif type{1} == 'PublicTest'
            path = strcat(path, 'publicTest/');
        else
            path = strcat(path, 'unknown/');
        end

        path = strcat(path, emotion);

        file_name = strcat(path, '/img', num2str(i), '.png');

        imwrite(img, file_name{1});
    end
end