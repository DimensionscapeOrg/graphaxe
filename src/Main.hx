package;

import ghx.display.Quad;
import ghx.display.Sprite;
/**
 * ...
 * @author Christopher Speciale
 */
class Main extends Sprite 
{

	public function new() 
	{
		super();
		trace('hello');

		addChild(new Quad(32,32,0x00ff00));
		
	}

	

}
