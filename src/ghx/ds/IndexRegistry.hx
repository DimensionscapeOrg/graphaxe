package ghx.ds;

import haxe.ds.IntMap;
@:access(ghx.ds.IndexRegistryData)
abstract IndexRegistry(IndexRegistryData) {
	public function new() {
		this = new IndexRegistryData(); // Initialize the underlying data structure
	}

    public inline function getNextIndex(): Int {
        return this.getNextFreeIndex(); // Get the next free index
    }

    public inline function release(index: Int): Bool {
        return this.free(index); // Release the index, returning true if successful
    }

    @:arrayAccess 
    public inline function isUsed(index: Int): Bool {
        return this.inUse(index); // Check if an index is currently in use
    }

    public inline function clear(): Void {
        this.__map.clear();
        this.__freeIndicies = [];
        this.__length = 0;
    }

    public inline function size():Int{
        return this.__length;
    }
}

@:noCompletion
private class IndexRegistryData {
	private var __length:Int;
	private var __map:IntMap<Null<Dynamic>>;
	private var __freeIndicies:Array<Int>;

	private function new() {
		__length = 0;
		__map = new IntMap();
        __freeIndicies = [];
	}

	@:noCompletion private function getNextFreeIndex():Int {
		var index:Int;
		if (__freeIndicies.length > 0) {
			index = __freeIndicies.pop();
		} else {
			index = __length;
		}
		return __set(index);
	}

	@:noCompletion private inline function __set(index:Int):Int {
		__map.set(index, null);
		__length++;

		return index;
	}

	@:noCompletion private inline function free(index:Int):Bool {
		if (__map.remove(index)) {
			__length--;
			if (index < __length) {
				__freeIndicies.push(index);
			}
			return true;
		}

		return false;
	}

	@:noCompletion private inline function inUse(index:Int):Bool {
		return __map.exists(index);
	}
}
