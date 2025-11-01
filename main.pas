program SnakeGame;
uses crt,
    { my unit }
    GetKeyU, mDataTypesU, LadderU;

const
    SNAKE_HEAD_CHAR = '@';
    SNAKE_BODY_CHAR = '*';
    BORDER_CHAR = '#';
    STAR_CHAR = '0';
    SCORE_STEP = 100;

type
    TItem = record
        posX, posY: integer;
    end;
    TQPointForSnake = ^TQSnake;
    TQSnake = record
        data: TItem;
        next: TQPointForSnake;
    end;
    TQSnakeR = record
        first, last: TQPointForSnake;
    end;

{ #global var }
var
    saveTextAttr: integer;
    gameScore: integer;

procedure QPutSnakeItem(var q: TQSnakeR; item: TItem);
begin
    if q.first = nil then
    begin
        new(q.first);
        q.last := q.first
    end
    else
    begin
        new(q.last^.next);
        q.last := q.last^.next
    end;
    q.last^.data := item;
    q.last^.next := nil
end;

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
                write(BORDER_CHAR);
            end;
        end;
    end;
    GotoXY(1, 1);
end;

function CheckBorderLimits(itemPosX, itemPosY: integer): boolean;
begin
    if ((itemPosX = 1) or (itemPosX = ScreenWidth)) or
       ((itemPosY = 1) or (itemPosY = ScreenHeight-1)) then
    begin
        CheckBorderLimits := false
    end
    else
        CheckBorderLimits := true;
end;

procedure SpawnItem(x, y: integer; item: char);
begin
    GotoXY(x, y);
    write(item);
    GotoXY(1, 1);
end;

procedure SystemKeyWatcher(var keyCode: integer);
begin
    if KeyPressed then
    begin
        GetKey(keyCode);
        case keyCode of
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
procedure WriteSnake(var snake: TQSnakeR);
var
    cur: TQPointForSnake;
begin
    cur := snake.first;
    while cur <> nil do
    begin
        GotoXY(cur^.data.posX, cur^.data.posY);
        write(SNAKE_BODY_CHAR);
        GotoXY(1, 1);
        cur := cur^.next;
    end;
end;
}

{ ? }
procedure MoveSnake(
    var snakePosX, snakePosY: integer;
    var snake: TQSnakeR;
    keyCode: integer
);
begin
    GotoXY(snakePosX, snakePosY);
    write(' ');

    case keyCode of
        -75: { left }
        begin
            snakePosX := snakePosX - 1;
        end;
        -77: { right }
        begin
            snakePosX := snakePosX + 1;
        end;
        -72: { up }
        begin
            snakePosY := snakePosY - 1;
        end;
        -80: { down }
        begin
            snakePosY := snakePosY + 1;
        end;
        else
        begin
            snakePosX := snakePosX - 1;
        end;
    end;

    if not CheckBorderLimits(snakePosX, snakePosY) then
    begin
        GameOver;
    end;

    {WriteSnake(snake);}
    GotoXY(snakePosX, snakePosY);
    write(SNAKE_HEAD_CHAR);
    GotoXY(1, 1);
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

procedure AddElementToSnakeQueue(var snake: TQSnakeR; item: TItem);
begin
    QPutSnakeItem(snake, item);
end;

var
    snakePosX, snakePosY: integer;
    itemPosX, itemPosY: integer;
    keyCode: integer;
    snake: TQSnakeR;
    item: TItem;
begin
    clrscr;
    randomize;
    saveTextAttr := TextAttr;

    { snake init }
    snake.first := nil;
    snake.last := nil;

    gameScore := 0;
    WriteBorder;

    CheckPositionForSpawn(snakePosX, snakePosY);
    SpawnItem(snakePosX, snakePosY, SNAKE_HEAD_CHAR);
    CheckPositionForSpawn(itemPosX, itemPosY);
    SpawnItem(itemPosX, itemPosY, STAR_CHAR);

    while true do
    begin
        SystemKeyWatcher(keyCode);
        MoveSnake(snakePosX, snakePosY, snake, keyCode);

        if TouchStar(snakePosX, snakePosY, itemPosX, itemPosY) then
        begin
            GotoXY(1, 1);
            write('touch');
            gameScore := gameScore + SCORE_STEP;
            readln;

            AddElementToSnakeQueue(snake, item);

            CheckPositionForSpawn(itemPosX, itemPosY);
            SpawnItem(itemPosX, itemPosY, STAR_CHAR);
        end;
        delay(120);
    end;
end.
