function [L,dirtyD,dirtyFs] = find_landmarks(D,SNR,N)
if nargin < 2, SNR = 0; end  
if nargin < 3, N = 7; end %avg no of points per sec
FACTOR=1;
f_sd = 30; % spread width of mask skirt
THOP = 0.02322;
a_dec = 1-0.01*(N*sqrt(THOP/0.032)/35);
maxpksperframe = 5; %max no of peaks allowed per frame --maybe useless as most peaks are below mask skirt
hpf_pole = 0.98; %high pass filter for log spectrogram
targetdf = 31;  %make region for making pairs (frequency/vertical)
targetdt = 63;  %make region for making pairs (time/horizontal)
verbose = 1;
targetSR = 11025;
if ischar(D) %if D is file name
  fname = D;
  [D,SR] = audioread(fname);
else
  fname = '<waveform>';
end

[nr,nc] = size(D);
if nr > nc
  D = D';
  [nr,nc] = size(D);
end
if nr > 1
  D = mean(D); %make it mono
  nr = 1;
end
D=D(1:length(D)/FACTOR);
[nr,nc] = size(D);
if length(D) == 0 %empty sounds
  L = [];
  S = [];
  T = [];
  maxes = [];
  return
end
if (SNR~=0)
    D=awgn(D,SNR);
    disp(['GAUSSIAN NOISE ADDED- ',num2str(SNR),'dB']);
end
dirtyD=D;
dirtyFs=SR;
if (SR ~= targetSR) 
  D = resample(D,targetSR,SR); %downsample to avoid aliasing
end
fft_ms = (512/(targetSR/1000));  % 46.4 ms for 11025 Hz
% makes nfft = 512 (good for calc) 
fft_hop = 1000*THOP;
nfft = round(targetSR/1000*fft_ms);
nhop = round(targetSR/1000*fft_hop);
thop = nhop / targetSR;
S = abs(specgram(D,nfft,targetSR,nfft,nfft-nhop));
Smax = max(S(:)); %maximum of all values
S = log(max(Smax/1e6,S)); % get only values bigger than Smax/1e6 and put other to Smax/1e6
S = S - mean(S(:)); %mean shift it
S = (filter([1 -1],[1 -hpf_pole],S')'); %filter slow variations and focus on onsets
maxespersec = 30; %how many maxes to keep per sec for preallocation
ddur = length(D)/targetSR;
nmaxkeep = round(maxespersec * ddur);
maxes = zeros(3,nmaxkeep);
nmaxes = 0;
maxix = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local peaks , store as maxes(i,:) = [t,f,val]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sthresh = spread(max(S(:,1:min(10,size(S,2))),[],2),f_sd)'; % initial threshold envelope based on peaks in first 10 frames
T = 0*S;

for i = 1:size(S,2)-1
  if any( S(:,i) > sthresh ) %around 80% frames stop
    s_this = S(:,i);
    sdiff = max(0,(s_this - sthresh))';
    dsdiff = diff([0,sdiff,0]); %difference between adjacent elements
    locs = find((dsdiff(1:end-1) > 0) & (dsdiff(2:end)<=0)); %loc max
    pks = sdiff(locs); 
    [vv,xx] = sort(pks,'descend');
    %store  peaks and update decay envelope
    nmaxthistime = 0;
    for j = 1:length(xx)
      p = locs(xx(j));
      if nmaxthistime < maxpksperframe
        if s_this(p) > sthresh(p) %extra check????
          nmaxthistime = nmaxthistime + 1;
          nmaxes = nmaxes + 1;
          maxes(2,nmaxes) = p;
          maxes(1,nmaxes) = i;
          maxes(3,nmaxes) = s_this(p);
          eww = exp(-0.5*(([1:length(sthresh)]'- p)/f_sd).^2);
          sthresh = max(sthresh, s_this(p)*eww); %update threshold envelope
        end
      end
    end
  end
  T(:,i) = sthresh; %useless only for debuging
  sthresh = a_dec*sthresh;
end

%same process in reverse(back pruning)
maxes2 = [];
nmaxes2 = 0;
whichmax = nmaxes;
sthresh = spread(S(:,end),f_sd)';
for i = (size(S,2)-1):-1:1
  while whichmax > 0 && maxes(1,whichmax) == i
    p = maxes(2,whichmax);
    v = maxes(3,whichmax);
    if  v >= sthresh(p)  % check
      nmaxes2 = nmaxes2 + 1;
      maxes2(:,nmaxes2) = [i;p];
      eww = exp(-0.5*(([1:length(sthresh)]'- p)/f_sd).^2);
      sthresh = max(sthresh, v*eww);
    end
    whichmax = whichmax - 1;
  end
  sthresh = a_dec*sthresh;
end

%Make landmark pairs <starttime F1 F2 delT>
maxes2 = fliplr(maxes2);
maxpairsperpeak=3; %max pairs from each peak
L = zeros(nmaxes2*maxpairsperpeak,4);
nlmarks = 0;
for i =1:nmaxes2
  startt = maxes2(1,i);
  F1 = maxes2(2,i);
  maxt = startt + targetdt;
  minf = F1 - targetdf;
  maxf = F1 + targetdf;
  matchmaxs = find((maxes2(1,:)>startt)&(maxes2(1,:)<maxt)&(maxes2(2,:)>minf)&(maxes2(2,:)<maxf));
  if length(matchmaxs) > maxpairsperpeak
    matchmaxs = matchmaxs(1:maxpairsperpeak);
  end
  for match = matchmaxs
    nlmarks = nlmarks+1;
    L(nlmarks,1) = round(startt);
    L(nlmarks,2) = F1;
    L(nlmarks,3) = maxes2(2,match);
    L(nlmarks,4) = round( (maxes2(1,match)-startt));
  end
end
L = L(1:nlmarks,:); %remove zeroes
if verbose
  disp([fname,' find_landmarks: ',num2str(length(D)/targetSR),' secs, ',...
      num2str(size(S,2)),' cols, ', ...
      num2str(nmaxes),' maxes, ', ...
      num2str(nmaxes2),' bwd-pruned maxes, ', ...
      num2str(nlmarks),' lmarks']);
  %sctest
end