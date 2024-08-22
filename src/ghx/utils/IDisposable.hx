package ghx.utils;

/**
 * @author Christopher Speciale
 */
interface IDisposable {
    /**
     * Releases the resources used by the object.
     */
    public function destroy(immediately:Bool = false):Void;
}