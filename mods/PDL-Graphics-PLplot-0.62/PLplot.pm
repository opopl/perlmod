
#
# GENERATED WITH PDL::PP! Don't modify!
#
package PDL::Graphics::PLplot;

@EXPORT_OK  = qw( PL_PARSE_PARTIAL PL_PARSE_FULL PL_PARSE_QUIET PL_PARSE_NODELETE PL_PARSE_SHOWALL PL_PARSE_OVERRIDE PL_PARSE_NOPROGRAM PL_PARSE_NODASH PL_PARSE_SKIP DRAW_LINEX DRAW_LINEY DRAW_LINEXY MAG_COLOR BASE_CONT TOP_CONT SURF_CONT DRAW_SIDES FACETED MESH PL_FCI_SANS PL_FCI_MONO PLK_BackSpace PLK_Tab PLK_Linefeed PLK_Return PLK_Escape PLK_Delete PLK_Clear PLK_Pause PLK_Scroll_Lock PLK_Home PLK_Left PLK_Up PLK_Right PLK_Down PLK_Prior PLK_Next PLK_End PLK_Begin PLK_Select PLK_Print PLK_Execute PLK_Insert PLK_Undo PLK_Redo PLK_Menu PLK_Find PLK_Cancel PLK_Help PLK_Break PLK_Mode_switch PLK_script_switch PLK_Num_Lock PLK_KP_Space PLK_KP_Tab PLK_KP_Enter PLK_KP_F1 PLK_KP_F2 PLK_KP_F3 PLK_KP_F4 PLK_KP_Equal PLK_KP_Multiply PLK_KP_Add PLK_KP_Separator PLK_KP_Subtract PLK_KP_Decimal PLK_KP_Divide PLK_KP_0 PLK_KP_1 PLK_KP_2 PLK_KP_3 PLK_KP_4 PLK_KP_5 PLK_KP_6 PLK_KP_7 PLK_KP_8 PLK_KP_9 PLK_F1 PLK_F2 PLK_F3 PLK_F4 PLK_F5 PLK_F6 PLK_F7 PLK_F8 PLK_F9 PLK_F10 PLK_F11 PLK_L1 PLK_F12 PLK_L2 PLK_F13 PLK_L3 PLK_F14 PLK_L4 PLK_F15 PLK_L5 PLK_F16 PLK_L6 PLK_F17 PLK_L7 PLK_F18 PLK_L8 PLK_F19 PLK_L9 PLK_F20 PLK_L10 PLK_F21 PLK_R1 PLK_F22 PLK_R2 PLK_F23 PLK_R3 PLK_F24 PLK_R4 PLK_F25 PLK_R5 PLK_F26 PLK_R6 PLK_F27 PLK_R7 PLK_F28 PLK_R8 PLK_F29 PLK_R9 PLK_F30 PLK_R10 PLK_F31 PLK_R11 PLK_F32 PLK_R12 PLK_R13 PLK_F33 PLK_F34 PLK_R14 PLK_F35 PLK_R15 PLK_Shift_L PLK_Shift_R PLK_Control_L PLK_Control_R PLK_Caps_Lock PLK_Shift_Lock PLK_Meta_L PLK_Meta_R PLK_Alt_L PLK_Alt_R PLK_Super_L PLK_Super_R PLK_Hyper_L PLK_Hyper_R GRID_CSA GRID_DTLI GRID_NNI GRID_NNIDW GRID_NNLI GRID_NNAIDW PL_X_AXIS PL_Y_AXIS PL_Z_AXIS PL_COLORBAR_SHADE PL_COLORBAR_SHADE_LABEL PL_COLORBAR_IMAGE PL_COLORBAR_GRADIENT PL_COLORBAR_CAP_LOW PL_COLORBAR_CAP_HIGH PL_COLORBAR_LABEL_LEFT PL_COLORBAR_LABEL_RIGHT PL_COLORBAR_LABEL_TOP PL_COLORBAR_LABEL_BOTTOM PL_LEGEND_BACKGROUND PL_LEGEND_BOUNDING_BOX PL_LEGEND_COLOR_BOX PL_LEGEND_LINE PL_LEGEND_NONE PL_LEGEND_ROW_MAJOR PL_LEGEND_SYMBOL PL_LEGEND_TEXT_LEFT PL_POSITION_BOTTOM PL_POSITION_INSIDE PL_POSITION_LEFT PL_POSITION_OUTSIDE PL_POSITION_RIGHT PL_POSITION_SUBPAGE PL_POSITION_TOP PL_POSITION_VIEWPORT plplot_use_standard_argument_order PDL::PP pladv plaxes PDL::PP plaxes_pp PDL::PP plbin plbop plbox PDL::PP plbox_pp plbox3 PDL::PP plbox3_pp plclear PDL::PP plcol0 PDL::PP plcol1 PDL::PP plcpstrm PDL::PP pldid2pc PDL::PP pldip2dc plend plend1 PDL::PP plenv PDL::PP plenv0 pleop PDL::PP plerrx PDL::PP plerry plfamadv PDL::PP plfill3 plflush PDL::PP plfont PDL::PP plfontld PDL::PP plgchr PDL::PP plgcompression PDL::PP plgdidev PDL::PP plgdiori PDL::PP plgdiplt PDL::PP plgfam PDL::PP plglevel PDL::PP plgpage plgra PDL::PP plgspa PDL::PP plgvpd PDL::PP plgvpw PDL::PP plgxax PDL::PP plgyax PDL::PP plgzax plinit PDL::PP pljoin pllab PDL::PP pllightsource PDL::PP pllsty plmtex PDL::PP plmtex_pp plmtex3 PDL::PP plmtex3_pp PDL::PP plpat PDL::PP plprec PDL::PP plpsty PDL::PP plptex PDL::PP plptex3 plreplot PDL::PP plschr PDL::PP plscmap0n PDL::PP plscmap1n PDL::PP plscol0 PDL::PP plscolbg PDL::PP plscolor PDL::PP plscompression plsdev PDL::PP plsdidev PDL::PP plsdimap PDL::PP plsdiori PDL::PP plsdiplt PDL::PP plsdiplz PDL::PP pl_setcontlabelparam PDL::PP pl_setcontlabelformat PDL::PP plsfam plsfnam PDL::PP plsmaj PDL::PP plsmin PDL::PP plsori PDL::PP plspage PDL::PP plspause PDL::PP plsstrm PDL::PP plssub PDL::PP plssym PDL::PP plstar plstart PDL::PP plstart_pp PDL::PP plstripa PDL::PP plstripd PDL::PP plsvpa PDL::PP plsxax PDL::PP plsxwin PDL::PP plsyax PDL::PP plszax pltext PDL::PP plvasp PDL::PP plvpas PDL::PP plvpor plvsta PDL::PP plw3d PDL::PP plwid PDL::PP plwind plsetopt PDL::PP plP_gpixmm PDL::PP plscolbga PDL::PP plscol0a PDL::PP plline PDL::PP plcolorpoints PDL::PP plsmem PDL::PP plfbox PDL::PP plunfbox PDL::PP plParseOpts PDL::PP plpoin PDL::PP plpoin3 PDL::PP plline3 PDL::PP plpoly3 PDL::PP plhist PDL::PP plfill PDL::PP plgradient PDL::PP plsym PDL::PP plsurf3d PDL::PP plstyl PDL::PP plseed PDL::PP plrandd pltr0 pltr1 pltr2 PDL::PP plAllocGrid plFreeGrid PDL::PP plAlloc2dGrid plFree2dGrid PDL::PP init_pltr plmap PDL::PP plmap_pp PDL::PP plstring PDL::PP plstring3 plmeridians PDL::PP plmeridians_pp plshades PDL::PP plshades_pp PDL::PP plcont PDL::PP plmesh PDL::PP plmeshc PDL::PP plot3d PDL::PP plot3dc PDL::PP plscmap1l plshade1 PDL::PP plshade1_pp PDL::PP plimage PDL::PP plimagefr plxormod plGetCursor plgstrm plgdev plgfnam plmkstrm plgver plstripc PDL::PP plstripc_pp PDL::PP plgriddata plarc plstransform plslabelfunc pllegend plspal0 plspal1 plbtime plconfigtime plctime pltimefmt plsesc PDL::PP plvect PDL::PP plsvect PDL::PP plhlsrgb PDL::PP plgcol0 PDL::PP plgcolbg PDL::PP plscmap0 PDL::PP plscmap1 PDL::PP plgcol0a PDL::PP plgcolbga PDL::PP plscmap0a PDL::PP plscmap1a PDL::PP plscmap1la PDL::PP plgfont PDL::PP plsfont PDL::PP plcalc_world  plgfci  plsfci );
%EXPORT_TAGS = (Func=>[@EXPORT_OK]);

use PDL::Core;
use PDL::Exporter;
use DynaLoader;



   
   @ISA    = ( 'PDL::Exporter','DynaLoader' );
   push @PDL::Core::PP, __PACKAGE__;
   bootstrap PDL::Graphics::PLplot ;





our $VERSION;
BEGIN {
$VERSION = '0.62'
};

=head1 NAME

PDL::Graphics::PLplot - Object-oriented interface from perl/PDL to the PLPLOT plotting library

=head1 SYNOPSIS

  use PDL;
  use PDL::Graphics::PLplot;

  my $pl = PDL::Graphics::PLplot->new (DEV => "png", FILE => "test.png");
  my $x  = sequence(10);
  my $y  = $x**2;
  $pl->xyplot($x, $y);
  $pl->close;

For more information on PLplot, see

 http://www.plplot.org/

Also see the test file, F<t/plplot.pl> in this distribution for some working examples.

=head1 LONG NAMES

If you are annoyed by the long constructor call, consider installing the
L<aliased|aliased> CPAN package. Using C<aliased>, the above example
becomes

  use PDL;
  use aliased 'PDL::Graphics::PLplot';

  my $pl = PLplot->new (DEV => "png", FILE => "test.png");
  my $x  = sequence(10);
  # etc, as above

=head1 DESCRIPTION

This is the PDL interface to the PLplot graphics library.  It provides
a familiar 'perlish' Object Oriented interface as well as access to
the low-level PLplot commands from the C-API.

=head1 OPTIONS

The following options are supported.  Most options can be used
with any function.  A few are only supported on the call to 'new'.

=head2 Options used upon creation of a PLplot object (with 'new'):

=head3 BACKGROUND

Set the color for index 0, the plot background

=head3 DEV

Set the output device type.  To see a list of allowed types, try:

  PDL::Graphics::PLplot->new();

=for example

   PDL::Graphics::PLplot->new(DEV => 'png', FILE => 'test.png');

=head3 FILE

Set the output file or display.  For file output devices, sets
the output file name.  For graphical displays (like C<'xwin'>) sets
the name of the display, eg (C<'hostname.foobar.com:0'>)

=for example

   PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png');
   PDL::Graphics::PLplot->new(DEV => 'xwin', FILE => ':0');

=head3 OPTS

Set plotting options.  See the PLplot documentation for the complete
listing of available options.  The value of C<'OPTS'> must be a hash
reference, whose keys are the names of the options.  For instance, to obtain
PostScript fonts with the ps output device, use:

=for example

   PDL::Graphics::PLplot->new(DEV => 'ps', OPTS => {drvopt => 'text=1'});

=head3 MEM

This option is used in conjunction with C<< DEV => 'mem' >>.  This option
takes as input a PDL image and allows one to 'decorate' it using PLplot.
The 'decorated' PDL image can then be written to an image file using,
for example, L<PDL::IO::Pic|PDL::IO::Pic>.  This option may not be available if
plplot does not include the 'mem' driver.

=for example

  # read in Earth image and draw an equator.
  my $pl = PDL::Graphics::PLplot->new (MEM => $earth, DEV => 'mem');
  my $x  = pdl(-180, 180);
  my $y  = zeroes(2);
  $pl->xyplot($x, $y,
              BOX => [-180,180,-90,90],
              VIEWPORT => [0.0, 1.0, 0.0, 1.0],
              XBOX => '', YBOX => '',
              PLOTTYPE => 'LINE');
  $pl->close;

=head3 FRAMECOLOR

Set color index 1, the frame color

=head3 JUST

A flag used to specify equal scale on the axes.  If this is
not specified, the default is to scale the axes to fit best on
the page.

=for example

  PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png', JUST => 1);

=head3 ORIENTATION

The orientation of the plot:

  0 --   0 degrees (landscape mode)
  1 --  90 degrees (portrait mode)
  2 -- 180 degrees (seascape mode)
  3 -- 270 degrees (upside-down mode)

Intermediate values (0.2) are acceptable if you are feeling daring.

=for example

  # portrait orientation
  PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png', ORIENTATION => 1);

=head3 PAGESIZE

Set the size in pixels of the output page.

=for example

  # PNG 500 by 600 pixels
  PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png', PAGESIZE => [500,600]);

=head3 SUBPAGES

Set the number of sub pages in the plot, [$nx, $ny]

=for example

  # PNG 300 by 600 pixels
  # Two subpages stacked on top of one another.
  PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png', PAGESIZE => [300,600],
                                              SUBPAGES => [1,2]);

=head2 Options used after initialization (after 'new')

=head3 BOX

Set the plotting box in world coordinates.  Used to explicitly
set the size of the plotting area.

=for example

 my $pl = PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png');
 $pl->xyplot ($x, $y, BOX => [0,100,0,200]);

=head3 CHARSIZE

Set the size of text in multiples of the default size.
C<< CHARSIZE => 1.5 >> gives characters 1.5 times the normal size.

=head3 COLOR

Set the current color for plotting and character drawing.
Colors are specified not as color indices but as RGB triples.
Some pre-defined triples are included:

  BLACK        GREEN        WHEAT        BLUE
  RED          AQUAMARINE   GREY         BLUEVIOLET
  YELLOW       PINK         BROWN        CYAN
  TURQUOISE    MAGENTA      SALMON       WHITE
  ROYALBLUE    DEEPSKYBLUE  VIOLET       STEELBLUE1
  DEEPPINK     MAGENTA      DARKORCHID1  PALEVIOLETRED2
  TURQUOISE1   LIGHTSEAGREEN SKYBLUE     FORESTGREEN
  CHARTREUSE3  GOLD2        SIENNA1      CORAL
  HOTPINK      LIGHTCORAL   LIGHTPINK1   LIGHTGOLDENROD

