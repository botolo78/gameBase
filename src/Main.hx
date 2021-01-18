import Data;
import hxd.Key;

class Main extends dn.Process {
	public static var ME : Main;

	/** Used to create "Access" instances that allow controller checks (keyboard or gamepad) **/
	public var controller : dn.heaps.Controller;

	/** Controller Access created for Main & Boot **/
	public var ca : dn.heaps.Controller.ControllerAccess;

	public function new(s:h2d.Scene) {
		super();
		ME = this;

        createRoot(s);

		// Engine settings
		engine.backgroundColor = 0xff<<24|0x000000;
		// engine.fullScreen = true; 
        #if( hl && !debug )
        engine.fullScreen = true;
        #end

		// Heaps resources
		#if( hl && debug )
			hxd.Res.initLocal();
        #else
      		hxd.Res.initEmbed();
        #end

        // CastleDB hot reloading
		#if debug
        hxd.res.Resource.LIVE_UPDATE = true;
        hxd.Res.data.watch(function() {
            delayer.cancelById("cdb");
            delayer.addS("cdb", function() {
				// Only reload actual updated file from disk after a short delay, to avoid reading a file being written
            	Data.load( hxd.Res.data.entry.getBytes().toString() );
            	if( Game.ME!=null )
                    Game.ME.onCdbReload();
            }, 0.2);
		});

		// Hot reloading (LDtk)
        hxd.Res.world.world.watch(function() {
            delayer.cancelById("ldtk");

            delayer.addS("ldtk", function() {
            	if( Game.ME!=null )
                    Game.ME.onLDtkReload();
            }, 0.2);
        });		
		#end

		// Assets & data init
		hxd.snd.Manager.get(); // force sound manager init on startup instead of first sound play
		Assets.init(); // init assets
		new ui.Console(Assets.fontTiny, s); // init debug console
		Lang.init("en"); // init Lang
		Data.load( hxd.Res.data.entry.getText() ); // read castleDB json

		// Game controller & default key bindings
		controller = new dn.heaps.Controller(s);
		ca = controller.createAccess("main");
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT, Key.Q, Key.A);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT, Key.D);
		controller.bind(X, Key.SPACE, Key.F, Key.E);
		controller.bind(A, Key.UP, Key.Z, Key.W);
		controller.bind(B, Key.ENTER, Key.NUMPAD_ENTER);
		controller.bind(SELECT, Key.R);
		controller.bind(START, Key.N);		


		#if js
		// Optional helper that shows a "Click to start/continue" message when the game looses focus
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.fontMedium);
		#end

		// Start with 1 frame delay, to avoid 1st frame freezing from the game perspective
		hxd.Timer.wantedFPS = Const.FPS;
		hxd.Timer.skip();

		delayer.addF( startGame, 1 );
	}


	/** Start game process **/
	public function startGame() {
		if( Game.ME!=null ) {
			Game.ME.destroy();
			delayer.addF(function() {
				new Game();
			}, 1);
		}
		else {
			#if !debug
			showIntro();
			#else
			new Game();
			#end
		}
	
	}


	public function showIntro() {
		// Logo
		var logo = Assets.tiles.getBitmap("logo");
		var b = logo.getBounds();
		logo.x = w()/2 - b.width/2;
		logo.y = h()/3 - b.height;

		// Text title
		var tfTitle = new h2d.Text(Assets.fontMedium);		
		tfTitle.text = "Description";
		tfTitle.textColor = 0xffcc00;		
		tfTitle.x = logo.x + 10;
		tfTitle.y = logo.y + b.height ;		

		// Text
		var tf = new h2d.Text(Assets.fontMedium);	
		tf.maxWidth = 330;	
		tf.text = "Base structure for my games, using Heaps framework (https://heaps.io) and Haxe language (https://haxe.org).";
		tf.textColor = 0xFFFFFF;		
		tf.x = logo.x + 10;
		tf.y = tfTitle.y+tfTitle.textHeight+10;		

		// Render
		root.add(logo, Const.DP_UI);
		root.add(tfTitle, Const.DP_UI);
		root.add(tf, Const.DP_UI);

		// Fade in
		Main.ME.tw.createS(logo.alpha,0>1,1.5);
		Main.ME.tw.createS(tfTitle.alpha,0>1,2.5);
		Main.ME.tw.createS(tf.alpha,0>1,2.5);

		// Move logo up
		var y = logo.y - 50;
		Main.ME.tw.createS(logo.y,y,1.5);

		// Fade out
		Main.ME.delayer.addS(()->{
			Main.ME.tw.createS(logo.alpha,1>0,1);
			Main.ME.tw.createS(tfTitle.alpha,1>0,0.5);
			Main.ME.tw.createS(tf.alpha,1>0,0.5);
		}, Const.INTRODELAY);

		// Start game
		Main.ME.delayer.addS(()->{
			new Game();
		}, Const.INTRODELAY+1);
	}	


    override function update() {
		Assets.tiles.tmod = tmod;
        super.update();
    }
}