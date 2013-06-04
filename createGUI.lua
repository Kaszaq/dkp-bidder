local gs=LibStub("GuiSkin-1.0");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
local L = LibStub("AceLocale-3.0"):GetLocale("DKP-Bidder")
local GRI=LibStub("GuildRosterInfo-1.0");--todo tutaj tez?
local BidderLDB = LibStub("LibDataBroker-1.1")
local BidderIcon = LibStub("LibDBIcon-1.0", true)

local tooltips={
	["blistcloth"]={
		[1]="Ignore "..B.color["MAGENTA"].."Cloth|r biddings",},
	["blistleather"]={
		[1]="Ignore "..B.color["MAGENTA"].."Leather|r biddings"},
	["blistmail"]={
		[1]="Ignore "..B.color["MAGENTA"].."Mail|r biddings"},
	["blistplate"]={
		[1]="Ignore "..B.color["MAGENTA"].."Plate|r biddings"},
	["blistconq"]={
		[1]="Ignore "..B.color["MAGENTA"].."Conqueror|r tokens"},
	["blistprot"]={
		[1]="Ignore "..B.color["MAGENTA"].."Protector|r tokens"},
	["blistvanq"]={
		[1]="Ignore "..B.color["MAGENTA"].."Vanquisher|r tokens"},
	["blistint"]={
		[1]="Ignore items with "..B.color["MAGENTA"].."Intellect|r"},
	["blistspi"]={
		[1]="Ignore items with "..B.color["MAGENTA"].."Spirit|r"},
	["blistagi"]={
		[1]="Ignore items with "..B.color["MAGENTA"].."Agility|r"},
	["bliststr"]={
		[1]="Ignore items with "..B.color["MAGENTA"].."Strength|r"},
	["autohide"]={
		[1]=B.color["MAGENTA"].."Hides|r DKP Bidder when bidding starts on a blacklisted item"},
}
local BidderLauncher = BidderLDB:NewDataObject("DKP Bidder", 
	{label="DKP Bidder",
	type = "data source",
	text = "DKP Bidder",
	icon = "Interface\\Addons\\DKP-Bidder\\Arts\\Logo2.tga",
	OnClick = function(clickedframe, button)
		--if button == "RightButton" then B:MinimapMenu() else B:ToggleBidder() end
		B:ToggleBidder()
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("DKP Bidder")
		tt:AddLine(B.color.WHITE .. "Click|r to toggle DKP Bidder")
		--tt:AddLine(B.color.WHITE .. "Right-Click|r for options")
		--tt:AddLine(B.color.WHITE .. "Shift+Click|r to hide this button")
	end,
	}
)

