package collaboRhythm.workstation.model.services
{
	import castle.flexbridge.kernel.DefaultKernel;
	import castle.flexbridge.kernel.IKernel;

	public class WorkstationKernel
	{
		private static var _instance:IKernel;
		
		public static function get instance():IKernel
		{
			if (_instance == null)
				_instance = new DefaultKernel();
			
			return _instance;
		}
	}
}