import dn.Process;
import hxd.Key;

class Game extends Process {
	public static var ME : Game;

	/** Game controller (pad or keyboard) **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	/** Particles **/
	public var fx : Fx;

	/** Basic viewport control **/
	public var camera : Camera;

	/** Container of all visual game objects. Ths wrapper is moved around by Camera. **/
	public var scroller : h2d.Layers;

	/** Level data **/
	public var level : Level;

	/** UI **/
	public var hud : ui.Hud;

	/** Slow mo internal values**/
	var curGameSpeed = 1.0;
	var slowMos : Map<String, { id:String, t:Float, f:Float }> = new Map();


	/** LDtk world data **/
	public var world : World;
	public var hero: en.Hero;
	public var curLevelIdx = 0;


	public function new() {
		super(Main.ME);
		ME = this;
		ca = Main.ME.controller.createAccess("game");
		ca.setLeftDeadZone(0.2);
		ca.setRightDeadZone(0.2);
		createRootInLayers(Main.ME.root, Const.DP_BG);

		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);
		scroller.filter = new h2d.filter.ColorMatrix(); // force rendering for pixel perfect

		world = new World();
		fx = new Fx();
		hud = new ui.Hud();
		startLevel(0);
	}


	function startLevel(idx=-1, ?data:World_Level) {
		curLevelIdx = idx;
		// Cleanup
		if( level!=null )
			level.destroy();
		for(e in Entity.ALL)
			e.destroy();		
		fx.clear();
		gc();

		// Init
		level = new Level( data!=null ? data : world.levels[curLevelIdx] );
		level.attachMainEntities();
		camera = new Camera();
		camera.trackEntity(hero,true);

		Process.resizeAll();
		hxd.Timer.skip();
	}

	public function notify(str:String, col=0x889fcd) {
		var f = new h2d.Flow();
		root.add(f, Const.DP_UI);
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.scale(Const.SCALE*2);
		tf.text = str;
		tf.textColor = col;
		f.x = Std.int( w()*0.5 - f.outerWidth*0.5 );
		f.y = Std.int( h()*0.4 - f.outerHeight*0.5 );

		tw.createMs(f.alpha, 0>1, 400);
		tw.createMs(tf.x, w()*0.5 > 0, TEaseOut, 200).end( ()->{
			tw.createMs(tf.x, 1500 | -w()*0.5, TEaseIn, 200).end( ()->{
				f.remove();
			});
		});
	}

	public function popText(x:Float, y:Float, str:String, col=0xffcc00) {
		var f = new h2d.Flow();
		scroller.add(f, Const.DP_UI);
		var tf = new h2d.Text(Assets.fontPixel, f);
		tf.text = str;
		tf.textColor = col;
		f.x = Std.int( x - f.outerWidth*0.5 );
		f.y = Std.int( y - f.outerHeight*0.5 );

		tw.createMs(f.alpha, 1>0, 1200).end( f.remove );
		tw.createMs(f.y, f.y-20, TEaseOut, 200);
	}


	/** CDB file changed on disk**/
	public function onCdbReload() {}


	/** Called when LDtk world changes on the disk**/
	
	public function onLDtkReload() {
		world.parseJson( hxd.Res.world.world.entry.getText() );
		startLevel(curLevelIdx);
	}	

	/** Window/app resize event **/
	override function onResize() {
		super.onResize();
		scroller.setScale(Const.SCALE);
	}


	/** Garbage collect any Entity marked for destruction **/
	function gc() {
		if( Entity.GC==null || Entity.GC.length==0 )
			return;

		for(e in Entity.GC)
			e.dispose();
		Entity.GC = [];
	}

	/** Called if game is destroyed, but only at the end of the frame **/
	override function onDispose() {
		super.onDispose();

		fx.destroy();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	/**
		Start a cumulative slow-motion effect that will affect `tmod` value in this Process
		and its children.

		@param sec Realtime second duration of this slowmo
		@param speedFactor Cumulative multiplier to the Process `tmod`
	**/
	public function addSlowMo(id:String, sec:Float, speedFactor=0.3) {
		if( slowMos.exists(id) ) {
			var s = slowMos.get(id);
			s.f = speedFactor;
			s.t = M.fmax(s.t, sec);
		}
		else
			slowMos.set(id, { id:id, t:sec, f:speedFactor });
	}


	function updateSlowMos() {
		// Timeout active slow-mos
		for(s in slowMos) {
			s.t -= utmod * 1/Const.FPS;
			if( s.t<=0 )
				slowMos.remove(s.id);
		}

		// Update game speed
		var targetGameSpeed = 1.0;
		for(s in slowMos)
			targetGameSpeed*=s.f;
		curGameSpeed += (targetGameSpeed-curGameSpeed) * (targetGameSpeed>curGameSpeed ? 0.2 : 0.6);

		if( M.fabs(curGameSpeed-targetGameSpeed)<=0.001 )
			curGameSpeed = targetGameSpeed;
	}


	/**
		Pause briefly the game for 1 frame: very useful for impactful moments,
		like when hitting an opponent in Street Fighter ;)
	**/
	public inline function stopFrame() {
		ucd.setS("stopFrame", 0.2);
	}



	/** Loop that happens at the beginning of the frame **/
	override function preUpdate() {
		super.preUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.preUpdate();
	}

	/** Loop that happens at the end of the frame **/
	override function postUpdate() {
		super.postUpdate();

		// Update slow-motions
		updateSlowMos();
		baseTimeMul = ( 0.2 + 0.8*curGameSpeed ) * ( ucd.has("stopFrame") ? 0.3 : 1 );
		Assets.tiles.tmod = tmod;


		for(e in Entity.ALL) if( !e.destroyed ) e.postUpdate();

		gc();
	}

	/** Main loop but limited to 30fps (so it might not be called during some frames) **/
	override function fixedUpdate() {
		super.fixedUpdate();

		for(e in Entity.ALL) if( !e.destroyed ) e.fixedUpdate();
	}

	/** Main loop **/
	override function update() {
		super.update();

		for(e in Entity.ALL) if( !e.destroyed ) e.update();

		if( !ui.Console.ME.isActive() && !ui.Modal.hasAny() ) {
			#if hl
			// Exit
			if( ca.isKeyboardPressed(Key.ESCAPE) ) {
				if( !cd.hasSetS("exitWarn",3) ) {
					var popup = new ui.Popup("Press ESC again to exit");
					Assets.SLIB.click(0.5);
					delayer.addS(()->{
						popup.dispose();
					}, 3);			
				}		
				else
					hxd.System.exit();
			}
			#end

			#if js
			// Sorry, cannot exit
			if( ca.isKeyboardPressed(Key.ESCAPE) ) {
				var popup = new ui.Popup("Close your browser to exit :)");
				Assets.SLIB.click(0.5);
				delayer.addS(()->{
					popup.dispose();
				}, 3);			
			}
			#end	

			// Restart
			if( ca.selectPressed() )
				Main.ME.startGame();
		}
	}
}

