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
		trace( gog.Api.getOverlayState() );
		trace( gog.Api.isOverlayVisible() );

		var b = new h2d.Interactive(100,20,s2d);
		b.backgroundColor = 0xFF0000;
		b.onClick = function(_){
			gog.Api.showOverlayWithWebPage("https://github.com/motion-twin/hlgog/");
		}

		var t = new h2d.Text(hxd.res.DefaultFont.get(), b);
		t.text = "OpenURL";
	}

	override function update(dt){
		gog.Api.processData();
	}


}