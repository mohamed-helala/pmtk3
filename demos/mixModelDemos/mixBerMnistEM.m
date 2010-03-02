%% Bernoulli mixture model for mnist digits

%% Setup data
setSeed(0);
binary     = true;
keepSparse = false; 
Ntest      = 1000;

if 1
    Ntrain  = 5000;
    Kvalues = [2, 10]; 
else
    Ntrain  = 1000;
    Kvalues = 2:15;
end
[Xtrain, Xtest] = setupMnist('binary', binary, 'ntrain', Ntrain,'ntest', Ntest,'keepSparse', keepSparse);
Xtrain = Xtrain + 1; % convert from 0:1 to 1:2
Xtest  = Xtest  + 1; 
%% Fit
[n, d] = size(Xtrain); 
NK     = length(Kvalues);
logp   = zeros(1, NK);
bicVal = zeros(1, NK);
options = {[], [], 'maxiter', 10, 'verbose', true};
model = cell(1, NK); 
for i=1:NK
    K = Kvalues(i);
    fprintf('Fitting K = %d \n', K)
    model{i}  = mixDiscreteFitEM(Xtrain, K, options{:});
    logp(i)   = sum(mixDiscreteLogprob(model{i}, Xtest));
    nParams   = K*d + K-1;
    bicVal(i) = -2*logp(i) + nParams*log(n);
end
%% Plot
for i=1:NK
    K = Kvalues(i);
    figure();
    [ynum, xnum] = nsubplots(K);
    if K==10
        ynum = 2; xnum = 5;
    end
    TK = model{i}.T; 
    mixweightK = model{i}.mixweight;
    for j=1:K
        subplot(ynum, xnum, j);
        imagesc(reshape(TK(2, :, j), 28, 28)); 
        colormap('gray');
        title(sprintf('%1.2f', mixweightK(j)));
        axis off
    end
    printPmtkFigure(sprintf('MnistMix%dBernoullis', K));
end
if numel(Kvalues) > 2
    figure(); 
    plot(Kvalues, bicVal, '-o', 'LineWidth', 2, 'MarkerSize', 8);
    title(sprintf('Minimum achieved for K = %d', Kvalues(minidx(bicVal))));
    printPmtkFigure('MnistBICvsKplot');
end