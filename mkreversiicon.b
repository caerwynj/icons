implement MkReversiIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkReversiIcon: module
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
		sys->fprint(sys->fildes(2), "mkreversiicon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	board := display.rgb(30, 120, 60);	# green felt
	grid  := display.rgb(18, 80, 40);	# darker grid lines
	icon.draw(all, board, nil, Point(0,0));

	# Grid lines for a 4x4 board.
	for(i := 0; i <= 4; i++) {
		gx := OX + i*CELL;
		icon.draw(Rect(Point(gx,OY), Point(gx+1,OY+4*CELL)), grid, nil, Point(0,0));
		gy := OY + i*CELL;
		icon.draw(Rect(Point(OX,gy), Point(OX+4*CELL,gy+1)), grid, nil, Point(0,0));
	}

	black := display.rgb(20, 20, 20);
	white := display.white;

	# Othello-style position: centre four plus a couple of captures.
	disc(icon, 1, 1, white);
	disc(icon, 2, 2, white);
	disc(icon, 2, 1, black);
	disc(icon, 1, 2, black);
	disc(icon, 3, 2, white);
	disc(icon, 0, 1, black);

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Reversi/icons/!Reversi.bit",  icon);
	writeimg("/usr/inferno/!Reversi/icons/!Reversi.mask", mask);
	sys->print("wrote !Reversi\n");
}

disc(img: ref Image, c, r: int, src: ref Image)
{
	cx := OX + c*CELL + CELL/2;
	cy := OY + r*CELL + CELL/2;
	img.fillellipse(Point(cx,cy), 2, 2, src, Point(0,0));
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkreversiicon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
