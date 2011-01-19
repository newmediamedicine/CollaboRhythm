package collaboRhythm.workstation.controller
{
	import collaboRhythm.workstation.model.User;
	import collaboRhythm.workstation.view.DemographicsFullView;
	
	import mx.core.IVisualElementContainer;
	
	import spark.effects.Move;

	public class DemographicsController
	{
		private var _demographicsFullView:DemographicsFullView;
		private var _remoteUser:User;
		
		public function DemographicsController(parentContainer:IVisualElementContainer)
		{
			_demographicsFullView = new DemographicsFullView();
			_demographicsFullView.visible = false;
			parentContainer.addElement(_demographicsFullView);
		}

		public function get remoteUser():User
		{
			return _remoteUser;
		}
		
		public function set remoteUser(value:User):void
		{
			_remoteUser = value;
			_demographicsFullView.user = value;
			_demographicsFullView.validateNow();
		}
		
		public function hide():void
		{
			//_remoteUsersView.visible = false;
			var move:Move = new Move(_demographicsFullView);
			move.xTo = -_demographicsFullView.width;
			move.xFrom = _demographicsFullView.x;
			move.play();
		}
		
		public function show():void
		{
			var move:Move = new Move(_demographicsFullView);
			move.xFrom = -_demographicsFullView.width;
			move.xTo = 0;
			move.play();
			_demographicsFullView.visible = true;
		}
	}
}