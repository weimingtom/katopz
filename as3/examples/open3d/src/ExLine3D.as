package
{
	import flash.display.Sprite;
	import flash.geom.Vector3D;
	
	import open3d.objects.Line3D;
	import open3d.view.SimpleView;

	[SWF(width=800, height = 600, backgroundColor = 0x666666, frameRate = 30)]

	/**
	 * ExLine3D
	 * @author katopz
	 */
	public class ExLine3D extends SimpleView
	{
		override protected function create():void
		{
			var size:int = 300;

			// X
			var lineX:Line3D = new Line3D(Vector.<Vector3D>([new Vector3D(size, 0, 0)]), 0xFF0000);
			// y
			var lineY:Line3D = new Line3D(Vector.<Vector3D>([new Vector3D(0, size, 0)]), 0x00FF00);
			// Z
			var lineZ:Line3D = new Line3D(Vector.<Vector3D>([new Vector3D(0, 0, size)]), 0x0000FF);
			
			renderer.view.addChild(lineX);
			renderer.view.addChild(lineY);
			renderer.view.addChild(lineZ);

			//isDebug = false;
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