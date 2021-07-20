local TOCNAME,core = ...

core.GuildChecker = {};
local GuildChecker = core.GuildChecker;
local GuildCheckerFrame;
local child;
local content1, content2, content3;
local allowedGuildsListFontString;
local blacklistedPlayersFontString;
local intentionallyOpened;

allowedGuilds={}
UserBlacklist={}
core.PatternWho1=core.Tool.CreatePattern(WHO_LIST_FORMAT )
core.PatternWho2=core.Tool.CreatePattern(WHO_LIST_GUILD_FORMAT )
core.PatternOnline=core.Tool.CreatePattern(ERR_FRIEND_ONLINE_SS)
--Defaults
local defaults = {
  theme = {
    r = 0,
    g = 0.8,
    b = 1,
    hex = "00ccff"
  },
  offline = {0.5,0.5,0.5},
  unknown = {0.7,0.7,1},
  unguilded = {1,0,0},
  approved = {0,1,0},
  notapproved = {1,0,0},
  blacklisted = {1,0,0}
}


-- local Functions -------------------------------------------------------------------------------------------------------------
local function ScrollFrame_OnMouseWheel(self, delta)
  local newValue = self:GetVerticalScroll() - (delta * 20);

  if (newValue < 0) then
    newValue = 0;
  elseif (newValue > self:GetVerticalScrollRange()) then
    newValue = self:GetVerticalScrollRange();
  end

  self:SetVerticalScroll(newValue);
end

local function newStack()
  return {""}   -- starts with an empty string
end

local function addString(stack, s)
  table.insert(stack, s)    -- push 's' into the the stack
  for i=table.getn(stack)-1, 1, -1 do
    if string.len(stack[i]) > string.len(stack[i+1]) then
      break
    end
    stack[i] = stack[i] .. table.remove(stack)
  end
end

local function addGuild()

  local guilds = core.Tool.Split(UpdateApprovalListBox:GetText(), ",");

  for i,guild in pairs(guilds) do
    guild = string.gsub(guild, '^%s*(.-)%s*$', '%1');
    if guild == "" or string.upper(guild) == string.upper("Enter Guild Name(s)") then
      core:Print("Guild name cannot be blank.");
      return
    end
    for k,v in pairs(allowedGuilds) do
      if string.upper(guild) == string.upper(v) then
        core:Print("The guild |cff00FF00".. guild .. "|r already exists in whitelist.");
        GuildChecker:RosterUpdate();
        return
      end
    end

    tinsert(allowedGuilds,guild);
    core:Print("The guild |cff00FF00" .. guild .. "|r has been added to the whitelist.")
    UpdateApprovalListBox:ClearFocus();
    --UpdateApprovalListBox:SetText("");

    GuildChecker:RosterUpdate();
    allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
  end
end

local function removeGuild()
  local guilds = core.Tool.Split(UpdateApprovalListBox:GetText(),",");
  for i,guild in pairs(guilds) do
    guild = string.gsub(guild, '^%s*(.-)%s*$', '%1');
    if guild == "" or string.upper(guild) == string.upper("Enter Guild Name(s)") then
      core:Print("Guild name cannot be blank.");
      return
    end

    for k,v in pairs(allowedGuilds) do
      if string.upper(guild) == string.upper(v) then
        tremove(allowedGuilds,k)
        core:Print("The guild |cff00FF00" .. v .. "|r has been removed from the whitelist.");
      end
    end
    UpdateApprovalListBox:ClearFocus();
    GuildChecker:RosterUpdate();
    allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
  end
end

local function clearList()
  if #allowedGuilds > 0 then
    allowedGuilds = {}
    core:Print("Guild whitelist has been reset.");
    GuildChecker:RosterUpdate();
    allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
  end
end

local function addBlacklist()
  local usernames = core.Tool.Split(BlacklistEditBox:GetText(),",");

  for i,username in pairs(usernames) do
    username = string.gsub(username, '^%s*(.-)%s*$', '%1');
    if username == "" or string.upper(username) == string.upper("Enter Player Name(s)") then
      core:Print("Player name cannot be blank.");
      return
    end
    for k,v in pairs(UserBlacklist) do
      if string.upper(username) == string.upper(v) then
        core:Print("The player |cffFF0000" .. v .. "|r already exists in blacklist.")
        GuildChecker:RosterUpdate();
        return
      end
    end
    tinsert(UserBlacklist,username)
    core:Print("The player |cffFF0000" .. username .. "|r has been added to the blacklist.")
    BlacklistEditBox:ClearFocus();
    --BlacklistEditBox:SetText("");
    GuildChecker:RosterUpdate();
    if UserBlacklist and #UserBlacklist > 0 then
      blacklistStr = ""
      for k,v in pairs(UserBlacklist) do
        if k == #UserBlacklist then
          blacklistStr = blacklistStr .. v
        else
          blacklistStr = blacklistStr .. v .. ", "
        end
      end
      --core:Print("Blacklist: " .. blacklistStr)
    else
      --core:Print("No blacklist contents to load.")
    end
    blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
  end
end

local function removeBlacklist()
  local usernames = core.Tool.Split(BlacklistEditBox:GetText(),",");
  for i,username in pairs(usernames) do
    username = string.gsub(username, '^%s*(.-)%s*$', '%1');
    if username == "" or string.upper(username) == string.upper("Enter Player Name(s)") then
      core:Print("Player name cannot be blank.");
      return
    end
    for k,v in pairs(UserBlacklist) do
      if string.upper(username) == string.upper(v) then
        core:Print("The player |cffFF0000".. v .. "|r has been removed from blacklist.")
        tremove(UserBlacklist,k)
        BlacklistEditBox:ClearFocus();
        --BlacklistEditBox:SetText("");
        GuildChecker:RosterUpdate();
        if UserBlacklist and #UserBlacklist > 0 then
          blacklistStr = ""
          for k,v in pairs(UserBlacklist) do
            if k == #UserBlacklist then
              blacklistStr = blacklistStr .. v
            else
              blacklistStr = blacklistStr .. v .. ", "
            end
          end
          --core:Print("Blacklist: " .. blacklistStr)
        else
          --core:Print("No blacklist contents to load.")
        end
      end
    end
    blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
  end
end

local function clearBlacklist()
  if #UserBlacklist > 0 then
    UserBlacklist = {}
    GuildChecker:RosterUpdate();
    core:Print("Player blacklist has been reset.")
    blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
  end
end

local function Tab_OnClick(self)
  PanelTemplates_SetTab(self:GetParent(), self:GetID());

  local scrollChild = GuildCheckerFrame.ScrollFrame:GetScrollChild();
  if (scrollChild) then
    scrollChild:Hide();
  end

  GuildCheckerFrame.ScrollFrame:SetScrollChild(self.content);
  GuildCheckerFrame.ScrollFrame:SetVerticalScroll(0);

  self.content:Show();

  if self:GetID() == 1 then
    --TODO:write function showContent1Buttons() and hideContent1Buttons()
    GuildCheckerFrame.RosterUpdateButton:Show();
  else
    GuildCheckerFrame.RosterUpdateButton:Hide();
  end

  if self:GetID() == 3 then
    --TODO:write function showContent1Buttons() and hideContent1Buttons()
    GuildCheckerFrame.createdByMessage:Show();
  else
    GuildCheckerFrame.createdByMessage:Hide();
  end



  --core:Print("self.content:GetID() = "..self:GetID());