=for example

 # These two are equivalent:
 $pl->xyplot ($x, $y, COLOR => 'YELLOW');
 $pl->xyplot ($x, $y, COLOR => [0,255,0]);

=head3 CONTOURLABELS

Control of labels for contour plots.

Must either be 0 (turn off contour labels), 1 (turn on default contour labels)
or a five element array:

 offset:  Offset of label from contour line (if set to 0.0, labels are printed on the lines). Default value is 0.006.
 size:    Font height for contour labels (normalized). Default value is 0.3.
 spacing: Spacing parameter for contour labels. Default value is 0.1.
 lexp:    If the contour numerical label is greater than 10^(lexp) or less than 10^(-lexp),
          then the exponential format is used. Default value of lexp is 4.
 sigdig:  Number of significant digits. Default value is 2";

=for example

 $pl->shadeplot ($z, $nsteps, BOX => [-1, 1, -1, 1], PLOTTYPE => 'CONTOUR', CONTOURLABELS => [0.004, 0.2, 0.2, 4, 2]);
 $pl->shadeplot ($z, $nsteps, BOX => [-1, 1, -1, 1], PLOTTYPE => 'CONTOUR', CONTOURLABELS => 0); # turn off labels
 $pl->shadeplot ($z, $nsteps, BOX => [-1, 1, -1, 1], PLOTTYPE => 'CONTOUR', CONTOURLABELS => 1); # use default labels

=head3 LINEWIDTH

Set the line width for plotting.  Values range from 1 to a device dependent maximum.

=head3 LINESTYLE

Set the line style for plotting.  Pre-defined line styles use values 1 to 8, one being
a solid line, 2-8 being various dashed patterns.

=head3 MAJTICKSIZE

Set the length of major ticks as a fraction of the default setting.
One (default) means leave these ticks the normal size.

=head3 MINTICKSIZE

Set the length of minor ticks (and error bar terminals) as a fraction of the default setting.
One (default) means leave these ticks the normal size.

=head3 NXSUB

The number of minor tick marks between each major tick mark on the X axis.
Specify zero (default) to let PLplot compute this automatically.

=head3 NYSUB

The number of minor tick marks between each major tick mark on the Y axis.
Specify zero (default) to let PLplot compute this automatically.

=head3 PALETTE

Load pre-defined color map 1 color ranges.  Currently, values include:

  RAINBOW   -- from Red to Violet through the spectrum
  REVERSERAINBOW   -- Violet through Red
  GREYSCALE -- from black to white via grey.
  REVERSEGREYSCALE -- from white to black via grey.
  GREENRED  -- from green to red
  REDGREEN  -- from red to green

=for example

 # Plot x/y points with the z axis in color
 $pl->xyplot ($x, $y, PALETTE => 'RAINBOW', PLOTTYPE => 'POINTS', COLORMAP => $z);

=head3 PLOTTYPE

Specify which type of XY or shade plot is desired:

  LINE       -- A line
  POINTS     -- A bunch of symbols
  LINEPOINTS -- both

  or, for 'shadeplot':
  CONTOUR    -- A contour plot of 2D data
  SHADE      -- A shade plot of 2D data

=head3 SUBPAGE

Set which subpage to plot on.  Subpages are numbered 1 to N.
A zero can be specified meaning 'advance to the next subpage' (just a call to
L<pladv()|/pladv>).

=for example

  my $pl = PDL::Graphics::PLplot->new(DEV      => 'png',
                                        FILE     => 'test.png',
                                        SUBPAGES => [1,2]);
  $pl->xyplot ($x, $y, SUBPAGE => 1);
  $pl->xyplot ($a, $b, SUBPAGE => 2);


=head3 SYMBOL

Specify which symbol to use when plotting C<< PLOTTYPE => 'POINTS' >>.
A large variety of symbols are available, see:
http://plplot.sourceforge.net/examples-data/demo07/x07.*.png, where * is 01 - 17.
You are most likely to find good plotting symbols in the 800s:
http://plplot.sourceforge.net/examples-data/demo07/x07.06.png

=head3 SYMBOLSIZE

Specify the size of symbols plotted in multiples of the default size (1).
Value are real numbers from 0 to large.

=head3 TEXTPOSITION

Specify the placement of text.  Either relative to border, specified as:

 [$side, $disp, $pos, $just]

Where

  side = 't', 'b', 'l', or 'r' for top, bottom, left and right
  disp is the number of character heights out from the edge
  pos  is the position along the edge of the viewport, from 0 to 1.
  just tells where the reference point of the string is: 0 = left, 1 = right, 0.5 = center.

or inside the plot window, specified as:

 [$x, $y, $dx, $dy, $just]

Where

  x  = x coordinate of reference point of string.
  y  = y coordinate of reference point of string.
  dx   Together with dy, this specifies the inclination of the string.
       The baseline of the string is parallel to a line joining (x, y) to (x+dx, y+dy).
  dy   Together with dx, this specifies the inclination of the string.
  just Specifies the position of the string relative to its reference point.
       If just=0, the reference point is at the left and if just=1,
       it is at the right of the string. Other values of just give
       intermediate justifications.

=for example

 # Plot text on top of plot
 $pl->text ("Top label",  TEXTPOSITION => ['t', 4.0, 0.5, 0.5]);

 # Plot text in plotting area
 $pl->text ("Line label", TEXTPOSITION => [50, 60, 5, 5, 0.5]);

=head3 TITLE

Add a title on top of a plot.

=for example

 # Plot text on top of plot
 $pl->xyplot ($x, $y, TITLE => 'X vs. Y');

=head3 UNFILLED_BARS

For 'bargraph', if set to true then plot the bars as outlines
in the current color and not as filled boxes

=for example

 # Plot text on top of plot
 $pl->bargraph($labels, $values, UNFILLED_BARS => 1);

=head3 VIEWPORT

Set the location of the plotting window on the page.
Takes a four element array ref specifying:

 xmin -- The coordinate of the left-hand edge of the viewport. (0 to 1)
 xmax -- The coordinate of the right-hand edge of the viewport. (0 to 1)
 ymin -- The coordinate of the bottom edge of the viewport. (0 to 1)
 ymax -- The coordinate of the top edge of the viewport. (0 to 1)

You will need to use this to make color keys or insets.

=for example

 # Make a small plotting window in the lower left of the page
 $pl->xyplot ($x, $y, VIEWPORT => [0.1, 0.5, 0.1, 0.5]);

 # Also useful in creating color keys:
 $pl->xyplot   ($x, $y, PALETTE => 'RAINBOW', PLOTTYPE => 'POINTS', COLORMAP => $z);
 $pl->colorkey ($z, 'v', VIEWPORT => [0.93, 0.96, 0.15, 0.85]);

 # Plot an inset; first the primary data and then the inset. In this
 # case, the inset contains a selection of the orignal data
 $pl->xyplot ($x, $y);
 $pl->xyplot (where($x, $y, $x < 1.2), VIEWPORT => [0.7, 0.9, 0.6, 0.8]);

=head3 XBOX

Specify how to label the X axis of the plot as a string of option letters:

  a: Draws axis, X-axis is horizontal line (y=0), and Y-axis is vertical line (x=0).
  b: Draws bottom (X) or left (Y) edge of frame.
  c: Draws top (X) or right (Y) edge of frame.
  f: Always use fixed point numeric labels.
  g: Draws a grid at the major tick interval.
  h: Draws a grid at the minor tick interval.
  i: Inverts tick marks, so they are drawn outwards, rather than inwards.
  l: Labels axis logarithmically. This only affects the labels, not the data,
     and so it is necessary to compute the logarithms of data points before
     passing them to any of the drawing routines.
  m: Writes numeric labels at major tick intervals in the
     unconventional location (above box for X, right of box for Y).
  n: Writes numeric labels at major tick intervals in the conventional location
     (below box for X, left of box for Y).
  s: Enables subticks between major ticks, only valid if t is also specified.
  t: Draws major ticks.

The default is C<'BCNST'> which draws lines around the plot, draws major and minor
ticks and labels major ticks.

=for example

 # plot two lines in a box with independent X axes labeled
 # differently on top and bottom
 $pl->xyplot($x1, $y, XBOX  => 'bnst',  # bottom line, bottom numbers, ticks, subticks
	              YBOX  => 'bnst'); # left line, left numbers, ticks, subticks
 $pl->xyplot($x2, $y, XBOX => 'cmst', # top line, top numbers, ticks, subticks
	              YBOX => 'cst',  # right line, ticks, subticks
	              BOX => [$x2->minmax, $y->minmax]);

=head3 XERRORBAR

Used only with L</xyplot>.  Draws horizontal error bars at all points (C<$x>, C<$y>) in the plot.
Specify a PDL containing the same number of points as C<$x> and C<$y>
which specifies the width of the error bar, which will be centered at (C<$x>, C<$y>).

=head3 XLAB

Specify a label for the X axis.

=head3 XTICK

Interval (in graph units/world coordinates) between major x axis tick marks.
Specify zero (default) to allow PLplot to compute this automatically.

=head3 YBOX

Specify how to label the Y axis of the plot as a string of option letters.
See L</XBOX>.

=head3 YERRORBAR

Used only for xyplot.  Draws vertical error bars at all points (C<$x>, C<$y>) in the plot.
Specify a PDL containing the same number of points as C<$x> and C<$y>
which specifies the width of the error bar, which will be centered at (C<$x>, C<$y>).

=head3 YLAB

Specify a label for the Y axis.

=head3 YTICK

Interval (in graph units/world coordinates) between major y axis tick marks.
Specify zero (default) to allow PLplot to compute this automatically.

=head3 ZRANGE

For L</xyplot> (when C<COLORMAP> is specified), for
L</shadeplot> and for L</colorkey>.
Normally, the range of the Z variable (color) is taken as
C<< $z->minmax >>.  If a different range is desired,
specify it in C<ZRANGE>, like so:

  $pl->shadeplot ($z, $nlevels, PALETTE => 'GREENRED', ZRANGE => [0,100]);

or

  $pl->xyplot ($x, $y, PALETTE  => 'RAINBOW', PLOTTYPE => 'POINTS',
	               COLORMAP => $z,        ZRANGE => [-90,-20]);
  $pl->colorkey  ($z, 'v', VIEWPORT => [0.93, 0.96, 0.13, 0.85],
                       ZRANGE => [-90,-20]);

=head1 METHODS

These are the high-level, object oriented methods for PLplot.

=head2 new

=for ref

Create an object representing a plot.

=for usage

 Arguments:
 none.

 Supported options:
 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

=for example

  my $pl = PDL::Graphics::PLplot->new(DEV => 'png',  FILE => 'test.png');


=head2 setparm

=for ref

Set options for a plot object.

=for usage

 Arguments:
 none.

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  $pl->setparm (TEXTSIZE => 2);

=head2 xyplot

=for ref

Plot XY lines and/or points.  Also supports color scales for points.
This function works with bad values.  If a bad value is specified for
a points plot, it is omitted.  If a bad value is specified for a line
plot, the bad value makes a gap in the line.  This is useful for
drawing maps; for example C<$x> and C<$y> can be the continent boundary
latitude and longitude.

=for usage

 Arguments:
 $x, $y

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  $pl->xyplot($x, $y, PLOTTYPE => 'POINTS', COLOR => 'BLUEVIOLET', SYMBOL => 1, SYMBOLSIZE => 4);
  $pl->xyplot($x, $y, PLOTTYPE => 'LINEPOINTS', COLOR => [50,230,30]);
  $pl->xyplot($x, $y, PALETTE => 'RAINBOW', PLOTTYPE => 'POINTS', COLORMAP => $z);

=head2 stripplots

=for ref

Plot a set of strip plots with a common X axis, but with different Y axes.
Looks like a stack of long, thin XY plots, all line up on the same X axis.

=for usage

 Arguments:
 $xs -- 1D PDL with common X axis values, length = N
 $ys -- reference to a list of 1D PDLs with Y-axis values, length = N
        or 2D PDL with N x M elements
 -- OR --
 $xs -- reference to a list of 1D PDLs with X-axis values
 $ys -- reference to a list of 1D PDLs with Y-axis values
 %opts -- Options hash

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  my $x  = sequence(20);
  my $y1  = $x**2;
  my $y2  = sqrt($x);
  my $y3  = $x**3;
  my $y4  = sin(($x/20) * 2 * $pi);
  $ys  = cat($y1, $y2, $y3, $y4);
  $pl->stripplots($x, $ys, PLOTTYPE => 'LINE', TITLE => 'functions',
                           YLAB     => ['x**2', 'sqrt(x)', 'x**3', 'sin(x/20*2pi)'],
                           COLOR    => ['GREEN', 'DEEPSKYBLUE', 'DARKORCHID1', 'DEEPPINK'], XLAB => 'X label');
  # Equivalent to above:
  $pl->stripplots($x, [$y1, $y2, $y3, $y4],
                           PLOTTYPE => 'LINE', TITLE => 'functions',
                           YLAB     => ['x**2', 'sqrt(x)', 'x**3', 'sin(x/20*2pi)'],
                           COLOR    => ['GREEN', 'DEEPSKYBLUE', 'DARKORCHID1', 'DEEPPINK'], XLAB => 'X label');

  # Here's something a bit different. Notice that different xs have
  # different lengths.
  $x1  = sequence(20);
  $y1  = $x1**2;

  $x2  = sequence(18);
  $y2  = sqrt($x2);

  $x3  = sequence(24);
  $y3  = $x3**3;

  my $x4  = sequence(27);
  $a  = ($x4/20) * 2 * $pi;
  my $y4  = sin($a);

  $xs  = [$x1, $x2, $x3, $x4];
  $ys  = [$y1, $y2, $y3, $y4];
  $pl->stripplots($xs, $ys, PLOTTYPE => 'LINE', TITLE => 'functions',
                YLAB => ['x**2', 'sqrt(x)', 'x**3', 'sin(x/20*2pi)'],
                         COLOR => ['GREEN', 'DEEPSKYBLUE', 'DARKORCHID1', 'DEEPPINK'], XLAB => 'X label');

