program Snake;
uses crt,
    { my unit }
    GetKeyU, mDataTypesU, LadderU;

const
    SNAKE_HEAD_CHAR = '@';
    SNAKE_BODY_CHAR = '*';
    BORDER_CHAR = '#';
    STAR_CHAR = '0';
    SCORE_STEP = 100;

{ #global var }
var
    saveTextAttr: integer;
    gameScore: integer;

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

procedure MoveSnake(var snakePosX, snakePosY, keyCode: integer);
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

var
    snakePosX, snakePosY: integer;
    itemPosX, itemPosY: integer;
    keyCode: integer;
begin
    clrscr;
    randomize;
    saveTextAttr := TextAttr;

    gameScore := 0;
    WriteBorder;

    CheckPositionForSpawn(snakePosX, snakePosY);
    SpawnItem(snakePosX, snakePosY, SNAKE_HEAD_CHAR);
    CheckPositionForSpawn(itemPosX, itemPosY);
    SpawnItem(itemPosX, itemPosY, STAR_CHAR);

    while true do
    begin
        SystemKeyWatcher(keyCode);
        MoveSnake(snakePosX, snakePosY, keyCode);

        if TouchStar(snakePosX, snakePosY, itemPosX, itemPosY) then
        begin
            GotoXY(1, 1);
            write('touch');
            gameScore := gameScore + SCORE_STEP;
            readln;

            CheckPositionForSpawn(itemPosX, itemPosY);
            SpawnItem(itemPosX, itemPosY, STAR_CHAR);
        end;
        delay(120);
    end;
end.
