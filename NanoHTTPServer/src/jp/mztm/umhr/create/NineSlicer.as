package jp.mztm.umhr.create
{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author umhr
	 */
	public class NineSlicer 
	{
		
		public function NineSlicer() 
		{
			
		}
		static public function scale(bitmapData:BitmapData, width:int, height:int, rectangle:Rectangle = null):BitmapData {
			if (rectangle == null) {
				rectangle = new Rectangle();
				rectangle.x = Math.floor(bitmapData.width >> 1);
				rectangle.y = Math.floor(bitmapData.height >> 1);
				rectangle.width = 1;
				rectangle.height = 1;
			}
			
			var t1x:int = rectangle.x;
			var t2x:int = rectangle.right + width - bitmapData.width;
			var t1y:int = rectangle.y;
			var t2y:int = rectangle.bottom + height - bitmapData.height;
			
			var matrix:Matrix = new Matrix();
			var clipRectangle:Rectangle = new Rectangle();
			var result:BitmapData = new BitmapData(width, height, true, 0x00000000);
			clipRectangle.x = 0;
			clipRectangle.y = 0;
			clipRectangle.width = t1x;
			clipRectangle.height = t1y;
			result.draw(bitmapData, matrix, null, null, clipRectangle);
			
			// ue
			var tempBitmapData:BitmapData = new BitmapData(rectangle.width, rectangle.y, true, 0x00000000);
			tempBitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, -rectangle.x));
			var shape:Shape = new Shape();
			shape.graphics.beginBitmapFill(tempBitmapData, null, true);
			shape.graphics.drawRect(0, 0, t2x - t1x, t1y);
			shape.graphics.endFill();
			result.draw(shape, new Matrix(1, 0, 0, 1, t1x, 0));
			
			// migiue
			matrix.tx = t2x -t1x-rectangle.width;
			matrix.ty = 0;
			clipRectangle.x = t2x;
			clipRectangle.y = 0;
			clipRectangle.width = width - t2x;
			clipRectangle.height = t1y;
			result.draw(bitmapData, matrix, null, null, clipRectangle);
			
			
			tempBitmapData = new BitmapData(rectangle.x, rectangle.height, true, 0x00000000);
			tempBitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, 0, -rectangle.y));
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(tempBitmapData, null, true);
			shape.graphics.drawRect(0, 0, t1x, t2y - t1y);
			shape.graphics.endFill();
			result.draw(shape, new Matrix(1, 0, 0, 1, 0, t1y));
			
			
			tempBitmapData = new BitmapData(rectangle.width, rectangle.height, true, 0x00000000);
			tempBitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, -rectangle.x, -rectangle.y));
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(tempBitmapData, null, true);
			shape.graphics.drawRect(0, 0, t2x - t1x, t2y - t1y);
			shape.graphics.endFill();
			result.draw(shape, new Matrix(1, 0, 0, 1, t1x, t1y));
			
			
			tempBitmapData = new BitmapData(bitmapData.width - rectangle.right, rectangle.height, true, 0x00000000);
			tempBitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, -rectangle.x - rectangle.width, -rectangle.y));
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(tempBitmapData, null, true);
			shape.graphics.drawRect(0, 0, width - t2x, t2y - t1y);
			shape.graphics.endFill();
			result.draw(shape, new Matrix(1, 0, 0, 1, t2x, t1y));
			
			
			// hidarishita
			matrix.tx = 0;
			matrix.ty = t2y -t1y - rectangle.height;
			clipRectangle.x = 0;
			clipRectangle.y = t2y;
			clipRectangle.width = t1x;
			clipRectangle.height = height - t2y;
			result.draw(bitmapData, matrix, null, null, clipRectangle);
			
			
			// shita
			tempBitmapData = new BitmapData(rectangle.width, bitmapData.height - rectangle.bottom, true, 0x00000000);
			tempBitmapData.draw(bitmapData, new Matrix(1, 0, 0, 1, -rectangle.x, -rectangle.y - rectangle.height));
			shape.graphics.clear();
			shape.graphics.beginBitmapFill(tempBitmapData, null, true);
			shape.graphics.drawRect(0, 0, t2x - t1x, height - t2y);
			shape.graphics.endFill();
			result.draw(shape, new Matrix(1, 0, 0, 1, t1x, t2y));
			
			
			// migishita
			matrix.tx = t2x -t1x - rectangle.width;
			matrix.ty = t2y -t1y - rectangle.height;
			clipRectangle.x = t2x;
			clipRectangle.y = t2y;
			clipRectangle.width = width - t2x;
			clipRectangle.height = height - t2y;
			result.draw(bitmapData, matrix, null, null, clipRectangle);
			
			return result;
		}		
	}

}