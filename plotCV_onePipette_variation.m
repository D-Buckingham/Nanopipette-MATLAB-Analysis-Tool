% For one pipette, CV plot of a condition, Name file CV and nothing else
%There is a build in filter which erases the spikes which are over a
%certain treshold and then smoothes the curve. Here you can see the
%variance of each contidion (like PBS, a concentration etc.)
clear;
clc;
%% Pipette folder path
pipPath = uigetdir("C:\Users\denis\Documents\Bachelor Thesis\Data");
pipName = strsplit(pipPath," ");
pipName = strcat(pipName{3:end});

condDir = dir(fullfile(pipPath));
condDir = condDir(3:end); % Because of dots
[condNum, ~] = size(condDir);

%
%% Start
prompt = "Condition?";
dlg_title = "Experiment";
num_lines = 1;
cond = str2double(inputdlg(prompt,dlg_title,num_lines));


for i = cond
    condPath = strcat(condDir(i).folder,'\',condDir(i).name,'\CV');
    pipName = strsplit(condPath, "\");
    pipName =[pipName{7} '           ' pipName{8} '           ' pipName{9}];%last three names of path as title

    % Out: CV folder path of the condition
    %% Current files
    % Sorting
    aPath = dir(fullfile(condPath,"*Current1 (A).tsv*"));
    
    s = 1:size(aPath);
    
    cv = zeros(max(size(aPath)),1);
    
    for j = s
        str = strsplit(aPath(j).name,"_");
        cv(j) = str2double(str{2});
    end
    
    [~, idx] = sort(cv);
    aPath = aPath(idx);
    % Out: aPath
    %% Voltage files
    vPath = dir(fullfile(condPath,"*V1 (V).tsv*"));
    vPath = vPath(idx);
    % Out: vPath
    %%    
    figure;

   
    for k =s%just take the promising CV's and then filter them before displaying
        a = importdata(strcat(condPath,"\",aPath(k).name));
        a = a*10^9;
        v = importdata(strcat(condPath,"\",vPath(k).name));
        
        filtmed = medfilt1(a,35);%erasing the high peaks which have a too large impact on a weigthed filter
        a = sgolayfilt(filtmed,1,15);%this smoothes out the curve (interpolation)

        %Consider the electrostatic discharge over the CV's
        originAarray = find(abs(a) < 0.001);
        for n = originAarray
            if n < 5000
                originA = n;
            end
        end
      
        originVarray = find(abs(v) < 0.001);
        for m = originVarray
            if m < 5000
                originV = m;
            end
        end
     
        shift = originV-originA;
        MatrixA = zeros(1,length(a));
         
        if shift < 0
            MatrixA(1:length(a)+shift) = a(1-shift:end);
            a = MatrixA;
        else
            MatrixA(shift+1:end) = a(1:end-shift);
            a = MatrixA;
        end
  
        
        vectorvoltage{k} = find((abs(v-0.49) < 0.005));
        vectorfirstvolt(k) = vectorvoltage{k}(1);
        vectorcurrent(k) = a(vectorfirstvolt(k));
        plot(v,a);
        hold on;
    end
    
    
    mean = mean(vectorcurrent)
    differencePBS =  1.67484 - mean
    standardErrorOfMean = std(vectorcurrent)/(sqrt(length(vectorcurrent)))
    xlabel("Voltage [V]");
    ylabel("Current [nA]");
    title(pipName);
    legend(strsplit(num2str(s)),"Location","southeast");
    box on;
    grid on;
    condDir(i).name
end