package collaboRhythm.workstation.model.services
{
	public class DefaultCurrentDateSource implements ICurrentDateSource
	{
		public function DefaultCurrentDateSource()
		{
		}
		
		public function now():Date
		{
			return new Date();
		}

		public function get currentDate():Date
		{
			return new Date();
		}
	}
}