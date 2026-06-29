implement Maskify;

#
# maskify [-c byte] [-q] <path.bit>...
#
# For each .bit file, derive a tight GREY1 mask by treating pixels
# whose CMAP8 byte equals the icon's background colour as
# transparent. By default the background is sampled from the
# corners of the .bit (the colour found in three of the four corners
# wins). Use -c <byte> to force a specific CMAP8 byte value as the
# background — useful when the icon's corner pixel is legitimately
# part of the icon.
#
# The generated mask is written next to the .bit:
#    /usr/inferno/!Calc/icons/!Calc.bit  ->  !Calc.mask
#
# Designed for the rectangular-mask !App icons produced by the
# mk*icon.b helpers under /home/caerwyn/github/icons/. Every one of
# those generators allocates the mask filled with draw->White and
# never modifies it; the result is that the icon's bbox shows
# through whatever desktop background it lands on (visible as a
# cream halo on pinboard). Run this tool once per .bit to write a
# silhouette-shaped mask.
#

include "sys.m";
	sys: Sys;
include "draw.m";
	draw: Draw;
	Display, Image, Rect, Point: import draw;
include "arg.m";

Maskify: module
{
	init: fn(ctxt: ref Draw->Context, argv: list of string);
};

display: ref Display;

init(nil: ref Draw->Context, argv: list of string)
{
	sys = load Sys Sys->PATH;
	draw = load Draw Draw->PATH;
	arg := load Arg Arg->PATH;

	bgforce := -1;
	quiet := 0;
	arg->init(argv);
	arg->setusage("maskify [-c byte] [-q] <path.bit>...");
	while((c := arg->opt()) != 0)
		case c {
		'c' =>
			bgforce = int arg->earg();
		'q' =>
			quiet = 1;
		* =>
			arg->usage();
		}
	argv = arg->argv();
	if(argv == nil)
		arg->usage();

	display = Display.allocate(nil);
	if(display == nil) {
		sys->fprint(sys->fildes(2), "maskify: no display: %r\n");
		raise "fail:nodisplay";
	}

	for(; argv != nil; argv = tl argv)
		maskify(hd argv, bgforce, quiet);
}

maskify(bitpath: string, bgforce, quiet: int)
{
	# Derive .mask path from .bit path: strip ".bit", append ".mask".
	if(len bitpath < 4 || bitpath[len bitpath-4:] != ".bit") {
		sys->fprint(sys->fildes(2), "maskify: %s: expected a .bit path\n", bitpath);
		return;
	}
	maskpath := bitpath[0:len bitpath-4] + ".mask";

	icon := display.open(bitpath);
	if(icon == nil) {
		sys->fprint(sys->fildes(2), "maskify: open %s: %r\n", bitpath);
		return;
	}
	if(icon.depth != 8) {
		sys->fprint(sys->fildes(2), "maskify: %s: only CMAP8 .bit files supported (depth=%d)\n",
			bitpath, icon.depth);
		return;
	}

	w := icon.r.max.x - icon.r.min.x;
	h := icon.r.max.y - icon.r.min.y;
	if(w <= 0 || h <= 0) {
		sys->fprint(sys->fildes(2), "maskify: %s: empty rect\n", bitpath);
		return;
	}
	pixels := array[w*h] of byte;
	if(icon.readpixels(icon.r, pixels) != len pixels) {
		sys->fprint(sys->fildes(2), "maskify: %s: short readpixels: %r\n", bitpath);
		return;
	}

	bg: int;
	if(bgforce >= 0) {
		bg = bgforce;
	} else {
		# Sample the four corners; pick the byte that appears at
		# the most corners. Ties go to the top-left corner.
		c1 := int pixels[0];
		c2 := int pixels[w-1];
		c3 := int pixels[(h-1)*w];
		c4 := int pixels[h*w-1];
		bg = vote(c1, c2, c3, c4);
	}

	# Build the packed depth-1 mask: 1 where pixel != bg, 0 where ==.
	# Each row is rounded up to a whole byte; bit 7 of each byte is
	# the leftmost pixel, matching how Inferno's GREY1 is encoded
	# (verified empirically by `imgshow` reading existing .mask files).
	rowbytes := (w + 7) / 8;
	mbuf := array[rowbytes*h] of byte;
	for(i := 0; i < len mbuf; i++)
		mbuf[i] = byte 0;
	nset := 0;
	for(y := 0; y < h; y++) {
		for(x := 0; x < w; x++) {
			if(int pixels[y*w + x] != bg) {
				mbuf[y*rowbytes + x/8] |= byte (1 << (7 - x%8));
				nset++;
			}
		}
	}

	mask := display.newimage(icon.r, draw->GREY1, 0, draw->Black);
	if(mask == nil) {
		sys->fprint(sys->fildes(2), "maskify: %s: newimage GREY1 failed: %r\n", bitpath);
		return;
	}
	if(mask.writepixels(icon.r, mbuf) != len mbuf) {
		sys->fprint(sys->fildes(2), "maskify: %s: writepixels short: %r\n", bitpath);
		return;
	}

	fd := sys->create(maskpath, Sys->OWRITE, 8r644);
	if(fd == nil) {
		sys->fprint(sys->fildes(2), "maskify: create %s: %r\n", maskpath);
		return;
	}
	if(display.writeimage(fd, mask) < 0) {
		sys->fprint(sys->fildes(2), "maskify: writeimage %s: %r\n", maskpath);
		return;
	}
	if(!quiet)
		sys->print("%s: bg=%d, %d/%d pixels visible\n",
			maskpath, bg, nset, w*h);
}

# Pick the most common of four corner values; on tie prefer top-left.
vote(a, b, c, d: int): int
{
	ca := count4(a, a, b, c, d);
	cb := count4(b, a, b, c, d);
	cc := count4(c, a, b, c, d);
	cd := count4(d, a, b, c, d);
	best := a;
	bestc := ca;
	if(cb > bestc) {
		best = b;
		bestc = cb;
	}
	if(cc > bestc) {
		best = c;
		bestc = cc;
	}
	if(cd > bestc) {
		best = d;
		bestc = cd;
	}
	return best;
}

count4(v, a, b, c, d: int): int
{
	n := 0;
	if(a == v)
		n++;
	if(b == v)
		n++;
	if(c == v)
		n++;
	if(d == v)
		n++;
	return n;
}
