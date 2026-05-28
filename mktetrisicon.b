implement MkTetrisIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkTetrisIcon: module
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
		sys->fprint(sys->fildes(2), "mktetrisicon: no display: %r\n");
		return;
	}

	W := 28;
	H := 28;
	all := Rect(Point(0,0), Point(W,H));

	# --- the .bit (CMAP8 colour image) ---
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	# Dark navy "well"; the 2px border and 1px bevels show through as grid.
	well := display.rgb(24, 24, 48);
	icon.draw(all, well, nil, Point(0,0));

	# Four interlocking tetrominoes packed into a 4x4 grid.
	# I (cyan) across the top, O (yellow), and purple / orange pieces below.
	C := 0; Y := 1; P := 2; O := 3;	# colour ids, -1 = empty well
	grid := array[4] of array of int;
	grid[0] = array[] of {C,  C,  C,  C};
	grid[1] = array[] of {Y,  Y, -1,  P};
	grid[2] = array[] of {Y,  Y,  P,  P};
	grid[3] = array[] of {O,  O,  O,  P};

	for(r := 0; r < 4; r++)
		for(c := 0; c < 4; c++) {
			id := grid[r][c];
			if(id == C)
				block(icon, c, r,  40, 200, 220);	# cyan
			else if(id == Y)
				block(icon, c, r, 230, 200,  40);	# yellow
			else if(id == P)
				block(icon, c, r, 170,  70, 200);	# purple
			else if(id == O)
				block(icon, c, r, 235, 140,  40);	# orange
		}

	# --- the .mask (GREY1: white = opaque). The icon is a full square. ---
	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Tetris/icons/!Tetris.bit",  icon);
	writeimg("/usr/inferno/!Tetris/icons/!Tetris.mask", mask);
	sys->print("wrote !Tetris.bit and !Tetris.mask\n");
}

# Draw one beveled tetris block at grid cell (c,r): light top/left edge,
# dark bottom/right edge, for the classic 3D look.
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
		sys->fprint(sys->fildes(2), "mktetrisicon: create %s: %r\n", path);
		return;
	}
	if(display.writeimage(fd, img) < 0)
		sys->fprint(sys->fildes(2), "mktetrisicon: writeimage %s: %r\n", path);
}
