clearvars
close all;
SNR=0;
LastSongNo=750;
BigList=1;
MaxSongs=1000;
expand=0;
for N=[7 20 30]
    tic
    HH=[];
    hash_t=containers.Map('KeyType','uint32','ValueType','any');
    parfor num=1:LastSongNo
        fileName=strcat('Songs/Song(',num2str(num),').mp3');
        L=find_landmarks(fileName,SNR,N); %<starttime F1 F2 delT>
        %     sctest;
        H=makeHash(L); %<anchortime hash>
        H(:,1)=H(:,1)*MaxSongs+num;  %anchortime++songID
        HH=[HH;H];
    end
    i=1;e=1;
    HH=sortrows(HH,[2 1]);
    hKeys=HH(:,2);
    hValues=HH(:,1); %anchortime++songID
    cKey=hKeys(1);
    while(e<length(hKeys))
        if(cKey~=hKeys(e+1))
            if(isKey(hash_t,cKey))
                hash_t(cKey)=[hash_t(cKey) ;hValues(i:e)];
                expand=expand+1;
            else
                hash_t(cKey)=hValues(i:e);
            end
            i=e+1;
            cKey=hKeys(i);
        end
        e=e+1;
    end
    if(BigList)
    save(strcat('BigHash1_',num2str(LastSongNo),'N',num2str(N),'.mat'),'hash_t');    
    else
    save(strcat('hash1_',num2str(LastSongNo),'N',num2str(N),'.mat'),'hash_t');
    end
    toc
end