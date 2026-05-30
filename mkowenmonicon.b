implement MkOwenMonIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkOwenMonIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

OX: con 3;
OY: con 3;
CELL: con 7;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) { sys->fprint(sys->fildes(2), "no display: %r\n"); return; }

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);
	bg := display.rgb(216, 220, 228);
	icon.draw(all, bg, nil, Point(0,0));

	node := display.rgb(72, 78, 90);
	green := display.rgb(80, 220, 110);
	red   := display.rgb(220, 60, 56);
	amber := display.rgb(240, 200, 60);

	# Grid of node tiles, each with a status LED.
	state := array[3] of array of int;
	state[0] = array[] of {1, 1, 1};	# 0 down, 1 ok, 2 warn
	state[1] = array[] of {1, 2, 1};
	state[2] = array[] of {1, 1, 0};
	for(r := 0; r < 3; r++)
		for(c := 0; c < 3; c++) {
			x := OX + c*CELL;
			y := OY + r*CELL;
			icon.draw(Rect(Point(x,y), Point(x+CELL-1,y+CELL-1)), node, nil, Point(0,0));
			led := green;
			if(state[r][c] == 2) led = amber;
			if(state[r][c] == 0) led = red;
			icon.fillellipse(Point(x+CELL/2, y+CELL/2), 1, 1, led, Point(0,0));
		}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!OwenMon/icons/!OwenMon.bit",  icon);
	writeimg("/usr/inferno/!OwenMon/icons/!OwenMon.mask", mask);
	sys->print("wrote !OwenMon\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
