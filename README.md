# Plotting Data of Nanopipette Measurements

In this project you find some useful tools to display CV (current versus voltage) and real time measurements (current versus time) plots.  
With these MATLAB codes you can select multiple conditions, which you measured, and display them in one plot, analyze the variation of your measurement of one condition and display the changes of the current over time.  

## Getting Started

Please follow these instructions to get the working tools.

### Prerequisites

Use MATLAB Simulink 2018b or later since some of the commands aren't supported for ealier versions.  
Install the Signal Processing Toolbox from https://ch.mathworks.com/de/products/signal.html  
It will automatically ask you if you want to download it as soon as you have run the codes. (This is needed for the AVST plots)

### Installation

1) Download the package to a local folder by running:
```
git clone https://gitlab.ethz.ch/denisb/nanopipette.git
```

2) Run Matlab and navigate to the folder

3) Enjoy!

## How to use

Your datapath should look like C:\Users\you\Date of your pipette\Name of your pipette.  
In the folder "Name of your pipette" you store all your conditions as folders like PBS, Concentrations etc. In these folders you store the AVST and CV folder.  
eg. C:\Users\you\Date of your pipette\Name of your pipette\DA 10uM\CV or C:\Users\you\Date of your pipette\Name of your pipette\DA 10uM\avst  
Now the code will recognize your folder and label the plots correctly.  
You can change the datapath in the first lines of the codes to yours since you won't have to choose the datapath each time when you run the codes.

### plotCV_onePipette_multiple_cond

First you will be asked to choose your datapath to the pipette you want to plot. After choosing your pipette there are three options:  
1)Choose the number of conditions you want to display  
2)Choose if you want to filter the data. This gets rid of some noise and artefacts and then smoothes the curve.
3)Choose if you want to zoom into the plot. Here the right half will be displayed.

### plotAvsT

Choose in the datapath the avst directory you want to display. The data will be automatically filtered.

### plotCV_onePipette_variation

Go to the pipette directory and then you have the option to choose which condition you want to plot. Here a numerical value is being asked.  
The advantage of this plot is, that you can see how strong your measurements variate from each other.

## Feedback

If you find any bug or have any suggestion, please do file issues. I am graceful for any feedback and will do my best to improve this package.

## Contact

denisb@ethz.ch
