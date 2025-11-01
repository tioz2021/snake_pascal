uses crt, SysUtils, GetKeyU;

const
    SNAKE_HEAD_CHAR = '@';
    SNAKE_BODY_CHAR = '#';
    BORDER_CHAR = '*';
    STAR_CHAR = '0';
    SCORE_STEP = 100;

type
    TDirection = (up, down, left, right);
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

procedure GameOver;
begin
    clrscr;
    TextColor(Red or Blink);
    TextBackground(Yellow);
    writeln('Game Over! Press Enter to finish the game');
    GotoXY(1, 2);
    {writeln('Your score: ', gameScore);}
    TextAttr := saveTextAttr;
    {ScoresLadder(gameScore, 1, 3);}
    readln;
    halt(1);
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
end;

procedure MoveSnake(var snake: TQR; dir: TDirection);
var
    i, j: integer;
    curPosX, curPosY, tmpPosX, tmpPosY: integer;
    cur, cur2: TQP;
begin
    HideSnake(snake);

    { write a new snake in new position }
    i := 1;
    cur := snake.first;
    cur2 := snake.first;
    while cur <> nil do
    begin
        if i = 1 then 
        begin
            TextColor(Red);
            curPosX := cur^.data.posX;
            curPosY := cur^.data.posY;
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
            {cur^.next^.data.smbl := '0';}
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

        write(cur^.data.smbl);

        GotoXY(1, 1);
        TextAttr := saveTextAttr;

        cur := cur^.next;
        inc(i);
    end;
    TextAttr := saveTextAttr;
end;

var
    item: TItem;
    i, keyCode: integer;
    snake: TQR;
    curPointer: TQP;
    dir: TDirection;
    lastMove: QWord;
    moveDelay: integer;
begin
    clrscr;
    saveTextAttr := TextAttr;
    dir := left;
    lastMove := GetTickCount64;

    { init snake }
    QInit(snake);

    { create snake (lenght = 10) }
    i := 1;
    while i < 10 do
    begin
        if i = 1 then
            CreateItem(item, i+34, 4, SNAKE_HEAD_CHAR)
        else
            CreateItem(item, i+34, 4, SNAKE_BODY_CHAR);
        QPutItem(snake, item);
        inc(i);
    end;

    { write snake }
    curPointer := snake.first;
    while curPointer <> nil do
    begin
        GotoXY(curPointer^.data.posX, curPointer^.data.posY);
        write(curPointer^.data.smbl);
        
        curPointer := curPointer^.next;
    end;

    while true do
    begin
        moveDelay := 500;

        if KeyPressed then
        begin
            GetKey(keyCode);
            case keyCode of
                -75: { left }
                begin
                    dir := left;
                    MoveSnake(snake, dir);
                end;
                -77: { right }
                begin
                    dir := right;
                    MoveSnake(snake, dir);
                end;
                -72: { up }
                begin
                    dir := up;
                    MoveSnake(snake, dir);
                end;
                -80: { down }
                begin
                    dir := down;
                    MoveSnake(snake, dir);
                end;
                32: { space }
                begin
                    {PauseGame(saveTextAttr)}
                end;
                27: { esc }
                begin
                    clrscr;
                    halt(1);
                end;
            end;
        end;

        if (GetTickCount64 - lastMove > moveDelay) then
        begin

            lastMove := GetTickCount64;
        end;

        delay(30);
    end;
    {
    GotoXY(5, 5);
    write('*');
    GotoXY(6, 5);
    write('*');
    GotoXY(7, 5);
    write('*');
    GotoXY(7, 6);
    write('*');
    GotoXY(7, 7);
    write('*');
    }

    clrscr;
end.
