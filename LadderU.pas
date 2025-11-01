unit LadderU;

interface

procedure ScoresLadder(var score: int64; posX, posY: integer);

implementation
uses crt, mDataTypesU;

const
    FILENAME_FOR_SCORE = 'data_score_ladder';
    MAX_RESULTS_FOR_LADDER = 10;
    MIN_VALID_SCORE = 1;

type
    TFile = file of integer;

procedure OpenFile(var f: TFile);
begin
    {$I-}
    assign(f, FILENAME_FOR_SCORE);
    reset(f);
    if IOResult <> 0 then
        rewrite(f);
end;

procedure ReadFileAndUploadDataToQueue(
    score: integer;
    var q: TQueueRecord;
    var f: TFile
);
var
    n: integer;
begin
    QInit(q);
    while not eof(f) do
    begin
        read(f, n);
        QPut(q, n)
    end;
    close(f);
    QPut(q, score)
end;

procedure AddUniqueToStack(var q: TQueueRecord; var stack: TStackPointer);
var
    current: TQueuePointer;
    exists: boolean;
    stackPtr: TStackPointer;
begin
    SInit(stack);
    current := q.first;
    
    while current <> nil do
    begin
        exists := false;
        stackPtr := stack;
        while stackPtr <> nil do
        begin
            if stackPtr^.data = current^.data then
            begin
                exists := true;
                break
            end;
            stackPtr := stackPtr^.next
        end;
        
        if not exists and (current^.data > MIN_VALID_SCORE) then
            SPush(stack, current^.data);
            
        current := current^.next
    end
end;

procedure SortStackData(var stack: TStackPointer);
var
    tmpNum: integer;
    pp: ^TStackPointer;
    swapped: boolean;
begin
    repeat
        swapped := false;
        pp := @(stack);
        while (pp^ <> nil) and (pp^^.next <> nil) do
        begin
            if pp^^.data < pp^^.next^.data then
            begin
                tmpNum := pp^^.data;
                pp^^.data := pp^^.next^.data;
                pp^^.next^.data := tmpNum;
                swapped := true
            end;
            pp := @(pp^^.next)
        end
    until not swapped
end;

procedure
WriteLadderForDisplay(var stack: TStackPointer; posX, posY: integer);
var
    i, topCounter: integer;
    pp: ^TStackPointer;
begin
    topCounter := 1;
    i := posY+1;
    TextColor(Blue);
    GotoXY(1, posY);
    write('TOP 10 score: ');
    pp := @(stack);
    while pp^ <> nil do
    begin
        if (pp^^.data > MIN_VALID_SCORE) 
            and (topCounter <= MAX_RESULTS_FOR_LADDER) then
        begin
            GotoXY(PosX, i);
            TextColor(Red);
            write(i-PosY, ': ');
            TextColor(Yellow);
            write(pp^^.data);
            i := i + 1;
            topCounter := topCounter + 1
        end;
        pp := @(pp^^.next)
    end
end;

procedure WriteDataOnFile(var stack: TStackPointer; var f: TFile);
var
    pp: ^TStackPointer;
    topCounter: integer;
begin
    rewrite(f);
    pp := @(stack);
    topCounter := 1;
    while (pp^ <> nil) do
    begin
        if (pp^^.data > MIN_VALID_SCORE) 
            and (topCounter <= MAX_RESULTS_FOR_LADDER) then
        begin
            write(f, pp^^.data);
            topCounter := topCounter + 1;
        end;
        pp := @(pp^^.next);
    end;
    close(f)
end;

procedure ScoresLadder(var score: int64; posX, posY: integer);
var
    queue: TQueueRecord;
    stack: TStackPointer;
    dataFile: TFile;
begin
    OpenFile(dataFile);
    ReadFileAndUploadDataToQueue(score, queue, dataFile);
    AddUniqueToStack(queue, stack);
    SortStackData(stack);
    WriteLadderForDisplay(stack, posX, posY);
    WriteDataOnFile(stack, dataFile);

    { clear }
    QClear(queue);
    SClear(stack);

    GotoXY(1, 1)
end;

end.
