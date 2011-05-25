package com.dougmccune.controls
{
	import flash.display.BitmapData;

	import flash.geom.Matrix;

	import mx.charts.DateTimeAxis;
	import mx.graphics.ImageSnapshot;

	public class SynchronizedAxisCache
	{
		private var _lastRenderedAxis:SynchronizedAxisRenderer;
		private var _lastRenderedWidth:Number;
		private var _lastRenderedHeight:Number;
		private var _lastRenderedMinimumTime:Date;
		private var _lastRenderedMaximumTime:Date;

		public function SynchronizedAxisCache()
		{
		}

		public function updateRenderedStatus(unscaledWidth:Number, unscaledHeight:Number, synchronizedAxisRenderer:SynchronizedAxisRenderer):void
		{
			lastRenderedWidth = unscaledWidth;
			lastRenderedHeight = unscaledHeight;
			lastRenderedAxis = synchronizedAxisRenderer;

			var axis:DateTimeAxis = synchronizedAxisRenderer.axis as DateTimeAxis;
			lastRenderedMinimumTime = axis.minimum;
			lastRenderedMaximumTime = axis.maximum;
		}

		public function isCompatibleAxisRendered(unscaledWidth:Number, unscaledHeight:Number, synchronizedAxisRenderer:SynchronizedAxisRenderer):Boolean
		{
			var axis:DateTimeAxis = synchronizedAxisRenderer.axis as DateTimeAxis;
			return (lastRenderedWidth == unscaledWidth &&
//					lastRenderedHeight == unscaledHeight &&
					lastRenderedAxis != synchronizedAxisRenderer &&
					lastRenderedMinimumTime == axis.minimum &&
					lastRenderedMaximumTime == axis.maximum);
		}

		private var dyTest:Number = 15;

		public function copyAxis(synchronizedAxisRenderer:SynchronizedAxisRenderer):void
		{
//			synchronizedAxisRenderer.graphics.clear();
//			synchronizedAxisRenderer.graphics.copyFrom(lastRenderedAxis.graphics);
//			copyAxisBitmap(synchronizedAxisRenderer);
		}

		private function copyAxisBitmap(synchronizedAxisRenderer:SynchronizedAxisRenderer):void
		{
			var bitmapData:BitmapData = ImageSnapshot.captureBitmapData(lastRenderedAxis);
			synchronizedAxisRenderer.graphics.lineStyle(0, 0, 0);
			if (bitmapData)
			{
				var dy:Number = synchronizedAxisRenderer.height - lastRenderedHeight;
//				dy /= 2;
//				dy = -Math.abs(dy);
//				if (dy > 0)
//					dy = dyTest;
				var matrix:Matrix = new Matrix();
				matrix.translate(0, dy);
				synchronizedAxisRenderer.graphics.beginBitmapFill(bitmapData, matrix);
				synchronizedAxisRenderer.graphics.drawRect(0, dy, bitmapData.width, bitmapData.height);
//				synchronizedAxisRenderer.graphics.beginBitmapFill(bitmapData, null, false, false);
//				synchronizedAxisRenderer.graphics.drawRect(0, dy, bitmapData.width, bitmapData.height);
				synchronizedAxisRenderer.graphics.endFill();

//				synchronizedAxisRenderer.graphics.beginFill(0x0000FF, 0.2);
//				synchronizedAxisRenderer.graphics.drawRect(0, dy, bitmapData.width, bitmapData.height);
//				synchronizedAxisRenderer.graphics.endFill();
			}
		}

		public function get lastRenderedAxis():SynchronizedAxisRenderer
		{
			return _lastRenderedAxis;
		}

		public function set lastRenderedAxis(value:SynchronizedAxisRenderer):void
		{
			_lastRenderedAxis = value;
		}

		public function get lastRenderedWidth():Number
		{
			return _lastRenderedWidth;
		}

		public function set lastRenderedWidth(value:Number):void
		{
			_lastRenderedWidth = value;
		}

		public function get lastRenderedHeight():Number
		{
			return _lastRenderedHeight;
		}

		public function set lastRenderedHeight(value:Number):void
		{
			_lastRenderedHeight = value;
		}

		public function get lastRenderedMinimumTime():Date
		{
			return _lastRenderedMinimumTime;
		}

		public function set lastRenderedMinimumTime(value:Date):void
		{
			_lastRenderedMinimumTime = value;
		}

		public function get lastRenderedMaximumTime():Date
		{
			return _lastRenderedMaximumTime;
		}

		public function set lastRenderedMaximumTime(value:Date):void
		{
			_lastRenderedMaximumTime = value;
		}
	}
}