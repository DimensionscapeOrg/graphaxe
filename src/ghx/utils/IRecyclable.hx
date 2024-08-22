package ghx.utils;

/**
 * @author Christopher Speciale
 */
interface IRecyclable {
    /**
     * Resets the state of the object to make it ready for reuse.
     */
    public function recycle():Void;

    /**
     * Resets the object to a default state.
     */
    public function reset():Void;
}