package collaboRhythm.core.view
{
	import mx.core.ILayoutElement;

	import spark.components.supportClasses.GroupBase;
	import spark.layouts.supportClasses.LayoutBase;

	/**
	 * Justin “Juice” Shacklette <justin@saturnboy.com>
	 * All code on this blog is MIT licensed <http://www.opensource.org/licenses/mit-license.php>.
	 * Preserve my copyright in the code, and use it however you want (commercial or non-commercial) for free.
	 * If you do something really cool with something I wrote, I’d love to hear from you.
	 * http://saturnboy.com/2009/10/flow-layout/
	 *
	 * A custom flow layout based heavily on Evtim's code:
	 * http://evtimmy.com/2009/06/flowlayout-a-spark-custom-layout-example/
	 *
	 * Assumes all elements have the same height, but different widths are
	 * obviously allowed (it wouldn't be a flow layout otherwise).
	 */
	public class FlowLayout extends LayoutBase
	{
		private var _border:Number = 10;
		private var _gap:Number = 10;

		/**
		 *  @private
		 */
		private var invalidateCompose:Boolean = true;

		/**
		 *  @private
		 *  The value of bounds.width, before the compose was done.
		 */
		private var _composeWidth:Number;

		/**
		 *  @private
		 *  The value of bounds.height, before the compose was done.
		 */
		private var _composeHeight:Number;

		/**
		 *  @private
		 *  Cache the width constraint as set by the layout in setLayoutBoundsSize()
		 *  so that text reflow can be calculated during a subsequent measure pass.
		 */
		private var _widthConstraint:Number = NaN;


		public function set border(val:Number):void
		{
			_border = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				layoutTarget.invalidateDisplayList();
			}
		}

		public function set gap(val:Number):void
		{
			_gap = val;
			var layoutTarget:GroupBase = target;
			if (layoutTarget)
			{
				layoutTarget.invalidateDisplayList();
			}
		}

		override public function updateDisplayList(containerWidth:Number, containerHeight:Number):void
		{
			var x:Number = _border;
			var y:Number = _border;
			var maxWidth:Number = 0;
			var maxHeight:Number = 0;

			//loop through all the elements
			var layoutTarget:GroupBase = target;
			var count:int = layoutTarget.numElements;

			for (var i:int = 0; i < count; i++)
			{
				var element:ILayoutElement = useVirtualLayout ?
						layoutTarget.getVirtualElementAt(i) :
						layoutTarget.getElementAt(i);

				//resize the element to its preferred size by passing in NaN
				element.setLayoutBoundsSize(NaN, NaN);

				//get element's size, but AFTER it has been resized to its preferred size.
				var elementWidth:Number = element.getLayoutBoundsWidth();
				var elementHeight:Number = element.getLayoutBoundsHeight();

				//does the element fit on this line, or should we move to the next line?
				if (x + elementWidth > layoutTarget.width)
				{
					//start from the left side
					x = _border;

					//move to the next line, and add the gap, but not if it's the first element
					//(this assumes all elements have the same height, but different widths are ok)
					if (i > 0)
					{
						y += elementHeight + _gap;
					}
				}
				//position the element
				element.setLayoutBoundsPosition(x, y);

				//update max dimensions (needed for scrolling)
				maxWidth = Math.max(maxWidth, x + elementWidth);
				maxHeight = Math.max(maxHeight, y + elementHeight);

				//update the current pos, and add the gap
				x += elementWidth + _gap;
			}

			//set final content size (needed for scrolling)
			var contentWidth:Number = Math.ceil(maxWidth + _border);
			var contentHeight:Number = Math.ceil(maxHeight + _border);
			layoutTarget.setContentSize(contentWidth, contentHeight);

			layoutTarget.minHeight = contentHeight;
		}

		override public function measure():void
		{
			var layoutTarget:GroupBase = target;
			if (!layoutTarget)
				return;

			measureReal(layoutTarget);

			// Use Math.ceil() to make sure that if the content partially occupies
			// the last pixel, we'll count it as if the whole pixel is occupied.
			layoutTarget.measuredWidth = Math.ceil(layoutTarget.measuredWidth);
			layoutTarget.measuredHeight = Math.ceil(layoutTarget.measuredHeight);
			layoutTarget.measuredMinWidth = Math.ceil(layoutTarget.measuredMinWidth);
			layoutTarget.measuredMinHeight = Math.ceil(layoutTarget.measuredMinHeight);
		}

		/**
		 *  @private
		 *
		 *  Compute exact values for measuredWidth,Height and measuredMinWidth,Height.
		 *
		 *  Measure each of the layout elements.
		 */
		private function measureReal(layoutTarget:GroupBase):void
		{
			var preferredX:Number = _border;
			var preferredY:Number = _border;
			var minX:Number = _border;
			var minY:Number = _border;
			var preferredWidth:Number = 0;
			var preferredHeight:Number = 0;
			var minWidth:Number = 0;
			var minHeight:Number = 0;

			//loop through all the elements
			var count:int = layoutTarget.numElements;

			for (var i:int = 0; i < count; i++)
			{
				var element:ILayoutElement = useVirtualLayout ?
						layoutTarget.getVirtualElementAt(i) :
						layoutTarget.getElementAt(i);

				if (!element || !element.includeInLayout)
				{
					continue;
				}

				var widthSize:SizesAndLimit = new SizesAndLimit();
				getElementWidth(element, false, widthSize);
				var heightSize:SizesAndLimit = new SizesAndLimit();
				getElementHeight(element, heightSize);

				//does the element fit on this line, or should we move to the next line?
				if (!isNaN(layoutTarget.explicitWidth) &&
						preferredX + widthSize.preferredSize > layoutTarget.explicitWidth)
				{
					//start from the left side
					preferredX = _border;

					//move to the next line, and add the gap, but not if it's the first element
					//(this assumes all elements have the same height, but different widths are ok)
					if (i > 0)
					{
						preferredY += heightSize.preferredSize + _gap;
					}
				}

				// For the minimum size, we are currently assuming that the elements will all be stacked in a vertical layout
				minX = _border;

				//move to the next line, and add the gap, but not if it's the first element
				//(this assumes all elements have the same height, but different widths are ok)
				if (i > 0)
				{
					minY += heightSize.minSize + _gap;
				}

				//update max dimensions (needed for scrolling)
				preferredWidth = Math.max(preferredWidth, preferredX + widthSize.preferredSize);
				preferredHeight = Math.max(preferredHeight, preferredY + heightSize.preferredSize);
				minWidth = Math.max(minWidth, minX + widthSize.minSize);
				minHeight = Math.max(minHeight, minY + heightSize.minSize);

				//update the current pos, and add the gap
				preferredX += widthSize.preferredSize + _gap;
				minX += widthSize.minSize + _gap;
			}

			layoutTarget.measuredWidth = preferredWidth + _border;
			layoutTarget.measuredHeight = preferredHeight + _border;
			layoutTarget.measuredMinWidth = minWidth + _border;
			layoutTarget.measuredMinHeight = minHeight + _border;
		}

		/**
		 *  @private
		 *  Fills in the result with preferred and min sizes of the element.
		 */
		private function getElementWidth(element:ILayoutElement, justify:Boolean, result:SizesAndLimit):void
		{
			// Calculate preferred width first, as it's being used to calculate min width
			var elementPreferredWidth:Number = Math.ceil(element.getPreferredBoundsWidth());

			// Calculate min width
			var flexibleWidth:Boolean = !isNaN(element.percentWidth) || justify;
			var elementMinWidth:Number = flexibleWidth ? Math.ceil(element.getMinBoundsWidth()) :
					elementPreferredWidth;
			result.preferredSize = elementPreferredWidth;
			result.minSize = elementMinWidth;
		}

		/**
		 *  @private
		 *  Fills in the result with preferred and min sizes of the element.
		 */
		private function getElementHeight(element:ILayoutElement, result:SizesAndLimit):void
		{
			// Calculate preferred height first, as it's being used to calculate min height below
			var elementPreferredHeight:Number = Math.ceil(element.getPreferredBoundsHeight());

			// Calculate min height
			var flexibleHeight:Boolean = !isNaN(element.percentHeight);
			var elementMinHeight:Number = flexibleHeight ? Math.ceil(element.getMinBoundsHeight()) :
					elementPreferredHeight;
			result.preferredSize = elementPreferredHeight;
			result.minSize = elementMinHeight;
		}

	}
}

class SizesAndLimit
{
	public var preferredSize:Number;
	public var minSize:Number;
}
