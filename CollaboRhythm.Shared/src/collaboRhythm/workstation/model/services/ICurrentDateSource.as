package collaboRhythm.workstation.model.services
{
	[Bindable]
	public interface ICurrentDateSource
	{
		function now():Date;
		function get currentDate():Date;
	}
}