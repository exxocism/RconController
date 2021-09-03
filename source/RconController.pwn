/*==========================================================
		"Rcon Controller" Filterscript for SA-MP
	Copyright (C) 2008-2015 CoolGuy(��Ծ���)

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
	���� - CoolGuy(��Ծ���)

�ֱ��� �ҽ��ڵ� ���� ������ changelog.txt�� �����Ͻʽÿ�.

"Rcon Controller" �� ���α׷� ����ī�� :
http://cafe.daum.net/Coolpdt
//=========================================================*/
//==========================================================
// Informations & Compile Options
//==========================================================
#define VERSION "V18 alpha3"
#define VERSION_INTERNAL 1803
#define MAX_SUBADMIN 20 //�߰� ������ �ο���� ���Դϴ�.
#define MAX_YELLS 200 //�߰� ������ ���� �����Դϴ�.
#define MAX_YELL_CHAR 64 //�ִ�� �߰��� �� �ִ� ���� �����Դϴ�.
#define MAX_BAD_PLAYERS 200 //�ִ�� ������ �� �ִ� ��ų� �÷��̾��� ���Դϴ�.
/* ���� ���� ȣȯ�� */
#define SAMP02X false //0.2X ȣȯ ������ : ���� ���� �ɼ��� ��� �����Ͻñ� �ٶ��ϴ�.
#define SAMP03a true //0.3a ���� �߰��� ���(GUI, RCON ���)���
#define SAMP03b true //0.3b ���� �߰��� ���(������Ʈ Ȯ��) ���
#define SAMP03x true //0.3x ���� �߰��� ��� ���
#define SAMP03z true //0.3z ���� �߰��� ��� ���(�ݹ� �Լ�)
#define PLUGIN false //�÷����� ���
#define COPYRIGHT_STRING "Copyright (c) 2008-2015 CoolGuy"



//==========================================================
// Includes
//==========================================================
#include <a_samp>
#if SAMP03b /* SA-MP 0.3b��  ��� ��� */
	#include <a_http>
#endif
#if PLUGIN /* �÷����� ���� */
	#include "filemanager"
#endif
#include "dutils"
#define _COOLGUY_NO_SUBADMIN
#include "coolguy" //CoolGuy's Standard Header
#include "y_bintree.inc" //Binary Tree


//=========================================================
// General Macros & Magic Numbers �� �Ʒ� �����Ʒ� �� �Ʒ� �����Ʒ�
//=========================================================
//���� ��� ����
#define FILE_SETTINGS "MINIMINI/RconController.ini"
#define FILE_YELLFILTER "MINIMINI/RC_Yells.ini"
#define FILE_DUMP "RC_Dump.txt"
#define FILE_FIRSTRUN "MINIMINI/firstrun"
#define DUMPEXIST fexist(FILE_DUMP)

//�ܼ� �ν� ����
#define ADMIN_ID MAX_PLAYERS
#define CONSOLE (playerid == ADMIN_ID)

//������ ����
#define MAX_WEAPONS 55

//��Ģ ����
#define PUNISH_FREEZE 0
#define PUNISH_SHUTUP 1
#define PUNISH_CMDRESTRICT 2
#define KICK_THIS_PLAYER -100
#define BAN_THIS_PLAYER -500

/* GUI ���� */
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
#if SAMP03b /* SA-MP 0.3b�� ������Ʈ ��� ��� */
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
#define No_Console() if(CONSOLE) return !print("[rcon] �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.")
#define No_Wildcard() (CONSOLE)? ((print("[rcon] ���ϵ�ī�带 ����� �� ���� ��ɾ��Դϴ�.") ^ 1)):(SendClientMessage(playerid, COLOR_GREY, "* ���ϵ�ī�带 ����� �� ���� ��ɾ��Դϴ�."))
#define STUB() print("stub")
#define SEND() SendClientMessage( playerid, COLOR_LIME, str )
#define SEND_C(%1) SendClientMessage( playerid, %1, str )

//�ڵ� ��ɾ� �ڵ鷯 : ������ �ӵ� ���
#define rcmd(%1,%2,%3) if((strcmp(cmds[1],(%1),true,(%2))==0) && (((cmds[(%2)+1]==0) && (rcmd_%3("")))||((cmds[(%2)+1]==32) && (rcmd_%3(cmds[(%2)+2]))))) return 1
#if SAMP03a /* SA-MP 0.3a�� ���̾�α� ��� ��� */
	#define gcmd(%1,%2) case %1: return dialog_%2(playerid,response,listitem,inputtext)
#endif

//����׿�
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
//���� Ÿ�̸�
enum Timerinfo
{
	CmdFlood,
	ChatFlood,
	ResetPing
}

#if SAMP03a /* SA-MP 0.3a�� ���̾�α� ��� ��� */
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

	/* ������ ���� ���� */
	USE_PINGCHECK=1, //������ ���
	HIGHPING_LIMIT, //�����ð� ���
	HIGHPING_WARN_LIMIT, //�����ð� ���Ƚ�� �Ӱ谪
	PINGCHECK_DURATION, //������ �ֱ�
	HIGHPING_WARNED_TIMES[MAX_PLAYERS], //���� �����ð����� ������ Ƚ��
	PLAYER_JUST_CONNECTED[MAX_PLAYERS] = {5, ...}, //���� �ڵ鸵�� ������ �ֱ� ����
	RESET_HIGHPING_TICK, //���Ƚ�� �ʱ�ȭ �ֱ�
	/* �����߹� ���� ���� */
	ENABLE_VOTEKICK,//��ǥ Ȱ��ȭ
	ENABLE_VOTEBAN,
	VOTEKICK_RUN_TIME, VOTEBAN_RUN_TIME, //��ǥ ������ �ð�
	VOTEKICK_NOTIFY_DURATION, VOTEBAN_NOTIFY_DURATION, // ��ǥ��Ȳ ���� �ֱ�
	VOTE_CONFIDENTIALITY, // ��ǥ �Ű��� ��ÿ���
	REQUIRED_MAN_VOTEKICK,
	REQUIRED_MAN_VOTEBAN, // �����߹��� ������ �ּ��ο�
	MINIMUM_VOTEKICK_PERCENTAGE, // �����߹���� �ʿ��� ��ǥ��
	MINIMUM_VOTEBAN_PERCENTAGE,
	//ingame variables
	VOTEKICK_PLAYER = INVALID_PLAYER_ID,
	VOTEBAN_PLAYER = INVALID_PLAYER_ID, //��� �÷��̾� ���̵�
	VOTEKICK_PLAYER_GOT,
	VOTEBAN_PLAYER_GOT,	//���� ǥ
	VOTEKICK_REMAINTIME,
	VOTEBAN_REMAINTIME, //���� �ð�
	CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS, //��ǥ�� ������ ����� �ʿ� �����ο�
	CURRENT_VOTEBAN_REQUIREMENT,
	VOTEKICK_TICK, // �����߹� ���� ������ Ÿ�̸�
	VOTEBAN_TICK,
	KICKVOTED_PLAYER_IP[MAX_PLAYERS], //�ߺ���ǥ ������ IP�����
	BANVOTED_PLAYER_IP[MAX_PLAYERS],
	
	POLICY_RCON_LOGINFAIL_INTERNAL, //���� ������ Rcon Login���н��� ������å
	MAX_RCONLOGIN_ATTEMPT, //�ִ� Rcon Login���� �ѵ�
	
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
	
#if SAMP03a /* SA-MP 0.3a�� ���̾�α� ��� ��� */
	new DIALOG_CLICKED_PLAYER[MAX_PLAYERS];
	new WEAPON_STORAGE[][Weapon_info] =
	{
		{"�극�� ��Ŭ", 1},
		{"����ä", 2},
		{"������", 3},
		{"����", 4},
		{"�߱������", 5},
		{"��", 6},
		{"�籸ä", 7},
		{"�Ϻ���", 8},
		{"������", 9},
		{"����", 10},
		{"����2", 11},
		{"���̺극����", 12},
		{"���̺극����2", 13},
		{"��", 14},
		{"������", 15},
		{"����ź", 16},
		{"�ַ簡��", 17},
		{"ȭ����", 18},
		{"��Ʈ 45", 22},
		{"��Ʈ (������ ����)", 23},
		{"����Ʈ �̱�", 24},
		{"��ź�� (�ܹ�)", 25},
		{"��ź�� (4����)", 26},
		{"��ź�� (7����)", 27},
		{"UZI", 28},
		{"MP-5", 29},
		{"AK-47", 30},
		{"M4", 31},
		{"TEC-9", 32},
		{"������", 33},
		{"�������� ������", 34},
		{"���� ��ó", 35},
		{"������ ����", 36},
		{"ȭ������", 37},
		{"�̴ϰ�", 38},
		{"��ź����", 39},
		{"��ź ��ȭ��", 40},
		{"�������� ĵ", 41},
		{"��ȭ��", 42},
		{"ī�޶�", 43},
		{"���ϻ�", 46}
	};
	new VEHICLE_STORAGE[][Weapon_info] =
	{
		{"���丣��", 411},
		{"��ź", 560},
		{"�Ǵн�", 603},
		{"�Ѿ�", 541},
		{"������", 562},
		{"�ý�", 420},
		{"����", 431},
		{"FBI ����", 490},
		{"���� Ʈ��", 556},
		{"FBI Ʈ��", 528},
		{"����ũ", 601},
		{"�ݰ� ����", 609},
		{"BMX ������", 481},
		{"���ڹ�� �������", 448},
		{"��������", 463},
		{"PCJ-600", 461},
		{"��ü��", 468},
		{"NRG-500", 522},
		{"���� �������", 523},
		{"���� ��ũ", 432},
		{"īƮ", 571},
		{"Ʈ����", 531},
		{"�޹���", 532},
		{"AT-400", 577},
		{"���������", 593},
		{"Shamal", 519},
		{"�����", 520},
		{"����", 425},
		{"���", 487},
		{"�ؾ����", 447}
	};
	new MUSIC_STORAGE[][Weapon_info] =
	{
		{"�´� �Ҹ�", 1002},
		{"�ε����� �Ҹ�", 1009},
		{"��ġ�Ҹ�", 1130},
		{"�����ϴ� �Ҹ�", 1140},
		{"�����б� ����", 1187},
		{"������� 1", 1097},
		{"�����б� ����", 1183},
		{"������� �б� ����", 1185}
	};
#endif

/***********************************************************/
/* SPECIAL DECLARATION SET ********************************/
/***********************************************************/

//==========================================================
// �ο�� ����
//==========================================================
#define IsPlayerSubAdmin(%1) PLAYER_AUTHORITY[(%1)][AUTH_SUBADMIN]
#define SetPlayerSubAdmin(%1,%2) PLAYER_AUTHORITY[%1][AUTH_SUBADMIN]=1;LoadPlayerAuthProfile(%1,%2)
#define UnSetPlayerSubAdmin(%1) for( new subvar = 1;  subvar < NUM_AUTH; subvar++ ) PLAYER_AUTHORITY[(%1)][Authinfo:subvar] = 0
#define AuthorityCheck(%1,%2) PLAYER_AUTHORITY[%1][%2]
#define SendAdminMessageAuth(%1,%2,%3) for(new sendmsg=0;sendmsg<NUM_PLAYERS;sendmsg++) if(IsPlayerAdmin(pITT[sendmsg]) || (IsPlayerSubAdmin(pITT[sendmsg]) && AuthorityCheck(pITT[sendmsg],%1))) SendClientMessage(pITT[sendmsg],%2,%3)
#define PERMANENT_ADMINSAY(%1) PERMANENT_ADMINSAY[%1]
#if SAMP03a /* SA-MP 0.3a�� ���̾�α� ��� ��� */
	#define Auth_Check(%1) if(IsPlayerSubAdmin(playerid) && !AuthorityCheck(playerid,(%1)) && SendClientMessage(playerid,COLOR_RED,"* �ش� ��ɾ ����� ������ �����ϴ�.")) return 1
#endif

//�⺻ �ο�� ����
enum SUBINFO 
{
	Name[MAX_PLAYER_NAME],
	Password_Hash,
	IP[16],
	profile_index //���� ������ ��ȣ
}

//���� ���
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

//���� ���� 
new 
	PLAYER_AUTHORITY[MAX_PLAYERS][Authinfo],
	SubAdmin[MAX_SUBADMIN][SUBINFO],
	//�ο�� ���, �ε� ��� ���������� ����
	Num_SubAdmin, LOAD_SUBADMIN=1,
	SUBADMIN_FAILLOGIN_TIMES[MAX_PLAYERS],
	SUBADMIN_FAILLOGIN_LIMIT=3;
	


//==========================================================
// ��ɾ� ����ȭ
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

//��ɾ� ����
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

//��ɾ� ����
new cmdlist[Cmdorder][Cmdinfo] = 
{
	{"��", "say", AUTH_CMD_SAY}, 									{"�����", "psay",AUTH_CMD_SAY}, 						{"�Ӹ�", "spm",AUTH_NONE},
	{"ű", "skick", AUTH_CMD_KICK}, 									{"��", "sban", AUTH_CMD_BAN}, 								{"������ǥ", "vkick", AUTH_NONE}, 							{"������ǥ", "vban", AUTH_NONE}, 
	{"�ſ���ȣ", "confidential", AUTH_CMD_VOTE},				{"��Ǯ��", "unban", AUTH_CMD_UNBAN},					{"ip��Ǯ��",  "unbanip", AUTH_CMD_UNBAN}, 
	{"���", "with", AUTH_CMD_WITH}, 								{"��ȯ", "call", AUTH_CMD_CALL}, 							{"����", "spectate", AUTH_CMD_SPECTATE},
	{"��������", "specoff", AUTH_CMD_SPECTATE}, 			{"���", "skill", AUTH_CMD_KILL}, 								{"ü����", "sethp", AUTH_CMD_SETHEALTH},
	{"����", "infinite", AUTH_CMD_SETHEALTH}, 				{"�Ƹ�", "armor", AUTH_CMD_SETARMOR}, 				{"�Ƹӹ���", "infarmor", AUTH_CMD_SETARMOR},
	{"���ֱ�", "mcash", AUTH_CMD_CASH},						{"����Ż", "forfeit", AUTH_CMD_FORFEIT}, 				{"������", "setcash", AUTH_CMD_CASH},
	{"���ھ�", "score", AUTH_CMD_SETSCORE}, 				{"�����ֱ�", "givewp", AUTH_CMD_GIVEWEAPON}, 	{"�����Ż", "disarm", AUTH_CMD_DISARM}, 
	{"������", "freeze", AUTH_CMD_FREEZE},					{"��������", "unfrz", AUTH_CMD_UNFREEZE}, 			{"����ȯ", "spcar", AUTH_CMD_SPAWNCAR},
	{"������", "drop",  AUTH_CMD_SPECTATE}, 				{"��������", "carhp", AUTH_CMD_CARENERGY},		{"������", "fixcar", AUTH_CMD_CARENERGY},
	{"��Ʈ��", "jpack",  AUTH_CMD_JETPACK},
	{"�Ҹ�", "sound", AUTH_CMD_SOUND},						{"�Ҹ�����", "mute", AUTH_CMD_SOUND}, 				{"��ź", "bomb", AUTH_CMD_BOMB},	
	{"�йٲٱ�", "chnick", AUTH_CMD_CHANGENICK},		{"ä��", "shutup", AUTH_CMD_SHUTUP}, 					{"ä������", "unshut", AUTH_CMD_UNSHUT},
	{"������", "yell", AUTH_CMD_YELLFILTER},					{"���߰�", "addyell", AUTH_CMD_YELLFILTER}, 		{"������", "delyell", AUTH_CMD_YELLFILTER},
	{"����","chatflood",AUTH_CMD_SHUTUP},					{"��ɾ��", "cmdflood", AUTH_CMD_SHUTUP}, 	{"������", "wpcheat", AUTH_CMD_ANTICHEAT},
	{"�����߰�", "addwc", AUTH_CMD_ANTICHEAT}, 			{"��������", "delwc", AUTH_CMD_ANTICHEAT}, 		{"��Ʈ����", "jpcheat", AUTH_CMD_ANTICHEAT},
	{"���", "desync", AUTH_CMD_DESYNC},						{"������", "ping", AUTH_CMD_PINGCHECK}, 			{"������", "plimit", AUTH_CMD_PINGCHECK},
	{"�ΰ��", "pwarntime", AUTH_CMD_PINGCHECK}, 		{"���ʱ�ȭ", "preset", AUTH_CMD_PINGCHECK}, 	
	{"�ο�", "subadmin", AUTH_CMD_SETSUBADMIN}, 		{"�ο�α���", "sublogin", AUTH_NONE}, 					{"�ο�����", "subout", AUTH_SUBADMIN},
	{"�ο��Ż", "suspend", AUTH_CMD_DELSUBADMIN}, 	{"�ο�ε�", "reloadsubs", AUTH_CMD_AUTH}, 
	{"���Ѻ���", "chauth", AUTH_CMD_AUTH}, 					{"���Ѹ��", "authlist", AUTH_CMD_AUTH}, 				{"������", "myauth", AUTH_SUBADMIN}, 
	{"��ɾ�����", "cmdtrace", AUTH_CMDTRACE}, 			{"ȣ��", "mks", AUTH_CMD_MAKESOUND}, 				{"����", "weather", AUTH_CMD_WEATHER}, 
	{"�߷�", "gravity", AUTH_CMD_GRAVITY}, 						{"�ð�", "wtime", AUTH_CMD_WTIME}, 						{"����", "find", AUTH_CMD_USERINFO},
	{"����",  "stat", AUTH_CMD_USERINFO}, 						{"����", "notice", AUTH_CMD_NOTICE},					{"�������", "nlist", AUTH_CMD_NOTICE},
	{"�����ε�", "reloadnotice", AUTH_CMD_NOTICE},		{"��������", "saveconfig", AUTH_CMD_CONFIG}, 		{"�����ε�", "loadconfig", AUTH_CMD_CONFIG},
	{"��������", "viewconfig", AUTH_NONE},						{"������ױ�", "locksvr", AUTH_CMD_LOCKSERVER},
#if SAMP03a
	{"����â", "gui", AUTH_SUBADMIN},
#endif
	{"����1", "rchelp", AUTH_NONE},								{"����2", "rchelp2", AUTH_NONE}, {"��������", "rconcontroller", AUTH_NONE}
};

//��ɾ ���� ���� (�Ķ����)
new Help_Params[Cmdorder][128] = {
	"[�Ҹ�]", 													" ", 																	"[�̸��̳� ��ȣ] [�Ҹ�]", 																//��, �����, �Ӹ�
	"[�̸��̳� ��ȣ] [����=����]", 					"[�̸��̳� ��ȣ] [����=����]", 							"[�̸��̳� ��ȣ]", 									"[�̸��̳� ��ȣ]",			//ű, ��, ������ǥ, ��������
	" ", 															"[���̵�]",														"[������]",																					//�ſ���ȣ, ��Ǯ��, ip��Ǯ��
	"[�̸��̳� ��ȣ]",										"[�̸��̳� ��ȣ, * = ���]", 								"[�̸��̳� ��ȣ]",																			//���, ��ȯ, ����
	" ",															"[�̸��̳� ��ȣ]",												"[�̸��̳� ��ȣ], [ü��]",																//��������, ���, ü����
	"[�̸��̳� ��ȣ]",										"[�̸��̳� ��ȣ] [�Ƹ�]",									"[�̸��̳� ��ȣ]",																			//����, �Ƹ�, �Ƹӹ���
	"[�̸��̳� ��ȣ] [��]",								"[�̸��̳� ��ȣ]",												"[�̸��̳� ��ȣ] [��]",																	//���ֱ�, ����Ż, ������
	"[�̸��̳� ��ȣ] [����]",							"[�̸��̳� ��ȣ] [�����ȣ] [�Ѿ�=3000��]",	"[�̸��̳� ��ȣ]",																			//���ھ�, �����ֱ�, �����Ż
	"[�̸��̳� ��ȣ] [�ð�=����]",					"[�̸��̳� ��ȣ]",												"[�̸��̳� ��ȣ] [��]",																//������, ��������, ����ȯ
	"[�̸��̳� ��ȣ]",										"[�̸��̳� ��ȣ] [������]",								"[�̸��̳� ��ȣ]",																			//������, ��������, ������
	"[�̸��̳� ��ȣ]",																																																					//��Ʈ��
	"[�̸��̳� ��ȣ, * = ���] [�Ҹ���ȣ]",		"[�̸��̳� ��ȣ]",												"[�̸��̳� ��ȣ]",																			//�Ҹ�, �Ҹ�����, ��ź
	"[�̸��̳� ��ȣ] [�г���]",						"[�̸��̳� ��ȣ] [��=����]",								"[�̸��̳� ��ȣ]",																			//�йٲٱ�, ä��, ä������
	" ",															"[�߰��� ��]",													"[������ ��]",																				//������, ���߰�, ������
	" ",															" ",																	" ",																								//����, ��ɾ��, ������
	"[������ �����ȣ]",									"[����� �����ȣ]",											" ",																								//�����߰�, ��������, ��Ʈ����
	"[0=�ٷ��߹� 1=�����ð� 2=�߹����]",		" ",																	"[������ �����ð�(ms)]",																//���, ������, ������
	"[�߹��� ����� Ƚ��]",								"[������ �ʱ�ȭ �ð�, 0=������]",																														//�ΰ��, ���ʱ�ȭ
	"[�̸��̳� ��ȣ]",										"[��й�ȣ]",													" ",																								//�ο�, �ο�α���, �ο�����
	"[�̸��̳� ��ȣ]",										" ",																																										//�ο��Ż, �ο�ε�
	"[�̸��̳� ��ȣ] [���ѹ�ȣ=0]",				" ",																	" ",																								//���Ѻ���, ���Ѹ��, ������
	" ",															"[������ Ƚ��] [�Ҹ�]",										"[����: 0~1337]",																			//��ɾ�����, ȣ��, ����
	"[�߷�=0.008, -50~+50]",							"[�ð�: 0~23]",													"[�̸��̳� ��ȣ]",																			//�߷�, �ð�, ����
	" ",															"[������ ��� ����:��]",									" ",																								//����, ����, �������
	" ",															" ",																	" ",																								//�����ε�, ��������, �����ε�
	" ",															" ",																																										//��������, ������ױ�
#if SAMP03a
	"[�̸��̳� ��ȣ]",																																																					//����â
#endif
	" ",															" ",																	" "																								//����1, ����2, ��������
};

// ���̳ʸ� Ʈ�� & �ؽ� : ��ɾ� �˻��ӵ� ����
new BinaryTree:TREE_CMDLIST_HANGUL<sizeof(cmdlist)>;
new BinaryTree:TREE_CMDLIST_ENGLISH<sizeof(cmdlist)>;

//��ȭ�� ���ü��
#define ALL_PLAYER_ID INVALID_PLAYER_ID+1
#define ABORT_PROCESS INVALID_PLAYER_ID+2
#define INTERACTIVE_MANAGEMENT INVALID_PLAYER_ID+3
#define PROCESS_COMPLETE INVALID_PLAYER_ID+4
#define HELP_PROCESS INVALID_PLAYER_ID+5
#define CMD_INVALID Cmdorder:sizeof(cmdlist)
new Cmdorder:INTERACTIVE_COMMAND[MAX_PLAYERS+1] = { CMD_INVALID, ... };
new INTERACTIVE_STATE[MAX_PLAYERS+1];

//����
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
#if !SAMP02X /* SA-MP 0.2X ȣȯ ������ */
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
	print("                   Copyright (C) 2008 - 2013 CoolGuy(��Ծ���) \n");
#if SAMP02X
	print("[rcon] SA-MP 0.2X ȣȯ ���� �۵����Դϴ�.");
#endif

	//���ʻ���� Ȯ��
	if( fexist(FILE_FIRSTRUN) )
	{
		SetTimer("Firstrun",1000,0);
		fremove(FILE_FIRSTRUN);
	}	

	//�ִ� �����ڼ��� ���Ѵ�.
	M_P = GetMaxPlayers();
	//����� �̸� ����
	PLAYER_NAME[ADMIN_ID] = "Admin";
	
	//���ͽ�ũ��Ʈ�� �����Ҷ� �ʿ��� �۾� ����
	IS_HEAR_CMDTRACE[ADMIN_ID] = 1; //��ɾ� ������� ���
	LoadUserConfigs();
	if( DUMPEXIST )
	{
		print("[rcon] ���� ������ �߰��߽��ϴ�. ���Ϳ� �̽��մϴ�...");
		CallDump();
	}
	GatherPlayerInformations();
	
	//���̳ʸ� Ʈ�� ����
	new CMD_HASH_HANGUL[sizeof(cmdlist)][E_BINTREE_INPUT];
	new CMD_HASH_ENGLISH[sizeof(cmdlist)][E_BINTREE_INPUT];
	for( new i = 0 ; i < sizeof(cmdlist) ; i++ )
	{
		//�ѱۺ���
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Cmd] );
		CMD_HASH_HANGUL[i][E_BINTREE_INPUT_POINTER] = i;
		//����
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_VALUE] = fnv_hash( cmdlist[Cmdorder:i][Func] );
		CMD_HASH_ENGLISH[i][E_BINTREE_INPUT_POINTER] = i;
	}
	Bintree_Generate( TREE_CMDLIST_HANGUL, CMD_HASH_HANGUL, sizeof(cmdlist) );
	Bintree_Generate( TREE_CMDLIST_ENGLISH, CMD_HASH_ENGLISH, sizeof(cmdlist) );

	//���� Ÿ�̸� ����
	if( USE_ANTI_CMDFLOOD) StaticTimer[CmdFlood] = SetTimer("ResetCmdFlood", CMDFLOOD_UNIT_TIME * 1000, 1);
	if( USE_ANTI_CHATFLOOD ) StaticTimer[ChatFlood] = SetTimer("ResetChatFlood", CHATFLOOD_UNIT_TIME * 1000, 1);
	if( USE_PINGCHECK && RESET_HIGHPING_TICK ) 
		StaticTimer[ResetPing] =  SetTimer("ResetPingCheck", RESET_HIGHPING_TICK * 1000, 1);
	SetTimer("Start_OneSecTimer_1", 480, 0);
	SetTimer("Start_OneSecTimer_2", 980, 0);
	
	//������Ʈ Ȯ��
#if SAMP03b
	rcmd_checkupdate(NULL);