In addition, COLOR may be specified as a reference to a list of colors.  If
this is done, the colors are applied separately to each plot.

Also, the options Y_BASE and Y_GUTTER can be specified.  Y_BASE gives the Y offset
of the bottom of the lowest plot (0-1, specified like a VIEWPORT, defaults to 0.1) and Y_GUTTER
gives the gap between the graphs (0-1, default = 0.02).

=head2 colorkey

=for ref

Plot a color key showing which color represents which value

=for usage

 Arguments:
 $range   : A PDL which tells the range of the color values
 $orientation : 'v' for vertical color key, 'h' for horizontal

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  # Plot X vs. Y with Z shown by the color.  Then plot
  # vertical key to the right of the original plot.
  $pl->xyplot ($x, $y, PALETTE => 'RAINBOW', PLOTTYPE => 'POINTS', COLORMAP => $z);
  $pl->colorkey ($z, 'v', VIEWPORT => [0.93, 0.96, 0.15, 0.85]);


=head2 shadeplot

=for ref

Create a shaded contour plot of 2D PDL 'z' with 'nsteps' contour levels.
Linear scaling is used to map the coordinates of Z(X, Y) to world coordinates
via the L</BOX> option.

=for usage

 Arguments:
 $z : A 2D PDL which contains surface values at each XY coordinate.
 $nsteps : The number of contour levels requested for the plot.

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  # vertical key to the right of the original plot.
  # The BOX must be specified to give real coordinate values to the $z array.
  $pl->shadeplot ($z, $nsteps, BOX => [-1, 1, -1, 1], PALETTE => 'RAINBOW', ZRANGE => [0,100]);
  $pl->colorkey  ($z, 'v', VIEWPORT => [0.93, 0.96, 0.15, 0.85], ZRANGE => [0,100]);

=head2 histogram

=for ref

Create a histogram of a 1-D variable.

=for usage

 Arguments:
 $x : A 1D PDL
 $nbins : The number of bins to use in the histogram.

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  $pl->histogram ($x, $nbins, BOX => [$min, $max, 0, 100]);

=head2 bargraph

=for ref

Simple utility to plot a bar chart with labels on the X axis.
The usual options can be specified, plus one other:  MAXBARLABELS
specifies the maximum number of labels to allow on the X axis.
The default is 20.  If this value is exceeded, then every other
label is plotted.  If twice MAXBARLABELS is exceeded, then only
every third label is printed, and so on.

if UNFILLED_BARS is set to true, then plot the bars as outlines
and not as filled rectangles.

=for usage

 Arguments:
 $labels -- A reference to a perl list of strings.
 $values -- A PDL of values to be plotted.

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  $labels = ['one', 'two', 'three'];
  $values = pdl(1, 2, 3);

  # Note if TEXTPOSITION is specified, it must be in 4 argument mode (border mode):
  # [$side, $disp, $pos, $just]
  #
  # Where side = 't', 'b', 'l', or 'r' for top, bottom, left and right
  #              'tv', 'bv', 'lv' or 'rv' for top, bottom, left or right perpendicular to the axis.
  #
  #     disp is the number of character heights out from the edge
  #     pos  is the position along the edge of the viewport, from 0 to 1.
  #     just tells where the reference point of the string is: 0 = left, 1 = right, 0.5 = center.
  #
  # The '$pos' entry will be ignored (computed by the bargraph routine)
  $pl->bargraph($labels, $values, MAXBARLABELS => 30, TEXTPOSITION => ['bv', 0.5, 1.0, 1.0]);

=head2 text

=for ref

Write text on a plot.  Text can either be written
with respect to the borders or at an arbitrary location and angle
(see the L</TEXTPOSITION> entry).

=for usage

 Arguments:
 $t : The text.

 Supported options:
 All options except:

 BACKGROUND
 DEV
 FILE
 FRAMECOLOR
 JUST
 PAGESIZE
 SUBPAGES

(These must be set in call to 'new'.)

=for example

  $pl->text("Count", COLOR => 'PINK',
	    TEXTPOSITION => ['t', 3, 0.5, 0.5]); # top, 3 units out, string ref. pt in
                                                 # center of string, middle of axis

=head2 close

=for ref

Close a PLplot object, writing out the file and cleaning up.

=for usage

Arguments:
None

Returns:
Nothing

This closing of the PLplot object can be done explicitly though the
'close' method.  Alternatively, a DESTROY block does an automatic
close whenever the PLplot object passes out of scope.

=for example

  $pl->close;

=cut

# pull in low level interface
use vars qw(%_constants %_actions);

# Colors (from rgb.txt) are stored as RGB triples
# with each value from 0-255
sub cc2t { [map {hex} split ' ', shift] }
%_constants = (
	       BLACK          => [  0,  0,  0],
	       RED            => [240, 50, 50],
	       YELLOW         => [255,255,  0],
	       GREEN          => [  0,255,  0],
	       AQUAMARINE     => [127,255,212],
	       PINK           => [255,192,203],
	       WHEAT          => [245,222,179],
	       GREY           => [190,190,190],
	       BROWN          => [165, 42, 42],
	       BLUE           => [  0,  0,255],
	       BLUEVIOLET     => [138, 43,226],
	       CYAN           => [  0,255,255],
	       TURQUOISE      => [ 64,224,208],
	       MAGENTA        => [255,  0,255],
	       SALMON         => [250,128,114],
	       WHITE          => [255,255,255],
               ROYALBLUE      => cc2t('2B 60 DE'),
               DEEPSKYBLUE    => cc2t('3B B9 FF'),
               VIOLET         => cc2t('8D 38 C9'),
               STEELBLUE1     => cc2t('5C B3 FF'),
               DEEPPINK       => cc2t('F5 28 87'),
               MAGENTA        => cc2t('FF 00 FF'),
               DARKORCHID1    => cc2t('B0 41 FF'),
               PALEVIOLETRED2 => cc2t('E5 6E 94'),
               TURQUOISE1     => cc2t('52 F3 FF'),
               LIGHTSEAGREEN  => cc2t('3E A9 9F'),
               SKYBLUE        => cc2t('66 98 FF'),
               FORESTGREEN    => cc2t('4E 92 58'),
               CHARTREUSE3    => cc2t('6C C4 17'),
               GOLD2          => cc2t('EA C1 17'),
               SIENNA1        => cc2t('F8 74 31'),
               CORAL          => cc2t('F7 65 41'),
               HOTPINK        => cc2t('F6 60 AB'),
               LIGHTCORAL     => cc2t('E7 74 71'),
               LIGHTPINK1     => cc2t('F9 A7 B0'),
               LIGHTGOLDENROD => cc2t('EC D8 72'),
	      );

# a hash of subroutines to invoke when certain keywords are specified
# These are called with arg(0) = $self (the plot object)
#                   and arg(1) = value specified for keyword
%_actions =
  (


   # Set color for index 0, the plot background
   BACKGROUND => sub {
     my $self  = shift;
     my $color = _color(shift);
     $self->{COLORS}[0] = $color;
     plscolbg (@$color);
   },

   # set plotting box in world coordinates
   BOX        => sub {
     my $self  = shift;
     my $box   = shift;
     die "Box must be a ref to a four element array" unless (ref($box) =~ /ARRAY/ and @$box == 4);
     $self->{BOX} = $box;
   },

   CHARSIZE   => sub { my $self = shift;
                       $self->{CHARSIZE} = $_[0];
                       plschr   (0, $_[0]) },  # 0 - N

   COLOR =>
   # maintain color map, set to specified rgb triple
   sub {
     my $self  = shift;
     my $color = _color(shift);

     # init.
     $self->{COLORS} = [] unless exists($self->{COLORS});

     my @idx = @{$self->{COLORS}}; # map of color index (0-15) to RGB triples
     my $found = 0;
     for (my $i=2;$i<@idx;$i++) {  # map entries 0 and 1 are reserved for BACKGROUND and FRAMECOLOR
       if (_coloreq ($color, $idx[$i])) {
	 $self->{CURRENT_COLOR_IDX} = $i;
	 $found = 1;
	 plscol0 ($self->{CURRENT_COLOR_IDX}, @$color);
       }
     }
     return if ($found);

     die "Too many colors used! (max 15)" if (@{$self->{COLORS}} > 14);

     # add this color as index 2 or greater (entries 0 and 1 reserved)
     my $idx = (@{$self->{COLORS}} > 1) ? @{$self->{COLORS}} : 2;
     $self->{COLORS}[$idx]      = $color;
     $self->{CURRENT_COLOR_IDX} = $idx;
     plscol0 ($self->{CURRENT_COLOR_IDX}, @$color);
   },

   # Contour plot label parameters (see setcontlabelparam and setcontlabelformat)
   CONTOURLABELS => sub { my $self  = shift;
                          my $parms = shift; # [offset, size, spacing, lexp, sigdig], or 0 (deactivate) or 1 (activate)
                          my $defaults = [0.006, 0.3, 0.1, 4, 2];
                          if ( (ref($parms) =~ /ARRAY/) && (@$parms == 5) ) {
                            $self->{CONTOURLABELS} = $parms;
                          } elsif ($parms == 0) {
                            $self->{CONTOURLABELS} = 0;
                          } elsif ($parms == 1) {
                            $self->{CONTOURLABELS} = $defaults;
                          } else {
                            die
"Illegal contour label parameters:  Must either be 0 (turn off contour labels), 1 (turn on default contour labels)
 or a five element array:
 offset:  Offset of label from contour line (if set to 0.0, labels are printed on the lines). Default value is 0.006.
 size:    Font height for contour labels (normalized). Default value is 0.3.
 spacing: Spacing parameter for contour labels. Default value is 0.1.
 lexp:    If the contour numerical label is greater than 10^(lexp) or less than 10^(-lexp),
          then the exponential format is used. Default value of lexp is 4.
 sigdig:  Number of significant digits. Default value is 2";
                          }
   },

   # set output device type
   DEV        => sub { my $self = shift;
                       my $dev  = shift;
                       $self->{DEV} = $dev;
                       plsdev   ($dev)
                     },   # this must be specified with call to new!

   # set PDL to plot into (alternative to specifying DEV)
   MEM        => sub { my $self = shift;
		       my $pdl  = shift;
		       my $x    = $pdl->getdim(1);
		       my $y    = $pdl->getdim(2);
		       plsmem   ($x, $y, $pdl);
		     },

   # set output file
   FILE       => sub { plsfnam  ($_[1]) },   # this must be specified with call to new!

   # set color for index 1, the plot frame and text
   FRAMECOLOR =>
   # set color index 1, the frame color
   sub {
     my $self  = shift;
     my $color = _color(shift);
     $self->{COLORS}[1] = $color;
     plscol0 (1, @$color);
   },

   # Set flag for equal scale axes
   JUST => sub {
     my $self  = shift;
     my $just  = shift;
     die "JUST must be 0 or 1 (defaults to 0)" unless ($just == 0 or $just == 1);
     $self->{JUST} = $just;
   },

    LINEWIDTH  => sub {
      my $self = shift;
      my $wid  = shift;
      die "LINEWIDTH must range from 0 to LARGE8" unless ($wid >= 0);
      $self->{LINEWIDTH} = $wid;
    },

   LINESTYLE  => sub {
     my $self = shift;
     my $sty  = shift;
     die "LINESTYLE must range from 1 to 8" unless ($sty >= 1 and $sty <= 8);
     $self->{LINESTYLE} = $sty;
   },

   MAJTICKSIZE  => sub {
     my $self = shift;
     my $val  = shift;
     die "MAJTICKSIZE must be greater than or equal to zero"
       unless ($val >= 0);
     plsmaj (0, $val);
   },

   MINTICKSIZE  => sub {
     my $self = shift;
     my $val  = shift;
     die "MINTICKSIZE must be greater than or equal to zero"
       unless ($val >= 0);
     plsmin (0, $val);
   },

   NXSUB  => sub {
     my $self = shift;
     my $val  = shift;
     die "NXSUB must be an integer greater than or equal to zero"
       unless ($val >= 0 and int($val) == $val);
     $self->{NXSUB} = $val;
   },

   NYSUB  => sub {
     my $self = shift;
     my $val  = shift;
     die "NYSUB must be an integer greater than or equal to zero"
       unless ($val >= 0 and int($val) == $val);
     $self->{NYSUB} = $val;
   },

   # set driver options, example for ps driver, {text => 1} is accepted
   OPTS => sub {
     my $self = shift;
     my $opts = shift;

     foreach my $opt (keys %$opts) {
       plsetopt ($opt, $$opts{$opt});
     }
   },

   # set driver options, example for ps driver, {text => 1} is accepted
   ORIENTATION => sub {
     my $self   = shift;
     my $orient = shift;

     die "Orientation must be between 0 and 4" unless ($orient >= 0 and $orient <= 4);
     $self->{ORIENTATION} = $orient;
   },

   PAGESIZE   =>
     # set plot size in mm.  Only useful in call to 'new'
     sub {
       my $self = shift;
       my $dims = shift;

       die "plot size must be a 2 element array ref:  X size in pixels, Y size in pixels"
	 if ((ref($dims) !~ /ARRAY/) || @$dims != 2);
       $self->{PAGESIZE} = $dims;
     },

   PALETTE =>

   # load some pre-done color map 1 setups
   sub {
     my $self = shift;
     my $pal  = shift;

     my %legal = (REVERSERAINBOW => 1, REVERSEGREYSCALE => 1, REDGREEN => 1, RAINBOW => 1, GREYSCALE => 1, GREENRED => 1);
     if ($legal{$pal}) {
       $self->{PALETTE} = $pal;
       if      ($pal eq 'RAINBOW') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(0,300), PDL->new(0.5, 0.5), PDL->new(1,1), PDL->new(0,0));
       } elsif ($pal eq 'REVERSERAINBOW') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(270,-30), PDL->new(0.5, 0.5), PDL->new(1,1), PDL->new(0,0));
       } elsif ($pal eq 'GREYSCALE') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(0,0),   PDL->new(0,1), PDL->new(0,0), PDL->new(0,0));
       } elsif ($pal eq 'REVERSEGREYSCALE') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(0,0),   PDL->new(1,0), PDL->new(0,0), PDL->new(0,0));
       } elsif ($pal eq 'GREENRED') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(120,0), PDL->new(0.5, 0.5), PDL->new(1,1), PDL->new(1,1));
       } elsif ($pal eq 'REDGREEN') {
	 plscmap1l (0, PDL->new(0,1), PDL->new(0,120), PDL->new(0.5, 0.5), PDL->new(1,1), PDL->new(1,1));
       }
     } else {
       die "Illegal palette name.  Legal names are: " . join (" ", keys %legal);
     }
   },

   PLOTTYPE =>
   # specify plot type (LINE, POINTS, LINEPOINTS, CONTOUR, SHADE)
   sub {
     my $self = shift;
     my $val  = shift;

     my %legal = (LINE => 1, POINTS => 1, LINEPOINTS => 1, CONTOUR => 1, SHADE => 1);
     if ($legal{$val}) {
       $self->{PLOTTYPE} = $val;
     } else {
       die "Illegal plot type.  Legal options are: " . join (" ", keys %legal);
     }
   },

   SUBPAGE =>
   # specify which subpage to plot on 1-N or 0 (meaning 'next')
   sub {
     my $self = shift;
     my $val  = shift;
     my $err  = "SUBPAGE = \$npage where \$npage = 1-N or 0 (for 'next subpage')";
     if ($val >= 0) {
       $self->{SUBPAGE} = $val;
     } else {
       die $err;
     }
   },

   SUBPAGES =>
   # specify number of sub pages [nx, ny]
   sub {
     my $self = shift;
     my $val  = shift;
     my $err  = "SUBPAGES = [\$nx, \$ny] where \$nx and \$ny are between 1 and 127";
     if (ref($val) =~ /ARRAY/ and @$val == 2) {
       my ($nx, $ny) = @$val;
       if ($nx > 0 and $nx < 128 and $ny > 0 and $ny < 128) {
	 $self->{SUBPAGES} = [$nx, $ny];
       } else {
	 die $err;
       }
     } else {
       die $err;
     }
   },

   SYMBOL =>
   # specify type of symbol to plot
   sub {
     my $self = shift;
     my $val  = shift;

     if ($val >= 0 && $val < 3000) {
       $self->{SYMBOL} = $val;
     } else {
       die "Illegal symbol number.  Legal symbols are between 0 and 3000";
     }
   },

   SYMBOLSIZE => sub {
     my ($self, $size) = @_;
     die "symbol size must be a real number from 0 to (large)" unless ($size >= 0);
     $self->{SYMBOLSIZE} = $size;
   },

   TEXTPOSITION =>
   # specify placement of text.  Either relative to border, specified as:
   # [$side, $disp, $pos, $just]
   # or
   # inside plot window, specified as:
   # [$x, $y, $dx, $dy, $just] (see POD doc for details)
   sub {
     my $self = shift;
     my $val  = shift;

     die "TEXTPOSITION value must be an array ref with either:
          [$side, $disp, $pos, $just] or [$x, $y, $dx, $dy, $just]"
       unless ((ref($val) =~ /ARRAY/) and ((@$val == 4) || (@$val == 5)));

     if (@$val == 4) {
       $self->{TEXTMODE} = 'border';
     } else {
       $self->{TEXTMODE} = 'plot';
     }
     $self->{TEXTPOSITION} = $val;
   },

   # draw a title for the graph
   TITLE      => sub {
     my $self = shift;
     my $text = shift;
     $self->{TITLE} = $text;
   },

   # Specify outline bars for bargraph
   UNFILLED_BARS => sub {
     my $self = shift;
     my $val  = shift;
     $self->{UNFILLED_BARS} = $val;
   },

   # set the location of the plotting window on the page
   VIEWPORT => sub {
     my $self  = shift;
     my $vp    = shift;
     die "Viewport must be a ref to a four element array"
       unless (ref($vp) =~ /ARRAY/ and @$vp == 4);
     $self->{VIEWPORT} = $vp;
   },

   XBOX       =>
     # set X axis label options.  See pod for definitions.
     sub {
       my $self = shift;
       my $opts = lc shift;

       my @opts = split '', $opts;
       map { 'abcdfghilmnst' =~ /$_/i || die "Illegal option $_.  Only abcdfghilmnst permitted" } @opts;

       $self->{XBOX} = $opts;
     },

   # draw an X axis label for the graph
   XLAB       => sub {
     my $self = shift;
     my $text = shift;
     $self->{XLAB} = $text;
   },

   XTICK  => sub {
     my $self = shift;
     my $val  = shift;
     die "XTICK must be greater than or equal to zero"
       unless ($val >= 0);
     $self->{XTICK} = $val;
   },

   YBOX       =>
     # set Y axis label options.  See pod for definitions.
     sub {
       my $self = shift;
       my $opts = shift;

       my @opts = split '', $opts;
       map { 'abcfghilmnstv' =~ /$_/i || die "Illegal option $_.  Only abcfghilmnstv permitted" } @opts;

       $self->{YBOX} = $opts;
     },

   # draw an Y axis label for the graph
   YLAB       => sub {
     my $self = shift;
     my $text = shift;
     $self->{YLAB} = $text;
   },

   YTICK  => sub {
     my $self = shift;
     my $val  = shift;
     die "YTICK must be greater than or equal to zero"
       unless ($val >= 0);
     $self->{YTICK} = $val;
   },

   ZRANGE  => sub {
     my $self = shift;
     my $val  = shift;
     die "ZRANGE must be a perl array ref with min and max Z values"
       unless (ref($val) =~ /ARRAY/ && @$val == 2);
     $self->{ZRANGE} = $val;
   },

);


