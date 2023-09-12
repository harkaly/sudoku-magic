

clear
rng('shuffle','twister');
global aSize
aSize=9; % USER DATA: size
%   table:      4  5  6        9
level=[-1 -1 -1 0 18 25 -1 -1 53*.6];
% max hole:     8 13 13       21   
% max one:     12 19 25       51
% max makay12/13: 20 27       53
global connections
connections=[];
global myconnections
myconnections=[];
global aFull
global aProved
global aWork
global aPossibilities
%global pointProved
global pointWork

makeConnections()
makeMyConnections()

% make a full sudokumatrix
tryTable=0;
while true
    tryTable=tryTable+1;
    res=makeFullSudoku();
    if res>=aSize*aSize
        break
    end
end

% %debug
% tryTable
% aFull
% aPossibilities
% disp("----------------------")




% % testarea :-)
% clc
% aWork=[
%      0     7     0     2     0     4     0     0     8;
%      0     0     0     0     1     0     0     4     3;
%      4     0     0     9     5     0     7     0     2;
%      6     0     9     4     0     2     0     0     0;
%      0     3     0     6     0     0     8     2     0;
%      0     4     2     3     0     0     0     6     0;
%      0     0     4     0     3     6     0     0     1;
%      3     0     0     0     0     9     0     8     0;
%      0     5     0     0     0     0     9     3     6
% ];
% tmp=(aWork==0);
% sum(tmp(:))
% buildPossibilities()
% aPossibilities
% solveSudoku(1)
% error("QED")






% remove elements and check solubility
aProved=aFull;
count=0;

for i=1:aSize*aSize % max number of holes
    aWork=aProved;
   
    ipos=randi(aSize*aSize);
    while(aWork(ipos)==0)
        ipos=randi(aSize*aSize);
    end
    
    aWork(ipos)=0;
    buildPossibilities()
    if solveSudoku(0)
        count=count+1;
%         %debug
%         disp(count)
%         disp("----------------------")
        aProved(ipos)=0;
        pointProved=pointWork;

    else
        break
    end
end

% % debug
% aFull
% count
% aProved
% aPossibilities

if count>=level(aSize) && pointProved>=0
    disp([count pointProved])
    disp(aProved)
end
%%% end of main



function f = solveSudoku(flagDebug)
    %global aFull
    global aWork
    global pointWork
    pointWork=0;
    
    if flagDebug
        disp("-----------------------")
    end
    while true 
        if false && solveHole()
            if flagDebug
                disp("Hole")
            end
            continue
        end
        if solveOnePossibility() % 0 point (Makay10)
            if flagDebug
                %disp("OnePossibility")
            end
            continue
        end
        if solveMakay21() % 1 point
            pointWork=pointWork+1;
            if flagDebug
                disp("Makay21")
            end
            continue
        end
        if solveMakay12() % 2 point
            pointWork=pointWork+20;
            if flagDebug
                disp("Makay12")
            end
            continue
        end
        if solveMakay13() % 4 point
            pointWork=pointWork+400;
            if flagDebug
                disp("Makay13")
            end
            continue
        end
        if solveOne()
            if flagDebug
                disp("One")
            end
            continue
        end
        if false && solveCheat()
            continue
        end
        break
    end
    tmp=(aWork==0);
    % if aWork==aFull
    if sum(tmp(:))==0 % TFH gondosan toltotte ki ;-) 
        f=true;
        if flagDebug
            disp("+")
        end
        return
    else
        f=false;
        if flagDebug
            disp("-")
        end
        return
    end
end

function f = solveCheat() % just knowing the solution :-) - disabled
    global aSize
    global aFull
    global aWork
  
    for ipos=1:aSize*aSize
        if aWork(ipos)==0
            aWork(ipos)=aFull(ipos);
            delPossibilities(ipos)
            delToConnPossibilities(ipos)
%             %debug
%             disp(["cheat" i])
            f=true;
            return
        end
    end
    
    f=false;
    return
end
function f = solveHole() % there is one hole in the group
    global connections
    global aFull
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
            aWork(posZero)=aFull(posZero); % csalok: megoldhato, de nem oldom meg
            delPossibilities(posZero)
            delToConnPossibilities(posZero)
