/*==========================================================
		"Rcon Controller" Filterscript for SA-MP
	Copyright (C) 2008-2015 CoolGuy(밥먹었니)

	RconController.pwn - Main interface
	Applicable SA-MP version : 0.2X - 0.3z

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see http://www.gnu.org/licenses.

"Rcon Controller" Credits :
	제작 - CoolGuy(밥먹었니)

최근의 소스코드 수정 사항은 changelog.txt를 참조하십시오.

"Rcon Controller" 및 프로그램 공식카페 :
http://cafe.daum.net/Coolpdt
//=========================================================*/
//==========================================================
// Informations & Compile Options
//==========================================================
#define VERSION "V18 alpha3"
#define VERSION_INTERNAL 1803
#define MAX_SUBADMIN 20 //추가 가능한 부운영진의 수입니다.
#define MAX_YELLS 200 //추가 가능한 욕의 갯수입니다.
#define MAX_YELL_CHAR 64 //최대로 추가할 수 있는 욕의 길이입니다.
#define MAX_BAD_PLAYERS 200 //최대로 저장할 수 있는 비매너 플레이어의 수입니다.
/* 하위 버전 호환성 */
#define SAMP02X false //0.2X 호환 컴파일 : 상위 버전 옵션을 모두 해제하시기 바랍니다.
#define SAMP03a true //0.3a 에서 추가된 기능(GUI, RCON 방어)사용
#define SAMP03b true //0.3b 에서 추가된 기능(업데이트 확인) 사용
#define SAMP03x true //0.3x 에서 추가된 기능 사용
#define SAMP03z true //0.3z 에서 추가된 기능 사용(콜백 함수)
#define PLUGIN false //플러그인 사용
#define COPYRIGHT_STRING "Copyright (c) 2008-2015 CoolGuy"



//==========================================================
// Includes
//==========================================================
#include <a_samp>
#if SAMP03b /* SA-MP 0.3b의  기능 사용 */
	#include <a_http>
#endif
#if PLUGIN /* 플러그인 점검 */
	#include "filemanager"
#endif
#include "dutils"
#define _COOLGUY_NO_SUBADMIN
#include "coolguy" //CoolGuy's Standard Header
#include "y_bintree.inc" //Binary Tree


//=========================================================
// General Macros & Magic Numbers 위 아래 위위아래 위 아래 위위아래
//=========================================================
//파일 목록 정의
#define FILE_SETTINGS "MINIMINI/RconController.ini"
#define FILE_YELLFILTER "MINIMINI/RC_Yells.ini"
#define FILE_DUMP "RC_Dump.txt"
#define FILE_FIRSTRUN "MINIMINI/firstrun"
#define DUMPEXIST fexist(FILE_DUMP)

//콘솔 인식 관련
#define ADMIN_ID MAX_PLAYERS
#define CONSOLE (playerid == ADMIN_ID)

//무기핵 관련
#define MAX_WEAPONS 55

//벌칙 관련
#define PUNISH_FREEZE 0
#define PUNISH_SHUTUP 1
#define PUNISH_CMDRESTRICT 2
#define KICK_THIS_PLAYER -100
#define BAN_THIS_PLAYER -500

/* GUI 관련 */
#if SAMP03a
	#define DIALOG_PM 1000
	#define DIALOG_USER_MAIN 1001
	#define DIALOG_USER_VOTEKICK 1002
	#define DIALOG_USER_VOTEBAN 1003
	#define DIALOG_ADMIN_MAIN 1004
	#define DIALOG_ADMIN_KICK 1005
	#define DIALOG_ADMIN_BAN 1006
	#define DIALOG_ADMIN_WITH 1007
	#define DIALOG_ADMIN_CALL 1008
	#define DIALOG_ADMIN_KILL 1009
	#define DIALOG_ADMIN_SETHP 1010 //sethealth
	#define DIALOG_ADMIN_INFINITE 1011
	#define DIALOG_ADMIN_MAKECASH 1012
	#define DIALOG_ADMIN_FORFEIT 1013
	#define DIALOG_ADMIN_SETCASH 1014
	#define DIALOG_ADMIN_SETSCORE 1015
	#define DIALOG_ADMIN_GIVEWP 1016 //giveweapon
	#define DIALOG_ADMIN_DISARM 1017
	#define DIALOG_ADMIN_FREEZE 1018
	#define DIALOG_ADMIN_UNFREEZE 1019
	#define DIALOG_ADMIN_ARMOR 1020
	#define DIALOG_ADMIN_INFARMOR 1021
	#define DIALOG_ADMIN_SPAWNCAR 1022
	#define DIALOG_ADMIN_SDROP 1023
	#define DIALOG_ADMIN_CARENERGY 1024
	#define DIALOG_ADMIN_JETPACK 1025
	#define DIALOG_ADMIN_MUSIC 1026
	#define DIALOG_ADMIN_MUSICOFF 1027
	#define DIALOG_ADMIN_BOMB 1028
	#define DIALOG_ADMIN_SHUTUP 1029
	#define DIALOG_ADMIN_UNSHUT 1030
	#define DIALOG_ADMIN_CHANGENICK 1031
	#define DIALOG_ADMIN_SPECTATE 1032
	#define DIALOG_ADMIN_SUBADMIN 1033
	#define DIALOG_ADMIN_DELSUB 1034
	#define DIALOG_ADMIN_FIND 1035
#endif

//automatic update
#if SAMP03b /* SA-MP 0.3b의 업데이트 기능 사용 */
	#define MAX_UPDATE 32
	#define UPDATE_CHECK 501
	#define UPDATE_FILELIST 502
	#define UPDATE_FILES 503
#endif

//=========================================================
// Fake Functions
//=========================================================
#define GetPlayerNameEx(%1) PLAYER_NAME[%1]
#define IsPlayerConnectedEx(%1) (pITT_INDEX[%1] != -1)
#define IsWeaponForbidden(%1) IS_WEAPON_FORBIDDEN[%1]
#define GetPlayerIpEx(%1) PLAYER_IP[%1]
#define No_Console() if(CONSOLE) return !print("[rcon] 콘솔에서는 사용이 불가능한 명령어입니다.")
#define No_Wildcard() (CONSOLE)? ((print("[rcon] 와일드카드를 사용할 수 없는 명령어입니다.") ^ 1)):(SendClientMessage(playerid, COLOR_GREY, "* 와일드카드를 사용할 수 없는 명령어입니다."))
#define STUB() print("stub")
#define SEND() SendClientMessage( playerid, COLOR_LIME, str )
#define SEND_C(%1) SendClientMessage( playerid, %1, str )

//자동 명령어 핸들러 : 컴파일 속도 향상
#define rcmd(%1,%2,%3) if((strcmp(cmds[1],(%1),true,(%2))==0) && (((cmds[(%2)+1]==0) && (rcmd_%3("")))||((cmds[(%2)+1]==32) && (rcmd_%3(cmds[(%2)+2]))))) return 1
#if SAMP03a /* SA-MP 0.3a의 다이얼로그 기능 사용 */
	#define gcmd(%1,%2) case %1: return dialog_%2(playerid,response,listitem,inputtext)
#endif

//디버그용
#define debugprintf printf
#define debugprint print

//=========================================================
// Fake Variables
//=========================================================
#define IS_CHAT_FORBIDDEN[%1] (PLAYER_PUNISH_REMAINTIME[%1][PUNISH_SHUTUP] != 0)
#define IS_CMD_FORBIDDEN[%1] (PLAYER_PUNISH_REMAINTIME[%1][PUNISH_CMDRESTRICT] != 0)

//=========================================================
// Global variables (general)
//=========================================================
//정적 타이머
enum Timerinfo
{
	CmdFlood,
	ChatFlood,
	ResetPing
}

#if SAMP03a /* SA-MP 0.3a의 다이얼로그 기능 사용 */
	enum Weapon_info
	{
		weaponname[32],
		weapon_id
	}
#endif

new
	//iteration optimization
	M_P,
	NUM_PLAYERS,
	pITT[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	pITT_INDEX[MAX_PLAYERS] = {-1, ...},

	StaticTimer[Timerinfo] = { -1, ... },
	
	IS_WEAPON_FORBIDDEN[MAX_WEAPONS],
	PLAYER_SPAWNED[MAX_PLAYERS],
	PLAYER_NAME[MAX_PLAYERS+1][MAX_PLAYER_NAME],
	PLAYER_IP[MAX_PLAYERS][16],
	PERMANENT_ADMINSAY[MAX_PLAYERS + 1], // for admin stuff
	PLAYER_CURSCR[MAX_PLAYERS + 1], // for admin stuff
	IS_HEAR_CMDTRACE[MAX_PLAYERS + 1] = {1, ...},	 //for admin stuff lol
	PLAYER_PUNISH_REMAINTIME[MAX_PLAYERS][3],	
	YELLS[MAX_YELLS][MAX_YELL_CHAR],
	YELL_VER[15],
	PLAYER_PMABUSE_TIMES[MAX_PLAYERS],	
	CHATFLOOD_TIMES[MAX_PLAYERS],
	CMDFLOOD_TIMES[MAX_PLAYERS],
	CMDFLOOD_STILL_TIMES[MAX_PLAYERS],
	PLAYER_CASH[MAX_PLAYERS],
	PLAYER_MONEYCHECK[MAX_PLAYERS],
	BinaryTree:TREE_BADPLAYER<MAX_BAD_PLAYERS>,
	BAD_PLAYER_IP[MAX_BAD_PLAYERS],
	BADKICKED_TIMESTAMP[MAX_BAD_PLAYERS],
	BADPLAYER_MESSAGE[512],
	ADMINCHAT_NAME[512],
	IS_PLAYER_SPECTATING[MAX_PLAYERS] = { INVALID_PLAYER_ID, ... },
	IS_PLAYER_SPECTATED[MAX_PLAYERS] = { INVALID_PLAYER_ID, ... },
	PLAYER_DESYNCED_TIMES[MAX_PLAYERS],

	/* 핑정리 관련 변수 */
	USE_PINGCHECK=1, //핑정리 사용
	HIGHPING_LIMIT, //지연시간 경고값
	HIGHPING_WARN_LIMIT, //지연시간 경고횟수 임계값
	PINGCHECK_DURATION, //핑정리 주기
	HIGHPING_WARNED_TIMES[MAX_PLAYERS], //높은 지연시간으로 경고받은 횟수
	PLAYER_JUST_CONNECTED[MAX_PLAYERS] = {5, ...}, //접속 핸들링과 핑정리 주기 조절
	RESET_HIGHPING_TICK, //경고횟수 초기화 주기
	/* 강제추방 관련 변수 */
	ENABLE_VOTEKICK,//투표 활성화
	ENABLE_VOTEBAN,
	VOTEKICK_RUN_TIME, VOTEBAN_RUN_TIME, //투표 돌리는 시간
	VOTEKICK_NOTIFY_DURATION, VOTEBAN_NOTIFY_DURATION, // 투표상황 공지 주기
	VOTE_CONFIDENTIALITY, // 투표 신고인 명시여부
	REQUIRED_MAN_VOTEKICK,
	REQUIRED_MAN_VOTEBAN, // 강제추방을 시작할 최소인원
	MINIMUM_VOTEKICK_PERCENTAGE, // 강제추방까지 필요한 득표율
	MINIMUM_VOTEBAN_PERCENTAGE,
	//ingame variables
	VOTEKICK_PLAYER = INVALID_PLAYER_ID,
	VOTEBAN_PLAYER = INVALID_PLAYER_ID, //대상 플레이어 아이디
	VOTEKICK_PLAYER_GOT,
	VOTEBAN_PLAYER_GOT,	//받은 표
	VOTEKICK_REMAINTIME,
	VOTEBAN_REMAINTIME, //남은 시간
	CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS, //투표를 시작할 당시의 필요 찬성인원
	CURRENT_VOTEBAN_REQUIREMENT,
	VOTEKICK_TICK, // 강제추방 공지 돌리는 타이머
	VOTEBAN_TICK,
	KICKVOTED_PLAYER_IP[MAX_PLAYERS], //중복투표 방지용 IP저장소
	BANVOTED_PLAYER_IP[MAX_PLAYERS],
	
	POLICY_RCON_LOGINFAIL_INTERNAL, //내부 유저가 Rcon Login실패시의 적용정책
	MAX_RCONLOGIN_ATTEMPT, //최대 Rcon Login실패 한도
	
	SAVE_CURRRENT_CONFIG=1,DUMPEXIT, ALLOW_DESYNC=2, DESYNC_LIMIT=30,
	USE_BADWARN=1, CUR_BADP_POINT, ALLOW_PRIVATE_SPECTATE=0,
	ONFLOOD_CHAT, ONFLOOD_CMD, ONCHEAT_WEAPON,
	USE_ANTI_MONEYCHEAT, USE_ANTI_WEAPONCHEAT, CMDFLOOD_LIMIT=15,
	CMDFLOOD_UNIT_TIME=10, CMDFLOOD_FORBIDDEN_TIME=30, USE_ANTI_CMDFLOOD=1,
	CMDFLOOD_STILL_LIMIT=15, PMABUSE_LIMIT=15, CHATFLOOD_LIMIT=5,
	USE_ANTI_CHATFLOOD=1, CHATFLOOD_UNIT_TIME=5,
	CHATFLOOD_SHUTUP_TIME=30,
	NOTICE_INTERVAL, Num_Notice, LAST_PLAYER_ID,
	SERVER_LOCKED, 
	USE_YELLFILTER, ALLOW_JETPACK=1, num_Yells;	
	
#if SAMP03a /* SA-MP 0.3a의 다이얼로그 기능 사용 */
	new DIALOG_CLICKED_PLAYER[MAX_PLAYERS];
	new WEAPON_STORAGE[][Weapon_info] =
	{
		{"브레스 너클", 1},
		{"골프채", 2},
		{"경찰봉", 3},
		{"과도", 4},
		{"야구방망이", 5},
		{"삽", 6},
		{"당구채", 7},
		{"일본도", 8},
		{"전기톱", 9},
		{"딜도", 10},
		{"딜도2", 11},
		{"바이브레이터", 12},
		{"바이브레이터2", 13},
		{"꽃", 14},
		{"지팡이", 15},
		{"슈류탄", 16},
		{"최루가스", 17},
		{"화염병", 18},
		{"콜트 45", 22},
		{"콜트 (소음기 장착)", 23},
		{"데저트 이글", 24},
		{"산탄총 (단발)", 25},
		{"산탄총 (4연발)", 26},
		{"산탄총 (7연발)", 27},
		{"UZI", 28},
		{"MP-5", 29},
		{"AK-47", 30},
		{"M4", 31},
		{"TEC-9", 32},
		{"라이플", 33},
		{"스나이퍼 라이플", 34},
		{"로켓 런처", 35},
		{"열추적 로켓", 36},
		{"화염방사기", 37},
		{"미니건", 38},
		{"폭탄가방", 39},
		{"폭탄 점화기", 40},
		{"스프레이 캔", 41},
		{"소화기", 42},
		{"카메라", 43},
		{"낙하산", 46}
	};
	new VEHICLE_STORAGE[][Weapon_info] =
	{
		{"인페르노", 411},
		{"술탄", 560},
		{"피닉스", 603},
		{"총알", 541},
		{"엘러지", 562},
		{"택시", 420},
		{"버스", 431},
		{"FBI 차랑", 490},
		{"몬스터 트럭", 556},
		{"FBI 트럭", 528},
		{"물탱크", 601},
		{"금고 차량", 609},
		{"BMX 자전거", 481},
		{"피자배달 오토바이", 448},
		{"프리웨이", 463},
		{"PCJ-600", 461},
		{"산체스", 468},
		{"NRG-500", 522},
		{"경찰 오토바이", 523},
		{"군용 탱크", 432},
		{"카트", 571},
		{"트랙터", 531},
		{"콤바인", 532},
		{"AT-400", 577},
		{"도도비행기", 593},
		{"Shamal", 519},
		{"히드라", 520},
		{"헌터", 425},
		{"헬기", 487},
		{"해양헬기", 447}
	};
	new MUSIC_STORAGE[][Weapon_info] =
	{
		{"맞는 소리", 1002},
		{"부딪히는 소리", 1009},
		{"펀치소리", 1130},
		{"폭발하는 소리", 1140},
		{"비행학교 음악", 1187},
		{"배경음악 1", 1097},
		{"운전학교 음악", 1183},
		{"오토바이 학교 음악", 1185}
	};
#endif

/***********************************************************/
/* SPECIAL DECLARATION SET ********************************/
/***********************************************************/

//==========================================================
// 부운영자 관련
//==========================================================
#define IsPlayerSubAdmin(%1) PLAYER_AUTHORITY[(%1)][AUTH_SUBADMIN]
#define SetPlayerSubAdmin(%1,%2) PLAYER_AUTHORITY[%1][AUTH_SUBADMIN]=1;LoadPlayerAuthProfile(%1,%2)
#define UnSetPlayerSubAdmin(%1) for( new subvar = 1;  subvar < NUM_AUTH; subvar++ ) PLAYER_AUTHORITY[(%1)][Authinfo:subvar] = 0
#define AuthorityCheck(%1,%2) PLAYER_AUTHORITY[%1][%2]
#define SendAdminMessageAuth(%1,%2,%3) for(new sendmsg=0;sendmsg<NUM_PLAYERS;sendmsg++) if(IsPlayerAdmin(pITT[sendmsg]) || (IsPlayerSubAdmin(pITT[sendmsg]) && AuthorityCheck(pITT[sendmsg],%1))) SendClientMessage(pITT[sendmsg],%2,%3)
#define PERMANENT_ADMINSAY(%1) PERMANENT_ADMINSAY[%1]
#if SAMP03a /* SA-MP 0.3a의 다이얼로그 기능 사용 */
	#define Auth_Check(%1) if(IsPlayerSubAdmin(playerid) && !AuthorityCheck(playerid,(%1)) && SendClientMessage(playerid,COLOR_RED,"* 해당 명령어를 사용할 권한이 없습니다.")) return 1
#endif

//기본 부운영자 정보
enum SUBINFO 
{
	Name[MAX_PLAYER_NAME],
	Password_Hash,
	IP[16],
	profile_index //제공 프로필 번호
}

//권한 목록
#define NUM_AUTH sizeof( PLAYER_AUTHORITY[] )
enum Authinfo
{
	AUTH_NONE,
	AUTH_SUBADMIN,
	AUTH_PMTRACE,
	AUTH_CMDTRACE,
	AUTH_NOTICES,
	AUTH_CMD_SAY,
	AUTH_CMD_WTIME,
	AUTH_CMD_KILL,
	AUTH_CMD_CASH,
	AUTH_CMD_GIVEWEAPON,
	AUTH_CMD_CHANGENICK,
	AUTH_CMD_SETHEALTH,
	AUTH_CMD_SETSCORE,
	AUTH_CMD_SETARMOR,
	AUTH_CMD_FREEZE,
	AUTH_CMD_UNFREEZE,
	AUTH_CMD_SOUND,
	AUTH_CMD_USERINFO,
	AUTH_CMD_JETPACK,
	AUTH_CMD_KICK,
	AUTH_CMD_BAN,
	AUTH_CMD_SHUTUP,
	AUTH_CMD_UNSHUT,
	AUTH_CMD_FORFEIT,
	AUTH_CMD_DISARM,
	AUTH_CMD_SPAWNCAR,
	AUTH_CMD_SETSUBADMIN,
	AUTH_CMD_DELSUBADMIN,
	AUTH_CMD_BOMB,
	AUTH_CMD_NOTICE,
	AUTH_CMD_LOCKSERVER,
	AUTH_CMD_WITH,
	AUTH_CMD_CALL,
	AUTH_CMD_AUTH,
	AUTH_CMD_GRAVITY,
	AUTH_CMD_WEATHER,
	AUTH_CMD_CARENERGY,
	AUTH_CMD_YELLFILTER,
	AUTH_CMD_ANTICHEAT,
	AUTH_CMD_PINGCHECK,
	AUTH_CMD_SPECTATE,
	AUTH_CMD_DESYNC,
	AUTH_CMD_MAKESOUND,
	AUTH_CMD_CONFIG,
	AUTH_CMD_UNBAN,
	AUTH_CMD_VOTE	
}

//변수 선언 
new 
	PLAYER_AUTHORITY[MAX_PLAYERS][Authinfo],
	SubAdmin[MAX_SUBADMIN][SUBINFO],
	//부운영자 목록, 로드 등등 설정파일의 변수
	Num_SubAdmin, LOAD_SUBADMIN=1,
	SUBADMIN_FAILLOGIN_TIMES[MAX_PLAYERS],
	SUBADMIN_FAILLOGIN_LIMIT=3;
	


//==========================================================
// 명령어 집중화
//==========================================================
//dcmd_sample( playerid, params[], help ) help = cmdidx
#define NULL {1,0}
#define NO_HELP false
#define CURRENT_CMD_NAME cmdlist[CMD_CURRENT][Cmd]
#define CURRENT_CMD_ALTER_NAME cmdlist[CMD_CURRENT][Func]
#define CURRENT_PARAMS Help_Params[CMD_CURRENT]
#define GetCmdName(%1) cmdlist[%1][Cmd]
#define GetCmdAltName(%1) cmdlist[%1][Func]
enum Cmdinfo
{
	Cmd[32],
	Func[32],
	Authinfo:Required_Auth
}

//명령어 순서
enum Cmdorder
{
	CMD_SAY, 						CMD_PSAY, 				CMD_SPM,
	CMD_KICK,						CMD_BAN,					CMD_VKICK,					 CMD_VBAN,
	CMD_CONFIDENTIAL,		CMD_UNBAN,				CMD_UNBANIP,
	CMD_WITH,						CMD_CALL, 					CMD_SPECTATE,
	CMD_SPECOFF, 				CMD_SKILL, 				CMD_SETHP,
	CMD_INFINITE, 				CMD_ARMOR, 				CMD_INFARMOR,
	CMD_MCASH,					CMD_FORFEIT, 			CMD_SETCASH,
	CMD_SCORE, 					CMD_GIVEWP,				CMD_DISARM,
	CMD_FREEZE, 					CMD_UNFRZ, 				CMD_SPCAR,
	CMD_DROP, 					CMD_CARHP, 				CMD_FIXCAR,
	CMD_JPACK,
	CMD_SOUND, 					CMD_MUTE, 				CMD_BOMB,
	CMD_CHNICK, 					CMD_SHUTUP, 			CMD_UNSHUT,
	CMD_YELL, 						CMD_ADDYELL, 			CMD_DELYELL,
	CMD_CHATFLOOD,			CMD_CMDFLOOD,		CMD_WPCHEAT,
	CMD_ADDWC,					CMD_DELWC, 				CMD_JPCHEAT,
	CMD_DESYNC, 				CMD_PING, 					CMD_PLIMIT,
	CMD_PWARNTIME, 			CMD_PRESET,
	CMD_SUBADMIN, 			CMD_SUBLOGIN, 		CMD_SUBOUT,
	CMD_SUSPEND, 				CMD_RELOADSUBS,
	CMD_CHAUTH, 				CMD_AUTHLIST, 			CMD_MYAUTH,
	CMD_CMDTRACE, 			CMD_MKS, 					CMD_WEATHER,
	CMD_GRAVITY, 				CMD_WTIME, 				CMD_FIND,
	CMD_STAT, 						CMD_NOTICE, 				CMD_NLIST,
	CMD_RELOADNOTICE, 	CMD_SAVECONFIG, 		CMD_LOADCONFIG,
	CMD_VIEWCONFIG, 			CMD_LOCKSVR,
#if SAMP03a
	CMD_GUI,
#endif
	CMD_HELP, 						CMD_HELP2, 				CMD_VERSIONINFO
}

//명령어 정보
new cmdlist[Cmdorder][Cmdinfo] = 
{
	{"말", "say", AUTH_CMD_SAY}, 									{"말모드", "psay",AUTH_CMD_SAY}, 						{"귓말", "spm",AUTH_NONE},
	{"킥", "skick", AUTH_CMD_KICK}, 									{"밴", "sban", AUTH_CMD_BAN}, 								{"강퇴투표", "vkick", AUTH_NONE}, 							{"영밴투표", "vban", AUTH_NONE}, 
	{"신원보호", "confidential", AUTH_CMD_VOTE},				{"밴풀기", "unban", AUTH_CMD_UNBAN},					{"ip밴풀기",  "unbanip", AUTH_CMD_UNBAN}, 
	{"출두", "with", AUTH_CMD_WITH}, 								{"소환", "call", AUTH_CMD_CALL}, 							{"감시", "spectate", AUTH_CMD_SPECTATE},
	{"감시해제", "specoff", AUTH_CMD_SPECTATE}, 			{"사살", "skill", AUTH_CMD_KILL}, 								{"체변경", "sethp", AUTH_CMD_SETHEALTH},
	{"무적", "infinite", AUTH_CMD_SETHEALTH}, 				{"아머", "armor", AUTH_CMD_SETARMOR}, 				{"아머무적", "infarmor", AUTH_CMD_SETARMOR},
	{"돈주기", "mcash", AUTH_CMD_CASH},						{"돈박탈", "forfeit", AUTH_CMD_FORFEIT}, 				{"돈설정", "setcash", AUTH_CMD_CASH},
	{"스코어", "score", AUTH_CMD_SETSCORE}, 				{"무기주기", "givewp", AUTH_CMD_GIVEWEAPON}, 	{"무기박탈", "disarm", AUTH_CMD_DISARM}, 
	{"프리즈", "freeze", AUTH_CMD_FREEZE},					{"언프리즈", "unfrz", AUTH_CMD_UNFREEZE}, 			{"차소환", "spcar", AUTH_CMD_SPAWNCAR},
	{"내리기", "drop",  AUTH_CMD_SPECTATE}, 				{"차에너지", "carhp", AUTH_CMD_CARENERGY},		{"차수리", "fixcar", AUTH_CMD_CARENERGY},
	{"제트팩", "jpack",  AUTH_CMD_JETPACK},
	{"소리", "sound", AUTH_CMD_SOUND},						{"소리끄기", "mute", AUTH_CMD_SOUND}, 				{"폭탄", "bomb", AUTH_CMD_BOMB},	
	{"닉바꾸기", "chnick", AUTH_CMD_CHANGENICK},		{"채금", "shutup", AUTH_CMD_SHUTUP}, 					{"채금해제", "unshut", AUTH_CMD_UNSHUT},
	{"욕필터", "yell", AUTH_CMD_YELLFILTER},					{"욕추가", "addyell", AUTH_CMD_YELLFILTER}, 		{"욕제거", "delyell", AUTH_CMD_YELLFILTER},
	{"도배","chatflood",AUTH_CMD_SHUTUP},					{"명령어도배", "cmdflood", AUTH_CMD_SHUTUP}, 	{"무기핵", "wpcheat", AUTH_CMD_ANTICHEAT},
	{"무기추가", "addwc", AUTH_CMD_ANTICHEAT}, 			{"무기제거", "delwc", AUTH_CMD_ANTICHEAT}, 		{"제트팩핵", "jpcheat", AUTH_CMD_ANTICHEAT},
	{"잠수", "desync", AUTH_CMD_DESYNC},						{"핑정리", "ping", AUTH_CMD_PINGCHECK}, 			{"핑제한", "plimit", AUTH_CMD_PINGCHECK},
	{"핑경고", "pwarntime", AUTH_CMD_PINGCHECK}, 		{"핑초기화", "preset", AUTH_CMD_PINGCHECK}, 	
	{"부운", "subadmin", AUTH_CMD_SETSUBADMIN}, 		{"부운로그인", "sublogin", AUTH_NONE}, 					{"부운종료", "subout", AUTH_SUBADMIN},
	{"부운박탈", "suspend", AUTH_CMD_DELSUBADMIN}, 	{"부운로드", "reloadsubs", AUTH_CMD_AUTH}, 
	{"권한변경", "chauth", AUTH_CMD_AUTH}, 					{"권한목록", "authlist", AUTH_CMD_AUTH}, 				{"내권한", "myauth", AUTH_SUBADMIN}, 
	{"명령어추적", "cmdtrace", AUTH_CMDTRACE}, 			{"호출", "mks", AUTH_CMD_MAKESOUND}, 				{"날씨", "weather", AUTH_CMD_WEATHER}, 
	{"중력", "gravity", AUTH_CMD_GRAVITY}, 						{"시각", "wtime", AUTH_CMD_WTIME}, 						{"누구", "find", AUTH_CMD_USERINFO},
	{"상태",  "stat", AUTH_CMD_USERINFO}, 						{"공지", "notice", AUTH_CMD_NOTICE},					{"공지목록", "nlist", AUTH_CMD_NOTICE},
	{"공지로드", "reloadnotice", AUTH_CMD_NOTICE},		{"설정저장", "saveconfig", AUTH_CMD_CONFIG}, 		{"설정로드", "loadconfig", AUTH_CMD_CONFIG},
	{"서버설정", "viewconfig", AUTH_NONE},						{"서버잠그기", "locksvr", AUTH_CMD_LOCKSERVER},
#if SAMP03a
	{"관리창", "gui", AUTH_SUBADMIN},
#endif
	{"도움말1", "rchelp", AUTH_NONE},								{"도움말2", "rchelp2", AUTH_NONE}, {"버전정보", "rconcontroller", AUTH_NONE}
};

//명령어에 대한 도움말 (파라메터)
new Help_Params[Cmdorder][128] = {
	"[할말]", 													" ", 																	"[이름이나 번호] [할말]", 																//말, 말모드, 귓말
	"[이름이나 번호] [이유=없음]", 					"[이름이나 번호] [이유=없음]", 							"[이름이나 번호]", 									"[이름이나 번호]",			//킥, 밴, 강퇴투표, 영밴투포
	" ", 															"[아이디]",														"[아이피]",																					//신원보호, 밴풀기, ip밴풀기
	"[이름이나 번호]",										"[이름이나 번호, * = 모두]", 								"[이름이나 번호]",																			//출두, 소환, 감시
	" ",															"[이름이나 번호]",												"[이름이나 번호], [체력]",																//감시해제, 사살, 체변경
	"[이름이나 번호]",										"[이름이나 번호] [아머]",									"[이름이나 번호]",																			//무적, 아머, 아머무적
	"[이름이나 번호] [돈]",								"[이름이나 번호]",												"[이름이나 번호] [돈]",																	//돈주기, 돈박탈, 돈설정
	"[이름이나 번호] [점수]",							"[이름이나 번호] [무기번호] [총알=3000발]",	"[이름이나 번호]",																			//스코어, 무기주기, 무기박탈
	"[이름이나 번호] [시간=무한]",					"[이름이나 번호]",												"[이름이나 번호] [모델]",																//프리즈, 언프리즈, 차소환
	"[이름이나 번호]",										"[이름이나 번호] [에너지]",								"[이름이나 번호]",																			//내리기, 차에너지, 차수리
	"[이름이나 번호]",																																																					//제트팩
	"[이름이나 번호, * = 모두] [소리번호]",		"[이름이나 번호]",												"[이름이나 번호]",																			//소리, 소리끄기, 폭탄
	"[이름이나 번호] [닉네임]",						"[이름이나 번호] [초=무한]",								"[이름이나 번호]",																			//닉바꾸기, 채금, 채금해제
	" ",															"[추가할 욕]",													"[제거할 욕]",																				//욕필터, 욕추가, 욕제거
	" ",															" ",																	" ",																								//도배, 명령어도배, 무기핵
	"[금지할 무기번호]",									"[허용할 무기번호]",											" ",																								//무기추가, 무기제거, 제트팩핵
	"[0=바로추방 1=일정시간 2=추방안함]",		" ",																	"[제한할 지연시간(ms)]",																//잠수, 핑정리, 핑제한
	"[추방전 경고할 횟수]",								"[핑정리 초기화 시간, 0=사용안함]",																														//핑경고, 핑초기화
	"[이름이나 번호]",										"[비밀번호]",													" ",																								//부운, 부운로그인, 부운종료
	"[이름이나 번호]",										" ",																																										//부운박탈, 부운로드
	"[이름이나 번호] [권한번호=0]",				" ",																	" ",																								//권한변경, 권한목록, 내권한
	" ",															"[비프음 횟수] [할말]",										"[날씨: 0~1337]",																			//명령어추적, 호출, 날씨
	"[중력=0.008, -50~+50]",							"[시각: 0~23]",													"[이름이나 번호]",																			//중력, 시간, 누구
	" ",															"[공지를 띄울 간격:초]",									" ",																								//상태, 공지, 공지목록
	" ",															" ",																	" ",																								//공지로드, 설정저장, 설정로드
	" ",															" ",																																										//서버설정, 서버잠그기
#if SAMP03a
	"[이름이나 번호]",																																																					//관리창
#endif
	" ",															" ",																	" "																								//도움말1, 도움말2, 버전정보
};

// 바이너리 트리 & 해싱 : 명령어 검색속도 증가
new BinaryTree:TREE_CMDLIST_HANGUL<sizeof(cmdlist)>;
new BinaryTree:TREE_CMDLIST_ENGLISH<sizeof(cmdlist)>;

//대화형 명령체계
#define ALL_PLAYER_ID INVALID_PLAYER_ID+1
#define ABORT_PROCESS INVALID_PLAYER_ID+2
#define INTERACTIVE_MANAGEMENT INVALID_PLAYER_ID+3
#define PROCESS_COMPLETE INVALID_PLAYER_ID+4
#define HELP_PROCESS INVALID_PLAYER_ID+5
#define CMD_INVALID Cmdorder:sizeof(cmdlist)
new Cmdorder:INTERACTIVE_COMMAND[MAX_PLAYERS+1] = { CMD_INVALID, ... };
new INTERACTIVE_STATE[MAX_PLAYERS+1];

//라인
new LINE[81] = { "===============================================================================", 0 };
new LINE_CLIENT[43] = { "=========================================", 0 };

/***********************************************************/
/* SPECIAL DECLARATION SET END ****************************/
/***********************************************************/


//==========================================================
// Forwards
//==========================================================
forward public Firstrun();
forward public ScrollHelp( playerid );
forward public Start_OneSecTimer_1();
forward public Start_OneSecTimer_2();
forward public OneSecTimer_1();
forward public OneSecTimer_2();
forward public ReLockServer();
forward public ResetChatFlood();
forward public ResetCmdFlood();
forward public ResetPingCheck();
forward public GivePlayerCash(playerid,money);
forward public ResetPlayerCash(playerid);
forward public GetPlayerCash(playerid);
forward public SetPlayerCash(playerid, money);
forward public SpectateTimer( playerid, giveplayerid );
#if SAMP03b
	forward public UpdateCheck(index, response_code, data[]);
#endif
#if !SAMP02X /* SA-MP 0.2X 호환 컴파일 */
	forward public OnPlayerPrivmsg(playerid, recieverid, text[]);
#endif
//commands
forward public dcmd_rchelp( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_rchelp2( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_with(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_call( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_sublogin( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_subout( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_gui( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_cmdtrace( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_find( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_spm(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_say( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_psay( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_wtime( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_skill( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_skick(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_sban(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_mcash(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_givewp(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_chnick(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_sethp(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_armor(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_infarmor( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_score(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_freeze(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_unfrz( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_sound(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_mute( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_jpack( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_shutup(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_unshut( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_forfeit( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_disarm( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_spcar(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_subadmin( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_suspend( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_bomb( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_setcash(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_infinite( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_notice( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_nlist( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_reloadnotice( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_reloadsubs( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_locksvr( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_chauth(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_authlist( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_gravity(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_weather(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_carhp(playerid, tmp[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_fixcar(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_yell(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_addyell(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_delyell( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_chatflood(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_wpcheat(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_addwc(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_delwc(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_jpcheat(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_cmdflood(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_ping(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_plimit(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_pwarntime(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_preset(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_drop(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_spectate(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_specoff(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_desync(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_mks( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_loadconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_saveconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_unban(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_unbanip( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_vkick( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_vban( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_confidential( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_rconcontroller( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_myauth(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_stat( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );
forward public dcmd_viewconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP );

//==========================================================
// Main Interface - Callback Declarations
//==========================================================
public OnFilterScriptInit()
{
	printf("\n           _---+ Now Loading MINIMINI: Rcon Controller %s  +---_", VERSION);
	print("                   Copyright (C) 2008 - 2013 CoolGuy(밥먹었니) \n");
#if SAMP02X
	print("[rcon] SA-MP 0.2X 호환 모드로 작동중입니다.");
#endif

	//최초사용자 확인
	if( fexist(FILE_FIRSTRUN) )
	{
		SetTimer("Firstrun",1000,0);
		fremove(FILE_FIRSTRUN);
	}	

	//최대 접속자수를 구한다.
	M_P = GetMaxPlayers();
	//운영자의 이름 적기
	PLAYER_NAME[ADMIN_ID] = "Admin";
	
	//필터스크립트를 구동할때 필요한 작업 시작
	IS_HEAR_CMDTRACE[ADMIN_ID] = 1; //명령어 추적기능 사용
	LoadUserConfigs();
	if( DUMPEXIST )
	{
		print("[rcon] 덤프 파일을 발견했습니다. 필터에 이식합니다...");
		CallDump();
	}
	GatherPlayerInformations();
	
	//바이너리 트리 구성
	new CMD_HASH_HANGUL[sizeof(cmdlist)][E_BINTREE_INPUT];
	new CMD_HASH_ENGLISH[sizeof(cmdlist)][E_BINTREE_INPUT];
	for( new i = 0 ; i < sizeof(cmdlist) ; i++ )
	{
		//한글부터
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Cmd] );
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_POINTER] = i;
		//영어
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Func] );
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_POINTER] = i;
	}
	Bintree_Generate( TREE_CMDLIST_HANGUL, CMD_HASH_HANGUL, sizeof(cmdlist) );
	Bintree_Generate( TREE_CMDLIST_ENGLISH, CMD_HASH_ENGLISH, sizeof(cmdlist) );

	//정적 타이머 구동
	if( USE_ANTI_CMDFLOOD) StaticTimer[CmdFlood] = SetTimer("ResetCmdFlood", CMDFLOOD_UNIT_TIME * 1000, 1);
	if( USE_ANTI_CHATFLOOD ) StaticTimer[ChatFlood] = SetTimer("ResetChatFlood", CHATFLOOD_UNIT_TIME * 1000, 1);
	if( USE_PINGCHECK && RESET_HIGHPING_TICK ) 
		StaticTimer[ResetPing] =  SetTimer("ResetPingCheck", RESET_HIGHPING_TICK * 1000, 1);
	SetTimer("Start_OneSecTimer_1", 480, 0);
	SetTimer("Start_OneSecTimer_2", 980, 0);
	
	//업데이트 확인
#if SAMP03b
	rcmd_checkupdate(NULL);
#endif
	return 1; /* Loading Complete! */
}
//==========================================================
public OnFilterScriptExit()
{
	//필터스크립트를 종료하기 전에 필요한 작업 수행
	if( SAVE_CURRRENT_CONFIG ) SaveUserConfigs();
	if( DUMPEXIT )
	{
		print("[rcon] 덤프 파일을 생성하고 있습니다...");
		CreateDump();
	}
	return 1;
}
//==========================================================
public OnGameModeExit()
{
	//모드가 종료될 때 필요한 작업 수행
	for( new i = 0 ; i < NUM_PLAYERS ; i++ ) PLAYER_SPAWNED[pITT[i]] = 0; //플레이어 스폰정보 초기화
	if(SERVER_LOCKED) //서버가 잠겨있는 경우
	{
		//FIXME : 15초가 적당합니까?
		print("[rcon] 모드가 변경되었습니다. 15초 후에 다시 서버가 잠깁니다.");
		SendAdminMessageAuth(AUTH_NOTICES, COLOR_IVORY, "* 모드가 변경되었습니다. 15초 후에 다시 서버가 잠깁니다.");
		SERVER_LOCKED = 0;
		SetTimer("ReLockServer", 15000, 0);
	}
	return 1;
}
//==========================================================
public OnPlayerPrivmsg(playerid, recieverid, text[])
{
	new str[193];

	//욕필터 감지
	if(USE_YELLFILTER && !CONSOLE)
	{
		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] 금지어가 감지되었습니다 - %s", YELLS[s]);
				for(new i = pos, j = pos + strlen(YELLS[s]); i < j; i++) text[i] = '+';
			}
		}
	}

	//귓속말 도배방지 기능
	if( !CONSOLE )
	{
		if( IS_CHAT_FORBIDDEN[playerid] )
		{
			PLAYER_PMABUSE_TIMES[playerid]++;
			if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)님이 플레이어를 귓말로 괴롭혀서 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)님이 플레이어를 귓말로 괴롭혀서 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			SendClientMessage(playerid, COLOR_RED, "* 채팅금지 중입니다. 계속해서 메세지 전송을 할 경우 강제 퇴장됩니다.");
			printf("[rcon] %s(%d)님은 벙어리 상태입니다.", GetPlayerNameEx(playerid), playerid);
			return 0;
		}

		if( USE_ANTI_CHATFLOOD )
		{
			CHATFLOOD_TIMES[playerid]++;
			if( CHATFLOOD_TIMES[playerid] >= CHATFLOOD_LIMIT )
			{
				PLAYER_PMABUSE_TIMES[playerid]++;
				if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
				{
					format( str, sizeof(str), "* %s(%d)님이 플레이어를 귓말로 괴롭혀서 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)님이 플레이어를 귓말로 괴롭혀서 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
					return 0;
				}
				format( str, sizeof(str), "PM from %s(%d): 더이상 귓말로 도배하지 않을게요. 죄송해요 ㅠ_ ㅠ", GetPlayerNameEx(playerid), playerid);
				SendClientMessage( playerid, COLOR_YELLOW, str );
				format( str, sizeof(str), "PM sent to %s: 더이상 귓말로 도배하지 않을게요. 죄송해요 ㅠ_ ㅠ", GetPlayerNameEx(recieverid));
				SendClientMessage( recieverid, COLOR_YELLOW, str );
				printf("[rcon] %s(%d)님이 귓속말 도배를 하여 도배방지가 작동했습니다.", GetPlayerNameEx(playerid), playerid);
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = CHATFLOOD_SHUTUP_TIME;
				return 0;
			}
		}
	}
	
	//메세지 보내기
	format(str,sizeof(str),"%s(%d) -> %s(%d): %s",CONSOLE? ("Admin"):(GetPlayerNameEx(playerid)),playerid,(recieverid==ADMIN_ID)? ("Admin"):(GetPlayerNameEx(recieverid)),recieverid,text);
	FixChars(str);
	SendAdminMessageAuth(AUTH_PMTRACE,COLOR_GREY,str);
	return 1;
}
//==========================================================
public OnPlayerText(playerid, text[])
{
	//대화형 명령체계
	if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID ) 
	{
		if( text[0] == '?' && !text[1] ) 
		{
			SendClientMessage( playerid, COLOR_RED, "* 취소되었습니다." );
			INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
			return 0;
		}
		new str[128];		
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
		CallLocalFunction( str, "isib", playerid, text, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
		return 0;
	}

	if( PERMANENT_ADMINSAY(	playerid) ) return !dcmd_say( playerid, text, CMD_SAY, NO_HELP ); //말모드 핸들링
	LAST_PLAYER_ID=playerid; // 마지막으로 채팅한 유저
	new str[128];
	
	if( IS_CHAT_FORBIDDEN[playerid] )
	{
		PLAYER_PMABUSE_TIMES[playerid]++;
		if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
		{
			format( str, sizeof(str), "* %s(%d)님이 채팅금지 상태에서 계속 도배를 하여 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
			SendClientMessageToAll( COLOR_RED, str );
			printf("[rcon] %s(%d)님이 채팅금지 상태에서 계속 도배를 하여 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
			if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
			return 0;
		}
		SendClientMessage(playerid, COLOR_RED, "* 채팅금지 중입니다. 계속해서 메세지 전송을 할 경우 강제 퇴장됩니다.");
		printf("[rcon] %s(%d)님은 벙어리 상태입니다.", GetPlayerNameEx(playerid), playerid);
		return 0;
	}

	if(USE_YELLFILTER)
	{

		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] 금지어가 감지되었습니다 - %s", YELLS[s]);
				format( str, sizeof(str), "* 금지어가 감지되었습니다. - %s", YELLS[s]);
				SendAdminMessageAuth( AUTH_NOTICES, COLOR_GREY, str );
				for(new i = pos, j = pos + strlen(YELLS[s]); i < j; i++) text[i] = '+';
			}
		}
	}

	if( USE_ANTI_CHATFLOOD )
	{
		CHATFLOOD_TIMES[playerid]++;
		if( CHATFLOOD_TIMES[playerid] >= CHATFLOOD_LIMIT )
		{
			PLAYER_PMABUSE_TIMES[playerid]++;
			if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)님이 계속 도배를 하여 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)님이 계속 도배를 하여 강제추방 되었습니다.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			format( str, sizeof(str), "%s(%d): 더이상 도배하지 않을게요. 죄송해요 ㅠ_ ㅠ", GetPlayerNameEx(playerid), playerid);
			FixChars(str);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			printf("[rcon] %s(%d)님이 도배를 하여 도배방지가 작동했습니다.", GetPlayerNameEx(playerid), playerid);
			PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = CHATFLOOD_SHUTUP_TIME;
			return 0;
		}
	}

	return 1;
}
//==========================================================
public OnPlayerUpdate(playerid)
{
	if(PLAYER_DESYNCED_TIMES[playerid]) PLAYER_DESYNCED_TIMES[playerid] = 0;
	return 1;
}
//==========================================================
public OnPlayerConnect(playerid)
{
    //iteration optimization
    pITT[NUM_PLAYERS] = playerid;
    pITT_INDEX[playerid] = NUM_PLAYERS;
    NUM_PLAYERS++;
    //connect routine
	ResetPlayerWeapons(playerid);
	PLAYER_SPAWNED[playerid] = 0;
	//시간 알려주기
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "오후";
	}
	else tmp = "오전";
	printf("[rcon] 현재 시각은 %s %2d시 %2d분 입니다.", tmp, h, m);
	//기본적인 정보 수집
	GetPlayerName( playerid, PLAYER_NAME[playerid], MAX_PLAYER_NAME );
	FixChars( PLAYER_NAME[playerid] );
	GetPlayerIp( playerid, PLAYER_IP[playerid], sizeof(PLAYER_IP[]) );

	//서버잠금의 경우
	if(SERVER_LOCKED)
	{
		new str[77];
		SendClientMessage(playerid, COLOR_RED, " Server is currently LOCKED. You can't join.");
		SendClientMessage(playerid, COLOR_RED, " 서버가 잠겨있어 접속이 불가능합니다.");
		format(str, sizeof(str), "* 서버가 잠겨있어 %s(%d)님의 접속요청을 거부했습니다.", GetPlayerNameEx(playerid), playerid);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] 서버가 잠겨있어 %s(%d)님의 접속요청을 거부했습니다.", GetPlayerNameEx(playerid), playerid);
		c_Kick(playerid);
		return 1;
	}

	//불량유저 점검
	if( USE_BADWARN )
	{
		h = GetTickCount( );
		
		if( CUR_BADP_POINT == 0 ) Bintree_Reset( TREE_BADPLAYER );
		new current_ip = fnv_hash( GetPlayerIpEx(playerid) );		
		new i = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		
		if ( i != BINTREE_NOT_FOUND && BAD_PLAYER_IP[i] != 0 )
		{
			//불량 유저이며, 강퇴당한 후 첫 접속인 경우
			if( h - BADKICKED_TIMESTAMP[i] < 5000 ) //존나빠른 재접속으로 인해 소비에트가  의심된다면
			{
				//씨밤쾅 좆까
				GameTextForPlayer( playerid, "~r~NO ~w~s~y~0~w~beit~n~~p~fuck", 60000, 3 );
				c_Kick( playerid );
				return 1;
			}
			BAD_PLAYER_IP[i] = 0;
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			new str[77];
			format( str, sizeof(str), "* 요주의 인물 %s(%d)님이 접속했습니다.", GetPlayerNameEx(playerid), playerid );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, str ); 
			print("[rcon] 요주의 인물이 접속했습니다.");
		}
	}

	PLAYER_CASH[playerid] = 0;
	ResetPlayerStatus(playerid);
	return 1;
}
//==========================================================
public OnPlayerRequestSpawn(playerid)
{
	//FIXME: 왜 이 작업을 하는지 모르겠습니다. 필터스크립트간 충돌이 날지도?
	ResetPlayerWeapons(playerid);
	return 1;
}
//==========================================================
public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		SetPlayerInterior( IS_PLAYER_SPECTATED[playerid], newinteriorid );
	}
	return 1;
}
//==========================================================
public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		if( newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER )
		{
			PlayerSpectateVehicle( IS_PLAYER_SPECTATED[playerid], GetPlayerVehicleID( playerid ) );
		}
		else if( oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER )
		{
			PlayerSpectatePlayer( IS_PLAYER_SPECTATED[playerid], playerid );
		}
	}
	return 1;
}
//==========================================================
public OnPlayerSpawn(playerid)
{
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* 플레이어가 살아났습니다. 감시가 시작될 때까지 기다려 주세요...." );
		TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 1 );
		PlayerSpectatePlayer( IS_PLAYER_SPECTATED[playerid], playerid );
		SetTimerEx( "SpectateTimer", 3000,0, "ii", IS_PLAYER_SPECTATED[playerid], playerid);
	}
	PLAYER_SPAWNED[playerid] = 1;
	return 1;
}
//==========================================================
public OnPlayerDeath(playerid, killerid, reason)
{
	PLAYER_SPAWNED[playerid] = 0;

	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		SendClientMessage( playerid, COLOR_ORANGE, "* 감시 모드가 종료되었습니다." );
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 0 );
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* 감시를 계속합니다. 플레이어가 다시 살아날때까지 기다려 주세요..." );
	}

	/*if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATING[IS_PLAYER_SPECTATED[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATED[playerid] = INVALID_PLAYER_ID;
	}*/

	return 1;
}
//==========================================================
public OnPlayerRequestClass(playerid, classid)
{
	PLAYER_SPAWNED[playerid] = 0;
	return 1;
}
//==========================================================
public OnPlayerCommandText(playerid, cmdtext[])
{
	if(!CONSOLE)
	{
		//command trace
		new str[160];
		format(str, sizeof(str), "%s(%d): %s", GetPlayerNameEx(playerid), playerid, cmdtext);
		FixChars(str);
		if(!IsCmdNeedToHide(cmdtext)) for(new i = 0; i < NUM_PLAYERS ; i++)
		if((IsPlayerAdmin(pITT[i]) || (IsPlayerSubAdmin(pITT[i]) && AuthorityCheck(pITT[i],AUTH_CMDTRACE))) && IS_HEAR_CMDTRACE[pITT[i]])
			SendClientMessage(pITT[i], COLOR_GREY, str);
		if( IS_HEAR_CMDTRACE[ ADMIN_ID ] ) printf("[type] [%s(%d)]: %s", GetPlayerNameEx(playerid), playerid, cmdtext);
		
		//대화형 명령체계
		if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID )
		{
			SendClientMessage( playerid, COLOR_RED, "* 대화형 명령체계가 작동중입니다. 사용중인 동작을 마친 후 사용하십시오.");
			SendClientMessage( playerid, COLOR_ORANGE, "* 동작을 취소하려면 ?을 입력하십시오.");
			return 1;
			/*
			if( cmdtext[1] == '?' && !cmdtext[2] ) 
			{
				SendClientMessage( playerid, COLOR_RED, "* 취소되었습니다." );
				INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
				return 1;
			}
			format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
			if ( !cmdtext[1] ) CallLocalFunction( str, "isib", playerid, NULL, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			else CallLocalFunction( str, "isib", playerid, cmdtext[1], _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			return 1; */
		}
			
		//명령어 도배 핸들링
		if( IS_CMD_FORBIDDEN[playerid] )
		{
			CMDFLOOD_STILL_TIMES[playerid]++;
			if( CMDFLOOD_STILL_TIMES[playerid] >= CMDFLOOD_STILL_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)님이 명령어 도배를 하여 강제 추방됩니다.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)님이 계속해서 명령어를 도배하여 강제추방 하였습니다.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
				return 1;
			}
			SendClientMessage( playerid, COLOR_RED, "* 명령어 사용이 제한되어 있습니다. 계속하여 명령어를 입력할 경우 추방됩니다." );
			return 1;
		}

		if( USE_ANTI_CMDFLOOD )
		{
			CMDFLOOD_TIMES[playerid]++;
			if( CMDFLOOD_TIMES[playerid] >= CMDFLOOD_LIMIT )
			{
				CMDFLOOD_STILL_TIMES[playerid]++;
				if( CMDFLOOD_STILL_TIMES[playerid] >= CMDFLOOD_STILL_LIMIT )
				{
					format( str, sizeof(str), "* %s(%d)님이 명령어 도배를 하여 강제 추방됩니다.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)님이 계속해서 명령어를 도배하여 강제추방 하였습니다.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
					return 1;
				}
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_CMDRESTRICT] = CMDFLOOD_FORBIDDEN_TIME;
				SendClientMessage( playerid, COLOR_RED, "* 명령어로 도배를 하여 명령어 사용이 제한됩니다." );
				printf("[rcon] %s(%d)님이 명령어 도배를 하여 명령어 사용을 제한하였습니다.", GetPlayerNameEx(playerid), playerid);
				return 1;
			}
		}
	}
	
	if( !cmdtext[1] ) return 0;
	
	//centralized command handling
	new length, hash, i, str[128];
	set( str, strtok( cmdtext[1], length ));
	hash = fnv_hash( str );
	
	//한글에서 먼저 검사
	i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
	if( i == BINTREE_NOT_FOUND ) //한글에 없음 영어에서 검사
	{
		i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
		if ( i == BINTREE_NOT_FOUND ) return 0; //명령어가 없음
	}
	//strtok 보정
	if( cmdtext[length] == ' ' ) length --;
	length++;
	
	//권한이 필요없거나, 콘솔이거나, 운영자이거나, 권한을 갖춘 부운영자의 경우 스킵
	if( cmdlist[Cmdorder:i][Required_Auth] != AUTH_NONE && !CONSOLE && !IsPlayerAdmin( playerid )
		&& !AuthorityCheck(playerid,cmdlist[Cmdorder:i][Required_Auth]) )
	{
		//어떤 것에도 해당하지 않음. 권한 없음 오류 메세지를 출력
		cmdtext[length] = EOS;
		format( str, sizeof(str), "* 명령어 '%s'을(를) 사용할 권한이 없습니다. 운영자에게 문의하세요.", cmdtext );
		SendClientMessage( playerid, COLOR_RED, str );
		return 1;
	}
	
	//함수 호출
	format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
	if( cmdtext[length] == 32 && cmdtext[length+1] != EOS )	CallLocalFunction( str, "isib", playerid, cmdtext[length+1], i, NO_HELP );
	else CallLocalFunction( str, "isib", playerid, NULL, i, NO_HELP );
	return 1;
}
//==========================================================
public OnPlayerDisconnect(playerid, reason)
{
	//iteration optimization
	NUM_PLAYERS--; //접속중인 플레이어 수 정정
	if( NUM_PLAYERS )
	{
	    //나간 플레이어의 반복문을 맨 뒤의 플레이어 번호로 채움 ( TRIM )
		pITT[ pITT_INDEX[playerid] ] = pITT[ NUM_PLAYERS ];
		//맨 뒤의 플레이어가 속한 슬롯을 나간 플레이어의 슬롯으로 지정
		pITT_INDEX[ pITT[ NUM_PLAYERS ] ] = pITT_INDEX[playerid];
	}
	//플레이어 변수 초기화
	pITT_INDEX[ playerid ] = -1;
	//votekick check
	new str[128];
	if( VOTEKICK_REMAINTIME > 0 && VOTEKICK_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)님이 게임을 나가 투표가 중단됩니다.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)님이 게임을 나가 투표가 중단됩니다.", GetPlayerNameEx( playerid ), playerid );
		VOTEKICK_REMAINTIME = 0;
		VOTEKICK_TICK = 0;
	}
	if( VOTEKICK_REMAINTIME > 0 && VOTEBAN_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)님이 게임을 나가 투표가 중단됩니다.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)님이 게임을 나가 투표가 중단됩니다.", GetPlayerNameEx( playerid ), playerid );
		VOTEBAN_REMAINTIME = 0;
		VOTEBAN_TICK = 0;
	}

    //불량 유저의 IP 기록
	if( reason == 2 )
	{
		static full;
		
		if( CUR_BADP_POINT == MAX_BAD_PLAYERS )
		{
			//가득 차면 매번 리소트를 해주어야 하나?
			//아니다. 그냥 삭제하고 다시 바꾸면 된다. 그때부터는 유지 관리만 한다. 매번 만들지 않고..
			full = 1;
			CUR_BADP_POINT = 0;
		}		
		
		new current_ip = fnv_hash( GetPlayerIpEx( playerid ) );
		new ptr = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		if( ptr != BINTREE_NOT_FOUND )
		{
			//같은 플레이어가 또 강퇴당하는 경우 ..
			//플래그를 세우고, 강퇴당한 시각을 기록한다.
			BAD_PLAYER_IP[ptr] = current_ip;
			BADKICKED_TIMESTAMP[ptr] = GetTickCount( );
		}
		else if( full )
		{
			// 이제 균형따윈 없다. 유지관리 모드로 전환
			ptr = 0;
			Bintree_FindValue( TREE_BADPLAYER, BAD_PLAYER_IP[CUR_BADP_POINT], _, ptr );
			Bintree_Delete ( TREE_BADPLAYER, ptr, 1 );
			
			BAD_PLAYER_IP[CUR_BADP_POINT] = current_ip;
			BADKICKED_TIMESTAMP[CUR_BADP_POINT] = GetTickCount( );
			
			Bintree_Add( TREE_BADPLAYER, CUR_BADP_POINT, BAD_PLAYER_IP[CUR_BADP_POINT], sizeof(TREE_BADPLAYER) - 1 );
			format( str, sizeof(str), "* 불량유저 확인용 IP테이블이 가득 찼습니다. 관리자에게 문의하세요" );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
			print("[rcon] 불량유저 확인용 IP테이블이 가득 찼습니다. 오래된 불량 유저부터 차례대로 삭제합니다." );			
		}
		else //가득 차지 않음. 매번 균형잡힌 트리를 만들어준다.
		{
			BAD_PLAYER_IP[CUR_BADP_POINT] = current_ip;
			BADKICKED_TIMESTAMP[CUR_BADP_POINT] = GetTickCount( );
			static BADPLAYER_TABLES[MAX_BAD_PLAYERS][E_BINTREE_INPUT];
			BADPLAYER_TABLES[CUR_BADP_POINT][E_BINTREE_INPUT_VALUE] = current_ip;
			BADPLAYER_TABLES[CUR_BADP_POINT][E_BINTREE_INPUT_POINTER] = CUR_BADP_POINT;
			Bintree_Reset( TREE_BADPLAYER );
			CUR_BADP_POINT++;
			Bintree_Generate( TREE_BADPLAYER, BADPLAYER_TABLES, CUR_BADP_POINT );		
		}		
	}
	//현재시간 알림
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "오후";
	}
	else tmp = "오전";
	printf("[rcon] 현재 시각은 %s %2d시 %2d분 입니다.", tmp, h, m);
	//변수 수정
	PLAYER_SPAWNED[playerid] = 0;
	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_ORANGE, "* 해당 플레이어가 게임에서 나가 감시모드를 종료합니다.");
		TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 0 );
		IS_PLAYER_SPECTATING[IS_PLAYER_SPECTATED[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATED[playerid] = INVALID_PLAYER_ID;
	}
	return 1;
}
//==========================================================
public OnRconCommand(cmd[])
{
	new cmds[129];
	//지정자로 인한 서버 크래시 방지
	for( new i = 0, len = strlen( cmd ) ; i < len ; i++ ) if( cmd[i] == '%' ) cmd[i] = '#';
	
	//대화형 명령체계
	if( INTERACTIVE_COMMAND[ADMIN_ID] != CMD_INVALID )
	{
		if( cmd[0] == '?' && !cmd[1] ) 
		{
			print( "[rcon] 취소되었습니다." );
			INTERACTIVE_COMMAND[ADMIN_ID] = CMD_INVALID;
			return 1;
		}
		new str[128];
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[ADMIN_ID]][Func] );
		CallLocalFunction( str, "isib", ADMIN_ID, cmd, _:INTERACTIVE_COMMAND[ADMIN_ID], NO_HELP );
		return 1;
	}
	
	//말모드에 대한 핸들링
	if( PERMANENT_ADMINSAY(ADMIN_ID) && cmd[0] != '!') return dcmd_say( ADMIN_ID, cmd, CMD_SAY, NO_HELP );
	else
	{
		if ( cmd[0] == '!' ) for( new i = 0, j = strlen( cmd ) ; i < j ; i++ ) cmds[i] = cmd[i];
		else for( new i = strlen( cmd ) ; i > 0 ; i-- ) cmds[i] = cmd[i -1];
	}
	cmds[0] = '/';

	//invoke command
	rcmd("도움말",6,help);
	rcmd("help",4,help);
	rcmd("help2",5,help2);
	
	//rcon-unique command
	rcmd("rcon",4,rcon);
	rcmd("update",6,checkupdate);
	rcmd("업데이트",8,checkupdate);
	
	/* deprecated */
	//rcmd("shelp",5,shelp);
	//rcmd("readcmd",7,readcmd);
	//rcmd("명령어읽기",10,readcmd);	
	

	return OnPlayerCommandText(ADMIN_ID, cmds);
}
//==========================================================
#if SAMP03a
//==========================================================
public OnRconLoginAttempt( ip[], password[], success )
{
	#define R_IP_HASH 0
	#define R_FAILED_ATTEMPT 1
	#define R_PLAYER_ID 2
	static iptables[128][3], ip_index, BinaryTree:TREE_IPTABLES<sizeof(iptables)>;
	
	//IP를 찾을 준비를 하자 ㅋㅋ
	new current_ip, playerid = INVALID_PLAYER_ID, str[128], i;
	current_ip = fnv_hash (ip);
	if( ip_index == 0 ) Bintree_Reset( TREE_IPTABLES );

	i = Bintree_FindValue( TREE_IPTABLES, current_ip ); //IP 테이블 목록을 검색
	if( i != BINTREE_NOT_FOUND )
	{
		//기존 목록에 존재하는 경우
		if( iptables[i][R_IP_HASH] == current_ip )
		{
			//성공했음. 실패값 초기화하고 값을 넘겨준다.
			if( success )
			{
				iptables[i][R_FAILED_ATTEMPT] = 0;
				return 1;
			}
			//실패리스트 추가. 아이디 기록
			iptables[i][R_FAILED_ATTEMPT]++;
			playerid = iptables[i][R_PLAYER_ID];
			//설정파일에서 정한 한도를 넘어가면
			if( iptables[i][R_FAILED_ATTEMPT] >= MAX_RCONLOGIN_ATTEMPT )
			{
				if( playerid == INVALID_PLAYER_ID)
				{
					format( str, sizeof(str), "* ip %s에서 잘못된 rcon 로그인 한도를 초과하여 ip밴을 수행합니다.", ip );
					SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
					printf("[rcon] ip %s에서 잘못된 rcon 로그인 한도를 초과하여 ip밴을 수행합니다.", ip );
					format( str, sizeof(str),"banip %s", ip );
					SendRconCommand( str );
					return 1;
				}
				//설정파일에서 정한 조치에 따라 처리
				switch( POLICY_RCON_LOGINFAIL_INTERNAL )
				{
					case 1:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE KICKED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* 계속해서 잘못된 로그인 시도를 하여 추방되었습니다." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~y~kicked", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)님이 잘못된 rcon 로그인 한도를 초과하여 추방됩니다.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)님이 잘못된 rcon 로그인 한도를 초과하여 추방됩니다.", GetPlayerNameEx(playerid), playerid );
						c_Kick(playerid);
					}
					case 2:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE BANNED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* 계속해서 잘못된 로그인 시도를 하여 영구추방되었습니다." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~r~BANNED", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)님이 잘못된 rcon 로그인 한도를 초과하여 영구추방됩니다.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)님이 잘못된 rcon 로그인 한도를 초과하여 영구추방됩니다.", GetPlayerNameEx(playerid), playerid );
						c_Ban(playerid);						
					}
				}
				return 1;
			}
			//한도는 넘어가지 않음. 운영자에게 잘못된 시도에 대해 알림
			if( playerid == INVALID_PLAYER_ID )
			{
				format( str, sizeof(str), "* ip %s에서 %d번째로 rcon 로그인 시도에 실패했습니다.", ip, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] ip %s에서 %d번째로 rcon 로그인 시도에 실패했습니다.", ip, iptables[i][R_FAILED_ATTEMPT] );
			}
			else
			{
				format( str, sizeof(str), "* %s(%d)님이 %d번째로 rcon 로그인 시도에 실패했습니다.",  GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] %s(%d)님이 %d번째로 rcon 로그인 시도에 실패했습니다.", GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
			}
			return 1;
		}
	}
	
	//리스트에 없음. 로그인 시도 성공. 그냥 돌려준다.
	if( success ) return 1;
	//리스트에 없음. 첫 로그인 시도 실패. 목록에 등재.
	//그전에, 테이블이 가득 찼는지 확인한다.
	static full;
	
	if( ip_index == sizeof(iptables) ) 
	{
		full = 1;
		ip_index = 0;
	}
	
	for( i = 0; i < NUM_PLAYERS ; i++ )//우선 플레이어가 접속중인지 찾는다.
	{
		if( !strcmp(GetPlayerIpEx(pITT[i]), ip, false) )
		{
			playerid = pITT[i]; //접속한 플레이어가 로그인 시도함.
			break;
		}
	}
	//Bintree_Add( TREE_IPTABLES, ip_index, current_ip, ip_index ); //just add;
	if( full )
	{
		//가득 찼으면 유지관리 실행
		new ptr;
		Bintree_FindValue( TREE_IPTABLES, iptables[ip_index][R_IP_HASH], _, ptr );
		Bintree_Delete( TREE_IPTABLES, ptr, 1 );
		
		iptables[ip_index][R_IP_HASH] = current_ip;
		iptables[ip_index][R_PLAYER_ID] = playerid; 
		iptables[ip_index][R_FAILED_ATTEMPT] = 1;
		
		Bintree_Add( TREE_IPTABLES, ip_index, current_ip, sizeof(TREE_IPTABLES) -1 );
		ip_index++;
		
		format( str, sizeof(str), "* RCON 로그인 방어용 IP테이블이 가득 찼습니다. 관리자에게 문의하세요", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		print("[rcon] RCON 로그인 방어용 IP테이블이 가득 찼습니다. 오래된 로그인 시도부터 차례대로 삭제합니다." );
	}
	else
	{
		//OR, sort and add data
		iptables[ip_index][R_IP_HASH] = current_ip;
		iptables[ip_index][R_PLAYER_ID] = playerid;
		iptables[ip_index][R_FAILED_ATTEMPT] = 1;
		static TABLE_INFO[sizeof(iptables)][E_BINTREE_INPUT];
		TABLE_INFO[ip_index][E_BINTREE_INPUT_VALUE] = current_ip;
		TABLE_INFO[ip_index][E_BINTREE_INPUT_POINTER] = ip_index;	
		Bintree_Reset( TREE_IPTABLES );
		ip_index++;
		Bintree_Generate( TREE_IPTABLES, TABLE_INFO, ip_index );
	}
	
	
	if( playerid == INVALID_PLAYER_ID )
	{
		//플레이어가 없음. ip밴을 준비한다.
		format( str, sizeof(str), "* ip %s에서 처음으로 rcon 로그인 시도에 실패했습니다.", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, "* 요청이 반복되면 ip밴을 수행합니다." );
		printf("[rcon] ip %s에서 처음으로 rcon 로그인 시도에 실패했습니다.", ip );
		print("[rcon] 요청이 반복되면 ip밴을 수행합니다.");
		return 1;
	}
	else 
	{
		//메세지 보내기
		format( str, sizeof(str), "* %s(%d)님이 처음으로 rcon 로그인 시도에 실패했습니다.", GetPlayerNameEx(playerid), playerid );
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
		printf("[rcon] %s(%d)님이 처음으로 rcon 로그인 시도에 실패했습니다.", GetPlayerNameEx(playerid), playerid );
	}
	#undef R_IP_HASH
	#undef R_FAILED_ATTEMPT
	#undef R_PLAYER_ID
	return 1;
}
//==========================================================
public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if( source != CLICK_SOURCE_SCOREBOARD ) return 0;
	
	if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID && INTERACTIVE_STATE[playerid] == 0 ) 
	{
		new str[128];
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
		CallLocalFunction( str, "isib", playerid, RetStr(clickedplayerid), _:INTERACTIVE_COMMAND[playerid], NO_HELP );
		return 1;
	}
	
	DIALOG_CLICKED_PLAYER[playerid]=clickedplayerid;
	ShowPlayerDialogs( playerid, (IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid))? (DIALOG_ADMIN_MAIN):(DIALOG_USER_MAIN) );
	return 1;
}
//==========================================================
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	//Admin Click
	if( IsPlayerAdmin(playerid) || IsPlayerSubAdmin(playerid) )
	{
		switch( dialogid )
		{
			gcmd(DIALOG_ADMIN_MAIN,adminmain); //기본 명령어 셋트
			gcmd(DIALOG_ADMIN_KICK,kick); //강제추방
			gcmd(DIALOG_ADMIN_BAN,ban); //영구추방
			gcmd(DIALOG_PM,superpm); //귓속말보내기
			gcmd(DIALOG_ADMIN_WITH,with); //이동하기
			gcmd(DIALOG_ADMIN_CALL,call); //소환하기
			gcmd(DIALOG_ADMIN_KILL,kill); //사살
			gcmd(DIALOG_ADMIN_SETHP,sethp); //체력설정
			gcmd(DIALOG_ADMIN_INFINITE,infinite); //체무한
			gcmd(DIALOG_ADMIN_MAKECASH,makecash); //돈주기
			gcmd(DIALOG_ADMIN_FORFEIT,forfeit); //돈뺏기
			gcmd(DIALOG_ADMIN_SETCASH,setcash); //돈설정
			gcmd(DIALOG_ADMIN_SETSCORE,setscore); //스코어설정
			gcmd(DIALOG_ADMIN_GIVEWP,givewp); //무기주기
			gcmd(DIALOG_ADMIN_DISARM,disarm); //무기박탈
			gcmd(DIALOG_ADMIN_FREEZE,freeze); //프리즈
			gcmd(DIALOG_ADMIN_UNFREEZE,unfreeze); //프리즈 해제
			gcmd(DIALOG_ADMIN_ARMOR,armor); //아머
			gcmd(DIALOG_ADMIN_INFARMOR,infarmor); //아머무적
			gcmd(DIALOG_ADMIN_SPAWNCAR,spawncar); //차소환
			gcmd(DIALOG_ADMIN_SDROP,sdrop); //차에서 내리기
			gcmd(DIALOG_ADMIN_CARENERGY,carenergy); //차에너지 변경
			gcmd(DIALOG_ADMIN_JETPACK,jetpack); //제트팩
			gcmd(DIALOG_ADMIN_MUSIC,music); //음악듣기
			gcmd(DIALOG_ADMIN_MUSICOFF,musicoff); //음악끄기
			gcmd(DIALOG_ADMIN_BOMB,bomb); //뇌 터트리기
			gcmd(DIALOG_ADMIN_SHUTUP,shutup); //채팅 금지
			gcmd(DIALOG_ADMIN_UNSHUT,unshut); //채금 해제
			gcmd(DIALOG_ADMIN_CHANGENICK,changenick); //닉바꾸기
			gcmd(DIALOG_ADMIN_SPECTATE,spectate); //감시하기
			gcmd(DIALOG_ADMIN_SUBADMIN,subadmin); //부운영자 임명
			gcmd(DIALOG_ADMIN_DELSUB,delsub); //부운영자 박탈
			gcmd(DIALOG_ADMIN_FIND,find); //이 유저의 정보 보기
		}
		return 0;
	}
	//user main
	switch( dialogid )
	{
		gcmd(DIALOG_USER_MAIN,usermain); //기본 명령어 셋트
		gcmd(DIALOG_USER_VOTEKICK,votekick); //강제추방
		gcmd(DIALOG_USER_VOTEBAN,voteban); //영구추방
		gcmd(DIALOG_PM,superpm); //귓속말보내기
	}
	return 0;
}
//==========================================================
// Gui Command
//==========================================================
dialog_adminmain( playerid, response, listitem, inputtext[] ) //메인 핸들러
{
	//취소한 경우
	if( !response ) return 1;
	
	switch( listitem )
	{
	    case 0: //Kick Player
	    {
	        Auth_Check(AUTH_CMD_KICK);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP에 버그가 있으므로 한글은 입력하지 마시기 바랍니다.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KICK ); //확인 메세지 띄우기
   	    }
	    case 1: //Ban Player
		{
		    Auth_Check(AUTH_CMD_BAN);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP에 버그가 있으므로 한글은 입력하지 마시기 바랍니다.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_BAN );//확인 메세지 띄우기
		}
		case 2: //메세지 보내기
	    {
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP에 버그가 있으므로 한글은 입력하지 마시기 바랍니다.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
		case 3:
		{
		    Auth_Check(AUTH_CMD_WITH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_WITH ); //이동하기
		}
		case 4:
		{
		    Auth_Check(AUTH_CMD_CALL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_CALL ); //소환하기
		}
		case 5:
		{
		    Auth_Check(AUTH_CMD_KILL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KILL ); //사살하기
		}
		case 6:
		{
			Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP ); //체력 변경하기
		}
		case 7:
		{
		    Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFINITE ); //무적으로 만들기
		}
		case 8:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH ); //돈주기
		}
		case 9:
		{
            Auth_Check(AUTH_CMD_FORFEIT);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FORFEIT ); //돈뺏기
		}
		case 10:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH ); //돈설정
		}
		case 11:
		{
		    Auth_Check(AUTH_CMD_SETSCORE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE ); //스코어설정
		}
		case 12:
		{
            Auth_Check(AUTH_CMD_GIVEWEAPON);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_GIVEWP ); //무기주기
		}
		case 13:
		{
		    Auth_Check(AUTH_CMD_DISARM);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_DISARM ); //무기뼾殮�
		}
		case 14:
		{
		    Auth_Check(AUTH_CMD_FREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FREEZE ); //프리즈
		}
		case 15:
		{
		    Auth_Check(AUTH_CMD_UNFREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNFREEZE ); //프리즈 해제
		}
		case 16:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR ); //아머
		}
		case 17:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFARMOR ); //아머무적
		}
		case 18:
		{
		    Auth_Check(AUTH_CMD_SPAWNCAR);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPAWNCAR ); //차량소환
		}
		case 19:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SDROP ); //차에서내리기
		}
		case 20:
		{
		    Auth_Check(AUTH_CMD_CARENERGY);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY ); //차에너지 점검
		}
		case 21:
		{
		    Auth_Check(AUTH_CMD_JETPACK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_JETPACK ); //제트팩 주기
		}
		case 22:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSIC ); //소리듣기
		}
		case 23:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSICOFF ); //소리끄기
		}
		case 24:
		{
		    Auth_Check(AUTH_CMD_BOMB);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_BOMB ); //폭탄 터트리기
		}
		case 25:
		{
		    Auth_Check(AUTH_CMD_SHUTUP);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SHUTUP ); //채팅 금지하기
		}
		case 26:
		{
		    Auth_Check(AUTH_CMD_UNSHUT);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNSHUT ); //채금 해제하기
		}
		case 27:
		{
		    Auth_Check(AUTH_CMD_CHANGENICK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK ); //닉네임 변경하기
		}
        case 28:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPECTATE ); //사용자 감시하기
		}
		case 29:
		{
		    Auth_Check(AUTH_CMD_SETSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SUBADMIN ); //부운영자 임명하기
		}
		case 30:
		{
		    Auth_Check(AUTH_CMD_DELSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_DELSUB ); //부운영자 박탈하기
		}
		case 31:
		{
			Auth_Check(AUTH_CMD_USERINFO);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FIND ); //이 유저의 정보 보기
		}
		default: //버그 탐지
		{
			new str[128];
			format( str, sizeof(str), "* 버그 메뉴창 스트리밍(%d): %s", listitem, inputtext );
			SendClientMessage( playerid, COLOR_RED, str );
		    return 1;
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_kick( playerid, response, listitem, inputtext[] ) //강제퇴장 경고 메세지
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //강제퇴장 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_skick( playerid, str, CMD_KICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_ban( playerid, response, listitem, inputtext[] ) //영구추방 경고 메세지
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //영구추방 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sban( playerid, str, CMD_BAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_with( playerid, response, listitem, inputtext[] ) //출두
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //출두 명령어 보내기
	dcmd_with( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_WITH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_call( playerid, response, listitem, inputtext[] ) //소환
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //소환 명령어 보내기
	dcmd_call( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_CALL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_kill( playerid, response, listitem, inputtext[] ) //소환
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //사살 명령어 보내기
	dcmd_skill( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SKILL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_sethp( playerid, response, listitem, inputtext[] ) //소환
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP );
	}
    //체력설정 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sethp( playerid, str, CMD_SETHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infinite( playerid, response, listitem, inputtext[] ) //소환
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //체력무한 명령어 보내기
	dcmd_infinite( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFINITE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_makecash( playerid, response, listitem, inputtext[] ) //돈주기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH );
	}
    //돈주기 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_mcash( playerid, str, CMD_MCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_forfeit( playerid, response, listitem, inputtext[] ) //돈뺏기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //돈몰수 명령어 보내기
	dcmd_forfeit( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FORFEIT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_setcash( playerid, response, listitem, inputtext[] ) //돈설정
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH );
	}
    //돈설정 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_setcash( playerid, str, CMD_SETCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_setscore( playerid, response, listitem, inputtext[] ) //스코어 설정
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE );
	}
    //스코어설정 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_score( playerid, str, CMD_SCORE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_givewp( playerid, response, listitem, inputtext[] ) //무기주기
{
	#define GIVEWP_STAGE_TYPE 0
	#define GIVEWP_STAGE_TYPECUSTOM 1
	#define GIVEWP_STAGE_AMMOAMOUNT 2
	#define GIVEWP_STAGE_AREYOUSURE 3
	static stage, weaponid, ammo;
	//취소한 경우
	if( !response )
	{
		if( stage == GIVEWP_STAGE_TYPE ) ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
		else
		{
		    stage = GIVEWP_STAGE_TYPE;
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_GIVEWP );
		}
	    return 1;
	}
	
	//기타 무기를 선택한 경우
	if( stage == GIVEWP_STAGE_TYPE && listitem == sizeof(WEAPON_STORAGE) )
	{
		stage = GIVEWP_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "제공할 무기를 선택하십시오.",
			"제공할 무기의 번호를 지정하십시오.", "확인", "뒤로" );
		return 1;
	}
	
	//무기번호를 골랐다. 총알수를 계산
	if( stage == GIVEWP_STAGE_TYPE || stage == GIVEWP_STAGE_TYPECUSTOM )
	{
	    //무기번호 저장
	    if( stage == GIVEWP_STAGE_TYPE ) weaponid = WEAPON_STORAGE[listitem][weapon_id];
	    else weaponid = strval(inputtext);
	    //총알수 묻기
	    stage = GIVEWP_STAGE_AMMOAMOUNT;
	    ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "총알 수를 지정하십시오.",
			"기록하지 않는 경우 3000발을 제공합니다.", "확인", "뒤로" );
	    return 1;
	}
	
	//총알수를 골랐다. 최종확인
	new str[128];
	if( stage == GIVEWP_STAGE_AMMOAMOUNT )
	{
	    //총알수 저장
		ammo = strval(inputtext);
		if( !ammo ) ammo = 3000;
		//최종확인
		stage = GIVEWP_STAGE_AREYOUSURE;
		GetWeaponName( weaponid, str, sizeof(str) );
		format( str, sizeof(str), "다음 플레이어에게 무기를 줍니다: %s(%d).\n 무기번호: %d(%s), 총알수 : %d발.\n계속하시겠습니까?",
			GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid],
			weaponid, str, ammo );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		return 1;
	}

    //무기주기 명령어 보내기
	format( str, sizeof(str), "%d %d %d", DIALOG_CLICKED_PLAYER[playerid], weaponid, ammo );
	dcmd_givewp( playerid, str, CMD_GIVEWP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
	stage = GIVEWP_STAGE_TYPE;
	#undef GIVEWP_STAGE_TYPE
	#undef GIVEWP_STAGE_TYPECUSTOM
	#undef GIVEWP_STAGE_AMMOAMOUNT
	#undef GIVEWP_STAGE_AREYOUSURE
	return 1;
}
//==========================================================
dialog_disarm( playerid, response, listitem, inputtext[] ) //무기뺏기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //무기몰수 명령어 보내기
	dcmd_disarm( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DISARM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_freeze( playerid, response, listitem, inputtext[] ) //프리즈
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //무기몰수 명령어 보내기
    new str[128];
    format( str, sizeof(str), "%d",DIALOG_CLICKED_PLAYER[playerid] );
	if( inputtext[0] ) format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_freeze( playerid, str, CMD_FREEZE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_unfreeze( playerid, response, listitem, inputtext[] ) //언프리즈
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //프리즈 해제 명령어 보내기
	dcmd_unfrz( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNFRZ, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_armor( playerid, response, listitem, inputtext[] ) //아머 변경
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR );
	}
    //체력설정 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_armor( playerid, str, CMD_ARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infarmor( playerid, response, listitem, inputtext[] ) //아머무적
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //체력무한 명령어 보내기
	dcmd_infarmor( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_spawncar( playerid, response, listitem, inputtext[] ) //차소환
{
	#define SPAWNCAR_STAGE_TYPE 0
	#define SPAWNCAR_STAGE_TYPECUSTOM 1
	#define SPAWNCAR_STAGE_AREYOUSURE 2
	static stage, modelid;
	//취소한 경우
	if( !response )
	{
		if( stage == SPAWNCAR_STAGE_TYPE ) ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
		else
		{
		    stage = SPAWNCAR_STAGE_TYPE;
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPAWNCAR );
		}
	    return 1;
	}

	//기타 차량을 선택한 경우
	if( stage == SPAWNCAR_STAGE_TYPE && listitem == sizeof(VEHICLE_STORAGE) )
	{
		stage = SPAWNCAR_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_INPUT, "제공할 차량을 선택하십시오.",
			"제공할 차량의 번호를 지정하십시오.", "확인", "뒤로" );
		return 1;
	}

	//차량번호를 골랐다. 최종확인
	new str[128];
	if( stage == SPAWNCAR_STAGE_TYPE || stage == SPAWNCAR_STAGE_TYPECUSTOM )
	{
	    //차량번호 저장
	    if( stage == SPAWNCAR_STAGE_TYPE ) modelid = VEHICLE_STORAGE[listitem][weapon_id];
		else modelid = strval(inputtext);
		//최종확인
		stage = SPAWNCAR_STAGE_AREYOUSURE;
		format( str, sizeof(str), "다음 플레이어에게 차량을 줍니다: %s(%d).\n차량 모델: %d.\n계속하시겠습니까?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], modelid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		return 1;
	}

    //차량소환 명령어 보내기
	format( str, sizeof(str), "%d %d", DIALOG_CLICKED_PLAYER[playerid], modelid );
	dcmd_spcar( playerid, str, CMD_SPCAR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
	stage = SPAWNCAR_STAGE_TYPE;
	#undef SPAWNCAR_STAGE_TYPE
	#undef SPAWNCAR_STAGE_TYPECUSTOM
	#undef SPAWNCAR_STAGE_AREYOUSURE
	return 1;
}
//==========================================================
dialog_sdrop( playerid, response, listitem, inputtext[] ) //차랑에서 내리기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //차량에서 내리기 명령어 보내기
	dcmd_drop( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DROP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_carenergy( playerid, response, listitem, inputtext[] ) //차에너지 변경
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY );
	}
    //차에너지 변경 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_carhp( playerid, str, CMD_CARHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_jetpack( playerid, response, listitem, inputtext[] ) //제트팩 주기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //제트팩 주기 명령어 보내기
	dcmd_jpack( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_JPACK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_music( playerid, response, listitem, inputtext[] ) //음악 재생
{
	#define MUSIC_STAGE_TYPE 0
	#define MUSIC_STAGE_TYPECUSTOM 1
	#define MUSIC_STAGE_AREYOUSURE 2
	static stage, soundid;
	//취소한 경우
	if( !response )
	{
		if( stage == MUSIC_STAGE_TYPE ) ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
		else
		{
		    stage = MUSIC_STAGE_TYPE;
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSIC );
		}
	    return 1;
	}

	//기타 차량을 선택한 경우
	if( stage == MUSIC_STAGE_TYPE && listitem == sizeof(MUSIC_STORAGE) )
	{
		stage = MUSIC_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_INPUT, "재생할 음악을 선택하십시오.",
			"재생할 음악의 번호를 지정하십시오.", "확인", "뒤로" );
		return 1;
	}

	//소리번호를 골랐다. 최종확인
	new str[128];
	if( stage == MUSIC_STAGE_TYPE || stage == MUSIC_STAGE_TYPECUSTOM )
	{
	    //차량번호 저장
	    if( stage == MUSIC_STAGE_TYPE ) soundid = MUSIC_STORAGE[listitem][weapon_id];
		else soundid = strval(inputtext);
		//최종확인
		stage = MUSIC_STAGE_AREYOUSURE;
		format( str, sizeof(str), "다음 플레이어에게 음악을 재생합니다: %s(%d).\n소리 번호: %d.\n계속하시겠습니까?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], soundid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		return 1;
	}

    //음악재생 명령어 보내기
	format( str, sizeof(str), "%d %d", DIALOG_CLICKED_PLAYER[playerid], soundid );
	dcmd_sound( playerid, str, CMD_SOUND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
	stage = MUSIC_STAGE_TYPE;
	#undef MUSIC_STAGE_TYPE
	#undef MUSIC_STAGE_TYPECUSTOM
	#undef MUSIC_STAGE_AREYOUSURE
	return 1;
}
//==========================================================
dialog_musicoff( playerid, response, listitem, inputtext[] ) //소리끄기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //소리끄기 명령어 보내기
	dcmd_mute( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_MUTE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_bomb( playerid, response, listitem, inputtext[] ) //폭탄 터트리기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //폭탄 터트리기 명령어 보내기
	dcmd_bomb( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_BOMB, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_shutup( playerid, response, listitem, inputtext[] ) //채팅금지
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //채팅금지 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_shutup( playerid, str, CMD_SHUTUP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_unshut( playerid, response, listitem, inputtext[] ) //채금해제
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //채금해제 명령어 보내기
	dcmd_unshut( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNSHUT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_changenick( playerid, response, listitem, inputtext[] ) //닉바꾸기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* 값을 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK );
	}
    //닉바꾸기 명령어 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_chnick( playerid, str, CMD_CHNICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_spectate( playerid, response, listitem, inputtext[] ) //감시하기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //감시 명령어 보내기
	dcmd_spectate( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SPECTATE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_subadmin( playerid, response, listitem, inputtext[] ) //부운영자 임명
{
	#define SUBADMIN_STAGE_TYPE 0
	#define SUBADMIN_STAGE_AREYOUSURE 1
	static stage, authid;
	//취소한 경우
	if( !response )
	{
		if( stage == SUBADMIN_STAGE_TYPE ) ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
		else
		{
		    stage = SUBADMIN_STAGE_TYPE;
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SUBADMIN );
		}
	    return 1;
	}

	//권한을 골랐다. 최종확인
	new str[128];
	if( stage == SUBADMIN_STAGE_TYPE )
	{
	    //권한번호 저장
	    authid = listitem;
		//최종확인
		stage = SUBADMIN_STAGE_AREYOUSURE;
		format( str, sizeof(str), "다음 플레이어를 부운영자로 임명합니다: %s(%d).\n부여할 권한: %s.\n계속하시겠습니까?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], inputtext );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		return 1;
	}

    //부운영자 임명 명령어 보내기
	format( str, sizeof(str), "%d %d", DIALOG_CLICKED_PLAYER[playerid], authid );
	dcmd_subadmin( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SUBADMIN, NO_HELP );
	dcmd_chauth( playerid, str, CMD_CHAUTH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
	stage = SUBADMIN_STAGE_TYPE;
	#undef SUBADMIN_STAGE_TYPE
	#undef SUBADMIN_STAGE_AREYOUSURE
	return 1;
}
//==========================================================
dialog_delsub( playerid, response, listitem, inputtext[] ) //부운영자 박탈
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //부운영자 박탈 명령어 보내기
	dcmd_suspend( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SUSPEND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_find( playerid, response, listitem, inputtext[] ) //이 유저의 정보 보기
{
	//취소한 경우
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //정보보기 명령어 보내기
	dcmd_find( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FIND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_usermain( playerid, response, listitem, inputtext[] ) //사용자 메인 대화상자
{
	//취소한 경우
	if( !response ) return 1;

	switch( listitem )
	{
	    case 0: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEKICK ); //Kick Player
	    case 1: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEBAN );//Ban Player
		case 2: //메세지 보내기
	    {
			#if !SAMP03x
			SendClientMessage( playerid, COLOR_RED, "* SA-MP에 버그가 있으므로 한글은 입력하지 마시기 바랍니다.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_superpm( playerid, response, listitem, inputtext[] ) //귓속말
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    //입력하지 않은 경우
	if( !inputtext[0] )
	{
		SendClientMessage( playerid, COLOR_GREY, "* 메세지를 입력하여 주십시오.");
	    return ShowPlayerDialogs( playerid, DIALOG_PM );
	}
	//메세지 보내기
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_spm( playerid, str, CMD_SPM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_votekick( playerid, response, listitem, inputtext[] ) //사용자 강제추방 투표
{
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
	dcmd_vkick( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VKICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}
//==========================================================
dialog_voteban( playerid, response, listitem, inputtext[] ) //사용자 영구추방 투표
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    dcmd_vban( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VBAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}

//==========================================================
#endif /* SA-MP 0.3a의 다이얼로그 기능 사용 */
//==========================================================
// dcmd Command
//==========================================================
public dcmd_rchelp( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] 사용 가능한 명령어의 목록을 봅니다." );
			printf( "[help] %s [명령어 이름] 을 입력하면 해당 명령어의 도움말을 보여줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s, %s 출두", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
			format( str, sizeof(str), "* 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 설명: 사용 가능한 명령어의 목록을 봅니다." );
			format( str, sizeof(str), "* 설명: /%s [명령어 이름] 을 입력하면 해당 명령어의 도움말을 보여줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s, /%s 출두", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
		}
		return 1;
	}

	if( !isnull(params) )
	{
		//각 명령어로 도움말을 리다이렉트한다
		//바이너리 트리 사용
		new i, hash, str[128];
		hash = fnv_hash( params );
		//한글에서 먼저 검사
		i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
		if( i == BINTREE_NOT_FOUND ) //한글에 없음 영어에서 검사
		{
			i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
			if ( i == BINTREE_NOT_FOUND )
			{
				//알 수 없는 명령어
				if( CONSOLE ) printf("[rcon] 알 수 없는 명령어입니다 :  %s", params );
				else
				{
					format( str, sizeof(str), "* 알 수 없는 명령어입니다 :  %s", params );
					SendClientMessage( playerid, COLOR_GREY, str );
				}
				return 1;
			}
		}
		format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
		CallLocalFunction( str, "isib", playerid, NULL, i, true ); //help mode
		return 1;
	}
	
	//명령어 목록 표시
	new str[256];
	if( CONSOLE )
	{
		print("\n=====================  Rcon Controller : Command List  ========================");
		print("           자세한 도움말을 보려면 도움말 [명령어 이름] 을 입력하십시오.");
		print(LINE);	
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, "===========  Rcon Controller : Command List  ==========");
		format( str, sizeof(str), "           자세한 도움말을 보려면 /%s [명령어 이름] 을 입력하십시오.", cmdlist[CMD_HELP][Cmd] );
		SendClientMessage( playerid, COLOR_SALMON, str );
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);	
	}
	
	//명령어를 가지런히 정렬하여 표시
	new idx;
	//세로로 표시
	new lines = ceildiv(sizeof( cmdlist ), 6); //몇줄인지 구한다
	for( new i = 0 ; i < lines ; i++ ) //줄만큼 반복
	{
		str = "     ";
		for( new j = 0 ; j < 6 ; j++ )
		{
			idx = (j*lines)+i;
			if(  idx < sizeof(cmdlist) ) format( str, sizeof(str), "%s%-12s", str, cmdlist[Cmdorder:idx][Cmd] );				
		}
		if( CONSOLE ) print( str );
		else SendClientMessage( playerid, COLOR_LIME, str );
	}		

	if( CONSOLE )
	{
		print(LINE);
		printf("              Total %d Commands, %s", sizeof( cmdlist ), COPYRIGHT_STRING );
		printf("%s\n",LINE);
		
		//printf(" 처음 사용하시는 분의 경우 
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		//format( str, sizeof(str), "      Total %d Commands, (C) 2008 - 2013 CoolGuy(밥먹었니)", sizeof( cmdlist ) );
		//SendClientMessage( playerid, COLOR_SALMON, str );
		//SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
	}
	/*
		도움말 양식 :  if( HELP )
	*/
	return 1;	
}
//==========================================================
public dcmd_rchelp2(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	//FIXME: 오래 되었습니다. 다른 명령어로 바꾸는 것이 필요합니다.
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] 모든 명령어에 대한 간략한 설명을 보여줍니다." );
			printf( "[help] 예) %s", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 모든 명령어에 대한 간략한 설명을 보여줍니다." );
			format( str, sizeof(str), "* 예) /%s", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	PLAYER_CURSCR[playerid] = 0;
	ScrollHelp( playerid );
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_with(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 특정 플레이어에게로 이동합니다." );
			printf( "[help] 예) /%s 10 : 10번에게 이동합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) /%s coolguy : coolguy에게 이동합니다.", CURRENT_CMD_NAME );
			print("[help] 게임 중에만 가능하며, 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 특정 플레이어에게로 이동합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번에게 이동합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy에게 이동합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}	
	
	No_Console();
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID: return No_Wildcard();
	}

	//Default Action
	new Float:pos[3], Float:Angle;
	SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	GetPlayerPos(giveplayerid, pos[0], pos[1], pos[2]);
	GetPlayerFacingAngle(giveplayerid, Angle);
	if(IsPlayerInAnyVehicle(playerid))
	{
		SetVehicleZAngle(GetPlayerVehicleID(playerid), Angle);
		LinkVehicleToInterior(GetPlayerVehicleID(playerid), GetPlayerInterior(giveplayerid));
		SetVehiclePosEx(GetPlayerVehicleID(playerid), pos[0], pos[1], pos[2]);
	}
	else
	{
		SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
		SetPlayerFacingAngle(playerid, Angle);
	}
	SendClientMessage(playerid, COLOR_GREENYELLOW, "* 출두 하였습니다.");
	printf("[rcon] %s(%d)님이 %s(%d)님에게 출두하였습니다.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
	return 1;
}
//==========================================================
public dcmd_call( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 특정 플레이어를 이곳으로 데려옵니다." );
			printf("[help] /%s *를 입력하면 모든 플레이어를 이곳으로 데려옵니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) /%s 10: 10번을 이곳으로 데려옵니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) /%s coolguy: 10번을 이곳으로 데려옵니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) /%s *: 모두를 이곳으로 데려옵니다.", CURRENT_CMD_NAME );
			print("[help] 게임 중에만 가능하며, 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 특정 플레이어를 이곳으로 데려옵니다." );
			format( str, sizeof(str), "* /%s *를 입력하면 모든 플레이어를 이곳으로 데려옵니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 10: 10번을 이곳으로 데려옵니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy: 10번을 이곳으로 데려옵니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s *: 모두를 이곳으로 데려옵니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			//debugprintf("print returns %d", !print("sample") );
		}
		return 1;
	}
	
	No_Console();
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				if( PLAYER_SPAWNED[pITT[i]] && pITT[i] != playerid )
				{
					new Float:pos[3],Float:Angle;
					SetPlayerInterior(pITT[i],GetPlayerInterior(playerid));
					GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
					GetPlayerFacingAngle(playerid,Angle);
					if(IsPlayerInAnyVehicle(pITT[i]))
					{
						SetVehicleZAngle(GetPlayerVehicleID(pITT[i]),Angle);
						LinkVehicleToInterior(GetPlayerVehicleID(pITT[i]),GetPlayerInterior(playerid));
						SetVehiclePosEx(GetPlayerVehicleID(pITT[i]),pos[0],pos[1],pos[2]);
					}
					else
					{
						SetPlayerPos(pITT[i],pos[0],pos[1],pos[2]);
						SetPlayerFacingAngle(pITT[i],Angle);
					}
				}
			}
			new str[81];
			format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 소환하였습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			printf("[rcon] %s(%d)님이 플레이어 모두를 소환하였습니다.",GetPlayerNameEx(playerid),playerid );
			return 1;
		}
	}

	new Float:pos[3],Float:Angle;
	SetPlayerInterior(giveplayerid,GetPlayerInterior(playerid));
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	GetPlayerFacingAngle(playerid,Angle);
	if(IsPlayerInAnyVehicle(giveplayerid))
	{
		SetVehicleZAngle(GetPlayerVehicleID(giveplayerid),Angle);
		LinkVehicleToInterior(GetPlayerVehicleID(giveplayerid),GetPlayerInterior(playerid));
		SetVehiclePosEx(GetPlayerVehicleID(giveplayerid),pos[0],pos[1],pos[2]);
	}
	else
	{
		SetPlayerPos(giveplayerid,pos[0],pos[1],pos[2]);
		SetPlayerFacingAngle(giveplayerid,Angle);
	}
	new str[81];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 소환하였습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님이 %s(%d)님을 소환하였습니다.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
	return 1;
}
//==========================================================
public dcmd_sublogin( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 부운영자 자격을 인증하여 권한을 얻습니다." );
			print( "[help] 부운영자 자격은 RconController.ini에서 만드실 수 있습니다. ");
			printf( "[help] 예) /%s password: 비밀번호 'password'를 사용하여 부운영자로 로그인합니다. ", CURRENT_CMD_NAME );
			print("[help] 게임 중에만 가능하며, 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 부운영자 자격을 인증하여 권한을 얻습니다."  );
			SendClientMessage( playerid, COLOR_LIME, "* 부운영자 자격을 얻으시려면 운영자에게 문의하세요." );
			format( str, sizeof(str), "* 예) /%s password: 비밀번호 'password'를 사용하여 부운영자로 로그인합니다. ", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	No_Console();	

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 부운영자 기능이 제한되어 있습니다. 관리자에게 문의하세요" );
		print( "[rcon] 부운영자 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요." );
		return 1;
	}

	new tmp[512];

	if(LOAD_SUBADMIN) // gather subadmin info
	{
		LOAD_SUBADMIN = 0;
		c_iniOpen( FILE_SETTINGS, io_read );
		for(new i=0; i < MAX_SUBADMIN; i++)
		{
			format(tmp,sizeof(tmp),"SubAdmin%d",i+1);
			tmp=c_iniGet("[SubAdmin]", tmp);
			if( !tmp[0] || tmp[0] == '\r' ){ break; }
			/*sscanf( tmp, "p|sssi", SubAdmin[i][Name], tmp, SubAdmin[i][IP], SubAdmin[i][profile_index] );
			SubAdmin[i][Password_Hash] = fnv_hash( tmp );*/
			new idx;
			//FixChars(tmp);
			set( SubAdmin[i][Name], strtok(tmp,idx,'|') );
			SubAdmin[i][Password_Hash]=fnv_hash(strtok(tmp,idx,'|'));
			set(SubAdmin[i][IP], strtok(tmp,idx,'|'));
			SubAdmin[i][profile_index]=strval(strtok(tmp,idx,'|'));
			Num_SubAdmin++;
		}
		c_iniClose( );
		//printf("total %d Subadmins.", Num_SubAdmin);
	}

	if(IsPlayerSubAdmin(playerid))
	{
		SendClientMessage( playerid, COLOR_GREY, "* 이미 부운영자입니다." );
		return 1;
	}
	
	if(isnull(params)) return Usage( playerid, CMD_CURRENT );

	for(new i=0;i<Num_SubAdmin;i++)
	{
		if(!strcmp(GetPlayerNameEx(playerid),SubAdmin[i][Name]) && !strcmp(PLAYER_IP[playerid],SubAdmin[i][IP]) && SubAdmin[i][Password_Hash]==fnv_hash(params))
		{
			//로그인 실패 횟수 초기화
			SUBADMIN_FAILLOGIN_TIMES[playerid] = 0;
			//메세지 띄우기
			format(tmp,sizeof(tmp),"* %s(%d)님께서 부운영자로 로그인 하셨습니다.",GetPlayerNameEx(playerid),playerid);
			SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
			SendClientMessage(playerid,COLOR_ORANGE,"* 도움말은 /rchelp이며, 로그아웃은 /subout 또는 /부운종료 입니다.");
			printf("[rcon] %s(%d)님께서 부운영자로 로그인 하셨습니다.",GetPlayerNameEx(playerid),playerid);			
			SetPlayerSubAdmin( playerid, SubAdmin[i][profile_index] );
			return 1;
		}
	}

	SUBADMIN_FAILLOGIN_TIMES[playerid]++;
	if( SUBADMIN_FAILLOGIN_TIMES[playerid] >= SUBADMIN_FAILLOGIN_LIMIT )
	{
		format(tmp,sizeof(tmp),"* %s(%d)님께서 부운영자 로그인에 실패하여 추방됩니다.",GetPlayerNameEx(playerid),playerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
		printf("[rcon] %s(%d)님께서 부운영자 로그인에 실패하여 추방됩니다.",GetPlayerNameEx(playerid),playerid);
		Kill( playerid );
		c_Kick(playerid);
		return 1;
	}
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* 부운영자 로그인에 실패하였습니다. 다시 시도해 보세요.");
	printf("[rcon] %s(%d)님께서 부운영자 로그인에 실패하였습니다.", GetPlayerNameEx(playerid), playerid);
	return 1;
}
//==========================================================
public dcmd_subout( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] 부운영자 자격을 반납하고 일반 유저가 됩니다." );
			printf( "[help] 예) /%s : 부운영자 자격을 반납하고 일반 유저가 됩니다.", CURRENT_CMD_NAME );
			print("[help] 게임 중에만 가능하며, 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 부운영자 자격을 반납하고 일반 유저가 됩니다." );
			format( str, sizeof(str), "* 예) /%s : 부운영자 자격을 반납하고 일반 유저가 됩니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();
	
	if( !IsPlayerSubAdmin( playerid ) )
	{
		SendClientMessage( playerid, COLOR_GREY, "* 부운영자가 아닙니다." );
		return 1;
	}
	
	new str[70];
	format(str,sizeof(str),"* %s(%d)님께서 부운영자 권한을 반납하였습니다.",GetPlayerNameEx(playerid),playerid);
	SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
	SendClientMessage(playerid,COLOR_GREENYELLOW,"* 로그아웃 하였습니다.");
	printf("[rcon] %s(%d)님께서 부운영자 권한을 반납하였습니다.",GetPlayerNameEx(playerid),playerid);
	PERMANENT_ADMINSAY[playerid] = 0;
	UnSetPlayerSubAdmin(playerid);
	#pragma unused params
	return 1;
}
//==========================================================
#if SAMP03a
//==========================================================
public dcmd_gui( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 사용자에 대한 관리 도구를 엽니다." );
			print( "[help] TAB키를 누르고 유저를 더블클릭하여 열 수도 있습니다.");
			printf( "[help] 예) /%s 10 : 10번 사용자를 어떻게 구워삶을지 창을 엽니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) /%s coolguy : coolguy를 어떻게 구워삶을지 창을 엽니다.", CURRENT_CMD_NAME );
			print("[help] 게임 중에만 가능하며, 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 해당 사용자에 대한 관리 도구를 엽니다." );
			SendClientMessage( playerid, COLOR_LIME, "* TAB키를 누르고 유저를 더블클릭하여 열 수도 있습니다.");
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 어떻게 구워삶을지 창을 엽니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy를 어떻게 구워삶을지 창을 엽니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	No_Console();	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID: return No_Wildcard();
	}	
	OnPlayerClickPlayer(playerid, giveplayerid, 0);
	return 1;
}
//==========================================================
#endif /* SA-MP 0.3a의 다이얼로그 기능 사용 */
//==========================================================
public dcmd_cmdtrace( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] 명령어 추적을 시작/종료합니다." );
			print("[help] 다른 플레이어의 명령어를 콘솔에 실시간으로 표시하는 기능입니다." );
			printf( "[help] 예) %s : 명령어 추적을 시작/종료합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 명령어 추적을 시작/종료합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 명령어 추적은 다른 플레이어의 명령어를 채팅창에 실시간으로 표시하는 기능입니다." );
			format( str, sizeof(str), "* 예) /%s : 명령어 추적을 시작/종료합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	IS_HEAR_CMDTRACE[playerid] = !IS_HEAR_CMDTRACE[playerid];
	
	if( CONSOLE ) printf("[rcon] 명령어 추적기능을 %s하였습니다.", (IS_HEAR_CMDTRACE[playerid])? ("시작"):("중단") );
	else
	{
		SendClientMessage(playerid,COLOR_GREENYELLOW,(IS_HEAR_CMDTRACE[playerid])? ("* 명령어 추적을 시작하였습니다."):("* 명령어 추적을 중단하였습니다."));
		printf("[rcon] %s(%d)님께서 명령어 추적을 %s하셨습니다.",GetPlayerNameEx(playerid),playerid,(IS_HEAR_CMDTRACE[playerid])? ("시작"):("중단"));
	}	
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_find( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 선택한 플레이어의 정보를 수집하여 보고합니다." );
			printf( "[help] 예) %s 10 : 10번 사용자의 정보를 수집하여 보고합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy의 정보를 수집하여 보고합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s ", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 선택한 플레이어의 정보를 수집하여 보고합니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자의 정보를 수집하여 보고합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy의 정보를 수집하여 보고합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID: return dcmd_stat( playerid, NULL, CMD_STAT, NO_HELP );
	}
	
	if(CONSOLE)
	{
		print(LINE);
		printf("%s(%d)%s - Ping: %d, IP: %s, Money: %d, Score: %d, HP: %d, ARM: %d",
			GetPlayerNameEx(giveplayerid),giveplayerid,(IsPlayerAdmin(giveplayerid)||IsPlayerSubAdmin(giveplayerid))? ("*"):(""),
			GetPlayerPing(giveplayerid),PlayerIP(giveplayerid),GetPlayerCash(giveplayerid),GetPlayerScore(giveplayerid),floatround(PlayerHealth(giveplayerid)),floatround(PlayerArmour(giveplayerid)));
		print(LINE);
	}
	else
	{
		new str[121];
		format( str, sizeof(str), "-> %s(%d)%s - Ping: %d, IP: %s, Money: %d, Score: %d, HP: %d, ARM: %d",
			GetPlayerNameEx(giveplayerid),giveplayerid,(IsPlayerAdmin(giveplayerid)||IsPlayerSubAdmin(giveplayerid))? ("*"):(""),
			GetPlayerPing(giveplayerid),PlayerIP(giveplayerid),GetPlayerCash(giveplayerid),GetPlayerScore(giveplayerid),floatround(PlayerHealth(giveplayerid)),floatround(PlayerArmour(giveplayerid)));
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
	}
	return 1;
}
//==========================================================
public dcmd_spm( playerid, tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print( LINE );
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 귓속말을 보냅니다." );
			printf( "[help] %s Admin 또는 운영자를 사용하시면 서버 운영자에게 메세지를 보낼 수 있습니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 안녕 : coolguy에게 \"안녕\"이라는 메세지를 보냅니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 운영자 운영자 쩌러: 운영자에게 '운영자 쩌러' 라고 이야기합니다.", CURRENT_CMD_NAME );
			print( LINE );
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT );
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 해당 플레이어에게 귓속말을 보냅니다." );
			format( str, sizeof(str), "* /%s Admin 또는 운영자를 사용하시면 서버 운영자에게 메세지를 보낼 수 있습니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 안녕 : coolguy에게 \"안녕\"이라는 메세지를 보냅니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 운영자 운영자 쩌러 : 운영자에게 '운영자 쩌러' 라고 이야기합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT );
		}
		return 1;
	}

	new params[MAX_PLAYER_NAME], giveplayerid, msg[128];
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"ss",params,msg);	
	giveplayerid = Process_GivePlayerID( playerid, params, true );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				//잘못 쓴 경우 확인
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 상대방에게 할 말을 써 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 상대방에게 할 말을 써 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //문자까지 입력
			{
				//쓴 글이 없는 경우
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] 보낼 메세지를 써 주십시오. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 보낼 메세지를 써 주십시오. ");
					return 1;
				}
				format( msg, sizeof(msg), "%s", tmp ); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((!msg[0] && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID: return No_Wildcard();
	}
	
	if( !OnPlayerPrivmsg(playerid, giveplayerid, msg) ) return 1;
	
	new str[168];
	format(str,sizeof(str),"PM from %s(%d): %s",CONSOLE? ("Admin"):(GetPlayerNameEx(playerid)),playerid,msg);
	if(giveplayerid == ADMIN_ID)
	{
		print(duplicatesymbol('=',79));
		print(str);
		print(duplicatesymbol('=',79));
	}
	else SendClientMessage(giveplayerid,COLOR_YELLOW,str);
	if(!CONSOLE)
	{
		format(str,sizeof(str),"PM sent to %s(%d): %s", GetPlayerNameEx(giveplayerid),giveplayerid,msg);
		SendClientMessage(playerid,COLOR_YELLOW,str);
	}
	printf("[pm] [%s(%d) -> %s(%d)]: %s", GetPlayerNameEx(playerid),playerid, GetPlayerNameEx(giveplayerid),giveplayerid,msg);
	return 1;
}
//==========================================================
public dcmd_say( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 운영자 자격으로 대화합니다." );
			printf( "[help] 예) %s 알려드립니다 : 운영자 자격으로 \"알려드립니다\" 라고 말합니다.", CURRENT_CMD_NAME );
			printf( "[help] 계속하여 운영자 자격으로 이야기하려면 %s 명령어를 사용하십시오." , GetCmdName(CMD_PSAY) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 운영자 자격으로 대화합니다." );
			format( str, sizeof(str), "* 예) /%s 알려드립니다 : 운영자 자격으로 \"알려드립니다\" 라고 말합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) 계속하여 운영자 자격으로 이야기하려면 /%s 명령어를 사용하십시오." , GetCmdName(CMD_PSAY) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) ) return Usage( playerid, CMD_CURRENT );

	new str[140];
	if (CONSOLE)
	{
		printf("[chat] [Admin]: %s",params);
		format(str,sizeof(str),"%s%s", ADMINCHAT_NAME, params);
		SendClientMessageToAll(COLOR_SPRINGGREEN,str);
	}
	else if(IsPlayerAdmin(playerid))
	{
		printf("[chat] [Admin]: %s",params);
		format(str,sizeof(str),"%s%s", ADMINCHAT_NAME, params);
		SendClientMessageToAll(COLOR_SPRINGGREEN,str);
	}
	else
	{
		printf("[chat] [SubAdmin]: %s",params);
		format(str,sizeof(str),"* 부운영자 %s: %s", GetPlayerNameEx(playerid), params);
		SendClientMessageToAll(COLOR_AQUA,str);
	}
	return 1;
}
//==========================================================
public dcmd_psay( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] 항상 운영자 자격으로 대화하도록 설정합니다." );
			print( "[help] 말모드 상태에서 명령어를 사용할경우 명령어 앞에 !를 붙이면 됩니다." );
			print( "[help] 말모드를 해제하려면 !말모드 를 입력하십시오." );
			printf( "[help] 예) %s : 항상 운영자 자격으로 대화하도록 설정합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 항상 운영자 자격으로 대화하도록 설정합니다." );
			format( str, sizeof(str), "* 예) /%s : 항상 운영자 자격으로 대화하도록 설정합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	PERMANENT_ADMINSAY[playerid] = !PERMANENT_ADMINSAY[playerid];
	if( CONSOLE )
	{
		if ( PERMANENT_ADMINSAY( playerid ) )
		{
			print( "[rcon] 운영자말 모드로 전환했습니다." );
			print( "[help] 말모드 상태에서 명령어를 사용할경우 명령어 앞에 !를 붙이면 됩니다." );
			print( "[help] 말모드를 해제하려면 !말모드 를 입력하십시오." );
		}
		else
		{
			print ("[rcon] 운영자말 모드를 종료했습니다." );
		}
	}
	else SendClientMessage( playerid, COLOR_GREENYELLOW, PERMANENT_ADMINSAY(playerid)? ( "* 운영자말 모드로 전환했습니다." ):( "* 운영자말 모드를 종료했습니다." ) );
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_wtime( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 서버의 시각을 변경합니다. 24시간제로 표기합니다." );
			printf( "[help] 예) %s 21: 서버 시각을 오후 09:00으로 변경합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 현재 서버의 시각을 변경합니다. 24시간제로 표기합니다." );
			format( str, sizeof(str), "* 예) /%s 21: 서버 시각을 오후 09:00으로 변경합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] 바꾸고 싶은 시각을 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* 바꾸고 싶은 시각을 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}
	
	if(isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 23)
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] 시각을 제대로 입력하여 주십시오." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* 시각을 제대로 입력하여 주십시오." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[36];
	format(str,sizeof(str),"* 시각이 %d:00 으로 변경되었습니다.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWorldTime(strval(params));
	printf("[rcon] 시각이 %d:00 으로 변경되었습니다.",strval(params));
	return 1;
}
//==========================================================
public dcmd_skill( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 사살합니다." );
			printf( "[help] 예) %s 10 : 10번 사용자를 사살합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy를 사살합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 사살합니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 사살합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy를 사살합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS ) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE )
			{
				SendClientMessageToAll(COLOR_GREENYELLOW, "* 운영자가 플레이어 모두를 사살하였습니다.");
				print("[rcon] 모든 플레이어를 사살했습니다.");			
			}
			else 
			{
				new str[81];
				format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 사살하였습니다.", GetPlayerNameEx(playerid));
				SendClientMessageToAll(COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 플레이어 모두를 사살하였습니다.",GetPlayerNameEx(playerid),playerid );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) Kill(pITT[i]);
			return 1;
		}
	}
	
	new str[79];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 사살했습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님을 사살했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	Kill(giveplayerid);
	return 1;
}
//==========================================================
public dcmd_skick(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 강제 추방합니다." );
			print( "[help] [이유]에 글자를 적으면 추방되는 유저에게 메세지가 전송됩니다." );
			printf( "[help] 예) %s 10 : 10번 사용자를 묻지도 따지지도 않고 추방합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 비매너 행위 : coolguy가 '비매너 행위'를 해서 추방합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 강제 추방합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* [이유]에 글자를 적으면 추방되는 유저에게 메세지가 전송됩니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 묻지도 따지지도 않고 추방합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 비매너 행위 : coolguy가 '비매너 행위'를 해서 추방합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//기초 프로세스
	sscanf(tmp,"ss",params,reason);
	if(isnull(tmp)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				//잘못 쓴 경우 확인
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 추방하는 이유가 있으면 써 주십시오. 없으면 '0' 을 적어주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 추방하는 이유가 있으면 써 주십시오. 없으면 0 을 적어주십시오." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //문자까지 입력
			{			
				if( isnull(tmp) || tmp[0] =='0' ) reason[0] = EOS; //이유가 없는 경우
				else format( reason, sizeof(reason), "%s", tmp ); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE )
			{
				if( strlen(reason) )
				{
					printf("[rcon] 모든 플레이어를 추방했습니다. (이유 : %s)", reason );
					format( reason, sizeof(reason), "* 운영자가 플레이어 모두를 추방하였습니다.(이유 : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* 운영자가 플레이어 모두를 추방하였습니다.");
					print("[rcon] 모든 플레이어를 추방했습니다.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 추방하였습니다.(이유 : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)님이 플레이어 모두를 추방하였습니다.(이유 : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 추방하였습니다.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)님이 플레이어 모두를 추방하였습니다.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_Kick(pITT[i]);
			return 1;
		}
	}
	
	new str[216];	
	if( strlen(reason) ) format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 추방했습니다.(이유 : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 추방했습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님을 추방했습니다.(이유 : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("적지 않음"));
	c_Kick(giveplayerid);
	return 1;
}
//==========================================================
public dcmd_sban(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 추방하며, 이후 접속을 차단합니다." );
			print( "[help] [이유]에 글자를 적으면 추방되는 유저에게 메세지가 전송됩니다." );
			printf( "[help] 예) %s 10 : 10번 사용자를 묻지도 따지지도 않고 영구추방합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 핵사용 : coolguy가 '핵사용'을 해서 영구추방합니다.", CURRENT_CMD_NAME );
			printf( "[help] 영구추방을 취소하려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 추방하며, 이후 접속을 차단합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* [이유]에 글자를 적으면 추방되는 유저에게 메세지가 전송됩니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 묻지도 따지지도 않고 영구추방합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 핵사용 : coolguy가 '핵사용'을 해서 영구추방합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 영구추방을 취소하려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_UNBAN) );			 SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//기초 프로세스
	sscanf(tmp,"ss",params,reason);
	if( isnull(tmp) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				//잘못 쓴 경우 확인
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 영구추방하는 이유가 있으면 써 주십시오. 없으면 '0' 을 적어주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 영구추방하는 이유가 있으면 써 주십시오. 없으면 0 을 적어주십시오." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //문자까지 입력
			{			
				if( isnull(tmp) || tmp[0] == '0' ) reason[0] = EOS; //이유가 없는 경우
				else format( reason, sizeof(reason), "%s", tmp ); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE )
			{
				if( strlen(reason) )
				{
					printf("[rcon] 모든 플레이어를 영구추방했습니다. (이유 : %s)", reason );
					format( reason, sizeof(reason), "* 운영자가 플레이어 모두를 영구추방하였습니다.(이유 : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* 운영자가 플레이어 모두를 영구추방하였습니다.");
					print("[rcon] 모든 플레이어를 영구추방했습니다.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 영구추방하였습니다.(이유 : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)님이 플레이어 모두를 영구추방하였습니다.(이유 : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* 운영자 %s(이)가 플레이어 모두를 영구추방하였습니다.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)님이 플레이어 모두를 영구추방하였습니다.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_BanEx( pITT[i], reason );
			return 1;
		}
	}
	
	new str[220];	
	if( strlen(reason) ) format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 영구추방했습니다.(이유 : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 영구추방했습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님을 영구추방했습니다.(이유 : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("적지 않음"));
	c_BanEx( giveplayerid, reason );
	return 1;
}
//==========================================================
public dcmd_mcash(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 플레이어에게 일정량의 돈을 주거나 뺏습니다." );
			printf( "[help] 예) %s 10 10000 : 10번에게 $10000의 돈을 줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy -20 : coolguy에게서 $20을 뺏습니다.", CURRENT_CMD_NAME );
			printf( "[help] 플레이어의 돈을 $0으로 만들려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_FORFEIT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 플레이어에게 일정량의 돈을 줍니다." );
			format( str, sizeof(str), "* 예) /%s 10 10000 : 10번에게 $10000의 돈을 줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy -20 : coolguy에게서 $20을 뺏습니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 플레이어의 돈을 $0으로 만들려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_FORFEIT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, amount;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,amount);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 상대방에게 줄 돈의 양을 써 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 상대방에게 줄 돈의 양을 써 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //돈 양 입력
			{
				//돈 양이 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) || strval(tmp) == 0 )
				{
					if( CONSOLE ) print("[rcon] 돈의 양을 제대로 써 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 돈의 양을 제대로 써 주십시오.");
					return 1;
				}
				amount = strval(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((amount == 0 && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어에게 $%d의 돈을 쥐어주었습니다.", amount );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어에게 $%d의 돈을 쥐어주었습니다.", amount);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어에게 $%d의 돈을 쥐어주었습니다.", GetPlayerNameEx(playerid), playerid, amount);
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* 운영자 %s(이)가 당신에게 $%d의 돈을 쥐어주었습니다.", GetPlayerNameEx(playerid), amount);
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,str);
				GivePlayerCash(pITT[i], amount);
			}
			return 1;
		}
	}

	GivePlayerCash(giveplayerid, amount);
	new str[95];
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)님에게 $%d의 돈을 쥐어주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)님이 %s(%d)님에게 $%d의 돈을 쥐어주었습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	}
	else printf("[rcon] %s(%d)님에게 $%d의 돈을 쥐어주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	
	format(str,sizeof(str),"* 운영자 %s(이)가 당신에게 $%d의 돈을 쥐어주었습니다.", GetPlayerNameEx(playerid), amount);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);	
	return 1;
}
//==========================================================
public dcmd_givewp(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 플레이어에게 무기와 탄약을 제공합니다." );
			print( "[help] [총알] 란에 기입하지 않는 경우 3000발을 제공하게 됩니다." );
			printf( "[help] 예) %s 10 32 50 : 10번에게 32번 무기(TEC-9)와 50발의 탄약을 줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 38: coolguy에게 38번 무기(미니건)와 3000발의 탄약을 줍니다.", CURRENT_CMD_NAME );
			print( "[help] 주요 무기 목록 : TEC9-32, 로켓-35, 미니건-38 ");
			printf( "[help] 무기를 뺏으려면 %s 명령을 사용하십시오.", GetCmdName(CMD_DISARM) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 플레이어에게 무기와 탄약을 제공합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* [총알] 란에 기입하지 않는 경우 3000발을 제공하게 됩니다." );
			format( str, sizeof(str), "* 예) /%s 10 32 50 : 10번에게 32번 무기(TEC-9)와 50발의 탄약을 줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 38: coolguy에게 38번 무기(미니건)와 3000발의 탄약을 줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 주요 무기 목록 : TEC9-32, 로켓-35, 미니건-38 "); SEND();
			format( str, sizeof(str), "* 무기를 뺏으려면 %s 명령을 사용하십시오.", GetCmdName(CMD_DISARM) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new params[MAX_PLAYER_NAME], giveplayerid, weaponid, ammo;

	sscanf(tmp,"sii",params,weaponid,ammo);

	if(isnull(params) || weaponid <= 0 || weaponid >= 54 || ammo < 0)
	{
		new str[128];
		if(CONSOLE)
		{
			printf("[rcon] 사용법: %s or %s [이름이나 번호] [무기번호] [총알 = 3000발]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			printf("[rcon] 자세한 사용법은 도움말 %s 을(를) 입력하세요.", GetCmdName(CMD_GIVEWP) );
		}
		else
		{
			format( str, sizeof(str), "* 사용법: /%s or /%s [이름이나 번호] [무기번호] [총알 = 3000발]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
			format( str, sizeof(str), "* 자세한 사용법은 /%s %s 을(를) 입력하세요.", GetCmdName(CMD_HELP), GetCmdName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
		}
		return 1;
	}
	if(isNumeric(params) && strval(params)>=0 && strval(params)<M_P && IsPlayerConnectedEx(strval(params))) giveplayerid=strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid=PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		return 1;
	}

	if( USE_ANTI_WEAPONCHEAT && IsWeaponForbidden(weaponid) )
	{
		if(CONSOLE) print("[rcon] 서버에서 사용을 금지한 무기입니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 서버에서 사용을 금지한 무기입니다.");
		return 1;
	}
	GivePlayerWeapon(giveplayerid,weaponid,(ammo)? (ammo):(3000));
	new str[148];
	GetWeaponName(weaponid,str,sizeof(str));
	printf("[rcon] %s(%d)님에게 무기 %s와(과) %d발의 탄약을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)님에게 무기 %s와(과) %d발의 탄약을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	GetWeaponName(weaponid,str,sizeof(str));
	format(str,sizeof(str),"* 운영자 %s(이)가 당신에게 무기 %s와(과) %d발의 탄약을 주었습니다.", GetPlayerNameEx(playerid), str,(ammo)? (ammo):(3000));
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	return 1;
}
//==========================================================
public dcmd_chnick(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어의 이름을 변경합니다." );
			print( "[help] 특정한 플러그인을 사용하는 서버의 경우 한글 닉네임 적용도 가능합니다." );
			printf( "[help] 예) %s 10 심영 : 10번 사용자의 닉네임을 '심영' 으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy Cool : coolguy의 닉네임을 Cool로 바꿉니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어의 이름을 변경합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 특정한 플러그인을 사용하는 서버의 경우 한글 닉네임 적용도 가능합니다." );
			format( str, sizeof(str), "* 예) /%s 10 심영 : 10번 사용자의 닉네임을 '심영' 으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy Cool : coolguy의 닉네임을 Cool로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, nick[MAX_PLAYER_NAME];
	
	//기초 프로세스
	sscanf(tmp,"ss",params,nick);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				//잘못 쓴 경우 확인
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 바꿀 닉네임을 적어 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 바꿀 닉네임을 적어 주십시오." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //문자까지 입력
			{			
				//쓴 글이 없는 경우
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] 닉네임을 써 주십시오. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 닉네임을 써 주십시오. ");
					return 1;
				}
				format( nick, sizeof(nick), "%s", tmp ); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if( (!nick[0] && (giveplayerid != INTERACTIVE_MANAGEMENT) ) || isnull(tmp)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID: return No_Wildcard();
	}

	new str[104];
	SetPlayerName( giveplayerid, nick );
	GetPlayerName( giveplayerid, str, MAX_PLAYER_NAME );
	//debugprintf("[rcon] 바꾼 닉네임 : %s, 현재 닉네임: %s", nick, str );
	if( strcmp( nick, str, false ) == 0 )
	{
		format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 닉네임을 %s(으)로 바꿨습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)님의 닉네임을 %s(으)로 바꿨습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		PLAYER_NAME[giveplayerid] = nick;
	}
	else
	{
		if( CONSOLE ) print("[rcon] 닉네임 변경에 실패했습니다. 변경하려는 닉네임에 문제가 있습니다.");
		else SendClientMessage( playerid, COLOR_RED, "* 닉네임 변경에 실패했습니다. 변경하려는 닉네임에 문제가 있습니다." );
	}
	return 1;
}
//==========================================================
public dcmd_sethp(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어의 체력을 설정합니다." );
			print( "[help] 일반적으로 기본 체력은 100이며, 0은 사망입니다." );
			printf( "[help] 예) %s 10 20.0 : 10번의 체력을 20.0으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 56.7 : coolguy의 체력을 56.7로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 체력을 0으로 만드려면 %s 명령어를, 무적으로 만드려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어의 체력을 설정합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 일반적으로 기본 체력은 100이며, 0은 사망입니다." );			
			format( str, sizeof(str), "* 예) /%s 10 20.0 : 10번의 체력을 20.0으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 56.7 : coolguy의 체력을 56.7로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 체력을 0으로 만드려면 /%s 명령어를, 무적으로 만드려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, Float:health;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"sf",params,health);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 설정할 체력을 적어 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 설정할 체력을 적어 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //체력 입력
			{
				//체력이 제대로 입력되지 않은 경우
				if( isnull(tmp) || floatstr(tmp) <= 0.0 )
				{
					if( CONSOLE ) print("[rcon] 체력을 제대로 적어 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 체력을 제대로 적어 주십시오.");
					return 1;
				}
				health = floatstr(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}	

	if( isnull(tmp) || ((health <= 0.0) && (giveplayerid != INTERACTIVE_MANAGEMENT)) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );

	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어의 체력을 %.1f로 변경했습니다.", health );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어의 체력을 %.1f로 변경했습니다.", health );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어의 체력을 %.1f로 변경했습니다.", GetPlayerNameEx(playerid), playerid, health);
			}
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 체력을 %.1f으로 변경했습니다.", GetPlayerNameEx(playerid), health);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth(pITT[i], health);
			return 1;
		}
	}

	new str[99];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 체력을 %.1f으로 변경했습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid, health);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 체력을 %.1f으로 변경했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,health);
	SetPlayerHealth(giveplayerid,health);
	return 1;
}
//==========================================================
public dcmd_armor(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어의 아머를 설정합니다." );
			printf( "[help] 예) %s 10 0 : 10번의 아머를 없앱니다. ",  CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 70.0 : coolguy의 아머를 70.0으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 기본 아머는 100이며, 아머 무한은 %s 명령어를 사용하십시오.", GetCmdName(CMD_INFARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어의 아머를 설정합니다." );
			format( str, sizeof(str), "* 예) /%s 10 0 : 10번의 아머를 없앱니다. ",  CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 70.0 : coolguy의 아머를 70.0으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) 기본 아머는 100이머, 아머를 무한으로 만드려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_INFARMOR) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, Float:armour;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"sf",params,armour);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 설정할 아머를 적어 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 설정할 아머를 적어 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //아머 입력
			{
				//아머가 제대로 입력되지 않은 경우
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] 아머를 제대로 적어 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 아머를 제대로 적어 주십시오.");
					return 1;
				}
				armour = floatstr(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}	

	if( isnull(tmp) || ((armour < 0.0) && (giveplayerid != INTERACTIVE_MANAGEMENT)) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );

	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어의 아머를 %.1f로 변경했습니다.", armour );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어의 아머를 %.1f로 변경했습니다.", armour );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어의 아머를 %.1f로 변경했습니다.", GetPlayerNameEx(playerid), playerid, armour);
			}
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 아머를 %.1f으로 변경했습니다.", GetPlayerNameEx(playerid), armour);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], armour);
			return 1;
		}
	}	

	new str[98];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 아머를 %.1f으로 변경했습니다.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,armour);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 아머를 %.1f으로 변경했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,armour);
	SetPlayerArmour(giveplayerid,armour);
	return 1;
}
//==========================================================
public dcmd_infarmor( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 네오로 만듭니다." );
			print( "[help] 아머가 무적이 되면 총알 등의 충격에 견딜 수 있습니다." );			
			printf( "[help] 예) %s 10 : 10번 사용자를 아머 무한으로 만듭니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy를 아머 무한으로 만듭니다.", CURRENT_CMD_NAME );
			printf( "[help] 아머를 없애려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_ARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 네오로 만듭니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 아머가 무적이 되면 총알 등의 충격에 견딜 수 있습니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 아머 무한으로 만듭니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy를 아머 무한으로 만듭니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 아머를 없애려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_ARMOR) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if( isnull(params) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 아머를 무한으로 만들었습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 아머를 무한으로 만들었습니다.");
				printf("[rcon] %s(%d)님이 모든 플레이어의 아머를 무한으로 만들었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 아머를 무한으로 만들었습니다.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], 10000.0);
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 아머를 무한으로 만들었습니다.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 아머를 무한으로 만들었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	SetPlayerArmour(giveplayerid, 10000.0);
	return 1;
}
//==========================================================
public dcmd_score(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어의 점수를 변경합니다." );
			printf( "[help] 예) %s 10 50 : 10번 사용자의 점수를 50으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 100 : coolguy의 점수를 100으로 바꿉니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어의 점수를 변경합니다." );
			format( str, sizeof(str), "* 예) /%s 10 50 : 10번 사용자의 점수를 50으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 100 : coolguy의 점수를 100으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, score;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,score);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 설정할 점수를 입력해 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 설정할 점수를 입력해 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //스코어 입력
			{
				//스코어가 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] 점수를 제대로 입력해 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 점수를 제대로 입력해 주십시오.");
					return 1;
				}
				score = strval(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((score == 0 && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS ) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어의 점수를 %d로 변경하였습니다.", score );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어의 점수를 %d로 변경하였습니다.", score );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어의 점수를 %d로 변경하였습니다.", GetPlayerNameEx(playerid), playerid, score);
			}
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 점수를 %d로 변경하였습니다.", GetPlayerNameEx(playerid), score);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerScore(pITT[i], score);
			return 1;
		}
	}
	
	SetPlayerScore(giveplayerid,score);
	new str[99];
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)님의 점수를 %d(으)로 변경하였습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* 운영자 %s(이)가 당신의 점수를 %d(으)로 변경하였습니다.", GetPlayerNameEx(playerid),score);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 점수를 %d로 변경하였습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
	return 1;
}
//==========================================================
public dcmd_freeze( playerid, tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 움직이지 못하게 합니다." );
			print( "[help] 시간을 적으면 그만큼만, 적지 않으면 풀어줄 때까지 움직일 수 없습니다." );
			printf( "[help] 예) %s 10 30 :10번 사용자를 30초간 움직이지 못하게 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy를 풀어줄 때까지 움직이지 못하게 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 다시 움직일수 있게 하려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_UNFRZ) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 움직이지 못하게 합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 시간을 적으면 그만큼만, 적지 않으면 풀어줄 때까지 움직일 수 없습니다." );
			format( str, sizeof(str), "* 예) /%s 10 30 :10번 사용자를 30초간 움직이지 못하게 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy를 풀어줄 때까지 계속 움직이지 못하게 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 다시 움직일수 있게 하려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_UNFRZ) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, second;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,second);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 움직이지 못하게 할 시간을 정하십시오. 계속 묶어두려면 0을 입력하십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 움직이지 못하게 할 시간을 정하십시오. 계속 묶어두려면 0을 입력하십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //시간초 입력
			{
				second = strval(tmp);
				//시간초가 제대로 입력되지 않은 경우
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] 시간을 제대로 입력해 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 시간을 제대로 입력해 주십시오.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((second < 0 && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어를 밧줄로 꽁꽁 묶었습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어를 밧줄로 꽁꽁 묶었습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어를 밧줄로 꽁꽁 묶었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어를 밧줄로 꽁꽁 묶었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				TogglePlayerControllable(pITT[i], 0);
				if(second > 0) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_FREEZE] = second;
			}
			return 1;
		}
	}
	
	new str[89];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 밧줄로 꽁꽁 묶었습니다.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님을 밧줄로 꽁꽁 묶었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	TogglePlayerControllable(giveplayerid,0);
	if(second > 0) PLAYER_PUNISH_REMAINTIME[giveplayerid][PUNISH_FREEZE] = second;
	return 1;
}
//==========================================================
public dcmd_unfrz( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 프리즈된 플레이어를 다시 움직일 수 있게 합니다." );
			printf( "[help] 예) %s 10 : 10번 사용자를 움직일 수 있게 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy를 움직일 수 있게 합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 프리즈된 플레이어를 다시 움직일 수 있게 합니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자를 움직일 수 있게 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy를 움직일 수 있게 합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 밧줄을 풀어주었습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 밧줄을 풀어주었습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 밧줄을 풀어주었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 밧줄을 풀어주었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				TogglePlayerControllable(pITT[i], 1);
				PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_FREEZE] = 0;
			}
			return 1;
		}
	}

	new str[98];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 꽁꽁 묶인 밧줄을 풀어주었습니다.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 꽁꽁 묶인 밧줄을 풀어주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	TogglePlayerControllable(giveplayerid,1);
	PLAYER_PUNISH_REMAINTIME[giveplayerid][PUNISH_FREEZE]=0;
	return 1;
}
//==========================================================
public dcmd_sound( playerid, tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 GTA:SA에 내장된 음악을 들려줍니다." );
			printf( "[help] 이름이나 번호에 *을 쓰면 모두에게 소리를 들려줍니다." );
			printf( "[help] 예) %s 10 1002 : 10번 사용자에게 맞는 소리를 들려줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 1185 : coolguy에게 바이크 스쿨 뮤직을 들려줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s * 1187 : 모두에게 비행기 스쿨 뮤직을 들려줍니다.", CURRENT_CMD_NAME );
			print("=================== 주요 소리 목록 ============================================");
			print("1002 맞는소리 1009 크래쉬 1130 펀치소리 1140 폭발 1187 비행기 스클 뮤직");
			print("1097 배경 음악 1183 드라이빙스쿨 뮤직 1185 바이크 스쿨 뮤직 ");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어에게 GTA:SA에 내장된 음악을 들려줍니다." ); SEND();
			format( str, sizeof(str), "* 이름이나 번호에 *을 쓰면 모두에게 소리를 들려줍니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 1002 : 10번 사용자에게 맞는 소리를 들려줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 1185 : coolguy에게 바이크 스쿨 뮤직을 들려줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s * 1187 : 모두에게 비행기 스쿨 뮤직을 들려줍니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= 주요 소리 목록 ===============================");
			SendClientMessage(playerid,COLOR_GREY," 1002 맞는소리 1009 크래쉬 1130 펀치소리 1140 폭발 1187 비행기 스클 뮤직");
			SendClientMessage(playerid,COLOR_GREY," 1097 배경 음악 1183 드라이빙스쿨 뮤직 1185 바이크 스쿨 뮤직 ");
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new params[MAX_PLAYER_NAME], giveplayerid, soundid;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,soundid);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 들려줄 소리의 번호를 입력해 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 들려줄 소리의 번호를 입력해 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //소리번호 입력
			{
				soundid = strval(tmp); //있는 경우
				//소리번호가 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) || soundid <= 0 )
				{
					if( CONSOLE ) print("[rcon] 소리번호를 제대로 입력해 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 소리번호를 제대로 입력해 주십시오.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((soundid <= 0 && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			for( new i = 0; i < NUM_PLAYERS; i++ ) PlaySoundForPlayer( pITT[i], soundid );
			new str[81];
			format(str,sizeof(str),"* 운영자 %s(이)가 음악을 틀었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			if(!CONSOLE)
			{
				format(str,sizeof(str),"* 모두에게 %d번 음악을 들려줬습니다.", soundid);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모두에게 %d번 음악을 재생하였습니다.",GetPlayerNameEx(playerid), playerid, soundid );
				return 1;
			}
			printf("[rcon] %s(%d)님이 모두에게 %d번 음악을 재생하였습니다.", GetPlayerNameEx(playerid), playerid, soundid );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[73];
		format(str,sizeof(str),"* %s(%d)님에게 %d번 음악을 들려줬습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* 운영자 %s(이)가 음악을 틀었습니다.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)님에게 %d번 음악을 들려줬습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
	PlaySoundForPlayer(giveplayerid,soundid);
	return 1;
}
//==========================================================
public dcmd_mute( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 들려주던 소리를 끕니다." );
			printf( "[help] 예) %s 10 : 10번에게 들려주던 소리를 끕니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy에게 들려주던 소리를 끕니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어에게 들려주던 소리를 끕니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번에게 들려주던 소리를 끕니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy에게 들려주던 소리를 끕니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 음악을 껐습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 음악을 껐습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 음악을 껐습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 음악을 껐습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )	StopSoundForPlayer( pITT[i] );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[53];
		format(str,sizeof(str),"* %s(%d)님의 음악을 껐습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* 운영자 %s(이)가 음악을 껐습니다.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)님의 음악을 껐습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	StopSoundForPlayer(giveplayerid);
	return 1;
}
//==========================================================
public dcmd_jpack( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 제트팩을 줍니다." );
			printf( "[help] 예) %s 10 : 10번에게 제트팩을 줍니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy : coolguy에게 제트팩을 줍니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어에게 제트팩을 줍니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번에게 제트팩을 줍니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy에게 제트팩을 줍니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if( !ALLOW_JETPACK )
	{
		if(CONSOLE) print("[rcon] 서버에서 제트팩을 허용하고 있지 않습니다.");
		else SendClientMessage(playerid, COLOR_GREY,"* 서버에서 제트팩을 허용하고 있지 않습니다.");
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어에게 제트팩을 주었습니다.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어에게 제트팩을 주었습니다.");
				printf("[rcon] %s(%d)님이 모든 플레이어에게 제트팩을 주었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어에게 제트팩을 주었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				new Float:pos[3];
				GetPlayerPos( pITT[i], pos[0], pos[1], pos[2] );
				SetPlayerPos( pITT[i], pos[0], pos[1], pos[2] + 3.0 );
				SetPlayerSpecialAction( pITT[i], SPECIAL_ACTION_USEJETPACK );
			}
			return 1;
		}
	}
	

	if(!CONSOLE)
	{
		new str[59];
		format(str,sizeof(str),"* %s(%d)님에게 제트팩을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* 운영자 %s(이)가 당신에게 제트팩을 주었습니다.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)님에게 제트팩을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	new Float:pos[3];
	GetPlayerPos( giveplayerid, pos[0], pos[1], pos[2] );
	SetPlayerPos( giveplayerid, pos[0], pos[1], pos[2] + 3.0 );
	SetPlayerSpecialAction(giveplayerid,SPECIAL_ACTION_USEJETPACK);
	return 1;
}
//==========================================================
public dcmd_shutup(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어가 채팅을 하지 못하도록 합니다." );
			print( "[help] [초] 에 입력을 하면 해당 초만큼, 입력하지 않으면 계속 채팅금지를 합니다." );
			printf( "[help] 예) %s 10 : 10번 사용자를 (풀어줄 때까지) 채팅금지 상태로 만듭니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy 30 : coolguy 님을 30초간 채팅금지 상태로 만듭니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 채팅 금지 상태를 풀어주려면 %s 명령어를 사용하십시오.", GetCmdName(CMD_UNSHUT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어가 채팅을 하지 못하도록 합니다." ); SEND();
			format( str, sizeof(str), "* [초] 부분에 입력을 하면 해당 초만큼, 입력하지 않으면 계속해서 채팅 금지를 합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 플레이어를 (풀어줄 때까지) 채팅금지 상태로 만듭니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 30 : coolguy 님을 30초간  채팅금지 상태로 만듭니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 채팅 금지 상태를 풀어주려면 /%s 명령어를 사용하십시오.", GetCmdName(CMD_UNSHUT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new params[MAX_PLAYER_NAME], giveplayerid, second;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,second);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 채팅하지 못하게 할 시간을 정하십시오. 계속 닥치게 하려면 0을 입력하십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 채팅하지 못하게 할 시간을 정하십시오. 계속 닥치게 하려면 0을 입력하십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //시간초 입력
			{
				second = strval(tmp);
				//시간초가 제대로 입력되지 않은 경우
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] 시간을 제대로 입력해 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 시간을 제대로 입력해 주십시오.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if((second < 0 && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 입에 걸레를 물렸습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 입에 걸레를 물렸습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 입에 걸레를 물렸습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 입에 걸레를 물렸습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = (second > 0)? (second):(-1);
			return 1;
		}
	}

	if( IS_CHAT_FORBIDDEN[giveplayerid] )
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 이미 채팅금지 상태입니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 이미 채팅금지 상태입니다.");
		return 1;
	}

	new str[89];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 입에 걸레를 물렸습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 입에 걸레를 물렸습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	PLAYER_PUNISH_REMAINTIME[giveplayerid][PUNISH_SHUTUP] = (second > 0)? (second):(-1);
	return 1;
}
//==========================================================
public dcmd_unshut( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 채팅금지 상태를 풀어줍니다." );
			printf( "[help] 예) %s 10 : 10번 사용자의 채팅금지 상태를 풀어줍니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy 님의 채팅금지 상태를 풀어줍니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어가 채팅을 하지 못하도록 합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자의 채팅금지 상태를 풀어줍니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy 님의 채팅금지 상태를 풀어줍니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 입에 물린 걸레를 빼주었습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 입에 물린 걸레를 빼주었습니다.");
				printf("[rcon] %s(%d)님이 모든 플레이어의 입에 물린 걸레를 빼주었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 입에 물린 걸레를 빼주었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = 0;
			return 1;
		}
	}
	
	if(!IS_CHAT_FORBIDDEN[giveplayerid])
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 채팅금지 상태가 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 채팅금지 상태가 아닙니다.");
		return 1;
	}

	new str[96];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 입에 물린 걸레를 빼주었습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 입에 물린 걸레를 빼주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	PLAYER_PUNISH_REMAINTIME[giveplayerid][PUNISH_SHUTUP]=0;
	return 1;
}
//==========================================================
public dcmd_forfeit( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 돈을 모조리 몰수합니다." );
			printf( "[help] 예) %s 10 : 10번 부르조아의 돈을 뺏습니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy 님의 돈을 모조리 국고에 환수합니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어의 돈을 모조리 몰수합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 부르조아의 돈을 뺏습니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy 님의 돈을 모조리 국고에 환수합니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new giveplayerid = Process_GivePlayerID( playerid, params );	
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 돈을 몰수하였습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 돈을 몰수하였습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 돈을 몰수하였습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 돈을 몰수하였습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerCash( pITT[i] );
			return 1;
		}
	}

	new str[84];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 돈을 몰수했습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 돈을 몰수했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	ResetPlayerCash(giveplayerid);
	return 1;
}
//==========================================================
public dcmd_disarm( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 무기를 광역수사대에서 급습하여 가져갑니다." );
			printf( "[help] 예) %s 10 : 10번 마피아의 무기를 뺏습니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy 님의 무기를 몰수합니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어의 무기를 광역수사대에서 급습하여 가져갑니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 마피아의 무기를 뺏습니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy 님의 무기를 몰수합니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 무기를 몰수했습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 무기를 몰수했습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 무기를 몰수했습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 무기를 몰수했습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerWeapons( pITT[i] );
			return 1;
		}
	}

	new str[86];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 무기를 몰수했습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 무기를 몰수했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	ResetPlayerWeapons(giveplayerid);
	return 1;
}
//==========================================================
public dcmd_spcar(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 차량을 제공합니다." );
			printf( "[help] 예) %s 10 522 : 10번 사용자에게 짱깨 오도방구를 제공합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 520 : coolguy에게 KF-16을 제공합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s * 560 : 모두에게 삐까뻔쩍 차량을 제공합니다.", CURRENT_CMD_NAME );
			print("=================== 주요 차량 목록 ============================================");
			print("NRG-500 522, Shamal 519, Hydra 520, Hunter 425");
			print("Maverick 497, Rhino 432, Sultan 560");
			print(LINE);

		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어에게 차량을 제공합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 522 : 10번 사용자에게 짱깨 오도방구를 제공합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 520 : coolguy에게 KF-16을 제공합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s * 560 : 모두에게 삐까뻔쩍 차량을 제공합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= 주요 차량 목록 ===============================");
			SendClientMessage(playerid,COLOR_GREY," NRG-500 522, Shamal 519, Hydra 520, Hunter 425");
			SendClientMessage(playerid,COLOR_GREY," Maverick 497, Rhino 432, Sultan 560");
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, model;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,model);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 상대방에게 줄 차량의 번호를 써 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 상대방에게 줄 차량의 번호를 써 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //차량 입력
			{
				model = strval(tmp); //있는 경우
				//차량번호가 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) || model < 400 || model > 611 )
				{
					if( CONSOLE ) print("[rcon] 차량번호를 제대로 써 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 차량번호를 제대로 써 주십시오.");
					return 1;
				}		
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if(((model < 400 || model > 611) && giveplayerid != INTERACTIVE_MANAGEMENT) || isnull(params) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어에게 %d번 차량을 주었습니다.", model );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어에게 %d번 차량을 주었습니다.", model);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어에게 %d번 차량을 주었습니다.", GetPlayerNameEx(playerid), playerid, model);
			}
			new Float:pos[3],Float:Angle;
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* 운영자 %s(이)가 당신에게 차량을 주었습니다.", GetPlayerNameEx(playerid));
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,str);				
				GetPlayerPos(pITT[i],pos[0],pos[1],pos[2]);
				GetPlayerFacingAngle(pITT[i],Angle);
				PutPlayerInVehicle( pITT[i] , CreateVehicle(model, pos[0],pos[1],pos[2], Angle, -1, -1, 3000), 0 );
			}
			return 1;
		}
	}

	new Float:pos[3],Float:Angle;
	GetPlayerPos(giveplayerid,pos[0],pos[1],pos[2]);
	GetPlayerFacingAngle(giveplayerid,Angle);
	PutPlayerInVehicle( giveplayerid , CreateVehicle(model, pos[0],pos[1],pos[2], Angle, -1, -1, 3000), 0 );
	if(!CONSOLE)
	{
		new str[63];
		format(str,sizeof(str),"* %s(%d)님에게 %d번 차량을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,model);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)님이 %s(%d)님에게 %d번 차량을 주었습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, model );
	}
	else printf("[rcon] %s(%d) 님에게 %d번 차량을 주었습니다.", GetPlayerNameEx(giveplayerid), giveplayerid, model );	
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* 운영자 %s(이)가 당신에게 차량을 주었습니다.", GetPlayerNameEx(playerid));	
	return 1;
}
//==========================================================
public dcmd_subadmin( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어에게 부운영자 권한을 줍니다." );
			printf( "[help] 예) %s 10 : 10번 시민을 정치인으로 만듭니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy님을 국회로 보냅니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어에게 부운영자 권한을 줍니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 시민을 정치인으로 만듭니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy님을 국회로 보냅니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어에게 임시 관리권한을 부여했습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어에게 임시 관리권한을 부여했습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어에게 임시 관리권한을 부여했습니다." , GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어에게 임시 관리권한을 부여했습니다." , GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			format( str, sizeof(str), "* 자세한 도움말은 /%s 및 /%s을(를) 참고하세요.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
			SendClientMessageToAll( COLOR_ORANGE, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				SetPlayerSubAdmin(pITT[i],c_iniInt("[SubAdmin]","AUTO_AUTHORITY"));
			}
			return 1;
		}
	}
	
	if(IsPlayerSubAdmin(giveplayerid))
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 이미 부운영자입니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 이미 부운영자입니다.");
		return 1;
	}

	new str[98];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님에게 임시 관리권한을 부여했습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	if( CONSOLE ) printf("[rcon] %s(%d)님에게 임시 관리권한을 부여했습니다.", GetPlayerNameEx(giveplayerid),giveplayerid);
	else printf("[rcon] %s(%d)님이 %s(%d)님에게 임시 관리권한을 부여했습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
	format( str, sizeof(str), "* 자세한 도움말은 /%s 및 /%s을(를) 참고하세요.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
	SendClientMessage( giveplayerid, COLOR_ORANGE, str);
	SetPlayerSubAdmin(giveplayerid,c_iniInt("[SubAdmin]","AUTO_AUTHORITY"));
	return 1;
}
//==========================================================
public dcmd_suspend( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 부운영자 권한을 박탈합니다." );
			printf( "[help] 예) %s 10 : 10번 정치인을 국민의 이름으로 소환합니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy님을 비리혐의로 깜방에 보냅니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어의 부운영자 권한을 박탈합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 정치인을 국민의 이름으로 소환합니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy님을 비리혐의로 깜방에 보냅니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 관리자의 부운영자 권한을 박탈했습니다." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 관리자의 부운영자 권한을 박탈했습니다." );
				printf("[rcon] %s(%d)님이 모든 관리자의 부운영자 권한을 박탈했습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 관리자의 부운영자 권한을 박탈했습니다." , GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				UnSetPlayerSubAdmin(pITT[i]);
			}
			return 1;
		}
	}
	
	if(!IsPlayerSubAdmin(giveplayerid))
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 부운영자가 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 부운영자가 아닙니다.");
		return 1;
	}

	new str[91];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 관리권한을 박탈했습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 관리권한을 박탈했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	UnSetPlayerSubAdmin( giveplayerid );
	return 1;
}
//==========================================================
public dcmd_bomb( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 뇌를 터트립니다." );
			printf( "[help] 예) %s 10 : 10번 사용자의 뇌에 구멍을 송송 냅니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy님을 천국 보냅니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어의 뇌를 터트립니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자의 뇌에 구멍을 송송 냅니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy님을 천국 보냅니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 뇌를 터트렸습니다." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* 모든 플레이어의 뇌를 터트렸습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어의 뇌를 터트렸습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95], Float:pos[3]; 
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 뇌를 터트렸습니다." , GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				GetPlayerPos( pITT[i], pos[0], pos[1], pos[2] );
				CreateExplosion( pos[0], pos[1], pos[2]+0.5, 12, 20.0 );
			}
			return 1;
		}
	}

	new str[84];
	if ( CONSOLE )
	{
		format(str,sizeof(str),"* 운영자가 %s(%d)님의 뇌를 터트렸습니다.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)님의 뇌를 터트렸습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	}	
	else
	{
		format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님의 뇌를 터트렸습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);	
		printf("[rcon] %s(%d)님이 %s(%d)님의 뇌를 터트렸습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
	}
	new Float:pos[3]; GetPlayerPos(giveplayerid,pos[0],pos[1],pos[2]); CreateExplosion(pos[0],pos[1],pos[2]+0.5, 12, 20.0);
	return 1;
}
//==========================================================
public dcmd_setcash(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 플레이어의 돈을 지정한 값으로 바꿉니다." );
			printf( "[help] 예) %s 10 10000 : 10번의 소지금을 $10000으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy -20 : coolguy를 -$20의 빚쟁이로 만듭니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 플레이어의 돈을 지정한 값으로 바꿉니다." );
			format( str, sizeof(str), "* 예) /%s 10 10000 : 10번의 소지금을 $10000으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy -20 : coolguy를 -$20의 빚쟁이로 만듭니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, money;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,money);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 플레이어의 소지금을 결정하십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 플레이어의 소지금을 결정하십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //돈 양 입력
			{
				//돈 양이 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] 소지금을 제대로 써 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 소지금을 제대로 써 주십시오.");
					return 1;
				}
				money = strval(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if( isnull(params) && ( giveplayerid != INTERACTIVE_MANAGEMENT ) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 플레이어의 소지금을 $%d로 설정했습니다.", money );
			else
			{
				format(str,sizeof(str),"* 모든 플레이어의 소지금을 $%d로 설정했습니다.", money );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 플레이어의 소지금을 $%d로 설정했습니다.", GetPlayerNameEx(playerid), playerid, money );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* 운영자 %s(이)가 당신의 소지금을 $%d로 바꾸었습니다.", GetPlayerNameEx(playerid), money);
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,str);
				ResetPlayerCash(pITT[i]);
				GivePlayerCash(pITT[i], money);
			}
			return 1;
		}
	}

	ResetPlayerCash(giveplayerid);
	GivePlayerCash(giveplayerid,money);
	new str[95];
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)님의 소지금을 $%d로 설정했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* 운영자 %s(이)가 당신의 소지금을 $%d로 바꾸었습니다.",GetPlayerNameEx(playerid),money);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님의 소지금을 $%d로 설정했습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
	return 1;
}
//==========================================================
public dcmd_infinite( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어를 무적으로 만듭니다." );
			printf( "[help] 예) %s 10 : 10번 사용자는 헐크가 됩니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy님이 존나 쎄집니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어를 무적으로 만듭니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 사용자는 헐크가 됩니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy님이 존나 쎄집니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어를 무적으로 만들었습니다." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* 모든 플레이어를 무적으로 만들었습니다." );
				printf("[rcon] %s(%d)님이 모든 플레이어를 무적으로 만들었습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95]; 
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어를 무적으로 만들었습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth( pITT[i], 100000.0 );
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* 운영자 %s(이)가 %s(%d)님을 무적으로 만들었습니다.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)님을 무적으로 만들었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid);
	SetPlayerHealth(giveplayerid,100000.0);
	return 1;
}
//==========================================================
public dcmd_notice( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 공지를 띄우거나 띄우지 않습니다." );
			printf( "[help] 예) %s : 공지를 설정 파일의 시간대로 띄우거나 중단합니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s 30 : 공지를 30초마다 띄웁니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 공지의 내용을 바꾸려면 %s를 참조하십시오..", FILE_SETTINGS  );
			printf( "[help] 공지 목록은 %s 명령어를 사용하여 확인하십시오.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 공지를 띄우거나 띄우지 않습니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 공지를 설정 파일의 시간대로 띄우거나 중단합니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s 30 : 공지를 30초마다 띄웁니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 공지의 내용을 바꾸려면 %s를 참조하십시오..", FILE_SETTINGS  ); SEND();
			format( str, sizeof(str), "* 공지 목록은 %s 명령어를 사용하여 확인하십시오.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 공지 기능이 제한되어 있습니다.");
		print("[rcon] 공지 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}

	if(!Num_Notice)
	{
		if(CONSOLE) print("[rcon] 공지가 없습니다. INI파일에 공지을(를) 입력하세요.");
		else SendClientMessage(playerid,COLOR_GREY,"* 공지가 없습니다. RconController.ini에 공지을(를) 입력하세요.");
		return 1;
	}
	if( NOTICE_INTERVAL )
	{
		print("[rcon] 공지 띄우기를 중단하였습니다.");
		SendClientMessageToAll(COLOR_GREENYELLOW,"* 공지 띄우기를 중단하였습니다.");
		NOTICE_INTERVAL = 0;
		return 1;
	}
	if( isnull(params) ) NOTICE_INTERVAL=c_iniInt("[General]","NOTICE_INTERVAL");
	else if( isNumeric(params) && strval(params) > 0 ) NOTICE_INTERVAL=strval(params);
	else return Usage( playerid, CMD_CURRENT );

	if( NOTICE_INTERVAL < 1 )
	{
		if(CONSOLE) print( "[rcon] 설정 파일에 값을 정확히 입력하십시오. 단위는 초입니다." );
		else SendClientMessage( playerid, COLOR_GREY,"* 설정 파일에 값을 정확히 입력하십시오. 단위는 초입니다." );
		return 1;
	}

	new str[46];
	CheckNoticeList();
	printf("[rcon] 이제부터 공지를 %d초마다 띄웁니다.",NOTICE_INTERVAL);
	format(str,sizeof(str),"* 이제부터 공지를 %d초마다 띄웁니다.",NOTICE_INTERVAL);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	return 1;
}
//==========================================================
public dcmd_nlist( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 뿌려주는 공지의 목록을 봅니다." );
			printf( "[help] 예) %s : 현재 뿌려주는 공지의 목록을 봅니다.", CURRENT_CMD_NAME );
			printf( "[help] 공지를 추가한 뒤엔 %s 명령어를 사용하여 로드하십시오.", GetCmdName(CMD_RELOADNOTICE)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 현재 뿌려주는 공지의 목록을 봅니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 현재 뿌려주는 공지의 목록을 봅니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 공지를 추가한 뒤엔 %s 명령어를 사용하여 로드하십시오.", GetCmdName(CMD_RELOADNOTICE)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 공지 기능이 제한되어 있습니다.");
		print("[rcon] 공지 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}

	if(CONSOLE) print("\n====== Notice List ============================================================");
	else SendClientMessage(playerid,COLOR_GREY,"= Notice List =============================");
	new File:fhnd, str[256], stridx, color;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//공지가 시작될때까지 빠른 스킵
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===공지 시작===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//줄 자르고, 주석과 단순엔터는 스킵
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//공지가 끝난 경우 스크립트 중지
		if( !strcmp( str, "===공지 끝===" ) ) break;
		//구분선을 만나면 구분선을 만든다
		if( !strcmp( str, "===구분선===" ) )
		{
			if( CONSOLE ) print(LINE);
			else SendClientMessage( playerid, COLOR_GREY, LINE_CLIENT);
			continue;
		}
		/* 멀티라인 공지를 읽는다 */
		stridx = 0; //기본값 적용
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //색깔 핸들러 확인
		{
			//공지띄울때의 인덱스 지정
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX값의 경우 직접 지정
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//미리 설정된 색깔
			else if ( !strcmp( str[1], "빨강" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "파랑" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "밝은 파랑" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "노랑" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "핑크" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "무적핑크" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "녹색" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "라임" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "흰색" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "시스템" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "회색" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "갈색" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "청록색" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "오렌지" ) ) color = COLOR_ORANGE;
		}
		//공지 띄우기
		print( str[stridx] );
		SendClientMessage( playerid, color, str[stridx] );
	}
	fclose(fhnd);
	if(CONSOLE)
	{
		format( str, sizeof(str), "====== Total %d notice(s). ================================================", Num_Notice );
		new num;
		switch (NUM_PLAYERS)
		{
			case 0 .. 9: num=5;
			case 10 .. 99: num=4;
			default: num=3;
		}
		format( str, sizeof(str), "%s%s\n", str, duplicatesymbol('=',num) );
		print( str );
	}
	else
	{
		format(str,sizeof(str),"= Total %d notice(s). ======================",Num_Notice);
		SendClientMessage(playerid,COLOR_GREY,str);
	}
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_reloadnotice( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 설정 파일에서 공지를 다시 불러옵니다." );
			printf( "[help] 예) %s : 설정 파일에서 공지를 다시 불러옵니다.", CURRENT_CMD_NAME );
			printf( "[help] 공지 목록을 보려면 %s 명령어를 참조하십시오.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 설정 파일에서 공지를 다시 불러옵니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 설정 파일에서 공지를 다시 불러옵니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 공지 목록을 보려면 %s 명령어를 참조하십시오.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 공지 기능이 제한되어 있습니다.");
		print("[rcon] 공지 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	CheckNoticeList();
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* 공지를 다시 불러왔습니다.");
	print("\nNotice list\n----------\n Loaded: RconController.ini\n");
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_reloadsubs( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 설정 파일에서 부운영자 목록을 다시 불러옵니다." );
			printf( "[help] 예) %s : 부운영자 목록을 다시 불러옵니다.", CURRENT_CMD_NAME );
			printf( "[help] 부운영자 목록을 바꾸려면 %s를 참조하십시오..", FILE_SETTINGS );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 설정 파일에서 부운영자 목록을 다시 불러옵니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 부운영자 목록을 다시 불러옵니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 부운영자 목록을 바꾸려면 %s를 참조하십시오..", FILE_SETTINGS ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 부운영자 기능이 제한되어 있습니다.");
		print("[rcon] 부운영자 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	LOAD_SUBADMIN = 1;
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* 부운영자 목록을 다시 불러왔습니다.");
	print("\nSubadmin list\n----------\n Loaded: RconController.ini\n");
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_locksvr( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 서버를 잠금 상태로 만들어, 다른 플레이어가 접속하지 못하게 합니다." );
			printf( "[help] 예) %s : 현시간부로 서버를 잠급니다.", CURRENT_CMD_NAME );
			print( "[help] 잠금을 해제하려면 다시 한번 입력하십시오.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 서버를 잠금 상태로 만들어, 다른 플레이어가 접속하지 못하게 합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 현시간부로 서버를 잠급니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 잠금을 해제하려면 다시 한번 입력하십시오."); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	SERVER_LOCKED = !SERVER_LOCKED;
	SendClientMessageToAll(COLOR_GREENYELLOW,(SERVER_LOCKED)? ("* 서버가 잠겼습니다. 더이상 접속이 불가능합니다."):("* 서버 잠금이 해제되었습니다."));
	printf("[rcon] %s",(SERVER_LOCKED)? ("서버를 잠궜습니다. 사용자가 더이상 접속할 수 없습니다."):("서버 잠금을 해제했습니다. 접속이 허용되었습니다."));
	#pragma unused playerid,params
	return 1;
}
//==========================================================
public dcmd_chauth(playerid,tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 부운영자의 권한을 다른 것으로 변경합니다." );
			printf( "[help] 예) %s 10 : 10번 부운영자의 권한을 0(모든 권한) 으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 3 : coolguy의 권한을 3으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 사용할 수 있는 권한 목록은 %s 명령어를 입력하십시오.", GetCmdName(CMD_AUTHLIST) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 지정한 부운영자의 권한을 다른 것으로 변경합니다." );
			format( str, sizeof(str), "* 예) /%s 10 : 10번 부운영자의 권한을 0(모든 권한) 으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 3 : coolguy의 권한을 3으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 사용할 수 있는 권한 목록은 %s 명령어를 입력하십시오.", GetCmdName(CMD_AUTHLIST) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 부운영자 기능이 제한되어 있습니다.");
		print("[rcon] 부운영자 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	
	new params[MAX_PLAYER_NAME], giveplayerid, authid;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"si",params,authid);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 변경할 권한의 번호를 입력해 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 변경할 권한의 번호를 입력해 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //스코어 입력
			{
				//스코어가 제대로 입력되지 않은 경우
				if( !isNumeric(tmp) || strval(tmp) < 0 )
				{
					if( CONSOLE ) print("[rcon] 권한번호를 제대로 입력해 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 권한번호를 제대로 입력해 주십시오.");
					return 1;
				}
				authid = strval(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}
	
	if( (isnull(tmp) && giveplayerid != INTERACTIVE_MANAGEMENT) || authid < 0) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 부운영자의 권한을 %s(%d)로 변경하였습니다.", (authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"), authid );
			else
			{
				format(str,sizeof(str),"* 모든 부운영자의 권한을 %s(%d)로 변경하였습니다.", (authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"), authid );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 부운영자의 권한을 %s(%d)로 변경하였습니다.", GetPlayerNameEx(playerid), playerid, (authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"), authid );
			}
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 부운영자의 권한을 %s(%d)로 변경하였습니다.", GetPlayerNameEx(playerid), (authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"), authid );
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				if( IsPlayerSubAdmin(pITT[i]) ) LoadPlayerAuthProfile(pITT[i], authid);
			}
			return 1;
		}
	}	

	if(!IsPlayerSubAdmin(giveplayerid))
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 부운영자가 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 부운영자가 아닙니다.");
		return 1;
	}

	if(LoadPlayerAuthProfile(giveplayerid,authid))
	{
		new str[202];
		format(str,sizeof(str),"Auth_Profile%d",authid);
		printf("[rcon] 부운영자 %s(%d)님에게 %d번 권한(%s)을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"));
		format(str,sizeof(str),"* 부운영자 %s(%d)님에게 %d번 권한(%s)을 주었습니다.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("모든 권한"));
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
	}
	return 1;
}
//==========================================================
public dcmd_authlist( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 사용할 수 있는 권한번호 목록을 살펴봅니다." );
			printf( "[help] 예) %s : 사용할 수 있는 권한번호 목록을 살펴봅니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 사용할 수 있는 권한번호 목록을 살펴봅니다." );
			format( str, sizeof(str), "* 예) /%s : 사용할 수 있는 권한번호 목록을 살펴봅니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 부운영자 기능이 제한되어 있습니다.");
		print("[rcon] 부운영자 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}

	if(CONSOLE)
	{
		print("= 부운영자 권한번호 목록 ===========================");
		print("0 : 모든 권한(운영자와 동일)");
	}
	else
	{
		SendClientMessage(playerid,COLOR_GREY,"= 부운영자 권한번호 목록 ===========================");
		SendClientMessage(playerid,COLOR_GREY,"0 : 모든 권한(운영자와 동일)");
	}
	new str[134];
	for(new i=1;i<32;i++)
	{
		format(str,sizeof(str),"Auth_Profile%d",i);
		set( str, c_iniGet("[SubAdmin]",str) );
		if( !str[0] ) break;
		format(str,sizeof(str),"%d : %s",i,str);
		if(CONSOLE) printf(str);
		else SendClientMessage(playerid,COLOR_GREY,str);
	}
	if(CONSOLE) print(LINE);
	else SendClientMessage(playerid,COLOR_GREY,LINE_CLIENT);
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_gravity(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 서버의 중력을 변경합니다. 기본값은 0.008 입니다." );
			printf( "[help] 예) %s -1: 날아봅시다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 30 : 차에 탑니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 현재 서버의 중력을 변경합니다. 기본값은 0.008 입니다." );
			format( str, sizeof(str), "* 예) /%s -1: 날아봅시다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 30 : 차에 탑니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] 바꾸고 싶은 중력을 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* 바꾸고 싶은 중력을 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || floatstr(params) < -50.0 || floatstr(params) > 50.0 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] 중력을 제대로 입력하여 주십시오." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* 중력을 제대로 입력하여 주십시오." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[37];
	format(str,sizeof(str),"* 중력이 %.3f(으)로 변경되었습니다.",floatstr(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetGravity(floatstr(params));
	printf("[rcon] 중력이 %.3f(으)로 변경되었습니다.",floatstr(params));
	return 1;
}
//==========================================================
public dcmd_weather(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 서버의 날씨를 변경합니다." );
			printf( "[help] 예) %s 0: 서버의 날씨를 0으로 바꿉니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 1337 : 서버의 날씨를 1337로 바꿉니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 현재 서버의 날씨를 변경합니다. 기본값은 0 입니다." );
			format( str, sizeof(str), "* 예) /%s 0: 서버의 날씨를 0으로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 1337 : 서버의 날씨를 1337로 바꿉니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] 바꾸고 싶은 날씨를 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* 바꾸고 싶은 날씨를 입력하여 주십시오. 취소는 ?을 입력하십시오." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 1337 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] 날씨를 제대로 입력하여 주십시오." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* 날씨를 제대로 입력하여 주십시오." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[30];
	format(str,sizeof(str),"* 날씨가 %d(으)로 변경되었습니다.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWeather(strval(params));
	printf("[rcon] 날씨가 %d(으)로 변경되었습니다.",strval(params));
	return 1;
}
//==========================================================
public dcmd_carhp(playerid, tmp[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 플레이어가 타고 있는 차량의 에너지를 수정합니다." );
			printf( "[help] 예) %s 10 100: 10번 사용자의 차량에 불을 붙입니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s coolguy 800: coolguy의 차량을 그럭저럭 괜찮은 상태로 만듭니다.", CURRENT_CMD_NAME );
			printf( "[help] 차량을 완전히 수리하려면 %s 명령어를 참고하십시오.", GetCmdName(CMD_FIXCAR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 플레이어가 타고 있는 차량의 에너지를 수정합니다." );
			format( str, sizeof(str), "* 예) /%s 10 100: 10번 사용자의 차량에 불을 붙입니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy 800: coolguy의 차량을 그럭저럭 괜찮은 상태로 만듭니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 차량을 완전히 수리하려면 %s 명령어를 참고하십시오.", GetCmdName(CMD_FIXCAR) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

		
	new params[MAX_PLAYER_NAME], giveplayerid, Float:energy;
	static INTERACTIVE_ADMIN_TEMP;
	
	sscanf(tmp,"sf",params,energy);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //숫자 입력
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] 설정할 차량의 에너지를 적어 주십시오.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* 설정할 차량의 에너지를 적어 주십시오.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //아머 입력
			{
				//아머가 제대로 입력되지 않은 경우
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] 차량 에너지를 제대로 적어 주십시오.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* 차량 에너지를 제대로 적어 주십시오.");
					return 1;
				}
				energy = floatstr(tmp); //있는 경우
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //사용자
			}
		}
	}	

	if( isnull(tmp) || ((energy < 0.0) && (giveplayerid != INTERACTIVE_MANAGEMENT)) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );

	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			new str[95];
			if( CONSOLE ) printf( "[rcon] 모든 차량의 에너지를 %.1f로 변경했습니다.", energy );
			else
			{
				format(str,sizeof(str),"* 모든 차량의 에너지를 %.1f로 변경했습니다.", energy );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)님이 모든 차량의 에너지를 %.1f로 변경했습니다.", GetPlayerNameEx(playerid), playerid, energy);
			}
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 차량의 에너지를 %.1f으로 변경했습니다.", GetPlayerNameEx(playerid), energy);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				if( IsPlayerInAnyVehicle( pITT[i] ) )
				{
					SetVehicleHealth(GetPlayerVehicleID(pITT[i]), energy );
				#if SAMP03x
					RepairVehicle(GetPlayerVehicleID(pITT[i]));
				#endif
				}				
			}
			return 1;
		}
	}
	
	if(!IsPlayerInAnyVehicle(giveplayerid))
	{
		SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 차량에 탑승하고 있지 않습니다.");
		return 1;
	}
	
	#if SAMP03x
		if( energy >= 1000.0 ) RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), energy);
	new str[80];
	if( CONSOLE )
	{
		format( str, sizeof(str), "* 운영자가 당신의 차량 에너지를 %.1f(으)로 변경하였습니다.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)님의 차량 에너지를 %.1f(으)로 변경하였습니다.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)님의 차량 에너지를 %.1f(으)로 변경하였습니다.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* 운영자 %s(%d)님이 당신의 차량 에너지를 %.1f(으)로 변경하였습니다.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)님이 %s(%d)님의 차량 에너지를 %.1f(으)로 변경하였습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, energy );
	}
	return 1;
}
//==========================================================
public dcmd_fixcar(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 차량을 수리합니다." );
			printf( "[help] 예) %s 10 : 10번 운전자의 차량을 수리합니다.",  CURRENT_CMD_NAME  );
			printf( "[help] 예) %s coolguy : coolguy 님의 차를 쌔삥으로 만듭니다.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 해당 플레이어의 차량을 수리합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 10번 운전자의 차량을 수리합니다.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* 예) /%s coolguy : coolguy 님의 차를 쌔삥으로 만듭니다.",  CURRENT_CMD_NAME  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new giveplayerid = Process_GivePlayerID( playerid, params );
	if(isnull(params)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	switch ( Post_Process( playerid, giveplayerid, CMD_CURRENT ) )
	{
		case PROCESS_COMPLETE: return 1;
		//case ADMIN_ID:		
		//case INTERACTIVE_MANAGEMENT:
		case ALL_PLAYER_ID:
		{
			if( CONSOLE ) print( "[rcon] 모든 플레이어의 차량을 수리했습니다.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* 모든 플레이어의 차량을 수리했습니다.");
				printf("[rcon] %s(%d)님이 모든 플레이어의 차량을 수리했습니다.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* 운영자 %s(이)가 모든 플레이어의 차량을 수리했습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				if( IsPlayerInAnyVehicle( pITT[i] ) )
				{
					SetVehicleHealth(GetPlayerVehicleID(pITT[i]), 1000.0);
				#if SAMP03x
					RepairVehicle(GetPlayerVehicleID(pITT[i]));
				#endif
				}				
			}
			return 1;
		}
	}	

	if(!IsPlayerInAnyVehicle(giveplayerid))
	{
		SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 차량에 탑승하고 있지 않습니다.");
		return 1;
	}
	
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), 1000.0);
	#if SAMP03x
		RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	new str[65];
	
	if( CONSOLE )
	{
		format( str, sizeof(str), "* 운영자가 당신의 차량을 수리했습니다.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)님의 차량을 수리했습니다.", GetPlayerNameEx(giveplayerid), giveplayerid);
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)님의 차량을 수리했습니다.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* 운영자 %s(%d)님이 당신의 차량을 수리했습니다.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)님이 %s(%d)님의 차량을 수리했습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid);
	}
	return 1;
}
//==========================================================
public dcmd_yell(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 욕필터 기능을 활성화/비활성화 합니다." );
			printf( "[help] 현재 정책: %s", (FILE_YELLFILTER)? ("사용"):("사용하지 않음") );
			printf( "[help] 금지단어 추가는 '%s', 제거는 '%s' 명령어를 참조하세요.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 욕필터 기능을 활성화/비활성화 합니다." );
			format( str, sizeof(str), "* 현재 정책: %s", (FILE_YELLFILTER)? ("사용"):("사용하지 않음") ); SEND();
			format( str, sizeof(str), "* 금지단어 추가는 '%s', 제거는 '%s' 명령어를 참조하세요.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 욕필터 기능이 제한되어 있습니다.");
		print("[rcon] 욕필터 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	USE_YELLFILTER = !USE_YELLFILTER;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_YELLFILTER? ("* 욕필터 기능이 시작되었습니다."):("* 욕필터 기능이 종료되었습니다.")));
	print((USE_YELLFILTER? ("[rcon] 욕필터 기능이 시작되었습니다."):("[rcon] 욕필터 기능이 종료되었습니다.")));
	#pragma unused playerid,params
	return 1;
}
//==========================================================
public dcmd_addyell(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 욕필터 기능의 세부 설정입니다." );
			print( "[help] 특정 단어를 금지어 목록에 추가합니다. 금지된 말은 **로 표시됩니다." );
			printf( "[help] 예) %s 젠장 : '젠장' 이라는 말을 사용하지 못하게 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 욕필터 기능을 활성화 / 비활성화 하려면 '%s' 를 참고하세요.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 욕필터 기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 특정 단어를 금지어 목록에 추가합니다. 금지된 말은 **로 표시됩니다." );
			format( str, sizeof(str), "* 예) /예) %s 젠장 : '젠장' 이라는 말을 사용하지 못하게 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 욕필터 기능을 활성화 / 비활성화 하려면 '%s' 를 참고하세요.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 욕필터 기능이 제한되어 있습니다.");
		print("[rcon] 욕필터 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	new File:fhandle, str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] 필터에 추가할 금지어를 입력하십시오.");
		else SendClientMessage(playerid,COLOR_GREY,"* 필터에 추가할 금지어를 입력하십시오.");
		return 1;
	}
	if(num_Yells == MAX_YELLS)
	{
		if(CONSOLE) print("[rcon] 더이상 금지어를 추가하실 수 없습니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 더이상 금지어를 추가하실 수 없습니다.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] 금지어 길이가 너무 깁니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 금지어 길이가 너무 깁니다.");
		return 1;
	}
	if( IsYellExists(params) )
	{
		if(CONSOLE) print("[rcon] 이미 존재하는 금지어입니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 이미 존재하는 금지어입니다.");
		return 1;
	}
	fhandle=fopen(FILE_YELLFILTER,io_append);
	if(!fhandle)
	{
		if(CONSOLE) print("[rcon] 금지어 추가에 실패했습니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 금지어 추가에 실패했습니다.");
		return 1;
	}
	fseek(fhandle,0,seek_end);
	c_fwrite(fhandle,"\r\n");
	c_fwrite(fhandle,params);
	fclose(fhandle);
	set( YELLS[num_Yells], params );
	num_Yells++;
	format(str, sizeof(str),"* 운영자 %s(이)가 \"%s\"을(를) 금지어로 설정하였습니다.",GetPlayerNameEx(playerid),params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[rcon] 새로운 금지어 \"%s\"를 추가하였습니다.",params);
	return 1;
}
//==========================================================
public dcmd_delyell( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 욕필터 기능의 세부 설정입니다." );
			print( "[help] 금지어 구문에서 해당 내용을 제거합니다." );
			printf( "[help] 예) %s 젠장 : '젠장' 이라는 말의 사용을 허용합니다.", CURRENT_CMD_NAME );
			printf( "[help] 욕필터 기능을 활성화 / 비활성화 하려면 '%s' 를 참고하세요.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 욕필터 기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 금지어 구문에서 해당 내용을 제거합니다." );
			format( str, sizeof(str), "* 예) /%s 젠장 : '젠장' 이라는 말의 사용을 허용합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 욕필터 기능을 활성화 / 비활성화 하려면 '%s' 를 참고하세요.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 욕필터 기능이 제한되어 있습니다.");
		print("[rcon] 욕필터 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	new File:fohnd,File:fwhnd,bool:dontwrite=false,bool:infile=false,str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] 필터에서 제거할 금지어를 입력하십시오.");
		else SendClientMessage(playerid,COLOR_GREY, "* 필터에서 제거할 금지어를 입력하십시오.");
		return 1;
	}
	if(num_Yells==0)
	{
		if(CONSOLE) print("[rcon] 파일에 제거할 금지어가 없습니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 파일에 제거할 금지어가 없습니다.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] 금지어 길이가 너무 깁니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 금지어 길이가 너무 깁니다.");
		return 1;
	}
	format( str, sizeof(str), "%s_", FILE_YELLFILTER );
	frename(FILE_YELLFILTER, str );
	fohnd=fopen( str, io_read);
	fwhnd=fopen(FILE_YELLFILTER,io_write);
	if( !fohnd || !fwhnd )
	{
		if(CONSOLE) print("[rcon] 금지어 제거에 실패했습니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 금지어 제거에 실패했습니다.");
		return 1;
	}
	while(fread(fohnd,str))
	{
		if(infile || str[0]=='#')
		{
			c_fwrite(fwhnd,str);
			continue;
		}
		StripNL(str);
		if( !str[0] || !str[1] ) dontwrite=true;
		else if (str[0]==' ') str = ret_memcpy(str,1,MAX_STRING);

		if( !strcmp( str, params) )
		{
			dontwrite=true;
			infile=true;
		}
		if(!dontwrite)
		{
			format(str,sizeof(str),"%s\r\n",str);
			c_fwrite(fwhnd,str);
		}
		dontwrite=false;
	}
	fclose(fohnd);
	fclose(fwhnd);
	format( str, sizeof(str), "%s_", FILE_YELLFILTER );
	fremove( str );
	if(!infile)
	{
		if(CONSOLE) print("[rcon] 존재하는 금지어가 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY, "* 존재하는 금지어가 아닙니다.");
		return 1;
	}
	LoadYellList();
	format(str,MAX_STRING,"* 알림 : \"%s\"은(는) 더이상 금지어가 아닙니다. ",params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[info] 금지어 \"%s\"를 제거하였습니다.",params);
	return 1;
}
//==========================================================
public dcmd_chatflood(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 도배방지 기능을 활성화/비활성화 합니다." );
			printf( "[help] 현재 정책: %s", (USE_ANTI_CHATFLOOD)? ("사용"):("사용하지 않음") );
			print( "[help] 도배방지 기능의 세부설정은 RconController.ini에서 수정하세요." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 도배방지 기능을 활성화/비활성화 합니다." );			
			format( str, sizeof(str), "* 현재 정책: %s", (USE_ANTI_CHATFLOOD)? ("사용"):("사용하지 않음") ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 도배방지 기능의 세부설정은 RconController.ini에서 수정하세요." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_ANTI_CHATFLOOD = !USE_ANTI_CHATFLOOD;
	if( USE_ANTI_CHATFLOOD ) 	StaticTimer[ChatFlood] = SetTimer("ResetChatFlood", CHATFLOOD_UNIT_TIME * 1000, 1);
	else
	{
		KillTimer( StaticTimer[ChatFlood] );
		StaticTimer[ChatFlood] = -1;
	}
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_CHATFLOOD? ("* 도배방지 기능이 시작되었습니다."):("* 도배방지 기능이 종료되었습니다.")));
	print((USE_ANTI_CHATFLOOD? ("[rcon] 도배방지 기능이 시작되었습니다."):("[rcon] 도배방지 기능이 종료되었습니다.")));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_wpcheat(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 무기핵 방지기능을 활성화/비활성화 합니다." );
			printf( "[help] 현재 정책: %s", (USE_ANTI_WEAPONCHEAT)? ("사용"):("사용하지 않음") );
			printf( "[help] 금지할 무기를 추가 및 제거하려면 '%s' / '%s' 를 참고하세요.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 무기핵 방지기능을 활성화/비활성화 합니다." );
			format( str, sizeof(str), "* 현재 정책: %s", (USE_ANTI_WEAPONCHEAT)? ("사용"):("사용하지 않음") ); SEND();
			format( str, sizeof(str), "* 금지할 무기를 추가 및 제거하려면 '%s' / '%s' 를 참고하세요.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_ANTI_WEAPONCHEAT = !USE_ANTI_WEAPONCHEAT;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_WEAPONCHEAT? ("* 무기핵 방지기능이 시작되었습니다."):("* 무기핵 방지기능이 종료되었습니다.")));
	print((USE_ANTI_WEAPONCHEAT? ("[rcon] 무기핵 방지기능이 시작되었습니다."):("[rcon] 무기핵 방지기능이 종료되었습니다.")));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_addwc(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 무기핵 방지기능의 세부 설정입니다." );
			print( "[help] 특정 무기의 사용을 금지합니다. 무기 사용시 추방됩니다." );
			printf( "[help] 예) %s 38: 미니건의 사용을 금지합니다.", CURRENT_CMD_NAME );
			printf( "[help] 무기 번호는 0 ~ %d 사이이며, 자세한 사항은 SA-MP Wiki를 참조하세요.", MAX_WEAPONS );
			printf( "[help] 무기핵 방지기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 무기핵 방지기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 특정 무기의 사용을 금지합니다. 무기 사용시 추방됩니다." );
			format( str, sizeof(str), "* 예) /%s 38: 미니건의 사용을 금지합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 무기 번호는 0 ~ %d 사이이며, 자세한 사항은 SA-MP Wiki를 참조하세요.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* 무기핵 방지기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] 사용법 : 무기추가 or addweapon [무기번호]");
		else SendClientMessage(playerid,COLOR_GREY,"* 사용법 : /무기추가 or /addweapon [무기번호]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] 잘못된 무기번호입니다. 무기번호는 '무기번호.txt'를 참조하세요.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못된 무기번호입니다. 무기번호는 '무기번호.txt'를 참조하세요.");
		return 1;
	}

	new weaponid = strval( params );
	if( IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] 이미 금지되어 있는 무기입니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 이미 금지되어 있는 무기입니다.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 1;
	new str[148], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* 운영자 %s(이)가 금지무기 목록에 무기 %s(%d)를 추가하였습니다. 해당 무기 사용시 추방됩니다.", GetPlayerNameEx(playerid), weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] 금지무기 목록에 무기 %s(%d)를 추가하였습니다.",  weapon_name, weaponid );
	return 1;
}
//==========================================================
public dcmd_delwc(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 무기핵 방지기능의 세부 설정입니다." );
			print( "[help] 특정 무기의 사용을 허용합니다." );			
			printf( "[help] 예) %s 38: 미니건의 사용을 허용합니다.", CURRENT_CMD_NAME );
			printf( "[help] 무기 번호는 0 ~ %d 사이이며, 자세한 사항은 SA-MP Wiki를 참조하세요.", MAX_WEAPONS );
			printf( "[help] 무기핵 방지기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 무기핵 방지기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 특정 무기의 사용을 허용합니다." );
			format( str, sizeof(str), "* 예) /%s 38: 미니건의 사용을 허용합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 무기 번호는 0 ~ %d 사이이며, 자세한 사항은 SA-MP Wiki를 참조하세요.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* 무기핵 방지기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] 사용법 : 무기제거 or delweapon [무기번호]");
		else SendClientMessage(playerid,COLOR_GREY,"* 사용법 : /무기제거 or /delweapon [무기번호]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] 잘못된 무기번호입니다. 무기번호는 '무기번호.txt'를 참조하세요.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못된 무기번호입니다. 무기번호는 '무기번호.txt'를 참조하세요.");
		return 1;
	}

	new weaponid = strval( params );
	if( !IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] 금지되어있지 않은 무기입니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 이미 금지되어있지 않은 무기입니다.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 0;
	new str[128], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* 알림 : 이제 무기 %s(%d)를 사용해도 추방되지 않습니다.", weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] 금지무기 목록에서 무기 %s(%d)를 제거하였습니다.",  weapon_name, weaponid );
	return 1;
}
//==========================================================
public dcmd_jpcheat(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 제트팩 사용을 허용/불허 합니다." );
			print( "[help] 불허한 경우, 제트팩 사용시 강제추방 합니다." );
			printf( "[help] 현재 정책: %s", (ALLOW_JETPACK)? ("허용"):("허용하지 않음") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 제트팩 사용을 허용/불허 합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 불허한 경우, 제트팩 사용시 강제추방 합니다." );
			format( str, sizeof(str), "* 현재 정책: %s", (ALLOW_JETPACK)? ("허용"):("허용하지 않음") ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	ALLOW_JETPACK = !ALLOW_JETPACK;
	SendClientMessageToAll(COLOR_GREENYELLOW,((!ALLOW_JETPACK)? ("* 알림 : 이제부터 제트팩을 사용하면 추방됩니다."):("* 알림 : 이제 제트팩을 사용해도 추방되지 않습니다.")));
	print(((!ALLOW_JETPACK)? ("[rcon] 제트팩 사용을 금지했습니다."):("[rcon] 제트팩 사용을 허용했습니다.")));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_cmdflood(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 명령어 도배방지 기능을 활성화 / 비활성화 합니다." );
			print( "[help] '/' 로 시작하는 명령어를 도배하여 시스템에 부하를 주는 악성 인원을 추방하는 기능입니다." );			
			printf( "[help] 현재 정책: %s", (USE_ANTI_CMDFLOOD)? ("사용"):("사용하지 않음") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 명령어 도배방지 기능을 활성화 / 비활성화 합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* '/' 로 시작하는 명령어를 도배하여 시스템에 부하를 주는 악성 인원을 추방하는 기능입니다." );
			format( str, sizeof(str), "* 현재 정책: %s", (USE_ANTI_CMDFLOOD)? ("사용"):("사용하지 않음") ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_ANTI_CMDFLOOD = !USE_ANTI_CMDFLOOD;
	if( USE_ANTI_CMDFLOOD ) 	StaticTimer[CmdFlood] = SetTimer("ResetCmdFlood", CMDFLOOD_UNIT_TIME * 1000, 1);
	else
	{
		KillTimer( StaticTimer[CmdFlood] );
		StaticTimer[CmdFlood] = -1;
	}
	SendClientMessageToAll(COLOR_GREENYELLOW,((USE_ANTI_CMDFLOOD)? ("* 명령어도배 방지기능이 시작되었습니다."):("* 명령어도배 방지기능이 종료되었습니다.")));
	print(((USE_ANTI_CMDFLOOD)? ("[rcon] 명령어도배 방지기능을 시작했습니다."):("[rcon] 명령어도배 방지기능을 종료했습니다.")));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_ping(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 핑정리 기능을 활성화 / 비활성화 합니다." );
			print( "[help] 인터넷이 느려 원활한 플레이를 저해하는 인원을 경고 또는 추방하는 기능입니다." );			
			printf( "[help] 현재 정책: %s", (USE_PINGCHECK)? ("사용"):("사용하지 않음") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 핑정리 기능을 활성화 / 비활성화 합니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 인터넷이 느려 원활한 플레이를 저해하는 인원을 경고 또는 추방하는 기능입니다." );
			format( str, sizeof(str), "* 현재 정책: %s", (USE_PINGCHECK)? ("사용"):("사용하지 않음") ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_PINGCHECK = !USE_PINGCHECK;
	if( USE_PINGCHECK && RESET_HIGHPING_TICK ) StaticTimer[ResetPing] = SetTimer("ResetPingCheck", RESET_HIGHPING_TICK * 1000, 1);
	else
	{
		KillTimer( StaticTimer[ResetPing] );
		StaticTimer[ResetPing] = -1;
	}
	SendClientMessageToAll( COLOR_GREENYELLOW, (USE_PINGCHECK)? ("* 핑정리 기능이 시작되었습니다."):("* 핑정리 기능이 종료되었습니다.") );
	print((USE_PINGCHECK)? ("[rcon] 핑정리 기능이 시작되었습니다."):("[rcon] 핑정리 기능이 종료되었습니다."));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_plimit(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 핑정리 기능의 세부 설정입니다." );
			print( "[help] 인터넷 지연시간이 일정 이상인 경우 경고 또는 추방조치를 합니다." );			
			printf( "[help] 예) %s 200: 지연시간이 200ms를 넘어갈 경우 %d회 경고후 추방합니다.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT );
			printf( "[help] 현재 경고기준: %dms", HIGHPING_LIMIT );
			printf( "[help] 핑 정리 기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 핑정리 기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 인터넷 지연시간이 일정 이상인 경우 경고 또는 추방조치를 합니다." );	
			format( str, sizeof(str), "* 예) /%s 200: 지연시간이 200ms를 넘어갈 경우 %d회 경고후 추방합니다.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* 현재 경고기준: %dms", HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* 핑 정리 기능을 활성화/비활성화 하려면 '/%s'를 참고하세요.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new ping;
	if( sscanf( params, "i", ping ) || ping < 1 )
	{
		if(CONSOLE) print("[rcon] 사용법 : 핑제한 or /setplimit [핑]");
		else SendClientMessage(playerid,COLOR_GREY,"* 사용법 : 핑제한 or /setplimit [핑]");
		return 1;
	}
	HIGHPING_LIMIT = ping;
	new str[48];
	format( str, sizeof(str), "* 핑정리 기준이 %dms로 변경되었습니다.", HIGHPING_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] 핑정리 기준을 %dms로 변경했습니다.", HIGHPING_LIMIT );
	return 1;
}
//==========================================================
public dcmd_pwarntime(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 핑정리 기능의 세부 설정입니다." );
			print( "[help] 일정 이상 경고를 받은 인원을 추방하게 합니다." );			
			printf( "[help] 예) %s 3: 지연시간이 %dms를 넘어갈 경우 3회 경고후 추방합니다.", CURRENT_CMD_NAME, HIGHPING_LIMIT );
			printf( "[help] 현재 경고횟수: %d회", HIGHPING_WARN_LIMIT );
			printf( "[help] 핑 정리 기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 핑정리 기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 일정 이상 경고를 받은 인원을 추방하게 합니다." );		
			format( str, sizeof(str), "* 예) /%s 3: 지연시간이 %dms를 넘어갈 경우 3회 경고후 추방합니다.", CURRENT_CMD_NAME, HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* 현재 경고횟수: %d회", HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* 핑 정리 기능을 활성화/비활성화 하려면 '/%s'를 참고하세요.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new warningtime;
	if( sscanf( params, "i", warningtime ) || warningtime < 1 )
	{
		if(CONSOLE) print("[rcon] 사용법 : 핑경고 or /setpwarn [횟수]");
		else SendClientMessage(playerid,COLOR_GREY,"* 사용법 : 핑제한 or /setpwarn [횟수]");
		return 1;
	}
	HIGHPING_WARN_LIMIT = warningtime;
	new str[56];
	format( str, sizeof(str), "* 이제부터 핑 기준을 %d번 초과하면 추방됩니다.", HIGHPING_WARN_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] 핑 기준초과 경고횟수를 %d번으로 조절하였습니다.",HIGHPING_WARN_LIMIT );
	return 1;
}
//==========================================================
public dcmd_preset(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 핑정리 기능의 세부 설정입니다." );
			print( "[help] 일정시간 이후 인터넷이 느린 플레이어의 누적값을 초기화 합니다." );
			printf( "[help] 예) %s : 현재 접속중인 플레이어의 경고 횟수를 초기화 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 10 : 경고 횟수를 매 10초마다 초기화 합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 0 : 경고 횟수를 없애지 않습니다. 임계값을 넘어가면 자동으로 추방합니다.", CURRENT_CMD_NAME );
			printf( "[help] 현재 초기화 기준: %d초마다 초기화(0: 초기화하지 않음).", RESET_HIGHPING_TICK );
			printf( "[help] 핑 정리 기능을 활성화/비활성화 하려면 '%s'를 참고하세요.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 핑정리 기능의 세부 설정입니다." );
			SendClientMessage( playerid, COLOR_LIME, "* 일정시간 이후 인터넷이 느린 플레이어의 누적값을 초기화 합니다." );
			format( str, sizeof(str), "* 예) /%s : 현재 접속중인 플레이어의 경고 횟수를 초기화 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 10 : 경고 횟수를 매 10초마다 초기화 합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 0 : 경고 횟수를 없애지 않습니다. 임계값을 넘어가면 자동으로 추방합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 현재 초기화 기준: %d초마다 초기화(0: 초기화하지 않음).", RESET_HIGHPING_TICK ); SEND();
			format( str, sizeof(str), "* 핑 정리 기능을 활성화/비활성화 하려면 '/%s'를 참고하세요.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//입력하지 않은 경우 단순 핑정리 초기화
	if( isnull(params) )
	{
		ResetPingCheck( );
		if( CONSOLE ) print("[rcon] 지연시간 경고횟수를 초기화 하였습니다.");
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* 지연시간 경고횟수를 초기화 하였습니다." );
		return 1;
	}
	new resetping_tick;
	if( sscanf( params, "i", resetping_tick ) || resetping_tick < 0 )
	{
		if( CONSOLE ) print("[rcon] 사용법 : 핑초기화 또는 resetping [시간=초기화, 0=사용안함]");
		else SendClientMessage( playerid, COLOR_GREY, "* 사용법 : /핑초기화 또는 /resetping [시간=초기화, 0=사용안함]" );
		return 1;
	}
	
	RESET_HIGHPING_TICK = resetping_tick;
	new str[80];
	if( !RESET_HIGHPING_TICK )
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "* 이제 지연시간 경고횟수를 초기화하지 않습니다." );
		print("[rcon] 이제 지연시간 경고횟수를 초기화하지 않습니다." );
	}
	else
	{
		format( str, sizeof(str), "* 이제부터 %d초마다 핑정리 경고횟수를 초기화합니다.", RESET_HIGHPING_TICK );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] 핑정리 경고횟수 초기화 시간을 %d초로 조절하였습니다.", RESET_HIGHPING_TICK );
	}	
	//핑정리 중이었던 경우 타이머 리셋
	if( USE_PINGCHECK )
	{
		KillTimer( StaticTimer[ResetPing] );
		if( RESET_HIGHPING_TICK ) StaticTimer[ResetPing] = SetTimer("ResetPingCheck", RESET_HIGHPING_TICK * 1000, 1);
		else StaticTimer[ResetPing] = -1;
	}
	return 1;
}
//==========================================================
public dcmd_drop(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 차량에 탑승중인 플레이어를 강제로 내리게 합니다." );
			printf( "[help] 예) %s coolguy : 'coolguy' 를 차에서 내리게 합니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 차량에 탑승중인 플레이어를 강제로 내리게 합니다." );
			format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy' 를 차에서 내리게 합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new giveplayerid;

	if(isnull(params))
	{
		if(CONSOLE) print("[rcon] 사용법 : /내리기 or /sdrop [이름이나 번호]");
		else SendClientMessage(playerid, COLOR_GREY, "* 사용법 : /내리기 or /sdrop [이름이나 번호]");
		return 1;
	}
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		return 1;
	}

	if( !IsPlayerInAnyVehicle( giveplayerid ) )
	{
		if(CONSOLE) print("[rcon] 해당 플레이어는 차에 타고있지 않습니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 해당 플레이어는 차에 타고있지 않습니다.");
		return 1;
	}

	RemovePlayerFromVehicle( giveplayerid );

	new str[83];
	format( str, sizeof(str), "* 운영자 %s(이)가 %s(%d)님을 차에서 내리게 했습니다.", GetPlayerNameEx(playerid), GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] %s(%d)님을 차량에서 내리게 했습니다.", GetPlayerNameEx( giveplayerid ), giveplayerid );
	return 1;
}
//==========================================================
public dcmd_spectate(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어를 감시하기 시작합니다." );
			printf( "[help] 예) %s coolguy : 'coolguy' 를 감시하기 시작합니다.", CURRENT_CMD_NAME );
			print( "[help] 콘솔에서는 사용이 불가능한 명령어입니다." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 해당 플레이어를 감시하기 시작합니다." );
			format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy' 를 감시하기 시작합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] 콘솔에서 사용이 불가능한 명령어입니다.");
		return 1;
	}
	new giveplayerid;

	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "* 사용법 : /감시 or /spectate [이름이나 번호]");
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else return SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");

	new str[83];

	if( IS_PLAYER_SPECTATED[giveplayerid] != INVALID_PLAYER_ID )
	{
		format( str, sizeof(str), "* 해당 플레이어는 이미 %s(%d)님이 감시중입니다.", GetPlayerNameEx(IS_PLAYER_SPECTATED[giveplayerid]), IS_PLAYER_SPECTATED[giveplayerid] );
		SendClientMessage( playerid, COLOR_GREY, str );
		return 1;
	}
	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
	}
	TogglePlayerSpectating(playerid, 1);
	if( IsPlayerInAnyVehicle( giveplayerid ) ) PlayerSpectateVehicle(playerid, GetPlayerVehicleID(giveplayerid));
	else PlayerSpectatePlayer(playerid, giveplayerid);
	SetPlayerInterior(playerid,GetPlayerInterior(giveplayerid));
	IS_PLAYER_SPECTATING[playerid] = giveplayerid;
	IS_PLAYER_SPECTATED[giveplayerid] = playerid;

	format( str, sizeof(str), "* %s(%d)님을 감시하기 시작합니다.", GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* 해제하시려면 /%s 또는 /%s 을(를) 입력하세요.", GetCmdName(CMD_SPECOFF), GetCmdAltName(CMD_SPECOFF) );
	SendClientMessage( playerid, COLOR_ORANGE, str );
	printf("[rcon] %s(%d)님이 %s(%d)님을 감시하기 시작했습니다.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx( giveplayerid ), giveplayerid );
	return 1;
}
//==========================================================
public dcmd_specoff(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 작동중인 감시모드를 해제합니다." );
			printf( "[help] 예) %s : 현재 작동중인 감시모드를 해제합니다.", CURRENT_CMD_NAME );
			print( "[help] 콘솔에서는 사용이 불가능한 명령어입니다." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 현재 작동중인 감시모드를 해제합니다." );
			format( str, sizeof(str), "* 예) /%s : 현재 작동중인 감시모드를 해제합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] 콘솔에서 사용이 불가능한 명령어입니다.");
		return 1;
	}
	/* if( GetPlayerState( playerid ) != PLAYER_STATE_SPECTATING )
	{
		SendClientMessage( playerid, COLOR_GREY, "* 감시중이 아닙니다." );
		return 1;
	} */

	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	TogglePlayerSpectating(playerid, 0);
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* 감시모드를 해제했습니다." );
	printf("[rcon] %s(%d)님이 감시모드를 해제했습니다.", GetPlayerNameEx(playerid), playerid);
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_desync(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 잠수방지 기능을 작동/해제합니다." );
			printf( "[help] 예) %s 0 : ESC키를 눌러서 잠수하면 자동으로 추방합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 1 : %d초이상 잠수타는 경우 추방합니다.", CURRENT_CMD_NAME, DESYNC_LIMIT );
			printf( "[help] 예) %s 2 : 잠수를 허용합니다.", CURRENT_CMD_NAME );
			print( "[help] 잠수방지 시간 기준은 RconController.ini에서 수정하세요." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 잠수방지 기능을 작동/해제합니다." );			
			format( str, sizeof(str), "* 예) /%s 0 : ESC키를 눌러서 잠수하면 자동으로 추방합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 예) /%s 1 : %d초이상 잠수타는 경우 추방합니다.", CURRENT_CMD_NAME, DESYNC_LIMIT ); SEND();
			format( str, sizeof(str), "* 예) /%s 2 : 잠수를 허용합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 잠수방지 시간 기준은 RconController.ini에서 수정하세요." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* 현재 잠수방지 기능이 제한되어 있습니다.");
		print("[rcon] 잠수방지 기능이 제한되어 있습니다. RconController.ini를 로드해 주세요.");
		return 1;
	}
	new desync;
	if( sscanf( params, "i", desync ) || desync < 0 || desync > 2 )
	{
		if(CONSOLE) print("[rcon] 사용법: 잠수 or desync [0 ~ 2]");
		else SendClientMessage( playerid, COLOR_RED, "* 사용법: /잠수 or /desync [0 ~ 2]");
		return 1;
	}
	ALLOW_DESYNC = desync;
	switch(desync)
	{
		case 0:
		{
			DESYNC_LIMIT = 5;
			SendClientMessageToAll(COLOR_GREENYELLOW, "* 알림 : 이제부터 ESC키를 눌러 잠수하면 추방됩니다.");
			print("[rcon] 잠수를 금지했습니다.");
		}
		case 1:
		{
			DESYNC_LIMIT = c_iniInt( "[General]", "DESYNC_LIMIT" );
			SendFormatMessageToAll(COLOR_GREENYELLOW, "* 알림 : 이제부터 %d초이상 ESC키를 눌러 잠수하면 추방됩니다.", DESYNC_LIMIT);
			printf("[rcon] 잠수를 %d초까지만 허용했습니다.", DESYNC_LIMIT);
		}
		case 2:
		{
			SendClientMessageToAll(COLOR_GREENYELLOW, "* 알림 : 이제부터 ESC키를 눌러 잠수해도 추방되지 않습니다.");
			print("[rcon] 잠수를 허용했습니다.");
		}
	}
	return 1;
}
//==========================================================
public dcmd_mks( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 시스템 비프음을 발생합니다. (Windows 7부터는 작동하지 않습니다.)" );
			printf( "[help] 예) %s 3,관리자님 헬프 : 비프음을 3회 발생하며, '관리자님 헬프' 라는 메세지를 띄웁니다.", CURRENT_CMD_NAME );			
			printf( "[help] 관리자에게 개인 메세지를 보내려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_SPM) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 시스템 비프음을 발생합니다. (Windows 7부터는 작동하지 않습니다.)" );
			format( str, sizeof(str), "* 예) /%s 3,관리자님 헬프 : 비프음을 3회 발생하며, '관리자님 헬프' 라는 메세지를 띄웁니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 관리자에게 개인 메세지를 보내려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_SPM) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new str[128], itteration;
	if( sscanf(params, "p,is", itteration, str) || itteration < 0 )
	{
		if(CONSOLE) print("[rcon] 사용법: 소리내기 or mks [비프음 횟수],[할말] - 띄어쓰기 대신 컴마로 구분해주세요.");
		else SendClientMessage( playerid, COLOR_GREY, "* 사용법: /소리내기 or /mks [비프음 횟수],[할말] - 띄어쓰기 대신 컴마로 구분해주세요.");
		return 1;
	}
	if( itteration > 5 )
	{
		if(CONSOLE) print("[rcon] 비프음은 5회까지만 설정 가능합니다.");
		else SendClientMessage( playerid, COLOR_GREY, "* 비프음은 5회까지만 설정 가능합니다.");
		return 1;
	}
	if (CONSOLE) printf("[call] 콘솔로부터 운영자 호출입니다. : %s", str);
	else printf("[call] 운영자 %s(%d)의 호출입니다: %s", GetPlayerNameEx(playerid), playerid, str);
	str[0] = EOS;
	for( new i = 0; i < itteration; i++ ) format( str, sizeof(str), "%s\a", str );
	print(str);
	return 1;
}
//==========================================================
public dcmd_loadconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] RconController.ini에 저장된 서버 설정을 다시 읽어옵니다." );
			printf( "[help] 현재 설정을 파일로 저장하려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_SAVECONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* RconController.ini에 저장된 서버 설정을 다시 읽어옵니다." );
			format( str, sizeof(str), "* 현재 설정을 파일로 저장하려면 '/%s'을(를) 참고하세요.", GetCmdName(CMD_SAVECONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini를 찾을 수 없습니다. 설정 부르기를 사용할 수 없습니다.");
		print("[rcon] RconController.ini를 찾을 수 없습니다. 설정 부르기를 사용할 수 없습니다.");
		return 1;
	}
	LoadUserConfigs(1);
	SendClientMessageToAll( COLOR_GREENYELLOW, "* 서버의 정책이 변경되었습니다." );
	print("[rcon] 서버의 설정을 다시 불러왔습니다.");
	#pragma unused playerid,params
	return 1;
}
//==========================================================
public dcmd_saveconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 서버의 현재 정책을 RconController.ini에 저장합니다." );
			printf( "[help] 서버의 설정을 파일로부터 읽어오려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_LOADCONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 서버의 현재 정책을 RconController.ini에 저장합니다." );
			format( str, sizeof(str), "* 서버의 설정을 파일로부터 읽어오려면 '/%s'을(를) 참고하세요.", GetCmdName(CMD_LOADCONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini를 찾을 수 없습니다. 설정 저장기능을 사용할 수 없습니다.");
		print("[rcon] RconController.ini를 찾을 수 없습니다. 설정 저장기능을 사용할 수 없습니다.");
		return 1;
	}
	SaveUserConfigs( );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, "* 현재 서버의 정책을 저장했습니다." );
	#pragma unused playerid,params
	return 1;
}
//==========================================================
public dcmd_unban(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 플레이어의 아이디로 걸린 밴을 해제합니다." );
			printf( "[help] 예) %s coolguy : 'coolguy'가 접속하는 것을 허용합니다.", CURRENT_CMD_NAME );
			printf( "[help] IP를 사용하여 밴을 풀려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_UNBANIP) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 해당 플레이어의 아이디로 걸린 밴을 해제합니다." );
			format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy'가 접속하는 것을 허용합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* IP를 사용하여 밴을 풀려면 '/%s'을(를) 참고하세요.", GetCmdName(CMD_UNBANIP) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || strlen(params) >= MAX_PLAYER_NAME )
	{
		if(CONSOLE) printf("[rcon] 사용법: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
		else
		{
			new str[128];
			format(str, sizeof(str), "* 사용법: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND_C(COLOR_RED);
		}
		return 1;
	}

	new str[50];
	format( str, sizeof(str), "unban %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* %s님을 밴목록에서 제거했습니다.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] %s님을 밴목록에서 제거했습니다.", params );
	return 1;
}
//==========================================================
public dcmd_unbanip( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 해당 IP에 걸린 밴을 해제합니다." );
			printf( "[help] 예) %s 192.168.0.1 : 해당 IP의 유저가 접속하는 것을 허용합니다.", CURRENT_CMD_NAME );
			printf( "[help] 아이디를 사용하여 밴을 풀려면 '%s'을(를) 참고하세요.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 해당 IP에 걸린 밴을 해제합니다." );
			format( str, sizeof(str), "* 예) /%s 192.168.0.1 : 해당 IP의 유저가 접속하는 것을 허용합니다.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* 아이디를 사용하여 밴을 풀려면 '/%s'을(를) 참고하세요.", GetCmdName(CMD_UNBAN) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] 사용법: 아이피밴풀기 or unbanip [아이디]");
		else SendClientMessage( playerid, COLOR_GREY, "* 사용법: /아이피밴풀기 or /unbanip [아이디]");
		return 1;
	}
	if( !IsValidIP(params) )
	{
		if(CONSOLE) print("[rcon] 아이피를 제대로 입력하세요.");
		else SendClientMessage( playerid, COLOR_ORANGE, "* 아이피를 제대로 입력하세요.");
		return 1;
	}

	new str[59];
	format( str, sizeof(str), "unbanip %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* 아이피 %s을(를) 밴목록에서 제거했습니다.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] 아이피 %s을(를) 밴목록에서 제거했습니다.", params );
	return 1;
}
//==========================================================
public dcmd_vkick( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 강제추방하는 투표를 개시합니다." );
			print( "[help] '사용' / '사용안함' 으로 강제추방 투표기능을 활성화/비활성화할 수 있습니다." );
			print( "[help] '중단' 으로 진행중인 투표를 중단할 수 있습니다." );
			printf( "[help] 예) %s 사용 : 강제추방 기능을 사용합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 사용안함 : 강제추방 기능을 사용하지 않습니다.", CURRENT_CMD_NAME );			
			printf( "[help] 예) %s coolguy : 'coolguy'를 추방하는 투표를 개시합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 중단 : 진행중인 강제추방 투표를 중단합니다.", CURRENT_CMD_NAME );
			printf( "[help] 투표 없이 강제추방은 '%s'을(를) 참고하세요.", cmdlist[CMD_KICK][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 강제추방하는 투표를 개시합니다." );
				SendClientMessage( playerid, COLOR_LIME, "* '사용' / '사용안함' 으로 강제추방 투표기능을 활성화/비활성화할 수 있습니다." );
				SendClientMessage( playerid, COLOR_LIME, "* '중단' 으로 진행중인 투표를 중단할 수 있습니다." );
				format( str, sizeof(str), "* 예) /%s 사용 : 강제추방 기능을 사용합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s 사용안함 : 강제추방 기능을 사용하지 않습니다.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy'를 추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s 중단 : 진행중인 강제추방 투표를 중단합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 투표 없이 강제추방은 '%s'을(를) 참고하세요.", cmdlist[CMD_KICK][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 강제추방하는 투표를 개시합니다." );
				format( str, sizeof(str), "* 예) /%s 1 : 1번 플레이어를 추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy'를 추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 투표는 일정 이상 사람이 있어야 가능하며, 투표기능이 비활성화된 경우 운영자에게 문의하세요." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new str[128], giveplayerid;
	
	//관리 명령어. 입력자가 운영자인 경우 관리명령어 입력여부 확인
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //투표 활성화 요청
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "사용", true ) == 0 ) //추방투표 기능 사용
		{
			if( ENABLE_VOTEKICK ) //이미 기능이 활성화된 경우
			{
			    if( CONSOLE ) print("[rcon] 이미 강제추방 투표기능을 사용중입니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 이미 강제추방 투표기능을 사용중입니다.");
			    return 1;
			}
	    	ENABLE_VOTEKICK = 1;

	    	print("[rcon] 강제추방 투표기능을 시작하였습니다.");
			format( str, sizeof(str), "* 운영자 %s(이)가 강제추방 투표기능을 시작하였습니다.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//투표 중단 요청
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "중단", true ) == 0 ) // 투표중단 요청
		{
		    if( VOTEKICK_REMAINTIME <= 0 ) //진행중인 투표가 없는 경우
			{
			    if( CONSOLE ) print("[rcon] 현재 진행중인 강제추방 투표가 없습니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 현재 진행중인 강제추방 투표가 없습니다.");
			    return 1;
			}
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] 진행중인 강제추방 투표를 중단합니다.");
			format( str, sizeof(str), "* 운영자 %s의 요청으로 진행중인 강제추방 투표를 중단합니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//투표 비활성화 요청
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "사용안함", true ) == 0 ) // 투표 비활성화 요청
		{
			if( !ENABLE_VOTEKICK ) //이미 기능이 비활성화된 경우
			{
			    if( CONSOLE ) print("[rcon] 강제추방 투표기능을 사용하지 않고 있습니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 강제추방 투표기능을 사용하지 않고 있습니다.");
			    return 1;
			}
			if ( VOTEKICK_REMAINTIME )
			{
				print("[rcon] 진행중인 강제추방 투표를 중단합니다.");
				format( str, sizeof(str), "* 운영자 %s의 요청으로 진행중인 강제추방 투표를 중단합니다.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEKICK = 0;
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] 강제추방 투표기능을 종료하였습니다.");
			format( str, sizeof(str), "* 운영자 %s(이)가 강제추방 투표기능을 종료하였습니다.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //투표기능을 사용하지 않는경우 메세지 띄움
	if( !ENABLE_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] 현재 강제추방 투표기능을 사용하고 있지 않습니다.\n[rcon] 사용하시려면 '%s 사용'을 입력하세요.", CURRENT_CMD_NAME);
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* 현재 강제추방 투표기능을 사용하고 있지 않습니다. 사용하시려면 '/%s 사용'을 입력하세요.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* 현재 강제추방 투표기능을 사용하고 있지 않습니다. 운영자에게 문의하세요.");
		return 1;
	}

	//일반 투표모드
	if( params[0] ) //무언가 입력했음.
	{
	    //투표를 시도한 경우
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "예", true ) == 0 ) // 투표하기
		{
			if( VOTEKICK_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] 강제추방 투표중이 아닙니다.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* 강제추방 투표중이 아닙니다.");
				return 1;
			}

			if( CONSOLE )
			{
				print("[rcon] 콘솔에서는 투표하실 수 없습니다.");
				return 1;
			}
			
			//투표여부 검사
			new i;
			for( i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
			{
				if( KICKVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //이미 투표하였음
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* 이미 투표하였습니다.");
					return 1;
				}
			}
			//투표하기
			SendClientMessage( playerid, COLOR_GREEN, "* 투표하셨습니다.");
			KICKVOTED_PLAYER_IP[VOTEKICK_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEKICK_PLAYER_GOT++;
			if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // 추방기준 통과
			{
				format( str, sizeof(str), "* 투표가 종료되었습니다. 투표 결과로 %s(%d)님을 강제 추방합니다.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] 투표 결과로 %s(%d)님을 강제 추방합니다.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				VOTEKICK_REMAINTIME = 0;
				c_Kick( VOTEKICK_PLAYER );
			}
			return 1;
		}
		//투표가 진행중인 경우
		if( VOTEKICK_REMAINTIME > 0 )
		{			
			if( CONSOLE ) print("[rcon] 진행중인 투표가 있습니다.");
			else SendClientMessage( playerid, COLOR_GREY, "* 진행중인 투표가 있습니다.");
		}
	}
	
	if( VOTEKICK_REMAINTIME > 0 ) //현재 투표가 진행중
	{
		if( CONSOLE )
		{
			printf("[rcon] 현재 %s(%d)님에 대한 강제추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
			printf("[rcon] 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 추방됩니다.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
			printf("[rcon] 중단하시려면 '%s 중단'을, 투표기능을 없애려면 '%s 사용안함' 을 입력하세요.", CURRENT_CMD_NAME, CURRENT_CMD_NAME);
			return 1;
		}
		format( str, sizeof(str), "* 현재 %s(%d)님에 대한 강제추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), " 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 추방됩니다.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), "* 투표하시려면 '/%s yes' 또는 '/%s 예' 를 입력하세요.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_SALMON); SEND_C(COLOR_GREENYELLOW);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* 중단하시려면 '/%s 중단'을, 투표기능을 없애려면 '/%s 사용안함' 을 입력하세요.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //현재 진행중인 투표 없음. 투표작성 시도가 없었음.
	{
		if( CONSOLE )
		{
			print("[rcon] 현재 진행중인 투표가 없습니다.");
			printf("[rcon] 사용법: %s or %s [이름이나 번호]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] 투표기능을 없애려면 '%s 사용안함'을 입력하세요.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* 현재 진행중인 투표가 없습니다.");
        format( str, sizeof(str),  "* 사용법: /%s 또는 /%s [이름이나 번호]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* 투표기능을 없애려면 '/%s 사용안함'을 입력하세요.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//투표 시작하기
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		return 1;
	}
	
	//최소인원에 미달하는경우
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] 투표를 시작하려면 최소 %d명의 플레이어가 필요합니다.", REQUIRED_MAN_VOTEKICK );
	    else
		{
			format( str, sizeof(str), "* 투표를 시작하려면 최소 %d명의 플레이어가 필요합니다.", REQUIRED_MAN_VOTEKICK ); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//OK.Assign Player Informations.
	VOTEKICK_PLAYER = giveplayerid;
	VOTEKICK_PLAYER_GOT = 0;
	VOTEKICK_TICK = 0;
	VOTEKICK_REMAINTIME = VOTEKICK_RUN_TIME;
	CURRENT_VOTEKICK_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEKICK_PERCENTAGE) / 100;
	
	//신고자 비밀보장의 경우 기밀, 아닌경우 이름 수집
	if( VOTE_CONFIDENTIALITY ) str = "기밀";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("서버주인"):(GetPlayerNameEx(playerid)) );
	//투표 메세지 띄우기
	format( str, sizeof(str), "* %s(%d)님에 대한 강제추방 투표가 신청되었습니다. (신청인: %s)",
		GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, str );
    SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* 투표는 총 %d초간 진행되며, %d명 이상이 찬성하면 추방됩니다.", VOTEKICK_RUN_TIME, CURRENT_VOTEKICK_REQUIREMENT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* 투표하시려면 '/%s yes' 또는 '/%s 예' 를 입력하시면 됩니다.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* 자, 지금부터 투표를 시작합니다!" );
	printf("[rcon] %s(%d)님에 대한 강제추방 투표가 신청되었습니다. (신청인: %s, 신원보호:%s)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, (playerid==ADMIN_ID)? ("서버주인"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("예"):("아니오") );
	return 1;
}
//==========================================================
public dcmd_vban( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 지정한 플레이어를 영구히 추방하는 투표를 개시합니다." );
			print( "[help] '사용' / '사용안함' 으로 영구추방 투표기능을 활성화/비활성화할 수 있습니다." );
			print( "[help] '중단' 으로 진행중인 투표를 중단할 수 있습니다." );
			printf( "[help] 예) %s 사용 : 영구추방 기능을 사용합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 사용안함 : 영구추방 기능을 사용하지 않습니다.", CURRENT_CMD_NAME );			
			printf( "[help] 예) %s coolguy : 'coolguy'를 영구추방하는 투표를 개시합니다.", CURRENT_CMD_NAME );
			printf( "[help] 예) %s 중단 : 진행중인 영구추방 투표를 중단합니다.", CURRENT_CMD_NAME );
			printf( "[help] 투표 없이 영구추방은 '%s'을(를) 참고하세요.", cmdlist[CMD_BAN][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 영구히 추방하는 투표를 개시합니다." );
				SendClientMessage( playerid, COLOR_LIME, "* '사용' / '사용안함' 으로 영구추방 투표기능을 활성화/비활성화할 수 있습니다." );
				SendClientMessage( playerid, COLOR_LIME, "* '중단' 으로 진행중인 투표를 중단할 수 있습니다." );
				format( str, sizeof(str), "* 예) /%s 사용 : 영구추방 기능을 사용합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s 사용안함 : 영구추방 기능을 사용하지 않습니다.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy'를 영구추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s 중단 : 진행중인 영구추방 투표를 중단합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 투표 없이 영구추방은 '%s'을(를) 참고하세요.", cmdlist[CMD_BAN][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 지정한 플레이어를 영구히 추방하는 투표를 개시합니다." );
				format( str, sizeof(str), "* 예) /%s 1 : 1번 플레이어를 영구추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* 예) /%s coolguy : 'coolguy'를 영구추방하는 투표를 개시합니다.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* 투표는 일정 이상 사람이 있어야 가능하며, 투표기능이 비활성화된 경우 운영자에게 문의하세요." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new str[128], giveplayerid;

	//관리 명령어. 입력자가 운영자인 경우 관리명령어 입력여부 확인
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //투표 활성화 요청
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "사용", true ) == 0 ) //추방투표 기능 사용
		{
			if( ENABLE_VOTEBAN ) //이미 기능이 활성화된 경우
			{
			    if( CONSOLE ) print("[rcon] 이미 영구추방 투표기능을 사용중입니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 이미 영구추방 투표기능을 사용중입니다.");
			    return 1;
			}
	    	ENABLE_VOTEBAN = 1;

	    	print("[rcon] 영구추방 투표기능을 시작하였습니다.");
			format( str, sizeof(str), "* 운영자 %s가 영구추방 투표기능을 시작하였습니다.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//투표 중단 요청
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "중단", true ) == 0 ) // 투표중단 요청
		{
		    if( VOTEBAN_REMAINTIME <= 0 ) //진행중인 투표가 없는 경우
			{
			    if( CONSOLE ) print("[rcon] 현재 진행중인 영구추방 투표가 없습니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 현재 진행중인 영구추방 투표가 없습니다.");
			    return 1;
			}
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] 진행중인 영구추방 투표를 중단합니다.");
			format( str, sizeof(str), "* 운영자 %s의 요청으로 진행중인 영구추방 투표를 중단합니다.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//투표 비활성화 요청
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "사용안함", true ) == 0 ) // 투표 비활성화 요청
		{
			if( !ENABLE_VOTEBAN ) //이미 기능이 비활성화된 경우
			{
			    if( CONSOLE ) print("[rcon] 영구추방 투표기능을 사용하지 않고 있습니다.");
			    else SendClientMessage( playerid, COLOR_GREY, "* 영구추방 투표기능을 사용하지 않고 있습니다.");
			    return 1;
			}
			if( VOTEBAN_REMAINTIME )
			{
				print("[rcon] 진행중인 영구추방 투표를 중단합니다.");
				format( str, sizeof(str), "* 운영자 %s의 요청으로 진행중인 영구추방 투표를 중단합니다.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEBAN = 0;
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] 영구추방 투표기능을 종료하였습니다.");
			format( str, sizeof(str), "* 운영자 %s가 영구추방 투표기능을 종료하였습니다.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //투표기능을 사용하지 않는경우 메세지 띄움
	if( !ENABLE_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] 현재 영구추방 투표기능을 사용하고 있지 않습니다.\n[rcon] 사용하시려면 '%s 사용' 을 입력하세요.", CURRENT_CMD_NAME );
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str),  "* 현재 영구추방 투표기능을 사용하고 있지 않습니다. 사용하시려면 '/%s 사용' 을 입력하세요.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* 현재 영구추방 투표기능을 사용하고 있지 않습니다. 운영자에게 문의하세요.");
		return 1;
	}

	//일반 투표모드
	if( params[0] ) //무언가 입력했음.
	{
	    //투표를 시도한 경우
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "예", true ) == 0 ) // 투표하기
		{
			if( VOTEBAN_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] 영구추방 투표중이 아닙니다.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* 영구추방 투표중이 아닙니다.");
				return 1;
			}
			
			if( CONSOLE )
			{
				print("[rcon] 콘솔에서는 투표하실 수 없습니다.");
				return 1;
			}

			//투표여부 검사
			new i;
			for( i = 0; i < VOTEBAN_PLAYER_GOT; i++ )
			{
				if( BANVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //이미 투표하였음
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* 이미 투표하였습니다.");
					return 1;
				}
			}
			//투표하기
			SendClientMessage( playerid, COLOR_GREEN, "* 투표하셨습니다.");
			BANVOTED_PLAYER_IP[VOTEBAN_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEBAN_PLAYER_GOT++;
			if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // 추방기준 통과
			{
				format( str, sizeof(str), "* 투표가 종료되었습니다. 투표 결과로 %s(%d)님을 영구히 추방합니다.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] 투표 결과로 %s(%d)님을 영구히 추방합니다.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				VOTEBAN_REMAINTIME = 0;
				c_Ban( VOTEBAN_PLAYER );
			}
			return 1;
		}
		//투표가 진행중인 경우
		if( VOTEBAN_REMAINTIME > 0 )
		{
			if( CONSOLE ) print("[rcon] 이미 진행중인 투표가 있습니다.");
			else SendClientMessage( playerid, COLOR_GREY, "* 이미 진행중인 투표가 있습니다." );
		}
	}
	if( VOTEBAN_REMAINTIME > 0 ) //현재 투표가 진행중
	{
		if( CONSOLE )
		{
			//아무것도 입력하지 않음. 투표가 진행중. 상태 확인.
			printf("[rcon] 현재 %s(%d)님에 대한 영구추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
			printf("[rcon] 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 영구추방됩니다.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
			printf("[rcon] 중단하시려면 '%s 중단' 을, 투표기능을 없애려면 '%s 사용안함' 을 입력하세요.", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			return 1;
		}
		format( str, sizeof(str), "* 현재 %s(%d)님에 대한 영구추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), " 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 추방됩니다.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), "* 투표하시려면 '/%s yes' 또는 '/%s 예' 를 입력하세요.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME); SEND_C(COLOR_SALMON);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
		    format( str, sizeof(str), "* 투표를 중단하시려면 '/%s 중단' 을, 투표기능을 없애려면 '/%s 사용안함' 을 입력하세요.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //현재 진행중인 투표 없음. 투표작성 시도가 없었음.
	{
		if( CONSOLE )
		{
			print("[rcon] 현재 진행중인 투표가 없습니다.");
			printf("[rcon] 사용법: %s or %s [이름이나 번호]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] 투표기능을 없애려면 '%s 사용안함'을 입력하세요.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* 현재 진행중인 투표가 없습니다.");
        format( str, sizeof(str),  "* 사용법: /%s 또는 /%s [이름이나 번호]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* 투표기능을 없애려면 '/%s 사용안함'을 입력하세요.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//투표 시작하기
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		else SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");
		return 1;
	}

	//최소인원에 미달하는경우
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] 투표를 시작하려면 최소 %d명의 플레이어가 필요합니다.", REQUIRED_MAN_VOTEBAN );
		else
		{
			format( str, sizeof(str), "* 투표를 시작하려면 최소 %d명의 플레이어가 필요합니다.", REQUIRED_MAN_VOTEBAN ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	
	//OK.Assign Player Informations.
	VOTEBAN_PLAYER = giveplayerid;
	VOTEBAN_PLAYER_GOT = 0;
	VOTEBAN_TICK = 0;
	VOTEBAN_REMAINTIME = VOTEBAN_RUN_TIME;
	CURRENT_VOTEBAN_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEBAN_PERCENTAGE) / 100;

	//신고자 비밀보장의 경우 기밀, 아닌경우 이름 수집
	if( VOTE_CONFIDENTIALITY ) str = "기밀";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("서버주인"):(GetPlayerNameEx(playerid)) );
	//투표 메세지 띄우기
	format( str, sizeof(str), "* %s(%d)님에 대한 영구추방 투표가 신청되었습니다. (신청인: %s)",
		GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, str );
    SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* 투표는 총 %d초간 진행되며, %d명 이상이 찬성하면 추방됩니다.", VOTEBAN_RUN_TIME, CURRENT_VOTEBAN_REQUIREMENT );
	SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* 투표하시려면 '/%s yes' 또는 '/%s 예' 를 입력하시면 됩니다.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* 자, 지금부터 투표를 시작합니다!" );
	printf("[rcon] %s(%d)님에 대한 영구추방 투표가 신청되었습니다. (신청인: %s, 신원보호:%s)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, (playerid==ADMIN_ID)? ("서버주인"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("예"):("아니오") );
	return 1;
}
//==========================================================
public dcmd_confidential( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 추방 또는 영구추방시 투표 개시인을 보여주는 기능입니다." );
			print( "[help] 반복 입력으로 켜고 끄기가 가능합니다." );		
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 추방 또는 영구추방시 투표 개시인을 보여주는 기능입니다." ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* 반복 입력으로 켜고 끄기가 가능합니다." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	VOTE_CONFIDENTIALITY = !VOTE_CONFIDENTIALITY;
	SendClientMessageToAll(COLOR_GREENYELLOW,(VOTE_CONFIDENTIALITY? ("* 지금부터 투표 개시자의 신원을 보호합니다."):("* 지금부터 투표 개시자의 신원이 공개됩니다.")));
	print((VOTE_CONFIDENTIALITY? ("[rcon] 지금부터 투표 개시자의 신원을 보호합니다."):("[rcon] 지금부터 투표 개시자의 신원이 공개됩니다.")));
	#pragma unused playerid, params
	return 1;
}
//==========================================================
public dcmd_rconcontroller( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Rcon Controller의 정보를 봅니다. 추가적으로 업데이트를 확인합니다." );
			printf( "[help] 예) %s : 프로그램의 정보를 봅니다.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Rcon Controller의 정보를 봅니다. 추가적으로 업데이트를 확인합니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 프로그램의 정보를 봅니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		printf("Rcon Controller %s을(를) 사용중입니다.\n%s", VERSION, COPYRIGHT_STRING );
		#if SAMP03b
			rcmd_checkupdate(NULL);
		#endif
	}
	else
	{
		new str[64];
		format( str, sizeof(str), "Rcon Controller %s을(를) 사용중입니다.", VERSION ); 
		SendClientMessage( playerid, COLOR_YELLOW, str );
		SendClientMessage( playerid, COLOR_YELLOW, COPYRIGHT_STRING );
	}
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_myauth(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 부운영자가 현재 자신이 가지고 있는 권한을 확인하는 기능입니다." );
			printf( "[help] 예) %s : 자신이 가지고 있는 권한을 확인합니다.", CURRENT_CMD_NAME );
			print("[help] 콘솔에서는 사용이 불가능한 명령어입니다.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* 부운영자가 현재 자신이 가지고 있는 권한을 확인하는 기능입니다." ); SEND();
			format( str, sizeof(str), "* 예) /%s : 자신이 가지고 있는 권한을 확인합니다.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();

	new auths[NUM_AUTH-2][]=
	{
		"귓속말 추적권",
		"명령어 추적권",
		"운영메세지 수신권",
		"운영자 채팅 사용권 (/말 , /say, /말모드, /psay)",
		"시간 조절권 (/시간, /wtime)",
		"생사 여탈권 (/킬, /skill)",
		"통화 조절권 (/돈주기, /givecash, /돈설정, /setcash)",
		"무기 제조권 (/무기주기, /giveweapon)",
		"닉네임 변경권 (/닉바꾸기, /chnick)",
		"체력 조절권 (/체변경, /sethp, /무적, /infinite)",
		"스코어 조절권 (/스코어, /setscore)",
		"아머 조절권 (/아머, /armour, /아머무적, /infarmor)",
		"긴급 체포권 (/프리즈, /freeze)",
		"특별 사면권 (/언프리즈, /unfreeze)",
		"음악 방송권 (/소리, /sound, /소리끄기, /stopsound)",
		"정보 열람권 (/누구, /user, /상태, /stat)",
		"제트팩 제조권 (/제트팩, /jetpack)",
		"강제 추방권 (/킥, /skick)",
		"영구 추방권 (/밴, /sban)",
		"소음 단속권 (/채금, /shutup, /도배, /chatflood, /명령어도배, /cmdflood)",
		"경범죄 사면권 (/리챗, /unshut)",
		"재산 몰수권 (/돈박탈, /forfeit)",
		"무장 해제권 (/무기박탈, /disarm) ",
		"마패 이용권 (/차소환, /spawncar)",
		"부운영자 임명권 (/부운, /subadmin)",
		"부운 탄핵권 (/부운박탈, /suspend)",
		"폭발물 사용권 (/폭탄, /bomb)",
		"국정 홍보권 (/공지, /notice, /공지목록, /noticelist, /공지로드, /reloadnotice)",
		"서버 비상 계엄권 (/서버잠그기, /locksvr)",
		"순간 이동권 (/출두, /with)",
		"유저 소환권 (/소환, /call)",
		"부운영자 인사권 (/권한변경, /chauth, /권한목록, /authlist, /부운로드, /reloadsubs)",
		"중력 조절권 (/중력, /gravity)",
		"날씨 조절권 (/날씨, /weather)",
		"차량 수리권 (/차에너지, /carenergy)",
		"욕설 단속권 (/욕필터, /yellfilter, /욕추가, /addyell, /욕제거, /delyell)",
		"핵방지 조절권 (/무기핵, /무기추가, /무기제거, /제트팩핵)",
		"핑 정리권 (/핑정리, /pingcheck, /핑제한, /setplimit, /핑경고, /setpwarn, /핑초기화, /resetping)",
		"불심 검문권 (/sdrop, /내리기, /감시, /spectate, /감시해제, /specoff)",
		"잠수 관리권 (/잠수, /desync)",
		"운영자 호출권 (/소리내기, /mks)",
		"설정 변경권(/설정로드, /설정저장, /loadconfig, /saveconfig)",
		"밴목록 해제권(/밴풀기, /unban, /아이피밴풀기, /unbanip)",
		"투표 사용/중단(/강퇴투표, /votekick, /영밴투표, /voteban)"
	};
	
	new str[128];
	if( IsPlayerAdmin(playerid) ) SendClientMessage( playerid, COLOR_LIME, "* 당신은 운영자입니다. Rcon Controller의 모든 명령어를 사용할 수 있습니다." );
	else
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "== 사용 가능한 권한 목록 ==" );
		for(new i = 2;i < NUM_AUTH;i++)
		{
			format(str,sizeof(str)," %s : %s",auths[i-2],(AuthorityCheck(playerid,Authinfo:i))? ("사용 가능"):("권한 없음"));
			SendClientMessage(playerid,(AuthorityCheck(playerid,Authinfo:i))? (COLOR_LIME):(COLOR_ORANGE),str);
		}
	}
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_stat( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 서버에 있는 플레이어 목록 및 기본정보를 확인합니다." );
			printf( "[help] 예) %s : 현재 서버에 있는 플레이어 목록 및 기본정보를 확인합니다.", CURRENT_CMD_NAME );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* 현재 서버의 정책을 확인합니다." );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* 예) /%s : 현재 서버에 있는 플레이어 목록 및 기본정보를 확인합니다.", CURRENT_CMD_NAME );			
			SendClientMessage( playerid, COLOR_LIME, str );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(CONSOLE)
	{
		print("\n====== Player Status ==========================================================");
		print("id   name             ping  ip                 money       score        hp  arm");
		print(LINE);
	}
	else
	{
		SendClientMessage(playerid,COLOR_GREY,"====== Player Status ================================================");
		SendClientMessage(playerid,COLOR_GREY,"id   name                   ping  ip               money       score       hp  arm");
		SendClientMessage(playerid,COLOR_GREY,LINE_CLIENT);
	}
	
	//각 사용자의 정보 표시
	new str[128];
	for(new i=0;i<NUM_PLAYERS;i++)
	{		
		format( str, sizeof(str), "%d%s%s %16s %-5d %16s %-11d  %-11d  %-3d %-3d",pITT[i],
			(IsPlayerAdmin(pITT[i])||IsPlayerSubAdmin(pITT[i]))? ("*"):(" "),
			duplicatesymbol(' ',3-(strlen(RetStr(pITT[i])))), GetPlayerNameEx(pITT[i]),
			GetPlayerPing(pITT[i]),GetPlayerIpEx(pITT[i]),GetPlayerCash(pITT[i]),
			GetPlayerScore(pITT[i]), floatround(PlayerHealth(pITT[i])),floatround(PlayerArmour(pITT[i])));
		if(CONSOLE) print( str );
		else	SendClientMessage( playerid, COLOR_GREY, str );
	}
	
	format( str, sizeof(str), "====== Total %d player(s). ================================================", NUM_PLAYERS );
	new num;
	switch (NUM_PLAYERS)
	{
		case 0 .. 9: num=5;
		case 10 .. 99: num=4;
		default: num=3;
 	}
	format( str, sizeof(str), "%s%s\n", str, duplicatesymbol('=',num) );
	if(CONSOLE) print( str );
	else	SendClientMessage( playerid, COLOR_GREY, str );
	#pragma unused params
	return 1;
}
//==========================================================
public dcmd_viewconfig( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] 구문: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] 현재 서버의 정책을 확인합니다." );
			//printf( "[help] 예) %s : 현재 서버의 정책을 확인합니다.", CURRENT_CMD_NAME );
			printf( "[help] 서버의 설정을 INI 파일에 저장하려면 '%s' 명령어를 참조하십시오.", GetCmdName(CMD_SAVECONFIG));
			printf( "[help] 서버의 설정을 INI 파일로부터 다시 로드하려면 '%s' 명령어를 참조하십시오.", GetCmdName(CMD_LOADCONFIG));
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* 구문: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* 현재 서버의 정책을 확인합니다." );
			SendClientMessage( playerid, COLOR_LIME, str );
			//format( str, sizeof(str), "* 예) /%s : 설정 파일에서 공지를 다시 불러옵니다.", CURRENT_CMD_NAME );
			//SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* 서버의 설정을 INI 파일에 저장하려면 '/%s' 명령어를 참조하십시오.", GetCmdName(CMD_SAVECONFIG));
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* 서버의 설정을 INI 파일로부터 다시 로드하려면 '/%s' 명령어를 참조하십시오.", GetCmdName(CMD_LOADCONFIG));
			SendClientMessage( playerid, COLOR_LIME, str );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	ShowServerConfig( playerid );
	#pragma unused params
	return 1;
}

//==========================================================
// Rcon Command
//==========================================================
rcmd_help(params[]) return dcmd_rchelp( ADMIN_ID, params, CMD_HELP, NO_HELP );
//==========================================================
rcmd_help2(params[]) return dcmd_rchelp2( ADMIN_ID, params, CMD_HELP2, NO_HELP );
//==========================================================
/* rcmd_readcmd(params[])
{
	READ_CINPUT = !READ_CINPUT;
	print( (READ_CINPUT)? ("[rcon] 명령어 읽기 기능을 활성화 했습니다."):("[rcon] 명령어 읽기 기능을 비활성화 했습니다.") );
	#pragma unused params
	return 1;
} */
//==========================================================
rcmd_rcon(params[])
{
	if( isnull(params) )
	{
		print("[rcon] 사용법 : rcon [명령어]");
		return 1;
	}
	printf("[rcon] RCON 명령어를 보냈습니다. - %s", params);
	SendRconCommand(params);
	return 1;
}
//==========================================================
rcmd_checkupdate(params[])
{
	#pragma unused params
	#if !SAMP03b
		print("[rcon]현재 호환 모드로 실행중입니다. 업데이트 확인 기능을 사용할 수 없습니다.");
	#else
		print("[rcon] 최신 버전 여부를 검사합니다..");		
		HTTP(UPDATE_CHECK, HTTP_GET,  "eax.kr/SA-MP/RconController.txt", "", "UpdateCheck");
	#endif
	return 1;
}

//==========================================================
// Sub-Functions
//==========================================================
LoadUserConfigs( ... )
{
	c_iniOpen( FILE_SETTINGS, io_read );

	if(!fexist(FILE_SETTINGS) || c_iniInt( "[General]", "기본값 사용"))
	{
		NOTICE_INTERVAL = 0;
		SUBADMIN_FAILLOGIN_LIMIT = 3;
		USE_YELLFILTER = 0;
		USE_ANTI_CHATFLOOD = 1;
		CHATFLOOD_LIMIT = 5;
		CHATFLOOD_UNIT_TIME = 5;
		CHATFLOOD_SHUTUP_TIME = 30;
		USE_ANTI_WEAPONCHEAT = 0;
		PMABUSE_LIMIT = 15;
		ALLOW_JETPACK = 1;
		CMDFLOOD_UNIT_TIME = 10;
		CMDFLOOD_LIMIT = 15;
		CMDFLOOD_STILL_LIMIT = 15;
		CMDFLOOD_FORBIDDEN_TIME = 30;
		USE_ANTI_CMDFLOOD = 1;
		USE_ANTI_MONEYCHEAT = 0;
		/* 핑정리 관련 */
		USE_PINGCHECK = 1;
		HIGHPING_LIMIT = 500;
		HIGHPING_WARN_LIMIT = 5;
		PINGCHECK_DURATION = 3;
		RESET_HIGHPING_TICK = 60;
		//READ_CINPUT = 1;
		ONFLOOD_CHAT = 0;
		ONFLOOD_CMD = 0;
		BADPLAYER_MESSAGE = "당신은 이 서버에서 불건전한 행동으로 추방된 적이 있습니다. 주의하십시오.";
		USE_BADWARN = 1;
		ADMINCHAT_NAME = "* 서버주인(콘솔) :";
		ALLOW_DESYNC = 2;
		DESYNC_LIMIT = 30;
		SAVE_CURRRENT_CONFIG = 0;
		ALLOW_PRIVATE_SPECTATE = 1;

		ENABLE_VOTEKICK = 0;
		ENABLE_VOTEBAN = 0;
		REQUIRED_MAN_VOTEKICK = 3;
		REQUIRED_MAN_VOTEBAN = 5;
		MINIMUM_VOTEKICK_PERCENTAGE = 50;
		MINIMUM_VOTEBAN_PERCENTAGE = 80;
		VOTEKICK_RUN_TIME = 60;
		VOTEBAN_RUN_TIME = 80;
		VOTEKICK_NOTIFY_DURATION = 10;
		VOTEBAN_NOTIFY_DURATION = 10;
		VOTE_CONFIDENTIALITY = 0;
		
        POLICY_RCON_LOGINFAIL_INTERNAL = 1;
		MAX_RCONLOGIN_ATTEMPT = 3;

		if(!fexist(FILE_SETTINGS))
		{
			print("[ERROR] RconController.ini를 찾을 수 없습니다. 기본값을 로드합니다.\n[ERROR] 또한 공지,부운영자 기능 및 일부기능이 제한됩니다.");
			print("[ERROR] 에러해결을 위해 scriptfiles\\MINIMINI 폴더에 RconController.ini를 넣어주세요.");
			Wait(5000);
			return ;
		}
		else print("[rcon] 설정에 따라 서버의 기본값을 불러왔습니다.");
	}

	if(c_iniInt("[General]", "USE_NOTICE")) NOTICE_INTERVAL = c_iniInt("[General]", "NOTICE_INTERVAL"); else NOTICE_INTERVAL = 0;
	SUBADMIN_FAILLOGIN_LIMIT = c_iniInt( "[SubAdmin]","FAILLOGIN_LIMIT");
	USE_YELLFILTER = c_iniInt("[General]", "USE_YELLFILTER");
	USE_ANTI_CHATFLOOD = c_iniInt("[General]", "USE_ANTI_CHATFLOOD");
	CHATFLOOD_LIMIT = c_iniInt("[General]", "CHATFLOOD_LIMIT");
	CHATFLOOD_UNIT_TIME = c_iniInt("[General]", "CHATFLOOD_UNIT_TIME");
	CHATFLOOD_SHUTUP_TIME = c_iniInt("[General]", "CHATFLOOD_SHUTUP_TIME");
	PERMANENT_ADMINSAY[ADMIN_ID] = c_iniInt("[General]", "AUTO_PSAY");
	PMABUSE_LIMIT = c_iniInt("[General]", "PMABUSE_LIMIT");
	USE_ANTI_CMDFLOOD = c_iniInt("[General]", "USE_ANTI_CMDFLOOD");
	CMDFLOOD_UNIT_TIME = c_iniInt("[General]", "CMDFLOOD_UNIT_TIME");
	CMDFLOOD_LIMIT = c_iniInt("[General]", "CMDFLOOD_LIMIT");
	CMDFLOOD_FORBIDDEN_TIME = c_iniInt("[General]", "CMDFLOOD_FORBIDDEN_TIME");
	CMDFLOOD_STILL_LIMIT = c_iniInt("[General]", "CMDFLOOD_STILL_LIMIT");
	/* 핑정리 관련 */
	USE_PINGCHECK = c_iniInt( "[General]", "USE_PINGCHECK" );
	HIGHPING_LIMIT = c_iniInt( "[General]", "HIGHPING_LIMIT" );
	HIGHPING_WARN_LIMIT = c_iniInt( "[General]", "HIGHPING_WARN_LIMIT" );
	PINGCHECK_DURATION = c_iniInt( "[General]", "PINGCHECK_DURATION" );
	RESET_HIGHPING_TICK = c_iniInt( "[General]", "RESET_HIGHPING_TICK" );
	//READ_CINPUT = c_iniInt( "[General]", "READ_CONSOLECMD" );
	USE_ANTI_WEAPONCHEAT = c_iniInt("[Anticheat]", "USE_ANTI_WEAPONCHEAT");
	ALLOW_JETPACK = c_iniInt("[Anticheat]", "ALLOW_JETPACK");
	USE_ANTI_MONEYCHEAT = c_iniInt("[Anticheat]", "USE_ANTI_MONEYCHEAT");
	ONFLOOD_CHAT = (strcmp( c_iniGet("[General]", "ONFLOOD_CHAT"), "ban", true ) == 0);
	ONFLOOD_CMD = (strcmp( c_iniGet("[General]", "ONFLOOD_CMD"), "ban", true ) == 0);
	BADPLAYER_MESSAGE = c_iniGet( "[General]", "ON_BADPLAYER_CONNECT" );
	USE_BADWARN = c_iniInt( "[General]", "USE_BADWARN" );
	ADMINCHAT_NAME = c_iniGet( "[General]", "ADMINCHAT_NAME" );
	ALLOW_DESYNC = c_iniInt( "[General]", "ALLOW_DESYNC" );
	if( ALLOW_DESYNC == 0 ) DESYNC_LIMIT = 5;
	else DESYNC_LIMIT = c_iniInt( "[General]", "DESYNC_LIMIT" );
	SAVE_CURRRENT_CONFIG = c_iniInt( "[General]", "SAVE_CURRRENT_CONFIG" );
	ALLOW_PRIVATE_SPECTATE = c_iniInt( "[Anticheat]", "ALLOW_PRIVATE_SPECTATE" );
	ONCHEAT_WEAPON = (strcmp( c_iniGet("[Anticheat]", "ONCHEAT_WEAPON"), "ban", true ) == 0);
	DUMPEXIT = c_iniInt( "[General]" , "ALWAYS_DUMP_MEMORY" );

	ENABLE_VOTEKICK = c_iniInt( "[Vote]" , "ENABLE_VOTEKICK" );
	ENABLE_VOTEBAN = c_iniInt( "[Vote]" , "ENABLE_VOTEBAN" );
	REQUIRED_MAN_VOTEKICK = c_iniInt( "[Vote]" , "REQUIRED_MAN_VOTEKICK" );
	REQUIRED_MAN_VOTEBAN = c_iniInt( "[Vote]" , "REQUIRED_MAN_VOTEBAN" );
	MINIMUM_VOTEKICK_PERCENTAGE = c_iniInt( "[Vote]" , "MINIMUM_VOTEKICK_PERCENTAGE" );
	MINIMUM_VOTEBAN_PERCENTAGE = c_iniInt( "[Vote]" , "MINIMUM_VOTEBAN_PERCENTAGE" );
	VOTEKICK_RUN_TIME = c_iniInt( "[Vote]" , "VOTEKICK_RUN_TIME" );
	VOTEBAN_RUN_TIME = c_iniInt( "[Vote]" , "VOTEBAN_RUN_TIME" );
    VOTEKICK_NOTIFY_DURATION = c_iniInt( "[Vote]" , "VOTEKICK_NOTIFY_DURATION" );
	VOTEBAN_NOTIFY_DURATION = c_iniInt( "[Vote]" , "VOTEBAN_NOTIFY_DURATION" );
	VOTE_CONFIDENTIALITY = c_iniInt( "[Vote]" , "VOTE_CONFIDENTIALITY" );
	
	POLICY_RCON_LOGINFAIL_INTERNAL = c_iniInt( "[security]" , "POLICY_RCON_LOGINFAIL_INTERNAL" );
	MAX_RCONLOGIN_ATTEMPT = c_iniInt( "[security]" , "MAX_RCONLOGIN_ATTEMPT" );

	new str[512], idx, tmp[512];
	str = c_iniGet( "[Anticheat]", "FORBIDDEN_WEAPONS");
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		tmp = strtok( str, idx, ',' );
		if( !tmp[0] || !isNumeric( tmp ) || strval(tmp) < 0 || strval(tmp) >= MAX_WEAPONS ) break;
		IS_WEAPON_FORBIDDEN[strval(tmp)] = 1;
	}

	c_iniClose( );

	CheckNoticeList();
	LoadYellList();

	//Verification
	if( NOTICE_INTERVAL < 0 ) NOTICE_INTERVAL = 0;
	if( SUBADMIN_FAILLOGIN_LIMIT < 1 ) SUBADMIN_FAILLOGIN_LIMIT = 3;
	if( USE_YELLFILTER < 0 || USE_YELLFILTER > 1 ) USE_YELLFILTER = 0;
	if( USE_ANTI_CHATFLOOD < 0 || USE_ANTI_CHATFLOOD > 1 ) USE_ANTI_CHATFLOOD = 1;
	if( CHATFLOOD_LIMIT < 1 ) CHATFLOOD_LIMIT = 5;
	if( CHATFLOOD_UNIT_TIME < 1 ) CHATFLOOD_UNIT_TIME = 5;
	if( CHATFLOOD_SHUTUP_TIME < 1 ) CHATFLOOD_SHUTUP_TIME = 30;
	if( PERMANENT_ADMINSAY[ADMIN_ID] < 0 || PERMANENT_ADMINSAY[ADMIN_ID] > 1 ) PERMANENT_ADMINSAY[ADMIN_ID] = 0;
	if( USE_ANTI_WEAPONCHEAT < 0 || USE_ANTI_WEAPONCHEAT > 1 ) USE_ANTI_WEAPONCHEAT = 0;
	if( PMABUSE_LIMIT < 1 ) PMABUSE_LIMIT = 15;
	if( ALLOW_JETPACK < 0 || ALLOW_JETPACK > 1 ) ALLOW_JETPACK = 1;
	if( USE_ANTI_CMDFLOOD < 0 || USE_ANTI_CMDFLOOD > 1 ) USE_ANTI_CMDFLOOD = 1;
	if( CMDFLOOD_UNIT_TIME < 1 ) CMDFLOOD_UNIT_TIME = 10;
	if( CMDFLOOD_LIMIT < 1 ) CMDFLOOD_LIMIT = 15;
	if( CMDFLOOD_STILL_LIMIT < 1 ) CMDFLOOD_STILL_LIMIT = 15;
	if( CMDFLOOD_FORBIDDEN_TIME < 1 ) CMDFLOOD_FORBIDDEN_TIME = 30;
	if( USE_ANTI_MONEYCHEAT < 0 || USE_ANTI_MONEYCHEAT > 1 ) USE_ANTI_MONEYCHEAT = 0;
	if( USE_PINGCHECK < 0 || USE_PINGCHECK > 1 ) USE_PINGCHECK = 1;
	/* 핑정리 관련 */
	if( HIGHPING_LIMIT < 1 ) HIGHPING_LIMIT = 500;
	if( HIGHPING_WARN_LIMIT < 0 ) HIGHPING_WARN_LIMIT = 5;
	if( PINGCHECK_DURATION < 1 ) PINGCHECK_DURATION = 3;
	if( RESET_HIGHPING_TICK < 0 ) RESET_HIGHPING_TICK = 60;
	//if( READ_CINPUT < 0 || READ_CINPUT > 1 ) READ_CINPUT = 1;
	if( USE_BADWARN < 0 || USE_BADWARN > 1 ) USE_BADWARN = 1;
	if( !BADPLAYER_MESSAGE[0]) BADPLAYER_MESSAGE = "당신은 이 서버에서 불건전한 행동으로 추방된 적이 있습니다. 주의하십시오.";
	if( !ADMINCHAT_NAME[0] ) ADMINCHAT_NAME = "* 서버주인(콘솔) :";
	if( ALLOW_DESYNC < 0 || ALLOW_DESYNC > 2 ) ALLOW_DESYNC = 2;
	if( DESYNC_LIMIT < 5 ) DESYNC_LIMIT = 5;
	if( SAVE_CURRRENT_CONFIG < 0 || SAVE_CURRRENT_CONFIG > 1 ) SAVE_CURRRENT_CONFIG = 1;
	if( ALLOW_PRIVATE_SPECTATE < 0 || ALLOW_PRIVATE_SPECTATE > 1 ) ALLOW_PRIVATE_SPECTATE = 0;
	if( DUMPEXIT < 0 || DUMPEXIT > 2 ) DUMPEXIT = 0;

	if( ENABLE_VOTEKICK < 0 || ENABLE_VOTEKICK > 1 ) ENABLE_VOTEKICK = 0;
	if( ENABLE_VOTEBAN < 0 || ENABLE_VOTEBAN > 1 ) ENABLE_VOTEBAN = 0;
	if( REQUIRED_MAN_VOTEKICK < 0 || REQUIRED_MAN_VOTEKICK > 200 ) REQUIRED_MAN_VOTEKICK = 3;
	if( REQUIRED_MAN_VOTEBAN < 0 || REQUIRED_MAN_VOTEBAN > 200 ) REQUIRED_MAN_VOTEBAN = 5;
	if( MINIMUM_VOTEKICK_PERCENTAGE < 0 || MINIMUM_VOTEKICK_PERCENTAGE > 100 ) MINIMUM_VOTEKICK_PERCENTAGE = 50;
	if( MINIMUM_VOTEBAN_PERCENTAGE < 0 || MINIMUM_VOTEBAN_PERCENTAGE > 100 ) MINIMUM_VOTEBAN_PERCENTAGE = 80;
	if( VOTEKICK_RUN_TIME < 0 ) VOTEKICK_RUN_TIME = 60;
	if( VOTEBAN_RUN_TIME < 0 ) VOTEBAN_RUN_TIME = 80;
	if( VOTEKICK_NOTIFY_DURATION < 1 || VOTEKICK_NOTIFY_DURATION > VOTEKICK_RUN_TIME ) VOTEKICK_NOTIFY_DURATION = 10;
	if( VOTEBAN_NOTIFY_DURATION < 1 || VOTEKICK_NOTIFY_DURATION > VOTEBAN_RUN_TIME ) VOTEKICK_NOTIFY_DURATION = 10;
	if( VOTE_CONFIDENTIALITY < 0 || VOTE_CONFIDENTIALITY > 1 ) VOTE_CONFIDENTIALITY = 0;

	if( POLICY_RCON_LOGINFAIL_INTERNAL < 0 || POLICY_RCON_LOGINFAIL_INTERNAL > 2 ) POLICY_RCON_LOGINFAIL_INTERNAL = 1;
	if( MAX_RCONLOGIN_ATTEMPT < 0 ) MAX_RCONLOGIN_ATTEMPT = 3;
	//Show it
	if( numargs() ) ShowServerConfig( ADMIN_ID );
}
//==========================================================
ShowServerConfig( playerid )
{
	if( CONSOLE )
	{	
		print("=============== 현재 서버 정책 ====================");
		printf("종료시에 서버 정책 저장 : %s",(SAVE_CURRRENT_CONFIG)? ("사용"):("사용안함"));
		if( DUMPEXIT == 0 ) print( "종료시에 메모리 덤프 생성 : 사용안함" );
		else if( DUMPEXIT == 1 ) print( "종료시에 메모리 덤프 생성 : 기본 덤프 생성" );
		else print( "종료시에 메모리 덤프 생성 : 전체 덤프 생성" );
		printf("서버 운영자 이름 : \"%s\"", ADMINCHAT_NAME );
		//printf("Controller 입력기 : %s",(READ_CINPUT)? ("사용"):("사용안함"));
		printf("자동 말모드 : %s",(PERMANENT_ADMINSAY[ADMIN_ID])? ("사용"):("사용안함"));
		if( NOTICE_INTERVAL ) printf( "공지 기능 : 사용, 공지 간격 : %d초", NOTICE_INTERVAL ); else print( "공지 기능 : 사용안함");
		if( USE_PINGCHECK ) printf("핑 정리 기능 : 사용(%d초마다, %dms, %d회 경고후 추방)", PINGCHECK_DURATION, HIGHPING_LIMIT, HIGHPING_WARN_LIMIT );
		else print("핑 정리 기능 : 사용안함");
		if( USE_YELLFILTER ) printf( "욕필터 : 사용, 패턴 버전 : v%s, 패턴 수 : %d개", YELL_VER[1],num_Yells ); else print( "욕필터 : 사용안함");
		if( USE_ANTI_CHATFLOOD ) printf( "도배방지 : 사용(%d초에 %d번, %d초간 벌칙, %d회 위반시 %s)", CHATFLOOD_UNIT_TIME, CHATFLOOD_LIMIT, CHATFLOOD_SHUTUP_TIME, PMABUSE_LIMIT, (ONFLOOD_CHAT)? ("영구추방"):("추방") );
		else print("도배방지 : 사용안함");
		if( USE_ANTI_CMDFLOOD ) printf( "명령어도배 방지 : 사용(%d초에 %d번, %d초간 벌칙, %d회 위반시 %s)", CMDFLOOD_UNIT_TIME, CMDFLOOD_LIMIT, CMDFLOOD_FORBIDDEN_TIME, CMDFLOOD_STILL_LIMIT, (ONFLOOD_CMD)? ("영구추방"):("추방") );
		else print( "명령어도배 방지 : 사용안함");
		if( USE_BADWARN ) printf( "불량유저 경고 : 사용(%-15s...)", BADPLAYER_MESSAGE ); else print( "불량유저 경고 : 사용안함" );
		if( ALLOW_DESYNC == 1 ) printf( "잠수허용 : %d초까지만 허용", DESYNC_LIMIT );
		else if( ALLOW_DESYNC == 2 ) print("잠수허용 : 허용");
		else print( "잠수허용 : 허용하지 않음" );
		if( ENABLE_VOTEKICK ) printf( "강제추방 투표 : 사용 (필요인원 %d명, %d%%이상 찬성, %d초동안)", REQUIRED_MAN_VOTEKICK, MINIMUM_VOTEKICK_PERCENTAGE, VOTEKICK_RUN_TIME );
		else print("강제추방 투표 : 사용안함");
		if( ENABLE_VOTEBAN ) printf( "영구추방 투표 : 사용 (필요인원 %d명, %d%%이상 찬성, %d초동안)", REQUIRED_MAN_VOTEBAN, MINIMUM_VOTEBAN_PERCENTAGE, VOTEBAN_RUN_TIME );
		else print("영구추방 투표 : 사용안함");
		if( VOTE_CONFIDENTIALITY ) print("투표시 신원보호 : 예"); else print("투표시 신원보호 : 아니오");
		if( USE_ANTI_WEAPONCHEAT ) printf( "무기핵 방지 : 사용( %s, 금지무기 %s )", (ONCHEAT_WEAPON)? ("추방"):("영구추방"), c_iniGet("[Anticheat]", "FORBIDDEN_WEAPONS"));
		else print( "무기핵 방지 : 사용안함" );
		printf( "제트팩 사용 : %s", (ALLOW_JETPACK)? ("허용"):("허용안함") );
		printf( "사설 감시 허용 : %s", (ALLOW_PRIVATE_SPECTATE)? ("허용"):("허용안함") );
		printf( "돈핵 방지 : %s", (USE_ANTI_MONEYCHEAT)? ("사용"):("사용안함") );
		print(LINE);
	}
	else SendClientMessage( playerid, COLOR_YELLOW, " * 준비중입니다." );
}
//==========================================================
SaveUserConfigs()
{
	c_iniOpen( FILE_SETTINGS, io_write );

	c_iniIntSet( "[General]", "USE_NOTICE", (NOTICE_INTERVAL)? (1):(0) );
	if( NOTICE_INTERVAL ) c_iniIntSet( "[General]", "NOTICE_INTERVAL", NOTICE_INTERVAL );
	c_iniIntSet( "[SubAdmin]", "FAILLOGIN_LIMIT", SUBADMIN_FAILLOGIN_LIMIT );
	c_iniIntSet( "[General]", "USE_YELLFILTER", USE_YELLFILTER );
	c_iniIntSet( "[General]", "USE_ANTI_CHATFLOOD", USE_ANTI_CHATFLOOD );
	c_iniIntSet( "[General]", "CHATFLOOD_LIMIT", CHATFLOOD_LIMIT );
	c_iniIntSet( "[General]", "CHATFLOOD_UNIT_TIME", CHATFLOOD_UNIT_TIME );
	c_iniIntSet( "[General]", "CHATFLOOD_SHUTUP_TIME", CHATFLOOD_SHUTUP_TIME );
	c_iniIntSet( "[General]", "AUTO_PSAY", PERMANENT_ADMINSAY[ADMIN_ID] );
	c_iniIntSet( "[General]", "PMABUSE_LIMIT", PMABUSE_LIMIT );
	c_iniIntSet( "[General]", "USE_ANTI_CMDFLOOD", USE_ANTI_CMDFLOOD );
	c_iniIntSet( "[General]", "CMDFLOOD_UNIT_TIME", CMDFLOOD_UNIT_TIME );
	c_iniIntSet( "[General]", "CMDFLOOD_LIMIT", CMDFLOOD_LIMIT );
	c_iniIntSet( "[General]", "CMDFLOOD_FORBIDDEN_TIME", CMDFLOOD_FORBIDDEN_TIME );
	c_iniIntSet( "[General]", "CMDFLOOD_STILL_LIMIT", CMDFLOOD_STILL_LIMIT );
	c_iniIntSet( "[General]", "USE_PINGCHECK", USE_PINGCHECK );
	c_iniIntSet( "[General]", "HIGHPING_LIMIT", HIGHPING_LIMIT );
	c_iniIntSet( "[General]", "HIGHPING_WARN_LIMIT", HIGHPING_WARN_LIMIT );
	c_iniIntSet( "[General]", "PINGCHECK_DURATION", PINGCHECK_DURATION );
	//c_iniIntSet( "[General]", "READ_CONSOLECMD", READ_CINPUT );
	c_iniIntSet( "[Anticheat]", "USE_ANTI_WEAPONCHEAT", USE_ANTI_WEAPONCHEAT );
	c_iniIntSet( "[Anticheat]", "ALLOW_JETPACK", ALLOW_JETPACK );
	c_iniIntSet( "[Anticheat]", "USE_ANTI_MONEYCHEAT", USE_ANTI_MONEYCHEAT );
	c_iniSet( "[General]", "ONFLOOD_CHAT", (ONFLOOD_CHAT)? ("Ban"):("Kick"));
	c_iniSet( "[General]", "ONFLOOD_CMD", (ONFLOOD_CMD)? ("Ban"):("Kick") );
	c_iniIntSet( "[General]", "USE_BADWARN", USE_BADWARN );
	c_iniIntSet( "[General]", "ALLOW_DESYNC", ALLOW_DESYNC );
	c_iniIntSet( "[General]", "DESYNC_LIMIT", DESYNC_LIMIT );
	c_iniIntSet( "[General]", "SAVE_CURRRENT_CONFIG", SAVE_CURRRENT_CONFIG );
	c_iniIntSet( "[Anticheat]", "ALLOW_PRIVATE_SPECTATE", ALLOW_PRIVATE_SPECTATE );
	c_iniSet( "[Anticheat]", "ONCHEAT_WEAPON", (ONCHEAT_WEAPON)? ("Ban"):("Kick") );
	c_iniIntSet( "[Vote]" , "ENABLE_VOTEKICK", ENABLE_VOTEKICK );
	c_iniIntSet( "[Vote]" , "ENABLE_VOTEBAN", ENABLE_VOTEBAN );
	c_iniIntSet( "[Vote]" , "VOTE_CONFIDENTIALITY", VOTE_CONFIDENTIALITY );

	new str[512];
	for(new i = 0; i < MAX_WEAPONS; i++)
	{
		if( IS_WEAPON_FORBIDDEN[i] )
		{
			format( str, sizeof(str), "%s%d,", str, i );
		}
	}
	c_iniSet("[Anticheat]", "FORBIDDEN_WEAPONS", str );

	c_iniClose( );
	print("[rcon] 서버의 현재 정책을 저장했습니다.");
}

//==========================================================
public ScrollHelp( playerid )
{
	#define ptr PLAYER_CURSCR[playerid]
	new text[128], color, quit;
	new lines = ceildiv(sizeof( cmdlist ), 6);
	
	switch( ptr )
	{
		case 0:
		{
			if( CONSOLE ) text = "\n=====================  Rcon Controller : Command List  ========================";
			else
			{
				text = "===========  Rcon Controller : Command List  ==========";
				color=COLOR_GREEN;
			}
		}
		case 1:
		{
			if( CONSOLE ) text = "           자세한 도움말을 보려면 도움말 [명령어 이름] 을 입력하십시오.";
			else
			{
				format( text, sizeof(text), "           자세한 도움말을 보려면 /%s [명령어 이름] 을 입력하십시오.", GetCmdName(CMD_HELP) );
				color=COLOR_SALMON;
			}
		}
		case 2:
		{
			if( CONSOLE ) text = LINE;
			else
			{
				text = LINE_CLIENT;
				color = COLOR_GREEN;
			}
			
		}
		case 3 .. (ceildiv(sizeof( cmdlist ), 6) + 2) : //몇줄인지 구한다
		{
			text = "     ";
			for( new j = 0 ; j < 6 ; j++ )
			{
				color = (j*lines)+(ptr-3);
				if(  color < sizeof(cmdlist) ) format( text, sizeof(text), "%s%-12s", text, cmdlist[Cmdorder:color][Cmd] );				
			}
			color = COLOR_LIME;
		}
		case (ceildiv(sizeof( cmdlist ), 6) + 3) :
		{
			if ( CONSOLE ) text = LINE;
			else
			{
				text = LINE_CLIENT;
				color = COLOR_GREEN;
			}
		}
		case (ceildiv(sizeof( cmdlist ), 6) + 4) :
		{
			if( CONSOLE ) format( text, sizeof(text), "              Total %d Commands, (C) 2008 - 2013 CoolGuy(밥먹었니)", sizeof( cmdlist ) );
			else quit = 1;
		}
		case (ceildiv(sizeof( cmdlist ), 6) + 5) :
		{
			if( CONSOLE ) text = LINE;
			else quit = 1;
		}
		default : quit = 1;
	}
	if( quit ) return ;
	if( CONSOLE ) print( text );
	else SendClientMessage( playerid, color, text );
	ptr++;
	SetTimerEx( "ScrollHelp", 1003, 0, "i", playerid );
	return ;
	#undef ptr
}
//==========================================================
ResetPlayerStatus(playerid)
{
	UnSetPlayerSubAdmin( playerid );
	PLAYER_JUST_CONNECTED[playerid] = 10;
	INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	PLAYER_DESYNCED_TIMES[playerid] = 0;
	HIGHPING_WARNED_TIMES[playerid] = 0;
	PLAYER_PMABUSE_TIMES[playerid] = 0;
	PERMANENT_ADMINSAY[playerid] = 0;
	IS_HEAR_CMDTRACE[playerid] = 1;
	SUBADMIN_FAILLOGIN_TIMES[playerid] = 0;
	PLAYER_PUNISH_REMAINTIME[playerid] = {0, 0, 0};
	CHATFLOOD_TIMES[playerid] = 0;
	CMDFLOOD_TIMES[playerid] = 0;
	CMDFLOOD_STILL_TIMES[playerid] = 0;
	PLAYER_MONEYCHECK[playerid] = 0;
	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATING[IS_PLAYER_SPECTATED[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATED[playerid] = INVALID_PLAYER_ID;
	}
}
//==========================================================
GatherPlayerInformations()
{
	for( new i = 0 ; i < M_P ; i++ )
	{
		if( GetPlayerName( i , PLAYER_NAME[i], MAX_PLAYER_NAME ) )
		{
		    //iteration optimization
            pITT[ NUM_PLAYERS ] = i;
			pITT_INDEX[ i ] = NUM_PLAYERS;
			NUM_PLAYERS++;
			//update info
			FixChars( PLAYER_NAME[i] );
			ResetPlayerStatus(i);
			GetPlayerIp( i, PLAYER_IP[i], sizeof(PLAYER_IP[]) );
			PLAYER_JUST_CONNECTED[i] = 5;
		}
	}
}
//==========================================================
public ResetChatFlood()
{
	for( new i = 0; i < NUM_PLAYERS; i++ )
	{
		CHATFLOOD_TIMES[pITT[i]] = 0;
	}
}
//==========================================================
public ResetCmdFlood()
{
	for( new i = 0; i < NUM_PLAYERS; i++ )
	{
		CMDFLOOD_TIMES[pITT[i]] = 0;
	}
}
//==========================================================
public ResetPingCheck() //핑정리 초기화
{
	for( new i = 0 ; i < NUM_PLAYERS ; i++ )
	{
		HIGHPING_WARNED_TIMES[ pITT[i] ] = 0;
	}
}
//==========================================================
public SpectateTimer( playerid, giveplayerid )
{
	new str[87];
	new Float:pos[3];
	format( str, sizeof(str), "* %s(%d)님을 감시하기 시작합니다. 잠시만 기다려 주세요....", GetPlayerNameEx( giveplayerid ), giveplayerid );
	TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 1 );
	PlayerSpectatePlayer( IS_PLAYER_SPECTATED[playerid], playerid );
	SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	SetPlayerInterior(playerid, GetPlayerInterior(giveplayerid));
	GetPlayerPos(giveplayerid, pos[0], pos[1], pos[2]);
	SetPlayerPos(playerid, pos[0], pos[1], pos[2]);
}
//==========================================================
public Start_OneSecTimer_1() SetTimer("OneSecTimer_1", 1000, 1);
//==========================================================
public Start_OneSecTimer_2() SetTimer("OneSecTimer_2", 1000, 1);
//==========================================================
public OneSecTimer_1()
{
    new str[256], money, playerping;
    
    //iteration
	for(new i=0;i<NUM_PLAYERS;i++)
	{
		if( !ALLOW_JETPACK && GetPlayerSpecialAction( pITT[i] ) == SPECIAL_ACTION_USEJETPACK )
		{
			printf("[rcon] %s(%d)님이 서버에서 금지한 제트팩을 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i]);
			format( str, sizeof(str), "* %s(%d)님이 서버에서 금지한 제트팩을 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i]);
			SendClientMessageToAll( COLOR_RED, str );
			c_Kick(pITT[i]);
			continue;
		}

		if( GetPlayerState( pITT[i] ) == PLAYER_STATE_SPECTATING )
		{
			if( IsPlayerAdmin(pITT[i]) || IsPlayerSubAdmin(pITT[i]) ) PLAYER_DESYNCED_TIMES[pITT[i]] = 0;
			else if( !ALLOW_PRIVATE_SPECTATE && IS_PLAYER_SPECTATING[pITT[i]] == INVALID_PLAYER_ID )
			{
				printf("[rcon] %s(%d)님이 서버에서 금지한 감시기능을 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i]);
				format( str, sizeof(str), "* %s(%d)님이 서버에서 금지한 감시기능을 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i]);
				SendClientMessageToAll( COLOR_RED, str );
				c_Kick(pITT[i]);
				continue;
			}
		}

		if( PLAYER_SPAWNED[pITT[i]] )
		{
			if( USE_ANTI_WEAPONCHEAT && IS_WEAPON_FORBIDDEN[GetPlayerWeapon(pITT[i])])
			{
				GetWeaponName( GetPlayerWeapon(pITT[i]), str, sizeof(str) );
				printf("[rcon] %s(%d)님이 서버에서 금지한 무기 %s을(를) 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i], str);
				format( str, sizeof(str), "* %s(%d)님이 서버에서 금지한 무기 %s을(를) 사용하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i] , str);
				SendClientMessageToAll( COLOR_RED, str );
				if( ONCHEAT_WEAPON ) c_Ban(pITT[i]); else c_Kick(pITT[i]);
				continue;
			}

			PLAYER_DESYNCED_TIMES[pITT[i]]++;
			if( ALLOW_DESYNC != 2 && PLAYER_DESYNCED_TIMES[pITT[i]] >= DESYNC_LIMIT )
			{
				//kick
				if( (IsPlayerAdmin(pITT[i]) || (IsPlayerSubAdmin(pITT[i]) && PLAYER_AUTHORITY[pITT[i]][AUTH_CMD_SPECTATE])) && GetPlayerState(pITT[i]) == PLAYER_STATE_SPECTATING) {}
				else
				{
					printf("[rcon] %s(%d)님이 제한시간(%d초) 이상 잠수하여 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT);
					format( str, sizeof(str), "* %s(%d)님이 제한시간(%d초) 이상 ESC키를 눌러 추방됩니다.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT );
					SendClientMessageToAll( COLOR_RED, str );
					c_Kick(pITT[i]);
					continue;
				}
			}
		}

		if(USE_PINGCHECK && !PLAYER_JUST_CONNECTED[pITT[i]])
		{
			playerping = GetPlayerPing(pITT[i]);
			if(playerping > HIGHPING_LIMIT)
			{
				HIGHPING_WARNED_TIMES[pITT[i]]++;
				if(HIGHPING_WARNED_TIMES[pITT[i]] > HIGHPING_WARN_LIMIT)
				{
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* 핑이 너무 높습니다. 서버 안정화를 위해 추방합니다. ㅠ_ ㅠ");
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* You have too high ping to play in my server. Sorry");
					format(str,sizeof(str),"* %s(%d)님의 핑이 너무 높아 추방합니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
					SendClientMessageExceptPlayer(pITT[i],COLOR_GREENYELLOW,str);
					printf("[info] %s(%d)님의 핑이 너무 높아 추방합니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
					c_Kick(pITT[i]);
					continue;
				}
				printf("[info] %s(%d)님의 핑이 %d을(를) 넘었습니다. (%d회)",GetPlayerNameEx(pITT[i]),pITT[i],HIGHPING_LIMIT,HIGHPING_WARNED_TIMES[pITT[i]]);
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* 경고! 핑이 너무 높습니다. 인터넷 환경을 개선하세요.");
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* You have too high ping. Please improve your internet condition.");
			}
			PLAYER_JUST_CONNECTED[pITT[i]] = PINGCHECK_DURATION;
		}
		else if( PLAYER_JUST_CONNECTED[pITT[i]] ) PLAYER_JUST_CONNECTED[pITT[i]]--;

		money = GetPlayerMoney( pITT[i] );
		if( !USE_ANTI_MONEYCHEAT ) PLAYER_CASH[pITT[i]] = money;
		else if( money != PLAYER_CASH[pITT[i]] )
		{
			if( PLAYER_CASH[pITT[i]] > GetPlayerMoney(pITT[i]) )
			{
				PLAYER_MONEYCHECK[pITT[i]]++;
				if( PLAYER_MONEYCHECK[pITT[i]] > 3 )
				{
					PLAYER_MONEYCHECK[pITT[i]] = 0;
					PLAYER_CASH[pITT[i]] = GetPlayerMoney(pITT[i]);
				}
				continue;
			}
			PLAYER_MONEYCHECK[pITT[i]] = 0;
			GivePlayerMoney(pITT[i], PLAYER_CASH[pITT[i]] - money);
		}

		for(new j=0;j<sizeof(PLAYER_PUNISH_REMAINTIME[]);j++)
		{ //for all punishment
			if(PLAYER_PUNISH_REMAINTIME[pITT[i]][j] > 0)
			{ // 초가 있으면
				PLAYER_PUNISH_REMAINTIME[pITT[i]][j]-=1; // reduce
				if(PLAYER_PUNISH_REMAINTIME[pITT[i]][j]==0)
				{
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* 서버주인: 앞으로는 조심하시길 바랍니다.");
					switch(j)
					{
					case PUNISH_FREEZE:
						{
							TogglePlayerControllable(pITT[i],1);
							printf("[rcon] %s(%d)님이 프리즈 벌칙에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)님이 프리즈 벌칙에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_SHUTUP:
						{
							printf("[rcon] %s(%d)님이 채팅금지 벌칙에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)님이 채팅금지 벌칙에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_CMDRESTRICT:
						{
							printf("[rcon] %s(%d)님이 명령어 사용제한에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)님이 명령어 사용제한에서 풀려났습니다.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					}
				}
				else
				{
					format(str,sizeof(str),"~y~%d ~w~sec left",PLAYER_PUNISH_REMAINTIME[pITT[i]][j]);
					GameTextForPlayer(pITT[i],str,3000,3);
				}
			} //if(PLAYER_PUNISH_REMAINTIME[i][j] > 0)
			else if( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] < 0 ) //킥이나 밴해야 한다면
			{
				//상태를 봐서
				switch ( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] )
				{
					case KICK_THIS_PLAYER: //킥이나
					{
						GameTextForPlayer(pITT[i],"You are ~y~Kicked", 150000, 5);
						Kick(pITT[i]);
					}
					case BAN_THIS_PLAYER: //밴을 한다
					{
						GameTextForPlayer(pITT[i],"You are ~r~BANNED", 150000, 5);
						GetPVarString(pITT[i],"BAN_REASON", str, sizeof(str));
						BanEx(pITT[i], str);
					}
				}
			}
		}//for(new j=0
	}//for(new i=0
}
//==========================================================
public OneSecTimer_2()
{
	new str[256];
	static CUR_TIME;

	/*if( READ_CINPUT )
	{
		new File:hnd = fopen( "request.txt", io_read );
		if( hnd )
		{
			while( fread( hnd, str ) )
			{
				StripNL( str );
				if( str[0] ) OnRconCommand( str );
			}
			fclose( hnd );
		}
		fremove("request.txt");
	}*/

	if(NOTICE_INTERVAL)
	{
		CUR_TIME++;
		if(CUR_TIME >= NOTICE_INTERVAL)
		{
			CUR_TIME=0;
			SendPlayerNotice(random(Num_Notice)+1);
		}
	}
	
	if(ENABLE_VOTEKICK)
	{
	    if( VOTEKICK_REMAINTIME > 0 )
	    {
	        VOTEKICK_REMAINTIME--;
	        VOTEKICK_TICK++;
	        if( VOTEKICK_REMAINTIME <= 0 )
	        {
				if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // 추방기준 통과
				{
					format( str, sizeof(str), "* 투표가 종료되었습니다. 투표 결과로 %s(%d)님을 강제 추방합니다.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] 투표 결과로 %s(%d)님을 강제 추방합니다.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
					c_Kick( VOTEKICK_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* 시간이 초과되어 %s(%d)님에 대한 강제추방은 반려됩니다.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] 투표결과 %s(%d)에 대한 강제추방은 반려됨.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
				}
	        }
			else if( VOTEKICK_TICK >= VOTEKICK_NOTIFY_DURATION )
			{
			    VOTEKICK_TICK = 0;
		 		format( str, sizeof(str), "* 현재 %s(%d)님에 대한 강제추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 추방됩니다.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* 투표하시려면 /vkick yes 또는 /킥 예 을(를) 입력하세요." );
				printf("[rcon] 강제추방 투표 %s(%d): %d명중 %d명 찬성. (남은시간 %d초).", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER, NUM_PLAYERS, VOTEKICK_PLAYER_GOT, VOTEKICK_REMAINTIME );
			}
	    }
	}


	if(ENABLE_VOTEBAN)
	{
	    if( VOTEBAN_REMAINTIME > 0 )
	    {
	        VOTEBAN_REMAINTIME--;
	        VOTEBAN_TICK++;
	        if( VOTEBAN_REMAINTIME <= 0 )
	        {
				if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // 추방기준 통과
				{
					format( str, sizeof(str), "* 투표가 종료되었습니다. 투표 결과로 %s(%d)님을 영구히 추방합니다.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] 투표 결과로 %s(%d)님을 영구히 추방합니다.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
					c_Ban( VOTEBAN_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* 시간이 초과되어 %s(%d)님에 대한 영구추방은 반려됩니다.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] 투표결과 %s(%d)에 대한 영구추방은 반려됨.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
				}
	        }
			else if( VOTEBAN_TICK >= VOTEBAN_NOTIFY_DURATION )
			{
			    VOTEBAN_TICK = 0;
		 		format( str, sizeof(str), "* 현재 %s(%d)님에 대한 영구추방 투표가 진행중입니다. (남은 시간 : %d초)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " 총 %d명중 %d명이 찬성표를 던졌으며, %d명 이상이 찬성하면 추방됩니다.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* 투표하시려면 /vBAN yes 또는 /밴 예 을(를) 입력하세요." );
				printf("[rcon] 영구추방 투표 %s(%d): %d명중 %d명 찬성. (남은시간 %d초).", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER, NUM_PLAYERS, VOTEBAN_PLAYER_GOT, VOTEBAN_REMAINTIME );
			}
	    }
	}
}
//==========================================================
#if SAMP03a
//==========================================================
ShowPlayerDialogs( playerid, dialogid ) //사용자에게 대화상자 띄우기
{
    new str[1024];
	switch( dialogid )
	{
	    case DIALOG_ADMIN_MAIN :
	    {
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n메세지 보내기\r\n출두\r\n소환\r\n사살\r\n체력 변경\r\n무적으로 만들기\r\n\
				쌈짓돈 주기\r\n가진돈 뺏기\r\n소지금 설정하기\r\n스코어 설정하기\r\n무기 제공\r\n\
				무기 몰수\r\n프리즈\r\n프리즈 해제\r\n아머 변경\r\n아머 무적\r\n차량 소환\r\n차에서 내리게하기\r\n\
				차에너지 변경\r\n제트팩 주기\r\n음악 재생\r\n재생중인 음악 끄기\r\n뇌 터트리기\r\n\
				채팅 금지\r\n채팅금지 해제\r\n닉네임 바꾸기\r\n이 플레이어 감시\r\n부운영자로 임명\r\n운영권한 박탈\r\n\
				이 유저의 정보 보기",
				"확인", "취소" );
		}
		case DIALOG_ADMIN_KICK :
		{
		    format( str, sizeof(str), "다음 플레이어를 추방합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KICK, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_BAN :
		{
		    format( str, sizeof(str), "다음 플레이어를 영구히 추방합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BAN, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_WITH :
		{
		    format( str, sizeof(str), "다음 플레이어에게 이동합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_WITH, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_CALL :
		{
		    format( str, sizeof(str), "다음 플레이어를 소환합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CALL, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_KILL :
		{
		    format( str, sizeof(str), "다음 플레이어를 사살합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KILL, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SETHP :
		{
		    format( str, sizeof(str), "다음 플레이어의 체력을 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETHP, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_INFINITE :
		{
		    format( str, sizeof(str), "다음 플레이어를 무적으로 만듭니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFINITE, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_MAKECASH :
		{
		    format( str, sizeof(str), "다음 플레이어에게 쌈짓돈을 쥐어줍니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAKECASH, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_FORFEIT :
		{
		    format( str, sizeof(str), "다음 플레이어의 소지금을 박탈합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FORFEIT, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SETCASH :
		{
		    format( str, sizeof(str), "다음 플레이어의 소지금을 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETCASH, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SETSCORE :
		{
		    format( str, sizeof(str), "다음 플레이어의 스코어를 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETSCORE, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_GIVEWP :
		{
			for( new i = 0 ; i < sizeof(WEAPON_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, WEAPON_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s다른 무기..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_LIST, "제공할 무기를 선택하십시오.", str, "선택", "뒤로" );
		}
		case DIALOG_ADMIN_DISARM :
		{
		    format( str, sizeof(str), "다음 플레이어의 무기를 박탈합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DISARM, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_FREEZE :
		{
		    format( str, sizeof(str), "다음 플레이어를 일정시간 묶어둡니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FREEZE, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_UNFREEZE :
		{
		    format( str, sizeof(str), "다음 플레이어의 결박을 풀어줍니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNFREEZE, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
 		case DIALOG_ADMIN_ARMOR :
		{
		    format( str, sizeof(str), "다음 플레이어의 아머를 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_ARMOR, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
 		case DIALOG_ADMIN_INFARMOR :
		{
		    format( str, sizeof(str), "다음 플레이어의 아머를 무한으로 만듭니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFARMOR, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SPAWNCAR :
		{
	    	for( new i = 0 ; i < sizeof(VEHICLE_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, VEHICLE_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s다른 차량..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_LIST, "제공할 차량을 선택하십시오", str, "선택", "뒤로" );
		}
		case DIALOG_ADMIN_SDROP :
		{
		    format( str, sizeof(str), "다음 플레이어를 차에서 내리게 합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SDROP, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_CARENERGY :
		{
		    format( str, sizeof(str), "다음 플레이어의 차에너지를 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CARENERGY, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_JETPACK :
		{
		    format( str, sizeof(str), "다음 플레이어에게 제트팩을 제공합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_JETPACK, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_MUSIC :
		{
	    	for( new i = 0 ; i < sizeof(MUSIC_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, MUSIC_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s다른 음악..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_LIST, "재생할 음악을 선택하십시오", str, "선택", "뒤로" );
		}
		case DIALOG_ADMIN_MUSICOFF :
		{
		    format( str, sizeof(str), "다음 플레이어의 재생중인 음악을 중지합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSICOFF, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_BOMB :
		{
		    format( str, sizeof(str), "다음 플레이어의 뇌를 터트립니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BOMB, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SHUTUP :
		{
		    format( str, sizeof(str), "다음 플레이어의 채팅을 일정시간 금지합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SHUTUP, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_UNSHUT :
		{
		    format( str, sizeof(str), "다음 플레이어의 채팅금지를 해제합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNSHUT, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_CHANGENICK :
		{
		    format( str, sizeof(str), "다음 플레이어의 닉네임을 변경합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CHANGENICK, DIALOG_STYLE_INPUT, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_SPECTATE :
		{
		    format( str, sizeof(str), "다음 플레이어를 감시합니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPECTATE, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}		
		case DIALOG_ADMIN_SUBADMIN :
		{
			new tmp[128];
			str="모든 권한";
			for(new i=1;i<32;i++)
			{
				format(tmp,sizeof(tmp),"Auth_Profile%d",i);
				set( tmp, c_iniGet("[SubAdmin]",tmp) );
				if( !tmp[0] ) break;
				format( str, sizeof(str), "%s\r\n%s", str, tmp );
			}
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_LIST, "해당 플레이어에게 부여할 권한을 선택하십시오.", str, "선택", "뒤로" );
		}
		case DIALOG_ADMIN_DELSUB :
		{
			format( str, sizeof(str), "%s(%d)님의  부운영자 권한을 박탈합니다.\r\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DELSUB, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_ADMIN_FIND :
		{
		    format( str, sizeof(str), "다음 플레이어의 정보를 봅니다: %s(%d).\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FIND, DIALOG_STYLE_MSGBOX, "계속하시겠습니까?", str, "예", "아니오" );
		}
		case DIALOG_PM :
		{
 		    format( str, sizeof(str), "%s(%d)님에게 보낼 메세지를 입력하여 주십시오.",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_PM, DIALOG_STYLE_INPUT, "메세지 보내기", str, "보내기", "뒤로" );
		}
		case DIALOG_USER_MAIN :
		{
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n메세지 보내기",
				"확인", "취소" );
		}
		case DIALOG_USER_VOTEKICK :
		{
		    format( str, sizeof(str), "%s(%d)님의 추방을 요청합니다.\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEKICK, DIALOG_STYLE_MSGBOX, "강제추방 투표", str, "예", "아니오" );
		}
		case DIALOG_USER_VOTEBAN :
		{
			format( str, sizeof(str), "%s(%d)님의 영구추방을 요청합니다.\n계속하시겠습니까?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "영구추방 투표", str, "예", "아니오" );
		}		
		default:
		{
			format( str, sizeof(str), "오류가 있습니다. DIALOG_ID : %d", dialogid );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "오류 발견!", str, "ㅇㅇ", "ㅇㅇ" );
		}
	}
	return 1;
}
//==========================================================
public Firstrun()
{
	print(LINE);
	print("\n[rcon] 처음 사용하시는군요! 저는 여러분의 서버관리를 도와주는 스크립트입니다.");
	print("[rcon] 기본적으로 제게는 대화형 명령어 및 와일드카드 기능이 있습니다.");
	printf("[rcon] 보통 명령어는 '%s player1 10000' 식으로 입력하는데요,", GetCmdName(CMD_MCASH));
	printf("[rcon] 명령어를 '%s ?' 로 입력하면 명령어를 쉽게 사용할 수 있습니다 ^.^", GetCmdName(CMD_MCASH));
	print("[rcon] 또 player1이 들어갈 자리에 '*'나 '!', '~'를 입력할 수가 있는데요.");
	print("[rcon] '*'는 '모든 사람', '!'는 '나와 가까이 있는 사람', '~'는 '마지막으로 채팅한 사람'을 의미해요.");
	printf("[rcon] 예를 들어, '%s * 1000' 이라고 쓰면 모든 사람에게 1000달러를 주는거죠.", GetCmdName(CMD_MCASH));
	printf("[rcon] 기타 도움말 목록을 보시려면 '%s' 를 입력하세요. 안녕!\n", GetCmdName(CMD_HELP));	
	print(LINE);
}
//==========================================================
#endif /* SA-MP 0.3a의 다이얼로그 기능 사용 */
//==========================================================
// Utility-Functions
//==========================================================
Process_GivePlayerID( playerid, params[], bool:checkadmin = false )
{
	new temp;
	
	if(isNumeric(params) && strval(params)>=0 && strval(params)<M_P && IsPlayerConnectedEx(strval(params))) return strval(params);
	else if((temp=PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) return temp;
	else if( params[0] == '*' && !params[1] ) return ALL_PLAYER_ID; //for All players
	else if( params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID) ) return LAST_PLAYER_ID; //last chatted player
	else if( params[0] == '!' && !params[1] ) //closest player
	{
		if( CONSOLE || NUM_PLAYERS < 2 ) return ABORT_PROCESS;
		SendClientMessage( playerid, COLOR_GREY, "* 가장 가까이 있는 사용자를 찾습니다.." );
		return GetClosestPlayer( playerid );
	}
	else if(params[0] == '?'  )
	{
		if ( !params[1] ) return INTERACTIVE_MANAGEMENT; //interactive management
		else if ( params[1] == '?' && !params[2] ) return HELP_PROCESS;
	}
	else if( checkadmin && (!strcmp( params, "Admin", true ) || !strcmp( params, "운영자", false)) ) return ADMIN_ID;
	return INVALID_PLAYER_ID;
}
//==========================================================
Post_Process( playerid, giveplayerid, Cmdorder:CMD_CURRENT, bool: process_interactive =true )
{
	//정제된 giveplayerid로 명령어 실행
	switch ( giveplayerid )
	{
		//case ADMIN_ID:
		case HELP_PROCESS:
		{
			new str[sizeof(cmdlist[])];
			format( str, sizeof(str), "dcmd_%s", cmdlist[CMD_CURRENT][Func] );
			CallLocalFunction( str, "isib", playerid, NULL, _:CMD_CURRENT, true );
			return PROCESS_COMPLETE;
		}
		case ABORT_PROCESS:
		{
			if( CONSOLE ) print("[rcon] 콘솔에서는 사용할 수 없습니다.");
			else SendClientMessage( playerid, COLOR_GREY, "* 사람이 없어 사용할 수 없습니다.");
			return PROCESS_COMPLETE;
		}
		case INVALID_PLAYER_ID: //Processed Invalid input
		{
			if(CONSOLE) print("[rcon] 잘못 입력하셨거나 현재 접속중이 아닙니다.");
			else SendClientMessage(playerid,COLOR_GREY,"* 잘못 입력하셨거나 현재 접속중이 아닙니다.");
			return PROCESS_COMPLETE;
		}
		case INTERACTIVE_MANAGEMENT: //Wildcard '?" enabled
		{
			if( process_interactive )
			{
				if( CONSOLE )
				{
					dcmd_stat ( playerid, NULL, CMD_STAT, NO_HELP );
					print("[rcon] 원하는 플레이어를 입력하십시오. 취소하려면 ?을 입력하십시오." );
				}
				else
				{
					#if SAMP02X
						dcmd_stat( playerid, NULL, CMD_STAT, NO_HELP );
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* 원하는 플레이어를 입력하십시오. 취소하려면 ?을 입력하십시오." );
					#else
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* TAB을 누르고 원하는 플레이어를 더블클릭 하십시오. 와일드카드를 쓸 수도 있습니다.");
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* 취소하려면 ?을 입력하십시오." );
					#endif
				}
				INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				INTERACTIVE_STATE[playerid] = 0;
				return PROCESS_COMPLETE;
			}
		}
	}
	INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	return giveplayerid;
}
//==========================================================
Usage( playerid, Cmdorder:CMD_CURRENT )
{
	new str[128];
	if(CONSOLE)
	{
		printf("[rcon] 사용법: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS);
		printf("[rcon] 자세한 사용법은 도움말 %s 을(를) 입력하세요.", CURRENT_CMD_NAME );
	}
	else
	{
		format( str, sizeof(str), "* 사용법: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME,  CURRENT_PARAMS);
		SendClientMessage(playerid, COLOR_GREY, str );
		format( str, sizeof(str), "* 자세한 사용법은 /%s %s 을(를) 입력하세요.", GetCmdName(CMD_HELP), CURRENT_CMD_NAME );
		SendClientMessage(playerid, COLOR_GREY, str );
	}
	return 1;
}
//==========================================================
#if SAMP03b
//==========================================================
public UpdateCheck(index, response_code, data[])
{
	//debugprintf("[rcon] 코드: %d", response_code);
	//debugprintf("[rcon] data: %s",data);
	switch(response_code)
	{
		case HTTP_ERROR_CANT_CONNECT:
		{
			printf("[rcon] 업데이트 서버에 연결할 수 없습니다.");
			return 1;
		}
		case 200: {}
		default:
		{
			printf("[rcon] 업데이트 확인에 실패했습니다. 오류 코드: %d", response_code);
			return 1;
		}
	}

	new version, vstring[128], rdate[128];	
	if( sscanf( data, "p,iss", version, vstring, rdate ) )
	{
		print("[rcon] 업데이트 확인에 실패했습니다. 서버가 좆됐습니다...ㅠㅠ");
		return 1;
	}
	
	if( version <= VERSION_INTERNAL )
	{
		printf("[rcon] 현재 최신 버전을 사용하고 있습니다.");
		return 1;
	}	
	printf("[rcon] 업데이트 가능한 버전이 있습니다.\n  \
			***********************************\n  \
			* 현재 버전: %-12s         *\n  \
			* 최신 버전: %-12s         *\n  \
			* 릴리즈 날짜 : %s        *\n  \
			***********************************", VERSION, vstring, rdate );
	print("[rcon] cafe.daum.net/Coolpdt를 방문하여 최신 버전을 다운로드받으시기 바랍니다.");
	//최신 버전의 폴더로 접근, 리스트 파일을 얻는다.
	//new tmp[256];
	//format( tmp, sizeof(tmp), "dl.dropbox.com/u/8120060/SA-MP/%d/index.txt", version );
	//HTTP( UPDATE_FILELIST, HTTP_GET,  tmp, "", "UpdateCheck");
	return 1;
}
//==========================================================
#endif /* SA-MP 0.3b의 업데이트 기능 사용 */
//==========================================================
CreateDump()
{
	new File:hnd = fopen( FILE_DUMP, io_write ), str[512];
	if( !hnd )
	{
		print("[rcon] 덤프 생성에 실패했습니다.");
		return ;
	}
	//==========================================================
	//Save your data : Dump Settings
	//==========================================================
	format( str, sizeof(str), "%d\r\n%d\r\n", tickcount(), DUMPEXIT );
	c_fwrite( hnd, str );
	//==========================================================
	//Make a Quick Dump
	//==========================================================
	format( str, sizeof(str), "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n",
		ALLOW_DESYNC,
		USE_PINGCHECK,
		USE_ANTI_MONEYCHEAT,
		USE_ANTI_WEAPONCHEAT,
		USE_ANTI_CHATFLOOD,
		USE_ANTI_CMDFLOOD,
		SERVER_LOCKED,
		USE_YELLFILTER,
		ALLOW_JETPACK,
		ENABLE_VOTEKICK,
		ENABLE_VOTEBAN,
		VOTEKICK_RUN_TIME,
		VOTEBAN_RUN_TIME,
		VOTEKICK_NOTIFY_DURATION,
		VOTEBAN_NOTIFY_DURATION,
		VOTE_CONFIDENTIALITY,
		REQUIRED_MAN_VOTEKICK,
		REQUIRED_MAN_VOTEBAN,
		MINIMUM_VOTEKICK_PERCENTAGE,
		MINIMUM_VOTEBAN_PERCENTAGE,
		VOTEKICK_PLAYER,
		VOTEBAN_PLAYER,
		VOTEKICK_PLAYER_GOT,
		VOTEBAN_PLAYER_GOT,
		VOTEKICK_REMAINTIME,
		VOTEBAN_REMAINTIME,
		CURRENT_VOTEKICK_REQUIREMENT,//투표 당시에 필요한 찬성인원
		CURRENT_VOTEBAN_REQUIREMENT,//투표 당시에 필요한 찬성인원
		VOTEKICK_TICK,
		VOTEBAN_TICK

	);
 	c_fwrite( hnd, str );
	for( new i = 0; i < M_P; i++ )
	{
		format( str, sizeof(str), "%d,%d,%d,%d\r\n",
			PLAYER_SPAWNED[i] ,
			IS_PLAYER_SPECTATING[i],
			IS_PLAYER_SPECTATED[i],
			PLAYER_CASH[i]
		);
		c_fwrite( hnd, str );
	}
	
	//투표가 진행중이었던 경우 중복투표 검사값 저장하기
	if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
	{
		for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
		{
			c_fwrite( hnd, RetStr(KICKVOTED_PLAYER_IP[i]) );
		}
	}
	//투표가 진행중이었던 경우 중복투표 검사값 저장하기
	if( ENABLE_VOTEBAN && VOTEBAN_REMAINTIME > 0 )
	{
	    for( new i = 0; i < VOTEBAN_PLAYER_GOT; i++ )
		{
		    c_fwrite( hnd, RetStr(BANVOTED_PLAYER_IP[i]) );
		}
	}
	//==========================================================
	//Make a Full Dump
	//==========================================================
	if( DUMPEXIT == 2)
	{
		//print("[rcon] 전체 덤프를 생성중입니다...");
		format( str, sizeof(str), "%d,%d,%d,%d,%d\r\n",
			USE_BADWARN,
			CUR_BADP_POINT,
			//READ_CINPUT,
			PINGCHECK_DURATION,
			LAST_PLAYER_ID,
			PERMANENT_ADMINSAY[MAX_PLAYERS]
		);
		c_fwrite( hnd, str );
		for( new i = 0; i < M_P; i++ )
		{
			format( str, sizeof(str), "%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\r\n",
				PERMANENT_ADMINSAY[i],
				IS_HEAR_CMDTRACE[i],
				PLAYER_PMABUSE_TIMES[i],
				CMDFLOOD_STILL_TIMES[i],
				PLAYER_PUNISH_REMAINTIME[i][0],
				PLAYER_PUNISH_REMAINTIME[i][1],
				PLAYER_PUNISH_REMAINTIME[i][2],
				PLAYER_DESYNCED_TIMES[i],
				SUBADMIN_FAILLOGIN_TIMES[i],
				HIGHPING_WARNED_TIMES[i],
				_:INTERACTIVE_COMMAND[i]
			);
			c_fwrite( hnd, str );
			str[0] = EOS;
			for( new j = 1; j < NUM_AUTH; j++ ) format( str, sizeof(str), "%s%d,", str, PLAYER_AUTHORITY[i][Authinfo:j] );
			format( str, sizeof(str), "%s\r\n", str );
			c_fwrite( hnd, str );
		}
		str[0] = EOS;
		for( new i = 0; i < MAX_WEAPONS; i++ ) format( str, sizeof(str), "%s%d,", str, IS_WEAPON_FORBIDDEN[i] );
		format( str, sizeof(str), "%s\r\n", str );
		c_fwrite( hnd, str );
		/*for( new i = 0; i < CUR_BADP_POINT ; i++ )
		{
			format( str, sizeof(str), "%d,%d\r\n", BAD_PLAYER_IP[i], BADKICKED_TIMESTAMP[i] );
			c_fwrite( hnd, str );
		}*/
	}
	fclose( hnd );
	//print("[rcon] 덤프 생성을 완료했습니다.");
}
//==========================================================
CallDump()
{
	new File:hnd = fopen( FILE_DUMP, io_read ), str[512], idx, FULLDUMP;
	if( !hnd ) print("[rcon] 덤프 이식에 실패했습니다.");
	else
	{
		fread( hnd, str );
		StripNL( str );
		if( tickcount() - strval( str ) > 1000 || tickcount() - strval( str ) < 0 ) print("[rcon] 덤프 파일이 낡아 이식하지 않고 폐기합니다.");
		else
		{
			fread( hnd, str );
			StripNL( str );
			FULLDUMP = strval( str );

			fread( hnd, str );
			StripNL( str );
			idx = 0;
			ALLOW_DESYNC = strval(strtok( str, idx, ',' ));
			USE_PINGCHECK = strval(strtok( str, idx, ',' ));
			USE_ANTI_MONEYCHEAT = strval(strtok( str, idx, ',' ));
			USE_ANTI_WEAPONCHEAT = strval(strtok( str, idx, ',' ));
			USE_ANTI_CHATFLOOD = strval(strtok( str, idx, ',' ));
			USE_ANTI_CMDFLOOD = strval(strtok( str, idx, ',' ));
			SERVER_LOCKED = strval(strtok( str, idx, ',' ));
			USE_YELLFILTER = strval(strtok( str, idx, ',' ));
			ALLOW_JETPACK = strval(strtok( str, idx, ',' ));
			
			ENABLE_VOTEKICK = strval(strtok( str, idx, ',' ));//투표 활성화
			ENABLE_VOTEBAN = strval(strtok( str, idx, ',' ));
			VOTEKICK_RUN_TIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_RUN_TIME = strval(strtok( str, idx, ',' )); //투표 돌리는 시간
			VOTEKICK_NOTIFY_DURATION = strval(strtok( str, idx, ',' ));
			VOTEBAN_NOTIFY_DURATION = strval(strtok( str, idx, ',' )); // 투표상황 공지 주기
			VOTE_CONFIDENTIALITY = strval(strtok( str, idx, ',' )); // 투표 신고인 명시여부
			REQUIRED_MAN_VOTEKICK = strval(strtok( str, idx, ',' ));
			REQUIRED_MAN_VOTEBAN = strval(strtok( str, idx, ',' ));// 강제추방을 시작할 최소인원
			MINIMUM_VOTEKICK_PERCENTAGE = strval(strtok( str, idx, ',' )); // 강제추방까지 필요한 득표율
			MINIMUM_VOTEBAN_PERCENTAGE = strval(strtok( str, idx, ',' ));
			
			VOTEKICK_PLAYER = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER = strval(strtok( str, idx, ',' )); //대상 플레이어 아이디
			VOTEKICK_PLAYER_GOT = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER_GOT = strval(strtok( str, idx, ',' ));	//받은 표
			VOTEKICK_REMAINTIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_REMAINTIME = strval(strtok( str, idx, ',' )); //남은 시간
			CURRENT_VOTEKICK_REQUIREMENT = strval(strtok( str, idx, ',' ));//투표 당시에 필요한 찬성인원
			CURRENT_VOTEBAN_REQUIREMENT = strval(strtok( str, idx, ',' ));//투표 당시에 필요한 찬성인원
			VOTEKICK_TICK = strval(strtok( str, idx, ',' )); // 강제추방 공지 돌리는 타이머
			VOTEBAN_TICK = strval(strtok( str, idx, ',' ));

			for( new i = 0; i < M_P; i++ )
			{
				fread( hnd, str );
				StripNL( str );
				idx = 0;
				PLAYER_SPAWNED[i] = strval(strtok( str, idx, ',' ));
				IS_PLAYER_SPECTATING[i] = strval(strtok( str, idx, ',' ));
				IS_PLAYER_SPECTATED[i] = strval(strtok( str, idx, ',' ));
				PLAYER_CASH[i] = strval(strtok( str, idx, ',' ));
			}
			
			//투표가 진행중이었던 경우 중복투표 검사값 불러오기
			if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
			{
				for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					KICKVOTED_PLAYER_IP[i] = strval(str);//중복투표 방지용 IP저장소
				}
			}
			//투표가 진행중이었던 경우 중복투표 검사값 불러오기
			if( ENABLE_VOTEBAN && VOTEBAN_REMAINTIME > 0 )
			{
				for( new i = 0; i < VOTEBAN_PLAYER_GOT; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					BANVOTED_PLAYER_IP[i] = strval(str);
				}
			}

			if( FULLDUMP == 2 )
			{
				//print("[rcon] 전체 덤프를 이식중입니다...");
				fread( hnd, str );
				StripNL( str );
				idx = 0;
				USE_BADWARN = strval(strtok( str, idx, ',' ));
				CUR_BADP_POINT = strval(strtok( str, idx, ',' ));
				//READ_CINPUT = strval(strtok( str, idx, ',' ));
				PINGCHECK_DURATION = strval(strtok( str, idx, ',' ));
				LAST_PLAYER_ID = strval(strtok( str, idx, ',' ));
				PERMANENT_ADMINSAY[MAX_PLAYERS] = strval(strtok( str, idx, ',' ));
				
				for( new i = 0; i < M_P; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					idx = 0;
					PERMANENT_ADMINSAY[i] = strval(strtok( str, idx, ',' ));
					IS_HEAR_CMDTRACE[i]	 = strval(strtok( str, idx, ',' ));
					PLAYER_PMABUSE_TIMES[i] = strval(strtok( str, idx, ',' ));
					CMDFLOOD_STILL_TIMES[i] = strval(strtok( str, idx, ',' ));
					PLAYER_PUNISH_REMAINTIME[i][0] = strval(strtok( str, idx, ',' ));
					PLAYER_PUNISH_REMAINTIME[i][1] = strval(strtok( str, idx, ',' ));
					PLAYER_PUNISH_REMAINTIME[i][2] = strval(strtok( str, idx, ',' ));
					PLAYER_DESYNCED_TIMES[i] = strval(strtok( str, idx, ',' ));
					SUBADMIN_FAILLOGIN_TIMES[i] = strval(strtok( str, idx, ',' ));
					HIGHPING_WARNED_TIMES[i] = strval(strtok( str, idx, ',' ));
					INTERACTIVE_COMMAND[i] = Cmdorder:strval(strtok( str, idx, ',' ));
					fread( hnd, str );
					StripNL( str );
					idx = 0;
					for( new j = 1; j < NUM_AUTH; j++ ) PLAYER_AUTHORITY[i][Authinfo:j] = strval(strtok( str, idx, ',' ));
				}
				fread( hnd, str );
				StripNL( str );
				idx = 0;
				for( new i = 0; i < MAX_WEAPONS; i++ ) IS_WEAPON_FORBIDDEN[i] = strval(strtok( str, idx, ',' ));
				/*for( new i = 0; i < CUR_BADP_POINT; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					idx = 0;
					if( str[0] == ',' ) continue;
					BAD_PLAYER_IP[i] = strval( strtok( str, idx, ',' ) );
					BADKICKED_TIMESTAMP[i] = strval(strtok( str, idx, ',' ));
				}*/
			}
			//print("[rcon] 덤프 이식을 완료했습니다.");
		}
		fclose( hnd );
	}
	fremove( FILE_DUMP );
}
//==========================================================
/* AuthorityCheck( playerid, authority )
{
	if ( CONSOLE || IsPlayerAdmin(playerid) || (IsPlayerSubAdmin(playerid) && PLAYER_AUTHORITY[playerid][authority]) ) return 1;
	return 0;
} */
//==========================================================
public GivePlayerCash(playerid,money)
{
	if((money>0 && GetPlayerCash(playerid)>0 && GetPlayerCash(playerid)+money < 0) || (money<0 && GetPlayerCash(playerid)<0 && GetPlayerCash(playerid)+money > 0)) return ;
	PLAYER_CASH[playerid] += money;
	GivePlayerMoney(playerid, money);
}
//==========================================================
public ResetPlayerCash(playerid)
{
	PLAYER_CASH[playerid] = 0;
	ResetPlayerMoney( playerid );
}
//==========================================================
public SetPlayerCash(playerid, money)
{
	PLAYER_CASH[playerid] = money;
	GivePlayerMoney(playerid, money - GetPlayerMoney(playerid));
}
//==========================================================
public GetPlayerCash(playerid) return (USE_ANTI_MONEYCHEAT)? (PLAYER_CASH[playerid]):(GetPlayerMoney(playerid));
//==========================================================
LoadYellList()
{
	if( !fexist(FILE_YELLFILTER) )
	{
		print("[ERROR] RC_yell.ini를 찾을 수 없습니다. 욕필터 기능이 제한됩니다.");
		print(" scriptfiles\\MINIMINI 폴더에 RC_yell.ini를 넣어주세요.");
		USE_YELLFILTER = 0;
		return ;
	}

	num_Yells = 0;
	new File:hnd = fopen( FILE_YELLFILTER, io_read ), str[512];
	fread( hnd, YELL_VER );
	StripNL( YELL_VER );
	while( fread( hnd, str ) )
	{
		StripNL(str);
		if( str[0] && str[0] != '#' && str[1] )
		{
			if ( str[0] == ' ' ) set(YELLS[num_Yells], str[1]);
			else set(YELLS[num_Yells], str);
		}
		num_Yells++;
		if( num_Yells == MAX_YELLS ) break;
	}
	fclose( hnd );
}
//==========================================================
IsYellExists(yell[])
{
	new File:fhandle, str[512];
	if((fhandle=fopen(FILE_YELLFILTER,io_read)))
	{
		while(fread(fhandle,str))
		{
			StripNL(str);
			if( !str[0] || str[0]=='#' ) continue;
			if( !strcmp( (str[0]==' ')? (ret_memcpy(str,1,MAX_YELL_CHAR)):(str), yell ) ) return 1;
		}
		fclose(fhandle);
	}//end if fopen
	return 0;
}
//==========================================================
PRIVATE_GetClosestPlayerID( partofname[] )
{
	if( !partofname[0] ) return INVALID_PLAYER_ID;
	new len = strlen( partofname );
	for(new i = 0 ; i < NUM_PLAYERS ; i++)
	{
		if( strcmp( GetPlayerNameEx( pITT[i] ), partofname, true, len) == 0 )
		{
			return pITT[i];
		}
	}
	return INVALID_PLAYER_ID;
}
//==========================================================
public ReLockServer()
{
	SERVER_LOCKED = 1;
	print("[rcon] 서버가 다시 잠금상태로 설정되었습니다.");
}
//==========================================================
IsCmdNeedToHide(cmd[])
{
	static hidecmds[][]=
	{
		"/부운로그인",
		"/sublogin",
		"/log",
		"/reg",
		"/로그인"
	};
	for(new i=0;i<sizeof(hidecmds);i++) if(!strcmp(cmd,hidecmds[i],true,strlen(hidecmds[i]))) return 1;
	return 0;
}
//==========================================================
LoadPlayerAuthProfile(playerid,profile_id)
{
	if(profile_id == 0) //기본 설정: 모든 권한
	{
		for(new i = 2 ; i < NUM_AUTH ; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 1;
		SendClientMessage(playerid,COLOR_IVORY,"* 권한 '모든 권한'(0)이 주어졌습니다.");
		return true;
	}
	for( new i = 2; i < NUM_AUTH; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 0;
	new i = 2,File:fhnd,str[MAX_STRING];
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	str=join("MINIMINI/",c_iniGet("[SubAdmin]",str));
	if(!fexist(str))
	{
		format(str,sizeof(str),"* RconController.ini의 Auth_Profile%d에 기록된 파일을 찾을 수 없습니다.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] RconController.ini의 Auth_Profile%d에 기록된 파일을 찾을 수 없습니다.",profile_id);
		return false;
	}
	fhnd=fopen(str,io_read);
	while(i < NUM_AUTH && fread(fhnd,str) )
	{
		if(str[0]=='0' || str[0]=='1')
		{
			PLAYER_AUTHORITY[playerid][Authinfo:i] = (str[0]=='1');
			i++;
		}
	}
	fclose(fhnd);
	if(i != NUM_AUTH)
	{
		format(str,sizeof(str),"* 권한 프로필 %d번에 이상이 있습니다. 파일을 확인해주세요.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] 권한 프로필 %d번에 이상이 있습니다. 파일을 확인해주세요.",profile_id);
	}
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	format(str,sizeof(str),"* 권한 %s(%d)이 주어졌습니다.",(profile_id)? (c_iniGet("[SubAdmin]",str)):("모든 권한"),profile_id);
	SendClientMessage(playerid,COLOR_IVORY,str);
	return true;
}
//==========================================================
CheckNoticeList()
{
	Num_Notice=0;
	new File:fhnd, str[256], line;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//공지가 시작될때까지 빠른 스킵
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===공지 시작===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//줄 자르고, 주석과 단순엔터는 스킵
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//공지가 끝난 경우		
		if( !strcmp( str, "===공지 끝===" ) )
		{
			if( line ) Num_Notice++;
			break;
		}
		line++;		
		//구분선을 만난 경우
		if( !strcmp( str, "===구분선===" ) )
		{
			Num_Notice++;
			continue;
		}
		//구문오류 확인
		if( str[0] == '<' && strfind( str, ">" ) == -1 )
		{
			printf( "[rcon] 공지 구문에 오류가 있습니다! 공지를 사용하지 않습니다.\n 오류 문장 : %s", str);
			format( str, sizeof(str), "* 공지 구문에 오류가 있습니다! 공지를 사용하지 않습니다.\n 오류 문장 : %s", str);
			SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
			NOTICE_INTERVAL = 0;
			break ;
		}
	}	
	fclose(fhnd);
	//공지가 없는 경우
	if( Num_Notice == 0 )
	{
		printf( "[rcon] 공지가 없습니다. 공지 기능을 비활성화합니다.");
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,"* 공지가 없습니다. 공지 기능을 비활성화합니다.");
		NOTICE_INTERVAL = 0;
	}
}
//==========================================================
SendPlayerNotice(index)
{
	new File:fhnd, curidx = 1, str[256], color, stridx;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//공지가 시작될때까지 빠른 스킵
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===공지 시작===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//줄 자르고, 주석과 단순엔터는 스킵
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//공지가 끝난 경우 스크립트 중지
		if( !strcmp( str, "===공지 끝===" ) ) break;
		//구분선을 만난 경우
		if( !strcmp( str, "===구분선===" ) ) 
		{
			if( curidx == index ) break; //공지를 올리는 중이었던 경우 중지
			curidx++; //인덱스 증가
			continue;
		}
		//인덱스에 도달할 때까지 진행
		if( curidx != index ) continue;
		/* 멀티라인 공지를 읽는다 */
		stridx = 0; //기본값 적용
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //색깔 핸들러 확인
		{
			//공지띄울때의 인덱스 지정
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX값의 경우 직접 지정
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//미리 설정된 색깔
			else if ( !strcmp( str[1], "빨강" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "파랑" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "밝은 파랑" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "노랑" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "핑크" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "무적핑크" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "녹색" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "라임" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "흰색" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "시스템" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "회색" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "갈색" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "청록색" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "오렌지" ) ) color = COLOR_ORANGE;
		}
		//공지 띄우기
		printf("[rcon] 공지 - %s", str[stridx] );
		SendClientMessageToAll( color, str[stridx] );
	}
	fclose(fhnd);
}
//==========================================================
stock c_Kick( playerid )
{
	PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_FREEZE] = KICK_THIS_PLAYER;
	return ;
}
//==========================================================
stock c_BanEx( playerid, reason[] )
{
	SetPVarString( playerid, "BAN_REASON", reason );
	PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = BAN_THIS_PLAYER;
	return ;
}
//==========================================================
stock c_Ban( playerid )
{
	PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = BAN_THIS_PLAYER;
	return ;
}
//==========================================================
GetClosestPlayer( playerid )
{
	new Float:pos[3], Float:closest, Float:distance, CLOSEST_PLAYER_ID=INVALID_PLAYER_ID;
	GetPlayerPos( playerid, pos[0], pos[1], pos[2]);
	
	CLOSEST_PLAYER_ID = (pITT[0] == playerid)? (pITT[1]):(pITT[0]);
	closest = GetPlayerDistanceFromPoint( CLOSEST_PLAYER_ID, pos[0], pos[1], pos[2] );

	for ( new i = 0 ; i < NUM_PLAYERS ; i++ )
	{
		if ( pITT[i] == playerid ) continue;
		distance = GetPlayerDistanceFromPoint( pITT[i], pos[0], pos[1], pos[2] );
		if ( closest > distance )
		{
			CLOSEST_PLAYER_ID = pITT[i];
			closest = distance;
		}
	}
	return CLOSEST_PLAYER_ID;
}
//==========================================================
duplicatesymbol(symbol,count)
{
	new tempst[2],string[256];
	format(tempst,128,"%c",symbol);
	for (new i=0;i<count;i++)
	{
		strins(string,tempst,strlen(string),strlen(string)+1+strlen(tempst));
	}
	return string;
}
//==========================================================
// Doodles
//==========================================================
/*
	#define dcmd(%1,%2,%3) if((strcmp(cmdtext[1],(%1),true,(%2))==0) && (((cmdtext[(%2)+1]==0) && (dcmd_%3(playerid,"")))||((cmdtext[(%2)+1]==32) && (dcmd_%3(playerid,cmdtext[(%2)+2]))))) return 1
//If 문으로 걸러주는경우 - SubAdmin 점검안함
#define dcmd_auth(%1,%2,%3,%4) \
	if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32)&& \
	(((CONSOLE||IsPlayerAdmin(playerid)||AuthorityCheck(playerid,%4))&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))|| \
	(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid,COLOR_RED,"* 해당 명령어를 사용할 권한이 없습니다."))) return 1
//If 문으로 걸러주지않는경우 - SubAdmin 점검함
#define dcmd_auth(%1,%2,%3,%4) if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32) \
	&&((AuthorityCheck(playerid,%4)&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))||(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid, COLOR_RED, "* 해당 명령어를 사용할 권한이 없습니다."))) return 1
*/


