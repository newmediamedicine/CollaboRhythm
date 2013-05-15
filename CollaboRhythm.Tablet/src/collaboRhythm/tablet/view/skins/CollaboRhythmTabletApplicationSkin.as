package collaboRhythm.tablet.view.skins
{

	import collaboRhythm.core.view.AboutApplicationView;
	import collaboRhythm.core.view.BusyView;
	import collaboRhythm.core.view.ConnectivityView;
	import collaboRhythm.core.view.InAppPassCodeView;
	import collaboRhythm.tablet.model.ViewNavigatorExtended;

	import flash.events.Event;

	import spark.primitives.Ellipse;
	import spark.primitives.Graphic;

	import spark.skins.mobile.ViewNavigatorApplicationSkin;

	public class CollaboRhythmTabletApplicationSkin extends ViewNavigatorApplicationSkin
	{
		public var connectivityView:ConnectivityView;
		public var busyView:BusyView;
		public var aboutApplicationView:AboutApplicationView;
		public var patientPointer:Graphic;
		public var clinicianPointer:Graphic;
		public var inAppPassCodeView:InAppPassCodeView;

		public function CollaboRhythmTabletApplicationSkin()
		{
			addEventListener(Event.RESIZE, resizeHandler)
		}

		override protected function createChildren():void
		{
			navigator = new ViewNavigatorExtended();
			navigator.id = "navigator";

			addChild(navigator);

			connectivityView = new ConnectivityView();
			connectivityView.width = 800;
			connectivityView.height = 600;
			connectivityView.visible = false;
			addChild(connectivityView);

			busyView = new BusyView();
			busyView.width = 800;
			busyView.height = 600;

			aboutApplicationView = new AboutApplicationView();
			aboutApplicationView.width = 800;
			aboutApplicationView.height = 600;
			aboutApplicationView.visible = false;
			addChild(aboutApplicationView);

			patientPointer = new Graphic();
			patientPointer.graphics.beginFill(0x2EB5E5, 0.5);
			patientPointer.graphics.drawCircle(0, 0, 30);
			patientPointer.graphics.endFill();
			patientPointer.visible = false;
			patientPointer.mouseEnabled = false;
			addChild(patientPointer);

			clinicianPointer = new Graphic();
			clinicianPointer.graphics.beginFill(0x9C69AD, 0.5);
			clinicianPointer.graphics.drawCircle(0, 0, 30);
			clinicianPointer.graphics.endFill();
			clinicianPointer.visible = false;
			clinicianPointer.mouseEnabled = false;
			addChild(clinicianPointer);

			inAppPassCodeView = new InAppPassCodeView();
			inAppPassCodeView.width = 800;
			inAppPassCodeView.height = 600;
			inAppPassCodeView.visible = false;
			addChild(inAppPassCodeView);
		}

		private function resizeHandler(event:Event):void
		{
			connectivityView.width = width;
			connectivityView.height = height;
			busyView.width = width;
			busyView.height = height;
			aboutApplicationView.width = width;
			aboutApplicationView.height = height;
			inAppPassCodeView.width = width;
			inAppPassCodeView.height = height;
		}
	}
}
