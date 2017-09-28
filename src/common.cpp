#include "hlgog.h"

static vclosure *g_eventHandler = 0;
static void sendEvent(event_type id, vdynamic *v) {
	vdynamic i;
	vdynamic *args[2];
	i.t = &hlt_i32;
	i.v.i = id;
	args[0] = &i;
	args[1] = v;
	hl_dyn_call(g_eventHandler, args, 2);
}

class AuthListener : public galaxy::api::GlobalAuthListener {
public:
	AuthListener() {
	}
	virtual void OnAuthSuccess() override {
		sendEvent(AuthSuccess, NULL);
	}
	virtual void OnAuthFailure(FailureReason reason) override {
		HLValue v;
		v.Set("reason", (int)reason);
		sendEvent(AuthFailure, v.value);
	}
	virtual void OnAuthLost() override {
		sendEvent(AuthLost, NULL);
	}
};

class UserStatsAndAchievementsRetrieveListener : public galaxy::api::GlobalUserStatsAndAchievementsRetrieveListener {
public:
	UserStatsAndAchievementsRetrieveListener() {
	}
	virtual void OnUserStatsAndAchievementsRetrieveSuccess( galaxy::api::GalaxyID user ) override {
		HLValue v;
		v.Set("user", user);
		sendEvent(UserStatsAndAchievementsRetrieveSuccess, v.value);
	}
	virtual void OnUserStatsAndAchievementsRetrieveFailure( galaxy::api::GalaxyID user, FailureReason reason ) override {
		HLValue v;
		v.Set("user", user);
		v.Set("reason", (int)reason);
		sendEvent(UserStatsAndAchievementsRetrieveFailure, v.value);
	}
};

class StatsAndAchievementsStoreListener : public galaxy::api::GlobalStatsAndAchievementsStoreListener {
public:
	StatsAndAchievementsStoreListener() {
	}

	virtual void OnUserStatsAndAchievementsStoreSuccess() override {
		sendEvent(UserStatsAndAchievementsStoreSuccess, NULL);
	}

	virtual void OnUserStatsAndAchievementsStoreFailure( FailureReason reason ) override {
		HLValue v;
		v.Set("reason", (int)reason);
		sendEvent(UserStatsAndAchievementsStoreFailure, v.value);
	}
};

class EncryptedAppTicketListener : public galaxy::api::GlobalEncryptedAppTicketListener {
public:
	EncryptedAppTicketListener() {
	}

	virtual void OnEncryptedAppTicketRetrieveSuccess() override {
		char data[2048];
		int size = 0;
		HLValue v;
		galaxy::api::User()->GetEncryptedAppTicket(data, 2048, (uint32_t&)size);
		GALAXY_ERROR();
		v.Set("data", data);
		v.Set("size", size);
		sendEvent(EncryptedAppTicketRetrieveSuccess, v.value);
	}

	virtual void OnEncryptedAppTicketRetrieveFailure(FailureReason reason) override {
		HLValue v;
		v.Set("reason", (int)reason);
		sendEvent(EncryptedAppTicketRetrieveFailure, v.value);
	}
};

class OverlayVisibilityChangeListener : public galaxy::api::GlobalOverlayVisibilityChangeListener {
public:
	OverlayVisibilityChangeListener() {
	}

	virtual void OnOverlayVisibilityChanged( bool visible ) override {
		HLValue v;
		v.Set("visible", visible);
		sendEvent(OverlayVisibilityChanged, v.value);
	}
};



