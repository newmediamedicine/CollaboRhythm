package collaboRhythm.shared.model.services
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;

	import j2as3.collection.HashMap;

	import spark.components.Image;

	public class DefaultImageCacheService implements IImageCacheService
	{
		private var _imageCache:HashMap = new HashMap();

		public function DefaultImageCacheService()
		{
		}

		public function getImage(image:Image, imageUrl:String):Object
		{
			image.addEventListener(Event.COMPLETE, image_completeHandler);

			if (_imageCache.getItem(imageUrl))
			{
				return new Bitmap(_imageCache.getItem(imageUrl));
			}
			else
			{
				return imageUrl;
			}
		}

		private function image_completeHandler(event:Event):void
		{
			var image:Image = event.target as Image;

			if (!_imageCache.getItem(image.source as String))
			{
				var bitmapData:BitmapData = image.bitmapData;
				_imageCache.put(image.source as String, bitmapData);
			}
		}
	}
}
