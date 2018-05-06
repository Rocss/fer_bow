
conf.clobber = 0;
conf.calDir = 'data/training';
conf.testDir = 'data/publicTest';
conf.resultsDir = 'results/' ;
conf.numClasses = 7;
conf.numTest = zeros(1, conf.numClasses);
conf.numWords = 2300;
conf.numSpatialX = 1;
conf.numSpatialY = 1;
conf.quantizer = 'kdtree';

conf.phowOpts = {'ContrastThreshold', 0.015, 'step', 1, 'sizes', [2, 4, 6, 8]};
conf.randSeed = 1;

conf.vocabPath = fullfile(conf.resultsDir, 'vocab.mat') ;
conf.histPath = fullfile(conf.resultsDir, 'hists.mat') ;
conf.modelPath = fullfile(conf.resultsDir, 'model.mat') ;
conf.resultPath = fullfile(conf.resultsDir, 'result') ;

randn('state', conf.randSeed) ;
rand('state', conf.randSeed) ;
vl_twister('state', conf.randSeed) ;

% --------------------------------------------------------------------
%                                                           Setup data
% --------------------------------------------------------------------
classes = dir(conf.calDir) ;
classes = classes([classes.isdir]) ;
classes = {classes(3:conf.numClasses+2).name} ;

images = {} ;
imageClass = {} ;
img_index = 0;

selTrain = [];
selTest = [];

for ci = 1:length(classes)
  ims = dir(fullfile(conf.calDir, classes{ci}, '*.png'))' ;
  ims = cellfun(@(x)fullfile(classes{ci},x),{ims.name},'UniformOutput',false) ;
  
  testIms = dir(fullfile(conf.testDir, classes{ci}, '*.png'))' ;
  testIms = cellfun(@(x)fullfile(classes{ci},x),{testIms.name},'UniformOutput',false) ;

  images = {images{:}, ims{:}, testIms{:}};
  imageClass{end+1} = ci * ones(1,length(ims) + length(testIms)) ;
  
  for i = 1:length(ims)
      img_index = img_index + 1;
      selTrain = [selTrain, img_index];
  end
  
  for i = 1:length(testIms)
      img_index = img_index + 1;
      selTest = [selTest, img_index];
      conf.numTest(1, ci) = length(testIms);
  end
end

imageClass = cat(2, imageClass{:}) ;



% --------------------------------------------------------------------
%                                                     Train vocabulary
% --------------------------------------------------------------------

if ~exist(conf.vocabPath) || conf.clobber
  % Get some PHOW descriptors to train the dictionary
  selTrainFeats = vl_colsubset(selTrain, 30) ;
  descriptors = {} ;
 
  for index = 1:length(selTrainFeats)

    im = imread(fullfile(conf.calDir, images{selTrainFeats(index)})) ;
    im = standarizeImage(im) ;
    [features, descrs] = vl_phow(im, conf.phowOpts{:}) ;
    
    descriptors{index} = descrs;
  end

  descriptors = vl_colsubset(cat(2, descriptors{:}), 10e4) ;
  descriptors = single(descriptors) ;

  % Quantize the descriptors to get the visual words
  vocab = vl_kmeans(descriptors, conf.numWords, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 50) ;
  save(conf.vocabPath, 'vocab') ;
else
  load(conf.vocabPath) ;
end

conf.vocab = vocab;

if strcmp(conf.quantizer, 'kdtree')
  conf.kdtree = vl_kdtreebuild(vocab) ;
end

% --------------------------------------------------------------------
%                                           Compute spatial histograms
% --------------------------------------------------------------------

if ~exist(conf.histPath) || conf.clobber
  hists = {} ;
  for ii = 1:length(images)
  % for ii = 1:length(images)
    fprintf('Processing %s (%.2f %%)\n', images{ii}, 100 * ii / length(images)) ;
    try
       im = imread(fullfile(conf.calDir, images{ii})) ;
    catch
       im = imread(fullfile(conf.testDir, images{ii})) ;
    end
    hists{ii} = getImageDescriptor(conf, im);
  end

  hists = cat(2, hists{:}) ;
  save(conf.histPath, 'hists') ;
else
  load(conf.histPath) ;
end

% % --------------------------------------------------------------------
% %                                                  Compute feature map
% % --------------------------------------------------------------------
% 
% psix = vl_homkermap(hists, 1, 'kchi2', 'gamma', .5) ;


% --------------------------------------------------------------------
%                                                            Train SVM
% --------------------------------------------------------------------

if ~exist(conf.modelPath) || conf.clobber
    perm = randperm(length(selTrain));
    randomPerm = selTrain(perm);
    
    YTrain = imageClass(randomPerm);
    featuresTrain = hists(:, randomPerm);
    featuresTrain = transpose(featuresTrain);
 
    classifier = fitcecoc(featuresTrain, YTrain, 'Verbose', 2);
    
    testPerm = randperm(length(selTest));
    testRandomPerm = selTest(testPerm); 
    
    YTest = imageClass(testRandomPerm);
    featuresTest = hists(:, testRandomPerm);
    featuresTest = transpose(featuresTest);
    
    YPred = predict(classifier,featuresTest);
    
    occurences = 0;
    for i = 1: length(YPred)
        if (YPred(i) == YTest(i))
            occurences = occurences + 1;
        end
    end
    
    accuracy = occurences/length(YPred);
end