/*
 *            Coolguy's functions v3.7
 *       (c) Copyright 2007-2008 CoolGuy
 *
 * author    :  밥먹었니 (cafe.daum.net/Coolpdt)
 * date      : 2007/03/20
 * Last update  : 2009/04/27
 * require :
 *
 * This file is provided as is (no warranties).
 * 
 *
-*---------------------------------------------------------------------------------------------------------------------
USAGE
	1. Type Some compile options if you need.
	2. Type #include <coolguy> last of your includes.

Compile Options
	#define _COOLGUY_NO_COLOR : Don't Use CoolGuy's Color Collection.
	#define _COOLGUY_NO_COMPRESS : Don't Use Compression Support.
	#define _COOLGUY_NO_ENCRYPT : Don't Use Encryption Support.
	#define _COOLGUY_NO_INI : Don't Use INI Support.
	#define _COOLGUY_NO_FILE : Don't Use File Support.
	#define _COOLGUY_NO_PLAYER : Don't Use Game & Player Support.
	#define _COOLGUY_NO_MATH : Don't Use Number & Calc Support.
	#define _COOLGUY_NO_SUBADMIN : Don't use Sub-admin Support.

Special Thanks To  
	 Y_LESS(thx very much, i copied some of his YSI interface)
	
Functions List :

native __ARGUMENT__();
	native
native GetArgString(arg,dest[]);
	native
native __CONVERT__();
	native
native RetStr(val);
native strfloat(Float:value);
native intfloat(Float:val);
	native
native __STRINGHANDLE__();
	native
native isHangulExists(const strings[]);
native str_left(source[],len);
native str_right(source[], len);
native join(string1[],string2[]);
native medium(source[],start,end);
native stringslice(const string[],stringindex,separator=' ');
native StripNL(str[]);
native isnull(string[]);
native sscanf(string[], format[], {Float,_}:...);
native CharPos(string[],character,index=1);
native FixChars(string[]);
native IsValidIP( IP[] );
	native
native __FILECONTROL__();
	native
native fcreate(filename[]);
native fsize(filename[]);
native c_fwrite( File:handle, const string[] );
	native
native __GAME&PLAYER__();
	native
native SendFormatMessage(playerid,COLOR,text[],{Float,_}:...);
native SendFormatMessageToAll(COLOR,text[],{Float,_}:...);
native PlayerName(playerid);
native Float:PlayerHealth(playerid);
native Float:PlayerArmour(playerid);
native PlayerIP(playerid);
native IsPartOfName(partofname[],playerid);
native GetClosestPlayerID(partofname[]);
native SendClientMessageExceptPlayer(id,COLOR,const text[]);
native wiper(...);
native wiperToAll();
native Eraser(lines,...);
native EraserToAll(lines);
native SetVehiclePosEx(vehicleid, Float:x, Float:y, Float:z);
native Kill(playerid);
native PlaySoundForPlayer(playerid,soundid);
native PlaySoundForAll(soundid);
native StopSoundForPlayer(playerid);
native StopSoundForAll();
native Num_Players();
	native
native __SUBADMIN__();
	native
native IsPlayerSubAdmin(playerid);
native SetPlayerSubAdmin(playerid);
native UnSetPlayerSubAdmin(playerid);
native ResetAllSubAdmins();
native SendAdminMessage(COLOR,text[],bool:tosubadmin=false);
native Num_SubAdmins();
native SubAdminMessage(COLOR,string[]);
	native
native __ENCRYPTION__();
	native
native coolguy_hash(buf[]);
native coolguy_checksum(buffer[],mod = 65521);
native bernstein(string[]);
native xencrypt(string[],enc[]);
native xdecrypt(string[],enc[]);
native encrypt(string[]);
	native
native __INI__();
	native
native c_iniOpen( file[], filemode:mode = io_readwrite );
native c_iniClose( );
native c_iniSet( header[], key[], value[] );
native c_iniIntSet( header[], key[], value );
native c_iniFloatSet( header[], key[], Float:value );
native c_iniBoolSet( header[], key[],bool:value );
native c_iniGet( header[], key[] );
native c_iniInt( header[], key[] );
native Float:c_iniFloat( header[], key[] );
native bool:c_iniBool( header[], key[] );
native c_iniUnSet( header[], key[] );
native c_iniIsSet( header[], key[] );
native c_iniIsHeader( header[] );
native INI_Set( file[], header[], key[], value[] );
native INI_IntSet(file[],header[],key[],value);
native INI_FloatSet(file[],header[],key[],Float:value);
native INI_BoolSet(file[],header[],key[],bool:value);
native INI_Get( file[], header[], key[] );
native INI_Int(file[],header[],key[]);
native Float:INI_Float(file[],header[],key[]);
native bool:INI_Bool(file[],header[],key[]);
native INI_UnSet(file[],header[],key[]);
native INI_IsSet(file[],header[],key[]);
native INI_IsHeader(file[],header[]);
native INI_Add(file[],header[],key[],value=1);
native INI_Sub(file[],header[],key[],value=1);
native INI_FloatAdd(file[],header[],key[],Float:value=1.000000);
native INI_FloatSub(file[],header[],key[],Float:value=1.000000);
	native
native __COMPRESSION__();
	native
native ceildiv(dividend, devisor);
native Bit_Bits(num);
native Bit_Get(Bit:array[], slot);
native Bit_Let(Bit:array[], slot);
native Bit_Vet(Bit:array[], slot);
native Bit_Set(Bit:array[], slot);
native Bit_SetAll(Bit:array[], set, size = sizeof (array));
native Bit_GetCount(Bit:array[], size = sizeof (array));
native Bit_Reverse(Bit:array[], slot);
native Bit_ReverseAll(Bit:array[], size = sizeof (array));
	native
native __CALCULATION__();
	native
native minrand(min,max);
native TwoWayRand(value);
native Float:floatrand(max,depth=6);
native Float:MinFloatrand(Float:min,Float:max);
native Float:TwoWayFloatrand(Float:max);
	native
native __ETC__();
	native
native Beep();
native Wait(time);
native Crash();

----------------------------------------------------------------------------------------------------------------------*/
//==========================================================
// Defines
//==========================================================
/* Dependencies */
#if defined MAX_STRING
	#undef MAX_STRING
#endif
#define MAX_STRING 256

/* Colors */
#if !defined _COOLGUY_NO_COLOR
#define COLOR_RED 0xFF000096
#define COLOR_LIGHTRED 0xFF0000AA
#define COLOR_DARKRED 0xA6000096
#define COLOR_INDIANRED 0xCD5C5CAA
#define COLOR_PALEVIOLETRED 0xDB7093AA
#define COLOR_MEDIUMVIOLETRED 0xC71585AA
#define COLOR_ORANGE 0xFF9900AA
#define COLOR_ORANGERED 0xFF4500AA
#define COLOR_SALMON 0xFA8072AA
#define COLOR_LIGHTSALMON 0xFFA07AAA
#define COLOR_MAGENTA 0xFF00FFFF
#define COLOR_MEDIUMMAGENTA  0x8B008BAA
#define COLOR_DARKMAGENTA 0x8B008BAA
#define COLOR_CORAL 0xFF7F50AA
#define COLOR_LIGHTCORAL 0xF08080AA
#define COLOR_GOLDENROD 0xDAA520AA
#define COLOR_PALEGOLDENROD 0xEEE8AAAA
#define COLOR_DARKGOLDENROD 0xB8860BAA
#define COLOR_PINK 0xFFC0CBAA
#define COLOR_DEEPPINK 0xFF1493AA
#define COLOR_HOTPINK 0xFF69B4AA
#define COLOR_LIGHTPINK 0xFFB6C1AA
#define COLOR_VIOLET 0xEE82EEFF
#define COLOR_DARKVIOLET 0x9400D3AA
#define COLOR_BLUEVIOLET 0x8A2BE2AA
#define COLOR_PLUM 0xDDA0DDAA
#define COLOR_CRIMSON 0xDC143CAA
#define COLOR_THISTLE 0xD8BFD8FF
#define COLOR_TOMATO 0xFF6347AA
#define COLOR_MAROON 0x800000AA
#define COLOR_TAN 0xD2B48CAA
#define COLOR_BURLYWOOD 0xDEB887AA
#define COLOR_NAVAZOWHITE 0xFFDEADAA
#define COLOR_SKIN 0xFFCC99AA
#define COLOR_PEACHPUFF 0xFFDAB9AA
#define COLOR_FUCHSIA 0xFF00FFAA
#define COLOR_FIREBRICK 0xB22222AA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_LIGHTGREEN 0xCBFEA9AA
#define COLOR_MEDIUMGREEN 0x00800096
#define COLOR_FORESTGREEN 0x228B22AA
#define COLOR_PALEGREEN 0x98FB98AA
#define COLOR_MEDIUMSPRINGGREEN 0x00FA9AAA
#define COLOR_DARKGREEN 0x006400AA
#define COLOR_LAWNGREEN 0x7CFC00AA
#define COLOR_LIMEGREEN 0x32CD32AA
#define COLOR_SEAGREEN 0x2E8B57AA
#define COLOR_LIGHTSEAGREEN 0x20B2AAAA
#define COLOR_SPRINGGREEN 0x00FF7FAA
#define COLOR_YELLOWGREEN 0x9ACD32AA
#define COLOR_LIME 0x10F441AA
#define COLOR_LIGHTLIME 0x00FF00AA
#define COLOR_CHARTREUSE 0x7FFF00AA
#define COLOR_TEAL 0x008080AA
#define COLOR_BLUE 0x6FA7FB96
#define COLOR_RBLUE 0x4169FFAA
#define COLOR_MIDNIGHTBLUE 0x191970AA
#define COLOR_DARKBLUE 0x00008BAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_STEELBLUE 0x4682B4AA
#define COLOR_FLBLUE 0x6495EDAA
#define COLOR_POLICEBLUE 0x3F63CCAA
#define COLOR_ROYALBLUE 0x4169E1AA
#define COLOR_SLATEBLUE 0x6A5ACDAA
#define COLOR_MEDIUMSLATEBLUE 0x7B68EEAA
#define COLOR_DARKSLATEBLUE 0x483D8BAA
#define COLOR_ALICEBLUE 0xF0F8FFAA
#define COLOR_TURQUOISE 0x40E0D0AA
#define COLOR_MEDIUMTURQUOISE 0x48D1CCAA
#define COLOR_PALETURQUOISE 0xAFEEEEAA
#define COLOR_CYAN 0x00FFFFAA
#define COLOR_LIGHTCYAN 0xE0FFFFAA
#define COLOR_DARKCYAN 0x008B8BAA
#define COLOR_PURPLE 0x330066AA
#define COLOR_MEDIUMPURPLE 0x9370DBAA
#define COLOR_ORCHID 0xDA70D6AA
#define COLOR_MEDIUMORCHID 0xBA55D3AA
#define COLOR_DARKORCHID 0x9932CCAA
#define COLOR_INDIGO 0x4B00B0AA
#define COLOR_NEUTRAL 0xABCDEF97
#define COLOR_LAVENDER 0xE6E6FAAA
#define COLOR_NAVY 0x000080AA
#define COLOR_MEDIUMAQUA 0x83BFBFAA
#define COLOR_YELLOW  0xFFFF00AA
#define COLOR_GREENYELLOW 0xADFF2FAA
#define COLOR_TAXIYELLOW 0xF0E68CAA
#define COLOR_LIGHTYELLOW 0xFAEAA9FF
#define COLOR_IVORY 0xFFFF82AA
#define COLOR_GOLD 0xFFD700AA
#define COLOR_BISQUE 0xFFE4C4AA
#define COLOR_PAPAYAWHIP 0xFFEFD5AA
#define COLOR_BROWN 0xC1762B96
#define COLOR_DARKBROWN 0x80400096
#define COLOR_ROSYBROWN 0xBC8F8FAA
#define COLOR_SADDLEBROWN 0x8B4513AA
#define COLOR_OLIVE 0x808000AA
#define COLOR_DARKKHAKI 0xBDB76BAA
#define COLOR_PERU 0xCD853FAA
#define COLOR_WHITE 0xFFFFFF96
#define COLOR_FLORALWHITE 0xFFFAF0AA
#define COLOR_WHITESMOKE 0xF5F5F5AA
#define COLOR_GHOSTWHITE 0xF8F8FFAA
#define COLOR_MINTCREAM 0xF5FFFAAA
#define COLOR_HONEYDEW 0xF0FFF0AA
#define COLOR_SEASHELL 0xFFF5EEAA
#define COLOR_LAVENDERBLUSH 0xFFF0F5AA
#define COLOR_BEIGE 0xF5F5DCAA
#define COLOR_LINEN 0xFAF0E6AA
#define COLOR_OLDLACE 0xFDF5E6AA
#define COLOR_AQUA 0xF0F8FFAA
#define COLOR_SYSTEM 0xEFEFF7AA
#define COLOR_SILVER 0xD2D2D296
#define COLOR_DARKSILVER 0xC0C0C0AA
#define COLOR_GRAY 0x80808096
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_DIMGRAY 0x696969AA
#define COLOR_DARKGREY 0x333333AA
#define COLOR_DARKGRAY 0xA9A9A9AA
#define COLOR_LIGHTSLATEGREY 0x778899AA
#define COLOR_DARKSLATEGRAY 0x2F4F4FAA
#define COLOR_BLACK 0x00000096

