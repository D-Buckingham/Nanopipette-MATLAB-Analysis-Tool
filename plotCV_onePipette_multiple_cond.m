% For one pipette, these plots can be zoomed in, filtered of the noise and
% smoothed. It compares different conditions and labels the values at 0.5 V in a CV plot
%@Denis Buckingham
clear
clc
%% Pipette folder path
pipPath = uigetdir("C:\Users\denis\Documents\Bachelor Thesis\Data\");
pipName = strsplit(pipPath," ");
pipName = strcat(pipName{3:end});%set the number to the n'th property which is your Data folder
    
condDir = dir(fullfile(pipPath));
condDir = condDir(3:end); % Because of dots
[condNum, ~] = size(condDir);
%
%% Start
prompt = ["How many conditions?","Do you want to filter the data? (0/1)","Do you want to zoom in (0/1/2)?"];
dlg_title = "Conditions, Filter, Zoom?";
num_lines = 1;
input = inputdlg(prompt,dlg_title,num_lines);
cond = str2double(input(1));
filter = str2double(input(2));
zoom = str2double(input(3));

%%
minimumcond = zeros(cond,1);
for i = 1:cond%iterate through the conditions like PBS etc
    condPath = strcat(condDir(i).folder,'\',condDir(i).name,'\CV');
    % Out: CV folder path of the condition
    %% Current files
    % Sorting
    aPath = dir(fullfile(condPath,"*Current1 (A).tsv*"));
    StringCvs = 1:size(aPath);
    aPath = aPath(StringCvs);
    vPath = dir(fullfile(condPath,"*V1 (V).tsv*"));
    vPath = vPath(StringCvs);
    %%    
    meanAll1 = cell(length(StringCvs),1);%cell struct with all cvs inside, meanAll(numberofcvs,a or v)

    for k = StringCvs%for each of conditions cv do:
        a = importdata(strcat(condPath,"\",aPath(k).name));
        v = importdata(strcat(condPath,"\",vPath(k).name));
        
        %resample the nonuniformly data
        [a,v] = resample(a,v,15500);
        meanAll1{k,1} = a;%all data of a inside meanAll
    end
    minimumcond(i) = min(cellfun('size',meanAll1,2));
end
minimax=max(minimumcond);

%%
figure;
%
%%
for i = 1:cond%iterate through the conditions like PBS etc
    condPath = strcat(condDir(i).folder,'\',condDir(i).name,'\CV');
    % Out: CV folder path of the condition
    pipName = strsplit(condPath, "\");
    pipName =[pipName{7} '           ' pipName{8}];%last three names of path as title

    %% Current files
    % Sorting
    aPath = dir(fullfile(condPath,"*Current1 (A).tsv*"));
    
    StringCvs = 1:size(aPath);
    
    cv = zeros(max(size(aPath)),1);
    
    for j = StringCvs
        str = strsplit(aPath(j).name,"_");
        cv(j) = str2double(str{2});
    end
    
    [~,idx] = sort(cv);%getting rid of unnecessary cv and sort
    aPath = aPath(idx);
    % Out: aPath which is a cell struct with name, folder, date, bytes and
    % size
    %% Voltage files
    vPath = dir(fullfile(condPath,"*V1 (V).tsv*"));
    vPath = vPath(idx);
    % Out: vPath, same attributes as aPath
    %%    
    meanAll = cell((length(StringCvs)-1),2);%cell struct with all cvs inside, meanAll(numberofcvs,a or v)
    
    for k = StringCvs%for each of conditions cv do:
        a = importdata(strcat(condPath,"\",aPath(k).name));
        a = a*10^9;
        if filter==1   
            filtmed = medfilt1(a,35);%erasing the high peaks which have a too large impact on a weigthed filter
            a = sgolayfilt(filtmed,1,15);%this smoothes out the curve (interpolation)
        end        
        v = importdata(strcat(condPath,"\",vPath(k).name));
        %resample the nonuniformly data

        [a,v] = resample(a,v,15500);
        
        if length(v) == minimax
            meanV=v;
        end
        meanAll{k,1} = a;%all data of a inside meanAll
        meanAll{k,2} = v;
    end
    %
    %%
    %TODO in meanAll all have to start with the same voltage value. Else it
    %isn't the right mean value
    meanSum = cell(1,1);
    meanSum{1,1} = zeros(1,1);
    
    for m = 1:(length(StringCvs))%iterate through all cvs, but without the first, since it is often unstable, variance is too high
        tempA = meanAll{m,1};
        meanSum{1,1} = meanSum{1,1} + tempA(1:(minimax(1)));%minimum of size of one cell in meanAll
    end
    
    meanA = meanSum{1,1} / (length(StringCvs));
       
    lengthA = length(meanA);
    %Now we want to shift the curves so that all go through the origin
    %First find the number of shifts which have to be done
     originAarray = find(abs(meanA) < 0.0005);
     for n = originAarray
         if n < 10000
             originA = n;
         end
     end
   
     originVarray = find(abs(meanV) < 0.001);
     for m = originVarray
         if m < 10000
             originV = m;
         end
     end
     
     shift = originV-originA;
     MatrixA = zeros(1,lengthA);
         
     if shift < 0
         MatrixA(1:lengthA+shift) = meanA(1-shift:end);
         meanA = MatrixA;
     else
         MatrixA(shift+1:end) = meanA(1:end-shift);
         meanA = MatrixA;
     end
     
    %we want from 0V - 0.5V
    maxarr=find((abs(meanV-0.49) < 0.0005));%TODO adjust the boundary of your CV
    for k=maxarr
        if k>4000
            maxi=k;
        end
    end
    maxA = meanA(maxi);

    if zoom==1
        firstarr=find((abs(meanV-0.0005) < 0.0005));
        first=firstarr(1);
        last=firstarr(end);
        meanA = meanA(first:end);
        meanV = meanV(first:end);
    end
    
    hold on;
    plot(meanV,meanA,"LineWidth",1);
    if zoom == 2
        xlim([0.3 1])
    end

    %%
    condDir(i).name
    %
    data{3*i,1} = condDir(i).name;
    data{3*i+1,1} = meanV;
    data{3*i +2,1} = meanA;
end

filename=uiputfile({'*.csv';'*.xlsx'},'Save as');
datatemps = cell2table(data);
writetable(datatemps,filename);

set(gcf,"Name","Means","NumberTitle","off");
xlabel("Voltage [V]");
ylabel("Current [nA]");
title(pipName);
legend(condDir.name,"Location","southeast","Fontsize",14);
box on;
