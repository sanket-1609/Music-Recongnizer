function H = makeHash(L)
F1bits = 8; %F1
DFbits = 6; %del F
DTbits = 6; %del T
H = uint32(L(:,1)); %initialize with starttimes
F1 = mod(round(L(:,2)-1),2^F1bits); %0-255 not 1-256
DF = round(L(:,3)-L(:,2));
if DF < 0 %make sure none are -ve
  DF = DF + 2^DFbits;
end
DF = mod(DF,2^DFbits);
DT = mod(abs(round(L(:,4))), 2^DTbits);
H = [H,uint32(F1*(2^(DFbits+DTbits))+DF*(2^DTbits)+DT)];%<starttime hash>
end

