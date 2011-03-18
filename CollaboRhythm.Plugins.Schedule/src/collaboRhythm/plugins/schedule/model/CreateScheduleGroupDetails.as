package collaboRhythm.plugins.schedule.model
{
	import collaboRhythm.shared.model.User;

	public class CreateScheduleGroupDetails
	{
		private var _user:User;
		private var _scheduleItemIDs:Vector.<String>
		
		public function CreateScheduleGroupDetails(user:User, scheduItemIDs:Vector.<String>)
		{
			_user = user;
			_scheduleItemIDs = scheduItemIDs;
		}

		public function get user():User
		{
			return _user;
		}
		
		public function get scheduleItemIDs():Vector.<String>
		{
			return _scheduleItemIDs;
		}		
	}
}