function B:CreateGUI()
	B.mainFrame=CreateFrame("Frame","DkpBidderGUIframe",UIParent);
	table.insert(_G.UISpecialFrames, "DkpBidderGUIframe");
	local f=B.mainFrame;
	f:SetWidth(265);
	f:SetHeight(395);
	f:Hide();
	f:EnableMouse(true);
	f:SetMovable(true);
	f:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-100 ,0)
	f:SetScript("OnMouseDown",
			function(self)
				self:StartMoving();
			end)
	f:SetScript("OnMouseUp",
			function(self)
				self:StopMovingOrSizing();
			end)
	f:SetScript("OnShow",
			function(self)
				PlaySound("igCharacterInfoOpen");
				if GetNumGuildMembers()>0 then
					GRI:UpdateData()
					B.view.dkpAmountString:SetText("DKP: "..GRI:GetNet(UnitName("player")));

				end;
				GuildRoster();
			end)
	f:SetScript("OnHide",
			function(self)
				PlaySound("igCharacterInfoClose");
			end)


	f:SetFrameStrata("MEDIUM");
	f:SetToplevel(true);
	local v=self.view;
	local dividerWidth=(B.mainFrame:GetWidth()-8)*256/(256-52);

	--BORDER textures part
	v["logoTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_logoTexture","BACKGROUND",58,58,"TOPLEFT", B.mainFrame, "TOPLEFT", 0,-8,[[Interface\Addons\DKP-Bidder\Arts\Logo2.tga]]);
	v["topRightTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_topRightTexture","BORDER",128,256,"TOPRIGHT", B.mainFrame, "TOPRIGHT", 35,0,[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]);
	v["topLeftTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_topLeftTexture","BORDER",256,256,"TOPLEFT", B.mainFrame, "TOPLEFT", -8,0,[[Interface\TaxiFrame\UI-TaxiFrame-TopLeft]]);
	v["botLeftTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_botLeftTexture","BORDER",256,286,"BOTTOMLEFT", B.mainFrame, "BOTTOMLEFT", -8,-76,[[Interface\TaxiFrame\UI-TaxiFrame-BotLeft]]);
	v["botRightTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_botRightTexture","BORDER",128,286,"BOTTOMRIGHT", B.mainFrame, "BOTTOMRIGHT", 35,-76,[[Interface\TaxiFrame\UI-TaxiFrame-BotRight]]);


	--close button
	self.view["closeButton"]= CreateFrame("Button",self.ver.."closeButton", self.mainFrame, "UIPanelCloseButton");
	local cb=self.view["closeButton"];
	cb:SetPoint("TOPRIGHT",self.mainFrame,"TOPRIGHT",5,-8);
	cb:SetWidth(32);
	cb:SetHeight(32);
	--//

	
	v.optionsButton = CreateFrame("Button", self.ver.."optionsButton", f)
	v.optionsButton:SetHeight(20)
	v.optionsButton:SetWidth(20)
	v.optionsButton:SetNormalTexture("Interface\\Addons\\DKP-Bidder\\arts\\icon-config")
	v.optionsButton:SetHighlightTexture("Interface\\Addons\\DKP-Bidder\\arts\\icon-config", 0.2)
	v.optionsButton:SetAlpha(0.8)
	v.optionsButton:SetPoint("TOPRIGHT", self.mainFrame, "TOPRIGHT", -22, -13);
	v.optionsButton:Show()
	v.optionsButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	v.optionsButton:SetScript("OnClick", function()
		local _,_,_,x = v.optionsFrame:GetPoint(v.optionsFrame:GetNumPoints())
		if x>=-100 then
			v.optionsFrame:SetPoint("TOPLEFT", f, "TOPRIGHT", -182,-18)
		else
			v.optionsFrame:SetPoint("TOPLEFT", f, "TOPRIGHT", -10,-18)
		end
	end)
	
	
	v.optionsFrame=CreateFrame("Frame",self.ver.."_optionsFrame",f);
	--v.optionsFrame:EnableMouse(true);
	v.optionsFrame:SetWidth(200);
	v.optionsFrame:SetHeight(361);
	v.optionsFrame:SetPoint("TOPLEFT", f, "TOPRIGHT", -182,-18)
	v.optionsFrame:SetMovable(true)
	v.optionsFrame:SetFrameLevel(f:GetFrameLevel()-1)
	v.optionsFrame:SetBackdrop({
		  bgFile =[[Interface\FrameGeneral\UI-Background-Rock]],
		  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		  tile = false,
		  atileSize = 32,
		  edgeSize =32,
		  insets = { left=11,right=11, top=10, bottom=10}
	})
	B:CreateOptions()
	
	--top gui part
	v.dkpAmountString=gs.CreateFontString(B.mainFrame,self.ver.."_dkpAmountString","ARTWORK","DKP:","TOPLEFT",B.mainFrame,"TOPLEFT",70,-45);
	local t=v.dkpAmountString
	t:SetFont([[Fonts\MORPHEUS.ttf]],18);
	--t:SetTextColor(1,1,1,1);
	--//

	--info part
	v.basicInfoTitleString=gs.CreateFontString(B.mainFrame,self.ver.."_basicInfoTitleString","ARTWORK","Info","TOP",B.mainFrame,"TOP",0,-80);
	v.minBidString=gs.CreateFontString(B.mainFrame,self.ver.."_minBidString","ARTWORK","Min bid: unknown","LEFT",B.mainFrame,"LEFT",20,0);
	v.minBidString:SetPoint("TOP",v.basicInfoTitleString,"BOTTOM",0,-4);
	v.bidMasterString=gs.CreateFontString(B.mainFrame,self.ver.."_BidMasterString","ARTWORK","Bid master: unknown","TOPLEFT",v.minBidString,"BOTTOMLEFT",0,-5);



	v.itemLinkString=gs.CreateFontString(f,nil,"ARTWORK","Item: ","TOPLEFT",v.bidMasterString,"BOTTOMLEFT",0,-5);

	v.itemLinkEditBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")

	v.itemLinkEditBox:SetPoint('LEFT', v.itemLinkString,'RIGHT',10 ,0)
	v.itemLinkEditBox:SetPoint('RIGHT', B.mainFrame,'RIGHT',-16 ,0)
	v.itemLinkEditBox:Show();
	v.itemLinkEditBox:Disable();
	v.itemLinkEditBox:SetAutoFocus(false);


	v.itemLinkEditBox:SetHeight(20);
	v.tooltipFrameHelp = CreateFrame("Frame",nil,f)
	v.itemLinkEditBox:SetScript("OnEnter", function(self)
		v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
				B:ShowGameTooltip();
			end)
	end)
	v.itemLinkEditBox:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
				-- Dont do anything
			end)
	end)




	v.listDivider=gs.CreateTexture(B.mainFrame,self.ver.."_dividerBorder","ARTWORK",dividerWidth,16,"LEFT", B.mainFrame, "LEFT", 6,0,[[Interface\MailFrame\MailPopup-Divider]]);
	v.listDivider:SetPoint("TOP",v.itemLinkEditBox,"BOTTOM",0,-2);
	--//

	--bidding list part
	v.listTitleString=gs.CreateFontString(B.mainFrame,self.ver.."_listTitleString","ARTWORK","Bidding list","TOP",v.listDivider,"BOTTOM",0,4);
	v.listTitleString:SetPoint("LEFT",(f:GetWidth()-v.listTitleString:GetWidth())/2+2,0);
	local data={columns={L["Nr"],L["Name"],L["Bid"],L["Total"]},columnsWidth={25,128,40,40},rows=5,height=70};
	self.countingFunction=function(a) return a.."." end;
	v.bidderList=LibStub("WowList-1.0"):CreateNew(self.ver.."_bidderList",data,B.mainFrame);
	v.bidderList:SetPoint('TOP', v.listTitleString,'BOTTOM', 0,-6);
	v.bidderList:SetPoint('LEFT', B.mainFrame,'LEFT', 16,0);
	v.bidderList:SetMultiSelection(false);
	--//


	--buttons part
	--button divider
	v.buttonDivider=gs.CreateTexture(B.mainFrame,nil,"ARTWORK",dividerWidth,16,"LEFT", v.listDivider, "LEFT", 0,0,[[Interface\MailFrame\MailPopup-Divider]]);
	v.buttonDivider:SetPoint("TOP",v.bidderList,"BOTTOM",0,0);
	--bidEditBox
	v.bidEditBox = CreateFrame("EditBox", self.ver.."Amount", B.mainFrame, "InputBoxTemplate")
	v.bidEditBox:SetMaxLetters(5)
	v.bidEditBox:SetNumeric()
	v.bidEditBox:SetNumber(0);
	v.bidEditBox:SetPoint('LEFT', B.mainFrame,'LEFT', 22,0)
	v.bidEditBox:SetPoint('TOP', v.buttonDivider,'BOTTOM', 0,-2)
	v.bidEditBox:SetAutoFocus(false);
	v.bidEditBox:SetScript("OnEscapePressed",function(self)
		self:ClearFocus();
	  end)
	--//bidEditBox


	--Bid Button
	v.bidButton = CreateFrame("Button", self.ver.."ButtonBid", B.mainFrame, "UIPanelButtonTemplate")
	v.bidButton:SetText("Bid");
	v.bidButton:SetPoint('TOPLEFT', v.bidEditBox,'TOPRIGHT', 5,0)
	v.bidButton:SetScript("OnClick",function(self)
		B:Bid(v.bidEditBox:GetNumber());
	  end)
	--//Bid Button


	---EditBox for over bidding
	v.overBidEditBox = CreateFrame("EditBox", self.ver.."OverAmount", B.mainFrame, "InputBoxTemplate")
	v.overBidEditBox:SetMaxLetters(6)
	v.overBidEditBox:SetNumeric()
	v.overBidEditBox:SetPoint('TOPLEFT', v.bidEditBox,'BOTTOMLEFT',0 ,-5)
	v.overBidEditBox:SetNumber(10);
	v.overBidEditBox:Show();
	v.overBidEditBox:SetAutoFocus(false);
	v.overBidEditBox:SetScript("OnEscapePressed",function(self)
		self:ClearFocus();
	  end)
	v.overBidEditBox:SetScript("OnTextChanged",function()
		v.overBidButton:SetText(L["OverBid by "]..v.overBidEditBox:GetNumber());
	  end)
	--//EditBox

	--OverBid Button
	v.overBidButton = CreateFrame("Button", self.ver.."ButtonOverBid", B.mainFrame, "UIPanelButtonTemplate")

	v.overBidButton:SetText(L["OverBid by "]..v.overBidEditBox:GetNumber());
	v.overBidButton:SetPoint('TOPLEFT',v.overBidEditBox,'TOPRIGHT', 5,0)
	v.overBidButton:SetScript("OnClick",function()
		if B:GetBidderList():GetData(1)~=nil then
			B:Bid(v.overBidEditBox:GetNumber()+B:GetBidderList():GetData(1)[3].name);
		else
			B:Bid(B.minBid);
		end
	  end)
	--//OverBid Button

	--Roster button
	v.openRosterButton= CreateFrame("Button", nil, B.mainFrame, "UIPanelButtonTemplate")
	v.openRosterButton:SetText(L["Open DKP roster"]);
	v.openRosterButton:SetPoint('TOPLEFT', v.overBidButton,'BOTTOMLEFT', 0,-5)
	v.openRosterButton:SetScript("OnClick",function(self)
		if B.view.rosterFrame:IsShown() then
			B.view.rosterFrame:Hide();
		else
			B.view.rosterFrame:Show();
		end
	  end)
	--//Roster Button
	
	
	-- FORCE SHOW STANDBY QUERY WINDOW - FOR TESTING
	-- v.openStandbyButton= CreateFrame("Button", nil, B.mainFrame, "UIPanelButtonTemplate")
	-- v.openStandbyButton:SetText(L["Open Standby Query"]);
	-- v.openStandbyButton:SetPoint('TOPLEFT', v.overBidButton,'BOTTOMLEFT', 180,-5)
	-- v.openStandbyButton:SetScript("OnClick",function(self)
		-- if B.view.standbyQuery:IsShown() then
			-- B.view.standbyQuery:Hide()
		-- else
			-- B.view.standbyQuery:Show()
		-- end
	  -- end)




	self:CreateTitle()
	self:CreateTimerFrame();
	v.timerFrame:SetPoint("BOTTOMLEFT",B.mainFrame,"BOTTOMLEFT",14,20);
	v.timerFrame:SetWidth(B.mainFrame:GetWidth()-24);
	v.timerFrame:SetHeight(16);
	--self:CreateTimerFrame(30);
	v.rosterFrame=B:CreateRosterFrame();
	v.standbyQuery=B:CreateStandbyQueryFrame();
	
	--disable buttons
	v.overBidButton:Disable();
	v.bidButton:Disable();

