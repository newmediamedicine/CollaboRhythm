package collaboRhythm.tablet.view.skins
{

	import collaboRhythm.core.view.AboutApplicationView;
	import collaboRhythm.core.view.ConnectivityView;

	import flash.events.Event;

	import spark.primitives.Ellipse;
	import spark.primitives.Graphic;

	import spark.skins.mobile.ViewNavigatorApplicationSkin;

	public class CollaboRhythmTabletApplicationSkin extends ViewNavigatorApplicationSkin
	{
		public var connectivityView:ConnectivityView;
		public var aboutApplicationView:AboutApplicationView;
		public var pointer:Graphic;

		public function CollaboRhythmTabletApplicationSkin()
		{
			addEventListener(Event.RESIZE, resizeHandler)
		}

		override protected function createChildren():void
		{
			super.createChildren();
			
			connectivityView = new ConnectivityView();
			connectivityView.width = 800;
			connectivityView.height = 600;
			connectivityView.visible = false;
			addChild(connectivityView);
			
			aboutApplicationView = new AboutApplicationView();
			aboutApplicationView.width = 800;
			aboutApplicationView.height = 600;
			aboutApplicationView.visible = false;
			addChild(aboutApplicationView);

			pointer = new Graphic();
			pointer.graphics.beginFill(0x000000);
			pointer.graphics.drawCircle(0, 0, 10);
			pointer.graphics.endFill();
			pointer.visible = false;
			addChild(pointer);
		}

		private function resizeHandler(event:Event):void
		{
			connectivityView.width = width;
			connectivityView.height = height;
			aboutApplicationView.width = width;
			aboutApplicationView.height = height;
		}
	}
}
