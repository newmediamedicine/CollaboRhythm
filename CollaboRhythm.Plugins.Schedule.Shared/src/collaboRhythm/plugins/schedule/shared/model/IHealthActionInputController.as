package collaboRhythm.plugins.schedule.shared.model
{
	import flash.net.URLVariables;

	public interface IHealthActionInputController
	{
		function showHealthActionInputView():void;
		function updateVariables(urlVariables:URLVariables):void;
		function get healthActionInputViewClass():Class;
	}
}
