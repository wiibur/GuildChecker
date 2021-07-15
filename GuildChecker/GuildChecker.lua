local TOCNAME,core = ...

core.GuildChecker = {};
local GuildChecker = core.GuildChecker;
local GuildCheckerFrame;
local child;
local content1, content2, content3;
local allowedGuildsListFontString;
local blacklistedPlayersFontString;

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
	}
}

-- local Functions -------------------------------------------------------------------------------------------------------------


-- GuildChecker Functions ------------------------------------------------------------------------------------------------------
function GuildChecker:Toggle()
	local window = GuildCheckerFrame or GuildChecker:CreateGuildChecker();
	window:SetShown(not window:IsShown());
end

function GuildChecker:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
	local btn = CreateFrame("Button", nil, relativeFrame, "UIPanelButtonTemplate");
	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
	btn:SetSize(60 ,18)
	btn:SetText(text);

	return btn;
end

function GuildChecker:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

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

  local guilds = core.Tool.Split(string.upper(UpdateApprovalListBox:GetText()), ",");

	for i,guild in pairs(guilds) do
		guild = string.gsub(guild, '^%s*(.-)%s*$', '%1');
	  if guild == "" or guild == string.upper("Enter Guild Name(s)") then
			core:Print("Guild name cannot be blank.");
	    return
	  end
		for k,v in pairs(allowedGuilds) do
			if guild == string.upper(v) then
				core:Print("Guild name already exists in whitelist.");
				GuildChecker:RosterUpdate();
				return
			end
		end

	  tinsert(allowedGuilds,guild);
		core:Print(guild.." has been added to the whitelist.")
	  UpdateApprovalListBox:ClearFocus();
	  --UpdateApprovalListBox:SetText("");

	  GuildChecker:RosterUpdate();
		allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
	end
end

local function removeGuild()
  local guilds = core.Tool.Split(string.upper(UpdateApprovalListBox:GetText()),",");
	for i,guild in pairs(guilds) do
		guild = string.gsub(guild, '^%s*(.-)%s*$', '%1');
		if guild == "" or guild == string.upper("Enter Guild Name(s)") then
	    core:Print("Guild name cannot be blank.");
	    return
	  end

	  for k,v in pairs(allowedGuilds) do
	    if guild == string.upper(v) then
	      tremove(allowedGuilds,k)
				core:Print("Guild name " .. guild .. " has been removed from the whitelist.");
	    end
	  end
	  UpdateApprovalListBox:ClearFocus();
	  GuildChecker:RosterUpdate();
		allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
	end
end

local function clearList()
  allowedGuilds = {}
  core:Print("Guild whitelist has been reset.");
  GuildChecker:RosterUpdate();
	allowedGuildsListFontString:SetText(GuildChecker:GetAllowedGuildsAsString());
end

local function addBlacklist()
  local usernames = core.Tool.Split(string.upper(BlacklistEditBox:GetText()),",");

	for i,username in pairs(usernames) do
		username = string.gsub(username, '^%s*(.-)%s*$', '%1');
	  if username == "" or username == string.upper("Enter Player Name(s)") then
			core:Print("Player name cannot be blank.");
			return
	  end
	  for k,v in pairs(UserBlacklist) do
	    if username == v then
	      core:Print("Player name already exists in blacklist.")
	      GuildChecker:RosterUpdate();
	      return
	    end
	  end
	  tinsert(UserBlacklist,username)
		core:Print("Player name " .. username.." has been added to the blacklist.")
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
	    core:Print("No blacklist contents to load.")
	  end
		blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
	end
end

local function removeBlacklist()
  local usernames = core.Tool.Split(string.upper(BlacklistEditBox:GetText()),",");
	for i,username in pairs(usernames) do
		username = string.gsub(username, '^%s*(.-)%s*$', '%1');
		if username == "" or username == string.upper("Enter Player Name(s)") then
			core:Print("Player name cannot be blank.");
			return
	  end
	  for k,v in pairs(UserBlacklist) do
	    if username == v then
	      core:Print("Player name ".. username .. " has been removed from blacklist.")
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
	        core:Print("No blacklist contents to load.")
	      end
	    end
	  end
		blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
	end
end

local function clearBlacklist()
  UserBlacklist = {}
  GuildChecker:RosterUpdate();
  core:Print("Player blacklist has been reset.")
	blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
