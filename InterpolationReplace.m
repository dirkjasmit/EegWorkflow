function [NewEEG] = InterpolationReplace(EEGIn, UseParallel)

% InterpolationCleaning replaces ALL channels with its interpolated variant.
%
% Requires channel information in EEG struct!
%
% Input: EEG struct (EEGLAB)
% Output: EEG struct (EEGLAB)

if nargin<2
    UseParallel = false;
end

NewEEG = EEGIn; % preallocation, to be overwritten

% impute each channel using all other channels
if UseParallel
    Temp = {};
    parfor ch=1:EEGIn.nbchan
        Temp{ch} = pop_interp(EEGIn,ch,'spherical');
    end
    for ch=1:EEGIn.nbchan
        try
            NewEEG.data(ch,:) = Temp{ch}.data(ch,:);
        catch E
            warning('Interpolation failed, using the original data')
            NewEEG.data(ch,:) = RealData(ch,:);
        end
    end

else
    for ch=1:EEGIn.nbchan
        if ~isempty(EEGIn.chanlocs(ch).X)
            Temp = pop_interp(EEGIn,ch,'spherical');
            NewEEG.data(ch,:) = Temp.data(ch,:);
        else % use statistical interpolation
            warning('No location data for channel. Using statistical approach')
            [~,b] = EigenRotatePlot(EEGIn.data(setdiff(1:EEGIn.nbchan,ch),:)',10,'varimax',false);
            pp = fitlm(b,EEGIn.data(ch,:)');
            NewEEG.data(ch,:) = predict(pp);
        end
    end
end

    
