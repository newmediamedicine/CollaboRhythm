package collaboRhythm.shared.model.services
{
	import spark.components.Image;

	public interface IImageCacheService
	{
		function getImage(image:Image, imageUrl:String):Object
	}
}
