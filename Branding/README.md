# GBO Demo Wallet brand assets

Source: https://gbo.simulatie.datastelsel.nl/, retrieved 10 November 2026.
The site uses a text wordmark, `GBO`, in Fira Sans SemiBold (600), rather than a
separate logo image. The PDF logos reproduce that wordmark. The opaque PNG app icons combine
the wordmark with a wallet and two cards. They contain no EU emblem or government crest.

| Role | Light | Dark |
| --- | --- | --- |
| Background | `#FFFFFF` | `#0E2B84` |
| Primary text | `#222222` | `#FFFFFF` |
| Secondary text | `#44546A` | `#C9D6E3` |
| Links and primary buttons | `#2651BD` | `#63DBFF` |
| Primary button text | `#FFFFFF` | `#0E2B84` |
| Grouped surfaces | `#EFF1F6` | `#0E2B84` |
| Elevated surfaces | `#FFFFFF` | `#143793` |
| Tertiary surfaces | `#ECF1FB` | `#1B409D` |
| App icon | `#2E62E6` | `#0E2B84` |

`#143793` and `#1B409D` are lighter steps of the site's deep blue for dark
surface separation. The regular UI retains the upstream system font; Fira Sans
is embedded only in the vector wordmark artwork. Generic upstream illustrations
are retained with GBO blue colors. Existing imageset names are retained for
upstream compatibility.

Font source: https://github.com/google/fonts/tree/main/ofl/firasans
Font file: `FiraSans-SemiBold.ttf`; license: `FiraSans-OFL.txt` in this directory.

Checked text contrast ratios: light body 15.91:1; light secondary 7.71:1;
light links/buttons 7.01:1; dark body 12.37:1; dark secondary 8.37:1;
dark links/buttons 7.72:1. White icon lettering on blue: 5.24:1.

## Wallet app icon (11 November 2026)

The icon uses a GBO-blue background, a wallet silhouette, two cards and the
existing Fira Sans SemiBold GBO wordmark. Light and dark versions use the
existing palette. Both AppIcon and AppIconDev contain identical opaque
1024×1024 RGB exports; iOS applies the corner mask. No additional text,
EU emblem or government crest is included.

`app-icon-light.svg` and `app-icon-dark.svg` are the editable vector sources.
Lettering is outlined, so rendering needs no installed font. Rasterize each
SVG at 1024×1024 with an opaque RGB background and replace the corresponding
PNG in both app-icon sets. `app-icon-preview.png` shows both appearances and
64-pixel previews; the corner mask is for the preview only.

These assets are intended for the next build. The already uploaded
TestFlight build 0.1.0 (1) retains its original icon.