#
## Internal utility routines
#

# handle color as string in _constants hash or [r,g,b] triple
# Input:  either color name or [r,g,b] array ref
# Output: [r,g,b] array ref or exception
sub _color {
  my $c = shift;
  if      (ref($c) =~ /ARRAY/) {
    return $c;
  } elsif ($c = $_constants{$c}) {
    return $c;
  } else {
    die "Color $c not defined";
  }
}

# return 1 if input [r,g,b] triples are equal.
sub _coloreq {
  my ($a, $b) = @_;
  for (my $i=0;$i<3;$i++) { return 0 if ($$a[$i] != $$b[$i]); }
  return 1;
}

# Initialize plotting window given the world coordinate box and
# a 'justify' flag (for equal axis scales).
sub _setwindow {

  my $self = shift;

  # choose correct subwindow
  pladv ($self->{SUBPAGE}) if (exists ($self->{SUBPAGE}));
  delete ($self->{SUBPAGE});  # get rid of SUBPAGE so future plots will stay on same
                              # page unless user asks for specific page

  my $box  = $self->{BOX} || [0,1,0,1]; # default window

  sub MAX { ($_[0] > $_[1]) ? $_[0] : $_[1]; }

  # get subpage offsets from page left/bottom of image
  my ($spxmin, $spxmax, $spymin, $spymax) = (PDL->new(0),PDL->new(0),PDL->new(0),PDL->new(0));
  plgspa($spxmin, $spxmax, $spymin, $spymax);
  $spxmin = $spxmin->at(0);
  $spxmax = $spxmax->at(0);
  $spymin = $spymin->at(0);
  $spymax = $spymax->at(0);
  my $xsize = $spxmax - $spxmin;
  my $ysize = $spymax - $spymin;

  my @vp = @{$self->{VIEWPORT}};  # view port xmin, xmax, ymin, ymax in fraction of image size

  # if JUSTify is zero, set to the user specified (or default) VIEWPORT
  if ($self->{JUST} == 0) {
    plvpor(@vp);

  # compute viewport to allow the same scales for both axes
  } else {
    my $p_def = PDL->new(0);
    my $p_ht  = PDL->new(0);
    plgchr ($p_def, $p_ht);
    $p_def = $p_def->at(0);
    my $lb = 8.0 * $p_def;
    my $rb = 5.0 * $p_def;
    my $tb = 5.0 * $p_def;
    my $bb = 5.0 * $p_def;
    my $dx = $$box[1] - $$box[0];
    my $dy = $$box[3] - $$box[2];
    my $xscale = $dx / ($xsize - $lb - $rb);
    my $yscale = $dy / ($ysize - $tb - $bb);
    my $scale  = MAX($xscale, $yscale);
    my $vpxmin = MAX($lb, 0.5 * ($xsize - $dx / $scale));
    my $vpxmax = $vpxmin + ($dx / $scale);
    my $vpymin = MAX($bb, 0.5 * ($ysize - $dy / $scale));
    my $vpymax = $vpymin + ($dy / $scale);
    plsvpa($vpxmin, $vpxmax, $vpymin, $vpymax);
    $self->{VIEWPORT} = [$vpxmin/$xsize, $vpxmax/$xsize, $vpymin/$ysize, $vpymax/$ysize];
  }

  # set up world coords in window
  plwind (@$box);

}

# Add title and axis labels.
sub _drawlabels {

  my $self = shift;

  plcol0  (1); # set to frame color
  plmtex   (2.5, 0.5, 0.5, 't', $self->{TITLE}) if ($self->{TITLE});
  plmtex   (3.0, 0.5, 0.5, 'b', $self->{XLAB})  if ($self->{XLAB});
  plmtex   (3.5, 0.5, 0.5, 'l', $self->{YLAB})  if ($self->{YLAB});
  plcol0  ($self->{CURRENT_COLOR_IDX}); # set back

}


#
## user-visible routines
#

# Pool of PLplot stream numbers.  One of these stream numbers is taken when 'new' is called
# and when the corresponding 'close' is called, it is returned to the pool.  The pool is
# just a queue:  'new' shifts stream numbers from the top of the queue, 'close' pushes them
# back on the bottom of the queue.
my @plplot_stream_pool = (0..99);

# This routine starts out a plot.  Generally one specifies
# DEV and FILE (device and output file name) as options.
sub new {
  my $type = shift;
  my $self = {};

  # set up object
  $self->{PLOTTYPE} = 'LINE';
  # $self->{CURRENT_COLOR_IDX} = 1;
  $self->{COLORS} = [];

  bless $self, $type;

  # set stream number first
  $self->{STREAMNUMBER} = shift @plplot_stream_pool;
  die "No more PLplot streams left, too many open PLplot objects!" if (!defined($self->{STREAMNUMBER}));
  plsstrm($self->{STREAMNUMBER});

  # set background and frame color first
  $self->setparm(BACKGROUND => 'WHITE',
		 FRAMECOLOR => 'BLACK');

  # set defaults, allow input options to override
  my %opts = (
	      COLOR      => 'BLACK',
	      XBOX       => 'BCNST',
	      YBOX       => 'BCNST',
	      JUST       => 0,
	      SUBPAGES   => [1,1],
	      VIEWPORT   => [0.1, 0.87, 0.13, 0.82],
	      SUBPAGE    => 0,
	      PAGESIZE   => [600, 500],
	      LINESTYLE  => 1,
              LINEWIDTH  => 0,
              SYMBOL     => 751, # a small square
	      NXSUB      => 0,
	      NYSUB      => 0,
	      ORIENTATION=> 0,
	      XTICK      => 0,
	      YTICK      => 0,
	      CHARSIZE   => 1,
	      @_);


  # apply options
  $self->setparm(%opts);

  # Do initial setup
  plspage (0, 0, @{$self->{PAGESIZE}}, 0, 0) if (defined($self->{PAGESIZE}));
  plssub (@{$self->{SUBPAGES}});
  plfontld (1); # extented symbol pages
  plscmap0n (16);   # set up color map 0 to 16 colors.  Is this needed?
  plscmap1n (128);  # set map 1 to 128 colors (should work for devices with 256 colors)
  plinit ();

  # set page orientation
  plsdiori ($self->{ORIENTATION});

  # set up plotting box
  $self->_setwindow;

  return $self;
}

# set parameters.  Called from user directly or from other routines.
sub setparm {
  my $self = shift;

  my %opts = @_;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # apply all options
 OPTION:
  foreach my $o (keys %opts) {
    unless (exists($_actions{$o})) {
      warn "Illegal option $o, ignoring";
      next OPTION;
    }
    &{$_actions{$o}}($self, $opts{$o});
  }
}

# handle 2D plots
sub xyplot {
  my $self = shift;
  my $x    = shift;
  my $y    = shift;

  my %opts = @_;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # only process COLORMAP entries once
  my $z = $opts{COLORMAP};
  delete ($opts{COLORMAP});

  # handle ERRORBAR options
  my $xeb = $opts{XERRORBAR};
  my $yeb = $opts{YERRORBAR};
  delete ($opts{XERRORBAR});
  delete ($opts{YERRORBAR});

  # apply options
  $self->setparm(%opts);

  unless (exists($self->{BOX})) {
    $self->{BOX} = [$x->minmax, $y->minmax];
  }

  # set up viewport, subpage, world coordinates
  $self->_setwindow;

  # draw labels
  $self->_drawlabels;

  # plot box
  plcol0  (1); # set to frame color
  plbox ($self->{XTICK}, $self->{NXSUB}, $self->{YTICK}, $self->{NYSUB},
	 $self->{XBOX}, $self->{YBOX}); # !!! note out of order call

  # set the color according to the color specified in the object
  # (we don't do this as an option, because then the frame might
  # get the color requested for the line/points
  plcol0  ($self->{CURRENT_COLOR_IDX});

  # set line style for plot only (not box)
  pllsty ($self->{LINESTYLE});

  # set line width for plot only (not box)
  plwid  ($self->{LINEWIDTH});

  # Plot lines if requested
  if  ($self->{PLOTTYPE} =~ /LINE/) {
    plline ($x, $y);
  }

  # set line width back
  plwid  (0);

  # plot points if requested
  if ($self->{PLOTTYPE} =~ /POINTS/) {
    my $c = $self->{SYMBOL};
    unless (defined($c)) {

      # the default for $c is a PDL of ones with shape
      # equal to $x with the first dimension removed
      my $z = PDL->zeroes($x->nelem);
      $c = PDL->ones($z->zcover) unless defined($c);
    }
    plssym   (0, $self->{SYMBOLSIZE}) if (defined($self->{SYMBOLSIZE}));

    if (defined($z)) {  # if a color range plot requested
      my ($min, $max) = exists ($self->{ZRANGE}) ? @{$self->{ZRANGE}} : $z->minmax;
      plcolorpoints ($x, $y, $z, $c, $min, $max);
    } else {
      plsym ($x, $y, $c);
    }
  }

  # Plot error bars, if requested
  if (defined($xeb)) {
    # horizontal (X) error bars
    plerrx ($x->nelem, $x - $xeb/2, $x + $xeb/2, $y);
  }

  if (defined($yeb)) {
    # vertical (Y) error bars
    plerry ($y->nelem, $x, $y - $yeb/2, $y + $yeb/2);
  }

  # Flush the PLplot stream.
  plflush();
}


