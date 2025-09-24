package backend.native;

#if windows
@:buildXml('
<target id="haxe">
	<lib name="dwmapi.lib"/>
</target>
')

@:cppFileCode('
#include <dwmapi.h>
')
class Windows {
	@:functionCode('
		int darkMode = enable ? 1 : 0;

		HWND window = FindWindowA(NULL, title.c_str());
		// Look for child windows if top level aint found
		if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, title.c_str());
		// If still not found, try to get the active window
		if (window == NULL) window = GetActiveWindow();
		if (window == NULL) return;

		if (S_OK != DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode))) {
			DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));
		}
		UpdateWindow(window);
	')
	public static function setDarkMode(title:String, enable:Bool) {
        flixel.FlxG.stage.window.borderless = true;
		flixel.FlxG.stage.window.borderless = false;
    }
}
#end