--[[
Made by ksq.
Contact with me by bigkaszak [ a ] wp.pl .
Any ideas, bug reports are welcome.
]]
Bidder = LibStub("AceAddon-3.0"):NewAddon("DKP Bidder", "AceComm-3.0","AceTimer-3.0","AceEvent-3.0","AceSerializer-3.0");
local L = LibStub("AceLocale-3.0"):GetLocale("DKP-Bidder")
local GRI=LibStub("GuildRosterInfo-1.0");
--/script LibStub("AceAddon-3.0"):GetAddon("DKP Bidder"):CreateTimerFrame(10);
Bidder.bidMaster=nil
local B=Bidder;
Bidder.ver="530 101"
Bidder.view={};
--Bidder.players={};
Bidder.transfer={};
Bidder.minBid=0;
Bidder.prefix="DKP_Bidder";
Bidder.color = {
	CYAN="|cff00ffff",
	LIGHTRED="|cffff6060",
	LIGHTBLUE="|cff00ccff",
	BLUE="|cff0000ff",
	GREEN="|cff00ff00",
	RED="|cffff0000",
	GOLD="|cffffcc00",
	ALICEBLUE="|cFFF0F8FF",
	ANTIQUEWHITE="|cFFFAEBD7",
	AQUA="|cff00ffff",
	ORANGE="|cffffa500",
	SPRINGGREEN="|cff00ff7f",
	STEELBLUE="|cff4682b4",
	YELLOW="|cFFFFFF00",
	PURPLE="|cFF800080",
	MAGENTA="|cFFFF00FF",
	CRIMSON="|cFFDC143C",
	ARTIFACT="|cffe6cc80",
	LEGENDARY="|cffff8000",
	EPIC="|cffa335ee",
	RARE="|cff0070dd",
	UNCOMMON="|cff1eff00",
	WHITE="|cffffffff",
	POOR="|cff9d9d9d",
}
Bidder.colors={
	blue= "|cff3366ff",
	red= "|cffff0000",
	green= "|cff00ff00",
	yellow= "|cffffff00",
	grey= "|cffaaaaaa",
	white= "|cffffffff",
	close= "|r",
	class={
		["Death Knight"]={0.77,0.12,0.23,1.00,"|CFFC41F3B"},
		Druid={1.00,0.49,0.04,1.00,"|CFFFF7D0A"},
		Hunter= {0.67,0.83,0.45,1.00,"|CFFABD473"},
		Mage= {0.41,0.80,0.94,1.00,"|CFF69CCF0"},
		Paladin= {0.96,0.55,0.73,1.00,"|CFFF58CBA"},
		Priest={1.00,1.00,1.00,1.00,"|CFFFFFFFF"},
		Rogue= {1.00,0.96,0.41,1.00,"|CFFFFF569"},
		Shaman={0.14,0.35, 1.00,1.00,"|CFF2459FF"},
		Warlock={0.58,0.51,0.79,1.00,"|CFF9482C9"},
		Warrior={0.78,0.61,0.43,1.00,"|CFFC79C6E"},
		Monk={0,1,0.59,1.0,"|CFF00FF96"},
		unknown={0.50,0.50,0.50,1.00,"|CFF666666"}
		}
	}
