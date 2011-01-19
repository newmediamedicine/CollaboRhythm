/*
Copyright (c) 2007 Brendan Meutzner

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

	import mx.charts.ChartItem;
	import mx.charts.renderers.CircleItemRenderer;

	public class LineSeriesCustomRenderer extends CircleItemRenderer
	{
	    public var _chartItem:ChartItem;
	   
	    
	    
	    override public function get data():Object
	    {
	        return _chartItem;
	    }
	
	    override public function set data(value:Object):void
	    {
	        _chartItem = ChartItem(value);
	        this.alpha = 0;

	    }
		
/**
 *  Constructor
 */
 		public function LineSeriesCustomRenderer():void
	    {
	        super();
	    }
	    
	    public function showRenderer(value:Boolean):void
	    {
	    	//if we show this renderer instance, set it's alpha to full, if not, set it's alpha to none and refresh display
	    	(value) ? this.alpha = 1 : this.alpha = 0;
	    }

	    
	    
	}
 
}
