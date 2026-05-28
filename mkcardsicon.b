implement MkCardsIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkCardsIcon: module
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
		sys->fprint(sys->fildes(2), "mkcardsicon: no display: %r\n");
		return;
	}

	all := Rect(Point(0,0), Point(28,28));
	icon := display.newimage(all, draw->CMAP8, 0, draw->White);

	green := display.rgb(34, 120, 64);	# card-table felt
	icon.draw(all, green, nil, Point(0,0));

	border := display.rgb(60, 60, 60);
	wht    := display.white;
	black  := display.rgb(20, 20, 20);
	red    := display.rgb(210, 40, 40);

	# Back card (spade), offset down-left.
	card(icon, Rect(Point(4,7),  Point(17,25)), border, wht);
	spade(icon, Point(10,16), black);

	# Front card (heart), offset up-right and overlapping.
	card(icon, Rect(Point(12,3), Point(25,21)), border, wht);
	heart(icon, Point(18,12), red);

	mask := display.newimage(all, draw->GREY1, 0, draw->White);

	writeimg("/usr/inferno/!Cards/icons/!Cards.bit",  icon);
	writeimg("/usr/inferno/!Cards/icons/!Cards.mask", mask);
	sys->print("wrote !Cards\n");
}

# A white card with a 1px dark border.
card(img: ref Image, r: Rect, border, face: ref Image)
{
	img.draw(r, border, nil, Point(0,0));
	inner := Rect(Point(r.min.x+1, r.min.y+1), Point(r.max.x-1, r.max.y-1));
	img.draw(inner, face, nil, Point(0,0));
}

# Heart centred at c.
heart(img: ref Image, c: Point, src: ref Image)
{
	img.fillellipse(Point(c.x-2, c.y-1), 2, 2, src, Point(0,0));
	img.fillellipse(Point(c.x+2, c.y-1), 2, 2, src, Point(0,0));
	pts := array[] of {
		Point(c.x-4, c.y), Point(c.x+4, c.y), Point(c.x, c.y+5),
	};
	img.fillpoly(pts, 1, src, Point(0,0));
}

# Spade centred at c.
spade(img: ref Image, c: Point, src: ref Image)
{
	img.fillellipse(Point(c.x-2, c.y), 2, 2, src, Point(0,0));
	img.fillellipse(Point(c.x+2, c.y), 2, 2, src, Point(0,0));
	pts := array[] of {
		Point(c.x, c.y-5), Point(c.x-4, c.y+1), Point(c.x+4, c.y+1),
	};
	img.fillpoly(pts, 1, src, Point(0,0));
	# stem
	img.draw(Rect(Point(c.x-1, c.y), Point(c.x+1, c.y+5)), src, nil, Point(0,0));
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "mkcardsicon: create %s: %r\n", path);
		return;
	}
	display.writeimage(fd, img);
}
