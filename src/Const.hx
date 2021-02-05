class Const {
	// Various constants
	public static inline var FPS = 60;
	public static inline var FIXED_FPS = 30;
	public static inline var SHOW_FPS = 0; // set to 1 to show FPS in debug mode
	public static inline var GRID = 16;
	public static inline var INFINITE = 999999;
	public static var SCALE = 1; // ignored if auto-scaling
	public static var UI_SCALE = 4;
	public static inline var SHOW_HUD = 1; // set to 1 to show HUD on screen
	public static inline var SHOW_SCREEN_OVERLAY = 1; // set to 1 to show screen overlay

	public static inline var GRAVITY = 0.035;
	public static inline var INTRODELAY = 5;

	public static var DARK_COLOR = 0x1b131b;

	/** Unique value generator **/
	public static var NEXT_UNIQ(get,never) : Int; static inline function get_NEXT_UNIQ() return _uniq++;
	static var _uniq = 0;

	/** Game layers indexes **/
	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;
}
