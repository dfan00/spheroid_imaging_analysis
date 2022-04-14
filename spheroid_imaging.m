%SOURCES
%http://bigwww.epfl.ch/sage/soft/mij/ <-- mij.jar and ij.jar packages
%https://imagej.net/scripting/matlab
%https://www.mathworks.com/matlabcentral/fileexchange/47545-mij-running-imagej-and-fiji-within-matlab
%https://www.mathworks.com/help/images/detecting-a-cell-using-image-segmentation.html
%https://www.mathworks.com/help/images/correcting-nonuniform-illumination.html

clc
clear all

tic;

filename='Drop1.tif';
im_mat=imread(filename); %extract image
image(im_mat);

javaaddpath 'C:\Program Files\MATLAB\R2022a\java\mij.jar' %extend java classpath to mij.jar
javaaddpath 'C:\Program Files\MATLAB\R2022a\java\ij.jar' %extend java classpath to ij.jar 
MIJ.start; %open ImageJ

IJ=ij.IJ;
ij.ImageJ();
ips=IJ.openImage('C:\Users\dalia\OneDrive\Documents\MATLAB\Drop1.tif') %call image
ips.show %show image
MIJ.run("8-bit");
MIJ.run("Sharpen");
MIJ.run("Threshold");

I=MIJ.getCurrentImage;
E=imadjust(wiener2(im2double(I(:,:,1))));
MIJ.createImage('result', E, true);

E=imsharpen(E);
bw=imbinarize(E, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4);
bw=bwareaopen(bw,2000);

BWoutline=bwperim(bw);
Segout=im_mat; 
Segout(BWoutline) = 255;
figure;
imshow(Segout)
title('Outlined Original Image');
hold on

s=regionprops(bw,I,{'Centroid','WeightedCentroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation'});
numObj=numel(s);

for k = 1 : numObj
    plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'r*')
    plot(s(k).Centroid(1), s(k).Centroid(2), 'bo')

    xbar = s(k).Centroid(1);
    ybar = s(k).Centroid(2);

    stats = regionprops('table',bw,'Centroid','MajorAxisLength','MinorAxisLength');

    min_len=s(k).MajorAxisLength;
    max_len=s(k).MinorAxisLength;

    diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
    radii_mean = diameters/2;
    radii_minor=stats.MinorAxisLength;
    radii_major=stats.MajorAxisLength;

    centers = stats.Centroid;

    centroids = cat(1,s.Centroid);
end

hold on
viscircles(centers,radii_mean);
viscircles(centers,radii_minor, 'Color', 'b');

hold off

toc;



