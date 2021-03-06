package
{
	import flash.display.Sprite;
	
	import open3d.materials.BitmapFileMaterial;
	import open3d.objects.SimpleCube;
	import open3d.view.SimpleView;

	[SWF(width=800,height=600,backgroundColor=0x666666,frameRate=30)]

	/**
	 * ExSimpleCube
	 * @author katopz
	 */
	public class ExSimpleCube extends SimpleView
	{
		private var simpleCube:SimpleCube;

		override protected function create():void
		{
			simpleCube = new SimpleCube(100, new BitmapFileMaterial("assets/earth.jpg"));
			renderer.view.addChild(simpleCube);
		}

		override protected function draw():void
		{
			var view:Sprite = renderer.view;
			view.rotationX = (mouseX - stage.stageWidth / 2) / 5;
			view.rotationZ = (mouseY - stage.stageHeight / 2) / 5;
			view.rotationY++;
		}
	}
}