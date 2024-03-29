# EegWorkflow
MATLAB/EEGLAB-based workflow for (automated) preprocessing of EEG data. Currently imports:
- EEGLAB .set
- ANT .cnt
- Brainvison analyzer
- Neuroscan .cnt files
- Biosemi BDF (NEW uses biosig toolbox, which correctly reads events)

Tested on Mac OS and Linux, not windows. MATLAB GUIs are notoriously sensitive to screen settings, so
you might have to adjust this to get visible buttons.

NEW: there are now yellow font size buttons that increase decrease font size.

INSTALLATION
- Install EEGLAB version 2020_0 (see https://github.com/sccn/eeglab)
- Run, and install the following plugins from the 'file -- manage extensions' menu (Note: if you are behind a firewall you may need to visit https://sccn.ucsd.edu/wiki/EEGLAB_Extensions to download and instructions how to install the plugins manually.)
  - clean rawdata
  - ICLabel
  - AAR
  - ANTImport (when reading ANT files)
  - biosig
- Download the EegWorkflow and unzip into a folder. 
- Start by:
   - add eeglab_2020_0 to the path (The EegWorkflow will popup a window if it can't be located)
   - running EegAutoflow.m or open EegAutoflow.fig

FOR SAVING FILES: Edit the '.projectStrings.ini' file in the current directory and add your own project names. This allows you to specfiy the output file prefix.
Do not touch the first line! This is the header.
  
REQUIRED
Requires the signal processing toolbox (required by EEGLAB)