HL_PRIM void HL_NAME(init)(char *id, char *secret, vclosure *eventHandler) {
	galaxy::api::Init(id, secret, false);
	GALAXY_ERROR();
	g_eventHandler = eventHandler;
	hl_add_root(&g_eventHandler);
	new AuthListener;
	new UserStatsAndAchievementsRetrieveListener;
	new StatsAndAchievementsStoreListener;
	new EncryptedAppTicketListener;
	new OverlayVisibilityChangeListener;
	galaxy::api::User()->SignIn();
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(process_data)() {
	galaxy::api::ProcessData();
	GALAXY_ERROR();
}

HL_PRIM bool HL_NAME(signed_in)() {
	return galaxy::api::User()->SignedIn();
}

HL_PRIM bool HL_NAME(is_logged_on)() {
	return galaxy::api::User()->IsLoggedOn();
}

HL_PRIM vuid HL_NAME(get_galaxy_id)() {
	return hl_of_uint64(galaxy::api::User()->GetGalaxyID().ToUint64());
}

HL_PRIM vbyte *HL_NAME(get_persona_name)() {
	const char *r = galaxy::api::Friends()->GetPersonaName();
	GALAXY_ERROR();
	return (vbyte*)r;
}

HL_PRIM vbyte *HL_NAME(get_current_game_language)() {
	return (vbyte*)galaxy::api::Apps()->GetCurrentGameLanguage();
}

HL_PRIM void HL_NAME(request_encrypted_app_ticket)( vbyte *data, int size ) {
	galaxy::api::User()->RequestEncryptedAppTicket( data, size );
	GALAXY_ERROR();
}

HL_PRIM int HL_NAME(get_overlay_state)() {
	return (int)galaxy::api::Utils()->GetOverlayState();
}

HL_PRIM bool HL_NAME(is_overlay_visible)() {
	return (int)galaxy::api::Utils()->IsOverlayVisible();
}

HL_PRIM void HL_NAME(show_overlay_with_web_page)(char *url) {
	galaxy::api::Utils()->ShowOverlayWithWebPage(url);
	GALAXY_ERROR();
}

DEFINE_PRIM(_VOID, init, _BYTES _BYTES _FUN(_VOID, _I32 _DYN));
DEFINE_PRIM(_VOID, process_data, _NO_ARG);
DEFINE_PRIM(_BOOL, signed_in, _NO_ARG);
DEFINE_PRIM(_BOOL, is_logged_on, _NO_ARG);
DEFINE_PRIM(_UID, get_galaxy_id, _NO_ARG);
DEFINE_PRIM(_BYTES, get_persona_name, _NO_ARG);
DEFINE_PRIM(_BYTES, get_current_game_language, _NO_ARG);
DEFINE_PRIM(_VOID, request_encrypted_app_ticket, _BYTES _I32);
DEFINE_PRIM(_BOOL, is_overlay_visible, _NO_ARG);
DEFINE_PRIM(_I32, get_overlay_state, _NO_ARG);
DEFINE_PRIM(_VOID, show_overlay_with_web_page, _BYTES);

// Achievements

HL_PRIM void HL_NAME(set_achievement)( char *name ) {
	galaxy::api::Stats()->SetAchievement(name);
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(clear_achievement)(char *name) {
	galaxy::api::Stats()->ClearAchievement(name);
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(set_stat_int)(char *name, int v) {
	galaxy::api::Stats()->SetStatInt(name, v);
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(set_stat_float)(char *name, float v) {
	galaxy::api::Stats()->SetStatFloat(name, v);
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(request_stats_and_achievements)() {
	galaxy::api::Stats()->RequestUserStatsAndAchievements();
	GALAXY_ERROR();
}

HL_PRIM void HL_NAME(store_stats_and_achievements)() {
	galaxy::api::Stats()->StoreStatsAndAchievements();
	GALAXY_ERROR();
}

DEFINE_PRIM(_VOID, set_achievement, _BYTES);
DEFINE_PRIM(_VOID, clear_achievement, _BYTES);
DEFINE_PRIM(_VOID, set_stat_int, _BYTES _I32);
DEFINE_PRIM(_VOID, set_stat_float, _BYTES _F32);
DEFINE_PRIM(_VOID, store_stats_and_achievements, _NO_ARG);
DEFINE_PRIM(_VOID, request_stats_and_achievements, _NO_ARG);
