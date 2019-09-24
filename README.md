# Hand Print
Enable native X gesture for your iPhone!

## Features
* iPhone X home and multitasking gestures
* Doesn't hidden Home Bar, carrier text, breadcrumb, unlock and notification.
* Uses original button gestures for screenshot and Siri
* Force-close apps without long-pressing in Multitasking
* Only support iOS12 so fixed Control Center crash and fixed the Flash button and Camera button on Lock Screen.

## Building
[Theos](https://github.com/theos/theos) required.

Build tweak using `make` in the source directory.

Tweak binary is located in `./.theos/obj/debug/HandPrint.dylib`.

Or build tweak using `make package` in the source directory.

Tweak package is located in `./packages/xxx.deb`.

## Installing
dpkg -i xxx.deb

Prebuilt releases are available [here](https://github.com/Halo-Michael/HandPrint/releases).

## Forks
HandPrint forked from [HomeGesture](https://github.com/VitaTaf/HomeGesture).
Developers are free to modify and use the HomeGesture source in their work in accordance with the GNU General Public License.
