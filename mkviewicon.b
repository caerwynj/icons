implement MkViewIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkViewIcon: module
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
	bg := display.rgb(216, 220, 228);
	icon.draw(all, bg, nil, Point(0,0));

	frame  := display.rgb(60, 60, 70);
	sky    := display.rgb(140, 198, 240);
	ground := display.rgb(110, 170, 90);
	mtn    := display.rgb(98, 110, 130);
	mtn2   := display.rgb(70, 82, 100);
	sun    := display.rgb(248, 210, 70);

	# Photo frame with picture inside.
	icon.draw(Rect(Point(3,4),  Point(25,24)), frame, nil, Point(0,0));
	icon.draw(Rect(Point(4,5),  Point(24,18)), sky, nil, Point(0,0));
	icon.draw(Rect(Point(4,18), Point(24,23)), ground, nil, Point(0,0));

	# Sun.
	icon.fillellipse(Point(19,9), 3, 3, sun, Point(0,0));

	# Mountains (back range darker, front range lighter).
	filltri(icon, Point(4,18),  Point(13,9),  Point(18,18), mtn);
	filltri(icon, Point(11,18), Point(20,12), Point(24,18), mtn2);

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!View/icons/!View.bit",  icon);
	writeimg("/usr/inferno/!View/icons/!View.mask", mask);
	sys->print("wrote !View\n");
}

filltri(img: ref Image, a, b, c: Point, src: ref Image)
{
	p := array[] of {a, b, c};
	ymin := a.y; ymax := a.y;
	for(k := 0; k < 3; k++) {
		if(p[k].y < ymin) ymin = p[k].y;
		if(p[k].y > ymax) ymax = p[k].y;
	}
	for(y := ymin; y <= ymax; y++) {
		xs := array[3] of int;
		nx := 0;
		for(k = 0; k < 3; k++) {
			p0 := p[k];
			p1 := p[(k+1)%3];
			if((p0.y <= y && p1.y > y) || (p1.y <= y && p0.y > y)) {
				xs[nx] = p0.x + (p1.x-p0.x)*(y-p0.y)/(p1.y-p0.y);
				nx++;
			}
		}
		if(nx >= 2) {
			lo := xs[0]; hi := xs[0];
			for(j := 1; j < nx; j++) {
				if(xs[j] < lo) lo = xs[j];
				if(xs[j] > hi) hi = xs[j];
			}
			img.draw(Rect(Point(lo,y), Point(hi+1,y+1)), src, nil, Point(0,0));
		}
	}
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
