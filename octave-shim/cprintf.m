## Copyright (C) 2015 ederag <edera@gmx.fr>
## 
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*- 
## @deftypefn {Function File} cprintf (@var{colorname}, @var{template}, @dots{})
## 
## Print optional arguments under the control of the template string,
## like printf, but in color.
## Available colors are defined in the ECMA-48 standard:
## @{"black", "red", "green", "yellow", "blue", "violet", "cyan"@}
## as well as @{"grey", "gray", "white"@} which are the same.
##
## The background color can also be specified, after a '/' character
## then @var{colorname} should be "foreground/background".
##
## @seealso{printf}
## @end deftypefn

## Author: ederag <edera@gmx.fr>
## Created: 2015-10-30

function cprintf (colorname, template, varargin)
	color_specification = strsplit(colorname, "/");
	
	# first string is forecolor
	forecolorname = color_specification{1};
	
	if template(end) == "\n"
		## workaround the cursor change if the ending is after the \n
		## remove the last \n
		template = template(1:end-1);
		append_newline = true;
	else
		append_newline = false;
	endif
	
	# "\033" character, in a backward-compatible way
	# Thanks to Mike Miller and nightcod3r
	# https://savannah.gnu.org/bugs/?49573
	# https://stackoverflow.com/questions/27642413/27651390?noredirect=1#comment68315660_27651390
	c_033 = char(base2dec("033",8));
	
	header = [c_033 '[01;'];
	ending = [c_033 '[00m'];
	
	switch forecolorname
	case {"default", "normal"}
		forecolorcode = "00";
	case "black"
		forecolorcode = "30";
	case "red"
		forecolorcode = "31";
	case "green"
		forecolorcode = "32";
	case "yellow"
		forecolorcode = "33";
	case "blue"
		forecolorcode = "34";
	case {"violet", "magenta"}
		forecolorcode = "35";
	case "cyan"
		forecolorcode = "36";
	case {"grey", "gray", "white"}
		forecolorcode = "37";
	otherwise
		error('unknown colorname : "%s"', forecolorname)
	endswitch
	
	if numel(color_specification) == 1
		colorcode = forecolorcode;
	else
		bgcolorname = color_specification{2};
		switch bgcolorname
		case "black"
			bgcolorcode = "40";
		case "red"
			bgcolorcode = "41";
		case "green"
			bgcolorcode = "42";
		case "yellow"
			bgcolorcode = "43";
		case "blue"
			bgcolorcode = "44";
		case "magenta"
			bgcolorcode = "45";
		case "cyan"
			bgcolorcode = "46";
		case {"grey", "gray", "white"}
			bgcolorcode = "47";
		otherwise
			error('unknown background colorname : "%s"', bgcolorname)
		endswitch
		colorcode = [forecolorcode, ";", bgcolorcode];
	endif
	
	new_template = [header, colorcode, "m", template, ending];
	printf(new_template, varargin{:})
	
	if append_newline
		## bring back the removed \n
		printf("\n")
	endif
endfunction

%!demo
%! number = 10.2;
%! cprintf("default", "%.1f, in default color\n", number)
%! cprintf("black", "%.1f, in black\n", number)
%! cprintf("red", "%.1f, in red\n", number)
%! cprintf("green", "%.1f, in green\n", number)
%! cprintf("yellow", "%.1f, in yellow\n", number)
%! cprintf("blue", "%.1f, in blue\n", number)
%! cprintf("magenta", "%.1f, in magenta\n", number)
%! cprintf("cyan", "%.1f, in cyan\n", number)
%! cprintf("white", "%.1f, in white\n", number)

# FIXME: In a for loop, it does not work ?
# %! colornames = {"black", "red", "green", "yellow", "blue", "violet", "cyan", "white"};
# %! cellfun(@(colorname) printf(colorname, "Text in %s\n", colorname), colornames)

%!demo
%! cprintf("yellow/blue", "yellow on blue background\n")
