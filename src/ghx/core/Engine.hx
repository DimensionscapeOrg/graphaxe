package ghx.core;

import starling.core.Starling;
import ghx.geom.Rectangle;
import openfl.display.Stage;
import openfl.Lib;
import haxe.Timer;

@:keep
final class Engine {
	public static var engine(default, null):Engine = __start();

	public static function __start():Engine {
		__setEngine();
		if (engine == null) {
			Timer.delay(__start, 0);
		}
		return null;
	}

	private static inline function __setEngine():Void {
		if (Lib.current.stage != null) {
			engine = new Engine(Lib.current.stage);
		}
	}

	// public var camera(get, null):Camera2D;
	public var viewPort(get, set):Rectangle;

	// private var _camera:Camera2D;
	private var __stage:Stage;
	private var __starling:Starling;
	private var __viewPort:Rectangle;

	private inline function get_viewPort():Rectangle {
		return __viewPort.clone();
	}

	private inline function set_viewPort(value:Rectangle):Rectangle {
		return __starling.viewPort = __viewPort = value;
	}

	private function new(stage:Stage) {
		trace("started");
		__stage = stage;

		__init();
	}

	private function __init():Void {
		__viewPort = new Rectangle(Config.viewport.x, Config.viewport.y, Config.viewport.width, Config.viewport.height);
		__starling = new Starling(Type.resolveClass(Config.entrypoint), __stage, __viewPort);
		__starling.showStats = Config.stats;
		__starling.start();
	}
}