#endif

new bool:TRUE=true, bool:FALSE=false;
#pragma unused TRUE,FALSE
// Main Functions
//==========================================================
// Argument
//==========================================================
#define GetArgString(%1,%2) do{ for(new x=0, y=x<strlen(%2); x < y;x++){ %2[x]=getarg(%1,x); if(getarg(%1,x)=='\0') break; } } while(FALSE)
//==========================================================
// Convert
//==========================================================
stock RetStr(val)
{
	new str[13];
	format(str,sizeof(str),"%d",val);
	return str;
}
//==========================================================
stock strfloat(Float:value)
{
	new str[13];
	format(str,sizeof(str),"%f",value);
	return str;
}
//==========================================================
stock intfloat(Float:val)
{
	new str[13];   
	format(str,sizeof(str),"%.0f", floatround(val));
	return strval(str);
}
//==========================================================
// String Handling
//==========================================================
stock isHangulExists(const strings[])
{
    for(new i;i<strlen(strings);i++)
    {
        if(strings[i]<32 || strings[i]>126)
        {
    		if(strings[i]=='\0' || strings[i]=='\n') return 0;
			return 1;
        }
    }
	return 0;
}
//==========================================================
stock str_left(source[],len)
{
	new retstr[MAX_STRING];
	strmid(retstr,source,0,len);
	return retstr;
}
//==========================================================
stock str_right(source[], len)
{
	new retstr[MAX_STRING],srclen = strlen(source);
	strmid(retstr,source,srclen - len,srclen);
	return retstr;
}
//==========================================================
stock join(string1[],string2[])
{
	new tmp[MAX_STRING];
	format(tmp,sizeof(tmp),"%s%s",string1,string2);
	return tmp;
}
//==========================================================
stock medium(source[],start,end)
{
	new retstr[MAX_STRING];
	strmid(retstr,source,start,end);
	return retstr;
}
//==========================================================
stock stringslice(const string[],stringindex,separator=' ')
{
    new stringstart;
    new stringnum;
    new stringlength;
    new result[32];

    for(stringnum=0;stringnum<=stringindex && stringlength<=strlen(string);++stringnum)
    {
        if(stringnum>0)stringlength++;
        stringstart=stringlength;
        while(stringlength<=strlen(string) && string[stringlength]!=separator && string[stringlength]!=EOS)
        {
                stringlength++;
        }
    }

    stringnum=0;
    stringlength=stringlength-stringstart;
    while(stringnum<=stringlength && stringnum<=sizeof(result))
    {
        result[stringnum]=string[stringnum+stringstart];
        stringnum++;
    }
    
    result[stringlength]=EOS;
    return result;
}
//==========================================================
stock StripNL(str[])
{
	new l = strlen(str);
	while (l-- && str[l] <= ' ') str[l] = 0;
}
//==========================================================
#define isnull(%1) ((%1[0] == 0) || (%1[0] == 1 && %1[1] == 0))
//==========================================================
/*----------------------------------------------------------------------------*-
Function:
        sscanf
Params:
        string[] - String to extract parameters from.
        format[] - Parameter types to get.
        {Float,_}:... - Data return variables.
Return:
        0 - Successful, not 0 - fail.
Notes:
        A fail is either insufficient variables to store the data or insufficient
        data for the format string - excess data is disgarded.
 
        A string in the middle of the input data is extracted as a single word, a
        string at the end of the data collects all remaining text.
 
        The format codes are:
 
        c - A character.
        d, i - An integer.
        h, x - A hex number (e.g. a colour).
        f - A float.
        s - A string.
        z - An optional string.
        pX - An additional delimiter where X is another character
       
        Now has IsNumeric integrated into the code.
       
        Added additional delimiters in the form of all whitespace and an
        optioanlly specified one in the format string.
-*----------------------------------------------------------------------------*/
stock sscanf(string[], format[], {Float,_}:...)
{
	if (isnull(string))	return format[0];
	new
		formatPos = 0,
		stringPos = 0,
		paramPos = 2,
		paramCount = numargs(),
		delim = ' ',
		ch;
	while (paramPos < paramCount && string[stringPos])
	{
		switch (format[formatPos++])
		{
			case '\0':
			{
				return 0;
			}
			case 'i', 'd':
			{
				new
					neg = 1,
					num = 0;
				ch = string[stringPos];
				if (ch == '-')
				{
					neg = -1;
					ch = string[++stringPos];
				}
				do
				{
					stringPos++;
					if (ch >= '0' && ch <= '9')
					{
						num = (num * 10) + (ch - '0');
					}
					else
					{
						return -1;
					}
				}
				while ((ch = string[stringPos]) > ' ' && ch != delim);
				setarg(paramPos, 0, num * neg);
			}
			case 'h', 'x':
			{
				new
					num = 0;
				while ((ch = string[stringPos]) > ' ' && ch != delim)
				{
					switch (ch)
					{
						case 'x', 'X':
						{
							num = 0;
							continue;
						}
						case '0' .. '9':
						{
							num = (num << 4) | (ch - '0');
						}
						case 'a' .. 'f':
						{
							num = (num << 4) | (ch - ('a' - 10));
						}
						case 'A' .. 'F':
						{
							num = (num << 4) | (ch - ('A' - 10));
						}
						default:
						{
							return -1;
						}
					}
				}
				setarg(paramPos, 0, num);
			}
			case 'c':
			{
				setarg(paramPos, 0, string[stringPos++]);
			}
			case 'f':
			{
				setarg(paramPos, 0, _:floatstr(string[stringPos]));
			}
			case 'p':
			{
				delim = format[formatPos++];
				continue;
			}
			case 'u':
			{
				new
					end = stringPos - 1,
					id = 0,
					bool:num = true;
					
				while ((ch = string[++end]) && ch != delim)
				{
					if (num)
					{
						if ('0' <= ch <= '9')
						{
							id = (id * 10) + (ch - '0');
						}
						else
						{
							num = false;
						}
					}
				}
				if (num && IsPlayerConnected(id))
				{
					setarg(paramPos, 0, id);
				}
				else
				{
					string[end] = '\0';
					num = false;
					new
						name[MAX_PLAYER_NAME];
					id = end - stringPos;
					for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
					{
						if ( GetPlayerName(playerid, name, sizeof (name)) )
						{
							FixChars( name );
							if( !strcmp(name, string[stringPos], true, id) )
							{
								setarg(paramPos, 0, playerid);
								num = true;
								break;
							}
						}
					}
					if (!num)
					{
						setarg(paramPos, 0, INVALID_PLAYER_ID);
					}
					string[end] = ch;
				}
				stringPos = end;
			}
			case 's', 'z':
			{
				new
					i = 0;
				if (format[formatPos])
				{
					while ((ch = string[stringPos++]) && ch != delim)
					{
						setarg(paramPos, i++, ch);
					}
					if (!i)
					{
						return -1;
					}
				}
				else
				{
					while ((ch = string[stringPos++]))
					{
						setarg(paramPos, i++, ch);
					}
				}
				stringPos--;
				setarg(paramPos, i, '\0');
			}
			default:
			{
				continue;
			}
		}
		while (string[stringPos] && string[stringPos] != delim && string[stringPos] > ' ')
		{
			stringPos++;
		}
		while (string[stringPos] && (string[stringPos] == delim || string[stringPos] <= ' '))
		{
			stringPos++;
		}
		paramPos++;
	}
	while (format[formatPos] == 'z') formatPos++;
	if (format[formatPos] > ' ') return format[formatPos];
	return 0;
}
//==========================================================
stock CharPos(string[],character,index=1)
{
	new curidx;
	for(new i=0;i<strlen(string);i++)
	{
		if(string[i]==character) curidx++;
		if(curidx==index) return i;
	}
	return -1;
}
//==========================================================
stock strset( dest[], source[] ) 
{
	new count = strlen(source);
	new i=0;
	for (i=0;i < count;i++) 
	{
		dest[i]=source[i];
	}
	dest[count]=0;
}
//==========================================================
stock FixChars(string[]) for (new i=0,j=strlen(string);i<j;i++) if (string[i] < 0) string[i] += 256;
//==========================================================
stock IsValidIP( IP[] )
{
	if( !IP[0] || strlen(IP) < 7 || strlen(IP) > 15 || CharPos( IP, '.', 3 ) == -1 ) return false;
	return true;
}