Bidder.dropDownMenuTable = {
	{
	text = L["DKP Roster Menu"],
	isTitle = 1,
	notCheckable = 1,
	},

	{
	text = L["Transfer DKP"],
	func = function()
		local v=Bidder.view.rosterFrame.view;
		local point=v.bidderList:GetSelected();
		if point~=nil then
			local text=L["Type how many points you want to transfer to selected players: "]

			local sep="";
			local mains={};
			for i=1,#point do

					text=text..sep..point[i][1].data.name;
					table.insert(mains,point[i][1].data.name);
					sep=",";

			end
			text=text..". "..L["The sum you enter will be split among selected players."];

			if StaticPopupDialogs["DKPBidder_TitleDropDownMenu_TransferStaticPopup"]~=nil then table.wipe(StaticPopupDialogs["DKPBidder_TitleDropDownMenu_TransferStaticPopup"]); end;
			StaticPopupDialogs["DKPBidder_TitleDropDownMenu_TransferStaticPopup"] = {
				text = text,
				hasEditBox=true,
				button1 = L["Transfer"],
				button2 = L["Cancel"],
				EditBoxOnTextChanged = function (self, data)
					self:GetParent().button1:Enable()
				end,
				OnShow = function (self, data)
					self.mains=mains;
					self.button1:Disable();
				end,
				OnAccept = function(self, data, data2)
					local number=self.editBox:GetNumber();
					if number then
						B:Transfer(number,mains);
					end
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
			}
			StaticPopup_Show("DKPBidder_TitleDropDownMenu_TransferStaticPopup");
		end
	end,
	notCheckable = 1,
	},
	{
	text = L["Export selected data"],
	func = function()
		local v=Bidder.view.rosterFrame.view;
		local point=v.bidderList:GetSelected();
		if point~=nil then
			local text="<table>"


			local mains={};
			for i=1,#point do
					table.insert(mains,point[i][1].data.name);
			end
			for i=1,#mains do
				if GRI:GetMain(mains[i])==mains[i] then text=text.."<tr><td>"..mains[i].."</td><td>"..GRI:GetNet(mains[i]).."</td><td>"..GRI:GetTot(mains[i]).."</td><td>"..GRI:GetClass(mains[i]).."</td><td>"..GRI:GetRank(mains[i]).."</td></tr>";
				else text=text.."<tr><td>"..mains[i].."</td><td>"..GRI:GetMain(mains[i]).."</td><td>"..GRI:GetMain(mains[i]).."</td><td>"..GRI:GetClass(mains[i]).."</td><td>"..GRI:GetRank(mains[i]).."</td></tr>";
				end
			end
			text=text.."</table>";
			local AceGUI = LibStub("AceGUI-3.0")
			-- Create a container frame
			local f = AceGUI:Create("Frame")
			f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
			f:SetTitle(L["Export data"])
			f:SetStatusText(L["You can copy this by pressing ctrl+c."])
			f:SetHeight(400);
			--f:SetLayout("Flow")
			-- Create a button
			local btn = AceGUI:Create("MultiLineEditBox")
			--btn:SetRelativeWidth(1.0)
			btn:SetLabel("")
			btn:SetFullHeight(true)
			btn:SetFullWidth(true)
			btn:SetText(text)
			btn:DisableButton(true);
			btn:SetNumLines(20)
			--btn:SetCallback("OnClick", function() print("Click!") end)
			-- Add the button to the container
			f:AddChild(btn)

		end
	end,
	notCheckable = 1,
	},
	{
	notCheckable = 1,
	disabled=1,
	text="",
	},
	{
	text = CLOSE,
	func = function() CloseDropDownMenus() end,
	notCheckable = 1,
	},
}

local options = {
type = "group",
	args = {
		General = {
			order = 50,
			type = "group",
			name = "DKP - Bidder",
			desc = "General",
			args = {
				Intro = {
					order = 1,
					type = "description",
					name = "Quick and simple DKP Bidding tool.",
				},
				ToggleBidder = {
					order = 100,
					type = "execute",
					name = "Toggle DKP Bidder",
					desc = "Toggles the main DKP Bidder window",
					func = function()
						B:ToggleBidder()
					end
				},
				MinimapBtn = {
					order = 150,
					type = "execute",
					name = "Toggle Minimap Button",
					desc = "Toggles showing or hiding of the minimap button",
					func = function() --function to run when pressed
						B:ToggleMinimapButton()
					end,
				},
			},
		},
	},
}
local DEFAULTS={
	profile = {
		blacklist={
			Cloth=false, 
			Leather=false, 
			Mail=false, 
			Plate=false, 
			Conqueror=false, 
			Protector=false, 
			Vanquisher=false, 
			AutoHide=false,
			bystat = {
				ITEM_MOD_STRENGTH_SHORT=false, 
				ITEM_MOD_INTELLECT_SHORT=false, 
				ITEM_MOD_AGILITY_SHORT=false, 
				ITEM_MOD_SPIRIT_SHORT=false,}
		},
		enable= {["bidder"]=true, ["tooltips"]=true},
		minimapicon = {hide = false, minimapPos = 180, radius = 80},
	}
}

