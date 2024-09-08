package ghx._internal.utils.rect;

import ghx.geom.Rectangle;

class RectanglePacker {
    private var totalWidth:Int = 0;
    private var totalHeight:Int = 0;
    private var margin:Int = 0;

    private var computedWidth:Int = 0;
    private var computedHeight:Int = 0;

    private var sizeQueue:Array<PackableSize> = [];
    private var packedRects:Array<PackedRect> = [];
    private var freeRects:Array<PackedRect> = [];
    private var tempFreeRects:Array<PackedRect> = [];

    private var outerBounds:PackedRect;

    private var sizeCache:Array<PackableSize> = [];
    private var rectCache:Array<PackedRect> = [];

    public var numRects(get, never):Int;

    private function get_numRects():Int {
        return packedRects.length;
    }

    public var totalPackedWidth(get, never):Int;

    private function get_totalPackedWidth():Int {
        return computedWidth;
    }

    public var totalPackedHeight(get, never):Int;

    private function get_totalPackedHeight():Int {
        return computedHeight;
    }

    public var paddingSize(get, never):Int;

    private function get_paddingSize():Int {
        return margin;
    }

    public function new(width:Int, height:Int, padding:Int = 0) {
        outerBounds = new PackedRect(width + 1, height + 1, 0, 0);
        initialize(width, height, padding);
    }

    public function initialize(width:Int, height:Int, padding:Int = 0):Void {
        clearPackedRects();
        clearFreeRects();

        totalWidth = width;
        totalHeight = height;
        computedWidth = 0;
        computedHeight = 0;
        margin = padding;

        freeRects.push(createRect(0, 0, totalWidth, totalHeight));
        clearSizeQueue();
    }

    public function getRect(index:Int):Rectangle {
        var rect:PackedRect = packedRects[index];
        return new Rectangle(rect.xPos, rect.yPos, rect.width, rect.height);
    }

    public function getRectId(index:Int):Int {
        return packedRects[index].identifier;
    }

    public function addRect(width:Int, height:Int, id:Int):Void {
        sizeQueue.push(createSize(width, height, id));
    }

    public function pack(sort:Bool = true):Int {
        if (sort) {
            sortSizeQueue();
        }

        while (sizeQueue.length > 0) {
            var size:PackableSize = sizeQueue.pop();
            var paddedDimensions = getPaddedDimensions(size.width, size.height);

            var index:Int = findFreeRectIndex(paddedDimensions.width, paddedDimensions.height);
            if (index >= 0) {
                placeRectInFreeSpace(size, index);
            }

            recycleSize(size);
        }

        return numRects;
    }

    private function sortSizeQueue():Void {
        sizeQueue.sort((a, b) -> a.width - b.width);
    }

    private function clearPackedRects():Void {
        while (packedRects.length > 0) {
            recycleRect(packedRects.pop());
        }
    }

    private function clearFreeRects():Void {
        while (freeRects.length > 0) {
            recycleRect(freeRects.pop());
        }
    }

    private function clearSizeQueue():Void {
        while (sizeQueue.length > 0) {
            recycleSize(sizeQueue.pop());
        }
    }

    private function placeRectInFreeSpace(size:PackableSize, index:Int):Void {
        var freeRect:PackedRect = freeRects[index];
        var targetRect:PackedRect = createRect(freeRect.xPos, freeRect.yPos, size.width, size.height);
        targetRect.identifier = size.identifier;

        createNewFreeRects(targetRect, freeRects, tempFreeRects);
        while (tempFreeRects.length > 0) {
            freeRects.push(tempFreeRects.pop());
        }

        packedRects.push(targetRect);
        updateComputedDimensions(targetRect);
    }

    private function updateComputedDimensions(rect:PackedRect):Void {
        computedWidth = Std.int(Math.max(computedWidth, rect.rightEdge));
        computedHeight = Std.int(Math.max(computedHeight, rect.bottomEdge));
    }

    private function getPaddedDimensions(width:Int, height:Int):{ width:Int, height:Int } {
        return { width: width + margin, height: height + margin };
    }

    private function filterContainedRects(rectangles:Array<PackedRect>):Void {
		var i:Int = 0;
		while (i < rectangles.length) {
			var rect:PackedRect = rectangles[i];
			var isContained:Bool = false;
	
			for (j in i + 1...rectangles.length) {
				var comparisonRect:PackedRect = rectangles[j];
				if (rect.isContainedIn(comparisonRect)) {
					recycleRect(rectangles.splice(i, 1)[0]);
					isContained = true;
					break;
				}
			}
	
			if (!isContained) {
				i++;
			}
		}
	}

