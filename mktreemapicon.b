implement MkTreemapIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkTreemapIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) { sys->fprint(sys->fildes(2), "no display: %r\n"); return; }

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	# Dark grid background shows through as 1px gutters between cells.
	gutter := display.rgb(40, 44, 52);
	icon.draw(all, gutter, nil, Point(0,0));

	# Nested rectangles of varying sizes (squarified-treemap style layout).
	tile(icon, Rect(Point(1,1),  Point(15,16)), 60, 130, 220);	# big blue
	tile(icon, Rect(Point(1,17), Point(15,27)), 70, 180, 100);	# green
	tile(icon, Rect(Point(16,1), Point(27,10)), 235, 150, 50);	# orange
	tile(icon, Rect(Point(16,11),Point(22,21)), 220, 60, 56);	# red
	tile(icon, Rect(Point(23,11),Point(27,21)), 170, 80, 200);	# purple
	tile(icon, Rect(Point(16,22),Point(27,27)), 60, 200, 220);	# cyan

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Treemap/icons/!Treemap.bit",  icon);
	writeimg("/usr/inferno/!Treemap/icons/!Treemap.mask", mask);
	sys->print("wrote !Treemap\n");
}

tile(img: ref Image, r: Rect, red, grn, blu: int)
{
	img.draw(r, display.rgb(red, grn, blu), nil, Point(0,0));
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
