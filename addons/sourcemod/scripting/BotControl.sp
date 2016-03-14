#define nDEBUG 1
#define PLUGIN_NAME  "BotSlay"
#define PLUGIN_VERSION "1.6"
#include "k64t"
#pragma semicolon 1
//*****************************************************************************
public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = "K64t",
	description = "Slay bots after all human players killed",
	version = PLUGIN_VERSION,
	url = ""
};
//*****************************************************************************
#define ARRAY_SIZE 40
#define MAX_STRING 512

#define T_TEAM 2
#define CT_TEAM 3

#define iT 0
#define iCT 1
new k_noBot_Count[2]={0,0};
new ROUND_END=0;
new Handle:BotTimer=INVALID_HANDLE;
new TeamLastPlayer;
new userid;
//*****************************************************************************
public OnPluginStart(){	
//*****************************************************************************
HookEvent("round_start", EventRoundStart);
HookEvent("round_end", EventRoundEnd);
HookEvent("player_death", EventPlayerDeath);
}
//*****************************************************************************
public EventPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast){
//*****************************************************************************
#if defined DEBUG 	
PrintToChatAll("PlayerDeath. k_noBot_Count %d = %d, k_noBot_Count %d = %d",iT,k_noBot_Count[iT],iCT,k_noBot_Count[iCT]);
#endif 
if (ROUND_END) return;

userid=GetClientOfUserId(GetEventInt(event, "userid"));
#if defined DEBUG	
decl String:PName[64];
GetClientName(userid, PName, sizeof(PName));
PrintToChatAll("PlayerDeath. userid=%d %s",userid,PName);
#endif
if (!IsFakeClient(userid))
	{
	#if defined DEBUG
	PrintToChatAll("PlayerDeath. This is not a bot.");
	#endif
	new iuserTeam=0;
	TeamLastPlayer = GetClientTeam(userid);
	#if defined DEBUG
	PrintToChatAll("PlayerDeath. TeamLastPlayer=%d.",TeamLastPlayer);
	#endif
	if (TeamLastPlayer==T_TEAM)
		iuserTeam=iT;
	else if (TeamLastPlayer==CT_TEAM)
		iuserTeam=iCT;
	#if defined DEBUG
	PrintToChatAll("PlayerDeath. iuserTeam=%d.",iuserTeam);
	#endif
		
	if 	(TeamLastPlayer==2 || TeamLastPlayer==3)
		{
		k_noBot_Count[iuserTeam]--;
		#if defined DEBUG
		PrintToChatAll("PlayerDeath. k_noBot_Count %d=%d",iuserTeam,k_noBot_Count[iuserTeam]);
		#endif			
		if (k_noBot_Count[iuserTeam]==0)
			{
			#if defined DEBUG
			PrintToChatAll("PlayerDeath. Start Timer");
			#endif	
			ROUND_END=1;				
			BotTimer=CreateTimer(1.0,_SlayBots,_,TIMER_REPEAT);
			#if defined DEBUG 
			if (BotTimer==INVALID_HANDLE) PrintToChatAll("INVALID_HANDLE");
			else PrintToChatAll("Timer HNDL = %u",BotTimer);
			#endif				
			}		
		}
	}	
}
//*****************************************************************************
public EventRoundEnd(Handle:event, const String:name[], bool:dontBroadcast){
//*****************************************************************************
ROUND_END=1;
#if defined DEBUG 	
PrintToChatAll("Round End");
#endif		
//if (ROUND_END) 	
#if defined DEBUG 	{
PrintToChatAll("BotTimer=%u %i",BotTimer,BotTimer);
if (BotTimer==INVALID_HANDLE) PrintToChatAll("BotTimer==INVALID_HANDLE");
else PrintToChatAll("BotTimer NOT INVALID_HANDLE");
#endif		

//	if (BotTimer!=INVALID_HANDLE) KillTimer(BotTimer);	
	if (BotTimer!=INVALID_HANDLE) 
		{
		CloseHandle(BotTimer);
		BotTimer=INVALID_HANDLE;
		}
//	}
#if defined DEBUG 	{
PrintToChatAll("BotTimer=%u %i",BotTimer,BotTimer);
if (BotTimer==INVALID_HANDLE) PrintToChatAll("BotTimer==INVALID_HANDLE");
else PrintToChatAll("BotTimer NOT INVALID_HANDLE");
#endif		

}
//*****************************************************************************
public  Action:myForcePlayerSuicide(Handle:Timer,any:client){
//*****************************************************************************
//if (IsPlayerAlive(client)) ForcePlayerSuicide(client);
Explode_Player(client);
}
//*****************************************************************************
public  Action:_SlayBots(Handle:Timer,any:vars){
//*****************************************************************************
#if defined DEBUG 	
PrintToServer("SlayBots");
PrintToChatAll("SlayBots");
#endif		

decl newHealth,i;
for ( i = 1; i<=MaxClients ; i++)
	{		
	if (!IsValidClient(i)) continue;
	if (IsFakeClient(i)) if (IsPlayerAlive(i)) if (TeamLastPlayer==GetClientTeam(i))
		{			
		decl String:PName[64];
		GetClientWeapon(i,PName,64);
		#if defined DEBUG
		PrintToChatAll("weapon %s ",PName);
		#endif	
		if (strcmp(PName,"weapon_knife",false)!=0)
			{
			newHealth=GetRandomInt(0,GetClientHealth(i)-1);		
			GetClientName(i, PName, sizeof(PName));
			#if defined DEBUG 	
			PrintToChatAll("health of %s is %d",PName,GetClientHealth(i));
			PrintToServer("health of %s is %d",PName,GetClientHealth(i));
			#endif		
			
			if (newHealth<=1)
				{
				new frag=GetClientFrags(i)+1;
				new death=GetClientDeaths(i)-1;
				#if defined DEBUG 	
				PrintToChatAll("SetEntProp(i, Prop_Data, m_iFrags, frag, 4);");    	
				PrintToServer("SetEntProp(i, Prop_Data, m_iFrags, frag, 4);");    	
				#endif	
				SetEntProp(i, Prop_Data, "m_iFrags", frag, 4);
				SetEntProp(i, Prop_Data, "m_iDeaths", death, 4);
				#if defined DEBUG 	
				PrintToChatAll("ForcePlayerSuicide");
				PrintToServer("ForcePlayerSuicide");
				#endif
				CreateTimer(1.0,myForcePlayerSuicide, i);				
				}
			else
				SetClientHealth(i,newHealth);
			}	
		}	
	}	
#if defined DEBUG 	
PrintToServer("end SlayBots");
PrintToChatAll("end SlayBots");
#endif		
	
}

