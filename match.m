function count  = match( hashCount, LastSongNo, MaxNoOfMatches) %make sure hashcount is sorted by both columns
count=[1:LastSongNo]';
count=[count,zeros(LastSongNo,2)]; % <songNo nMatch DT>
cNo=1;
cDT=0;
cCount=0;
i=1;
while i<=length(hashCount)
    cDT=0;
    cCount=0;
    while(i<=length(hashCount)&&hashCount(i,2)==cNo)
        if(hashCount(i,1)~=cDT)
            if(cCount>count(cNo,2))
                count(cNo,2)=cCount;
                count(cNo,3)=cDT;
            end
            cDT=hashCount(i,1);
            cCount=0;
        else
            if(cDT~=0)            
                cCount=cCount+1;
            end
        end
        i=i+1;
    end
    if(cCount>count(cNo,2))
        count(cNo,2)=cCount;
        count(cNo,3)=cDT;
    end
    cNo=cNo+1;
end
count=sortrows(count,2,'descend');
count=count(1:MaxNoOfMatches,:);