end

local function SetTabs(frame,numTabs,...)
  frame.numTabs = numTabs;

  local contents = {};
  local frameName = frame:GetName();

  for i = 1, numTabs do
    local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
    tab:SetID(i);
    tab:SetText(select(i, ...));
    tab:SetScript("OnClick", Tab_OnClick);

    tab.content = CreateFrame("Frame", nil, GuildCheckerFrame.ScrollFrame);
    tab.content:SetSize(455, 700);
    tab.content:Hide();

    --[[ just for tutorial only:
    tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
    tab.content.bg:SetAllPoints(true);
    tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);
    ]]
    table.insert(contents, tab.content);

    if (i == 1) then
      tab:SetPoint("TOPLEFT", GuildCheckerFrame, "BOTTOMLEFT", 5, 2);
    else
      tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -14, 0);
    end
  end

  if GuildCheckerFirstTimeRun then
    --core:Print("Debug: first time run, showing about tab")
    Tab_OnClick(_G[frameName.."Tab3"]);
    GuildCheckerFirstTimeRun = false;
  else
    --core:Print("Debug: not first time run, showing players tab")
    Tab_OnClick(_G[frameName.."Tab1"]);
  end

  return unpack(contents);
end

local function GetPlayersList()
  local plist={}

  if IsInRaid() then
      for i=1,40 do
          if (UnitName('raid'..i)) then
              tinsert(plist,(UnitName('raid'..i)))
          end
      end
  elseif IsInGroup() then
      for i=1,4 do
          if (UnitName('party'..i)) then
              tinsert(plist,(UnitName('party'..i)))
          end
      end
      tinsert(plist,(UnitName('player')))
  end
  
  return plist;
end

local function PlayerIsInGroup(name)
  local playerIsInGroup = false;

  for k,v in pairs(GetPlayersList()) do
    if string.upper(v) == string.upper(name) then
      playerIsInGroup = true;
    end
  end
  return playerIsInGroup;
end

local function PlayerIdInGroup(name)
  local playerIdInGroup;

  for k,v in pairs(GetPlayersList()) do
    if string.upper(v) == string.upper(name) then
      playerIdInGroup = k;
    end
  end
  return playerIdInGroup;
end

local function GuildIsApproved(name)
  local guildIsApproved = false;

  for k,v in pairs(allowedGuilds) do
    if string.upper(v) == string.upper(name) then
      guildIsApproved = true;
    end
  end
  return guildIsApproved;
end

local function PlayerIsBlacklisted(name)
  local blacklisted = false;
  for k,v in pairs(UserBlacklist) do
    if string.upper(name) == string.upper(v) then
      core:Print("Player |cffFF0000" .. v .. "|r is blacklisted and flagged for removal (click Update button).");
      blacklisted = true;
    end
  end
  return blacklisted;
end

local function SetTextColor(fontString,hex)
  fontString:SetTextColor(unpack(hex))
end

local function ExistingFrameIdForPlayer(playerName)
  local id = 0;
  
  for i=1,#GuildCheckerFrame.playerNames do
    if string.upper(playerName) == string.upper(GuildCheckerFrame.playerNames[i]:GetText()) and GuildCheckerFrame.playerNames[i]:IsShown() then
      id = i
    end
  end
  
  return id;
end

local function RemovePlayer(i)
  --core:Print("Debug: RemovePlayer at index i = " .. i .. GuildCheckerFrame.playerNames[i]:GetText())
  GuildCheckerFrame.playerNames[i]:SetText("");
  GuildCheckerFrame.playerGuilds[i]:SetText("");
  
  GuildCheckerFrame.validatebuttons[i]:Enable();
  GuildCheckerFrame.kickbuttons[i]:Enable();
  GuildCheckerFrame.blacklistbuttons[i]:Enable();
  
  GuildCheckerFrame.playerNames[i]:ClearAllPoints();
  GuildCheckerFrame.playerGuilds[i]:ClearAllPoints();
  GuildCheckerFrame.validatebuttons[i]:ClearAllPoints();
  GuildCheckerFrame.kickbuttons[i]:ClearAllPoints();
  GuildCheckerFrame.blacklistbuttons[i]:ClearAllPoints();
  
  GuildCheckerFrame.validatebuttons[i]:Hide();
  GuildCheckerFrame.kickbuttons[i]:Hide();
  GuildCheckerFrame.blacklistbuttons[i]:Hide();
  
  
    
  tinsert(GuildCheckerFrame.emptyPlayerNames, GuildCheckerFrame.playerNames[i])
  tinsert(GuildCheckerFrame.emptyPlayerGuilds, GuildCheckerFrame.playerGuilds[i])
  tinsert(GuildCheckerFrame.emptyValidatebuttons, GuildCheckerFrame.validatebuttons[i])
  tinsert(GuildCheckerFrame.emptyKickbuttons, GuildCheckerFrame.kickbuttons[i])
  tinsert(GuildCheckerFrame.emptyBlacklistbuttons, GuildCheckerFrame.blacklistbuttons[i])
    
  tremove(GuildCheckerFrame.playerNames, i)
  tremove(GuildCheckerFrame.playerGuilds, i)
  tremove(GuildCheckerFrame.validatebuttons, i)
  tremove(GuildCheckerFrame.kickbuttons, i)
  tremove(GuildCheckerFrame.blacklistbuttons, i)
end

local function GetExistingEmptyPlayerNameFrameId()
  local frameId = 0
  
  
  
  return frameId
end

local function ShowPlayer(i)
  GuildCheckerFrame.playerNames[i]:Show();
  GuildCheckerFrame.playerGuilds[i]:Show();
  GuildCheckerFrame.validatebuttons[i]:Show();
  GuildCheckerFrame.kickbuttons[i]:Show();
  GuildCheckerFrame.blacklistbuttons[i]:Show();
end

