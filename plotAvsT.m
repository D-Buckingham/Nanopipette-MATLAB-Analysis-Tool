%It plots the avst data from the nanopipettes, by searching for the directory avst of a pipette measurement. Then it takes the last three names of the directories as title. Go to directory avst, which you want to display
%@Denis Buckingham
clear;
clc;

atPath = uigetdir("C:\Users\denis\Documents\Bachelor Thesis\Data\");
pipName = strsplit(atPath, "\");


prompt = "Which conditions (title)?";
conditions = input(prompt,'s');


pipName =[pipName{7} '             ' pipName{8} '             ' conditions];%last three names of path as title

aPath = dir(fullfile(atPath,"*Current1 (A).tsv*"));
tPath = dir(fullfile(atPath,"*dt(s).tsv*"));

a = importdata(strcat(atPath,"\",aPath.name));
a = a*10^9;

t = importdata(strcat(atPath,"\",tPath.name));
l = size(t,2);
t = t.*(0:1:(l-1));

z = highpass(a,1,(10000/26));
a = a - z;
a = sgolayfilt(a,1,501);%filtering and smoothing

data(:,2) = a;
data(:,3) = t;
filename=uiputfile({'*.csv';'*.xlsx'},'Save as');
datatemps = array2table(data);

writetable(datatemps,filename);

figure;
x0=0;
y0=80;
width=2000;
height=400;
set(gcf,'position',[x0,y0,width,height])
plot(t,a);
xlabel("Time [s]");
ylabel("Current [nA]");
title(pipName);