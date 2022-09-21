
/* 
	This is a glue c file for importing delta client c functions into Lua workflow.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <lua.h>
#include <lauxlib.h>
#include <curl/curl.h>

/* CURL *curl_easy_init(void); */
static int l_curl_easy_init(lua_State *L) {
	
	CURL *curl = curl_easy_init();
	
	lua_pushlightuserdata(L, (void *) curl);

	return 1;
}

/* void curl_easy_cleanup(CURL *curl); */
static int l_curl_easy_cleanup(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -1);
		
	curl_easy_cleanup(curl);

	return 0;
}

/* CURLcode curl_easy_perform(CURL *curl); */
static int l_curl_easy_perform(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -1);
		
	CURLcode code = curl_easy_perform(curl);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_url(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *url = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_URL, url);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_header(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	int onoff = lua_toboolean(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_HEADER, onoff);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_netrc(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	lua_Integer level = lua_tointeger(L, -1);

	CURLcode code =	curl_easy_setopt(curl, CURLOPT_NETRC, level);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_post(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	int post = lua_toboolean(L, -1);

	CURLcode code =	curl_easy_setopt(curl, CURLOPT_POST, post);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_verbose(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	int onoff = lua_toboolean(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_VERBOSE, onoff);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_capath(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *path = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_CAPATH, path);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_cainfo(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *path = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_CAINFO, path);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_username(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *username = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_USERNAME, username);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_password(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *passwd = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_PASSWORD, passwd);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_postfields(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *fields = lua_tostring(L, -1);
		
	CURLcode code =	curl_easy_setopt(curl, CURLOPT_POSTFIELDS, fields);

	lua_pushinteger(L, code);

	return 1;
}

static int l_curl_easy_setopt_httpheader(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	struct curl_slist *list = (struct curl_slist *)lua_touserdata(L, -1);

	CURLcode code =	curl_easy_setopt(curl, CURLOPT_HTTPHEADER, list);

	lua_pushinteger(L, code);

	return 1;
}


static int l_curl_easy_reset(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -1);
	
	curl_easy_reset(curl);

	return 0;
}

static int l_curl_easy_duphandle(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -1);
	
	CURL *dup = curl_easy_duphandle(curl);

	lua_pushlightuserdata(L, dup);

	return 1;
}

static int l_curl_slist_append(lua_State *L) {
	
	struct curl_slist *list = (struct curl_slist *)lua_touserdata(L, -2);
	const char *header = lua_tostring(L, -1);

	list = curl_slist_append(list, header);

	lua_pushlightuserdata (L, (void *)list);

	return 1;
}

static int l_curl_slist_free_all(lua_State *L) {
	
	struct curl_slist *list = (struct curl_slist *)lua_touserdata(L, -1);

	curl_slist_free_all(list);

	return 0;
}

struct memory {
	lua_State *L;
	char *response;
	size_t size;
};
 
static size_t cb(void *data, size_t size, size_t nmemb, void *userp)
{
	assert(size == 1); // according to the documentation.

	size_t realsize = size * nmemb;

	struct memory *mem = (struct memory *)userp;

	char *ptr = realloc(mem->response, mem->size + realsize + 1);

	if(ptr == NULL)
	return 0;  

	mem->response = ptr;
	memcpy(&(mem->response[mem->size]), data, realsize);
	mem->size += realsize;
	mem->response[mem->size] = 0;

	return realsize;
}

static size_t cb1(void *data, size_t size, size_t nmemb, void *userp)
{
	size_t realsize = cb(data, size, nmemb, userp);

	struct memory *mem = (struct memory *)userp;

	lua_State *L = (lua_State *) lua_touserdata(mem->L, -2);
	lua_pushvalue(mem->L, -1);	// duplicate the callback function for repeated applications of it.
	lua_xmove(mem->L, L, 1);
	lua_pushstring(L, mem->response);
	lua_pushinteger(L, realsize);
	lua_call(L, 2, 0);

	return realsize;
}

static int l_curl_easy_setopt_writefunction(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2); 	// the second argument is the callback function
	int isfunction = lua_isfunction(L, -1);
	
	lua_State *S;
	CURLcode code;
	
	if (isfunction == 1) {
		S = lua_newthread (L); // such a new thread is pushed on L also.
		lua_pushlightuserdata(S, (void *) L); // put the current state itself
		lua_pushvalue(L, -2);	// duplicate the given function
		lua_xmove(L, S, 1);	// then save the doubled reference to the helper state.
		
		code =	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb1);
	} else {
		S = NULL;
		code =	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, cb);
	}
	
	struct memory *mem = (struct memory *) malloc( sizeof( struct memory ));
	mem->L = S;
	mem->response = NULL;
	mem->size = 0;
	
	CURLcode ccode = curl_easy_setopt(curl, CURLOPT_WRITEDATA,  mem);
	assert(ccode == 0);
	
	lua_pushinteger(L, code);
	lua_pushlightuserdata(L, mem);
	
	if (S != NULL) {
		lua_pushvalue(L, -3);	// duplicate the working thread
		lua_remove(L, -4);	// cleanup a doubled value
	} else {
		lua_pushnil(L);
	}

	return 3;
}

