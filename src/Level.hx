import en.Collectable;

class Level extends dn.Process {
	var game(get,never) : Game; inline function get_game() return Game.ME;
	var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	/** Level grid-based width**/
	public var cWid(get,never) : Int; inline function get_cWid() return level.l_Collisions.cWid;

	/** Level grid-based height **/
	public var cHei(get,never) : Int; inline function get_cHei() return level.l_Collisions.cHei;

	/** Level pixel width**/
	public var pxWid(get,never) : Int; inline function get_pxWid() return cWid*Const.GRID;

	/** Level pixel height**/
	public var pxHei(get,never) : Int; inline function get_pxHei() return cHei*Const.GRID;

	public var level : World_Level;

	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var extraCollMap : Map<Int,Bool> = new Map();
	var invalidated = true;

	/** LDtk tilegroup layers**/
	// var tg_collisions : h2d.TileGroup;
	// var tg_decorations : h2d.TileGroup;
	// var tg_stamps : h2d.TileGroup;


	public function new(l:World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		level = l;
		var sourceTile = l.l_Collisions.tileset.getAtlasTile();

		// tg_collisions = new h2d.TileGroup(sourceTile, root);
		// tg_decorations = new h2d.TileGroup(sourceTile, root);
		// tg_stamps = new h2d.TileGroup(sourceTile, root);

		// Marking
		for(cy in 0...cHei)
			for(cx in 0...cWid) {
				if( !hasCollision(cx,cy) && !hasCollision(cx,cy-1) ) {
					if( hasCollision(cx+1,cy) && !hasCollision(cx+1,cy-1) )
						setMarks(cx,cy, [Grab,GrabRight]);
	
					if( hasCollision(cx-1,cy) && !hasCollision(cx-1,cy-1) )
						setMarks(cx,cy, [Grab,GrabLeft]);
				}
	
				if( !hasCollision(cx,cy) && hasCollision(cx,cy+1) ) {
					if( hasCollision(cx+1,cy) || !hasCollision(cx+1,cy+1) )
						setMarks(cx,cy, [PlatformEnd,PlatformEndRight]);
					if( hasCollision(cx-1,cy) || !hasCollision(cx-1,cy+1) )
						setMarks(cx,cy, [PlatformEnd,PlatformEndLeft]);
				}
			}		

	}

	// Spawn entities
	public function attachMainEntities() {

		// Collectables
			for( e in level.l_Entities.all_Collectable ) {
				new en.Collectable(e);
				}	

		// Hero
		var e = level.l_Entities.all_Hero[0];
		game.hero = new en.Hero(e);
		
		// Doors
		for( e in level.l_Entities.all_Door ) new en.Door(e);

		// Text
		for( e in level.l_Entities.all_Text ) new en.Text(e);
			
		// Triggers
		for( e in level.l_Entities.all_Trigger ) new en.Trigger(e);

		// Bumpers
		for( e in level.l_Entities.all_Bumper ) new en.Bumper(e);

		// Test Entities 16x16 (DEBUG)
		for( e in level.l_Entities.all_TestEntity16x16 ) new en.TestEntity16x16(e);

		// Test Entities 32x16 (DEBUG)
		for( e in level.l_Entities.all_TestEntity32x16 ) new en.TestEntity32x16(e);				
	}	



	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx,cy) return cx + cy*cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
	}

	override function onDispose() {
		super.onDispose();

		level = null;
		marks = null;

		// tg_collisions.remove();
		// tg_decorations.remove();
		// tg_stamps.remove();
	}



	/** Return TRUE if mark is present at coordinates **/
	public inline function hasMark(mark:LevelMark, cx:Int, cy:Int) {
		return !isValid(cx,cy) || !marks.exists(mark) ? false : marks.get(mark).exists( coordId(cx,cy) );
	}	

	/** Enable mark at coordinates **/
	public function setMark(cx:Int, cy:Int, mark:LevelMark) {
		if( isValid(cx,cy) && !hasMark(mark,cx,cy) ) {
			if( !marks.exists(mark) )
				marks.set(mark, new Map());
			marks.get(mark).set( coordId(cx,cy), true );
		}
	}

	public inline function setMarks(cx,cy,marks:Array<LevelMark>) {
		for(m in marks)
			setMark(cx,cy,m);
	}

	/** Remove mark at coordinates **/
	public function removeMark(mark:LevelMark, cx:Int, cy:Int) {
		if( isValid(cx,cy) && hasMark(mark,cx,cy) )
			marks.get(mark).remove( coordId(cx,cy) );
	}

	/** Return TRUE if "Collisions" layer contains a collision value **/
	public inline function hasCollision(cx,cy) : Bool {
		// return !isValid(cx,cy) ? true : level.l_Collisions.getInt(cx,cy)==0;
		return !isValid(cx,cy)
		? true
		: level.l_Collisions.getInt(cx,cy)==0 || // Main level collisions (walls..)
		extraCollMap.exists(coordId(cx,cy)); // Collision with other entities
	}

	public function setExtraCollision(cx,cy,v:Bool) {
		if( isValid(cx,cy) )
			if( v )
				extraCollMap.set( coordId(cx,cy), true );
			else
				extraCollMap.remove( coordId(cx,cy) );
	}	


	function render() {
		root.removeChildren();	
		// tg_collisions.clear();
		// tg_decorations.clear();
		// tg_stamps.clear();	


		// Create a wrapper to render all layers in it
		var levelWrapper = new h2d.Object( Game.ME.scroller );

		// Position accordingly to world pixel coords
		levelWrapper.x = level.worldX;
		levelWrapper.y = level.worldY;

		// Level background image
		if( level.hasBgImage() )
			levelWrapper.addChild( level.getBgBitmap() );

		// Level Collisions
		levelWrapper.addChild( level.l_Collisions.render() );
		// Level Decorations
		levelWrapper.addChild( level.l_Decorations.render() );
		// Level Stamps
		levelWrapper.addChild( level.l_Stamps.render() );


		// // Render collisions
		// for( autoTile in level.l_Collisions.autoTiles ) {
		// 	var tile = level.l_Collisions.tileset.getAutoLayerTile(autoTile);
		// 	tg_collisions.add(autoTile.renderX, autoTile.renderY, tile);
		// 	}

		// // Render decorations
		// for( autoTile in level.l_Decorations.autoTiles ) {
		// 	var tile = level.l_Decorations.tileset.getAutoLayerTile(autoTile);
		// 	tg_decorations.add(autoTile.renderX, autoTile.renderY, tile);
		// }

		// // Stamps
		// level.l_Stamps.render(tg_stamps);
	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}