# Handle sets of 2D strip plots sharing one X axis.  Input is
# $self -- PLplot object with existing options
# $xs   -- Ref to list of 1D PDLs with X values
# $ys   -- Ref to list of 1D PDLs with Y values
#          or a 2D PDL
# %opts -- Options values
sub stripplots {

  my $self    = shift;
  my $xs      = shift;
  my $yargs   = shift;

  my %opts = @_;

  # NYTICK => number of y axis ticks
  my $nytick = $opts{NYTICK} || 2;
  delete ($opts{NYTICK});

  # only process COLORMAP entries once
  my $zs = $opts{COLORMAP};
  delete ($opts{COLORMAP});

  # handle XLAB, YLAB and TITLE options
  my $title = $opts{TITLE} || '';
  my $xlab  = $opts{XLAB}  || '';
  my @ylabs = defined($opts{YLAB}) && (ref($opts{YLAB}) =~ /ARRAY/) ? @{$opts{YLAB}} : ();
  delete @opts{qw(TITLE XLAB YLAB)};

  # Ensure we're dealing with an array reference
  my $ys;
  if (ref ($yargs) eq 'ARRAY') {
    $ys = $yargs;
  }
  elsif (ref ($yargs) =~ /PDL/) {
    $ys = [dog $yargs];
  }
  else {
    barf("stripplots requires that its second argument be either a 2D piddle or\na reference to a list of 1D piddles, but you provided neither.");
  }

# This doesn't work because $xs can be an anonymous array, too
#  # Let's be sure the user sent us what we expected:
#  foreach (@$ys) {
#    barf ("stripplots needs to have piddles for its y arguments!")
#      unless (ref =~ /PDL/);
#    barf("stripplots requires that the x and y dimensions agree!")
#      unless ($_->nelem == $xs->nelem);
#  }

  my $nplots = @$ys;

  # Use list of colors, or single color.  If COLOR not specified, default to BLACK for each graph
  my @colors = (defined ($opts{COLOR}) && ref($opts{COLOR}) =~ /ARRAY/) ? @{$opts{COLOR}}
             :  defined ($opts{COLOR})                                  ? ($opts{COLOR}) x $nplots
             : ('BLACK') x $nplots;
  delete @opts{qw(COLOR)};

  my $y_base   = defined($opts{Y_BASE})   ? $opts{Y_BASE}   : 0.1;  # Y offset to start bottom plot
  my $y_gutter = defined($opts{Y_GUTTER}) ? $opts{Y_GUTTER} : 0.02; # Y gap between plots
  delete @opts{qw(Y_BASE Y_GUTTER)};

  # apply options
  $self->setparm(%opts);

  my ($xmin, $xmax);
  if (ref ($xs) =~ /PDL/) {
    ($xmin, $xmax) = $xs->minmax;
  }
  else {
    $xmin = pdl(map { $_->min } @$xs)->min;
    $xmax = pdl(map { $_->max } @$xs)->max;
  }

  SUBPAGE:
    for (my $subpage=0;$subpage<$nplots;$subpage++) {

      my $y = $ys->[$subpage];
      my $x = ref ($xs) =~ /PDL/ ? $xs : $xs->[$subpage];
      my $mask = $y->isgood;
      $y = $y->where($mask);
      $x = $x->where($mask);
      my $z = $zs->slice(":,($subpage)")->where($mask)      if (defined($zs));
      my $yeb  = $yebs->slice(":,($subpage)")->where($mask) if (defined($yebs));
      my $ylab = $ylabs[$subpage];

      my $bottomplot = ($subpage == 0);
      my $topplot    = ($subpage == $nplots-1);

      my $xbox = 'bc';
      $xbox = 'cstnb' if ($bottomplot);

      my $box = $opts{BOX};
      my $yrange = defined($box) ? $$box[3] - $$box[2] : $y->max - $y->min;
      my $del = $yrange ? $yrange * 0.05 : 1;
      my @ybounds = ($y->min - $del, $y->max + $del);
      my $ytick = ($yrange/$nytick);
      my @COLORMAP  = (COLORMAP => $z)    if defined($z);
      $self->xyplot($x, $y,
		  COLOR     => $colors[$subpage],
		  BOX       => defined($box) ? $box : [$xmin, $xmax, @ybounds],
		  XBOX      => $xbox,
		  YBOX      => 'BCNT',
                  YTICK     => $ytick,
                  MAJTICKSIZE => 0.6,
		  CHARSIZE  => 0.4,
                  @COLORMAP,
		  VIEWPORT  => [
				0.15,
				0.9,
                                $y_base             + ($subpage     * (0.8/$nplots)),
                                $y_base - $y_gutter + (($subpage+1) * (0.8/$nplots)),
				],
		  );

      $self->text($ylab,  TEXTPOSITION => ['L', 4, 0.5, 0.5], COLOR => 'BLACK', CHARSIZE => 0.6) if (defined($ylab));
      $self->text($xlab,  TEXTPOSITION => ['B', 3, 0.5, 0.5], COLOR => 'BLACK', CHARSIZE => 0.6) if ($xlab && $bottomplot);
      $self->text($title, TEXTPOSITION => ['T', 2, 0.5, 0.5], COLOR => 'BLACK', CHARSIZE => 1.3) if ($title && $topplot);

    }

}


# Draw a color key or wedge showing the scale of map1 colors
sub colorkey {
  my $self = shift;
  my $var  = shift;
  my $orientation = shift; # 'v' (for vertical) or 'h' (for horizontal)

  my %opts = @_;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # apply options
  $self->setparm(%opts);

  # set up viewport, subpage, world coordinates
  $self->_setwindow;

  # draw labels
  $self->_drawlabels;

  # Allow user to set X, Y box type for color key scale.  D. Hunt 1/7/2009
  my $xbox = exists($self->{XBOX}) ? $self->{XBOX} : 'TM';
  my $ybox = exists($self->{YBOX}) ? $self->{YBOX} : 'TM';

  my @box;

  plcol0  (1); # set to frame color

  my ($min, $max) = exists ($self->{ZRANGE}) ? @{$self->{ZRANGE}} : $var->minmax;

  # plot box
  if      ($orientation eq 'v') {
    # set world coordinates based on input variable
    @box = (0, 1, $min, $max);
    plwind (@box);
    plbox (0, 0, 0, 0, '', $ybox);  # !!! note out of order call
  } elsif ($orientation eq 'h') {
    @box = ($min, $max, 0, 1);
    plwind (@box);
    plbox (0, 0, 0, 0, $xbox, '');  # !!! note out of order call
  } else {
    die "Illegal orientation value: $orientation.  Should be 'v' (vertical) or 'h' (horizontal)";
  }

  # restore color setting
  plcol0  ($self->{CURRENT_COLOR_IDX});

  # This is the number of colors shown in the color wedge.  Make
  # this smaller for gif images as these are limited to 256 colors total.
  # D. Hunt 8/9/2006
  my $ncols = ($self->{DEV} =~ /gif/) ? 32 : 128;

  if ($orientation eq 'v') {
    my $yinc = ($box[3] - $box[2])/$ncols;
    my $y0 = $box[2];
    for (my $i=0;$i<$ncols;$i++) {
      $y0 = $box[2] + ($i * $yinc);
      my $y1 = $y0 + $yinc;
      PDL::Graphics::PLplot::plcol1($i/$ncols);

      # Instead of using plfill (which is not supported on some devices)
      # use multiple calls to plline to color in the space. D. Hunt 8/9/2006
      foreach my $inc (0..9) {
        my $frac = $inc * 0.1;
        my $y = $y0 + (($y1 - $y0) * $frac);
        PDL::Graphics::PLplot::plline (PDL->new(0,1), PDL->new($y,$y));
      }

    }
  } else {
    my $xinc = ($box[1] - $box[0])/$ncols;
    my $x0 = $box[0];
    for (my $i=0;$i<$ncols;$i++) {
      $x0 = $box[0] + ($i * $xinc);
      my $x1 = $x0 + $xinc;
      PDL::Graphics::PLplot::plcol1($i/$ncols);

      # Instead of using plfill (which is not supported on some devices)
      # use multiple calls to plline to color in the space. D. Hunt 8/9/2006
      foreach my $inc (0..9) {
        my $frac = $inc * 0.1;
        my $x = $x0 + (($x1 - $x0) * $frac);
        PDL::Graphics::PLplot::plline (PDL->new($x,$x), PDL->new(0,1));
      }

    }
  }

  # Flush the PLplot stream.
  plflush();
}

# handle shade plots of gridded (2D) data
sub shadeplot {
  my $self   = shift;
  my $z      = shift;
  my $nsteps = shift;

  my %opts = @_;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # apply options
  $self->setparm(%opts);

  my ($nx, $ny) = $z->dims;

  unless (exists($self->{BOX})) {
    $self->{BOX} = [0, $nx, 0, $ny];
  }

  # set up plotting box
  $self->_setwindow;

  # draw labels
  $self->_drawlabels;

  # plot box
  plcol0  (1); # set to frame color
  plbox ($self->{XTICK}, $self->{NXSUB}, $self->{YTICK}, $self->{NYSUB},
	 $self->{XBOX}, $self->{YBOX}); # !!! note out of order call

  my ($min, $max) = exists ($self->{ZRANGE}) ? @{$self->{ZRANGE}} : $z->minmax;
  my $clevel = ((PDL->sequence($nsteps)*(($max - $min)/($nsteps-1))) + $min);

  # may add as options later.  Now use constants
  my $fill_width = 2;
  my $cont_color = 0;
  my $cont_width = 0;

  my $rectangular = 1; # only false for non-linear coord mapping (not done yet in perl)

  # map X coords linearly to X range, Y coords linearly to Y range
  my $xmap = ((PDL->sequence($nx)*(($self->{BOX}[1] - $self->{BOX}[0])/($nx - 1))) + $self->{BOX}[0]);
  my $ymap = ((PDL->sequence($ny)*(($self->{BOX}[3] - $self->{BOX}[2])/($ny - 1))) + $self->{BOX}[2]);

  my $grid = plAllocGrid ($xmap, $ymap);

  # Choose shade plot or contour plot
  if (!defined($self->{PLOTTYPE}) || ($self->{PLOTTYPE} eq 'SHADE') ) {

    plshades($z, @{$self->{BOX}}, $clevel, $fill_width,
             $cont_color, $cont_width, $rectangular,
	     0, \&pltr1, $grid);

  } elsif ($self->{PLOTTYPE} eq 'CONTOUR') {

    if (defined($self->{CONTOURLABELS}) && $self->{CONTOURLABELS}) {
      my ($offset, $size, $spacing, $lexp, $sigdig) = @{$self->{CONTOURLABELS}};
      pl_setcontlabelparam ($offset, $size, $spacing, 1); # 1 = activate
      pl_setcontlabelformat ($lexp, $sigdig);
    } else { # == 0, set labels off
      pl_setcontlabelparam (0.006, 0.3, 0.1, 0); # 0 = deactivate
    }

    # set the color according to the color specified in the object
    # (we don't do this as an option, because then the frame might
    # get the color requested for the line/points
    plcol0  ($self->{CURRENT_COLOR_IDX});

    # set line style for plot only (not box)
    pllsty ($self->{LINESTYLE});

    # set line width for plot only (not box)
    plwid  ($self->{LINEWIDTH});

    plcont ($z, 1, $nx, 1, $ny, $clevel, \&pltr1, $grid);

  }
  plFreeGrid ($grid);

  # Flush the PLplot stream.
  plflush();
}

# handle histograms
sub histogram {
  my $self   = shift;
  my $x      = shift;
  my $nbins  = shift;

  my %opts = @_;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # apply options
  $self->setparm(%opts);

  my ($min, $max) = $x->minmax;

  unless (exists($self->{BOX})) {
    $self->{BOX} = [$min, $max, 0, $x->nelem]; # box probably too tall!
  }

  # set up plotting box
  $self->_setwindow;

  # draw labels
  $self->_drawlabels;

  # plot box
  plcol0  (1); # set to frame color
  plbox ($self->{XTICK}, $self->{NXSUB}, $self->{YTICK}, $self->{NYSUB},
	 $self->{XBOX}, $self->{YBOX}); # !!! note out of order call

  # set line style for plot only (not box)
  pllsty ($self->{LINESTYLE});

  # set line width for plot only (not box)
  plwid  ($self->{LINEWIDTH});

  # set color for histograms
  plcol0  ($self->{CURRENT_COLOR_IDX});

  plhist ($x, $min, $max, $nbins, 1);  # '1' is oldbins parm:  dont call plenv!

  # set line width back
  plwid  (0);

  # Flush the PLplot stream.
  plflush();
}

