implement MkSnakeIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkSnakeIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

OX: con 2;	# grid origin
OY: con 2;
CELL: con 6;	# cell size in pixels

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;

	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "mksnakeicon: no display: %r\n");
		return;
	}

	W := 28;
	H := 28;
	all := Rect(Point(0,0), Point(W,H));

	# --- the .bit (CMAP8 colour image) ---
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	# Dark playfield.
	field := display.rgb(16, 36, 28);
	icon.draw(all, field, nil, Point(0,0));

	# Snake body: a connected path of cells (c,r), head first.
	xs := array[] of {0, 1, 2, 2, 2, 3, 3};
	ys := array[] of {0, 0, 0, 1, 2, 2, 3};
	for(i := 0; i < len xs; i++)
		block(icon, xs[i], ys[i], 64, 200, 84);	# bright green

	# Eyes on the head cell (faces right, toward the next segment).
	hx := OX + xs[0]*CELL;
	hy := OY + ys[0]*CELL;
	black := display.rgb(10, 20, 12);
	icon.draw(Rect(Point(hx+4,hy+1), Point(hx+5,hy+2)), black, nil, Point(0,0));
	icon.draw(Rect(Point(hx+4,hy+3), Point(hx+5,hy+4)), black, nil, Point(0,0));

	# Food: a red apple in an empty cell, with a small highlight.
	fc := 0; fr := 2;
	fx := OX + fc*CELL + CELL/2;
	fy := OY + fr*CELL + CELL/2;
	red   := display.rgb(220, 48, 40);
	white := display.white;
	icon.fillellipse(Point(fx,fy), 2, 2, red, Point(0,0));
	icon.draw(Rect(Point(fx-1,fy-1), Point(fx,fy)), white, nil, Point(0,0));

	# --- the .mask (GREY1: white = opaque). Full square. ---
	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Snake/icons/!Snake.bit",  icon);
	writeimg("/usr/inferno/!Snake/icons/!Snake.mask", mask);
	sys->print("wrote !Snake.bit and !Snake.mask\n");
}

# Draw one beveled snake segment at grid cell (c,r).
block(img: ref Image, c, r, red, grn, blu: int)
{
	x := OX + c*CELL;
	y := OY + r*CELL;
	base := display.rgb(red, grn, blu);
	lite := display.rgb(clamp(red+70), clamp(grn+70), clamp(blu+70));
	dark := display.rgb(clamp(red-70), clamp(grn-70), clamp(blu-70));

	img.draw(Rect(Point(x,y), Point(x+CELL,y+CELL)), base, nil, Point(0,0));
	img.draw(Rect(Point(x,y), Point(x+CELL,y+1)), lite, nil, Point(0,0));	# top
	img.draw(Rect(Point(x,y), Point(x+1,y+CELL)), lite, nil, Point(0,0));	# left
	img.draw(Rect(Point(x,y+CELL-1), Point(x+CELL,y+CELL)), dark, nil, Point(0,0));	# bottom
	img.draw(Rect(Point(x+CELL-1,y), Point(x+CELL,y+CELL)), dark, nil, Point(0,0));	# right
}

clamp(v: int): int
{
	if(v < 0)
		return 0;
	if(v > 255)
		return 255;
	return v;
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mksnakeicon: create %s: %r\n", path);
		return;
	}
	if(display.writeimage(fd, img) < 0)
		sys->fprint(sys->fildes(2), "mksnakeicon: writeimage %s: %r\n", path);
}
