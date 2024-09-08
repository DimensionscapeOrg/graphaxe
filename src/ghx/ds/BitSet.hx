package ghx.ds;


abstract BitSet(IntMap<Int>) {
    public function new() {
        this = new IntMap<Int>();
    }

    @:arrayAccess
    public function get(index: Int): Bool {
        var arrayIndex = index >> 5; 
        var bitIndex = index & 31;

        var current = this[arrayIndex];
        if (current == null) return false;
        return (current & (1 << bitIndex)) != 0;
    }

    @:arrayAccess
    public function set(index: Int, value: Bool): Void {
        var arrayIndex = index >> 5; 
        var bitIndex = index & 31;

        if (value) {
            var current = this[arrayIndex];
            if (current == null) current = 0;
            this[arrayIndex] = current | (1 << bitIndex); // Set the bit
        } else {
            var current = this[arrayIndex];
            if (current != null) {
                var newVal = current & ~(1 << bitIndex); // Clear the bit
                if (newVal == 0) {
                    this.remove(arrayIndex); // Remove empty chunks
                } else {
                    this[arrayIndex] = newVal;
                }
            }
        }
    }

    public inline function clear(): Void {
        this = new IntMap<Int>();
    }

    public inline function remove(index:Int):Bool{
        this.remove(index);
    }
}