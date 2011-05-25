package com.dougmccune.controls
{
    import flash.geom.Rectangle;

    public class StaticAxisRenderer extends AxisRendererExt
	{
		public function StaticAxisRenderer()
		{
			super();
		}

		private var _guttersEverAdjusted:Boolean;
		private var _previousWidth:Number;
		private var _previousHeight:Number;
        private var _previousGutters:Rectangle;
		
		public override function adjustGutters(workingGutters:Rectangle, adjustable:Object):Rectangle
		{
            // TODO: Remove this hack and find a better way to avoid unnecessary calls to adjustGutters
            // Note that this only works because adjustGutters gets called once with bottom = 0, and then later with bottom = 20 for our particular situation.
            // Detecting and eliminating unnecessary calls to adjustGutters may require changes to CartesianChart.
			if (workingGutters.bottom == 0 || (_guttersEverAdjusted && this.width == _previousWidth && this.height == _previousHeight && workingGutters.equals(_previousGutters)))
			{
				return workingGutters;
			}
			else
			{
				_guttersEverAdjusted = true;
				_previousWidth = this.width;
				_previousHeight = this.height;
                _previousGutters = super.adjustGutters(workingGutters, adjustable);
				return _previousGutters;
			}
		}
		
	}
}