function B:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("DKPbidderDB", DEFAULTS, true)
	self.db.RegisterCallback(self, "OnProfileChanged", "Update")
	self.db.RegisterCallback(self, "OnProfileCopied",  "Update")
	self.db.RegisterCallback(self, "OnProfileReset",   "Update")
	if not self.db then
		Print("Error: Database not loaded correctly. Please exit out of WoW and delete DKP-Bidder.lua found in: \\World of Warcraft\\WTF\\Account\\<<Account Name>>\\<<Realm Name>>\\<<Player Name>>\\SavedVariables\\")
	end
	
	bidDB = self.db.profile
	
	-----ACE DB OPTIONS INIT-----
	self.Profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.Profiles.name = "Profiles"

	LibStub("AceConfig-3.0"):RegisterOptionsTable("DKP Bidder",          options)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("DKP Bidder.Profiles", self.Profiles)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DKP Bidder", "DKP Bidder")
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DKP Bidder.Profiles", self.Profiles.name, "DKP Bidder")

	self:RegisterComm(self.prefix); --todo: in other addon prefix is set as a global, find and destroy!
	
	B:CreateGUI()
	self:AttachSkin();
	self:RegisterEvent("GUILD_ROSTER_UPDATE");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	GRI:RegisterCallback("DataUpdated",self.RosterDataUpdate,self);
	
	local func=function(msg) self:SlashCmdFunction(msg) end;
	
	SlashCmdList["DKP_BIDDER"] = func
	SLASH_DKP_BIDDER1 = "/dkpb"
	SLASH_DKP_BIDDER2 = "/dkp_bidder"
	SLASH_DKP_BIDDER3 = "/dkpbidder"
	
	self:Print(B.colors["red"]..B.ver..B.colors["close"].." "..L["version Loaded"]);
end;
function B:OnEnable()
	B:CreateMinimapIcon();
end
function B:Update(event, database, newProfileKey)
	bidDB = database.profile
	B:RefreshOptions()
end
function B:GetPlayerTextColor(name)
	return self.colors.class[GRI:GetClass(name)][5];
end
function B:GetPlayerColor(name)
	return self.colors.class[GRI:GetClass(name)];
end
function B:Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(B.colors["grey"].."DKP - |r|CFF2459FFBidder"..B.colors["grey"].."> "..B.colors["close"]..msg);
end
function B:SlashCmdFunction(msg)
	if (msg==L["show"]) then
		B.mainFrame:Show();
	elseif msg==L["icon"] then
		if B:CheckMinimapStatus() then
			B:HideMinimapButton()
		else
			B:ShowMinimapButton()
		end;
	elseif msg==L["sum"] then
		local sum=0;
		local sumTot=0;
		local p=GRI:GetMainPlayers();
		for i=1,#p do
			sum=sum+GRI:GetNet(p[i]);
			sumTot=sumTot+GRI:GetTot(p[i]);
		end;
		self:Print(L["Guild dkp pool is "]..sum);
		self:Print(L["Total guild dkp acquired is "]..sumTot);
	elseif msg==L["exportAlts"] then
		local text=""

		local p=GRI:GetData();
		for i,v in pairs(p) do
			text=text..'Characters.setMain("'..i..'","'..v.main..'");';

		end;

		local AceGUI = LibStub("AceGUI-3.0")
		-- Create a container frame
		local f = AceGUI:Create("Frame")
		f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
		f:SetTitle(L["Export data"])
		f:SetStatusText(L["You can copy this by pressing ctrl+c."])
		f:SetHeight(400);
		--f:SetLayout("Flow")
		-- Create a button
		local btn = AceGUI:Create("MultiLineEditBox")
		--btn:SetRelativeWidth(1.0)
		btn:SetLabel("")
		btn:SetFullHeight(true)
		btn:SetFullWidth(true)
		btn:SetText(text)
		btn:DisableButton(true);
		btn:SetNumLines(20)
		--btn:SetCallback("OnClick", function() print("Click!") end)
		-- Add the button to the container
		f:AddChild(btn)

		--self:Print("Guild total dkp pool is "..sum);
	else
		B:Print(L["Possible usage with slash command:"])
		B:Print(" * "..L["show"].." - "..L["shows bidding frame"])
		B:Print(" * "..L["icon"].." - "..L["enabling/disabling minimap icon"])
		B:Print(" * "..L["sum"].." - "..L["prints summed amount of guild members dkp"])
	end
end;
function B:GetBidderList()
	return self.view.bidderList;
end;
