clear all
clc

run_tracker;
precisions1 = show_precision(positions, ground_truth, '');

run_tracker_1;
precisions2 = show_precision(positions, ground_truth, '');

f = fopen('C:\Users\rams1\Desktop\Spring2016\CV\Projects\Project_3\Videos\tiger1\tiger1_MIL_TR001.txt');
f = textscan(f,'%f,%f,%f,%f'); fpos = [f{1} f{2}]; hw = [f{3} f{4}];
fpos = fpos + 2*hw;
precisions3 = show_precision(fpos, ground_truth, '');

figure(4);
plot(1:length(precisions1),precisions1,'r',1:length(precisions2),precisions2,'b',1:length(precisions3),precisions3,'g','LineWidth',2);
legend('Kalman predicted','CM','MIL');