local function GetGuildForPlayer(playerName)
  local guildName, guildRankName, guildRankIndex = GetGuildInfo(playerName)
  
  if guildName == nil then
    local existingFrameId = ExistingFrameIdForPlayer(playerName)
    --core:Print("Debug: existingFrameId = " .. existingFrameId)
    if existingFrameId > 0 then
      local fontStringText = GuildCheckerFrame.playerGuilds[existingFrameId]:GetText()
    
      if fontStringText ~= nil and fontStringText ~= "" and fontStringText ~= "UNGUILDED" then
        guildName=string.sub(fontStringText,3,#fontStringText-1); --need to trim the angle brackets off this string
      elseif fontStringText == "UNGUILDED" then
        guildName = fontStringText
      else
        guildName = ""
      end
    end  
  end

  return guildName
end

local function UpdatePlayerColor(id)
  local playerName = GuildCheckerFrame.playerNames[id]:GetText()
  local guildName = GetGuildForPlayer(playerName)
  --core:Print("Debug: UpdatePlayerColor(): playerName = " .. playerName .. ", guildName = " .. guildName)
  if not UnitIsConnected(playerName) then
    --core:Print("Debug: UpdatePlayerColor(): offline player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.offline);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.offline);
    GuildCheckerFrame.validatebuttons[id]:Disable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  elseif string.upper(guildName) == "UNGUILDED" then
    --core:Print("Debug: UpdatePlayerColor(): unguilded player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.unguilded);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.unguilded);
    GuildCheckerFrame.validatebuttons[id]:Disable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  elseif GuildIsApproved(guildName) then
    --core:Print("Debug: UpdatePlayerColor(): guild is approved for player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.approved);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.approved);
    GuildCheckerFrame.validatebuttons[id]:Disable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  elseif guildName ~= "" and not GuildIsApproved(guildName) then
    --core:Print("Debug: UpdatePlayerColor(): guild is not approved for player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.notapproved);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.notapproved);
    GuildCheckerFrame.validatebuttons[id]:Disable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  elseif PlayerIsBlacklisted(playerName) then
    --core:Print("Debug: UpdatePlayerColor(): blacklisted player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.blacklisted);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.blacklisted);
    GuildCheckerFrame.validatebuttons[id]:Enable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  else
    --unknown
    --core:Print("Debug: UpdatePlayerColor(): guild is unknown for player " .. playerName)
    SetTextColor(GuildCheckerFrame.playerNames[id], defaults.unknown);
    SetTextColor(GuildCheckerFrame.playerGuilds[id], defaults.unknown);
    GuildCheckerFrame.validatebuttons[id]:Enable();
    GuildCheckerFrame.kickbuttons[id]:Enable();
    GuildCheckerFrame.blacklistbuttons[id]:Enable();
  end
  
  if guildName ~= "" and guildName ~= "UNGUILDED" then
    GuildCheckerFrame.playerGuilds[id]:SetText(" <" .. guildName .. ">")
  else
    GuildCheckerFrame.playerGuilds[id]:SetText(guildName)  
  end
end

local function GetShownPlayersList()
  local shownPlayers = {}
  
  for i=1,#GuildCheckerFrame.playerNames do
    if GuildCheckerFrame.playerNames[i]:IsShown() then
      tinsert(shownPlayers,GuildCheckerFrame.playerNames[i])
    end
  end
  
  return shownPlayers
end

local function GetBlacklistedPlayersList()
  local shownPlayersList = GetShownPlayersList();
  local blacklistedPlayersList = GetShownPlayersList();
  
  for i=1,#shownPlayersList do
    shownPlayerName = shownPlayersList[i]:GetText()
    if PlayerIsBlacklisted(shownPlayerName) then
      tinsert(blacklistedPlayersList,shownPlayerName)
    end
  end  
  
  return blacklistedPlayersList
end

local function GetUnapprovedGuildPlayersList()
  local shownPlayersList = GetShownPlayersList();
  local unapprovedGuildPlayersList = {}
  
  for i=1,#shownPlayersList do
    shownPlayerName = shownPlayersList[i]:GetText()
    if not GuildIsApproved(shownPlayerName) then
      tinsert(unapprovedGuildPlayersList,shownPlayerName)
    end
  end  
  
  return unapprovedGuildPlayersList
end

local function GetUnguildedPlayersList()
  local shownPlayersList = GetShownPlayersList();
  local unguildedPlayersList = {}
  
  for i=1,#shownPlayersList do
    shownPlayerName = shownPlayersList[i]:GetText()
    if ShownPlayerIsUnguilded(shownPlayerName) then
      tinsert(unguildedPlayersList,shownPlayerName)
    end
  end  
  
  return unguildedPlayersList
end

local function ShownPlayerIsUnguilded(name)
  --TODO
  local shownPlayersList = GetShownPlayersList();
  local unguilded = false;
  
  for i=1,#shownPlayersList do
    shownGuildName=string.sub(shownPlayersList[i]:GetText(),3,#shownPlayersList[i]:GetText()-1);
    if shownGuildName == "UNGUILDED" then
      unguilded = true;
    end
  end  
  
  return unguilded
end

local function SortPlayersList()
  --TODO: this function sorts the current list of player fontstrings and puts at the top those users that are blacklisted, have an unapproved guild, or are unguilded
  
end

local function SwapPlayers(existingFrameId, currentPlayersIndex)
  --core:Print("Debug: SwapPlayers(): swapping existingFrameId= "..existingFrameId.." into currentPlayersIndex="..currentPlayersIndex)
  local tempName, tempGuild, tempKickButton, tempValidateButton, tempBlacklistButton
  --if originalPlayerId ~= PlayerIdInGroup(GuildCheckerFrame.playerNames[originalPlayerId]:GetText()) then
  --HidePlayer(originalPlayerId)
  --end
  --save the original player data if the player is in the group
  
  tempName = GuildCheckerFrame.playerNames[currentPlayersIndex]
  tempGuild = GuildCheckerFrame.playerGuilds[currentPlayersIndex]
  tempKickButton = GuildCheckerFrame.kickbuttons[currentPlayersIndex]
  tempValidateButton = GuildCheckerFrame.validatebuttons[currentPlayersIndex] 
  tempBlacklistButton = GuildCheckerFrame.blacklistbuttons[currentPlayersIndex]

  
  
  --swap new player data into original slot
  GuildCheckerFrame.playerNames[currentPlayersIndex] = GuildCheckerFrame.playerNames[existingFrameId]
  GuildCheckerFrame.playerGuilds[currentPlayersIndex] = GuildCheckerFrame.playerGuilds[existingFrameId]
  GuildCheckerFrame.kickbuttons[currentPlayersIndex] = GuildCheckerFrame.kickbuttons[existingFrameId]
  GuildCheckerFrame.validatebuttons[currentPlayersIndex] = GuildCheckerFrame.validatebuttons[existingFrameId]
  GuildCheckerFrame.blacklistbuttons[currentPlayersIndex] = GuildCheckerFrame.blacklistbuttons[existingFrameId]
  
  GuildCheckerFrame.playerNames[existingFrameId] = tempName
  GuildCheckerFrame.playerGuilds[existingFrameId] = tempGuild
  GuildCheckerFrame.kickbuttons[existingFrameId] = tempKickButton
  GuildCheckerFrame.validatebuttons[existingFrameId] = tempValidateButton
  GuildCheckerFrame.blacklistbuttons[existingFrameId] = tempBlacklistButton
  --[[get original player id's latest group position if the player is in the group
  if PlayerIsInGroup(originalPlayerId) then
    local originalPlayerNewId = PlayerIdInGroup(tempName:GetText())
    --get the id for where we inserted the tempframe
    local existingFrameId = ExistingFrameIdForPlayer(tempName:GetText())
    SwapPlayers(existingFrameId,originalPlayerNewId)   
    
  end]]
end

local function UpdatePlayerPosition(existingFrameIndex,currentPlayerListIndex)
  
  
  --core:Print("Debug: UpdatePlayerPosition: existingFrameIndex = " ..existingFrameIndex..", currentPlayerListIndex = " .. currentPlayerListIndex)
  if currentPlayerListIndex == 1 then
    GuildCheckerFrame.playerNames[existingFrameIndex]:SetPoint("TOPLEFT", content1, "TOPLEFT", 5, -6);
    GuildCheckerFrame.playerGuilds[existingFrameIndex]:SetPoint("LEFT", GuildCheckerFrame.playerNames[existingFrameIndex], "RIGHT", 0, 0);
    GuildCheckerFrame.validatebuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.playerGuilds[existingFrameIndex],"RIGHT",0,0);
    GuildCheckerFrame.kickbuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.validatebuttons[existingFrameIndex],"RIGHT")
    GuildCheckerFrame.blacklistbuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.kickbuttons[existingFrameIndex],"RIGHT")
  else --TODO: need to anchor the n > 2 frames onto the n=1 frame...once proper frame recycling is in place
    --SwapPlayers(existingFrameIndex,currentPlayerListIndex)
    --core:Print("Debug: UpdatePlayerPosition: existingFrameIndex="..existingFrameIndex..", currentPlayerListIndex="..currentPlayerListIndex)
    --figure out which value is nil
    if GuildCheckerFrame.playerNames[existingFrameIndex] == nil then core:Print("|cffFF1493Debug: UpdatePlayerPosition: GuildCheckerFrame.playerNames[existingFrameIndex] == nil|r") end
    if GuildCheckerFrame.playerNames[existingFrameIndex-1] == nil then core:Print("|cffFF1493Debug: UpdatePlayerPosition: GuildCheckerFrame.playerNames[existingFrameIndex-1] == nil|r") end
    --GuildCheckerFrame.playerNames[existingFrameIndex]:SetPoint("TOPLEFT", content1, "TOPLEFT", 5,-18*(currentPlayerListIndex-1));
    GuildCheckerFrame.playerNames[existingFrameIndex]:SetPoint("TOPLEFT", GuildCheckerFrame.playerNames[existingFrameIndex-1], "TOPLEFT", 0,-18);
    GuildCheckerFrame.playerGuilds[existingFrameIndex]:SetPoint("LEFT", GuildCheckerFrame.playerNames[existingFrameIndex], "RIGHT", 0, 0);
    --GuildCheckerFrame.validatebuttons[existingFrameIndex]:SetPoint("TOPRIGHT",content1,0,-18*(currentPlayerListIndex-1));
    GuildCheckerFrame.validatebuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.playerGuilds[existingFrameIndex],"RIGHT",0,0);
    GuildCheckerFrame.kickbuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.validatebuttons[existingFrameIndex],"RIGHT")
    GuildCheckerFrame.blacklistbuttons[existingFrameIndex]:SetPoint("LEFT",GuildCheckerFrame.kickbuttons[existingFrameIndex],"RIGHT")
  end
end

-- GuildChecker Functions ------------------------------------------------------------------------------------------------------
function GuildChecker:Toggle()
  local window = GuildCheckerFrame or GuildChecker:CreateGuildChecker();
  window:SetShown(not window:IsShown());
end

function GuildChecker:CreatePlayer(k, v, guildName)
  --core:Print("Debug: CreatePlayer: " .. v .. "")
  local playerName, playerGuild, validateButton, kick1, blacklist1
  
  --check if empty frame exists
  if #GuildCheckerFrame.emptyPlayerNames > 0 then
    --core:Print("Debug: CreatePlayer: " .. v .. ": Re-using existing frames")
    --take the top object from each table
    playerName = GuildCheckerFrame.emptyPlayerNames[1]
    playerGuild = GuildCheckerFrame.emptyPlayerGuilds[1]
    validateButton = GuildCheckerFrame.emptyValidatebuttons[1]
    kick1 = GuildCheckerFrame.emptyKickbuttons[1]
    blacklist1 = GuildCheckerFrame.emptyBlacklistbuttons[1]
    
    tremove(GuildCheckerFrame.emptyPlayerNames, 1)
    tremove(GuildCheckerFrame.emptyPlayerGuilds, 1)
    tremove(GuildCheckerFrame.emptyValidatebuttons, 1)
    tremove(GuildCheckerFrame.emptyKickbuttons, 1)
    tremove(GuildCheckerFrame.emptyBlacklistbuttons, 1)
  else 
    --core:Print("Debug: CreatePlayer: " .. v .. ": creating new frames")
    playerName = content1:CreateFontString("playerName","OVERLAY", content1,nil);
    playerGuild = content1:CreateFontString("playerGuild","OVERLAY",content1,nil);
    validateButton = CreateFrame("Button", "validateButton", content1, "UIPanelButtonTemplate")
    kick1 = CreateFrame("Button","kick1",content1,"UIPanelButtonTemplate")
    blacklist1 = CreateFrame("Button","blacklist1",content1,"UIPanelButtonTemplate")
  end
  
  
  playerName:SetFontObject("GameFontNormal");
  playerName:SetText(v);
  playerName:SetWidth(100)
  playerName:SetJustifyH("LEFT")
  playerGuild:SetFontObject("GameFontNormal");
  playerGuild:SetWidth(100)
  playerGuild:SetJustifyH("LEFT")
  
  validateButton:SetSize(60 ,18)
  validateButton:SetText("Detect")
  validateButton:SetScript("OnClick", function()
    core.Tool.RunSlashCmd("/who n-" .. v)
  end)
  
   
  kick1:SetSize(60,18)
  kick1:SetText("Kick")
  kick1:SetScript("OnClick", function ()
  core.Tool.RunSlashCmd("/kick " .. v)
  --core:Print("Clicked kick button, now updating roster");
    GuildChecker:RosterUpdate();
  end)
  
  
  blacklist1:SetSize(60,18)
  blacklist1:SetText("Blacklist")
  blacklist1:SetScript("OnClick", function ()
    tinsert(UserBlacklist,v)
    blacklist1:Disable()
    SetTextColor(playerName, defaults.blacklisted);
    SetTextColor(playerGuild, defaults.blacklisted);
    blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
    UninviteUnit(v);
    core:Print("|cffFF0000" .. v .. "|r has been blacklisted and uninvited from the group.");
  end)
  
  tinsert(GuildCheckerFrame.playerNames, playerName);
  tinsert(GuildCheckerFrame.playerGuilds, playerGuild);
  tinsert(GuildCheckerFrame.validatebuttons, validateButton);
  tinsert(GuildCheckerFrame.kickbuttons, kick1);
  tinsert(GuildCheckerFrame.blacklistbuttons, blacklist1);
  
  validateButton:Show()
  kick1:Show()
  blacklist1:Show()
  validateButton:Enable()
  kick1:Enable()
  blacklist1:Enable()
  
  local existingFrameId = ExistingFrameIdForPlayer(v)
  
  if existingFrameId > 0 then
      UpdatePlayerPosition(ExistingFrameIdForPlayer(v),k)
      
      if ExistingFrameIdForPlayer(v) ~= k then
        
        SwapPlayers(ExistingFrameIdForPlayer(v),k)
        UpdatePlayerPosition(ExistingFrameIdForPlayer(v),k)    
      end
  end
  
  UpdatePlayerColor(k)
  
  --implement a return value so i can keep track of whole player objects in another table
  --return {playerName,playerGuild,validateButton,kick1,blacklist1}
end

function GuildChecker:GetThemeColor()
  local c = defaults.theme;
  return c.r, c.g, c.b, c.hex;
end

function GuildChecker:GetBlacklistedPlayersAsString()
  local blacklistString = "";

  for g,w in pairs(UserBlacklist) do
    if(g == #UserBlacklist) then
      blacklistString = blacklistString .. w;
    else
      blacklistString = blacklistString .. w .. ", ";
    end
  end

  if(blacklistString == "") then
    blacklistString = "None";
  end

  return blacklistString;
end

function GuildChecker:GetAllowedGuildsAsString()

  local guildstring = "";
  for g,w in pairs(allowedGuilds) do
    if(g == #allowedGuilds) then
      guildstring = guildstring .. w;
    else
      guildstring = guildstring .. w .. ", ";
    end
  end

  if(guildstring == "") then
    guildstring = "None";
  end

  return guildstring;
end

function GuildChecker:Show()
  GuildCheckerFrame:Show();
end

function GuildChecker:Hide()
  GuildCheckerFrame:Hide();
end

function GuildChecker:IsShown()
  return GuildCheckerFrame:IsShown()
end

function GuildChecker:IsIntentionallyOpened()
  return intentionallyOpened
end

function GuildChecker:SetIntentionallyOpened(arg1)
  intentionallyOpened = arg1
end

function GuildChecker:RosterUpdate()
  --core:Print("Debug: Update Method:")
  local currentPlayersList= GetPlayersList();
  
  -- this check will keep the window open if the user opened it with the /guildchecker command
  if GuildCheckerFirstTimeRun or IsInGroup() or intentionallyOpened then    
    GuildCheckerFrame:Show();
  else    
    GuildCheckerFrame:Hide();   
  end

  -- handle the roster button (only enable it if you are in a group)
  if IsInGroup() then 
    GuildCheckerFrame.RosterUpdateButton:Enable(); 
  else
    GuildCheckerFrame.RosterUpdateButton:Disable(); 
  end
  
  --cycle through existing frames and hide players that have left the group
  for i=1,#GuildCheckerFrame.playerNames do
    --core:Print("Debug: checking to see if player i="..i.."needs to be hidden") --playerNames[i] can be nil sometimes if you remove a player while iterating
    if GuildCheckerFrame.playerNames[i] ~= nil then
        local existingFramePlayerName = GuildCheckerFrame.playerNames[i]:GetText()
        if not PlayerIsInGroup(existingFramePlayerName) then
          --core:Print("Debug: "..existingFramePlayerName..": hiding existing frameId=" .. i .. " for user that left group")
          RemovePlayer(i)    
          --let's say removed player is i=2, the removePlayer method will remove teh reference for playerNames[2], then the for loop iterates to i=3
        end
    end
  end
  
  --cycle through current list of players in group and update or create frame
  for currentPlayersIndex,currentPlayersName in pairs(currentPlayersList) do
    
    local guildName = GetGuildForPlayer(currentPlayersName)
    --core:Print("Debug: " .. currentPlayersName .. ": checking to see if player has an existing frame")
    --get frame id if frame already exists for this player
    local existingFrameId = ExistingFrameIdForPlayer(currentPlayersName)
   
    if existingFrameId > 0 then
      
      --update player frame
      --core:Print("Debug: Update Method: currentPlayersName = " .. currentPlayersName .. ", existingFrameId = " .. existingFrameId .. ", currentPlayersIndex = " .. currentPlayersIndex)
      if existingFrameId ~= currentPlayersIndex then
        --core:Print("Debug: " .. currentPlayersName .. ": need to swap existingFrameId=" .. existingFrameId .. ", into currentPlayersIndex=" .. currentPlayersIndex)
        
        --copy existing contents into current index
        SwapPlayers(existingFrameId, currentPlayersIndex)
        
        --on the right track here
        --need to remove the old existingFrameId data in the tables
        
        UpdatePlayerColor(currentPlayersIndex)
        UpdatePlayerPosition(existingFrameId,currentPlayersIndex)
        
        --ShowPlayer(currentPlayersIndex)
      else
        UpdatePlayerColor(existingFrameId)
        UpdatePlayerPosition(existingFrameId,currentPlayersIndex)
        --ShowPlayer(existingFrameId)
      end
    else
      --frame does not exist, create player frame
      if currentPlayersName ~= "Unknown" then
        GuildChecker:CreatePlayer(currentPlayersIndex, currentPlayersName, guildName)
      end
      --core:Print("Debug: Roser Update: " .. currentPlayersName .. ": created new frame at currentPlayersIndex=" .. currentPlayersIndex)
    end
  end
  
  -- Blacklist code ----------------------------------------------------------------------------------
  for i=1,#GuildCheckerFrame.playerNames do
    name = GuildCheckerFrame.playerNames[i]:GetText()
    if PlayerIsBlacklisted(name) then
      GuildCheckerFrame.blacklistbuttons[i]:Disable();
      GuildCheckerFrame.validatebuttons[i]:Disable();
      SetTextColor(GuildCheckerFrame.playerNames[i], defaults.blacklisted);
      SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.blacklisted);
      UninviteUnit(GuildCheckerFrame.playerNames[i]:GetText())
    end
  end
end

function GuildChecker:ParseSystemMessage(arg1)
  local d,name,level,a1,a2,a3 = string.match(arg1,core.PatternWho2)  --a3 is guild

  if not name or not a3 then
    d,name,level,a1,a2,a3 = string.match(arg1,core.PatternWho1)
  end

  if not name then
    return;
  end
  
  if PlayerIsInGroup(name) then
    local existingFrameId = ExistingFrameIdForPlayer(name)
    if existingFrameId > 0 then
      if a3 ~= "" then
        GuildCheckerFrame.playerGuilds[existingFrameId]:SetText(" <"..a3..">");
      else
        --user exists but guild is empty (they are unguilded)
        GuildCheckerFrame.playerGuilds[existingFrameId]:SetText("UNGUILDED");
      end
      UpdatePlayerColor(existingFrameId)
    end
  end
  
  
  --[[
  if(PlayerIsInGroup(name)) then
    for i=1,#GuildCheckerFrame.playerNames do
      if name then
        if string.upper(GuildCheckerFrame.playerNames[i]:GetText()) == string.upper(name) then
          if a3 ~= "" then
            local matchfound = false;
            for g,w in pairs(allowedGuilds) do
              if w == string.upper(a3) then
                SetTextColor(GuildCheckerFrame.playerNames[i], defaults.approved);
                SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.approved);
                GuildCheckerFrame.validatebuttons[i]:Disable();
                GuildCheckerFrame.blacklistbuttons[i]:Enable();
                matchfound = true;
              end
            end
            if not matchfound then
              SetTextColor(GuildCheckerFrame.playerNames[i], defaults.notapproved);
              SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.notapproved);
              GuildCheckerFrame.validatebuttons[i]:Disable();
              GuildCheckerFrame.blacklistbuttons[i]:Enable();
            end
            GuildCheckerFrame.playerGuilds[i]:SetText(" <"..a3..">");
          else
            --user exists but guild is empty
            SetTextColor(GuildCheckerFrame.playerNames[i], defaults.unguilded);
            SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.unguilded);
            GuildCheckerFrame.playerGuilds[i]:SetText("UNGUILDED");
            GuildCheckerFrame.blacklistbuttons[i]:Enable();
            GuildCheckerFrame.validatebuttons[i]:Disable();
          end
        end
      end
    end
  end
  ]]
