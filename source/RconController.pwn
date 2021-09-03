/*==========================================================
		"Rcon Controller" Filterscript for SA-MP
	Copyright (C) 2008-2015 CoolGuy(¹ä¸Ô¾ú´Ï)

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
	Á¦ÀÛ - CoolGuy(¹ä¸Ô¾ú´Ï)

ÃÖ±ÙÀÇ ¼Ò½ºÄÚµå ¼öÁ¤ »çÇ×Àº changelog.txt¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.

"Rcon Controller" ¹× ÇÁ·Î±×·¥ °ø½ÄÄ«Æä :
http://cafe.daum.net/Coolpdt
//=========================================================*/
//==========================================================
// Informations & Compile Options
//==========================================================
#define VERSION "V18 alpha3"
#define VERSION_INTERNAL 1803
#define MAX_SUBADMIN 20 //Ãß°¡ °¡´ÉÇÑ ºÎ¿î¿µÁøÀÇ ¼öÀÔ´Ï´Ù.
#define MAX_YELLS 200 //Ãß°¡ °¡´ÉÇÑ ¿åÀÇ °¹¼öÀÔ´Ï´Ù.
#define MAX_YELL_CHAR 64 //ÃÖ´ë·Î Ãß°¡ÇÒ ¼ö ÀÖ´Â ¿åÀÇ ±æÀÌÀÔ´Ï´Ù.
#define MAX_BAD_PLAYERS 200 //ÃÖ´ë·Î ÀúÀåÇÒ ¼ö ÀÖ´Â ºñ¸Å³Ê ÇÃ·¹ÀÌ¾îÀÇ ¼öÀÔ´Ï´Ù.
/* ÇÏÀ§ ¹öÀü È£È¯¼º */
#define SAMP02X false //0.2X È£È¯ ÄÄÆÄÀÏ : »óÀ§ ¹öÀü ¿É¼ÇÀ» ¸ðµÎ ÇØÁ¦ÇÏ½Ã±â ¹Ù¶ø´Ï´Ù.
#define SAMP03a true //0.3a ¿¡¼­ Ãß°¡µÈ ±â´É(GUI, RCON ¹æ¾î)»ç¿ë
#define SAMP03b true //0.3b ¿¡¼­ Ãß°¡µÈ ±â´É(¾÷µ¥ÀÌÆ® È®ÀÎ) »ç¿ë
#define SAMP03x true //0.3x ¿¡¼­ Ãß°¡µÈ ±â´É »ç¿ë
#define SAMP03z true //0.3z ¿¡¼­ Ãß°¡µÈ ±â´É »ç¿ë(ÄÝ¹é ÇÔ¼ö)
#define PLUGIN false //ÇÃ·¯±×ÀÎ »ç¿ë
#define COPYRIGHT_STRING "Copyright (c) 2008-2015 CoolGuy"



//==========================================================
// Includes
//==========================================================
#include <a_samp>
#if SAMP03b /* SA-MP 0.3bÀÇ  ±â´É »ç¿ë */
	#include <a_http>
#endif
#if PLUGIN /* ÇÃ·¯±×ÀÎ Á¡°Ë */
	#include "filemanager"
#endif
#include "dutils"
#define _COOLGUY_NO_SUBADMIN
#include "coolguy" //CoolGuy's Standard Header
#include "y_bintree.inc" //Binary Tree


//=========================================================
// General Macros & Magic Numbers À§ ¾Æ·¡ À§À§¾Æ·¡ À§ ¾Æ·¡ À§À§¾Æ·¡
//=========================================================
//ÆÄÀÏ ¸ñ·Ï Á¤ÀÇ
#define FILE_SETTINGS "MINIMINI/RconController.ini"
#define FILE_YELLFILTER "MINIMINI/RC_Yells.ini"
#define FILE_DUMP "RC_Dump.txt"
#define FILE_FIRSTRUN "MINIMINI/firstrun"
#define DUMPEXIST fexist(FILE_DUMP)

//ÄÜ¼Ö ÀÎ½Ä °ü·Ã
#define ADMIN_ID MAX_PLAYERS
#define CONSOLE (playerid == ADMIN_ID)

//¹«±âÇÙ °ü·Ã
#define MAX_WEAPONS 55

//¹úÄ¢ °ü·Ã
#define PUNISH_FREEZE 0
#define PUNISH_SHUTUP 1
#define PUNISH_CMDRESTRICT 2
#define KICK_THIS_PLAYER -100
#define BAN_THIS_PLAYER -500

/* GUI °ü·Ã */
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
#if SAMP03b /* SA-MP 0.3bÀÇ ¾÷µ¥ÀÌÆ® ±â´É »ç¿ë */
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
#define No_Console() if(CONSOLE) return !print("[rcon] ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.")
#define No_Wildcard() (CONSOLE)? ((print("[rcon] ¿ÍÀÏµåÄ«µå¸¦ »ç¿ëÇÒ ¼ö ¾ø´Â ¸í·É¾îÀÔ´Ï´Ù.") ^ 1)):(SendClientMessage(playerid, COLOR_GREY, "* ¿ÍÀÏµåÄ«µå¸¦ »ç¿ëÇÒ ¼ö ¾ø´Â ¸í·É¾îÀÔ´Ï´Ù."))
#define STUB() print("stub")
#define SEND() SendClientMessage( playerid, COLOR_LIME, str )
#define SEND_C(%1) SendClientMessage( playerid, %1, str )

//ÀÚµ¿ ¸í·É¾î ÇÚµé·¯ : ÄÄÆÄÀÏ ¼Óµµ Çâ»ó
#define rcmd(%1,%2,%3) if((strcmp(cmds[1],(%1),true,(%2))==0) && (((cmds[(%2)+1]==0) && (rcmd_%3("")))||((cmds[(%2)+1]==32) && (rcmd_%3(cmds[(%2)+2]))))) return 1
#if SAMP03a /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
	#define gcmd(%1,%2) case %1: return dialog_%2(playerid,response,listitem,inputtext)
#endif

//µð¹ö±×¿ë
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
//Á¤Àû Å¸ÀÌ¸Ó
enum Timerinfo
{
	CmdFlood,
	ChatFlood,
	ResetPing
}

#if SAMP03a /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
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

	/* ÇÎÁ¤¸® °ü·Ã º¯¼ö */
	USE_PINGCHECK=1, //ÇÎÁ¤¸® »ç¿ë
	HIGHPING_LIMIT, //Áö¿¬½Ã°£ °æ°í°ª
	HIGHPING_WARN_LIMIT, //Áö¿¬½Ã°£ °æ°íÈ½¼ö ÀÓ°è°ª
	PINGCHECK_DURATION, //ÇÎÁ¤¸® ÁÖ±â
	HIGHPING_WARNED_TIMES[MAX_PLAYERS], //³ôÀº Áö¿¬½Ã°£À¸·Î °æ°í¹ÞÀº È½¼ö
	PLAYER_JUST_CONNECTED[MAX_PLAYERS] = {5, ...}, //Á¢¼Ó ÇÚµé¸µ°ú ÇÎÁ¤¸® ÁÖ±â Á¶Àý
	RESET_HIGHPING_TICK, //°æ°íÈ½¼ö ÃÊ±âÈ­ ÁÖ±â
	/* °­Á¦Ãß¹æ °ü·Ã º¯¼ö */
	ENABLE_VOTEKICK,//ÅõÇ¥ È°¼ºÈ­
	ENABLE_VOTEBAN,
	VOTEKICK_RUN_TIME, VOTEBAN_RUN_TIME, //ÅõÇ¥ µ¹¸®´Â ½Ã°£
	VOTEKICK_NOTIFY_DURATION, VOTEBAN_NOTIFY_DURATION, // ÅõÇ¥»óÈ² °øÁö ÁÖ±â
	VOTE_CONFIDENTIALITY, // ÅõÇ¥ ½Å°íÀÎ ¸í½Ã¿©ºÎ
	REQUIRED_MAN_VOTEKICK,
	REQUIRED_MAN_VOTEBAN, // °­Á¦Ãß¹æÀ» ½ÃÀÛÇÒ ÃÖ¼ÒÀÎ¿ø
	MINIMUM_VOTEKICK_PERCENTAGE, // °­Á¦Ãß¹æ±îÁö ÇÊ¿äÇÑ µæÇ¥À²
	MINIMUM_VOTEBAN_PERCENTAGE,
	//ingame variables
	VOTEKICK_PLAYER = INVALID_PLAYER_ID,
	VOTEBAN_PLAYER = INVALID_PLAYER_ID, //´ë»ó ÇÃ·¹ÀÌ¾î ¾ÆÀÌµð
	VOTEKICK_PLAYER_GOT,
	VOTEBAN_PLAYER_GOT,	//¹ÞÀº Ç¥
	VOTEKICK_REMAINTIME,
	VOTEBAN_REMAINTIME, //³²Àº ½Ã°£
	CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS, //ÅõÇ¥¸¦ ½ÃÀÛÇÒ ´ç½ÃÀÇ ÇÊ¿ä Âù¼ºÀÎ¿ø
	CURRENT_VOTEBAN_REQUIREMENT,
	VOTEKICK_TICK, // °­Á¦Ãß¹æ °øÁö µ¹¸®´Â Å¸ÀÌ¸Ó
	VOTEBAN_TICK,
	KICKVOTED_PLAYER_IP[MAX_PLAYERS], //Áßº¹ÅõÇ¥ ¹æÁö¿ë IPÀúÀå¼Ò
	BANVOTED_PLAYER_IP[MAX_PLAYERS],
	
	POLICY_RCON_LOGINFAIL_INTERNAL, //³»ºÎ À¯Àú°¡ Rcon Login½ÇÆÐ½ÃÀÇ Àû¿ëÁ¤Ã¥
	MAX_RCONLOGIN_ATTEMPT, //ÃÖ´ë Rcon Login½ÇÆÐ ÇÑµµ
	
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
	
#if SAMP03a /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
	new DIALOG_CLICKED_PLAYER[MAX_PLAYERS];
	new WEAPON_STORAGE[][Weapon_info] =
	{
		{"ºê·¹½º ³ÊÅ¬", 1},
		{"°ñÇÁÃ¤", 2},
		{"°æÂûºÀ", 3},
		{"°úµµ", 4},
		{"¾ß±¸¹æ¸ÁÀÌ", 5},
		{"»ð", 6},
		{"´ç±¸Ã¤", 7},
		{"ÀÏº»µµ", 8},
		{"Àü±âÅé", 9},
		{"µôµµ", 10},
		{"µôµµ2", 11},
		{"¹ÙÀÌºê·¹ÀÌÅÍ", 12},
		{"¹ÙÀÌºê·¹ÀÌÅÍ2", 13},
		{"²É", 14},
		{"ÁöÆÎÀÌ", 15},
		{"½´·ùÅº", 16},
		{"ÃÖ·ç°¡½º", 17},
		{"È­¿°º´", 18},
		{"ÄÝÆ® 45", 22},
		{"ÄÝÆ® (¼ÒÀ½±â ÀåÂø)", 23},
		{"µ¥ÀúÆ® ÀÌ±Û", 24},
		{"»êÅºÃÑ (´Ü¹ß)", 25},
		{"»êÅºÃÑ (4¿¬¹ß)", 26},
		{"»êÅºÃÑ (7¿¬¹ß)", 27},
		{"UZI", 28},
		{"MP-5", 29},
		{"AK-47", 30},
		{"M4", 31},
		{"TEC-9", 32},
		{"¶óÀÌÇÃ", 33},
		{"½º³ªÀÌÆÛ ¶óÀÌÇÃ", 34},
		{"·ÎÄÏ ·±Ã³", 35},
		{"¿­ÃßÀû ·ÎÄÏ", 36},
		{"È­¿°¹æ»ç±â", 37},
		{"¹Ì´Ï°Ç", 38},
		{"ÆøÅº°¡¹æ", 39},
		{"ÆøÅº Á¡È­±â", 40},
		{"½ºÇÁ·¹ÀÌ Äµ", 41},
		{"¼ÒÈ­±â", 42},
		{"Ä«¸Þ¶ó", 43},
		{"³«ÇÏ»ê", 46}
	};
	new VEHICLE_STORAGE[][Weapon_info] =
	{
		{"ÀÎÆä¸£³ë", 411},
		{"¼úÅº", 560},
		{"ÇÇ´Ð½º", 603},
		{"ÃÑ¾Ë", 541},
		{"¿¤·¯Áö", 562},
		{"ÅÃ½Ã", 420},
		{"¹ö½º", 431},
		{"FBI Â÷¶û", 490},
		{"¸ó½ºÅÍ Æ®·°", 556},
		{"FBI Æ®·°", 528},
		{"¹°ÅÊÅ©", 601},
		{"±Ý°í Â÷·®", 609},
		{"BMX ÀÚÀü°Å", 481},
		{"ÇÇÀÚ¹è´Þ ¿ÀÅä¹ÙÀÌ", 448},
		{"ÇÁ¸®¿þÀÌ", 463},
		{"PCJ-600", 461},
		{"»êÃ¼½º", 468},
		{"NRG-500", 522},
		{"°æÂû ¿ÀÅä¹ÙÀÌ", 523},
		{"±º¿ë ÅÊÅ©", 432},
		{"Ä«Æ®", 571},
		{"Æ®·¢ÅÍ", 531},
		{"ÄÞ¹ÙÀÎ", 532},
		{"AT-400", 577},
		{"µµµµºñÇà±â", 593},
		{"Shamal", 519},
		{"È÷µå¶ó", 520},
		{"ÇåÅÍ", 425},
		{"Çï±â", 487},
		{"ÇØ¾çÇï±â", 447}
	};
	new MUSIC_STORAGE[][Weapon_info] =
	{
		{"¸Â´Â ¼Ò¸®", 1002},
		{"ºÎµúÈ÷´Â ¼Ò¸®", 1009},
		{"ÆÝÄ¡¼Ò¸®", 1130},
		{"Æø¹ßÇÏ´Â ¼Ò¸®", 1140},
		{"ºñÇàÇÐ±³ À½¾Ç", 1187},
		{"¹è°æÀ½¾Ç 1", 1097},
		{"¿îÀüÇÐ±³ À½¾Ç", 1183},
		{"¿ÀÅä¹ÙÀÌ ÇÐ±³ À½¾Ç", 1185}
	};
#endif

/***********************************************************/
/* SPECIAL DECLARATION SET ********************************/
/***********************************************************/

//==========================================================
// ºÎ¿î¿µÀÚ °ü·Ã
//==========================================================
#define IsPlayerSubAdmin(%1) PLAYER_AUTHORITY[(%1)][AUTH_SUBADMIN]
#define SetPlayerSubAdmin(%1,%2) PLAYER_AUTHORITY[%1][AUTH_SUBADMIN]=1;LoadPlayerAuthProfile(%1,%2)
#define UnSetPlayerSubAdmin(%1) for( new subvar = 1;  subvar < NUM_AUTH; subvar++ ) PLAYER_AUTHORITY[(%1)][Authinfo:subvar] = 0
#define AuthorityCheck(%1,%2) PLAYER_AUTHORITY[%1][%2]
#define SendAdminMessageAuth(%1,%2,%3) for(new sendmsg=0;sendmsg<NUM_PLAYERS;sendmsg++) if(IsPlayerAdmin(pITT[sendmsg]) || (IsPlayerSubAdmin(pITT[sendmsg]) && AuthorityCheck(pITT[sendmsg],%1))) SendClientMessage(pITT[sendmsg],%2,%3)
#define PERMANENT_ADMINSAY(%1) PERMANENT_ADMINSAY[%1]
#if SAMP03a /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
	#define Auth_Check(%1) if(IsPlayerSubAdmin(playerid) && !AuthorityCheck(playerid,(%1)) && SendClientMessage(playerid,COLOR_RED,"* ÇØ´ç ¸í·É¾î¸¦ »ç¿ëÇÒ ±ÇÇÑÀÌ ¾ø½À´Ï´Ù.")) return 1
#endif

//±âº» ºÎ¿î¿µÀÚ Á¤º¸
enum SUBINFO 
{
	Name[MAX_PLAYER_NAME],
	Password_Hash,
	IP[16],
	profile_index //Á¦°ø ÇÁ·ÎÇÊ ¹øÈ£
}

//±ÇÇÑ ¸ñ·Ï
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

//º¯¼ö ¼±¾ð 
new 
	PLAYER_AUTHORITY[MAX_PLAYERS][Authinfo],
	SubAdmin[MAX_SUBADMIN][SUBINFO],
	//ºÎ¿î¿µÀÚ ¸ñ·Ï, ·Îµå µîµî ¼³Á¤ÆÄÀÏÀÇ º¯¼ö
	Num_SubAdmin, LOAD_SUBADMIN=1,
	SUBADMIN_FAILLOGIN_TIMES[MAX_PLAYERS],
	SUBADMIN_FAILLOGIN_LIMIT=3;
	


//==========================================================
// ¸í·É¾î ÁýÁßÈ­
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

//¸í·É¾î ¼ø¼­
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

//¸í·É¾î Á¤º¸
new cmdlist[Cmdorder][Cmdinfo] = 
{
	{"¸»", "say", AUTH_CMD_SAY}, 									{"¸»¸ðµå", "psay",AUTH_CMD_SAY}, 						{"±Ó¸»", "spm",AUTH_NONE},
	{"Å±", "skick", AUTH_CMD_KICK}, 									{"¹ê", "sban", AUTH_CMD_BAN}, 								{"°­ÅðÅõÇ¥", "vkick", AUTH_NONE}, 							{"¿µ¹êÅõÇ¥", "vban", AUTH_NONE}, 
	{"½Å¿øº¸È£", "confidential", AUTH_CMD_VOTE},				{"¹êÇ®±â", "unban", AUTH_CMD_UNBAN},					{"ip¹êÇ®±â",  "unbanip", AUTH_CMD_UNBAN}, 
	{"ÃâµÎ", "with", AUTH_CMD_WITH}, 								{"¼ÒÈ¯", "call", AUTH_CMD_CALL}, 							{"°¨½Ã", "spectate", AUTH_CMD_SPECTATE},
	{"°¨½ÃÇØÁ¦", "specoff", AUTH_CMD_SPECTATE}, 			{"»ç»ì", "skill", AUTH_CMD_KILL}, 								{"Ã¼º¯°æ", "sethp", AUTH_CMD_SETHEALTH},
	{"¹«Àû", "infinite", AUTH_CMD_SETHEALTH}, 				{"¾Æ¸Ó", "armor", AUTH_CMD_SETARMOR}, 				{"¾Æ¸Ó¹«Àû", "infarmor", AUTH_CMD_SETARMOR},
	{"µ·ÁÖ±â", "mcash", AUTH_CMD_CASH},						{"µ·¹ÚÅ»", "forfeit", AUTH_CMD_FORFEIT}, 				{"µ·¼³Á¤", "setcash", AUTH_CMD_CASH},
	{"½ºÄÚ¾î", "score", AUTH_CMD_SETSCORE}, 				{"¹«±âÁÖ±â", "givewp", AUTH_CMD_GIVEWEAPON}, 	{"¹«±â¹ÚÅ»", "disarm", AUTH_CMD_DISARM}, 
	{"ÇÁ¸®Áî", "freeze", AUTH_CMD_FREEZE},					{"¾ðÇÁ¸®Áî", "unfrz", AUTH_CMD_UNFREEZE}, 			{"Â÷¼ÒÈ¯", "spcar", AUTH_CMD_SPAWNCAR},
	{"³»¸®±â", "drop",  AUTH_CMD_SPECTATE}, 				{"Â÷¿¡³ÊÁö", "carhp", AUTH_CMD_CARENERGY},		{"Â÷¼ö¸®", "fixcar", AUTH_CMD_CARENERGY},
	{"Á¦Æ®ÆÑ", "jpack",  AUTH_CMD_JETPACK},
	{"¼Ò¸®", "sound", AUTH_CMD_SOUND},						{"¼Ò¸®²ô±â", "mute", AUTH_CMD_SOUND}, 				{"ÆøÅº", "bomb", AUTH_CMD_BOMB},	
	{"´Ð¹Ù²Ù±â", "chnick", AUTH_CMD_CHANGENICK},		{"Ã¤±Ý", "shutup", AUTH_CMD_SHUTUP}, 					{"Ã¤±ÝÇØÁ¦", "unshut", AUTH_CMD_UNSHUT},
	{"¿åÇÊÅÍ", "yell", AUTH_CMD_YELLFILTER},					{"¿åÃß°¡", "addyell", AUTH_CMD_YELLFILTER}, 		{"¿åÁ¦°Å", "delyell", AUTH_CMD_YELLFILTER},
	{"µµ¹è","chatflood",AUTH_CMD_SHUTUP},					{"¸í·É¾îµµ¹è", "cmdflood", AUTH_CMD_SHUTUP}, 	{"¹«±âÇÙ", "wpcheat", AUTH_CMD_ANTICHEAT},
	{"¹«±âÃß°¡", "addwc", AUTH_CMD_ANTICHEAT}, 			{"¹«±âÁ¦°Å", "delwc", AUTH_CMD_ANTICHEAT}, 		{"Á¦Æ®ÆÑÇÙ", "jpcheat", AUTH_CMD_ANTICHEAT},
	{"Àá¼ö", "desync", AUTH_CMD_DESYNC},						{"ÇÎÁ¤¸®", "ping", AUTH_CMD_PINGCHECK}, 			{"ÇÎÁ¦ÇÑ", "plimit", AUTH_CMD_PINGCHECK},
	{"ÇÎ°æ°í", "pwarntime", AUTH_CMD_PINGCHECK}, 		{"ÇÎÃÊ±âÈ­", "preset", AUTH_CMD_PINGCHECK}, 	
	{"ºÎ¿î", "subadmin", AUTH_CMD_SETSUBADMIN}, 		{"ºÎ¿î·Î±×ÀÎ", "sublogin", AUTH_NONE}, 					{"ºÎ¿îÁ¾·á", "subout", AUTH_SUBADMIN},
	{"ºÎ¿î¹ÚÅ»", "suspend", AUTH_CMD_DELSUBADMIN}, 	{"ºÎ¿î·Îµå", "reloadsubs", AUTH_CMD_AUTH}, 
	{"±ÇÇÑº¯°æ", "chauth", AUTH_CMD_AUTH}, 					{"±ÇÇÑ¸ñ·Ï", "authlist", AUTH_CMD_AUTH}, 				{"³»±ÇÇÑ", "myauth", AUTH_SUBADMIN}, 
	{"¸í·É¾îÃßÀû", "cmdtrace", AUTH_CMDTRACE}, 			{"È£Ãâ", "mks", AUTH_CMD_MAKESOUND}, 				{"³¯¾¾", "weather", AUTH_CMD_WEATHER}, 
	{"Áß·Â", "gravity", AUTH_CMD_GRAVITY}, 						{"½Ã°¢", "wtime", AUTH_CMD_WTIME}, 						{"´©±¸", "find", AUTH_CMD_USERINFO},
	{"»óÅÂ",  "stat", AUTH_CMD_USERINFO}, 						{"°øÁö", "notice", AUTH_CMD_NOTICE},					{"°øÁö¸ñ·Ï", "nlist", AUTH_CMD_NOTICE},
	{"°øÁö·Îµå", "reloadnotice", AUTH_CMD_NOTICE},		{"¼³Á¤ÀúÀå", "saveconfig", AUTH_CMD_CONFIG}, 		{"¼³Á¤·Îµå", "loadconfig", AUTH_CMD_CONFIG},
	{"¼­¹ö¼³Á¤", "viewconfig", AUTH_NONE},						{"¼­¹öÀá±×±â", "locksvr", AUTH_CMD_LOCKSERVER},
#if SAMP03a
	{"°ü¸®Ã¢", "gui", AUTH_SUBADMIN},
#endif
	{"µµ¿ò¸»1", "rchelp", AUTH_NONE},								{"µµ¿ò¸»2", "rchelp2", AUTH_NONE}, {"¹öÀüÁ¤º¸", "rconcontroller", AUTH_NONE}
};

//¸í·É¾î¿¡ ´ëÇÑ µµ¿ò¸» (ÆÄ¶ó¸ÞÅÍ)
new Help_Params[Cmdorder][128] = {
	"[ÇÒ¸»]", 													" ", 																	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [ÇÒ¸»]", 																//¸», ¸»¸ðµå, ±Ó¸»
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [ÀÌÀ¯=¾øÀ½]", 					"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [ÀÌÀ¯=¾øÀ½]", 							"[ÀÌ¸§ÀÌ³ª ¹øÈ£]", 									"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",			//Å±, ¹ê, °­ÅðÅõÇ¥, ¿µ¹êÅõÆ÷
	" ", 															"[¾ÆÀÌµð]",														"[¾ÆÀÌÇÇ]",																					//½Å¿øº¸È£, ¹êÇ®±â, ip¹êÇ®±â
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",										"[ÀÌ¸§ÀÌ³ª ¹øÈ£, * = ¸ðµÎ]", 								"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//ÃâµÎ, ¼ÒÈ¯, °¨½Ã
	" ",															"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",												"[ÀÌ¸§ÀÌ³ª ¹øÈ£], [Ã¼·Â]",																//°¨½ÃÇØÁ¦, »ç»ì, Ã¼º¯°æ
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",										"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [¾Æ¸Ó]",									"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//¹«Àû, ¾Æ¸Ó, ¾Æ¸Ó¹«Àû
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [µ·]",								"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",												"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [µ·]",																	//µ·ÁÖ±â, µ·¹ÚÅ», µ·¼³Á¤
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [Á¡¼ö]",							"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [¹«±â¹øÈ£] [ÃÑ¾Ë=3000¹ß]",	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//½ºÄÚ¾î, ¹«±âÁÖ±â, ¹«±â¹ÚÅ»
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [½Ã°£=¹«ÇÑ]",					"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",												"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [¸ðµ¨]",																//ÇÁ¸®Áî, ¾ðÇÁ¸®Áî, Â÷¼ÒÈ¯
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",										"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [¿¡³ÊÁö]",								"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//³»¸®±â, Â÷¿¡³ÊÁö, Â÷¼ö¸®
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																																																					//Á¦Æ®ÆÑ
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£, * = ¸ðµÎ] [¼Ò¸®¹øÈ£]",		"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",												"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//¼Ò¸®, ¼Ò¸®²ô±â, ÆøÅº
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [´Ð³×ÀÓ]",						"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [ÃÊ=¹«ÇÑ]",								"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//´Ð¹Ù²Ù±â, Ã¤±Ý, Ã¤±ÝÇØÁ¦
	" ",															"[Ãß°¡ÇÒ ¿å]",													"[Á¦°ÅÇÒ ¿å]",																				//¿åÇÊÅÍ, ¿åÃß°¡, ¿åÁ¦°Å
	" ",															" ",																	" ",																								//µµ¹è, ¸í·É¾îµµ¹è, ¹«±âÇÙ
	"[±ÝÁöÇÒ ¹«±â¹øÈ£]",									"[Çã¿ëÇÒ ¹«±â¹øÈ£]",											" ",																								//¹«±âÃß°¡, ¹«±âÁ¦°Å, Á¦Æ®ÆÑÇÙ
	"[0=¹Ù·ÎÃß¹æ 1=ÀÏÁ¤½Ã°£ 2=Ãß¹æ¾ÈÇÔ]",		" ",																	"[Á¦ÇÑÇÒ Áö¿¬½Ã°£(ms)]",																//Àá¼ö, ÇÎÁ¤¸®, ÇÎÁ¦ÇÑ
	"[Ãß¹æÀü °æ°íÇÒ È½¼ö]",								"[ÇÎÁ¤¸® ÃÊ±âÈ­ ½Ã°£, 0=»ç¿ë¾ÈÇÔ]",																														//ÇÎ°æ°í, ÇÎÃÊ±âÈ­
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",										"[ºñ¹Ð¹øÈ£]",													" ",																								//ºÎ¿î, ºÎ¿î·Î±×ÀÎ, ºÎ¿îÁ¾·á
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",										" ",																																										//ºÎ¿î¹ÚÅ», ºÎ¿î·Îµå
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£] [±ÇÇÑ¹øÈ£=0]",				" ",																	" ",																								//±ÇÇÑº¯°æ, ±ÇÇÑ¸ñ·Ï, ³»±ÇÇÑ
	" ",															"[ºñÇÁÀ½ È½¼ö] [ÇÒ¸»]",										"[³¯¾¾: 0~1337]",																			//¸í·É¾îÃßÀû, È£Ãâ, ³¯¾¾
	"[Áß·Â=0.008, -50~+50]",							"[½Ã°¢: 0~23]",													"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																			//Áß·Â, ½Ã°£, ´©±¸
	" ",															"[°øÁö¸¦ ¶ç¿ï °£°Ý:ÃÊ]",									" ",																								//»óÅÂ, °øÁö, °øÁö¸ñ·Ï
	" ",															" ",																	" ",																								//°øÁö·Îµå, ¼³Á¤ÀúÀå, ¼³Á¤·Îµå
	" ",															" ",																																										//¼­¹ö¼³Á¤, ¼­¹öÀá±×±â
#if SAMP03a
	"[ÀÌ¸§ÀÌ³ª ¹øÈ£]",																																																					//°ü¸®Ã¢
#endif
	" ",															" ",																	" "																								//µµ¿ò¸»1, µµ¿ò¸»2, ¹öÀüÁ¤º¸
};

// ¹ÙÀÌ³Ê¸® Æ®¸® & ÇØ½Ì : ¸í·É¾î °Ë»ö¼Óµµ Áõ°¡
new BinaryTree:TREE_CMDLIST_HANGUL<sizeof(cmdlist)>;
new BinaryTree:TREE_CMDLIST_ENGLISH<sizeof(cmdlist)>;

//´ëÈ­Çü ¸í·ÉÃ¼°è
#define ALL_PLAYER_ID INVALID_PLAYER_ID+1
#define ABORT_PROCESS INVALID_PLAYER_ID+2
#define INTERACTIVE_MANAGEMENT INVALID_PLAYER_ID+3
#define PROCESS_COMPLETE INVALID_PLAYER_ID+4
#define HELP_PROCESS INVALID_PLAYER_ID+5
#define CMD_INVALID Cmdorder:sizeof(cmdlist)
new Cmdorder:INTERACTIVE_COMMAND[MAX_PLAYERS+1] = { CMD_INVALID, ... };
new INTERACTIVE_STATE[MAX_PLAYERS+1];

//¶óÀÎ
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
#if !SAMP02X /* SA-MP 0.2X È£È¯ ÄÄÆÄÀÏ */
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
	print("                   Copyright (C) 2008 - 2013 CoolGuy(¹ä¸Ô¾ú´Ï) \n");
#if SAMP02X
	print("[rcon] SA-MP 0.2X È£È¯ ¸ðµå·Î ÀÛµ¿ÁßÀÔ´Ï´Ù.");
#endif

	//ÃÖÃÊ»ç¿ëÀÚ È®ÀÎ
	if( fexist(FILE_FIRSTRUN) )
	{
		SetTimer("Firstrun",1000,0);
		fremove(FILE_FIRSTRUN);
	}	

	//ÃÖ´ë Á¢¼ÓÀÚ¼ö¸¦ ±¸ÇÑ´Ù.
	M_P = GetMaxPlayers();
	//¿î¿µÀÚÀÇ ÀÌ¸§ Àû±â
	PLAYER_NAME[ADMIN_ID] = "Admin";
	
	//ÇÊÅÍ½ºÅ©¸³Æ®¸¦ ±¸µ¿ÇÒ¶§ ÇÊ¿äÇÑ ÀÛ¾÷ ½ÃÀÛ
	IS_HEAR_CMDTRACE[ADMIN_ID] = 1; //¸í·É¾î ÃßÀû±â´É »ç¿ë
	LoadUserConfigs();
	if( DUMPEXIST )
	{
		print("[rcon] ´ýÇÁ ÆÄÀÏÀ» ¹ß°ßÇß½À´Ï´Ù. ÇÊÅÍ¿¡ ÀÌ½ÄÇÕ´Ï´Ù...");
		CallDump();
	}
	GatherPlayerInformations();
	
	//¹ÙÀÌ³Ê¸® Æ®¸® ±¸¼º
	new CMD_HASH_HANGUL[sizeof(cmdlist)][E_BINTREE_INPUT];
	new CMD_HASH_ENGLISH[sizeof(cmdlist)][E_BINTREE_INPUT];
	for( new i = 0 ; i < sizeof(cmdlist) ; i++ )
	{
		//ÇÑ±ÛºÎÅÍ
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Cmd] );
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_POINTER] = i;
		//¿µ¾î
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Func] );
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_POINTER] = i;
	}
	Bintree_Generate( TREE_CMDLIST_HANGUL, CMD_HASH_HANGUL, sizeof(cmdlist) );
	Bintree_Generate( TREE_CMDLIST_ENGLISH, CMD_HASH_ENGLISH, sizeof(cmdlist) );

	//Á¤Àû Å¸ÀÌ¸Ó ±¸µ¿
	if( USE_ANTI_CMDFLOOD) StaticTimer[CmdFlood] = SetTimer("ResetCmdFlood", CMDFLOOD_UNIT_TIME * 1000, 1);
	if( USE_ANTI_CHATFLOOD ) StaticTimer[ChatFlood] = SetTimer("ResetChatFlood", CHATFLOOD_UNIT_TIME * 1000, 1);
	if( USE_PINGCHECK && RESET_HIGHPING_TICK ) 
		StaticTimer[ResetPing] =  SetTimer("ResetPingCheck", RESET_HIGHPING_TICK * 1000, 1);
	SetTimer("Start_OneSecTimer_1", 480, 0);
	SetTimer("Start_OneSecTimer_2", 980, 0);
	
	//¾÷µ¥ÀÌÆ® È®ÀÎ
#if SAMP03b
	rcmd_checkupdate(NULL);
