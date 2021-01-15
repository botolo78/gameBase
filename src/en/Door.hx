package en;

class Door extends Entity {
	public static var ALL : Array<Door> = [];
	var data : Entity_Door;
	var cHei = 2;
	public var isClosed(default,null) : Bool;
	public var needKey : Bool;

	public function new(e:Entity_Door) {
		super(e.cx, e.cy);
		ALL.push(this);
		data = e;
		gravityMul = 0;
		needKey = data.f_needKey;
		setClosed(true);
		Game.ME.scroller.add(spr, Const.DP_BG);
	}

	public function setClosed(closed:Bool) {
		if( level==null || level.destroyed || !isAlive() )
			return;

		isClosed = closed;

		if( isClosed )
			setSquashX(0.7);
		else
			setSquashY(0.7);

		if( spr!=null && !spr.destroyed )
			spr.set(needKey && data.f_showLock ? ( closed ? "doorKeyClosed" : "doorKeyOpen" ) : ( closed ? "doorClosed" : "doorOpen" ));

		for(i in 0...cHei)
			level.setExtraCollision(cx,cy-i, closed);
	}

	override function postUpdate() {
		super.postUpdate();
		if( !isClosed )
			spr.visible = true;
	}

	override function dispose() {
		super.dispose();

		if( isClosed )
			setClosed(false);

		ALL.remove(this);
	}

	override function update() {
		super.update();
	}
}