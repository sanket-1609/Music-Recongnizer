S = abs(specgram(D,nfft,targetSR,nfft,nfft-nhop));
F=1:257;
T=1:size(S,2);
figure
imagesc( T, F, log(S) ); %plot the log spectrum
set(gca,'YDir', 'normal'); % flip
hold on;
scatter(maxes2(1,:),maxes2(2,:),'MarkerFaceColor',[0 0 0]);
figure
imagesc( T, F, log(S) ); %plot the log spectrum
set(gca,'YDir', 'normal'); % flip