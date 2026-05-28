implement MkConnect4Icon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkConnect4Icon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

OX: con 2;
OY: con 2;
CELL: con 6;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "mkconnect4icon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	bg := display.rgb(220, 224, 230);
	icon.draw(all, bg, nil, Point(0,0));

	# Blue board.
	blue := display.rgb(40, 80, 200);
	icon.draw(Rect(Point(2,2), Point(26,26)), blue, nil, Point(0,0));

	empty := display.rgb(232, 234, 240);
	red   := display.rgb(220, 50, 45);
	yel   := display.rgb(242, 208, 40);

	# 4x4 grid of holes; 0 empty, 1 red, 2 yellow. Discs obey gravity.
	E := 0; R := 1; Y := 2;
	g := array[4] of array of int;
	g[0] = array[] of {E, E, E, E};
	g[1] = array[] of {E, E, R, E};
	g[2] = array[] of {E, Y, R, E};
	g[3] = array[] of {Y, Y, R, Y};

	for(r := 0; r < 4; r++)
		for(c := 0; c < 4; c++) {
			src := empty;
			if(g[r][c] == R)
				src = red;
			else if(g[r][c] == Y)
				src = yel;
			cx := OX + c*CELL + CELL/2;
			cy := OY + r*CELL + CELL/2;
			icon.fillellipse(Point(cx,cy), 2, 2, src, Point(0,0));
		}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Connect4/icons/!Connect4.bit",  icon);
	writeimg("/usr/inferno/!Connect4/icons/!Connect4.mask", mask);
	sys->print("wrote !Connect4\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkconnect4icon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