#endif
	return 1; /* Loading Complete! */
}
//==========================================================
public OnFilterScriptExit()
{
	//ÇÊÅÍ½ºÅ©¸³Æ®¸¦ Á¾·áÇÏ±â Àü¿¡ ÇÊ¿äÇÑ ÀÛ¾÷ ¼öÇà
	if( SAVE_CURRRENT_CONFIG ) SaveUserConfigs();
	if( DUMPEXIT )
	{
		print("[rcon] ´ýÇÁ ÆÄÀÏÀ» »ý¼ºÇÏ°í ÀÖ½À´Ï´Ù...");
		CreateDump();
	}
	return 1;
}
//==========================================================
public OnGameModeExit()
{
	//¸ðµå°¡ Á¾·áµÉ ¶§ ÇÊ¿äÇÑ ÀÛ¾÷ ¼öÇà
	for( new i = 0 ; i < NUM_PLAYERS ; i++ ) PLAYER_SPAWNED[pITT[i]] = 0; //ÇÃ·¹ÀÌ¾î ½ºÆùÁ¤º¸ ÃÊ±âÈ­
	if(SERVER_LOCKED) //¼­¹ö°¡ Àá°ÜÀÖ´Â °æ¿ì
	{
		//FIXME : 15ÃÊ°¡ Àû´çÇÕ´Ï±î?
		print("[rcon] ¸ðµå°¡ º¯°æµÇ¾ú½À´Ï´Ù. 15ÃÊ ÈÄ¿¡ ´Ù½Ã ¼­¹ö°¡ Àá±é´Ï´Ù.");
		SendAdminMessageAuth(AUTH_NOTICES, COLOR_IVORY, "* ¸ðµå°¡ º¯°æµÇ¾ú½À´Ï´Ù. 15ÃÊ ÈÄ¿¡ ´Ù½Ã ¼­¹ö°¡ Àá±é´Ï´Ù.");
		SERVER_LOCKED = 0;
		SetTimer("ReLockServer", 15000, 0);
	}
	return 1;
}
//==========================================================
public OnPlayerPrivmsg(playerid, recieverid, text[])
{
	new str[193];

	//¿åÇÊÅÍ °¨Áö
	if(USE_YELLFILTER && !CONSOLE)
	{
		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] ±ÝÁö¾î°¡ °¨ÁöµÇ¾ú½À´Ï´Ù - %s", YELLS[s]);
				for(new i = pos, j = pos + strlen(YELLS[s]); i < j; i++) text[i] = '+';
			}
		}
	}

	//±Ó¼Ó¸» µµ¹è¹æÁö ±â´É
	if( !CONSOLE )
	{
		if( IS_CHAT_FORBIDDEN[playerid] )
		{
			PLAYER_PMABUSE_TIMES[playerid]++;
			if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î¸¦ ±Ó¸»·Î ±«·ÓÇô¼­ °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î¸¦ ±Ó¸»·Î ±«·ÓÇô¼­ °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			SendClientMessage(playerid, COLOR_RED, "* Ã¤ÆÃ±ÝÁö ÁßÀÔ´Ï´Ù. °è¼ÓÇØ¼­ ¸Þ¼¼Áö Àü¼ÛÀ» ÇÒ °æ¿ì °­Á¦ ÅðÀåµË´Ï´Ù.");
			printf("[rcon] %s(%d)´ÔÀº º¡¾î¸® »óÅÂÀÔ´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
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
					format( str, sizeof(str), "* %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î¸¦ ±Ó¸»·Î ±«·ÓÇô¼­ °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î¸¦ ±Ó¸»·Î ±«·ÓÇô¼­ °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
					return 0;
				}
				format( str, sizeof(str), "PM from %s(%d): ´õÀÌ»ó ±Ó¸»·Î µµ¹èÇÏÁö ¾ÊÀ»°Ô¿ä. ÁË¼ÛÇØ¿ä ¤Ð_ ¤Ð", GetPlayerNameEx(playerid), playerid);
				SendClientMessage( playerid, COLOR_YELLOW, str );
				format( str, sizeof(str), "PM sent to %s: ´õÀÌ»ó ±Ó¸»·Î µµ¹èÇÏÁö ¾ÊÀ»°Ô¿ä. ÁË¼ÛÇØ¿ä ¤Ð_ ¤Ð", GetPlayerNameEx(recieverid));
				SendClientMessage( recieverid, COLOR_YELLOW, str );
				printf("[rcon] %s(%d)´ÔÀÌ ±Ó¼Ó¸» µµ¹è¸¦ ÇÏ¿© µµ¹è¹æÁö°¡ ÀÛµ¿Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = CHATFLOOD_SHUTUP_TIME;
				return 0;
			}
		}
	}
	
	//¸Þ¼¼Áö º¸³»±â
	format(str,sizeof(str),"%s(%d) -> %s(%d): %s",CONSOLE? ("Admin"):(GetPlayerNameEx(playerid)),playerid,(recieverid==ADMIN_ID)? ("Admin"):(GetPlayerNameEx(recieverid)),recieverid,text);
	FixChars(str);
	SendAdminMessageAuth(AUTH_PMTRACE,COLOR_GREY,str);
	return 1;
}
//==========================================================
public OnPlayerText(playerid, text[])
{
	//´ëÈ­Çü ¸í·ÉÃ¼°è
	if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID ) 
	{
		if( text[0] == '?' && !text[1] ) 
		{
			SendClientMessage( playerid, COLOR_RED, "* Ãë¼ÒµÇ¾ú½À´Ï´Ù." );
			INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
			return 0;
		}
		new str[128];		
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
		CallLocalFunction( str, "isib", playerid, text, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
		return 0;
	}

	if( PERMANENT_ADMINSAY(	playerid) ) return !dcmd_say( playerid, text, CMD_SAY, NO_HELP ); //¸»¸ðµå ÇÚµé¸µ
	LAST_PLAYER_ID=playerid; // ¸¶Áö¸·À¸·Î Ã¤ÆÃÇÑ À¯Àú
	new str[128];
	
	if( IS_CHAT_FORBIDDEN[playerid] )
	{
		PLAYER_PMABUSE_TIMES[playerid]++;
		if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
		{
			format( str, sizeof(str), "* %s(%d)´ÔÀÌ Ã¤ÆÃ±ÝÁö »óÅÂ¿¡¼­ °è¼Ó µµ¹è¸¦ ÇÏ¿© °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
			SendClientMessageToAll( COLOR_RED, str );
			printf("[rcon] %s(%d)´ÔÀÌ Ã¤ÆÃ±ÝÁö »óÅÂ¿¡¼­ °è¼Ó µµ¹è¸¦ ÇÏ¿© °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
			if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
			return 0;
		}
		SendClientMessage(playerid, COLOR_RED, "* Ã¤ÆÃ±ÝÁö ÁßÀÔ´Ï´Ù. °è¼ÓÇØ¼­ ¸Þ¼¼Áö Àü¼ÛÀ» ÇÒ °æ¿ì °­Á¦ ÅðÀåµË´Ï´Ù.");
		printf("[rcon] %s(%d)´ÔÀº º¡¾î¸® »óÅÂÀÔ´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
		return 0;
	}

	if(USE_YELLFILTER)
	{

		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] ±ÝÁö¾î°¡ °¨ÁöµÇ¾ú½À´Ï´Ù - %s", YELLS[s]);
				format( str, sizeof(str), "* ±ÝÁö¾î°¡ °¨ÁöµÇ¾ú½À´Ï´Ù. - %s", YELLS[s]);
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
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ °è¼Ó µµ¹è¸¦ ÇÏ¿© °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)´ÔÀÌ °è¼Ó µµ¹è¸¦ ÇÏ¿© °­Á¦Ãß¹æ µÇ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			format( str, sizeof(str), "%s(%d): ´õÀÌ»ó µµ¹èÇÏÁö ¾ÊÀ»°Ô¿ä. ÁË¼ÛÇØ¿ä ¤Ð_ ¤Ð", GetPlayerNameEx(playerid), playerid);
			FixChars(str);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			printf("[rcon] %s(%d)´ÔÀÌ µµ¹è¸¦ ÇÏ¿© µµ¹è¹æÁö°¡ ÀÛµ¿Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
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
	//½Ã°£ ¾Ë·ÁÁÖ±â
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "¿ÀÈÄ";
	}
	else tmp = "¿ÀÀü";
	printf("[rcon] ÇöÀç ½Ã°¢Àº %s %2d½Ã %2dºÐ ÀÔ´Ï´Ù.", tmp, h, m);
	//±âº»ÀûÀÎ Á¤º¸ ¼öÁý
	GetPlayerName( playerid, PLAYER_NAME[playerid], MAX_PLAYER_NAME );
	FixChars( PLAYER_NAME[playerid] );
	GetPlayerIp( playerid, PLAYER_IP[playerid], sizeof(PLAYER_IP[]) );

	//¼­¹öÀá±ÝÀÇ °æ¿ì
	if(SERVER_LOCKED)
	{
		new str[77];
		SendClientMessage(playerid, COLOR_RED, " Server is currently LOCKED. You can't join.");
		SendClientMessage(playerid, COLOR_RED, " ¼­¹ö°¡ Àá°ÜÀÖ¾î Á¢¼ÓÀÌ ºÒ°¡´ÉÇÕ´Ï´Ù.");
		format(str, sizeof(str), "* ¼­¹ö°¡ Àá°ÜÀÖ¾î %s(%d)´ÔÀÇ Á¢¼Ó¿äÃ»À» °ÅºÎÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] ¼­¹ö°¡ Àá°ÜÀÖ¾î %s(%d)´ÔÀÇ Á¢¼Ó¿äÃ»À» °ÅºÎÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
		c_Kick(playerid);
		return 1;
	}

	//ºÒ·®À¯Àú Á¡°Ë
	if( USE_BADWARN )
	{
		h = GetTickCount( );
		
		if( CUR_BADP_POINT == 0 ) Bintree_Reset( TREE_BADPLAYER );
		new current_ip = fnv_hash( GetPlayerIpEx(playerid) );		
		new i = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		
		if ( i != BINTREE_NOT_FOUND && BAD_PLAYER_IP[i] != 0 )
		{
			//ºÒ·® À¯ÀúÀÌ¸ç, °­Åð´çÇÑ ÈÄ Ã¹ Á¢¼ÓÀÎ °æ¿ì
			if( h - BADKICKED_TIMESTAMP[i] < 5000 ) //Á¸³ªºü¸¥ ÀçÁ¢¼ÓÀ¸·Î ÀÎÇØ ¼Òºñ¿¡Æ®°¡  ÀÇ½ÉµÈ´Ù¸é
			{
				//¾¾¹ãÄç Á¿±î
				GameTextForPlayer( playerid, "~r~NO ~w~s~y~0~w~beit~n~~p~fuck", 60000, 3 );
				c_Kick( playerid );
				return 1;
			}
			BAD_PLAYER_IP[i] = 0;
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			new str[77];
			format( str, sizeof(str), "* ¿äÁÖÀÇ ÀÎ¹° %s(%d)´ÔÀÌ Á¢¼ÓÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, str ); 
			print("[rcon] ¿äÁÖÀÇ ÀÎ¹°ÀÌ Á¢¼ÓÇß½À´Ï´Ù.");
		}
	}

	PLAYER_CASH[playerid] = 0;
	ResetPlayerStatus(playerid);
	return 1;
}
//==========================================================
public OnPlayerRequestSpawn(playerid)
{
	//FIXME: ¿Ö ÀÌ ÀÛ¾÷À» ÇÏ´ÂÁö ¸ð¸£°Ú½À´Ï´Ù. ÇÊÅÍ½ºÅ©¸³Æ®°£ Ãæµ¹ÀÌ ³¯Áöµµ?
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
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* ÇÃ·¹ÀÌ¾î°¡ »ì¾Æ³µ½À´Ï´Ù. °¨½Ã°¡ ½ÃÀÛµÉ ¶§±îÁö ±â´Ù·Á ÁÖ¼¼¿ä...." );
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
		SendClientMessage( playerid, COLOR_ORANGE, "* °¨½Ã ¸ðµå°¡ Á¾·áµÇ¾ú½À´Ï´Ù." );
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 0 );
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* °¨½Ã¸¦ °è¼ÓÇÕ´Ï´Ù. ÇÃ·¹ÀÌ¾î°¡ ´Ù½Ã »ì¾Æ³¯¶§±îÁö ±â´Ù·Á ÁÖ¼¼¿ä..." );
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
		
		//´ëÈ­Çü ¸í·ÉÃ¼°è
		if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID )
		{
			SendClientMessage( playerid, COLOR_RED, "* ´ëÈ­Çü ¸í·ÉÃ¼°è°¡ ÀÛµ¿ÁßÀÔ´Ï´Ù. »ç¿ëÁßÀÎ µ¿ÀÛÀ» ¸¶Ä£ ÈÄ »ç¿ëÇÏ½Ê½Ã¿À.");
			SendClientMessage( playerid, COLOR_ORANGE, "* µ¿ÀÛÀ» Ãë¼ÒÇÏ·Á¸é ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
			return 1;
			/*
			if( cmdtext[1] == '?' && !cmdtext[2] ) 
			{
				SendClientMessage( playerid, COLOR_RED, "* Ãë¼ÒµÇ¾ú½À´Ï´Ù." );
				INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
				return 1;
			}
			format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
			if ( !cmdtext[1] ) CallLocalFunction( str, "isib", playerid, NULL, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			else CallLocalFunction( str, "isib", playerid, cmdtext[1], _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			return 1; */
		}
			
		//¸í·É¾î µµ¹è ÇÚµé¸µ
		if( IS_CMD_FORBIDDEN[playerid] )
		{
			CMDFLOOD_STILL_TIMES[playerid]++;
			if( CMDFLOOD_STILL_TIMES[playerid] >= CMDFLOOD_STILL_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ ¸í·É¾î µµ¹è¸¦ ÇÏ¿© °­Á¦ Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)´ÔÀÌ °è¼ÓÇØ¼­ ¸í·É¾î¸¦ µµ¹èÇÏ¿© °­Á¦Ãß¹æ ÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
				return 1;
			}
			SendClientMessage( playerid, COLOR_RED, "* ¸í·É¾î »ç¿ëÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. °è¼ÓÇÏ¿© ¸í·É¾î¸¦ ÀÔ·ÂÇÒ °æ¿ì Ãß¹æµË´Ï´Ù." );
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
					format( str, sizeof(str), "* %s(%d)´ÔÀÌ ¸í·É¾î µµ¹è¸¦ ÇÏ¿© °­Á¦ Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)´ÔÀÌ °è¼ÓÇØ¼­ ¸í·É¾î¸¦ µµ¹èÇÏ¿© °­Á¦Ãß¹æ ÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
					return 1;
				}
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_CMDRESTRICT] = CMDFLOOD_FORBIDDEN_TIME;
				SendClientMessage( playerid, COLOR_RED, "* ¸í·É¾î·Î µµ¹è¸¦ ÇÏ¿© ¸í·É¾î »ç¿ëÀÌ Á¦ÇÑµË´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸í·É¾î µµ¹è¸¦ ÇÏ¿© ¸í·É¾î »ç¿ëÀ» Á¦ÇÑÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
				return 1;
			}
		}
	}
	
	if( !cmdtext[1] ) return 0;
	
	//centralized command handling
	new length, hash, i, str[128];
	set( str, strtok( cmdtext[1], length ));
	hash = fnv_hash( str );
	
	//ÇÑ±Û¿¡¼­ ¸ÕÀú °Ë»ç
	i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
	if( i == BINTREE_NOT_FOUND ) //ÇÑ±Û¿¡ ¾øÀ½ ¿µ¾î¿¡¼­ °Ë»ç
	{
		i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
		if ( i == BINTREE_NOT_FOUND ) return 0; //¸í·É¾î°¡ ¾øÀ½
	}
	//strtok º¸Á¤
	if( cmdtext[length] == ' ' ) length --;
	length++;
	
	//±ÇÇÑÀÌ ÇÊ¿ä¾ø°Å³ª, ÄÜ¼ÖÀÌ°Å³ª, ¿î¿µÀÚÀÌ°Å³ª, ±ÇÇÑÀ» °®Ãá ºÎ¿î¿µÀÚÀÇ °æ¿ì ½ºÅµ
	if( cmdlist[Cmdorder:i][Required_Auth] != AUTH_NONE && !CONSOLE && !IsPlayerAdmin( playerid )
		&& !AuthorityCheck(playerid,cmdlist[Cmdorder:i][Required_Auth]) )
	{
		//¾î¶² °Í¿¡µµ ÇØ´çÇÏÁö ¾ÊÀ½. ±ÇÇÑ ¾øÀ½ ¿À·ù ¸Þ¼¼Áö¸¦ Ãâ·Â
		cmdtext[length] = EOS;
		format( str, sizeof(str), "* ¸í·É¾î '%s'À»(¸¦) »ç¿ëÇÒ ±ÇÇÑÀÌ ¾ø½À´Ï´Ù. ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä.", cmdtext );
		SendClientMessage( playerid, COLOR_RED, str );
		return 1;
	}
	
	//ÇÔ¼ö È£Ãâ
	format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
	if( cmdtext[length] == 32 && cmdtext[length+1] != EOS )	CallLocalFunction( str, "isib", playerid, cmdtext[length+1], i, NO_HELP );
	else CallLocalFunction( str, "isib", playerid, NULL, i, NO_HELP );
	return 1;
}
//==========================================================
public OnPlayerDisconnect(playerid, reason)
{
	//iteration optimization
	NUM_PLAYERS--; //Á¢¼ÓÁßÀÎ ÇÃ·¹ÀÌ¾î ¼ö Á¤Á¤
	if( NUM_PLAYERS )
	{
	    //³ª°£ ÇÃ·¹ÀÌ¾îÀÇ ¹Ýº¹¹®À» ¸Ç µÚÀÇ ÇÃ·¹ÀÌ¾î ¹øÈ£·Î Ã¤¿ò ( TRIM )
		pITT[ pITT_INDEX[playerid] ] = pITT[ NUM_PLAYERS ];
		//¸Ç µÚÀÇ ÇÃ·¹ÀÌ¾î°¡ ¼ÓÇÑ ½½·ÔÀ» ³ª°£ ÇÃ·¹ÀÌ¾îÀÇ ½½·ÔÀ¸·Î ÁöÁ¤
		pITT_INDEX[ pITT[ NUM_PLAYERS ] ] = pITT_INDEX[playerid];
	}
	//ÇÃ·¹ÀÌ¾î º¯¼ö ÃÊ±âÈ­
	pITT_INDEX[ playerid ] = -1;
	//votekick check
	new str[128];
	if( VOTEKICK_REMAINTIME > 0 && VOTEKICK_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)´ÔÀÌ °ÔÀÓÀ» ³ª°¡ ÅõÇ¥°¡ Áß´ÜµË´Ï´Ù.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)´ÔÀÌ °ÔÀÓÀ» ³ª°¡ ÅõÇ¥°¡ Áß´ÜµË´Ï´Ù.", GetPlayerNameEx( playerid ), playerid );
		VOTEKICK_REMAINTIME = 0;
		VOTEKICK_TICK = 0;
	}
	if( VOTEKICK_REMAINTIME > 0 && VOTEBAN_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)´ÔÀÌ °ÔÀÓÀ» ³ª°¡ ÅõÇ¥°¡ Áß´ÜµË´Ï´Ù.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)´ÔÀÌ °ÔÀÓÀ» ³ª°¡ ÅõÇ¥°¡ Áß´ÜµË´Ï´Ù.", GetPlayerNameEx( playerid ), playerid );
		VOTEBAN_REMAINTIME = 0;
		VOTEBAN_TICK = 0;
	}

    //ºÒ·® À¯ÀúÀÇ IP ±â·Ï
	if( reason == 2 )
	{
		static full;
		
		if( CUR_BADP_POINT == MAX_BAD_PLAYERS )
		{
			//°¡µæ Â÷¸é ¸Å¹ø ¸®¼ÒÆ®¸¦ ÇØÁÖ¾î¾ß ÇÏ³ª?
			//¾Æ´Ï´Ù. ±×³É »èÁ¦ÇÏ°í ´Ù½Ã ¹Ù²Ù¸é µÈ´Ù. ±×¶§ºÎÅÍ´Â À¯Áö °ü¸®¸¸ ÇÑ´Ù. ¸Å¹ø ¸¸µéÁö ¾Ê°í..
			full = 1;
			CUR_BADP_POINT = 0;
		}		
		
		new current_ip = fnv_hash( GetPlayerIpEx( playerid ) );
		new ptr = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		if( ptr != BINTREE_NOT_FOUND )
		{
			//°°Àº ÇÃ·¹ÀÌ¾î°¡ ¶Ç °­Åð´çÇÏ´Â °æ¿ì ..
			//ÇÃ·¡±×¸¦ ¼¼¿ì°í, °­Åð´çÇÑ ½Ã°¢À» ±â·ÏÇÑ´Ù.
			BAD_PLAYER_IP[ptr] = current_ip;
			BADKICKED_TIMESTAMP[ptr] = GetTickCount( );
		}
		else if( full )
		{
			// ÀÌÁ¦ ±ÕÇüµûÀ© ¾ø´Ù. À¯Áö°ü¸® ¸ðµå·Î ÀüÈ¯
			ptr = 0;
			Bintree_FindValue( TREE_BADPLAYER, BAD_PLAYER_IP[CUR_BADP_POINT], _, ptr );
			Bintree_Delete ( TREE_BADPLAYER, ptr, 1 );
			
			BAD_PLAYER_IP[CUR_BADP_POINT] = current_ip;
			BADKICKED_TIMESTAMP[CUR_BADP_POINT] = GetTickCount( );
			
			Bintree_Add( TREE_BADPLAYER, CUR_BADP_POINT, BAD_PLAYER_IP[CUR_BADP_POINT], sizeof(TREE_BADPLAYER) - 1 );
			format( str, sizeof(str), "* ºÒ·®À¯Àú È®ÀÎ¿ë IPÅ×ÀÌºíÀÌ °¡µæ Ã¡½À´Ï´Ù. °ü¸®ÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä" );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
			print("[rcon] ºÒ·®À¯Àú È®ÀÎ¿ë IPÅ×ÀÌºíÀÌ °¡µæ Ã¡½À´Ï´Ù. ¿À·¡µÈ ºÒ·® À¯ÀúºÎÅÍ Â÷·Ê´ë·Î »èÁ¦ÇÕ´Ï´Ù." );			
		}
		else //°¡µæ Â÷Áö ¾ÊÀ½. ¸Å¹ø ±ÕÇüÀâÈù Æ®¸®¸¦ ¸¸µé¾îÁØ´Ù.
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
	//ÇöÀç½Ã°£ ¾Ë¸²
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "¿ÀÈÄ";
	}
	else tmp = "¿ÀÀü";
	printf("[rcon] ÇöÀç ½Ã°¢Àº %s %2d½Ã %2dºÐ ÀÔ´Ï´Ù.", tmp, h, m);
	//º¯¼ö ¼öÁ¤
	PLAYER_SPAWNED[playerid] = 0;
	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_ORANGE, "* ÇØ´ç ÇÃ·¹ÀÌ¾î°¡ °ÔÀÓ¿¡¼­ ³ª°¡ °¨½Ã¸ðµå¸¦ Á¾·áÇÕ´Ï´Ù.");
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
	//ÁöÁ¤ÀÚ·Î ÀÎÇÑ ¼­¹ö Å©·¡½Ã ¹æÁö
	for( new i = 0, len = strlen( cmd ) ; i < len ; i++ ) if( cmd[i] == '%' ) cmd[i] = '#';
	
	//´ëÈ­Çü ¸í·ÉÃ¼°è
	if( INTERACTIVE_COMMAND[ADMIN_ID] != CMD_INVALID )
	{
		if( cmd[0] == '?' && !cmd[1] ) 
		{
			print( "[rcon] Ãë¼ÒµÇ¾ú½À´Ï´Ù." );
			INTERACTIVE_COMMAND[ADMIN_ID] = CMD_INVALID;
			return 1;
		}
		new str[128];
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[ADMIN_ID]][Func] );
		CallLocalFunction( str, "isib", ADMIN_ID, cmd, _:INTERACTIVE_COMMAND[ADMIN_ID], NO_HELP );
		return 1;
	}
	
	//¸»¸ðµå¿¡ ´ëÇÑ ÇÚµé¸µ
	if( PERMANENT_ADMINSAY(ADMIN_ID) && cmd[0] != '!') return dcmd_say( ADMIN_ID, cmd, CMD_SAY, NO_HELP );
	else
	{
		if ( cmd[0] == '!' ) for( new i = 0, j = strlen( cmd ) ; i < j ; i++ ) cmds[i] = cmd[i];
		else for( new i = strlen( cmd ) ; i > 0 ; i-- ) cmds[i] = cmd[i -1];
	}
	cmds[0] = '/';

	//invoke command
	rcmd("µµ¿ò¸»",6,help);
	rcmd("help",4,help);
	rcmd("help2",5,help2);
	
	//rcon-unique command
	rcmd("rcon",4,rcon);
	rcmd("update",6,checkupdate);
	rcmd("¾÷µ¥ÀÌÆ®",8,checkupdate);
	
	/* deprecated */
	//rcmd("shelp",5,shelp);
	//rcmd("readcmd",7,readcmd);
	//rcmd("¸í·É¾îÀÐ±â",10,readcmd);	
	

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
	
	//IP¸¦ Ã£À» ÁØºñ¸¦ ÇÏÀÚ ¤»¤»
	new current_ip, playerid = INVALID_PLAYER_ID, str[128], i;
	current_ip = fnv_hash (ip);
	if( ip_index == 0 ) Bintree_Reset( TREE_IPTABLES );

	i = Bintree_FindValue( TREE_IPTABLES, current_ip ); //IP Å×ÀÌºí ¸ñ·ÏÀ» °Ë»ö
	if( i != BINTREE_NOT_FOUND )
	{
		//±âÁ¸ ¸ñ·Ï¿¡ Á¸ÀçÇÏ´Â °æ¿ì
		if( iptables[i][R_IP_HASH] == current_ip )
		{
			//¼º°øÇßÀ½. ½ÇÆÐ°ª ÃÊ±âÈ­ÇÏ°í °ªÀ» ³Ñ°ÜÁØ´Ù.
			if( success )
			{
				iptables[i][R_FAILED_ATTEMPT] = 0;
				return 1;
			}
			//½ÇÆÐ¸®½ºÆ® Ãß°¡. ¾ÆÀÌµð ±â·Ï
			iptables[i][R_FAILED_ATTEMPT]++;
			playerid = iptables[i][R_PLAYER_ID];
			//¼³Á¤ÆÄÀÏ¿¡¼­ Á¤ÇÑ ÇÑµµ¸¦ ³Ñ¾î°¡¸é
			if( iptables[i][R_FAILED_ATTEMPT] >= MAX_RCONLOGIN_ATTEMPT )
			{
				if( playerid == INVALID_PLAYER_ID)
				{
					format( str, sizeof(str), "* ip %s¿¡¼­ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© ip¹êÀ» ¼öÇàÇÕ´Ï´Ù.", ip );
					SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
					printf("[rcon] ip %s¿¡¼­ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© ip¹êÀ» ¼öÇàÇÕ´Ï´Ù.", ip );
					format( str, sizeof(str),"banip %s", ip );
					SendRconCommand( str );
					return 1;
				}
				//¼³Á¤ÆÄÀÏ¿¡¼­ Á¤ÇÑ Á¶Ä¡¿¡ µû¶ó Ã³¸®
				switch( POLICY_RCON_LOGINFAIL_INTERNAL )
				{
					case 1:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE KICKED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* °è¼ÓÇØ¼­ Àß¸øµÈ ·Î±×ÀÎ ½Ãµµ¸¦ ÇÏ¿© Ãß¹æµÇ¾ú½À´Ï´Ù." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~y~kicked", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)´ÔÀÌ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)´ÔÀÌ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
						c_Kick(playerid);
					}
					case 2:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE BANNED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* °è¼ÓÇØ¼­ Àß¸øµÈ ·Î±×ÀÎ ½Ãµµ¸¦ ÇÏ¿© ¿µ±¸Ãß¹æµÇ¾ú½À´Ï´Ù." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~r~BANNED", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)´ÔÀÌ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© ¿µ±¸Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)´ÔÀÌ Àß¸øµÈ rcon ·Î±×ÀÎ ÇÑµµ¸¦ ÃÊ°úÇÏ¿© ¿µ±¸Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
						c_Ban(playerid);						
					}
				}
				return 1;
			}
			//ÇÑµµ´Â ³Ñ¾î°¡Áö ¾ÊÀ½. ¿î¿µÀÚ¿¡°Ô Àß¸øµÈ ½Ãµµ¿¡ ´ëÇØ ¾Ë¸²
			if( playerid == INVALID_PLAYER_ID )
			{
				format( str, sizeof(str), "* ip %s¿¡¼­ %d¹øÂ°·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", ip, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] ip %s¿¡¼­ %d¹øÂ°·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", ip, iptables[i][R_FAILED_ATTEMPT] );
			}
			else
			{
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ %d¹øÂ°·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.",  GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] %s(%d)´ÔÀÌ %d¹øÂ°·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
			}
			return 1;
		}
	}
	
	//¸®½ºÆ®¿¡ ¾øÀ½. ·Î±×ÀÎ ½Ãµµ ¼º°ø. ±×³É µ¹·ÁÁØ´Ù.
	if( success ) return 1;
	//¸®½ºÆ®¿¡ ¾øÀ½. Ã¹ ·Î±×ÀÎ ½Ãµµ ½ÇÆÐ. ¸ñ·Ï¿¡ µîÀç.
	//±×Àü¿¡, Å×ÀÌºíÀÌ °¡µæ Ã¡´ÂÁö È®ÀÎÇÑ´Ù.
	static full;
	
	if( ip_index == sizeof(iptables) ) 
	{
		full = 1;
		ip_index = 0;
	}
	
	for( i = 0; i < NUM_PLAYERS ; i++ )//¿ì¼± ÇÃ·¹ÀÌ¾î°¡ Á¢¼ÓÁßÀÎÁö Ã£´Â´Ù.
	{
		if( !strcmp(GetPlayerIpEx(pITT[i]), ip, false) )
		{
			playerid = pITT[i]; //Á¢¼ÓÇÑ ÇÃ·¹ÀÌ¾î°¡ ·Î±×ÀÎ ½ÃµµÇÔ.
			break;
		}
	}
	//Bintree_Add( TREE_IPTABLES, ip_index, current_ip, ip_index ); //just add;
	if( full )
	{
		//°¡µæ Ã¡À¸¸é À¯Áö°ü¸® ½ÇÇà
		new ptr;
		Bintree_FindValue( TREE_IPTABLES, iptables[ip_index][R_IP_HASH], _, ptr );
		Bintree_Delete( TREE_IPTABLES, ptr, 1 );
		
		iptables[ip_index][R_IP_HASH] = current_ip;
		iptables[ip_index][R_PLAYER_ID] = playerid; 
		iptables[ip_index][R_FAILED_ATTEMPT] = 1;
		
		Bintree_Add( TREE_IPTABLES, ip_index, current_ip, sizeof(TREE_IPTABLES) -1 );
		ip_index++;
		
		format( str, sizeof(str), "* RCON ·Î±×ÀÎ ¹æ¾î¿ë IPÅ×ÀÌºíÀÌ °¡µæ Ã¡½À´Ï´Ù. °ü¸®ÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		print("[rcon] RCON ·Î±×ÀÎ ¹æ¾î¿ë IPÅ×ÀÌºíÀÌ °¡µæ Ã¡½À´Ï´Ù. ¿À·¡µÈ ·Î±×ÀÎ ½ÃµµºÎÅÍ Â÷·Ê´ë·Î »èÁ¦ÇÕ´Ï´Ù." );
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
		//ÇÃ·¹ÀÌ¾î°¡ ¾øÀ½. ip¹êÀ» ÁØºñÇÑ´Ù.
		format( str, sizeof(str), "* ip %s¿¡¼­ Ã³À½À¸·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, "* ¿äÃ»ÀÌ ¹Ýº¹µÇ¸é ip¹êÀ» ¼öÇàÇÕ´Ï´Ù." );
		printf("[rcon] ip %s¿¡¼­ Ã³À½À¸·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", ip );
		print("[rcon] ¿äÃ»ÀÌ ¹Ýº¹µÇ¸é ip¹êÀ» ¼öÇàÇÕ´Ï´Ù.");
		return 1;
	}
	else 
	{
		//¸Þ¼¼Áö º¸³»±â
		format( str, sizeof(str), "* %s(%d)´ÔÀÌ Ã³À½À¸·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
		printf("[rcon] %s(%d)´ÔÀÌ Ã³À½À¸·Î rcon ·Î±×ÀÎ ½Ãµµ¿¡ ½ÇÆÐÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
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
			gcmd(DIALOG_ADMIN_MAIN,adminmain); //±âº» ¸í·É¾î ¼ÂÆ®
			gcmd(DIALOG_ADMIN_KICK,kick); //°­Á¦Ãß¹æ
			gcmd(DIALOG_ADMIN_BAN,ban); //¿µ±¸Ãß¹æ
			gcmd(DIALOG_PM,superpm); //±Ó¼Ó¸»º¸³»±â
			gcmd(DIALOG_ADMIN_WITH,with); //ÀÌµ¿ÇÏ±â
			gcmd(DIALOG_ADMIN_CALL,call); //¼ÒÈ¯ÇÏ±â
			gcmd(DIALOG_ADMIN_KILL,kill); //»ç»ì
			gcmd(DIALOG_ADMIN_SETHP,sethp); //Ã¼·Â¼³Á¤
			gcmd(DIALOG_ADMIN_INFINITE,infinite); //Ã¼¹«ÇÑ
			gcmd(DIALOG_ADMIN_MAKECASH,makecash); //µ·ÁÖ±â
			gcmd(DIALOG_ADMIN_FORFEIT,forfeit); //µ·»¯±â
			gcmd(DIALOG_ADMIN_SETCASH,setcash); //µ·¼³Á¤
			gcmd(DIALOG_ADMIN_SETSCORE,setscore); //½ºÄÚ¾î¼³Á¤
			gcmd(DIALOG_ADMIN_GIVEWP,givewp); //¹«±âÁÖ±â
			gcmd(DIALOG_ADMIN_DISARM,disarm); //¹«±â¹ÚÅ»
			gcmd(DIALOG_ADMIN_FREEZE,freeze); //ÇÁ¸®Áî
			gcmd(DIALOG_ADMIN_UNFREEZE,unfreeze); //ÇÁ¸®Áî ÇØÁ¦
			gcmd(DIALOG_ADMIN_ARMOR,armor); //¾Æ¸Ó
			gcmd(DIALOG_ADMIN_INFARMOR,infarmor); //¾Æ¸Ó¹«Àû
			gcmd(DIALOG_ADMIN_SPAWNCAR,spawncar); //Â÷¼ÒÈ¯
			gcmd(DIALOG_ADMIN_SDROP,sdrop); //Â÷¿¡¼­ ³»¸®±â
			gcmd(DIALOG_ADMIN_CARENERGY,carenergy); //Â÷¿¡³ÊÁö º¯°æ
			gcmd(DIALOG_ADMIN_JETPACK,jetpack); //Á¦Æ®ÆÑ
			gcmd(DIALOG_ADMIN_MUSIC,music); //À½¾Çµè±â
			gcmd(DIALOG_ADMIN_MUSICOFF,musicoff); //À½¾Ç²ô±â
			gcmd(DIALOG_ADMIN_BOMB,bomb); //³ú ÅÍÆ®¸®±â
			gcmd(DIALOG_ADMIN_SHUTUP,shutup); //Ã¤ÆÃ ±ÝÁö
			gcmd(DIALOG_ADMIN_UNSHUT,unshut); //Ã¤±Ý ÇØÁ¦
			gcmd(DIALOG_ADMIN_CHANGENICK,changenick); //´Ð¹Ù²Ù±â
			gcmd(DIALOG_ADMIN_SPECTATE,spectate); //°¨½ÃÇÏ±â
			gcmd(DIALOG_ADMIN_SUBADMIN,subadmin); //ºÎ¿î¿µÀÚ ÀÓ¸í
			gcmd(DIALOG_ADMIN_DELSUB,delsub); //ºÎ¿î¿µÀÚ ¹ÚÅ»
			gcmd(DIALOG_ADMIN_FIND,find); //ÀÌ À¯ÀúÀÇ Á¤º¸ º¸±â
		}
		return 0;
	}
	//user main
	switch( dialogid )
	{
		gcmd(DIALOG_USER_MAIN,usermain); //±âº» ¸í·É¾î ¼ÂÆ®
		gcmd(DIALOG_USER_VOTEKICK,votekick); //°­Á¦Ãß¹æ
		gcmd(DIALOG_USER_VOTEBAN,voteban); //¿µ±¸Ãß¹æ
		gcmd(DIALOG_PM,superpm); //±Ó¼Ó¸»º¸³»±â
	}
	return 0;
}
//==========================================================
// Gui Command
//==========================================================
dialog_adminmain( playerid, response, listitem, inputtext[] ) //¸ÞÀÎ ÇÚµé·¯
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return 1;
	
	switch( listitem )
	{
	    case 0: //Kick Player
	    {
	        Auth_Check(AUTH_CMD_KICK);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP¿¡ ¹ö±×°¡ ÀÖÀ¸¹Ç·Î ÇÑ±ÛÀº ÀÔ·ÂÇÏÁö ¸¶½Ã±â ¹Ù¶ø´Ï´Ù.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KICK ); //È®ÀÎ ¸Þ¼¼Áö ¶ç¿ì±â
   	    }
	    case 1: //Ban Player
		{
		    Auth_Check(AUTH_CMD_BAN);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP¿¡ ¹ö±×°¡ ÀÖÀ¸¹Ç·Î ÇÑ±ÛÀº ÀÔ·ÂÇÏÁö ¸¶½Ã±â ¹Ù¶ø´Ï´Ù.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_BAN );//È®ÀÎ ¸Þ¼¼Áö ¶ç¿ì±â
		}
		case 2: //¸Þ¼¼Áö º¸³»±â
	    {
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP¿¡ ¹ö±×°¡ ÀÖÀ¸¹Ç·Î ÇÑ±ÛÀº ÀÔ·ÂÇÏÁö ¸¶½Ã±â ¹Ù¶ø´Ï´Ù.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
		case 3:
		{
		    Auth_Check(AUTH_CMD_WITH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_WITH ); //ÀÌµ¿ÇÏ±â
		}
		case 4:
		{
		    Auth_Check(AUTH_CMD_CALL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_CALL ); //¼ÒÈ¯ÇÏ±â
		}
		case 5:
		{
		    Auth_Check(AUTH_CMD_KILL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KILL ); //»ç»ìÇÏ±â
		}
		case 6:
		{
			Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP ); //Ã¼·Â º¯°æÇÏ±â
		}
		case 7:
		{
		    Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFINITE ); //¹«ÀûÀ¸·Î ¸¸µé±â
		}
		case 8:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH ); //µ·ÁÖ±â
		}
		case 9:
		{
            Auth_Check(AUTH_CMD_FORFEIT);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FORFEIT ); //µ·»¯±â
		}
		case 10:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH ); //µ·¼³Á¤
		}
		case 11:
		{
		    Auth_Check(AUTH_CMD_SETSCORE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE ); //½ºÄÚ¾î¼³Á¤
		}
		case 12:
		{
            Auth_Check(AUTH_CMD_GIVEWEAPON);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_GIVEWP ); //¹«±âÁÖ±â
		}
		case 13:
		{
		    Auth_Check(AUTH_CMD_DISARM);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_DISARM ); //¹«±â–ÁÖ±â
		}
		case 14:
		{
		    Auth_Check(AUTH_CMD_FREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FREEZE ); //ÇÁ¸®Áî
		}
		case 15:
		{
		    Auth_Check(AUTH_CMD_UNFREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNFREEZE ); //ÇÁ¸®Áî ÇØÁ¦
		}
		case 16:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR ); //¾Æ¸Ó
		}
		case 17:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFARMOR ); //¾Æ¸Ó¹«Àû
		}
		case 18:
		{
		    Auth_Check(AUTH_CMD_SPAWNCAR);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPAWNCAR ); //Â÷·®¼ÒÈ¯
		}
		case 19:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SDROP ); //Â÷¿¡¼­³»¸®±â
		}
		case 20:
		{
		    Auth_Check(AUTH_CMD_CARENERGY);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY ); //Â÷¿¡³ÊÁö Á¡°Ë
		}
		case 21:
		{
		    Auth_Check(AUTH_CMD_JETPACK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_JETPACK ); //Á¦Æ®ÆÑ ÁÖ±â
		}
		case 22:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSIC ); //¼Ò¸®µè±â
		}
		case 23:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSICOFF ); //¼Ò¸®²ô±â
		}
		case 24:
		{
		    Auth_Check(AUTH_CMD_BOMB);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_BOMB ); //ÆøÅº ÅÍÆ®¸®±â
		}
		case 25:
		{
		    Auth_Check(AUTH_CMD_SHUTUP);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SHUTUP ); //Ã¤ÆÃ ±ÝÁöÇÏ±â
		}
		case 26:
		{
		    Auth_Check(AUTH_CMD_UNSHUT);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNSHUT ); //Ã¤±Ý ÇØÁ¦ÇÏ±â
		}
		case 27:
		{
		    Auth_Check(AUTH_CMD_CHANGENICK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK ); //´Ð³×ÀÓ º¯°æÇÏ±â
		}
        case 28:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPECTATE ); //»ç¿ëÀÚ °¨½ÃÇÏ±â
		}
		case 29:
		{
		    Auth_Check(AUTH_CMD_SETSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SUBADMIN ); //ºÎ¿î¿µÀÚ ÀÓ¸íÇÏ±â
		}
		case 30:
		{
		    Auth_Check(AUTH_CMD_DELSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_DELSUB ); //ºÎ¿î¿µÀÚ ¹ÚÅ»ÇÏ±â
		}
		case 31:
		{
			Auth_Check(AUTH_CMD_USERINFO);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FIND ); //ÀÌ À¯ÀúÀÇ Á¤º¸ º¸±â
		}
		default: //¹ö±× Å½Áö
		{
			new str[128];
			format( str, sizeof(str), "* ¹ö±× ¸Þ´ºÃ¢ ½ºÆ®¸®¹Ö(%d): %s", listitem, inputtext );
			SendClientMessage( playerid, COLOR_RED, str );
		    return 1;
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_kick( playerid, response, listitem, inputtext[] ) //°­Á¦ÅðÀå °æ°í ¸Þ¼¼Áö
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //°­Á¦ÅðÀå ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_skick( playerid, str, CMD_KICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_ban( playerid, response, listitem, inputtext[] ) //¿µ±¸Ãß¹æ °æ°í ¸Þ¼¼Áö
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //¿µ±¸Ãß¹æ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sban( playerid, str, CMD_BAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_with( playerid, response, listitem, inputtext[] ) //ÃâµÎ
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ÃâµÎ ¸í·É¾î º¸³»±â
	dcmd_with( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_WITH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_call( playerid, response, listitem, inputtext[] ) //¼ÒÈ¯
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //¼ÒÈ¯ ¸í·É¾î º¸³»±â
	dcmd_call( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_CALL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_kill( playerid, response, listitem, inputtext[] ) //¼ÒÈ¯
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //»ç»ì ¸í·É¾î º¸³»±â
	dcmd_skill( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SKILL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_sethp( playerid, response, listitem, inputtext[] ) //¼ÒÈ¯
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP );
	}
    //Ã¼·Â¼³Á¤ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sethp( playerid, str, CMD_SETHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infinite( playerid, response, listitem, inputtext[] ) //¼ÒÈ¯
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Ã¼·Â¹«ÇÑ ¸í·É¾î º¸³»±â
	dcmd_infinite( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFINITE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_makecash( playerid, response, listitem, inputtext[] ) //µ·ÁÖ±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH );
	}
    //µ·ÁÖ±â ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_mcash( playerid, str, CMD_MCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_forfeit( playerid, response, listitem, inputtext[] ) //µ·»¯±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //µ·¸ô¼ö ¸í·É¾î º¸³»±â
	dcmd_forfeit( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FORFEIT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_setcash( playerid, response, listitem, inputtext[] ) //µ·¼³Á¤
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH );
	}
    //µ·¼³Á¤ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_setcash( playerid, str, CMD_SETCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_setscore( playerid, response, listitem, inputtext[] ) //½ºÄÚ¾î ¼³Á¤
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE );
	}
    //½ºÄÚ¾î¼³Á¤ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_score( playerid, str, CMD_SCORE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_givewp( playerid, response, listitem, inputtext[] ) //¹«±âÁÖ±â
{
	#define GIVEWP_STAGE_TYPE 0
	#define GIVEWP_STAGE_TYPECUSTOM 1
	#define GIVEWP_STAGE_AMMOAMOUNT 2
	#define GIVEWP_STAGE_AREYOUSURE 3
	static stage, weaponid, ammo;
	//Ãë¼ÒÇÑ °æ¿ì
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
	
	//±âÅ¸ ¹«±â¸¦ ¼±ÅÃÇÑ °æ¿ì
	if( stage == GIVEWP_STAGE_TYPE && listitem == sizeof(WEAPON_STORAGE) )
	{
		stage = GIVEWP_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "Á¦°øÇÒ ¹«±â¸¦ ¼±ÅÃÇÏ½Ê½Ã¿À.",
			"Á¦°øÇÒ ¹«±âÀÇ ¹øÈ£¸¦ ÁöÁ¤ÇÏ½Ê½Ã¿À.", "È®ÀÎ", "µÚ·Î" );
		return 1;
	}
	
	//¹«±â¹øÈ£¸¦ °ñ¶ú´Ù. ÃÑ¾Ë¼ö¸¦ °è»ê
	if( stage == GIVEWP_STAGE_TYPE || stage == GIVEWP_STAGE_TYPECUSTOM )
	{
	    //¹«±â¹øÈ£ ÀúÀå
	    if( stage == GIVEWP_STAGE_TYPE ) weaponid = WEAPON_STORAGE[listitem][weapon_id];
	    else weaponid = strval(inputtext);
	    //ÃÑ¾Ë¼ö ¹¯±â
	    stage = GIVEWP_STAGE_AMMOAMOUNT;
	    ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "ÃÑ¾Ë ¼ö¸¦ ÁöÁ¤ÇÏ½Ê½Ã¿À.",
			"±â·ÏÇÏÁö ¾Ê´Â °æ¿ì 3000¹ßÀ» Á¦°øÇÕ´Ï´Ù.", "È®ÀÎ", "µÚ·Î" );
	    return 1;
	}
	
	//ÃÑ¾Ë¼ö¸¦ °ñ¶ú´Ù. ÃÖÁ¾È®ÀÎ
	new str[128];
	if( stage == GIVEWP_STAGE_AMMOAMOUNT )
	{
	    //ÃÑ¾Ë¼ö ÀúÀå
		ammo = strval(inputtext);
		if( !ammo ) ammo = 3000;
		//ÃÖÁ¾È®ÀÎ
		stage = GIVEWP_STAGE_AREYOUSURE;
		GetWeaponName( weaponid, str, sizeof(str) );
		format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô ¹«±â¸¦ ÁÝ´Ï´Ù: %s(%d).\n ¹«±â¹øÈ£: %d(%s), ÃÑ¾Ë¼ö : %d¹ß.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
			GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid],
			weaponid, str, ammo );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		return 1;
	}

    //¹«±âÁÖ±â ¸í·É¾î º¸³»±â
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
dialog_disarm( playerid, response, listitem, inputtext[] ) //¹«±â»¯±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //¹«±â¸ô¼ö ¸í·É¾î º¸³»±â
	dcmd_disarm( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DISARM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_freeze( playerid, response, listitem, inputtext[] ) //ÇÁ¸®Áî
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //¹«±â¸ô¼ö ¸í·É¾î º¸³»±â
    new str[128];
    format( str, sizeof(str), "%d",DIALOG_CLICKED_PLAYER[playerid] );
	if( inputtext[0] ) format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_freeze( playerid, str, CMD_FREEZE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_unfreeze( playerid, response, listitem, inputtext[] ) //¾ðÇÁ¸®Áî
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ÇÁ¸®Áî ÇØÁ¦ ¸í·É¾î º¸³»±â
	dcmd_unfrz( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNFRZ, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_armor( playerid, response, listitem, inputtext[] ) //¾Æ¸Ó º¯°æ
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR );
	}
    //Ã¼·Â¼³Á¤ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_armor( playerid, str, CMD_ARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infarmor( playerid, response, listitem, inputtext[] ) //¾Æ¸Ó¹«Àû
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Ã¼·Â¹«ÇÑ ¸í·É¾î º¸³»±â
	dcmd_infarmor( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_spawncar( playerid, response, listitem, inputtext[] ) //Â÷¼ÒÈ¯
{
	#define SPAWNCAR_STAGE_TYPE 0
	#define SPAWNCAR_STAGE_TYPECUSTOM 1
	#define SPAWNCAR_STAGE_AREYOUSURE 2
	static stage, modelid;
	//Ãë¼ÒÇÑ °æ¿ì
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

	//±âÅ¸ Â÷·®À» ¼±ÅÃÇÑ °æ¿ì
	if( stage == SPAWNCAR_STAGE_TYPE && listitem == sizeof(VEHICLE_STORAGE) )
	{
		stage = SPAWNCAR_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_INPUT, "Á¦°øÇÒ Â÷·®À» ¼±ÅÃÇÏ½Ê½Ã¿À.",
			"Á¦°øÇÒ Â÷·®ÀÇ ¹øÈ£¸¦ ÁöÁ¤ÇÏ½Ê½Ã¿À.", "È®ÀÎ", "µÚ·Î" );
		return 1;
	}

	//Â÷·®¹øÈ£¸¦ °ñ¶ú´Ù. ÃÖÁ¾È®ÀÎ
	new str[128];
	if( stage == SPAWNCAR_STAGE_TYPE || stage == SPAWNCAR_STAGE_TYPECUSTOM )
	{
	    //Â÷·®¹øÈ£ ÀúÀå
	    if( stage == SPAWNCAR_STAGE_TYPE ) modelid = VEHICLE_STORAGE[listitem][weapon_id];
		else modelid = strval(inputtext);
		//ÃÖÁ¾È®ÀÎ
		stage = SPAWNCAR_STAGE_AREYOUSURE;
		format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô Â÷·®À» ÁÝ´Ï´Ù: %s(%d).\nÂ÷·® ¸ðµ¨: %d.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], modelid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		return 1;
	}

    //Â÷·®¼ÒÈ¯ ¸í·É¾î º¸³»±â
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
dialog_sdrop( playerid, response, listitem, inputtext[] ) //Â÷¶û¿¡¼­ ³»¸®±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Â÷·®¿¡¼­ ³»¸®±â ¸í·É¾î º¸³»±â
	dcmd_drop( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DROP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_carenergy( playerid, response, listitem, inputtext[] ) //Â÷¿¡³ÊÁö º¯°æ
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY );
	}
    //Â÷¿¡³ÊÁö º¯°æ ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_carhp( playerid, str, CMD_CARHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_jetpack( playerid, response, listitem, inputtext[] ) //Á¦Æ®ÆÑ ÁÖ±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Á¦Æ®ÆÑ ÁÖ±â ¸í·É¾î º¸³»±â
	dcmd_jpack( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_JPACK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_music( playerid, response, listitem, inputtext[] ) //À½¾Ç Àç»ý
{
	#define MUSIC_STAGE_TYPE 0
	#define MUSIC_STAGE_TYPECUSTOM 1
	#define MUSIC_STAGE_AREYOUSURE 2
	static stage, soundid;
	//Ãë¼ÒÇÑ °æ¿ì
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

	//±âÅ¸ Â÷·®À» ¼±ÅÃÇÑ °æ¿ì
	if( stage == MUSIC_STAGE_TYPE && listitem == sizeof(MUSIC_STORAGE) )
	{
		stage = MUSIC_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_INPUT, "Àç»ýÇÒ À½¾ÇÀ» ¼±ÅÃÇÏ½Ê½Ã¿À.",
			"Àç»ýÇÒ À½¾ÇÀÇ ¹øÈ£¸¦ ÁöÁ¤ÇÏ½Ê½Ã¿À.", "È®ÀÎ", "µÚ·Î" );
		return 1;
	}

	//¼Ò¸®¹øÈ£¸¦ °ñ¶ú´Ù. ÃÖÁ¾È®ÀÎ
	new str[128];
	if( stage == MUSIC_STAGE_TYPE || stage == MUSIC_STAGE_TYPECUSTOM )
	{
	    //Â÷·®¹øÈ£ ÀúÀå
	    if( stage == MUSIC_STAGE_TYPE ) soundid = MUSIC_STORAGE[listitem][weapon_id];
		else soundid = strval(inputtext);
		//ÃÖÁ¾È®ÀÎ
		stage = MUSIC_STAGE_AREYOUSURE;
		format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô À½¾ÇÀ» Àç»ýÇÕ´Ï´Ù: %s(%d).\n¼Ò¸® ¹øÈ£: %d.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], soundid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		return 1;
	}

    //À½¾ÇÀç»ý ¸í·É¾î º¸³»±â
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
dialog_musicoff( playerid, response, listitem, inputtext[] ) //¼Ò¸®²ô±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //¼Ò¸®²ô±â ¸í·É¾î º¸³»±â
	dcmd_mute( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_MUTE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_bomb( playerid, response, listitem, inputtext[] ) //ÆøÅº ÅÍÆ®¸®±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ÆøÅº ÅÍÆ®¸®±â ¸í·É¾î º¸³»±â
	dcmd_bomb( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_BOMB, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_shutup( playerid, response, listitem, inputtext[] ) //Ã¤ÆÃ±ÝÁö
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Ã¤ÆÃ±ÝÁö ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_shutup( playerid, str, CMD_SHUTUP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_unshut( playerid, response, listitem, inputtext[] ) //Ã¤±ÝÇØÁ¦
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Ã¤±ÝÇØÁ¦ ¸í·É¾î º¸³»±â
	dcmd_unshut( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNSHUT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_changenick( playerid, response, listitem, inputtext[] ) //´Ð¹Ù²Ù±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* °ªÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK );
	}
    //´Ð¹Ù²Ù±â ¸í·É¾î º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_chnick( playerid, str, CMD_CHNICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_spectate( playerid, response, listitem, inputtext[] ) //°¨½ÃÇÏ±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //°¨½Ã ¸í·É¾î º¸³»±â
	dcmd_spectate( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SPECTATE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_subadmin( playerid, response, listitem, inputtext[] ) //ºÎ¿î¿µÀÚ ÀÓ¸í
{
	#define SUBADMIN_STAGE_TYPE 0
	#define SUBADMIN_STAGE_AREYOUSURE 1
	static stage, authid;
	//Ãë¼ÒÇÑ °æ¿ì
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

	//±ÇÇÑÀ» °ñ¶ú´Ù. ÃÖÁ¾È®ÀÎ
	new str[128];
	if( stage == SUBADMIN_STAGE_TYPE )
	{
	    //±ÇÇÑ¹øÈ£ ÀúÀå
	    authid = listitem;
		//ÃÖÁ¾È®ÀÎ
		stage = SUBADMIN_STAGE_AREYOUSURE;
		format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ ºÎ¿î¿µÀÚ·Î ÀÓ¸íÇÕ´Ï´Ù: %s(%d).\nºÎ¿©ÇÒ ±ÇÇÑ: %s.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], inputtext );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		return 1;
	}

    //ºÎ¿î¿µÀÚ ÀÓ¸í ¸í·É¾î º¸³»±â
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
dialog_delsub( playerid, response, listitem, inputtext[] ) //ºÎ¿î¿µÀÚ ¹ÚÅ»
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ºÎ¿î¿µÀÚ ¹ÚÅ» ¸í·É¾î º¸³»±â
	dcmd_suspend( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SUSPEND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_find( playerid, response, listitem, inputtext[] ) //ÀÌ À¯ÀúÀÇ Á¤º¸ º¸±â
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //Á¤º¸º¸±â ¸í·É¾î º¸³»±â
	dcmd_find( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FIND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_usermain( playerid, response, listitem, inputtext[] ) //»ç¿ëÀÚ ¸ÞÀÎ ´ëÈ­»óÀÚ
{
	//Ãë¼ÒÇÑ °æ¿ì
	if( !response ) return 1;

	switch( listitem )
	{
	    case 0: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEKICK ); //Kick Player
	    case 1: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEBAN );//Ban Player
		case 2: //¸Þ¼¼Áö º¸³»±â
	    {
			#if !SAMP03x
			SendClientMessage( playerid, COLOR_RED, "* SA-MP¿¡ ¹ö±×°¡ ÀÖÀ¸¹Ç·Î ÇÑ±ÛÀº ÀÔ·ÂÇÏÁö ¸¶½Ã±â ¹Ù¶ø´Ï´Ù.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_superpm( playerid, response, listitem, inputtext[] ) //±Ó¼Ó¸»
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    //ÀÔ·ÂÇÏÁö ¾ÊÀº °æ¿ì
	if( !inputtext[0] )
	{
		SendClientMessage( playerid, COLOR_GREY, "* ¸Þ¼¼Áö¸¦ ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.");
	    return ShowPlayerDialogs( playerid, DIALOG_PM );
	}
	//¸Þ¼¼Áö º¸³»±â
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_spm( playerid, str, CMD_SPM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_votekick( playerid, response, listitem, inputtext[] ) //»ç¿ëÀÚ °­Á¦Ãß¹æ ÅõÇ¥
{
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
	dcmd_vkick( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VKICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}
//==========================================================
dialog_voteban( playerid, response, listitem, inputtext[] ) //»ç¿ëÀÚ ¿µ±¸Ãß¹æ ÅõÇ¥
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    dcmd_vban( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VBAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}

//==========================================================
#endif /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
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
			printf( "[help] ±¸¹®: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] »ç¿ë °¡´ÉÇÑ ¸í·É¾îÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù." );
			printf( "[help] %s [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ¸é ÇØ´ç ¸í·É¾îÀÇ µµ¿ò¸»À» º¸¿©ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s, %s ÃâµÎ", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¼³¸í: »ç¿ë °¡´ÉÇÑ ¸í·É¾îÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù." );
			format( str, sizeof(str), "* ¼³¸í: /%s [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ¸é ÇØ´ç ¸í·É¾îÀÇ µµ¿ò¸»À» º¸¿©ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s, /%s ÃâµÎ", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
		}
		return 1;
	}

	if( !isnull(params) )
	{
		//°¢ ¸í·É¾î·Î µµ¿ò¸»À» ¸®´ÙÀÌ·ºÆ®ÇÑ´Ù
		//¹ÙÀÌ³Ê¸® Æ®¸® »ç¿ë
		new i, hash, str[128];
		hash = fnv_hash( params );
		//ÇÑ±Û¿¡¼­ ¸ÕÀú °Ë»ç
		i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
		if( i == BINTREE_NOT_FOUND ) //ÇÑ±Û¿¡ ¾øÀ½ ¿µ¾î¿¡¼­ °Ë»ç
		{
			i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
			if ( i == BINTREE_NOT_FOUND )
			{
				//¾Ë ¼ö ¾ø´Â ¸í·É¾î
				if( CONSOLE ) printf("[rcon] ¾Ë ¼ö ¾ø´Â ¸í·É¾îÀÔ´Ï´Ù :  %s", params );
				else
				{
					format( str, sizeof(str), "* ¾Ë ¼ö ¾ø´Â ¸í·É¾îÀÔ´Ï´Ù :  %s", params );
					SendClientMessage( playerid, COLOR_GREY, str );
				}
				return 1;
			}
		}
		format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
		CallLocalFunction( str, "isib", playerid, NULL, i, true ); //help mode
		return 1;
	}
	
	//¸í·É¾î ¸ñ·Ï Ç¥½Ã
	new str[256];
	if( CONSOLE )
	{
		print("\n=====================  Rcon Controller : Command List  ========================");
		print("           ÀÚ¼¼ÇÑ µµ¿ò¸»À» º¸·Á¸é µµ¿ò¸» [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
		print(LINE);	
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, "===========  Rcon Controller : Command List  ==========");
		format( str, sizeof(str), "           ÀÚ¼¼ÇÑ µµ¿ò¸»À» º¸·Á¸é /%s [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ½Ê½Ã¿À.", cmdlist[CMD_HELP][Cmd] );
		SendClientMessage( playerid, COLOR_SALMON, str );
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);	
	}
	
	//¸í·É¾î¸¦ °¡Áö·±È÷ Á¤·ÄÇÏ¿© Ç¥½Ã
	new idx;
	//¼¼·Î·Î Ç¥½Ã
	new lines = ceildiv(sizeof( cmdlist ), 6); //¸îÁÙÀÎÁö ±¸ÇÑ´Ù
	for( new i = 0 ; i < lines ; i++ ) //ÁÙ¸¸Å­ ¹Ýº¹
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
		
		//printf(" Ã³À½ »ç¿ëÇÏ½Ã´Â ºÐÀÇ °æ¿ì 
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		//format( str, sizeof(str), "      Total %d Commands, (C) 2008 - 2013 CoolGuy(¹ä¸Ô¾ú´Ï)", sizeof( cmdlist ) );
		//SendClientMessage( playerid, COLOR_SALMON, str );
		//SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
	}
	/*
		µµ¿ò¸» ¾ç½Ä :  if( HELP )
	*/
	return 1;	
}
//==========================================================
public dcmd_rchelp2(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	//FIXME: ¿À·¡ µÇ¾ú½À´Ï´Ù. ´Ù¸¥ ¸í·É¾î·Î ¹Ù²Ù´Â °ÍÀÌ ÇÊ¿äÇÕ´Ï´Ù.
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] ±¸¹®: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ¸ðµç ¸í·É¾î¿¡ ´ëÇÑ °£·«ÇÑ ¼³¸íÀ» º¸¿©ÁÝ´Ï´Ù." );
			printf( "[help] ¿¹) %s", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¸ðµç ¸í·É¾î¿¡ ´ëÇÑ °£·«ÇÑ ¼³¸íÀ» º¸¿©ÁÝ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s", CURRENT_CMD_NAME ); SEND();
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
			printf( "[help] ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Æ¯Á¤ ÇÃ·¹ÀÌ¾î¿¡°Ô·Î ÀÌµ¿ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) /%s 10 : 10¹ø¿¡°Ô ÀÌµ¿ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) /%s coolguy : coolguy¿¡°Ô ÀÌµ¿ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print("[help] °ÔÀÓ Áß¿¡¸¸ °¡´ÉÇÏ¸ç, ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Æ¯Á¤ ÇÃ·¹ÀÌ¾î¿¡°Ô·Î ÀÌµ¿ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø¿¡°Ô ÀÌµ¿ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¿¡°Ô ÀÌµ¿ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
	SendClientMessage(playerid, COLOR_GREENYELLOW, "* ÃâµÎ ÇÏ¿´½À´Ï´Ù.");
	printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´Ô¿¡°Ô ÃâµÎÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Æ¯Á¤ ÇÃ·¹ÀÌ¾î¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù." );
			printf("[help] /%s *¸¦ ÀÔ·ÂÇÏ¸é ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) /%s 10: 10¹øÀ» ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) /%s coolguy: 10¹øÀ» ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) /%s *: ¸ðµÎ¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME );
			print("[help] °ÔÀÓ Áß¿¡¸¸ °¡´ÉÇÏ¸ç, ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Æ¯Á¤ ÇÃ·¹ÀÌ¾î¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù." );
			format( str, sizeof(str), "* /%s *¸¦ ÀÔ·ÂÇÏ¸é ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10: 10¹øÀ» ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy: 10¹øÀ» ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s *: ¸ðµÎ¸¦ ÀÌ°÷À¸·Î µ¥·Á¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¼ÒÈ¯ÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¼ÒÈ¯ÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid );
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
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» ¼ÒÈ¯ÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´ÔÀ» ¼ÒÈ¯ÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ÀÎÁõÇÏ¿© ±ÇÇÑÀ» ¾ò½À´Ï´Ù." );
			print( "[help] ºÎ¿î¿µÀÚ ÀÚ°ÝÀº RconController.ini¿¡¼­ ¸¸µå½Ç ¼ö ÀÖ½À´Ï´Ù. ");
			printf( "[help] ¿¹) /%s password: ºñ¹Ð¹øÈ£ 'password'¸¦ »ç¿ëÇÏ¿© ºÎ¿î¿µÀÚ·Î ·Î±×ÀÎÇÕ´Ï´Ù. ", CURRENT_CMD_NAME );
			print("[help] °ÔÀÓ Áß¿¡¸¸ °¡´ÉÇÏ¸ç, ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ÀÎÁõÇÏ¿© ±ÇÇÑÀ» ¾ò½À´Ï´Ù."  );
			SendClientMessage( playerid, COLOR_LIME, "* ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ¾òÀ¸½Ã·Á¸é ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä." );
			format( str, sizeof(str), "* ¿¹) /%s password: ºñ¹Ð¹øÈ£ 'password'¸¦ »ç¿ëÇÏ¿© ºÎ¿î¿µÀÚ·Î ·Î±×ÀÎÇÕ´Ï´Ù. ", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	No_Console();	

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. °ü¸®ÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä" );
		print( "[rcon] ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä." );
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
		SendClientMessage( playerid, COLOR_GREY, "* ÀÌ¹Ì ºÎ¿î¿µÀÚÀÔ´Ï´Ù." );
		return 1;
	}
	
	if(isnull(params)) return Usage( playerid, CMD_CURRENT );

	for(new i=0;i<Num_SubAdmin;i++)
	{
		if(!strcmp(GetPlayerNameEx(playerid),SubAdmin[i][Name]) && !strcmp(PLAYER_IP[playerid],SubAdmin[i][IP]) && SubAdmin[i][Password_Hash]==fnv_hash(params))
		{
			//·Î±×ÀÎ ½ÇÆÐ È½¼ö ÃÊ±âÈ­
			SUBADMIN_FAILLOGIN_TIMES[playerid] = 0;
			//¸Þ¼¼Áö ¶ç¿ì±â
			format(tmp,sizeof(tmp),"* %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ·Î ·Î±×ÀÎ ÇÏ¼Ì½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid);
			SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
			SendClientMessage(playerid,COLOR_ORANGE,"* µµ¿ò¸»Àº /rchelpÀÌ¸ç, ·Î±×¾Æ¿ôÀº /subout ¶Ç´Â /ºÎ¿îÁ¾·á ÀÔ´Ï´Ù.");
			printf("[rcon] %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ·Î ·Î±×ÀÎ ÇÏ¼Ì½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid);			
			SetPlayerSubAdmin( playerid, SubAdmin[i][profile_index] );
			return 1;
		}
	}

	SUBADMIN_FAILLOGIN_TIMES[playerid]++;
	if( SUBADMIN_FAILLOGIN_TIMES[playerid] >= SUBADMIN_FAILLOGIN_LIMIT )
	{
		format(tmp,sizeof(tmp),"* %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ ·Î±×ÀÎ¿¡ ½ÇÆÐÇÏ¿© Ãß¹æµË´Ï´Ù.",GetPlayerNameEx(playerid),playerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
		printf("[rcon] %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ ·Î±×ÀÎ¿¡ ½ÇÆÐÇÏ¿© Ãß¹æµË´Ï´Ù.",GetPlayerNameEx(playerid),playerid);
		Kill( playerid );
		c_Kick(playerid);
		return 1;
	}
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* ºÎ¿î¿µÀÚ ·Î±×ÀÎ¿¡ ½ÇÆÐÇÏ¿´½À´Ï´Ù. ´Ù½Ã ½ÃµµÇØ º¸¼¼¿ä.");
	printf("[rcon] %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ ·Î±×ÀÎ¿¡ ½ÇÆÐÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
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
			printf( "[help] ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ¹Ý³³ÇÏ°í ÀÏ¹Ý À¯Àú°¡ µË´Ï´Ù." );
			printf( "[help] ¿¹) /%s : ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ¹Ý³³ÇÏ°í ÀÏ¹Ý À¯Àú°¡ µË´Ï´Ù.", CURRENT_CMD_NAME );
			print("[help] °ÔÀÓ Áß¿¡¸¸ °¡´ÉÇÏ¸ç, ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ¹Ý³³ÇÏ°í ÀÏ¹Ý À¯Àú°¡ µË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : ºÎ¿î¿µÀÚ ÀÚ°ÝÀ» ¹Ý³³ÇÏ°í ÀÏ¹Ý À¯Àú°¡ µË´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();
	
	if( !IsPlayerSubAdmin( playerid ) )
	{
		SendClientMessage( playerid, COLOR_GREY, "* ºÎ¿î¿µÀÚ°¡ ¾Æ´Õ´Ï´Ù." );
		return 1;
	}
	
	new str[70];
	format(str,sizeof(str),"* %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹Ý³³ÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid);
	SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
	SendClientMessage(playerid,COLOR_GREENYELLOW,"* ·Î±×¾Æ¿ô ÇÏ¿´½À´Ï´Ù.");
	printf("[rcon] %s(%d)´Ô²²¼­ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹Ý³³ÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid);
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
			printf( "[help] ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç »ç¿ëÀÚ¿¡ ´ëÇÑ °ü¸® µµ±¸¸¦ ¿±´Ï´Ù." );
			print( "[help] TABÅ°¸¦ ´©¸£°í À¯Àú¸¦ ´õºíÅ¬¸¯ÇÏ¿© ¿­ ¼öµµ ÀÖ½À´Ï´Ù.");
			printf( "[help] ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¾î¶»°Ô ±¸¿ö»îÀ»Áö Ã¢À» ¿±´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) /%s coolguy : coolguy¸¦ ¾î¶»°Ô ±¸¿ö»îÀ»Áö Ã¢À» ¿±´Ï´Ù.", CURRENT_CMD_NAME );
			print("[help] °ÔÀÓ Áß¿¡¸¸ °¡´ÉÇÏ¸ç, ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇØ´ç »ç¿ëÀÚ¿¡ ´ëÇÑ °ü¸® µµ±¸¸¦ ¿±´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* TABÅ°¸¦ ´©¸£°í À¯Àú¸¦ ´õºíÅ¬¸¯ÇÏ¿© ¿­ ¼öµµ ÀÖ½À´Ï´Ù.");
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¾î¶»°Ô ±¸¿ö»îÀ»Áö Ã¢À» ¿±´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¸¦ ¾î¶»°Ô ±¸¿ö»îÀ»Áö Ã¢À» ¿±´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
#endif /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
//==========================================================
public dcmd_cmdtrace( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] ±¸¹®: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ¸í·É¾î ÃßÀûÀ» ½ÃÀÛ/Á¾·áÇÕ´Ï´Ù." );
			print("[help] ´Ù¸¥ ÇÃ·¹ÀÌ¾îÀÇ ¸í·É¾î¸¦ ÄÜ¼Ö¿¡ ½Ç½Ã°£À¸·Î Ç¥½ÃÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ¸í·É¾î ÃßÀûÀ» ½ÃÀÛ/Á¾·áÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¸í·É¾î ÃßÀûÀ» ½ÃÀÛ/Á¾·áÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ¸í·É¾î ÃßÀûÀº ´Ù¸¥ ÇÃ·¹ÀÌ¾îÀÇ ¸í·É¾î¸¦ Ã¤ÆÃÃ¢¿¡ ½Ç½Ã°£À¸·Î Ç¥½ÃÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : ¸í·É¾î ÃßÀûÀ» ½ÃÀÛ/Á¾·áÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	IS_HEAR_CMDTRACE[playerid] = !IS_HEAR_CMDTRACE[playerid];
	
	if( CONSOLE ) printf("[rcon] ¸í·É¾î ÃßÀû±â´ÉÀ» %sÇÏ¿´½À´Ï´Ù.", (IS_HEAR_CMDTRACE[playerid])? ("½ÃÀÛ"):("Áß´Ü") );
	else
	{
		SendClientMessage(playerid,COLOR_GREENYELLOW,(IS_HEAR_CMDTRACE[playerid])? ("* ¸í·É¾î ÃßÀûÀ» ½ÃÀÛÇÏ¿´½À´Ï´Ù."):("* ¸í·É¾î ÃßÀûÀ» Áß´ÜÇÏ¿´½À´Ï´Ù."));
		printf("[rcon] %s(%d)´Ô²²¼­ ¸í·É¾î ÃßÀûÀ» %sÇÏ¼Ì½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid,(IS_HEAR_CMDTRACE[playerid])? ("½ÃÀÛ"):("Áß´Ü"));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¼±ÅÃÇÑ ÇÃ·¹ÀÌ¾îÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguyÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s ", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¼±ÅÃÇÑ ÇÃ·¹ÀÌ¾îÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguyÀÇ Á¤º¸¸¦ ¼öÁýÇÏ¿© º¸°íÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô ±Ó¼Ó¸»À» º¸³À´Ï´Ù." );
			printf( "[help] %s Admin ¶Ç´Â ¿î¿µÀÚ¸¦ »ç¿ëÇÏ½Ã¸é ¼­¹ö ¿î¿µÀÚ¿¡°Ô ¸Þ¼¼Áö¸¦ º¸³¾ ¼ö ÀÖ½À´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy ¾È³ç : coolguy¿¡°Ô \"¾È³ç\"ÀÌ¶ó´Â ¸Þ¼¼Áö¸¦ º¸³À´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s ¿î¿µÀÚ ¿î¿µÀÚ Â¼·¯: ¿î¿µÀÚ¿¡°Ô '¿î¿µÀÚ Â¼·¯' ¶ó°í ÀÌ¾ß±âÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print( LINE );
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT );
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô ±Ó¼Ó¸»À» º¸³À´Ï´Ù." );
			format( str, sizeof(str), "* /%s Admin ¶Ç´Â ¿î¿µÀÚ¸¦ »ç¿ëÇÏ½Ã¸é ¼­¹ö ¿î¿µÀÚ¿¡°Ô ¸Þ¼¼Áö¸¦ º¸³¾ ¼ö ÀÖ½À´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy ¾È³ç : coolguy¿¡°Ô \"¾È³ç\"ÀÌ¶ó´Â ¸Þ¼¼Áö¸¦ º¸³À´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s ¿î¿µÀÚ ¿î¿µÀÚ Â¼·¯ : ¿î¿µÀÚ¿¡°Ô '¿î¿µÀÚ Â¼·¯' ¶ó°í ÀÌ¾ß±âÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				//Àß¸ø ¾´ °æ¿ì È®ÀÎ
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] »ó´ë¹æ¿¡°Ô ÇÒ ¸»À» ½á ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* »ó´ë¹æ¿¡°Ô ÇÒ ¸»À» ½á ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¹®ÀÚ±îÁö ÀÔ·Â
			{
				//¾´ ±ÛÀÌ ¾ø´Â °æ¿ì
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] º¸³¾ ¸Þ¼¼Áö¸¦ ½á ÁÖ½Ê½Ã¿À. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* º¸³¾ ¸Þ¼¼Áö¸¦ ½á ÁÖ½Ê½Ã¿À. ");
					return 1;
				}
				format( msg, sizeof(msg), "%s", tmp ); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s ¾Ë·Áµå¸³´Ï´Ù : ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î \"¾Ë·Áµå¸³´Ï´Ù\" ¶ó°í ¸»ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] °è¼ÓÇÏ¿© ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ÀÌ¾ß±âÇÏ·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À." , GetCmdName(CMD_PSAY) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s ¾Ë·Áµå¸³´Ï´Ù : ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î \"¾Ë·Áµå¸³´Ï´Ù\" ¶ó°í ¸»ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) °è¼ÓÇÏ¿© ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ÀÌ¾ß±âÇÏ·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À." , GetCmdName(CMD_PSAY) ); SEND();
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
		format(str,sizeof(str),"* ºÎ¿î¿µÀÚ %s: %s", GetPlayerNameEx(playerid), params);
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
			printf( "[help] ±¸¹®: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] Ç×»ó ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÏµµ·Ï ¼³Á¤ÇÕ´Ï´Ù." );
			print( "[help] ¸»¸ðµå »óÅÂ¿¡¼­ ¸í·É¾î¸¦ »ç¿ëÇÒ°æ¿ì ¸í·É¾î ¾Õ¿¡ !¸¦ ºÙÀÌ¸é µË´Ï´Ù." );
			print( "[help] ¸»¸ðµå¸¦ ÇØÁ¦ÇÏ·Á¸é !¸»¸ðµå ¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À." );
			printf( "[help] ¿¹) %s : Ç×»ó ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÏµµ·Ï ¼³Á¤ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Ç×»ó ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÏµµ·Ï ¼³Á¤ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : Ç×»ó ¿î¿µÀÚ ÀÚ°ÝÀ¸·Î ´ëÈ­ÇÏµµ·Ï ¼³Á¤ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	PERMANENT_ADMINSAY[playerid] = !PERMANENT_ADMINSAY[playerid];
	if( CONSOLE )
	{
		if ( PERMANENT_ADMINSAY( playerid ) )
		{
			print( "[rcon] ¿î¿µÀÚ¸» ¸ðµå·Î ÀüÈ¯Çß½À´Ï´Ù." );
			print( "[help] ¸»¸ðµå »óÅÂ¿¡¼­ ¸í·É¾î¸¦ »ç¿ëÇÒ°æ¿ì ¸í·É¾î ¾Õ¿¡ !¸¦ ºÙÀÌ¸é µË´Ï´Ù." );
			print( "[help] ¸»¸ðµå¸¦ ÇØÁ¦ÇÏ·Á¸é !¸»¸ðµå ¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		}
		else
		{
			print ("[rcon] ¿î¿µÀÚ¸» ¸ðµå¸¦ Á¾·áÇß½À´Ï´Ù." );
		}
	}
	else SendClientMessage( playerid, COLOR_GREENYELLOW, PERMANENT_ADMINSAY(playerid)? ( "* ¿î¿µÀÚ¸» ¸ðµå·Î ÀüÈ¯Çß½À´Ï´Ù." ):( "* ¿î¿µÀÚ¸» ¸ðµå¸¦ Á¾·áÇß½À´Ï´Ù." ) );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ¼­¹öÀÇ ½Ã°¢À» º¯°æÇÕ´Ï´Ù. 24½Ã°£Á¦·Î Ç¥±âÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 21: ¼­¹ö ½Ã°¢À» ¿ÀÈÄ 09:00À¸·Î º¯°æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇöÀç ¼­¹öÀÇ ½Ã°¢À» º¯°æÇÕ´Ï´Ù. 24½Ã°£Á¦·Î Ç¥±âÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 21: ¼­¹ö ½Ã°¢À» ¿ÀÈÄ 09:00À¸·Î º¯°æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] ¹Ù²Ù°í ½ÍÀº ½Ã°¢À» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* ¹Ù²Ù°í ½ÍÀº ½Ã°¢À» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}
	
	if(isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 23)
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] ½Ã°¢À» Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* ½Ã°¢À» Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[36];
	format(str,sizeof(str),"* ½Ã°¢ÀÌ %d:00 À¸·Î º¯°æµÇ¾ú½À´Ï´Ù.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWorldTime(strval(params));
	printf("[rcon] ½Ã°¢ÀÌ %d:00 À¸·Î º¯°æµÇ¾ú½À´Ï´Ù.",strval(params));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ »ç»ìÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ »ç»ìÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¸¦ »ç»ìÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ »ç»ìÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ »ç»ìÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¸¦ »ç»ìÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
				SendClientMessageToAll(COLOR_GREENYELLOW, "* ¿î¿µÀÚ°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ »ç»ìÇÏ¿´½À´Ï´Ù.");
				print("[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ »ç»ìÇß½À´Ï´Ù.");			
			}
			else 
			{
				new str[81];
				format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ »ç»ìÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
				SendClientMessageToAll(COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ »ç»ìÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),playerid );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) Kill(pITT[i]);
			return 1;
		}
	}
	
	new str[79];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» »ç»ìÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀ» »ç»ìÇß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦ Ãß¹æÇÕ´Ï´Ù." );
			print( "[help] [ÀÌÀ¯]¿¡ ±ÛÀÚ¸¦ ÀûÀ¸¸é Ãß¹æµÇ´Â À¯Àú¿¡°Ô ¸Þ¼¼Áö°¡ Àü¼ÛµË´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¹¯Áöµµ µûÁöÁöµµ ¾Ê°í Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy ºñ¸Å³Ê ÇàÀ§ : coolguy°¡ 'ºñ¸Å³Ê ÇàÀ§'¸¦ ÇØ¼­ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦ Ãß¹æÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* [ÀÌÀ¯]¿¡ ±ÛÀÚ¸¦ ÀûÀ¸¸é Ãß¹æµÇ´Â À¯Àú¿¡°Ô ¸Þ¼¼Áö°¡ Àü¼ÛµË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¹¯Áöµµ µûÁöÁöµµ ¾Ê°í Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy ºñ¸Å³Ê ÇàÀ§ : coolguy°¡ 'ºñ¸Å³Ê ÇàÀ§'¸¦ ÇØ¼­ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//±âÃÊ ÇÁ·Î¼¼½º
	sscanf(tmp,"ss",params,reason);
	if(isnull(tmp)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				//Àß¸ø ¾´ °æ¿ì È®ÀÎ
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] Ãß¹æÇÏ´Â ÀÌÀ¯°¡ ÀÖÀ¸¸é ½á ÁÖ½Ê½Ã¿À. ¾øÀ¸¸é '0' À» Àû¾îÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* Ãß¹æÇÏ´Â ÀÌÀ¯°¡ ÀÖÀ¸¸é ½á ÁÖ½Ê½Ã¿À. ¾øÀ¸¸é 0 À» Àû¾îÁÖ½Ê½Ã¿À." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¹®ÀÚ±îÁö ÀÔ·Â
			{			
				if( isnull(tmp) || tmp[0] =='0' ) reason[0] = EOS; //ÀÌÀ¯°¡ ¾ø´Â °æ¿ì
				else format( reason, sizeof(reason), "%s", tmp ); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
					printf("[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇß½À´Ï´Ù. (ÀÌÀ¯ : %s)", reason );
					format( reason, sizeof(reason), "* ¿î¿µÀÚ°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* ¿î¿µÀÚ°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.");
					print("[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇß½À´Ï´Ù.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ Ãß¹æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_Kick(pITT[i]);
			return 1;
		}
	}
	
	new str[216];	
	if( strlen(reason) ) format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» Ãß¹æÇß½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» Ãß¹æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀ» Ãß¹æÇß½À´Ï´Ù.(ÀÌÀ¯ : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("ÀûÁö ¾ÊÀ½"));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇÏ¸ç, ÀÌÈÄ Á¢¼ÓÀ» Â÷´ÜÇÕ´Ï´Ù." );
			print( "[help] [ÀÌÀ¯]¿¡ ±ÛÀÚ¸¦ ÀûÀ¸¸é Ãß¹æµÇ´Â À¯Àú¿¡°Ô ¸Þ¼¼Áö°¡ Àü¼ÛµË´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¹¯Áöµµ µûÁöÁöµµ ¾Ê°í ¿µ±¸Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy ÇÙ»ç¿ë : coolguy°¡ 'ÇÙ»ç¿ë'À» ÇØ¼­ ¿µ±¸Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿µ±¸Ãß¹æÀ» Ãë¼ÒÇÏ·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇÏ¸ç, ÀÌÈÄ Á¢¼ÓÀ» Â÷´ÜÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* [ÀÌÀ¯]¿¡ ±ÛÀÚ¸¦ ÀûÀ¸¸é Ãß¹æµÇ´Â À¯Àú¿¡°Ô ¸Þ¼¼Áö°¡ Àü¼ÛµË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¹¯Áöµµ µûÁöÁöµµ ¾Ê°í ¿µ±¸Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy ÇÙ»ç¿ë : coolguy°¡ 'ÇÙ»ç¿ë'À» ÇØ¼­ ¿µ±¸Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿µ±¸Ãß¹æÀ» Ãë¼ÒÇÏ·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNBAN) );			 SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//±âÃÊ ÇÁ·Î¼¼½º
	sscanf(tmp,"ss",params,reason);
	if( isnull(tmp) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				//Àß¸ø ¾´ °æ¿ì È®ÀÎ
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¿µ±¸Ãß¹æÇÏ´Â ÀÌÀ¯°¡ ÀÖÀ¸¸é ½á ÁÖ½Ê½Ã¿À. ¾øÀ¸¸é '0' À» Àû¾îÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¿µ±¸Ãß¹æÇÏ´Â ÀÌÀ¯°¡ ÀÖÀ¸¸é ½á ÁÖ½Ê½Ã¿À. ¾øÀ¸¸é 0 À» Àû¾îÁÖ½Ê½Ã¿À." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¹®ÀÚ±îÁö ÀÔ·Â
			{			
				if( isnull(tmp) || tmp[0] == '0' ) reason[0] = EOS; //ÀÌÀ¯°¡ ¾ø´Â °æ¿ì
				else format( reason, sizeof(reason), "%s", tmp ); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
					printf("[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸Ãß¹æÇß½À´Ï´Ù. (ÀÌÀ¯ : %s)", reason );
					format( reason, sizeof(reason), "* ¿î¿µÀÚ°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* ¿î¿µÀÚ°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.");
					print("[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸Ãß¹æÇß½À´Ï´Ù.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)´ÔÀÌ ÇÃ·¹ÀÌ¾î ¸ðµÎ¸¦ ¿µ±¸Ãß¹æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_BanEx( pITT[i], reason );
			return 1;
		}
	}
	
	new str[220];	
	if( strlen(reason) ) format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» ¿µ±¸Ãß¹æÇß½À´Ï´Ù.(ÀÌÀ¯ : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» ¿µ±¸Ãß¹æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀ» ¿µ±¸Ãß¹æÇß½À´Ï´Ù.(ÀÌÀ¯ : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("ÀûÁö ¾ÊÀ½"));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÏÁ¤·®ÀÇ µ·À» ÁÖ°Å³ª »¯½À´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 10000 : 10¹ø¿¡°Ô $10000ÀÇ µ·À» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy -20 : coolguy¿¡°Ô¼­ $20À» »¯½À´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ÇÃ·¹ÀÌ¾îÀÇ µ·À» $0À¸·Î ¸¸µé·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_FORFEIT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÏÁ¤·®ÀÇ µ·À» ÁÝ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 10000 : 10¹ø¿¡°Ô $10000ÀÇ µ·À» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy -20 : coolguy¿¡°Ô¼­ $20À» »¯½À´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ÇÃ·¹ÀÌ¾îÀÇ µ·À» $0À¸·Î ¸¸µé·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_FORFEIT) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] »ó´ë¹æ¿¡°Ô ÁÙ µ·ÀÇ ¾çÀ» ½á ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* »ó´ë¹æ¿¡°Ô ÁÙ µ·ÀÇ ¾çÀ» ½á ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //µ· ¾ç ÀÔ·Â
			{
				//µ· ¾çÀÌ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) || strval(tmp) == 0 )
				{
					if( CONSOLE ) print("[rcon] µ·ÀÇ ¾çÀ» Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* µ·ÀÇ ¾çÀ» Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				amount = strval(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", amount );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", amount);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, amount);
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), amount);
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
		format(str,sizeof(str),"* %s(%d)´Ô¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´Ô¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	}
	else printf("[rcon] %s(%d)´Ô¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô $%dÀÇ µ·À» Áã¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), amount);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÃ·¹ÀÌ¾î¿¡°Ô ¹«±â¿Í Åº¾àÀ» Á¦°øÇÕ´Ï´Ù." );
			print( "[help] [ÃÑ¾Ë] ¶õ¿¡ ±âÀÔÇÏÁö ¾Ê´Â °æ¿ì 3000¹ßÀ» Á¦°øÇÏ°Ô µË´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 32 50 : 10¹ø¿¡°Ô 32¹ø ¹«±â(TEC-9)¿Í 50¹ßÀÇ Åº¾àÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 38: coolguy¿¡°Ô 38¹ø ¹«±â(¹Ì´Ï°Ç)¿Í 3000¹ßÀÇ Åº¾àÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			print( "[help] ÁÖ¿ä ¹«±â ¸ñ·Ï : TEC9-32, ·ÎÄÏ-35, ¹Ì´Ï°Ç-38 ");
			printf( "[help] ¹«±â¸¦ »¯À¸·Á¸é %s ¸í·ÉÀ» »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_DISARM) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÃ·¹ÀÌ¾î¿¡°Ô ¹«±â¿Í Åº¾àÀ» Á¦°øÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* [ÃÑ¾Ë] ¶õ¿¡ ±âÀÔÇÏÁö ¾Ê´Â °æ¿ì 3000¹ßÀ» Á¦°øÇÏ°Ô µË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 32 50 : 10¹ø¿¡°Ô 32¹ø ¹«±â(TEC-9)¿Í 50¹ßÀÇ Åº¾àÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 38: coolguy¿¡°Ô 38¹ø ¹«±â(¹Ì´Ï°Ç)¿Í 3000¹ßÀÇ Åº¾àÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ÁÖ¿ä ¹«±â ¸ñ·Ï : TEC9-32, ·ÎÄÏ-35, ¹Ì´Ï°Ç-38 "); SEND();
			format( str, sizeof(str), "* ¹«±â¸¦ »¯À¸·Á¸é %s ¸í·ÉÀ» »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_DISARM) ); SEND();
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
			printf("[rcon] »ç¿ë¹ý: %s or %s [ÀÌ¸§ÀÌ³ª ¹øÈ£] [¹«±â¹øÈ£] [ÃÑ¾Ë = 3000¹ß]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			printf("[rcon] ÀÚ¼¼ÇÑ »ç¿ë¹ýÀº µµ¿ò¸» %s À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.", GetCmdName(CMD_GIVEWP) );
		}
		else
		{
			format( str, sizeof(str), "* »ç¿ë¹ý: /%s or /%s [ÀÌ¸§ÀÌ³ª ¹øÈ£] [¹«±â¹øÈ£] [ÃÑ¾Ë = 3000¹ß]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
			format( str, sizeof(str), "* ÀÚ¼¼ÇÑ »ç¿ë¹ýÀº /%s %s À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.", GetCmdName(CMD_HELP), GetCmdName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
		}
		return 1;
	}
	if(isNumeric(params) && strval(params)>=0 && strval(params)<M_P && IsPlayerConnectedEx(strval(params))) giveplayerid=strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid=PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	if( USE_ANTI_WEAPONCHEAT && IsWeaponForbidden(weaponid) )
	{
		if(CONSOLE) print("[rcon] ¼­¹ö¿¡¼­ »ç¿ëÀ» ±ÝÁöÇÑ ¹«±âÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ¼­¹ö¿¡¼­ »ç¿ëÀ» ±ÝÁöÇÑ ¹«±âÀÔ´Ï´Ù.");
		return 1;
	}
	GivePlayerWeapon(giveplayerid,weaponid,(ammo)? (ammo):(3000));
	new str[148];
	GetWeaponName(weaponid,str,sizeof(str));
	printf("[rcon] %s(%d)´Ô¿¡°Ô ¹«±â %s¿Í(°ú) %d¹ßÀÇ Åº¾àÀ» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)´Ô¿¡°Ô ¹«±â %s¿Í(°ú) %d¹ßÀÇ Åº¾àÀ» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	GetWeaponName(weaponid,str,sizeof(str));
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô ¹«±â %s¿Í(°ú) %d¹ßÀÇ Åº¾àÀ» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), str,(ammo)? (ammo):(3000));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ ÀÌ¸§À» º¯°æÇÕ´Ï´Ù." );
			print( "[help] Æ¯Á¤ÇÑ ÇÃ·¯±×ÀÎÀ» »ç¿ëÇÏ´Â ¼­¹öÀÇ °æ¿ì ÇÑ±Û ´Ð³×ÀÓ Àû¿ëµµ °¡´ÉÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 ½É¿µ : 10¹ø »ç¿ëÀÚÀÇ ´Ð³×ÀÓÀ» '½É¿µ' À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy Cool : coolguyÀÇ ´Ð³×ÀÓÀ» Cool·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ ÀÌ¸§À» º¯°æÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* Æ¯Á¤ÇÑ ÇÃ·¯±×ÀÎÀ» »ç¿ëÇÏ´Â ¼­¹öÀÇ °æ¿ì ÇÑ±Û ´Ð³×ÀÓ Àû¿ëµµ °¡´ÉÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 ½É¿µ : 10¹ø »ç¿ëÀÚÀÇ ´Ð³×ÀÓÀ» '½É¿µ' À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy Cool : coolguyÀÇ ´Ð³×ÀÓÀ» Cool·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, nick[MAX_PLAYER_NAME];
	
	//±âÃÊ ÇÁ·Î¼¼½º
	sscanf(tmp,"ss",params,nick);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				//Àß¸ø ¾´ °æ¿ì È®ÀÎ
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¹Ù²Ü ´Ð³×ÀÓÀ» Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¹Ù²Ü ´Ð³×ÀÓÀ» Àû¾î ÁÖ½Ê½Ã¿À." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¹®ÀÚ±îÁö ÀÔ·Â
			{			
				//¾´ ±ÛÀÌ ¾ø´Â °æ¿ì
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] ´Ð³×ÀÓÀ» ½á ÁÖ½Ê½Ã¿À. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ´Ð³×ÀÓÀ» ½á ÁÖ½Ê½Ã¿À. ");
					return 1;
				}
				format( nick, sizeof(nick), "%s", tmp ); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
	//debugprintf("[rcon] ¹Ù²Û ´Ð³×ÀÓ : %s, ÇöÀç ´Ð³×ÀÓ: %s", nick, str );
	if( strcmp( nick, str, false ) == 0 )
	{
		format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ´Ð³×ÀÓÀ» %s(À¸)·Î ¹Ù²å½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)´ÔÀÇ ´Ð³×ÀÓÀ» %s(À¸)·Î ¹Ù²å½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		PLAYER_NAME[giveplayerid] = nick;
	}
	else
	{
		if( CONSOLE ) print("[rcon] ´Ð³×ÀÓ º¯°æ¿¡ ½ÇÆÐÇß½À´Ï´Ù. º¯°æÇÏ·Á´Â ´Ð³×ÀÓ¿¡ ¹®Á¦°¡ ÀÖ½À´Ï´Ù.");
		else SendClientMessage( playerid, COLOR_RED, "* ´Ð³×ÀÓ º¯°æ¿¡ ½ÇÆÐÇß½À´Ï´Ù. º¯°æÇÏ·Á´Â ´Ð³×ÀÓ¿¡ ¹®Á¦°¡ ÀÖ½À´Ï´Ù." );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» ¼³Á¤ÇÕ´Ï´Ù." );
			print( "[help] ÀÏ¹ÝÀûÀ¸·Î ±âº» Ã¼·ÂÀº 100ÀÌ¸ç, 0Àº »ç¸ÁÀÔ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 20.0 : 10¹øÀÇ Ã¼·ÂÀ» 20.0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 56.7 : coolguyÀÇ Ã¼·ÂÀ» 56.7·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] Ã¼·ÂÀ» 0À¸·Î ¸¸µå·Á¸é %s ¸í·É¾î¸¦, ¹«ÀûÀ¸·Î ¸¸µå·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» ¼³Á¤ÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ÀÏ¹ÝÀûÀ¸·Î ±âº» Ã¼·ÂÀº 100ÀÌ¸ç, 0Àº »ç¸ÁÀÔ´Ï´Ù." );			
			format( str, sizeof(str), "* ¿¹) /%s 10 20.0 : 10¹øÀÇ Ã¼·ÂÀ» 20.0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 56.7 : coolguyÀÇ Ã¼·ÂÀ» 56.7·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* Ã¼·ÂÀ» 0À¸·Î ¸¸µå·Á¸é /%s ¸í·É¾î¸¦, ¹«ÀûÀ¸·Î ¸¸µå·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¼³Á¤ÇÒ Ã¼·ÂÀ» Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¼³Á¤ÇÒ Ã¼·ÂÀ» Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //Ã¼·Â ÀÔ·Â
			{
				//Ã¼·ÂÀÌ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( isnull(tmp) || floatstr(tmp) <= 0.0 )
				{
					if( CONSOLE ) print("[rcon] Ã¼·ÂÀ» Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* Ã¼·ÂÀ» Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				health = floatstr(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» %.1f·Î º¯°æÇß½À´Ï´Ù.", health );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» %.1f·Î º¯°æÇß½À´Ï´Ù.", health );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» %.1f·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, health);
			}
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), health);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth(pITT[i], health);
			return 1;
		}
	}

	new str[99];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ Ã¼·ÂÀ» %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid, health);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ Ã¼·ÂÀ» %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,health);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¼³Á¤ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 0 : 10¹øÀÇ ¾Æ¸Ó¸¦ ¾ø¾Û´Ï´Ù. ",  CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 70.0 : coolguyÀÇ ¾Æ¸Ó¸¦ 70.0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ±âº» ¾Æ¸Ó´Â 100ÀÌ¸ç, ¾Æ¸Ó ¹«ÇÑÀº %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_INFARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¼³Á¤ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 0 : 10¹øÀÇ ¾Æ¸Ó¸¦ ¾ø¾Û´Ï´Ù. ",  CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 70.0 : coolguyÀÇ ¾Æ¸Ó¸¦ 70.0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) ±âº» ¾Æ¸Ó´Â 100ÀÌ¸Ó, ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µå·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_INFARMOR) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¼³Á¤ÇÒ ¾Æ¸Ó¸¦ Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¼³Á¤ÇÒ ¾Æ¸Ó¸¦ Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¾Æ¸Ó ÀÔ·Â
			{
				//¾Æ¸Ó°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] ¾Æ¸Ó¸¦ Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ¾Æ¸Ó¸¦ Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				armour = floatstr(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", armour );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", armour );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, armour);
			}
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), armour);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], armour);
			return 1;
		}
	}	

	new str[98];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ¾Æ¸Ó¸¦ %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,armour);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ¾Æ¸Ó¸¦ %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,armour);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ³×¿À·Î ¸¸µì´Ï´Ù." );
			print( "[help] ¾Æ¸Ó°¡ ¹«ÀûÀÌ µÇ¸é ÃÑ¾Ë µîÀÇ Ãæ°Ý¿¡ °ßµô ¼ö ÀÖ½À´Ï´Ù." );			
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¾Æ¸Ó ¹«ÇÑÀ¸·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¸¦ ¾Æ¸Ó ¹«ÇÑÀ¸·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¾Æ¸Ó¸¦ ¾ø¾Ö·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_ARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ³×¿À·Î ¸¸µì´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ¾Æ¸Ó°¡ ¹«ÀûÀÌ µÇ¸é ÃÑ¾Ë µîÀÇ Ãæ°Ý¿¡ °ßµô ¼ö ÀÖ½À´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¾Æ¸Ó ¹«ÇÑÀ¸·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¸¦ ¾Æ¸Ó ¹«ÇÑÀ¸·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¾Æ¸Ó¸¦ ¾ø¾Ö·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_ARMOR) ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.");
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], 10000.0);
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ º¯°æÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 50 : 10¹ø »ç¿ëÀÚÀÇ Á¡¼ö¸¦ 50À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 100 : coolguyÀÇ Á¡¼ö¸¦ 100À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ º¯°æÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 50 : 10¹ø »ç¿ëÀÚÀÇ Á¡¼ö¸¦ 50À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 100 : coolguyÀÇ Á¡¼ö¸¦ 100À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¼³Á¤ÇÒ Á¡¼ö¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¼³Á¤ÇÒ Á¡¼ö¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //½ºÄÚ¾î ÀÔ·Â
			{
				//½ºÄÚ¾î°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] Á¡¼ö¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* Á¡¼ö¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				score = strval(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ %d·Î º¯°æÇÏ¿´½À´Ï´Ù.", score );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ %d·Î º¯°æÇÏ¿´½À´Ï´Ù.", score );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ %d·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, score);
			}
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Á¡¼ö¸¦ %d·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), score);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerScore(pITT[i], score);
			return 1;
		}
	}
	
	SetPlayerScore(giveplayerid,score);
	new str[99];
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)´ÔÀÇ Á¡¼ö¸¦ %d(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½ÅÀÇ Á¡¼ö¸¦ %d(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid),score);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ Á¡¼ö¸¦ %d·Î º¯°æÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù." );
			print( "[help] ½Ã°£À» ÀûÀ¸¸é ±×¸¸Å­¸¸, ÀûÁö ¾ÊÀ¸¸é Ç®¾îÁÙ ¶§±îÁö ¿òÁ÷ÀÏ ¼ö ¾ø½À´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 30 :10¹ø »ç¿ëÀÚ¸¦ 30ÃÊ°£ ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¸¦ Ç®¾îÁÙ ¶§±îÁö ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ´Ù½Ã ¿òÁ÷ÀÏ¼ö ÀÖ°Ô ÇÏ·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNFRZ) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ½Ã°£À» ÀûÀ¸¸é ±×¸¸Å­¸¸, ÀûÁö ¾ÊÀ¸¸é Ç®¾îÁÙ ¶§±îÁö ¿òÁ÷ÀÏ ¼ö ¾ø½À´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 30 :10¹ø »ç¿ëÀÚ¸¦ 30ÃÊ°£ ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¸¦ Ç®¾îÁÙ ¶§±îÁö °è¼Ó ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ´Ù½Ã ¿òÁ÷ÀÏ¼ö ÀÖ°Ô ÇÏ·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNFRZ) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÒ ½Ã°£À» Á¤ÇÏ½Ê½Ã¿À. °è¼Ó ¹­¾îµÎ·Á¸é 0À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¿òÁ÷ÀÌÁö ¸øÇÏ°Ô ÇÒ ½Ã°£À» Á¤ÇÏ½Ê½Ã¿À. °è¼Ó ¹­¾îµÎ·Á¸é 0À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //½Ã°£ÃÊ ÀÔ·Â
			{
				second = strval(tmp);
				//½Ã°£ÃÊ°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] ½Ã°£À» Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ½Ã°£À» Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
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
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀ» ¹åÁÙ·Î ²Ç²Ç ¹­¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÁ¸®ÁîµÈ ÇÃ·¹ÀÌ¾î¸¦ ´Ù½Ã ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¸¦ ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÁ¸®ÁîµÈ ÇÃ·¹ÀÌ¾î¸¦ ´Ù½Ã ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ¸¦ ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¸¦ ¿òÁ÷ÀÏ ¼ö ÀÖ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
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
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ²Ç²Ç ¹­ÀÎ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ²Ç²Ç ¹­ÀÎ ¹åÁÙÀ» Ç®¾îÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô GTA:SA¿¡ ³»ÀåµÈ À½¾ÇÀ» µé·ÁÁÝ´Ï´Ù." );
			printf( "[help] ÀÌ¸§ÀÌ³ª ¹øÈ£¿¡ *À» ¾²¸é ¸ðµÎ¿¡°Ô ¼Ò¸®¸¦ µé·ÁÁÝ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 1002 : 10¹ø »ç¿ëÀÚ¿¡°Ô ¸Â´Â ¼Ò¸®¸¦ µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 1185 : coolguy¿¡°Ô ¹ÙÀÌÅ© ½ºÄð ¹ÂÁ÷À» µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s * 1187 : ¸ðµÎ¿¡°Ô ºñÇà±â ½ºÄð ¹ÂÁ÷À» µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			print("=================== ÁÖ¿ä ¼Ò¸® ¸ñ·Ï ============================================");
			print("1002 ¸Â´Â¼Ò¸® 1009 Å©·¡½¬ 1130 ÆÝÄ¡¼Ò¸® 1140 Æø¹ß 1187 ºñÇà±â ½ºÅ¬ ¹ÂÁ÷");
			print("1097 ¹è°æ À½¾Ç 1183 µå¶óÀÌºù½ºÄð ¹ÂÁ÷ 1185 ¹ÙÀÌÅ© ½ºÄð ¹ÂÁ÷ ");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô GTA:SA¿¡ ³»ÀåµÈ À½¾ÇÀ» µé·ÁÁÝ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ÀÌ¸§ÀÌ³ª ¹øÈ£¿¡ *À» ¾²¸é ¸ðµÎ¿¡°Ô ¼Ò¸®¸¦ µé·ÁÁÝ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 1002 : 10¹ø »ç¿ëÀÚ¿¡°Ô ¸Â´Â ¼Ò¸®¸¦ µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 1185 : coolguy¿¡°Ô ¹ÙÀÌÅ© ½ºÄð ¹ÂÁ÷À» µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s * 1187 : ¸ðµÎ¿¡°Ô ºñÇà±â ½ºÄð ¹ÂÁ÷À» µé·ÁÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= ÁÖ¿ä ¼Ò¸® ¸ñ·Ï ===============================");
			SendClientMessage(playerid,COLOR_GREY," 1002 ¸Â´Â¼Ò¸® 1009 Å©·¡½¬ 1130 ÆÝÄ¡¼Ò¸® 1140 Æø¹ß 1187 ºñÇà±â ½ºÅ¬ ¹ÂÁ÷");
			SendClientMessage(playerid,COLOR_GREY," 1097 ¹è°æ À½¾Ç 1183 µå¶óÀÌºù½ºÄð ¹ÂÁ÷ 1185 ¹ÙÀÌÅ© ½ºÄð ¹ÂÁ÷ ");
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] µé·ÁÁÙ ¼Ò¸®ÀÇ ¹øÈ£¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* µé·ÁÁÙ ¼Ò¸®ÀÇ ¹øÈ£¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¼Ò¸®¹øÈ£ ÀÔ·Â
			{
				soundid = strval(tmp); //ÀÖ´Â °æ¿ì
				//¼Ò¸®¹øÈ£°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) || soundid <= 0 )
				{
					if( CONSOLE ) print("[rcon] ¼Ò¸®¹øÈ£¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ¼Ò¸®¹øÈ£¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ À½¾ÇÀ» Æ²¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			if(!CONSOLE)
			{
				format(str,sizeof(str),"* ¸ðµÎ¿¡°Ô %d¹ø À½¾ÇÀ» µé·ÁÁá½À´Ï´Ù.", soundid);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµÎ¿¡°Ô %d¹ø À½¾ÇÀ» Àç»ýÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid), playerid, soundid );
				return 1;
			}
			printf("[rcon] %s(%d)´ÔÀÌ ¸ðµÎ¿¡°Ô %d¹ø À½¾ÇÀ» Àç»ýÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, soundid );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[73];
		format(str,sizeof(str),"* %s(%d)´Ô¿¡°Ô %d¹ø À½¾ÇÀ» µé·ÁÁá½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ¿î¿µÀÚ %s(ÀÌ)°¡ À½¾ÇÀ» Æ²¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)´Ô¿¡°Ô %d¹ø À½¾ÇÀ» µé·ÁÁá½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¿¡°Ô µé·ÁÁÖ´ø ¼Ò¸®¸¦ ²ü´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ À½¾ÇÀ» ²°½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ À½¾ÇÀ» ²°½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ À½¾ÇÀ» ²°½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ À½¾ÇÀ» ²°½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )	StopSoundForPlayer( pITT[i] );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[53];
		format(str,sizeof(str),"* %s(%d)´ÔÀÇ À½¾ÇÀ» ²°½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ¿î¿µÀÚ %s(ÀÌ)°¡ À½¾ÇÀ» ²°½À´Ï´Ù.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)´ÔÀÇ À½¾ÇÀ» ²°½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy : coolguy¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy¿¡°Ô Á¦Æ®ÆÑÀ» ÁÝ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if( !ALLOW_JETPACK )
	{
		if(CONSOLE) print("[rcon] ¼­¹ö¿¡¼­ Á¦Æ®ÆÑÀ» Çã¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.");
		else SendClientMessage(playerid, COLOR_GREY,"* ¼­¹ö¿¡¼­ Á¦Æ®ÆÑÀ» Çã¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.");
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.");
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* %s(%d)´Ô¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)´Ô¿¡°Ô Á¦Æ®ÆÑÀ» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î°¡ Ã¤ÆÃÀ» ÇÏÁö ¸øÇÏµµ·Ï ÇÕ´Ï´Ù." );
			print( "[help] [ÃÊ] ¿¡ ÀÔ·ÂÀ» ÇÏ¸é ÇØ´ç ÃÊ¸¸Å­, ÀÔ·ÂÇÏÁö ¾ÊÀ¸¸é °è¼Ó Ã¤ÆÃ±ÝÁö¸¦ ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ¸¦ (Ç®¾îÁÙ ¶§±îÁö) Ã¤ÆÃ±ÝÁö »óÅÂ·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy 30 : coolguy ´ÔÀ» 30ÃÊ°£ Ã¤ÆÃ±ÝÁö »óÅÂ·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] Ã¤ÆÃ ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÖ·Á¸é %s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNSHUT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î°¡ Ã¤ÆÃÀ» ÇÏÁö ¸øÇÏµµ·Ï ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* [ÃÊ] ºÎºÐ¿¡ ÀÔ·ÂÀ» ÇÏ¸é ÇØ´ç ÃÊ¸¸Å­, ÀÔ·ÂÇÏÁö ¾ÊÀ¸¸é °è¼ÓÇØ¼­ Ã¤ÆÃ ±ÝÁö¸¦ ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ÇÃ·¹ÀÌ¾î¸¦ (Ç®¾îÁÙ ¶§±îÁö) Ã¤ÆÃ±ÝÁö »óÅÂ·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 30 : coolguy ´ÔÀ» 30ÃÊ°£  Ã¤ÆÃ±ÝÁö »óÅÂ·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* Ã¤ÆÃ ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÖ·Á¸é /%s ¸í·É¾î¸¦ »ç¿ëÇÏ½Ê½Ã¿À.", GetCmdName(CMD_UNSHUT) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] Ã¤ÆÃÇÏÁö ¸øÇÏ°Ô ÇÒ ½Ã°£À» Á¤ÇÏ½Ê½Ã¿À. °è¼Ó ´ÚÄ¡°Ô ÇÏ·Á¸é 0À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* Ã¤ÆÃÇÏÁö ¸øÇÏ°Ô ÇÒ ½Ã°£À» Á¤ÇÏ½Ê½Ã¿À. °è¼Ó ´ÚÄ¡°Ô ÇÏ·Á¸é 0À» ÀÔ·ÂÇÏ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //½Ã°£ÃÊ ÀÔ·Â
			{
				second = strval(tmp);
				//½Ã°£ÃÊ°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] ½Ã°£À» Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ½Ã°£À» Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = (second > 0)? (second):(-1);
			return 1;
		}
	}

	if( IS_CHAT_FORBIDDEN[giveplayerid] )
	{
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ÀÌ¹Ì Ã¤ÆÃ±ÝÁö »óÅÂÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ÀÌ¹Ì Ã¤ÆÃ±ÝÁö »óÅÂÀÔ´Ï´Ù.");
		return 1;
	}

	new str[89];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ÀÔ¿¡ °É·¹¸¦ ¹°·È½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ Ã¤ÆÃ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÝ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚÀÇ Ã¤ÆÃ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÝ´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy ´ÔÀÇ Ã¤ÆÃ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÝ´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î°¡ Ã¤ÆÃÀ» ÇÏÁö ¸øÇÏµµ·Ï ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚÀÇ Ã¤ÆÃ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÝ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy ´ÔÀÇ Ã¤ÆÃ±ÝÁö »óÅÂ¸¦ Ç®¾îÁÝ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù.");
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = 0;
			return 1;
		}
	}
	
	if(!IS_CHAT_FORBIDDEN[giveplayerid])
	{
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Ã¤ÆÃ±ÝÁö »óÅÂ°¡ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Ã¤ÆÃ±ÝÁö »óÅÂ°¡ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	new str[96];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ÀÔ¿¡ ¹°¸° °É·¹¸¦ »©ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ðÁ¶¸® ¸ô¼öÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø ºÎ¸£Á¶¾ÆÀÇ µ·À» »¯½À´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy ´ÔÀÇ µ·À» ¸ðÁ¶¸® ±¹°í¿¡ È¯¼öÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ðÁ¶¸® ¸ô¼öÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ºÎ¸£Á¶¾ÆÀÇ µ·À» »¯½À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy ´ÔÀÇ µ·À» ¸ðÁ¶¸® ±¹°í¿¡ È¯¼öÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ô¼öÇÏ¿´½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ô¼öÇÏ¿´½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ô¼öÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ µ·À» ¸ô¼öÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerCash( pITT[i] );
			return 1;
		}
	}

	new str[84];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ µ·À» ¸ô¼öÇß½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ µ·À» ¸ô¼öÇß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ±¤¿ª¼ö»ç´ë¿¡¼­ ±Þ½ÀÇÏ¿© °¡Á®°©´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø ¸¶ÇÇ¾ÆÀÇ ¹«±â¸¦ »¯½À´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy ´ÔÀÇ ¹«±â¸¦ ¸ô¼öÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ±¤¿ª¼ö»ç´ë¿¡¼­ ±Þ½ÀÇÏ¿© °¡Á®°©´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ¸¶ÇÇ¾ÆÀÇ ¹«±â¸¦ »¯½À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy ´ÔÀÇ ¹«±â¸¦ ¸ô¼öÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerWeapons( pITT[i] );
			return 1;
		}
	}

	new str[86];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ¹«±â¸¦ ¸ô¼öÇß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô Â÷·®À» Á¦°øÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 522 : 10¹ø »ç¿ëÀÚ¿¡°Ô Â¯±ú ¿Àµµ¹æ±¸¸¦ Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 520 : coolguy¿¡°Ô KF-16À» Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s * 560 : ¸ðµÎ¿¡°Ô »ß±î»·Â½ Â÷·®À» Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print("=================== ÁÖ¿ä Â÷·® ¸ñ·Ï ============================================");
			print("NRG-500 522, Shamal 519, Hydra 520, Hunter 425");
			print("Maverick 497, Rhino 432, Sultan 560");
			print(LINE);

		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô Â÷·®À» Á¦°øÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 522 : 10¹ø »ç¿ëÀÚ¿¡°Ô Â¯±ú ¿Àµµ¹æ±¸¸¦ Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 520 : coolguy¿¡°Ô KF-16À» Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s * 560 : ¸ðµÎ¿¡°Ô »ß±î»·Â½ Â÷·®À» Á¦°øÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= ÁÖ¿ä Â÷·® ¸ñ·Ï ===============================");
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] »ó´ë¹æ¿¡°Ô ÁÙ Â÷·®ÀÇ ¹øÈ£¸¦ ½á ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* »ó´ë¹æ¿¡°Ô ÁÙ Â÷·®ÀÇ ¹øÈ£¸¦ ½á ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //Â÷·® ÀÔ·Â
			{
				model = strval(tmp); //ÀÖ´Â °æ¿ì
				//Â÷·®¹øÈ£°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) || model < 400 || model > 611 )
				{
					if( CONSOLE ) print("[rcon] Â÷·®¹øÈ£¸¦ Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* Â÷·®¹øÈ£¸¦ Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					return 1;
				}		
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", model );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", model);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, model);
			}
			new Float:pos[3],Float:Angle;
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* %s(%d)´Ô¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,model);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´Ô¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, model );
	}
	else printf("[rcon] %s(%d) ´Ô¿¡°Ô %d¹ø Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid, model );	
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½Å¿¡°Ô Â÷·®À» ÁÖ¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));	
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ÁÝ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø ½Ã¹ÎÀ» Á¤Ä¡ÀÎÀ¸·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy´ÔÀ» ±¹È¸·Î º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ÁÝ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ½Ã¹ÎÀ» Á¤Ä¡ÀÎÀ¸·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy´ÔÀ» ±¹È¸·Î º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù." , GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù." , GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			format( str, sizeof(str), "* ÀÚ¼¼ÇÑ µµ¿ò¸»Àº /%s ¹× /%sÀ»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
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
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ÀÌ¹Ì ºÎ¿î¿µÀÚÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ÀÌ¹Ì ºÎ¿î¿µÀÚÀÔ´Ï´Ù.");
		return 1;
	}

	new str[98];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´Ô¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	if( CONSOLE ) printf("[rcon] %s(%d)´Ô¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù.", GetPlayerNameEx(giveplayerid),giveplayerid);
	else printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´Ô¿¡°Ô ÀÓ½Ã °ü¸®±ÇÇÑÀ» ºÎ¿©Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
	format( str, sizeof(str), "* ÀÚ¼¼ÇÑ µµ¿ò¸»Àº /%s ¹× /%sÀ»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø Á¤Ä¡ÀÎÀ» ±¹¹ÎÀÇ ÀÌ¸§À¸·Î ¼ÒÈ¯ÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy´ÔÀ» ºñ¸®ÇøÀÇ·Î ±ô¹æ¿¡ º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø Á¤Ä¡ÀÎÀ» ±¹¹ÎÀÇ ÀÌ¸§À¸·Î ¼ÒÈ¯ÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy´ÔÀ» ºñ¸®ÇøÀÇ·Î ±ô¹æ¿¡ º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç °ü¸®ÀÚÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç °ü¸®ÀÚÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç °ü¸®ÀÚÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç °ü¸®ÀÚÀÇ ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù." , GetPlayerNameEx(playerid));
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
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ºÎ¿î¿µÀÚ°¡ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ºÎ¿î¿µÀÚ°¡ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	new str[91];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ °ü¸®±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ °ü¸®±ÇÇÑÀ» ¹ÚÅ»Çß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®¸³´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚÀÇ ³ú¿¡ ±¸¸ÛÀ» ¼Û¼Û ³À´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy´ÔÀ» Ãµ±¹ º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®¸³´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚÀÇ ³ú¿¡ ±¸¸ÛÀ» ¼Û¼Û ³À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy´ÔÀ» Ãµ±¹ º¸³À´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95], Float:pos[3]; 
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù." , GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* ¿î¿µÀÚ°¡ %s(%d)´ÔÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)´ÔÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
	}	
	else
	{
		format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);	
		printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´ÔÀÇ ³ú¸¦ ÅÍÆ®·È½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÃ·¹ÀÌ¾îÀÇ µ·À» ÁöÁ¤ÇÑ °ªÀ¸·Î ¹Ù²ß´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 10000 : 10¹øÀÇ ¼ÒÁö±ÝÀ» $10000À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy -20 : coolguy¸¦ -$20ÀÇ ºúÀïÀÌ·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÃ·¹ÀÌ¾îÀÇ µ·À» ÁöÁ¤ÇÑ °ªÀ¸·Î ¹Ù²ß´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 10000 : 10¹øÀÇ ¼ÒÁö±ÝÀ» $10000À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy -20 : coolguy¸¦ -$20ÀÇ ºúÀïÀÌ·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» °áÁ¤ÇÏ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» °áÁ¤ÇÏ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //µ· ¾ç ÀÔ·Â
			{
				//µ· ¾çÀÌ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] ¼ÒÁö±ÝÀ» Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ¼ÒÁö±ÝÀ» Á¦´ë·Î ½á ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				money = strval(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¼³Á¤Çß½À´Ï´Ù.", money );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¼³Á¤Çß½À´Ï´Ù.", money );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¼³Á¤Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, money );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½ÅÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¹Ù²Ù¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), money);
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
		format(str,sizeof(str),"* %s(%d)´ÔÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¼³Á¤Çß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ´ç½ÅÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¹Ù²Ù¾ú½À´Ï´Ù.",GetPlayerNameEx(playerid),money);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀÇ ¼ÒÁö±ÝÀ» $%d·Î ¼³Á¤Çß½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µì´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø »ç¿ëÀÚ´Â ÇæÅ©°¡ µË´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy´ÔÀÌ Á¸³ª ½êÁý´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µì´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø »ç¿ëÀÚ´Â ÇæÅ©°¡ µË´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy´ÔÀÌ Á¸³ª ½êÁý´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù." );
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95]; 
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth( pITT[i], 100000.0 );
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)´ÔÀ» ¹«ÀûÀ¸·Î ¸¸µé¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] °øÁö¸¦ ¶ç¿ì°Å³ª ¶ç¿ìÁö ¾Ê½À´Ï´Ù." );
			printf( "[help] ¿¹) %s : °øÁö¸¦ ¼³Á¤ ÆÄÀÏÀÇ ½Ã°£´ë·Î ¶ç¿ì°Å³ª Áß´ÜÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s 30 : °øÁö¸¦ 30ÃÊ¸¶´Ù ¶ç¿ó´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] °øÁöÀÇ ³»¿ëÀ» ¹Ù²Ù·Á¸é %s¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À..", FILE_SETTINGS  );
			printf( "[help] °øÁö ¸ñ·ÏÀº %s ¸í·É¾î¸¦ »ç¿ëÇÏ¿© È®ÀÎÇÏ½Ê½Ã¿À.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* °øÁö¸¦ ¶ç¿ì°Å³ª ¶ç¿ìÁö ¾Ê½À´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : °øÁö¸¦ ¼³Á¤ ÆÄÀÏÀÇ ½Ã°£´ë·Î ¶ç¿ì°Å³ª Áß´ÜÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 30 : °øÁö¸¦ 30ÃÊ¸¶´Ù ¶ç¿ó´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* °øÁöÀÇ ³»¿ëÀ» ¹Ù²Ù·Á¸é %s¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À..", FILE_SETTINGS  ); SEND();
			format( str, sizeof(str), "* °øÁö ¸ñ·ÏÀº %s ¸í·É¾î¸¦ »ç¿ëÇÏ¿© È®ÀÎÇÏ½Ê½Ã¿À.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}

	if(!Num_Notice)
	{
		if(CONSOLE) print("[rcon] °øÁö°¡ ¾ø½À´Ï´Ù. INIÆÄÀÏ¿¡ °øÁöÀ»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.");
		else SendClientMessage(playerid,COLOR_GREY,"* °øÁö°¡ ¾ø½À´Ï´Ù. RconController.ini¿¡ °øÁöÀ»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.");
		return 1;
	}
	if( NOTICE_INTERVAL )
	{
		print("[rcon] °øÁö ¶ç¿ì±â¸¦ Áß´ÜÇÏ¿´½À´Ï´Ù.");
		SendClientMessageToAll(COLOR_GREENYELLOW,"* °øÁö ¶ç¿ì±â¸¦ Áß´ÜÇÏ¿´½À´Ï´Ù.");
		NOTICE_INTERVAL = 0;
		return 1;
	}
	if( isnull(params) ) NOTICE_INTERVAL=c_iniInt("[General]","NOTICE_INTERVAL");
	else if( isNumeric(params) && strval(params) > 0 ) NOTICE_INTERVAL=strval(params);
	else return Usage( playerid, CMD_CURRENT );

	if( NOTICE_INTERVAL < 1 )
	{
		if(CONSOLE) print( "[rcon] ¼³Á¤ ÆÄÀÏ¿¡ °ªÀ» Á¤È®È÷ ÀÔ·ÂÇÏ½Ê½Ã¿À. ´ÜÀ§´Â ÃÊÀÔ´Ï´Ù." );
		else SendClientMessage( playerid, COLOR_GREY,"* ¼³Á¤ ÆÄÀÏ¿¡ °ªÀ» Á¤È®È÷ ÀÔ·ÂÇÏ½Ê½Ã¿À. ´ÜÀ§´Â ÃÊÀÔ´Ï´Ù." );
		return 1;
	}

	new str[46];
	CheckNoticeList();
	printf("[rcon] ÀÌÁ¦ºÎÅÍ °øÁö¸¦ %dÃÊ¸¶´Ù ¶ç¿ó´Ï´Ù.",NOTICE_INTERVAL);
	format(str,sizeof(str),"* ÀÌÁ¦ºÎÅÍ °øÁö¸¦ %dÃÊ¸¶´Ù ¶ç¿ó´Ï´Ù.",NOTICE_INTERVAL);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç »Ñ·ÁÁÖ´Â °øÁöÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÇöÀç »Ñ·ÁÁÖ´Â °øÁöÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] °øÁö¸¦ Ãß°¡ÇÑ µÚ¿£ %s ¸í·É¾î¸¦ »ç¿ëÇÏ¿© ·ÎµåÇÏ½Ê½Ã¿À.", GetCmdName(CMD_RELOADNOTICE)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇöÀç »Ñ·ÁÁÖ´Â °øÁöÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : ÇöÀç »Ñ·ÁÁÖ´Â °øÁöÀÇ ¸ñ·ÏÀ» º¾´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* °øÁö¸¦ Ãß°¡ÇÑ µÚ¿£ %s ¸í·É¾î¸¦ »ç¿ëÇÏ¿© ·ÎµåÇÏ½Ê½Ã¿À.", GetCmdName(CMD_RELOADNOTICE)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}

	if(CONSOLE) print("\n====== Notice List ============================================================");
	else SendClientMessage(playerid,COLOR_GREY,"= Notice List =============================");
	new File:fhnd, str[256], stridx, color;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//°øÁö°¡ ½ÃÀÛµÉ¶§±îÁö ºü¸¥ ½ºÅµ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===°øÁö ½ÃÀÛ===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//ÁÙ ÀÚ¸£°í, ÁÖ¼®°ú ´Ü¼ø¿£ÅÍ´Â ½ºÅµ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//°øÁö°¡ ³¡³­ °æ¿ì ½ºÅ©¸³Æ® ÁßÁö
		if( !strcmp( str, "===°øÁö ³¡===" ) ) break;
		//±¸ºÐ¼±À» ¸¸³ª¸é ±¸ºÐ¼±À» ¸¸µç´Ù
		if( !strcmp( str, "===±¸ºÐ¼±===" ) )
		{
			if( CONSOLE ) print(LINE);
			else SendClientMessage( playerid, COLOR_GREY, LINE_CLIENT);
			continue;
		}
		/* ¸ÖÆ¼¶óÀÎ °øÁö¸¦ ÀÐ´Â´Ù */
		stridx = 0; //±âº»°ª Àû¿ë
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //»ö±ò ÇÚµé·¯ È®ÀÎ
		{
			//°øÁö¶ç¿ï¶§ÀÇ ÀÎµ¦½º ÁöÁ¤
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX°ªÀÇ °æ¿ì Á÷Á¢ ÁöÁ¤
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//¹Ì¸® ¼³Á¤µÈ »ö±ò
			else if ( !strcmp( str[1], "»¡°­" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "ÆÄ¶û" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "¹àÀº ÆÄ¶û" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "³ë¶û" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "ÇÎÅ©" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "¹«ÀûÇÎÅ©" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "³ì»ö" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "¶óÀÓ" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "Èò»ö" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "½Ã½ºÅÛ" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "È¸»ö" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "°¥»ö" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "Ã»·Ï»ö" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "¿À·»Áö" ) ) color = COLOR_ORANGE;
		}
		//°øÁö ¶ç¿ì±â
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¼³Á¤ ÆÄÀÏ¿¡¼­ °øÁö¸¦ ´Ù½Ã ºÒ·¯¿É´Ï´Ù." );
			printf( "[help] ¿¹) %s : ¼³Á¤ ÆÄÀÏ¿¡¼­ °øÁö¸¦ ´Ù½Ã ºÒ·¯¿É´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] °øÁö ¸ñ·ÏÀ» º¸·Á¸é %s ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ¼³Á¤ ÆÄÀÏ¿¡¼­ °øÁö¸¦ ´Ù½Ã ºÒ·¯¿É´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : ¼³Á¤ ÆÄÀÏ¿¡¼­ °øÁö¸¦ ´Ù½Ã ºÒ·¯¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* °øÁö ¸ñ·ÏÀ» º¸·Á¸é %s ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] °øÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	CheckNoticeList();
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* °øÁö¸¦ ´Ù½Ã ºÒ·¯¿Ô½À´Ï´Ù.");
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¼³Á¤ ÆÄÀÏ¿¡¼­ ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ´Ù½Ã ºÒ·¯¿É´Ï´Ù." );
			printf( "[help] ¿¹) %s : ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ´Ù½Ã ºÒ·¯¿É´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ¹Ù²Ù·Á¸é %s¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À..", FILE_SETTINGS );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ¼³Á¤ ÆÄÀÏ¿¡¼­ ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ´Ù½Ã ºÒ·¯¿É´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ´Ù½Ã ºÒ·¯¿É´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ¹Ù²Ù·Á¸é %s¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À..", FILE_SETTINGS ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	LOAD_SUBADMIN = 1;
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* ºÎ¿î¿µÀÚ ¸ñ·ÏÀ» ´Ù½Ã ºÒ·¯¿Ô½À´Ï´Ù.");
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¼­¹ö¸¦ Àá±Ý »óÅÂ·Î ¸¸µé¾î, ´Ù¸¥ ÇÃ·¹ÀÌ¾î°¡ Á¢¼ÓÇÏÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s : Çö½Ã°£ºÎ·Î ¼­¹ö¸¦ Àá±Þ´Ï´Ù.", CURRENT_CMD_NAME );
			print( "[help] Àá±ÝÀ» ÇØÁ¦ÇÏ·Á¸é ´Ù½Ã ÇÑ¹ø ÀÔ·ÂÇÏ½Ê½Ã¿À.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ¼­¹ö¸¦ Àá±Ý »óÅÂ·Î ¸¸µé¾î, ´Ù¸¥ ÇÃ·¹ÀÌ¾î°¡ Á¢¼ÓÇÏÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : Çö½Ã°£ºÎ·Î ¼­¹ö¸¦ Àá±Þ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* Àá±ÝÀ» ÇØÁ¦ÇÏ·Á¸é ´Ù½Ã ÇÑ¹ø ÀÔ·ÂÇÏ½Ê½Ã¿À."); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	SERVER_LOCKED = !SERVER_LOCKED;
	SendClientMessageToAll(COLOR_GREENYELLOW,(SERVER_LOCKED)? ("* ¼­¹ö°¡ Àá°å½À´Ï´Ù. ´õÀÌ»ó Á¢¼ÓÀÌ ºÒ°¡´ÉÇÕ´Ï´Ù."):("* ¼­¹ö Àá±ÝÀÌ ÇØÁ¦µÇ¾ú½À´Ï´Ù."));
	printf("[rcon] %s",(SERVER_LOCKED)? ("¼­¹ö¸¦ Àá±É½À´Ï´Ù. »ç¿ëÀÚ°¡ ´õÀÌ»ó Á¢¼ÓÇÒ ¼ö ¾ø½À´Ï´Ù."):("¼­¹ö Àá±ÝÀ» ÇØÁ¦Çß½À´Ï´Ù. Á¢¼ÓÀÌ Çã¿ëµÇ¾ú½À´Ï´Ù."));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» ´Ù¸¥ °ÍÀ¸·Î º¯°æÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» 0(¸ðµç ±ÇÇÑ) À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 3 : coolguyÀÇ ±ÇÇÑÀ» 3À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ ¸ñ·ÏÀº %s ¸í·É¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.", GetCmdName(CMD_AUTHLIST) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» ´Ù¸¥ °ÍÀ¸·Î º¯°æÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» 0(¸ðµç ±ÇÇÑ) À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 3 : coolguyÀÇ ±ÇÇÑÀ» 3À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ ¸ñ·ÏÀº %s ¸í·É¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.", GetCmdName(CMD_AUTHLIST) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] º¯°æÇÒ ±ÇÇÑÀÇ ¹øÈ£¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* º¯°æÇÒ ±ÇÇÑÀÇ ¹øÈ£¸¦ ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //½ºÄÚ¾î ÀÔ·Â
			{
				//½ºÄÚ¾î°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( !isNumeric(tmp) || strval(tmp) < 0 )
				{
					if( CONSOLE ) print("[rcon] ±ÇÇÑ¹øÈ£¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ±ÇÇÑ¹øÈ£¸¦ Á¦´ë·Î ÀÔ·ÂÇØ ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				authid = strval(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» %s(%d)·Î º¯°æÇÏ¿´½À´Ï´Ù.", (authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"), authid );
			else
			{
				format(str,sizeof(str),"* ¸ðµç ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» %s(%d)·Î º¯°æÇÏ¿´½À´Ï´Ù.", (authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"), authid );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» %s(%d)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, (authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"), authid );
			}
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ºÎ¿î¿µÀÚÀÇ ±ÇÇÑÀ» %s(%d)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), (authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"), authid );
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
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ºÎ¿î¿µÀÚ°¡ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ºÎ¿î¿µÀÚ°¡ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	if(LoadPlayerAuthProfile(giveplayerid,authid))
	{
		new str[202];
		format(str,sizeof(str),"Auth_Profile%d",authid);
		printf("[rcon] ºÎ¿î¿µÀÚ %s(%d)´Ô¿¡°Ô %d¹ø ±ÇÇÑ(%s)À» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"));
		format(str,sizeof(str),"* ºÎ¿î¿µÀÚ %s(%d)´Ô¿¡°Ô %d¹ø ±ÇÇÑ(%s)À» ÁÖ¾ú½À´Ï´Ù.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ¹øÈ£ ¸ñ·ÏÀ» »ìÆìº¾´Ï´Ù." );
			printf( "[help] ¿¹) %s : »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ¹øÈ£ ¸ñ·ÏÀ» »ìÆìº¾´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ¹øÈ£ ¸ñ·ÏÀ» »ìÆìº¾´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : »ç¿ëÇÒ ¼ö ÀÖ´Â ±ÇÇÑ¹øÈ£ ¸ñ·ÏÀ» »ìÆìº¾´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ºÎ¿î¿µÀÚ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}

	if(CONSOLE)
	{
		print("= ºÎ¿î¿µÀÚ ±ÇÇÑ¹øÈ£ ¸ñ·Ï ===========================");
		print("0 : ¸ðµç ±ÇÇÑ(¿î¿µÀÚ¿Í µ¿ÀÏ)");
	}
	else
	{
		SendClientMessage(playerid,COLOR_GREY,"= ºÎ¿î¿µÀÚ ±ÇÇÑ¹øÈ£ ¸ñ·Ï ===========================");
		SendClientMessage(playerid,COLOR_GREY,"0 : ¸ðµç ±ÇÇÑ(¿î¿µÀÚ¿Í µ¿ÀÏ)");
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ¼­¹öÀÇ Áß·ÂÀ» º¯°æÇÕ´Ï´Ù. ±âº»°ªÀº 0.008 ÀÔ´Ï´Ù." );
			printf( "[help] ¿¹) %s -1: ³¯¾Æº¾½Ã´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s 30 : Â÷¿¡ Å¾´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇöÀç ¼­¹öÀÇ Áß·ÂÀ» º¯°æÇÕ´Ï´Ù. ±âº»°ªÀº 0.008 ÀÔ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s -1: ³¯¾Æº¾½Ã´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 30 : Â÷¿¡ Å¾´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] ¹Ù²Ù°í ½ÍÀº Áß·ÂÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* ¹Ù²Ù°í ½ÍÀº Áß·ÂÀ» ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || floatstr(params) < -50.0 || floatstr(params) > 50.0 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] Áß·ÂÀ» Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* Áß·ÂÀ» Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[37];
	format(str,sizeof(str),"* Áß·ÂÀÌ %.3f(À¸)·Î º¯°æµÇ¾ú½À´Ï´Ù.",floatstr(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetGravity(floatstr(params));
	printf("[rcon] Áß·ÂÀÌ %.3f(À¸)·Î º¯°æµÇ¾ú½À´Ï´Ù.",floatstr(params));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ¼­¹öÀÇ ³¯¾¾¸¦ º¯°æÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 0: ¼­¹öÀÇ ³¯¾¾¸¦ 0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s 1337 : ¼­¹öÀÇ ³¯¾¾¸¦ 1337·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇöÀç ¼­¹öÀÇ ³¯¾¾¸¦ º¯°æÇÕ´Ï´Ù. ±âº»°ªÀº 0 ÀÔ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 0: ¼­¹öÀÇ ³¯¾¾¸¦ 0À¸·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 1337 : ¼­¹öÀÇ ³¯¾¾¸¦ 1337·Î ¹Ù²ß´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] ¹Ù²Ù°í ½ÍÀº ³¯¾¾¸¦ ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* ¹Ù²Ù°í ½ÍÀº ³¯¾¾¸¦ ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À. Ãë¼Ò´Â ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 1337 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] ³¯¾¾¸¦ Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* ³¯¾¾¸¦ Á¦´ë·Î ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[30];
	format(str,sizeof(str),"* ³¯¾¾°¡ %d(À¸)·Î º¯°æµÇ¾ú½À´Ï´Ù.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWeather(strval(params));
	printf("[rcon] ³¯¾¾°¡ %d(À¸)·Î º¯°æµÇ¾ú½À´Ï´Ù.",strval(params));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÃ·¹ÀÌ¾î°¡ Å¸°í ÀÖ´Â Â÷·®ÀÇ ¿¡³ÊÁö¸¦ ¼öÁ¤ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 100: 10¹ø »ç¿ëÀÚÀÇ Â÷·®¿¡ ºÒÀ» ºÙÀÔ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s coolguy 800: coolguyÀÇ Â÷·®À» ±×·°Àú·° ±¦ÂúÀº »óÅÂ·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] Â÷·®À» ¿ÏÀüÈ÷ ¼ö¸®ÇÏ·Á¸é %s ¸í·É¾î¸¦ Âü°íÇÏ½Ê½Ã¿À.", GetCmdName(CMD_FIXCAR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÃ·¹ÀÌ¾î°¡ Å¸°í ÀÖ´Â Â÷·®ÀÇ ¿¡³ÊÁö¸¦ ¼öÁ¤ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 10 100: 10¹ø »ç¿ëÀÚÀÇ Â÷·®¿¡ ºÒÀ» ºÙÀÔ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy 800: coolguyÀÇ Â÷·®À» ±×·°Àú·° ±¦ÂúÀº »óÅÂ·Î ¸¸µì´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* Â÷·®À» ¿ÏÀüÈ÷ ¼ö¸®ÇÏ·Á¸é %s ¸í·É¾î¸¦ Âü°íÇÏ½Ê½Ã¿À.", GetCmdName(CMD_FIXCAR) ); SEND();
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
			case 0: //¼ýÀÚ ÀÔ·Â
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ¼³Á¤ÇÒ Â÷·®ÀÇ ¿¡³ÊÁö¸¦ Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ¼³Á¤ÇÒ Â÷·®ÀÇ ¿¡³ÊÁö¸¦ Àû¾î ÁÖ½Ê½Ã¿À.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //¾Æ¸Ó ÀÔ·Â
			{
				//¾Æ¸Ó°¡ Á¦´ë·Î ÀÔ·ÂµÇÁö ¾ÊÀº °æ¿ì
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] Â÷·® ¿¡³ÊÁö¸¦ Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* Â÷·® ¿¡³ÊÁö¸¦ Á¦´ë·Î Àû¾î ÁÖ½Ê½Ã¿À.");
					return 1;
				}
				energy = floatstr(tmp); //ÀÖ´Â °æ¿ì
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //»ç¿ëÀÚ
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
			if( CONSOLE ) printf( "[rcon] ¸ðµç Â÷·®ÀÇ ¿¡³ÊÁö¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", energy );
			else
			{
				format(str,sizeof(str),"* ¸ðµç Â÷·®ÀÇ ¿¡³ÊÁö¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", energy );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç Â÷·®ÀÇ ¿¡³ÊÁö¸¦ %.1f·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, energy);
			}
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç Â÷·®ÀÇ ¿¡³ÊÁö¸¦ %.1fÀ¸·Î º¯°æÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), energy);
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
		SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Â÷·®¿¡ Å¾½ÂÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.");
		return 1;
	}
	
	#if SAMP03x
		if( energy >= 1000.0 ) RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), energy);
	new str[80];
	if( CONSOLE )
	{
		format( str, sizeof(str), "* ¿î¿µÀÚ°¡ ´ç½ÅÀÇ Â÷·® ¿¡³ÊÁö¸¦ %.1f(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)´ÔÀÇ Â÷·® ¿¡³ÊÁö¸¦ %.1f(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)´ÔÀÇ Â÷·® ¿¡³ÊÁö¸¦ %.1f(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* ¿î¿µÀÚ %s(%d)´ÔÀÌ ´ç½ÅÀÇ Â÷·® ¿¡³ÊÁö¸¦ %.1f(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´ÔÀÇ Â÷·® ¿¡³ÊÁö¸¦ %.1f(À¸)·Î º¯°æÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, energy );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 10 : 10¹ø ¿îÀüÀÚÀÇ Â÷·®À» ¼ö¸®ÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  );
			printf( "[help] ¿¹) %s coolguy : coolguy ´ÔÀÇ Â÷¸¦ ½Ø»æÀ¸·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®ÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : 10¹ø ¿îÀüÀÚÀÇ Â÷·®À» ¼ö¸®ÇÕ´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s coolguy : coolguy ´ÔÀÇ Â÷¸¦ ½Ø»æÀ¸·Î ¸¸µì´Ï´Ù.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.");
				printf("[rcon] %s(%d)´ÔÀÌ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ ¸ðµç ÇÃ·¹ÀÌ¾îÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(playerid));
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
		SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Â÷·®¿¡ Å¾½ÂÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.");
		return 1;
	}
	
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), 1000.0);
	#if SAMP03x
		RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	new str[65];
	
	if( CONSOLE )
	{
		format( str, sizeof(str), "* ¿î¿µÀÚ°¡ ´ç½ÅÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)´ÔÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid);
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)´ÔÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* ¿î¿µÀÚ %s(%d)´ÔÀÌ ´ç½ÅÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´ÔÀÇ Â÷·®À» ¼ö¸®Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (FILE_YELLFILTER)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") );
			printf( "[help] ±ÝÁö´Ü¾î Ãß°¡´Â '%s', Á¦°Å´Â '%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (FILE_YELLFILTER)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") ); SEND();
			format( str, sizeof(str), "* ±ÝÁö´Ü¾î Ãß°¡´Â '%s', Á¦°Å´Â '%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	USE_YELLFILTER = !USE_YELLFILTER;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_YELLFILTER? ("* ¿åÇÊÅÍ ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("* ¿åÇÊÅÍ ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
	print((USE_YELLFILTER? ("[rcon] ¿åÇÊÅÍ ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("[rcon] ¿åÇÊÅÍ ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¿åÇÊÅÍ ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] Æ¯Á¤ ´Ü¾î¸¦ ±ÝÁö¾î ¸ñ·Ï¿¡ Ãß°¡ÇÕ´Ï´Ù. ±ÝÁöµÈ ¸»Àº **·Î Ç¥½ÃµË´Ï´Ù." );
			printf( "[help] ¿¹) %s Á¨Àå : 'Á¨Àå' ÀÌ¶ó´Â ¸»À» »ç¿ëÇÏÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¿åÇÊÅÍ ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* Æ¯Á¤ ´Ü¾î¸¦ ±ÝÁö¾î ¸ñ·Ï¿¡ Ãß°¡ÇÕ´Ï´Ù. ±ÝÁöµÈ ¸»Àº **·Î Ç¥½ÃµË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /¿¹) %s Á¨Àå : 'Á¨Àå' ÀÌ¶ó´Â ¸»À» »ç¿ëÇÏÁö ¸øÇÏ°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	new File:fhandle, str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] ÇÊÅÍ¿¡ Ãß°¡ÇÒ ±ÝÁö¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇÊÅÍ¿¡ Ãß°¡ÇÒ ±ÝÁö¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.");
		return 1;
	}
	if(num_Yells == MAX_YELLS)
	{
		if(CONSOLE) print("[rcon] ´õÀÌ»ó ±ÝÁö¾î¸¦ Ãß°¡ÇÏ½Ç ¼ö ¾ø½À´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ´õÀÌ»ó ±ÝÁö¾î¸¦ Ãß°¡ÇÏ½Ç ¼ö ¾ø½À´Ï´Ù.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] ±ÝÁö¾î ±æÀÌ°¡ ³Ê¹« ±é´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ±ÝÁö¾î ±æÀÌ°¡ ³Ê¹« ±é´Ï´Ù.");
		return 1;
	}
	if( IsYellExists(params) )
	{
		if(CONSOLE) print("[rcon] ÀÌ¹Ì Á¸ÀçÇÏ´Â ±ÝÁö¾îÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* ÀÌ¹Ì Á¸ÀçÇÏ´Â ±ÝÁö¾îÀÔ´Ï´Ù.");
		return 1;
	}
	fhandle=fopen(FILE_YELLFILTER,io_append);
	if(!fhandle)
	{
		if(CONSOLE) print("[rcon] ±ÝÁö¾î Ãß°¡¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* ±ÝÁö¾î Ãß°¡¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
		return 1;
	}
	fseek(fhandle,0,seek_end);
	c_fwrite(fhandle,"\r\n");
	c_fwrite(fhandle,params);
	fclose(fhandle);
	set( YELLS[num_Yells], params );
	num_Yells++;
	format(str, sizeof(str),"* ¿î¿µÀÚ %s(ÀÌ)°¡ \"%s\"À»(¸¦) ±ÝÁö¾î·Î ¼³Á¤ÇÏ¿´½À´Ï´Ù.",GetPlayerNameEx(playerid),params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[rcon] »õ·Î¿î ±ÝÁö¾î \"%s\"¸¦ Ãß°¡ÇÏ¿´½À´Ï´Ù.",params);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¿åÇÊÅÍ ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] ±ÝÁö¾î ±¸¹®¿¡¼­ ÇØ´ç ³»¿ëÀ» Á¦°ÅÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s Á¨Àå : 'Á¨Àå' ÀÌ¶ó´Â ¸»ÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¿åÇÊÅÍ ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ±ÝÁö¾î ±¸¹®¿¡¼­ ÇØ´ç ³»¿ëÀ» Á¦°ÅÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s Á¨Àå : 'Á¨Àå' ÀÌ¶ó´Â ¸»ÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿åÇÊÅÍ ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	new File:fohnd,File:fwhnd,bool:dontwrite=false,bool:infile=false,str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] ÇÊÅÍ¿¡¼­ Á¦°ÅÇÒ ±ÝÁö¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.");
		else SendClientMessage(playerid,COLOR_GREY, "* ÇÊÅÍ¿¡¼­ Á¦°ÅÇÒ ±ÝÁö¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À.");
		return 1;
	}
	if(num_Yells==0)
	{
		if(CONSOLE) print("[rcon] ÆÄÀÏ¿¡ Á¦°ÅÇÒ ±ÝÁö¾î°¡ ¾ø½À´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* ÆÄÀÏ¿¡ Á¦°ÅÇÒ ±ÝÁö¾î°¡ ¾ø½À´Ï´Ù.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] ±ÝÁö¾î ±æÀÌ°¡ ³Ê¹« ±é´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* ±ÝÁö¾î ±æÀÌ°¡ ³Ê¹« ±é´Ï´Ù.");
		return 1;
	}
	format( str, sizeof(str), "%s_", FILE_YELLFILTER );
	frename(FILE_YELLFILTER, str );
	fohnd=fopen( str, io_read);
	fwhnd=fopen(FILE_YELLFILTER,io_write);
	if( !fohnd || !fwhnd )
	{
		if(CONSOLE) print("[rcon] ±ÝÁö¾î Á¦°Å¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* ±ÝÁö¾î Á¦°Å¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
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
		if(CONSOLE) print("[rcon] Á¸ÀçÇÏ´Â ±ÝÁö¾î°¡ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY, "* Á¸ÀçÇÏ´Â ±ÝÁö¾î°¡ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}
	LoadYellList();
	format(str,MAX_STRING,"* ¾Ë¸² : \"%s\"Àº(´Â) ´õÀÌ»ó ±ÝÁö¾î°¡ ¾Æ´Õ´Ï´Ù. ",params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[info] ±ÝÁö¾î \"%s\"¸¦ Á¦°ÅÇÏ¿´½À´Ï´Ù.",params);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] µµ¹è¹æÁö ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (USE_ANTI_CHATFLOOD)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") );
			print( "[help] µµ¹è¹æÁö ±â´ÉÀÇ ¼¼ºÎ¼³Á¤Àº RconController.ini¿¡¼­ ¼öÁ¤ÇÏ¼¼¿ä." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* µµ¹è¹æÁö ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );			
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (USE_ANTI_CHATFLOOD)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* µµ¹è¹æÁö ±â´ÉÀÇ ¼¼ºÎ¼³Á¤Àº RconController.ini¿¡¼­ ¼öÁ¤ÇÏ¼¼¿ä." );
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
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_CHATFLOOD? ("* µµ¹è¹æÁö ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("* µµ¹è¹æÁö ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
	print((USE_ANTI_CHATFLOOD? ("[rcon] µµ¹è¹æÁö ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("[rcon] µµ¹è¹æÁö ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (USE_ANTI_WEAPONCHEAT)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") );
			printf( "[help] ±ÝÁöÇÒ ¹«±â¸¦ Ãß°¡ ¹× Á¦°ÅÇÏ·Á¸é '%s' / '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (USE_ANTI_WEAPONCHEAT)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") ); SEND();
			format( str, sizeof(str), "* ±ÝÁöÇÒ ¹«±â¸¦ Ãß°¡ ¹× Á¦°ÅÇÏ·Á¸é '%s' / '%s' ¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_ANTI_WEAPONCHEAT = !USE_ANTI_WEAPONCHEAT;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_WEAPONCHEAT? ("* ¹«±âÇÙ ¹æÁö±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("* ¹«±âÇÙ ¹æÁö±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
	print((USE_ANTI_WEAPONCHEAT? ("[rcon] ¹«±âÇÙ ¹æÁö±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("[rcon] ¹«±âÇÙ ¹æÁö±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¹«±âÇÙ ¹æÁö±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] Æ¯Á¤ ¹«±âÀÇ »ç¿ëÀ» ±ÝÁöÇÕ´Ï´Ù. ¹«±â »ç¿ë½Ã Ãß¹æµË´Ï´Ù." );
			printf( "[help] ¿¹) %s 38: ¹Ì´Ï°ÇÀÇ »ç¿ëÀ» ±ÝÁöÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¹«±â ¹øÈ£´Â 0 ~ %d »çÀÌÀÌ¸ç, ÀÚ¼¼ÇÑ »çÇ×Àº SA-MP Wiki¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", MAX_WEAPONS );
			printf( "[help] ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¹«±âÇÙ ¹æÁö±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* Æ¯Á¤ ¹«±âÀÇ »ç¿ëÀ» ±ÝÁöÇÕ´Ï´Ù. ¹«±â »ç¿ë½Ã Ãß¹æµË´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 38: ¹Ì´Ï°ÇÀÇ »ç¿ëÀ» ±ÝÁöÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¹«±â ¹øÈ£´Â 0 ~ %d »çÀÌÀÌ¸ç, ÀÚ¼¼ÇÑ »çÇ×Àº SA-MP Wiki¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý : ¹«±âÃß°¡ or addweapon [¹«±â¹øÈ£]");
		else SendClientMessage(playerid,COLOR_GREY,"* »ç¿ë¹ý : /¹«±âÃß°¡ or /addweapon [¹«±â¹øÈ£]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] Àß¸øµÈ ¹«±â¹øÈ£ÀÔ´Ï´Ù. ¹«±â¹øÈ£´Â '¹«±â¹øÈ£.txt'¸¦ ÂüÁ¶ÇÏ¼¼¿ä.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸øµÈ ¹«±â¹øÈ£ÀÔ´Ï´Ù. ¹«±â¹øÈ£´Â '¹«±â¹øÈ£.txt'¸¦ ÂüÁ¶ÇÏ¼¼¿ä.");
		return 1;
	}

	new weaponid = strval( params );
	if( IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] ÀÌ¹Ì ±ÝÁöµÇ¾î ÀÖ´Â ¹«±âÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÀÌ¹Ì ±ÝÁöµÇ¾î ÀÖ´Â ¹«±âÀÔ´Ï´Ù.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 1;
	new str[148], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* ¿î¿µÀÚ %s(ÀÌ)°¡ ±ÝÁö¹«±â ¸ñ·Ï¿¡ ¹«±â %s(%d)¸¦ Ãß°¡ÇÏ¿´½À´Ï´Ù. ÇØ´ç ¹«±â »ç¿ë½Ã Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(playerid), weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] ±ÝÁö¹«±â ¸ñ·Ï¿¡ ¹«±â %s(%d)¸¦ Ãß°¡ÇÏ¿´½À´Ï´Ù.",  weapon_name, weaponid );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¹«±âÇÙ ¹æÁö±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] Æ¯Á¤ ¹«±âÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù." );			
			printf( "[help] ¿¹) %s 38: ¹Ì´Ï°ÇÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¹«±â ¹øÈ£´Â 0 ~ %d »çÀÌÀÌ¸ç, ÀÚ¼¼ÇÑ »çÇ×Àº SA-MP Wiki¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", MAX_WEAPONS );
			printf( "[help] ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¹«±âÇÙ ¹æÁö±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* Æ¯Á¤ ¹«±âÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 38: ¹Ì´Ï°ÇÀÇ »ç¿ëÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¹«±â ¹øÈ£´Â 0 ~ %d »çÀÌÀÌ¸ç, ÀÚ¼¼ÇÑ »çÇ×Àº SA-MP Wiki¸¦ ÂüÁ¶ÇÏ¼¼¿ä.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* ¹«±âÇÙ ¹æÁö±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý : ¹«±âÁ¦°Å or delweapon [¹«±â¹øÈ£]");
		else SendClientMessage(playerid,COLOR_GREY,"* »ç¿ë¹ý : /¹«±âÁ¦°Å or /delweapon [¹«±â¹øÈ£]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] Àß¸øµÈ ¹«±â¹øÈ£ÀÔ´Ï´Ù. ¹«±â¹øÈ£´Â '¹«±â¹øÈ£.txt'¸¦ ÂüÁ¶ÇÏ¼¼¿ä.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸øµÈ ¹«±â¹øÈ£ÀÔ´Ï´Ù. ¹«±â¹øÈ£´Â '¹«±â¹øÈ£.txt'¸¦ ÂüÁ¶ÇÏ¼¼¿ä.");
		return 1;
	}

	new weaponid = strval( params );
	if( !IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] ±ÝÁöµÇ¾îÀÖÁö ¾ÊÀº ¹«±âÀÔ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÀÌ¹Ì ±ÝÁöµÇ¾îÀÖÁö ¾ÊÀº ¹«±âÀÔ´Ï´Ù.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 0;
	new str[128], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* ¾Ë¸² : ÀÌÁ¦ ¹«±â %s(%d)¸¦ »ç¿ëÇØµµ Ãß¹æµÇÁö ¾Ê½À´Ï´Ù.", weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] ±ÝÁö¹«±â ¸ñ·Ï¿¡¼­ ¹«±â %s(%d)¸¦ Á¦°ÅÇÏ¿´½À´Ï´Ù.",  weapon_name, weaponid );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Á¦Æ®ÆÑ »ç¿ëÀ» Çã¿ë/ºÒÇã ÇÕ´Ï´Ù." );
			print( "[help] ºÒÇãÇÑ °æ¿ì, Á¦Æ®ÆÑ »ç¿ë½Ã °­Á¦Ãß¹æ ÇÕ´Ï´Ù." );
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (ALLOW_JETPACK)? ("Çã¿ë"):("Çã¿ëÇÏÁö ¾ÊÀ½") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Á¦Æ®ÆÑ »ç¿ëÀ» Çã¿ë/ºÒÇã ÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ºÒÇãÇÑ °æ¿ì, Á¦Æ®ÆÑ »ç¿ë½Ã °­Á¦Ãß¹æ ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (ALLOW_JETPACK)? ("Çã¿ë"):("Çã¿ëÇÏÁö ¾ÊÀ½") ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	ALLOW_JETPACK = !ALLOW_JETPACK;
	SendClientMessageToAll(COLOR_GREENYELLOW,((!ALLOW_JETPACK)? ("* ¾Ë¸² : ÀÌÁ¦ºÎÅÍ Á¦Æ®ÆÑÀ» »ç¿ëÇÏ¸é Ãß¹æµË´Ï´Ù."):("* ¾Ë¸² : ÀÌÁ¦ Á¦Æ®ÆÑÀ» »ç¿ëÇØµµ Ãß¹æµÇÁö ¾Ê½À´Ï´Ù.")));
	print(((!ALLOW_JETPACK)? ("[rcon] Á¦Æ®ÆÑ »ç¿ëÀ» ±ÝÁöÇß½À´Ï´Ù."):("[rcon] Á¦Æ®ÆÑ »ç¿ëÀ» Çã¿ëÇß½À´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¸í·É¾î µµ¹è¹æÁö ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			print( "[help] '/' ·Î ½ÃÀÛÇÏ´Â ¸í·É¾î¸¦ µµ¹èÇÏ¿© ½Ã½ºÅÛ¿¡ ºÎÇÏ¸¦ ÁÖ´Â ¾Ç¼º ÀÎ¿øÀ» Ãß¹æÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );			
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (USE_ANTI_CMDFLOOD)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¸í·É¾î µµ¹è¹æÁö ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* '/' ·Î ½ÃÀÛÇÏ´Â ¸í·É¾î¸¦ µµ¹èÇÏ¿© ½Ã½ºÅÛ¿¡ ºÎÇÏ¸¦ ÁÖ´Â ¾Ç¼º ÀÎ¿øÀ» Ãß¹æÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (USE_ANTI_CMDFLOOD)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") ); SEND();
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
	SendClientMessageToAll(COLOR_GREENYELLOW,((USE_ANTI_CMDFLOOD)? ("* ¸í·É¾îµµ¹è ¹æÁö±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("* ¸í·É¾îµµ¹è ¹æÁö±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.")));
	print(((USE_ANTI_CMDFLOOD)? ("[rcon] ¸í·É¾îµµ¹è ¹æÁö±â´ÉÀ» ½ÃÀÛÇß½À´Ï´Ù."):("[rcon] ¸í·É¾îµµ¹è ¹æÁö±â´ÉÀ» Á¾·áÇß½À´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÎÁ¤¸® ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			print( "[help] ÀÎÅÍ³ÝÀÌ ´À·Á ¿øÈ°ÇÑ ÇÃ·¹ÀÌ¸¦ ÀúÇØÇÏ´Â ÀÎ¿øÀ» °æ°í ¶Ç´Â Ãß¹æÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );			
			printf( "[help] ÇöÀç Á¤Ã¥: %s", (USE_PINGCHECK)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÎÁ¤¸® ±â´ÉÀ» È°¼ºÈ­ / ºñÈ°¼ºÈ­ ÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ÀÎÅÍ³ÝÀÌ ´À·Á ¿øÈ°ÇÑ ÇÃ·¹ÀÌ¸¦ ÀúÇØÇÏ´Â ÀÎ¿øÀ» °æ°í ¶Ç´Â Ãß¹æÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç Á¤Ã¥: %s", (USE_PINGCHECK)? ("»ç¿ë"):("»ç¿ëÇÏÁö ¾ÊÀ½") ); SEND();
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
	SendClientMessageToAll( COLOR_GREENYELLOW, (USE_PINGCHECK)? ("* ÇÎÁ¤¸® ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("* ÇÎÁ¤¸® ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù.") );
	print((USE_PINGCHECK)? ("[rcon] ÇÎÁ¤¸® ±â´ÉÀÌ ½ÃÀÛµÇ¾ú½À´Ï´Ù."):("[rcon] ÇÎÁ¤¸® ±â´ÉÀÌ Á¾·áµÇ¾ú½À´Ï´Ù."));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] ÀÎÅÍ³Ý Áö¿¬½Ã°£ÀÌ ÀÏÁ¤ ÀÌ»óÀÎ °æ¿ì °æ°í ¶Ç´Â Ãß¹æÁ¶Ä¡¸¦ ÇÕ´Ï´Ù." );			
			printf( "[help] ¿¹) %s 200: Áö¿¬½Ã°£ÀÌ 200ms¸¦ ³Ñ¾î°¥ °æ¿ì %dÈ¸ °æ°íÈÄ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT );
			printf( "[help] ÇöÀç °æ°í±âÁØ: %dms", HIGHPING_LIMIT );
			printf( "[help] ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ÀÎÅÍ³Ý Áö¿¬½Ã°£ÀÌ ÀÏÁ¤ ÀÌ»óÀÎ °æ¿ì °æ°í ¶Ç´Â Ãß¹æÁ¶Ä¡¸¦ ÇÕ´Ï´Ù." );	
			format( str, sizeof(str), "* ¿¹) /%s 200: Áö¿¬½Ã°£ÀÌ 200ms¸¦ ³Ñ¾î°¥ °æ¿ì %dÈ¸ °æ°íÈÄ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* ÇöÀç °æ°í±âÁØ: %dms", HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '/%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new ping;
	if( sscanf( params, "i", ping ) || ping < 1 )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý : ÇÎÁ¦ÇÑ or /setplimit [ÇÎ]");
		else SendClientMessage(playerid,COLOR_GREY,"* »ç¿ë¹ý : ÇÎÁ¦ÇÑ or /setplimit [ÇÎ]");
		return 1;
	}
	HIGHPING_LIMIT = ping;
	new str[48];
	format( str, sizeof(str), "* ÇÎÁ¤¸® ±âÁØÀÌ %dms·Î º¯°æµÇ¾ú½À´Ï´Ù.", HIGHPING_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] ÇÎÁ¤¸® ±âÁØÀ» %dms·Î º¯°æÇß½À´Ï´Ù.", HIGHPING_LIMIT );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] ÀÏÁ¤ ÀÌ»ó °æ°í¸¦ ¹ÞÀº ÀÎ¿øÀ» Ãß¹æÇÏ°Ô ÇÕ´Ï´Ù." );			
			printf( "[help] ¿¹) %s 3: Áö¿¬½Ã°£ÀÌ %dms¸¦ ³Ñ¾î°¥ °æ¿ì 3È¸ °æ°íÈÄ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, HIGHPING_LIMIT );
			printf( "[help] ÇöÀç °æ°íÈ½¼ö: %dÈ¸", HIGHPING_WARN_LIMIT );
			printf( "[help] ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ÀÏÁ¤ ÀÌ»ó °æ°í¸¦ ¹ÞÀº ÀÎ¿øÀ» Ãß¹æÇÏ°Ô ÇÕ´Ï´Ù." );		
			format( str, sizeof(str), "* ¿¹) /%s 3: Áö¿¬½Ã°£ÀÌ %dms¸¦ ³Ñ¾î°¥ °æ¿ì 3È¸ °æ°íÈÄ Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* ÇöÀç °æ°íÈ½¼ö: %dÈ¸", HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '/%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new warningtime;
	if( sscanf( params, "i", warningtime ) || warningtime < 1 )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý : ÇÎ°æ°í or /setpwarn [È½¼ö]");
		else SendClientMessage(playerid,COLOR_GREY,"* »ç¿ë¹ý : ÇÎÁ¦ÇÑ or /setpwarn [È½¼ö]");
		return 1;
	}
	HIGHPING_WARN_LIMIT = warningtime;
	new str[56];
	format( str, sizeof(str), "* ÀÌÁ¦ºÎÅÍ ÇÎ ±âÁØÀ» %d¹ø ÃÊ°úÇÏ¸é Ãß¹æµË´Ï´Ù.", HIGHPING_WARN_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] ÇÎ ±âÁØÃÊ°ú °æ°íÈ½¼ö¸¦ %d¹øÀ¸·Î Á¶ÀýÇÏ¿´½À´Ï´Ù.",HIGHPING_WARN_LIMIT );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			print( "[help] ÀÏÁ¤½Ã°£ ÀÌÈÄ ÀÎÅÍ³ÝÀÌ ´À¸° ÇÃ·¹ÀÌ¾îÀÇ ´©Àû°ªÀ» ÃÊ±âÈ­ ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÇöÀç Á¢¼ÓÁßÀÎ ÇÃ·¹ÀÌ¾îÀÇ °æ°í È½¼ö¸¦ ÃÊ±âÈ­ ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s 10 : °æ°í È½¼ö¸¦ ¸Å 10ÃÊ¸¶´Ù ÃÊ±âÈ­ ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s 0 : °æ°í È½¼ö¸¦ ¾ø¾ÖÁö ¾Ê½À´Ï´Ù. ÀÓ°è°ªÀ» ³Ñ¾î°¡¸é ÀÚµ¿À¸·Î Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ÇöÀç ÃÊ±âÈ­ ±âÁØ: %dÃÊ¸¶´Ù ÃÊ±âÈ­(0: ÃÊ±âÈ­ÇÏÁö ¾ÊÀ½).", RESET_HIGHPING_TICK );
			printf( "[help] ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇÎÁ¤¸® ±â´ÉÀÇ ¼¼ºÎ ¼³Á¤ÀÔ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, "* ÀÏÁ¤½Ã°£ ÀÌÈÄ ÀÎÅÍ³ÝÀÌ ´À¸° ÇÃ·¹ÀÌ¾îÀÇ ´©Àû°ªÀ» ÃÊ±âÈ­ ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : ÇöÀç Á¢¼ÓÁßÀÎ ÇÃ·¹ÀÌ¾îÀÇ °æ°í È½¼ö¸¦ ÃÊ±âÈ­ ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 10 : °æ°í È½¼ö¸¦ ¸Å 10ÃÊ¸¶´Ù ÃÊ±âÈ­ ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 0 : °æ°í È½¼ö¸¦ ¾ø¾ÖÁö ¾Ê½À´Ï´Ù. ÀÓ°è°ªÀ» ³Ñ¾î°¡¸é ÀÚµ¿À¸·Î Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ÇöÀç ÃÊ±âÈ­ ±âÁØ: %dÃÊ¸¶´Ù ÃÊ±âÈ­(0: ÃÊ±âÈ­ÇÏÁö ¾ÊÀ½).", RESET_HIGHPING_TICK ); SEND();
			format( str, sizeof(str), "* ÇÎ Á¤¸® ±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ ÇÏ·Á¸é '/%s'¸¦ Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//ÀÔ·ÂÇÏÁö ¾ÊÀº °æ¿ì ´Ü¼ø ÇÎÁ¤¸® ÃÊ±âÈ­
	if( isnull(params) )
	{
		ResetPingCheck( );
		if( CONSOLE ) print("[rcon] Áö¿¬½Ã°£ °æ°íÈ½¼ö¸¦ ÃÊ±âÈ­ ÇÏ¿´½À´Ï´Ù.");
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* Áö¿¬½Ã°£ °æ°íÈ½¼ö¸¦ ÃÊ±âÈ­ ÇÏ¿´½À´Ï´Ù." );
		return 1;
	}
	new resetping_tick;
	if( sscanf( params, "i", resetping_tick ) || resetping_tick < 0 )
	{
		if( CONSOLE ) print("[rcon] »ç¿ë¹ý : ÇÎÃÊ±âÈ­ ¶Ç´Â resetping [½Ã°£=ÃÊ±âÈ­, 0=»ç¿ë¾ÈÇÔ]");
		else SendClientMessage( playerid, COLOR_GREY, "* »ç¿ë¹ý : /ÇÎÃÊ±âÈ­ ¶Ç´Â /resetping [½Ã°£=ÃÊ±âÈ­, 0=»ç¿ë¾ÈÇÔ]" );
		return 1;
	}
	
	RESET_HIGHPING_TICK = resetping_tick;
	new str[80];
	if( !RESET_HIGHPING_TICK )
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÀÌÁ¦ Áö¿¬½Ã°£ °æ°íÈ½¼ö¸¦ ÃÊ±âÈ­ÇÏÁö ¾Ê½À´Ï´Ù." );
		print("[rcon] ÀÌÁ¦ Áö¿¬½Ã°£ °æ°íÈ½¼ö¸¦ ÃÊ±âÈ­ÇÏÁö ¾Ê½À´Ï´Ù." );
	}
	else
	{
		format( str, sizeof(str), "* ÀÌÁ¦ºÎÅÍ %dÃÊ¸¶´Ù ÇÎÁ¤¸® °æ°íÈ½¼ö¸¦ ÃÊ±âÈ­ÇÕ´Ï´Ù.", RESET_HIGHPING_TICK );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] ÇÎÁ¤¸® °æ°íÈ½¼ö ÃÊ±âÈ­ ½Ã°£À» %dÃÊ·Î Á¶ÀýÇÏ¿´½À´Ï´Ù.", RESET_HIGHPING_TICK );
	}	
	//ÇÎÁ¤¸® ÁßÀÌ¾ú´ø °æ¿ì Å¸ÀÌ¸Ó ¸®¼Â
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Â÷·®¿¡ Å¾½ÂÁßÀÎ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦·Î ³»¸®°Ô ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s coolguy : 'coolguy' ¸¦ Â÷¿¡¼­ ³»¸®°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Â÷·®¿¡ Å¾½ÂÁßÀÎ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦·Î ³»¸®°Ô ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy' ¸¦ Â÷¿¡¼­ ³»¸®°Ô ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new giveplayerid;

	if(isnull(params))
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý : /³»¸®±â or /sdrop [ÀÌ¸§ÀÌ³ª ¹øÈ£]");
		else SendClientMessage(playerid, COLOR_GREY, "* »ç¿ë¹ý : /³»¸®±â or /sdrop [ÀÌ¸§ÀÌ³ª ¹øÈ£]");
		return 1;
	}
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	if( !IsPlayerInAnyVehicle( giveplayerid ) )
	{
		if(CONSOLE) print("[rcon] ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Â÷¿¡ Å¸°íÀÖÁö ¾Ê½À´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â Â÷¿¡ Å¸°íÀÖÁö ¾Ê½À´Ï´Ù.");
		return 1;
	}

	RemovePlayerFromVehicle( giveplayerid );

	new str[83];
	format( str, sizeof(str), "* ¿î¿µÀÚ %s(ÀÌ)°¡ %s(%d)´ÔÀ» Â÷¿¡¼­ ³»¸®°Ô Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] %s(%d)´ÔÀ» Â÷·®¿¡¼­ ³»¸®°Ô Çß½À´Ï´Ù.", GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾î¸¦ °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s coolguy : 'coolguy' ¸¦ °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print( "[help] ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇØ´ç ÇÃ·¹ÀÌ¾î¸¦ °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy' ¸¦ °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] ÄÜ¼Ö¿¡¼­ »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
		return 1;
	}
	new giveplayerid;

	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "* »ç¿ë¹ý : /°¨½Ã or /spectate [ÀÌ¸§ÀÌ³ª ¹øÈ£]");
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else return SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");

	new str[83];

	if( IS_PLAYER_SPECTATED[giveplayerid] != INVALID_PLAYER_ID )
	{
		format( str, sizeof(str), "* ÇØ´ç ÇÃ·¹ÀÌ¾î´Â ÀÌ¹Ì %s(%d)´ÔÀÌ °¨½ÃÁßÀÔ´Ï´Ù.", GetPlayerNameEx(IS_PLAYER_SPECTATED[giveplayerid]), IS_PLAYER_SPECTATED[giveplayerid] );
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

	format( str, sizeof(str), "* %s(%d)´ÔÀ» °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù.", GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* ÇØÁ¦ÇÏ½Ã·Á¸é /%s ¶Ç´Â /%s À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.", GetCmdName(CMD_SPECOFF), GetCmdAltName(CMD_SPECOFF) );
	SendClientMessage( playerid, COLOR_ORANGE, str );
	printf("[rcon] %s(%d)´ÔÀÌ %s(%d)´ÔÀ» °¨½ÃÇÏ±â ½ÃÀÛÇß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ÀÛµ¿ÁßÀÎ °¨½Ã¸ðµå¸¦ ÇØÁ¦ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÇöÀç ÀÛµ¿ÁßÀÎ °¨½Ã¸ðµå¸¦ ÇØÁ¦ÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print( "[help] ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇöÀç ÀÛµ¿ÁßÀÎ °¨½Ã¸ðµå¸¦ ÇØÁ¦ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s : ÇöÀç ÀÛµ¿ÁßÀÎ °¨½Ã¸ðµå¸¦ ÇØÁ¦ÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] ÄÜ¼Ö¿¡¼­ »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
		return 1;
	}
	/* if( GetPlayerState( playerid ) != PLAYER_STATE_SPECTATING )
	{
		SendClientMessage( playerid, COLOR_GREY, "* °¨½ÃÁßÀÌ ¾Æ´Õ´Ï´Ù." );
		return 1;
	} */

	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	TogglePlayerSpectating(playerid, 0);
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* °¨½Ã¸ðµå¸¦ ÇØÁ¦Çß½À´Ï´Ù." );
	printf("[rcon] %s(%d)´ÔÀÌ °¨½Ã¸ðµå¸¦ ÇØÁ¦Çß½À´Ï´Ù.", GetPlayerNameEx(playerid), playerid);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Àá¼ö¹æÁö ±â´ÉÀ» ÀÛµ¿/ÇØÁ¦ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 0 : ESCÅ°¸¦ ´­·¯¼­ Àá¼öÇÏ¸é ÀÚµ¿À¸·Î Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s 1 : %dÃÊÀÌ»ó Àá¼öÅ¸´Â °æ¿ì Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, DESYNC_LIMIT );
			printf( "[help] ¿¹) %s 2 : Àá¼ö¸¦ Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print( "[help] Àá¼ö¹æÁö ½Ã°£ ±âÁØÀº RconController.ini¿¡¼­ ¼öÁ¤ÇÏ¼¼¿ä." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Àá¼ö¹æÁö ±â´ÉÀ» ÀÛµ¿/ÇØÁ¦ÇÕ´Ï´Ù." );			
			format( str, sizeof(str), "* ¿¹) /%s 0 : ESCÅ°¸¦ ´­·¯¼­ Àá¼öÇÏ¸é ÀÚµ¿À¸·Î Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 1 : %dÃÊÀÌ»ó Àá¼öÅ¸´Â °æ¿ì Ãß¹æÇÕ´Ï´Ù.", CURRENT_CMD_NAME, DESYNC_LIMIT ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s 2 : Àá¼ö¸¦ Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Àá¼ö¹æÁö ½Ã°£ ±âÁØÀº RconController.ini¿¡¼­ ¼öÁ¤ÇÏ¼¼¿ä." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ÇöÀç Àá¼ö¹æÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù.");
		print("[rcon] Àá¼ö¹æÁö ±â´ÉÀÌ Á¦ÇÑµÇ¾î ÀÖ½À´Ï´Ù. RconController.ini¸¦ ·ÎµåÇØ ÁÖ¼¼¿ä.");
		return 1;
	}
	new desync;
	if( sscanf( params, "i", desync ) || desync < 0 || desync > 2 )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý: Àá¼ö or desync [0 ~ 2]");
		else SendClientMessage( playerid, COLOR_RED, "* »ç¿ë¹ý: /Àá¼ö or /desync [0 ~ 2]");
		return 1;
	}
	ALLOW_DESYNC = desync;
	switch(desync)
	{
		case 0:
		{
			DESYNC_LIMIT = 5;
			SendClientMessageToAll(COLOR_GREENYELLOW, "* ¾Ë¸² : ÀÌÁ¦ºÎÅÍ ESCÅ°¸¦ ´­·¯ Àá¼öÇÏ¸é Ãß¹æµË´Ï´Ù.");
			print("[rcon] Àá¼ö¸¦ ±ÝÁöÇß½À´Ï´Ù.");
		}
		case 1:
		{
			DESYNC_LIMIT = c_iniInt( "[General]", "DESYNC_LIMIT" );
			SendFormatMessageToAll(COLOR_GREENYELLOW, "* ¾Ë¸² : ÀÌÁ¦ºÎÅÍ %dÃÊÀÌ»ó ESCÅ°¸¦ ´­·¯ Àá¼öÇÏ¸é Ãß¹æµË´Ï´Ù.", DESYNC_LIMIT);
			printf("[rcon] Àá¼ö¸¦ %dÃÊ±îÁö¸¸ Çã¿ëÇß½À´Ï´Ù.", DESYNC_LIMIT);
		}
		case 2:
		{
			SendClientMessageToAll(COLOR_GREENYELLOW, "* ¾Ë¸² : ÀÌÁ¦ºÎÅÍ ESCÅ°¸¦ ´­·¯ Àá¼öÇØµµ Ãß¹æµÇÁö ¾Ê½À´Ï´Ù.");
			print("[rcon] Àá¼ö¸¦ Çã¿ëÇß½À´Ï´Ù.");
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ½Ã½ºÅÛ ºñÇÁÀ½À» ¹ß»ýÇÕ´Ï´Ù. (Windows 7ºÎÅÍ´Â ÀÛµ¿ÇÏÁö ¾Ê½À´Ï´Ù.)" );
			printf( "[help] ¿¹) %s 3,°ü¸®ÀÚ´Ô ÇïÇÁ : ºñÇÁÀ½À» 3È¸ ¹ß»ýÇÏ¸ç, '°ü¸®ÀÚ´Ô ÇïÇÁ' ¶ó´Â ¸Þ¼¼Áö¸¦ ¶ç¿ó´Ï´Ù.", CURRENT_CMD_NAME );			
			printf( "[help] °ü¸®ÀÚ¿¡°Ô °³ÀÎ ¸Þ¼¼Áö¸¦ º¸³»·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_SPM) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ½Ã½ºÅÛ ºñÇÁÀ½À» ¹ß»ýÇÕ´Ï´Ù. (Windows 7ºÎÅÍ´Â ÀÛµ¿ÇÏÁö ¾Ê½À´Ï´Ù.)" );
			format( str, sizeof(str), "* ¿¹) /%s 3,°ü¸®ÀÚ´Ô ÇïÇÁ : ºñÇÁÀ½À» 3È¸ ¹ß»ýÇÏ¸ç, '°ü¸®ÀÚ´Ô ÇïÇÁ' ¶ó´Â ¸Þ¼¼Áö¸¦ ¶ç¿ó´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* °ü¸®ÀÚ¿¡°Ô °³ÀÎ ¸Þ¼¼Áö¸¦ º¸³»·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_SPM) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new str[128], itteration;
	if( sscanf(params, "p,is", itteration, str) || itteration < 0 )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý: ¼Ò¸®³»±â or mks [ºñÇÁÀ½ È½¼ö],[ÇÒ¸»] - ¶ç¾î¾²±â ´ë½Å ÄÄ¸¶·Î ±¸ºÐÇØÁÖ¼¼¿ä.");
		else SendClientMessage( playerid, COLOR_GREY, "* »ç¿ë¹ý: /¼Ò¸®³»±â or /mks [ºñÇÁÀ½ È½¼ö],[ÇÒ¸»] - ¶ç¾î¾²±â ´ë½Å ÄÄ¸¶·Î ±¸ºÐÇØÁÖ¼¼¿ä.");
		return 1;
	}
	if( itteration > 5 )
	{
		if(CONSOLE) print("[rcon] ºñÇÁÀ½Àº 5È¸±îÁö¸¸ ¼³Á¤ °¡´ÉÇÕ´Ï´Ù.");
		else SendClientMessage( playerid, COLOR_GREY, "* ºñÇÁÀ½Àº 5È¸±îÁö¸¸ ¼³Á¤ °¡´ÉÇÕ´Ï´Ù.");
		return 1;
	}
	if (CONSOLE) printf("[call] ÄÜ¼Ö·ÎºÎÅÍ ¿î¿µÀÚ È£ÃâÀÔ´Ï´Ù. : %s", str);
	else printf("[call] ¿î¿µÀÚ %s(%d)ÀÇ È£ÃâÀÔ´Ï´Ù: %s", GetPlayerNameEx(playerid), playerid, str);
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] RconController.ini¿¡ ÀúÀåµÈ ¼­¹ö ¼³Á¤À» ´Ù½Ã ÀÐ¾î¿É´Ï´Ù." );
			printf( "[help] ÇöÀç ¼³Á¤À» ÆÄÀÏ·Î ÀúÀåÇÏ·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_SAVECONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* RconController.ini¿¡ ÀúÀåµÈ ¼­¹ö ¼³Á¤À» ´Ù½Ã ÀÐ¾î¿É´Ï´Ù." );
			format( str, sizeof(str), "* ÇöÀç ¼³Á¤À» ÆÄÀÏ·Î ÀúÀåÇÏ·Á¸é '/%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_SAVECONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ¼³Á¤ ºÎ¸£±â¸¦ »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
		print("[rcon] RconController.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ¼³Á¤ ºÎ¸£±â¸¦ »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
		return 1;
	}
	LoadUserConfigs(1);
	SendClientMessageToAll( COLOR_GREENYELLOW, "* ¼­¹öÀÇ Á¤Ã¥ÀÌ º¯°æµÇ¾ú½À´Ï´Ù." );
	print("[rcon] ¼­¹öÀÇ ¼³Á¤À» ´Ù½Ã ºÒ·¯¿Ô½À´Ï´Ù.");
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ¼­¹öÀÇ ÇöÀç Á¤Ã¥À» RconController.ini¿¡ ÀúÀåÇÕ´Ï´Ù." );
			printf( "[help] ¼­¹öÀÇ ¼³Á¤À» ÆÄÀÏ·ÎºÎÅÍ ÀÐ¾î¿À·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_LOADCONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¼­¹öÀÇ ÇöÀç Á¤Ã¥À» RconController.ini¿¡ ÀúÀåÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¼­¹öÀÇ ¼³Á¤À» ÆÄÀÏ·ÎºÎÅÍ ÀÐ¾î¿À·Á¸é '/%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_LOADCONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ¼³Á¤ ÀúÀå±â´ÉÀ» »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
		print("[rcon] RconController.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ¼³Á¤ ÀúÀå±â´ÉÀ» »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
		return 1;
	}
	SaveUserConfigs( );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÇöÀç ¼­¹öÀÇ Á¤Ã¥À» ÀúÀåÇß½À´Ï´Ù." );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ¾ÆÀÌµð·Î °É¸° ¹êÀ» ÇØÁ¦ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s coolguy : 'coolguy'°¡ Á¢¼ÓÇÏ´Â °ÍÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] IP¸¦ »ç¿ëÇÏ¿© ¹êÀ» Ç®·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_UNBANIP) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇØ´ç ÇÃ·¹ÀÌ¾îÀÇ ¾ÆÀÌµð·Î °É¸° ¹êÀ» ÇØÁ¦ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy'°¡ Á¢¼ÓÇÏ´Â °ÍÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* IP¸¦ »ç¿ëÇÏ¿© ¹êÀ» Ç®·Á¸é '/%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_UNBANIP) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || strlen(params) >= MAX_PLAYER_NAME )
	{
		if(CONSOLE) printf("[rcon] »ç¿ë¹ý: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
		else
		{
			new str[128];
			format(str, sizeof(str), "* »ç¿ë¹ý: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND_C(COLOR_RED);
		}
		return 1;
	}

	new str[50];
	format( str, sizeof(str), "unban %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* %s´ÔÀ» ¹ê¸ñ·Ï¿¡¼­ Á¦°ÅÇß½À´Ï´Ù.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] %s´ÔÀ» ¹ê¸ñ·Ï¿¡¼­ Á¦°ÅÇß½À´Ï´Ù.", params );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇØ´ç IP¿¡ °É¸° ¹êÀ» ÇØÁ¦ÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s 192.168.0.1 : ÇØ´ç IPÀÇ À¯Àú°¡ Á¢¼ÓÇÏ´Â °ÍÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¾ÆÀÌµð¸¦ »ç¿ëÇÏ¿© ¹êÀ» Ç®·Á¸é '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ÇØ´ç IP¿¡ °É¸° ¹êÀ» ÇØÁ¦ÇÕ´Ï´Ù." );
			format( str, sizeof(str), "* ¿¹) /%s 192.168.0.1 : ÇØ´ç IPÀÇ À¯Àú°¡ Á¢¼ÓÇÏ´Â °ÍÀ» Çã¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ¾ÆÀÌµð¸¦ »ç¿ëÇÏ¿© ¹êÀ» Ç®·Á¸é '/%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", GetCmdName(CMD_UNBAN) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] »ç¿ë¹ý: ¾ÆÀÌÇÇ¹êÇ®±â or unbanip [¾ÆÀÌµð]");
		else SendClientMessage( playerid, COLOR_GREY, "* »ç¿ë¹ý: /¾ÆÀÌÇÇ¹êÇ®±â or /unbanip [¾ÆÀÌµð]");
		return 1;
	}
	if( !IsValidIP(params) )
	{
		if(CONSOLE) print("[rcon] ¾ÆÀÌÇÇ¸¦ Á¦´ë·Î ÀÔ·ÂÇÏ¼¼¿ä.");
		else SendClientMessage( playerid, COLOR_ORANGE, "* ¾ÆÀÌÇÇ¸¦ Á¦´ë·Î ÀÔ·ÂÇÏ¼¼¿ä.");
		return 1;
	}

	new str[59];
	format( str, sizeof(str), "unbanip %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* ¾ÆÀÌÇÇ %sÀ»(¸¦) ¹ê¸ñ·Ï¿¡¼­ Á¦°ÅÇß½À´Ï´Ù.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] ¾ÆÀÌÇÇ %sÀ»(¸¦) ¹ê¸ñ·Ï¿¡¼­ Á¦°ÅÇß½À´Ï´Ù.", params );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
			print( "[help] '»ç¿ë' / '»ç¿ë¾ÈÇÔ' À¸·Î °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ÇÒ ¼ö ÀÖ½À´Ï´Ù." );
			print( "[help] 'Áß´Ü' À¸·Î ÁøÇàÁßÀÎ ÅõÇ¥¸¦ Áß´ÜÇÒ ¼ö ÀÖ½À´Ï´Ù." );
			printf( "[help] ¿¹) %s »ç¿ë : °­Á¦Ãß¹æ ±â´ÉÀ» »ç¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s »ç¿ë¾ÈÇÔ : °­Á¦Ãß¹æ ±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.", CURRENT_CMD_NAME );			
			printf( "[help] ¿¹) %s coolguy : 'coolguy'¸¦ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s Áß´Ü : ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ÅõÇ¥ ¾øÀÌ °­Á¦Ãß¹æÀº '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", cmdlist[CMD_KICK][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
				SendClientMessage( playerid, COLOR_LIME, "* '»ç¿ë' / '»ç¿ë¾ÈÇÔ' À¸·Î °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ÇÒ ¼ö ÀÖ½À´Ï´Ù." );
				SendClientMessage( playerid, COLOR_LIME, "* 'Áß´Ü' À¸·Î ÁøÇàÁßÀÎ ÅõÇ¥¸¦ Áß´ÜÇÒ ¼ö ÀÖ½À´Ï´Ù." );
				format( str, sizeof(str), "* ¿¹) /%s »ç¿ë : °­Á¦Ãß¹æ ±â´ÉÀ» »ç¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s »ç¿ë¾ÈÇÔ : °­Á¦Ãß¹æ ±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy'¸¦ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s Áß´Ü : ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ÅõÇ¥ ¾øÀÌ °­Á¦Ãß¹æÀº '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", cmdlist[CMD_KICK][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ °­Á¦Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
				format( str, sizeof(str), "* ¿¹) /%s 1 : 1¹ø ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy'¸¦ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÅõÇ¥´Â ÀÏÁ¤ ÀÌ»ó »ç¶÷ÀÌ ÀÖ¾î¾ß °¡´ÉÇÏ¸ç, ÅõÇ¥±â´ÉÀÌ ºñÈ°¼ºÈ­µÈ °æ¿ì ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new str[128], giveplayerid;
	
	//°ü¸® ¸í·É¾î. ÀÔ·ÂÀÚ°¡ ¿î¿µÀÚÀÎ °æ¿ì °ü¸®¸í·É¾î ÀÔ·Â¿©ºÎ È®ÀÎ
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //ÅõÇ¥ È°¼ºÈ­ ¿äÃ»
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "»ç¿ë", true ) == 0 ) //Ãß¹æÅõÇ¥ ±â´É »ç¿ë
		{
			if( ENABLE_VOTEKICK ) //ÀÌ¹Ì ±â´ÉÀÌ È°¼ºÈ­µÈ °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] ÀÌ¹Ì °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÁßÀÔ´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ÀÌ¹Ì °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÁßÀÔ´Ï´Ù.");
			    return 1;
			}
	    	ENABLE_VOTEKICK = 1;

	    	print("[rcon] °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» ½ÃÀÛÇÏ¿´½À´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %s(ÀÌ)°¡ °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» ½ÃÀÛÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//ÅõÇ¥ Áß´Ü ¿äÃ»
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "Áß´Ü", true ) == 0 ) // ÅõÇ¥Áß´Ü ¿äÃ»
		{
		    if( VOTEKICK_REMAINTIME <= 0 ) //ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø´Â °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] ÇöÀç ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ÇöÀç ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			    return 1;
			}
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %sÀÇ ¿äÃ»À¸·Î ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//ÅõÇ¥ ºñÈ°¼ºÈ­ ¿äÃ»
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "»ç¿ë¾ÈÇÔ", true ) == 0 ) // ÅõÇ¥ ºñÈ°¼ºÈ­ ¿äÃ»
		{
			if( !ENABLE_VOTEKICK ) //ÀÌ¹Ì ±â´ÉÀÌ ºñÈ°¼ºÈ­µÈ °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê°í ÀÖ½À´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê°í ÀÖ½À´Ï´Ù.");
			    return 1;
			}
			if ( VOTEKICK_REMAINTIME )
			{
				print("[rcon] ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.");
				format( str, sizeof(str), "* ¿î¿µÀÚ %sÀÇ ¿äÃ»À¸·Î ÁøÇàÁßÀÎ °­Á¦Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEKICK = 0;
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» Á¾·áÇÏ¿´½À´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %s(ÀÌ)°¡ °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» Á¾·áÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê´Â°æ¿ì ¸Þ¼¼Áö ¶ç¿ò
	if( !ENABLE_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] ÇöÀç °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.\n[rcon] »ç¿ëÇÏ½Ã·Á¸é '%s »ç¿ë'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME);
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ÇöÀç °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù. »ç¿ëÇÏ½Ã·Á¸é '/%s »ç¿ë'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÇöÀç °­Á¦Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù. ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä.");
		return 1;
	}

	//ÀÏ¹Ý ÅõÇ¥¸ðµå
	if( params[0] ) //¹«¾ð°¡ ÀÔ·ÂÇßÀ½.
	{
	    //ÅõÇ¥¸¦ ½ÃµµÇÑ °æ¿ì
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "¿¹", true ) == 0 ) // ÅõÇ¥ÇÏ±â
		{
			if( VOTEKICK_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] °­Á¦Ãß¹æ ÅõÇ¥ÁßÀÌ ¾Æ´Õ´Ï´Ù.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* °­Á¦Ãß¹æ ÅõÇ¥ÁßÀÌ ¾Æ´Õ´Ï´Ù.");
				return 1;
			}

			if( CONSOLE )
			{
				print("[rcon] ÄÜ¼Ö¿¡¼­´Â ÅõÇ¥ÇÏ½Ç ¼ö ¾ø½À´Ï´Ù.");
				return 1;
			}
			
			//ÅõÇ¥¿©ºÎ °Ë»ç
			new i;
			for( i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
			{
				if( KICKVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //ÀÌ¹Ì ÅõÇ¥ÇÏ¿´À½
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* ÀÌ¹Ì ÅõÇ¥ÇÏ¿´½À´Ï´Ù.");
					return 1;
				}
			}
			//ÅõÇ¥ÇÏ±â
			SendClientMessage( playerid, COLOR_GREEN, "* ÅõÇ¥ÇÏ¼Ì½À´Ï´Ù.");
			KICKVOTED_PLAYER_IP[VOTEKICK_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEKICK_PLAYER_GOT++;
			if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // Ãß¹æ±âÁØ Åë°ú
			{
				format( str, sizeof(str), "* ÅõÇ¥°¡ Á¾·áµÇ¾ú½À´Ï´Ù. ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» °­Á¦ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» °­Á¦ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				VOTEKICK_REMAINTIME = 0;
				c_Kick( VOTEKICK_PLAYER );
			}
			return 1;
		}
		//ÅõÇ¥°¡ ÁøÇàÁßÀÎ °æ¿ì
		if( VOTEKICK_REMAINTIME > 0 )
		{			
			if( CONSOLE ) print("[rcon] ÁøÇàÁßÀÎ ÅõÇ¥°¡ ÀÖ½À´Ï´Ù.");
			else SendClientMessage( playerid, COLOR_GREY, "* ÁøÇàÁßÀÎ ÅõÇ¥°¡ ÀÖ½À´Ï´Ù.");
		}
	}
	
	if( VOTEKICK_REMAINTIME > 0 ) //ÇöÀç ÅõÇ¥°¡ ÁøÇàÁß
	{
		if( CONSOLE )
		{
			printf("[rcon] ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
			printf("[rcon] ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
			printf("[rcon] Áß´ÜÇÏ½Ã·Á¸é '%s Áß´Ü'À», ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '%s »ç¿ë¾ÈÇÔ' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME, CURRENT_CMD_NAME);
			return 1;
		}
		format( str, sizeof(str), "* ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), " ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), "* ÅõÇ¥ÇÏ½Ã·Á¸é '/%s yes' ¶Ç´Â '/%s ¿¹' ¸¦ ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_SALMON); SEND_C(COLOR_GREENYELLOW);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* Áß´ÜÇÏ½Ã·Á¸é '/%s Áß´Ü'À», ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '/%s »ç¿ë¾ÈÇÔ' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥ ¾øÀ½. ÅõÇ¥ÀÛ¼º ½Ãµµ°¡ ¾ø¾úÀ½.
	{
		if( CONSOLE )
		{
			print("[rcon] ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			printf("[rcon] »ç¿ë¹ý: %s or %s [ÀÌ¸§ÀÌ³ª ¹øÈ£]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '%s »ç¿ë¾ÈÇÔ'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
        format( str, sizeof(str),  "* »ç¿ë¹ý: /%s ¶Ç´Â /%s [ÀÌ¸§ÀÌ³ª ¹øÈ£]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '/%s »ç¿ë¾ÈÇÔ'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//ÅõÇ¥ ½ÃÀÛÇÏ±â
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}
	
	//ÃÖ¼ÒÀÎ¿ø¿¡ ¹Ì´ÞÇÏ´Â°æ¿ì
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] ÅõÇ¥¸¦ ½ÃÀÛÇÏ·Á¸é ÃÖ¼Ò %d¸íÀÇ ÇÃ·¹ÀÌ¾î°¡ ÇÊ¿äÇÕ´Ï´Ù.", REQUIRED_MAN_VOTEKICK );
	    else
		{
			format( str, sizeof(str), "* ÅõÇ¥¸¦ ½ÃÀÛÇÏ·Á¸é ÃÖ¼Ò %d¸íÀÇ ÇÃ·¹ÀÌ¾î°¡ ÇÊ¿äÇÕ´Ï´Ù.", REQUIRED_MAN_VOTEKICK ); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//OK.Assign Player Informations.
	VOTEKICK_PLAYER = giveplayerid;
	VOTEKICK_PLAYER_GOT = 0;
	VOTEKICK_TICK = 0;
	VOTEKICK_REMAINTIME = VOTEKICK_RUN_TIME;
	CURRENT_VOTEKICK_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEKICK_PERCENTAGE) / 100;
	
	//½Å°íÀÚ ºñ¹Ðº¸ÀåÀÇ °æ¿ì ±â¹Ð, ¾Æ´Ñ°æ¿ì ÀÌ¸§ ¼öÁý
	if( VOTE_CONFIDENTIALITY ) str = "±â¹Ð";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("¼­¹öÁÖÀÎ"):(GetPlayerNameEx(playerid)) );
	//ÅõÇ¥ ¸Þ¼¼Áö ¶ç¿ì±â
	format( str, sizeof(str), "* %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æ ÅõÇ¥°¡ ½ÅÃ»µÇ¾ú½À´Ï´Ù. (½ÅÃ»ÀÎ: %s)",
		GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, str );
    SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* ÅõÇ¥´Â ÃÑ %dÃÊ°£ ÁøÇàµÇ¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", VOTEKICK_RUN_TIME, CURRENT_VOTEKICK_REQUIREMENT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* ÅõÇ¥ÇÏ½Ã·Á¸é '/%s yes' ¶Ç´Â '/%s ¿¹' ¸¦ ÀÔ·ÂÇÏ½Ã¸é µË´Ï´Ù.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* ÀÚ, Áö±ÝºÎÅÍ ÅõÇ¥¸¦ ½ÃÀÛÇÕ´Ï´Ù!" );
	printf("[rcon] %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æ ÅõÇ¥°¡ ½ÅÃ»µÇ¾ú½À´Ï´Ù. (½ÅÃ»ÀÎ: %s, ½Å¿øº¸È£:%s)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, (playerid==ADMIN_ID)? ("¼­¹öÁÖÀÎ"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("¿¹"):("¾Æ´Ï¿À") );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸È÷ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
			print( "[help] '»ç¿ë' / '»ç¿ë¾ÈÇÔ' À¸·Î ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ÇÒ ¼ö ÀÖ½À´Ï´Ù." );
			print( "[help] 'Áß´Ü' À¸·Î ÁøÇàÁßÀÎ ÅõÇ¥¸¦ Áß´ÜÇÒ ¼ö ÀÖ½À´Ï´Ù." );
			printf( "[help] ¿¹) %s »ç¿ë : ¿µ±¸Ãß¹æ ±â´ÉÀ» »ç¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s »ç¿ë¾ÈÇÔ : ¿µ±¸Ãß¹æ ±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.", CURRENT_CMD_NAME );			
			printf( "[help] ¿¹) %s coolguy : 'coolguy'¸¦ ¿µ±¸Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¿¹) %s Áß´Ü : ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ÅõÇ¥ ¾øÀÌ ¿µ±¸Ãß¹æÀº '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", cmdlist[CMD_BAN][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸È÷ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
				SendClientMessage( playerid, COLOR_LIME, "* '»ç¿ë' / '»ç¿ë¾ÈÇÔ' À¸·Î ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» È°¼ºÈ­/ºñÈ°¼ºÈ­ÇÒ ¼ö ÀÖ½À´Ï´Ù." );
				SendClientMessage( playerid, COLOR_LIME, "* 'Áß´Ü' À¸·Î ÁøÇàÁßÀÎ ÅõÇ¥¸¦ Áß´ÜÇÒ ¼ö ÀÖ½À´Ï´Ù." );
				format( str, sizeof(str), "* ¿¹) /%s »ç¿ë : ¿µ±¸Ãß¹æ ±â´ÉÀ» »ç¿ëÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s »ç¿ë¾ÈÇÔ : ¿µ±¸Ãß¹æ ±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy'¸¦ ¿µ±¸Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s Áß´Ü : ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ÅõÇ¥ ¾øÀÌ ¿µ±¸Ãß¹æÀº '%s'À»(¸¦) Âü°íÇÏ¼¼¿ä.", cmdlist[CMD_BAN][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÁöÁ¤ÇÑ ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸È÷ Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù." );
				format( str, sizeof(str), "* ¿¹) /%s 1 : 1¹ø ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ¿¹) /%s coolguy : 'coolguy'¸¦ ¿µ±¸Ãß¹æÇÏ´Â ÅõÇ¥¸¦ °³½ÃÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ÅõÇ¥´Â ÀÏÁ¤ ÀÌ»ó »ç¶÷ÀÌ ÀÖ¾î¾ß °¡´ÉÇÏ¸ç, ÅõÇ¥±â´ÉÀÌ ºñÈ°¼ºÈ­µÈ °æ¿ì ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new str[128], giveplayerid;

	//°ü¸® ¸í·É¾î. ÀÔ·ÂÀÚ°¡ ¿î¿µÀÚÀÎ °æ¿ì °ü¸®¸í·É¾î ÀÔ·Â¿©ºÎ È®ÀÎ
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //ÅõÇ¥ È°¼ºÈ­ ¿äÃ»
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "»ç¿ë", true ) == 0 ) //Ãß¹æÅõÇ¥ ±â´É »ç¿ë
		{
			if( ENABLE_VOTEBAN ) //ÀÌ¹Ì ±â´ÉÀÌ È°¼ºÈ­µÈ °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] ÀÌ¹Ì ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÁßÀÔ´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ÀÌ¹Ì ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÁßÀÔ´Ï´Ù.");
			    return 1;
			}
	    	ENABLE_VOTEBAN = 1;

	    	print("[rcon] ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» ½ÃÀÛÇÏ¿´½À´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %s°¡ ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» ½ÃÀÛÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//ÅõÇ¥ Áß´Ü ¿äÃ»
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "Áß´Ü", true ) == 0 ) // ÅõÇ¥Áß´Ü ¿äÃ»
		{
		    if( VOTEBAN_REMAINTIME <= 0 ) //ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø´Â °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] ÇöÀç ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ÇöÀç ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			    return 1;
			}
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %sÀÇ ¿äÃ»À¸·Î ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//ÅõÇ¥ ºñÈ°¼ºÈ­ ¿äÃ»
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "»ç¿ë¾ÈÇÔ", true ) == 0 ) // ÅõÇ¥ ºñÈ°¼ºÈ­ ¿äÃ»
		{
			if( !ENABLE_VOTEBAN ) //ÀÌ¹Ì ±â´ÉÀÌ ºñÈ°¼ºÈ­µÈ °æ¿ì
			{
			    if( CONSOLE ) print("[rcon] ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê°í ÀÖ½À´Ï´Ù.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê°í ÀÖ½À´Ï´Ù.");
			    return 1;
			}
			if( VOTEBAN_REMAINTIME )
			{
				print("[rcon] ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.");
				format( str, sizeof(str), "* ¿î¿µÀÚ %sÀÇ ¿äÃ»À¸·Î ÁøÇàÁßÀÎ ¿µ±¸Ãß¹æ ÅõÇ¥¸¦ Áß´ÜÇÕ´Ï´Ù.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEBAN = 0;
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» Á¾·áÇÏ¿´½À´Ï´Ù.");
			format( str, sizeof(str), "* ¿î¿µÀÚ %s°¡ ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» Á¾·áÇÏ¿´½À´Ï´Ù.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏÁö ¾Ê´Â°æ¿ì ¸Þ¼¼Áö ¶ç¿ò
	if( !ENABLE_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] ÇöÀç ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù.\n[rcon] »ç¿ëÇÏ½Ã·Á¸é '%s »ç¿ë' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME );
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str),  "* ÇöÀç ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù. »ç¿ëÇÏ½Ã·Á¸é '/%s »ç¿ë' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÇöÀç ¿µ±¸Ãß¹æ ÅõÇ¥±â´ÉÀ» »ç¿ëÇÏ°í ÀÖÁö ¾Ê½À´Ï´Ù. ¿î¿µÀÚ¿¡°Ô ¹®ÀÇÇÏ¼¼¿ä.");
		return 1;
	}

	//ÀÏ¹Ý ÅõÇ¥¸ðµå
	if( params[0] ) //¹«¾ð°¡ ÀÔ·ÂÇßÀ½.
	{
	    //ÅõÇ¥¸¦ ½ÃµµÇÑ °æ¿ì
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "¿¹", true ) == 0 ) // ÅõÇ¥ÇÏ±â
		{
			if( VOTEBAN_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] ¿µ±¸Ãß¹æ ÅõÇ¥ÁßÀÌ ¾Æ´Õ´Ï´Ù.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* ¿µ±¸Ãß¹æ ÅõÇ¥ÁßÀÌ ¾Æ´Õ´Ï´Ù.");
				return 1;
			}
			
			if( CONSOLE )
			{
				print("[rcon] ÄÜ¼Ö¿¡¼­´Â ÅõÇ¥ÇÏ½Ç ¼ö ¾ø½À´Ï´Ù.");
				return 1;
			}

			//ÅõÇ¥¿©ºÎ °Ë»ç
			new i;
			for( i = 0; i < VOTEBAN_PLAYER_GOT; i++ )
			{
				if( BANVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //ÀÌ¹Ì ÅõÇ¥ÇÏ¿´À½
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* ÀÌ¹Ì ÅõÇ¥ÇÏ¿´½À´Ï´Ù.");
					return 1;
				}
			}
			//ÅõÇ¥ÇÏ±â
			SendClientMessage( playerid, COLOR_GREEN, "* ÅõÇ¥ÇÏ¼Ì½À´Ï´Ù.");
			BANVOTED_PLAYER_IP[VOTEBAN_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEBAN_PLAYER_GOT++;
			if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // Ãß¹æ±âÁØ Åë°ú
			{
				format( str, sizeof(str), "* ÅõÇ¥°¡ Á¾·áµÇ¾ú½À´Ï´Ù. ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» ¿µ±¸È÷ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» ¿µ±¸È÷ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				VOTEBAN_REMAINTIME = 0;
				c_Ban( VOTEBAN_PLAYER );
			}
			return 1;
		}
		//ÅõÇ¥°¡ ÁøÇàÁßÀÎ °æ¿ì
		if( VOTEBAN_REMAINTIME > 0 )
		{
			if( CONSOLE ) print("[rcon] ÀÌ¹Ì ÁøÇàÁßÀÎ ÅõÇ¥°¡ ÀÖ½À´Ï´Ù.");
			else SendClientMessage( playerid, COLOR_GREY, "* ÀÌ¹Ì ÁøÇàÁßÀÎ ÅõÇ¥°¡ ÀÖ½À´Ï´Ù." );
		}
	}
	if( VOTEBAN_REMAINTIME > 0 ) //ÇöÀç ÅõÇ¥°¡ ÁøÇàÁß
	{
		if( CONSOLE )
		{
			//¾Æ¹«°Íµµ ÀÔ·ÂÇÏÁö ¾ÊÀ½. ÅõÇ¥°¡ ÁøÇàÁß. »óÅÂ È®ÀÎ.
			printf("[rcon] ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
			printf("[rcon] ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é ¿µ±¸Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
			printf("[rcon] Áß´ÜÇÏ½Ã·Á¸é '%s Áß´Ü' À», ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '%s »ç¿ë¾ÈÇÔ' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			return 1;
		}
		format( str, sizeof(str), "* ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), " ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), "* ÅõÇ¥ÇÏ½Ã·Á¸é '/%s yes' ¶Ç´Â '/%s ¿¹' ¸¦ ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME); SEND_C(COLOR_SALMON);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
		    format( str, sizeof(str), "* ÅõÇ¥¸¦ Áß´ÜÇÏ½Ã·Á¸é '/%s Áß´Ü' À», ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '/%s »ç¿ë¾ÈÇÔ' À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥ ¾øÀ½. ÅõÇ¥ÀÛ¼º ½Ãµµ°¡ ¾ø¾úÀ½.
	{
		if( CONSOLE )
		{
			print("[rcon] ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
			printf("[rcon] »ç¿ë¹ý: %s or %s [ÀÌ¸§ÀÌ³ª ¹øÈ£]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '%s »ç¿ë¾ÈÇÔ'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* ÇöÀç ÁøÇàÁßÀÎ ÅõÇ¥°¡ ¾ø½À´Ï´Ù.");
        format( str, sizeof(str),  "* »ç¿ë¹ý: /%s ¶Ç´Â /%s [ÀÌ¸§ÀÌ³ª ¹øÈ£]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ÅõÇ¥±â´ÉÀ» ¾ø¾Ö·Á¸é '/%s »ç¿ë¾ÈÇÔ'À» ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//ÅõÇ¥ ½ÃÀÛÇÏ±â
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		else SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
		return 1;
	}

	//ÃÖ¼ÒÀÎ¿ø¿¡ ¹Ì´ÞÇÏ´Â°æ¿ì
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] ÅõÇ¥¸¦ ½ÃÀÛÇÏ·Á¸é ÃÖ¼Ò %d¸íÀÇ ÇÃ·¹ÀÌ¾î°¡ ÇÊ¿äÇÕ´Ï´Ù.", REQUIRED_MAN_VOTEBAN );
		else
		{
			format( str, sizeof(str), "* ÅõÇ¥¸¦ ½ÃÀÛÇÏ·Á¸é ÃÖ¼Ò %d¸íÀÇ ÇÃ·¹ÀÌ¾î°¡ ÇÊ¿äÇÕ´Ï´Ù.", REQUIRED_MAN_VOTEBAN ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	
	//OK.Assign Player Informations.
	VOTEBAN_PLAYER = giveplayerid;
	VOTEBAN_PLAYER_GOT = 0;
	VOTEBAN_TICK = 0;
	VOTEBAN_REMAINTIME = VOTEBAN_RUN_TIME;
	CURRENT_VOTEBAN_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEBAN_PERCENTAGE) / 100;

	//½Å°íÀÚ ºñ¹Ðº¸ÀåÀÇ °æ¿ì ±â¹Ð, ¾Æ´Ñ°æ¿ì ÀÌ¸§ ¼öÁý
	if( VOTE_CONFIDENTIALITY ) str = "±â¹Ð";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("¼­¹öÁÖÀÎ"):(GetPlayerNameEx(playerid)) );
	//ÅõÇ¥ ¸Þ¼¼Áö ¶ç¿ì±â
	format( str, sizeof(str), "* %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ½ÅÃ»µÇ¾ú½À´Ï´Ù. (½ÅÃ»ÀÎ: %s)",
		GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, str );
    SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* ÅõÇ¥´Â ÃÑ %dÃÊ°£ ÁøÇàµÇ¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", VOTEBAN_RUN_TIME, CURRENT_VOTEBAN_REQUIREMENT );
	SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* ÅõÇ¥ÇÏ½Ã·Á¸é '/%s yes' ¶Ç´Â '/%s ¿¹' ¸¦ ÀÔ·ÂÇÏ½Ã¸é µË´Ï´Ù.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* ÀÚ, Áö±ÝºÎÅÍ ÅõÇ¥¸¦ ½ÃÀÛÇÕ´Ï´Ù!" );
	printf("[rcon] %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ½ÅÃ»µÇ¾ú½À´Ï´Ù. (½ÅÃ»ÀÎ: %s, ½Å¿øº¸È£:%s)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, (playerid==ADMIN_ID)? ("¼­¹öÁÖÀÎ"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("¿¹"):("¾Æ´Ï¿À") );
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Ãß¹æ ¶Ç´Â ¿µ±¸Ãß¹æ½Ã ÅõÇ¥ °³½ÃÀÎÀ» º¸¿©ÁÖ´Â ±â´ÉÀÔ´Ï´Ù." );
			print( "[help] ¹Ýº¹ ÀÔ·ÂÀ¸·Î ÄÑ°í ²ô±â°¡ °¡´ÉÇÕ´Ï´Ù." );		
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Ãß¹æ ¶Ç´Â ¿µ±¸Ãß¹æ½Ã ÅõÇ¥ °³½ÃÀÎÀ» º¸¿©ÁÖ´Â ±â´ÉÀÔ´Ï´Ù." ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ¹Ýº¹ ÀÔ·ÂÀ¸·Î ÄÑ°í ²ô±â°¡ °¡´ÉÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	VOTE_CONFIDENTIALITY = !VOTE_CONFIDENTIALITY;
	SendClientMessageToAll(COLOR_GREENYELLOW,(VOTE_CONFIDENTIALITY? ("* Áö±ÝºÎÅÍ ÅõÇ¥ °³½ÃÀÚÀÇ ½Å¿øÀ» º¸È£ÇÕ´Ï´Ù."):("* Áö±ÝºÎÅÍ ÅõÇ¥ °³½ÃÀÚÀÇ ½Å¿øÀÌ °ø°³µË´Ï´Ù.")));
	print((VOTE_CONFIDENTIALITY? ("[rcon] Áö±ÝºÎÅÍ ÅõÇ¥ °³½ÃÀÚÀÇ ½Å¿øÀ» º¸È£ÇÕ´Ï´Ù."):("[rcon] Áö±ÝºÎÅÍ ÅõÇ¥ °³½ÃÀÚÀÇ ½Å¿øÀÌ °ø°³µË´Ï´Ù.")));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Rcon ControllerÀÇ Á¤º¸¸¦ º¾´Ï´Ù. Ãß°¡ÀûÀ¸·Î ¾÷µ¥ÀÌÆ®¸¦ È®ÀÎÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÇÁ·Î±×·¥ÀÇ Á¤º¸¸¦ º¾´Ï´Ù.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Rcon ControllerÀÇ Á¤º¸¸¦ º¾´Ï´Ù. Ãß°¡ÀûÀ¸·Î ¾÷µ¥ÀÌÆ®¸¦ È®ÀÎÇÕ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : ÇÁ·Î±×·¥ÀÇ Á¤º¸¸¦ º¾´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		printf("Rcon Controller %sÀ»(¸¦) »ç¿ëÁßÀÔ´Ï´Ù.\n%s", VERSION, COPYRIGHT_STRING );
		#if SAMP03b
			rcmd_checkupdate(NULL);
		#endif
	}
	else
	{
		new str[64];
		format( str, sizeof(str), "Rcon Controller %sÀ»(¸¦) »ç¿ëÁßÀÔ´Ï´Ù.", VERSION ); 
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ºÎ¿î¿µÀÚ°¡ ÇöÀç ÀÚ½ÅÀÌ °¡Áö°í ÀÖ´Â ±ÇÇÑÀ» È®ÀÎÇÏ´Â ±â´ÉÀÔ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÀÚ½ÅÀÌ °¡Áö°í ÀÖ´Â ±ÇÇÑÀ» È®ÀÎÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			print("[help] ÄÜ¼Ö¿¡¼­´Â »ç¿ëÀÌ ºÒ°¡´ÉÇÑ ¸í·É¾îÀÔ´Ï´Ù.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ºÎ¿î¿µÀÚ°¡ ÇöÀç ÀÚ½ÅÀÌ °¡Áö°í ÀÖ´Â ±ÇÇÑÀ» È®ÀÎÇÏ´Â ±â´ÉÀÔ´Ï´Ù." ); SEND();
			format( str, sizeof(str), "* ¿¹) /%s : ÀÚ½ÅÀÌ °¡Áö°í ÀÖ´Â ±ÇÇÑÀ» È®ÀÎÇÕ´Ï´Ù.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();

	new auths[NUM_AUTH-2][]=
	{
		"±Ó¼Ó¸» ÃßÀû±Ç",
		"¸í·É¾î ÃßÀû±Ç",
		"¿î¿µ¸Þ¼¼Áö ¼ö½Å±Ç",
		"¿î¿µÀÚ Ã¤ÆÃ »ç¿ë±Ç (/¸» , /say, /¸»¸ðµå, /psay)",
		"½Ã°£ Á¶Àý±Ç (/½Ã°£, /wtime)",
		"»ý»ç ¿©Å»±Ç (/Å³, /skill)",
		"ÅëÈ­ Á¶Àý±Ç (/µ·ÁÖ±â, /givecash, /µ·¼³Á¤, /setcash)",
		"¹«±â Á¦Á¶±Ç (/¹«±âÁÖ±â, /giveweapon)",
		"´Ð³×ÀÓ º¯°æ±Ç (/´Ð¹Ù²Ù±â, /chnick)",
		"Ã¼·Â Á¶Àý±Ç (/Ã¼º¯°æ, /sethp, /¹«Àû, /infinite)",
		"½ºÄÚ¾î Á¶Àý±Ç (/½ºÄÚ¾î, /setscore)",
		"¾Æ¸Ó Á¶Àý±Ç (/¾Æ¸Ó, /armour, /¾Æ¸Ó¹«Àû, /infarmor)",
		"±ä±Þ Ã¼Æ÷±Ç (/ÇÁ¸®Áî, /freeze)",
		"Æ¯º° »ç¸é±Ç (/¾ðÇÁ¸®Áî, /unfreeze)",
		"À½¾Ç ¹æ¼Û±Ç (/¼Ò¸®, /sound, /¼Ò¸®²ô±â, /stopsound)",
		"Á¤º¸ ¿­¶÷±Ç (/´©±¸, /user, /»óÅÂ, /stat)",
		"Á¦Æ®ÆÑ Á¦Á¶±Ç (/Á¦Æ®ÆÑ, /jetpack)",
		"°­Á¦ Ãß¹æ±Ç (/Å±, /skick)",
		"¿µ±¸ Ãß¹æ±Ç (/¹ê, /sban)",
		"¼ÒÀ½ ´Ü¼Ó±Ç (/Ã¤±Ý, /shutup, /µµ¹è, /chatflood, /¸í·É¾îµµ¹è, /cmdflood)",
		"°æ¹üÁË »ç¸é±Ç (/¸®Ãª, /unshut)",
		"Àç»ê ¸ô¼ö±Ç (/µ·¹ÚÅ», /forfeit)",
		"¹«Àå ÇØÁ¦±Ç (/¹«±â¹ÚÅ», /disarm) ",
		"¸¶ÆÐ ÀÌ¿ë±Ç (/Â÷¼ÒÈ¯, /spawncar)",
		"ºÎ¿î¿µÀÚ ÀÓ¸í±Ç (/ºÎ¿î, /subadmin)",
		"ºÎ¿î ÅºÇÙ±Ç (/ºÎ¿î¹ÚÅ», /suspend)",
		"Æø¹ß¹° »ç¿ë±Ç (/ÆøÅº, /bomb)",
		"±¹Á¤ È«º¸±Ç (/°øÁö, /notice, /°øÁö¸ñ·Ï, /noticelist, /°øÁö·Îµå, /reloadnotice)",
		"¼­¹ö ºñ»ó °è¾ö±Ç (/¼­¹öÀá±×±â, /locksvr)",
		"¼ø°£ ÀÌµ¿±Ç (/ÃâµÎ, /with)",
		"À¯Àú ¼ÒÈ¯±Ç (/¼ÒÈ¯, /call)",
		"ºÎ¿î¿µÀÚ ÀÎ»ç±Ç (/±ÇÇÑº¯°æ, /chauth, /±ÇÇÑ¸ñ·Ï, /authlist, /ºÎ¿î·Îµå, /reloadsubs)",
		"Áß·Â Á¶Àý±Ç (/Áß·Â, /gravity)",
		"³¯¾¾ Á¶Àý±Ç (/³¯¾¾, /weather)",
		"Â÷·® ¼ö¸®±Ç (/Â÷¿¡³ÊÁö, /carenergy)",
		"¿å¼³ ´Ü¼Ó±Ç (/¿åÇÊÅÍ, /yellfilter, /¿åÃß°¡, /addyell, /¿åÁ¦°Å, /delyell)",
		"ÇÙ¹æÁö Á¶Àý±Ç (/¹«±âÇÙ, /¹«±âÃß°¡, /¹«±âÁ¦°Å, /Á¦Æ®ÆÑÇÙ)",
		"ÇÎ Á¤¸®±Ç (/ÇÎÁ¤¸®, /pingcheck, /ÇÎÁ¦ÇÑ, /setplimit, /ÇÎ°æ°í, /setpwarn, /ÇÎÃÊ±âÈ­, /resetping)",
		"ºÒ½É °Ë¹®±Ç (/sdrop, /³»¸®±â, /°¨½Ã, /spectate, /°¨½ÃÇØÁ¦, /specoff)",
		"Àá¼ö °ü¸®±Ç (/Àá¼ö, /desync)",
		"¿î¿µÀÚ È£Ãâ±Ç (/¼Ò¸®³»±â, /mks)",
		"¼³Á¤ º¯°æ±Ç(/¼³Á¤·Îµå, /¼³Á¤ÀúÀå, /loadconfig, /saveconfig)",
		"¹ê¸ñ·Ï ÇØÁ¦±Ç(/¹êÇ®±â, /unban, /¾ÆÀÌÇÇ¹êÇ®±â, /unbanip)",
		"ÅõÇ¥ »ç¿ë/Áß´Ü(/°­ÅðÅõÇ¥, /votekick, /¿µ¹êÅõÇ¥, /voteban)"
	};
	
	new str[128];
	if( IsPlayerAdmin(playerid) ) SendClientMessage( playerid, COLOR_LIME, "* ´ç½ÅÀº ¿î¿µÀÚÀÔ´Ï´Ù. Rcon ControllerÀÇ ¸ðµç ¸í·É¾î¸¦ »ç¿ëÇÒ ¼ö ÀÖ½À´Ï´Ù." );
	else
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "== »ç¿ë °¡´ÉÇÑ ±ÇÇÑ ¸ñ·Ï ==" );
		for(new i = 2;i < NUM_AUTH;i++)
		{
			format(str,sizeof(str)," %s : %s",auths[i-2],(AuthorityCheck(playerid,Authinfo:i))? ("»ç¿ë °¡´É"):("±ÇÇÑ ¾øÀ½"));
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ¼­¹ö¿¡ ÀÖ´Â ÇÃ·¹ÀÌ¾î ¸ñ·Ï ¹× ±âº»Á¤º¸¸¦ È®ÀÎÇÕ´Ï´Ù." );
			printf( "[help] ¿¹) %s : ÇöÀç ¼­¹ö¿¡ ÀÖ´Â ÇÃ·¹ÀÌ¾î ¸ñ·Ï ¹× ±âº»Á¤º¸¸¦ È®ÀÎÇÕ´Ï´Ù.", CURRENT_CMD_NAME );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ÇöÀç ¼­¹öÀÇ Á¤Ã¥À» È®ÀÎÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ¿¹) /%s : ÇöÀç ¼­¹ö¿¡ ÀÖ´Â ÇÃ·¹ÀÌ¾î ¸ñ·Ï ¹× ±âº»Á¤º¸¸¦ È®ÀÎÇÕ´Ï´Ù.", CURRENT_CMD_NAME );			
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
	
	//°¢ »ç¿ëÀÚÀÇ Á¤º¸ Ç¥½Ã
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
			printf( "[help] ±¸¹®: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ÇöÀç ¼­¹öÀÇ Á¤Ã¥À» È®ÀÎÇÕ´Ï´Ù." );
			//printf( "[help] ¿¹) %s : ÇöÀç ¼­¹öÀÇ Á¤Ã¥À» È®ÀÎÇÕ´Ï´Ù.", CURRENT_CMD_NAME );
			printf( "[help] ¼­¹öÀÇ ¼³Á¤À» INI ÆÄÀÏ¿¡ ÀúÀåÇÏ·Á¸é '%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_SAVECONFIG));
			printf( "[help] ¼­¹öÀÇ ¼³Á¤À» INI ÆÄÀÏ·ÎºÎÅÍ ´Ù½Ã ·ÎµåÇÏ·Á¸é '%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_LOADCONFIG));
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ±¸¹®: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ÇöÀç ¼­¹öÀÇ Á¤Ã¥À» È®ÀÎÇÕ´Ï´Ù." );
			SendClientMessage( playerid, COLOR_LIME, str );
			//format( str, sizeof(str), "* ¿¹) /%s : ¼³Á¤ ÆÄÀÏ¿¡¼­ °øÁö¸¦ ´Ù½Ã ºÒ·¯¿É´Ï´Ù.", CURRENT_CMD_NAME );
			//SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ¼­¹öÀÇ ¼³Á¤À» INI ÆÄÀÏ¿¡ ÀúÀåÇÏ·Á¸é '/%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_SAVECONFIG));
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ¼­¹öÀÇ ¼³Á¤À» INI ÆÄÀÏ·ÎºÎÅÍ ´Ù½Ã ·ÎµåÇÏ·Á¸é '/%s' ¸í·É¾î¸¦ ÂüÁ¶ÇÏ½Ê½Ã¿À.", GetCmdName(CMD_LOADCONFIG));
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
	print( (READ_CINPUT)? ("[rcon] ¸í·É¾î ÀÐ±â ±â´ÉÀ» È°¼ºÈ­ Çß½À´Ï´Ù."):("[rcon] ¸í·É¾î ÀÐ±â ±â´ÉÀ» ºñÈ°¼ºÈ­ Çß½À´Ï´Ù.") );
	#pragma unused params
	return 1;
} */
//==========================================================
rcmd_rcon(params[])
{
	if( isnull(params) )
	{
		print("[rcon] »ç¿ë¹ý : rcon [¸í·É¾î]");
		return 1;
	}
	printf("[rcon] RCON ¸í·É¾î¸¦ º¸³Â½À´Ï´Ù. - %s", params);
	SendRconCommand(params);
	return 1;
}
//==========================================================
rcmd_checkupdate(params[])
{
	#pragma unused params
	#if !SAMP03b
		print("[rcon]ÇöÀç È£È¯ ¸ðµå·Î ½ÇÇàÁßÀÔ´Ï´Ù. ¾÷µ¥ÀÌÆ® È®ÀÎ ±â´ÉÀ» »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
	#else
		print("[rcon] ÃÖ½Å ¹öÀü ¿©ºÎ¸¦ °Ë»çÇÕ´Ï´Ù..");		
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

	if(!fexist(FILE_SETTINGS) || c_iniInt( "[General]", "±âº»°ª »ç¿ë"))
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
		/* ÇÎÁ¤¸® °ü·Ã */
		USE_PINGCHECK = 1;
		HIGHPING_LIMIT = 500;
		HIGHPING_WARN_LIMIT = 5;
		PINGCHECK_DURATION = 3;
		RESET_HIGHPING_TICK = 60;
		//READ_CINPUT = 1;
		ONFLOOD_CHAT = 0;
		ONFLOOD_CMD = 0;
		BADPLAYER_MESSAGE = "´ç½ÅÀº ÀÌ ¼­¹ö¿¡¼­ ºÒ°ÇÀüÇÑ Çàµ¿À¸·Î Ãß¹æµÈ ÀûÀÌ ÀÖ½À´Ï´Ù. ÁÖÀÇÇÏ½Ê½Ã¿À.";
		USE_BADWARN = 1;
		ADMINCHAT_NAME = "* ¼­¹öÁÖÀÎ(ÄÜ¼Ö) :";
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
			print("[ERROR] RconController.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ±âº»°ªÀ» ·ÎµåÇÕ´Ï´Ù.\n[ERROR] ¶ÇÇÑ °øÁö,ºÎ¿î¿µÀÚ ±â´É ¹× ÀÏºÎ±â´ÉÀÌ Á¦ÇÑµË´Ï´Ù.");
			print("[ERROR] ¿¡·¯ÇØ°áÀ» À§ÇØ scriptfiles\\MINIMINI Æú´õ¿¡ RconController.ini¸¦ ³Ö¾îÁÖ¼¼¿ä.");
			Wait(5000);
			return ;
		}
		else print("[rcon] ¼³Á¤¿¡ µû¶ó ¼­¹öÀÇ ±âº»°ªÀ» ºÒ·¯¿Ô½À´Ï´Ù.");
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
	/* ÇÎÁ¤¸® °ü·Ã */
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
	/* ÇÎÁ¤¸® °ü·Ã */
	if( HIGHPING_LIMIT < 1 ) HIGHPING_LIMIT = 500;
	if( HIGHPING_WARN_LIMIT < 0 ) HIGHPING_WARN_LIMIT = 5;
	if( PINGCHECK_DURATION < 1 ) PINGCHECK_DURATION = 3;
	if( RESET_HIGHPING_TICK < 0 ) RESET_HIGHPING_TICK = 60;
	//if( READ_CINPUT < 0 || READ_CINPUT > 1 ) READ_CINPUT = 1;
	if( USE_BADWARN < 0 || USE_BADWARN > 1 ) USE_BADWARN = 1;
	if( !BADPLAYER_MESSAGE[0]) BADPLAYER_MESSAGE = "´ç½ÅÀº ÀÌ ¼­¹ö¿¡¼­ ºÒ°ÇÀüÇÑ Çàµ¿À¸·Î Ãß¹æµÈ ÀûÀÌ ÀÖ½À´Ï´Ù. ÁÖÀÇÇÏ½Ê½Ã¿À.";
	if( !ADMINCHAT_NAME[0] ) ADMINCHAT_NAME = "* ¼­¹öÁÖÀÎ(ÄÜ¼Ö) :";
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
		print("=============== ÇöÀç ¼­¹ö Á¤Ã¥ ====================");
		printf("Á¾·á½Ã¿¡ ¼­¹ö Á¤Ã¥ ÀúÀå : %s",(SAVE_CURRRENT_CONFIG)? ("»ç¿ë"):("»ç¿ë¾ÈÇÔ"));
		if( DUMPEXIT == 0 ) print( "Á¾·á½Ã¿¡ ¸Þ¸ð¸® ´ýÇÁ »ý¼º : »ç¿ë¾ÈÇÔ" );
		else if( DUMPEXIT == 1 ) print( "Á¾·á½Ã¿¡ ¸Þ¸ð¸® ´ýÇÁ »ý¼º : ±âº» ´ýÇÁ »ý¼º" );
		else print( "Á¾·á½Ã¿¡ ¸Þ¸ð¸® ´ýÇÁ »ý¼º : ÀüÃ¼ ´ýÇÁ »ý¼º" );
		printf("¼­¹ö ¿î¿µÀÚ ÀÌ¸§ : \"%s\"", ADMINCHAT_NAME );
		//printf("Controller ÀÔ·Â±â : %s",(READ_CINPUT)? ("»ç¿ë"):("»ç¿ë¾ÈÇÔ"));
		printf("ÀÚµ¿ ¸»¸ðµå : %s",(PERMANENT_ADMINSAY[ADMIN_ID])? ("»ç¿ë"):("»ç¿ë¾ÈÇÔ"));
		if( NOTICE_INTERVAL ) printf( "°øÁö ±â´É : »ç¿ë, °øÁö °£°Ý : %dÃÊ", NOTICE_INTERVAL ); else print( "°øÁö ±â´É : »ç¿ë¾ÈÇÔ");
		if( USE_PINGCHECK ) printf("ÇÎ Á¤¸® ±â´É : »ç¿ë(%dÃÊ¸¶´Ù, %dms, %dÈ¸ °æ°íÈÄ Ãß¹æ)", PINGCHECK_DURATION, HIGHPING_LIMIT, HIGHPING_WARN_LIMIT );
		else print("ÇÎ Á¤¸® ±â´É : »ç¿ë¾ÈÇÔ");
		if( USE_YELLFILTER ) printf( "¿åÇÊÅÍ : »ç¿ë, ÆÐÅÏ ¹öÀü : v%s, ÆÐÅÏ ¼ö : %d°³", YELL_VER[1],num_Yells ); else print( "¿åÇÊÅÍ : »ç¿ë¾ÈÇÔ");
		if( USE_ANTI_CHATFLOOD ) printf( "µµ¹è¹æÁö : »ç¿ë(%dÃÊ¿¡ %d¹ø, %dÃÊ°£ ¹úÄ¢, %dÈ¸ À§¹Ý½Ã %s)", CHATFLOOD_UNIT_TIME, CHATFLOOD_LIMIT, CHATFLOOD_SHUTUP_TIME, PMABUSE_LIMIT, (ONFLOOD_CHAT)? ("¿µ±¸Ãß¹æ"):("Ãß¹æ") );
		else print("µµ¹è¹æÁö : »ç¿ë¾ÈÇÔ");
		if( USE_ANTI_CMDFLOOD ) printf( "¸í·É¾îµµ¹è ¹æÁö : »ç¿ë(%dÃÊ¿¡ %d¹ø, %dÃÊ°£ ¹úÄ¢, %dÈ¸ À§¹Ý½Ã %s)", CMDFLOOD_UNIT_TIME, CMDFLOOD_LIMIT, CMDFLOOD_FORBIDDEN_TIME, CMDFLOOD_STILL_LIMIT, (ONFLOOD_CMD)? ("¿µ±¸Ãß¹æ"):("Ãß¹æ") );
		else print( "¸í·É¾îµµ¹è ¹æÁö : »ç¿ë¾ÈÇÔ");
		if( USE_BADWARN ) printf( "ºÒ·®À¯Àú °æ°í : »ç¿ë(%-15s...)", BADPLAYER_MESSAGE ); else print( "ºÒ·®À¯Àú °æ°í : »ç¿ë¾ÈÇÔ" );
		if( ALLOW_DESYNC == 1 ) printf( "Àá¼öÇã¿ë : %dÃÊ±îÁö¸¸ Çã¿ë", DESYNC_LIMIT );
		else if( ALLOW_DESYNC == 2 ) print("Àá¼öÇã¿ë : Çã¿ë");
		else print( "Àá¼öÇã¿ë : Çã¿ëÇÏÁö ¾ÊÀ½" );
		if( ENABLE_VOTEKICK ) printf( "°­Á¦Ãß¹æ ÅõÇ¥ : »ç¿ë (ÇÊ¿äÀÎ¿ø %d¸í, %d%%ÀÌ»ó Âù¼º, %dÃÊµ¿¾È)", REQUIRED_MAN_VOTEKICK, MINIMUM_VOTEKICK_PERCENTAGE, VOTEKICK_RUN_TIME );
		else print("°­Á¦Ãß¹æ ÅõÇ¥ : »ç¿ë¾ÈÇÔ");
		if( ENABLE_VOTEBAN ) printf( "¿µ±¸Ãß¹æ ÅõÇ¥ : »ç¿ë (ÇÊ¿äÀÎ¿ø %d¸í, %d%%ÀÌ»ó Âù¼º, %dÃÊµ¿¾È)", REQUIRED_MAN_VOTEBAN, MINIMUM_VOTEBAN_PERCENTAGE, VOTEBAN_RUN_TIME );
		else print("¿µ±¸Ãß¹æ ÅõÇ¥ : »ç¿ë¾ÈÇÔ");
		if( VOTE_CONFIDENTIALITY ) print("ÅõÇ¥½Ã ½Å¿øº¸È£ : ¿¹"); else print("ÅõÇ¥½Ã ½Å¿øº¸È£ : ¾Æ´Ï¿À");
		if( USE_ANTI_WEAPONCHEAT ) printf( "¹«±âÇÙ ¹æÁö : »ç¿ë( %s, ±ÝÁö¹«±â %s )", (ONCHEAT_WEAPON)? ("Ãß¹æ"):("¿µ±¸Ãß¹æ"), c_iniGet("[Anticheat]", "FORBIDDEN_WEAPONS"));
		else print( "¹«±âÇÙ ¹æÁö : »ç¿ë¾ÈÇÔ" );
		printf( "Á¦Æ®ÆÑ »ç¿ë : %s", (ALLOW_JETPACK)? ("Çã¿ë"):("Çã¿ë¾ÈÇÔ") );
		printf( "»ç¼³ °¨½Ã Çã¿ë : %s", (ALLOW_PRIVATE_SPECTATE)? ("Çã¿ë"):("Çã¿ë¾ÈÇÔ") );
		printf( "µ·ÇÙ ¹æÁö : %s", (USE_ANTI_MONEYCHEAT)? ("»ç¿ë"):("»ç¿ë¾ÈÇÔ") );
		print(LINE);
	}
	else SendClientMessage( playerid, COLOR_YELLOW, " * ÁØºñÁßÀÔ´Ï´Ù." );
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
	print("[rcon] ¼­¹öÀÇ ÇöÀç Á¤Ã¥À» ÀúÀåÇß½À´Ï´Ù.");
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
			if( CONSOLE ) text = "           ÀÚ¼¼ÇÑ µµ¿ò¸»À» º¸·Á¸é µµ¿ò¸» [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ½Ê½Ã¿À.";
			else
			{
				format( text, sizeof(text), "           ÀÚ¼¼ÇÑ µµ¿ò¸»À» º¸·Á¸é /%s [¸í·É¾î ÀÌ¸§] À» ÀÔ·ÂÇÏ½Ê½Ã¿À.", GetCmdName(CMD_HELP) );
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
		case 3 .. (ceildiv(sizeof( cmdlist ), 6) + 2) : //¸îÁÙÀÎÁö ±¸ÇÑ´Ù
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
			if( CONSOLE ) format( text, sizeof(text), "              Total %d Commands, (C) 2008 - 2013 CoolGuy(¹ä¸Ô¾ú´Ï)", sizeof( cmdlist ) );
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
public ResetPingCheck() //ÇÎÁ¤¸® ÃÊ±âÈ­
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
	format( str, sizeof(str), "* %s(%d)´ÔÀ» °¨½ÃÇÏ±â ½ÃÀÛÇÕ´Ï´Ù. Àá½Ã¸¸ ±â´Ù·Á ÁÖ¼¼¿ä....", GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf("[rcon] %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ Á¦Æ®ÆÑÀ» »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i]);
			format( str, sizeof(str), "* %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ Á¦Æ®ÆÑÀ» »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i]);
			SendClientMessageToAll( COLOR_RED, str );
			c_Kick(pITT[i]);
			continue;
		}

		if( GetPlayerState( pITT[i] ) == PLAYER_STATE_SPECTATING )
		{
			if( IsPlayerAdmin(pITT[i]) || IsPlayerSubAdmin(pITT[i]) ) PLAYER_DESYNCED_TIMES[pITT[i]] = 0;
			else if( !ALLOW_PRIVATE_SPECTATE && IS_PLAYER_SPECTATING[pITT[i]] == INVALID_PLAYER_ID )
			{
				printf("[rcon] %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ °¨½Ã±â´ÉÀ» »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i]);
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ °¨½Ã±â´ÉÀ» »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i]);
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
				printf("[rcon] %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ ¹«±â %sÀ»(¸¦) »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i], str);
				format( str, sizeof(str), "* %s(%d)´ÔÀÌ ¼­¹ö¿¡¼­ ±ÝÁöÇÑ ¹«±â %sÀ»(¸¦) »ç¿ëÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i] , str);
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
					printf("[rcon] %s(%d)´ÔÀÌ Á¦ÇÑ½Ã°£(%dÃÊ) ÀÌ»ó Àá¼öÇÏ¿© Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT);
					format( str, sizeof(str), "* %s(%d)´ÔÀÌ Á¦ÇÑ½Ã°£(%dÃÊ) ÀÌ»ó ESCÅ°¸¦ ´­·¯ Ãß¹æµË´Ï´Ù.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT );
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
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* ÇÎÀÌ ³Ê¹« ³ô½À´Ï´Ù. ¼­¹ö ¾ÈÁ¤È­¸¦ À§ÇØ Ãß¹æÇÕ´Ï´Ù. ¤Ð_ ¤Ð");
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* You have too high ping to play in my server. Sorry");
					format(str,sizeof(str),"* %s(%d)´ÔÀÇ ÇÎÀÌ ³Ê¹« ³ô¾Æ Ãß¹æÇÕ´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
					SendClientMessageExceptPlayer(pITT[i],COLOR_GREENYELLOW,str);
					printf("[info] %s(%d)´ÔÀÇ ÇÎÀÌ ³Ê¹« ³ô¾Æ Ãß¹æÇÕ´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
					c_Kick(pITT[i]);
					continue;
				}
				printf("[info] %s(%d)´ÔÀÇ ÇÎÀÌ %dÀ»(¸¦) ³Ñ¾ú½À´Ï´Ù. (%dÈ¸)",GetPlayerNameEx(pITT[i]),pITT[i],HIGHPING_LIMIT,HIGHPING_WARNED_TIMES[pITT[i]]);
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* °æ°í! ÇÎÀÌ ³Ê¹« ³ô½À´Ï´Ù. ÀÎÅÍ³Ý È¯°æÀ» °³¼±ÇÏ¼¼¿ä.");
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
			{ // ÃÊ°¡ ÀÖÀ¸¸é
				PLAYER_PUNISH_REMAINTIME[pITT[i]][j]-=1; // reduce
				if(PLAYER_PUNISH_REMAINTIME[pITT[i]][j]==0)
				{
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* ¼­¹öÁÖÀÎ: ¾ÕÀ¸·Î´Â Á¶½ÉÇÏ½Ã±æ ¹Ù¶ø´Ï´Ù.");
					switch(j)
					{
					case PUNISH_FREEZE:
						{
							TogglePlayerControllable(pITT[i],1);
							printf("[rcon] %s(%d)´ÔÀÌ ÇÁ¸®Áî ¹úÄ¢¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)´ÔÀÌ ÇÁ¸®Áî ¹úÄ¢¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_SHUTUP:
						{
							printf("[rcon] %s(%d)´ÔÀÌ Ã¤ÆÃ±ÝÁö ¹úÄ¢¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)´ÔÀÌ Ã¤ÆÃ±ÝÁö ¹úÄ¢¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_CMDRESTRICT:
						{
							printf("[rcon] %s(%d)´ÔÀÌ ¸í·É¾î »ç¿ëÁ¦ÇÑ¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)´ÔÀÌ ¸í·É¾î »ç¿ëÁ¦ÇÑ¿¡¼­ Ç®·Á³µ½À´Ï´Ù.",GetPlayerNameEx(pITT[i]),pITT[i]);
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
			else if( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] < 0 ) //Å±ÀÌ³ª ¹êÇØ¾ß ÇÑ´Ù¸é
			{
				//»óÅÂ¸¦ ºÁ¼­
				switch ( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] )
				{
					case KICK_THIS_PLAYER: //Å±ÀÌ³ª
					{
						GameTextForPlayer(pITT[i],"You are ~y~Kicked", 150000, 5);
						Kick(pITT[i]);
					}
					case BAN_THIS_PLAYER: //¹êÀ» ÇÑ´Ù
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
				if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // Ãß¹æ±âÁØ Åë°ú
				{
					format( str, sizeof(str), "* ÅõÇ¥°¡ Á¾·áµÇ¾ú½À´Ï´Ù. ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» °­Á¦ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» °­Á¦ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
					c_Kick( VOTEKICK_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* ½Ã°£ÀÌ ÃÊ°úµÇ¾î %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æÀº ¹Ý·ÁµË´Ï´Ù.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ÅõÇ¥°á°ú %s(%d)¿¡ ´ëÇÑ °­Á¦Ãß¹æÀº ¹Ý·ÁµÊ.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
				}
	        }
			else if( VOTEKICK_TICK >= VOTEKICK_NOTIFY_DURATION )
			{
			    VOTEKICK_TICK = 0;
		 		format( str, sizeof(str), "* ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ °­Á¦Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* ÅõÇ¥ÇÏ½Ã·Á¸é /vkick yes ¶Ç´Â /Å± ¿¹ À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä." );
				printf("[rcon] °­Á¦Ãß¹æ ÅõÇ¥ %s(%d): %d¸íÁß %d¸í Âù¼º. (³²Àº½Ã°£ %dÃÊ).", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER, NUM_PLAYERS, VOTEKICK_PLAYER_GOT, VOTEKICK_REMAINTIME );
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
				if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // Ãß¹æ±âÁØ Åë°ú
				{
					format( str, sizeof(str), "* ÅõÇ¥°¡ Á¾·áµÇ¾ú½À´Ï´Ù. ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» ¿µ±¸È÷ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ÅõÇ¥ °á°ú·Î %s(%d)´ÔÀ» ¿µ±¸È÷ Ãß¹æÇÕ´Ï´Ù.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
					c_Ban( VOTEBAN_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* ½Ã°£ÀÌ ÃÊ°úµÇ¾î %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æÀº ¹Ý·ÁµË´Ï´Ù.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ÅõÇ¥°á°ú %s(%d)¿¡ ´ëÇÑ ¿µ±¸Ãß¹æÀº ¹Ý·ÁµÊ.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
				}
	        }
			else if( VOTEBAN_TICK >= VOTEBAN_NOTIFY_DURATION )
			{
			    VOTEBAN_TICK = 0;
		 		format( str, sizeof(str), "* ÇöÀç %s(%d)´Ô¿¡ ´ëÇÑ ¿µ±¸Ãß¹æ ÅõÇ¥°¡ ÁøÇàÁßÀÔ´Ï´Ù. (³²Àº ½Ã°£ : %dÃÊ)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " ÃÑ %d¸íÁß %d¸íÀÌ Âù¼ºÇ¥¸¦ ´øÁ³À¸¸ç, %d¸í ÀÌ»óÀÌ Âù¼ºÇÏ¸é Ãß¹æµË´Ï´Ù.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* ÅõÇ¥ÇÏ½Ã·Á¸é /vBAN yes ¶Ç´Â /¹ê ¿¹ À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä." );
				printf("[rcon] ¿µ±¸Ãß¹æ ÅõÇ¥ %s(%d): %d¸íÁß %d¸í Âù¼º. (³²Àº½Ã°£ %dÃÊ).", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER, NUM_PLAYERS, VOTEBAN_PLAYER_GOT, VOTEBAN_REMAINTIME );
			}
	    }
	}
}
//==========================================================
#if SAMP03a
//==========================================================
ShowPlayerDialogs( playerid, dialogid ) //»ç¿ëÀÚ¿¡°Ô ´ëÈ­»óÀÚ ¶ç¿ì±â
{
    new str[1024];
	switch( dialogid )
	{
	    case DIALOG_ADMIN_MAIN :
	    {
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n¸Þ¼¼Áö º¸³»±â\r\nÃâµÎ\r\n¼ÒÈ¯\r\n»ç»ì\r\nÃ¼·Â º¯°æ\r\n¹«ÀûÀ¸·Î ¸¸µé±â\r\n\
				½ÓÁþµ· ÁÖ±â\r\n°¡Áøµ· »¯±â\r\n¼ÒÁö±Ý ¼³Á¤ÇÏ±â\r\n½ºÄÚ¾î ¼³Á¤ÇÏ±â\r\n¹«±â Á¦°ø\r\n\
				¹«±â ¸ô¼ö\r\nÇÁ¸®Áî\r\nÇÁ¸®Áî ÇØÁ¦\r\n¾Æ¸Ó º¯°æ\r\n¾Æ¸Ó ¹«Àû\r\nÂ÷·® ¼ÒÈ¯\r\nÂ÷¿¡¼­ ³»¸®°ÔÇÏ±â\r\n\
				Â÷¿¡³ÊÁö º¯°æ\r\nÁ¦Æ®ÆÑ ÁÖ±â\r\nÀ½¾Ç Àç»ý\r\nÀç»ýÁßÀÎ À½¾Ç ²ô±â\r\n³ú ÅÍÆ®¸®±â\r\n\
				Ã¤ÆÃ ±ÝÁö\r\nÃ¤ÆÃ±ÝÁö ÇØÁ¦\r\n´Ð³×ÀÓ ¹Ù²Ù±â\r\nÀÌ ÇÃ·¹ÀÌ¾î °¨½Ã\r\nºÎ¿î¿µÀÚ·Î ÀÓ¸í\r\n¿î¿µ±ÇÇÑ ¹ÚÅ»\r\n\
				ÀÌ À¯ÀúÀÇ Á¤º¸ º¸±â",
				"È®ÀÎ", "Ãë¼Ò" );
		}
		case DIALOG_ADMIN_KICK :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ Ãß¹æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KICK, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_BAN :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ ¿µ±¸È÷ Ãß¹æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BAN, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_WITH :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô ÀÌµ¿ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_WITH, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_CALL :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ ¼ÒÈ¯ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CALL, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_KILL :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ »ç»ìÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KILL, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SETHP :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Ã¼·ÂÀ» º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETHP, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_INFINITE :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ ¹«ÀûÀ¸·Î ¸¸µì´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFINITE, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_MAKECASH :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô ½ÓÁþµ·À» Áã¾îÁÝ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAKECASH, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_FORFEIT :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» ¹ÚÅ»ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FORFEIT, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SETCASH :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ¼ÒÁö±ÝÀ» º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETCASH, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SETSCORE :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ½ºÄÚ¾î¸¦ º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETSCORE, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_GIVEWP :
		{
			for( new i = 0 ; i < sizeof(WEAPON_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, WEAPON_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s´Ù¸¥ ¹«±â..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_LIST, "Á¦°øÇÒ ¹«±â¸¦ ¼±ÅÃÇÏ½Ê½Ã¿À.", str, "¼±ÅÃ", "µÚ·Î" );
		}
		case DIALOG_ADMIN_DISARM :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ¹«±â¸¦ ¹ÚÅ»ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DISARM, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_FREEZE :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ ÀÏÁ¤½Ã°£ ¹­¾îµÓ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FREEZE, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_UNFREEZE :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ °á¹ÚÀ» Ç®¾îÁÝ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNFREEZE, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
 		case DIALOG_ADMIN_ARMOR :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_ARMOR, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
 		case DIALOG_ADMIN_INFARMOR :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ¾Æ¸Ó¸¦ ¹«ÇÑÀ¸·Î ¸¸µì´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFARMOR, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SPAWNCAR :
		{
	    	for( new i = 0 ; i < sizeof(VEHICLE_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, VEHICLE_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s´Ù¸¥ Â÷·®..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_LIST, "Á¦°øÇÒ Â÷·®À» ¼±ÅÃÇÏ½Ê½Ã¿À", str, "¼±ÅÃ", "µÚ·Î" );
		}
		case DIALOG_ADMIN_SDROP :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ Â÷¿¡¼­ ³»¸®°Ô ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SDROP, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_CARENERGY :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Â÷¿¡³ÊÁö¸¦ º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CARENERGY, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_JETPACK :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¿¡°Ô Á¦Æ®ÆÑÀ» Á¦°øÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_JETPACK, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_MUSIC :
		{
	    	for( new i = 0 ; i < sizeof(MUSIC_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, MUSIC_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s´Ù¸¥ À½¾Ç..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_LIST, "Àç»ýÇÒ À½¾ÇÀ» ¼±ÅÃÇÏ½Ê½Ã¿À", str, "¼±ÅÃ", "µÚ·Î" );
		}
		case DIALOG_ADMIN_MUSICOFF :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Àç»ýÁßÀÎ À½¾ÇÀ» ÁßÁöÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSICOFF, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_BOMB :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ³ú¸¦ ÅÍÆ®¸³´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BOMB, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SHUTUP :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Ã¤ÆÃÀ» ÀÏÁ¤½Ã°£ ±ÝÁöÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SHUTUP, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_UNSHUT :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Ã¤ÆÃ±ÝÁö¸¦ ÇØÁ¦ÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNSHUT, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_CHANGENICK :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ ´Ð³×ÀÓÀ» º¯°æÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CHANGENICK, DIALOG_STYLE_INPUT, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_SPECTATE :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾î¸¦ °¨½ÃÇÕ´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPECTATE, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}		
		case DIALOG_ADMIN_SUBADMIN :
		{
			new tmp[128];
			str="¸ðµç ±ÇÇÑ";
			for(new i=1;i<32;i++)
			{
				format(tmp,sizeof(tmp),"Auth_Profile%d",i);
				set( tmp, c_iniGet("[SubAdmin]",tmp) );
				if( !tmp[0] ) break;
				format( str, sizeof(str), "%s\r\n%s", str, tmp );
			}
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_LIST, "ÇØ´ç ÇÃ·¹ÀÌ¾î¿¡°Ô ºÎ¿©ÇÒ ±ÇÇÑÀ» ¼±ÅÃÇÏ½Ê½Ã¿À.", str, "¼±ÅÃ", "µÚ·Î" );
		}
		case DIALOG_ADMIN_DELSUB :
		{
			format( str, sizeof(str), "%s(%d)´ÔÀÇ  ºÎ¿î¿µÀÚ ±ÇÇÑÀ» ¹ÚÅ»ÇÕ´Ï´Ù.\r\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DELSUB, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_ADMIN_FIND :
		{
		    format( str, sizeof(str), "´ÙÀ½ ÇÃ·¹ÀÌ¾îÀÇ Á¤º¸¸¦ º¾´Ï´Ù: %s(%d).\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FIND, DIALOG_STYLE_MSGBOX, "°è¼ÓÇÏ½Ã°Ú½À´Ï±î?", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_PM :
		{
 		    format( str, sizeof(str), "%s(%d)´Ô¿¡°Ô º¸³¾ ¸Þ¼¼Áö¸¦ ÀÔ·ÂÇÏ¿© ÁÖ½Ê½Ã¿À.",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_PM, DIALOG_STYLE_INPUT, "¸Þ¼¼Áö º¸³»±â", str, "º¸³»±â", "µÚ·Î" );
		}
		case DIALOG_USER_MAIN :
		{
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n¸Þ¼¼Áö º¸³»±â",
				"È®ÀÎ", "Ãë¼Ò" );
		}
		case DIALOG_USER_VOTEKICK :
		{
		    format( str, sizeof(str), "%s(%d)´ÔÀÇ Ãß¹æÀ» ¿äÃ»ÇÕ´Ï´Ù.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEKICK, DIALOG_STYLE_MSGBOX, "°­Á¦Ãß¹æ ÅõÇ¥", str, "¿¹", "¾Æ´Ï¿À" );
		}
		case DIALOG_USER_VOTEBAN :
		{
			format( str, sizeof(str), "%s(%d)´ÔÀÇ ¿µ±¸Ãß¹æÀ» ¿äÃ»ÇÕ´Ï´Ù.\n°è¼ÓÇÏ½Ã°Ú½À´Ï±î?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "¿µ±¸Ãß¹æ ÅõÇ¥", str, "¿¹", "¾Æ´Ï¿À" );
		}		
		default:
		{
			format( str, sizeof(str), "¿À·ù°¡ ÀÖ½À´Ï´Ù. DIALOG_ID : %d", dialogid );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "¿À·ù ¹ß°ß!", str, "¤·¤·", "¤·¤·" );
		}
	}
	return 1;
}
//==========================================================
public Firstrun()
{
	print(LINE);
	print("\n[rcon] Ã³À½ »ç¿ëÇÏ½Ã´Â±º¿ä! Àú´Â ¿©·¯ºÐÀÇ ¼­¹ö°ü¸®¸¦ µµ¿ÍÁÖ´Â ½ºÅ©¸³Æ®ÀÔ´Ï´Ù.");
	print("[rcon] ±âº»ÀûÀ¸·Î Á¦°Ô´Â ´ëÈ­Çü ¸í·É¾î ¹× ¿ÍÀÏµåÄ«µå ±â´ÉÀÌ ÀÖ½À´Ï´Ù.");
	printf("[rcon] º¸Åë ¸í·É¾î´Â '%s player1 10000' ½ÄÀ¸·Î ÀÔ·ÂÇÏ´Âµ¥¿ä,", GetCmdName(CMD_MCASH));
	printf("[rcon] ¸í·É¾î¸¦ '%s ?' ·Î ÀÔ·ÂÇÏ¸é ¸í·É¾î¸¦ ½±°Ô »ç¿ëÇÒ ¼ö ÀÖ½À´Ï´Ù ^.^", GetCmdName(CMD_MCASH));
	print("[rcon] ¶Ç player1ÀÌ µé¾î°¥ ÀÚ¸®¿¡ '*'³ª '!', '~'¸¦ ÀÔ·ÂÇÒ ¼ö°¡ ÀÖ´Âµ¥¿ä.");
	print("[rcon] '*'´Â '¸ðµç »ç¶÷', '!'´Â '³ª¿Í °¡±îÀÌ ÀÖ´Â »ç¶÷', '~'´Â '¸¶Áö¸·À¸·Î Ã¤ÆÃÇÑ »ç¶÷'À» ÀÇ¹ÌÇØ¿ä.");
	printf("[rcon] ¿¹¸¦ µé¾î, '%s * 1000' ÀÌ¶ó°í ¾²¸é ¸ðµç »ç¶÷¿¡°Ô 1000´Þ·¯¸¦ ÁÖ´Â°ÅÁÒ.", GetCmdName(CMD_MCASH));
	printf("[rcon] ±âÅ¸ µµ¿ò¸» ¸ñ·ÏÀ» º¸½Ã·Á¸é '%s' ¸¦ ÀÔ·ÂÇÏ¼¼¿ä. ¾È³ç!\n", GetCmdName(CMD_HELP));	
	print(LINE);
}
//==========================================================
#endif /* SA-MP 0.3aÀÇ ´ÙÀÌ¾ó·Î±× ±â´É »ç¿ë */
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
		SendClientMessage( playerid, COLOR_GREY, "* °¡Àå °¡±îÀÌ ÀÖ´Â »ç¿ëÀÚ¸¦ Ã£½À´Ï´Ù.." );
		return GetClosestPlayer( playerid );
	}
	else if(params[0] == '?'  )
	{
		if ( !params[1] ) return INTERACTIVE_MANAGEMENT; //interactive management
		else if ( params[1] == '?' && !params[2] ) return HELP_PROCESS;
	}
	else if( checkadmin && (!strcmp( params, "Admin", true ) || !strcmp( params, "¿î¿µÀÚ", false)) ) return ADMIN_ID;
	return INVALID_PLAYER_ID;
}
//==========================================================
Post_Process( playerid, giveplayerid, Cmdorder:CMD_CURRENT, bool: process_interactive =true )
{
	//Á¤Á¦µÈ giveplayerid·Î ¸í·É¾î ½ÇÇà
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
			if( CONSOLE ) print("[rcon] ÄÜ¼Ö¿¡¼­´Â »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
			else SendClientMessage( playerid, COLOR_GREY, "* »ç¶÷ÀÌ ¾ø¾î »ç¿ëÇÒ ¼ö ¾ø½À´Ï´Ù.");
			return PROCESS_COMPLETE;
		}
		case INVALID_PLAYER_ID: //Processed Invalid input
		{
			if(CONSOLE) print("[rcon] Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
			else SendClientMessage(playerid,COLOR_GREY,"* Àß¸ø ÀÔ·ÂÇÏ¼Ì°Å³ª ÇöÀç Á¢¼ÓÁßÀÌ ¾Æ´Õ´Ï´Ù.");
			return PROCESS_COMPLETE;
		}
		case INTERACTIVE_MANAGEMENT: //Wildcard '?" enabled
		{
			if( process_interactive )
			{
				if( CONSOLE )
				{
					dcmd_stat ( playerid, NULL, CMD_STAT, NO_HELP );
					print("[rcon] ¿øÇÏ´Â ÇÃ·¹ÀÌ¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À. Ãë¼ÒÇÏ·Á¸é ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
				}
				else
				{
					#if SAMP02X
						dcmd_stat( playerid, NULL, CMD_STAT, NO_HELP );
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* ¿øÇÏ´Â ÇÃ·¹ÀÌ¾î¸¦ ÀÔ·ÂÇÏ½Ê½Ã¿À. Ãë¼ÒÇÏ·Á¸é ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
					#else
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* TABÀ» ´©¸£°í ¿øÇÏ´Â ÇÃ·¹ÀÌ¾î¸¦ ´õºíÅ¬¸¯ ÇÏ½Ê½Ã¿À. ¿ÍÀÏµåÄ«µå¸¦ ¾µ ¼öµµ ÀÖ½À´Ï´Ù.");
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* Ãë¼ÒÇÏ·Á¸é ?À» ÀÔ·ÂÇÏ½Ê½Ã¿À." );
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
		printf("[rcon] »ç¿ë¹ý: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS);
		printf("[rcon] ÀÚ¼¼ÇÑ »ç¿ë¹ýÀº µµ¿ò¸» %s À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.", CURRENT_CMD_NAME );
	}
	else
	{
		format( str, sizeof(str), "* »ç¿ë¹ý: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME,  CURRENT_PARAMS);
		SendClientMessage(playerid, COLOR_GREY, str );
		format( str, sizeof(str), "* ÀÚ¼¼ÇÑ »ç¿ë¹ýÀº /%s %s À»(¸¦) ÀÔ·ÂÇÏ¼¼¿ä.", GetCmdName(CMD_HELP), CURRENT_CMD_NAME );
		SendClientMessage(playerid, COLOR_GREY, str );
	}
	return 1;
}
//==========================================================
#if SAMP03b
//==========================================================
public UpdateCheck(index, response_code, data[])
{
	//debugprintf("[rcon] ÄÚµå: %d", response_code);
	//debugprintf("[rcon] data: %s",data);
	switch(response_code)
	{
		case HTTP_ERROR_CANT_CONNECT:
		{
			printf("[rcon] ¾÷µ¥ÀÌÆ® ¼­¹ö¿¡ ¿¬°áÇÒ ¼ö ¾ø½À´Ï´Ù.");
			return 1;
		}
		case 200: {}
		default:
		{
			printf("[rcon] ¾÷µ¥ÀÌÆ® È®ÀÎ¿¡ ½ÇÆÐÇß½À´Ï´Ù. ¿À·ù ÄÚµå: %d", response_code);
			return 1;
		}
	}

	new version, vstring[128], rdate[128];	
	if( sscanf( data, "p,iss", version, vstring, rdate ) )
	{
		print("[rcon] ¾÷µ¥ÀÌÆ® È®ÀÎ¿¡ ½ÇÆÐÇß½À´Ï´Ù. ¼­¹ö°¡ Á¿µÆ½À´Ï´Ù...¤Ð¤Ð");
		return 1;
	}
	
	if( version <= VERSION_INTERNAL )
	{
		printf("[rcon] ÇöÀç ÃÖ½Å ¹öÀüÀ» »ç¿ëÇÏ°í ÀÖ½À´Ï´Ù.");
		return 1;
	}	
	printf("[rcon] ¾÷µ¥ÀÌÆ® °¡´ÉÇÑ ¹öÀüÀÌ ÀÖ½À´Ï´Ù.\n  \
			***********************************\n  \
			* ÇöÀç ¹öÀü: %-12s         *\n  \
			* ÃÖ½Å ¹öÀü: %-12s         *\n  \
			* ¸±¸®Áî ³¯Â¥ : %s        *\n  \
			***********************************", VERSION, vstring, rdate );
	print("[rcon] cafe.daum.net/Coolpdt¸¦ ¹æ¹®ÇÏ¿© ÃÖ½Å ¹öÀüÀ» ´Ù¿î·Îµå¹ÞÀ¸½Ã±â ¹Ù¶ø´Ï´Ù.");
	//ÃÖ½Å ¹öÀüÀÇ Æú´õ·Î Á¢±Ù, ¸®½ºÆ® ÆÄÀÏÀ» ¾ò´Â´Ù.
	//new tmp[256];
	//format( tmp, sizeof(tmp), "dl.dropbox.com/u/8120060/SA-MP/%d/index.txt", version );
	//HTTP( UPDATE_FILELIST, HTTP_GET,  tmp, "", "UpdateCheck");
	return 1;
}
//==========================================================
#endif /* SA-MP 0.3bÀÇ ¾÷µ¥ÀÌÆ® ±â´É »ç¿ë */
//==========================================================
CreateDump()
{
	new File:hnd = fopen( FILE_DUMP, io_write ), str[512];
	if( !hnd )
	{
		print("[rcon] ´ýÇÁ »ý¼º¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
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
		CURRENT_VOTEKICK_REQUIREMENT,//ÅõÇ¥ ´ç½Ã¿¡ ÇÊ¿äÇÑ Âù¼ºÀÎ¿ø
		CURRENT_VOTEBAN_REQUIREMENT,//ÅõÇ¥ ´ç½Ã¿¡ ÇÊ¿äÇÑ Âù¼ºÀÎ¿ø
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
	
	//ÅõÇ¥°¡ ÁøÇàÁßÀÌ¾ú´ø °æ¿ì Áßº¹ÅõÇ¥ °Ë»ç°ª ÀúÀåÇÏ±â
	if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
	{
		for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
		{
			c_fwrite( hnd, RetStr(KICKVOTED_PLAYER_IP[i]) );
		}
	}
	//ÅõÇ¥°¡ ÁøÇàÁßÀÌ¾ú´ø °æ¿ì Áßº¹ÅõÇ¥ °Ë»ç°ª ÀúÀåÇÏ±â
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
		//print("[rcon] ÀüÃ¼ ´ýÇÁ¸¦ »ý¼ºÁßÀÔ´Ï´Ù...");
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
	//print("[rcon] ´ýÇÁ »ý¼ºÀ» ¿Ï·áÇß½À´Ï´Ù.");
}
//==========================================================
CallDump()
{
	new File:hnd = fopen( FILE_DUMP, io_read ), str[512], idx, FULLDUMP;
	if( !hnd ) print("[rcon] ´ýÇÁ ÀÌ½Ä¿¡ ½ÇÆÐÇß½À´Ï´Ù.");
	else
	{
		fread( hnd, str );
		StripNL( str );
		if( tickcount() - strval( str ) > 1000 || tickcount() - strval( str ) < 0 ) print("[rcon] ´ýÇÁ ÆÄÀÏÀÌ ³°¾Æ ÀÌ½ÄÇÏÁö ¾Ê°í Æó±âÇÕ´Ï´Ù.");
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
			
			ENABLE_VOTEKICK = strval(strtok( str, idx, ',' ));//ÅõÇ¥ È°¼ºÈ­
			ENABLE_VOTEBAN = strval(strtok( str, idx, ',' ));
			VOTEKICK_RUN_TIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_RUN_TIME = strval(strtok( str, idx, ',' )); //ÅõÇ¥ µ¹¸®´Â ½Ã°£
			VOTEKICK_NOTIFY_DURATION = strval(strtok( str, idx, ',' ));
			VOTEBAN_NOTIFY_DURATION = strval(strtok( str, idx, ',' )); // ÅõÇ¥»óÈ² °øÁö ÁÖ±â
			VOTE_CONFIDENTIALITY = strval(strtok( str, idx, ',' )); // ÅõÇ¥ ½Å°íÀÎ ¸í½Ã¿©ºÎ
			REQUIRED_MAN_VOTEKICK = strval(strtok( str, idx, ',' ));
			REQUIRED_MAN_VOTEBAN = strval(strtok( str, idx, ',' ));// °­Á¦Ãß¹æÀ» ½ÃÀÛÇÒ ÃÖ¼ÒÀÎ¿ø
			MINIMUM_VOTEKICK_PERCENTAGE = strval(strtok( str, idx, ',' )); // °­Á¦Ãß¹æ±îÁö ÇÊ¿äÇÑ µæÇ¥À²
			MINIMUM_VOTEBAN_PERCENTAGE = strval(strtok( str, idx, ',' ));
			
			VOTEKICK_PLAYER = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER = strval(strtok( str, idx, ',' )); //´ë»ó ÇÃ·¹ÀÌ¾î ¾ÆÀÌµð
			VOTEKICK_PLAYER_GOT = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER_GOT = strval(strtok( str, idx, ',' ));	//¹ÞÀº Ç¥
			VOTEKICK_REMAINTIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_REMAINTIME = strval(strtok( str, idx, ',' )); //³²Àº ½Ã°£
			CURRENT_VOTEKICK_REQUIREMENT = strval(strtok( str, idx, ',' ));//ÅõÇ¥ ´ç½Ã¿¡ ÇÊ¿äÇÑ Âù¼ºÀÎ¿ø
			CURRENT_VOTEBAN_REQUIREMENT = strval(strtok( str, idx, ',' ));//ÅõÇ¥ ´ç½Ã¿¡ ÇÊ¿äÇÑ Âù¼ºÀÎ¿ø
			VOTEKICK_TICK = strval(strtok( str, idx, ',' )); // °­Á¦Ãß¹æ °øÁö µ¹¸®´Â Å¸ÀÌ¸Ó
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
			
			//ÅõÇ¥°¡ ÁøÇàÁßÀÌ¾ú´ø °æ¿ì Áßº¹ÅõÇ¥ °Ë»ç°ª ºÒ·¯¿À±â
			if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
			{
				for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					KICKVOTED_PLAYER_IP[i] = strval(str);//Áßº¹ÅõÇ¥ ¹æÁö¿ë IPÀúÀå¼Ò
				}
			}
			//ÅõÇ¥°¡ ÁøÇàÁßÀÌ¾ú´ø °æ¿ì Áßº¹ÅõÇ¥ °Ë»ç°ª ºÒ·¯¿À±â
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
				//print("[rcon] ÀüÃ¼ ´ýÇÁ¸¦ ÀÌ½ÄÁßÀÔ´Ï´Ù...");
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
			//print("[rcon] ´ýÇÁ ÀÌ½ÄÀ» ¿Ï·áÇß½À´Ï´Ù.");
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
		print("[ERROR] RC_yell.ini¸¦ Ã£À» ¼ö ¾ø½À´Ï´Ù. ¿åÇÊÅÍ ±â´ÉÀÌ Á¦ÇÑµË´Ï´Ù.");
		print(" scriptfiles\\MINIMINI Æú´õ¿¡ RC_yell.ini¸¦ ³Ö¾îÁÖ¼¼¿ä.");
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
	print("[rcon] ¼­¹ö°¡ ´Ù½Ã Àá±Ý»óÅÂ·Î ¼³Á¤µÇ¾ú½À´Ï´Ù.");
}
//==========================================================
IsCmdNeedToHide(cmd[])
{
	static hidecmds[][]=
	{
		"/ºÎ¿î·Î±×ÀÎ",
		"/sublogin",
		"/log",
		"/reg",
		"/·Î±×ÀÎ"
	};
	for(new i=0;i<sizeof(hidecmds);i++) if(!strcmp(cmd,hidecmds[i],true,strlen(hidecmds[i]))) return 1;
	return 0;
}
//==========================================================
LoadPlayerAuthProfile(playerid,profile_id)
{
	if(profile_id == 0) //±âº» ¼³Á¤: ¸ðµç ±ÇÇÑ
	{
		for(new i = 2 ; i < NUM_AUTH ; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 1;
		SendClientMessage(playerid,COLOR_IVORY,"* ±ÇÇÑ '¸ðµç ±ÇÇÑ'(0)ÀÌ ÁÖ¾îÁ³½À´Ï´Ù.");
		return true;
	}
	for( new i = 2; i < NUM_AUTH; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 0;
	new i = 2,File:fhnd,str[MAX_STRING];
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	str=join("MINIMINI/",c_iniGet("[SubAdmin]",str));
	if(!fexist(str))
	{
		format(str,sizeof(str),"* RconController.iniÀÇ Auth_Profile%d¿¡ ±â·ÏµÈ ÆÄÀÏÀ» Ã£À» ¼ö ¾ø½À´Ï´Ù.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] RconController.iniÀÇ Auth_Profile%d¿¡ ±â·ÏµÈ ÆÄÀÏÀ» Ã£À» ¼ö ¾ø½À´Ï´Ù.",profile_id);
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
		format(str,sizeof(str),"* ±ÇÇÑ ÇÁ·ÎÇÊ %d¹ø¿¡ ÀÌ»óÀÌ ÀÖ½À´Ï´Ù. ÆÄÀÏÀ» È®ÀÎÇØÁÖ¼¼¿ä.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] ±ÇÇÑ ÇÁ·ÎÇÊ %d¹ø¿¡ ÀÌ»óÀÌ ÀÖ½À´Ï´Ù. ÆÄÀÏÀ» È®ÀÎÇØÁÖ¼¼¿ä.",profile_id);
	}
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	format(str,sizeof(str),"* ±ÇÇÑ %s(%d)ÀÌ ÁÖ¾îÁ³½À´Ï´Ù.",(profile_id)? (c_iniGet("[SubAdmin]",str)):("¸ðµç ±ÇÇÑ"),profile_id);
	SendClientMessage(playerid,COLOR_IVORY,str);
	return true;
}
//==========================================================
CheckNoticeList()
{
	Num_Notice=0;
	new File:fhnd, str[256], line;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//°øÁö°¡ ½ÃÀÛµÉ¶§±îÁö ºü¸¥ ½ºÅµ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===°øÁö ½ÃÀÛ===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//ÁÙ ÀÚ¸£°í, ÁÖ¼®°ú ´Ü¼ø¿£ÅÍ´Â ½ºÅµ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//°øÁö°¡ ³¡³­ °æ¿ì		
		if( !strcmp( str, "===°øÁö ³¡===" ) )
		{
			if( line ) Num_Notice++;
			break;
		}
		line++;		
		//±¸ºÐ¼±À» ¸¸³­ °æ¿ì
		if( !strcmp( str, "===±¸ºÐ¼±===" ) )
		{
			Num_Notice++;
			continue;
		}
		//±¸¹®¿À·ù È®ÀÎ
		if( str[0] == '<' && strfind( str, ">" ) == -1 )
		{
			printf( "[rcon] °øÁö ±¸¹®¿¡ ¿À·ù°¡ ÀÖ½À´Ï´Ù! °øÁö¸¦ »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.\n ¿À·ù ¹®Àå : %s", str);
			format( str, sizeof(str), "* °øÁö ±¸¹®¿¡ ¿À·ù°¡ ÀÖ½À´Ï´Ù! °øÁö¸¦ »ç¿ëÇÏÁö ¾Ê½À´Ï´Ù.\n ¿À·ù ¹®Àå : %s", str);
			SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
			NOTICE_INTERVAL = 0;
			break ;
		}
	}	
	fclose(fhnd);
	//°øÁö°¡ ¾ø´Â °æ¿ì
	if( Num_Notice == 0 )
	{
		printf( "[rcon] °øÁö°¡ ¾ø½À´Ï´Ù. °øÁö ±â´ÉÀ» ºñÈ°¼ºÈ­ÇÕ´Ï´Ù.");
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,"* °øÁö°¡ ¾ø½À´Ï´Ù. °øÁö ±â´ÉÀ» ºñÈ°¼ºÈ­ÇÕ´Ï´Ù.");
		NOTICE_INTERVAL = 0;
	}
}
//==========================================================
SendPlayerNotice(index)
{
	new File:fhnd, curidx = 1, str[256], color, stridx;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//°øÁö°¡ ½ÃÀÛµÉ¶§±îÁö ºü¸¥ ½ºÅµ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===°øÁö ½ÃÀÛ===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//ÁÙ ÀÚ¸£°í, ÁÖ¼®°ú ´Ü¼ø¿£ÅÍ´Â ½ºÅµ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//°øÁö°¡ ³¡³­ °æ¿ì ½ºÅ©¸³Æ® ÁßÁö
		if( !strcmp( str, "===°øÁö ³¡===" ) ) break;
		//±¸ºÐ¼±À» ¸¸³­ °æ¿ì
		if( !strcmp( str, "===±¸ºÐ¼±===" ) ) 
		{
			if( curidx == index ) break; //°øÁö¸¦ ¿Ã¸®´Â ÁßÀÌ¾ú´ø °æ¿ì ÁßÁö
			curidx++; //ÀÎµ¦½º Áõ°¡
			continue;
		}
		//ÀÎµ¦½º¿¡ µµ´ÞÇÒ ¶§±îÁö ÁøÇà
		if( curidx != index ) continue;
		/* ¸ÖÆ¼¶óÀÎ °øÁö¸¦ ÀÐ´Â´Ù */
		stridx = 0; //±âº»°ª Àû¿ë
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //»ö±ò ÇÚµé·¯ È®ÀÎ
		{
			//°øÁö¶ç¿ï¶§ÀÇ ÀÎµ¦½º ÁöÁ¤
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX°ªÀÇ °æ¿ì Á÷Á¢ ÁöÁ¤
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//¹Ì¸® ¼³Á¤µÈ »ö±ò
			else if ( !strcmp( str[1], "»¡°­" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "ÆÄ¶û" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "¹àÀº ÆÄ¶û" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "³ë¶û" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "ÇÎÅ©" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "¹«ÀûÇÎÅ©" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "³ì»ö" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "¶óÀÓ" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "Èò»ö" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "½Ã½ºÅÛ" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "È¸»ö" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "°¥»ö" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "Ã»·Ï»ö" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "¿À·»Áö" ) ) color = COLOR_ORANGE;
		}
		//°øÁö ¶ç¿ì±â
		printf("[rcon] °øÁö - %s", str[stridx] );
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
//If ¹®À¸·Î °É·¯ÁÖ´Â°æ¿ì - SubAdmin Á¡°Ë¾ÈÇÔ
#define dcmd_auth(%1,%2,%3,%4) \
	if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32)&& \
	(((CONSOLE||IsPlayerAdmin(playerid)||AuthorityCheck(playerid,%4))&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))|| \
	(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid,COLOR_RED,"* ÇØ´ç ¸í·É¾î¸¦ »ç¿ëÇÒ ±ÇÇÑÀÌ ¾ø½À´Ï´Ù."))) return 1
//If ¹®À¸·Î °É·¯ÁÖÁö¾Ê´Â°æ¿ì - SubAdmin Á¡°ËÇÔ
#define dcmd_auth(%1,%2,%3,%4) if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32) \
	&&((AuthorityCheck(playerid,%4)&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))||(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid, COLOR_RED, "* ÇØ´ç ¸í·É¾î¸¦ »ç¿ëÇÒ ±ÇÇÑÀÌ ¾ø½À´Ï´Ù."))) return 1
*/


