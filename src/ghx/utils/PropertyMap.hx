package ghx.utils;

/**
 * `PropertyMap<T>` is an abstract type that provides an object-like interface over a `Map<String, T>`. 
 * It allows for easy manipulation and access of key-value pairs as if they were object properties.
 * The abstract includes several static utility methods for common operations, such as checking for the 
 * existence of a property, clearing all properties, deleting a specific property, and getting the size 
 * of the map. Additionally, it supports array-like access to map entries using overridden operators.
 *
 * @param T The type of values stored in the map.
 * 
 * @author Christopher Speciale
 */
abstract PropertyMap<T>(Map<String, T>) from Map<String, T> to Map<String, T> {
	/**
	 * Checks if a given property exists in the map.
	 *
	 * @param object The `PropertyMap<Any>` instance.
	 * @param property The key to check for existence in the map.
	 * @return `true` if the property exists, otherwise `false`.
	 */
	public static function hasProperty(object:PropertyMap<Any>, property:String):Bool {
		var map:Map<String, Any> = (cast object : Map<String, Any>);
		return map.exists(property);
	}

	/**
	 * Clears all entries from the map.
	 *
	 * @param object The `PropertyMap<Any>` instance.
	 */
	public static function clear(object:PropertyMap<Any>):Void {
		var map:Map<String, Any> = (cast object : Map<String, Any>);
		map.clear();
	}

	 /**
     * Deletes a specific property from the map.
     *
     * @param object The `PropertyMap<Any>` instance.
     * @param property The key of the property to be deleted from the map.
     */
	public static function delete(object:PropertyMap<Any>, property:String):Void {
		var map:Map<String, Any> = (cast object : Map<String, Any>);
		map.remove(property);
	}

	/**
     * Gets the number of entries in the map.
     *
     * @param object The `PropertyMap<Any>` instance.
     * @return The number of key-value pairs in the map.
     */
	public static function size(object:PropertyMap<Any>):Int {
		var n:Int = 0;
		var map:Map<String, Any> = (cast object : Map<String, Any>);

		for (obj in map) {
			n++;
		}
		return n;
	}

	/**
     * Returns an iterator over the values in the map.
     *
     * @param object The `PropertyMap<Any>` instance.
     * @return An iterator over the values in the map.
     */
	public static function iterator(object:PropertyMap<Any>):Iterator<Any> {
		var map:Map<String, Any> = (cast object : Map<String, Any>);
		return map.iterator();
	}

	/**
     * Creates a new `PropertyMap<T>` instance.
     */
	public inline function new() {
		this = new Map<String, T>();
	}

	@:arrayAccess
	@:op(a.b)
	private inline function __get__(key:String):T {
		return this.get(key);
	}

	@:arrayAccess
	@:op(a.b)
	private inline function __set__(key:String, value:T):T {
		this.set(key, value);
		return value;
	}
}