end

function GuildChecker:ParseNamplates(unitID)
  --local nameplate = C_NamePlate.GetNamePlateForUnit(unitID)
  local name = UnitName(unitID);

  if PlayerIsInGroup(name) then
    --core:Print("[ParseNamePlates] Detected nameplate for group member " .. name);
    if PlayerIsBlacklisted(name) then
      --[[ cannot uninvite a player during this event, it simply won't work- maybe i should do something else like update a label indicating a blacklisted user has joined

        core:Print("[ParseNamePlates] " .. name .. " is blacklisted and will be removed from the group");
        UninviteUnit(name);
        core.Tool.RunSlashCmd("/kick " .. name)
      ]]
    else
      local guildName, guildRankName, guildRankIndex = GetGuildInfo(name);
      for i=1,#GuildCheckerFrame.playerNames do
        if guildName then
          if string.upper(GuildCheckerFrame.playerNames[i]:GetText()) == string.upper(name) then
            local matchfound = false;
            for g,w in pairs(allowedGuilds) do
              if w == string.upper(guildName) then
                SetTextColor(GuildCheckerFrame.playerNames[i], defaults.approved);
                SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.approved);
                GuildCheckerFrame.validatebuttons[i]:Disable();
                GuildCheckerFrame.blacklistbuttons[i]:Enable();
                matchfound = true;
              end
            end
            if not matchfound then
              SetTextColor(GuildCheckerFrame.playerNames[i], defaults.notapproved);
              SetTextColor(GuildCheckerFrame.playerGuilds[i], defaults.notapproved);
              GuildCheckerFrame.validatebuttons[i]:Disable();
              GuildCheckerFrame.blacklistbuttons[i]:Enable();
            end

            GuildCheckerFrame.playerGuilds[i]:SetText(" <"..guildName..">");

          end
        else
          GuildCheckerFrame.playerGuilds[i]:SetText("|cff0000FFUNGUILDED|r");
        end
      end
    end
  else
    --player is not in the group
  end