#endif
	return 1; /* Loading Complete! */
}
//==========================================================
public OnFilterScriptExit()
{
	//���ͽ�ũ��Ʈ�� �����ϱ� ���� �ʿ��� �۾� ����
	if( SAVE_CURRRENT_CONFIG ) SaveUserConfigs();
	if( DUMPEXIT )
	{
		print("[rcon] ���� ������ �����ϰ� �ֽ��ϴ�...");
		CreateDump();
	}
	return 1;
}
//==========================================================
public OnGameModeExit()
{
	//��尡 ����� �� �ʿ��� �۾� ����
	for( new i = 0 ; i < NUM_PLAYERS ; i++ ) PLAYER_SPAWNED[pITT[i]] = 0; //�÷��̾� �������� �ʱ�ȭ
	if(SERVER_LOCKED) //������ ����ִ� ���
	{
		//FIXME : 15�ʰ� �����մϱ�?
		print("[rcon] ��尡 ����Ǿ����ϴ�. 15�� �Ŀ� �ٽ� ������ ���ϴ�.");
		SendAdminMessageAuth(AUTH_NOTICES, COLOR_IVORY, "* ��尡 ����Ǿ����ϴ�. 15�� �Ŀ� �ٽ� ������ ���ϴ�.");
		SERVER_LOCKED = 0;
		SetTimer("ReLockServer", 15000, 0);
	}
	return 1;
}
//==========================================================
public OnPlayerPrivmsg(playerid, recieverid, text[])
{
	new str[193];

	//������ ����
	if(USE_YELLFILTER && !CONSOLE)
	{
		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] ����� �����Ǿ����ϴ� - %s", YELLS[s]);
				for(new i = pos, j = pos + strlen(YELLS[s]); i < j; i++) text[i] = '+';
			}
		}
	}

	//�ӼӸ� ������� ���
	if( !CONSOLE )
	{
		if( IS_CHAT_FORBIDDEN[playerid] )
		{
			PLAYER_PMABUSE_TIMES[playerid]++;
			if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)���� �÷��̾ �Ӹ��� �������� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)���� �÷��̾ �Ӹ��� �������� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			SendClientMessage(playerid, COLOR_RED, "* ä�ñ��� ���Դϴ�. ����ؼ� �޼��� ������ �� ��� ���� ����˴ϴ�.");
			printf("[rcon] %s(%d)���� ��� �����Դϴ�.", GetPlayerNameEx(playerid), playerid);
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
					format( str, sizeof(str), "* %s(%d)���� �÷��̾ �Ӹ��� �������� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)���� �÷��̾ �Ӹ��� �������� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
					return 0;
				}
				format( str, sizeof(str), "PM from %s(%d): ���̻� �Ӹ��� �������� �����Կ�. �˼��ؿ� ��_ ��", GetPlayerNameEx(playerid), playerid);
				SendClientMessage( playerid, COLOR_YELLOW, str );
				format( str, sizeof(str), "PM sent to %s: ���̻� �Ӹ��� �������� �����Կ�. �˼��ؿ� ��_ ��", GetPlayerNameEx(recieverid));
				SendClientMessage( recieverid, COLOR_YELLOW, str );
				printf("[rcon] %s(%d)���� �ӼӸ� ���踦 �Ͽ� ��������� �۵��߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_SHUTUP] = CHATFLOOD_SHUTUP_TIME;
				return 0;
			}
		}
	}
	
	//�޼��� ������
	format(str,sizeof(str),"%s(%d) -> %s(%d): %s",CONSOLE? ("Admin"):(GetPlayerNameEx(playerid)),playerid,(recieverid==ADMIN_ID)? ("Admin"):(GetPlayerNameEx(recieverid)),recieverid,text);
	FixChars(str);
	SendAdminMessageAuth(AUTH_PMTRACE,COLOR_GREY,str);
	return 1;
}
//==========================================================
public OnPlayerText(playerid, text[])
{
	//��ȭ�� ���ü��
	if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID ) 
	{
		if( text[0] == '?' && !text[1] ) 
		{
			SendClientMessage( playerid, COLOR_RED, "* ��ҵǾ����ϴ�." );
			INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
			return 0;
		}
		new str[128];		
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
		CallLocalFunction( str, "isib", playerid, text, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
		return 0;
	}

	if( PERMANENT_ADMINSAY(	playerid) ) return !dcmd_say( playerid, text, CMD_SAY, NO_HELP ); //����� �ڵ鸵
	LAST_PLAYER_ID=playerid; // ���������� ä���� ����
	new str[128];
	
	if( IS_CHAT_FORBIDDEN[playerid] )
	{
		PLAYER_PMABUSE_TIMES[playerid]++;
		if( PLAYER_PMABUSE_TIMES[playerid] >= PMABUSE_LIMIT )
		{
			format( str, sizeof(str), "* %s(%d)���� ä�ñ��� ���¿��� ��� ���踦 �Ͽ� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
			SendClientMessageToAll( COLOR_RED, str );
			printf("[rcon] %s(%d)���� ä�ñ��� ���¿��� ��� ���踦 �Ͽ� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
			if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
			return 0;
		}
		SendClientMessage(playerid, COLOR_RED, "* ä�ñ��� ���Դϴ�. ����ؼ� �޼��� ������ �� ��� ���� ����˴ϴ�.");
		printf("[rcon] %s(%d)���� ��� �����Դϴ�.", GetPlayerNameEx(playerid), playerid);
		return 0;
	}

	if(USE_YELLFILTER)
	{

		for(new s = 0; s < num_Yells; s++)
		{
			new pos;
			while( (pos = strfind(text,YELLS[s],true)) != -1)
			{
				printf("[rcon] ����� �����Ǿ����ϴ� - %s", YELLS[s]);
				format( str, sizeof(str), "* ����� �����Ǿ����ϴ�. - %s", YELLS[s]);
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
				format( str, sizeof(str), "* %s(%d)���� ��� ���踦 �Ͽ� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)���� ��� ���踦 �Ͽ� �����߹� �Ǿ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CHAT ) c_Ban(playerid); else c_Kick(playerid);
				return 0;
			}
			format( str, sizeof(str), "%s(%d): ���̻� �������� �����Կ�. �˼��ؿ� ��_ ��", GetPlayerNameEx(playerid), playerid);
			FixChars(str);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			printf("[rcon] %s(%d)���� ���踦 �Ͽ� ��������� �۵��߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
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
	//�ð� �˷��ֱ�
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "����";
	}
	else tmp = "����";
	printf("[rcon] ���� �ð��� %s %2d�� %2d�� �Դϴ�.", tmp, h, m);
	//�⺻���� ���� ����
	GetPlayerName( playerid, PLAYER_NAME[playerid], MAX_PLAYER_NAME );
	FixChars( PLAYER_NAME[playerid] );
	GetPlayerIp( playerid, PLAYER_IP[playerid], sizeof(PLAYER_IP[]) );

	//��������� ���
	if(SERVER_LOCKED)
	{
		new str[77];
		SendClientMessage(playerid, COLOR_RED, " Server is currently LOCKED. You can't join.");
		SendClientMessage(playerid, COLOR_RED, " ������ ����־� ������ �Ұ����մϴ�.");
		format(str, sizeof(str), "* ������ ����־� %s(%d)���� ���ӿ�û�� �ź��߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] ������ ����־� %s(%d)���� ���ӿ�û�� �ź��߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
		c_Kick(playerid);
		return 1;
	}

	//�ҷ����� ����
	if( USE_BADWARN )
	{
		h = GetTickCount( );
		
		if( CUR_BADP_POINT == 0 ) Bintree_Reset( TREE_BADPLAYER );
		new current_ip = fnv_hash( GetPlayerIpEx(playerid) );		
		new i = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		
		if ( i != BINTREE_NOT_FOUND && BAD_PLAYER_IP[i] != 0 )
		{
			//�ҷ� �����̸�, ������� �� ù ������ ���
			if( h - BADKICKED_TIMESTAMP[i] < 5000 ) //�������� ���������� ���� �Һ�Ʈ��  �ǽɵȴٸ�
			{
				//������ ����
				GameTextForPlayer( playerid, "~r~NO ~w~s~y~0~w~beit~n~~p~fuck", 60000, 3 );
				c_Kick( playerid );
				return 1;
			}
			BAD_PLAYER_IP[i] = 0;
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			SendClientMessage( playerid, COLOR_RED, BADPLAYER_MESSAGE );
			new str[77];
			format( str, sizeof(str), "* ������ �ι� %s(%d)���� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, str ); 
			print("[rcon] ������ �ι��� �����߽��ϴ�.");
		}
	}

	PLAYER_CASH[playerid] = 0;
	ResetPlayerStatus(playerid);
	return 1;
}
//==========================================================
public OnPlayerRequestSpawn(playerid)
{
	//FIXME: �� �� �۾��� �ϴ��� �𸣰ڽ��ϴ�. ���ͽ�ũ��Ʈ�� �浹�� ������?
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
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* �÷��̾ ��Ƴ����ϴ�. ���ð� ���۵� ������ ��ٷ� �ּ���...." );
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
		SendClientMessage( playerid, COLOR_ORANGE, "* ���� ��尡 ����Ǿ����ϴ�." );
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		TogglePlayerSpectating( IS_PLAYER_SPECTATED[playerid], 0 );
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_GREY, "* ���ø� ����մϴ�. �÷��̾ �ٽ� ��Ƴ������� ��ٷ� �ּ���..." );
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
		
		//��ȭ�� ���ü��
		if( INTERACTIVE_COMMAND[playerid] != CMD_INVALID )
		{
			SendClientMessage( playerid, COLOR_RED, "* ��ȭ�� ���ü�谡 �۵����Դϴ�. ������� ������ ��ģ �� ����Ͻʽÿ�.");
			SendClientMessage( playerid, COLOR_ORANGE, "* ������ ����Ϸ��� ?�� �Է��Ͻʽÿ�.");
			return 1;
			/*
			if( cmdtext[1] == '?' && !cmdtext[2] ) 
			{
				SendClientMessage( playerid, COLOR_RED, "* ��ҵǾ����ϴ�." );
				INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
				return 1;
			}
			format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[playerid]][Func] );
			if ( !cmdtext[1] ) CallLocalFunction( str, "isib", playerid, NULL, _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			else CallLocalFunction( str, "isib", playerid, cmdtext[1], _:INTERACTIVE_COMMAND[playerid], NO_HELP );
			return 1; */
		}
			
		//��ɾ� ���� �ڵ鸵
		if( IS_CMD_FORBIDDEN[playerid] )
		{
			CMDFLOOD_STILL_TIMES[playerid]++;
			if( CMDFLOOD_STILL_TIMES[playerid] >= CMDFLOOD_STILL_LIMIT )
			{
				format( str, sizeof(str), "* %s(%d)���� ��ɾ� ���踦 �Ͽ� ���� �߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid);
				SendClientMessageToAll( COLOR_RED, str );
				printf("[rcon] %s(%d)���� ����ؼ� ��ɾ �����Ͽ� �����߹� �Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
				return 1;
			}
			SendClientMessage( playerid, COLOR_RED, "* ��ɾ� ����� ���ѵǾ� �ֽ��ϴ�. ����Ͽ� ��ɾ �Է��� ��� �߹�˴ϴ�." );
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
					format( str, sizeof(str), "* %s(%d)���� ��ɾ� ���踦 �Ͽ� ���� �߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid);
					SendClientMessageToAll( COLOR_RED, str );
					printf("[rcon] %s(%d)���� ����ؼ� ��ɾ �����Ͽ� �����߹� �Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid);
					if( ONFLOOD_CMD ) c_Ban(playerid); else c_Kick(playerid);
					return 1;
				}
				PLAYER_PUNISH_REMAINTIME[playerid][PUNISH_CMDRESTRICT] = CMDFLOOD_FORBIDDEN_TIME;
				SendClientMessage( playerid, COLOR_RED, "* ��ɾ�� ���踦 �Ͽ� ��ɾ� ����� ���ѵ˴ϴ�." );
				printf("[rcon] %s(%d)���� ��ɾ� ���踦 �Ͽ� ��ɾ� ����� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid);
				return 1;
			}
		}
	}
	
	if( !cmdtext[1] ) return 0;
	
	//centralized command handling
	new length, hash, i, str[128];
	set( str, strtok( cmdtext[1], length ));
	hash = fnv_hash( str );
	
	//�ѱۿ��� ���� �˻�
	i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
	if( i == BINTREE_NOT_FOUND ) //�ѱۿ� ���� ����� �˻�
	{
		i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
		if ( i == BINTREE_NOT_FOUND ) return 0; //��ɾ ����
	}
	//strtok ����
	if( cmdtext[length] == ' ' ) length --;
	length++;
	
	//������ �ʿ���ų�, �ܼ��̰ų�, ����̰ų�, ������ ���� �ο���� ��� ��ŵ
	if( cmdlist[Cmdorder:i][Required_Auth] != AUTH_NONE && !CONSOLE && !IsPlayerAdmin( playerid )
		&& !AuthorityCheck(playerid,cmdlist[Cmdorder:i][Required_Auth]) )
	{
		//� �Ϳ��� �ش����� ����. ���� ���� ���� �޼����� ���
		cmdtext[length] = EOS;
		format( str, sizeof(str), "* ��ɾ� '%s'��(��) ����� ������ �����ϴ�. ��ڿ��� �����ϼ���.", cmdtext );
		SendClientMessage( playerid, COLOR_RED, str );
		return 1;
	}
	
	//�Լ� ȣ��
	format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
	if( cmdtext[length] == 32 && cmdtext[length+1] != EOS )	CallLocalFunction( str, "isib", playerid, cmdtext[length+1], i, NO_HELP );
	else CallLocalFunction( str, "isib", playerid, NULL, i, NO_HELP );
	return 1;
}
//==========================================================
public OnPlayerDisconnect(playerid, reason)
{
	//iteration optimization
	NUM_PLAYERS--; //�������� �÷��̾� �� ����
	if( NUM_PLAYERS )
	{
	    //���� �÷��̾��� �ݺ����� �� ���� �÷��̾� ��ȣ�� ä�� ( TRIM )
		pITT[ pITT_INDEX[playerid] ] = pITT[ NUM_PLAYERS ];
		//�� ���� �÷��̾ ���� ������ ���� �÷��̾��� �������� ����
		pITT_INDEX[ pITT[ NUM_PLAYERS ] ] = pITT_INDEX[playerid];
	}
	//�÷��̾� ���� �ʱ�ȭ
	pITT_INDEX[ playerid ] = -1;
	//votekick check
	new str[128];
	if( VOTEKICK_REMAINTIME > 0 && VOTEKICK_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)���� ������ ���� ��ǥ�� �ߴܵ˴ϴ�.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)���� ������ ���� ��ǥ�� �ߴܵ˴ϴ�.", GetPlayerNameEx( playerid ), playerid );
		VOTEKICK_REMAINTIME = 0;
		VOTEKICK_TICK = 0;
	}
	if( VOTEKICK_REMAINTIME > 0 && VOTEBAN_PLAYER == playerid )
	{
		format( str, sizeof(str), "* %s(%d)���� ������ ���� ��ǥ�� �ߴܵ˴ϴ�.", GetPlayerNameEx( playerid ), playerid );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] %s(%d)���� ������ ���� ��ǥ�� �ߴܵ˴ϴ�.", GetPlayerNameEx( playerid ), playerid );
		VOTEBAN_REMAINTIME = 0;
		VOTEBAN_TICK = 0;
	}

    //�ҷ� ������ IP ���
	if( reason == 2 )
	{
		static full;
		
		if( CUR_BADP_POINT == MAX_BAD_PLAYERS )
		{
			//���� ���� �Ź� ����Ʈ�� ���־�� �ϳ�?
			//�ƴϴ�. �׳� �����ϰ� �ٽ� �ٲٸ� �ȴ�. �׶����ʹ� ���� ������ �Ѵ�. �Ź� ������ �ʰ�..
			full = 1;
			CUR_BADP_POINT = 0;
		}		
		
		new current_ip = fnv_hash( GetPlayerIpEx( playerid ) );
		new ptr = Bintree_FindValue( TREE_BADPLAYER, current_ip );
		if( ptr != BINTREE_NOT_FOUND )
		{
			//���� �÷��̾ �� ������ϴ� ��� ..
			//�÷��׸� �����, ������� �ð��� ����Ѵ�.
			BAD_PLAYER_IP[ptr] = current_ip;
			BADKICKED_TIMESTAMP[ptr] = GetTickCount( );
		}
		else if( full )
		{
			// ���� �������� ����. �������� ���� ��ȯ
			ptr = 0;
			Bintree_FindValue( TREE_BADPLAYER, BAD_PLAYER_IP[CUR_BADP_POINT], _, ptr );
			Bintree_Delete ( TREE_BADPLAYER, ptr, 1 );
			
			BAD_PLAYER_IP[CUR_BADP_POINT] = current_ip;
			BADKICKED_TIMESTAMP[CUR_BADP_POINT] = GetTickCount( );
			
			Bintree_Add( TREE_BADPLAYER, CUR_BADP_POINT, BAD_PLAYER_IP[CUR_BADP_POINT], sizeof(TREE_BADPLAYER) - 1 );
			format( str, sizeof(str), "* �ҷ����� Ȯ�ο� IP���̺��� ���� á���ϴ�. �����ڿ��� �����ϼ���" );
			SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
			print("[rcon] �ҷ����� Ȯ�ο� IP���̺��� ���� á���ϴ�. ������ �ҷ� �������� ���ʴ�� �����մϴ�." );			
		}
		else //���� ���� ����. �Ź� �������� Ʈ���� ������ش�.
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
	//����ð� �˸�
	new h, m, s, tmp[5];
	gettime(h, m, s);
	if( h >= 12 )
	{
		if(h > 12) h -= 12;
		tmp = "����";
	}
	else tmp = "����";
	printf("[rcon] ���� �ð��� %s %2d�� %2d�� �Դϴ�.", tmp, h, m);
	//���� ����
	PLAYER_SPAWNED[playerid] = 0;
	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}
	if( IS_PLAYER_SPECTATED[playerid] != INVALID_PLAYER_ID )
	{
		SendClientMessage( IS_PLAYER_SPECTATED[playerid], COLOR_ORANGE, "* �ش� �÷��̾ ���ӿ��� ���� ���ø�带 �����մϴ�.");
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
	//�����ڷ� ���� ���� ũ���� ����
	for( new i = 0, len = strlen( cmd ) ; i < len ; i++ ) if( cmd[i] == '%' ) cmd[i] = '#';
	
	//��ȭ�� ���ü��
	if( INTERACTIVE_COMMAND[ADMIN_ID] != CMD_INVALID )
	{
		if( cmd[0] == '?' && !cmd[1] ) 
		{
			print( "[rcon] ��ҵǾ����ϴ�." );
			INTERACTIVE_COMMAND[ADMIN_ID] = CMD_INVALID;
			return 1;
		}
		new str[128];
		format( str, sizeof(str), "dcmd_%s", cmdlist[INTERACTIVE_COMMAND[ADMIN_ID]][Func] );
		CallLocalFunction( str, "isib", ADMIN_ID, cmd, _:INTERACTIVE_COMMAND[ADMIN_ID], NO_HELP );
		return 1;
	}
	
	//����忡 ���� �ڵ鸵
	if( PERMANENT_ADMINSAY(ADMIN_ID) && cmd[0] != '!') return dcmd_say( ADMIN_ID, cmd, CMD_SAY, NO_HELP );
	else
	{
		if ( cmd[0] == '!' ) for( new i = 0, j = strlen( cmd ) ; i < j ; i++ ) cmds[i] = cmd[i];
		else for( new i = strlen( cmd ) ; i > 0 ; i-- ) cmds[i] = cmd[i -1];
	}
	cmds[0] = '/';

	//invoke command
	rcmd("����",6,help);
	rcmd("help",4,help);
	rcmd("help2",5,help2);
	
	//rcon-unique command
	rcmd("rcon",4,rcon);
	rcmd("update",6,checkupdate);
	rcmd("������Ʈ",8,checkupdate);
	
	/* deprecated */
	//rcmd("shelp",5,shelp);
	//rcmd("readcmd",7,readcmd);
	//rcmd("��ɾ��б�",10,readcmd);	
	

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
	
	//IP�� ã�� �غ� ���� ����
	new current_ip, playerid = INVALID_PLAYER_ID, str[128], i;
	current_ip = fnv_hash (ip);
	if( ip_index == 0 ) Bintree_Reset( TREE_IPTABLES );

	i = Bintree_FindValue( TREE_IPTABLES, current_ip ); //IP ���̺� ����� �˻�
	if( i != BINTREE_NOT_FOUND )
	{
		//���� ��Ͽ� �����ϴ� ���
		if( iptables[i][R_IP_HASH] == current_ip )
		{
			//��������. ���а� �ʱ�ȭ�ϰ� ���� �Ѱ��ش�.
			if( success )
			{
				iptables[i][R_FAILED_ATTEMPT] = 0;
				return 1;
			}
			//���и���Ʈ �߰�. ���̵� ���
			iptables[i][R_FAILED_ATTEMPT]++;
			playerid = iptables[i][R_PLAYER_ID];
			//�������Ͽ��� ���� �ѵ��� �Ѿ��
			if( iptables[i][R_FAILED_ATTEMPT] >= MAX_RCONLOGIN_ATTEMPT )
			{
				if( playerid == INVALID_PLAYER_ID)
				{
					format( str, sizeof(str), "* ip %s���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� ip���� �����մϴ�.", ip );
					SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
					printf("[rcon] ip %s���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� ip���� �����մϴ�.", ip );
					format( str, sizeof(str),"banip %s", ip );
					SendRconCommand( str );
					return 1;
				}
				//�������Ͽ��� ���� ��ġ�� ���� ó��
				switch( POLICY_RCON_LOGINFAIL_INTERNAL )
				{
					case 1:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE KICKED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* ����ؼ� �߸��� �α��� �õ��� �Ͽ� �߹�Ǿ����ϴ�." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~y~kicked", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid );
						c_Kick(playerid);
					}
					case 2:
					{
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* YOU HAVE REPEATED BAD RCON ATTEMPTS. YOU ARE BANNED" );
						SendClientMessage( iptables[i][R_PLAYER_ID], COLOR_RED, "* ����ؼ� �߸��� �α��� �õ��� �Ͽ� �����߹�Ǿ����ϴ�." );
						GameTextForPlayer( iptables[i][R_PLAYER_ID], "you are ~r~BANNED", 5000, 5 );
						format( str, sizeof(str), "* %s(%d)���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� �����߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid );
						SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
						printf("[rcon] %s(%d)���� �߸��� rcon �α��� �ѵ��� �ʰ��Ͽ� �����߹�˴ϴ�.", GetPlayerNameEx(playerid), playerid );
						c_Ban(playerid);						
					}
				}
				return 1;
			}
			//�ѵ��� �Ѿ�� ����. ��ڿ��� �߸��� �õ��� ���� �˸�
			if( playerid == INVALID_PLAYER_ID )
			{
				format( str, sizeof(str), "* ip %s���� %d��°�� rcon �α��� �õ��� �����߽��ϴ�.", ip, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] ip %s���� %d��°�� rcon �α��� �õ��� �����߽��ϴ�.", ip, iptables[i][R_FAILED_ATTEMPT] );
			}
			else
			{
				format( str, sizeof(str), "* %s(%d)���� %d��°�� rcon �α��� �õ��� �����߽��ϴ�.",  GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
				SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
				printf("[rcon] %s(%d)���� %d��°�� rcon �α��� �õ��� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, iptables[i][R_FAILED_ATTEMPT] );
			}
			return 1;
		}
	}
	
	//����Ʈ�� ����. �α��� �õ� ����. �׳� �����ش�.
	if( success ) return 1;
	//����Ʈ�� ����. ù �α��� �õ� ����. ��Ͽ� ����.
	//������, ���̺��� ���� á���� Ȯ���Ѵ�.
	static full;
	
	if( ip_index == sizeof(iptables) ) 
	{
		full = 1;
		ip_index = 0;
	}
	
	for( i = 0; i < NUM_PLAYERS ; i++ )//�켱 �÷��̾ ���������� ã�´�.
	{
		if( !strcmp(GetPlayerIpEx(pITT[i]), ip, false) )
		{
			playerid = pITT[i]; //������ �÷��̾ �α��� �õ���.
			break;
		}
	}
	//Bintree_Add( TREE_IPTABLES, ip_index, current_ip, ip_index ); //just add;
	if( full )
	{
		//���� á���� �������� ����
		new ptr;
		Bintree_FindValue( TREE_IPTABLES, iptables[ip_index][R_IP_HASH], _, ptr );
		Bintree_Delete( TREE_IPTABLES, ptr, 1 );
		
		iptables[ip_index][R_IP_HASH] = current_ip;
		iptables[ip_index][R_PLAYER_ID] = playerid; 
		iptables[ip_index][R_FAILED_ATTEMPT] = 1;
		
		Bintree_Add( TREE_IPTABLES, ip_index, current_ip, sizeof(TREE_IPTABLES) -1 );
		ip_index++;
		
		format( str, sizeof(str), "* RCON �α��� ���� IP���̺��� ���� á���ϴ�. �����ڿ��� �����ϼ���", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		print("[rcon] RCON �α��� ���� IP���̺��� ���� á���ϴ�. ������ �α��� �õ����� ���ʴ�� �����մϴ�." );
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
		//�÷��̾ ����. ip���� �غ��Ѵ�.
		format( str, sizeof(str), "* ip %s���� ó������ rcon �α��� �õ��� �����߽��ϴ�.", ip );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_RED, str );
		SendAdminMessageAuth( AUTH_NOTICES, COLOR_ORANGE, "* ��û�� �ݺ��Ǹ� ip���� �����մϴ�." );
		printf("[rcon] ip %s���� ó������ rcon �α��� �õ��� �����߽��ϴ�.", ip );
		print("[rcon] ��û�� �ݺ��Ǹ� ip���� �����մϴ�.");
		return 1;
	}
	else 
	{
		//�޼��� ������
		format( str, sizeof(str), "* %s(%d)���� ó������ rcon �α��� �õ��� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_RED,str);
		printf("[rcon] %s(%d)���� ó������ rcon �α��� �õ��� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
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
			gcmd(DIALOG_ADMIN_MAIN,adminmain); //�⺻ ��ɾ� ��Ʈ
			gcmd(DIALOG_ADMIN_KICK,kick); //�����߹�
			gcmd(DIALOG_ADMIN_BAN,ban); //�����߹�
			gcmd(DIALOG_PM,superpm); //�ӼӸ�������
			gcmd(DIALOG_ADMIN_WITH,with); //�̵��ϱ�
			gcmd(DIALOG_ADMIN_CALL,call); //��ȯ�ϱ�
			gcmd(DIALOG_ADMIN_KILL,kill); //���
			gcmd(DIALOG_ADMIN_SETHP,sethp); //ü�¼���
			gcmd(DIALOG_ADMIN_INFINITE,infinite); //ü����
			gcmd(DIALOG_ADMIN_MAKECASH,makecash); //���ֱ�
			gcmd(DIALOG_ADMIN_FORFEIT,forfeit); //������
			gcmd(DIALOG_ADMIN_SETCASH,setcash); //������
			gcmd(DIALOG_ADMIN_SETSCORE,setscore); //���ھ��
			gcmd(DIALOG_ADMIN_GIVEWP,givewp); //�����ֱ�
			gcmd(DIALOG_ADMIN_DISARM,disarm); //�����Ż
			gcmd(DIALOG_ADMIN_FREEZE,freeze); //������
			gcmd(DIALOG_ADMIN_UNFREEZE,unfreeze); //������ ����
			gcmd(DIALOG_ADMIN_ARMOR,armor); //�Ƹ�
			gcmd(DIALOG_ADMIN_INFARMOR,infarmor); //�Ƹӹ���
			gcmd(DIALOG_ADMIN_SPAWNCAR,spawncar); //����ȯ
			gcmd(DIALOG_ADMIN_SDROP,sdrop); //������ ������
			gcmd(DIALOG_ADMIN_CARENERGY,carenergy); //�������� ����
			gcmd(DIALOG_ADMIN_JETPACK,jetpack); //��Ʈ��
			gcmd(DIALOG_ADMIN_MUSIC,music); //���ǵ��
			gcmd(DIALOG_ADMIN_MUSICOFF,musicoff); //���ǲ���
			gcmd(DIALOG_ADMIN_BOMB,bomb); //�� ��Ʈ����
			gcmd(DIALOG_ADMIN_SHUTUP,shutup); //ä�� ����
			gcmd(DIALOG_ADMIN_UNSHUT,unshut); //ä�� ����
			gcmd(DIALOG_ADMIN_CHANGENICK,changenick); //�йٲٱ�
			gcmd(DIALOG_ADMIN_SPECTATE,spectate); //�����ϱ�
			gcmd(DIALOG_ADMIN_SUBADMIN,subadmin); //�ο�� �Ӹ�
			gcmd(DIALOG_ADMIN_DELSUB,delsub); //�ο�� ��Ż
			gcmd(DIALOG_ADMIN_FIND,find); //�� ������ ���� ����
		}
		return 0;
	}
	//user main
	switch( dialogid )
	{
		gcmd(DIALOG_USER_MAIN,usermain); //�⺻ ��ɾ� ��Ʈ
		gcmd(DIALOG_USER_VOTEKICK,votekick); //�����߹�
		gcmd(DIALOG_USER_VOTEBAN,voteban); //�����߹�
		gcmd(DIALOG_PM,superpm); //�ӼӸ�������
	}
	return 0;
}
//==========================================================
// Gui Command
//==========================================================
dialog_adminmain( playerid, response, listitem, inputtext[] ) //���� �ڵ鷯
{
	//����� ���
	if( !response ) return 1;
	
	switch( listitem )
	{
	    case 0: //Kick Player
	    {
	        Auth_Check(AUTH_CMD_KICK);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP�� ���װ� �����Ƿ� �ѱ��� �Է����� ���ñ� �ٶ��ϴ�.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KICK ); //Ȯ�� �޼��� ����
   	    }
	    case 1: //Ban Player
		{
		    Auth_Check(AUTH_CMD_BAN);
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP�� ���װ� �����Ƿ� �ѱ��� �Է����� ���ñ� �ٶ��ϴ�.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_BAN );//Ȯ�� �޼��� ����
		}
		case 2: //�޼��� ������
	    {
			#if !SAMP03x
				SendClientMessage( playerid, COLOR_RED, "* SA-MP�� ���װ� �����Ƿ� �ѱ��� �Է����� ���ñ� �ٶ��ϴ�.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
		case 3:
		{
		    Auth_Check(AUTH_CMD_WITH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_WITH ); //�̵��ϱ�
		}
		case 4:
		{
		    Auth_Check(AUTH_CMD_CALL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_CALL ); //��ȯ�ϱ�
		}
		case 5:
		{
		    Auth_Check(AUTH_CMD_KILL);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_KILL ); //����ϱ�
		}
		case 6:
		{
			Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP ); //ü�� �����ϱ�
		}
		case 7:
		{
		    Auth_Check(AUTH_CMD_SETHEALTH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFINITE ); //�������� �����
		}
		case 8:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH ); //���ֱ�
		}
		case 9:
		{
            Auth_Check(AUTH_CMD_FORFEIT);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FORFEIT ); //������
		}
		case 10:
		{
		    Auth_Check(AUTH_CMD_CASH);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH ); //������
		}
		case 11:
		{
		    Auth_Check(AUTH_CMD_SETSCORE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE ); //���ھ��
		}
		case 12:
		{
            Auth_Check(AUTH_CMD_GIVEWEAPON);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_GIVEWP ); //�����ֱ�
		}
		case 13:
		{
		    Auth_Check(AUTH_CMD_DISARM);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_DISARM ); //�����ֱ�
		}
		case 14:
		{
		    Auth_Check(AUTH_CMD_FREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FREEZE ); //������
		}
		case 15:
		{
		    Auth_Check(AUTH_CMD_UNFREEZE);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNFREEZE ); //������ ����
		}
		case 16:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR ); //�Ƹ�
		}
		case 17:
		{
		    Auth_Check(AUTH_CMD_SETARMOR);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_INFARMOR ); //�Ƹӹ���
		}
		case 18:
		{
		    Auth_Check(AUTH_CMD_SPAWNCAR);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPAWNCAR ); //������ȯ
		}
		case 19:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SDROP ); //������������
		}
		case 20:
		{
		    Auth_Check(AUTH_CMD_CARENERGY);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY ); //�������� ����
		}
		case 21:
		{
		    Auth_Check(AUTH_CMD_JETPACK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_JETPACK ); //��Ʈ�� �ֱ�
		}
		case 22:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSIC ); //�Ҹ����
		}
		case 23:
		{
		    Auth_Check(AUTH_CMD_SOUND);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_MUSICOFF ); //�Ҹ�����
		}
		case 24:
		{
		    Auth_Check(AUTH_CMD_BOMB);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_BOMB ); //��ź ��Ʈ����
		}
		case 25:
		{
		    Auth_Check(AUTH_CMD_SHUTUP);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SHUTUP ); //ä�� �����ϱ�
		}
		case 26:
		{
		    Auth_Check(AUTH_CMD_UNSHUT);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_UNSHUT ); //ä�� �����ϱ�
		}
		case 27:
		{
		    Auth_Check(AUTH_CMD_CHANGENICK);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK ); //�г��� �����ϱ�
		}
        case 28:
		{
		    Auth_Check(AUTH_CMD_SPECTATE);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SPECTATE ); //����� �����ϱ�
		}
		case 29:
		{
		    Auth_Check(AUTH_CMD_SETSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_SUBADMIN ); //�ο�� �Ӹ��ϱ�
		}
		case 30:
		{
		    Auth_Check(AUTH_CMD_DELSUBADMIN);
		    ShowPlayerDialogs( playerid, DIALOG_ADMIN_DELSUB ); //�ο�� ��Ż�ϱ�
		}
		case 31:
		{
			Auth_Check(AUTH_CMD_USERINFO);
			ShowPlayerDialogs( playerid, DIALOG_ADMIN_FIND ); //�� ������ ���� ����
		}
		default: //���� Ž��
		{
			new str[128];
			format( str, sizeof(str), "* ���� �޴�â ��Ʈ����(%d): %s", listitem, inputtext );
			SendClientMessage( playerid, COLOR_RED, str );
		    return 1;
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_kick( playerid, response, listitem, inputtext[] ) //�������� ��� �޼���
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�������� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_skick( playerid, str, CMD_KICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_ban( playerid, response, listitem, inputtext[] ) //�����߹� ��� �޼���
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�����߹� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sban( playerid, str, CMD_BAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_with( playerid, response, listitem, inputtext[] ) //���
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //��� ��ɾ� ������
	dcmd_with( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_WITH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_call( playerid, response, listitem, inputtext[] ) //��ȯ
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //��ȯ ��ɾ� ������
	dcmd_call( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_CALL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_kill( playerid, response, listitem, inputtext[] ) //��ȯ
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //��� ��ɾ� ������
	dcmd_skill( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SKILL, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_sethp( playerid, response, listitem, inputtext[] ) //��ȯ
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETHP );
	}
    //ü�¼��� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_sethp( playerid, str, CMD_SETHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infinite( playerid, response, listitem, inputtext[] ) //��ȯ
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ü�¹��� ��ɾ� ������
	dcmd_infinite( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFINITE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_makecash( playerid, response, listitem, inputtext[] ) //���ֱ�
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAKECASH );
	}
    //���ֱ� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_mcash( playerid, str, CMD_MCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_forfeit( playerid, response, listitem, inputtext[] ) //������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //������ ��ɾ� ������
	dcmd_forfeit( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FORFEIT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_setcash( playerid, response, listitem, inputtext[] ) //������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETCASH );
	}
    //������ ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_setcash( playerid, str, CMD_SETCASH, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_setscore( playerid, response, listitem, inputtext[] ) //���ھ� ����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_SETSCORE );
	}
    //���ھ�� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_score( playerid, str, CMD_SCORE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_givewp( playerid, response, listitem, inputtext[] ) //�����ֱ�
{
	#define GIVEWP_STAGE_TYPE 0
	#define GIVEWP_STAGE_TYPECUSTOM 1
	#define GIVEWP_STAGE_AMMOAMOUNT 2
	#define GIVEWP_STAGE_AREYOUSURE 3
	static stage, weaponid, ammo;
	//����� ���
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
	
	//��Ÿ ���⸦ ������ ���
	if( stage == GIVEWP_STAGE_TYPE && listitem == sizeof(WEAPON_STORAGE) )
	{
		stage = GIVEWP_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "������ ���⸦ �����Ͻʽÿ�.",
			"������ ������ ��ȣ�� �����Ͻʽÿ�.", "Ȯ��", "�ڷ�" );
		return 1;
	}
	
	//�����ȣ�� �����. �Ѿ˼��� ���
	if( stage == GIVEWP_STAGE_TYPE || stage == GIVEWP_STAGE_TYPECUSTOM )
	{
	    //�����ȣ ����
	    if( stage == GIVEWP_STAGE_TYPE ) weaponid = WEAPON_STORAGE[listitem][weapon_id];
	    else weaponid = strval(inputtext);
	    //�Ѿ˼� ����
	    stage = GIVEWP_STAGE_AMMOAMOUNT;
	    ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_INPUT, "�Ѿ� ���� �����Ͻʽÿ�.",
			"������� �ʴ� ��� 3000���� �����մϴ�.", "Ȯ��", "�ڷ�" );
	    return 1;
	}
	
	//�Ѿ˼��� �����. ����Ȯ��
	new str[128];
	if( stage == GIVEWP_STAGE_AMMOAMOUNT )
	{
	    //�Ѿ˼� ����
		ammo = strval(inputtext);
		if( !ammo ) ammo = 3000;
		//����Ȯ��
		stage = GIVEWP_STAGE_AREYOUSURE;
		GetWeaponName( weaponid, str, sizeof(str) );
		format( str, sizeof(str), "���� �÷��̾�� ���⸦ �ݴϴ�: %s(%d).\n �����ȣ: %d(%s), �Ѿ˼� : %d��.\n����Ͻðڽ��ϱ�?",
			GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid],
			weaponid, str, ammo );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		return 1;
	}

    //�����ֱ� ��ɾ� ������
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
dialog_disarm( playerid, response, listitem, inputtext[] ) //���⻯��
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //������� ��ɾ� ������
	dcmd_disarm( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DISARM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_freeze( playerid, response, listitem, inputtext[] ) //������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //������� ��ɾ� ������
    new str[128];
    format( str, sizeof(str), "%d",DIALOG_CLICKED_PLAYER[playerid] );
	if( inputtext[0] ) format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_freeze( playerid, str, CMD_FREEZE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_unfreeze( playerid, response, listitem, inputtext[] ) //��������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //������ ���� ��ɾ� ������
	dcmd_unfrz( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNFRZ, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_armor( playerid, response, listitem, inputtext[] ) //�Ƹ� ����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_ARMOR );
	}
    //ü�¼��� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_armor( playerid, str, CMD_ARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_infarmor( playerid, response, listitem, inputtext[] ) //�Ƹӹ���
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ü�¹��� ��ɾ� ������
	dcmd_infarmor( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_INFARMOR, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_spawncar( playerid, response, listitem, inputtext[] ) //����ȯ
{
	#define SPAWNCAR_STAGE_TYPE 0
	#define SPAWNCAR_STAGE_TYPECUSTOM 1
	#define SPAWNCAR_STAGE_AREYOUSURE 2
	static stage, modelid;
	//����� ���
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

	//��Ÿ ������ ������ ���
	if( stage == SPAWNCAR_STAGE_TYPE && listitem == sizeof(VEHICLE_STORAGE) )
	{
		stage = SPAWNCAR_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_INPUT, "������ ������ �����Ͻʽÿ�.",
			"������ ������ ��ȣ�� �����Ͻʽÿ�.", "Ȯ��", "�ڷ�" );
		return 1;
	}

	//������ȣ�� �����. ����Ȯ��
	new str[128];
	if( stage == SPAWNCAR_STAGE_TYPE || stage == SPAWNCAR_STAGE_TYPECUSTOM )
	{
	    //������ȣ ����
	    if( stage == SPAWNCAR_STAGE_TYPE ) modelid = VEHICLE_STORAGE[listitem][weapon_id];
		else modelid = strval(inputtext);
		//����Ȯ��
		stage = SPAWNCAR_STAGE_AREYOUSURE;
		format( str, sizeof(str), "���� �÷��̾�� ������ �ݴϴ�: %s(%d).\n���� ��: %d.\n����Ͻðڽ��ϱ�?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], modelid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		return 1;
	}

    //������ȯ ��ɾ� ������
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
dialog_sdrop( playerid, response, listitem, inputtext[] ) //�������� ������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�������� ������ ��ɾ� ������
	dcmd_drop( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_DROP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_carenergy( playerid, response, listitem, inputtext[] ) //�������� ����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CARENERGY );
	}
    //�������� ���� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_carhp( playerid, str, CMD_CARHP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_jetpack( playerid, response, listitem, inputtext[] ) //��Ʈ�� �ֱ�
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //��Ʈ�� �ֱ� ��ɾ� ������
	dcmd_jpack( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_JPACK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_music( playerid, response, listitem, inputtext[] ) //���� ���
{
	#define MUSIC_STAGE_TYPE 0
	#define MUSIC_STAGE_TYPECUSTOM 1
	#define MUSIC_STAGE_AREYOUSURE 2
	static stage, soundid;
	//����� ���
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

	//��Ÿ ������ ������ ���
	if( stage == MUSIC_STAGE_TYPE && listitem == sizeof(MUSIC_STORAGE) )
	{
		stage = MUSIC_STAGE_TYPECUSTOM;
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_INPUT, "����� ������ �����Ͻʽÿ�.",
			"����� ������ ��ȣ�� �����Ͻʽÿ�.", "Ȯ��", "�ڷ�" );
		return 1;
	}

	//�Ҹ���ȣ�� �����. ����Ȯ��
	new str[128];
	if( stage == MUSIC_STAGE_TYPE || stage == MUSIC_STAGE_TYPECUSTOM )
	{
	    //������ȣ ����
	    if( stage == MUSIC_STAGE_TYPE ) soundid = MUSIC_STORAGE[listitem][weapon_id];
		else soundid = strval(inputtext);
		//����Ȯ��
		stage = MUSIC_STAGE_AREYOUSURE;
		format( str, sizeof(str), "���� �÷��̾�� ������ ����մϴ�: %s(%d).\n�Ҹ� ��ȣ: %d.\n����Ͻðڽ��ϱ�?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], soundid );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		return 1;
	}

    //������� ��ɾ� ������
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
dialog_musicoff( playerid, response, listitem, inputtext[] ) //�Ҹ�����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�Ҹ����� ��ɾ� ������
	dcmd_mute( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_MUTE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_bomb( playerid, response, listitem, inputtext[] ) //��ź ��Ʈ����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //��ź ��Ʈ���� ��ɾ� ������
	dcmd_bomb( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_BOMB, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_shutup( playerid, response, listitem, inputtext[] ) //ä�ñ���
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ä�ñ��� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_shutup( playerid, str, CMD_SHUTUP, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_unshut( playerid, response, listitem, inputtext[] ) //ä������
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //ä������ ��ɾ� ������
	dcmd_unshut( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_UNSHUT, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_changenick( playerid, response, listitem, inputtext[] ) //�йٲٱ�
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );
	if( !inputtext[0] )
	{
	    SendClientMessage( playerid, COLOR_GREY, "* ���� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_ADMIN_CHANGENICK );
	}
    //�йٲٱ� ��ɾ� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_chnick( playerid, str, CMD_CHNICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_spectate( playerid, response, listitem, inputtext[] ) //�����ϱ�
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //���� ��ɾ� ������
	dcmd_spectate( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SPECTATE, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_subadmin( playerid, response, listitem, inputtext[] ) //�ο�� �Ӹ�
{
	#define SUBADMIN_STAGE_TYPE 0
	#define SUBADMIN_STAGE_AREYOUSURE 1
	static stage, authid;
	//����� ���
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

	//������ �����. ����Ȯ��
	new str[128];
	if( stage == SUBADMIN_STAGE_TYPE )
	{
	    //���ѹ�ȣ ����
	    authid = listitem;
		//����Ȯ��
		stage = SUBADMIN_STAGE_AREYOUSURE;
		format( str, sizeof(str), "���� �÷��̾ �ο�ڷ� �Ӹ��մϴ�: %s(%d).\n�ο��� ����: %s.\n����Ͻðڽ��ϱ�?",
			GetPlayerNameEx( DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid], inputtext );
		ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		return 1;
	}

    //�ο�� �Ӹ� ��ɾ� ������
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
dialog_delsub( playerid, response, listitem, inputtext[] ) //�ο�� ��Ż
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�ο�� ��Ż ��ɾ� ������
	dcmd_suspend( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_SUSPEND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_find( playerid, response, listitem, inputtext[] ) //�� ������ ���� ����
{
	//����� ���
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_ADMIN_MAIN );

    //�������� ��ɾ� ������
	dcmd_find( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_FIND, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem, inputtext
	return 1;
}
//==========================================================
dialog_usermain( playerid, response, listitem, inputtext[] ) //����� ���� ��ȭ����
{
	//����� ���
	if( !response ) return 1;

	switch( listitem )
	{
	    case 0: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEKICK ); //Kick Player
	    case 1: ShowPlayerDialogs( playerid, DIALOG_USER_VOTEBAN );//Ban Player
		case 2: //�޼��� ������
	    {
			#if !SAMP03x
			SendClientMessage( playerid, COLOR_RED, "* SA-MP�� ���װ� �����Ƿ� �ѱ��� �Է����� ���ñ� �ٶ��ϴ�.");
			#endif
			ShowPlayerDialogs( playerid, DIALOG_PM );
		}
	}
	#pragma unused inputtext
	return 1;
}
//==========================================================
dialog_superpm( playerid, response, listitem, inputtext[] ) //�ӼӸ�
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    //�Է����� ���� ���
	if( !inputtext[0] )
	{
		SendClientMessage( playerid, COLOR_GREY, "* �޼����� �Է��Ͽ� �ֽʽÿ�.");
	    return ShowPlayerDialogs( playerid, DIALOG_PM );
	}
	//�޼��� ������
	new str[128];
	format( str, sizeof(str), "%d %s", DIALOG_CLICKED_PLAYER[playerid], inputtext );
	dcmd_spm( playerid, str, CMD_SPM, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem
	return 1;
}
//==========================================================
dialog_votekick( playerid, response, listitem, inputtext[] ) //����� �����߹� ��ǥ
{
	if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
	dcmd_vkick( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VKICK, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}
//==========================================================
dialog_voteban( playerid, response, listitem, inputtext[] ) //����� �����߹� ��ǥ
{
    if( !response ) return ShowPlayerDialogs( playerid, DIALOG_USER_MAIN );
    dcmd_vban( playerid, RetStr(DIALOG_CLICKED_PLAYER[playerid]), CMD_VBAN, NO_HELP );
    DIALOG_CLICKED_PLAYER[playerid]=INVALID_PLAYER_ID;
    #pragma unused listitem,inputtext
	return 1;
}

//==========================================================
#endif /* SA-MP 0.3a�� ���̾�α� ��� ��� */
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
			printf( "[help] ����: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ��� ������ ��ɾ��� ����� ���ϴ�." );
			printf( "[help] %s [��ɾ� �̸�] �� �Է��ϸ� �ش� ��ɾ��� ������ �����ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s, %s ���", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
			format( str, sizeof(str), "* ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ����: ��� ������ ��ɾ��� ����� ���ϴ�." );
			format( str, sizeof(str), "* ����: /%s [��ɾ� �̸�] �� �Է��ϸ� �ش� ��ɾ��� ������ �����ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s, /%s ���", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);			
		}
		return 1;
	}

	if( !isnull(params) )
	{
		//�� ��ɾ�� ������ �����̷�Ʈ�Ѵ�
		//���̳ʸ� Ʈ�� ���
		new i, hash, str[128];
		hash = fnv_hash( params );
		//�ѱۿ��� ���� �˻�
		i = Bintree_FindValue( TREE_CMDLIST_HANGUL, hash );
		if( i == BINTREE_NOT_FOUND ) //�ѱۿ� ���� ����� �˻�
		{
			i = Bintree_FindValue( TREE_CMDLIST_ENGLISH, hash );
			if ( i == BINTREE_NOT_FOUND )
			{
				//�� �� ���� ��ɾ�
				if( CONSOLE ) printf("[rcon] �� �� ���� ��ɾ��Դϴ� :  %s", params );
				else
				{
					format( str, sizeof(str), "* �� �� ���� ��ɾ��Դϴ� :  %s", params );
					SendClientMessage( playerid, COLOR_GREY, str );
				}
				return 1;
			}
		}
		format( str, sizeof(str), "dcmd_%s", cmdlist[Cmdorder:i][Func] );
		CallLocalFunction( str, "isib", playerid, NULL, i, true ); //help mode
		return 1;
	}
	
	//��ɾ� ��� ǥ��
	new str[256];
	if( CONSOLE )
	{
		print("\n=====================  Rcon Controller : Command List  ========================");
		print("           �ڼ��� ������ ������ ���� [��ɾ� �̸�] �� �Է��Ͻʽÿ�.");
		print(LINE);	
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, "===========  Rcon Controller : Command List  ==========");
		format( str, sizeof(str), "           �ڼ��� ������ ������ /%s [��ɾ� �̸�] �� �Է��Ͻʽÿ�.", cmdlist[CMD_HELP][Cmd] );
		SendClientMessage( playerid, COLOR_SALMON, str );
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);	
	}
	
	//��ɾ �������� �����Ͽ� ǥ��
	new idx;
	//���η� ǥ��
	new lines = ceildiv(sizeof( cmdlist ), 6); //�������� ���Ѵ�
	for( new i = 0 ; i < lines ; i++ ) //�ٸ�ŭ �ݺ�
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
		
		//printf(" ó�� ����Ͻô� ���� ��� 
	}
	else
	{
		SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		//format( str, sizeof(str), "      Total %d Commands, (C) 2008 - 2013 CoolGuy(��Ծ���)", sizeof( cmdlist ) );
		//SendClientMessage( playerid, COLOR_SALMON, str );
		//SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
	}
	/*
		���� ��� :  if( HELP )
	*/
	return 1;	
}
//==========================================================
public dcmd_rchelp2(playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	//FIXME: ���� �Ǿ����ϴ�. �ٸ� ��ɾ�� �ٲٴ� ���� �ʿ��մϴ�.
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] ����: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ��� ��ɾ ���� ������ ������ �����ݴϴ�." );
			printf( "[help] ��) %s", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ��� ��ɾ ���� ������ ������ �����ݴϴ�." );
			format( str, sizeof(str), "* ��) /%s", CURRENT_CMD_NAME ); SEND();
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
			printf( "[help] ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Ư�� �÷��̾�Է� �̵��մϴ�." );
			printf( "[help] ��) /%s 10 : 10������ �̵��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) /%s coolguy : coolguy���� �̵��մϴ�.", CURRENT_CMD_NAME );
			print("[help] ���� �߿��� �����ϸ�, �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Ư�� �÷��̾�Է� �̵��մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10������ �̵��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� �̵��մϴ�.", CURRENT_CMD_NAME ); SEND();
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
	SendClientMessage(playerid, COLOR_GREENYELLOW, "* ��� �Ͽ����ϴ�.");
	printf("[rcon] %s(%d)���� %s(%d)�Կ��� ����Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Ư�� �÷��̾ �̰����� �����ɴϴ�." );
			printf("[help] /%s *�� �Է��ϸ� ��� �÷��̾ �̰����� �����ɴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) /%s 10: 10���� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) /%s coolguy: 10���� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) /%s *: ��θ� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME );
			print("[help] ���� �߿��� �����ϸ�, �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* Ư�� �÷��̾ �̰����� �����ɴϴ�." );
			format( str, sizeof(str), "* /%s *�� �Է��ϸ� ��� �÷��̾ �̰����� �����ɴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 10: 10���� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy: 10���� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s *: ��θ� �̰����� �����ɴϴ�.", CURRENT_CMD_NAME ); SEND();
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
			format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� ��ȯ�Ͽ����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			printf("[rcon] %s(%d)���� �÷��̾� ��θ� ��ȯ�Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid );
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
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ��ȯ�Ͽ����ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� %s(%d)���� ��ȯ�Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid,GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ο�� �ڰ��� �����Ͽ� ������ ����ϴ�." );
			print( "[help] �ο�� �ڰ��� RconController.ini���� ����� �� �ֽ��ϴ�. ");
			printf( "[help] ��) /%s password: ��й�ȣ 'password'�� ����Ͽ� �ο�ڷ� �α����մϴ�. ", CURRENT_CMD_NAME );
			print("[help] ���� �߿��� �����ϸ�, �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ο�� �ڰ��� �����Ͽ� ������ ����ϴ�."  );
			SendClientMessage( playerid, COLOR_LIME, "* �ο�� �ڰ��� �����÷��� ��ڿ��� �����ϼ���." );
			format( str, sizeof(str), "* ��) /%s password: ��й�ȣ 'password'�� ����Ͽ� �ο�ڷ� �α����մϴ�. ", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	No_Console();	

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� �ο�� ����� ���ѵǾ� �ֽ��ϴ�. �����ڿ��� �����ϼ���" );
		print( "[rcon] �ο�� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���." );
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
		SendClientMessage( playerid, COLOR_GREY, "* �̹� �ο���Դϴ�." );
		return 1;
	}
	
	if(isnull(params)) return Usage( playerid, CMD_CURRENT );

	for(new i=0;i<Num_SubAdmin;i++)
	{
		if(!strcmp(GetPlayerNameEx(playerid),SubAdmin[i][Name]) && !strcmp(PLAYER_IP[playerid],SubAdmin[i][IP]) && SubAdmin[i][Password_Hash]==fnv_hash(params))
		{
			//�α��� ���� Ƚ�� �ʱ�ȭ
			SUBADMIN_FAILLOGIN_TIMES[playerid] = 0;
			//�޼��� ����
			format(tmp,sizeof(tmp),"* %s(%d)�Բ��� �ο�ڷ� �α��� �ϼ̽��ϴ�.",GetPlayerNameEx(playerid),playerid);
			SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
			SendClientMessage(playerid,COLOR_ORANGE,"* ������ /rchelp�̸�, �α׾ƿ��� /subout �Ǵ� /�ο����� �Դϴ�.");
			printf("[rcon] %s(%d)�Բ��� �ο�ڷ� �α��� �ϼ̽��ϴ�.",GetPlayerNameEx(playerid),playerid);			
			SetPlayerSubAdmin( playerid, SubAdmin[i][profile_index] );
			return 1;
		}
	}

	SUBADMIN_FAILLOGIN_TIMES[playerid]++;
	if( SUBADMIN_FAILLOGIN_TIMES[playerid] >= SUBADMIN_FAILLOGIN_LIMIT )
	{
		format(tmp,sizeof(tmp),"* %s(%d)�Բ��� �ο�� �α��ο� �����Ͽ� �߹�˴ϴ�.",GetPlayerNameEx(playerid),playerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,tmp);
		printf("[rcon] %s(%d)�Բ��� �ο�� �α��ο� �����Ͽ� �߹�˴ϴ�.",GetPlayerNameEx(playerid),playerid);
		Kill( playerid );
		c_Kick(playerid);
		return 1;
	}
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* �ο�� �α��ο� �����Ͽ����ϴ�. �ٽ� �õ��� ������.");
	printf("[rcon] %s(%d)�Բ��� �ο�� �α��ο� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid);
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
			printf( "[help] ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] �ο�� �ڰ��� �ݳ��ϰ� �Ϲ� ������ �˴ϴ�." );
			printf( "[help] ��) /%s : �ο�� �ڰ��� �ݳ��ϰ� �Ϲ� ������ �˴ϴ�.", CURRENT_CMD_NAME );
			print("[help] ���� �߿��� �����ϸ�, �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ο�� �ڰ��� �ݳ��ϰ� �Ϲ� ������ �˴ϴ�." );
			format( str, sizeof(str), "* ��) /%s : �ο�� �ڰ��� �ݳ��ϰ� �Ϲ� ������ �˴ϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();
	
	if( !IsPlayerSubAdmin( playerid ) )
	{
		SendClientMessage( playerid, COLOR_GREY, "* �ο�ڰ� �ƴմϴ�." );
		return 1;
	}
	
	new str[70];
	format(str,sizeof(str),"* %s(%d)�Բ��� �ο�� ������ �ݳ��Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid);
	SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
	SendClientMessage(playerid,COLOR_GREENYELLOW,"* �α׾ƿ� �Ͽ����ϴ�.");
	printf("[rcon] %s(%d)�Բ��� �ο�� ������ �ݳ��Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid);
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
			printf( "[help] ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� ����ڿ� ���� ���� ������ ���ϴ�." );
			print( "[help] TABŰ�� ������ ������ ����Ŭ���Ͽ� �� ���� �ֽ��ϴ�.");
			printf( "[help] ��) /%s 10 : 10�� ����ڸ� ��� ���������� â�� ���ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) /%s coolguy : coolguy�� ��� ���������� â�� ���ϴ�.", CURRENT_CMD_NAME );
			print("[help] ���� �߿��� �����ϸ�, �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ش� ����ڿ� ���� ���� ������ ���ϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* TABŰ�� ������ ������ ����Ŭ���Ͽ� �� ���� �ֽ��ϴ�.");
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� ��� ���������� â�� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� ��� ���������� â�� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
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
#endif /* SA-MP 0.3a�� ���̾�α� ��� ��� */
//==========================================================
public dcmd_cmdtrace( playerid, params[], Cmdorder:CMD_CURRENT, bool:HELP )
{
	if( HELP )
	{
		//CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME
		if( CONSOLE )
		{
			print(LINE);
			printf( "[help] ����: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] ��ɾ� ������ ����/�����մϴ�." );
			print("[help] �ٸ� �÷��̾��� ��ɾ �ֿܼ� �ǽð����� ǥ���ϴ� ����Դϴ�." );
			printf( "[help] ��) %s : ��ɾ� ������ ����/�����մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ��ɾ� ������ ����/�����մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ��ɾ� ������ �ٸ� �÷��̾��� ��ɾ ä��â�� �ǽð����� ǥ���ϴ� ����Դϴ�." );
			format( str, sizeof(str), "* ��) /%s : ��ɾ� ������ ����/�����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	IS_HEAR_CMDTRACE[playerid] = !IS_HEAR_CMDTRACE[playerid];
	
	if( CONSOLE ) printf("[rcon] ��ɾ� ��������� %s�Ͽ����ϴ�.", (IS_HEAR_CMDTRACE[playerid])? ("����"):("�ߴ�") );
	else
	{
		SendClientMessage(playerid,COLOR_GREENYELLOW,(IS_HEAR_CMDTRACE[playerid])? ("* ��ɾ� ������ �����Ͽ����ϴ�."):("* ��ɾ� ������ �ߴ��Ͽ����ϴ�."));
		printf("[rcon] %s(%d)�Բ��� ��ɾ� ������ %s�ϼ̽��ϴ�.",GetPlayerNameEx(playerid),playerid,(IS_HEAR_CMDTRACE[playerid])? ("����"):("�ߴ�"));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾��� ������ �����Ͽ� �����մϴ�." );
			printf( "[help] ��) %s 10 : 10�� ������� ������ �����Ͽ� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy�� ������ �����Ͽ� �����մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s ", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾��� ������ �����Ͽ� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ������� ������ �����Ͽ� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� ������ �����Ͽ� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� �ӼӸ��� �����ϴ�." );
			printf( "[help] %s Admin �Ǵ� ��ڸ� ����Ͻø� ���� ��ڿ��� �޼����� ���� �� �ֽ��ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy �ȳ� : coolguy���� \"�ȳ�\"�̶�� �޼����� �����ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s ��� ��� ¼��: ��ڿ��� '��� ¼��' ��� �̾߱��մϴ�.", CURRENT_CMD_NAME );
			print( LINE );
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT );
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ش� �÷��̾�� �ӼӸ��� �����ϴ�." );
			format( str, sizeof(str), "* /%s Admin �Ǵ� ��ڸ� ����Ͻø� ���� ��ڿ��� �޼����� ���� �� �ֽ��ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy �ȳ� : coolguy���� \"�ȳ�\"�̶�� �޼����� �����ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s ��� ��� ¼�� : ��ڿ��� '��� ¼��' ��� �̾߱��մϴ�.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //���� �Է�
			{
				//�߸� �� ��� Ȯ��
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ���濡�� �� ���� �� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ���濡�� �� ���� �� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ڱ��� �Է�
			{
				//�� ���� ���� ���
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] ���� �޼����� �� �ֽʽÿ�. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ���� �޼����� �� �ֽʽÿ�. ");
					return 1;
				}
				format( msg, sizeof(msg), "%s", tmp ); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ��� �ڰ����� ��ȭ�մϴ�." );
			printf( "[help] ��) %s �˷��帳�ϴ� : ��� �ڰ����� \"�˷��帳�ϴ�\" ��� ���մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ����Ͽ� ��� �ڰ����� �̾߱��Ϸ��� %s ��ɾ ����Ͻʽÿ�." , GetCmdName(CMD_PSAY) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ��� �ڰ����� ��ȭ�մϴ�." );
			format( str, sizeof(str), "* ��) /%s �˷��帳�ϴ� : ��� �ڰ����� \"�˷��帳�ϴ�\" ��� ���մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) ����Ͽ� ��� �ڰ����� �̾߱��Ϸ��� /%s ��ɾ ����Ͻʽÿ�." , GetCmdName(CMD_PSAY) ); SEND();
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
		format(str,sizeof(str),"* �ο�� %s: %s", GetPlayerNameEx(playerid), params);
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
			printf( "[help] ����: %s or %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			print( "[help] �׻� ��� �ڰ����� ��ȭ�ϵ��� �����մϴ�." );
			print( "[help] ����� ���¿��� ��ɾ ����Ұ�� ��ɾ� �տ� !�� ���̸� �˴ϴ�." );
			print( "[help] ����带 �����Ϸ��� !����� �� �Է��Ͻʽÿ�." );
			printf( "[help] ��) %s : �׻� ��� �ڰ����� ��ȭ�ϵ��� �����մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �׻� ��� �ڰ����� ��ȭ�ϵ��� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s : �׻� ��� �ڰ����� ��ȭ�ϵ��� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	PERMANENT_ADMINSAY[playerid] = !PERMANENT_ADMINSAY[playerid];
	if( CONSOLE )
	{
		if ( PERMANENT_ADMINSAY( playerid ) )
		{
			print( "[rcon] ��ڸ� ���� ��ȯ�߽��ϴ�." );
			print( "[help] ����� ���¿��� ��ɾ ����Ұ�� ��ɾ� �տ� !�� ���̸� �˴ϴ�." );
			print( "[help] ����带 �����Ϸ��� !����� �� �Է��Ͻʽÿ�." );
		}
		else
		{
			print ("[rcon] ��ڸ� ��带 �����߽��ϴ�." );
		}
	}
	else SendClientMessage( playerid, COLOR_GREENYELLOW, PERMANENT_ADMINSAY(playerid)? ( "* ��ڸ� ���� ��ȯ�߽��ϴ�." ):( "* ��ڸ� ��带 �����߽��ϴ�." ) );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ������ �ð��� �����մϴ�. 24�ð����� ǥ���մϴ�." );
			printf( "[help] ��) %s 21: ���� �ð��� ���� 09:00���� �����մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ���� ������ �ð��� �����մϴ�. 24�ð����� ǥ���մϴ�." );
			format( str, sizeof(str), "* ��) /%s 21: ���� �ð��� ���� 09:00���� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] �ٲٰ� ���� �ð��� �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* �ٲٰ� ���� �ð��� �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}
	
	if(isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 23)
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] �ð��� ����� �Է��Ͽ� �ֽʽÿ�." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* �ð��� ����� �Է��Ͽ� �ֽʽÿ�." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[36];
	format(str,sizeof(str),"* �ð��� %d:00 ���� ����Ǿ����ϴ�.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWorldTime(strval(params));
	printf("[rcon] �ð��� %d:00 ���� ����Ǿ����ϴ�.",strval(params));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ ����մϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڸ� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy�� ����մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ ����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
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
				SendClientMessageToAll(COLOR_GREENYELLOW, "* ��ڰ� �÷��̾� ��θ� ����Ͽ����ϴ�.");
				print("[rcon] ��� �÷��̾ ����߽��ϴ�.");			
			}
			else 
			{
				new str[81];
				format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� ����Ͽ����ϴ�.", GetPlayerNameEx(playerid));
				SendClientMessageToAll(COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� �÷��̾� ��θ� ����Ͽ����ϴ�.",GetPlayerNameEx(playerid),playerid );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) Kill(pITT[i]);
			return 1;
		}
	}
	
	new str[79];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ����߽��ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ ���� �߹��մϴ�." );
			print( "[help] [����]�� ���ڸ� ������ �߹�Ǵ� �������� �޼����� ���۵˴ϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڸ� ������ �������� �ʰ� �߹��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy ��ų� ���� : coolguy�� '��ų� ����'�� �ؼ� �߹��մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ ���� �߹��մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* [����]�� ���ڸ� ������ �߹�Ǵ� �������� �޼����� ���۵˴ϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� ������ �������� �ʰ� �߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy ��ų� ���� : coolguy�� '��ų� ����'�� �ؼ� �߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//���� ���μ���
	sscanf(tmp,"ss",params,reason);
	if(isnull(tmp)) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //���� �Է�
			{
				//�߸� �� ��� Ȯ��
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] �߹��ϴ� ������ ������ �� �ֽʽÿ�. ������ '0' �� �����ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* �߹��ϴ� ������ ������ �� �ֽʽÿ�. ������ 0 �� �����ֽʽÿ�." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ڱ��� �Է�
			{			
				if( isnull(tmp) || tmp[0] =='0' ) reason[0] = EOS; //������ ���� ���
				else format( reason, sizeof(reason), "%s", tmp ); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
					printf("[rcon] ��� �÷��̾ �߹��߽��ϴ�. (���� : %s)", reason );
					format( reason, sizeof(reason), "* ��ڰ� �÷��̾� ��θ� �߹��Ͽ����ϴ�.(���� : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* ��ڰ� �÷��̾� ��θ� �߹��Ͽ����ϴ�.");
					print("[rcon] ��� �÷��̾ �߹��߽��ϴ�.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� �߹��Ͽ����ϴ�.(���� : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)���� �÷��̾� ��θ� �߹��Ͽ����ϴ�.(���� : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� �߹��Ͽ����ϴ�.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)���� �÷��̾� ��θ� �߹��Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_Kick(pITT[i]);
			return 1;
		}
	}
	
	new str[216];	
	if( strlen(reason) ) format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �߹��߽��ϴ�.(���� : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �߹��߽��ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �߹��߽��ϴ�.(���� : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("���� ����"));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ �߹��ϸ�, ���� ������ �����մϴ�." );
			print( "[help] [����]�� ���ڸ� ������ �߹�Ǵ� �������� �޼����� ���۵˴ϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڸ� ������ �������� �ʰ� �����߹��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy �ٻ�� : coolguy�� '�ٻ��'�� �ؼ� �����߹��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �����߹��� ����Ϸ��� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ �߹��ϸ�, ���� ������ �����մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* [����]�� ���ڸ� ������ �߹�Ǵ� �������� �޼����� ���۵˴ϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� ������ �������� �ʰ� �����߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy �ٻ�� : coolguy�� '�ٻ��'�� �ؼ� �����߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �����߹��� ����Ϸ��� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNBAN) );			 SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, reason[128];
	
	//���� ���μ���
	sscanf(tmp,"ss",params,reason);
	if( isnull(tmp) ) if( giveplayerid != HELP_PROCESS) return Usage( playerid, CMD_CURRENT );
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //���� �Է�
			{
				//�߸� �� ��� Ȯ��
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] �����߹��ϴ� ������ ������ �� �ֽʽÿ�. ������ '0' �� �����ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* �����߹��ϴ� ������ ������ �� �ֽʽÿ�. ������ 0 �� �����ֽʽÿ�." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ڱ��� �Է�
			{			
				if( isnull(tmp) || tmp[0] == '0' ) reason[0] = EOS; //������ ���� ���
				else format( reason, sizeof(reason), "%s", tmp ); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
					printf("[rcon] ��� �÷��̾ �����߹��߽��ϴ�. (���� : %s)", reason );
					format( reason, sizeof(reason), "* ��ڰ� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.(���� : %s)", reason );
					SendClientMessageToAll(COLOR_GREENYELLOW, reason );
				}
				else
				{
					SendClientMessageToAll(COLOR_GREENYELLOW, "* ��ڰ� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.");
					print("[rcon] ��� �÷��̾ �����߹��߽��ϴ�.");
				}
			}
			else 
			{
				new str[81];
				if( strlen(reason) )
				{
					format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.(���� : %s)", GetPlayerNameEx(playerid), reason );
					printf("[rcon] %s(%d)���� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.(���� : %s)", GetPlayerNameEx(playerid), playerid, reason );
				}
				else
				{
					format(str,sizeof(str),"* ��� %s(��)�� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.", GetPlayerNameEx(playerid));
					printf("[rcon] %s(%d)���� �÷��̾� ��θ� �����߹��Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid );
				}
				SendClientMessageToAll(COLOR_GREENYELLOW,str);		
			}
			for( new i = 0; i < NUM_PLAYERS; i++ ) c_BanEx( pITT[i], reason );
			return 1;
		}
	}
	
	new str[220];	
	if( strlen(reason) ) format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �����߹��߽��ϴ�.(���� : %s)", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid, reason );
	else format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �����߹��߽��ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �����߹��߽��ϴ�.(���� : %s)",GetPlayerNameEx(giveplayerid),giveplayerid,strlen(reason)? (reason):("���� ����"));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �÷��̾�� �������� ���� �ְų� �����ϴ�." );
			printf( "[help] ��) %s 10 10000 : 10������ $10000�� ���� �ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy -20 : coolguy���Լ� $20�� �����ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �÷��̾��� ���� $0���� ������� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_FORFEIT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �÷��̾�� �������� ���� �ݴϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 10000 : 10������ $10000�� ���� �ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy -20 : coolguy���Լ� $20�� �����ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �÷��̾��� ���� $0���� ������� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_FORFEIT) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ���濡�� �� ���� ���� �� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ���濡�� �� ���� ���� �� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�� �� �Է�
			{
				//�� ���� ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) || strval(tmp) == 0 )
				{
					if( CONSOLE ) print("[rcon] ���� ���� ����� �� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ���� ���� ����� �� �ֽʽÿ�.");
					return 1;
				}
				amount = strval(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾�� $%d�� ���� ����־����ϴ�.", amount );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾�� $%d�� ���� ����־����ϴ�.", amount);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾�� $%d�� ���� ����־����ϴ�.", GetPlayerNameEx(playerid), playerid, amount);
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ��� %s(��)�� ��ſ��� $%d�� ���� ����־����ϴ�.", GetPlayerNameEx(playerid), amount);
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
		format(str,sizeof(str),"* %s(%d)�Կ��� $%d�� ���� ����־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)���� %s(%d)�Կ��� $%d�� ���� ����־����ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	}
	else printf("[rcon] %s(%d)�Կ��� $%d�� ���� ����־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,amount);
	
	format(str,sizeof(str),"* ��� %s(��)�� ��ſ��� $%d�� ���� ����־����ϴ�.", GetPlayerNameEx(playerid), amount);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �÷��̾�� ����� ź���� �����մϴ�." );
			print( "[help] [�Ѿ�] ���� �������� �ʴ� ��� 3000���� �����ϰ� �˴ϴ�." );
			printf( "[help] ��) %s 10 32 50 : 10������ 32�� ����(TEC-9)�� 50���� ź���� �ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 38: coolguy���� 38�� ����(�̴ϰ�)�� 3000���� ź���� �ݴϴ�.", CURRENT_CMD_NAME );
			print( "[help] �ֿ� ���� ��� : TEC9-32, ����-35, �̴ϰ�-38 ");
			printf( "[help] ���⸦ �������� %s ����� ����Ͻʽÿ�.", GetCmdName(CMD_DISARM) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �÷��̾�� ����� ź���� �����մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* [�Ѿ�] ���� �������� �ʴ� ��� 3000���� �����ϰ� �˴ϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 32 50 : 10������ 32�� ����(TEC-9)�� 50���� ź���� �ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 38: coolguy���� 38�� ����(�̴ϰ�)�� 3000���� ź���� �ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �ֿ� ���� ��� : TEC9-32, ����-35, �̴ϰ�-38 "); SEND();
			format( str, sizeof(str), "* ���⸦ �������� %s ����� ����Ͻʽÿ�.", GetCmdName(CMD_DISARM) ); SEND();
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
			printf("[rcon] ����: %s or %s [�̸��̳� ��ȣ] [�����ȣ] [�Ѿ� = 3000��]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			printf("[rcon] �ڼ��� ������ ���� %s ��(��) �Է��ϼ���.", GetCmdName(CMD_GIVEWP) );
		}
		else
		{
			format( str, sizeof(str), "* ����: /%s or /%s [�̸��̳� ��ȣ] [�����ȣ] [�Ѿ� = 3000��]", GetCmdName(CMD_GIVEWP), GetCmdAltName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
			format( str, sizeof(str), "* �ڼ��� ������ /%s %s ��(��) �Է��ϼ���.", GetCmdName(CMD_HELP), GetCmdName(CMD_GIVEWP) );
			SendClientMessage(playerid, COLOR_GREY, str );
		}
		return 1;
	}
	if(isNumeric(params) && strval(params)>=0 && strval(params)<M_P && IsPlayerConnectedEx(strval(params))) giveplayerid=strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid=PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		return 1;
	}

	if( USE_ANTI_WEAPONCHEAT && IsWeaponForbidden(weaponid) )
	{
		if(CONSOLE) print("[rcon] �������� ����� ������ �����Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �������� ����� ������ �����Դϴ�.");
		return 1;
	}
	GivePlayerWeapon(giveplayerid,weaponid,(ammo)? (ammo):(3000));
	new str[148];
	GetWeaponName(weaponid,str,sizeof(str));
	printf("[rcon] %s(%d)�Կ��� ���� %s��(��) %d���� ź���� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)�Կ��� ���� %s��(��) %d���� ź���� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,str,(ammo)? (ammo):(3000));
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	GetWeaponName(weaponid,str,sizeof(str));
	format(str,sizeof(str),"* ��� %s(��)�� ��ſ��� ���� %s��(��) %d���� ź���� �־����ϴ�.", GetPlayerNameEx(playerid), str,(ammo)? (ammo):(3000));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾��� �̸��� �����մϴ�." );
			print( "[help] Ư���� �÷������� ����ϴ� ������ ��� �ѱ� �г��� ���뵵 �����մϴ�." );
			printf( "[help] ��) %s 10 �ɿ� : 10�� ������� �г����� '�ɿ�' ���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy Cool : coolguy�� �г����� Cool�� �ٲߴϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾��� �̸��� �����մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* Ư���� �÷������� ����ϴ� ������ ��� �ѱ� �г��� ���뵵 �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 �ɿ� : 10�� ������� �г����� '�ɿ�' ���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy Cool : coolguy�� �г����� Cool�� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	static INTERACTIVE_ADMIN_TEMP;
	new params[MAX_PLAYER_NAME], giveplayerid, nick[MAX_PLAYER_NAME];
	
	//���� ���μ���
	sscanf(tmp,"ss",params,nick);	
	giveplayerid = Process_GivePlayerID( playerid, params );
	
	//Interactive command
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT )
	{
		switch ( INTERACTIVE_STATE[playerid] )
		{
			case 0: //���� �Է�
			{
				//�߸� �� ��� Ȯ��
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] �ٲ� �г����� ���� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* �ٲ� �г����� ���� �ֽʽÿ�." );
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ڱ��� �Է�
			{			
				//�� ���� ���� ���
				if( isnull(tmp) )
				{
					if( CONSOLE ) print("[rcon] �г����� �� �ֽʽÿ�. ");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �г����� �� �ֽʽÿ�. ");
					return 1;
				}
				format( nick, sizeof(nick), "%s", tmp ); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
	//debugprintf("[rcon] �ٲ� �г��� : %s, ���� �г���: %s", nick, str );
	if( strcmp( nick, str, false ) == 0 )
	{
		format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �г����� %s(��)�� �ٲ���ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)���� �г����� %s(��)�� �ٲ���ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,nick);
		PLAYER_NAME[giveplayerid] = nick;
	}
	else
	{
		if( CONSOLE ) print("[rcon] �г��� ���濡 �����߽��ϴ�. �����Ϸ��� �г��ӿ� ������ �ֽ��ϴ�.");
		else SendClientMessage( playerid, COLOR_RED, "* �г��� ���濡 �����߽��ϴ�. �����Ϸ��� �г��ӿ� ������ �ֽ��ϴ�." );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾��� ü���� �����մϴ�." );
			print( "[help] �Ϲ������� �⺻ ü���� 100�̸�, 0�� ����Դϴ�." );
			printf( "[help] ��) %s 10 20.0 : 10���� ü���� 20.0���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 56.7 : coolguy�� ü���� 56.7�� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ü���� 0���� ������� %s ��ɾ, �������� ������� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾��� ü���� �����մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* �Ϲ������� �⺻ ü���� 100�̸�, 0�� ����Դϴ�." );			
			format( str, sizeof(str), "* ��) /%s 10 20.0 : 10���� ü���� 20.0���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 56.7 : coolguy�� ü���� 56.7�� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ü���� 0���� ������� /%s ��ɾ, �������� ������� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_SKILL), GetCmdName(CMD_INFINITE) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ������ ü���� ���� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ������ ü���� ���� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //ü�� �Է�
			{
				//ü���� ����� �Էµ��� ���� ���
				if( isnull(tmp) || floatstr(tmp) <= 0.0 )
				{
					if( CONSOLE ) print("[rcon] ü���� ����� ���� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ü���� ����� ���� �ֽʽÿ�.");
					return 1;
				}
				health = floatstr(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾��� ü���� %.1f�� �����߽��ϴ�.", health );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾��� ü���� %.1f�� �����߽��ϴ�.", health );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ü���� %.1f�� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, health);
			}
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ü���� %.1f���� �����߽��ϴ�.", GetPlayerNameEx(playerid), health);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth(pITT[i], health);
			return 1;
		}
	}

	new str[99];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ü���� %.1f���� �����߽��ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx(giveplayerid), giveplayerid, health);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ü���� %.1f���� �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,health);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾��� �ƸӸ� �����մϴ�." );
			printf( "[help] ��) %s 10 0 : 10���� �ƸӸ� ���۴ϴ�. ",  CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 70.0 : coolguy�� �ƸӸ� 70.0���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �⺻ �ƸӴ� 100�̸�, �Ƹ� ������ %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_INFARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾��� �ƸӸ� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 0 : 10���� �ƸӸ� ���۴ϴ�. ",  CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 70.0 : coolguy�� �ƸӸ� 70.0���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) �⺻ �ƸӴ� 100�̸�, �ƸӸ� �������� ������� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_INFARMOR) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ������ �ƸӸ� ���� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ������ �ƸӸ� ���� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�Ƹ� �Է�
			{
				//�ƸӰ� ����� �Էµ��� ���� ���
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] �ƸӸ� ����� ���� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �ƸӸ� ����� ���� �ֽʽÿ�.");
					return 1;
				}
				armour = floatstr(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾��� �ƸӸ� %.1f�� �����߽��ϴ�.", armour );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾��� �ƸӸ� %.1f�� �����߽��ϴ�.", armour );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾��� �ƸӸ� %.1f�� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, armour);
			}
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� �ƸӸ� %.1f���� �����߽��ϴ�.", GetPlayerNameEx(playerid), armour);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], armour);
			return 1;
		}
	}	

	new str[98];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �ƸӸ� %.1f���� �����߽��ϴ�.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid,armour);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �ƸӸ� %.1f���� �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,armour);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ �׿��� ����ϴ�." );
			print( "[help] �ƸӰ� ������ �Ǹ� �Ѿ� ���� ��ݿ� �ߵ� �� �ֽ��ϴ�." );			
			printf( "[help] ��) %s 10 : 10�� ����ڸ� �Ƹ� �������� ����ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy�� �Ƹ� �������� ����ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �ƸӸ� ���ַ��� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_ARMOR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ �׿��� ����ϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* �ƸӰ� ������ �Ǹ� �Ѿ� ���� ��ݿ� �ߵ� �� �ֽ��ϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� �Ƹ� �������� ����ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� �Ƹ� �������� ����ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �ƸӸ� ���ַ��� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_ARMOR) ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� �ƸӸ� �������� ��������ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� �ƸӸ� �������� ��������ϴ�.");
				printf("[rcon] %s(%d)���� ��� �÷��̾��� �ƸӸ� �������� ��������ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� �ƸӸ� �������� ��������ϴ�.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerArmour(pITT[i], 10000.0);
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �ƸӸ� �������� ��������ϴ�.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �ƸӸ� �������� ��������ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾��� ������ �����մϴ�." );
			printf( "[help] ��) %s 10 50 : 10�� ������� ������ 50���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 100 : coolguy�� ������ 100���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾��� ������ �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 50 : 10�� ������� ������ 50���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 100 : coolguy�� ������ 100���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ������ ������ �Է��� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ������ ������ �Է��� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ھ� �Է�
			{
				//���ھ ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] ������ ����� �Է��� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ������ ����� �Է��� �ֽʽÿ�.");
					return 1;
				}
				score = strval(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾��� ������ %d�� �����Ͽ����ϴ�.", score );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾��� ������ %d�� �����Ͽ����ϴ�.", score );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ������ %d�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, score);
			}
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ������ %d�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), score);
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerScore(pITT[i], score);
			return 1;
		}
	}
	
	SetPlayerScore(giveplayerid,score);
	new str[99];
	if(!CONSOLE)
	{
		format(str,sizeof(str),"* %s(%d)���� ������ %d(��)�� �����Ͽ����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* ��� %s(��)�� ����� ������ %d(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid),score);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ������ %d�� �����Ͽ����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,score);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ �������� ���ϰ� �մϴ�." );
			print( "[help] �ð��� ������ �׸�ŭ��, ���� ������ Ǯ���� ������ ������ �� �����ϴ�." );
			printf( "[help] ��) %s 10 30 :10�� ����ڸ� 30�ʰ� �������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy�� Ǯ���� ������ �������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �ٽ� �����ϼ� �ְ� �Ϸ��� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNFRZ) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ �������� ���ϰ� �մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* �ð��� ������ �׸�ŭ��, ���� ������ Ǯ���� ������ ������ �� �����ϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 30 :10�� ����ڸ� 30�ʰ� �������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� Ǯ���� ������ ��� �������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �ٽ� �����ϼ� �ְ� �Ϸ��� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNFRZ) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] �������� ���ϰ� �� �ð��� ���Ͻʽÿ�. ��� ����η��� 0�� �Է��Ͻʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* �������� ���ϰ� �� �ð��� ���Ͻʽÿ�. ��� ����η��� 0�� �Է��Ͻʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�ð��� �Է�
			{
				second = strval(tmp);
				//�ð��ʰ� ����� �Էµ��� ���� ���
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] �ð��� ����� �Է��� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �ð��� ����� �Է��� �ֽʽÿ�.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾ ���ٷ� �ǲ� �������ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾ ���ٷ� �ǲ� �������ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾ ���ٷ� �ǲ� �������ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾ ���ٷ� �ǲ� �������ϴ�.", GetPlayerNameEx(playerid));
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
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ���ٷ� �ǲ� �������ϴ�.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ���ٷ� �ǲ� �������ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������� �÷��̾ �ٽ� ������ �� �ְ� �մϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڸ� ������ �� �ְ� �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy�� ������ �� �ְ� �մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������� �÷��̾ �ٽ� ������ �� �ְ� �մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڸ� ������ �� �ְ� �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy�� ������ �� �ְ� �մϴ�.", CURRENT_CMD_NAME ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ������ Ǯ���־����ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� ������ Ǯ���־����ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ������ Ǯ���־����ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ������ Ǯ���־����ϴ�.", GetPlayerNameEx(playerid));
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
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �ǲ� ���� ������ Ǯ���־����ϴ�.", GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �ǲ� ���� ������ Ǯ���־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� GTA:SA�� ����� ������ ����ݴϴ�." );
			printf( "[help] �̸��̳� ��ȣ�� *�� ���� ��ο��� �Ҹ��� ����ݴϴ�." );
			printf( "[help] ��) %s 10 1002 : 10�� ����ڿ��� �´� �Ҹ��� ����ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 1185 : coolguy���� ����ũ ���� ������ ����ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s * 1187 : ��ο��� ����� ���� ������ ����ݴϴ�.", CURRENT_CMD_NAME );
			print("=================== �ֿ� �Ҹ� ��� ============================================");
			print("1002 �´¼Ҹ� 1009 ũ���� 1130 ��ġ�Ҹ� 1140 ���� 1187 ����� ��Ŭ ����");
			print("1097 ��� ���� 1183 ����̺����� ���� 1185 ����ũ ���� ���� ");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾�� GTA:SA�� ����� ������ ����ݴϴ�." ); SEND();
			format( str, sizeof(str), "* �̸��̳� ��ȣ�� *�� ���� ��ο��� �Ҹ��� ����ݴϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 1002 : 10�� ����ڿ��� �´� �Ҹ��� ����ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 1185 : coolguy���� ����ũ ���� ������ ����ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s * 1187 : ��ο��� ����� ���� ������ ����ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= �ֿ� �Ҹ� ��� ===============================");
			SendClientMessage(playerid,COLOR_GREY," 1002 �´¼Ҹ� 1009 ũ���� 1130 ��ġ�Ҹ� 1140 ���� 1187 ����� ��Ŭ ����");
			SendClientMessage(playerid,COLOR_GREY," 1097 ��� ���� 1183 ����̺����� ���� 1185 ����ũ ���� ���� ");
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ����� �Ҹ��� ��ȣ�� �Է��� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ����� �Ҹ��� ��ȣ�� �Է��� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�Ҹ���ȣ �Է�
			{
				soundid = strval(tmp); //�ִ� ���
				//�Ҹ���ȣ�� ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) || soundid <= 0 )
				{
					if( CONSOLE ) print("[rcon] �Ҹ���ȣ�� ����� �Է��� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �Ҹ���ȣ�� ����� �Է��� �ֽʽÿ�.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			format(str,sizeof(str),"* ��� %s(��)�� ������ Ʋ�����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll(COLOR_GREENYELLOW,str);
			if(!CONSOLE)
			{
				format(str,sizeof(str),"* ��ο��� %d�� ������ �������ϴ�.", soundid);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��ο��� %d�� ������ ����Ͽ����ϴ�.",GetPlayerNameEx(playerid), playerid, soundid );
				return 1;
			}
			printf("[rcon] %s(%d)���� ��ο��� %d�� ������ ����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, soundid );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[73];
		format(str,sizeof(str),"* %s(%d)�Կ��� %d�� ������ �������ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ��� %s(��)�� ������ Ʋ�����ϴ�.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)�Կ��� %d�� ������ �������ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,soundid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� ����ִ� �Ҹ��� ���ϴ�." );
			printf( "[help] ��) %s 10 : 10������ ����ִ� �Ҹ��� ���ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy���� ����ִ� �Ҹ��� ���ϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾�� ����ִ� �Ҹ��� ���ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10������ ����ִ� �Ҹ��� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� ����ִ� �Ҹ��� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ������ �����ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� ������ �����ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ������ �����ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ������ �����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ )	StopSoundForPlayer( pITT[i] );
			return 1;
		}
	}
	
	if(!CONSOLE)
	{
		new str[53];
		format(str,sizeof(str),"* %s(%d)���� ������ �����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ��� %s(��)�� ������ �����ϴ�.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)���� ������ �����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� ��Ʈ���� �ݴϴ�." );
			printf( "[help] ��) %s 10 : 10������ ��Ʈ���� �ݴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy : coolguy���� ��Ʈ���� �ݴϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾�� ��Ʈ���� �ݴϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10������ ��Ʈ���� �ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� ��Ʈ���� �ݴϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if( !ALLOW_JETPACK )
	{
		if(CONSOLE) print("[rcon] �������� ��Ʈ���� ����ϰ� ���� �ʽ��ϴ�.");
		else SendClientMessage(playerid, COLOR_GREY,"* �������� ��Ʈ���� ����ϰ� ���� �ʽ��ϴ�.");
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾�� ��Ʈ���� �־����ϴ�.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾�� ��Ʈ���� �־����ϴ�.");
				printf("[rcon] %s(%d)���� ��� �÷��̾�� ��Ʈ���� �־����ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾�� ��Ʈ���� �־����ϴ�.", GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* %s(%d)�Կ��� ��Ʈ���� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ��� %s(��)�� ��ſ��� ��Ʈ���� �־����ϴ�.", GetPlayerNameEx(playerid));
	printf("[rcon] %s(%d)�Կ��� ��Ʈ���� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾ ä���� ���� ���ϵ��� �մϴ�." );
			print( "[help] [��] �� �Է��� �ϸ� �ش� �ʸ�ŭ, �Է����� ������ ��� ä�ñ����� �մϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڸ� (Ǯ���� ������) ä�ñ��� ���·� ����ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy 30 : coolguy ���� 30�ʰ� ä�ñ��� ���·� ����ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ä�� ���� ���¸� Ǯ���ַ��� %s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNSHUT) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾ ä���� ���� ���ϵ��� �մϴ�." ); SEND();
			format( str, sizeof(str), "* [��] �κп� �Է��� �ϸ� �ش� �ʸ�ŭ, �Է����� ������ ����ؼ� ä�� ������ �մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� �÷��̾ (Ǯ���� ������) ä�ñ��� ���·� ����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 30 : coolguy ���� 30�ʰ�  ä�ñ��� ���·� ����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ä�� ���� ���¸� Ǯ���ַ��� /%s ��ɾ ����Ͻʽÿ�.", GetCmdName(CMD_UNSHUT) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ä������ ���ϰ� �� �ð��� ���Ͻʽÿ�. ��� ��ġ�� �Ϸ��� 0�� �Է��Ͻʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ä������ ���ϰ� �� �ð��� ���Ͻʽÿ�. ��� ��ġ�� �Ϸ��� 0�� �Է��Ͻʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�ð��� �Է�
			{
				second = strval(tmp);
				//�ð��ʰ� ����� �Էµ��� ���� ���
				if ( !isNumeric(tmp) || second < 0  )
				{
					if( CONSOLE ) print("[rcon] �ð��� ����� �Է��� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �ð��� ����� �Է��� �ֽʽÿ�.");
					return 1;
				}				
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� �Կ� �ɷ��� ���Ƚ��ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� �Կ� �ɷ��� ���Ƚ��ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� �Կ� �ɷ��� ���Ƚ��ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� �Կ� �ɷ��� ���Ƚ��ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = (second > 0)? (second):(-1);
			return 1;
		}
	}

	if( IS_CHAT_FORBIDDEN[giveplayerid] )
	{
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� �̹� ä�ñ��� �����Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� �̹� ä�ñ��� �����Դϴ�.");
		return 1;
	}

	new str[89];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �Կ� �ɷ��� ���Ƚ��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �Կ� �ɷ��� ���Ƚ��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ä�ñ��� ���¸� Ǯ���ݴϴ�." );
			printf( "[help] ��) %s 10 : 10�� ������� ä�ñ��� ���¸� Ǯ���ݴϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy ���� ä�ñ��� ���¸� Ǯ���ݴϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾ ä���� ���� ���ϵ��� �մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ������� ä�ñ��� ���¸� Ǯ���ݴϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy ���� ä�ñ��� ���¸� Ǯ���ݴϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� �Կ� ���� �ɷ��� ���־����ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� �Կ� ���� �ɷ��� ���־����ϴ�.");
				printf("[rcon] %s(%d)���� ��� �÷��̾��� �Կ� ���� �ɷ��� ���־����ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� �Կ� ���� �ɷ��� ���־����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) PLAYER_PUNISH_REMAINTIME[pITT[i]][PUNISH_SHUTUP] = 0;
			return 1;
		}
	}
	
	if(!IS_CHAT_FORBIDDEN[giveplayerid])
	{
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� ä�ñ��� ���°� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� ä�ñ��� ���°� �ƴմϴ�.");
		return 1;
	}

	new str[96];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �Կ� ���� �ɷ��� ���־����ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �Կ� ���� �ɷ��� ���־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ���� ������ �����մϴ�." );
			printf( "[help] ��) %s 10 : 10�� �θ������� ���� �����ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy ���� ���� ������ ���� ȯ���մϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾��� ���� ������ �����մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� �θ������� ���� �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy ���� ���� ������ ���� ȯ���մϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ���� �����Ͽ����ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� ���� �����Ͽ����ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ���� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ���� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerCash( pITT[i] );
			return 1;
		}
	}

	new str[84];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ���� �����߽��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ���� �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ���⸦ ��������뿡�� �޽��Ͽ� �������ϴ�." );
			printf( "[help] ��) %s 10 : 10�� ���Ǿ��� ���⸦ �����ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy ���� ���⸦ �����մϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾��� ���⸦ ��������뿡�� �޽��Ͽ� �������ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ���Ǿ��� ���⸦ �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy ���� ���⸦ �����մϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ���⸦ �����߽��ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� ���⸦ �����߽��ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ���⸦ �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ���⸦ �����߽��ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) ResetPlayerWeapons( pITT[i] );
			return 1;
		}
	}

	new str[86];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ���⸦ �����߽��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ���⸦ �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� ������ �����մϴ�." );
			printf( "[help] ��) %s 10 522 : 10�� ����ڿ��� ¯�� �����汸�� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 520 : coolguy���� KF-16�� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s * 560 : ��ο��� �߱½ ������ �����մϴ�.", CURRENT_CMD_NAME );
			print("=================== �ֿ� ���� ��� ============================================");
			print("NRG-500 522, Shamal 519, Hydra 520, Hunter 425");
			print("Maverick 497, Rhino 432, Sultan 560");
			print(LINE);

		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾�� ������ �����մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 522 : 10�� ����ڿ��� ¯�� �����汸�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 520 : coolguy���� KF-16�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s * 560 : ��ο��� �߱½ ������ �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage(playerid,COLOR_GREY,"= �ֿ� ���� ��� ===============================");
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ���濡�� �� ������ ��ȣ�� �� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ���濡�� �� ������ ��ȣ�� �� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���� �Է�
			{
				model = strval(tmp); //�ִ� ���
				//������ȣ�� ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) || model < 400 || model > 611 )
				{
					if( CONSOLE ) print("[rcon] ������ȣ�� ����� �� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ������ȣ�� ����� �� �ֽʽÿ�.");
					return 1;
				}		
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾�� %d�� ������ �־����ϴ�.", model );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾�� %d�� ������ �־����ϴ�.", model);
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾�� %d�� ������ �־����ϴ�.", GetPlayerNameEx(playerid), playerid, model);
			}
			new Float:pos[3],Float:Angle;
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ��� %s(��)�� ��ſ��� ������ �־����ϴ�.", GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* %s(%d)�Կ��� %d�� ������ �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,model);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)���� %s(%d)�Կ��� %d�� ������ �־����ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, model );
	}
	else printf("[rcon] %s(%d) �Կ��� %d�� ������ �־����ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid, model );	
	SendFormatMessage(giveplayerid,COLOR_GREENYELLOW,"* ��� %s(��)�� ��ſ��� ������ �־����ϴ�.", GetPlayerNameEx(playerid));	
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾�� �ο�� ������ �ݴϴ�." );
			printf( "[help] ��) %s 10 : 10�� �ù��� ��ġ������ ����ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy���� ��ȸ�� �����ϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾�� �ο�� ������ �ݴϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� �ù��� ��ġ������ ����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� ��ȸ�� �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾�� �ӽ� ���������� �ο��߽��ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾�� �ӽ� ���������� �ο��߽��ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾�� �ӽ� ���������� �ο��߽��ϴ�." , GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾�� �ӽ� ���������� �ο��߽��ϴ�." , GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			format( str, sizeof(str), "* �ڼ��� ������ /%s �� /%s��(��) �����ϼ���.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
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
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� �̹� �ο���Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� �̹� �ο���Դϴ�.");
		return 1;
	}

	new str[98];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)�Կ��� �ӽ� ���������� �ο��߽��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	if( CONSOLE ) printf("[rcon] %s(%d)�Կ��� �ӽ� ���������� �ο��߽��ϴ�.", GetPlayerNameEx(giveplayerid),giveplayerid);
	else printf("[rcon] %s(%d)���� %s(%d)�Կ��� �ӽ� ���������� �ο��߽��ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
	format( str, sizeof(str), "* �ڼ��� ������ /%s �� /%s��(��) �����ϼ���.", GetCmdName(CMD_HELP), GetCmdName(CMD_MYAUTH) );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� �ο�� ������ ��Ż�մϴ�." );
			printf( "[help] ��) %s 10 : 10�� ��ġ���� ������ �̸����� ��ȯ�մϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy���� �����Ƿ� ���濡 �����ϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾��� �ο�� ������ ��Ż�մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ��ġ���� ������ �̸����� ��ȯ�մϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� �����Ƿ� ���濡 �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �������� �ο�� ������ ��Ż�߽��ϴ�." );
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �������� �ο�� ������ ��Ż�߽��ϴ�." );
				printf("[rcon] %s(%d)���� ��� �������� �ο�� ������ ��Ż�߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �������� �ο�� ������ ��Ż�߽��ϴ�." , GetPlayerNameEx(playerid));
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
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� �ο�ڰ� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� �ο�ڰ� �ƴմϴ�.");
		return 1;
	}

	new str[91];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ���������� ��Ż�߽��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� ���������� ��Ż�߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ���� ��Ʈ���ϴ�." );
			printf( "[help] ��) %s 10 : 10�� ������� ���� ������ �ۼ� ���ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy���� õ�� �����ϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾��� ���� ��Ʈ���ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ������� ���� ������ �ۼ� ���ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� õ�� �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ���� ��Ʈ�Ƚ��ϴ�." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* ��� �÷��̾��� ���� ��Ʈ�Ƚ��ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ���� ��Ʈ�Ƚ��ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95], Float:pos[3]; 
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ���� ��Ʈ�Ƚ��ϴ�." , GetPlayerNameEx(playerid));
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
		format(str,sizeof(str),"* ��ڰ� %s(%d)���� ���� ��Ʈ�Ƚ��ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);
		printf("[rcon] %s(%d)���� ���� ��Ʈ�Ƚ��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
	}	
	else
	{
		format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� ���� ��Ʈ�Ƚ��ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
		SendClientMessageToAll(COLOR_GREENYELLOW,str);	
		printf("[rcon] %s(%d)���� %s(%d)���� ���� ��Ʈ�Ƚ��ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �÷��̾��� ���� ������ ������ �ٲߴϴ�." );
			printf( "[help] ��) %s 10 10000 : 10���� �������� $10000���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy -20 : coolguy�� -$20�� �����̷� ����ϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �÷��̾��� ���� ������ ������ �ٲߴϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 10000 : 10���� �������� $10000���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy -20 : coolguy�� -$20�� �����̷� ����ϴ�.", CURRENT_CMD_NAME ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] �÷��̾��� �������� �����Ͻʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* �÷��̾��� �������� �����Ͻʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�� �� �Է�
			{
				//�� ���� ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) )
				{
					if( CONSOLE ) print("[rcon] �������� ����� �� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* �������� ����� �� �ֽʽÿ�.");
					return 1;
				}
				money = strval(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �÷��̾��� �������� $%d�� �����߽��ϴ�.", money );
			else
			{
				format(str,sizeof(str),"* ��� �÷��̾��� �������� $%d�� �����߽��ϴ�.", money );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� �÷��̾��� �������� $%d�� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, money );
			}
			for( new i = 0; i < NUM_PLAYERS; i++ )
			{
				format(str,sizeof(str),"* ��� %s(��)�� ����� �������� $%d�� �ٲپ����ϴ�.", GetPlayerNameEx(playerid), money);
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
		format(str,sizeof(str),"* %s(%d)���� �������� $%d�� �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
		SendClientMessage(playerid,COLOR_GREENYELLOW,str);
	}
	format(str,sizeof(str),"* ��� %s(��)�� ����� �������� $%d�� �ٲپ����ϴ�.",GetPlayerNameEx(playerid),money);
	SendClientMessage(giveplayerid,COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �������� $%d�� �����߽��ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,money);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾ �������� ����ϴ�." );
			printf( "[help] ��) %s 10 : 10�� ����ڴ� ��ũ�� �˴ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy���� ���� �����ϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾ �������� ����ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� ����ڴ� ��ũ�� �˴ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy���� ���� �����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾ �������� ��������ϴ�." );
			else
			{
				SendClientMessage( playerid, COLOR_GREENYELLOW, "* ��� �÷��̾ �������� ��������ϴ�." );
				printf("[rcon] %s(%d)���� ��� �÷��̾ �������� ��������ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95]; 
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾ �������� ��������ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_GREENYELLOW, str );
			for( new i = 0; i < NUM_PLAYERS; i++ ) SetPlayerHealth( pITT[i], 100000.0 );
			return 1;
		}
	}

	new str[88];
	format(str,sizeof(str),"* ��� %s(��)�� %s(%d)���� �������� ��������ϴ�.",GetPlayerNameEx(playerid),GetPlayerNameEx(giveplayerid),giveplayerid);
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	printf("[rcon] %s(%d)���� �������� ��������ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ���ų� ����� �ʽ��ϴ�." );
			printf( "[help] ��) %s : ������ ���� ������ �ð���� ���ų� �ߴ��մϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s 30 : ������ 30�ʸ��� ���ϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ������ ������ �ٲٷ��� %s�� �����Ͻʽÿ�..", FILE_SETTINGS  );
			printf( "[help] ���� ����� %s ��ɾ ����Ͽ� Ȯ���Ͻʽÿ�.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ������ ���ų� ����� �ʽ��ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : ������ ���� ������ �ð���� ���ų� �ߴ��մϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s 30 : ������ 30�ʸ��� ���ϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ������ ������ �ٲٷ��� %s�� �����Ͻʽÿ�..", FILE_SETTINGS  ); SEND();
			format( str, sizeof(str), "* ���� ����� %s ��ɾ ����Ͽ� Ȯ���Ͻʽÿ�.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ���� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ���� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}

	if(!Num_Notice)
	{
		if(CONSOLE) print("[rcon] ������ �����ϴ�. INI���Ͽ� ������(��) �Է��ϼ���.");
		else SendClientMessage(playerid,COLOR_GREY,"* ������ �����ϴ�. RconController.ini�� ������(��) �Է��ϼ���.");
		return 1;
	}
	if( NOTICE_INTERVAL )
	{
		print("[rcon] ���� ���⸦ �ߴ��Ͽ����ϴ�.");
		SendClientMessageToAll(COLOR_GREENYELLOW,"* ���� ���⸦ �ߴ��Ͽ����ϴ�.");
		NOTICE_INTERVAL = 0;
		return 1;
	}
	if( isnull(params) ) NOTICE_INTERVAL=c_iniInt("[General]","NOTICE_INTERVAL");
	else if( isNumeric(params) && strval(params) > 0 ) NOTICE_INTERVAL=strval(params);
	else return Usage( playerid, CMD_CURRENT );

	if( NOTICE_INTERVAL < 1 )
	{
		if(CONSOLE) print( "[rcon] ���� ���Ͽ� ���� ��Ȯ�� �Է��Ͻʽÿ�. ������ ���Դϴ�." );
		else SendClientMessage( playerid, COLOR_GREY,"* ���� ���Ͽ� ���� ��Ȯ�� �Է��Ͻʽÿ�. ������ ���Դϴ�." );
		return 1;
	}

	new str[46];
	CheckNoticeList();
	printf("[rcon] �������� ������ %d�ʸ��� ���ϴ�.",NOTICE_INTERVAL);
	format(str,sizeof(str),"* �������� ������ %d�ʸ��� ���ϴ�.",NOTICE_INTERVAL);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� �ѷ��ִ� ������ ����� ���ϴ�." );
			printf( "[help] ��) %s : ���� �ѷ��ִ� ������ ����� ���ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ������ �߰��� �ڿ� %s ��ɾ ����Ͽ� �ε��Ͻʽÿ�.", GetCmdName(CMD_RELOADNOTICE)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ���� �ѷ��ִ� ������ ����� ���ϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : ���� �ѷ��ִ� ������ ����� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ������ �߰��� �ڿ� %s ��ɾ ����Ͽ� �ε��Ͻʽÿ�.", GetCmdName(CMD_RELOADNOTICE)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ���� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ���� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}

	if(CONSOLE) print("\n====== Notice List ============================================================");
	else SendClientMessage(playerid,COLOR_GREY,"= Notice List =============================");
	new File:fhnd, str[256], stridx, color;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//������ ���۵ɶ����� ���� ��ŵ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===���� ����===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//�� �ڸ���, �ּ��� �ܼ����ʹ� ��ŵ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//������ ���� ��� ��ũ��Ʈ ����
		if( !strcmp( str, "===���� ��===" ) ) break;
		//���м��� ������ ���м��� �����
		if( !strcmp( str, "===���м�===" ) )
		{
			if( CONSOLE ) print(LINE);
			else SendClientMessage( playerid, COLOR_GREY, LINE_CLIENT);
			continue;
		}
		/* ��Ƽ���� ������ �д´� */
		stridx = 0; //�⺻�� ����
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //���� �ڵ鷯 Ȯ��
		{
			//������ﶧ�� �ε��� ����
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX���� ��� ���� ����
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//�̸� ������ ����
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "�Ķ�" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "���� �Ķ�" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "��ũ" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "������ũ" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "�ý���" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "ȸ��" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "û�ϻ�" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "������" ) ) color = COLOR_ORANGE;
		}
		//���� ����
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ���Ͽ��� ������ �ٽ� �ҷ��ɴϴ�." );
			printf( "[help] ��) %s : ���� ���Ͽ��� ������ �ٽ� �ҷ��ɴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ���� ����� ������ %s ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_NLIST)  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ���� ���Ͽ��� ������ �ٽ� �ҷ��ɴϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : ���� ���Ͽ��� ������ �ٽ� �ҷ��ɴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ���� ����� ������ %s ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_NLIST)  ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ���� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ���� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	CheckNoticeList();
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* ������ �ٽ� �ҷ��Խ��ϴ�.");
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ���Ͽ��� �ο�� ����� �ٽ� �ҷ��ɴϴ�." );
			printf( "[help] ��) %s : �ο�� ����� �ٽ� �ҷ��ɴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] �ο�� ����� �ٲٷ��� %s�� �����Ͻʽÿ�..", FILE_SETTINGS );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ���� ���Ͽ��� �ο�� ����� �ٽ� �ҷ��ɴϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : �ο�� ����� �ٽ� �ҷ��ɴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �ο�� ����� �ٲٷ��� %s�� �����Ͻʽÿ�..", FILE_SETTINGS ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� �ο�� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] �ο�� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	LOAD_SUBADMIN = 1;
	if(!CONSOLE) SendClientMessage(playerid,COLOR_GREY,"* �ο�� ����� �ٽ� �ҷ��Խ��ϴ�.");
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ��� ���·� �����, �ٸ� �÷��̾ �������� ���ϰ� �մϴ�." );
			printf( "[help] ��) %s : ���ð��η� ������ ��޴ϴ�.", CURRENT_CMD_NAME );
			print( "[help] ����� �����Ϸ��� �ٽ� �ѹ� �Է��Ͻʽÿ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* ������ ��� ���·� �����, �ٸ� �÷��̾ �������� ���ϰ� �մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : ���ð��η� ������ ��޴ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ����� �����Ϸ��� �ٽ� �ѹ� �Է��Ͻʽÿ�."); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	SERVER_LOCKED = !SERVER_LOCKED;
	SendClientMessageToAll(COLOR_GREENYELLOW,(SERVER_LOCKED)? ("* ������ �����ϴ�. ���̻� ������ �Ұ����մϴ�."):("* ���� ����� �����Ǿ����ϴ�."));
	printf("[rcon] %s",(SERVER_LOCKED)? ("������ ��ɽ��ϴ�. ����ڰ� ���̻� ������ �� �����ϴ�."):("���� ����� �����߽��ϴ�. ������ ���Ǿ����ϴ�."));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �ο���� ������ �ٸ� ������ �����մϴ�." );
			printf( "[help] ��) %s 10 : 10�� �ο���� ������ 0(��� ����) ���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 3 : coolguy�� ������ 3���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ����� �� �ִ� ���� ����� %s ��ɾ �Է��Ͻʽÿ�.", GetCmdName(CMD_AUTHLIST) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ �ο���� ������ �ٸ� ������ �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 : 10�� �ο���� ������ 0(��� ����) ���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 3 : coolguy�� ������ 3���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ����� �� �ִ� ���� ����� %s ��ɾ �Է��Ͻʽÿ�.", GetCmdName(CMD_AUTHLIST) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� �ο�� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] �ο�� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ������ ������ ��ȣ�� �Է��� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ������ ������ ��ȣ�� �Է��� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //���ھ� �Է�
			{
				//���ھ ����� �Էµ��� ���� ���
				if( !isNumeric(tmp) || strval(tmp) < 0 )
				{
					if( CONSOLE ) print("[rcon] ���ѹ�ȣ�� ����� �Է��� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ���ѹ�ȣ�� ����� �Է��� �ֽʽÿ�.");
					return 1;
				}
				authid = strval(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� �ο���� ������ %s(%d)�� �����Ͽ����ϴ�.", (authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"), authid );
			else
			{
				format(str,sizeof(str),"* ��� �ο���� ������ %s(%d)�� �����Ͽ����ϴ�.", (authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"), authid );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� �ο���� ������ %s(%d)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, (authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"), authid );
			}
			format(str,sizeof(str),"* ��� %s(��)�� ��� �ο���� ������ %s(%d)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), (authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"), authid );
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
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� �ο�ڰ� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� �ο�ڰ� �ƴմϴ�.");
		return 1;
	}

	if(LoadPlayerAuthProfile(giveplayerid,authid))
	{
		new str[202];
		format(str,sizeof(str),"Auth_Profile%d",authid);
		printf("[rcon] �ο�� %s(%d)�Կ��� %d�� ����(%s)�� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"));
		format(str,sizeof(str),"* �ο�� %s(%d)�Կ��� %d�� ����(%s)�� �־����ϴ�.",GetPlayerNameEx(giveplayerid),giveplayerid,authid,(authid)? (c_iniGet("[SubAdmin]",str)):("��� ����"));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ����� �� �ִ� ���ѹ�ȣ ����� ���캾�ϴ�." );
			printf( "[help] ��) %s : ����� �� �ִ� ���ѹ�ȣ ����� ���캾�ϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ����� �� �ִ� ���ѹ�ȣ ����� ���캾�ϴ�." );
			format( str, sizeof(str), "* ��) /%s : ����� �� �ִ� ���ѹ�ȣ ����� ���캾�ϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� �ο�� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] �ο�� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}

	if(CONSOLE)
	{
		print("= �ο�� ���ѹ�ȣ ��� ===========================");
		print("0 : ��� ����(��ڿ� ����)");
	}
	else
	{
		SendClientMessage(playerid,COLOR_GREY,"= �ο�� ���ѹ�ȣ ��� ===========================");
		SendClientMessage(playerid,COLOR_GREY,"0 : ��� ����(��ڿ� ����)");
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ������ �߷��� �����մϴ�. �⺻���� 0.008 �Դϴ�." );
			printf( "[help] ��) %s -1: ���ƺ��ô�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s 30 : ���� ž�ϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ���� ������ �߷��� �����մϴ�. �⺻���� 0.008 �Դϴ�." );
			format( str, sizeof(str), "* ��) /%s -1: ���ƺ��ô�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 30 : ���� ž�ϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] �ٲٰ� ���� �߷��� �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* �ٲٰ� ���� �߷��� �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || floatstr(params) < -50.0 || floatstr(params) > 50.0 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] �߷��� ����� �Է��Ͽ� �ֽʽÿ�." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* �߷��� ����� �Է��Ͽ� �ֽʽÿ�." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[37];
	format(str,sizeof(str),"* �߷��� %.3f(��)�� ����Ǿ����ϴ�.",floatstr(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetGravity(floatstr(params));
	printf("[rcon] �߷��� %.3f(��)�� ����Ǿ����ϴ�.",floatstr(params));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ������ ������ �����մϴ�." );
			printf( "[help] ��) %s 0: ������ ������ 0���� �ٲߴϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s 1337 : ������ ������ 1337�� �ٲߴϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ���� ������ ������ �����մϴ�. �⺻���� 0 �Դϴ�." );
			format( str, sizeof(str), "* ��) /%s 0: ������ ������ 0���� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 1337 : ������ ������ 1337�� �ٲߴϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//Interactive management	
	if( params[0] == '?' ) 
	{
		if ( CONSOLE ) print("[rcon] �ٲٰ� ���� ������ �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		else SendClientMessage( playerid, COLOR_YELLOW, "* �ٲٰ� ���� ������ �Է��Ͽ� �ֽʽÿ�. ��Ҵ� ?�� �Է��Ͻʽÿ�." );
		INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
		return 1;
	}

	if( isnull(params) || !isNumeric(params) || strval(params) < 0 || strval(params) > 1337 )
	{
		if( INTERACTIVE_COMMAND[ playerid ] == CMD_CURRENT )
		{
			if ( CONSOLE ) print("[rcon] ������ ����� �Է��Ͽ� �ֽʽÿ�." );
			else SendClientMessage( playerid, COLOR_YELLOW, "* ������ ����� �Է��Ͽ� �ֽʽÿ�." );
			return 1;
		}
		else return Usage( playerid, CMD_CURRENT );
	}
	
	if( INTERACTIVE_COMMAND[playerid] == CMD_CURRENT ) INTERACTIVE_COMMAND[playerid] = CMD_INVALID;
	new str[30];
	format(str,sizeof(str),"* ������ %d(��)�� ����Ǿ����ϴ�.",strval(params));
	SendClientMessageToAll(COLOR_GREENYELLOW,str);
	SetWeather(strval(params));
	printf("[rcon] ������ %d(��)�� ����Ǿ����ϴ�.",strval(params));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �÷��̾ Ÿ�� �ִ� ������ �������� �����մϴ�." );
			printf( "[help] ��) %s 10 100: 10�� ������� ������ ���� ���Դϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s coolguy 800: coolguy�� ������ �׷����� ������ ���·� ����ϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ������ ������ �����Ϸ��� %s ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_FIXCAR) );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �÷��̾ Ÿ�� �ִ� ������ �������� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 10 100: 10�� ������� ������ ���� ���Դϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy 800: coolguy�� ������ �׷����� ������ ���·� ����ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ������ ������ �����Ϸ��� %s ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_FIXCAR) ); SEND();
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
			case 0: //���� �Է�
			{
				if ( Post_Process( playerid, giveplayerid, CMD_CURRENT, false ) == PROCESS_COMPLETE ) return 1;
				else INTERACTIVE_COMMAND[playerid] = CMD_CURRENT;
				
				if( CONSOLE )
				{
					INTERACTIVE_ADMIN_TEMP = giveplayerid;
					print("[rcon] ������ ������ �������� ���� �ֽʽÿ�.");
				}
				else
				{
					SetPVarInt( playerid, "INTERACTIVE_TEMP", giveplayerid );
					SendClientMessage( playerid, COLOR_YELLOW, "* ������ ������ �������� ���� �ֽʽÿ�.");
				}
				INTERACTIVE_STATE[playerid]++;
				return 1;
			}
			case 1: //�Ƹ� �Է�
			{
				//�ƸӰ� ����� �Էµ��� ���� ���
				if( isnull(tmp) || floatstr(tmp) < 0.0 )
				{
					if( CONSOLE ) print("[rcon] ���� �������� ����� ���� �ֽʽÿ�.");
					else SendClientMessage( playerid, COLOR_YELLOW, "* ���� �������� ����� ���� �ֽʽÿ�.");
					return 1;
				}
				energy = floatstr(tmp); //�ִ� ���
				giveplayerid = (CONSOLE)? (INTERACTIVE_ADMIN_TEMP):(GetPVarInt(playerid,"INTERACTIVE_TEMP")); //�����
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
			if( CONSOLE ) printf( "[rcon] ��� ������ �������� %.1f�� �����߽��ϴ�.", energy );
			else
			{
				format(str,sizeof(str),"* ��� ������ �������� %.1f�� �����߽��ϴ�.", energy );
				SendClientMessage(playerid,COLOR_GREENYELLOW,str);
				printf("[rcon] %s(%d)���� ��� ������ �������� %.1f�� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, energy);
			}
			format(str,sizeof(str),"* ��� %s(��)�� ��� ������ �������� %.1f���� �����߽��ϴ�.", GetPlayerNameEx(playerid), energy);
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
		SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� ������ ž���ϰ� ���� �ʽ��ϴ�.");
		return 1;
	}
	
	#if SAMP03x
		if( energy >= 1000.0 ) RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), energy);
	new str[80];
	if( CONSOLE )
	{
		format( str, sizeof(str), "* ��ڰ� ����� ���� �������� %.1f(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)���� ���� �������� %.1f(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)���� ���� �������� %.1f(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid, energy );
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* ��� %s(%d)���� ����� ���� �������� %.1f(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, energy );
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)���� %s(%d)���� ���� �������� %.1f(��)�� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid, energy );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ������ �����մϴ�." );
			printf( "[help] ��) %s 10 : 10�� �������� ������ �����մϴ�.",  CURRENT_CMD_NAME  );
			printf( "[help] ��) %s coolguy : coolguy ���� ���� �ػ����� ����ϴ�.",  CURRENT_CMD_NAME  );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ش� �÷��̾��� ������ �����մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : 10�� �������� ������ �����մϴ�.",  CURRENT_CMD_NAME  ); SEND();
			format( str, sizeof(str), "* ��) /%s coolguy : coolguy ���� ���� �ػ����� ����ϴ�.",  CURRENT_CMD_NAME  ); SEND();
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
			if( CONSOLE ) print( "[rcon] ��� �÷��̾��� ������ �����߽��ϴ�.");
			else
			{
				SendClientMessage(playerid,COLOR_GREENYELLOW, "* ��� �÷��̾��� ������ �����߽��ϴ�.");
				printf("[rcon] %s(%d)���� ��� �÷��̾��� ������ �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid );
			}
			new str[95];
			format(str,sizeof(str),"* ��� %s(��)�� ��� �÷��̾��� ������ �����߽��ϴ�.", GetPlayerNameEx(playerid));
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
		SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� ������ ž���ϰ� ���� �ʽ��ϴ�.");
		return 1;
	}
	
	SetVehicleHealth(GetPlayerVehicleID(giveplayerid), 1000.0);
	#if SAMP03x
		RepairVehicle(GetPlayerVehicleID(giveplayerid));
	#endif
	new str[65];
	
	if( CONSOLE )
	{
		format( str, sizeof(str), "* ��ڰ� ����� ������ �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)���� ������ �����߽��ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid);
	}
	else
	{
		format( str, sizeof(str), "* %s(%d)���� ������ �����߽��ϴ�.", GetPlayerNameEx(giveplayerid), giveplayerid);
		SendClientMessage(playerid,COLOR_GREENYELLOW, str );
		format( str, sizeof(str), "* ��� %s(%d)���� ����� ������ �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
		SendClientMessage(giveplayerid,COLOR_GREENYELLOW, str );	
		printf("[rcon] %s(%d)���� %s(%d)���� ������ �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx(giveplayerid), giveplayerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );
			printf( "[help] ���� ��å: %s", (FILE_YELLFILTER)? ("���"):("������� ����") );
			printf( "[help] �����ܾ� �߰��� '%s', ���Ŵ� '%s' ��ɾ �����ϼ���.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );
			format( str, sizeof(str), "* ���� ��å: %s", (FILE_YELLFILTER)? ("���"):("������� ����") ); SEND();
			format( str, sizeof(str), "* �����ܾ� �߰��� '%s', ���Ŵ� '%s' ��ɾ �����ϼ���.", GetCmdName(CMD_ADDYELL), GetCmdName(CMD_DELYELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ������ ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ������ ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	USE_YELLFILTER = !USE_YELLFILTER;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_YELLFILTER? ("* ������ ����� ���۵Ǿ����ϴ�."):("* ������ ����� ����Ǿ����ϴ�.")));
	print((USE_YELLFILTER? ("[rcon] ������ ����� ���۵Ǿ����ϴ�."):("[rcon] ������ ����� ����Ǿ����ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� ���� �����Դϴ�." );
			print( "[help] Ư�� �ܾ ������ ��Ͽ� �߰��մϴ�. ������ ���� **�� ǥ�õ˴ϴ�." );
			printf( "[help] ��) %s ���� : '����' �̶�� ���� ������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �Ϸ��� '%s' �� �����ϼ���.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* Ư�� �ܾ ������ ��Ͽ� �߰��մϴ�. ������ ���� **�� ǥ�õ˴ϴ�." );
			format( str, sizeof(str), "* ��) /��) %s ���� : '����' �̶�� ���� ������� ���ϰ� �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �Ϸ��� '%s' �� �����ϼ���.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ������ ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ������ ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	new File:fhandle, str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] ���Ϳ� �߰��� ����� �Է��Ͻʽÿ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* ���Ϳ� �߰��� ����� �Է��Ͻʽÿ�.");
		return 1;
	}
	if(num_Yells == MAX_YELLS)
	{
		if(CONSOLE) print("[rcon] ���̻� ����� �߰��Ͻ� �� �����ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* ���̻� ����� �߰��Ͻ� �� �����ϴ�.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] ������ ���̰� �ʹ� ��ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* ������ ���̰� �ʹ� ��ϴ�.");
		return 1;
	}
	if( IsYellExists(params) )
	{
		if(CONSOLE) print("[rcon] �̹� �����ϴ� �������Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* �̹� �����ϴ� �������Դϴ�.");
		return 1;
	}
	fhandle=fopen(FILE_YELLFILTER,io_append);
	if(!fhandle)
	{
		if(CONSOLE) print("[rcon] ������ �߰��� �����߽��ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* ������ �߰��� �����߽��ϴ�.");
		return 1;
	}
	fseek(fhandle,0,seek_end);
	c_fwrite(fhandle,"\r\n");
	c_fwrite(fhandle,params);
	fclose(fhandle);
	set( YELLS[num_Yells], params );
	num_Yells++;
	format(str, sizeof(str),"* ��� %s(��)�� \"%s\"��(��) ������� �����Ͽ����ϴ�.",GetPlayerNameEx(playerid),params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[rcon] ���ο� ������ \"%s\"�� �߰��Ͽ����ϴ�.",params);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� ���� �����Դϴ�." );
			print( "[help] ������ �������� �ش� ������ �����մϴ�." );
			printf( "[help] ��) %s ���� : '����' �̶�� ���� ����� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �Ϸ��� '%s' �� �����ϼ���.", GetCmdName(CMD_YELL) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ������ �������� �ش� ������ �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s ���� : '����' �̶�� ���� ����� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �Ϸ��� '%s' �� �����ϼ���.", GetCmdName(CMD_YELL) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( !fexist(FILE_YELLFILTER) )
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ������ ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ������ ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	new File:fohnd,File:fwhnd,bool:dontwrite=false,bool:infile=false,str[512];

	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] ���Ϳ��� ������ ����� �Է��Ͻʽÿ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* ���Ϳ��� ������ ����� �Է��Ͻʽÿ�.");
		return 1;
	}
	if(num_Yells==0)
	{
		if(CONSOLE) print("[rcon] ���Ͽ� ������ ����� �����ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* ���Ͽ� ������ ����� �����ϴ�.");
		return 1;
	}
	if(strlen(params) >= MAX_YELL_CHAR)
	{
		if(CONSOLE) print("[rcon] ������ ���̰� �ʹ� ��ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* ������ ���̰� �ʹ� ��ϴ�.");
		return 1;
	}
	format( str, sizeof(str), "%s_", FILE_YELLFILTER );
	frename(FILE_YELLFILTER, str );
	fohnd=fopen( str, io_read);
	fwhnd=fopen(FILE_YELLFILTER,io_write);
	if( !fohnd || !fwhnd )
	{
		if(CONSOLE) print("[rcon] ������ ���ſ� �����߽��ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* ������ ���ſ� �����߽��ϴ�.");
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
		if(CONSOLE) print("[rcon] �����ϴ� ����� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY, "* �����ϴ� ����� �ƴմϴ�.");
		return 1;
	}
	LoadYellList();
	format(str,MAX_STRING,"* �˸� : \"%s\"��(��) ���̻� ����� �ƴմϴ�. ",params);
	SendClientMessageToAll(COLOR_GREENYELLOW, str);
	printf("[info] ������ \"%s\"�� �����Ͽ����ϴ�.",params);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������� ����� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );
			printf( "[help] ���� ��å: %s", (USE_ANTI_CHATFLOOD)? ("���"):("������� ����") );
			print( "[help] ������� ����� ���μ����� RconController.ini���� �����ϼ���." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������� ����� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );			
			format( str, sizeof(str), "* ���� ��å: %s", (USE_ANTI_CHATFLOOD)? ("���"):("������� ����") ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������� ����� ���μ����� RconController.ini���� �����ϼ���." );
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
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_CHATFLOOD? ("* ������� ����� ���۵Ǿ����ϴ�."):("* ������� ����� ����Ǿ����ϴ�.")));
	print((USE_ANTI_CHATFLOOD? ("[rcon] ������� ����� ���۵Ǿ����ϴ�."):("[rcon] ������� ����� ����Ǿ����ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );
			printf( "[help] ���� ��å: %s", (USE_ANTI_WEAPONCHEAT)? ("���"):("������� ����") );
			printf( "[help] ������ ���⸦ �߰� �� �����Ϸ��� '%s' / '%s' �� �����ϼ���.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �մϴ�." );
			format( str, sizeof(str), "* ���� ��å: %s", (USE_ANTI_WEAPONCHEAT)? ("���"):("������� ����") ); SEND();
			format( str, sizeof(str), "* ������ ���⸦ �߰� �� �����Ϸ��� '%s' / '%s' �� �����ϼ���.", GetCmdName(CMD_ADDWC), GetCmdName(CMD_DELWC) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	USE_ANTI_WEAPONCHEAT = !USE_ANTI_WEAPONCHEAT;
	SendClientMessageToAll(COLOR_GREENYELLOW,(USE_ANTI_WEAPONCHEAT? ("* ������ ��������� ���۵Ǿ����ϴ�."):("* ������ ��������� ����Ǿ����ϴ�.")));
	print((USE_ANTI_WEAPONCHEAT? ("[rcon] ������ ��������� ���۵Ǿ����ϴ�."):("[rcon] ������ ��������� ����Ǿ����ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ��������� ���� �����Դϴ�." );
			print( "[help] Ư�� ������ ����� �����մϴ�. ���� ���� �߹�˴ϴ�." );
			printf( "[help] ��) %s 38: �̴ϰ��� ����� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ���� ��ȣ�� 0 ~ %d �����̸�, �ڼ��� ������ SA-MP Wiki�� �����ϼ���.", MAX_WEAPONS );
			printf( "[help] ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ��������� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* Ư�� ������ ����� �����մϴ�. ���� ���� �߹�˴ϴ�." );
			format( str, sizeof(str), "* ��) /%s 38: �̴ϰ��� ����� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ���� ��ȣ�� 0 ~ %d �����̸�, �ڼ��� ������ SA-MP Wiki�� �����ϼ���.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] ���� : �����߰� or addweapon [�����ȣ]");
		else SendClientMessage(playerid,COLOR_GREY,"* ���� : /�����߰� or /addweapon [�����ȣ]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] �߸��� �����ȣ�Դϴ�. �����ȣ�� '�����ȣ.txt'�� �����ϼ���.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸��� �����ȣ�Դϴ�. �����ȣ�� '�����ȣ.txt'�� �����ϼ���.");
		return 1;
	}

	new weaponid = strval( params );
	if( IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] �̹� �����Ǿ� �ִ� �����Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �̹� �����Ǿ� �ִ� �����Դϴ�.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 1;
	new str[148], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* ��� %s(��)�� �������� ��Ͽ� ���� %s(%d)�� �߰��Ͽ����ϴ�. �ش� ���� ���� �߹�˴ϴ�.", GetPlayerNameEx(playerid), weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] �������� ��Ͽ� ���� %s(%d)�� �߰��Ͽ����ϴ�.",  weapon_name, weaponid );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ��������� ���� �����Դϴ�." );
			print( "[help] Ư�� ������ ����� ����մϴ�." );			
			printf( "[help] ��) %s 38: �̴ϰ��� ����� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ���� ��ȣ�� 0 ~ %d �����̸�, �ڼ��� ������ SA-MP Wiki�� �����ϼ���.", MAX_WEAPONS );
			printf( "[help] ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_WPCHEAT) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ��������� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* Ư�� ������ ����� ����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 38: �̴ϰ��� ����� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ���� ��ȣ�� 0 ~ %d �����̸�, �ڼ��� ������ SA-MP Wiki�� �����ϼ���.", MAX_WEAPONS ); SEND();
			format( str, sizeof(str), "* ������ ��������� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_WPCHEAT) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || !isNumeric(params) )
	{
		if(CONSOLE) print("[rcon] ���� : �������� or delweapon [�����ȣ]");
		else SendClientMessage(playerid,COLOR_GREY,"* ���� : /�������� or /delweapon [�����ȣ]");
		return 1;
	}

	if( strval(params) < 0 || strval(params) >= MAX_WEAPONS )
	{
		if(CONSOLE) print("[rcon] �߸��� �����ȣ�Դϴ�. �����ȣ�� '�����ȣ.txt'�� �����ϼ���.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸��� �����ȣ�Դϴ�. �����ȣ�� '�����ȣ.txt'�� �����ϼ���.");
		return 1;
	}

	new weaponid = strval( params );
	if( !IsWeaponForbidden( weaponid ) )
	{
		if(CONSOLE) print("[rcon] �����Ǿ����� ���� �����Դϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �̹� �����Ǿ����� ���� �����Դϴ�.");
		return 1;
	}

	IS_WEAPON_FORBIDDEN[weaponid] = 0;
	new str[128], weapon_name[32];
	GetWeaponName( weaponid, weapon_name, sizeof(weapon_name)  );
	format( str, sizeof(str), "* �˸� : ���� ���� %s(%d)�� ����ص� �߹���� �ʽ��ϴ�.", weapon_name, weaponid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf( "[rcon] �������� ��Ͽ��� ���� %s(%d)�� �����Ͽ����ϴ�.",  weapon_name, weaponid );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ��Ʈ�� ����� ���/���� �մϴ�." );
			print( "[help] ������ ���, ��Ʈ�� ���� �����߹� �մϴ�." );
			printf( "[help] ���� ��å: %s", (ALLOW_JETPACK)? ("���"):("������� ����") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ��Ʈ�� ����� ���/���� �մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ������ ���, ��Ʈ�� ���� �����߹� �մϴ�." );
			format( str, sizeof(str), "* ���� ��å: %s", (ALLOW_JETPACK)? ("���"):("������� ����") ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	ALLOW_JETPACK = !ALLOW_JETPACK;
	SendClientMessageToAll(COLOR_GREENYELLOW,((!ALLOW_JETPACK)? ("* �˸� : �������� ��Ʈ���� ����ϸ� �߹�˴ϴ�."):("* �˸� : ���� ��Ʈ���� ����ص� �߹���� �ʽ��ϴ�.")));
	print(((!ALLOW_JETPACK)? ("[rcon] ��Ʈ�� ����� �����߽��ϴ�."):("[rcon] ��Ʈ�� ����� ����߽��ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ��ɾ� ������� ����� Ȱ��ȭ / ��Ȱ��ȭ �մϴ�." );
			print( "[help] '/' �� �����ϴ� ��ɾ �����Ͽ� �ý��ۿ� ���ϸ� �ִ� �Ǽ� �ο��� �߹��ϴ� ����Դϴ�." );			
			printf( "[help] ���� ��å: %s", (USE_ANTI_CMDFLOOD)? ("���"):("������� ����") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ��ɾ� ������� ����� Ȱ��ȭ / ��Ȱ��ȭ �մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* '/' �� �����ϴ� ��ɾ �����Ͽ� �ý��ۿ� ���ϸ� �ִ� �Ǽ� �ο��� �߹��ϴ� ����Դϴ�." );
			format( str, sizeof(str), "* ���� ��å: %s", (USE_ANTI_CMDFLOOD)? ("���"):("������� ����") ); SEND();
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
	SendClientMessageToAll(COLOR_GREENYELLOW,((USE_ANTI_CMDFLOOD)? ("* ��ɾ�� ��������� ���۵Ǿ����ϴ�."):("* ��ɾ�� ��������� ����Ǿ����ϴ�.")));
	print(((USE_ANTI_CMDFLOOD)? ("[rcon] ��ɾ�� ��������� �����߽��ϴ�."):("[rcon] ��ɾ�� ��������� �����߽��ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �մϴ�." );
			print( "[help] ���ͳ��� ���� ��Ȱ�� �÷��̸� �����ϴ� �ο��� ��� �Ǵ� �߹��ϴ� ����Դϴ�." );			
			printf( "[help] ���� ��å: %s", (USE_PINGCHECK)? ("���"):("������� ����") );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� Ȱ��ȭ / ��Ȱ��ȭ �մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ���ͳ��� ���� ��Ȱ�� �÷��̸� �����ϴ� �ο��� ��� �Ǵ� �߹��ϴ� ����Դϴ�." );
			format( str, sizeof(str), "* ���� ��å: %s", (USE_PINGCHECK)? ("���"):("������� ����") ); SEND();
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
	SendClientMessageToAll( COLOR_GREENYELLOW, (USE_PINGCHECK)? ("* ������ ����� ���۵Ǿ����ϴ�."):("* ������ ����� ����Ǿ����ϴ�.") );
	print((USE_PINGCHECK)? ("[rcon] ������ ����� ���۵Ǿ����ϴ�."):("[rcon] ������ ����� ����Ǿ����ϴ�."));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� ���� �����Դϴ�." );
			print( "[help] ���ͳ� �����ð��� ���� �̻��� ��� ��� �Ǵ� �߹���ġ�� �մϴ�." );			
			printf( "[help] ��) %s 200: �����ð��� 200ms�� �Ѿ ��� %dȸ ����� �߹��մϴ�.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT );
			printf( "[help] ���� ������: %dms", HIGHPING_LIMIT );
			printf( "[help] �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ���ͳ� �����ð��� ���� �̻��� ��� ��� �Ǵ� �߹���ġ�� �մϴ�." );	
			format( str, sizeof(str), "* ��) /%s 200: �����ð��� 200ms�� �Ѿ ��� %dȸ ����� �߹��մϴ�.", CURRENT_CMD_NAME, HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* ���� ������: %dms", HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '/%s'�� �����ϼ���.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new ping;
	if( sscanf( params, "i", ping ) || ping < 1 )
	{
		if(CONSOLE) print("[rcon] ���� : ������ or /setplimit [��]");
		else SendClientMessage(playerid,COLOR_GREY,"* ���� : ������ or /setplimit [��]");
		return 1;
	}
	HIGHPING_LIMIT = ping;
	new str[48];
	format( str, sizeof(str), "* ������ ������ %dms�� ����Ǿ����ϴ�.", HIGHPING_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] ������ ������ %dms�� �����߽��ϴ�.", HIGHPING_LIMIT );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� ���� �����Դϴ�." );
			print( "[help] ���� �̻� ��� ���� �ο��� �߹��ϰ� �մϴ�." );			
			printf( "[help] ��) %s 3: �����ð��� %dms�� �Ѿ ��� 3ȸ ����� �߹��մϴ�.", CURRENT_CMD_NAME, HIGHPING_LIMIT );
			printf( "[help] ���� ���Ƚ��: %dȸ", HIGHPING_WARN_LIMIT );
			printf( "[help] �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* ���� �̻� ��� ���� �ο��� �߹��ϰ� �մϴ�." );		
			format( str, sizeof(str), "* ��) /%s 3: �����ð��� %dms�� �Ѿ ��� 3ȸ ����� �߹��մϴ�.", CURRENT_CMD_NAME, HIGHPING_LIMIT ); SEND();
			format( str, sizeof(str), "* ���� ���Ƚ��: %dȸ", HIGHPING_WARN_LIMIT ); SEND();
			format( str, sizeof(str), "* �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '/%s'�� �����ϼ���.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new warningtime;
	if( sscanf( params, "i", warningtime ) || warningtime < 1 )
	{
		if(CONSOLE) print("[rcon] ���� : �ΰ�� or /setpwarn [Ƚ��]");
		else SendClientMessage(playerid,COLOR_GREY,"* ���� : ������ or /setpwarn [Ƚ��]");
		return 1;
	}
	HIGHPING_WARN_LIMIT = warningtime;
	new str[56];
	format( str, sizeof(str), "* �������� �� ������ %d�� �ʰ��ϸ� �߹�˴ϴ�.", HIGHPING_WARN_LIMIT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] �� �����ʰ� ���Ƚ���� %d������ �����Ͽ����ϴ�.",HIGHPING_WARN_LIMIT );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ����� ���� �����Դϴ�." );
			print( "[help] �����ð� ���� ���ͳ��� ���� �÷��̾��� �������� �ʱ�ȭ �մϴ�." );
			printf( "[help] ��) %s : ���� �������� �÷��̾��� ��� Ƚ���� �ʱ�ȭ �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s 10 : ��� Ƚ���� �� 10�ʸ��� �ʱ�ȭ �մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s 0 : ��� Ƚ���� ������ �ʽ��ϴ�. �Ӱ谪�� �Ѿ�� �ڵ����� �߹��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ���� �ʱ�ȭ ����: %d�ʸ��� �ʱ�ȭ(0: �ʱ�ȭ���� ����).", RESET_HIGHPING_TICK );
			printf( "[help] �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '%s'�� �����ϼ���.", GetCmdName(CMD_PING) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ����� ���� �����Դϴ�." );
			SendClientMessage( playerid, COLOR_LIME, "* �����ð� ���� ���ͳ��� ���� �÷��̾��� �������� �ʱ�ȭ �մϴ�." );
			format( str, sizeof(str), "* ��) /%s : ���� �������� �÷��̾��� ��� Ƚ���� �ʱ�ȭ �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 10 : ��� Ƚ���� �� 10�ʸ��� �ʱ�ȭ �մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 0 : ��� Ƚ���� ������ �ʽ��ϴ�. �Ӱ谪�� �Ѿ�� �ڵ����� �߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ���� �ʱ�ȭ ����: %d�ʸ��� �ʱ�ȭ(0: �ʱ�ȭ���� ����).", RESET_HIGHPING_TICK ); SEND();
			format( str, sizeof(str), "* �� ���� ����� Ȱ��ȭ/��Ȱ��ȭ �Ϸ��� '/%s'�� �����ϼ���.", GetCmdName(CMD_PING) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	//�Է����� ���� ��� �ܼ� ������ �ʱ�ȭ
	if( isnull(params) )
	{
		ResetPingCheck( );
		if( CONSOLE ) print("[rcon] �����ð� ���Ƚ���� �ʱ�ȭ �Ͽ����ϴ�.");
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* �����ð� ���Ƚ���� �ʱ�ȭ �Ͽ����ϴ�." );
		return 1;
	}
	new resetping_tick;
	if( sscanf( params, "i", resetping_tick ) || resetping_tick < 0 )
	{
		if( CONSOLE ) print("[rcon] ���� : ���ʱ�ȭ �Ǵ� resetping [�ð�=�ʱ�ȭ, 0=������]");
		else SendClientMessage( playerid, COLOR_GREY, "* ���� : /���ʱ�ȭ �Ǵ� /resetping [�ð�=�ʱ�ȭ, 0=������]" );
		return 1;
	}
	
	RESET_HIGHPING_TICK = resetping_tick;
	new str[80];
	if( !RESET_HIGHPING_TICK )
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� �����ð� ���Ƚ���� �ʱ�ȭ���� �ʽ��ϴ�." );
		print("[rcon] ���� �����ð� ���Ƚ���� �ʱ�ȭ���� �ʽ��ϴ�." );
	}
	else
	{
		format( str, sizeof(str), "* �������� %d�ʸ��� ������ ���Ƚ���� �ʱ�ȭ�մϴ�.", RESET_HIGHPING_TICK );
		SendClientMessageToAll( COLOR_GREENYELLOW, str );
		printf("[rcon] ������ ���Ƚ�� �ʱ�ȭ �ð��� %d�ʷ� �����Ͽ����ϴ�.", RESET_HIGHPING_TICK );
	}	
	//������ ���̾��� ��� Ÿ�̸� ����
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ž������ �÷��̾ ������ ������ �մϴ�." );
			printf( "[help] ��) %s coolguy : 'coolguy' �� ������ ������ �մϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ž������ �÷��̾ ������ ������ �մϴ�." );
			format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy' �� ������ ������ �մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new giveplayerid;

	if(isnull(params))
	{
		if(CONSOLE) print("[rcon] ���� : /������ or /sdrop [�̸��̳� ��ȣ]");
		else SendClientMessage(playerid, COLOR_GREY, "* ���� : /������ or /sdrop [�̸��̳� ��ȣ]");
		return 1;
	}
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if(CONSOLE) print("[rcon] �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		return 1;
	}

	if( !IsPlayerInAnyVehicle( giveplayerid ) )
	{
		if(CONSOLE) print("[rcon] �ش� �÷��̾�� ���� Ÿ������ �ʽ��ϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �ش� �÷��̾�� ���� Ÿ������ �ʽ��ϴ�.");
		return 1;
	}

	RemovePlayerFromVehicle( giveplayerid );

	new str[83];
	format( str, sizeof(str), "* ��� %s(��)�� %s(%d)���� ������ ������ �߽��ϴ�.", GetPlayerNameEx(playerid), GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	printf("[rcon] %s(%d)���� �������� ������ �߽��ϴ�.", GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾ �����ϱ� �����մϴ�." );
			printf( "[help] ��) %s coolguy : 'coolguy' �� �����ϱ� �����մϴ�.", CURRENT_CMD_NAME );
			print( "[help] �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ش� �÷��̾ �����ϱ� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy' �� �����ϱ� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] �ֿܼ��� ����� �Ұ����� ��ɾ��Դϴ�.");
		return 1;
	}
	new giveplayerid;

	if(isnull(params)) return SendClientMessage(playerid, COLOR_GREY, "* ���� : /���� or /spectate [�̸��̳� ��ȣ]");
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else return SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");

	new str[83];

	if( IS_PLAYER_SPECTATED[giveplayerid] != INVALID_PLAYER_ID )
	{
		format( str, sizeof(str), "* �ش� �÷��̾�� �̹� %s(%d)���� �������Դϴ�.", GetPlayerNameEx(IS_PLAYER_SPECTATED[giveplayerid]), IS_PLAYER_SPECTATED[giveplayerid] );
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

	format( str, sizeof(str), "* %s(%d)���� �����ϱ� �����մϴ�.", GetPlayerNameEx( giveplayerid ), giveplayerid );
	SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* �����Ͻ÷��� /%s �Ǵ� /%s ��(��) �Է��ϼ���.", GetCmdName(CMD_SPECOFF), GetCmdAltName(CMD_SPECOFF) );
	SendClientMessage( playerid, COLOR_ORANGE, str );
	printf("[rcon] %s(%d)���� %s(%d)���� �����ϱ� �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid, GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� �۵����� ���ø�带 �����մϴ�." );
			printf( "[help] ��) %s : ���� �۵����� ���ø�带 �����մϴ�.", CURRENT_CMD_NAME );
			print( "[help] �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ���� �۵����� ���ø�带 �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s : ���� �۵����� ���ø�带 �����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		print("[rcon] �ֿܼ��� ����� �Ұ����� ��ɾ��Դϴ�.");
		return 1;
	}
	/* if( GetPlayerState( playerid ) != PLAYER_STATE_SPECTATING )
	{
		SendClientMessage( playerid, COLOR_GREY, "* �������� �ƴմϴ�." );
		return 1;
	} */

	if( IS_PLAYER_SPECTATING[playerid] != INVALID_PLAYER_ID )
	{
		IS_PLAYER_SPECTATED[IS_PLAYER_SPECTATING[playerid]] = INVALID_PLAYER_ID;
		IS_PLAYER_SPECTATING[playerid] = INVALID_PLAYER_ID;
	}

	TogglePlayerSpectating(playerid, 0);
	SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���ø�带 �����߽��ϴ�." );
	printf("[rcon] %s(%d)���� ���ø�带 �����߽��ϴ�.", GetPlayerNameEx(playerid), playerid);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������� ����� �۵�/�����մϴ�." );
			printf( "[help] ��) %s 0 : ESCŰ�� ������ ����ϸ� �ڵ����� �߹��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s 1 : %d���̻� ���Ÿ�� ��� �߹��մϴ�.", CURRENT_CMD_NAME, DESYNC_LIMIT );
			printf( "[help] ��) %s 2 : ����� ����մϴ�.", CURRENT_CMD_NAME );
			print( "[help] ������� �ð� ������ RconController.ini���� �����ϼ���." );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������� ����� �۵�/�����մϴ�." );			
			format( str, sizeof(str), "* ��) /%s 0 : ESCŰ�� ������ ����ϸ� �ڵ����� �߹��մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ��) /%s 1 : %d���̻� ���Ÿ�� ��� �߹��մϴ�.", CURRENT_CMD_NAME, DESYNC_LIMIT ); SEND();
			format( str, sizeof(str), "* ��) /%s 2 : ����� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������� �ð� ������ RconController.ini���� �����ϼ���." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* ���� ������� ����� ���ѵǾ� �ֽ��ϴ�.");
		print("[rcon] ������� ����� ���ѵǾ� �ֽ��ϴ�. RconController.ini�� �ε��� �ּ���.");
		return 1;
	}
	new desync;
	if( sscanf( params, "i", desync ) || desync < 0 || desync > 2 )
	{
		if(CONSOLE) print("[rcon] ����: ��� or desync [0 ~ 2]");
		else SendClientMessage( playerid, COLOR_RED, "* ����: /��� or /desync [0 ~ 2]");
		return 1;
	}
	ALLOW_DESYNC = desync;
	switch(desync)
	{
		case 0:
		{
			DESYNC_LIMIT = 5;
			SendClientMessageToAll(COLOR_GREENYELLOW, "* �˸� : �������� ESCŰ�� ���� ����ϸ� �߹�˴ϴ�.");
			print("[rcon] ����� �����߽��ϴ�.");
		}
		case 1:
		{
			DESYNC_LIMIT = c_iniInt( "[General]", "DESYNC_LIMIT" );
			SendFormatMessageToAll(COLOR_GREENYELLOW, "* �˸� : �������� %d���̻� ESCŰ�� ���� ����ϸ� �߹�˴ϴ�.", DESYNC_LIMIT);
			printf("[rcon] ����� %d�ʱ����� ����߽��ϴ�.", DESYNC_LIMIT);
		}
		case 2:
		{
			SendClientMessageToAll(COLOR_GREENYELLOW, "* �˸� : �������� ESCŰ�� ���� ����ص� �߹���� �ʽ��ϴ�.");
			print("[rcon] ����� ����߽��ϴ�.");
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ý��� �������� �߻��մϴ�. (Windows 7���ʹ� �۵����� �ʽ��ϴ�.)" );
			printf( "[help] ��) %s 3,�����ڴ� ���� : �������� 3ȸ �߻��ϸ�, '�����ڴ� ����' ��� �޼����� ���ϴ�.", CURRENT_CMD_NAME );			
			printf( "[help] �����ڿ��� ���� �޼����� �������� '%s'��(��) �����ϼ���.", GetCmdName(CMD_SPM) );
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ý��� �������� �߻��մϴ�. (Windows 7���ʹ� �۵����� �ʽ��ϴ�.)" );
			format( str, sizeof(str), "* ��) /%s 3,�����ڴ� ���� : �������� 3ȸ �߻��ϸ�, '�����ڴ� ����' ��� �޼����� ���ϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* �����ڿ��� ���� �޼����� �������� '%s'��(��) �����ϼ���.", GetCmdName(CMD_SPM) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	new str[128], itteration;
	if( sscanf(params, "p,is", itteration, str) || itteration < 0 )
	{
		if(CONSOLE) print("[rcon] ����: �Ҹ����� or mks [������ Ƚ��],[�Ҹ�] - ���� ��� �ĸ��� �������ּ���.");
		else SendClientMessage( playerid, COLOR_GREY, "* ����: /�Ҹ����� or /mks [������ Ƚ��],[�Ҹ�] - ���� ��� �ĸ��� �������ּ���.");
		return 1;
	}
	if( itteration > 5 )
	{
		if(CONSOLE) print("[rcon] �������� 5ȸ������ ���� �����մϴ�.");
		else SendClientMessage( playerid, COLOR_GREY, "* �������� 5ȸ������ ���� �����մϴ�.");
		return 1;
	}
	if (CONSOLE) printf("[call] �ַܼκ��� ��� ȣ���Դϴ�. : %s", str);
	else printf("[call] ��� %s(%d)�� ȣ���Դϴ�: %s", GetPlayerNameEx(playerid), playerid, str);
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] RconController.ini�� ����� ���� ������ �ٽ� �о�ɴϴ�." );
			printf( "[help] ���� ������ ���Ϸ� �����Ϸ��� '%s'��(��) �����ϼ���.", GetCmdName(CMD_SAVECONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* RconController.ini�� ����� ���� ������ �ٽ� �о�ɴϴ�." );
			format( str, sizeof(str), "* ���� ������ ���Ϸ� �����Ϸ��� '/%s'��(��) �����ϼ���.", GetCmdName(CMD_SAVECONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini�� ã�� �� �����ϴ�. ���� �θ��⸦ ����� �� �����ϴ�.");
		print("[rcon] RconController.ini�� ã�� �� �����ϴ�. ���� �θ��⸦ ����� �� �����ϴ�.");
		return 1;
	}
	LoadUserConfigs(1);
	SendClientMessageToAll( COLOR_GREENYELLOW, "* ������ ��å�� ����Ǿ����ϴ�." );
	print("[rcon] ������ ������ �ٽ� �ҷ��Խ��ϴ�.");
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ ���� ��å�� RconController.ini�� �����մϴ�." );
			printf( "[help] ������ ������ ���Ϸκ��� �о������ '%s'��(��) �����ϼ���.", GetCmdName(CMD_LOADCONFIG) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* ������ ���� ��å�� RconController.ini�� �����մϴ�." );
			format( str, sizeof(str), "* ������ ������ ���Ϸκ��� �о������ '/%s'��(��) �����ϼ���.", GetCmdName(CMD_LOADCONFIG) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if(!fexist(FILE_SETTINGS))
	{
		SendClientMessage( playerid, COLOR_RED, "* RconController.ini�� ã�� �� �����ϴ�. ���� �������� ����� �� �����ϴ�.");
		print("[rcon] RconController.ini�� ã�� �� �����ϴ�. ���� �������� ����� �� �����ϴ�.");
		return 1;
	}
	SaveUserConfigs( );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� ������ ��å�� �����߽��ϴ�." );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� �÷��̾��� ���̵�� �ɸ� ���� �����մϴ�." );
			printf( "[help] ��) %s coolguy : 'coolguy'�� �����ϴ� ���� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] IP�� ����Ͽ� ���� Ǯ���� '%s'��(��) �����ϼ���.", GetCmdName(CMD_UNBANIP) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ش� �÷��̾��� ���̵�� �ɸ� ���� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy'�� �����ϴ� ���� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* IP�� ����Ͽ� ���� Ǯ���� '/%s'��(��) �����ϼ���.", GetCmdName(CMD_UNBANIP) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) || strlen(params) >= MAX_PLAYER_NAME )
	{
		if(CONSOLE) printf("[rcon] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
		else
		{
			new str[128];
			format(str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND_C(COLOR_RED);
		}
		return 1;
	}

	new str[50];
	format( str, sizeof(str), "unban %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* %s���� ���Ͽ��� �����߽��ϴ�.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] %s���� ���Ͽ��� �����߽��ϴ�.", params );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ش� IP�� �ɸ� ���� �����մϴ�." );
			printf( "[help] ��) %s 192.168.0.1 : �ش� IP�� ������ �����ϴ� ���� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ���̵� ����Ͽ� ���� Ǯ���� '%s'��(��) �����ϼ���.", GetCmdName(CMD_UNBAN) );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ش� IP�� �ɸ� ���� �����մϴ�." );
			format( str, sizeof(str), "* ��) /%s 192.168.0.1 : �ش� IP�� ������ �����ϴ� ���� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
			format( str, sizeof(str), "* ���̵� ����Ͽ� ���� Ǯ���� '/%s'��(��) �����ϼ���.", GetCmdName(CMD_UNBAN) ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( isnull(params) )
	{
		if(CONSOLE) print("[rcon] ����: �����ǹ�Ǯ�� or unbanip [���̵�]");
		else SendClientMessage( playerid, COLOR_GREY, "* ����: /�����ǹ�Ǯ�� or /unbanip [���̵�]");
		return 1;
	}
	if( !IsValidIP(params) )
	{
		if(CONSOLE) print("[rcon] �����Ǹ� ����� �Է��ϼ���.");
		else SendClientMessage( playerid, COLOR_ORANGE, "* �����Ǹ� ����� �Է��ϼ���.");
		return 1;
	}

	new str[59];
	format( str, sizeof(str), "unbanip %s", params );
	SendRconCommand( str );
	SendRconCommand( "reloadbans" );
	format( str, sizeof(str), "* ������ %s��(��) ���Ͽ��� �����߽��ϴ�.", params );
	if( !CONSOLE ) SendClientMessage( playerid, COLOR_GREENYELLOW, str );
	printf("[rcon] ������ %s��(��) ���Ͽ��� �����߽��ϴ�.", params );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ �����߹��ϴ� ��ǥ�� �����մϴ�." );
			print( "[help] '���' / '������' ���� �����߹� ��ǥ����� Ȱ��ȭ/��Ȱ��ȭ�� �� �ֽ��ϴ�." );
			print( "[help] '�ߴ�' ���� �������� ��ǥ�� �ߴ��� �� �ֽ��ϴ�." );
			printf( "[help] ��) %s ��� : �����߹� ����� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s ������ : �����߹� ����� ������� �ʽ��ϴ�.", CURRENT_CMD_NAME );			
			printf( "[help] ��) %s coolguy : 'coolguy'�� �߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s �ߴ� : �������� �����߹� ��ǥ�� �ߴ��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��ǥ ���� �����߹��� '%s'��(��) �����ϼ���.", cmdlist[CMD_KICK][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ �����߹��ϴ� ��ǥ�� �����մϴ�." );
				SendClientMessage( playerid, COLOR_LIME, "* '���' / '������' ���� �����߹� ��ǥ����� Ȱ��ȭ/��Ȱ��ȭ�� �� �ֽ��ϴ�." );
				SendClientMessage( playerid, COLOR_LIME, "* '�ߴ�' ���� �������� ��ǥ�� �ߴ��� �� �ֽ��ϴ�." );
				format( str, sizeof(str), "* ��) /%s ��� : �����߹� ����� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s ������ : �����߹� ����� ������� �ʽ��ϴ�.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy'�� �߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s �ߴ� : �������� �����߹� ��ǥ�� �ߴ��մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��ǥ ���� �����߹��� '%s'��(��) �����ϼ���.", cmdlist[CMD_KICK][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ �����߹��ϴ� ��ǥ�� �����մϴ�." );
				format( str, sizeof(str), "* ��) /%s 1 : 1�� �÷��̾ �߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy'�� �߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ��ǥ�� ���� �̻� ����� �־�� �����ϸ�, ��ǥ����� ��Ȱ��ȭ�� ��� ��ڿ��� �����ϼ���." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	
	new str[128], giveplayerid;
	
	//���� ��ɾ�. �Է��ڰ� ����� ��� ������ɾ� �Է¿��� Ȯ��
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //��ǥ Ȱ��ȭ ��û
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "���", true ) == 0 ) //�߹���ǥ ��� ���
		{
			if( ENABLE_VOTEKICK ) //�̹� ����� Ȱ��ȭ�� ���
			{
			    if( CONSOLE ) print("[rcon] �̹� �����߹� ��ǥ����� ������Դϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* �̹� �����߹� ��ǥ����� ������Դϴ�.");
			    return 1;
			}
	    	ENABLE_VOTEKICK = 1;

	    	print("[rcon] �����߹� ��ǥ����� �����Ͽ����ϴ�.");
			format( str, sizeof(str), "* ��� %s(��)�� �����߹� ��ǥ����� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//��ǥ �ߴ� ��û
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "�ߴ�", true ) == 0 ) // ��ǥ�ߴ� ��û
		{
		    if( VOTEKICK_REMAINTIME <= 0 ) //�������� ��ǥ�� ���� ���
			{
			    if( CONSOLE ) print("[rcon] ���� �������� �����߹� ��ǥ�� �����ϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ���� �������� �����߹� ��ǥ�� �����ϴ�.");
			    return 1;
			}
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] �������� �����߹� ��ǥ�� �ߴ��մϴ�.");
			format( str, sizeof(str), "* ��� %s�� ��û���� �������� �����߹� ��ǥ�� �ߴ��մϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//��ǥ ��Ȱ��ȭ ��û
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "������", true ) == 0 ) // ��ǥ ��Ȱ��ȭ ��û
		{
			if( !ENABLE_VOTEKICK ) //�̹� ����� ��Ȱ��ȭ�� ���
			{
			    if( CONSOLE ) print("[rcon] �����߹� ��ǥ����� ������� �ʰ� �ֽ��ϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* �����߹� ��ǥ����� ������� �ʰ� �ֽ��ϴ�.");
			    return 1;
			}
			if ( VOTEKICK_REMAINTIME )
			{
				print("[rcon] �������� �����߹� ��ǥ�� �ߴ��մϴ�.");
				format( str, sizeof(str), "* ��� %s�� ��û���� �������� �����߹� ��ǥ�� �ߴ��մϴ�.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEKICK = 0;
		    VOTEKICK_REMAINTIME = 0;
			VOTEKICK_PLAYER_GOT = 0;
			VOTEKICK_TICK = 0;
			CURRENT_VOTEKICK_REQUIREMENT = MAX_PLAYERS;
			VOTEKICK_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] �����߹� ��ǥ����� �����Ͽ����ϴ�.");
			format( str, sizeof(str), "* ��� %s(��)�� �����߹� ��ǥ����� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid));
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //��ǥ����� ������� �ʴ°�� �޼��� ���
	if( !ENABLE_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�.\n[rcon] ����Ͻ÷��� '%s ���'�� �Է��ϼ���.", CURRENT_CMD_NAME);
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�. ����Ͻ÷��� '/%s ���'�� �Է��ϼ���.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�. ��ڿ��� �����ϼ���.");
		return 1;
	}

	//�Ϲ� ��ǥ���
	if( params[0] ) //���� �Է�����.
	{
	    //��ǥ�� �õ��� ���
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "��", true ) == 0 ) // ��ǥ�ϱ�
		{
			if( VOTEKICK_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] �����߹� ��ǥ���� �ƴմϴ�.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* �����߹� ��ǥ���� �ƴմϴ�.");
				return 1;
			}

			if( CONSOLE )
			{
				print("[rcon] �ֿܼ����� ��ǥ�Ͻ� �� �����ϴ�.");
				return 1;
			}
			
			//��ǥ���� �˻�
			new i;
			for( i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
			{
				if( KICKVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //�̹� ��ǥ�Ͽ���
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* �̹� ��ǥ�Ͽ����ϴ�.");
					return 1;
				}
			}
			//��ǥ�ϱ�
			SendClientMessage( playerid, COLOR_GREEN, "* ��ǥ�ϼ̽��ϴ�.");
			KICKVOTED_PLAYER_IP[VOTEKICK_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEKICK_PLAYER_GOT++;
			if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // �߹���� ���
			{
				format( str, sizeof(str), "* ��ǥ�� ����Ǿ����ϴ�. ��ǥ ����� %s(%d)���� ���� �߹��մϴ�.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] ��ǥ ����� %s(%d)���� ���� �߹��մϴ�.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
				VOTEKICK_REMAINTIME = 0;
				c_Kick( VOTEKICK_PLAYER );
			}
			return 1;
		}
		//��ǥ�� �������� ���
		if( VOTEKICK_REMAINTIME > 0 )
		{			
			if( CONSOLE ) print("[rcon] �������� ��ǥ�� �ֽ��ϴ�.");
			else SendClientMessage( playerid, COLOR_GREY, "* �������� ��ǥ�� �ֽ��ϴ�.");
		}
	}
	
	if( VOTEKICK_REMAINTIME > 0 ) //���� ��ǥ�� ������
	{
		if( CONSOLE )
		{
			printf("[rcon] ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
			printf("[rcon] �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
			printf("[rcon] �ߴ��Ͻ÷��� '%s �ߴ�'��, ��ǥ����� ���ַ��� '%s ������' �� �Է��ϼ���.", CURRENT_CMD_NAME, CURRENT_CMD_NAME);
			return 1;
		}
		format( str, sizeof(str), "* ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), " �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT ); SEND_C(COLOR_GREENYELLOW);
		format( str, sizeof(str), "* ��ǥ�Ͻ÷��� '/%s yes' �Ǵ� '/%s ��' �� �Է��ϼ���.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_SALMON); SEND_C(COLOR_GREENYELLOW);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* �ߴ��Ͻ÷��� '/%s �ߴ�'��, ��ǥ����� ���ַ��� '/%s ������' �� �Է��ϼ���.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //���� �������� ��ǥ ����. ��ǥ�ۼ� �õ��� ������.
	{
		if( CONSOLE )
		{
			print("[rcon] ���� �������� ��ǥ�� �����ϴ�.");
			printf("[rcon] ����: %s or %s [�̸��̳� ��ȣ]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] ��ǥ����� ���ַ��� '%s ������'�� �Է��ϼ���.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� �������� ��ǥ�� �����ϴ�.");
        format( str, sizeof(str),  "* ����: /%s �Ǵ� /%s [�̸��̳� ��ȣ]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ��ǥ����� ���ַ��� '/%s ������'�� �Է��ϼ���.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//��ǥ �����ϱ�
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		return 1;
	}
	
	//�ּ��ο��� �̴��ϴ°��
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEKICK )
	{
		if( CONSOLE ) printf("[rcon] ��ǥ�� �����Ϸ��� �ּ� %d���� �÷��̾ �ʿ��մϴ�.", REQUIRED_MAN_VOTEKICK );
	    else
		{
			format( str, sizeof(str), "* ��ǥ�� �����Ϸ��� �ּ� %d���� �÷��̾ �ʿ��մϴ�.", REQUIRED_MAN_VOTEKICK ); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//OK.Assign Player Informations.
	VOTEKICK_PLAYER = giveplayerid;
	VOTEKICK_PLAYER_GOT = 0;
	VOTEKICK_TICK = 0;
	VOTEKICK_REMAINTIME = VOTEKICK_RUN_TIME;
	CURRENT_VOTEKICK_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEKICK_PERCENTAGE) / 100;
	
	//�Ű��� ��к����� ��� ���, �ƴѰ�� �̸� ����
	if( VOTE_CONFIDENTIALITY ) str = "���";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("��������"):(GetPlayerNameEx(playerid)) );
	//��ǥ �޼��� ����
	format( str, sizeof(str), "* %s(%d)�Կ� ���� �����߹� ��ǥ�� ��û�Ǿ����ϴ�. (��û��: %s)",
		GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, str );
    SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* ��ǥ�� �� %d�ʰ� ����Ǹ�, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", VOTEKICK_RUN_TIME, CURRENT_VOTEKICK_REQUIREMENT );
	SendClientMessageToAll( COLOR_GREENYELLOW, str );
	format( str, sizeof(str), "* ��ǥ�Ͻ÷��� '/%s yes' �Ǵ� '/%s ��' �� �Է��Ͻø� �˴ϴ�.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* ��, ���ݺ��� ��ǥ�� �����մϴ�!" );
	printf("[rcon] %s(%d)�Կ� ���� �����߹� ��ǥ�� ��û�Ǿ����ϴ�. (��û��: %s, �ſ���ȣ:%s)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, (playerid==ADMIN_ID)? ("��������"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("��"):("�ƴϿ�") );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ������ �÷��̾ ������ �߹��ϴ� ��ǥ�� �����մϴ�." );
			print( "[help] '���' / '������' ���� �����߹� ��ǥ����� Ȱ��ȭ/��Ȱ��ȭ�� �� �ֽ��ϴ�." );
			print( "[help] '�ߴ�' ���� �������� ��ǥ�� �ߴ��� �� �ֽ��ϴ�." );
			printf( "[help] ��) %s ��� : �����߹� ����� ����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s ������ : �����߹� ����� ������� �ʽ��ϴ�.", CURRENT_CMD_NAME );			
			printf( "[help] ��) %s coolguy : 'coolguy'�� �����߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��) %s �ߴ� : �������� �����߹� ��ǥ�� �ߴ��մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ��ǥ ���� �����߹��� '%s'��(��) �����ϼ���.", cmdlist[CMD_BAN][Cmd] );			
			print(LINE);
		}
		else
		{				
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			
			if ( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
			{
				format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ ������ �߹��ϴ� ��ǥ�� �����մϴ�." );
				SendClientMessage( playerid, COLOR_LIME, "* '���' / '������' ���� �����߹� ��ǥ����� Ȱ��ȭ/��Ȱ��ȭ�� �� �ֽ��ϴ�." );
				SendClientMessage( playerid, COLOR_LIME, "* '�ߴ�' ���� �������� ��ǥ�� �ߴ��� �� �ֽ��ϴ�." );
				format( str, sizeof(str), "* ��) /%s ��� : �����߹� ����� ����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s ������ : �����߹� ����� ������� �ʽ��ϴ�.", CURRENT_CMD_NAME ); SEND();			
				format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy'�� �����߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s �ߴ� : �������� �����߹� ��ǥ�� �ߴ��մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��ǥ ���� �����߹��� '%s'��(��) �����ϼ���.", cmdlist[CMD_BAN][Cmd] ); SEND();
			}
			else
			{
				format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ������ �÷��̾ ������ �߹��ϴ� ��ǥ�� �����մϴ�." );
				format( str, sizeof(str), "* ��) /%s 1 : 1�� �÷��̾ �����߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				format( str, sizeof(str), "* ��) /%s coolguy : 'coolguy'�� �����߹��ϴ� ��ǥ�� �����մϴ�.", CURRENT_CMD_NAME ); SEND();
				SendClientMessage( playerid, COLOR_LIME, "* ��ǥ�� ���� �̻� ����� �־�� �����ϸ�, ��ǥ����� ��Ȱ��ȭ�� ��� ��ڿ��� �����ϼ���." );
			}
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}

	new str[128], giveplayerid;

	//���� ��ɾ�. �Է��ڰ� ����� ��� ������ɾ� �Է¿��� Ȯ��
    if( (CONSOLE || IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE)) && params[0] )
	{
	    //��ǥ Ȱ��ȭ ��û
	    if( strcmp( params, "on", true ) == 0 || strcmp( params, "���", true ) == 0 ) //�߹���ǥ ��� ���
		{
			if( ENABLE_VOTEBAN ) //�̹� ����� Ȱ��ȭ�� ���
			{
			    if( CONSOLE ) print("[rcon] �̹� �����߹� ��ǥ����� ������Դϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* �̹� �����߹� ��ǥ����� ������Դϴ�.");
			    return 1;
			}
	    	ENABLE_VOTEBAN = 1;

	    	print("[rcon] �����߹� ��ǥ����� �����Ͽ����ϴ�.");
			format( str, sizeof(str), "* ��� %s�� �����߹� ��ǥ����� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//��ǥ �ߴ� ��û
		if( strcmp( params, "stop", true ) == 0 || strcmp( params, "�ߴ�", true ) == 0 ) // ��ǥ�ߴ� ��û
		{
		    if( VOTEBAN_REMAINTIME <= 0 ) //�������� ��ǥ�� ���� ���
			{
			    if( CONSOLE ) print("[rcon] ���� �������� �����߹� ��ǥ�� �����ϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* ���� �������� �����߹� ��ǥ�� �����ϴ�.");
			    return 1;
			}
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] �������� �����߹� ��ǥ�� �ߴ��մϴ�.");
			format( str, sizeof(str), "* ��� %s�� ��û���� �������� �����߹� ��ǥ�� �ߴ��մϴ�.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
		//��ǥ ��Ȱ��ȭ ��û
		if( strcmp( params, "off", true ) == 0 || strcmp( params, "������", true ) == 0 ) // ��ǥ ��Ȱ��ȭ ��û
		{
			if( !ENABLE_VOTEBAN ) //�̹� ����� ��Ȱ��ȭ�� ���
			{
			    if( CONSOLE ) print("[rcon] �����߹� ��ǥ����� ������� �ʰ� �ֽ��ϴ�.");
			    else SendClientMessage( playerid, COLOR_GREY, "* �����߹� ��ǥ����� ������� �ʰ� �ֽ��ϴ�.");
			    return 1;
			}
			if( VOTEBAN_REMAINTIME )
			{
				print("[rcon] �������� �����߹� ��ǥ�� �ߴ��մϴ�.");
				format( str, sizeof(str), "* ��� %s�� ��û���� �������� �����߹� ��ǥ�� �ߴ��մϴ�.", GetPlayerNameEx(playerid) );
				SendClientMessageToAll( COLOR_SALMON, str );
			}
		    ENABLE_VOTEBAN = 0;
		    VOTEBAN_REMAINTIME = 0;
			VOTEBAN_PLAYER_GOT = 0;
			VOTEBAN_TICK = 0;
			CURRENT_VOTEBAN_REQUIREMENT = MAX_PLAYERS;
			VOTEBAN_PLAYER = INVALID_PLAYER_ID;

	    	print("[rcon] �����߹� ��ǥ����� �����Ͽ����ϴ�.");
			format( str, sizeof(str), "* ��� %s�� �����߹� ��ǥ����� �����Ͽ����ϴ�.", GetPlayerNameEx(playerid) );
			SendClientMessageToAll( COLOR_SALMON, str );
			return 1;
		}
	}

    //��ǥ����� ������� �ʴ°�� �޼��� ���
	if( !ENABLE_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�.\n[rcon] ����Ͻ÷��� '%s ���' �� �Է��ϼ���.", CURRENT_CMD_NAME );
		else if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str),  "* ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�. ����Ͻ÷��� '/%s ���' �� �Է��ϼ���.", CURRENT_CMD_NAME); SEND_C(COLOR_GREENYELLOW);
		}
		else SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� �����߹� ��ǥ����� ����ϰ� ���� �ʽ��ϴ�. ��ڿ��� �����ϼ���.");
		return 1;
	}

	//�Ϲ� ��ǥ���
	if( params[0] ) //���� �Է�����.
	{
	    //��ǥ�� �õ��� ���
	    if( strcmp( params, "yes", true ) == 0 || strcmp( params, "��", true ) == 0 ) // ��ǥ�ϱ�
		{
			if( VOTEBAN_REMAINTIME <= 0 )
			{
				if( CONSOLE ) print("[rcon] �����߹� ��ǥ���� �ƴմϴ�.");
				else SendClientMessage( playerid, COLOR_ORANGE, "* �����߹� ��ǥ���� �ƴմϴ�.");
				return 1;
			}
			
			if( CONSOLE )
			{
				print("[rcon] �ֿܼ����� ��ǥ�Ͻ� �� �����ϴ�.");
				return 1;
			}

			//��ǥ���� �˻�
			new i;
			for( i = 0; i < VOTEBAN_PLAYER_GOT; i++ )
			{
				if( BANVOTED_PLAYER_IP[i] == coolguy_hash(GetPlayerIpEx(i)) ) //�̹� ��ǥ�Ͽ���
				{
					SendClientMessage( playerid, COLOR_ORANGE, "* �̹� ��ǥ�Ͽ����ϴ�.");
					return 1;
				}
			}
			//��ǥ�ϱ�
			SendClientMessage( playerid, COLOR_GREEN, "* ��ǥ�ϼ̽��ϴ�.");
			BANVOTED_PLAYER_IP[VOTEBAN_PLAYER_GOT] = coolguy_hash(GetPlayerIpEx(i));
			VOTEBAN_PLAYER_GOT++;
			if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // �߹���� ���
			{
				format( str, sizeof(str), "* ��ǥ�� ����Ǿ����ϴ�. ��ǥ ����� %s(%d)���� ������ �߹��մϴ�.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				printf("[rcon] ��ǥ ����� %s(%d)���� ������ �߹��մϴ�.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
				VOTEBAN_REMAINTIME = 0;
				c_Ban( VOTEBAN_PLAYER );
			}
			return 1;
		}
		//��ǥ�� �������� ���
		if( VOTEBAN_REMAINTIME > 0 )
		{
			if( CONSOLE ) print("[rcon] �̹� �������� ��ǥ�� �ֽ��ϴ�.");
			else SendClientMessage( playerid, COLOR_GREY, "* �̹� �������� ��ǥ�� �ֽ��ϴ�." );
		}
	}
	if( VOTEBAN_REMAINTIME > 0 ) //���� ��ǥ�� ������
	{
		if( CONSOLE )
		{
			//�ƹ��͵� �Է����� ����. ��ǥ�� ������. ���� Ȯ��.
			printf("[rcon] ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
			printf("[rcon] �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �����߹�˴ϴ�.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
			printf("[rcon] �ߴ��Ͻ÷��� '%s �ߴ�' ��, ��ǥ����� ���ַ��� '%s ������' �� �Է��ϼ���.", CURRENT_CMD_NAME, CURRENT_CMD_NAME );
			return 1;
		}
		format( str, sizeof(str), "* ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), " �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
		SendClientMessage( playerid, COLOR_ORANGE, str );
		format( str, sizeof(str), "* ��ǥ�Ͻ÷��� '/%s yes' �Ǵ� '/%s ��' �� �Է��ϼ���.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME); SEND_C(COLOR_SALMON);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
		    format( str, sizeof(str), "* ��ǥ�� �ߴ��Ͻ÷��� '/%s �ߴ�' ��, ��ǥ����� ���ַ��� '/%s ������' �� �Է��ϼ���.", CURRENT_CMD_NAME, CURRENT_CMD_NAME ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	else if( isnull(params) ) //���� �������� ��ǥ ����. ��ǥ�ۼ� �õ��� ������.
	{
		if( CONSOLE )
		{
			print("[rcon] ���� �������� ��ǥ�� �����ϴ�.");
			printf("[rcon] ����: %s or %s [�̸��̳� ��ȣ]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME );
			printf("[rcon] ��ǥ����� ���ַ��� '%s ������'�� �Է��ϼ���.", CURRENT_CMD_NAME);
			return 1;
		}
	    SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���� �������� ��ǥ�� �����ϴ�.");
        format( str, sizeof(str),  "* ����: /%s �Ǵ� /%s [�̸��̳� ��ȣ]", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME ); SEND_C(COLOR_GREY);
		if( IsPlayerAdmin(playerid) || AuthorityCheck(playerid,AUTH_CMD_VOTE) )
		{
			format( str, sizeof(str), "* ��ǥ����� ���ַ��� '/%s ������'�� �Է��ϼ���.", CURRENT_CMD_NAME); SEND_C(COLOR_GREY);
		}
		return 1;
	}

	//��ǥ �����ϱ�
	if(isNumeric(params) && strval(params) >= 0 && strval(params) < M_P && IsPlayerConnectedEx(strval(params))) giveplayerid = strval(params);
	else if(params[0] == '~' && IsPlayerConnectedEx(LAST_PLAYER_ID)) giveplayerid=LAST_PLAYER_ID;
	else if((giveplayerid = PRIVATE_GetClosestPlayerID(params)) != INVALID_PLAYER_ID) {}
	else
	{
		if( CONSOLE ) print("[rcon] �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		else SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
		return 1;
	}

	//�ּ��ο��� �̴��ϴ°��
	if( NUM_PLAYERS < REQUIRED_MAN_VOTEBAN )
	{
		if( CONSOLE ) printf("[rcon] ��ǥ�� �����Ϸ��� �ּ� %d���� �÷��̾ �ʿ��մϴ�.", REQUIRED_MAN_VOTEBAN );
		else
		{
			format( str, sizeof(str), "* ��ǥ�� �����Ϸ��� �ּ� %d���� �÷��̾ �ʿ��մϴ�.", REQUIRED_MAN_VOTEBAN ); SEND_C(COLOR_GREY);
		}
		return 1;
	}
	
	//OK.Assign Player Informations.
	VOTEBAN_PLAYER = giveplayerid;
	VOTEBAN_PLAYER_GOT = 0;
	VOTEBAN_TICK = 0;
	VOTEBAN_REMAINTIME = VOTEBAN_RUN_TIME;
	CURRENT_VOTEBAN_REQUIREMENT =  (NUM_PLAYERS *  MINIMUM_VOTEBAN_PERCENTAGE) / 100;

	//�Ű��� ��к����� ��� ���, �ƴѰ�� �̸� ����
	if( VOTE_CONFIDENTIALITY ) str = "���";
	else format( str, sizeof(str), "%s", (playerid==ADMIN_ID)? ("��������"):(GetPlayerNameEx(playerid)) );
	//��ǥ �޼��� ����
	format( str, sizeof(str), "* %s(%d)�Կ� ���� �����߹� ��ǥ�� ��û�Ǿ����ϴ�. (��û��: %s)",
		GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, str );
    SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* ��ǥ�� �� %d�ʰ� ����Ǹ�, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", VOTEBAN_RUN_TIME, CURRENT_VOTEBAN_REQUIREMENT );
	SendClientMessageToAll( COLOR_ORANGE, str );
	format( str, sizeof(str), "* ��ǥ�Ͻ÷��� '/%s yes' �Ǵ� '/%s ��' �� �Է��Ͻø� �˴ϴ�.", CURRENT_CMD_ALTER_NAME, CURRENT_CMD_NAME );
	SendClientMessageToAll( COLOR_SALMON, str );
	SendClientMessageToAll( COLOR_SALMON, "* ��, ���ݺ��� ��ǥ�� �����մϴ�!" );
	printf("[rcon] %s(%d)�Կ� ���� �����߹� ��ǥ�� ��û�Ǿ����ϴ�. (��û��: %s, �ſ���ȣ:%s)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, (playerid==ADMIN_ID)? ("��������"):(GetPlayerNameEx(playerid)),
	(VOTE_CONFIDENTIALITY)? ("��"):("�ƴϿ�") );
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �߹� �Ǵ� �����߹�� ��ǥ �������� �����ִ� ����Դϴ�." );
			print( "[help] �ݺ� �Է����� �Ѱ� ���Ⱑ �����մϴ�." );		
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �߹� �Ǵ� �����߹�� ��ǥ �������� �����ִ� ����Դϴ�." ); SEND();
			SendClientMessage( playerid, COLOR_LIME, "* �ݺ� �Է����� �Ѱ� ���Ⱑ �����մϴ�." );
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	VOTE_CONFIDENTIALITY = !VOTE_CONFIDENTIALITY;
	SendClientMessageToAll(COLOR_GREENYELLOW,(VOTE_CONFIDENTIALITY? ("* ���ݺ��� ��ǥ �������� �ſ��� ��ȣ�մϴ�."):("* ���ݺ��� ��ǥ �������� �ſ��� �����˴ϴ�.")));
	print((VOTE_CONFIDENTIALITY? ("[rcon] ���ݺ��� ��ǥ �������� �ſ��� ��ȣ�մϴ�."):("[rcon] ���ݺ��� ��ǥ �������� �ſ��� �����˴ϴ�.")));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] Rcon Controller�� ������ ���ϴ�. �߰������� ������Ʈ�� Ȯ���մϴ�." );
			printf( "[help] ��) %s : ���α׷��� ������ ���ϴ�.", CURRENT_CMD_NAME );
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* Rcon Controller�� ������ ���ϴ�. �߰������� ������Ʈ�� Ȯ���մϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : ���α׷��� ������ ���ϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	if( CONSOLE )
	{
		printf("Rcon Controller %s��(��) ������Դϴ�.\n%s", VERSION, COPYRIGHT_STRING );
		#if SAMP03b
			rcmd_checkupdate(NULL);
		#endif
	}
	else
	{
		new str[64];
		format( str, sizeof(str), "Rcon Controller %s��(��) ������Դϴ�.", VERSION ); 
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] �ο�ڰ� ���� �ڽ��� ������ �ִ� ������ Ȯ���ϴ� ����Դϴ�." );
			printf( "[help] ��) %s : �ڽ��� ������ �ִ� ������ Ȯ���մϴ�.", CURRENT_CMD_NAME );
			print("[help] �ֿܼ����� ����� �Ұ����� ��ɾ��Դϴ�.");
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS ); SEND();
			format( str, sizeof(str), "* �ο�ڰ� ���� �ڽ��� ������ �ִ� ������ Ȯ���ϴ� ����Դϴ�." ); SEND();
			format( str, sizeof(str), "* ��) /%s : �ڽ��� ������ �ִ� ������ Ȯ���մϴ�.", CURRENT_CMD_NAME ); SEND();
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
		}
		return 1;
	}
	
	No_Console();

	new auths[NUM_AUTH-2][]=
	{
		"�ӼӸ� ������",
		"��ɾ� ������",
		"��޼��� ���ű�",
		"��� ä�� ���� (/�� , /say, /�����, /psay)",
		"�ð� ������ (/�ð�, /wtime)",
		"���� ��Ż�� (/ų, /skill)",
		"��ȭ ������ (/���ֱ�, /givecash, /������, /setcash)",
		"���� ������ (/�����ֱ�, /giveweapon)",
		"�г��� ����� (/�йٲٱ�, /chnick)",
		"ü�� ������ (/ü����, /sethp, /����, /infinite)",
		"���ھ� ������ (/���ھ�, /setscore)",
		"�Ƹ� ������ (/�Ƹ�, /armour, /�Ƹӹ���, /infarmor)",
		"��� ü���� (/������, /freeze)",
		"Ư�� ���� (/��������, /unfreeze)",
		"���� ��۱� (/�Ҹ�, /sound, /�Ҹ�����, /stopsound)",
		"���� ������ (/����, /user, /����, /stat)",
		"��Ʈ�� ������ (/��Ʈ��, /jetpack)",
		"���� �߹�� (/ű, /skick)",
		"���� �߹�� (/��, /sban)",
		"���� �ܼӱ� (/ä��, /shutup, /����, /chatflood, /��ɾ��, /cmdflood)",
		"����� ���� (/��ê, /unshut)",
		"��� ������ (/����Ż, /forfeit)",
		"���� ������ (/�����Ż, /disarm) ",
		"���� �̿�� (/����ȯ, /spawncar)",
		"�ο�� �Ӹ�� (/�ο�, /subadmin)",
		"�ο� ź�ٱ� (/�ο��Ż, /suspend)",
		"���߹� ���� (/��ź, /bomb)",
		"���� ȫ���� (/����, /notice, /�������, /noticelist, /�����ε�, /reloadnotice)",
		"���� ��� ����� (/������ױ�, /locksvr)",
		"���� �̵��� (/���, /with)",
		"���� ��ȯ�� (/��ȯ, /call)",
		"�ο�� �λ�� (/���Ѻ���, /chauth, /���Ѹ��, /authlist, /�ο�ε�, /reloadsubs)",
		"�߷� ������ (/�߷�, /gravity)",
		"���� ������ (/����, /weather)",
		"���� ������ (/��������, /carenergy)",
		"�弳 �ܼӱ� (/������, /yellfilter, /���߰�, /addyell, /������, /delyell)",
		"�ٹ��� ������ (/������, /�����߰�, /��������, /��Ʈ����)",
		"�� ������ (/������, /pingcheck, /������, /setplimit, /�ΰ��, /setpwarn, /���ʱ�ȭ, /resetping)",
		"�ҽ� �˹��� (/sdrop, /������, /����, /spectate, /��������, /specoff)",
		"��� ������ (/���, /desync)",
		"��� ȣ��� (/�Ҹ�����, /mks)",
		"���� �����(/�����ε�, /��������, /loadconfig, /saveconfig)",
		"���� ������(/��Ǯ��, /unban, /�����ǹ�Ǯ��, /unbanip)",
		"��ǥ ���/�ߴ�(/������ǥ, /votekick, /������ǥ, /voteban)"
	};
	
	new str[128];
	if( IsPlayerAdmin(playerid) ) SendClientMessage( playerid, COLOR_LIME, "* ����� ����Դϴ�. Rcon Controller�� ��� ��ɾ ����� �� �ֽ��ϴ�." );
	else
	{
		SendClientMessage( playerid, COLOR_GREENYELLOW, "== ��� ������ ���� ��� ==" );
		for(new i = 2;i < NUM_AUTH;i++)
		{
			format(str,sizeof(str)," %s : %s",auths[i-2],(AuthorityCheck(playerid,Authinfo:i))? ("��� ����"):("���� ����"));
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ������ �ִ� �÷��̾� ��� �� �⺻������ Ȯ���մϴ�." );
			printf( "[help] ��) %s : ���� ������ �ִ� �÷��̾� ��� �� �⺻������ Ȯ���մϴ�.", CURRENT_CMD_NAME );			
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ���� ������ ��å�� Ȯ���մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ��) /%s : ���� ������ �ִ� �÷��̾� ��� �� �⺻������ Ȯ���մϴ�.", CURRENT_CMD_NAME );			
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
	
	//�� ������� ���� ǥ��
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
			printf( "[help] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			print( "[help] ���� ������ ��å�� Ȯ���մϴ�." );
			//printf( "[help] ��) %s : ���� ������ ��å�� Ȯ���մϴ�.", CURRENT_CMD_NAME );
			printf( "[help] ������ ������ INI ���Ͽ� �����Ϸ��� '%s' ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_SAVECONFIG));
			printf( "[help] ������ ������ INI ���Ϸκ��� �ٽ� �ε��Ϸ��� '%s' ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_LOADCONFIG));
			print(LINE);
		}
		else
		{
			new str[128];
			SendClientMessage( playerid, COLOR_GREEN, LINE_CLIENT);
			format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS );
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ���� ������ ��å�� Ȯ���մϴ�." );
			SendClientMessage( playerid, COLOR_LIME, str );
			//format( str, sizeof(str), "* ��) /%s : ���� ���Ͽ��� ������ �ٽ� �ҷ��ɴϴ�.", CURRENT_CMD_NAME );
			//SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ������ ������ INI ���Ͽ� �����Ϸ��� '/%s' ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_SAVECONFIG));
			SendClientMessage( playerid, COLOR_LIME, str );
			format( str, sizeof(str), "* ������ ������ INI ���Ϸκ��� �ٽ� �ε��Ϸ��� '/%s' ��ɾ �����Ͻʽÿ�.", GetCmdName(CMD_LOADCONFIG));
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
	print( (READ_CINPUT)? ("[rcon] ��ɾ� �б� ����� Ȱ��ȭ �߽��ϴ�."):("[rcon] ��ɾ� �б� ����� ��Ȱ��ȭ �߽��ϴ�.") );
	#pragma unused params
	return 1;
} */
//==========================================================
rcmd_rcon(params[])
{
	if( isnull(params) )
	{
		print("[rcon] ���� : rcon [��ɾ�]");
		return 1;
	}
	printf("[rcon] RCON ��ɾ ���½��ϴ�. - %s", params);
	SendRconCommand(params);
	return 1;
}
//==========================================================
rcmd_checkupdate(params[])
{
	#pragma unused params
	#if !SAMP03b
		print("[rcon]���� ȣȯ ���� �������Դϴ�. ������Ʈ Ȯ�� ����� ����� �� �����ϴ�.");
	#else
		print("[rcon] �ֽ� ���� ���θ� �˻��մϴ�..");		
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

	if(!fexist(FILE_SETTINGS) || c_iniInt( "[General]", "�⺻�� ���"))
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
		/* ������ ���� */
		USE_PINGCHECK = 1;
		HIGHPING_LIMIT = 500;
		HIGHPING_WARN_LIMIT = 5;
		PINGCHECK_DURATION = 3;
		RESET_HIGHPING_TICK = 60;
		//READ_CINPUT = 1;
		ONFLOOD_CHAT = 0;
		ONFLOOD_CMD = 0;
		BADPLAYER_MESSAGE = "����� �� �������� �Ұ����� �ൿ���� �߹�� ���� �ֽ��ϴ�. �����Ͻʽÿ�.";
		USE_BADWARN = 1;
		ADMINCHAT_NAME = "* ��������(�ܼ�) :";
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
			print("[ERROR] RconController.ini�� ã�� �� �����ϴ�. �⺻���� �ε��մϴ�.\n[ERROR] ���� ����,�ο�� ��� �� �Ϻα���� ���ѵ˴ϴ�.");
			print("[ERROR] �����ذ��� ���� scriptfiles\\MINIMINI ������ RconController.ini�� �־��ּ���.");
			Wait(5000);
			return ;
		}
		else print("[rcon] ������ ���� ������ �⺻���� �ҷ��Խ��ϴ�.");
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
	/* ������ ���� */
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
	/* ������ ���� */
	if( HIGHPING_LIMIT < 1 ) HIGHPING_LIMIT = 500;
	if( HIGHPING_WARN_LIMIT < 0 ) HIGHPING_WARN_LIMIT = 5;
	if( PINGCHECK_DURATION < 1 ) PINGCHECK_DURATION = 3;
	if( RESET_HIGHPING_TICK < 0 ) RESET_HIGHPING_TICK = 60;
	//if( READ_CINPUT < 0 || READ_CINPUT > 1 ) READ_CINPUT = 1;
	if( USE_BADWARN < 0 || USE_BADWARN > 1 ) USE_BADWARN = 1;
	if( !BADPLAYER_MESSAGE[0]) BADPLAYER_MESSAGE = "����� �� �������� �Ұ����� �ൿ���� �߹�� ���� �ֽ��ϴ�. �����Ͻʽÿ�.";
	if( !ADMINCHAT_NAME[0] ) ADMINCHAT_NAME = "* ��������(�ܼ�) :";
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
		print("=============== ���� ���� ��å ====================");
		printf("����ÿ� ���� ��å ���� : %s",(SAVE_CURRRENT_CONFIG)? ("���"):("������"));
		if( DUMPEXIT == 0 ) print( "����ÿ� �޸� ���� ���� : ������" );
		else if( DUMPEXIT == 1 ) print( "����ÿ� �޸� ���� ���� : �⺻ ���� ����" );
		else print( "����ÿ� �޸� ���� ���� : ��ü ���� ����" );
		printf("���� ��� �̸� : \"%s\"", ADMINCHAT_NAME );
		//printf("Controller �Է±� : %s",(READ_CINPUT)? ("���"):("������"));
		printf("�ڵ� ����� : %s",(PERMANENT_ADMINSAY[ADMIN_ID])? ("���"):("������"));
		if( NOTICE_INTERVAL ) printf( "���� ��� : ���, ���� ���� : %d��", NOTICE_INTERVAL ); else print( "���� ��� : ������");
		if( USE_PINGCHECK ) printf("�� ���� ��� : ���(%d�ʸ���, %dms, %dȸ ����� �߹�)", PINGCHECK_DURATION, HIGHPING_LIMIT, HIGHPING_WARN_LIMIT );
		else print("�� ���� ��� : ������");
		if( USE_YELLFILTER ) printf( "������ : ���, ���� ���� : v%s, ���� �� : %d��", YELL_VER[1],num_Yells ); else print( "������ : ������");
		if( USE_ANTI_CHATFLOOD ) printf( "������� : ���(%d�ʿ� %d��, %d�ʰ� ��Ģ, %dȸ ���ݽ� %s)", CHATFLOOD_UNIT_TIME, CHATFLOOD_LIMIT, CHATFLOOD_SHUTUP_TIME, PMABUSE_LIMIT, (ONFLOOD_CHAT)? ("�����߹�"):("�߹�") );
		else print("������� : ������");
		if( USE_ANTI_CMDFLOOD ) printf( "��ɾ�� ���� : ���(%d�ʿ� %d��, %d�ʰ� ��Ģ, %dȸ ���ݽ� %s)", CMDFLOOD_UNIT_TIME, CMDFLOOD_LIMIT, CMDFLOOD_FORBIDDEN_TIME, CMDFLOOD_STILL_LIMIT, (ONFLOOD_CMD)? ("�����߹�"):("�߹�") );
		else print( "��ɾ�� ���� : ������");
		if( USE_BADWARN ) printf( "�ҷ����� ��� : ���(%-15s...)", BADPLAYER_MESSAGE ); else print( "�ҷ����� ��� : ������" );
		if( ALLOW_DESYNC == 1 ) printf( "������ : %d�ʱ����� ���", DESYNC_LIMIT );
		else if( ALLOW_DESYNC == 2 ) print("������ : ���");
		else print( "������ : ������� ����" );
		if( ENABLE_VOTEKICK ) printf( "�����߹� ��ǥ : ��� (�ʿ��ο� %d��, %d%%�̻� ����, %d�ʵ���)", REQUIRED_MAN_VOTEKICK, MINIMUM_VOTEKICK_PERCENTAGE, VOTEKICK_RUN_TIME );
		else print("�����߹� ��ǥ : ������");
		if( ENABLE_VOTEBAN ) printf( "�����߹� ��ǥ : ��� (�ʿ��ο� %d��, %d%%�̻� ����, %d�ʵ���)", REQUIRED_MAN_VOTEBAN, MINIMUM_VOTEBAN_PERCENTAGE, VOTEBAN_RUN_TIME );
		else print("�����߹� ��ǥ : ������");
		if( VOTE_CONFIDENTIALITY ) print("��ǥ�� �ſ���ȣ : ��"); else print("��ǥ�� �ſ���ȣ : �ƴϿ�");
		if( USE_ANTI_WEAPONCHEAT ) printf( "������ ���� : ���( %s, �������� %s )", (ONCHEAT_WEAPON)? ("�߹�"):("�����߹�"), c_iniGet("[Anticheat]", "FORBIDDEN_WEAPONS"));
		else print( "������ ���� : ������" );
		printf( "��Ʈ�� ��� : %s", (ALLOW_JETPACK)? ("���"):("������") );
		printf( "�缳 ���� ��� : %s", (ALLOW_PRIVATE_SPECTATE)? ("���"):("������") );
		printf( "���� ���� : %s", (USE_ANTI_MONEYCHEAT)? ("���"):("������") );
		print(LINE);
	}
	else SendClientMessage( playerid, COLOR_YELLOW, " * �غ����Դϴ�." );
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
	print("[rcon] ������ ���� ��å�� �����߽��ϴ�.");
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
			if( CONSOLE ) text = "           �ڼ��� ������ ������ ���� [��ɾ� �̸�] �� �Է��Ͻʽÿ�.";
			else
			{
				format( text, sizeof(text), "           �ڼ��� ������ ������ /%s [��ɾ� �̸�] �� �Է��Ͻʽÿ�.", GetCmdName(CMD_HELP) );
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
		case 3 .. (ceildiv(sizeof( cmdlist ), 6) + 2) : //�������� ���Ѵ�
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
			if( CONSOLE ) format( text, sizeof(text), "              Total %d Commands, (C) 2008 - 2013 CoolGuy(��Ծ���)", sizeof( cmdlist ) );
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
public ResetPingCheck() //������ �ʱ�ȭ
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
	format( str, sizeof(str), "* %s(%d)���� �����ϱ� �����մϴ�. ��ø� ��ٷ� �ּ���....", GetPlayerNameEx( giveplayerid ), giveplayerid );
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
			printf("[rcon] %s(%d)���� �������� ������ ��Ʈ���� ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i]);
			format( str, sizeof(str), "* %s(%d)���� �������� ������ ��Ʈ���� ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i]);
			SendClientMessageToAll( COLOR_RED, str );
			c_Kick(pITT[i]);
			continue;
		}

		if( GetPlayerState( pITT[i] ) == PLAYER_STATE_SPECTATING )
		{
			if( IsPlayerAdmin(pITT[i]) || IsPlayerSubAdmin(pITT[i]) ) PLAYER_DESYNCED_TIMES[pITT[i]] = 0;
			else if( !ALLOW_PRIVATE_SPECTATE && IS_PLAYER_SPECTATING[pITT[i]] == INVALID_PLAYER_ID )
			{
				printf("[rcon] %s(%d)���� �������� ������ ���ñ���� ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i]);
				format( str, sizeof(str), "* %s(%d)���� �������� ������ ���ñ���� ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i]);
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
				printf("[rcon] %s(%d)���� �������� ������ ���� %s��(��) ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i], str);
				format( str, sizeof(str), "* %s(%d)���� �������� ������ ���� %s��(��) ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i] , str);
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
					printf("[rcon] %s(%d)���� ���ѽð�(%d��) �̻� ����Ͽ� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT);
					format( str, sizeof(str), "* %s(%d)���� ���ѽð�(%d��) �̻� ESCŰ�� ���� �߹�˴ϴ�.", GetPlayerNameEx(pITT[i]), pITT[i], DESYNC_LIMIT );
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
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* ���� �ʹ� �����ϴ�. ���� ����ȭ�� ���� �߹��մϴ�. ��_ ��");
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* You have too high ping to play in my server. Sorry");
					format(str,sizeof(str),"* %s(%d)���� ���� �ʹ� ���� �߹��մϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
					SendClientMessageExceptPlayer(pITT[i],COLOR_GREENYELLOW,str);
					printf("[info] %s(%d)���� ���� �ʹ� ���� �߹��մϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
					c_Kick(pITT[i]);
					continue;
				}
				printf("[info] %s(%d)���� ���� %d��(��) �Ѿ����ϴ�. (%dȸ)",GetPlayerNameEx(pITT[i]),pITT[i],HIGHPING_LIMIT,HIGHPING_WARNED_TIMES[pITT[i]]);
				SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* ���! ���� �ʹ� �����ϴ�. ���ͳ� ȯ���� �����ϼ���.");
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
			{ // �ʰ� ������
				PLAYER_PUNISH_REMAINTIME[pITT[i]][j]-=1; // reduce
				if(PLAYER_PUNISH_REMAINTIME[pITT[i]][j]==0)
				{
					SendClientMessage(pITT[i],COLOR_GREENYELLOW,"* ��������: �����δ� �����Ͻñ� �ٶ��ϴ�.");
					switch(j)
					{
					case PUNISH_FREEZE:
						{
							TogglePlayerControllable(pITT[i],1);
							printf("[rcon] %s(%d)���� ������ ��Ģ���� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)���� ������ ��Ģ���� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_SHUTUP:
						{
							printf("[rcon] %s(%d)���� ä�ñ��� ��Ģ���� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)���� ä�ñ��� ��Ģ���� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
							SendAdminMessageAuth(AUTH_NOTICES,COLOR_GREY,str);
						}
					case PUNISH_CMDRESTRICT:
						{
							printf("[rcon] %s(%d)���� ��ɾ� ������ѿ��� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
							format(str,sizeof(str),"* %s(%d)���� ��ɾ� ������ѿ��� Ǯ�������ϴ�.",GetPlayerNameEx(pITT[i]),pITT[i]);
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
			else if( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] < 0 ) //ű�̳� ���ؾ� �Ѵٸ�
			{
				//���¸� ����
				switch ( PLAYER_PUNISH_REMAINTIME[pITT[i]][j] )
				{
					case KICK_THIS_PLAYER: //ű�̳�
					{
						GameTextForPlayer(pITT[i],"You are ~y~Kicked", 150000, 5);
						Kick(pITT[i]);
					}
					case BAN_THIS_PLAYER: //���� �Ѵ�
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
				if( VOTEKICK_PLAYER_GOT >= CURRENT_VOTEKICK_REQUIREMENT ) // �߹���� ���
				{
					format( str, sizeof(str), "* ��ǥ�� ����Ǿ����ϴ�. ��ǥ ����� %s(%d)���� ���� �߹��մϴ�.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ��ǥ ����� %s(%d)���� ���� �߹��մϴ�.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
					c_Kick( VOTEKICK_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* �ð��� �ʰ��Ǿ� %s(%d)�Կ� ���� �����߹��� �ݷ��˴ϴ�.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ��ǥ��� %s(%d)�� ���� �����߹��� �ݷ���.", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER );
					VOTEKICK_TICK = 0;
				}
	        }
			else if( VOTEKICK_TICK >= VOTEKICK_NOTIFY_DURATION )
			{
			    VOTEKICK_TICK = 0;
		 		format( str, sizeof(str), "* ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEKICK_PLAYER ), VOTEKICK_PLAYER, VOTEKICK_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", NUM_PLAYERS, VOTEKICK_PLAYER_GOT, CURRENT_VOTEKICK_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* ��ǥ�Ͻ÷��� /vkick yes �Ǵ� /ű �� ��(��) �Է��ϼ���." );
				printf("[rcon] �����߹� ��ǥ %s(%d): %d���� %d�� ����. (�����ð� %d��).", GetPlayerNameEx(VOTEKICK_PLAYER), VOTEKICK_PLAYER, NUM_PLAYERS, VOTEKICK_PLAYER_GOT, VOTEKICK_REMAINTIME );
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
				if( VOTEBAN_PLAYER_GOT >= CURRENT_VOTEBAN_REQUIREMENT ) // �߹���� ���
				{
					format( str, sizeof(str), "* ��ǥ�� ����Ǿ����ϴ�. ��ǥ ����� %s(%d)���� ������ �߹��մϴ�.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ��ǥ ����� %s(%d)���� ������ �߹��մϴ�.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
					c_Ban( VOTEBAN_PLAYER );
				}
				else
				{
				    format( str, sizeof(str), "* �ð��� �ʰ��Ǿ� %s(%d)�Կ� ���� �����߹��� �ݷ��˴ϴ�.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					SendClientMessageToAll( COLOR_GREENYELLOW, str );
					printf("[rcon] ��ǥ��� %s(%d)�� ���� �����߹��� �ݷ���.", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER );
					VOTEBAN_TICK = 0;
				}
	        }
			else if( VOTEBAN_TICK >= VOTEBAN_NOTIFY_DURATION )
			{
			    VOTEBAN_TICK = 0;
		 		format( str, sizeof(str), "* ���� %s(%d)�Կ� ���� �����߹� ��ǥ�� �������Դϴ�. (���� �ð� : %d��)", GetPlayerNameEx( VOTEBAN_PLAYER ), VOTEBAN_PLAYER, VOTEBAN_REMAINTIME );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				format( str, sizeof(str), " �� %d���� %d���� ����ǥ�� ��������, %d�� �̻��� �����ϸ� �߹�˴ϴ�.", NUM_PLAYERS, VOTEBAN_PLAYER_GOT, CURRENT_VOTEBAN_REQUIREMENT );
				SendClientMessageToAll( COLOR_GREENYELLOW, str );
				SendClientMessageToAll( COLOR_SALMON, "* ��ǥ�Ͻ÷��� /vBAN yes �Ǵ� /�� �� ��(��) �Է��ϼ���." );
				printf("[rcon] �����߹� ��ǥ %s(%d): %d���� %d�� ����. (�����ð� %d��).", GetPlayerNameEx(VOTEBAN_PLAYER), VOTEBAN_PLAYER, NUM_PLAYERS, VOTEBAN_PLAYER_GOT, VOTEBAN_REMAINTIME );
			}
	    }
	}
}
//==========================================================
#if SAMP03a
//==========================================================
ShowPlayerDialogs( playerid, dialogid ) //����ڿ��� ��ȭ���� ����
{
    new str[1024];
	switch( dialogid )
	{
	    case DIALOG_ADMIN_MAIN :
	    {
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n�޼��� ������\r\n���\r\n��ȯ\r\n���\r\nü�� ����\r\n�������� �����\r\n\
				������ �ֱ�\r\n������ ����\r\n������ �����ϱ�\r\n���ھ� �����ϱ�\r\n���� ����\r\n\
				���� ����\r\n������\r\n������ ����\r\n�Ƹ� ����\r\n�Ƹ� ����\r\n���� ��ȯ\r\n������ �������ϱ�\r\n\
				�������� ����\r\n��Ʈ�� �ֱ�\r\n���� ���\r\n������� ���� ����\r\n�� ��Ʈ����\r\n\
				ä�� ����\r\nä�ñ��� ����\r\n�г��� �ٲٱ�\r\n�� �÷��̾� ����\r\n�ο�ڷ� �Ӹ�\r\n����� ��Ż\r\n\
				�� ������ ���� ����",
				"Ȯ��", "���" );
		}
		case DIALOG_ADMIN_KICK :
		{
		    format( str, sizeof(str), "���� �÷��̾ �߹��մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KICK, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_BAN :
		{
		    format( str, sizeof(str), "���� �÷��̾ ������ �߹��մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BAN, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_WITH :
		{
		    format( str, sizeof(str), "���� �÷��̾�� �̵��մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_WITH, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_CALL :
		{
		    format( str, sizeof(str), "���� �÷��̾ ��ȯ�մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CALL, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_KILL :
		{
		    format( str, sizeof(str), "���� �÷��̾ ����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_KILL, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SETHP :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ü���� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETHP, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_INFINITE :
		{
		    format( str, sizeof(str), "���� �÷��̾ �������� ����ϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFINITE, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_MAKECASH :
		{
		    format( str, sizeof(str), "���� �÷��̾�� �������� ����ݴϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MAKECASH, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_FORFEIT :
		{
		    format( str, sizeof(str), "���� �÷��̾��� �������� ��Ż�մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FORFEIT, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SETCASH :
		{
		    format( str, sizeof(str), "���� �÷��̾��� �������� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETCASH, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SETSCORE :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ���ھ �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SETSCORE, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_GIVEWP :
		{
			for( new i = 0 ; i < sizeof(WEAPON_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, WEAPON_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s�ٸ� ����..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_GIVEWP, DIALOG_STYLE_LIST, "������ ���⸦ �����Ͻʽÿ�.", str, "����", "�ڷ�" );
		}
		case DIALOG_ADMIN_DISARM :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ���⸦ ��Ż�մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DISARM, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_FREEZE :
		{
		    format( str, sizeof(str), "���� �÷��̾ �����ð� ����Ӵϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FREEZE, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_UNFREEZE :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ����� Ǯ���ݴϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNFREEZE, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
 		case DIALOG_ADMIN_ARMOR :
		{
		    format( str, sizeof(str), "���� �÷��̾��� �ƸӸ� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_ARMOR, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
 		case DIALOG_ADMIN_INFARMOR :
		{
		    format( str, sizeof(str), "���� �÷��̾��� �ƸӸ� �������� ����ϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_INFARMOR, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SPAWNCAR :
		{
	    	for( new i = 0 ; i < sizeof(VEHICLE_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, VEHICLE_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s�ٸ� ����..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPAWNCAR, DIALOG_STYLE_LIST, "������ ������ �����Ͻʽÿ�", str, "����", "�ڷ�" );
		}
		case DIALOG_ADMIN_SDROP :
		{
		    format( str, sizeof(str), "���� �÷��̾ ������ ������ �մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SDROP, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_CARENERGY :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ���������� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CARENERGY, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_JETPACK :
		{
		    format( str, sizeof(str), "���� �÷��̾�� ��Ʈ���� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_JETPACK, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_MUSIC :
		{
	    	for( new i = 0 ; i < sizeof(MUSIC_STORAGE) ; i++ )
				format( str, sizeof(str), "%s%s\r\n", str, MUSIC_STORAGE[i][weaponname] );
			format( str, sizeof(str), "%s�ٸ� ����..", str);
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSIC, DIALOG_STYLE_LIST, "����� ������ �����Ͻʽÿ�", str, "����", "�ڷ�" );
		}
		case DIALOG_ADMIN_MUSICOFF :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ������� ������ �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_MUSICOFF, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_BOMB :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ���� ��Ʈ���ϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_BOMB, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SHUTUP :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ä���� �����ð� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SHUTUP, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_UNSHUT :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ä�ñ����� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_UNSHUT, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_CHANGENICK :
		{
		    format( str, sizeof(str), "���� �÷��̾��� �г����� �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_CHANGENICK, DIALOG_STYLE_INPUT, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_SPECTATE :
		{
		    format( str, sizeof(str), "���� �÷��̾ �����մϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SPECTATE, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}		
		case DIALOG_ADMIN_SUBADMIN :
		{
			new tmp[128];
			str="��� ����";
			for(new i=1;i<32;i++)
			{
				format(tmp,sizeof(tmp),"Auth_Profile%d",i);
				set( tmp, c_iniGet("[SubAdmin]",tmp) );
				if( !tmp[0] ) break;
				format( str, sizeof(str), "%s\r\n%s", str, tmp );
			}
			ShowPlayerDialog( playerid, DIALOG_ADMIN_SUBADMIN, DIALOG_STYLE_LIST, "�ش� �÷��̾�� �ο��� ������ �����Ͻʽÿ�.", str, "����", "�ڷ�" );
		}
		case DIALOG_ADMIN_DELSUB :
		{
			format( str, sizeof(str), "%s(%d)����  �ο�� ������ ��Ż�մϴ�.\r\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_DELSUB, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_ADMIN_FIND :
		{
		    format( str, sizeof(str), "���� �÷��̾��� ������ ���ϴ�: %s(%d).\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_ADMIN_FIND, DIALOG_STYLE_MSGBOX, "����Ͻðڽ��ϱ�?", str, "��", "�ƴϿ�" );
		}
		case DIALOG_PM :
		{
 		    format( str, sizeof(str), "%s(%d)�Կ��� ���� �޼����� �Է��Ͽ� �ֽʽÿ�.",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_PM, DIALOG_STYLE_INPUT, "�޼��� ������", str, "������", "�ڷ�" );
		}
		case DIALOG_USER_MAIN :
		{
			format( str, sizeof(str), "Rcon Controller - %s(%d)", GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_MAIN, DIALOG_STYLE_LIST, str,
				"Kick player\r\nBan player\r\n�޼��� ������",
				"Ȯ��", "���" );
		}
		case DIALOG_USER_VOTEKICK :
		{
		    format( str, sizeof(str), "%s(%d)���� �߹��� ��û�մϴ�.\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEKICK, DIALOG_STYLE_MSGBOX, "�����߹� ��ǥ", str, "��", "�ƴϿ�" );
		}
		case DIALOG_USER_VOTEBAN :
		{
			format( str, sizeof(str), "%s(%d)���� �����߹��� ��û�մϴ�.\n����Ͻðڽ��ϱ�?",
				GetPlayerNameEx(DIALOG_CLICKED_PLAYER[playerid]), DIALOG_CLICKED_PLAYER[playerid] );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "�����߹� ��ǥ", str, "��", "�ƴϿ�" );
		}		
		default:
		{
			format( str, sizeof(str), "������ �ֽ��ϴ�. DIALOG_ID : %d", dialogid );
			ShowPlayerDialog( playerid, DIALOG_USER_VOTEBAN, DIALOG_STYLE_MSGBOX, "���� �߰�!", str, "����", "����" );
		}
	}
	return 1;
}
//==========================================================
public Firstrun()
{
	print(LINE);
	print("\n[rcon] ó�� ����Ͻô±���! ���� �������� ���������� �����ִ� ��ũ��Ʈ�Դϴ�.");
	print("[rcon] �⺻������ ���Դ� ��ȭ�� ��ɾ� �� ���ϵ�ī�� ����� �ֽ��ϴ�.");
	printf("[rcon] ���� ��ɾ�� '%s player1 10000' ������ �Է��ϴµ���,", GetCmdName(CMD_MCASH));
	printf("[rcon] ��ɾ '%s ?' �� �Է��ϸ� ��ɾ ���� ����� �� �ֽ��ϴ� ^.^", GetCmdName(CMD_MCASH));
	print("[rcon] �� player1�� �� �ڸ��� '*'�� '!', '~'�� �Է��� ���� �ִµ���.");
	print("[rcon] '*'�� '��� ���', '!'�� '���� ������ �ִ� ���', '~'�� '���������� ä���� ���'�� �ǹ��ؿ�.");
	printf("[rcon] ���� ���, '%s * 1000' �̶�� ���� ��� ������� 1000�޷��� �ִ°���.", GetCmdName(CMD_MCASH));
	printf("[rcon] ��Ÿ ���� ����� ���÷��� '%s' �� �Է��ϼ���. �ȳ�!\n", GetCmdName(CMD_HELP));	
	print(LINE);
}
//==========================================================
#endif /* SA-MP 0.3a�� ���̾�α� ��� ��� */
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
		SendClientMessage( playerid, COLOR_GREY, "* ���� ������ �ִ� ����ڸ� ã���ϴ�.." );
		return GetClosestPlayer( playerid );
	}
	else if(params[0] == '?'  )
	{
		if ( !params[1] ) return INTERACTIVE_MANAGEMENT; //interactive management
		else if ( params[1] == '?' && !params[2] ) return HELP_PROCESS;
	}
	else if( checkadmin && (!strcmp( params, "Admin", true ) || !strcmp( params, "���", false)) ) return ADMIN_ID;
	return INVALID_PLAYER_ID;
}
//==========================================================
Post_Process( playerid, giveplayerid, Cmdorder:CMD_CURRENT, bool: process_interactive =true )
{
	//������ giveplayerid�� ��ɾ� ����
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
			if( CONSOLE ) print("[rcon] �ֿܼ����� ����� �� �����ϴ�.");
			else SendClientMessage( playerid, COLOR_GREY, "* ����� ���� ����� �� �����ϴ�.");
			return PROCESS_COMPLETE;
		}
		case INVALID_PLAYER_ID: //Processed Invalid input
		{
			if(CONSOLE) print("[rcon] �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
			else SendClientMessage(playerid,COLOR_GREY,"* �߸� �Է��ϼ̰ų� ���� �������� �ƴմϴ�.");
			return PROCESS_COMPLETE;
		}
		case INTERACTIVE_MANAGEMENT: //Wildcard '?" enabled
		{
			if( process_interactive )
			{
				if( CONSOLE )
				{
					dcmd_stat ( playerid, NULL, CMD_STAT, NO_HELP );
					print("[rcon] ���ϴ� �÷��̾ �Է��Ͻʽÿ�. ����Ϸ��� ?�� �Է��Ͻʽÿ�." );
				}
				else
				{
					#if SAMP02X
						dcmd_stat( playerid, NULL, CMD_STAT, NO_HELP );
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* ���ϴ� �÷��̾ �Է��Ͻʽÿ�. ����Ϸ��� ?�� �Է��Ͻʽÿ�." );
					#else
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* TAB�� ������ ���ϴ� �÷��̾ ����Ŭ�� �Ͻʽÿ�. ���ϵ�ī�带 �� ���� �ֽ��ϴ�.");
						SendClientMessage( playerid, COLOR_GREENYELLOW, "* ����Ϸ��� ?�� �Է��Ͻʽÿ�." );
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
		printf("[rcon] ����: %s or %s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME, CURRENT_PARAMS);
		printf("[rcon] �ڼ��� ������ ���� %s ��(��) �Է��ϼ���.", CURRENT_CMD_NAME );
	}
	else
	{
		format( str, sizeof(str), "* ����: /%s or /%s %s", CURRENT_CMD_NAME, CURRENT_CMD_ALTER_NAME,  CURRENT_PARAMS);
		SendClientMessage(playerid, COLOR_GREY, str );
		format( str, sizeof(str), "* �ڼ��� ������ /%s %s ��(��) �Է��ϼ���.", GetCmdName(CMD_HELP), CURRENT_CMD_NAME );
		SendClientMessage(playerid, COLOR_GREY, str );
	}
	return 1;
}
//==========================================================
#if SAMP03b
//==========================================================
public UpdateCheck(index, response_code, data[])
{
	//debugprintf("[rcon] �ڵ�: %d", response_code);
	//debugprintf("[rcon] data: %s",data);
	switch(response_code)
	{
		case HTTP_ERROR_CANT_CONNECT:
		{
			printf("[rcon] ������Ʈ ������ ������ �� �����ϴ�.");
			return 1;
		}
		case 200: {}
		default:
		{
			printf("[rcon] ������Ʈ Ȯ�ο� �����߽��ϴ�. ���� �ڵ�: %d", response_code);
			return 1;
		}
	}

	new version, vstring[128], rdate[128];	
	if( sscanf( data, "p,iss", version, vstring, rdate ) )
	{
		print("[rcon] ������Ʈ Ȯ�ο� �����߽��ϴ�. ������ ���ƽ��ϴ�...�Ф�");
		return 1;
	}
	
	if( version <= VERSION_INTERNAL )
	{
		printf("[rcon] ���� �ֽ� ������ ����ϰ� �ֽ��ϴ�.");
		return 1;
	}	
	printf("[rcon] ������Ʈ ������ ������ �ֽ��ϴ�.\n  \
			***********************************\n  \
			* ���� ����: %-12s         *\n  \
			* �ֽ� ����: %-12s         *\n  \
			* ������ ��¥ : %s        *\n  \
			***********************************", VERSION, vstring, rdate );
	print("[rcon] cafe.daum.net/Coolpdt�� �湮�Ͽ� �ֽ� ������ �ٿ�ε�����ñ� �ٶ��ϴ�.");
	//�ֽ� ������ ������ ����, ����Ʈ ������ ��´�.
	//new tmp[256];
	//format( tmp, sizeof(tmp), "dl.dropbox.com/u/8120060/SA-MP/%d/index.txt", version );
	//HTTP( UPDATE_FILELIST, HTTP_GET,  tmp, "", "UpdateCheck");
	return 1;
}
//==========================================================
#endif /* SA-MP 0.3b�� ������Ʈ ��� ��� */
//==========================================================
CreateDump()
{
	new File:hnd = fopen( FILE_DUMP, io_write ), str[512];
	if( !hnd )
	{
		print("[rcon] ���� ������ �����߽��ϴ�.");
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
		CURRENT_VOTEKICK_REQUIREMENT,//��ǥ ��ÿ� �ʿ��� �����ο�
		CURRENT_VOTEBAN_REQUIREMENT,//��ǥ ��ÿ� �ʿ��� �����ο�
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
	
	//��ǥ�� �������̾��� ��� �ߺ���ǥ �˻簪 �����ϱ�
	if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
	{
		for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
		{
			c_fwrite( hnd, RetStr(KICKVOTED_PLAYER_IP[i]) );
		}
	}
	//��ǥ�� �������̾��� ��� �ߺ���ǥ �˻簪 �����ϱ�
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
		//print("[rcon] ��ü ������ �������Դϴ�...");
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
	//print("[rcon] ���� ������ �Ϸ��߽��ϴ�.");
}
//==========================================================
CallDump()
{
	new File:hnd = fopen( FILE_DUMP, io_read ), str[512], idx, FULLDUMP;
	if( !hnd ) print("[rcon] ���� �̽Ŀ� �����߽��ϴ�.");
	else
	{
		fread( hnd, str );
		StripNL( str );
		if( tickcount() - strval( str ) > 1000 || tickcount() - strval( str ) < 0 ) print("[rcon] ���� ������ ���� �̽����� �ʰ� ����մϴ�.");
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
			
			ENABLE_VOTEKICK = strval(strtok( str, idx, ',' ));//��ǥ Ȱ��ȭ
			ENABLE_VOTEBAN = strval(strtok( str, idx, ',' ));
			VOTEKICK_RUN_TIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_RUN_TIME = strval(strtok( str, idx, ',' )); //��ǥ ������ �ð�
			VOTEKICK_NOTIFY_DURATION = strval(strtok( str, idx, ',' ));
			VOTEBAN_NOTIFY_DURATION = strval(strtok( str, idx, ',' )); // ��ǥ��Ȳ ���� �ֱ�
			VOTE_CONFIDENTIALITY = strval(strtok( str, idx, ',' )); // ��ǥ �Ű��� ��ÿ���
			REQUIRED_MAN_VOTEKICK = strval(strtok( str, idx, ',' ));
			REQUIRED_MAN_VOTEBAN = strval(strtok( str, idx, ',' ));// �����߹��� ������ �ּ��ο�
			MINIMUM_VOTEKICK_PERCENTAGE = strval(strtok( str, idx, ',' )); // �����߹���� �ʿ��� ��ǥ��
			MINIMUM_VOTEBAN_PERCENTAGE = strval(strtok( str, idx, ',' ));
			
			VOTEKICK_PLAYER = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER = strval(strtok( str, idx, ',' )); //��� �÷��̾� ���̵�
			VOTEKICK_PLAYER_GOT = strval(strtok( str, idx, ',' ));
			VOTEBAN_PLAYER_GOT = strval(strtok( str, idx, ',' ));	//���� ǥ
			VOTEKICK_REMAINTIME = strval(strtok( str, idx, ',' ));
			VOTEBAN_REMAINTIME = strval(strtok( str, idx, ',' )); //���� �ð�
			CURRENT_VOTEKICK_REQUIREMENT = strval(strtok( str, idx, ',' ));//��ǥ ��ÿ� �ʿ��� �����ο�
			CURRENT_VOTEBAN_REQUIREMENT = strval(strtok( str, idx, ',' ));//��ǥ ��ÿ� �ʿ��� �����ο�
			VOTEKICK_TICK = strval(strtok( str, idx, ',' )); // �����߹� ���� ������ Ÿ�̸�
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
			
			//��ǥ�� �������̾��� ��� �ߺ���ǥ �˻簪 �ҷ�����
			if( ENABLE_VOTEKICK && VOTEKICK_REMAINTIME > 0 )
			{
				for( new i = 0; i < VOTEKICK_PLAYER_GOT; i++ )
				{
					fread( hnd, str );
					StripNL( str );
					KICKVOTED_PLAYER_IP[i] = strval(str);//�ߺ���ǥ ������ IP�����
				}
			}
			//��ǥ�� �������̾��� ��� �ߺ���ǥ �˻簪 �ҷ�����
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
				//print("[rcon] ��ü ������ �̽����Դϴ�...");
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
			//print("[rcon] ���� �̽��� �Ϸ��߽��ϴ�.");
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
		print("[ERROR] RC_yell.ini�� ã�� �� �����ϴ�. ������ ����� ���ѵ˴ϴ�.");
		print(" scriptfiles\\MINIMINI ������ RC_yell.ini�� �־��ּ���.");
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
	print("[rcon] ������ �ٽ� ��ݻ��·� �����Ǿ����ϴ�.");
}
//==========================================================
IsCmdNeedToHide(cmd[])
{
	static hidecmds[][]=
	{
		"/�ο�α���",
		"/sublogin",
		"/log",
		"/reg",
		"/�α���"
	};
	for(new i=0;i<sizeof(hidecmds);i++) if(!strcmp(cmd,hidecmds[i],true,strlen(hidecmds[i]))) return 1;
	return 0;
}
//==========================================================
LoadPlayerAuthProfile(playerid,profile_id)
{
	if(profile_id == 0) //�⺻ ����: ��� ����
	{
		for(new i = 2 ; i < NUM_AUTH ; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 1;
		SendClientMessage(playerid,COLOR_IVORY,"* ���� '��� ����'(0)�� �־������ϴ�.");
		return true;
	}
	for( new i = 2; i < NUM_AUTH; i++) PLAYER_AUTHORITY[playerid][Authinfo:i] = 0;
	new i = 2,File:fhnd,str[MAX_STRING];
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	str=join("MINIMINI/",c_iniGet("[SubAdmin]",str));
	if(!fexist(str))
	{
		format(str,sizeof(str),"* RconController.ini�� Auth_Profile%d�� ��ϵ� ������ ã�� �� �����ϴ�.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] RconController.ini�� Auth_Profile%d�� ��ϵ� ������ ã�� �� �����ϴ�.",profile_id);
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
		format(str,sizeof(str),"* ���� ������ %d���� �̻��� �ֽ��ϴ�. ������ Ȯ�����ּ���.",profile_id);
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
		printf("[rcon] ���� ������ %d���� �̻��� �ֽ��ϴ�. ������ Ȯ�����ּ���.",profile_id);
	}
	format(str,sizeof(str),"Auth_Profile%d",profile_id);
	format(str,sizeof(str),"* ���� %s(%d)�� �־������ϴ�.",(profile_id)? (c_iniGet("[SubAdmin]",str)):("��� ����"),profile_id);
	SendClientMessage(playerid,COLOR_IVORY,str);
	return true;
}
//==========================================================
CheckNoticeList()
{
	Num_Notice=0;
	new File:fhnd, str[256], line;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//������ ���۵ɶ����� ���� ��ŵ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===���� ����===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//�� �ڸ���, �ּ��� �ܼ����ʹ� ��ŵ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//������ ���� ���		
		if( !strcmp( str, "===���� ��===" ) )
		{
			if( line ) Num_Notice++;
			break;
		}
		line++;		
		//���м��� ���� ���
		if( !strcmp( str, "===���м�===" ) )
		{
			Num_Notice++;
			continue;
		}
		//�������� Ȯ��
		if( str[0] == '<' && strfind( str, ">" ) == -1 )
		{
			printf( "[rcon] ���� ������ ������ �ֽ��ϴ�! ������ ������� �ʽ��ϴ�.\n ���� ���� : %s", str);
			format( str, sizeof(str), "* ���� ������ ������ �ֽ��ϴ�! ������ ������� �ʽ��ϴ�.\n ���� ���� : %s", str);
			SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,str);
			NOTICE_INTERVAL = 0;
			break ;
		}
	}	
	fclose(fhnd);
	//������ ���� ���
	if( Num_Notice == 0 )
	{
		printf( "[rcon] ������ �����ϴ�. ���� ����� ��Ȱ��ȭ�մϴ�.");
		SendAdminMessageAuth(AUTH_NOTICES,COLOR_IVORY,"* ������ �����ϴ�. ���� ����� ��Ȱ��ȭ�մϴ�.");
		NOTICE_INTERVAL = 0;
	}
}
//==========================================================
SendPlayerNotice(index)
{
	new File:fhnd, curidx = 1, str[256], color, stridx;
	fhnd=fopen(FILE_SETTINGS,io_read);
	//������ ���۵ɶ����� ���� ��ŵ
	while( fread( fhnd, str ) )
	{
		if( str[0] == '=' && str[1] == '=' )
		{	
			StripNL( str );
			if( !strcmp( str, "===���� ����===" ) ) break;
		}
	}
	while( fread( fhnd, str ) )
	{
		//�� �ڸ���, �ּ��� �ܼ����ʹ� ��ŵ
		StripNL( str );
		if(str[0] == '#' || !str[0] ) continue;
		//������ ���� ��� ��ũ��Ʈ ����
		if( !strcmp( str, "===���� ��===" ) ) break;
		//���м��� ���� ���
		if( !strcmp( str, "===���м�===" ) ) 
		{
			if( curidx == index ) break; //������ �ø��� ���̾��� ��� ����
			curidx++; //�ε��� ����
			continue;
		}
		//�ε����� ������ ������ ����
		if( curidx != index ) continue;
		/* ��Ƽ���� ������ �д´� */
		stridx = 0; //�⺻�� ����
		color = COLOR_LIGHTBLUE;
		if( str[0] == '<' ) //���� �ڵ鷯 Ȯ��
		{
			//������ﶧ�� �ε��� ����
			stridx = strfind( str, ">" ) + 1;
			str[stridx-1] = EOS;
			//HEX���� ��� ���� ����
			if( str[1] == '0' && str[2] == 'x' ) color = HexToInt( str[1] );
			//�̸� ������ ����
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_RED;
			else if ( !strcmp( str[1], "�Ķ�" ) ) color = COLOR_BLUE;
			else if ( !strcmp( str[1], "���� �Ķ�" ) ) color = COLOR_LIGHTBLUE;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_YELLOW;
			else if ( !strcmp( str[1], "��ũ" ) ) color = COLOR_PINK;
			else if ( !strcmp( str[1], "������ũ" ) ) color = COLOR_LIGHTPINK;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_GREEN;
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_LIME;
			else if ( !strcmp( str[1], "���" ) ) color = COLOR_WHITE;
			else if ( !strcmp( str[1], "�ý���" ) ) color = COLOR_SYSTEM;
			else if ( !strcmp( str[1], "ȸ��" ) ) color = COLOR_GREY;
			else if ( !strcmp( str[1], "����" ) ) color = COLOR_BROWN;
			else if ( !strcmp( str[1], "û�ϻ�" ) ) color = COLOR_TEAL;
			else if ( !strcmp( str[1], "������" ) ) color = COLOR_ORANGE;
		}
		//���� ����
		printf("[rcon] ���� - %s", str[stridx] );
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
//If ������ �ɷ��ִ°�� - SubAdmin ���˾���
#define dcmd_auth(%1,%2,%3,%4) \
	if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32)&& \
	(((CONSOLE||IsPlayerAdmin(playerid)||AuthorityCheck(playerid,%4))&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))|| \
	(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid,COLOR_RED,"* �ش� ��ɾ ����� ������ �����ϴ�."))) return 1
//If ������ �ɷ������ʴ°�� - SubAdmin ������
#define dcmd_auth(%1,%2,%3,%4) if(strcmp(cmdtext[1],(%1),true,(%2))==0&&(cmdtext[(%2)+1]==0||cmdtext[(%2)+1]==32) \
	&&((AuthorityCheck(playerid,%4)&&((cmdtext[(%2)+1]==0&&dcmd_%3(playerid,""))||(cmdtext[(%2)+1]==32&&dcmd_%3(playerid,cmdtext[(%2)+2]))))||SendClientMessage(playerid, COLOR_RED, "* �ش� ��ɾ ����� ������ �����ϴ�."))) return 1
*/


