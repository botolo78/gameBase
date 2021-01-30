package en;


class Text extends Entity {
	public static var ALL : Array<Text> = [];

	var data : Entity_Text;
	var wrapper : h2d.Object;
	var tf : h2d.Text;
	var darkCount = 0;
	public var textVisible = true;

	public function new(e:Entity_Text) {
		super(e.cx, e.cy);
		data = e;
		ALL.push(this);
		gravityMul = 0;
		textVisible = !data.f_startHidden;

		wrapper = new h2d.Object();
		game.scroller.add(wrapper, Const.DP_BG);

		var c = e.f_color_int;
		var px = 0;
		var py = 0;
		tf = new h2d.Text(Assets.fontPixel, wrapper);
		tf.setPosition(px,py);
		tf.text = e.f_text;
		tf.textColor = c;
		tf.maxWidth = 160;

	}

	override function dispose() {
		super.dispose();
		ALL.remove(this);
		wrapper.remove();
	}

	public function reveal() {
		textVisible = true;
		cd.setS("revealAnim",0.5);
		cd.setS("revealed", Const.INFINITE);
	}

	override function postUpdate() {
		super.postUpdate();
		spr.visible = false;
		wrapper.visible = textVisible;

		wrapper.x = Std.int( data.pixelX - tf.textWidth*0.5 );
		wrapper.y = Std.int( data.pixelY - tf.textHeight*0.5 ) + Std.int(8*cd.getRatio("revealAnim"));


	}

	override function update() {
		super.update();
		if  (data.f_vanish && cd.has("revealed") && distCase(hero)> 4) {
			game.delayer.addS(()->{
				destroy();
			}, 1);		
			
		}
	}
}