end

function GuildChecker:CreateGuildChecker()
  GuildCheckerFrame = CreateFrame("Frame","GuildCheckerFrame",UIParent,"BasicFrameTemplateWithInset");
  GuildCheckerFrame:SetMovable(true);
  GuildCheckerFrame:SetResizable(true);
  GuildCheckerFrame:EnableMouse(true);
  GuildCheckerFrame:RegisterForDrag("LeftButton");
  GuildCheckerFrame:SetScript("OnDragStart",GuildCheckerFrame.StartMoving);
  GuildCheckerFrame:SetScript("OnDragStop",GuildCheckerFrame.StopMovingOrSizing);
  GuildCheckerFrame:SetSize(500,200);
  GuildCheckerFrame:SetMinResize(500,200);
  GuildCheckerFrame:SetMaxResize(500,600);
  GuildCheckerFrame:SetPoint("CENTER", UIParent, "CENTER");

  GuildCheckerFrame.title = GuildCheckerFrame:CreateFontString(nil,"OVERLAY");
  GuildCheckerFrame.title:SetFontObject("GameFontHighlight");
  GuildCheckerFrame.title:SetPoint("LEFT", GuildCheckerFrame.TitleBg, "LEFT", 5, 0);
  GuildCheckerFrame.title:SetText("|cff00ccff"..TOCNAME.."|r |cffFF1493BETA|r");

  GuildCheckerFrame.RosterUpdateButton = CreateFrame("Button", "RosterUpdateButton", GuildCheckerFrame, "UIPanelButtonTemplate")
  GuildCheckerFrame.RosterUpdateButton:SetSize(60 ,18)
  GuildCheckerFrame.RosterUpdateButton:SetText("Update")
  GuildCheckerFrame.RosterUpdateButton:SetScript("OnClick", function(self)
    GuildChecker:RosterUpdate();
  end)
  GuildCheckerFrame.RosterUpdateButton:SetPoint("TOPRIGHT",GuildCheckerFrame.TitleBg,"TOPRIGHT",0,2);
  GuildCheckerFrame.RosterUpdateButton:Disable();

  GuildCheckerFrame.createdByMessage = GuildCheckerFrame:CreateFontString("createdByMessage","OVERLAY",GuildCheckerFrame,nil);
  GuildCheckerFrame.createdByMessage:SetFontObject("GameFontHighlight");
  GuildCheckerFrame.createdByMessage:SetPoint("TOPRIGHT",GuildCheckerFrame.TitleBg,"TOPRIGHT",-5,-2);
  GuildCheckerFrame.createdByMessage:SetText("Created By: |cff9370DBWiibur <TL> Herod|r".."  Discord: |cff9370DBWiibur#0001|r\n");


  local rb = CreateFrame("Button", nil, GuildCheckerFrame)
  rb:SetPoint("BOTTOMRIGHT", -6, 7)
  rb:SetSize(16, 16)
  rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

  rb:SetScript("OnMouseDown", function()
    GuildCheckerFrame:StartSizing("BOTTOMRIGHT")
  end)
  rb:SetScript("OnMouseUp", function()
    GuildCheckerFrame:StopMovingOrSizing()
  end)
  --scroll frame---------------------------------------------------------------------------------------------------------------------------------------------
  GuildCheckerFrame.ScrollFrame = CreateFrame("ScrollFrame", nil, GuildCheckerFrame, "UIPanelScrollFrameTemplate");
  GuildCheckerFrame.ScrollFrame:SetPoint("TOPLEFT", GuildCheckerFrame.InsetBg, "TOPLEFT", 4, 0);
  GuildCheckerFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", GuildCheckerFrame.InsetBg, "BOTTOMRIGHT", -3, 3);
  GuildCheckerFrame.ScrollFrame:SetClipsChildren(true);
  GuildCheckerFrame.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

  GuildCheckerFrame.ScrollFrame.ScrollBar:ClearAllPoints();
  GuildCheckerFrame.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", GuildCheckerFrame.ScrollFrame, "TOPRIGHT", -12, -18);
  GuildCheckerFrame.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", GuildCheckerFrame.ScrollFrame, "BOTTOMRIGHT", -7, 18);

  child = CreateFrame("Frame", nil, GuildCheckerFrame.ScrollFrame);
  child:SetSize(455, 700);

  GuildCheckerFrame.ScrollFrame:SetScrollChild(child);
  
  GuildCheckerFrame:HookScript("OnHide", function()
    -- do stuff
    --core:Print("Debug: intentionally opened set to false")
    intentionallyOpened = false;
  end)
  
  ---------------------------------------------------------------------------------------------------------------------------------------------

  content1, content2, content3 = SetTabs(GuildCheckerFrame, 3, "Players", "Options", "About")





  --content2--------------------------------------------------------------------------------------------------
  --TODO: set this
  local allowedGuildsListHeader = content2:CreateFontString("allowedGuildsList","OVERLAY",content2,nil);
  allowedGuildsListHeader:SetFontObject("GameFontHighlight");
  allowedGuildsListHeader:SetText("Allowed Guilds: ");
  allowedGuildsListHeader:SetPoint("TOPLEFT",content2,5,-6);

  allowedGuildsListFontString = content2:CreateFontString("allowedGuildsListString","OVERLAY",content2,nil);
  allowedGuildsListFontString:SetFontObject("GameFontGreen");
  allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
  allowedGuildsListFontString:SetPoint("TOPLEFT",allowedGuildsListHeader,"BOTTOMLEFT",0,0);
  allowedGuildsListFontString:SetWidth(465);
  allowedGuildsListFontString:SetJustifyH("LEFT");

  local UpdateApprovalListBox = CreateFrame("EditBox","UpdateApprovalListBox", content2, "InputBoxTemplate")
  UpdateApprovalListBox:SetSize(240 ,18)
  SetTextColor(UpdateApprovalListBox, defaults.offline)
  UpdateApprovalListBox:SetText("Enter Guild Name(s)");
  UpdateApprovalListBox:SetPoint("TOPLEFT",allowedGuildsListFontString,"BOTTOMLEFT",5,0)
  UpdateApprovalListBox:SetAutoFocus( false );
  UpdateApprovalListBox:SetScript('OnEditFocusGained', function(self)
    UpdateApprovalListBox:SetTextColor(1,1,1)
    UpdateApprovalListBox:SetText("")
  end)
  UpdateApprovalListBox:SetScript('OnEditFocusLost', function(self)
    SetTextColor(UpdateApprovalListBox, defaults.offline)
    UpdateApprovalListBox:SetText("Enter Guild Name(s)")
  end)

  local UpdateApprovalListButton = CreateFrame("Button", "UpdateApprovalListButton", content2, "UIPanelButtonTemplate")
  UpdateApprovalListButton:SetSize(80 ,18)
  UpdateApprovalListButton:SetText("Add")
  UpdateApprovalListButton:SetScript("OnClick", addGuild)
  UpdateApprovalListButton:SetPoint("TOPLEFT",UpdateApprovalListBox,"BOTTOMLEFT",-5,-2)

  local RemoveGuildButton = CreateFrame("Button", "RemoveGuildButton", content2, "UIPanelButtonTemplate")
  RemoveGuildButton:SetSize(80 ,18)
  RemoveGuildButton:SetText("Remove")
  RemoveGuildButton:SetScript("OnClick", removeGuild)
  RemoveGuildButton:SetPoint("LEFT",UpdateApprovalListButton,"RIGHT",0,0)

  local ClearApprovalListButton = CreateFrame("Button", "ClearApprovalListButton", content2, "UIPanelButtonTemplate")
  ClearApprovalListButton:SetSize(80 ,18)
  ClearApprovalListButton:SetText("Reset")
  ClearApprovalListButton:SetScript("OnClick", clearList)
  ClearApprovalListButton:SetPoint("LEFT",RemoveGuildButton,"RIGHT",0,0)


  local blacklistedPlayersListHeader = content2:CreateFontString("blacklistedPlayersListHeader","OVERLAY",allowedGuildsListHeader,nil);
  blacklistedPlayersListHeader:SetFontObject("GameFontHighlight");
  blacklistedPlayersListHeader:SetText("Blacklisted Players: ");
  blacklistedPlayersListHeader:SetPoint("TOPLEFT",UpdateApprovalListButton,"BOTTOMLEFT",0,-10);

  blacklistedPlayersFontString = content2:CreateFontString("blacklistedPlayersFontString","OVERLAY",content2,nil);
  blacklistedPlayersFontString:SetFontObject("GameFontRed");
  blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
  blacklistedPlayersFontString:SetPoint("TOPLEFT",blacklistedPlayersListHeader,"BOTTOMLEFT");
  blacklistedPlayersFontString:SetWidth(465);
  blacklistedPlayersFontString:SetJustifyH("LEFT");

  local BlacklistEditBox = CreateFrame("EditBox","BlacklistEditBox", content2, "InputBoxTemplate")
  BlacklistEditBox:SetSize(240 ,18)
  SetTextColor(BlacklistEditBox, defaults.offline)
  BlacklistEditBox:SetText("Enter Player Name(s)");
  BlacklistEditBox:SetPoint("TOPLEFT",blacklistedPlayersFontString,"BOTTOMLEFT",5,-2)
  BlacklistEditBox:SetAutoFocus( false );
  BlacklistEditBox:SetScript('OnEditFocusGained', function(self)
    BlacklistEditBox:SetTextColor(1,1,1)
    BlacklistEditBox:SetText("")
  end)
  BlacklistEditBox:SetScript('OnEditFocusLost', function(self)
    SetTextColor(BlacklistEditBox, defaults.offline)
    BlacklistEditBox:SetText("Enter Player Name(s)")
  end)

  local BlacklistUpdateButton = CreateFrame("Button", "BlacklistUpdateButton", content2, "UIPanelButtonTemplate")
  BlacklistUpdateButton:SetSize(80 ,18)
  BlacklistUpdateButton:SetText("Add")
  BlacklistUpdateButton:SetScript("OnClick", addBlacklist)
  BlacklistUpdateButton:SetPoint("TOPLEFT",BlacklistEditBox,"BOTTOMLEFT",-5,-2)

  local removeBlacklistButton = CreateFrame("Button", "removeBlacklistButton", content2, "UIPanelButtonTemplate")
  removeBlacklistButton:SetSize(80 ,18)
  removeBlacklistButton:SetText("Remove")
  removeBlacklistButton:SetScript("OnClick", removeBlacklist)
  removeBlacklistButton:SetPoint("LEFT",BlacklistUpdateButton,"RIGHT",0,0)

  local ClearBlacklistButton = CreateFrame("Button", "ClearBlacklistButton", content2, "UIPanelButtonTemplate")
  ClearBlacklistButton:SetSize(80 ,18)
  ClearBlacklistButton:SetText("Reset")
  ClearBlacklistButton:SetScript("OnClick", clearBlacklist)
  ClearBlacklistButton:SetPoint("LEFT",removeBlacklistButton,"RIGHT",0,0)

  --content3--------------------------------------------------------------------------------------------------


  local aboutMessage = content3:CreateFontString("aboutMessage","OVERLAY", content3,nil);
  aboutMessage:SetFontObject("GameFontHighlight");
  aboutMessage:SetPoint("TOPLEFT", content3, "TOPLEFT", 5, -6);
  aboutMessage:SetWidth(460);
  aboutMessage:SetJustifyH("LEFT");


  local aboutString = newStack();
  --addString(aboutString,"Created By: |cff9370DBWiibur <TL> - Herod|r".."      Discord: |cff9370DBWiibur#0001|r\n");
  addString(aboutString,"Description:\n");
  addString(aboutString,"|cff9ACD32"..TOCNAME.." is a tool for guild coalitions that allows raid or group leaders to verify that everyone in the group belongs to a guild in the coalition.|r\n");
  addString(aboutString,"\nUsage:\n");
  addString(aboutString,"|cff9ACD321. Add guilds to the whitelist of approved guilds on the Options tab. This can be done individually or with a comma-separated list.|r\n");
  addString(aboutString,"|cff9ACD322. As group members join they will be added on the Players tab and their guild will be detected, if they are in range.|r\n");
  addString(aboutString,"|cff9ACD323. Use the |rDetect button |cff9ACD32if a player's guild isn't detected automatically (can only be used once every few seconds).|r\n");
  addString(aboutString,"|cff9ACD324. Use the |rUpdate button |cff9ACD32if a player's name shows up as |r|cff808080UNKNOWN|r|cff9ACD32.|r\n");
  addString(aboutString,"|cff9ACD325. Enable friendly nameplates to boost guild detection.|r\n");
  addString(aboutString,"|cff9ACD326. If you hide the add-on, show it again with: |r|cffFFD700/guildchecker|r\n");
  addString(aboutString,"|cff9ACD327. Blacklisted players should be removed from the group automatically, but this requires another roster update event to occur (can be triggered manually via the |rUpdate button|cff9ACD32).|r\n");
  addString(aboutString,"\n");
  --[[addString(aboutString,"Player Name Color Codes:\n");
  addString(aboutString,"|cff808080Offline|r\n");
  addString(aboutString,"|cffFFD700Guild unknown|r\n");
  addString(aboutString,"|cff0000FFUnguilded|r\n");
  addString(aboutString,"|cff00FF00In whitelisted guild|r\n");
  addString(aboutString,"|cffFF0000Not in whitelisted guild|r\n");
  addString(aboutString,"|cffFF00FFBlacklisted user|r\n");
  ]]
  aboutMessage:SetText(table.concat(aboutString));
  
  
  local colorCodesHeaderFontString = content3:CreateFontString("colorCodesString","OVERLAY", content3, nil)
  colorCodesHeaderFontString:SetFontObject("GameFontHighlight")
  colorCodesHeaderFontString:SetPoint("TOP", aboutMessage, "BOTTOM", 0, 0)
  colorCodesHeaderFontString:SetWidth(460)
  colorCodesHeaderFontString:SetJustifyH("LEFT")
  colorCodesHeaderFontString:SetText("Player Name Color Codes:")
  
  local offlineColorCodeFontString = content3:CreateFontString("offlineColorCodeFontString","OVERLAY", content3, nil)
  offlineColorCodeFontString:SetFontObject("GameFontNormal")
  offlineColorCodeFontString:SetPoint("TOP", colorCodesHeaderFontString, "BOTTOM", 0, 0)
  offlineColorCodeFontString:SetWidth(460)
  offlineColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(offlineColorCodeFontString, defaults.offline)
  offlineColorCodeFontString:SetText("Player is offline")
  
  local guildUnknownColorCodeFontString = content3:CreateFontString("guildUnknownCodeFontString","OVERLAY", content3, nil)
  guildUnknownColorCodeFontString:SetFontObject("GameFontNormal")
  guildUnknownColorCodeFontString:SetPoint("TOP", offlineColorCodeFontString, "BOTTOM", 0, 0)
  guildUnknownColorCodeFontString:SetWidth(460)
  guildUnknownColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(guildUnknownColorCodeFontString, defaults.unknown)
  guildUnknownColorCodeFontString:SetText("Player's guild unknown")
    
  local approvedColorCodeFontString = content3:CreateFontString("approvedColorCodeFontString","OVERLAY", content3, nil)
  approvedColorCodeFontString:SetFontObject("GameFontNormal")
  approvedColorCodeFontString:SetPoint("TOP", guildUnknownColorCodeFontString, "BOTTOM", 0, 0)
  approvedColorCodeFontString:SetWidth(460)
  approvedColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(approvedColorCodeFontString, defaults.approved)
  approvedColorCodeFontString:SetText("Player is in an approved guild") 
  
  local unguildedColorCodeFontString = content3:CreateFontString("unguildedCodeFontString","OVERLAY", content3, nil)
  unguildedColorCodeFontString:SetFontObject("GameFontNormal")
  unguildedColorCodeFontString:SetPoint("TOP", approvedColorCodeFontString, "BOTTOM", 0, 0)
  unguildedColorCodeFontString:SetWidth(460)
  unguildedColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(unguildedColorCodeFontString, defaults.unguilded)
  unguildedColorCodeFontString:SetText("Player is unguilded, in an unapproved guild, or blacklisted")  
  --[[
  local unapprovedColorCodeFontString = content3:CreateFontString("unapprovedColorCodeFontString","OVERLAY", content3, nil)
  unapprovedColorCodeFontString:SetFontObject("GameFontNormal")
  unapprovedColorCodeFontString:SetPoint("TOP", unguildedColorCodeFontString, "BOTTOM", 0, 0)
  unapprovedColorCodeFontString:SetWidth(460)
  unapprovedColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(unapprovedColorCodeFontString, defaults.notapproved)
  unapprovedColorCodeFontString:SetText("Player is in an unapproved guild") 
  
  local blacklistedColorCodeFontString = content3:CreateFontString("blacklistedColorCodeFontString","OVERLAY", content3, nil)
  blacklistedColorCodeFontString:SetFontObject("GameFontNormal")
  blacklistedColorCodeFontString:SetPoint("TOP", unapprovedColorCodeFontString, "BOTTOM", 0, 0)
  blacklistedColorCodeFontString:SetWidth(460)
  blacklistedColorCodeFontString:SetJustifyH("LEFT")
  SetTextColor(blacklistedColorCodeFontString, defaults.blacklisted)
  blacklistedColorCodeFontString:SetText("Player is blacklisted") 
  ]]
  
  -----------------------------------------------------------------------------------------------------------



  GuildCheckerFrame.playerNames = {};
  GuildCheckerFrame.playerGuilds = {};
  GuildCheckerFrame.validatebuttons = {};
  GuildCheckerFrame.kickbuttons = {};
  GuildCheckerFrame.blacklistbuttons = {};
  
  GuildCheckerFrame.emptyPlayerNames = {};
  GuildCheckerFrame.emptyPlayerGuilds = {};
  GuildCheckerFrame.emptyValidatebuttons = {};
  GuildCheckerFrame.emptyKickbuttons = {};
  GuildCheckerFrame.emptyBlacklistbuttons = {};
  

  GuildCheckerFrame:Hide();
  return GuildCheckerFrame;
