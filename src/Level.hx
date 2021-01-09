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
	var tilesetSource : h2d.Tile;


	var marks : Map< LevelMark, Map<Int,Bool> > = new Map();
	var extraCollMap : Map<Int,Bool> = new Map();
	var invalidated = true;

	public function new(l:World_Level) {
		super(Game.ME);
		createRootInLayers(Game.ME.scroller, Const.DP_BG);
		level = l;
		tilesetSource = Assets.ldtkTilesets["Tiles"];

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

		// Hero
		var e = level.l_Entities.all_Hero[0];
		game.hero = new en.Hero(e);
	}	


	

	/** TRUE if given coords are in level bounds **/
	public inline function isValid(cx,cy) return cx>=0 && cx<cWid && cy>=0 && cy<cHei;

	/** Gets the integer ID of a given level grid coord **/
	public inline function coordId(cx,cy) return cx + cy*cWid;

	/** Ask for a level render that will only happen at the end of the current frame. **/
	public inline function invalidate() {
		invalidated = true;
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
		: level.l_Collisions.getInt(cx,cy)==0 || 
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
		// Render collisions
		var tg_collisions = new h2d.TileGroup(tilesetSource, root);
		level.l_Collisions.renderInTileGroup(tg_collisions, false);

	}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}