package com.dougmccune.controls
{

	import flash.display.DisplayObject;
	import flash.geom.Rectangle;

	import mx.charts.DateTimeAxis;
	import mx.charts.LinearAxis;
	import mx.charts.chartClasses.NumericAxis;

	import mx.core.UIComponent;

	import mx.utils.ObjectUtil;

	public class StaticAxisRenderer extends AxisRendererExt
	{
		private var _guttersEverAdjusted:Boolean;
		private var _previousWidth:Number;
		private var _previousHeight:Number;
		private var _previousGutters:Rectangle;
		private var _previousMinimum:Number;
		private var _previousMaximum:Number;

		public function StaticAxisRenderer()
		{
			super();
		}

		public override function adjustGutters(workingGutters:Rectangle, adjustable:Object):Rectangle
		{
			var ancestorId:String = getAncestorId(4);
			var logMessage:String = ancestorId + " adjustGutters width,height " + this.width + "," + this.height + " workingGutters(x,y,w,h)=(" + describeRectangle(workingGutters) + ")";

			var result:Rectangle;

			var linearAxis:LinearAxis = this.axis as LinearAxis;
			var minimum:Number = linearAxis ? linearAxis.minimum : NaN;
			var maximum:Number = linearAxis ? linearAxis.maximum : NaN;

            // TODO: Remove this hack and find a better way to avoid unnecessary calls to adjustGutters
            // Note that this only works because adjustGutters gets called once with bottom = 0, and then later with bottom = 20 for our particular situation.
            // Detecting and eliminating unnecessary calls to adjustGutters may require changes to CartesianChart.
			if (workingGutters.bottom == 0 ||
					(_guttersEverAdjusted &&
						this.width == _previousWidth &&
						this.height == _previousHeight &&
						minimum == _previousMinimum &&
						maximum == _previousMaximum &&
						workingGutters.equals(_previousGutters)
					)
				)
			{
				_logger.info(logMessage + "; skipping adjustment");
				result = workingGutters;
			}
			else
			{
				_logger.info(logMessage + "; adjusting...");
				_guttersEverAdjusted = true;
				_previousWidth = this.width;
				_previousHeight = this.height;
				_previousMinimum = minimum;
				_previousMaximum = maximum;
                _previousGutters = super.adjustGutters(workingGutters, adjustable);
				result = _previousGutters;
			}
			return result;
		}

		private function getAncestorId(generations:int):String
		{
			var ancestor:DisplayObject = this;
			for (var i:int = 0; i < generations; i++)
			{
				if (ancestor.parent == null)
					break;
				ancestor = ancestor.parent;
			}

			var component:UIComponent = (ancestor as UIComponent);
			return component ? component.id : null;
		}

		private function describeRectangle(rectangle:Rectangle):String
		{
			return rectangle.x + "," + rectangle.y + "," + rectangle.width + "," + rectangle.height;
		}
		
	}
}