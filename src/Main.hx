package;

import starling.events.Event;
import ghx.display.Button;
import ghx.display.Image;
import starling.textures.Texture;
import openfl.display.BitmapData;
import haxe.ds.IntMap;
import ghx.geom.Rectangle;
import ghx.display.Quad;
import ghx.display.Sprite;
import ghx._internal.utils.rect.RectanglePacker;
import ghx.ds.IndexRegistry;
import openfl.Assets;

/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite {
	var rectPack:RectanglePacker;
	var indexReg:IndexRegistry;
	var quadRects:IntMap<QuadRect> = new IntMap();

	public function new() {
		super();

		/* var bitmapData:BitmapData = Assets.getBitmapData("ico/test.png");
			var texture:Texture = Texture.fromBitmapData(bitmapData, false);
			var img:Image = new Image(texture);
			img.x = 100;
			img.y = 100;
			img.tileGrid = new Rectangle(-16,0, -17, texture.height);
			img.width = 16;
			//img.height = 16;
			///img.width = 4;
			addChild(img); */

		// addChild(new Quad(32, 32, 0x00ff00));

		var button:Button = new Button(Texture.fromColor(200, 32, 0xffffff), "Grow bebe grow!");
		button.y = 400;
		// button.width = 64;
		// button.height = 32;
		button.addEventListener(Event.TRIGGERED, (e) -> {
			//removeChildren(1, -1, true);
			//rectPack.initialize(1024, 256, 0);

			
				var id:Int = indexReg.getNextIndex();
				var quadRect:QuadRect = new QuadRect(Std.random(99) + 1, Std.random(99) + 1, Std.random(2094967295), id);
				quadRects.set(id, quadRect);
				insertRect(Std.int(quadRect.width), Std.int(quadRect.height), id);
				// quadRect.textureRe
				addChild(quadRect);
			
	
			rectPack.pack(true);
			for (i in 0...rectPack.numRects) {
				var rect:Rectangle = rectPack.getRect(i);
				var id:Int = rectPack.getRectId(i);
				var quad:QuadRect = quadRects.get(id);
	
				// trace(rect);
				quad.x = rect.x;
				quad.y = rect.y;
			}
		});
		addChild(button);

		rectPack = new RectanglePacker(1024, 256, 0);
		indexReg = new IndexRegistry();
		
	}

	function insertRect(width:Int, height:Int, id:Int):Void {
		rectPack.addRect(width, height, id);
	}
}

class QuadRect extends Quad {
	public var id:Int;

	public function new(width:Float, height:Float, color:UInt, id:Int) {
		super(width, height, color);
	}
}
