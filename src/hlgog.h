#define HL_NAME(n) gog_##n
#include <hl.h>
#include <galaxy/GalaxyApi.h>

#define  GALAXY_ERROR() { const galaxy::api::IError *err = galaxy::api::GetError(); if( err != NULL ) hl_error("Galaxy error: %s", hl_to_utf16(err->GetName())); }

typedef vbyte *		vuid;
#define _UID		_BYTES
#define hlt_uid		hlt_bytes

vuid hl_of_uint64(uint64 uid) {
	union {
		vbyte b[8];
		uint64 v;
	} data;
	data.v = uid;
	return (vuid)hl_copy_bytes(data.b, 8);
}

class HLValue {
public:
	vdynamic *value;
	HLValue() {
		value = (vdynamic*)hl_alloc_dynobj();
	}
	void Set(const char *name, galaxy::api::GalaxyID uid) {
		hl_dyn_setp(value, hl_hash_utf8(name), &hlt_uid, hl_of_uint64(uid.ToUint64()));
	}
	void Set(const char *name, bool b) {
		hl_dyn_seti(value, hl_hash_utf8(name), &hlt_bool, b);
	}
	void Set(const char *name, int v) {
		hl_dyn_seti(value, hl_hash_utf8(name), &hlt_i32, v);
	}
	void Set(const char *name, double v){ 
		hl_dyn_setd(value, hl_hash_utf8(name), v);
	}
	void Set(const char *name, float v) {
		hl_dyn_setf(value, hl_hash_utf8(name), v);
	}
	void Set(const char *name, const char *b) {
		hl_dyn_setp(value, hl_hash_utf8(name), &hlt_bytes, hl_copy_bytes((vbyte*)b, strlen(b) + 1));
	}
	void Set(const char *name, vdynamic *d) {
		hl_dyn_setp(value, hl_hash_utf8(name), &hlt_dyn, d);
	}
};

typedef enum {
	AuthSuccess,
	AuthFailure,
	AuthLost,
	UserStatsAndAchievementsRetrieveSuccess,
	UserStatsAndAchievementsRetrieveFailure,
	UserStatsAndAchievementsStoreSuccess,
	UserStatsAndAchievementsStoreFailure,
	EncryptedAppTicketRetrieveSuccess,
	EncryptedAppTicketRetrieveFailure,
	OverlayVisibilityChanged,
} event_type;

void hlgog_sendEvent(event_type id, vdynamic *v);