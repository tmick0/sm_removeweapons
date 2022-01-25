#include <sourcemod>
#include <sdktools_functions>

#pragma newdecls required

#define MAX_SLOTS 6

public Plugin myinfo =
{
    name = "removeweapons",
    author = "tmick0",
    description = "Removes weapons of targeted users",
    version = "0.1",
    url = "github.com/tmick0/sm_removeweapons"
};

#define CMD_REMOVEWEAPONS "sm_removeweapons"

public void OnPluginStart() {
    LoadTranslations("common.phrases");
    RegAdminCmd(CMD_REMOVEWEAPONS, CmdRemoveWeapons, ADMFLAG_GENERIC, "remove weapons of the target");
}

Action CmdRemoveWeapons(int client, int argc) {
    if (GetCmdArgs() != 1) {
        ReplyToCommand(client, "usage: %s <target>", CMD_REMOVEWEAPONS);
        return Plugin_Handled;
    }

    char arg[128];
    GetCmdArg(1, arg, sizeof(arg));

    int targets[64];
    char name[256];
    bool ml;
    int count = ProcessTargetString(arg, client, targets, sizeof(targets), 0, name, sizeof(name), ml);

    if (count <= 0) {
        ReplyToTargetError(client, count);
        return Plugin_Handled;
    }

    int removed = 0;
    for (int i = 0; i < count; ++i) {
        if (IsClientConnected(targets[i]) && IsClientInGame(targets[i]) && IsPlayerAlive(targets[i])) {
            for (int j = 0; j < MAX_SLOTS; ++j) {
                int weapon = GetPlayerWeaponSlot(targets[i], j);
                if (weapon > 0) {
                    RemovePlayerItem(targets[i], weapon);
                }
            }
            ++removed;
        }
    }

    if (count > 1) {
        ReplyToCommand(client, "Removed weapons from %s", name);
    }
    else {
        ReplyToCommand(client, "Removed weapons from %d players", removed);
    }

    return Plugin_Handled;
}
