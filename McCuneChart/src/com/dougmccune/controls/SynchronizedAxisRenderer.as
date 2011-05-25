package com.dougmccune.controls
{
	import flash.display.DisplayObject;

	import mx.controls.Label;

	public class SynchronizedAxisRenderer extends AxisRendererExt
	{
		private var _synchronizedAxisCache:SynchronizedAxisCache;

		public function SynchronizedAxisRenderer()
		{
			super();
		}

		public function get synchronizedAxisCache():SynchronizedAxisCache
		{
			return _synchronizedAxisCache;
		}

		public function set synchronizedAxisCache(value:SynchronizedAxisCache):void
		{
			_synchronizedAxisCache = value;
		}

		override protected function updateDisplayList(unscaledWidth:Number,
													  unscaledHeight:Number):void
		{
//			super.updateDisplayList(unscaledWidth, unscaledHeight);
			if (false && synchronizedAxisCache && synchronizedAxisCache.isCompatibleAxisRendered(unscaledWidth, unscaledHeight, this))
			{
				setLabelsVisible(false);
				synchronizedAxisCache.copyAxis(this);
			}
			else
			{
				setLabelsVisible(true);
				super.updateDisplayList(unscaledWidth, unscaledHeight);
				if (synchronizedAxisCache)
					synchronizedAxisCache.updateRenderedStatus(unscaledWidth, unscaledHeight, this);
			}
		}

		private function setLabelsVisible(visible:Boolean):void
		{
//			for (var i:int = 0; i < this.numChildren; i++)
//			{
//				var child:DisplayObject = this.getChildAt(i);
//				child.visible = visible;
//			}
		}
	}
}