package com.leebrimelow.drawing
{
        /*
         * This class is based on code written by Ric Ewing (www.ricewing.com).
         * See the details at http://www.adobe.com/devnet/flash/articles/adv_draw_methods.html.
         * I made several changes including the sending the target Sprite to the function.
         * Usage: Wedge.draw(mySprite, 350, 200, 100, arcAngle);
        */
        
        import flash.display.*;
        
        import mx.core.UIComponent;
        
		/**
		 * http://code.google.com/p/leebrimelow/source/browse/trunk/as3/com/leebrimelow/drawing/Wedge.as?r=9
		 * 
		 * MIT License: http://www.opensource.org/licenses/mit-license.php
		 * 
		 */
        public class Wedge
        {
                public static function draw(t:UIComponent, sx:Number, sy:Number, radius:Number, arc:Number, startAngle:Number=0):void 
                {
                        var segAngle:Number;
                        var angle:Number;
                        var angleMid:Number;
                        var numOfSegs:Number;
                        var ax:Number;
                        var ay:Number;
                        var bx:Number;
                        var by:Number;
                        var cx:Number;
                        var cy:Number;
                        
                        // Move the pen
                        t.graphics.moveTo(sx, sy);
                        
                        // No need to draw more than 360
                        if (Math.abs(arc) > 360) 
                        {
                                arc = 360;
                        }
                        
                        numOfSegs = Math.ceil(Math.abs(arc) / 45);
                        segAngle = arc / numOfSegs;
                        segAngle = (segAngle / 180) * Math.PI;
                        angle = (startAngle / 180) * Math.PI;
                        
                        // Calculate the start point
                        ax = sx + Math.cos(angle) * radius;
                        ay = sy + Math.sin(angle) * radius;
                        
                        // Draw the first line
                        t.graphics.lineTo(ax, ay);

                        for (var i:int=0; i<numOfSegs; i++) 
                        {
                                angle += segAngle;
                                angleMid = angle - (segAngle / 2);
                                bx = sx + Math.cos(angle) * radius;
                                by = sy + Math.sin(angle) * radius;
                                cx = sx + Math.cos(angleMid) * (radius / Math.cos(segAngle / 2));
                                cy = sy + Math.sin(angleMid) * (radius / Math.cos(segAngle / 2));
                                t.graphics.curveTo(cx, cy, bx, by);
                        }
                        
                        // Close the wedge
                        t.graphics.lineTo(sx, sy);
                }
        }
}