end

function B:CreateOptions()
	local f=B.mainFrame
	local v=self.view
	local y, newline, spacer=-36, 23, 43
	
	if not v.blisttext then
		v.blisttext=gs.CreateFontString(v.optionsFrame,self.ver.."_BlackListText","ARTWORK","Blacklist","TOP",v.optionsFrame,"TOP",4,-14);
		v.blisttext:SetFont([[Fonts\MORPHEUS.ttf]], 20)--[[Fonts\MORPHEUS.ttf]] --,16);
		
		--CLOTH--
		v.blistCloth=CreateFrame("CheckButton",self.ver.."_blistCloth",v.optionsFrame , "UICheckButtonTemplate");
		v.blistCloth:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistCloth:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistCloth:GetName() .. "Text"]:SetText("Cloth")
		
		--LEATHER--
		v.blistLeather=CreateFrame("CheckButton",self.ver.."_blistLeather",v.optionsFrame , "UICheckButtonTemplate");
		v.blistLeather:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 90, y)
		v.blistLeather:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistLeather:GetName() .. "Text"]:SetText("Leather")
		
		y=y-newline
		--MAIL--
		v.blistMail=CreateFrame("CheckButton",self.ver.."_blistMail",v.optionsFrame , "UICheckButtonTemplate");
		v.blistMail:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistMail:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistMail:GetName() .. "Text"]:SetText("Mail")
		
		--PLATE--
		v.blistPlate=CreateFrame("CheckButton",self.ver.."_blistPlate",v.optionsFrame , "UICheckButtonTemplate");
		v.blistPlate:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 90, y)
		v.blistPlate:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistPlate:GetName() .. "Text"]:SetText("Plate")
		
		y=y-spacer
		--CONQUEROR TOKENS--
		v.blistConq=CreateFrame("CheckButton",self.ver.."_blistConq",v.optionsFrame , "UICheckButtonTemplate");
		v.blistConq:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistConq:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistConq:GetName() .. "Text"]:SetText("Conqueror Tokens")
		
		y=y-newline
		--PROTECTOR TOKENS--
		v.blistProt=CreateFrame("CheckButton",self.ver.."_blistProt",v.optionsFrame , "UICheckButtonTemplate");
		v.blistProt:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistProt:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistProt:GetName() .. "Text"]:SetText("Protector Tokens")
		
		y=y-newline
		--VANQUISHER TOKENS--
		v.blistVanq=CreateFrame("CheckButton",self.ver.."_blistVanq",v.optionsFrame , "UICheckButtonTemplate");
		v.blistVanq:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistVanq:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistVanq:GetName() .. "Text"]:SetText("Vanquisher Tokens")
		
		y=y-spacer
		--INTELLECT--
		v.blistInt=CreateFrame("CheckButton",self.ver.."blistInt",v.optionsFrame , "UICheckButtonTemplate");
		v.blistInt:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistInt:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistInt:GetName() .. "Text"]:SetText("Intellect")
		
		y=y-newline
		--SPIRIT--
		v.blistSpi=CreateFrame("CheckButton",self.ver.."_blistSpi",v.optionsFrame , "UICheckButtonTemplate");
		v.blistSpi:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistSpi:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistSpi:GetName() .. "Text"]:SetText("Spirit")
		
		y=y-newline
		--AGILITY--
		v.blistAgi=CreateFrame("CheckButton",self.ver.."blistAgi",v.optionsFrame , "UICheckButtonTemplate");
		v.blistAgi:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistAgi:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistAgi:GetName() .. "Text"]:SetText("Agility")
		
		y=y-newline
		--STRENGTH--
		v.blistStr=CreateFrame("CheckButton",self.ver.."_blistStr",v.optionsFrame , "UICheckButtonTemplate");
		v.blistStr:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.blistStr:SetFrameLevel(f:GetFrameLevel()-1)
		_G[v.blistStr:GetName() .. "Text"]:SetText("Strength")
		
		y=y-spacer
		--AUTO HIDE?--
		v.autoHide=CreateFrame("CheckButton",self.ver.."_autoHide",v.optionsFrame , "UICheckButtonTemplate");
		v.autoHide:SetPoint("TOPLEFT",v.optionsFrame, "TOPLEFT", 25, y)
		v.autoHide:SetFrameLevel(f:GetFrameLevel()-1)
		--_G[v.autoHide:GetName() .. "Text"]:SetFont("GameFontNormal",13)
		_G[v.autoHide:GetName() .. "Text"]:SetText("Auto Hide?")
		
	end
	
	v.blistCloth:Show()
	v.blistLeather:Show()
	v.blistMail:Show()
	v.blistPlate:Show()
	v.blistConq:Show()
	v.blistProt:Show()
	v.blistVanq:Show()
	v.blistInt:Show()
	v.blistSpi:Show()
	v.blistAgi:Show()
	v.blistStr:Show()
	v.autoHide:Show()
	
	
	--if not bidDB.blacklist then
	--	bidDB.blacklist={}
	--end
	
	v.blistCloth:SetScript("OnEnter", function(self) B:OnEnter(self,"blistcloth") end)
	v.blistCloth:SetScript("OnLeave", function(self) B:OnLeave(self) end)
	v.blistCloth:SetChecked(bidDB.blacklist.Cloth)
	v.blistCloth:SetScript("OnClick", function()
		if v.blistCloth:GetChecked()==1 then
			bidDB.blacklist.Cloth=true
		else
			bidDB.blacklist.Cloth=false
		end
	end);
	
	v.blistLeather:SetScript("OnEnter", function(self) B:OnEnter(self,"blistleather") end)
	v.blistLeather:SetScript("OnLeave", function(self) B:OnLeave(self) end)
	v.blistLeather:SetChecked(bidDB.blacklist.Leather)
	v.blistLeather:SetScript("OnClick", function()
		if v.blistLeather:GetChecked()==1 then
			bidDB.blacklist.Leather=true
		else
			bidDB.blacklist.Leather=false
		end
	end);

	v.blistMail:SetScript("OnEnter", function(self) B:OnEnter(self,"blistmail") end)
	v.blistMail:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistMail:SetChecked(bidDB.blacklist.Mail)
	v.blistMail:SetScript("OnClick", function()
		if v.blistMail:GetChecked()==1 then
			bidDB.blacklist.Mail=true
		else
			bidDB.blacklist.Mail=false
		end
	end);

	v.blistPlate:SetScript("OnEnter", function(self) B:OnEnter(self,"blistplate") end)
	v.blistPlate:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistPlate:SetChecked(bidDB.blacklist.Plate)
	v.blistPlate:SetScript("OnClick", function()
		if v.blistPlate:GetChecked()==1 then
			bidDB.blacklist.Plate=true
		else
			bidDB.blacklist.Plate=false
		end
	end);

	v.blistConq:SetScript("OnEnter", function(self) B:OnEnter(self,"blistconq") end)
	v.blistConq:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistConq:SetChecked(bidDB.blacklist.Conqueror)
	v.blistConq:SetScript("OnClick", function()
		if v.blistConq:GetChecked()==1 then
			bidDB.blacklist.Conqueror=true
		else
			bidDB.blacklist.Conqueror=false
		end
	end);

	v.blistProt:SetScript("OnEnter", function(self) B:OnEnter(self,"blistprot") end)
	v.blistProt:SetScript("OnLeave", function(self) B:OnLeave(self) end)		
	v.blistProt:SetChecked(bidDB.blacklist.Protector)
	v.blistProt:SetScript("OnClick", function()
		if v.blistProt:GetChecked()==1 then
			bidDB.blacklist.Protector=true
		else
			bidDB.blacklist.Protector=false
		end
	end);

	v.blistVanq:SetScript("OnEnter", function(self) B:OnEnter(self,"blistvanq") end)
	v.blistVanq:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistVanq:SetChecked(bidDB.blacklist.Vanquisher)
	v.blistVanq:SetScript("OnClick", function()
		if v.blistVanq:GetChecked()==1 then
			bidDB.blacklist.Vanquisher=true
		else
			bidDB.blacklist.Vanquisher=false
		end
	end);
	
	v.blistInt:SetScript("OnEnter", function(self) B:OnEnter(self,"blistint") end)
	v.blistInt:SetScript("OnLeave", function(self) B:OnLeave(self) end)
	v.blistInt:SetChecked(bidDB.blacklist.bystat.ITEM_MOD_INTELLECT_SHORT)
	v.blistInt:SetScript("OnClick", function()
		if v.blistInt:GetChecked()==1 then
			bidDB.blacklist.bystat.ITEM_MOD_INTELLECT_SHORT=true
		else
			bidDB.blacklist.bystat.ITEM_MOD_INTELLECT_SHORT=false
		end
	end);

	v.blistAgi:SetScript("OnEnter", function(self) B:OnEnter(self,"blistagi") end)
	v.blistAgi:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistAgi:SetChecked(bidDB.blacklist.bystat.ITEM_MOD_AGILITY_SHORT)
	v.blistAgi:SetScript("OnClick", function()
		if v.blistAgi:GetChecked()==1 then
			bidDB.blacklist.bystat.ITEM_MOD_AGILITY_SHORT=true
		else
			bidDB.blacklist.bystat.ITEM_MOD_AGILITY_SHORT=false
		end
	end);

	v.blistStr:SetScript("OnEnter", function(self) B:OnEnter(self,"bliststr") end)
	v.blistStr:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistStr:SetChecked(bidDB.blacklist.bystat.ITEM_MOD_STRENGTH_SHORT)
	v.blistStr:SetScript("OnClick", function()
		if v.blistStr:GetChecked()==1 then
			bidDB.blacklist.bystat.ITEM_MOD_STRENGTH_SHORT=true
		else
			bidDB.blacklist.bystat.ITEM_MOD_STRENGTH_SHORT=false
		end
	end);

	v.blistSpi:SetScript("OnEnter", function(self) B:OnEnter(self,"blistspi") end)
	v.blistSpi:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.blistSpi:SetChecked(bidDB.blacklist.bystat.ITEM_MOD_SPIRIT_SHORT)
	v.blistSpi:SetScript("OnClick", function()
		if v.blistSpi:GetChecked()==1 then
			bidDB.blacklist.bystat.ITEM_MOD_SPIRIT_SHORT=true
		else
			bidDB.blacklist.bystat.ITEM_MOD_SPIRIT_SHORT=false
		end
	end);

	v.autoHide:SetScript("OnEnter", function(self) B:OnEnter(self,"autohide") end)
	v.autoHide:SetScript("OnLeave", function(self) B:OnLeave(self) end)	
	v.autoHide:SetChecked(bidDB.blacklist.AutoHide)
	v.autoHide:SetScript("OnClick", function()
		if v.autoHide:GetChecked()==1 then
			bidDB.blacklist.AutoHide=true
		else
			bidDB.blacklist.AutoHide=false
		end
	end);
