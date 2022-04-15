%SPHEROID IMAGING ANALYSIS - V1
%http://bigwww.epfl.ch/sage/soft/mij/ <-- mij.jar and ij.jar packages

clc
clear all

tic;

filename='Drop1.tif';
im_mat=imread(filename); %extract image
image(im_mat); %print original image

javaaddpath 'C:\Program Files\MATLAB\R2022a\java\mij.jar' %extend java classpath to mij.jar
javaaddpath 'C:\Program Files\MATLAB\R2022a\java\ij.jar' %extend java classpath to ij.jar 
MIJ.start; %open ImageJ

IJ=ij.IJ;
ij.ImageJ();
ips=IJ.openImage('C:\Users\dalia\OneDrive\Documents\MATLAB\Drop1.tif') %call image
ips.show; %show image
MIJ.run("8-bit"); %using ImageJ to convert RGB image to 8-bit
MIJ.run("Sharpen"); %using ImageJ to sharpen image
MIJ.run("Threshold"); %%using ImageJ threshold function

I=MIJ.getCurrentImage;
E=imadjust(wiener2(im2double(I(:,:,1))));
MIJ.createImage('result', E, true); %return output from ImageJ to MATLAB space

E=imsharpen(E);
bw=imbinarize(E, 'adaptive','ForegroundPolarity','dark','Sensitivity',0.4); %binarize 8-bit image

bw=imcomplement(bw);
bw=bwareaopen(bw,10000); %filter out small objects that will contribute to noise

BWoutline=bwperim(bw); %edge detection
Segout=im_mat; 
Segout(BWoutline) = 255;
figure;
imshow(Segout)
title('Outlined Original Image');
hold on %overlay outline on original image

bw2=bwpropfilt(bw,'Area', [30000 100000]); %noise filter that is selective based on area 
bw_2=bwareaopen(bw2,3000);

s=regionprops(bw2,I,{'Centroid','WeightedCentroid', 'MajorAxisLength', 'MinorAxisLength', 'Orientation', 'Area', 'Circularity'}); %get data from bw2
sortedAreas = sort([s.Area], 'descend');
[labeledImage, numObj] = bwlabel(bw2); %determine number of objects in bw2

hold on

for k = 1 : numObj
    plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'r*')
    plot(s(k).Centroid(1), s(k).Centroid(2), 'bo')

    xbar = s(k).Centroid(1); %compute centroids
    ybar = s(k).Centroid(2);

    stats = regionprops('table',bw2,'Centroid','MajorAxisLength','MinorAxisLength', 'Area', 'Circularity');

    min_len=s(k).MajorAxisLength;
    max_len=s(k).MinorAxisLength;

    diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
    radii_mean = diameters/2; %compute radii
    radii_minor=stats.MinorAxisLength/2;
    radii_major=stats.MajorAxisLength/2;

    centers = stats.Centroid;

    centroids = cat(1,s.Centroid);
end

viscircles(centers,radii_mean, 'Color', 'b'); %overlay circle with radius of the avg of minor and major axes
viscircles(centers,radii_major, 'Color', 'r'); %overlay circle with radius of major axis
viscircles(centers,radii_minor, 'Color', 'y'); %overlay circle with radius of minor axis

hold off

toc;

filename = 'spheroid_data.xlsx';
writetable(stats,filename,'Sheet','MyNewSheet','WriteVariableNames',false); %write data to excel file




