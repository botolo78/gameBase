package ui;

class Popup extends Entity {
	public static var ALL : Array<Popup> = [];

	var wrapper : h2d.Object;
	var bg : h2d.ScaleGrid;
	var tf : h2d.Text;

	public function new(str:String, ?c = 0xffffff) {
		super(cx, cy);
		ALL.push(this);

		wrapper = new h2d.Object();
		game.scroller.add(wrapper, Const.DP_UI);

		var px = 15; // Padding X
		var py = 10; // Padding Y
		bg = new h2d.ScaleGrid(Assets.tiles.getTile("uiBox"), 5, 5, wrapper);
		tf = new h2d.Text(Assets.fontPixel, wrapper);
		tf.setPosition(px,py);
		tf.text = str;
		tf.textColor = c;
		tf.maxWidth = 160;

		bg.width = px*2 + tf.textWidth;
		bg.height = py*2 + tf.textHeight;
		bg.color.setColor( C.addAlphaF( C.interpolateInt(c, 0xb7ff00, 0.8) ) );
		bg.colorAdd = new h3d.Vector();
	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		wrapper.remove();
	}


	override function postUpdate() {
		super.postUpdate();
		spr.visible = false;
		wrapper.x = (level.level.pxWid-bg.width)/2;
		wrapper.y = (level.level.pxHei/2)-tf.textHeight*2+Const.GRID*2;	
	}

	override function update() {
		super.update();
	}
}