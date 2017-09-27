package test;

class Test extends hxd.App {

	static function main(){
		new Test();
	}

	override function init(){
		var f = sys.io.File.getContent("gog_app.txt");
		var a = f.split("\n");
		a = a.map(StringTools.trim);

		gog.Api.registerGlobalEvent(AuthSuccess, function(_){
			trace("Auth succeed, name="+gog.Api.getPersonaName());
			trace( gog.Api.isLoggedOn() );
			trace( gog.Api.signedIn() );

			gog.Api.requestStatsAndAchievements();

			gog.Api.requestEncryptedAppTicket( haxe.io.Bytes.ofString("TestData") );
		});

		gog.Api.registerGlobalEvent(UserStatsAndAchievementsRetrieveSuccess, function(d:{user: gog.Api.GalaxyID}){
			trace('OK: d=${d.user}');
			gog.Api.setAchievement("Test");
			gog.Api.storeStatsAndAchievements();
		});

		gog.Api.registerGlobalEvent(EncryptedAppTicketRetrieveFailure, function(d:{reason:Int}){
			trace('EncryptedAppTicketRetrieveFailure:${d.reason}');
		});

		gog.Api.registerGlobalEvent(EncryptedAppTicketRetrieveSuccess, function(d:{data:hl.Bytes, size:Int}){
			var data = d.data.toBytes(d.size);
			trace("Ticket:"+data.toString());
		});

		gog.Api.registerGlobalEvent(UserStatsAndAchievementsStoreSuccess, function(_){
			trace('Store OK');
		});

		gog.Api.registerGlobalEvent(OverlayVisibilityChanged, function(d){
			trace('OverlayVisibilityChanged d=$d');
		});

		gog.Api.init(a[0],a[1]);

		trace( gog.Api.getCurrentGameLanguage() );
	}

	override function update(dt){
		gog.Api.processData();
	}


}