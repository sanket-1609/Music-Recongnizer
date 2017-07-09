clearvars
close all;
num=9;
SNR=0;
N=30;
LastSongNo=750;
MaxNoOfMatches=4;
load BigHash1_750N30.mat
fileName=strcat('rec/Recording (',num2str(num),').m4a');
[L,REC,SR]=find_landmarks(fileName,SNR,N); %<starttime F1 F2 delT>
% sctest;
H=makeHash(L); %<anchortime hash>
hKeys=H(:,2);
hashCount=[];
for i=1:length(hKeys)
   if(isKey(hash_t,hKeys(i)))
       temp=hash_t(hKeys(i));
       temp=[floor(temp/1000),mod(temp,1000)];
       temp(:,1)=temp(:,1)-H(i,1);
       hashCount=[hashCount;temp];
   end
end
hashCount=sortrows(hashCount,[2 1]);
count=match(hashCount,LastSongNo,MaxNoOfMatches)
%sound(REC,SR);
return