//*****************************************************************************
public EventRoundStart(Handle:event, const String:name[], bool:dontBroadcast){
//*****************************************************************************
#if defined DEBUG 	
PrintToChatAll("RoundStart");
#endif	
#if defined DEBUG 	
PrintToChatAll("BotTimer=%u %i",BotTimer,BotTimer);
if (BotTimer==INVALID_HANDLE) PrintToChatAll("BotTimer==INVALID_HANDLE");
else PrintToChatAll("BotTimer NOT INVALID_HANDLE");
#endif		

k_noBot_Count[iT]=0;
k_noBot_Count[iCT]=0;
ROUND_END=0;
new i=1;
for (i=1; i<=MaxClients; i++)
	{
	if (!IsValidClient(i)) continue;
	if (!IsFakeClient(i)) if (IsPlayerAlive(i))
		{
		TeamLastPlayer=GetClientTeam(i);
		#if defined DEBUG 	
		PrintToChatAll("Round Start. GetClientTeam(%d)=%d not a bot",i,TeamLastPlayer);
		#endif
		if (TeamLastPlayer==T_TEAM)
			k_noBot_Count[iT]++;
		else if (TeamLastPlayer==CT_TEAM)
			k_noBot_Count[iCT]++;
		}	
	}		
#if defined DEBUG 	
PrintToChatAll("Round Start. k_noBot_Count %d = %d, k_noBot_Count %d = %d",iT,k_noBot_Count[iT],iCT,k_noBot_Count[iCT]);
#endif
}