# Draw bar graphs
sub bargraph {
  my $self   = shift;
  my $labels = shift; # ref to perl list of labels for bars
  my $values = shift; # pdl of values for bars

  my %opts = @_;

  # max number of readable labels on x axis
  my $maxlab = defined($opts{MAXBARLABELS}) ? $opts{MAXBARLABELS} : 20;
  delete ($opts{MAXBARLABELS});

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});
  my $xmax = scalar(@$labels);

  # apply options
  $self->setparm(%opts);

  my ($ymin, $ymax) = $values->minmax;

  unless (exists($self->{BOX})) {
    $self->{BOX} = [0, $xmax, $ymin, $ymax]; # box probably too tall!
  }

  # set up plotting box
  $self->_setwindow;

  # draw labels
  $self->_drawlabels;

  # plot box
  plcol0  (1); # set to frame color
  plbox ($self->{XTICK}, $self->{NXSUB}, $self->{YTICK}, $self->{NYSUB},
	 'bc', $self->{YBOX}); # !!! note out of order call

  # Now respect TEXTPOSITION setting if TEXTMODE eq 'border'
  # This allows the user to tweak the label placement.  D. Hunt 9/4/2007
  my ($side, $disp, $foo, $just) = ('BV', 0.2, 0, 1.0);
  if (defined($self->{TEXTMODE}) && $self->{TEXTMODE} eq 'border') {
    ($side, $disp, $foo, $just) = @{$self->{TEXTPOSITION}};
  }

  # plot labels
  plschr   (0, $self->{CHARSIZE} * 0.7); # use smaller characters
  my $pos = 0;
  my $skip   = int($xmax/$maxlab) + 1;
  for (my $i=0;$i<$xmax;$i+=$skip) {
    $pos = ((0.5+$i)/$xmax);
    my $lab = $$labels[$i];
    plmtex ($disp, $pos, $just, $side, $lab); # !!! out of order parms
  }

  plcol0  ($self->{CURRENT_COLOR_IDX}); # set back to line color

  # set line style for plot only (not box)
  pllsty ($self->{LINESTYLE});

  # set line width for plot only (not box)
  plwid  ($self->{LINEWIDTH});

  # draw bars
  if ($self->{UNFILLED_BARS}) {
    plunfbox (PDL->sequence($xmax)+0.5, $values);
  } else {
    plfbox (PDL->sequence($xmax)+0.5, $values);
  }

  # set line width back
  plwid  (0);

  # set char size back
  plschr (0, $self->{CHARSIZE});

  # Flush the PLplot stream.
  plflush();
}

# Add text to a plot
sub text {
  my $self = shift;
  my $text = shift;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # apply options
  $self->setparm(@_);

  # set the color according to the color specified in the object
  plcol0  ($self->{CURRENT_COLOR_IDX});

  # plot either relative to border, or inside view port
  if      ($self->{TEXTMODE} eq 'border') {
    my ($side, $disp, $pos, $just) = @{$self->{TEXTPOSITION}};
    plmtex ($disp, $pos, $just, $side, $text); # !!! out of order parms
  } elsif ($self->{TEXTMODE} eq 'plot') {
    my ($x, $y, $dx, $dy, $just) = @{$self->{TEXTPOSITION}};
    plptex ($x, $y, $dx, $dy, $just, $text);
  }

  # Flush the PLplot stream.
  plflush();
}

# Clear the current page. This should only be used with interactive devices!
sub clear {
  my $self = shift;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  plclear();
  return;
}

# Get mouse click coordinates (OO version). This should only be used with interactive devices!
sub cursor {
  my $self = shift;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  # Flush the stream, to make sure the plot is visible & current
  plflush();

  # Get the cursor position
  my %gin = plGetCursor();

  # Return an array with the coordinates of the mouse click
  return ($gin{"wX"}, $gin{"wY"}, $gin{"pX"}, $gin{"pY"}, $gin{"dX"}, $gin{"dY"});
}

# Explicitly close a plot and free the object
sub close {
  my $self = shift;

  # Set PLplot to right output stream
  plsstrm($self->{STREAMNUMBER});

  plend1 ();

  # Return this stream number to the pool.
  push (@plplot_stream_pool, $self->{STREAMNUMBER});
  delete $self->{STREAMNUMBER};

  return;
}






=head1 FUNCTIONS



=cut




sub reorder {
  my $name = shift;
  my %reorder = (
                 plaxes       => [0,1,6,2,3,7,4,5],
		 plbox        => [4,0,1,5,2,3], # 4th arg -> 0th arg, 0th arg -> 1st arg, etc
                 plbox3       => [6,7,0,1,8,9,2,3,10,11,4,5],
                 plmtex       => [3,0,1,2,4],
                 plmtex3      => [3,0,1,2,4],
                 plstart      => [2,0,1],
                 plstripc     => [13,14,0,1,2,3,4,5,6,7,8,9,10,11,12,15,16,17,18],
                 plmap        => [4,5,0,1,2,3],
                 plmeridians  => [6,0,1,2,3,4,5],
                 plshades     => [0,10,1,2,3,4,5,6,7,8,9,11,12],
                 plshade1     => [0,15,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17],
		);
  my $ordering = $reorder{$name};
  die "Cannot find argument reordering for $name" if (!defined($ordering));
  my @out;
  for (my $i=0;$i<@_;$i++) {
    $out[$$ordering[$i]] = $_[$i];
  }
  return @out;
}

# Routine for users to set normal plplot argument order
sub plplot_use_standard_argument_order {
  $PDL::Graphics::PLplot::standard_order = shift;
}



=pod

The PDL low-level interface to the PLplot library closely mimics the C API.
Users are referred to the PLplot User's Manual, distributed with the source
PLplot tarball.  This manual is also available on-line at the PLplot web
site (L<http://www.plplot.org/>).

There are three differences in the way the functions are called.  The first
one is due to a limitation in the pp_def wrapper of PDL, which forces all
the non-piddle arguments to be at the end of the arguments list.  It is
the case of strings (C<char *>) arguments in the C API.  This affects the
following functions:

plaxes
plbox
plbox3
plmtex
plmtex3
plstart
plstripc
plmap
plmeridians
plshades
plshade1

This difference can be got around by a call to

plplot_use_standard_argument_order(1);

This re-arranges the string arguments to their proper/intuitive position
compared with the C plplot interface.  This can be restored to it's default
by calling:

plplot_use_standard_argument_order(0);

The second notable different between the C and the PDL APIs is that many of
the PDL calls do not need arguments to specify the size of the the vectors
and/or matrices being passed.  These size parameters are deduced from the
size of the piddles, when possible and are just omitted from the C call
when translating it to perl.

The third difference has to do with output parameters.  In C these are
passed in with the input parameters.  In the perl interface, they are omitted.
For example:

C:

  pllegend(&p_legend_width, &p_legend_height,
           opt, position, x, y, plot_width, bg_color, bb_color, bb_style, nrow, ncolumn, nlegend,
           opt_array,
           text_offset, text_scale, text_spacing, text_justification,
           text_colors, (const char **)text, box_colors, box_patterns, box_scales, box_line_widths,
           line_colors, line_styles, line_widths, symbol_colors, symbol_scales, symbol_numbers, (const char **)symbols);

perl:

  my ($legend_width, $legend_height) = 
    pllegend ($position, $opt, $x, $y, $plot_width, $bg_color, $nlegend,
    \@opt_array,
    $text_offset, $text_scale, $text_spacing, $test_justification,
    \@text_colors, \@text, \@box_colors, \@box_patterns, \@box_scales, \@line_colors,
    \@line_styles, \@line_widths, \@symbol_colors, \@symbol_scales, \@symbol_numbers, \@symbols);

Some of the API functions implemented in PDL have other specificities in
comparison with the C API and will be discussed below.

=cut





=head2 pladv

=for sig

  Signature: (int page())


=for ref

info not available


=for bad

pladv does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pladv = \&PDL::pladv;





=head2 plaxes_pp

=for sig

  Signature: (double xzero();double yzero();double xtick();int nxsub();double ytick();int nysub(); char *xopt;char *yopt)


=for ref

info not available


=for bad

plaxes_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plaxes_pp = \&PDL::plaxes_pp;





=head2 plbin

=for sig

  Signature: (int nbin();double x(dima);double y(dima);int center())


=for ref

info not available


=for bad

plbin does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plbin = \&PDL::plbin;



sub plbox { plbox_pp ($standard_order ? reorder ("plbox", @_) : @_) }



=head2 plbox_pp

=for sig

  Signature: (double xtick();int nxsub();double ytick();int nysub(); char *xopt;char *yopt)


=for ref

info not available


=for bad

plbox_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plbox_pp = \&PDL::plbox_pp;



sub plbox3 { plbox3_pp ($standard_order ? reorder ("plbox3", @_) : @_) }



=head2 plbox3_pp

=for sig

  Signature: (double xtick();int nsubx();double ytick();int nsuby();double ztick();int nsubz(); char *xopt;char *xlabel;char *yopt;char *ylabel;char *zopt;char *zlabel)


=for ref

info not available


=for bad

plbox3_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plbox3_pp = \&PDL::plbox3_pp;





=head2 plcol0

=for sig

  Signature: (int icolzero())


=for ref

info not available


=for bad

plcol0 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcol0 = \&PDL::plcol0;





=head2 plcol1

=for sig

  Signature: (double colone())


=for ref

info not available


=for bad

plcol1 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcol1 = \&PDL::plcol1;





=head2 plcpstrm

=for sig

  Signature: (int iplsr();int flags())


=for ref

info not available


=for bad

plcpstrm does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcpstrm = \&PDL::plcpstrm;





=head2 pldid2pc

=for sig

  Signature: (double xmin(dima);double ymin(dima);double xmax(dima);double ymax(dima))


=for ref

info not available


=for bad

pldid2pc does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pldid2pc = \&PDL::pldid2pc;





=head2 pldip2dc

=for sig

  Signature: (double xmin(dima);double ymin(dima);double xmax(dima);double ymax(dima))


=for ref

info not available


=for bad

pldip2dc does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pldip2dc = \&PDL::pldip2dc;





=head2 plenv

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax();int just();int axis())


=for ref

info not available


=for bad

plenv does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plenv = \&PDL::plenv;





=head2 plenv0

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax();int just();int axis())


=for ref

info not available


=for bad

plenv0 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plenv0 = \&PDL::plenv0;





=head2 plerrx

=for sig

  Signature: (int n();double xmin(dima);double xmax(dima);double y(dima))


=for ref

info not available


=for bad

plerrx does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plerrx = \&PDL::plerrx;





=head2 plerry

=for sig

  Signature: (int n();double x(dima);double ymin(dima);double ymax(dima))


=for ref

info not available


=for bad

plerry does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plerry = \&PDL::plerry;





=head2 plfill3

=for sig

  Signature: (int n();double x(dima);double y(dima);double z(dima))


=for ref

info not available


=for bad

plfill3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plfill3 = \&PDL::plfill3;





=head2 plfont

=for sig

  Signature: (int ifont())


=for ref

info not available


=for bad

plfont does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plfont = \&PDL::plfont;





=head2 plfontld

=for sig

  Signature: (int fnt())


=for ref

info not available


=for bad

plfontld does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plfontld = \&PDL::plfontld;





=head2 plgchr

=for sig

  Signature: (double [o]p_def();double [o]p_ht())


=for ref

info not available


=for bad

plgchr does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgchr = \&PDL::plgchr;





=head2 plgcompression

=for sig

  Signature: (int [o]compression())


=for ref

info not available


=for bad

plgcompression does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgcompression = \&PDL::plgcompression;





=head2 plgdidev

=for sig

  Signature: (double [o]p_mar();double [o]p_aspect();double [o]p_jx();double [o]p_jy())


=for ref

info not available


=for bad

plgdidev does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgdidev = \&PDL::plgdidev;





=head2 plgdiori

=for sig

  Signature: (double [o]p_rot())


=for ref

info not available


=for bad

plgdiori does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgdiori = \&PDL::plgdiori;





=head2 plgdiplt

=for sig

  Signature: (double [o]p_xmin();double [o]p_ymin();double [o]p_xmax();double [o]p_ymax())


=for ref

info not available


=for bad

plgdiplt does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgdiplt = \&PDL::plgdiplt;





=head2 plgfam

=for sig

  Signature: (int [o]p_fam();int [o]p_num();int [o]p_bmax())


=for ref

info not available


=for bad

plgfam does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgfam = \&PDL::plgfam;





=head2 plglevel

=for sig

  Signature: (int [o]p_level())


=for ref

info not available


=for bad

plglevel does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plglevel = \&PDL::plglevel;





=head2 plgpage

=for sig

  Signature: (double [o]p_xp();double [o]p_yp();int [o]p_xleng();int [o]p_yleng();int [o]p_xoff();int [o]p_yoff())


=for ref

info not available


=for bad

plgpage does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgpage = \&PDL::plgpage;





=head2 plgspa

=for sig

  Signature: (double [o]xmin();double [o]xmax();double [o]ymin();double [o]ymax())


=for ref

info not available


=for bad

plgspa does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgspa = \&PDL::plgspa;





=head2 plgvpd

=for sig

  Signature: (double [o]p_xmin();double [o]p_xmax();double [o]p_ymin();double [o]p_ymax())


=for ref

info not available


=for bad

plgvpd does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgvpd = \&PDL::plgvpd;





=head2 plgvpw

=for sig

  Signature: (double [o]p_xmin();double [o]p_xmax();double [o]p_ymin();double [o]p_ymax())


=for ref

info not available


=for bad

plgvpw does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgvpw = \&PDL::plgvpw;





=head2 plgxax

=for sig

  Signature: (int [o]p_digmax();int [o]p_digits())


=for ref

info not available


=for bad

plgxax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgxax = \&PDL::plgxax;





=head2 plgyax

=for sig

  Signature: (int [o]p_digmax();int [o]p_digits())


=for ref

info not available


=for bad

plgyax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgyax = \&PDL::plgyax;





=head2 plgzax

=for sig

  Signature: (int [o]p_digmax();int [o]p_digits())


=for ref

info not available


=for bad

plgzax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgzax = \&PDL::plgzax;





=head2 pljoin

=for sig

  Signature: (double xone();double yone();double xtwo();double ytwo())


=for ref

info not available


=for bad

pljoin does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pljoin = \&PDL::pljoin;





=head2 pllightsource

=for sig

  Signature: (double x();double y();double z())


=for ref

info not available


=for bad

pllightsource does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pllightsource = \&PDL::pllightsource;





=head2 pllsty

=for sig

  Signature: (int lin())


=for ref

info not available


=for bad

pllsty does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pllsty = \&PDL::pllsty;



sub plmtex { plmtex_pp ($standard_order ? reorder ("plmtex", @_) : @_) }



=head2 plmtex_pp

