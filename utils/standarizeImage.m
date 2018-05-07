function im = standarizeImage(im)
    im = im2single(im) ;
    im = histeq(im);
%     im = imresize(im, [48 48]);
end