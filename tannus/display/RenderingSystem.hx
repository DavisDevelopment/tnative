package tannus.display;

/**
  * Enum of all available Rendering Backends
  */
enum RenderingSystem {
	/* Flash Sprite */
	Flash(s : Sprite);

	/* HTML Canvas */
	Canvas(c : Canvas);
}

/* === Abstract Away the References Made By RenderingSystem, So That All of Them are Available on All Targets === */

/* Sprite */
#if flash
typedef Sprite = flash.display.Sprite;
#else
typedef Sprite = Dynamic;
#end

/* Canvas */
#if (js && !node)
typedef Canvas = js.html.CanvasElement;
#else
typedef Canvas = Dynamic;
#end