=for sig

  Signature: (double disp();double pos();double just(); char *side;char *text)


=for ref

info not available


=for bad

plmtex_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmtex_pp = \&PDL::plmtex_pp;



sub plmtex3 { plmtex3_pp ($standard_order ? reorder ("plmtex3", @_) : @_) }



=head2 plmtex3_pp

=for sig

  Signature: (double disp();double pos();double just(); char *side;char *text)


=for ref

info not available


=for bad

plmtex3_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmtex3_pp = \&PDL::plmtex3_pp;





=head2 plpat

=for sig

  Signature: (int nlin();int inc(dima);int del(dima))


=for ref

info not available


=for bad

plpat does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plpat = \&PDL::plpat;





=head2 plprec

=for sig

  Signature: (int setp();int prec())


=for ref

info not available


=for bad

plprec does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plprec = \&PDL::plprec;





=head2 plpsty

=for sig

  Signature: (int patt())


=for ref

info not available


=for bad

plpsty does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plpsty = \&PDL::plpsty;





=head2 plptex

=for sig

  Signature: (double x();double y();double dx();double dy();double just(); char *text)


=for ref

info not available


=for bad

plptex does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plptex = \&PDL::plptex;





=head2 plptex3

=for sig

  Signature: (double x();double y();double z();double dx();double dy();double dz();double sx();double sy();double sz();double just(); char *text)


=for ref

info not available


=for bad

plptex3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plptex3 = \&PDL::plptex3;





=head2 plschr

=for sig

  Signature: (double def();double scale())


=for ref

info not available


=for bad

plschr does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plschr = \&PDL::plschr;





=head2 plscmap0n

=for sig

  Signature: (int ncolzero())


=for ref

info not available


=for bad

plscmap0n does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap0n = \&PDL::plscmap0n;





=head2 plscmap1n

=for sig

  Signature: (int ncolone())


=for ref

info not available


=for bad

plscmap1n does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap1n = \&PDL::plscmap1n;





=head2 plscol0

=for sig

  Signature: (int icolzero();int r();int g();int b())


=for ref

info not available


=for bad

plscol0 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscol0 = \&PDL::plscol0;





=head2 plscolbg

=for sig

  Signature: (int r();int g();int b())


=for ref

info not available


=for bad

plscolbg does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscolbg = \&PDL::plscolbg;





=head2 plscolor

=for sig

  Signature: (int color())


=for ref

info not available


=for bad

plscolor does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscolor = \&PDL::plscolor;





=head2 plscompression

=for sig

  Signature: (int compression())


=for ref

info not available


=for bad

plscompression does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscompression = \&PDL::plscompression;





=head2 plsdidev

=for sig

  Signature: (double mar();double aspect();double jx();double jy())


=for ref

info not available


=for bad

plsdidev does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsdidev = \&PDL::plsdidev;





=head2 plsdimap

=for sig

  Signature: (int dimxmin();int dimxmax();int dimymin();int dimymax();double dimxpmm();double dimypmm())


=for ref

info not available


=for bad

plsdimap does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsdimap = \&PDL::plsdimap;





=head2 plsdiori

=for sig

  Signature: (double rot())


=for ref

info not available


=for bad

plsdiori does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsdiori = \&PDL::plsdiori;





=head2 plsdiplt

=for sig

  Signature: (double xmin();double ymin();double xmax();double ymax())


=for ref

info not available


=for bad

plsdiplt does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsdiplt = \&PDL::plsdiplt;





=head2 plsdiplz

=for sig

  Signature: (double xmin();double ymin();double xmax();double ymax())


=for ref

info not available


=for bad

plsdiplz does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsdiplz = \&PDL::plsdiplz;





=head2 pl_setcontlabelparam

=for sig

  Signature: (double offset();double size();double spacing();int active())


=for ref

info not available


=for bad

pl_setcontlabelparam does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pl_setcontlabelparam = \&PDL::pl_setcontlabelparam;





=head2 pl_setcontlabelformat

=for sig

  Signature: (int lexp();int sigdig())


=for ref

info not available


=for bad

pl_setcontlabelformat does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*pl_setcontlabelformat = \&PDL::pl_setcontlabelformat;





=head2 plsfam

=for sig

  Signature: (int fam();int num();int bmax())


=for ref

info not available


=for bad

plsfam does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsfam = \&PDL::plsfam;





=head2 plsmaj

=for sig

  Signature: (double def();double scale())


=for ref

info not available


=for bad

plsmaj does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsmaj = \&PDL::plsmaj;





=head2 plsmin

=for sig

  Signature: (double def();double scale())


=for ref

info not available


=for bad

plsmin does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsmin = \&PDL::plsmin;





=head2 plsori

=for sig

  Signature: (int ori())


=for ref

info not available


=for bad

plsori does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsori = \&PDL::plsori;





=head2 plspage

=for sig

  Signature: (double xp();double yp();int xleng();int yleng();int xoff();int yoff())


=for ref

info not available


=for bad

plspage does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plspage = \&PDL::plspage;





=head2 plspause

=for sig

  Signature: (int pause())


=for ref

info not available


=for bad

plspause does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plspause = \&PDL::plspause;





=head2 plsstrm

=for sig

  Signature: (int strm())


=for ref

info not available


=for bad

plsstrm does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsstrm = \&PDL::plsstrm;





=head2 plssub

=for sig

  Signature: (int nx();int ny())


=for ref

info not available


=for bad

plssub does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plssub = \&PDL::plssub;





=head2 plssym

=for sig

  Signature: (double def();double scale())


=for ref

info not available


=for bad

plssym does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plssym = \&PDL::plssym;





=head2 plstar

=for sig

  Signature: (int nx();int ny())


=for ref

info not available


=for bad

plstar does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstar = \&PDL::plstar;



sub plstart { plstart_pp ($standard_order ? reorder ("plstart", @_) : @_) }



=head2 plstart_pp

=for sig

  Signature: (int nx();int ny(); char *devname)


=for ref

info not available


=for bad

plstart_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstart_pp = \&PDL::plstart_pp;





=head2 plstripa

=for sig

  Signature: (int id();int pen();double x();double y())


=for ref

info not available


=for bad

plstripa does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstripa = \&PDL::plstripa;





=head2 plstripd

=for sig

  Signature: (int id())


=for ref

info not available


=for bad

plstripd does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstripd = \&PDL::plstripd;





=head2 plsvpa

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax())


=for ref

info not available


=for bad

plsvpa does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsvpa = \&PDL::plsvpa;





=head2 plsxax

=for sig

  Signature: (int digmax();int digits())


=for ref

info not available


=for bad

plsxax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsxax = \&PDL::plsxax;





=head2 plsxwin

=for sig

  Signature: (int window_id())


=for ref

info not available


=for bad

plsxwin does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsxwin = \&PDL::plsxwin;





=head2 plsyax

=for sig

  Signature: (int digmax();int digits())


=for ref

info not available


=for bad

plsyax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsyax = \&PDL::plsyax;





=head2 plszax

=for sig

  Signature: (int digmax();int digits())


=for ref

info not available


=for bad

plszax does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plszax = \&PDL::plszax;





=head2 plvasp

=for sig

  Signature: (double aspect())


=for ref

info not available


=for bad

plvasp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plvasp = \&PDL::plvasp;





=head2 plvpas

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax();double aspect())


=for ref

info not available


=for bad

plvpas does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plvpas = \&PDL::plvpas;





=head2 plvpor

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax())


=for ref

info not available


=for bad

plvpor does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plvpor = \&PDL::plvpor;





=head2 plw3d

=for sig

  Signature: (double basex();double basey();double height();double xminzero();double xmaxzero();double yminzero();double ymaxzero();double zminzero();double zmaxzero();double alt();double az())


=for ref

info not available


=for bad

plw3d does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plw3d = \&PDL::plw3d;





=head2 plwid

=for sig

  Signature: (int width())


=for ref

info not available


=for bad

plwid does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plwid = \&PDL::plwid;





=head2 plwind

=for sig

  Signature: (double xmin();double xmax();double ymin();double ymax())


=for ref

info not available


=for bad

plwind does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plwind = \&PDL::plwind;





=head2 plP_gpixmm

=for sig

  Signature: (double p_x(dima);double p_y(dima))


=for ref

info not available


=for bad

plP_gpixmm does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plP_gpixmm = \&PDL::plP_gpixmm;





=head2 plscolbga

=for sig

  Signature: (int r();int g();int b();double a())


=for ref

info not available


=for bad

plscolbga does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscolbga = \&PDL::plscolbga;





=head2 plscol0a

=for sig

  Signature: (int icolzero();int r();int g();int b();double a())


=for ref

info not available


=for bad

plscol0a does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscol0a = \&PDL::plscol0a;





=head2 plline

=for sig

  Signature: (x(n); y(n))

=for ref

Draws line segments along (x1,y1)->(x2,y2)->(x3,y3)->...

=for bad

If the nth value of either x or y are bad, then it will be skipped, breaking
the line.  In this way, you can specify multiple line segments with a single
pair of x and y piddles.

The usage is straight-forward:

=for usage

 plline($x, $y);

For example:

=for example

 # Draw a sine wave
 $x = sequence(100)/10;
 $y = sin($x);

 # Draws the sine wave:
 plline($x, $y);

 # Set values above 3/4 to 'bad', effectively drawing a bunch of detached,
 # capped waves
 $y->setbadif($y > 3/4);
 plline($x, $y);



=for bad

plline does handle bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plline = \&PDL::plline;





=head2 plcolorpoints

=for sig

  Signature: (x(n); y(n); z(n); int sym(); minz(); maxz())

=for ref

PDL-specific: Implements what amounts to a threaded version of plsym.

=for bad

Bad values for z are simply skipped; all other bad values are not processed.

In the following usage, all of the piddles must have the same dimensions:

=for usage

 plcolorpoints($x, $y, $z, $symbol_index, $minz, $maxz)

For example:

=for example

 # Generate a parabola some points
 my $x = sequence(30) / 3;   # Regular sampling
 my $y = $x**2;              # Parabolic y
 my $z = 30 - $x**3;         # Cubic coloration
 my $symbols = floor($x);    # Use different symbols for each 1/3 of the plot
                             #  These should be integers.

 plcolorpoints($x, $y, $z, $symbols, -5, 20);  # Thread over everything
 plcolorpoints($x, $y, 1, 1, -1, 2);           # same color and symbol for all



=for bad

plcolorpoints does handle bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcolorpoints = \&PDL::plcolorpoints;





=head2 plsmem

=for sig

  Signature: (int maxx();int maxy();image(3,x,y))


=for ref

info not available


=for bad

plsmem does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsmem = \&PDL::plsmem;





=head2 plfbox

=for sig

  Signature: (xo(); yo())


=for ref

info not available


=for bad

plfbox does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plfbox = \&PDL::plfbox;





=head2 plunfbox

=for sig

  Signature: (xo(); yo())


=for ref

info not available


=for bad

plunfbox does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plunfbox = \&PDL::plunfbox;





=head2 plParseOpts

=for sig

  Signature: (int [o] retval(); SV* argv; int mode)

=for ref

FIXME: documentation here!

=for bad

plParseOpts does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plParseOpts = \&PDL::plParseOpts;





=head2 plpoin

=for sig

  Signature: (x(n); y(n); int code())


=for ref

info not available


=for bad

plpoin does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plpoin = \&PDL::plpoin;





=head2 plpoin3

=for sig

  Signature: (x(n); y(n); z(n); int code())


=for ref

info not available


=for bad

plpoin3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plpoin3 = \&PDL::plpoin3;





=head2 plline3

=for sig

  Signature: (x(n); y(n); z(n))


=for ref

info not available


=for bad

plline3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plline3 = \&PDL::plline3;





=head2 plpoly3

=for sig

  Signature: (x(n); y(n); z(n); int draw(m); int ifcc())


=for ref

info not available


=for bad

plpoly3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plpoly3 = \&PDL::plpoly3;





=head2 plhist

=for sig

  Signature: (data(n); datmin(); datmax(); int nbin(); int oldwin())


=for ref

info not available


=for bad

plhist does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plhist = \&PDL::plhist;





=head2 plfill

=for sig

  Signature: (x(n); y(n))


=for ref

info not available


=for bad

plfill does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plfill = \&PDL::plfill;





=head2 plgradient

=for sig

  Signature: (x(n); y(n); angle())


=for ref

info not available


=for bad

plgradient does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgradient = \&PDL::plgradient;





=head2 plsym

=for sig

  Signature: (x(n); y(n); int code())


=for ref

info not available


=for bad

plsym does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsym = \&PDL::plsym;





=head2 plsurf3d

=for sig

  Signature: (x(nx); y(ny); z(nx,ny); int opt(); clevel(nlevel))


=for ref

info not available


=for bad

plsurf3d does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsurf3d = \&PDL::plsurf3d;





=head2 plstyl

=for sig

  Signature: (int mark(nms); int space(nms))


=for ref

info not available


=for bad

plstyl does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstyl = \&PDL::plstyl;





=head2 plseed

=for sig

  Signature: (int seed())


=for ref

info not available


=for bad

plseed does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plseed = \&PDL::plseed;





=head2 plrandd

=for sig

  Signature: (double [o]rand())


=for ref

info not available


=for bad

plrandd does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plrandd = \&PDL::plrandd;





=head2 plAllocGrid

=for sig

  Signature: (double xg(nx); double yg(ny); int [o] grid())

=for ref

FIXME: documentation here!

=for bad

plAllocGrid does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plAllocGrid = \&PDL::plAllocGrid;





=head2 plAlloc2dGrid

=for sig

  Signature: (double xg(nx,ny); double yg(nx,ny); int [o] grid())

=for ref

FIXME: documentation here!

=for bad

plAlloc2dGrid does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plAlloc2dGrid = \&PDL::plAlloc2dGrid;





=head2 init_pltr

=for sig

  Signature: (P(); C(); SV* p0; SV* p1; SV* p2)

=for ref

FIXME: documentation here!

=for bad

init_pltr does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*init_pltr = \&PDL::init_pltr;



init_pltr (\&pltr0, \&pltr1, \&pltr2);


sub plmap { plmap_pp ($standard_order ? reorder ("plmap", @_) : @_) }



