implement MkPaintIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkPaintIcon: module
{
	init:	fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, nil: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "mkpainticon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	bg := display.rgb(206, 214, 224);
	icon.draw(all, bg, nil, Point(0,0));

	# Painter's palette.
	pal := display.rgb(202, 168, 120);
	icon.fillellipse(Point(14,16), 12, 8, pal, Point(0,0));
	# thumb hole (cut back to background)
	icon.fillellipse(Point(8,19), 2, 3, bg, Point(0,0));

	# Dabs of paint.
	icon.fillellipse(Point(8,9),  2, 2, display.rgb(220, 50, 50), Point(0,0));	# red
	icon.fillellipse(Point(14,8), 2, 2, display.rgb(240, 210, 50), Point(0,0));	# yellow
	icon.fillellipse(Point(20,9), 2, 2, display.rgb(60, 120, 220), Point(0,0));	# blue
	icon.fillellipse(Point(21,16),2, 2, display.rgb(60, 180, 90), Point(0,0));	# green

	# Brush: wooden handle with a dark ferrule/tip.
	icon.line(Point(17,25), Point(26,13), Draw->Endsquare, Draw->Endsquare, 1,
		display.rgb(150, 100, 50), Point(0,0));
	icon.line(Point(15,27), Point(18,23), Draw->Endsquare, Draw->Endsquare, 1,
		display.rgb(40, 40, 40), Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Paint/icons/!Paint.bit",  icon);
	writeimg("/usr/inferno/!Paint/icons/!Paint.mask", mask);
	sys->print("wrote !Paint\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkpainticon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
