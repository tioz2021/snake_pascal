uses crt, GetKeyU;

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

procedure MoveSnake(var snake: TQR; dir: TDirection);
var
    i, curPosX, curPosY, tmpPosX, tmpPosY: integer;
    cur: TQP;
begin
    cur := snake.first;

    { clear snake symbols }
    while cur <> nil do
    begin
        GotoXY(cur^.data.posX, cur^.data.posY);
        write(' ');
        cur := cur^.next;
    end;

    { write a new snake in new position }
    i := 1;
    cur := snake.first;
    while cur <> nil do
    begin
        if i = 1 then 
        begin
            TextColor(Red);
            curPosX := cur^.data.posX;
            curPosY := cur^.data.posY;
            case dir of
                up:
                    dec(cur^.data.PosY);
                down:
                    inc(cur^.data.PosY);
                left:
                    dec(cur^.data.PosX);
                right:
                    inc(cur^.data.PosX);
            end;
            GotoXY(cur^.data.PosX, cur^.data.PosY);
        end
        else
        begin
            TextColor(Yellow);
            tmpPosX := cur^.data.posX;
            tmpPosY := cur^.data.posY;
            cur^.data.posX := curPosX;
            cur^.data.posY := curPosY;
            GotoXY(cur^.data.PosX, cur^.data.PosY);
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
begin
    clrscr;
    saveTextAttr := TextAttr;

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
        if KeyPressed then
        begin
            GetKey(keyCode);
            case keyCode of
                -75: { left }
                begin
                    MoveSnake(snake, left);
                end;
                -77: { right }
                begin
                    MoveSnake(snake, right);
                end;
                -72: { up }
                begin
                    MoveSnake(snake, up);
                end;
                -80: { down }
                begin
                    MoveSnake(snake, down);
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