end

--SET TITLE - window with linked item or other useless info.
function B:CreateTitle()
	local v=B.view;
	v.titleFrame = CreateFrame("Frame",self.ver.."_TitleFrame",B.mainFrame)
	v.titleString=gs.CreateFontString(B.mainFrame,self.ver.."_Title","ARTWORK","DKP Bidder","TOP",v.titleFrame,"TOP",18,-14);
	local title=self.view["title"];
	v.titleFrame:SetHeight(20)
	v.titleFrame:SetWidth(v.titleString:GetWidth() + 20)
	v.titleString:SetPoint("TOP", B.mainFrame, "TOP", 18,-18);
	v.titleFrame:SetPoint("TOP", v.titleString, "TOP", 0, 0);
	v.titleFrame:SetMovable(true)
	v.titleFrame:EnableMouse(true)
	v.titleFrame:SetScript("OnMouseDown",function()
		B.mainFrame:StartMoving()
	end)
	v.titleFrame:SetScript("OnMouseUp",function()
		B.mainFrame:StopMovingOrSizing()
	end)
end
function B:ShowGameTooltip()
	local v=self.view;
	GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
	GameTooltip:ClearAllPoints();
	GameTooltip:SetPoint("bottom", v.itemLinkEditBox, "top", 0, 0)
	GameTooltip:ClearLines()

	if v.itemLinkEditBox:GetText()~="" then
		GameTooltip:SetHyperlink(v.itemLinkEditBox:GetText())
	end