static int l_curl_easy_getopt_writedata(lua_State *L) {
	
	struct memory *mem = (struct memory *)lua_touserdata(L, -1);
	lua_pushstring(L, mem->response);
	lua_pushinteger(L, mem->size);
	return 2;
}


static int l_curl_easy_getinfo_response_code(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -1);
	
	long response_code;
	CURLcode code = curl_easy_getinfo(curl, CURLINFO_RESPONSE_CODE, &response_code);
	
	lua_pushinteger(L, code);
	lua_pushinteger(L, response_code);

	return 2;
}

static int l_curl_version(lua_State *L) {
	
	char *version =	curl_version();

	lua_pushstring(L, version);

	return 1;
}

static int l_curl_getdate(lua_State *L) {
	
	const char *datestr = lua_tostring(L, -1);
	time_t t = curl_getdate(datestr, NULL);

	lua_pushinteger(L, t);

	return 1;
}

static int l_curl_easy_escape(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *str = lua_tostring(L, -1);
	
	char *encoded = curl_easy_escape(curl, str, 0);
	
	lua_pushstring(L, encoded);

	return 1;
}

static int l_curl_easy_unescape(lua_State *L) {
	
	CURL *curl = (CURL *)lua_touserdata(L, -2);
	const char *str = lua_tostring(L, -1);
	int size;	

	char *decoded = curl_easy_unescape(curl, str, 0, &size);
	
	lua_pushstring(L, decoded);
	lua_pushinteger(L, size);

	return 2;
}

static int l_curl_free(lua_State *L) {
	const char *str = lua_tostring(L, -1);
	curl_free((char *)str);

	return 0;
}

static int l_libc_free(lua_State *L) {
	void *p = lua_touserdata(L, -1);
	free(p);

	return 0;
}

static int l_test(lua_State *L) {
	lua_State *S = lua_newthread (L); // such a new thread is pushed on L also.
	lua_Integer i = lua_tointeger(L, -2);
	lua_pushinteger(S, i);
	assert(lua_tointeger(S, -1) == 42);
	return 1;
}

static int l_test_func(lua_State *L) {
	lua_State *S = lua_newthread (L); // such a new thread is pushed on L also.
	lua_pushvalue(L, -2);	// duplicate the given function
	lua_xmove(L, S, 1);
	return 1; // the thread actually
}

/*
	Registration phase starts
*/

static const struct luaL_Reg libcurl [] = {
	{"curl_easy_init", l_curl_easy_init},
	{"curl_easy_cleanup", l_curl_easy_cleanup},
	{"curl_easy_reset", l_curl_easy_reset},
	{"curl_easy_duphandle", l_curl_easy_duphandle},
	{"curl_easy_setopt_url", l_curl_easy_setopt_url},
	{"curl_easy_setopt_header", l_curl_easy_setopt_header},
	{"curl_easy_setopt_netrc", l_curl_easy_setopt_netrc},
	{"curl_easy_setopt_post", l_curl_easy_setopt_post},
	{"curl_easy_setopt_verbose", l_curl_easy_setopt_verbose},
	{"curl_easy_setopt_capath", l_curl_easy_setopt_capath},
	{"curl_easy_setopt_cainfo", l_curl_easy_setopt_cainfo},
	{"curl_easy_setopt_username", l_curl_easy_setopt_username},
	{"curl_easy_setopt_password", l_curl_easy_setopt_password},
	{"curl_easy_setopt_postfields", l_curl_easy_setopt_postfields},
	{"curl_easy_setopt_httpheader", l_curl_easy_setopt_httpheader},
	{"curl_easy_setopt_writefunction", l_curl_easy_setopt_writefunction},
	{"curl_easy_getinfo_response_code", l_curl_easy_getinfo_response_code},
	{"curl_easy_getopt_writedata", l_curl_easy_getopt_writedata},
	{"curl_easy_perform", l_curl_easy_perform},
	{"curl_slist_append", l_curl_slist_append},
	{"curl_slist_free_all", l_curl_slist_free_all},
	{"curl_version", l_curl_version},
	{"curl_getdate", l_curl_getdate},
	{"curl_easy_escape", l_curl_easy_escape},
	{"curl_easy_unescape", l_curl_easy_unescape},
	{"libc_free", l_libc_free},
	{"curl_free", l_curl_free},
	{"test", l_test},
	{"test_func", l_test_func},
	{NULL, NULL} /* sentinel */
};
 
int luaopen_libcurllua (lua_State *L) {
	luaL_newlib(L, libcurl);
	return 1;
}

