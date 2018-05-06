function hist = getImageDescriptor(conf, im)
    im = standarizeImage(im) ;
    width = size(im,2) ;
    height = size(im,1) ;

    % get PHOW features
    [frames, descrs] = vl_phow(im, conf.phowOpts{:}) ;

    % quantize local descriptors into visual words
    binsa = double(vl_kdtreequery(conf.kdtree, conf.vocab, ...
                                  single(descrs), ...
                                  'MaxComparisons', 50)) ;

    % quantize location                          
    binsx = vl_binsearch(linspace(1,width,conf.numSpatialX+1), frames(1,:)) ;
    binsy = vl_binsearch(linspace(1,height,conf.numSpatialY+1), frames(2,:)) ;

    % combined quantization
    bins = sub2ind([conf.numSpatialY, conf.numSpatialX, conf.numWords], binsy,binsx,binsa) ;
    hist = zeros(conf.numSpatialY * conf.numSpatialX * conf.numWords, 1);
    hist = vl_binsum(hist, ones(size(bins)), bins);
    hist = single(hist / sum(hist)) ;
end