    private function createNewFreeRects(target:PackedRect, existing:Array<PackedRect>, results:Array<PackedRect>):Void {
		var paddedRect = margin == 0 ? target : createRect(target.xPos, target.yPos, target.width + margin, target.height + margin);
	
		var i:Int = 0;
		while (i < existing.length) {
			var area:PackedRect = existing[i];
			if (target.intersects(area)) {
				divideRectAreas(paddedRect, area, results);
				existing.splice(i, 1);  // Remove the intersected area
			} else {
				i++;  // Only increment i if no element was removed
			}
		}
	
		if (paddedRect != target) {
			recycleRect(paddedRect);
		}
	
		filterContainedRects(results);
	}

    private function divideRectAreas(divider:PackedRect, area:PackedRect, results:Array<PackedRect>):Void {
        var rightGap:Int = area.rightEdge - divider.rightEdge;
        var leftGap:Int = divider.xPos - area.xPos;
        var bottomGap:Int = area.bottomEdge - divider.bottomEdge;
        var topGap:Int = divider.yPos - area.yPos;

        if (rightGap > 0) results.push(createRect(divider.rightEdge, area.yPos, rightGap, area.height));
        if (leftGap > 0) results.push(createRect(area.xPos, area.yPos, leftGap, area.height));
        if (bottomGap > 0) results.push(createRect(area.xPos, divider.bottomEdge, area.width, bottomGap));
        if (topGap > 0) results.push(createRect(area.xPos, area.yPos, area.width, topGap));

        if (results.length == 0 && (divider.width < area.width || divider.height < area.height)) {
            results.push(area);
        } else {
            recycleRect(area);
        }
    }

    private function findFreeRectIndex(width:Int, height:Int):Int {
        var bestMatch:PackedRect = outerBounds;
        var index:Int = -1;

        for (i in 0...freeRects.length) {
            var free:PackedRect = freeRects[i];
            if (isBetterMatch(free, bestMatch, width, height)) {
                bestMatch = free;
                index = i;
                if (isPerfectMatch(free, width, height)) break;
            }
        }

        return index;
    }

    private function isBetterMatch(free:PackedRect, bestMatch:PackedRect, width:Int, height:Int):Bool {
        var paddedWidth:Int = width + margin;
        var paddedHeight:Int = height + margin;

        return (free.xPos < bestMatch.xPos && paddedWidth <= free.width && paddedHeight <= free.height)
            || (free.xPos < bestMatch.xPos && width <= free.width && height <= free.height);
    }

    private function isPerfectMatch(free:PackedRect, width:Int, height:Int):Bool {
        return (width == free.width && free.width <= free.height && free.rightEdge < totalWidth)
            || (height == free.height && free.height <= free.width);
    }

    private function createRect(x:Int, y:Int, width:Int, height:Int):PackedRect {
        return rectCache.length > 0 ? rectCache.pop().setPosition(x, y, width, height) : new PackedRect(x, y, width, height);
    }

    private function recycleRect(rect:PackedRect):Void {
        rectCache.push(rect);
    }

    private function createSize(width:Int, height:Int, id:Int):PackableSize {
        return sizeCache.length > 0 ? sizeCache.pop().setDimensions(width, height, id) : new PackableSize(width, height, id);
    }

    private function recycleSize(size:PackableSize):Void {
        sizeCache.push(size);
    }
}

private class PackableSize {
    public var width:Int;
    public var height:Int;
    public var identifier:Int;
    public var area:Int;

    public function new(width:Int, height:Int, id:Int) {
        setDimensions(width, height, id);
    }

    public function setDimensions(width:Int, height:Int, id:Int):PackableSize {
        this.width = width;
        this.height = height;
        this.identifier = id;
        this.area = width * height;
        return this;
    }
}

private class PackedRect {
    public var xPos:Int;
    public var yPos:Int;
    public var width:Int;
    public var height:Int;
    public var rightEdge:Int;
    public var bottomEdge:Int;
    public var identifier:Int;

    public function new(x:Int = 0, y:Int = 0, width:Int = 0, height:Int = 0) {
        setPosition(x, y, width, height);
    }

    public function setPosition(x:Int, y:Int, width:Int, height:Int):PackedRect {
        this.xPos = x;
        this.yPos = y;
        this.width = width;
        this.height = height;
        this.rightEdge = x + width;
        this.bottomEdge = y + height;
        return this;
    }

    public function isContainedIn(other:PackedRect):Bool {
        return xPos >= other.xPos && yPos >= other.yPos && rightEdge <= other.rightEdge && bottomEdge <= other.bottomEdge;
    }

    public function intersects(other:PackedRect):Bool {
        return !(xPos >= other.rightEdge || rightEdge <= other.xPos || yPos >= other.bottomEdge || bottomEdge <= other.yPos);
    }
}