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
	import mx.containers.HBox;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	import flash.display.SpreadMethod;
	
	
	public class GradientBox extends HBox
	{
        import flash.display.Graphics;
        
        [Bindable]
        public var gradientColors:Array;
        [Bindable]
        public var gradientAlphas:Array;
        [Bindable]
        public var gradientRatios:Array;
        [Bindable]
        public var gradientAngle:int;
        [Bindable]
        public var innerRadius:Number;
        
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            super.updateDisplayList(unscaledWidth, unscaledHeight);
            
            var fillType:String = GradientType.LINEAR;
            var colors:Array = gradientColors;
            var alphas:Array = gradientAlphas;
            var ratios:Array = gradientRatios;
            var matrix:Matrix = new Matrix();
            matrix.createGradientBox(unscaledWidth, unscaledHeight, (gradientAngle * Math.PI/180));
            
            var spreadMethod:String = SpreadMethod.PAD;
            
            graphics.clear();
            graphics.beginGradientFill(fillType, colors, alphas, ratios, matrix, spreadMethod);
            if(isNaN(innerRadius))
            {
                graphics.drawRect(1, 1, unscaledWidth - 1, unscaledHeight - 1);
            }
            else
            {
                graphics.drawRoundRect(1, 1, unscaledWidth - 2, unscaledHeight - 2, innerRadius);
            }
            graphics.endFill();
        }
	}
}