end

B.timeLeft=0;
function B:CreateTimerFrame(timeleft)--TODO: move this to gui lib, and fix so it wouldnt call onupdate all the time :/ create->remove create->remove
	if timeleft==nil then timeleft=-1 end;
	local v=B.view;
	B.timerIsOn=true;
	if v.StringTimer~=nil then v.StringTimer:SetText("Time left for bidding: "..timeleft); end;
	B.timeLeft=timeleft;
	B.lastTimerValue=timeleft;
	if(v.timerFrame == nil) then
		v.timerFrame = CreateFrame("Frame",self.ver.."_timerFrameBackground", B.mainFrame);

		v.timerProgressFrame = CreateFrame("Frame",self.ver.."_timerFrame", v.timerFrame);


		v.timerProgressFrame:SetScript("onUpdate",function (self,elapse)
						if B.timeLeft>0 and B.timerIsOn then
							local a=B.timeLeft;
							v.timerProgressFrame:SetHeight(self:GetParent():GetHeight())
								v.timerProgressFrame:SetBackdropColor(0.5-B.timeLeft/B.lastTimerValue/2,B.timeLeft/B.lastTimerValue/2,0,1)
								v.timerProgressFrame:SetWidth((self:GetParent():GetWidth())*B.timeLeft/B.lastTimerValue)
							B.timeLeft=B.timeLeft-elapse;
							if ceil(B.timeLeft)<ceil(a) then
								if ceil(a)~=0 then v.StringTimer:SetText(L["Time left: "]..ceil(B.timeLeft)); end;
							end;
						elseif B.timerIsOn then
							v.timerProgressFrame:SetWidth(-1);
							B.timerIsOn=false;

							v.StringTimer:SetText(L["Timer off."]);

						end;
					end);
		local backdrop = {
			bgFile =  gs.blank,  -- path to the background texture
			edgeFile = "",  -- path to the border texture
			tile = false,    -- true to repeat the background texture to fill the frame, false to scale it
			tileSize = 0,  -- size (width or height) of the square repeating background tiles (in pixels)
			edgeSize = 0,  -- thickness of edge segments and square size of edge corners (in pixels)
			insets = {    -- distance from the edges of the frame to those of the background texture (in pixels)
				left = 0,
				right =0,
				top = 0,
				bottom = 0
			}
		}
		v.timerProgressFrame:SetBackdrop(backdrop);


		v.timerProgressFrame:SetHeight(v.timerFrame:GetHeight()-2);
		v.timerProgressFrame:SetWidth(0);

		v.StringTimer  = v.timerProgressFrame:CreateFontString(self.ver.."StringTimer","OVERLAY","GameFontNormal")
		v.StringTimer:SetText("Timer off.");
		v.timerProgressFrame:Show();
		v.timerProgressFrame:SetPoint("TOPLEFT",v.timerFrame,"TOPLEFT",0,0);
		v.StringTimer:SetPoint("TOP",v.timerFrame,"TOP",0,-3);
		B.timerIsOn=false;
	end




	--for not reapeatable call on settext;


