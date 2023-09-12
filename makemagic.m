

clear
rng('shuffle','twister');
global aSize
aSize=6; % USER size
%   table:    3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20
level=[-1 -1  5  7  9 11 13 15 17 19 21 23  0  0  0  0  0  0  0 39];
global connections
connections=[];
global myconnections
myconnections=[];
global aProved
global aWork

makeConnections()
makeMyConnections()

% make a full mask
aProved=ones(aSize);

% remove elements and check solubility
count=0;
for i=1:aSize*aSize % max number of holes
    aWork=aProved;
   
    ipos=randi(aSize*aSize);
    while(aWork(ipos)==0)
        ipos=randi(aSize*aSize);
    end
    
    aWork(ipos)=0;
    if solveMagic()
        count=count+1;
        aProved(ipos)=0;
    else
        break
    end
end

% make a full, shuffled matrix and apply the mask
aFull=suffleMatrix(magic(aSize),aSize);
aPrint=aFull.*suffleMatrix(aProved,aSize);

if count>=level(aSize)
    %disp(count)
    disp(aPrint)
end
%%% end of main



function f = solveMagic
    global aWork
    
    while true 
        if solveHole()
            continue
        end
        if false && solveCheat()
            continue
        end
        break
    end
    tmp=(aWork==0);
    if sum(tmp(:))==0 % TFH gondosan toltotte ki ;-) 
        f=true;
        return
    else
        f=false;
        return
    end
end

function f = solveHole()
    global connections
    global aWork

    for iconn=1:size(connections,1) 
        numZero=0;
        posZero=-1;
        for iinconn=1:size(connections,2)
            if aWork(connections(iconn,iinconn))==0
                numZero=numZero+1;
                posZero=connections(iconn,iinconn);
            end
        end
        if numZero==1
            aWork(posZero)=1;
            f=true;
            return
        end
    end
    
    f=false;
    return
end

function makeConnections() % making connections
    global connections
    global aSize
    base=[1:aSize];
    
    for i=1:aSize % columns     
        connections=[connections; (i-1)*aSize+base];
    end
    for i=1:aSize % rows     
        connections=[connections; i+aSize*(base-1)];
    end
end

function makeMyConnections() % making connections of every cell
    global connections
    global myconnections
    global aSize
    
    for ipos=1:aSize*aSize % pos
        tmpConnection=[];
        for iconn=1:size(connections,1) 
            if ismember(ipos,connections(iconn,:))
                for iinconn=1:size(connections,2)
                    if connections(iconn,iinconn)~=ipos
                        tmpConnection=[tmpConnection connections(iconn,iinconn)];
                    end
                end
            end
        end
        myconnections(ipos,:)=unique(tmpConnection);
    end
end

function f = suffleMatrix(M,crChanges) % shuffle matrix
    myShuffle=randi([1,size(M,1)],crChanges,4); % crChanges*2 switches
    for i=1:size(myShuffle,1)
        M(:,[myShuffle(i,1),myShuffle(i,2)])=M(:,[myShuffle(i,2),myShuffle(i,1)]);
        M([myShuffle(i,3),myShuffle(i,4)],:)=M([myShuffle(i,4),myShuffle(i,3)],:);
    end
    f=M;
end
















































%end
