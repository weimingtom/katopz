package
{
	import com.sleepydesign.components.DialogBalloon;
	import com.sleepydesign.display.SDSprite;
	import com.sleepydesign.net.LoaderUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.MouseEvent;

	[SWF(width="1680",height="822",frameRate="30",backgroundColor="#000000")]
	public class main extends SDSprite
	{
		public function main()
		{
			addChild(LoaderUtil.loadAsset("bg.jpg"));
			addChild(LoaderUtil.load("CandlePage.swf") as Loader);
			
			var testButton:DialogBalloon = addChild(new DialogBalloon("click me for search!")) as DialogBalloon;
			testButton.mouseEnabled = true;
			testButton.buttonMode = true;
			testButton.addEventListener(MouseEvent.CLICK, function():void
			{
				Search.show();
			});
			
			testButton.x = 200;
			testButton.y = 200;
		}
	}
}