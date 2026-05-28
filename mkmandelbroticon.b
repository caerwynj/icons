implement MkMandelbrotIcon;

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;

MkMandelbrotIcon: module
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

	maxit := 28;
	# Escape-iteration palette (reused per pixel).
	pal := array[maxit+1] of ref Image;
	for(n := 0; n <= maxit; n++) {
		if(n >= maxit)
			pal[n] = display.rgb(0, 0, 0);		# inside the set
		else
			pal[n] = display.rgb(clamp(n*10), clamp(n*7), clamp(70+n*6));
	}

	# Compute the Mandelbrot set over c in [-2.2,0.8] x [-1.5,1.5].
	for(py := 0; py < 28; py++)
		for(px := 0; px < 28; px++) {
			cx := -2.2 + (real px)*(3.0/28.0);
			cy := -1.5 + (real py)*(3.0/28.0);
			zx := 0.0; zy := 0.0;
			n := 0;
			while(n < maxit && zx*zx + zy*zy <= 4.0) {
				t := zx*zx - zy*zy + cx;
				zy = 2.0*zx*zy + cy;
				zx = t;
				n++;
			}
			icon.draw(Rect(Point(px,py), Point(px+1,py+1)), pal[n], nil, Point(0,0));
		}

	mask := display.newimage(all, draw->GREY1, 0, draw->White);
	writeimg("/usr/inferno/!Mandelbrot/icons/!Mandelbrot.bit",  icon);
	writeimg("/usr/inferno/!Mandelbrot/icons/!Mandelbrot.mask", mask);
	sys->print("wrote !Mandelbrot\n");
}

clamp(v: int): int
{
	if(v < 0) return 0;
	if(v > 255) return 255;
	return v;
}

writeimg(path: string, img: ref Image)
{
	fd := sys->create(path, Sys->OWRITE, 8r644);
	if(fd == nil) { sys->fprint(sys->fildes(2), "create %s: %r\n", path); return; }
	display.writeimage(fd, img);
}
