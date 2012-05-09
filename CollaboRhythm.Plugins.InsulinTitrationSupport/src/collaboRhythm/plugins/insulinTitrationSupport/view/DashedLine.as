package collaboRhythm.plugins.insulinTitrationSupport.view
{
	import flash.display.Shape;
	import flash.events.Event;

	import spark.primitives.Rect;

	public class DashedLine extends Rect
	{
		public function DashedLine()
		{
		}

		/** Color of the primary dash in the line */
		public function set dotColor( value:uint  ):void
		{
			_dotColor = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** Alpha of the primary dash in the line */
		public function set dotAlpha( value:Number ): void
		{
			_dotAlpha = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** With od the primary dash in the line */
		public function set dotWidth( value:Number ):void
		{
			_dotWidth = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** Height of the primary dash in the line */
		public function set dotHeight( value:Number ):void
		{
			_dotHeight = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/**
		 * Color of the spacer in the line (usually transparent, but can
		 * be another color)
		 */
		public function set spacerColor( value:uint ):void
		{
			_spacerColor = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/**
		 * Alpha of the spacer in the line. (usually transparent, but doesn't
		 * have to be)
		 */
		public function set spacerAlpha( value:Number ):void
		{
			_spacerAlpha = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** Width of the spacer in the line */
		public function set spacerWidth( value:Number ):void
		{
			_spacerWidth = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** Height of the spacer in the line */
		public function set spacerHeight( value:Number ):void
		{
			_spacerHeight = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		/** Padding betweent the dot and spacer */
		public function set padding( value:Number ):void
		{
			_padding = value;
			dispatchEvent( new Event( 'linePropertyChanged' ) );
		}

		[Bindable ('linePropertyChanged')]
		public function get lineSegment():Shape
		{
			var bg:Shape = new Shape();
			bg.graphics.beginFill( _dotColor, _dotAlpha );
			bg.graphics.drawRect( _padding, 0, _dotWidth, _dotHeight );
			bg.graphics.endFill();

			bg.graphics.beginFill( _spacerColor, _spacerAlpha );
			bg.graphics.drawRect( _dotWidth + (_padding * 2 ), 0, _spacerWidth, _spacerHeight );
			bg.graphics.endFill();

			return bg;
		}

		private var _dotColor:uint = 0xFFFFFF;
		private var _dotAlpha:Number = 1;
		private var _dotWidth:Number = 3;
		private var _dotHeight:Number = _dotWidth
		private var _spacerAlpha:Number = 0;
		private var _spacerColor:uint  = 0xFFFFFF;
		private var _spacerWidth:Number = _dotWidth;
		private var _spacerHeight:Number = _spacerWidth;
		private var _padding:Number = 0;	}
}
