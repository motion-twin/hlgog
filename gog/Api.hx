package gog;

@:enum abstract EventType(Int) {
	var AuthSuccess = 0;
	var AuthFailure = 1;
	var AuthLost = 2;
	var UserStatsAndAchievementsRetrieveSuccess = 3;
	var UserStatsAndAchievementsRetrieveFailure = 4;
	var UserStatsAndAchievementsStoreSuccess  = 5;
	var UserStatsAndAchievementsStoreFailure  = 6;
	var EncryptedAppTicketRetrieveSuccess = 7;
	var EncryptedAppTicketRetrieveFailure = 8;
	var OverlayVisibilityChanged = 9;
}

@:enum abstract OverlayState(Int) {
	var Undefined          = 0;
	var NotSupported       = 1;
	var Disabled           = 2;
	var FailedToInitialize = 3;
	var Initialized        = 4;
}

abstract GalaxyID(hl.Bytes) {
	function new(uid) {
		this = uid;
	}
	public function toString() {
		return this == null ? "NULL" : getType()+":"+haxe.Int64.toStr(getRealId());
	}
	public function getBytes() {
		return this.toBytes(8);
	}
	public function getType() : Int {
		return this.getI32(4)>>24;
	}
	public function getRealId() : haxe.Int64 {
		return haxe.Int64.make(this.getI32(4)&0xffffff, this.getI32(0));
	}
	@:op(a == b) static function __compare( a : GalaxyID, b : GalaxyID ) {
		return (cast a : hl.Bytes).compare(0, (cast b : hl.Bytes), 0, 8) == 0;
	}
	public static function fromBytes( bytes : haxe.io.Bytes ) : GalaxyID {
		if( bytes.length != 8 ) throw "Invalid UID";
		return new GalaxyID(@:privateAccess bytes.b);
	}
}

@:hlNative("gog")
@:access(String)
class Api {

	static var listeners : Map<EventType, Array<Dynamic->Void>> = new Map();

	public static function init( id : String, secret : String ){
		gogInit(id.toUtf8(), secret.toUtf8(), onEvent);
		haxe.MainLoop.add(processData);
	}

	public static function registerGlobalEvent( type : EventType, cb : Dynamic -> Void ){
		var a = listeners.get(type);
		if( a == null )
			listeners.set(type, a=[]);
		a.push( cb );
	}

	static function onEvent( type : EventType, data : Dynamic ){
		if( listeners.exists(type) )
			for( f in listeners.get(type) )
				f(data);
	}

	@:hlNative("gog", "init")
	static function gogInit( id : hl.Bytes, secret : hl.Bytes, onEvent : EventType -> Dynamic -> Void ){
	}

	static function processData() : Void {
	}

	@:hlNative("gog", "is_logged_on")
	public static function isLoggedOn() : Bool { return false; }

	public static function signedIn() : Bool {
		return false;
	}

	public static function getGalaxyId() : GalaxyID {
		return null;
	}

	public static function getPersonaName() : String {
		return String.fromUTF8(gogGetPersonaName());
	}

	@:hlNative("gog", "get_persona_name")
	static function gogGetPersonaName() : hl.Bytes { return null; }

	public static function getCurrentGameLanguage() : String {
		return String.fromUTF8(gogGetCurrentGameLanguage());
	}

	@:hlNative("gog", "get_current_game_language")
	static function gogGetCurrentGameLanguage() : hl.Bytes { return null; }

	public static function requestEncryptedAppTicket( data : haxe.io.Bytes ){
		gogRequestEncryptedAppTicket(@:privateAccess data.b, data.length);
	}

	@:hlNative("gog", "request_encrypted_app_ticket")
	static function gogRequestEncryptedAppTicket( data : hl.Bytes, size : Int ) : Void { }
	
	public static function getOverlayState() : OverlayState {
		return (cast 0:OverlayState);
	}

	public static function isOverlayVisible() : Bool {
		return false;
	}

	public static function showOverlayWithWebPage( url : String ){
		gogShowOverlayWithWebPage(url.toUtf8());
	}

	@:hlNative("gog", "show_overlay_with_web_page")
	static function gogShowOverlayWithWebPage( url : hl.Bytes ) : Void {
	}

	public static function isDlcInstalled( productId : haxe.Int64 ){
		var b = new hl.Bytes(8);
		b.setI32(0, productId.low);
		b.setI32(4, productId.high);
		return gogIsDlcInstalled(b);
	}

	@:hlNative("gog", "is_dlc_installed")
	static function gogIsDlcInstalled( productId : hl.Bytes ) : Bool {
		return false;
	}

	// Achievements

	public static function storeStatsAndAchievements() : Void {
	}

	public static function requestStatsAndAchievements() : Void {
	}

	public static function setAchievement( name :String ){
		gogSetAchievement(name.toUtf8());
	}

	public static function hasAchievement( name :String ) : Bool {
		return gogHasAchievement(name.toUtf8());
	}

	public static function clearAchievement( name :String ){
		gogClearAchievement(name.toUtf8());
	}

	public static function setStatInt( name : String, value : Int ){
		gogSetStatInt(name.toUtf8(), value);
	}

	public static function setStatFloat( name :String, value : Float ){
		gogSetStatFloat(name.toUtf8(), value);
	}

	@:hlNative("gog", "set_achievement")
	static function gogSetAchievement( name : hl.Bytes ) : Void { }

	@:hlNative("gog", "has_achievement")
	static function gogHasAchievement( name : hl.Bytes ) : Bool { return false; }

	@:hlNative("gog", "clear_achievement")
	static function gogClearAchievement( name : hl.Bytes ) : Void { }

	@:hlNative("gog", "set_stat_int")
	static function gogSetStatInt( name : hl.Bytes, v : Int ) : Void { }

	@:hlNative("gog", "set_stat_float")
	static function gogSetStatFloat( name : hl.Bytes, v : hl.F32 ) : Void { }

	
	

}