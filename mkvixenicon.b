implement MkVixenIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkVixenIcon: module
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

	orange := display.rgb(228, 124, 46);
	dorng  := display.rgb(160, 78, 26);
	wht    := display.white;
	blk    := display.rgb(20, 20, 24);

	# Ears (outer + inner darker).
	filltri(icon, Point(3,4),  Point(11,3), Point(10,13), orange);
	filltri(icon, Point(25,4), Point(17,3), Point(18,13), orange);
	filltri(icon, Point(5,5),  Point(10,4), Point(10,10), dorng);
	filltri(icon, Point(23,5), Point(18,4), Point(18,10), dorng);

	# Face.
	filltri(icon, Point(4,10), Point(24,10), Point(14,25), orange);

	# White snout, black nose, eyes.
	icon.fillellipse(Point(14,21), 5, 3, wht, Point(0,0));
	icon.fillellipse(Point(14,20), 1, 1, blk, Point(0,0));
	icon.fillellipse(Point(10,15), 1, 2, blk, Point(0,0));
	icon.fillellipse(Point(18,15), 1, 2, blk, Point(0,0));

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Vixen/icons/!Vixen.bit",  icon);
	writeimg("/usr/inferno/!Vixen/icons/!Vixen.mask", mask);
	sys->print("wrote !Vixen\n");
}

# Scanline triangle fill (fillpoly is broken headless).
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