=head2 plmap_pp

=for sig

  Signature: (minlong(); maxlong(); minlat(); maxlat(); SV* mapform; char* type)


=for ref

info not available


=for bad

plmap_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmap_pp = \&PDL::plmap_pp;





=head2 plstring

=for sig

  Signature: (x(na); y(na); char* string)


=for ref

info not available


=for bad

plstring does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstring = \&PDL::plstring;





=head2 plstring3

=for sig

  Signature: (x(na); y(na); z(na); char* string)


=for ref

info not available


=for bad

plstring3 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstring3 = \&PDL::plstring3;



sub plmeridians { plmeridians_pp ($standard_order ? reorder ("plmeridians", @_) : @_) }



=head2 plmeridians_pp

=for sig

  Signature: (dlong(); dlat(); minlong(); maxlong(); minlat(); maxlat(); SV* mapform)


=for ref

info not available


=for bad

plmeridians_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmeridians_pp = \&PDL::plmeridians_pp;



sub plshades { plshades_pp ($standard_order ? reorder ("plshades", @_) : @_) }



=head2 plshades_pp

=for sig

  Signature: (z(x,y); xmin(); xmax(); ymin(); ymax();
                  clevel(l); int fill_width(); int cont_color();
                  int cont_width(); int rectangular(); SV* defined; SV* pltr; SV* pltr_data)


=for ref

info not available


=for bad

plshades_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plshades_pp = \&PDL::plshades_pp;





=head2 plcont

=for sig

  Signature: (f(nx,ny); int kx(); int lx(); int ky(); int ly(); clevel(nlevel); SV* pltr; SV* pltr_data)

=for ref

FIXME: documentation here!

=for bad

plcont does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcont = \&PDL::plcont;





=head2 plmesh

=for sig

  Signature: (x(nx); y(ny); z(nx,ny); int opt())

=for ref

FIXME: documentation here!

=for bad

plmesh does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmesh = \&PDL::plmesh;





=head2 plmeshc

=for sig

  Signature: (x(nx); y(ny); z(nx,ny); int opt(); clevel(nlevel))

=for ref

FIXME: documentation here!

=for bad

plmeshc does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plmeshc = \&PDL::plmeshc;





=head2 plot3d

=for sig

  Signature: (x(nx); y(ny); z(nx,ny); int opt(); int side())

=for ref

FIXME: documentation here!

=for bad

plot3d does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plot3d = \&PDL::plot3d;





=head2 plot3dc

=for sig

  Signature: (x(nx); y(ny); z(nx,ny); int opt(); clevel(nlevel))

=for ref

FIXME: documentation here!

=for bad

plot3dc does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plot3dc = \&PDL::plot3dc;





=head2 plscmap1l

=for sig

  Signature: (int itype(); isty(n); coord1(n); coord2(n); coord3(n); int rev(nrev))

=for ref

FIXME: documentation here!

=for bad

plscmap1l does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap1l = \&PDL::plscmap1l;



sub plshade1 { plshade1_pp ($standard_order ? reorder ("plshade1", @_) : @_) }



=head2 plshade1_pp

=for sig

  Signature: (a(nx,ny); left(); right(); bottom(); top(); shade_min();shade_max(); sh_cmap(); sh_color(); sh_width();min_color(); min_width(); max_color(); max_width();rectangular(); SV* defined; SV* pltr; SV* pltr_data)

=for ref

FIXME: documentation here!

=for bad

plshade1_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plshade1_pp = \&PDL::plshade1_pp;





=head2 plimage

=for sig

  Signature: (idata(nx,ny); xmin(); xmax(); ymin(); ymax();zmin(); zmax(); Dxmin(); Dxmax(); Dymin(); Dymax())


=for ref

info not available


=for bad

plimage does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plimage = \&PDL::plimage;





=head2 plimagefr

=for sig

  Signature: (idata(nx,ny); xmin(); xmax(); ymin(); ymax();zmin(); zmax(); valuemin(); valuemax(); SV* pltr; SV* pltr_data)


=for ref

info not available


=for bad

plimagefr does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plimagefr = \&PDL::plimagefr;



=head2 plxormod

=for sig

  $status = plxormod ($mode)

=for ref

See the PLplot manual for reference.

=cut


=head2 plGetCursor

=for sig

  %gin = plGetCursor ()

=for ref

plGetCursor waits for graphics input event and translate to world
coordinates and returns a hash with the following keys:

    type:      of event (CURRENTLY UNUSED)
    state:     key or button mask
    keysym:    key selected
    button:    mouse button selected
    subwindow: subwindow (alias subpage, alias subplot) number
    string:    translated string
    pX, pY:    absolute device coordinates of pointer
    dX, dY:    relative device coordinates of pointer
    wX, wY:    world coordinates of pointer

Returns an empty hash if no translation to world coordinates is possible.

=cut


=head2 plgstrm

=for sig

  $strm = plgstrm ()

=for ref

Returns the number of the current output stream.

=cut


=head2 plgsdev

=for sig

  $driver = plgdev ()

=for ref

Returns the current driver name.

=cut


=head2 plmkstrm

=for sig

  $strm = plmkstrm ()

=for ref

Creates a new stream and makes it the default.  Returns the number of
the created stream.

=cut


=head2 plgver

=for sig

  $version = plgver ()

=for ref

See the PLplot manual for reference.

=cut


sub plstripc { plstripc_pp ($standard_order ? reorder ("plstripc", @_) : @_) }



=head2 plstripc_pp

=for sig

  Signature: (xmin(); xmax(); xjump(); ymin(); ymax();xlpos(); ylpos(); int y_ascl(); int acc();int colbox(); int collab();int colline(n); int styline(n);  int [o] id(); char* xspec; char* yspec; SV* legline;char* labx; char* laby; char* labtop)

=for ref

FIXME: documentation here!

=for bad

plstripc_pp does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plstripc_pp = \&PDL::plstripc_pp;





=head2 plgriddata

=for sig

  Signature: (x(npts); y(npts); z(npts); xg(nptsx); yg(nptsy);int type(); data(); [o] zg(nptsx,nptsy))

=for ref

FIXME: documentation here!

=for bad

plgriddata does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgriddata = \&PDL::plgriddata;



=head2 plarc

=for sig

  plarc ($x, $y, $a, $b, $angle1, $angle2, $rotate, $fill);

=for ref

Draw a (possibly) filled arc centered at x, y with semimajor axis a and semiminor axis b, starting at angle1 and ending at angle2.
See the PLplot manual for reference.

=cut


=head2 plstransform

=for sig

  plstransform ($subroutine_reference);

=for ref

Sets the default transformation routine for plotting.

  sub mapform {
    my ($x, $y) = @_;

    my $radius = 90.0 - $y;
    my $xp = $radius * cos ($x * pi / 180);
    my $yp = $radius * sin ($x * pi / 180);

    return ($xp, $yp);
  }
  plstransform (\&mapform);

See the PLplot manual for more details.

=cut


=head2 plslabelfunc

=for sig

  plslabelfunc ($subroutine_reference);

=for ref

  # A custom axis labeling function for longitudes and latitudes.
  sub geolocation_labeler {
    my ($axis, $value, $length) = @_;
    my ($direction_label, $label_val);
    if (($axis == PL_Y_AXIS) && $value == 0) {
        return "Eq";
      } elsif ($axis == PL_Y_AXIS) {
      $label_val = $value;
      $direction_label = ($label_val > 0) ? " N" : " S";
    } elsif ($axis == PL_X_AXIS) {
      my $times  = floor((abs($value) + 180.0 ) / 360.0);
      $label_val = ($value < 0) ? $value + 360.0 * $times : $value - 360.0 * $times;
      $direction_label = ($label_val > 0) ? " E"
                       : ($label_val < 0) ? " W"
                       :                    "";
    }
    return substr (sprintf ("%.0f%s", abs($label_val), $direction_label), 0, $length);
  }
  plslabelfunc(\&geolocation_labeler);

See the PLplot manual for more details.

=cut


=head2 pllegend

=for sig

my ($legend_width, $legend_height) = 
    pllegend ($position, $opt, $x, $y, $plot_width, $bg_color, $nlegend,
    \@opt_array,
    $text_offset, $text_scale, $text_spacing, $test_justification,
    \@text_colors, \@text, \@box_colors, \@box_patterns, \@box_scales, \@line_colors,
    \@line_styles, \@line_widths, \@symbol_colors, \@symbol_scales, \@symbol_numbers, \@symbols);

=for ref

See the PLplot manual for more details.

=cut


=head2 plspal0

=for sig

  plspal0($filename);

=for ref

Set color palette 0 from the input .pal file.  See the PLplot manual for more details.

=cut


=head2 plspal1

=for sig

  plspal1($filename);

=for ref

Set color palette 1 from the input .pal file.  See the PLplot manual for more details.

=cut


=head2 plbtime

=for sig

  my ($year, $month, $day, $hour, $min, $sec) = plbtime($ctime);

=for ref

  Calculate broken-down time from continuous time for current stream.

=cut


=head2 plconfigtime

=for sig

  plconfigtime($scale, $offset1, $offset2, $ccontrol, $ifbtime_offset, $year, $month, $day, $hour, $min, $sec);

=for ref

Configure transformation between continuous and broken-down time (and                                                           
vice versa) for current stream.

=cut


=head2 plctime

=for sig

  my $ctime = plctime($year, $month, $day, $hour, $min, $sec);

=for ref

  Calculate continuous time from broken-down time for current stream.

=cut


=head2 pltimefmt

=for sig

  pltimefmt($fmt);

=for ref

Set format for date / time labels.  See the PLplot manual for more details.

=cut


=head2 plsesc

=for sig

  plsesc($esc);

=for ref


Set the escape character for text strings.  See the PLplot manual for more details.

=cut




=head2 plvect

=for sig

  Signature: (u(nx,ny); v(nx,ny); scale(); SV* pltr; SV* pltr_data)

=for ref

FIXME: documentation here!

=for bad

plvect does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plvect = \&PDL::plvect;





=head2 plsvect

=for sig

  Signature: (arrowx(npts); arrowy(npts); int fill())


=for ref

info not available


=for bad

plsvect does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsvect = \&PDL::plsvect;





=head2 plhlsrgb

=for sig

  Signature: (double h();double l();double s();double [o]p_r();double [o]p_g();double [o]p_b())


=for ref

info not available


=for bad

plhlsrgb does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plhlsrgb = \&PDL::plhlsrgb;





=head2 plgcol0

=for sig

  Signature: (int icolzero(); int [o]r(); int [o]g(); int [o]b())


=for ref

info not available


=for bad

plgcol0 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgcol0 = \&PDL::plgcol0;





=head2 plgcolbg

=for sig

  Signature: (int [o]r(); int [o]g(); int [o]b())


=for ref

info not available


=for bad

plgcolbg does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgcolbg = \&PDL::plgcolbg;





=head2 plscmap0

=for sig

  Signature: (int r(n); int g(n); int b(n))


=for ref

info not available


=for bad

plscmap0 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap0 = \&PDL::plscmap0;





=head2 plscmap1

=for sig

  Signature: (int r(n); int g(n); int b(n))


=for ref

info not available


=for bad

plscmap1 does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap1 = \&PDL::plscmap1;





=head2 plgcol0a

=for sig

  Signature: (int icolzero(); int [o]r(); int [o]g(); int [o]b(); double [o]a())


=for ref

info not available


=for bad

plgcol0a does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgcol0a = \&PDL::plgcol0a;





=head2 plgcolbga

=for sig

  Signature: (int [o]r(); int [o]g(); int [o]b(); double [o]a())


=for ref

info not available


=for bad

plgcolbga does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgcolbga = \&PDL::plgcolbga;





=head2 plscmap0a

=for sig

  Signature: (int r(n); int g(n); int b(n); double a(n))


=for ref

info not available


=for bad

plscmap0a does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap0a = \&PDL::plscmap0a;





=head2 plscmap1a

=for sig

  Signature: (int r(n); int g(n); int b(n); double a(n))


=for ref

info not available


=for bad

plscmap1a does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap1a = \&PDL::plscmap1a;





=head2 plscmap1la

=for sig

  Signature: (int itype(); isty(n); coord1(n); coord2(n); coord3(n); coord4(n); int rev(nrev))

=for ref

FIXME: documentation here!

=for bad

plscmap1la does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plscmap1la = \&PDL::plscmap1la;





=head2 plgfont

=for sig

  Signature: (int [o]p_family(); int [o]p_style(); int [o]p_weight())


=for ref

info not available


=for bad

plgfont does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plgfont = \&PDL::plgfont;





=head2 plsfont

=for sig

  Signature: (int family(); int style(); int weight())


=for ref

info not available


=for bad

plsfont does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plsfont = \&PDL::plsfont;





=head2 plcalc_world

=for sig

  Signature: (double rx(); double ry(); double [o]wx(); double [o]wy(); int [o]window())


=for ref

info not available


=for bad

plcalc_world does not process bad values.
It will set the bad-value flag of all output piddles if the flag is set for any of the input piddles.


=cut






*plcalc_world = \&PDL::plcalc_world;




=pod

=head1 WARNINGS AND ERRORS

PLplot gives many errors and warnings.  Some of these are given by the
PDL interface while others are internal PLplot messages.  Below are
some of these messages, and what you need to do to address them:

=over

=item *
Box must be a ref to a four element array

When specifying a box, you must pass a reference to a
four-element array, or use an anonymous four-element array.

 # Gives trouble:
 $pl->xyplot($x, $y, BOX => (0, 0, 100, 200) );
 # What you meant to say was:
 $pl->xyplot($x, $y, BOX => [0, 0, 100, 200] );

=item *
Too many colors used! (max 15)


=back

=head1 AUTHORS

  Doug Hunt <dhunt@ucar.edu>
  Rafael Laboissiere <rlaboiss@users.sourceforge.net>
  David Mertens <mertens2@illinois.edu>

=head1 SEE ALSO

perl(1), PDL(1), L<http://www.plplot.org/>

The other common graphics packages include L<PDL::PGPLOT>
and L<PDL::TriD>.

=cut



;



# Exit with OK status

1;

		   