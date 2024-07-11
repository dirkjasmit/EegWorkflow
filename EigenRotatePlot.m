function [rot,scores,eval,evec] = EigenRotatePlot(D, ncomps, method, doplot)

% extract the most important components from data D, rotate, and plot the
% rotated components. NOTE enter the data in D, not the correlation matrix!
% - D: scores or correlation matrix
% - ncomps: number of components to extract
% - method of rotation (varimax)
% - plot result
%
% - output = rotated scores matrix

if nargin<4 || isempty(doplot)
    doplot=false;
end

if nargin<3 || isempty(method)
    method='varimax';
end

if nargin<2 || isempty(ncomps)
    ncomps = 1.0;
end

if size(D,1)==size(D,2)
    % assume corr matrix
    [evec, eval] = pcacov(D); % pcacov wil produce real numbers and ordered large to small
    warning('using data as correlation matrix')
else
    [evec, eval] = pcacov(corr(D,'rows','pairwise')); % pcacov wil produce real numbers and ordered large to small
end
eval = diag(eval);
% disp(eval);
%ndx = sortindex(diag(eval),'descend');
%evec = evec(:,ndx);
%eval = eval(ndx,ndx);
if ncomps==1.0
    ncomps = sum(diag(eval)>=1);
end
if ncomps>1
    L = evec(:,1:ncomps); % *sqrt(eval(1:ncomps,1:ncomps));
    if strcmpi(method,'none')
        rot = L;
    else
        rot = L;
        rot = rotatefactors(L,'method',method,'maxit',1000);
    end
    % rot = rot.*repmat((sum(rot)<0)*-2+1,size(rot,1),1);
else
    rot = evec(:,1:ncomps)*sqrt(eval(1:ncomps,1:ncomps));
end

if doplot
    figure('pos',[265         161        1200         700]);
    subplot(2,3,1:3)
    plot(rot,'linewidth',1.2);
    subplot(2,3,4)
    plot(diag(eval(1:ncomps,1:ncomps))/sum(diag(eval))*100,'-ok')
    ylabel('% var.')
    subplot(2,3,5:6)
    imagesc(rot);
    %set(gca,'xtick',1:size(rot,2),'xticklabel',strsplit(sprintf('%.2f\n',diag(eval(1:ncomps,1:ncomps))),'\n'))
end

if nargout>1
    scores=D*rot;
end


