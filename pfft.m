function [P,fs,AllP] = pfft(Data,Rate,Window,Overlap)

% function [P,fs,AllP] = pfft(Data,Rate,Window)
%
% Calculates the one-sided power density spectrun of signals in columns in
% matrix Data. fs is returned when Rate is defined. Window is 1) the size of
% the FFT window, which will be moved along the signals and averaged or 2)
% the window (e.g. hanning(512)) that will be used and moved along the
% signals and averaged.
% 
% ADDED: normalize the spectrum to window length * sample rate (See matlab
% site
% https://www.mathworks.com/help/signal/ug/power-spectral-density-estimates-using-fft.html
% which matches the output from pwelch.
% 
% output: 
% - P: Power
% - fs: frequencies
% - AllP: PSDs for all FFT windows

cTranspose = 0;
if size(Data,2)>size(Data,1)
    warning('Are data organized correctly in columns? Applying transpose.')
    cTranspose=1;
end
if cTranspose
    N=size(Data,2);
else
    N=size(Data,1);
end    

% check parameters
if nargin<4
    Overlap = .5;
end
if nargin<3
    Window = N;
    if mod(N,2)==1
        error('Only windows with even number of samples')
    end
end
if nargin<2
    Rate = 1;
end

if isscalar(Window)
    Len=Window;
    Window=ones(Len,1);
else
    Len=length(Window);
    if size(Window,1)<size(Window,2)
        Window=Window';
    end
end

fs = linspace(0,Rate./2,Len/2+1);
if ~cTranspose
    P = zeros(length(fs),size(Data,2),size(Data,3));
else
    P = zeros(length(fs),size(Data,1),size(Data,3));
end   
start = floor(linspace(0,N-Len,floor((N/Len-1)/(1-Overlap)+1)))+1;

% start looping across the epohcs. Note that the epochs may be longer than
% the FFT window, therefore, the within epoch PSD may be an average PSD
% along all the windows that fit within it. This is then stores in
% P(:,:,e). The final P will then be an average across those epochs.
% Windows within peoch will start at start samples 'start'
for e=1:size(Data,3)
    Ps = zeros(length(fs),size(Data,2-cTranspose),length(start));
    count=0;
    for s=start
        count=count+1;
        if cTranspose
            Temp = Data(:,s:s+Len-1,e)';
        else
            Temp = Data(s:s+Len-1,:,e);
        end
        F = fft(Temp.*repmat(Window,1,size(Temp,2)));
        Ps(:,:,count) = (abs(F(1:end/2+1,:)).^2)./(Len*Rate);
        Ps(2:end,:,count) = Ps(2:end,:,count).*2;
    end
    P(:,:,e) = mean(Ps,3);
end

% if the input data has a 3rd dimension, P does not need to be averaged
% acrss the 3rd dimenaion. AllP then reflectes the windows WITHIN the
% single epoch. If it DOES have a 3rd dimension, then AllP holds the per
% epoch winodw PSDs
if size(Data,3)==1
    AllP = Ps;
else
    AllP = P;
    P = mean(P,3);
end

if nargout==0
    plot(fs,10*log10(P));
end
