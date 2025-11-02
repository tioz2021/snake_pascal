uses crt, SysUtils,
    { my unit }
    GetKeyU, mDataTypesU, LadderU;

const
    STAR_CHAR = '*';
    STAR_CHAR_COLOR = Yellow;
    SCORE_STEP = 100;
    GAME_SPEED = 200;

    SNAKE_HEAD_CHAR = ' ';
    SNAKE_HEAD_COLOR = Red;
    SNAKE_BODY_CHAR = ' ';
    SNAKE_BODY_COLOR = Green;
    BORDER_CHAR = ' ';
    BORDER_CHAR_COLOR = LightBlue;

type
    TDirection = (up, down, left, right, none);
    TItem = record
        smbl: char;
        posX, posY: integer;
    end;
    TQP = ^TQ;
    TQ = record
        data: TItem;
        next: TQP;
    end;
    TQR = record
        first, last: TQP;
    end;

{ #global var }
var
    saveTextAttr: integer;
    gameScore: int64;

procedure GameOver;
begin
    clrscr;
    TextColor(Red or Blink);
    TextBackground(Yellow);
    writeln('Game Over! Press Enter to finish the game');
    GotoXY(1, 2);
    writeln('Your score: ', gameScore);
    TextAttr := saveTextAttr;
    ScoresLadder(gameScore, 1, 3);
    readln;
    halt(1);
end;

procedure DrawInfo;
begin
    TextColor(Yellow);
    GotoXY(1, ScreenHeight);
    write('Snake | ');
    GotoXY(9 , ScreenHeight);
    write('Score: ');
    TextColor(Red);
    write(gameScore);
    TextColor(Yellow);
    GotoXY(1, 1);

    TextAttr := saveTextAttr;
end;

procedure WriteBorder;
var
    i, j: integer;
begin
    for i := 1 to ScreenHeight do
    begin
        for j := 1 to ScreenWidth do
        begin
            GotoXY(j, i-1);
            if ((i = 1) or (i = ScreenHeight)) or
                ((j = 1) or (j = ScreenWidth)) then
            begin
                TextBackground(BORDER_CHAR_COLOR);
                write(BORDER_CHAR);
            end;
        end;
    end;
    GotoXY(1, 1);
    TextAttr := saveTextAttr;
end;

procedure GamePause;
begin
    GotoXY(1, 1);
    TextColor(Yellow);
    write('The game is pause. Type enter to continue games');
    readln;
    GotoXY(1, 1);
    TextAttr := saveTextAttr;
    WriteBorder;
end;

procedure QInit(var q: TQR);
begin
    q.first := nil;
    q.last := nil;
end;

procedure QPutItem(var q: TQR; item: TItem);
begin
    if q.first = nil then
    begin
        new(q.first);
        q.last := q.first;
    end
    else
    begin
        new(q.last^.next);
        q.last := q.last^.next;
    end;
    q.last^.data := item;
    q.last^.next := nil;
end;

procedure CreateItem(var item: TItem; x, y: integer; smbl: char);
begin
    item.smbl := smbl;
    item.posX := x;
    item.posY := y;
end;

procedure HideSnake(var snake: TQR);
var
    cur: TQP;
begin
    cur := snake.first;
    while cur <> nil do
    begin
        GotoXY(cur^.data.posX, cur^.data.posY);
        write(' ');
        cur := cur^.next;
    end;
    GotoXY(1, 1);
end;

procedure WriteSnake(var snake: TQR);
var
    cur: TQP;
begin
    cur := snake.first;
    while cur <> nil do
    begin
        GotoXY(cur^.data.posX, cur^.data.posY);
        write(cur^.data.smbl);
        
        cur := cur^.next;
    end;
    GotoXY(1, 1);
end;

function PressKeyChecker(x, y: integer): boolean;
begin
    if x = y then
        PressKeyChecker := true
    else
        PressKeyChecker := false;
end;

function
PossiblityOfChangingDirection(var snake: TQR; dir: TDirection): TDirection;
var
    cur: TQP;
    tmpPos, tmpPosNext: integer;
begin
    cur := snake.first;
    if cur^.next <> nil then
    begin
        case dir of
            up:
            begin
                tmpPos := cur^.data.posY-1;
                tmpPosNext := cur^.next^.data.posY;
                if PressKeyChecker(tmpPos, tmpPosNext) then
                    PossiblityOfChangingDirection := none
                else
                    PossiblityOfChangingDirection := up;
            end;
            down:
            begin
                tmpPos := cur^.data.posY+1;
                tmpPosNext := cur^.next^.data.posY;
                if PressKeyChecker(tmpPos, tmpPosNext) then
                    PossiblityOfChangingDirection := none
                else
                    PossiblityOfChangingDirection := down;
            end;
            left:
            begin
                tmpPos := cur^.data.posX-1;
                tmpPosNext := cur^.next^.data.posX;
                if PressKeyChecker(tmpPos, tmpPosNext) then
                    PossiblityOfChangingDirection := none
                else
                    PossiblityOfChangingDirection := left;
            end;
            right:
            begin
                tmpPos := cur^.data.posX+1;
                tmpPosNext := cur^.next^.data.posX;
                if PressKeyChecker(tmpPos, tmpPosNext) then
                    PossiblityOfChangingDirection := none
                else
                    PossiblityOfChangingDirection := right;
            end;
        end;
    end;

end;

procedure MoveSnake(var snake: TQR; dir: TDirection);
var
    i, j: integer;
    curPosX, curPosY, tmpPosX, tmpPosY: integer;
    cur, cur2: TQP;
begin
    { write a new snake in new position }
    cur := snake.first;
    cur2 := snake.first;

    { clear prev snake position }
    HideSnake(snake);
    i := 1;
    while cur <> nil do
    begin
        if i = 1 then 
        begin
            curPosX := cur^.data.posX;
            curPosY := cur^.data.posY;
            { change direction }
            case dir of
                up:
                begin
                    dec(cur^.data.posY);
                end;
                down:
                begin
                    inc(cur^.data.posY);
                end;
                left:
                begin
                    dec(cur^.data.posX);
                end;
                right:
                begin
                    inc(cur^.data.posX);
                end;
            end;

            { collision check } 
            j := 1;
            while cur2 <> nil do
            begin
                if j <> 1 then
                begin
                    if (cur2^.data.posX = cur^.data.posX) and 
                        (cur2^.data.posY = cur^.data.posY) then
                    begin
                        GameOver;
                    end;
                end;
                inc(j);
                cur2 := cur2^.next;
            end;
            GotoXY(cur^.data.posX, cur^.data.posY);
        end
        else
        begin
            tmpPosX := cur^.data.posX;
            tmpPosY := cur^.data.posY;
            cur^.data.posX := curPosX;
            cur^.data.posY := curPosY;

            GotoXY(cur^.data.posX, cur^.data.posY);
            curPosX := tmpPosX;
            curPosY := tmpPosY;
        end;

        { write snake }
        if i = 1 then
            TextBackground(SNAKE_HEAD_COLOR)
        else
            TextBackground(SNAKE_BODY_COLOR);
        write(cur^.data.smbl);
        GotoXY(1, 1);
        TextAttr := saveTextAttr;

        cur := cur^.next;
        inc(i);
    end;
    TextAttr := saveTextAttr;
end;

function CheckBorderLimits(itemPosX, itemPosY: integer): boolean;
begin
    if ((itemPosX < 1) or (itemPosX > ScreenWidth-2)) or
       ((itemPosY < 1) or (itemPosY > ScreenHeight-2)) then
    begin
        CheckBorderLimits := false
    end
    else
        CheckBorderLimits := true;
end;

procedure SpawnItem(x, y: integer; item: char);
begin
    TextBackground(STAR_CHAR_COLOR);
    GotoXY(x, y);
    write(item);
    GotoXY(1, 1);
    TextAttr := saveTextAttr;
end;

function TouchStar(snakePosX, snakePosY,
    itemPosX, itemPosY: integer): boolean;
begin
    if (snakePosX = itemPosX) and (snakePosY = itemPosY) then
        TouchStar := true
    else
        TouchStar := false;
end;

procedure CheckPositionForSpawn(var itemPosX, itemPosY: integer);
begin
    while true do
    begin
        itemPosX := random(ScreenWidth);
        itemPosY := random(ScreenHeight);
        if CheckBorderLimits(itemPosX, itemPosY) then
            break;
    end;
end;

procedure RandomDirectionForStart(var dir: TDirection);
var
    n: integer;
begin
    n := random(4)-1;
    case n of
        1: dir := left;
        2: dir := right;
        3: dir := up;
        4: dir := down;
    end;
end;

var
    item: TItem;
    tmpX, tmpY, keyCode: integer;
    snake: TQR;
    dir, tmpDir: TDirection;
    lastMove: QWord;
    moveDelay: integer;
    itemPosX, itemPosY, snakePosX, snakePosY: integer;
begin
    { base util}
    randomize;
    clrscr;
    saveTextAttr := TextAttr;
    lastMove := GetTickCount64;
    gameScore := 0;

    { ... }
    RandomDirectionForStart(dir);
    WriteBorder;
    CheckPositionForSpawn(itemPosX, itemPosY);
    SpawnItem(itemPosX, itemPosY, STAR_CHAR);

    { random spawn and create snake }
    QInit(snake);
    {CheckPositionForSpawn(snakePosX, snakePosY);}
    snakePosX := ScreenWidth div 2;
    snakePosY := ScreenHeight div 2;
    CreateItem(item, snakePosX, snakePosY, SNAKE_HEAD_CHAR);
    QPutItem(snake, item);
    WriteSnake(snake);

    while true do
    begin
        moveDelay := GAME_SPEED;

        { move info }
        GotoXY(ScreenWidth-40, ScreenHeight);
        write('Move info: ', ScreenWidth, ' : ', ScreenHeight, 
            ' | ', snakePosX, ' : ', snakePosY,
            ' | ', itemPosX, ' : ', itemPosY);
        GotoXY(1, 1);

        if KeyPressed then
        begin
            GetKey(keyCode);
            case keyCode of
                -75: { left }
                begin
                    tmpDir := PossiblityOfChangingDirection(snake, left);
                    if tmpDir <> none then
                        dir := left;
                end;
                -77: { right }
                begin
                    tmpDir := PossiblityOfChangingDirection(snake, right);
                    if tmpDir <> none then
                        dir := right;
                end;
                -72: { up }
                begin
                    tmpDir := PossiblityOfChangingDirection(snake, up);
                    if tmpDir <> none then
                        dir := up;
                end;
                -80: { down }
                begin
                    tmpDir := PossiblityOfChangingDirection(snake, down);
                    if tmpDir <> none then
                        dir := down;
                end;
                32: { space }
                begin
                    GamePause;
                end;
                27: { esc }
                begin
                    { close game }
                    clrscr;
                    halt(1);
                end;
            end;
        end;

        if (GetTickCount64 - lastMove > moveDelay) then
        begin
            { info }
            DrawInfo;

            { move snake }
            MoveSnake(snake, dir);

            { check head position and game over}
            snakePosX := snake.first^.data.posX;
            snakePosY := snake.first^.data.posY;
            if not CheckBorderLimits(snakePosX, snakePosY) then
            begin
                GameOver;
            end;

            { eat star }
            if TouchStar(snakePosX, snakePosY, itemPosX, itemPosY) then
            begin
                { last snake element position }
                tmpX := snake.last^.data.posX;
                tmpY := snake.last^.data.posY;

                { create new Item }
                CreateItem(item, tmpX, tmpY, SNAKE_BODY_CHAR);
                QPutItem(snake, item);

                { spawn new star }
                CheckPositionForSpawn(itemPosX, itemPosY);
                SpawnItem(itemPosX, itemPosY, STAR_CHAR);

                { add score }
                gameScore := gameScore + SCORE_STEP;
            end;

            lastMove := GetTickCount64;
        end;

        delay(30);
    end;
    clrscr;
end.