//==========================================================
// File Control
//==========================================================
#if !defined _COOLGUY_NO_FILE
stock fcreate(filename[])
{
	if(fexist(filename)) return false;
	new File:fhandle = fopen(filename,io_write);
	if(!fhandle) return false;
	fclose(fhandle);
	return true;
}
//==========================================================
stock fsize(filename[])
{
	new size[10];
    new File:file = fopen(filename,io_append);
    new Float:flen = flength(file)/1048576.0;
    if(flen < 1.0)
	{
    	flen *= 1024;
    	format(size,sizeof(size),"%.f KB",flen);
    }
    else format(size,sizeof(size),"%.2f MB",flen);
    fclose(file);
    return size;
}
//=========================================================
// c_fwrite : 한글이 파일에 제대로 입/출력되지 않는 문제를 해결한다.
//=========================================================
stock c_fwrite( File: handle, const string[] )
{
	for( new c_fwval = 0; c_fwval < strlen( string );  c_fwval++ ) fputchar( handle, string[c_fwval], false);
	return ;
}
//==========================================================
#endif
//==========================================================
// Game & Player Control
//==========================================================
#if !defined _COOLGUY_NO_PLAYER
//==========================================================
#define SendFormatMessage(%1,%2,%3,%4) do{new sendfstring[256]; format(sendfstring,256,(%3),%4); FixChars( sendfstring ); SendClientMessage(%1,(%2),sendfstring);}while(FALSE)
//==========================================================
#define SendFormatMessageToAll(%1,%2,%3) do{new sendfstring[256]; format(sendfstring,256,(%2),%3); FixChars( sendfstring ); SendClientMessageToAll((%1),sendfstring);}while(FALSE)
//==========================================================
stock PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid,name,MAX_PLAYER_NAME);
	return name;
}
//==========================================================
stock Float:PlayerHealth(playerid)
{
	new Float:thehealth;
	GetPlayerHealth(playerid,thehealth);
	return thehealth;
}
//==========================================================
stock Float:PlayerArmour(playerid)
{
	new Float:thearmour;
	GetPlayerArmour(playerid,thearmour);
	return thearmour;
}
//==========================================================
stock PlayerIP(playerid)
{
	new str[16];
	GetPlayerIp(playerid,str,16);
	return str;
}
//==========================================================
#define IsPartOfName(%1,%2) strcmp(%1,PlayerName(%2),true,strlen(%1))
//==========================================================
stock GetClosestPlayerID( partofname[] )
{
	if( !partofname[0] ) return INVALID_PLAYER_ID;
	new playername[ MAX_PLAYER_NAME ];
	for(new i = 0 ; i < MAX_PLAYERS ; i++)
	{
		if( GetPlayerName(i, playername, MAX_PLAYER_NAME) && strcmp(partofname, playername, true, strlen(partofname)) == 0 )
		{
			return i;
		}
	}            
	return INVALID_PLAYER_ID;
}
//==========================================================
stock SendClientMessageExceptPlayer(id,COLOR,const text[]) for(new i=0,total=GetMaxPlayers();i<total;i++) if(i != id) SendClientMessage(i,COLOR,text);
//==========================================================
stock wiper(...) for(new j=0, total=numargs();j<total;j++) for(new i=0;i<10;i++) SendClientMessage(getarg(j),0xAFAFAFAA,"\n");
//==========================================================
stock wiperToAll() for(new i=0;i<10;i++) SendClientMessageToAll(0xAFAFAFAA,"\n");
//==========================================================
stock Eraser(lines,...)	for(new i=1,j=numargs();i<j;i++) for(new a=0;a < lines;a++) SendClientMessage(getarg(i),0xAFAFAFAA,"\n");
//==========================================================
stock EraserToAll(lines) for(new a=0;a < lines;a++) SendClientMessageToAll(0xAFAFAFAA, "\n");
//==========================================================
stock SetVehiclePosEx( vehicleid, Float:x, Float:y, Float:z )
{
	SetVehiclePos(vehicleid,x, y, z);
	switch(GetVehicleModel(vehicleid))
	{
		case 509, 581, 481, 462, 521, 463, 510, 522, 461, 448, 468, 586:
		{
		    new Max_Players = GetMaxPlayers();
		    for( new i = 0; i < Max_Players; i++ )
		    {
		        if( IsPlayerInVehicle( i, vehicleid ))
		        {
		            new Player_State =  GetPlayerState(i);
		            SetPlayerPos(i, 0.0, 0.0, 0.0 );
		            if( Player_State == PLAYER_STATE_DRIVER )
		            {
			   			PutPlayerInVehicle( i, vehicleid, 0 );
					}					
					else 
					{
						PutPlayerInVehicle( i, vehicleid, 1 );
					}
				}
			}
		}
	}
}
//==========================================================
#define Kill(%1) SetPlayerHealth(%1,-999)
//==========================================================
#define PlaySoundForPlayer(%1,%2) PlayerPlaySound(%1, %2, 0.0, 0.0, 0.0)
//==========================================================
stock PlaySoundForAll(soundid) for(new i=0,j=GetMaxPlayers();i<j;i++) PlaySoundForPlayer(i,soundid);
//==========================================================
#define StopSoundForPlayer(%1) PlayerPlaySound(%1,1184,0.0,0.0,0.0)
//==========================================================
stock StopSoundForAll() for(new i=0,j=GetMaxPlayers();i<j;i++) if(IsPlayerConnected(i)) StopSoundForPlayer(i);
//==========================================================
stock Num_Players()
{
 	new activeplayers=0;
	for(new i=0,j=GetMaxPlayers();i<j;i++) if(IsPlayerConnected(i)) activeplayers++;
	return activeplayers;
}
//==========================================================
stock Float:GetPlayerDistanceToPoint(playerid,{Float,_}:...)
{
	new num = numargs(),Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	if(num == 3) return floatsqroot(floatpower(floatabs(floatsub(pos[0],Float:getarg(1))),2)+floatpower(floatabs(floatsub(pos[1],Float:getarg(2))),2));
	else if(num == 4) return floatsqroot(floatpower(floatabs(floatsub(pos[0],Float:getarg(1))),2)+floatpower(floatabs(floatsub(pos[1],Float:getarg(2))),2)+floatpower(floatabs(floatsub(pos[2],Float:getarg(3))),2));
	return -1.0;
}
//==========================================================
stock Float:GetDistanceBetweenPlayers(playerid,playerid2)
{
	new Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	return GetPlayerDistanceToPoint(playerid2,pos[0],pos[1],pos[2]);
}
//==========================================================
stock IsPlayerInArea(playerid,Float:x1,Float:x2,Float:y1,Float:y2)
{
	new Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	if(pos[0]>=x1 && pos[0]<=x2 && pos[1]>=y1 && pos[1]<=y2) return 1;
	return 0;
}
//==========================================================
stock IsPlayerInCube(playerid,Float:x1,Float:x2,Float:y1,Float:y2,Float:z1,Float:z2)
{
	new Float:pos[3];
	GetPlayerPos(playerid,pos[0],pos[1],pos[2]);
	if(x1<pos[0] && x2>pos[0] && y1<pos[1] && y2>pos[1] && z1<pos[2] && z2>pos[2]) return 1;
	return 0;
}
//==========================================================
stock IsPlayerInCircle(playerid,Float:X,Float:Y,Float:Radius) return (GetPlayerDistanceToPoint(playerid,X,Y)<Radius? (1):(0));
//==========================================================
stock IsPlayerInSphere(playerid,Float:X,Float:Y,Float:Z,Float:Radius) return (GetPlayerDistanceToPoint(playerid,X,Y,Z)<Radius? (1):(0));
//==========================================================
stock IsValidWeaponId(weaponid)	return ((weaponid == 19|| weaponid == 20|| weaponid == 21 ||weaponid > 46 || weaponid < 0)? (0):(1));
//==========================================================
stock FlashPlayerWantedLevel(playerid, times)
{
	static flash;
	new level = GetPlayerWantedLevel(playerid);
	if(times)
	{
	    if(!flash)
	    {
	        flash=1;
	        SetPlayerWantedLevel(playerid, 0);
	    }
	    else {
	        flash=0;
	        SetPlayerWantedLevel(playerid, level);
	    }
	    SetTimerEx("FlashPlayerWantedLevel", 500, 0, "ii", playerid, times-1);
	}
	else
	{
	    SetPlayerWantedLevel(playerid, level);
	}
}
//==========================================================
stock IsValidVehicleMod(componentid) return ((componentid < 1000 || componentid > 1193)? (0):(1));
//==========================================================
stock AddVehicleComponentEx(vehicleid, ...) {
	new arg = 1, n = numargs(), componentid;
	while(arg < n) {
		componentid = getarg(arg);
		if(IsValidVehicleMod(componentid)) {
			AddVehicleComponent(vehicleid, componentid);
			// Add any paired components
			switch(componentid) {
				case 1143: AddVehicleComponent(vehicleid, 1142);
				case 1145: AddVehicleComponent(vehicleid, 1144);
				case 1108: AddVehicleComponent(vehicleid, 1107);
				case 1042: AddVehicleComponent(vehicleid, 1099);
				case 1036: AddVehicleComponent(vehicleid, 1040);
				case 1039: AddVehicleComponent(vehicleid, 1041);
				case 1047: AddVehicleComponent(vehicleid, 1051);
				case 1048: AddVehicleComponent(vehicleid, 1052);
				case 1069: AddVehicleComponent(vehicleid, 1071);
				case 1070: AddVehicleComponent(vehicleid, 1072);
				case 1122: AddVehicleComponent(vehicleid, 1101);
				case 1106: AddVehicleComponent(vehicleid, 1124);
				case 1133: AddVehicleComponent(vehicleid, 1102);
				case 1118: AddVehicleComponent(vehicleid, 1120);
				case 1119: AddVehicleComponent(vehicleid, 1121);
				case 1056: AddVehicleComponent(vehicleid, 1062);
				case 1057: AddVehicleComponent(vehicleid, 1063);
				case 1026: AddVehicleComponent(vehicleid, 1027);
				case 1031: AddVehicleComponent(vehicleid, 1030);
				case 1134: AddVehicleComponent(vehicleid, 1137);
				case 1090: AddVehicleComponent(vehicleid, 1094);
				case 1093: AddVehicleComponent(vehicleid, 1095);
				case 1007: AddVehicleComponent(vehicleid, 1017);
			}
		}
		arg++;
	}
}
//==========================================================
stock RemoveVehicleComponentEx(vehicleid, ...) {
	new arg = 1, n = numargs(), componentid;
	while(arg < n) {
		componentid = getarg(arg);
		if(IsValidVehicleMod(componentid)) {
			RemoveVehicleComponent(vehicleid, componentid);
			// Remove any paired components
			switch(componentid) {
				case 1143: RemoveVehicleComponent(vehicleid, 1142);
				case 1145: RemoveVehicleComponent(vehicleid, 1144);
				case 1108: RemoveVehicleComponent(vehicleid, 1107);
				case 1042: RemoveVehicleComponent(vehicleid, 1099);
				case 1036: RemoveVehicleComponent(vehicleid, 1040);
				case 1039: RemoveVehicleComponent(vehicleid, 1041);
				case 1047: RemoveVehicleComponent(vehicleid, 1051);
				case 1048: RemoveVehicleComponent(vehicleid, 1052);
				case 1069: RemoveVehicleComponent(vehicleid, 1071);
				case 1070: RemoveVehicleComponent(vehicleid, 1072);
				case 1122: RemoveVehicleComponent(vehicleid, 1101);
				case 1106: RemoveVehicleComponent(vehicleid, 1124);
				case 1133: RemoveVehicleComponent(vehicleid, 1102);
				case 1118: RemoveVehicleComponent(vehicleid, 1120);
				case 1119: RemoveVehicleComponent(vehicleid, 1121);
				case 1056: RemoveVehicleComponent(vehicleid, 1062);
				case 1057: RemoveVehicleComponent(vehicleid, 1063);
				case 1026: RemoveVehicleComponent(vehicleid, 1027);
				case 1031: RemoveVehicleComponent(vehicleid, 1030);
				case 1134: RemoveVehicleComponent(vehicleid, 1137);
				case 1090: RemoveVehicleComponent(vehicleid, 1094);
				case 1093: RemoveVehicleComponent(vehicleid, 1095);
				case 1007: RemoveVehicleComponent(vehicleid, 1017);
			}
		}
		arg++;
	}
}
//==========================================================
stock AddCircleOfStaticVehicles(vehicleid, Float:X, Float:Y, Float:Z, Float:radius, num_of_vehicles, color1, color2) {
	new i,
	Float: radAngle,
	Float: xCoord,
	Float: yCoord;

	for(i=0; i<num_of_vehicles; i++) {
		radAngle = floatdiv(floatmul(i,PI), floatdiv(num_of_vehicles, 2));
		xCoord = floatmul(floatcos(radAngle), radius);
		yCoord = floatmul(floatsin(radAngle), radius);
		AddStaticVehicle( vehicleid,
		floatadd(xCoord, (X)),
		floatadd(yCoord, (Y)),
		Z,
		floatadd(floatmul(radAngle, 60), 90),
		color1,
		color2);
	}

	return 1;
}
//==========================================================
stock SetPlayersPosInCircle(Float:X, Float:Y, Float:Z, Float:radius){
	new i,
	Float: radAngle,
	Float: xCoord,
	Float: yCoord,
	players_num,
	bool:playerAlreadySet[100] = {false,...};

	for(i=0; i<100; i++)
	if(IsPlayerConnected(i))
	players_num++;

	for(i=0; i<players_num; i++) {
	    radAngle = floatdiv(floatmul(i,PI), floatdiv(players_num, 2));
	    xCoord = floatmul(floatcos(radAngle), radius);
	    yCoord = floatmul(floatsin(radAngle), radius);

		for(i=0; i<100; i++) if(IsPlayerConnected(i) && !playerAlreadySet[i]){
		    playerAlreadySet[i] = true;
		    SetPlayerPos(i,floatadd(xCoord, (X)),floatadd(yCoord, (Y)),	Z);
			SetPlayerFacingAngle(i, floatadd(floatmul(radAngle, 60), 90));
			break;
		}
	}
	return 1;
}
//==========================================================
stock SetObjectToFaceCords(objectid, Float:x1,Float:y1,Float:z1)
{
//   SetObjectToFaceCords() By LucifeR   //
//                LucifeR@vgames.co.il   //

// setting the objects cords
new Float:x2,Float:y2,Float:z2;
GetObjectPos(objectid, x2,y2,z2);

// setting the distance values
new Float:DX = floatabs(x2-x1);
new Float:DY = floatabs(y2-y1);
new Float:DZ = floatabs(z2-z1);

// defining the angles and setting them to 0
    new Float:yaw = 0;
    new Float:pitch = 0;

    // check that there isnt any 0 in one of the distances,
// if there is any  use the given parameters:
if(DY == 0 || DX == 0)
{
    if(DY == 0 && DX > 0) {
yaw = 0;
pitch = 0; }
else if(DY == 0 && DX < 0) {
yaw = 180;
pitch = 180; }
else if(DY > 0 && DX == 0)  {
yaw = 90;
pitch = 90; }
else if(DY < 0 && DX == 0) {
yaw = 270;
pitch = 270; }
else if(DY == 0 && DX == 0) {
yaw = 0;
pitch = 0; }
}

// calculating the angale using atan
else // non of the distances is 0.
{
    // calculatin the angles
yaw = atan(DX/DY);
pitch = atan(floatsqroot(DX*DX + DZ*DZ) / DY);

// there are three quarters in a circle, now i will
// check wich circle this is and change the angles
// according to it.
if(x1 > x2 && y1 <= y2) {
    yaw = yaw + 90;
pitch = pitch - 45; }
        else if(x1 <= x2 && y1 < y2) {
    yaw = 90 - yaw;
pitch = pitch - 45; }
        else if(x1 < x2 && y1 >= y2) {
    yaw = yaw - 90;
pitch = pitch - 45; }
        else if(x1 >= x2 && y1 > y2) {
    yaw = 270 - yaw;
pitch = pitch + 315; }

// the pitch could be only in two quarters, lets see wich one:
        if(z1 < z2)
    pitch = 360-pitch;
}

// setting the object rotation (should be twice cuz of lame GTA rotation system)
SetObjectRot(objectid, 0, 0, yaw);
SetObjectRot(objectid, 0, pitch, yaw);
}
//==========================================================
#endif
//==========================================================
// Sub-Admin Support
//==========================================================
#if !defined _COOLGUY_NO_SUBADMIN
#define IsPlayerSubAdmin(%1) existproperty(%1, "SAdmin")
//==========================================================
#define SetPlayerSubAdmin(%1) setproperty(%1, "SAdmin")
//==========================================================
#define UnSetPlayerSubAdmin(%1) deleteproperty(%1, "SAdmin")
//==========================================================
#define ResetAllSubAdmins() for(new i=0,j=GetMaxPlayers();i < j;i++) if(IsPlayerSubAdmin(i)) UnSetPlayerSubAdmin(i)
//==========================================================
stock SendAdminMessage(COLOR,text[],bool:tosubadmin=false)
{
	new i, total;
	if(tosubadmin) for(i=0,total=GetMaxPlayers();i<total;i++) if(IsPlayerAdmin(i) || IsPlayerSubAdmin(i)) SendClientMessage(i,COLOR,text);
	else for(i=0,total=GetMaxPlayers();i<total;i++) if(IsPlayerAdmin(i)) SendClientMessage(i,COLOR,text);
}
//==========================================================
stock Num_SubAdmins()
{
	new count;
	for(new i=0,j=GetMaxPlayers();i < j;i++) if(IsPlayerSubAdmin(i)) count++;
	return count;
}
//==========================================================
stock SubAdminMessage(COLOR,string[]) for(new i=0,j=GetMaxPlayers();i<j;i++) if(IsPlayerSubAdmin(i)) SendClientMessage(i,COLOR,string);
#endif
//==========================================================
// Encrypting
//==========================================================
#if !defined _COOLGUY_NO_ENCRYPT
stock coolguy_hash(buf[])
{
    new length=strlen(buf);
    new s1 = 1;
    new s2 = 0;
    new n;
    for (n=0; n<length; n++)
    {
       s1 = (s1 + buf[n]) % 65521;
       s2 = (s2 + s1)     % 65521;
    }
    
    return (s2 << 16) + s1;
}
//==========================================================
stock coolguy_checksum(buffer[],mod = 65521)
{
	new a = 0,b = 1,c = 2,d = 3;
    for(new i=0,j=strlen(buffer);i<j;i++){
        a = ((a + buffer[i]) % mod);
        b = ((a + b)	     % mod);
        c = ((a + b + c)     % mod);
        d = ((a + b + c + d) % mod);
    }
    return ((d << 16) + (a + b + c));
}
//==========================================================
stock sax_hash(s[]){new i,j,h;while((j=s[i++]))h^=(h<<5)+(h>>2)+j;return h;}
//==========================================================
stock bernstein(s[]){new h=-1,i,j;while((j=s[i++]))h=h*33+j;return h;}
//==========================================================
stock fnv_hash(s[]){new h=2166136261,i,j;while((j=s[i++]))h=h*16777619^j;return h;}
//==========================================================
stock xencrypt(string[],enc[]) for(new len = strlen(string), enclen = strlen(enc), i = 0, j = 0; i < len; i++, j++, j %= enclen) string[i] += enc[j];
//==========================================================
stock xdecrypt(string[],enc[]) for(new len = strlen(string), enclen = strlen(enc), i = 0, j = 0; i < len; i++, j++, j %= enclen) string[i] -= enc[j];
//==========================================================
stock encrypt(string[])//no stringlength checking
{
	static key[] = "Put your key here, remember to escape \", \' and \\, like so.";
	// The more different characters there are in here, the better the code

	static size = sizeof(key) - 1;
	// Theres a slight bug, you don't want to count the end \0

	new retval[64];
	// Passwords limited to 48 chars (64 - 16 for rounding)

	new j, k, sum, tmp[] = {0, 0};
	// Initialise the variables

	j = strlen(string);
	sum = j;
	// Get the length of the source string

	k = ((j >> 4) + 1) << 4;
	// Round up to the nearest 16 (trust me, it does)

	for (new i = 0; i < k; i++)
	{
		if (i < j)
		{
			tmp[0] = string[i];
			// Get the next character
		}
		else
		{
			tmp[0] = ' ';
			// Add the padding
		}

		sum = ((sum + strfind(key, tmp) + 1) % size);
		// Add the new position to the running total and limit
		// it to the size of the array (thus carrying character
		// data over to the next)

		retval[i] = key[sum];
		// Add the new character to the running array.
	}
	return retval;
}
//==========================================================
stock RMB1(buf[]){
	new length=strlen(buf);
	new a;
	new s1 = 2;
	new s2 = 3;
   	new s3 = 5;
   	new s4 = 7;
   	new s5 = 9;
   	new s6 = 11;
   	new s7 = 13;
   	new s8 = 17;
   	new s9 = 7919;
   	new s10 = 7907;
   	new s11 = 7901;
   	new s12 = 7883;
   	new s13 = 7879;
   	new s14 = 7877;
   	new s15 = 7873;
   	new s16 = 7867;
   	for (a=0; a<length; a++){
        s1 = (s1 + buf[a]) * 65521;
        s2 = (s2 / s1 + buf[a]) * 65521;
        s3 = (s3 * s2 / s1 + buf[a]) * 65521;
        s4 = (s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s5 = (s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s6 = (s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s7 = (s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s8 = (s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s9 = (s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s10 = (s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s11 = (s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s12 = (s12 + s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s13 = (s13 / s12 + s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s14 = (s14 * s13 / s12 + s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s15 = (s15 - s14 * s13 / s12 + s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
        s16 = (s16 + s15 - s14 * s13 / s12 + s11 - s10 * s9 / s8 + s7 - s6 * s5 / s4 + s3 - s2 * s1 / buf[a]) * 65521;
    }
    return (s16 << 128) * s1 * s2 * s3 * s4 * s5 * s6 * s7 + s8 + s9 + s10 + s11 + s12 + s13 + s14 + s15 + s16;
}
//==========================================================
stock SHA1(const string[]){
	new hashtmp[MAX_STRING],len = strlen(string),digest[MAX_STRING];
	format(hashtmp,sizeof(hashtmp),"%s",string);
	hashtmp[len >> 5] |= 0x80 << (24 - len % 32);
	hashtmp[((len + 64 >> 9) << 4) + 15] = len;
	new w[80], a =  1732584193, b = -271733879, c = -1732584194, d =  271733878, e = -1009589776;
	for(new i=0;i<len;i+=16){
		new olda = a, oldb = b, oldc = c, oldd = d, olde = e;
		for(new j=0;j<80;j++){
			if(j < 16) w[j] = hashtmp[i+j];
			else w[j] = Roll(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
			new t = Add(Add(Roll(a, 5), SHA1FT(j, b, c, d)),Add(Add(e, w[j]), SHA1KT(j)));
			e = d;
			d = c;
			c = Roll(b, 30);
			b = a;
			a = t;
		}
		a = Add(a, olda);
   		b = Add(b, oldb);
   		c = Add(c, oldc);
    	d = Add(d, oldd);
    	e = Add(e, olde);
	}
	format(digest,sizeof(digest),"%s%s%s%s%s",IntToHex(a),IntToHex(b),IntToHex(c),IntToHex(d),IntToHex(e));
	return digest;
}
//==========================================================
stock Roll(num,cnt) return (num << cnt) | (num >>> (32-cnt));
//==========================================================
stock Add(x,y){
	new lsw = (x & 0xFFFF) + (y & 0xFFFF);
	new msw = (x >> 16) + (y >> 16) + (lsw >> 16);
	return (msw << 16) | (lsw & 0xFFFF);
}
//==========================================================
stock SHA1FT(t,b,c,d){
	if(t < 20) return (b & c) | ((~b) & d);
	if(t < 40) return b ^ c ^ d;
	if(t < 60) return (b & c) | (b & d) | (c & d);
	return b ^ c ^ d;
}
//==========================================================
stock SHA1KT(t) return (t < 20) ? 1518500249 : (t < 40) ? 1859775393 : (t < 60) ? -1894007588 : -899497514;
//==========================================================
stock MD5(const string[]){
	new len = strlen(string);
	new x[MAX_STRING];
	format(x,sizeof(x),"%s",string);
	x[len >> 5] |= 0x80 << (len % 32);
	x[((len + 64 >> 9) << 4) + 14] = len;
	new a =  1732584193;
	new b = -271733879;
	new c = -1732584194;
	new d =  271733878;
	for(new i=0;i<len;i+=16){
		new olda = a;
		new oldb = b;
		new oldc = c;
		new oldd = d;
		a = MD5FF(a, b, c, d, x[i+ 0], 7 , -680876936);
		d = MD5FF(d, a, b, c, x[i+ 1], 12, -389564586);
  		c = MD5FF(c, d, a, b, x[i+ 2], 17,  606105819);
    	b = MD5FF(b, c, d, a, x[i+ 3], 22, -1044525330);
    	a = MD5FF(a, b, c, d, x[i+ 4], 7 , -176418897);
    	d = MD5FF(d, a, b, c, x[i+ 5], 12,  1200080426);
    	c = MD5FF(c, d, a, b, x[i+ 6], 17, -1473231341);
    	b = MD5FF(b, c, d, a, x[i+ 7], 22, -45705983);
    	a = MD5FF(a, b, c, d, x[i+ 8], 7 ,  1770035416);
    	d = MD5FF(d, a, b, c, x[i+ 9], 12, -1958414417);
    	c = MD5FF(c, d, a, b, x[i+10], 17, -42063);
    	b = MD5FF(b, c, d, a, x[i+11], 22, -1990404162);
    	a = MD5FF(a, b, c, d, x[i+12], 7 ,  1804603682);
    	d = MD5FF(d, a, b, c, x[i+13], 12, -40341101);
    	c = MD5FF(c, d, a, b, x[i+14], 17, -1502002290);
    	b = MD5FF(b, c, d, a, x[i+15], 22,  1236535329);
    	a = MD5GG(a, b, c, d, x[i+ 1], 5 , -165796510);
    	d = MD5GG(d, a, b, c, x[i+ 6], 9 , -1069501632);
    	c = MD5GG(c, d, a, b, x[i+11], 14,  643717713);
    	b = MD5GG(b, c, d, a, x[i+ 0], 20, -373897302);
    	a = MD5GG(a, b, c, d, x[i+ 5], 5 , -701558691);
    	d = MD5GG(d, a, b, c, x[i+10], 9 ,  38016083);
    	c = MD5GG(c, d, a, b, x[i+15], 14, -660478335);
    	b = MD5GG(b, c, d, a, x[i+ 4], 20, -405537848);
   		a = MD5GG(a, b, c, d, x[i+ 9], 5 ,  568446438);
    	d = MD5GG(d, a, b, c, x[i+14], 9 , -1019803690);
    	c = MD5GG(c, d, a, b, x[i+ 3], 14, -187363961);
    	b = MD5GG(b, c, d, a, x[i+ 8], 20,  1163531501);
    	a = MD5GG(a, b, c, d, x[i+13], 5 , -1444681467);
    	d = MD5GG(d, a, b, c, x[i+ 2], 9 , -51403784);
    	c = MD5GG(c, d, a, b, x[i+ 7], 14,  1735328473);
    	b = MD5GG(b, c, d, a, x[i+12], 20, -1926607734);
    	a = MD5HH(a, b, c, d, x[i+ 5], 4 , -378558);
    	d = MD5HH(d, a, b, c, x[i+ 8], 11, -2022574463);
    	c = MD5HH(c, d, a, b, x[i+11], 16,  1839030562);
    	b = MD5HH(b, c, d, a, x[i+14], 23, -35309556);
    	a = MD5HH(a, b, c, d, x[i+ 1], 4 , -1530992060);
    	d = MD5HH(d, a, b, c, x[i+ 4], 11,  1272893353);
    	c = MD5HH(c, d, a, b, x[i+ 7], 16, -155497632);
    	b = MD5HH(b, c, d, a, x[i+10], 23, -1094730640);
    	a = MD5HH(a, b, c, d, x[i+13], 4 ,  681279174);
    	d = MD5HH(d, a, b, c, x[i+ 0], 11, -358537222);
    	c = MD5HH(c, d, a, b, x[i+ 3], 16, -722521979);
   		b = MD5HH(b, c, d, a, x[i+ 6], 23,  76029189);
    	a = MD5HH(a, b, c, d, x[i+ 9], 4 , -640364487);
    	d = MD5HH(d, a, b, c, x[i+12], 11, -421815835);
    	c = MD5HH(c, d, a, b, x[i+15], 16,  530742520);
    	b = MD5HH(b, c, d, a, x[i+ 2], 23, -995338651);
    	a = MD5II(a, b, c, d, x[i+ 0], 6 , -198630844);
    	d = MD5II(d, a, b, c, x[i+ 7], 10,  1126891415);
    	c = MD5II(c, d, a, b, x[i+14], 15, -1416354905);
    	b = MD5II(b, c, d, a, x[i+ 5], 21, -57434055);
    	a = MD5II(a, b, c, d, x[i+12], 6 ,  1700485571);
    	d = MD5II(d, a, b, c, x[i+ 3], 10, -1894986606);
    	c = MD5II(c, d, a, b, x[i+10], 15, -1051523);
    	b = MD5II(b, c, d, a, x[i+ 1], 21, -2054922799);
    	a = MD5II(a, b, c, d, x[i+ 8], 6 ,  1873313359);
    	d = MD5II(d, a, b, c, x[i+15], 10, -30611744);
    	c = MD5II(c, d, a, b, x[i+ 6], 15, -1560198380);
    	b = MD5II(b, c, d, a, x[i+13], 21,  1309151649);
    	a = MD5II(a, b, c, d, x[i+ 4], 6 , -145523070);
    	d = MD5II(d, a, b, c, x[i+11], 10, -1120210379);
    	c = MD5II(c, d, a, b, x[i+ 2], 15,  718787259);
    	b = MD5II(b, c, d, a, x[i+ 9], 21, -343485551);
    	a = Add(a, olda);
    	b = Add(b, oldb);
    	c = Add(c, oldc);
    	d = Add(d, oldd);
    }
    new digest[MAX_STRING];
    format(digest,sizeof(digest),"%s%s%s%s",IntToHex(a),IntToHex(b),IntToHex(c),IntToHex(d));
    return digest;
}
//==========================================================
stock MD5FF(a,b,c,d,x,s,t) return MD5CMN((b & c) | ((~b) & d),a,b,x,s,t);
//==========================================================
stock MD5CMN(q,a,b,x,s,t) return Add(Roll(Add(Add(a,q),Add(x,t)),s),b);
//==========================================================
stock MD5GG(a,b,c,d,x,s,t) return MD5CMN((b & d) | (c & (~d)),a,b,x,s,t);
//==========================================================
stock MD5HH(a,b,c,d,x,s,t) return MD5CMN(b^c^d,a,b,x,s,t);
//==========================================================
stock MD5II(a, b, c, d, x, s, t) return MD5CMN(c ^ (b | (~d)), a, b, x, s, t);
#endif
//==========================================================
// INI
//==========================================================
#if !defined _COOLGUY_NO_INI
#if !defined MAX_INI_BUFFER
	#define MAX_INI_BUFFER 128
#endif
#if !defined MAX_INI_HEADER
	#define MAX_INI_HEADER 32
#endif
#if !defined MAX_INI_KEYNAME
	#define MAX_INI_KEYNAME 64
#endif

#define INI_FLAG_INVALID 0
#define INI_FLAG_UNUSED 1
enum INI_INFO
{
	e_Flag, // 0 : invalid 1 : info inside, unwrited
	e_Header_str[MAX_INI_HEADER],
	e_Name_str[MAX_INI_KEYNAME],
	e_Header_hash,
	e_Name_hash,
	e_value_string[MAX_STRING]
}
new INI_NAME[256], Cur_ini, filemode: inimode;
new INI_BUFFER[MAX_INI_BUFFER][INI_INFO];
//==========================================================
stock c_iniOpen( file[], filemode: mode = io_readwrite )
{
	inimode = mode;
	switch( mode )
	{
		case io_read: // file must exist
		{
			INI_NAME[0] = EOS, Cur_ini = 0; //포인터 초기화
			new temp[MAX_STRING], File:hnd;
			hnd = fopen( file, io_read );
			if(!hnd)
			{
				print("[ERROR] Warning: Error Processing c_iniOpen()");
				return false;
			}
			new cur_header, ptr;
			while( fread( hnd, temp ) )
			{
				if( temp[0] == '#' ) continue;
				else if( temp[0] == '[' )
				{
					StripNL( temp );
					ptr = strfind( temp, "]" );
					temp[ptr + 1] = EOS; // cut annotation
					cur_header = fnv_hash( temp ); // write header
					continue;
				}
				ptr = strfind( temp, "=" );
				if( ptr > 0 )
				{
					if( Cur_ini >= MAX_INI_BUFFER )
					{
						print("[ERROR] Warning: Error Processing c_iniOpen() : BUFFER LIMIT EXCEEDED");
						fclose( hnd );
						return false;
					}
					StripNL( temp );
					INI_BUFFER[Cur_ini][e_Flag] = INI_FLAG_UNUSED; // set 'info inide, unused' flag
					INI_BUFFER[Cur_ini][e_Header_hash] = cur_header; // write header
					temp[ptr] = EOS;
					INI_BUFFER[Cur_ini][e_Name_hash] = fnv_hash( temp ); // write name
					strset( INI_BUFFER[Cur_ini][e_value_string], temp[ptr + 1] ); // write value
					if( ( ptr = strfind( INI_BUFFER[Cur_ini][e_value_string], "//" ) ) != -1 ) INI_BUFFER[Cur_ini][e_value_string][ptr] = EOS; // cut annotation
					Cur_ini++;
				}
			}
			fclose( hnd );
			for( new i = Cur_ini; i < MAX_INI_BUFFER; i++ ) INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID; //set invalid value
		}
		case io_write, io_append: // creates new file
		{
			Cur_ini = 0;
			strset( INI_NAME, file );
			for( new i = 0; i < MAX_INI_BUFFER; i++ ) INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID; //set invalid value
		}
		case io_readwrite: // read & write
		{
			Cur_ini = 0; //포인터 초기화
			strset( INI_NAME, file );
			new temp[MAX_STRING], File:hnd;
			hnd = fopen( file, io_read );
			if(!hnd)
			{
				print("[ERROR] Warning: Error Processing c_iniOpen()");
				return false;
			}
			new cur_header, cur_header_str[MAX_STRING], ptr;
			while( fread( hnd, temp ) )
			{
				if( temp[0] == '#' ) continue;
				else if( temp[0] == '[' )
				{
					StripNL( temp );
					ptr = strfind( temp, "]" );
					temp[ptr + 1] = EOS; // cut annotation
					cur_header_str = temp; // write header string
					cur_header = fnv_hash( temp ); // write header
					continue;
				}
				ptr = strfind( temp, "=" );
				if( ptr > 0 )
				{
					if( Cur_ini >= MAX_INI_BUFFER )
					{
						print("[ERROR] Warning: Error Processing c_iniOpen() : BUFFER LIMIT EXCEEDED");
						fclose( hnd );
						return false;
					}
					StripNL( temp );
					INI_BUFFER[Cur_ini][e_Flag] = INI_FLAG_UNUSED; // set 'info inide, unused' flag
					strset( INI_BUFFER[Cur_ini][e_Header_str], cur_header_str ); // write header string
					INI_BUFFER[Cur_ini][e_Header_hash] = cur_header; // write header
					temp[ptr] = EOS;
					strset( INI_BUFFER[Cur_ini][e_Name_str], temp ); // write name string
					INI_BUFFER[Cur_ini][e_Name_hash] = fnv_hash( temp ); // write name
					strset( INI_BUFFER[Cur_ini][e_value_string], temp[ptr + 1] ); // write value
					if( ( ptr = strfind( INI_BUFFER[Cur_ini][e_value_string], "//" ) ) != -1 ) INI_BUFFER[Cur_ini][e_value_string][ptr] = EOS; // cut annotation
					Cur_ini++;
				}
			}
			fclose( hnd );
			for( new i = Cur_ini; i < MAX_INI_BUFFER; i++ ) INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID; //set invalid value
		}
	}
	return true;
}
//==========================================================
stock c_iniClose( )
{
	if( inimode != io_read ) // WRITE MODE
	{
		new temp[MAX_STRING], tname[129], i, len, File:ohnd, File:whnd, buf[1];
		for( i = 0, len = strlen( INI_NAME ) ; i < len ; i++ )  tname[i] = INI_NAME[i];
		tname[i] = '_';

		if( !fexist( INI_NAME ) )
		{
   			ohnd = fopen( tname, io_write );
			if(!ohnd)
			{
				print("[ERROR] Warning: Error Processing c_iniClose()");
				return false;
			}
			fclose(ohnd);
		}
		else
		{
			ohnd = fopen( INI_NAME, io_read );
			whnd = fopen( tname, io_write );
			if(!ohnd || !whnd)
			{
				print("[ERROR] Warning: Error Processing c_iniClose()");
				return false;
			}
			for ( i = flength( ohnd ) ; i > 0 ; i-- ) fputchar( whnd, fgetchar( ohnd, buf[0], false ), false );
			fclose( ohnd );
			fclose( whnd );
		}

		ohnd = fopen( tname, io_read );
		whnd = fopen( INI_NAME, io_write );
	    if(!ohnd || !whnd)
		{
			print("[ERROR] Warning: Error Processing c_iniClose()");
			return false;
		}

		new cur_header, header_temp[MAX_STRING], name_hash, start, infile;
	    while( fread( ohnd, temp ) )
	    {
	        StripNL( temp );
			if( temp[0] == '#' ) {}
			else if( temp[0] == '[' )
	        {
				strset( header_temp, temp );
				if( start )
				{
					infile = false;
					for( i = 0; i < Cur_ini; i++ )
					{
						if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == cur_header ) // 헤더만있고 값이 없는경우 !
						{
							INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID;
							format( temp, sizeof( temp ), "%s=%s\r\n", INI_BUFFER[i][e_Header_str], INI_BUFFER[i][e_Name_str]);
							c_fwrite( whnd, temp );
							infile = true;
						}
					}
					if( infile ) strset( temp, header_temp );
				}
				else start = 1;
				buf[0] = strfind( header_temp, "]" );
				header_temp[buf[0] + 1] = EOS; // cut annotation
				cur_header = fnv_hash( header_temp ); // write header
			}
			else if( (buf[0] = strfind( temp, "=" )) > 0 )
			{
				temp[buf[0]] = EOS; // cut value & anno.
				name_hash = fnv_hash( temp ); // write key
				temp[buf[0]] = '='; // restore value & anno.
				for( i = 0; i < Cur_ini; i++ )
				{
					if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == cur_header && INI_BUFFER[i][e_Name_hash] == name_hash )
					{
						INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID;
						new annotation[256], p;
						buf[0] = strfind( temp, "//" );
						if ( buf[0] != -1 ) for( p = buf[0], len = strlen( temp ) ; p < len ; p++ ) annotation[p  - buf[0]] = temp[p];
		                format( temp, sizeof( temp ), "%s=%s%s", INI_BUFFER[i][e_Name_str], INI_BUFFER[i][e_value_string], annotation);
						break;
					}
				}
			}
			format( temp, sizeof(temp), "%s\r\n", temp );
	        c_fwrite( whnd, temp );
	    }

		for( i = 0; i < Cur_ini; i++ )
		{
			if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED ) // 아직도 기록안된 경우 !
			{
				INI_BUFFER[i][e_Flag] = INI_FLAG_INVALID;
				if( INI_BUFFER[i][e_Header_hash] != cur_header ) // 헤더도 없는경우 !
				{
					format( temp, sizeof( temp ), "\r\n%s\r\n", INI_BUFFER[i][e_Header_str] );
					c_fwrite( whnd, temp );
					cur_header = INI_BUFFER[i][e_Header_hash];
				}
				format( temp, sizeof( temp ), "%s=%s\r\n", INI_BUFFER[i][e_Name_str], INI_BUFFER[i][e_value_string] );
				c_fwrite( whnd, temp );
			}
		}
	    fclose( whnd );
	    fclose( ohnd );
	    fremove( tname );
	}
	return true;
}
//==========================================================
stock c_iniSet( header[], key[], value[] )
{
	if( inimode == io_read )
	{
		print("[ERROR] Warning: Error Processing c_iniSet() : Read-only mode.");
		return false;
	}
	if( Cur_ini >= MAX_INI_BUFFER )
	{
		print("[ERROR] Warning: Error Processing c_iniSet() : BUFFER LIMIT EXCEEDED");
		return false;
	}
	new headerhash = fnv_hash( header );
	new keyhash = fnv_hash( key );
	if( inimode == io_readwrite )
	{
		new found;
		for( new i = 0; i < Cur_ini; i++ )
		{
			if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == headerhash && INI_BUFFER[i][e_Name_hash] == keyhash )
			{
				found = 1;
				strset( INI_BUFFER[i][e_value_string], value );
				break;
			}
		}
		if( found ) return true;
	}
	strset( INI_BUFFER[Cur_ini][e_Header_str], header );
	strset( INI_BUFFER[Cur_ini][e_Name_str], key );
	strset( INI_BUFFER[Cur_ini][e_value_string], value );
	INI_BUFFER[Cur_ini][e_Header_hash] = headerhash;
	INI_BUFFER[Cur_ini][e_Name_hash] = keyhash;
	INI_BUFFER[Cur_ini][e_Flag] = INI_FLAG_UNUSED;
	Cur_ini++;
	return true;
}
//==========================================================
stock c_iniIntSet( header[], key[], value )
{
	new valuestring[13];
	format( valuestring, sizeof(valuestring), "%d", value );
	return c_iniSet( header, key, valuestring );
}
//==========================================================
stock c_iniFloatSet( header[], key[], Float:value )
{
	new valuestring[13];
	format( valuestring, sizeof(valuestring), "%f", value );
	return c_iniSet( header, key, valuestring );
}
//==========================================================
stock c_iniBoolSet( header[], key[], bool:value )
{
	new valuestring[13];
	format( valuestring, sizeof(valuestring), "%d", value );
	return c_iniSet( header, key, valuestring );
}
//==========================================================
stock c_iniGet( header[], key[] )
{
	new result[MAX_STRING];
	new headerhash = fnv_hash( header );
	new keyhash = fnv_hash( key );
	for( new i = 0; i < Cur_ini; i++ )
	{
		if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == headerhash && INI_BUFFER[i][e_Name_hash] == keyhash )
		{
			strset( result, INI_BUFFER[i][e_value_string] );
			break;
		}
	}
	return result;
}
//==========================================================
stock c_iniInt( header[], key[] ) return strval( c_iniGet( header, key ) );
//==========================================================
stock Float:c_iniFloat(header[], key[] ) return floatstr(c_iniGet(header, key));
//==========================================================
stock bool:c_iniBool(header[], key[] ) return bool:strval(c_iniGet(header,key));
//==========================================================
stock c_iniUnSet( header[], key[] )
{
	new headerhash = fnv_hash( header );
	new keyhash = fnv_hash( key );
	for( new i = 0; i < Cur_ini; i++ )
	{
		if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == headerhash && INI_BUFFER[i][e_Name_hash] == keyhash )
		{
			INI_BUFFER[i][e_Flag] == INI_FLAG_INVALID;
			return true;
		}
	}
	return false;
}
//==========================================================
stock c_iniIsSet( header[], key[] )
{
	new headerhash = fnv_hash( header );
	new keyhash = fnv_hash( key );
	for( new i = 0; i < Cur_ini; i++ )
	{
		if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == headerhash && INI_BUFFER[i][e_Name_hash] == keyhash )
		{
			return true;
		}
	}
	return false;
}
//==========================================================
stock c_iniIsHeader( header[] )
{
	new headerhash = fnv_hash( header );
	for( new i = 0; i < Cur_ini; i++ )
	{
		if( INI_BUFFER[i][e_Flag] == INI_FLAG_UNUSED && INI_BUFFER[i][e_Header_hash] == headerhash )
		{
			return true;
		}
	}
	return false;
}

//==========================================================
stock INI_IntSet(file[],header[],key[],value)
{
    new str[13];
	format(str,sizeof(str),"%d",value);
	return INI_Set(file,header,key, str);
}
//==========================================================
stock INI_Int(file[],header[],key[]) return strval(INI_Get(file,header,key));
//==========================================================
stock INI_Set( file[], header[], key[], value[] )
{
    new temp[512], tname[129], i, len, File:ohnd, File:whnd, buf[1];
	for( i = 0, len = strlen( file ) ; i < len ; i++ )  tname[i] = file[i];
	tname[i] = '_';

	if( !fexist( file ) )
	{
		whnd = fopen( file, io_write );
		ohnd = fopen( tname, io_write );
		if(!ohnd || !whnd)
		{
			print("[ERROR] Warning: Error Processing INI_Set()");
			return false;
		}
		fclose(ohnd);
		fclose(whnd);
	}
	else
	{
		ohnd = fopen( file, io_read );
		whnd = fopen( tname, io_write );
		if(!ohnd || !whnd)
		{
			print("[ERROR] Warning: Error Processing INI_Set()");
			return false;
		}
		for ( i = flength( ohnd ) ; i > 0 ; i-- ) fputchar( whnd, fgetchar( ohnd, buf[0], false ), false );
		fclose( ohnd );
		fclose( whnd );
	}

	ohnd = fopen( tname, io_read );
	whnd = fopen( file, io_write );
    if(!ohnd || !whnd)
	{
		print("[ERROR] Warning: Error Processing INI_Set()");
		return false;
	}
	new bool:inheader, bool:infile;
	len = strlen( header );
    while( fread( ohnd, temp ) )
    {
        StripNL( temp );
        if( inheader )
        {
            if( temp[0] == '[' )
            {
                inheader = false;
                if( !infile )
                {
                    format( temp, sizeof( temp ), "%s=%s\r\n%s", key, value, temp );
                    infile = true;
                }
            }
			else if( temp[0] == key[0] && temp[len] == '=' && strcmp( temp, key, false, len ) == 0 )
            {
				new annotation[256];
				buf[0] = strfind( temp, "//" );
				if ( buf[0] != -1 ) for( i = buf[0], len = strlen( temp ) ; i < len ; i++ ) annotation[i  - buf[0]] = temp[i];
                format( temp, sizeof( temp ), "%s=%s%s", key, value, annotation);
                infile = true;
				inheader = false;
            }
        }
		else if( !infile && temp[0] == '[' && temp[len - 1] == ']' && strcmp( header, temp, false, len ) == 0 )
		{
			len = strlen( key );
			inheader = true;
		}
		format( temp, sizeof(temp), "%s\r\n", temp );
        c_fwrite( whnd, temp );
    }

    if( !infile )
    {
        if( !inheader )
        {
            format( temp, sizeof( temp ), "\r\n%s\r\n", header );
            c_fwrite( whnd, temp );
        }
        format( temp, sizeof( temp ), "%s=%s\r\n", key, value );
        c_fwrite( whnd, temp );
    }
    fclose( whnd );
    fclose( ohnd );
    fremove( tname );
	return true;
}
//==========================================================
stock INI_Get( file[], header[], key[] )
{
	new result[512], File:hnd;
	hnd = fopen( file, io_read );
	if(!hnd)
	{
		print("[ERROR] Warning: Error Processing INI_Get()");
		return result;
	}
	new temp[512], bool:inheader, len;
	len = strlen( header );
	while( fread( hnd, temp ) )
	{
		if( inheader )
		{
			if( temp[0] == '[' ) break;
			else if( temp[0] == key[0] && temp[len] == '=' && strcmp( temp, key, false, len ) == 0 )
			{
				StripNL( temp );
				new ptr = strfind( temp, "//" );
				strmid( result, temp, len + 1, ( ptr == -1 )? ( strlen( temp ) ):( ptr ) );
				break;
			}
		}
		else if( temp[0] == '[' && temp[len - 1] == ']' && strcmp( header, temp, false, len ) == 0 )
		{
			len = strlen( key );
			inheader = true;
		}
	}
	fclose( hnd );
	return result;
}
//==========================================================
stock Float:INI_Float(file[],header[],key[]) return floatstr(INI_Get(file,header,key));
//==========================================================
stock INI_FloatSet(file[],header[],key[],Float:value)
{
    new str[13];
	format(str,sizeof(str),"%f",value);
	return INI_Set(file,header,key,str);
}
//==========================================================
stock bool:INI_Bool(file[],header[],key[]) return bool:strval(INI_Get(file,header,key));
//==========================================================
stock INI_BoolSet(file[],header[],key[],bool:value)
{
   	new str[13];
	format(str,sizeof(str),"%d",value);
	return INI_Set(file,header,key, str);
}
//==========================================================
stock INI_UnSet(file[],header[],key[])
{
    new temp[512], tname[129], i, len, File:ohnd, File:whnd, buf[1];
	for( i = 0, len = strlen( file ) ; i < len ; i++ )  tname[i] = file[i];
	tname[i] = '_';

	if( !fexist( file ) )
	{
		whnd = fopen( file, io_write );
		ohnd = fopen( tname, io_write );
		if(!ohnd || !whnd)
		{
			print("[ERROR] Warning: Error Processing INI_UnSet()");
			return false;
		}
		fclose(ohnd);
		fclose(whnd);
	}
	else
	{

		ohnd = fopen( file, io_read );
		whnd = fopen( tname, io_write );
		if(!ohnd || !whnd)
		{
			print("[ERROR] Warning: Error Processing INI_UnSet()");
			return false;
		}
		for ( new i = flength( ohnd ) ; i > 0 ; i-- ) fputchar( whnd, fgetchar( ohnd, buf[0], false ), false );
		fclose( ohnd );
		fclose( whnd );
	}

	ohnd = fopen( tname, io_read );
	whnd = fopen( file, io_write );
    if(!ohnd || !whnd)
	{
		print("[ERROR] Warning: Error Processing INI_UnSet()");
		return false;
	}

	new bool:inheader, bool:dontwrite, bool:infile;
	len = strlen( header );
    while( fread( ohnd, temp ) )
    {
        StripNL( temp );
		dontwrite = false;
        if( inheader )
        {
            if( temp[0] == '[' )
			{
				inheader = false;
				infile = true;
			}
			else if( temp[0] == key[0] && temp[len] == '=' && strcmp( temp, key, false, len ) == 0 )
			{
				dontwrite = true;
				infile = true;
				inheader = false;
			}
        }
		else if( !infile && temp[0] == '[' && temp[len - 1] == ']' && strcmp( header, temp, false, len ) == 0 )
		{
			len = strlen( key );
			inheader = true;
		}
		if( !dontwrite )
		{
			format( temp, sizeof(temp), "%s\r\n", temp );
        	c_fwrite( whnd, temp );
		}
    }

    fclose( whnd );
    fclose( ohnd );
    fremove( tname );
	return true;
}
//==========================================================
stock INI_IsSet(file[],header[],key[])
{
	new isset, File:hnd;
	hnd = fopen( file, io_read );
	if(!hnd)
	{
		print("[ERROR] Warning: Error Processing INI_IsSet()");
		return isset;
	}
	new temp[512], bool:inheader, len;
	len = strlen( header );
	while( fread( hnd, temp ) )
	{
		if( inheader )
		{
			if( temp[0] == '[' ) break;
			else if( temp[0] == key[0] && temp[len] == '=' && strcmp( temp, key, false, len ) == 0 )
			{
				isset = true;
				break;
			}
		}
		else if( temp[0] == '[' && temp[len - 1] == ']' && strcmp( header, temp, false, len ) == 0 )
		{
			len = strlen( key );
			inheader = true;
		}
	}
	fclose( hnd );
	return isset;
}
//==========================================================
stock INI_IsHeader(file[],header[])
{
	new isheader, File:hnd;
	hnd = fopen( file, io_read );
	if(!hnd)
	{
		print("[ERROR] Warning: Error Processing INI_IsHeader()");
		return isheader;
	}
	new temp[512], len;
	len = strlen( header );
	while( fread( hnd, temp ) )
	{
		if( temp[0] == '[' && temp[len - 1] == ']' && strcmp( header, temp, false, len ) == 0 )
		{
			isheader = true;
			break;
		}
	}
	fclose( hnd );
	return isheader;
}
//==========================================================
stock INI_Add(file[],header[],key[],value=1) return c_iniIntSet(file,header,key,INI_Int(file,header,key) + value);
//==========================================================
stock INI_Sub(file[],header[],key[],value=1) return c_iniIntSet(file,header,key,INI_Int(file,header,key) - value);
//==========================================================
stock INI_FloatAdd(file[],header[],key[],Float:value=1.000000) return INI_FloatSet(file,header,key,floatadd(INI_Float(file,header,key),value));
//==========================================================
stock INI_FloatSub(file[],header[],key[],Float:value=1.000000)	return INI_FloatSet(file,header,key,floatsub(INI_Float(file,header,key),value));
#endif
//==========================================================
// Compression
//==========================================================
#if !defined _COOLGUY_NO_COMPRESS
//==========================================================
#define ARR(%1) ((%1) /  cellbits)
//==========================================================
#define ARG(%1) (1 << ((%1) % cellbits))
//==========================================================
#define ceildiv(%1,%2) ((((%1)+(%2))-1) / (%2))
//==========================================================
#define Bit_Bits(%1) (ceildiv((%1), cellbits))
//==========================================================
#define MAX_BPLAYERS Bit_Bits(MAX_PLAYERS)
//==========================================================
#define Bit_Get(%1,%2) ((%1[ARR(%2)] & Bit:ARG(%2)) ? 1 : 0)
//==========================================================
#define Bit_Let(%1,%2) %1[ARR(%2)] |= Bit:ARG(%2)
//==========================================================
#define Bit_Vet(%1,%2) %1[ARR(%2)] &= Bit:(~ARG(%2))
//==========================================================
stock Bit_Set(Bit:array[], slot, set, size = sizeof (array))
{
	if (slot / cellbits >= size) return;
	if (set) Bit_Let(array, slot);
	else Bit_Vet(array, slot);
}
//==========================================================
stock Bit_SetAll(Bit:array[], set, size = sizeof (array))
{
	new
		Bit:val = (set) ? (Bit:0xFFFFFFFF) : (Bit:0);
	for (new i = 0; i < size; i++) array[i] = val;
}
//==========================================================
stock Bit_GetCount(Bit:array[], size = sizeof (array))
{
	new
		count;
	for (new i = 0; i < size; i++) for (new j = 1; j; j <<= 1) if (array[i] & Bit:j) count++;
	return count;
}
//==========================================================
stock Bit_Reverse(Bit:array[], slot)
{
	if( Bit_Get( array, slot ) ) Bit_Vet( array, slot );
	else Bit_Let( array, slot );
}
//==========================================================
stock Bit_ReverseAll(Bit:array[],num = -1)
{
	new max=(num==-1? (*cellbits):(num));
	if(num/cellbits >= sizeof(array)) return;
	for (new i = 0; i < max; i++) Bit_Reverse(array,i);
}
#endif
//==========================================================
// Number & Calc
//==========================================================
#if !defined _COOLGUY_NO_MATH
#define PI 3.14159265
//==========================================================
stock minrand(min,max) return random(max - min) + min;
//==========================================================
stock TwoWayRand(value)	return random(value * 2 + 1) - value;
//==========================================================
stock Float:floatrand(max,depth=6)
{
	new floatdepth=1, i=depth;
	while(i){floatdepth*=10; --i;}
	return floatdiv(float(random(max*floatdepth)), float(floatdepth));
}
//==========================================================
stock Float:MinFloatrand(Float:min,Float:max) return floatrand(max - min) + min;
//==========================================================
stock Float:TwoWayFloatrand(Float:max) return floatrand(max * float(2) + float(1)) - max;
//==========================================================
#endif
//==========================================================
// ETC
//==========================================================
#define Beep() print("\a")
//==========================================================
stock Wait(time)
{
	new stamp = tickcount();
	while(tickcount() - stamp < time){}
}
//==========================================================
#define Crash() fread( File:0, "" )

//==========================================================
// Wasted & Developing in progress
//==========================================================