end

function B:ToggleBidder()
	if (B.mainFrame:IsShown()==nil) then self.mainFrame:Show(); else self.mainFrame:Hide(); end;
end

function B:CreateRosterFrame()

		local f=gs:CreateFrame(self.ver.."_RosterFrame","DKP Roster","BASIC",400,415,'LEFT',UIParent,'LEFT',100 ,0);--400 375
		f:Hide();
		f.showAlts=true;
		f.showOffline=true;
		f.view={};
		f:SetScript("OnShow",
				function(self)
					PlaySound("igCharacterInfoOpen");
					self:UpdateList();
					GuildRoster();
				end)
		f:SetScript("OnHide",
				function(self)
					PlaySound("igCharacterInfoClose");
				end)
		local v=f.view;


		v.dropDownMenu= CreateFrame("Frame", B.ver.."DKPBidder_TitleDropDownMenu", f, "UIDropDownMenuTemplate")

		function f:RightMouseClick(arg,arg2)
			local cursorX, cursorY = GetCursorPosition()
			local scale=UIParent:GetEffectiveScale();
			EasyMenu(B.dropDownMenuTable, self.view.dropDownMenu,"UIParent", cursorX/scale, cursorY/scale, "MENU",0.5)

		end



		local data={columns={L["Name"],L["Current"],L["Overall"],L["Spent"],L["Rank"]},columnsWidth={90,60,60,60,90},rows=20,height=280};
		v.bidderList=LibStub("WowList-1.0"):CreateNew(self:GetName().."_bidderList",data,f);
		v.bidderList:SetPoint('TOPLEFT', f,'TOPLEFT', 16,-60);
		v.bidderList:SetColumnSortFunction(1,function(a,b) return a.data.name<b.data.name end)
		v.bidderList:SetColumnSortFunction(2,function(a,b) return a>b end)
		v.bidderList:SetColumnSortFunction(3,function(a,b) return a>b end)
		v.bidderList:SetColumnSortFunction(4,function(a,b) return a>b end)
		v.bidderList:SetColumnSortFunction(5,function(a,b) return a.rankIndex>b.rankIndex end)
		v.bidderList.RegisterCallback(f, "RightMouseClick");





		v.filterFontString=gs.CreateFontString(f,nil,"ARTWORK","Filter: ","TOPLEFT",f,"TOPLEFT",16,-32);
		v.filterFontString:SetTextColor(1,1,1,1);
		---FilterEditBox
		v.filterEditBox = CreateFrame("EditBox",nil, f, "InputBoxTemplate")
		v.filterEditBox:SetMaxLetters(20)
		v.filterEditBox:SetPoint('TOPLEFT', v.filterFontString,'TOPRIGHT',5 ,4)
		v.filterEditBox:Show();
		v.filterEditBox:SetAutoFocus(false);
		v.filterEditBox:SetHeight(20);
		v.filterEditBox:SetWidth(100);
		v.filterEditBox:SetScript("OnEscapePressed",function(self)
			self:ClearFocus();
		  end)
		v.filterEditBox:SetScript("OnTextChanged",function(self)

			local txt=string.lower(v.filterEditBox:GetText());
			txt = string.gsub(txt, "(%W)", "%%%1")
			self:GetParent().view.bidderList:AddFilter("filterByEditBox",function(data)

					return  string.find(string.lower(data[1].data.main), txt) or
						string.find(string.lower(data[1].data.name), txt) or
						string.find(data[2], txt) or
						string.find(data[3], txt) or
						string.find(data[4], txt) or
						string.find(string.lower(data[5].name), txt);
				end);
			self:GetParent().view.bidderList:UpdateView();
		  end)
		--//FilterEditBox








		v.altsCheckBox=gs.CreateCheckBox(f,"Show alts");
		v.altsCheckBox:Show();
		v.altsCheckBox:SetPoint('TOPLEFT', v.bidderList,'BOTTOMLEFT', 0,-10);
		v.altsCheckBox:SetChecked(true);
		v.altsCheckBox:SetScript("OnClick",function(self, button, down)
			if self:GetChecked() then
				self:GetParent().view.bidderList:RemoveFilter("showAlts");
				self:GetParent().view.bidderList:UpdateView();
			else
				self:GetParent().view.bidderList:AddFilter("showAlts",function(data) return data[1].data.main==data[1].data.name end);
				self:GetParent().view.bidderList:UpdateView();
			end
		end)

		v.offlineCheckBox=gs.CreateCheckBox(f,"Show offline");
		v.offlineCheckBox:Show();
		v.offlineCheckBox:SetPoint('BOTTOMLEFT',v.altsCheckBox,'BOTTOMRIGHT', 100,0);
		v.offlineCheckBox:SetChecked(true);
		v.offlineCheckBox:SetScript("OnClick",function(self, button, down)
			if self:GetChecked() then
				self:GetParent().view.bidderList:RemoveFilter("showOffline");
				self:GetParent().view.bidderList:UpdateView();
			else
				self:GetParent().view.bidderList:AddFilter("showOffline",function(data) return data[1].data.online end);
				self:GetParent().view.bidderList:UpdateView();
			end
		end)



		v.showRaidMembersCheckBox=gs.CreateCheckBox(f,"Raid only");
		v.showRaidMembersCheckBox:Show();
		v.showRaidMembersCheckBox:SetPoint('BOTTOMLEFT',v.offlineCheckBox,'BOTTOMRIGHT', 100,0);
		v.showRaidMembersCheckBox:SetChecked(false);
		v.showRaidMembersCheckBox:SetScript("OnClick",function(self, button, down)
			if not self:GetChecked() then
				self:GetParent().view.bidderList:RemoveFilter("showRaidMembersOnly");
				self:GetParent().view.bidderList:UpdateView();
			else
				self:GetParent().view.bidderList:AddFilter("showRaidMembersOnly",function(data)
					for i=1,40 do
						if GetRaidRosterInfo(i) and GetRaidRosterInfo(i)==data[1].data.name then return true end;
					end;
					return false
				end);
				self:GetParent().view.bidderList:UpdateView();
			end
		end)

		function f:UpdateList()
			local players=GRI:GetData();
			local v=self.view;
			local data;

			for i,d in pairs(v.bidderList:GetKeySet()) do

				if players[i]==nil then

					v.bidderList:RemoveData(d,i);

				end;
			end;

			for i,d in pairs(players) do

				if v.bidderList:GetDataByKey(i)==nil then
					data={
						{
							func=function(a,b,data) if data.main==data.name then return data.main else return data.name.."("..data.main..")" end end,
							data={main=d.main,name=i,online=d.online},
							color=d.color;
						},
						d.net,d.tot,(d.tot-d.net),{name=d.rank,rankIndex=d.rankIndex},
					}
					v.bidderList:AddData(data,i);

				else

					data=v.bidderList:GetDataByKey(i);
					data[1]={
							func=function(a,b,data) if data.main==data.name then return data.main else return data.name.."("..data.main..")" end end,
							data={main=d.main,name=i,online=d.online},
							color=d.color,
						};
					data[2]=d.net
					data[3]=d.tot
					data[4]=(d.tot-d.net)
					data[5]={name=d.rank,rankIndex=d.rankIndex}

				end;

			end;
			v.bidderList:UpdateView();
		end;
		return f;
