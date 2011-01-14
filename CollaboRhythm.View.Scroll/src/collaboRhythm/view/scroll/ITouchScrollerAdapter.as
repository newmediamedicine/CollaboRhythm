package collaboRhythm.view.scroll
{
	import flash.display.Graphics;
	
	import mx.core.UIComponent;

	/**
	 * Adapter to enable touch scrolling for any scrollable component. The interface could be implemented by the
	 * component itself or by some other class which acts as an intermediary.
	 * 
	 * @author sgilroy
	 * @see collaboRhythm.workstation.view.scroll.TouchScroller
	 */
	public interface ITouchScrollerAdapter
	{
		function ITouchScrollerAdapter();
		function get component():UIComponent;
		/**
		 * Returns the container to which child controls (such as the scroll indicators) can be added 
		 * @return 
		 */
		function get componentContainer():UIComponent;
		function get graphics():Graphics;
		/**
		 * Returns the width of the panel or visible area in which scrollable content is displayed. 
		 * @return 
		 */
		function get panelWidth():Number;
		/**
		 * Returns the height of the panel or visible area in which scrollable content is displayed. 
		 * @return 
		 */
		function get panelHeight():Number;
		/**
		 * Returns the width of the content which can be scrolled. 
		 * @return 
		 */
		function get scrollableAreaWidth():Number;
		/**
		 * Returns the height of the content which can be scrolled. 
		 * @return 
		 */
		function get scrollableAreaHeight():Number;
		function get contentPositionX():Number;
		function set contentPositionX(value:Number):void;
		function get contentPositionY():Number;
		function set contentPositionY(value:Number):void;
		function hideScrollBarV():void;
		function hideScrollBarH():void;
		function showScrollBarV():void;
		function showScrollBarH():void;
		
//		function get grabCursor():Class;
	}
}