function [Data_filtered] = filter_fir(Data, fs, hp, lp, fir_order, zerophase, stopband, plotresponse)
%
% Modified klaus.linkenkaer@cncr.vu.nl, 070904.
% Modified d.j.a.smit@vu.nl 080505 (fir_order calculation)
% Modified d.j.a.smit@vu.nl 080505 (data arrangement: into rows)
% Modified d.j.smit@amc.nl 130616 zerophase
% Modified d.j.smit@amc.nl 031116 stopband
%
%
%******************************************************************************************************************
% Purpose...
%
% Zero-phase finite impulse response bandpass filter the signal 'F' with a Hamming window.
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

if nargin < 5 
    fir_order = 3.0;
end

% detect third dimension
if isnumeric(Data) && size(Data,3)>1
    % handle the 3rd dimension but recursively calling
    X = nan(size(Data));
    for e=1:size(Data,3)
        X(:,:,e) = filter_fir(Data(:,:,e),fs, hp, lp, fir_order, zerophase, stopband, ifthen(e==1,plotresponse,false));
    end
    Data_filtered = X; 

% detect EEG struct and loop through segments if so (*recursive call)
elseif isstruct(Data) && isfield(Data,'nbchan')
    % data is a EEGLAB structure, check whether this is epochs data
    if size(Data.data,3)>1
        % handle the 3rd dimension but recursively calling
        X = nan(size(Data.data));
        for e=1:size(Data.data,3)
            X(:,:,e) = filter_fir(Data.data(:,:,e),fs, hp, lp, fir_order, zerophase, stopband, ifthen(e==1,plotresponse,false));
        end
        Data_filtered = Data;   % return the EEG struct
        Data_filtered.data = X; % but replace with filtered data
    else
        % Do the same as for epoched data, except that you now pass
        % stretches between boundary events. So check for boundary events
        % and filter between these. 
        if ~isfield(Data,'event') || isempty(Data.event)
            % treat data as single epoch if there are no boundaries
            ndx = [];
            cut = [1 size(Data.data,2)]; % only works for 2D data!
        else
            % events available: collect boundary latencies
            ndx = strcmpi({Data.event.type},'boundary');
            cut = round([1 Data.event(ndx).latency Data.pnts+1]);
        end

        % loop thru segment(s)
        X = [];
        for c=1:length(cut)-1
            X = [X filter_fir(Data.data(:,cut(c):cut(c+1)-1),fs, hp, lp, fir_order, zerophase, stopband, ifthen(c==1,plotresponse,false))];
        end
        Data_filtered = Data;   % return the EEG struct
        Data_filtered.data = X; % but replace with filtered data
    end
else

    % Define filter characteristics:
    if isempty(hp) || hp==0
        b = fir1(round(fir_order*fix(fs/lp)),lp/(fs/2),'low');
        if stopband
            warning('Stopband defined without hp defined. Ingnoring stopband.')
        end
    elseif isempty(lp) || lp==0
        b = fir1(round(fir_order*fix(fs/hp)),hp/(fs/2),'high');
        if stopband
            warning('Stopband defined without lp defined. Ingnoring stopband.')
        end
    elseif ~stopband
        b = fir1(round(fir_order*fix(fs/hp)),[hp lp]/(fs/2));
    else
        b = fir1(round(fir_order*fix(fs/hp)),[hp lp]/(fs/2), 'stop');
    end
    
    if plotresponse
        figure;
        freqz(b,1);
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
        Data_filtered = filtfilt(b,1,Data')';
    else
        Data_filtered = filter(b,1,Data')';
    end

    if doconvert
        % convert back to single
        Data_filtered = single(Data_filtered);
    end
end