end;

function B:CreateStandbyQueryFrame()
	B:Print("Standby Query creating.")
	local f=gs:CreateFrame(self.ver.."_StandbyQueryFrame","Standby Query","BASIC",280,130,'CENTER',UIParent,'CENTER',0 ,0);--400 375
	f:Hide()
	f.view={}
	local v=f.view
	v.acceptQuery=gs:CreateButton(self.ver.."_acceptQuery", "Yes", 120, "CENTER", f,"CENTER", 0, -30)
	--v.cancelQuery=gs:CreateButton(self.ver.."_cancelQuery", "No", 20, "LEFT", v.acceptQuery,"RIGHT", 60, 0)
	--(name,level,text,point,relativeTo,point2,x,y)
	v.standbyQueryText1=gs.CreateFontString(f, self.ver.."_standbyQueryText1", "ARTWORK", "Ragnaros has been slain!", "CENTER", f, "CENTER", 0, 25)
	v.standbyQueryText2=gs.CreateFontString(f, self.ver.."_standbyQueryText2", "ARTWORK", "Receive 100 DKP?", "CENTER", f, "CENTER", 0, 4)
	return f;
end
function B:RefreshOptions()
	B:CreateOptions()
end

function B:OnEnter(self,arg)
	if bidDB.enable.tooltips then
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		for i=1,#tooltips[arg] do
			GameTooltip:AddLine(tooltips[arg][i],1,1,1,1)
		end
		GameTooltip:Show()
	end
