uses crt;

type
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

var
    item: TItem;
    i: integer;
    q: TQR;
    curPointer: TQP;
begin
    clrscr;

    QInit(q);

    i := 1;
    while i < 10 do
    begin
        CreateItem(item, i+4, 4, '*');
        QPutItem(q, item);
        inc(i);
    end;

    curPointer := q.first;
    while curPointer <> nil do
    begin
        GotoXY(curPointer^.data.posX, curPointer^.data.posY);
        write(curPointer^.data.smbl);
        
        curPointer := curPointer^.next;
    end;

    curPointer := q.first;
    while curPointer <> nil do
    begin
        GotoXY(curPointer^.data.posX, curPointer^.data.posY);
        write(curPointer^.data.smbl);
        
        curPointer := curPointer^.next;
    end;

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
    

    readln;
    clrscr;
end.
