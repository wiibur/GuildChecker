local TOCNAME, core = ...;

--------------------------------------
-- Custom Slash Command
--------------------------------------
core.commands = {
  ["show"] = core.GuildChecker.Toggle, -- this is a function (no knowledge of Config object)

  ["help"] = function()
    print(" ");
    core:Print("List of slash commands:")
    core:Print("|cff00cc66/at config|r - shows config menu");
    core:Print("|cff00cc66/at help|r - shows help info");
    print(" ");
  end,

  ["example"] = {
    ["test"] = function(...)
      core:Print("My Value:", tostringall(...));
    end
  }
};

local function HandleSlashCommands(str)
  if (#str == 0) then
    -- User just entered "/at" with no additional args.
    core.commands.help();
    return;
  end

  local args = {};
  for _, arg in ipairs({ string.split(' ', str) }) do
    if (#arg > 0) then
      table.insert(args, arg);
    end
  end

  local path = core.commands; -- required for updating found table.

  for id, arg in ipairs(args) do
    if (#arg > 0) then -- if string length is greater than 0.
      arg = arg:lower();
      if (path[arg]) then
        if (type(path[arg]) == "function") then
          -- all remaining args passed to our function!
          path[arg](select(id + 1, unpack(args)));
          return;
        elseif (type(path[arg]) == "table") then
          path = path[arg]; -- another sub-table found!
        end
      else
        -- does not exist!
        core.commands.help();
        return;
      end
    end
  end
end

function core:Print(...)
    local hex = select(4, self.GuildChecker:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), "[GuildChecker]");
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

function core:init()
  SLASH_GUILDCHECKER1 = '/guildchecker';
  SLASH_GUILDCHECKER2 = '/GUILDCHECKER';
  local function handler(msg, editBox)
    if msg == '' then
      core.GuildChecker:Toggle();
      if core.GuildChecker:IsShown() then
        --core:Print("Debug: user wanted to open guildchecker")
        core.GuildChecker:SetIntentionallyOpened(true) --user wanted to open this to mess with options or look at About tab, don't close it until they want to close it, even if they aren't in a group
      end
    end
    
    if msg == 'test' then
      --TODO: write a function to create raid test data (40 player rows)
    end
  end
  SlashCmdList["GUILDCHECKER"] = handler;
  
  core.GuildChecker:CreateGuildChecker();
  if GuildCheckerFirstTimeRun then
    core.GuildChecker:Show()
  end
  --core.GuildChecker:Toggle();
  
  --[[ don't need to print this anymore, can probably delete this code
  --print current UserBlacklist
  if UserBlacklist and #UserBlacklist > 0 then
    blacklistStr = ""
    for k,v in pairs(UserBlacklist) do
      if k == #UserBlacklist then
        blacklistStr = blacklistStr .. v
      else
        blacklistStr = blacklistStr .. v .. ", "
      end
    end
    core:Print("Blacklist: " .. blacklistStr)
  else
    core:Print("No UserBlacklist to load.")
  end
  ]]
  core:Print(TOCNAME .. " addon has been fully loaded.");
end

local function OnEvent(self, event, ...)
    if event == "ADDON_LOADED" and ... == TOCNAME then
      if GuildCheckerFirstTimeRun == nil then
        GuildCheckerFirstTimeRun = true;
      end
      
      core.init();
      core.GuildChecker:RosterUpdate();
    end

    if event == "GROUP_ROSTER_UPDATE" then
      core.GuildChecker:RosterUpdate();
    end

    if event == "CHAT_MSG_SYSTEM" then
      core.GuildChecker:ParseSystemMessage(...);
    end
  --[[
    if event == "NAME_PLATE_UNIT_ADDED" then
      core.GuildChecker:ParseNamplates(...);
    end
  ]]
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:RegisterEvent("GROUP_ROSTER_UPDATE");
events:RegisterEvent("CHAT_MSG_SYSTEM");
events:RegisterEvent("NAME_PLATE_UNIT_ADDED");
events:SetScript("OnEvent",OnEvent);
