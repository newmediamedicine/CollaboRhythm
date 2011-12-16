package collaboRhythm.tablet.view
{

	import collaboRhythm.shared.controller.apps.WorkstationAppControllerBase;

	import flash.events.Event;

	import spark.components.View;

	public class TabletFullViewContainer extends TabletViewBase
	{
		public function TabletFullViewContainer()
		{
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}

		override protected function createChildren():void
		{
			super.createChildren();

			if (app)
			{
				app.fullContainer = this;
				app.showFullView(null);
			}
		}

		override public function initialize():void
		{
			super.initialize();

			title = app.name;
		}

		public function get app():WorkstationAppControllerBase
		{
			return data as WorkstationAppControllerBase;
		}

		protected function removedFromStageHandler(event:Event):void
		{
			if (app)
			{
				app.closeFullView();
				while (this.numElements > 0)
				{
					this.removeElementAt(0);
				}
			}
		}
	}
}