%             %debug
%             disp(["hole" posZero])
            f=true;
            return
        end
    end
    
    f=false;
    return
end
function f = solveOne() % just one number can be on the cell - check connections
    global myconnections
    global aSize
    % global aFull
    global aWork

    for ipos=1:aSize*aSize % pos
        if aWork(ipos)~=0
            continue
        end
        base=ones(aSize,1);
        for iinconn=1:size(myconnections,2) 
            if aWork(myconnections(ipos,iinconn))>0
                base(aWork(myconnections(ipos,iinconn)))=0;
            end
        end
        if sum(base)==1
            % aWork(ipos)=aFull(ipos); % csalok: megoldhato, de nem oldom meg
            aWork(ipos)=find(base==1); % rendes vagyok
            delPossibilities(ipos)
            delToConnPossibilities(ipos)
%             %debug
%             disp(["one" ipos])
            f=true;
            return
        end
    end
    
    f=false;
    return
end
function f = solveOnePossibility() % just one number is possible on the cell - check aPossibilities
    global aPossibilities
    global aSize
    % global aFull
    global aWork

    for ipos=1:aSize*aSize % pos
        if aWork(ipos)~=0
            continue
        end
        base=aPossibilities(ipos,:);
        if sum(base)==1
            % aWork(ipos)=aFull(ipos); % csalok: megoldhato, de nem oldom meg
            aWork(ipos)=find(base==1); % rendes vagyok
            delPossibilities(ipos)
            delToConnPossibilities(ipos)
%             %debug
%             disp(["onePossibility" ipos])
            f=true;
            return
        end
    end
    
    f=false;
    return
end
function f = solveMakay12() % rule nr.1, n=2
% http://www.math.u-szeged.hu/Sudoku/
% 1. n-es lehetoseg (n >= 1, 2n − 2 pont): Ha egy adott sorban, oszlopban vagy blokkban van n
% db cella, amelyen legfeljebb n db kulonbozo szam fordulhat elo, akkor ennek az n db szamnak
% valamilyen sorrendben pontosan ebben az n db cellaban kell elofordulnia. Tehat ez az n db
% szam az adott sorban, oszlopban vagy blokkban minden mas cellabol torolheto a lehetosegek
% kozul.

    global connections
    global aPossibilities
    global aWork
    flagWork=false;

    for iconn=1:size(connections,1) 
        for iinconn1=1:size(connections,2)-1
            for iinconn2=iinconn1+1:size(connections,2)
                if aWork(connections(iconn,iinconn1))==0 && aWork(connections(iconn,iinconn2))==0
                    base=aPossibilities(connections(iconn,iinconn1),:)|aPossibilities(connections(iconn,iinconn2),:);
                    if sum(base)==2
                        basef=find(base==1);
                        for i=1:size(basef,2)
                            for iinconn=1:size(connections,2)
                                if iinconn==iinconn1
                                    continue
                                end
                                if iinconn==iinconn2
                                    continue
                                end
                                if aWork(connections(iconn,iinconn))==0
                                    if aPossibilities(connections(iconn,iinconn),basef(i))==1
                                        flagWork=true;
                                        aPossibilities(connections(iconn,iinconn),basef(i))=0;
                                    end
                                end
                            end
                        end
                        if flagWork
%                            %debug
%                            disp(["Makay12" connections(iconn,iinconn1) connections(iconn,iinconn2)])
                            f=true;
                            return
                        end
                    end
                end
            end
        end
    end
    
    f=false;
    return
