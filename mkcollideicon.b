implement MkCollideIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkCollideIcon: module
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
	bg := display.rgb(220, 224, 232);
	icon.draw(all, bg, nil, Point(0,0));

	red    := display.rgb(220, 60, 56);
	rhi    := display.rgb(250, 150, 146);
	blue   := display.rgb(60, 120, 220);
	bhi    := display.rgb(140, 190, 240);
	spark  := display.rgb(244, 210, 64);

	# Two balls overlapping at the collision point ~(14,14).
	icon.fillellipse(Point(9,17), 6, 6, red, Point(0,0));
	icon.fillellipse(Point(7,15), 2, 2, rhi, Point(0,0));
	icon.fillellipse(Point(20,12), 6, 6, blue, Point(0,0));
	icon.fillellipse(Point(18,10), 2, 2, bhi, Point(0,0));

	# Sparks radiating from the collision.
	c := Point(14, 15);
	rays := array[] of {
		Point(c.x, c.y-7), Point(c.x+6, c.y-5),
		Point(c.x+7, c.y), Point(c.x-7, c.y),
		Point(c.x-6, c.y-5),
	};
	for(i := 0; i < len rays; i++)
		icon.line(c, rays[i], Draw->Endsquare, Draw->Endsquare, 0, spark, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Collide/icons/!Collide.bit",  icon);
	writeimg("/usr/inferno/!Collide/icons/!Collide.mask", mask);
	sys->print("wrote !Collide\n");
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
