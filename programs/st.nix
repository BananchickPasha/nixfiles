{pkgs}:
with pkgs;
st.overrideAttrs (oldAttrs: {
        name = "pahan-st";
        conf = ''
static char *font = "Ubuntu Mono:size=11:Bold:antialias=true:autohint=true";
static int borderpx = 2;

static const char *colorname[] = {
	/* 8 normal colors */
  "#262626",
	"#cf6a4c",
	"#98971A",
	"#d79921",
	"#458588",
	"#b16286",
	"#689d6a",
	"#dddddd",

	/* 8 bright colors */
	"#393939",
	"#fb4934",
	"#b8bb26",
	"#fabd2f",
	"#83a598",
	"#d3869b",
	"#8ec07c",
	"#dddddd",

	[255] = 0,

	/* more colors can be added after 255 to use with DefaultXX */
	"#cccccc",
	"#555555",

};

        '';
      })