end
function f = solveMakay13() % rule nr.1, n=3
% http://www.math.u-szeged.hu/Sudoku/
% 1. n-es lehetoseg (n >= 1, 2n − 2 pont): Ha egy adott sorban, oszlopban vagy blokkban van n
% db cella, amelyen legfeljebb n db kulonbozo szam fordulhat elo, akkor ennek az n db szamnak
% valamilyen sorrendben pontosan ebben az n db cellaban kell elofordulnia. Tehat ez az n db
% szam az adott sorban, oszlopban vagy blokkban minden mas cellabol torolheto a lehetosegek
% kozul.

    global connections
    global aPossibilities
    global aWork
    flagWork=false;

    for iconn=1:size(connections,1) 
        for iinconn1=1:size(connections,2)-2
            for iinconn2=iinconn1+1:size(connections,2)-1
                for iinconn3=iinconn2+1:size(connections,2)
                    if aWork(connections(iconn,iinconn1))==0 && aWork(connections(iconn,iinconn2))==0 && aWork(connections(iconn,iinconn3))==0
                        base=aPossibilities(connections(iconn,iinconn1),:)|aPossibilities(connections(iconn,iinconn2),:)|aPossibilities(connections(iconn,iinconn3),:);
                        if sum(base)==3
                            basef=find(base==1);
                            for i=1:size(basef,2)
                                for iinconn=1:size(connections,2)
                                    if iinconn==iinconn1
                                        continue
                                    end
                                    if iinconn==iinconn2
                                        continue
                                    end
                                    if iinconn==iinconn3
                                        continue
                                    end
                                    if aWork(connections(iconn,iinconn))==0
                                        if aPossibilities(connections(iconn,iinconn),basef(i))==1
                                            flagWork=true;
                                            aPossibilities(connections(iconn,iinconn),basef(i))=0;
                                        end
                                    end
                                end
                            end
                            if flagWork
%                                %debug
%                                disp(["Makay13" connections(iconn,iinconn1) connections(iconn,iinconn2) connections(iconn,iinconn3)])
                                f=true;
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    
    f=false;
    return
end
function f = solveMakay21() % rule nr.2, n=1
% http://www.math.u-szeged.hu/Sudoku/
% n-es rejtett lehetoseg (n >= 1, 2n−1 pont): Ha egy adott sorban, oszlopban vagy blokkban
% van n db szam, amelyek csak n db cellaban fordulhatnak elo, akkor ennek az n db szamnak
% valamilyen sorrendben pontosan ebben az n db cellaban kell elofordulnia. Tehat az n db
% cellabol az adott n db szamon kıvul minden mas lehetoseg torolheto.
% itt: n=1
    global connections
    global aPossibilities
    global aWork
    global aSize
    
    for iconn=1:size(connections,1) 
        base=zeros(1,aSize);
        basePos=zeros(1,aSize);
        for iinconn=1:size(connections,2)
            if aWork(connections(iconn,iinconn))==0
                for i=1:aSize
                    if aPossibilities(connections(iconn,iinconn),i)
                        base(i)=base(i)+1;
                        basePos(i)=connections(iconn,iinconn);
                    end
                end
            end
        end
        basef=find(base==1);
        for i=1:size(basef,2)
%             basef
%             base
%             basePos
           
            aWork(basePos(basef(i)))=basef(i);
            delPossibilities(basePos(basef(i)))
            delToConnPossibilities(basePos(basef(i)))
%             %debug
%             disp(["Makay21" basePos(basef(i)) basef(i)])
            f=true;
            return
        end
    end
    
    f=false;
    return
end

function delPossibilities(q) % everything on this position
    global aPossibilities
    aPossibilities(q,:)=0;
end
function delFromConnPossibilities(q) % on this position based on myconnection 
    global aPossibilities
    global aWork
    global myconnections
    
    for iinconn=1:size(myconnections,2) 
        if aWork(myconnections(q,iinconn))~=0
            aPossibilities(q,aWork(myconnections(q,iinconn)))=0;
        end
    end
end
function delToConnPossibilities(q) % on myconnection positions based on this position 
    global aPossibilities
    global aWork
    global myconnections
    
    if aWork(q)==0
        return
    end
    
    for iinconn=1:size(myconnections,2) 
        aPossibilities(myconnections(q,iinconn),aWork(q))=0;
    end
end
function buildPossibilities_() % new table based on aWork
    global aSize;
    global aWork
    global aPossibilities
    aPossibilities=ones(aSize*aSize,aSize);    
    
    for ipos=1:aSize*aSize % pos
        if(aWork(ipos)~=0)
            aPossibilities(ipos,:)=0;
            delToConnPossibilities(ipos)
        end
    end