end

function B:OnLeave(self)
	if bidDB.enable.tooltips then
		GameTooltip:Hide()
		GameTooltip:ClearLines()
	end
end

--  Minimap Button  --
function B:MinimapMenu()
	-- local mainList = {[1]="Cancel"}
	-- local i = 1
	-- for layoutname, layoutnames in pairs(pDB.layoutlist) do
		-- savesList[i] = 
			-- { text = layoutnames, notCheckable=true, hasArrow = true,
				-- menuList = {
					-- { text = "Restore", notCheckable=true, func = function() RM:startMover(layoutnames); end },
					-- { text = "Invite", notCheckable=true, func = function() RM:inviteRaid(layoutnames); end },
					-- { text = "Print", notCheckable=true, func = function() RM:PopupWindow(RM:printLayout(layoutnames)); end },
				-- },
			-- }
		-- i = i+1
	-- end
	
	-- if savesList == nil then
		-- RM:Print("You have no Saved Layouts")
	-- end
		
	local minimapmenu = {
		{ text = "DKP Bidder", notCheckable=true, isTitle = true},
		{ text = "Profiles", notCheckable=true, func = function() B:showConfigWindow(); end },
	}
	local minimapmenuFrame = CreateFrame("Frame", "MiniMapMenuFrame", UIParent, "UIDropDownMenuTemplate")
	EasyMenu(minimapmenu, minimapmenuFrame, "cursor", 0 , 0, "MENU", 0.5);
end

function B:ToggleMinimapButton()
	if BidderIcon and not BidderIcon:IsRegistered("DKP Bidder") then
		BidderIcon:Register("DKP Bidder", BidderLauncher, bidDB.minimapicon)
	end
	if BidderIcon then
		BidderIcon:Refresh("DKP Bidder", bidDB.minimapicon)
		if bidDB.minimapicon.hide==true then
			BidderIcon:Show("DKP Bidder")
			bidDB.minimapicon.hide=false
		elseif bidDB.minimapicon.hide==false then
			BidderIcon:Hide("DKP Bidder")
			self:Print("Minimap icon hidden")
			bidDB.minimapicon.hide=true
		end
	end
end

function B:CreateMinimapIcon()
	if BidderLDB and BidderIcon then
		BidderIcon:Register("DKP Bidder", BidderLauncher, bidDB.minimapicon)
		--if bidDB.minimapicon.hide==false then
		--	BidderIcon:Show("DKP Bidder")
		--end
	end
end

