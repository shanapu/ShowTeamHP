//includes
#include <cstrike>
#include <sourcemod>
#include <sdktools>
#include <autoexecconfig>

//Compiler Options
#pragma semicolon 1
#pragma newdecls required

//ConVars
ConVar gc_bPlugin;

//Handles
Handle CheckTimer;

//Booleans
bool ShowHP[MAXPLAYERS+1];

#define LoopValidClients(%1,%2,%3) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsValidClient(%1, %2, %3))

public Plugin myinfo =
{
	name = "ShowTeamHP",
	author = "shanapu",
	description = "Show health & name of teammates in HUD",
	version = "1.0",
	url = "shanapu.de"
};

public void OnPluginStart()
{
	// Translation
//	LoadTranslations("ShowTeamHP.phrases");
	RegConsoleCmd("sm_showhp", Command_ShowHP, "Toggle Show Teammates HP");
	
	//AutoExecConfig
	AutoExecConfig_SetFile("ShowTeamHP");
	AutoExecConfig_SetCreateFile(true);
	
	gc_bPlugin = AutoExecConfig_CreateConVar("sm_showteamhp_enable", "1", "0 - disabled, 1 - enable this SourceMod plugin", _, true,  0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile();
	AutoExecConfig_CleanFile();
}

public Action Timer_CheckView(Handle timer)
{
	LoopValidClients(client,true,false)
	{
		int Target = GetClientAimTarget(client, true);
		
		if(IsValidClient(Target,true,false) && ShowHP[client])
		{
			int TargetHP = GetClientHealth(Target);
			
			if(GetClientTeam(Target) == GetClientTeam(client))
			{
				PrintHintText(client,"<font face='Arial' size='26'>Player</font>  <font size='28' color='#00FF00'>%N</font> \n<font face='Arial' size='26'>HP:</font>  <font size='28' color='#FF0000'>%i</font>", Target, TargetHP);
			}
		}
	}
}


public Action Command_ShowHP(int client,int args)
{
	if(ShowHP[client])
	{
		ShowHP[client] = false;
	}
	else ShowHP[client] = true;
}

public void OnClientPutInServer(int client)
{
	ShowHP[client] = true;
}

public void OnMapStart()
{
	if (gc_bPlugin.BoolValue) CheckTimer = CreateTimer (0.25, Timer_CheckView, _, TIMER_REPEAT);
}

public void OnMapEnd()
{
	delete CheckTimer;
}

stock bool IsValidClient(int client, bool bAllowBots = false, bool bAllowDead = true)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bAllowBots) || IsClientSourceTV(client) || IsClientReplay(client) || (!bAllowDead && !IsPlayerAlive(client)))
	{
		return false;
	}
	return true;
}