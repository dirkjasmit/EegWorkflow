function [Data_filtered, H, F] = filter_butter(Data, fs, hp, lp, butter_order, zerophase, stopband, plotresponse)
%
% Modified klaus.linkenkaer@cncr.vu.nl, 070904.
% Modified d.j.a.smit@vu.nl 080505 (fir_order calculation)
% Modified d.j.a.smit@vu.nl 080505 (data arrangement: into rows)
% Modified d.j.smit@amc.nl 130616 zerophase
% Modified d.j.smit@amc.nl 031116 stopband
% Modified d.j.smit@amc.nl 031116 possibility to pass EEG struct. Filter
% between boundary events.
% Modified d.j.smit@amc.nl 031116 butterworth filter
%
%
%******************************************************************************************************************
% Purpose...
%
% Zero-phase (or causal) IIR butterworth filter
%
%
%******************************************************************************************************************
% Input parameters...
%
% Data		: data matrix (or vector), time along the 2nd dimension!
% fs		: sampling frequency.
% hp		: highpass corner (e.g., 8 Hz).
% lp		: lowpass corner (e.g., 13 Hz).
% fir_order	: (changed DS) filter order in number of cycles of the sinus corresponding to 
%             the hp parameter (default 3.0).
% zerophase : (changed DS) use filtfilt if true (now default) rather than single-pass filter
% stopband  : (changed DS) invert filter (default false)
% plotresponse : (changed DS) plot the frequency and phase response
%
%******************************************************************************************************************
% Default parameters (can be changed)...

% time window included in the filtering process. 
% Filter orders suitable for alpha and beta oscillations and based on:
% Nikulin. 2005. Neurosci. Long-range temporal correlations in EEG oscillations...
if nargin<8
    plotresponse = false;
end
if nargin<7
    stopband = false;
end
if nargin<6
    zerophase = true;
end

if nargin < 5 || isempty(butter_order)
    butter_order = 3;
end

% detect EEG struct and loop through segments if so (*recursive call)
if isstruct(Data) && isfield(Data,'nbchan')
    % either use boundary events to cut the data into chunks (continuous
    % data) or use the third dimansion
    if Data.trials==1
        ndx = strcmpi({Data.event.type},'boundary');
        cut = round([1 Data.event(ndx).latency Data.pnts+1]);
        X = [];
        for c=1:length(cut)-1
            X = [X filter_butter(Data.data(:,cut(c):cut(c+1)-1),fs, hp, lp, butter_order, zerophase, stopband, ifthen(c==1,plotresponse,false))];
        end
        Data_filtered = Data;
        Data_filtered.data = X;
    else
        % loop thru 3rd dimension
        X = [];
        for c=1:size(Data.data,3)
            X = cat(3,X,filter_butter(Data.data(:,:,c),fs, hp, lp, butter_order, zerophase, stopband, ifthen(c==1,plotresponse,false)));
        end
        Data_filtered = Data;
        Data_filtered.data = X;
    end
        
else

    % Define filter characteristics:
    if isempty(hp) || hp==0
        d = designfilt('lowpassiir', 'FilterOrder', butter_order, ...
               'HalfPowerFrequency1', 1,  ...
               'SampleRate', fs, 'DesignMethod', 'butter');
        % [z,p,k] = butter(butter_order, lp/(fs/2), 'low');
        if stopband
            warning('Stopband defined without hp defined. Ignoring stopband.')
        end
    elseif isempty(lp) || lp==0
        d = designfilt('highpassiir', 'FilterOrder', butter_order, ...
               'HalfPowerFrequency1', 1,  ...
               'SampleRate', fs, 'DesignMethod', 'butter');
        %[z,p,k] = butter(butter_order, hp/(fs/2), 'high');
        if stopband
            warning('Stopband defined without lp defined. Ignoring stopband.')
        end
    elseif ~stopband
%        d = designfilt('bandpassiir','designmethod','butter','passbandfrequency',[hp lp],'samplerate',fs,'filterorder',butter_order);
%        d = designfilt('bandpassiir', 'FilterOrder', butter_order, ...
%               'PassbandFrequency1', 1,  'PassbandFrequency2', 45,...
%               'SampleRate', fs, 'DesignMethod', 'butter');
        d = designfilt('bandpassiir', 'FilterOrder', butter_order, ...
               'HalfPowerFrequency1', hp, 'HalfPowerFrequency2', lp, ...
               'SampleRate', fs, 'DesignMethod', 'butter');
        %[z,p,k] = butter(butter_order, [hp lp]/(fs/2));
    else
        d = designfilt('bandstopiir', 'FilterOrder', butter_order, ...
               'HalfPowerFrequency1', 1, 'HalfPowerFrequency2', 45, ...
               'SampleRate', fs, 'DesignMethod', 'butter');
        % [z,p,k] = butter(butter_order, [hp lp]/(fs/2), 'stop');
    end
    
    if plotresponse 
        fvtool(d);
    end
    if nargout>1
        [H,F] = impz(d);
    end

    % convert type if necessary
    if isa(Data,'single')
        doconvert = true;
        Data = double(Data);
    else
        doconvert = false;
    end

    % Apply filter:
    if zerophase
        Data_filtered = filtfilt(d,Data')';
    else
        Data_filtered = filter(d,Data')';
    end

    if doconvert
        % convert back to single
        Data_filtered = single(Data_filtered);
    end
end



