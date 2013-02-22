package collaboRhythm.shared.model.services
{
	import spark.components.View;

	public interface IViewModifier
	{
		function modify(view:View):void;
	}
}
