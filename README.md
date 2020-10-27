# EegWorkflow
MATLAB/EEGLAB-based workflow for (automated) preprocessing of EEG data. Currently imports:
- EEGLAB .set
- ANT .cnt
- Brainvison analyzer
- Neuroscan .cnt files

Tested on Mac OS and Linux, not windows. MATLAB GUIs are notoriously sensitive to screen settings, so
you might have to adjust this to get visible buttons.

INSTALLATION
- Install EEGLAB version 2020_0 (see https://github.com/sccn/eeglab)
- Run, and install the following plugins from the 'file -- manage extensions' menu
  - clean rawdata
  - ICLabel
  - AAR
  - ANTImport (when reading ANT files)
- Download the EegWorkflow unzip into a folder. 
- Start by:
  - running EegAutoflow.m
  - adding eeglab_2020_0 to the path (The EegWorkflow will popup a window for this)
  - click 'change folder' if it pops up
  
REQUIRED
Requires the signal processing toolbox

