function [exp,conf,fitindex,DFA_x,DFA_y] = dfa(data,srate,varargin)

% function [exp conf fitindex DFA_x DFA_y] = dfa(data,srate,varargin)
%   determine the DFA scaling exponent for each column of data
%   input:
%   - data: columns of signals
%   - srate: sampling frequency
%   - varargin:
%     o overlap: proportion overlap between adjacent windows (def = .5)
%     o window: [min max] size of the minimum and maximum window size in
%       seconds (def=[1 20])
%     o plot: (0/1) plot the resulting regression (def=0)
%     o fit: ('R2','RMS') return R2 and RMS deviation as
%       fitindex, as well as the regression data points. R2 is 
%       simply the squared correlation, but this value will depend on the
%       value of the DFA exponent found. RMS simply is the standard deviation
%       of the residuals of Y (which in this case are also RMS scores) after
%       regressing out X. Outputs a struct with both values and the data:
%         fit.RMS, fit.R2, fit.DataX fit.DataY
%     o 'noise': matrix of indentically filtered (white) noise signals of
%       the same length as data that will be used to correct the final DFA
%       regression.
%     o 'logbins': Number of windows PER DECADE on the time scale. Actual
%       number of time window for the DFA regression will depend on the
%       <window> parameter as well. Default 10.
%
% output: 
% - exp:   DFA exponents of each of the signals (columns)
% - conf:  
% - fitindex: several fit indices in a struct
% - DFA_x: the size of the time windows (in samples).  Regression is
%          performed on log10(DFA_x).
% - DFA_y: the RMS deviation of the detrended window values of the cumsum
%          of the signal (usually the abs(hilbert()) of a filtered EEG
%          signal). Regression is performed on log10(DFA_y)
%
% BASED ON ORIGINAL SCRIPT PROVIDED BY K.LINKENKAER-HANSEN

overlap = 0.5;
window = [1 20];
doplot=0;
fittype='r2';
noise=[];
logbins=10;
for v=1:2:length(varargin)
    switch lower(varargin{v})
        case 'overlap'
            overlap = varargin{v+1};
        case 'window'
            window = varargin{v+1};
        case 'plot'
            doplot = varargin{v+1};
        case 'fit'
            fittype = varargin{v+1};
        case 'noise'
            noise = varargin{v+1};
        case 'logbins'
            logbins = varargin{v+1};
    end
end
            
if size(data,1) < size(data,2)
    warning('dfa.m: Are the data in columns?')
end

if nargout>2
    fitindex = struct;
end

NSignals = size(data,2);
NSamples = size(data,1);


% preprocessing data
if ~isempty(noise)
    if size(noise,1)~=size(data,1)
        error('Noise and data matrices must have the same number of rows')
    end
    noise = Normalize(noise);
    data = Normalize(data);
end

% Defining window sizes to be log-linearly increasing. d1 and d2 define the
% decades that the window sizes are working in, defined by the lower and
% upper window lengths. Then space out logarithmically the window sizes for
% these decades, always getting the same window sizes. Then select the
% window sizes which fit within the 'window' bounds. This way, the chose
% window sizes depend less on (arbitrary) input parameters.
d1 = floor(log10(window(1)*srate));
d2 = ceil(log10(window(2)*srate));
DFA_x_t = round(logspace(d1,d2,(d2-d1)*logbins));	% creates vector from 10^d1 to 10^d2 with log-equidistant points.
DFA_x = DFA_x_t(DFA_x_t>=window(1)*srate & DFA_x_t<=window(2)*srate);	% Only include log-bins in the time range of interest!

% Initialise
DFA_y = zeros(size(DFA_x,2),NSignals);
N = zeros(1,size(DFA_x,2));
y = zeros(1,size(data,2));

% preprocess input data: detrend signals and take cumsum
b = detrend(data,'constant');
y = cumsum(b);

% loop through window sizes defined in DFA_x
for i = 1:size(DFA_x,2)
    % note that overlap will not be exact!
    NWin = length(1:round(DFA_x(i)*(1-overlap)):NSamples-DFA_x(i)+1);
    StartSamples = round(linspace(1,NSamples-DFA_x(i)+1,NWin));
    D = zeros(NWin,NSignals);		% initialize vector for temporarily storing the root-mean-square of each detrended window.
    
    count = 0;
    for s = StartSamples
        count=count+1;
        D(count,:) = sqrt(mean(fastdetrend(y(s:s+DFA_x(i)-1,:)).^2)); % RMS fluctuation after detrending each column.
    end
    N(i) = count;
    
    %N(i) = length(StartSamples);
    %D = cell2mat(arrayfun(@(x)sqrt(mean(fastdetrend(y(x:x+DFA_x(i),:)).^2))',nn,'uni',0))';
    
    if N(i)>0
        DFA_y(i,:) = mean(D(1:N(i),:));						% the root-mean-square fluctuation of the integrated and detrended time series
    else
        DFA_y(i,1:NSignals) = NaN;
    end
end  					  	       			% -- the F(n) in eq. (1) in Peng et al. 1995.


% first get noise regression data if passed along. This will be used to
% correct the signal regression
if ~isempty(noise)
    [dummy1 dummy2 NoiseFit] = dfa(noise,srate,'overlap',overlap,'window',window,'plot',0,'fit','r2');
end

% initialise exponent output
exp = zeros(1,NSignals);

% initialise the X variable
X = [ones(1,length(DFA_x))' log10(DFA_x')];
for signal=1:NSignals
    if ~isempty(noise)
        Y = log10(DFA_y(:,signal)./mean(NoiseFit.DataY,2));
    else
        Y = log10(DFA_y(:,signal));
    end
    [beta,bint,r,rint,stats] = regress(Y,X);
    exp(signal) = beta(2,1);
    conf(signal) = ((bint(2,2))-(bint(2,1)))/2;		% compute +- 95% confidence intervals
    fitindex.R2(signal) = stats(1);
    fitindex.RMS(signal) = stats(4);
end

% output X and Y regression data
if nargout>2
    fitindex.DataX = log10(DFA_x./srate);
    fitindex.DataY = log10(DFA_y);
end


    
% optional visual output
if doplot
    h = figure;
    hold on
    
    plot(log10(DFA_x./srate),log10(DFA_y),'ko');
    if ~isempty(noise)
        plot(log10(DFA_x./srate),log10(DFA_y./mean(NoiseFit.DataY,2)),'ro');
    end
    lsline

    grid on
    zoom on
    axis([log10(min(DFA_x./srate))-0.1 log10(max(DFA_x/srate))+0.1 min(log10(DFA_y(:)))-0.1 max(log10(DFA_y(:)))+0.1])
    xlabel('log_{10}(time), [Seconds]','Fontsize',12)
    ylabel('log_{10} F(time)','Fontsize',12)
%    title(sprintf('DFA exp=%3.2f',exp(),'fontsize',12)
    axis equal
end

% additional output?
if nargout>=4
    DFA_x = log10(DFA_x);
end
if nargout>=5
    DFA_y = log10(DFA_y);
end


end %function file


% fast detrending

function signal = fastdetrend(signal)
% fast detrending of "signal" is indeed much faster than "detrend"
n = size(signal,1);
if n == 1
    signal = signal(:); % make signal a row vector
end

% set up linear fitting 
N = size(signal,1);
a = [zeros(N,1) ones(N,1)];
a(1:N) = (1:N)'/N;

signal = signal - a*(a\signal); % remove best fit

if (n==1)
    signal = signal.'; % return correct dimensions
end

end % function fastdetrend