end
function buildPossibilities() % new table based on aWork - quicker for few holes
    global aSize;
    global aWork
    global aPossibilities
    aPossibilities=ones(aSize*aSize,aSize);    
    
    for ipos=1:aSize*aSize % pos
        if(aWork(ipos)~=0)
            aPossibilities(ipos,:)=0;
        else
            delFromConnPossibilities(ipos)
        end
    end
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
    if aSize==4
        connections=[connections; [1 2 5 6]];
        connections=[connections; [3 4 7 8]];
        connections=[connections; [9 10 13 14]];
        connections=[connections; [11 12 15 16]];
    elseif aSize==5 % left top corner: 3 vertical
        connections=[connections; [1 2 3 6 7]];
        connections=[connections; [4 5 9 10 15]];
        connections=[connections; [11 16 17 21 22]];
        connections=[connections; [19 20 23 24 25]];
        connections=[connections; [8 12 13 14 18]];
    elseif aSize==6 % vertical blocks
        connections=[connections; [1 2 3 7 8 9]];
        connections=[connections; [4 5 6 10 11 12]];
        connections=[connections; [13 14 15 19 20 21]];
        connections=[connections; [16 17 18 22 23 24]];
        connections=[connections; [25 26 27 31 32 33]];
        connections=[connections; [28 29 30 34 35 36]];
    elseif aSize==9 
        connections=[connections; [1 2 3 10 11 12 19 20 21]];
        connections=[connections; [4 5 6 13 14 15 22 23 24]];
        connections=[connections; [7 8 9 16 17 18 25 26 27]];
        connections=[connections; [28 29 30 37 38 39 46 47 48]];
        connections=[connections; [31 32 33 40 41 42 49 50 51]];
        connections=[connections; [34 35 36 43 44 45 52 53 54]];
        connections=[connections; [55 56 57 64 65 66 73 74 75]];
        connections=[connections; [58 59 60 67 68 69 76 77 78]];
        connections=[connections; [61 62 63 70 71 72 79 80 81]];
    else
       error("Not implemented box size") 
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
        if aSize~=5
            myconnections(ipos,:)=unique(tmpConnection);
        else
            qq=unique(tmpConnection);
            while size(qq,2)<10
                qq=[qq qq(1)];
            end
            myconnections(ipos,:)=qq;
        end
    end
end

function f=makeFullSudoku() % making a full table with myconnections
    global aFull
    global myconnections
    global aSize;
    aFull=zeros(aSize,aSize);
   
    for ipos=1:aSize*aSize % pos
        flagInsert=false;
        tmpval=randperm(aSize);
        for ival=1:aSize % future element index
            flagFound=false;
            for iinconn=1:size(myconnections,2) 
                if aFull(myconnections(ipos,iinconn))==tmpval(ival)
                    flagFound=true;
                    break
                end
            end
            if flagFound==false
                aFull(ipos)=tmpval(ival);
                flagInsert=true;
                break
            end
        end
        if flagInsert==false
            f=ipos;
            return
        end
    end

    f=ipos;
    return
end

function f=OldMakeFullSudoku() % making a full table with connections
    global aFull
    global connections
    global aSize;
    aFull=zeros(aSize,aSize);
   
    for ipos=1:aSize*aSize % pos
        flagInsert=false;
        tmpval=randperm(aSize);
        for ival=1:aSize % future element index
            flagFound=false;
            for iconn=1:size(connections,1) 
                if ismember(ipos,connections(iconn,:))
                    for iinconn=1:size(connections,2)
                        if aFull(connections(iconn,iinconn))==tmpval(ival)
                            flagFound=true;
                            break
                        end
                    end
                    if flagFound
                        break
                    end
                end
                if flagFound
                    break
                end
            end
            if flagFound==false
                aFull(ipos)=tmpval(ival);
                flagInsert=true;
                break
            end
        end
        if flagInsert==false
            f=ipos;
            return
        end
    end

    f=ipos;
    return
end



















































%end