end
------------------------------------------------------------------------------------------------------------------------------------------

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = GuildCheckerFrame.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	GuildCheckerFrame.ScrollFrame:SetScrollChild(self.content);
	GuildCheckerFrame.ScrollFrame:SetVerticalScroll(0);

	self.content:Show();

	if self:GetID() ~= 1 then
		--TODO:write function showContent1Buttons() and hideContent1Buttons()
		GuildCheckerFrame.RosterUpdateButton:Hide();
	else
		GuildCheckerFrame.RosterUpdateButton:Show();
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
		core:Print("first time run, showing about tab")
		Tab_OnClick(_G[frameName.."Tab3"]);
		GuildCheckerFirstTimeRun = false;
	else
		core:Print("not first time run, showing players tab")
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
			core:Print("[GuildChecker] Detected blacklisted user: " .. v);
			blacklisted = true;
		end
	end
	return blacklisted;
end

local function PlayerIsUnguilded()

end

local function SortPlayersList()
	--TODO: this function sorts the current list of player fontstrings and puts at the top those users that are blacklisted, have an unapproved guild, or are unguilded

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

function GuildChecker:RosterUpdate()
  local plist= GetPlayersList();

	-- handle the roster button (only enable it if people are in your party/raid)
	if #plist > 0 then GuildCheckerFrame.RosterUpdateButton:Enable(); else GuildCheckerFrame.RosterUpdateButton:Disable(); end

  -- if a user leaves the party, need to remove their GuildCheckerFrame element/widget
  for i=1,#GuildCheckerFrame.playerNames do
    local userIsInGroup = false;
    for k,v in pairs(plist) do
      if GuildCheckerFrame.playerNames[i]:GetText() == v then
        userIsInGroup = true;
      end
    end
    if not userIsInGroup then
      GuildCheckerFrame.playerNames[i]:Hide();
			GuildCheckerFrame.playerGuilds[i]:Hide();
      GuildCheckerFrame.validatebuttons[i]:Hide();
      GuildCheckerFrame.kickbuttons[i]:Hide();
      GuildCheckerFrame.blacklistbuttons[i]:Hide();
      --tremove(GuildCheckerFrame.playerNames, i);
    end
  end

	-- check if fontstring has already been created for each player in the group
  for k,v in pairs(plist) do
    local startingY = 0;

    local guildName, guildRankName, guildRankIndex = GetGuildInfo(v)



		local alreadyCreated = false;

    for i=1,#GuildCheckerFrame.playerNames do

        if GuildCheckerFrame.playerNames[i]:GetText() == v then
          alreadyCreated = true;
					--core:Print("roster update debug: inside alreadyCreated=true logic for player " .. v);
					--core:Print("player = "..v..", guildName = "..guildName);



          --need to reset the position for index 1 to the top left then build children from there
          if k == 1 then
            GuildCheckerFrame.playerNames[i]:SetPoint("TOPLEFT", content1, "TOPLEFT", 5, -6);
						GuildCheckerFrame.playerGuilds[i]:SetPoint("LEFT", GuildCheckerFrame.playerNames[i], "RIGHT", 0, 0);
            GuildCheckerFrame.validatebuttons[i]:SetPoint("TOPRIGHT",content1,0,-4);
            GuildCheckerFrame.kickbuttons[i]:SetPoint("RIGHT",GuildCheckerFrame.validatebuttons[i],"LEFT")
            GuildCheckerFrame.blacklistbuttons[i]:SetPoint("RIGHT",GuildCheckerFrame.kickbuttons[i],"LEFT")
          else
            GuildCheckerFrame.playerNames[i]:SetPoint("TOPLEFT", content1, "TOPLEFT", 5, -19*(k-1));
						GuildCheckerFrame.playerGuilds[i]:SetPoint("LEFT", GuildCheckerFrame.playerNames[i], "RIGHT", 0, 0);
            GuildCheckerFrame.validatebuttons[i]:SetPoint("TOPRIGHT",content1,0,-19*(k-1));
            GuildCheckerFrame.kickbuttons[i]:SetPoint("RIGHT",GuildCheckerFrame.validatebuttons[i],"LEFT")
            GuildCheckerFrame.blacklistbuttons[i]:SetPoint("RIGHT",GuildCheckerFrame.kickbuttons[i],"LEFT")
          end

          GuildCheckerFrame.playerNames[i]:Show();
					GuildCheckerFrame.playerGuilds[i]:Show();
          GuildCheckerFrame.validatebuttons[i]:Show();
          GuildCheckerFrame.kickbuttons[i]:Show();
          GuildCheckerFrame.blacklistbuttons[i]:Show();
          --try and recheck guildname for existing playerNames, update name color accordingly


					--TODO: guildName is returning nil when user's are re-added, maybe can do a /who lookup if it is nil, then proceed
					--also, could  check to see  if the value of GuildCheckerFrame.playerGuilds[i]:GetText() is set, and then if it equals the whitelisted guild
					if guildName == nil then
						local fontStringText = GuildCheckerFrame.playerGuilds[i]:GetText()
						if fontStringText ~= nil and fontStringText ~= "" and fontStringText ~= "UNGUILDED" then
							guildName=string.sub(GuildCheckerFrame.playerGuilds[i]:GetText(),3,#GuildCheckerFrame.playerGuilds[i]:GetText()-1); --need to trim the angle brackets off this string
						end
					end
          if guildName ~= nil then
            local allowed = false
						--core:Print("roster update debug: inside guildName~=nil logic for player " .. v .. ", guildName = "..guildName);
            for g,w in pairs(allowedGuilds) do
              if string.upper(w) == string.upper(guildName) then
								--core:Print("text color for player "..v.." set to green");
                GuildCheckerFrame.playerNames[i]:SetTextColor(0,1,0);
								GuildCheckerFrame.playerGuilds[i]:SetTextColor(0,1,0);
                allowed = true;
                GuildCheckerFrame.validatebuttons[i]:Disable();
                GuildCheckerFrame.blacklistbuttons[i]:Enable();
							end
            end
            if allowed == false then
							GuildCheckerFrame.playerNames[i]:SetTextColor(1,0,0);
							GuildCheckerFrame.playerGuilds[i]:SetTextColor(1,0,0);
							--core:Print("re-showing frame for player "..v);
							--core:Print("text color for player "..v.." set to red");
              --GuildCheckerFrame.playerNames[i]:SetFontObject("GameFontRed");
							--GuildCheckerFrame.playerGuilds[i]:SetFontObject("GameFontRed");
              GuildCheckerFrame.validatebuttons[i]:Disable();
              GuildCheckerFrame.blacklistbuttons[i]:Enable();
            end
						--re-check if user is on the blacklist, update their color accordingly
						GuildCheckerFrame.playerGuilds[i]:SetText(" <"..guildName..">");

					elseif PlayerIsBlacklisted(v) then
						--core:Print("Setting player name "..v.." and guild to magenta")
						GuildCheckerFrame.playerNames[i]:SetTextColor(1,0,1);
						GuildCheckerFrame.playerGuilds[i]:SetTextColor(1,0,1);
					else
						GuildCheckerFrame.playerNames[i]:SetTextColor(0.5,0.5,0.5);
						GuildCheckerFrame.playerGuilds[i]:SetTextColor(0.5,0.5,0.5);
					end
        end
      end


			-- NEW PLAYER RECORD CREATION -------------------------------------------------------------
      if not alreadyCreated then
        local playerName = content1:CreateFontString("playerName","OVERLAY", content1,nil);
				playerName:SetFontObject("GameFontNormal");
				local playerGuild = content1:CreateFontString("playerGuild","OVERLAY",content1,nil);
				playerGuild:SetFontObject("GameFontNormal");

        local validateButton = CreateFrame("Button", "validateButton", content1, "UIPanelButtonTemplate")
	      validateButton:SetSize(60 ,18)
	      validateButton:SetText("Detect")
        validateButton:SetScript("OnClick", function()
      		core.Tool.RunSlashCmd("/who n-" .. v)
      	end)

				local kick1 = CreateFrame("Button","kick1",content1,"UIPanelButtonTemplate")
        kick1:SetSize(60,18)
        kick1:SetText("Kick")
        kick1:SetScript("OnClick", function ()
          core.Tool.RunSlashCmd("/kick " .. v)
					--core:Print("Clicked kick button, now updating roster");
					GuildChecker:RosterUpdate();
        end)

				local blacklist1 = CreateFrame("Button","blacklist1",content1,"UIPanelButtonTemplate")
        blacklist1:SetSize(60,18)
        blacklist1:SetText("Blacklist")
        blacklist1:SetScript("OnClick", function ()
					--TODO: should call addBlacklist() local method
          tinsert(UserBlacklist,string.upper(v))
          blacklist1:Disable()
          playerName:SetTextColor(1,0,1);
					playerGuild:SetTextColor(1,0,1);
					blacklistedPlayersFontString:SetText(GuildChecker:GetBlacklistedPlayersAsString());
					UninviteUnit(v);
					core:Print(v.." has been blacklisted and uninvited from the group.");
        end)
        if(guildName == nil) then
          playerName:SetTextColor(0.5,0.5,0.5);
					playerGuild:SetTextColor(0.5,0.5,0.5);
          blacklist1:Disable();
        else
          local allowed = false

            for g,w in pairs(allowedGuilds) do
                if w == guildName then
                    playerName:SetTextColor(0,1,0);
										playerGuild:SetTextColor(0,1,0);
                    allowed = true
                    validateButton:Disable();
                    --blacklist1:Disable();
                end
            end
            if allowed == false then
                playerName:SetTextColor(1,0,0);
								playerGuild:SetTextColor(1,0,0);
                validateButton:Disable();
                blacklist1:Enable();
            end

						playerGuild:SetText(" <"..guildName..">");
        end

				--TODO: Handle case where playerName = "UNKNOWN" which can happen sometimes when event fires.
        playerName:SetText(v);

        if k == 1 then
          playerName:SetPoint("TOPLEFT", content1, "TOPLEFT", 5, -6);
					playerGuild:SetPoint("LEFT",playerName,"RIGHT",0,0);
          validateButton:SetPoint("TOPRIGHT",content1,0,-2)
          kick1:SetPoint("RIGHT",validateButton,"LEFT")
          blacklist1:SetPoint("RIGHT",kick1,"LEFT")

        else
          playerName:SetPoint("TOPLEFT", content1, "TOPLEFT", 5, -19*(k-1));
					playerGuild:SetPoint("LEFT",playerName,"RIGHT",0,0);
          validateButton:SetPoint("TOPRIGHT",content1,0,-19*(k-1))
          kick1:SetPoint("RIGHT",validateButton,"LEFT")
          blacklist1:SetPoint("RIGHT",kick1,"LEFT")
        end
        tinsert(GuildCheckerFrame.playerNames, playerName);
				tinsert(GuildCheckerFrame.playerGuilds, playerGuild);
        tinsert(GuildCheckerFrame.validatebuttons, validateButton);
        tinsert(GuildCheckerFrame.kickbuttons, kick1);
        tinsert(GuildCheckerFrame.blacklistbuttons, blacklist1);
      end
  end

	-- Blacklist code ----------------------------------------------------------------------------------
  for i=1,#GuildCheckerFrame.playerNames do
    for j,m in pairs(UserBlacklist) do
      if string.upper(GuildCheckerFrame.playerNames[i]:GetText()) == string.upper(m) then
        core:Print("[RosterUpdate] Detected blacklisted user: " .. string.upper(GuildCheckerFrame.playerNames[i]:GetText()))
        GuildCheckerFrame.blacklistbuttons[i]:Disable();
        GuildCheckerFrame.validatebuttons[i]:Disable();
        GuildCheckerFrame.playerNames[i]:SetTextColor(1,0,1);
				GuildCheckerFrame.playerGuilds[i]:SetTextColor(1,0,1);
        UninviteUnit(GuildCheckerFrame.playerNames[i]:GetText())
      end
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

	if(PlayerIsInGroup(name)) then
	  for i=1,#GuildCheckerFrame.playerNames do
			if name then
				if string.upper(GuildCheckerFrame.playerNames[i]:GetText()) == string.upper(name) then
					if a3 ~= "" then
		        local matchfound = false;
		        for g,w in pairs(allowedGuilds) do
		          if w == string.upper(a3) then
		            GuildCheckerFrame.playerNames[i]:SetTextColor(0,1,0);
								GuildCheckerFrame.playerGuilds[i]:SetTextColor(0,1,0);
		            GuildCheckerFrame.validatebuttons[i]:Disable();
		            GuildCheckerFrame.blacklistbuttons[i]:Enable();
		            matchfound = true;
		          end
		        end
		        if not matchfound then
		          GuildCheckerFrame.playerNames[i]:SetTextColor(1,0,0);
							GuildCheckerFrame.playerGuilds[i]:SetTextColor(1,0,0);
		          GuildCheckerFrame.validatebuttons[i]:Disable();
		          GuildCheckerFrame.blacklistbuttons[i]:Enable();
		        end
						GuildCheckerFrame.playerGuilds[i]:SetText(" <"..a3..">");
					else
						--user exists but guild is empty
						GuildCheckerFrame.playerNames[i]:SetTextColor(0,0,1);
						GuildCheckerFrame.playerGuilds[i]:SetTextColor(0,0,1);
						GuildCheckerFrame.playerGuilds[i]:SetText("UNGUILDED");
						GuildCheckerFrame.blacklistbuttons[i]:Enable();
					end
				end
			end
		end
	end
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
			          GuildCheckerFrame.playerNames[i]:SetTextColor(0,1,0);
								GuildCheckerFrame.playerGuilds[i]:SetTextColor(0,1,0);
			          GuildCheckerFrame.validatebuttons[i]:Disable();
			          GuildCheckerFrame.blacklistbuttons[i]:Enable();
			          matchfound = true;
			        end
			      end
			      if not matchfound then
			        GuildCheckerFrame.playerNames[i]:SetTextColor(1,0,0);
							GuildCheckerFrame.playerGuilds[i]:SetTextColor(1,0,0);
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
	GuildCheckerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT");

	GuildCheckerFrame.title = GuildCheckerFrame:CreateFontString(nil,"OVERLAY");
	GuildCheckerFrame.title:SetFontObject("GameFontHighlight");
	GuildCheckerFrame.title:SetPoint("LEFT", GuildCheckerFrame.TitleBg, "LEFT", 5, 0);
	GuildCheckerFrame.title:SetText("|cff00ccff"..TOCNAME.."|r |cffFF1493BETA|r");

	GuildCheckerFrame.RosterUpdateButton = CreateFrame("Button", "RosterUpdateButton", GuildCheckerFrame, "UIPanelButtonTemplate")
	GuildCheckerFrame.RosterUpdateButton:SetSize(100 ,18)
	GuildCheckerFrame.RosterUpdateButton:SetText("Roster Update")
	GuildCheckerFrame.RosterUpdateButton:SetScript("OnClick", function(self)
		GuildChecker:RosterUpdate();
	end)
	GuildCheckerFrame.RosterUpdateButton:SetPoint("TOPRIGHT",GuildCheckerFrame.TitleBg,"TOPRIGHT",0,2);
	GuildCheckerFrame.RosterUpdateButton:Disable();

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
	UpdateApprovalListBox:SetTextColor(0.6,0.6,0.6)
	UpdateApprovalListBox:SetText("Enter Guild Name(s)");
	UpdateApprovalListBox:SetPoint("TOPLEFT",allowedGuildsListFontString,"BOTTOMLEFT",5,0)
	UpdateApprovalListBox:SetAutoFocus( false );
	UpdateApprovalListBox:SetScript('OnEditFocusGained', function(self)
		UpdateApprovalListBox:SetTextColor(1,1,1)
		UpdateApprovalListBox:SetText("")
	end)
	UpdateApprovalListBox:SetScript('OnEditFocusLost', function(self)
		UpdateApprovalListBox:SetTextColor(0.6,0.6,0.6)
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
	BlacklistEditBox:SetTextColor(0.6,0.6,0.6)
	BlacklistEditBox:SetText("Enter Player Name(s)");
	BlacklistEditBox:SetPoint("TOPLEFT",blacklistedPlayersFontString,"BOTTOMLEFT",5,-2)
	BlacklistEditBox:SetAutoFocus( false );
	BlacklistEditBox:SetScript('OnEditFocusGained', function(self)
		BlacklistEditBox:SetTextColor(1,1,1)
		BlacklistEditBox:SetText("")
	end)
	BlacklistEditBox:SetScript('OnEditFocusLost', function(self)
		BlacklistEditBox:SetTextColor(0.6,0.6,0.6)
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
	--aboutMessage:SetText("Notes: \n|cff9ACD321. Guild detection is based on player being visible/nearby.\n2. Enable friendly nameplates to boost guild detection.\n3. If you hide the add-on, show it again with \"/guildchecker show\".\n4. Use the Roster Update button if a player's name shows up as \"UNKNOWN\".\n5. Use the Detect button if a player's guild isn't detected automatically (can only be used once every few seconds).|r\n\nCreated By: |cff9370DBWiibur <TL> - Herod|r\nDiscord:      |cff9370DBWiibur#0001|r");
	aboutMessage:SetPoint("TOPLEFT", content3, "TOPLEFT", 5, -6);
	aboutMessage:SetWidth(460);
	aboutMessage:SetJustifyH("LEFT");

	local aboutString = newStack();
	addString(aboutString,"Created By: |cff9370DBWiibur <TL> - Herod|r".."      Discord: |cff9370DBWiibur#0001|r\n");
	addString(aboutString,"\nDescription:\n");
	addString(aboutString,"|cff9ACD32"..TOCNAME.." is a tool for guild coalitions that allows raid or group leaders to verify that everyone in the group belongs to a guild in the coalition.|r\n");
	addString(aboutString,"\nUsage:\n");
	addString(aboutString,"|cff9ACD321. Add guilds to the whitelist of approved guilds on the Options tab. This can be done individually or with a comma-separated list.|r\n");
	addString(aboutString,"|cff9ACD322. As group members join they will be added on the Players tab and their guild will be detected, if they are in range.|r\n");
	addString(aboutString,"|cff9ACD323. Use the Detect button if a player's guild isn't detected automatically (can only be used once every few seconds).|r\n");
	addString(aboutString,"|cff9ACD324. Use the Roster Update button if a player's name shows up as \"UNKNOWN\".|r\n");
	addString(aboutString,"|cff9ACD325. Enable friendly nameplates to boost guild detection.|r\n");
	addString(aboutString,"|cff9ACD326. If you hide the add-on, show it again with \"/guildchecker show\".|r\n");
	addString(aboutString,"|cff9ACD327. Blacklisted players should be removed from the group automatically, but this requires another roster update event to occur (can be triggered manually via the Roster Update button).|r\n");
	addString(aboutString,"\n");
	addString(aboutString,"Player Name Color Codes:\n");
	addString(aboutString,"|cff808080Guild unknown|r\n");
	addString(aboutString,"|cff0000FFUnguilded|r\n");
	addString(aboutString,"|cff00FF00In whitelisted guild|r\n");
	addString(aboutString,"|cffFF0000Not in whitelisted guild|r\n");
	addString(aboutString,"|cffFF00FFBlacklisted user|r\n");



	--addString(aboutString,"|cff9ACD32".."".."|r\n");

	aboutMessage:SetText(table.concat(aboutString));

	-----------------------------------------------------------------------------------------------------------



	GuildCheckerFrame.playerNames = {};
	GuildCheckerFrame.playerGuilds = {};
	GuildCheckerFrame.validatebuttons = {};
	GuildCheckerFrame.kickbuttons = {};
	GuildCheckerFrame.blacklistbuttons = {};

	GuildCheckerFrame:Hide();
	return GuildCheckerFrame;
end


--[[Useful stuff

print("|cffFF0000This text is red|r This text is white |cff00FF00This text is green|r |cff0000FFThis text is blue|r")
https://www.rapidtables.com/web/color/html-color-codes.html
yellowgreen	#9ACD32 |cff9ACD32 |r
deeppink	#FF1493 |cffFF1493|r
mediumpurple	#9370DB |cff9370DB|r
magenta	#FF00FF |cffFF00FF|r
gray	#808080 |cff808080|r

]]

--[[TODO:
2. create a reorder function for the player names to put blacklisted and non-approved guilds at the top automatically (might be an option toggle)
4. update rosterUpdate() to mass kick players not in an approved guild?
5. add title label on players tab to show number of players in the raid, number approved, number not approved/blacklisted/unguilded
	a. maybe something like 35/40 players approved (x approved players / group size)
6. make sure player name frames are being used efficiently, not wasting frames
	a. when a user leaves the group, recycle their frame so it can be used again
8. are there any cases where a blacklisted player in a whitelisted guild might cause issues?
9. update ParseNameplates() to remove blacklisted users - this doesn't work, i tried it already, the uninvite command won't execute via this event
	a. create a label for this type of message "blacklisted user detected" and show it in main window somewhere

- only display addon when in a group or in a raid
-there is a bug where a user's name color won't update when the blacklist is cleared or they are removed from the blacklist
- rosterupdate doesn't update the color of unguilded players correctly
]]
