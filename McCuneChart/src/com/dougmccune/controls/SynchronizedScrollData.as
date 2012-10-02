package com.dougmccune.controls
{
	public class SynchronizedScrollData
	{
		private var _minimumTime:Number;
		private var _maximumTime:Number;
		private var _mainChartToContainerRatio:Number;
		private var _mainDataRatio:Number;
		private var _leftRangeTime:Number;
		private var _rightRangeTime:Number;
		private var _contentPositionX:Number;
		private var _sourceId:String;
		private var _stop:Boolean;

		public function SynchronizedScrollData(sourceId:String = null, minimumTime:Number = NaN,
											   maximumTime:Number = NaN, mainChartToContainerRatio:Number = NaN,
											   mainDataRatio:Number = NaN, leftRangeTime:Number = NaN,
											   rightRangeTime:Number = NaN, contentPositionX:Number = NaN,
											   stop:Boolean = false)
		{
			_sourceId = sourceId;
			_minimumTime = minimumTime;
			_maximumTime = maximumTime;
			_mainChartToContainerRatio = mainChartToContainerRatio;
			_mainDataRatio = mainDataRatio;
			_leftRangeTime = leftRangeTime;
			_rightRangeTime = rightRangeTime;
			_contentPositionX = contentPositionX;
			_stop = stop;
		}

		public static function create(chart:TouchScrollingScrubChart, stop:Boolean = false):SynchronizedScrollData
		{
			return new SynchronizedScrollData(chart.id, chart.minimumTime, chart.maximumTime,
					chart.mainChartToContainerRatio, chart.mainDataRatio, chart.leftRangeTime, chart.rightRangeTime,
					chart.contentPositionX, stop);
		}

		public function get minimumTime():Number
		{
			return _minimumTime;
		}

		public function set minimumTime(value:Number):void
		{
			_minimumTime = value;
		}

		public function get maximumTime():Number
		{
			return _maximumTime;
		}

		public function set maximumTime(value:Number):void
		{
			_maximumTime = value;
		}

		public function get mainChartToContainerRatio():Number
		{
			return _mainChartToContainerRatio;
		}

		public function set mainChartToContainerRatio(value:Number):void
		{
			_mainChartToContainerRatio = value;
		}

		public function get mainDataRatio():Number
		{
			return _mainDataRatio;
		}

		public function set mainDataRatio(value:Number):void
		{
			_mainDataRatio = value;
		}

		public function get leftRangeTime():Number
		{
			return _leftRangeTime;
		}

		public function set leftRangeTime(value:Number):void
		{
			_leftRangeTime = value;
		}

		public function get rightRangeTime():Number
		{
			return _rightRangeTime;
		}

		public function set rightRangeTime(value:Number):void
		{
			_rightRangeTime = value;
		}

		public function get contentPositionX():Number
		{
			return _contentPositionX;
		}

		public function set contentPositionX(value:Number):void
		{
			_contentPositionX = value;
		}

		public function get sourceId():String
		{
			return _sourceId;
		}

		public function set sourceId(value:String):void
		{
			_sourceId = value;
		}

		public function get stop():Boolean
		{
			return _stop;
		}

		public function set stop(value:Boolean):void
		{
			_stop = value;
		}
	}
}
