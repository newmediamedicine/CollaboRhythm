package collaboRhythm.shared.ui.healthCharts.model.modifiers
{
	import flash.display.Graphics;

	import mx.charts.renderers.AreaRenderer;

	public class AreaRendererEx extends AreaRenderer
	{
		public function AreaRendererEx()
		{
			super();
		}

		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			var boundary:Array /* of Object */ = data.filteredCache;
			var n:int = boundary.length;

			if (n <= 1)
			{
				var g:Graphics = graphics;
				g.clear();
			}
			else
			{
				super.updateDisplayList(unscaledWidth, unscaledHeight);
			}
		}
	}
}
