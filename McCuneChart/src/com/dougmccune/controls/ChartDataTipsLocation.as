package com.dougmccune.controls
{
	public class ChartDataTipsLocation
	{
		private var _scrubChartId:String;
		private var _innerChartId:String;
		private var _localX:Number;
		private var _localY:Number;
		private var _sensitivity:Number;

		public function ChartDataTipsLocation(scrubChartId:String=null, innerChartId:String=null, localX:Number=NaN, localY:Number=NaN,
									  sensitivity:Number=NaN)
		{
			_scrubChartId = scrubChartId;
			_innerChartId = innerChartId;
			_localX = localX;
			_localY = localY;
			_sensitivity = sensitivity;
		}

		public function get innerChartId():String
		{
			return _innerChartId;
		}

		public function set innerChartId(value:String):void
		{
			_innerChartId = value;
		}

		public function get scrubChartId():String
		{
			return _scrubChartId;
		}

		public function set scrubChartId(value:String):void
		{
			_scrubChartId = value;
		}

		public function get localX():Number
		{
			return _localX;
		}

		public function set localX(value:Number):void
		{
			_localX = value;
		}

		public function get localY():Number
		{
			return _localY;
		}

		public function set localY(value:Number):void
		{
			_localY = value;
		}

		public function get sensitivity():Number
		{
			return _sensitivity;
		}

		public function set sensitivity(value:Number):void
		{
			_sensitivity = value;
		}
	}
}
