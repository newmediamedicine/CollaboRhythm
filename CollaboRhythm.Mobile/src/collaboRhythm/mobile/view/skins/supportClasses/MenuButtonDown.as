package collaboRhythm.mobile.view.skins.supportClasses
{
	import flash.display.Graphics;
	
	import spark.core.SpriteVisualElement;
	
	public class MenuButtonDown extends SpriteVisualElement
	{
		public function MenuButtonDown()
		{
			super();
		}
		
		/**
		 * Called during the validation pass by the Flex LayoutManager via
		 * the layout object.
		 * @param width
		 * @param height
		 * @param postLayoutTransform
		 * 
		 */
		override public function setLayoutBoundsSize(width:Number, height:Number, postLayoutTransform:Boolean=true):void 
		{
			super.setLayoutBoundsSize(width, height, postLayoutTransform);
			
			//call our drawing function
			draw(width, height);
		}
		
		/**
		 * Draw the ruler 
		 * 
		 * TODO: logic to actually reuse commands and data if nothing has changed
		 * @param w width of ruler
		 * @param h height of ruler
		 * 
		 */
		protected function draw(w:Number, h:Number):void 
		{
			var g:Graphics = this.graphics;
			
			w = isNaN(w) ? this.width : w;
			h = (isNaN(h) ? this.height : h) - 1;
			
			//redraw
			g.clear();
			
			// TODO: draw a shadow (?) around the inner edge of the button
//			g.beginFill(
//			g.drawRect(0, 0, w, h);
//			g.endFill();
		}
	}
}