end

--[[
function GuildChecker:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
  local btn = CreateFrame("Button", nil, relativeFrame, "UIPanelButtonTemplate");
  btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
  btn:SetSize(60 ,18)
  btn:SetText(text);

  return btn;
end
]]

--[[Color codes

|cffFF0000This text is red|r 
This text is white |cff00FF00This text is green|r |cff0000FFThis text is blue|r")
https://www.rapidtables.com/web/color/html-color-codes.html
yellowgreen #9ACD32 |cff9ACD32 |r
deeppink  #FF1493 |cffFF1493|r
mediumpurple  #9370DB |cff9370DB|r
magenta #FF00FF |cffFF00FF|r
gray  #808080 |cff808080|r
gold  #FFD700 |cffFFD700|r rgb(255,215,0) 1,0.84,0
]]

--[[TODO:
2. create a reorder function for the player names to put blacklisted and non-approved guilds at the top automatically (might be an option toggle)
4. update rosterUpdate() to mass kick players not in an approved guild?
5. add title label on players tab to show number of players in the raid, number approved, number not approved/blacklisted/unguilded
  a. maybe something like 35/40 players approved (x approved players / group size)
6. make sure player name frames are being used efficiently, not wasting frames
  a. when a user leaves the group, recycle their frame so it can be used again

-there is a bug where a user's name color won't update when the blacklist is cleared or they are removed from the blacklist
- rosterupdate doesn't update the color of unguilded players correctly

/who player gas
returned several players with gas in their name
need to add logic to check the full name match for a list of /who results (how to read the results list and match from it?)

the 2nd player's y-position is too close to the first row because i'm not checking when k==1 if that player is first in the list in the addon already, even if they're first in the plist

if new player record but it's not first in the overall list

]]
