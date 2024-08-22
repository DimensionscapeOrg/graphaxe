package;

import haxe.Timer;
import ghx.utils.PropertyMap;
import openfl.display.Sprite;
import openfl.Lib;
import openfl.utils.Object as FLObject;

/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite 
{

	var o:PropertyMap<Dynamic>;
	public function new() 
	{
		super();
		o = new PropertyMap();

		o.a = 1;

		trace(o.a);

		//MapObject.delete(o, "a");
		
		//trace(o.a);


		for(obj in PropertyMap.iterator(o)){
			trace(obj);
		}
		var bObject:BaseObject = new BaseObject();
	
	}

	

}
