/*
Copyright (c) 2007 Brendan Meutzner

*Adapted from example by Ely Greenfield - www.quietlyscheming.com*


Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
*/
package skins
{
	import mx.core.UIComponent;
	import mx.charts.chartClasses.IAxisRenderer;
	import mx.charts.chartClasses.IAxis;
	import flash.geom.Rectangle;
	import mx.charts.chartClasses.AxisLabelSet;
	import mx.controls.Label;
	import mx.charts.AxisLabel;
	import mx.states.SetStyle;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import mx.charts.chartClasses.ChartBase;
	import mx.charts.chartClasses.CartesianChart;
	
	[Style(name="axisBackgroundColor", type="uint", format="Color", inherit="no")]
	[Style(name="axisBackgroundAlpha", type="Number", inherit="no")]
	[Style(name="labelAlign", type="String", inherit="no")]
	[Style(name="labelPaddingLeft", type="Number", inherit="no")]
	[Style(name="labelFontColor", type="uint", format="Color", inherit="no")]
	[Style(name="labelFontSize", type="Number", inherit="no")]


	public class InnerAxisRenderer extends UIComponent implements IAxisRenderer
	{
		public var axisWidth:Number;
		public var axisPosition:String;
		
		
		//private var maskSprite:Sprite;
		private var _horizontal:Boolean;
		private var _axis:IAxis;
		private var _gutters:Rectangle;
		private var _labelData:AxisLabelSet;
		private var _labels:Array = [];
		private var _titles:Array = [];
		
		
		public function InnerAxisRenderer()
		{
			super();					
		}
		
		
		public function get horizontal():Boolean
		{return _horizontal;}
		public function set horizontal(value:Boolean):void
		{_horizontal=value;}
	
		public function chartStateChanged(oldState:uint,v:uint):void
		{}
	
		public function set otherAxes(value:Array):void
		{}
	
		public function get axis():IAxis
		{return _axis;}
		public function set axis(value:IAxis):void
		{
			_axis = value;
		}
		
		public function set heightLimit(value:Number):void
		{}
		public function get heightLimit():Number
		{return 0;}
	
		public function get placement():String
		{return "bottom" }
		public function set placement(value:String):void
		{}
	
		private function get axisLength():Number
		{
			return (_horizontal) ? (unscaledWidth - _gutters.left - _gutters.right) : (unscaledHeight - _gutters.top - _gutters.bottom);
		}
	
		public function get gutters():Rectangle
		{return _gutters;}
		public function set gutters(value:Rectangle):void
		{
            if (!_gutters || !_gutters.equals(value))
            {
                _gutters = value;
                if(_axis == null)
                    return;

                _labelData = _axis.getLabels(axisLength);

                for(var i:int = 0; i < _labels.length; i++)
                {
                    removeChild(_labels[i]);
                }

                _labels = [];

                for(i = 0; i < _labelData.labels.length; i++)
                {
                    var l:Label = new Label();
                    if(_horizontal)
                    {
                        l.setStyle('textAlign', this.getStyle('labelAlign'));
                        l.setStyle('fontSize', this.getStyle('labelFontSize'));
                        l.setStyle('color', this.getStyle('labelFontColor'));
                        l.setStyle('paddingLeft', this.getStyle('labelPaddingLeft'));
                        l.data = AxisLabel(_labelData.labels[i]).text;
                        _labels.push(l);
                        addChild(l);
                        l.validateNow();

                    }
                    else
                    {
                        if(i % 2 == 0)
                        {
                            (axisPosition == 'left') ? l.setStyle('textAlign', 'left') : l.setStyle('textAlign', 'right');
                            l.setStyle('fontSize', this.getStyle('labelFontSize'));
                            l.setStyle('color', this.getStyle('labelFontColor'));
                            l.data = AxisLabel(_labelData.labels[i]).text;
                            _labels.push(l);
                            addChild(l);
                            l.validateNow();

                        }
                    }
                }

                invalidateDisplayList();
            }
		}
		
		public function get ticks():Array
		{
			if(_labelData == null)
				return [];
			else if (_horizontal)
				return _labelData.ticks;
			else
			{
				var t:Array = [];
				for(var i:int = 0;i<_labelData.ticks.length;i++)
					t.unshift(1 - _labelData.ticks[i]);
				return t;
			}
		}
		
		//called to redraw axis in the event that series data info is not provided soon enough
		public function refresh():void
		{
			this.gutters = _gutters;
		}
		
		public function get minorTicks():Array
		{
			return (_labelData == null)? []:_labelData.minorTicks;
		}
			
		
		public function adjustGutters(workingGutters:Rectangle, adjustable:Object):Rectangle
		{
			gutters = workingGutters.clone();
			return workingGutters;
		}
	
		
			
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			graphics.clear();
			var axisLen:Number = axisLength;
			
			//horizontalAxis
			if(_horizontal)
			{
				graphics.beginFill(this.getStyle('axisBackgroundColor'), this.getStyle('axisBackgroundAlpha'));
				graphics.drawRect(0, unscaledHeight - axisWidth, unscaledWidth, axisWidth);
				graphics.endFill();	
			}
			//verticalAxis
			else
			{
				graphics.beginFill(this.getStyle('axisBackgroundColor'), this.getStyle('axisBackgroundAlpha'));
				graphics.drawRect(0,0,axisWidth,unscaledHeight);
				graphics.endFill();
				
				graphics.lineStyle(1, 0x666666, 1);
				if(axisPosition == 'left') {
					graphics.moveTo(0 + _gutters.left, 0);
			        graphics.lineTo(0 + _gutters.left, unscaledHeight - _gutters.bottom);
				} else if(axisPosition == 'right') {
					graphics.moveTo(unscaledWidth - _gutters.right, 0);
			        graphics.lineTo(unscaledWidth - _gutters.right, unscaledHeight - _gutters.bottom);
				}
			}
			
			var l:Label;
			var tInst:Label;
			var ld:AxisLabel;
			//horizontalAxis
			if(_horizontal)
			{
				for (var i:int = 0; i < _labels.length; i++)
				{
					l = _labels[i];
					ld = _labelData.labels[i];
					
					var left:Number = axisLen * ld.position;// - l.measuredWidth/2;
					l.move(left, (unscaledHeight - axisWidth));
					
					var width:Number = l.measuredWidth;
					if (i + 1 < _labels.length)
					{
						var nextLabelData:AxisLabel = _labelData.labels[i + 1];
						width = axisLen * Math.abs(nextLabelData.position - ld.position);
					}
					else if (i > 0)
					{
						var prevLabelData:AxisLabel = _labelData.labels[i - 1];
						width = axisLen * Math.abs(prevLabelData.position - ld.position);
					}
						
					l.setActualSize(width,axisWidth);
				}
			}
			//vertical axis
			else
			{
				for (var k:int = 0;k<_labels.length;k++)
				{
					l = _labels[k];
					ld = _labelData.labels[k*2];
					var top:Number = axisLen * (1-ld.position) - l.measuredHeight;					
					// TODO: remove + 4 hack; this is to compensate for truncating which occurs 
					width = l.measuredWidth + 4;
					(axisPosition == 'left') ? l.move(0 + _gutters.left, top) : l.move((unscaledWidth - width - _gutters.right), top);
					l.setActualSize(width,axisWidth);
				}

			}
		}
	}
}