package ghx;
import haxe.ds.ObjectMap;
import ghx.utils.IRecyclable;
import ghx.utils.IDisposable;



/**
 * BaseObject Class
 * 
 * The `BaseObject` class serves as a base class for all objects.
 * It implements both the `IDisposable` and `IRecyclable` interfaces, allowing for efficient object management,
 * including destruction and resetting of object states for reuse.
 * 
 * @author Christopher Speciale
 */
 class BaseObject implements IDisposable implements IRecyclable {
    
    /**
     * A static map to track all instances of `BaseObject`.
     * The key and value are both references to the `BaseObject` instance itself.
     */
    private static var gMap:ObjectMap<BaseObject,BaseObject> = new ObjectMap();
    
    /**
     * A static array to keep track of objects flagged for delayed destruction.
     */
    private static var flaggedObjs:Array<BaseObject> = [];

    /**
     * Clears all objects from the global map, effectively freeing all tracked objects.
     */
    public static function freeAll():Void {
        gMap.clear();
    }

    /**
     * Processes all objects flagged for destruction.
     * This method removes them from the global map and clears the flagged objects array.
     */
    public static function run():Void {
        for (obj in flaggedObjs) {
            gMap.remove(obj);
        }

        flaggedObjs.resize(0);
    }

    /**
     * A public string property to store the name of the object.
     */
    public var name:String;

    /**
     * Constructor for the `BaseObject` class.
     * Initializes a new instance and registers it in the global map.
     */
    public function new() {
        gMap.set(this, this);
    }

    /**
     * Recycles the object by resetting its state.
     * This method can be overridden in subclasses to implement additional recycling logic.
     */
    public function recycle():Void {
        resetObject();
    }

    /**
     * Resets the object's state to its initial values.
     * Currently, this resets the `name` property to an empty string.
     * This method can be overridden in subclasses to reset additional properties.
     */
    public function resetObject():Void {
        name = "";
    }

    /**
     * Marks the object for destruction.
     * If `immediately` is set to `true`, the object is removed from the global map immediately.
     * Otherwise, the object is added to the flagged objects array for delayed destruction.
     * 
     * @param immediately Whether the object should be destroyed immediately or not.
     */
    public function destroy(immediately:Bool = false):Void {
        if (immediately) {
            gMap.remove(this);
        } else {
            flaggedObjs.push(this);
        }
    }

    /**
     * Provides a string representation of the object.
     * This method can be useful for debugging purposes.
     * 
     * @return A string that represents the current object.
     */
    public function toString():String {
        return Std.string(this);
    }
}