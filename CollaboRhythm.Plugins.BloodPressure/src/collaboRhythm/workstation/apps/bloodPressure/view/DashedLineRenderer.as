package collaboRhythm.workstation.apps.bloodPressure.view
{
	import mx.charts.renderers.LineRenderer;
	import mx.graphics.IStroke;
	import mx.charts.chartClasses.GraphicsUtilities;

	public class DashedLineRenderer extends LineRenderer 
	{
		private var _lineSegment:Object;
		private var _pattern:Array = [10,15];

		public function DashedLineRenderer() {
			super();
		}
				
		[Inspectable(environment="none")]
		override public function get data():Object
		{
			return _lineSegment;
		}

		override public function set data(value:Object):void
		{
			_lineSegment = value;
			invalidateDisplayList();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number,
												  unscaledHeight:Number):void
		{
			var stroke:IStroke = getStyle("lineStroke");		
			var form:String = getStyle("form");
			var pattern:Array = getStyle("dashingPattern");
			pattern = (pattern == null) ? _pattern : pattern;
			
			graphics.clear();
	
			DashedGraphicUtilities.drawDashedPolyLine(graphics, stroke, pattern, _lineSegment.items);
		}
	}
}