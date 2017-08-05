
local ASI = {['List'] = {}}

--[[//////////////////////////////////////////////////

    MAIN INTERFACE FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.Main = {}
    function AS_CreateFrames()

        ----- MAIN FRAME
            ASI.Main.Frame.Create()

        ------ HEADER FRAME
            AS.mainframe.headerframe = CreateFrame("Frame", nil, AS.mainframe)
            AS.mainframe.headerframe:SetPoint("TOPLEFT")
            AS.mainframe.headerframe:SetPoint("RIGHT")
            AS.mainframe.headerframe:SetHeight(AS_HEADERHEIGHT)

            ------ LIST LABEL
                AS.mainframe.headerframe.listlabel = AS.mainframe.headerframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.mainframe.headerframe.listlabel:SetJustifyH("CENTER")
                AS.mainframe.headerframe.listlabel:SetPoint("TOP", AS.mainframe.headerframe, "TOP", 0, -12)

            ------ START BUTTON
                ASI.Main.StartButton.Create()

            ------ STOP BUTTON
                ASI.Main.StopButton.Create()

            ------ PREV BUTTON
                ASI.Main.PrevButton.Create()

            ------ NEXT BUTTON
                ASI.Main.NextButton.Create()

            ------ INPUT SEARCH BOX
                ASI.Main.InputSearch.Create()

            ------ INPUT GOLD AUCTIONS SOLD BOX
                ASI.Main.InputGold.Create()

            ------ ADD ITEM BUTTON
                ASI.Main.AddButton.Create()

            ------ SOLD AUCTIONS BUTTON
                ASI.Main.SoldAuctionButton.Create()

            ------ SEARCH LIST FRAME
                ASI.List.Search.Create()

            ------ SOLD AUCTION LIST FRAME
                ASI.List.Sold.Create()

        ------ FOOTER SECTION

            ------ DELETE BUTTON
                ASI.Main.DeleteButton.Create()

            ------ REFRESH SOLD AUCTION BUTTON
                ASI.Main.RefreshButton.Create()

            ------ DROPDOWN MENU
                ASI.Main.OptionsDropDown.Create()

            ------ DROPDOWN MENU LABEL/BUTTON
                ASI.Main.OptionsButton.Create()

        ASI.Options.Create()
        ASI.Search.CreateFrame()
        ASI.MassCancel.CreateFrame()
        ASI.Filters.CreateFrame()
    end

    ASI.Main.Frame = {}
    function ASI.Main.Frame.Create()

        AS.mainframe = CreateFrame("Frame", "ASmainframe", UIParent)
        AS.mainframe:SetPoint("CENTER", 0, 0)
        AS.mainframe:SetHeight(AS_GROSSHEIGHT + 6)
        AS.mainframe:SetWidth(280)
        AS.mainframe:SetToplevel(true)
        AS.mainframe:SetFrameStrata("MEDIUM")
        AS.mainframe:Hide()

        AS.mainframe:SetScript("OnMouseDown", ASI.Main.Frame.MouseDown)
        AS.mainframe:SetScript("OnMouseUp", ASI.Main.Frame.MouseUp)
        AS.mainframe:SetScript("OnHide", ASI.Main.Frame.Hide)
        AS.mainframe:SetScript("OnShow", ASI.Main.Frame.Show)

        ASI.Backdrop(AS.mainframe)

        ------ CLOSE BUTTON
        AS.mainframe.closebutton = ASI.Close.Create(AS.mainframe)
        AS.mainframe.closebutton:SetScript("OnClick", function(self)
            AS.mainframe:Hide()
        end)
    end

    function ASI.Main.Frame:Show(...)

        if not ASsavedtable.onetimead then StaticPopup_Show("AS_OneTimeAd") end
    end

    function ASI.Main.Frame:MouseDown(...)

        self:StartMoving()
    end

    function ASI.Main.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function ASI.Main.Frame:Hide(...)

        self.headerframe.stopsearchbutton:Click()
        self.headerframe.editbox:SetText("|cff737373"..L[10015])
        self.headerframe.additembutton:Disable()

        AS_CloseAllPrompt()
    end

    ASI.Main.StartButton = {}
    function ASI.Main.StartButton.Create()

        AS.mainframe.headerframe.startsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
        AS.mainframe.headerframe.startsearchbutton:SetText(L[10061])
        AS.mainframe.headerframe.startsearchbutton:SetWidth(100)
        AS.mainframe.headerframe.startsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.startsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe, "TOPLEFT", 17, -45)

        AS.mainframe.headerframe.startsearchbutton:SetScript("OnClick", ASI.Main.StartButton.Click)
        AS.mainframe.headerframe.startsearchbutton:SetScript("OnEnter", ASI.Main.StartButton.Enter)
        AS.mainframe.headerframe.startsearchbutton:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.Reskin(AS.mainframe.headerframe.startsearchbutton)
        else
            ASI.GradientButton.Create(AS.mainframe.headerframe.startsearchbutton, "VERTICAL")
        end
    end

    function ASI.Main.StartButton:Click(...)

        if AS.manualprompt:IsVisible() then AS.manualprompt:Hide() end
        if AS.mainframe.soldlistframe:IsVisible() then AS.mainframe.soldlistframe:Hide() end

        if AuctionFrame and AuctionFrame:IsVisible() then
            AuctionFrameTab1:Click()  -- Focus on search tab
            if AuctionFrameBrowse:IsVisible() then
                
                if not IsShiftKeyDown() then AS.currentauction = 1 end

                AS.mainframe.headerframe.stopsearchbutton:Click()
                AS.status = STATE.QUERYING
                AS.mainframe.headerframe.stopsearchbutton:Enable()
            end
        end

        ASprint(MSG_C.ERROR.."Auction window is not visible")
    end

    function ASI.Main.StartButton:Enter(...)

        ASshowtooltip(self, L[10021])
    end

    ASI.Main.StopButton = {}
    function ASI.Main.StopButton.Create()

        AS.mainframe.headerframe.stopsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
        AS.mainframe.headerframe.stopsearchbutton:SetText(L[10060])
        AS.mainframe.headerframe.stopsearchbutton:SetWidth(50)
        AS.mainframe.headerframe.stopsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.stopsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.startsearchbutton,"TOPRIGHT", 2, 0)
        AS.mainframe.headerframe.stopsearchbutton:Disable()

        AS.mainframe.headerframe.stopsearchbutton:SetScript("OnClick", ASI.Main.StopButton.Click)
        AS.mainframe.headerframe.stopsearchbutton:SetScript("OnEnter", ASI.Main.StopButton.Enter)
        AS.mainframe.headerframe.stopsearchbutton:SetScript("OnLeave", AShidetooltip)
        AS.mainframe.headerframe.stopsearchbutton:SetScript("OnDisable", ASI.Main.StopButton.Disable)

        if AS_SKIN then
            F.Reskin(AS.mainframe.headerframe.stopsearchbutton)
        else
            ASI.GradientButton.Create(AS.mainframe.headerframe.stopsearchbutton, "VERTICAL")
        end
    end

    function ASI.Main.StopButton:Click(...)

        self:Disable()
    end

    function ASI.Main.StopButton:Enter(...)

        ASshowtooltip(self, L[10022])
    end

    function ASI.Main.StopButton:Disable(...)

        AS.prompt:Hide()
        if AS.override then AS.currentauction = 1 end

        AS.currentresult = 0
        AS.status = nil
        AS.override = false
        -- set default AH sort (could not achieve the same result using API)
        AuctionFrame_SetSort("list", "quality", false)
    end

    ASI.Main.InputSearch = {}
    function ASI.Main.InputSearch.Create()

        AS.mainframe.headerframe.editbox = CreateFrame("EditBox", nil, AS.mainframe.headerframe, "InputBoxTemplate")
        AS.mainframe.headerframe.editbox:SetPoint("BOTTOMLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 27, 15)
        AS.mainframe.headerframe.editbox:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.editbox:SetWidth(AS.mainframe.headerframe:GetWidth()-76)
        AS.mainframe.headerframe.editbox:SetAutoFocus(false)
        AS.mainframe.headerframe.editbox:SetText("|cff737373"..L[10015])

        AS.mainframe.headerframe.editbox:HookScript("OnEscapePressed", ASI.Main.InputSearch.Escape)
        AS.mainframe.headerframe.editbox:SetScript("OnEnterPressed", ASI.Main.InputSearch.EnterPressed)
        AS.mainframe.headerframe.editbox:SetScript("OnEditFocusGained", ASI.Main.InputSearch.FocusGain)
        AS.mainframe.headerframe.editbox:SetScript("OnEditFocusLost", ASI.Main.InputSearch.FocusLost)
        AS.mainframe.headerframe.editbox:SetScript("OnTextChanged", ASI.Main.InputSearch.Text)

        if AS_SKIN then
            F.ReskinInput(AS.mainframe.headerframe.editbox) -- Aurora
        else
            ASI.Input(AS.mainframe.headerframe.editbox)
            AS.mainframe.headerframe.editbox:SetFontObject("ChatFontNormal")
        end
    end

    function ASI.Main.InputSearch:Text(userInput)

        if userInput then

            if self:GetText() == "" then
                AS.mainframe.headerframe.additembutton:Disable()
            else
                AS.mainframe.headerframe.additembutton:Enable()
            end
        end
    end

    function ASI.Main.InputSearch:FocusGain(...)

        if AO_RENAME then ASshowtooltip(self, L[10037], nil, true) else ASshowtooltip(self, L[10090], nil, true) end
        if self:GetText() == "|cff737373"..L[10015] then self:SetText("") end
    end

    function ASI.Main.InputSearch:FocusLost(...)

        if self:GetText() == "" then self:SetText("|cff737373"..L[10015]) end

        AO_RENAME = nil
        AShidetooltip()
    end

    function ASI.Main.InputSearch:EnterPressed(...)

        AS.mainframe.headerframe.additembutton:Click()
    end

    function ASI.Main.InputSearch:Escape(...)

        AO_RENAME = nil
    end

    ASI.Main.InputGold = {}
    function ASI.Main.InputGold.Create()

        AS.mainframe.headerframe.soldeditbox = CreateFrame("EditBox", nil, AS.mainframe.headerframe, "InputBoxTemplate")
        AS.mainframe.headerframe.soldeditbox:SetPoint("BOTTOMLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 27, 15)
        AS.mainframe.headerframe.soldeditbox:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.soldeditbox:SetWidth(AS.mainframe.headerframe:GetWidth()-45)
        AS.mainframe.headerframe.soldeditbox:SetJustifyH("CENTER")
        AS.mainframe.headerframe.soldeditbox:Hide()
        AS.mainframe.headerframe.soldeditbox:Disable()

        if AS_SKIN then
            F.ReskinInput(AS.mainframe.headerframe.soldeditbox) -- Aurora
        else
            ASI.Input(AS.mainframe.headerframe.soldeditbox)
        end
    end

    ASI.Main.AddButton = {}
    function ASI.Main.AddButton.Create()

        AS.mainframe.headerframe.additembutton = CreateFrame("Button", nil, AS.mainframe.headerframe,"UIPanelbuttontemplate")
        AS.mainframe.headerframe.additembutton:SetText("+")
        AS.mainframe.headerframe.additembutton:SetWidth(30)
        AS.mainframe.headerframe.additembutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.additembutton:Disable()
        AS.mainframe.headerframe.additembutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.editbox, "TOPRIGHT", 2, 0)

        AS.mainframe.headerframe.additembutton:SetScript("OnClick", AS_AddItem)
        AS.mainframe.headerframe.additembutton:SetScript("OnEnable", ASI.Main.AddButton.Enable)
        AS.mainframe.headerframe.additembutton:SetScript("OnDisable", ASI.Main.AddButton.Disable)

        ASI.GradientButton.Create(AS.mainframe.headerframe.additembutton, "VERTICAL")
    end

    function ASI.Main.AddButton:Enable(...)

        self:LockHighlight()
    end

    function ASI.Main.AddButton:Disable(...)

        self:UnlockHighlight()
    end

    ASI.Main.DeleteButton = {}
    function ASI.Main.DeleteButton.Create()

        AS.mainframe.headerframe.deletelistbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
        AS.mainframe.headerframe.deletelistbutton:SetText(L[10066])
        AS.mainframe.headerframe.deletelistbutton:SetWidth(100)
        AS.mainframe.headerframe.deletelistbutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.deletelistbutton:SetPoint("BOTTOMLEFT", AS.mainframe, "BOTTOMLEFT", 17, 3)

        AS.mainframe.headerframe.deletelistbutton:SetScript("OnClick", ASI.Main.DeleteButton.Click)
        AS.mainframe.headerframe.deletelistbutton:SetScript("OnEnter", ASI.Main.DeleteButton.Enter)
        AS.mainframe.headerframe.deletelistbutton:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.Reskin(AS.mainframe.headerframe.deletelistbutton)
        else
            ASI.GradientButton.Create(AS.mainframe.headerframe.deletelistbutton, "VERTICAL")
        end
    end

    function ASI.Main.DeleteButton:Click(...)

        if IsControlKeyDown() then
            -- delete list if not current server name
            if GetRealmName() == ACTIVE_TABLE then
                ASprint(MSG_C.EVENT.."[ Resetting server list ]")
                AS.item = {}
                AS_SavedVariables()
            else
                ASprint(MSG_C.EVENT.."[ Deleting list: "..ACTIVE_TABLE.." ]")
                ASsavedtable[ACTIVE_TABLE] = nil
                AS_LoadTable(GetRealmName())
            end
            AS_ScrollbarUpdate()
        end
    end

    function ASI.Main.DeleteButton:Enter(...)

        ASshowtooltip(self, L[10058])
    end

    ASI.Main.RefreshButton = {}
    function ASI.Main.RefreshButton.Create()

        AS.mainframe.headerframe.refreshlistbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
        AS.mainframe.headerframe.refreshlistbutton:SetText(L[10083])
        AS.mainframe.headerframe.refreshlistbutton:SetWidth(100)
        AS.mainframe.headerframe.refreshlistbutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.refreshlistbutton:SetPoint("BOTTOMLEFT", AS.mainframe, "BOTTOMLEFT", 17, 3)
        AS.mainframe.headerframe.refreshlistbutton:Hide()

        AS.mainframe.headerframe.refreshlistbutton:SetScript("OnClick", ASI.Main.RefreshButton.Click)
        AS.mainframe.headerframe.refreshlistbutton:SetScript("OnEnter", ASI.Main.RefreshButton.Enter)
        AS.mainframe.headerframe.refreshlistbutton:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.Reskin(AS.mainframe.headerframe.refreshlistbutton)
        else
            ASI.GradientButton.Create(AS.mainframe.headerframe.refreshlistbutton, "VERTICAL")
        end
    end

    function ASI.Main.RefreshButton:Click(...)

        AO_FIRSTRUN_AH = false
        ASprint(MSG_C.WARN..L[10075], 1)
    end

    function ASI.Main.RefreshButton:Enter(...)

        ASshowtooltip(self, L[10084])
    end

    ASI.Main.PrevButton = {}
    function ASI.Main.PrevButton.Create()

        AS.mainframe.headerframe.prevlist = ASI.PrevButton.Create(AS.mainframe.headerframe)
        AS.mainframe.headerframe.prevlist:SetPoint("LEFT", AS.mainframe.headerframe.stopsearchbutton, "RIGHT", 10, 0)
        AS.mainframe.headerframe.prevlist:HookScript("OnClick", ASI.Main.PrevButton.Click)
    end

    function ASI.Main.PrevButton:Click(...)

        if ASsavedtable then
            local current = I_LISTNAMES[ACTIVE_TABLE]
            if LISTNAMES[current - 1] == nil then -- Go to the end
                AS_SwitchTable(LISTNAMES[table.maxn(LISTNAMES)])
            else
                AS_SwitchTable(LISTNAMES[current - 1])
            end
        end
    end

    ASI.Main.NextButton = {}
    function ASI.Main.NextButton.Create()

        AS.mainframe.headerframe.nextlist = ASI.NextButton.Create(AS.mainframe.headerframe)
        AS.mainframe.headerframe.nextlist:SetPoint("LEFT", AS.mainframe.headerframe.prevlist,"RIGHT", 7, 0)
        AS.mainframe.headerframe.nextlist:HookScript("OnClick", ASI.Main.NextButton.Click)
    end

    function ASI.Main.NextButton:Click(...)

        if ASsavedtable then
            local current = I_LISTNAMES[ACTIVE_TABLE]
            if LISTNAMES[current + 1] == nil then -- Go back to beginning
                AS_SwitchTable(LISTNAMES[1])
            else
                AS_SwitchTable(LISTNAMES[current + 1])
            end
        end
    end

    ASI.Main.SoldAuctionButton = {}
    function ASI.Main.SoldAuctionButton.Create()

        AS.mainframe.headerframe.soldbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
        AS.mainframe.headerframe.soldbutton:SetText("|TInterface\\MoneyFrame\\UI-GoldIcon:16:16:2:0|t")
        AS.mainframe.headerframe.soldbutton:SetWidth(30)
        AS.mainframe.headerframe.soldbutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.mainframe.headerframe.soldbutton:SetPoint("TOP", AS.mainframe.headerframe.startsearchbutton, "TOP")
        AS.mainframe.headerframe.soldbutton:SetPoint("RIGHT", AS.mainframe.headerframe.additembutton, "RIGHT")

        AS.mainframe.headerframe.soldbutton:SetScript("OnClick", ASI.Main.SoldAuctionButton.Click)
        AS.mainframe.headerframe.soldbutton:SetScript("OnEnter", ASI.Main.SoldAuctionButton.Enter)
        AS.mainframe.headerframe.soldbutton:SetScript("OnLeave", AShidetooltip)

        ASI.GradientButton.Create(AS.mainframe.headerframe.soldbutton, "VERTICAL")
    end

    function ASI.Main.SoldAuctionButton:Click(...)

        if AS.mainframe.soldlistframe:IsVisible() then -- Toggle off
            AS.mainframe.soldlistframe:Hide()
        else -- Toggle on
            AS.mainframe.soldlistframe:Show()
        end
    end

    function ASI.Main.SoldAuctionButton:Enter(...)

        ASshowtooltip(self, L[10070])
    end

    ASI.Main.OptionsDropDown = {}
    function ASI.Main.OptionsDropDown.Create()

        ASdropDownMenu = CreateFrame("Frame", "ASdropDownMenu", AS.mainframe, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(ASdropDownMenu, 130, 4)
        ASdropDownMenu:SetPoint("TOPLEFT", AS.mainframe.headerframe.deletelistbutton, "TOPRIGHT", -8, 4)
        UIDropDownMenu_Initialize(ASdropDownMenu, ASI.Main.OptionsDropDown.Initialize) --The virtual

        if AS_SKIN then F.ReskinDropDown(ASdropDownMenu) end -- Aurora
    end

    function ASI.Main.OptionsDropDown:Initialize(level)
        --drop down menues can have sub menues. The value of level determines the drop down sub menu tier
        local level = level or 1 

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()

            --- Profile/Server list
            ASI.Main.OptionsDropDown.Menu(info, L[10063], "Import", level)
            --- Edit list options
            ASI.Main.OptionsDropDown.Menu(info, L[10064], "ASlistoptions", level)
            --- Create new list
            ASI.Main.OptionsDropDown.Button(self, info, L[10065], "ASnewlist", false, level)

            if ASsavedtable then
                --- Copper override first
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["copperoverride"], "copperoverride", ASsavedtable.copperoverride, level)
                --- Remember auction price
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["rememberprice"], "rememberprice", ASsavedtable.rememberprice, level)
                --- Cancel auction
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["cancelauction"], "cancelauction", ASsavedtable.cancelauction, level)
                --- Search owned auction
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["searchauction"], "searchauction", ASsavedtable.searchauction, level)
                --- Alerts
                ASI.Main.OptionsDropDown.Menu(info, L[10080], "AOalerts", level)
                --- Auto open
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["ASautoopen"], "ASautoopen", ASsavedtable.ASautoopen, level)
                --- Auto start
                ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL["ASautostart"], "ASautostart", ASsavedtable.ASautostart, level)
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "Import" then
            local info = UIDropDownMenu_CreateInfo()

            if ASsavedtable then
                for key, value in pairs(ASsavedtable) do
                    if not OPT_LABEL[key] and not OPT_HIDDEN[key] then -- Found a server

                        if key == ACTIVE_TABLE then -- indicate which list is being used
                            info.checked = true
                        else
                            info.checked = false
                        end
                        ASI.Main.OptionsDropDown.Button(self, info, key, key, info.checked, level)
                    end
                end
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "ASlistoptions" then
            local info = UIDropDownMenu_CreateInfo()
            --- Rename current list
            ASI.Main.OptionsDropDown.Button(self, info, L[10016], "AOrenamelist", false, level)

            if ASsavedtable then
                for key, value in pairs(ASsavedtable[ACTIVE_TABLE]) do
                    if OPT_LABEL[key] then -- sounds
        
                        if type(value) == "boolean" then
                            info.checked = value
                        else
                            info.checked = false
                        end

                        ASI.Main.OptionsDropDown.Button(self, info, OPT_LABEL[key], key, info.checked, level)
                    end
                end
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "AOalerts" then
            local info = UIDropDownMenu_CreateInfo()
            --- Chat options
            ASI.Main.OptionsDropDown.Menu(info, L[10081], "AOchat", level)
            --- Sounds options
            ASI.Main.OptionsDropDown.Menu(info, L[10076], "AOsounds", level)

        elseif level == 3 and UIDROPDOWNMENU_MENU_VALUE == "AOchat" then
            local info = UIDropDownMenu_CreateInfo()
            -- Sold
            ASI.Main.OptionsDropDown.Button(self, info, L[10078], "AOchatsold", ASsavedtable.AOchatsold, level)

        elseif level == 3 and UIDROPDOWNMENU_MENU_VALUE == "AOsounds" then
            local info = UIDropDownMenu_CreateInfo()
            --- Outbid
            ASI.Main.OptionsDropDown.Button(self, info, L[10077], "AOoutbid", ASsavedtable.AOoutbid, level)
            --- Sold
            ASI.Main.OptionsDropDown.Button(self, info, L[10078], "AOsold", ASsavedtable.AOsold, level)
            --- Expired
            ASI.Main.OptionsDropDown.Button(self, info, L[10079], "AOexpired", ASsavedtable.AOexpired, level)

        else
            local info = UIDropDownMenu_CreateInfo()

            info.text = L[10017]
            info.value = nil
            info.hasArrow = false
            info.owner = self:GetParent()
            UIDropDownMenu_AddButton(info, level)
        end
    end

    function ASI.Main.OptionsDropDown.Menu(info, label, value, level)

        info.text = label
        info.value = value
        info.hasArrow = true
        info.checked = false

        UIDropDownMenu_AddButton(info, level)
    end

    function ASI.Main.OptionsDropDown.Button(self, info, label, value, checked, level)

        info.text = label
        info.hasArrow = false
        info.value = value
        info.func = ASdropDownMenuItem_OnClick
        info.owner = self:GetParent()
        info.checked = checked

        UIDropDownMenu_AddButton(info, level)

    end

    ASI.Main.OptionsButton = {}
    function ASI.Main.OptionsButton.Create()

        ASdropdownmenubutton = CreateFrame("Button", nil, ASdropDownMenu)
        ASdropdownmenubutton:SetText(L[10062])
        ASdropdownmenubutton:SetNormalFontObject("GameFontNormal")
        ASdropdownmenubutton:SetPoint("CENTER", ASdropDownMenu, "CENTER", -7, 1)
        ASdropdownmenubutton:SetWidth(80)
        ASdropdownmenubutton:SetHeight(34)

        ASdropdownmenubutton:SetScript("OnClick", ASI.Main.OptionsButton.Click)
    end

    function ASI.Main.OptionsButton:Click(...)

        ASdropDownMenuButton:Click()
    end

--[[//////////////////////////////////////////////////

    SCROLL SEARCH LIST FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.List.Search = {}
    function ASI.List.Search.Create()

        AS.mainframe.listframe = CreateFrame("Frame", "FauxScrollFrameTest", AS.mainframe)
        AS.mainframe.listframe:SetPoint("TOPLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        AS.mainframe.listframe:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", 0, 10)

        AS.mainframe.listframe:SetScript("OnShow", function(self)
            AS.mainframe.headerframe.refreshlistbutton:Hide()
            AS.mainframe.headerframe.deletelistbutton:Show()
        end)

        AS.mainframe.listframe.scrollFrame = ASI.List.ScrollFrame(AS.mainframe.listframe,
                                             "AS_scrollframe", AS_ScrollbarUpdate, ASI.List.Search.Button)
    end

    function ASI.List.Search.Button(index)

        -------------- STYLE ----------------
            local button = ASI.List.Button(index, AS.mainframe.listframe)
            button.icon = ASI.List.Icon.Create(button)
            button.leftstring:SetPoint("LEFT", button:GetNormalTexture(), "LEFT", 10, 0)
            button.leftstring:SetPoint("RIGHT", button:GetNormalTexture(), "RIGHT", -2, 0)
        -------------- SCRIPT ----------------
            button:SetScript("OnMouseDown", function(self) -- compensate for scroll bar
                self.originalpos = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
            end)
            button:SetScript("OnClick", ASI.List.Search.Click)
            button:SetScript("OnMouseUp", ASI.List.Search.MouseUp)
            button:SetScript("OnEnter", ASI.List.Search.Enter)
            button:SetScript("OnDoubleClick", ASI.List.Search.DoubleClick)
            button:SetScript("OnLeave", AShidetooltip)

       return button
    end

    function ASI.List.Search:Click(...)

        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
        local item = AS.item[idx]

        if AS.optionframe:IsVisible() then AS.optionframe:Hide() end
        
        if IsShiftKeyDown() then
            if item.link then
                SetItemRef(ASsanitize(item.link), ASsanitize(item.link), "LeftButton")
            else
                AS.mainframe.headerframe.editbox:SetText(item.name)
            end
        else
            AS_SetSelected(idx)
            AS.optionframe:SetParent(self)
            AS.optionframe:SetPoint("TOP", self, "BOTTOMRIGHT")
            AS.optionframe:Show()
        end
    end

    function ASI.List.Search:Enter(...)

        local hexcolor, title
        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
        local item = AS.item[idx]

        if item.rarity then
            _, _, _, hexcolor = GetItemQualityColor(item.rarity)
            title = "|c"..hexcolor..item.name
        else
            title = "|cffffffff"..item.name
        end

        local tooltip = ASshowtooltip(self, nil, title, true)
        tooltip:AddLine(L[10059], 0, 1, 1, 1, 1) -- Instructions

        if item.ignoretable and item.ignoretable[item.name] then
            local filters = {}

            if item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice > 0 then
                filters["|cff00ffff"..L[10023]..":|r"] = ASGSC(tonumber(item.ignoretable[item.name].cutoffprice))
            elseif item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice == 0 then
                filters["|cff00ffff"..L[10024]..":|r"] = "|cff9d9d9d"..L[10025].."|r"
            end

            if item.ignoretable[item.name].ilvl then
                filters["|cff00ffff"..L[10026]..":|r"] = "|cffffffff"..item.ignoretable[item.name].ilvl.."|r"
            end

            if item.ignoretable[item.name].stackone then
                filters['single'] = "|cff00ffffIgnoring stacks of 1|r"
            end

            if next(filters) then
                local key, value

                tooltip:AddLine(" ")
                tooltip:AddLine(L[10019])

                for key, value in pairs(filters) do
                    if key == "single" then
                        tooltip:AddLine(value)
                    else
                        tooltip:AddDoubleLine(key, value)
                    end
                end
            end
        end

        if item.sellbid or item.sellbuyout then
            tooltip:AddLine(" ")
            tooltip:AddLine(L[10085])

            if item.sellbid then
                tooltip:AddDoubleLine("|cff00ffff"..L[10027]..":|r", ASGSC(item.sellbid))
            end
            if item.sellbuyout and item.sellbuyout > 0 then
                tooltip:AddDoubleLine("|cff00ffff"..L[10028]..":|r", ASGSC(item.sellbuyout))
            end
        end

        if item.notes then
            tooltip:AddLine(" ")
            tooltip:AddLine("|cff888888-------------------------------|r")
            tooltip:AddLine("|cffffffff"..item.notes.."|r")
        end

        tooltip:Show()
    end

    function ASI.List.Search:MouseUp(button)

        if button == "RightButton" then
            if AuctionFrame and AuctionFrame:IsVisible() then
                local idx = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                
                AuctionFrameTab1:Click() -- Focus on search tab
                AuctionFrameBrowse.page = 0

                AS.override = true
                AS.currentauction = idx
                AS.status = STATE.QUERYING
                return
            end
            ASprint(MSG_C.ERROR.."Auction house is not visible")
        else
            AS_MoveListButton(self.originalpos)
            AS_ScrollbarUpdate()
        end
    end

    function ASI.List.Search:DoubleClick(...)

        BrowseResetButton:Click()
        AuctionFrameBrowse.page = 0
        BrowseName:SetText(ASsanitize(self.leftstring:GetText()))
        if AuctionFrame.selectedTab == 3 or AuctionFrame.selectedTab == 2 then
            AuctionFrameTab1:Click()
        end
        AuctionFrameBrowse_Search()
    end


--[[//////////////////////////////////////////////////

    SCROLL SOLD LIST FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.List.Sold = {}
    function ASI.List.Sold.Create()

        AS.mainframe.soldlistframe = CreateFrame("Frame", "FauxScrollFrameTest", AS.mainframe)
        AS.mainframe.soldlistframe:SetPoint("TOPLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        AS.mainframe.soldlistframe:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", 0, 10)
        AS.mainframe.soldlistframe:Hide()

        AS.mainframe.soldlistframe:SetScript("OnHide", function(self)
            AS.mainframe.headerframe.soldeditbox:Hide()
            AS.mainframe.headerframe.editbox:Show()
            AS.mainframe.headerframe.additembutton:Show()
            AS.mainframe.headerframe.soldbutton:UnlockHighlight()
            AS.mainframe.listframe:Show()
        end)
        AS.mainframe.soldlistframe:SetScript("OnShow", function(self)
            AS.mainframe.headerframe.editbox:Hide()
            AS.mainframe.headerframe.additembutton:Hide()
            AS.mainframe.headerframe.soldbutton:LockHighlight() 
            AS.mainframe.headerframe.deletelistbutton:Hide()
            AS.mainframe.headerframe.refreshlistbutton:Show()
            AS.mainframe.listframe:Hide()
            AO_OwnerScrollbarUpdate()
            AS.mainframe.headerframe.soldeditbox:Show()
        end)

        AS.mainframe.soldlistframe.scrollFrame = ASI.List.ScrollFrame(AS.mainframe.soldlistframe, "AS_soldauction_scrollframe", AO_OwnerScrollbarUpdate, ASI.List.Sold.Button)
    end

    function ASI.List.Sold.Button(index)

        -------------- STYLE ----------------
            local button = ASI.List.Button(index, AS.mainframe.soldlistframe)
            button.icon = ASI.List.Icon.Create(button)
            button.leftstring:SetPoint("LEFT", button:GetNormalTexture(), "LEFT", 10, 0)
            button.rightstring = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.rightstring:SetJustifyH("RIGHT")
            button.rightstring:SetJustifyV("CENTER")
            button.rightstring:SetWordWrap(false)
            button.rightstring:SetPoint("RIGHT", button:GetNormalTexture(),"RIGHT", -2, 0)
        -------------- SCRIPT ----------------
            button:SetScript("OnEnter", ASI.List.Sold.Enter)
            button:SetScript("OnLeave", AShidetooltip)
            button:SetScript("OnDoubleClick", ASI.List.Sold.DoubleClick)

       return button
    end

    function ASI.List.Sold:Enter(...)
        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.soldlistframe.scrollFrame)
        local item = AS.soldauctions[idx]

        local tooltip = ASshowtooltip(self, nil, L[10071], true)
        tooltip:AddLine(" ")

        if item.quantity and item.quantity > 0 then
            tooltip:AddDoubleLine("|cff00ffff"..L[10072]..":|r", "|cffffffff"..item.quantity.."|r")
        end
        if item.buyer then
            tooltip:AddDoubleLine("|cff00ffff"..L[10073]..":|r", "|cffffffff"..item.buyer.."|r")
        end
        tooltip:AddDoubleLine("|cff00ffff"..L[10074]..":|r", "|cffffffff"..SecondsToTime(item['time'] - GetTime()).."|r")

        tooltip:Show()
    end

    function ASI.List.Sold:DoubleClick(...)

        BrowseResetButton:Click()
        AuctionFrameBrowse.page = 0
        BrowseName:SetText(ASsanitize(self.leftstring:GetText()))
        AuctionFrameBrowse_Search()
    end


--[[//////////////////////////////////////////////////

    OPTION FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.Options = {}
    function ASI.Options.Create()

        AS.optionframe = CreateFrame("Frame", "ASoptionframe", AS.mainframe)
        AS.optionframe:SetHeight((AS_BUTTON_HEIGHT * 8) + (AS_FRAMEWHITESPACE * 2))  -- 8 buttons
        AS.optionframe:SetWidth(200)
        AS.optionframe:SetToplevel(true)
        
        AS.optionframe:SetBackdrop({    bgFile = AS_backdrop,
                                        edgeFile = AS_backdrop,
                                        tile = false, tileSize = 32, edgeSize = 1,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        AS.optionframe:SetBackdropColor(0, 0, 0, 0.8)
        AS.optionframe:SetBackdropBorderColor(r, g, b, 0.3)

        AS.optionframe:SetScript("OnLeave", function(self)
            local x, y = GetCursorScaledPosition()
            -- Only hide when cursor exits at the top or bottom of the option menu
            if (x < self:GetLeft()) or (x > self:GetRight()) or (y < self:GetBottom()) or (y > self:GetTop()) then
                self:Hide()
            end
        end)
        AS.optionframe:SetScript("OnShow", function(self)
            self:SetFrameStrata("TOOLTIP")
        end)

        ------ SELL ITEM
        AS.optionframe.sellbutton = ASI.Options.Button(L[10029])
        AS.optionframe.sellbutton:SetPoint("TOP", 0, -AS_FRAMEWHITESPACE)
        AS.optionframe.sellbutton:SetScript("OnClick", ASI.Options.Sell)

        ------ MASS CANCEL
        AS.optionframe.masscancelbutton = ASI.Options.Button(L[10087])
        AS.optionframe.masscancelbutton:SetPoint("TOP", AS.optionframe.sellbutton, "BOTTOM")
        AS.optionframe.masscancelbutton:SetScript("OnClick", ASI.Options.MassCancel)

        ------ MANUAL PRICE
        AS.optionframe.manualpricebutton = ASI.Options.Button(L[10030])
        AS.optionframe.manualpricebutton:SetPoint("TOP", AS.optionframe.masscancelbutton, "BOTTOM")
        AS.optionframe.manualpricebutton:SetScript("OnClick", ASI.Options.Filters)

        ------ COPY ENTRY
        AS.optionframe.copyrowbutton = ASI.Options.Button(L[10032])
        AS.optionframe.copyrowbutton:SetPoint("TOP", AS.optionframe.manualpricebutton, "BOTTOM")
        AS.optionframe.copyrowbutton:SetScript("OnClick", ASI.Options.Copy)

        ------ RESET FILTERS
        AS.optionframe.resetignorebutton = ASI.Options.Button(L[10033])
        AS.optionframe.resetignorebutton:SetPoint("TOP", AS.optionframe.copyrowbutton, "BOTTOM")
        AS.optionframe.resetignorebutton:SetScript("OnClick", ASI.Options.Reset)

        ------ MOVE ENTRY TO TOP
        AS.optionframe.movetotopbutton = ASI.Options.Button(L[10034])
        AS.optionframe.movetotopbutton:SetPoint("TOP", AS.optionframe.resetignorebutton,"BOTTOM")
        AS.optionframe.movetotopbutton:SetScript("OnClick", ASI.Options.MoveTop)

        ------ MOVE ENTRY TO BOTTOM
        AS.optionframe.movetobottombutton = ASI.Options.Button(L[10035])
        AS.optionframe.movetobottombutton:SetPoint("TOP", ASoptionframe.movetotopbutton,"BOTTOM")
        AS.optionframe.movetobottombutton:SetScript("OnClick", ASI.Options.MoveBottom)

        ------ DELETE ENTRY
        AS.optionframe.deleterowbutton = ASI.Options.Button(L[10036])
        AS.optionframe.deleterowbutton:SetPoint("TOP", AS.optionframe.movetobottombutton, "BOTTOM")
        AS.optionframe.deleterowbutton:SetScript("OnClick", ASI.Options.Delete)
    end

    function ASI.Options.Button(label)
        local button = CreateFrame("Button", nil, AS.optionframe)
        
        button:SetHeight(AS_BUTTON_HEIGHT)
        button:SetWidth(AS.optionframe:GetWidth())
        button:SetNormalFontObject("GameFontNormal")
        button:SetText(label)
        button:SetHighlightTexture(AS_backdrop)
        button:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)

        return button
    end

    function ASI.Options:Sell(...)

        local bag, slot, link, name
        local _, item = AS_GetSelected()

        AS.optionframe:Hide()
        CancelSell()

        if AuctionFrameAuctions.priceType ~= 1 then
            AuctionFrameAuctions.priceType = 1
            UIDropDownMenu_SetSelectedValue(PriceDropDown, AuctionFrameAuctions.priceType) -- Set to unit price
        end

        for bag = 0, 4 do -- Find item in bags and create auction
            for slot = 1, GetContainerNumSlots(bag) do
                link = GetContainerItemLink(bag, slot)
                if link then
                    name = GetItemInfo(link)
                    if name and (name == item.name or 
                                (item.link and string.find(item.link, name) and not string.find(item.link, name.."%s")) or 
                                string.find(string.lower(name), string.lower(item.name))) then -- string.find ignores dashes

                        ASprint(MSG_C.INFO.."Setting up sale:|r "..item.name, 1)
                        AuctionFrameTab3:Click()
                        PickupContainerItem(bag, slot)
                        ClickAuctionSellItemButton()
                        ClearCursor()

                        if ASsavedtable.rememberprice then
                            if item.sellbid then -- Set to unit price, since we do not set stack size
                                MoneyInputFrame_SetCopper(StartPrice, math.floor(item.sellbid))
                            end
                            if item.sellbuyout then
                                MoneyInputFrame_SetCopper(BuyoutPrice, math.floor(item.sellbuyout))
                            end
                        end
                        return
                    end -- if name matches
                end -- if link
            end -- end slots
        end -- end bags
        ASprint(MSG_C.ERROR.."Item not found in bags")
    end

    function ASI.Options:Filters(...)

        local listnumber, item = AS_GetSelected()

        AS_CloseAllPrompt()

        AS.item['ASmanualedit'] = {}
        AS.item['ASmanualedit'].name = item.name
        AS.item['ASmanualedit'].listnumber = listnumber

        AS.manualprompt.stackone:SetChecked(false)
        AS.manualprompt.priceoverride:SetText("")
        AS.manualprompt.ilvlinput:SetText("")
        if item.icon then
            AS.manualprompt.icon:SetNormalTexture(item.icon)
            AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        else
            -- clear icon, link
            AS.manualprompt.icon:SetNormalTexture("")
            AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
            AS.manualprompt.icon.link = nil
        end

        if item.notes then
            AS.manualprompt.notes:SetText(item.notes)
        else
            AS.manualprompt.notes:SetText("")
        end

        if item.rarity then
            local _, _, _, hexcolor = GetItemQualityColor(item.rarity)
            AS.manualprompt.upperstring:SetText("|c"..hexcolor..tostring(item.name))
        else
            AS.manualprompt.upperstring:SetText(item.name)
        end
        
        if item.ignoretable and item.ignoretable[item.name] then
            if item.ignoretable[item.name].cutoffprice then
                AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":\n"..ASGSC(tonumber(item.ignoretable[item.name].cutoffprice)))
            else
                AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":\n")
            end
            if item.ignoretable[item.name].ilvl then
                AS.manualprompt.ilvllabel:SetText(L[10026]..":\n".."|cffffffff"..item.ignoretable[item.name].ilvl.."|r")
                AS.manualprompt.ilvlinput:SetText(item.ignoretable[item.name].ilvl)
            else
                AS.manualprompt.ilvllabel:SetText(L[10026]..":\n")
            end

            if item.ignoretable[item.name].stackone then
                AS.manualprompt.stackone:SetChecked(true)
            end
        end

        AS.optionframe:Hide()
        AS.manualprompt:Show()
    end

    function ASI.Options:Reset(...)
        local _, item = AS_GetSelected()
        ASprint(MSG_C.INFO.."Reset filters for:|r "..item.name, 1)

        item.ignoretable = nil
        item.priceoverride = nil
        AS_SavedVariables()
        AS.optionframe:Hide()
    end

    function ASI.Options:Delete(...)
        local listnumber, item = AS_GetSelected()
        ASprint(MSG_C.INFO.."Removing:|r "..item.name, 1)

        table.remove(AS.item, listnumber)
        AS_ScrollbarUpdate() -- Necessary to remove empty gap
        AS_SavedVariables()
        AS.optionframe:Hide()
    end

    function ASI.Options:Rename(...)

        local listnumber = AS_GetSelected()
        AO_RENAME = listnumber
        AS.mainframe.headerframe.editbox:SetFocus()
        AS.optionframe:Hide()
    end

    function ASI.Options:Copy(...)

        local _, item = AS_GetSelected()
        AS_COPY = item

        AS.mainframe.headerframe.editbox:SetText(item.name)
        AS.mainframe.headerframe.additembutton:Enable()
        AS.mainframe.headerframe.additembutton:LockHighlight()
        AS.optionframe:Hide()
    end

    function ASI.Options:MoveTop(...)

        AS_MoveListButton(AS_GetSelected(), 1)
    end

    function ASI.Options:MoveBottom(...)

        AS_MoveListButton(AS_GetSelected(), table.maxn(AS.item))
    end

    function ASI.Options:MassCancel(...)

        local x, auction
        local _, item = AS_GetSelected()

        AS_CloseAllPrompt()
        AS.optionframe:Hide()

        AuctionFrameTab3:Click() -- Focus on auction tab

        if AuctionFrame and AuctionFrame:IsVisible() then
            AS.currentownerauctions = AO_CurrentOwnedAuctions(item.name)
            if next(AS.currentownerauctions) then
                AS.CancelStatus = STATE.QUERYING
                return
            end
            ASprint("No items with that name found in your owned auctions.", 1)
            return
        end
        ASprint("Auction House is not visible.", 1)
    end


--[[//////////////////////////////////////////////////

    SEARCH PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.Search = {}
    function ASI.Search.CreateFrame()

        ------ MAIN FRAME
            ASI.Search.Frame.Create()

            ------ ICON
                ASI.Search.Icon.Create()

            ------ ITEM
                ASI.Search.Item.Create()

            ------ BID/BUYOUT FRAME
                ASI.Search.BidBuyoutFrame.Create()

            ------ BUYOUT-ONLY FRAME
                ASI.Search.BuyoutFrame.Create()

            ------ BID BUTTON
                ASI.Search.BidButton.Create()

            ------ BUYOUT BUTTON
                ASI.Search.BuyButton.Create()

            ------ CUTOFF PRICE LABEL
                AS.prompt.lowerstring = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.prompt.lowerstring:SetJustifyH("CENTER")
                AS.prompt.lowerstring:SetJustifyV("TOP")
                AS.prompt.lowerstring:SetWidth(AS.prompt.separator:GetWidth() + AS.prompt.rseparator:GetWidth())
                AS.prompt.lowerstring:SetPoint("TOP", AS.prompt.bid, "BOTTOMRIGHT", 1, -7)
                AS.prompt.lowerstring:SetSpacing(2)
                AS.prompt.lowerstring:SetTextColor(r, g, b) -- Aurora

            ------ EXTRA BUTTONS
                ASI.Search.ExtraButtons.Create()

        ------ TRACKER
            ASI.Search.Tracker.Create()

    end

    ASI.Search.Frame = {}
    function ASI.Search.Frame.Create()

        AS.prompt = CreateFrame("Frame", "ASpromptframe", AS.mainframe)
        AS.prompt:SetPoint("TOPLEFT", AS.mainframe, "TOPRIGHT", 3, 0)
        AS.prompt:SetHeight(420)
        AS.prompt:SetWidth(200)
        AS.prompt:SetFrameStrata("DIALOG")
        AS.prompt:Hide()
        ASI.Backdrop(AS.prompt)
        AS.prompt:SetUserPlaced(true)

        AS.prompt:SetScript("OnMouseDown", ASI.Search.Frame.MouseDown)
        AS.prompt:SetScript("OnMouseUp", ASI.Search.Frame.MouseUp)
        AS.prompt:SetScript("OnHide", ASI.Search.Frame.Hide)
        AS.prompt:SetScript("OnShow", ASI.Search.Frame.Show)

        ------ CLOSE BUTTON
        AS.prompt.closebutton = ASI.Close.Create(AS.prompt)
        AS.prompt.closebutton:SetScript("OnClick", function(self) AS.mainframe.headerframe.stopsearchbutton:Click() end)
    end

    function ASI.Search.Frame:MouseDown(...)

        self:StartMoving()
    end

    function ASI.Search.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function ASI.Search.Frame:Hide(...)

        if AS.status == nil then
            AS.mainframe.headerframe.stopsearchbutton:Click()
        end
    end

    function ASI.Search.Frame:Show(...)

        local _, item = AS_GetSelected()

        if AS.boughtauctions[item.name] then
            AS.prompt.tracker.quantity:SetText("("..AS.boughtauctions[item.name]['buyquantity']..")")
            AS.prompt.tracker.total:SetText(ASGSC(AS.boughtauctions[item.name]['buy']))
        else
            AS.prompt.tracker.quantity:SetText("(0)")
            AS.prompt.tracker.total:SetText(ASGSC(0))
        end
    end

    ASI.Search.Icon = {}
    function ASI.Search.Icon.Create()

        AS.prompt.icon = CreateFrame("Button", nil, AS.prompt)
        AS.prompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        AS.prompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        AS.prompt.icon:SetPoint("TOPLEFT", AS.prompt, "TOPLEFT", 18, -15)
        AS.prompt.icon:SetHeight(37)
        AS.prompt.icon:SetWidth(37)

        AS.prompt.icon:SetScript("OnEnter", ASI.Search.Icon.Enter)
        AS.prompt.icon:SetScript("OnLeave", ASI.GameTooltip.Leave)
    end

    function ASI.Search.Icon:Enter(...)

        local link = GetAuctionItemLink("list", AS.currentresult)
        if link then
            --if (item.id and item.id > 0) then
            GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
            -- Check the link type:   http://www.wowinterface.com/forums/archive/index.php/t-48939.html
            if strmatch(link, "|Hbattlepet:") then
                -- Battle pet link
                local _, speciesID, level, breedQuality, maxHealth, power, speed, name = strsplit(":", link)
                BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
            else
                -- Other kind of link, OK to use GameTooltip
                GameTooltip:SetHyperlink(link)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.prompt.icon, "TOPLEFT", -10, -20)
            if EnhTooltip then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.prompt.icon, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    ASI.Search.Item = {}
    function ASI.Search.Item.Create()

        ------ ITEM ILVL
            AS.prompt.ilvlbg = AS.prompt.icon:CreateTexture(nil, "OVERLAY")
            AS.prompt.ilvlbg:SetColorTexture(0, 0, 0, 0.80)
            AS.prompt.ilvlbg:SetWidth(AS.prompt.icon:GetWidth() + 2)
            AS.prompt.ilvlbg:SetHeight(15)
            AS.prompt.ilvlbg:SetPoint("TOPLEFT", AS.prompt.icon, "BOTTOMLEFT")

            AS.prompt.ilvl = AS.prompt.icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.ilvl:SetJustifyH("CENTER")
            AS.prompt.ilvl:SetWordWrap(false)
            AS.prompt.ilvl:SetWidth(AS.prompt.icon:GetWidth())
            AS.prompt.ilvl:SetTextColor(r, g, b, 1) -- Aurora
            AS.prompt.ilvl:SetPoint("BOTTOMLEFT", AS.prompt.ilvlbg, "BOTTOMLEFT", 0, 1)

        ------ ITEM LABEL
            AS.prompt.upperstring = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.upperstring:SetJustifyH("CENTER")
            AS.prompt.upperstring:SetWidth(AS.prompt:GetWidth() - (AS.prompt.icon:GetWidth() + (2*AS_FRAMEWHITESPACE)))
            AS.prompt.upperstring:SetHeight(AS.prompt.icon:GetHeight())
            AS.prompt.upperstring:SetPoint("LEFT", AS.prompt.icon, "RIGHT", 7, 0)
            AS.prompt.upperstring:SetPoint("RIGHT", AS.prompt, "RIGHT", -15, 0)

        ------ ITEM QUANTITY
            AS.prompt.quantity = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local Path = AS.prompt.quantity:GetFont()
            AS.prompt.quantity:SetFont(Path, 30) -- Resize string
            AS.prompt.quantity:SetJustifyH("CENTER")
            AS.prompt.quantity:SetPoint("TOP", AS.prompt, "TOP", 0, -AS.prompt.icon:GetWidth() - 30)

        ------ ITEM VENDOR
            AS.prompt.vendor = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.vendor:SetJustifyH("CENTER")
            AS.prompt.vendor:SetWordWrap(false)
            AS.prompt.vendor:SetWidth(AS.prompt:GetWidth()-20)
            AS.prompt.vendor:SetTextColor(r, g, b, 1) -- Aurora
            AS.prompt.vendor:SetPoint("TOP", AS.prompt.quantity, "BOTTOM", 0, -4)

        ------ ITEM LEFT SEPARATOR
            AS.prompt.separator = AS.prompt:CreateTexture()
            AS.prompt.separator:SetColorTexture(r, b, g, 0.3) -- Aurora
            AS.prompt.separator:SetSize((AS.prompt:GetWidth()/2)-20, 1)
            AS.prompt.separator:SetPoint("RIGHT", AS.prompt.vendor, "BOTTOM", 0, -23)

        ------ ITEM RIGHT SEPARATOR
            AS.prompt.rseparator = AS.prompt:CreateTexture()
            AS.prompt.rseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            AS.prompt.rseparator:SetSize((AS.prompt:GetWidth()/2)-20, 1)
            AS.prompt.rseparator:SetPoint("LEFT", AS.prompt.separator, "RIGHT")
    end

    ASI.Search.BidBuyoutFrame = {}
    function ASI.Search.BidBuyoutFrame.Create()

        AS.prompt.bidbuyout = CreateFrame("FRAME", nil, AS.prompt)

        ------ ITEM BID LABEL
            AS.prompt.bidbuyout.bid = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            AS.prompt.bidbuyout.bid:SetJustifyH("CENTER")
            AS.prompt.bidbuyout.bid:SetText(string.upper(L[10042]))
            AS.prompt.bidbuyout.bid:SetPoint("BOTTOM", AS.prompt.separator, "TOP", 0, 2)

        ------ BID AMOUNT EACH
            AS.prompt.bidbuyout.bid.single = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.bidbuyout.bid.single:SetJustifyH("RIGHT")
            AS.prompt.bidbuyout.bid.single:SetPoint("TOP", AS.prompt.bidbuyout.bid, "BOTTOM", 0, -10)
            AS.prompt.bidbuyout.bid.single:SetTextColor(r, g, b) -- Aurora

        ------ BID AMOUNT TOTAL
            AS.prompt.bidbuyout.bid.total = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.bidbuyout.bid.total:SetJustifyH("RIGHT")
            AS.prompt.bidbuyout.bid.total:SetPoint("TOP", AS.prompt.bidbuyout.bid.single, "BOTTOM", 0, -16)
            AS.prompt.bidbuyout.bid.total:SetTextColor(r, g, b) -- Aurora

        ------ ITEM BUYOUT LABEL
            AS.prompt.bidbuyout.buyout = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            AS.prompt.bidbuyout.buyout:SetJustifyH("CENTER")
            AS.prompt.bidbuyout.buyout:SetText(string.upper(L[10041]))
            AS.prompt.bidbuyout.buyout:SetPoint("BOTTOM", AS.prompt.rseparator, "TOP", 0, 2)

        ------ BUYOUT AMOUNT EACH
            AS.prompt.bidbuyout.buyout.single = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.bidbuyout.buyout.single:SetJustifyH("LEFT")
            AS.prompt.bidbuyout.buyout.single:SetPoint("TOP", AS.prompt.bidbuyout.buyout, "BOTTOM", 0, -10)
            AS.prompt.bidbuyout.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            AS.prompt.bidbuyout.buyout.total = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.bidbuyout.buyout.total:SetJustifyH("LEFT")
            AS.prompt.bidbuyout.buyout.total:SetPoint("TOP", AS.prompt.bidbuyout.buyout.single, "BOTTOM", 0, -16)
            AS.prompt.bidbuyout.buyout.total:SetTextColor(r, g, b) -- Aurora

        ------ MIDDLE SEPARATOR
            AS.prompt.bidbuyout.vseparator = AS.prompt.bidbuyout:CreateTexture()
            AS.prompt.bidbuyout.vseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            AS.prompt.bidbuyout.vseparator:SetSize(1, AS.prompt.bidbuyout.bid:GetHeight() + 17)
            AS.prompt.bidbuyout.vseparator:SetPoint("TOP", AS.prompt.separator, "RIGHT")

            ------ MIDDLE SEPARATOR EACH
                AS.prompt.bidbuyout.each = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                AS.prompt.bidbuyout.each:SetHeight(AS.prompt.bidbuyout.bid.single:GetHeight() + 10)
                AS.prompt.bidbuyout.each:SetJustifyH("CENTER")
                AS.prompt.bidbuyout.each:SetJustifyV("BOTTOM")
                AS.prompt.bidbuyout.each:SetText(L[10053])
                AS.prompt.bidbuyout.each:SetTextColor(r, g, b, 1) -- Aurora
                AS.prompt.bidbuyout.each:SetPoint("CENTER", AS.prompt.bidbuyout.vseparator)

            ------ MIDDLE HORIZONTAL SEPARATOR
                AS.prompt.bidbuyout.hseparator = AS.prompt:CreateTexture()
                AS.prompt.bidbuyout.hseparator:SetColorTexture(r, b, g, 0.3) -- Aurora
                AS.prompt.bidbuyout.hseparator:SetSize(AS.prompt.separator:GetWidth()+AS.prompt.rseparator:GetWidth(), 1)
                AS.prompt.bidbuyout.hseparator:SetPoint("TOP", AS.prompt.bidbuyout.vseparator, "BOTTOM", 0, -1)
    end

    ASI.Search.BuyoutFrame = {}
    function ASI.Search.BuyoutFrame.Create()

        AS.prompt.buyoutonly = CreateFrame("FRAME", nil, AS.prompt)

        ------ ITEM BUYOUT LABEL
            AS.prompt.buyoutonly.buyout = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            AS.prompt.buyoutonly.buyout:SetJustifyH("CENTER")
            AS.prompt.buyoutonly.buyout:SetText("|c00ffffff"..string.upper(L[10041]).."|r")
            AS.prompt.buyoutonly.buyout:SetPoint("BOTTOM", AS.prompt.separator, "TOPRIGHT", 0, 2)

        ------ BUYOUT AMOUNT EACH
            AS.prompt.buyoutonly.buyout.single = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.buyoutonly.buyout.single:SetJustifyH("CENTER")
            AS.prompt.buyoutonly.buyout.single:SetPoint("TOP", AS.prompt.buyoutonly.buyout, "BOTTOM", 0, -10)
            AS.prompt.buyoutonly.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            AS.prompt.buyoutonly.buyout.total = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.buyoutonly.buyout.total:SetJustifyH("CENTER")
            AS.prompt.buyoutonly.buyout.total:SetPoint("TOP", AS.prompt.buyoutonly.buyout.single, "BOTTOM", 0, -16)
            AS.prompt.buyoutonly.buyout.total:SetTextColor(r, g, b) -- Aurora
    end

    ASI.Search.BidButton = {}
    function ASI.Search.BidButton.Create()

        AS.prompt.bid = CreateFrame("Button", nil, AS.prompt, "UIPanelbuttontemplate")
        AS.prompt.bid:SetText(L[10042])
        AS.prompt.bid:SetWidth((AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
        AS.prompt.bid:SetHeight(AS_BUTTON_HEIGHT)
        AS.prompt.bid:SetPoint("TOP", AS.prompt.separator, "BOTTOM", 0, -60)

        AS.prompt.bid:SetScript("OnClick", ASI.Search.BidButton.Click)

        if AS_SKIN then
            F.Reskin(AS.prompt.bid) -- Aurora
        else
            ASI.GradientButton.Create(AS.prompt.bid, "VERTICAL")
        end
    end

    function ASI.Search.BidButton:Click(...)

        local _, item = AS_GetSelected()
        local bid = AS_GetCost()
        selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
        ASprint(MSG_C.DEBUG.."Bidding price: "..ASGSC(bid))

        PlaceAuctionBid("list", selected_auction, bid)  --the actual bidding call.
        AS_TrackerUpdate(item.name, AS.currentauctionitem[3], bid)
        AS.prompt:Hide()
        AS.status = STATE.BUYING
    end

    ASI.Search.BuyButton = {}
    function ASI.Search.BuyButton.Create()

        AS.prompt.buyout = CreateFrame("Button", nil, AS.prompt, "UIPanelbuttontemplate")
        AS.prompt.buyout:SetText(L[10041])
        AS.prompt.buyout:SetWidth((AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
        AS.prompt.buyout:SetHeight(AS_BUTTON_HEIGHT)
        AS.prompt.buyout:SetPoint("LEFT", AS.prompt.bid, "RIGHT", 2, 0)

        AS.prompt.buyout:SetScript("OnClick", ASI.Search.BuyButton.Click)

        if AS_SKIN then
            F.Reskin(AS.prompt.buyout) -- Aurora
        else
            ASI.GradientButton.Create(AS.prompt.buyout, "VERTICAL")
        end
    end

    function ASI.Search.BuyButton:Click(...)

        local _, item = AS_GetSelected()
        local _, buyout = AS_GetCost()
        selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
        ASprint(MSG_C.DEBUG.."Buying price: "..ASGSC(buyout))
        
        PlaceAuctionBid("list", selected_auction, buyout) -- The actual buying call
        AS_TrackerUpdate(item.name, AS.currentauctionitem[3], nil, buyout)
        -- The next item will be the same location as what was just bought
        AS.prompt:Hide()
        AS.currentresult = selected_auction - 1
        AS.status = STATE.BUYING
    end

    ASI.Search.ExtraButtons = {}
    function ASI.Search.ExtraButtons.Create()

        ASI.Search.ExtraButtons.CreateHandler()

        AS.prompt.buttonnames = {L[10047], L[10019], L[10044], L[10043]}
        local buttontooltips = {L[10056], L[10057], L[10054], L[10055]}
        local buttonnames = AS.prompt.buttonnames

        buttonwidth = (AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)  --basically half its frame size

        local columns = 2
        local latest_column = nil
        local latest_row = nil
        local current_column = 1

        for i = 1, table.maxn(AS.prompt.buttonnames) do

            AS.prompt[AS.prompt.buttonnames[i]] = ASI.Button.Create(AS.prompt, AS.prompt.buttonnames[i], buttontooltips[i])
            current_button = AS.prompt[buttonnames[i]]

            if i == 1 then -- Very first button
                current_button:SetPoint("BOTTOMLEFT", 20, 10)
                latest_row = current_button
            elseif current_column == 1 then -- Grow to the top
                current_button:SetPoint("BOTTOM", latest_row, "TOP", 0, 1)
                latest_row = current_button
            else -- Grow to the right
                current_button:SetPoint("LEFT", latest_column, "RIGHT", 2, 0)
            end

            latest_column = current_button
            if current_column == columns then -- End of columns, start from column 1
                current_column = 1
            else
                current_column = current_column + 1
            end
        end
    end

    function ASI.Search.ExtraButtons.CreateHandler()
        ------------------------------------------------------------------
        --  Create all the script handlers for the buttons
        ------------------------------------------------------------------
        AS[L[10043]] = function()  -- Go to next item in AH
                ASprint(MSG_C.INFO.."Skipping item...")
                AS.status = STATE.EVALUATING
        end

        AS[L[10044]] = function()  -- Go to next item in snatch list
                AS.prompt:Hide()
                AS.currentauction = AS.currentauction + 1
                AS.currentresult = 0
                AS.status = STATE.QUERYING
        end

        AS[L[10036]] = function()  -- Delete item
                table.remove(AS.item, AS.currentauction)
                AS.status = STATE.QUERYING
                AS_ScrollbarUpdate()
        end

        AS[L[10046]] = function()  -- Delete list
                if IsControlKeyDown() then
                    AS.item = {}
                    AS.status = nil
                    ASsavedtable = nil
                    AS_ScrollbarUpdate()
                end
        end

        AS[L[10047]] = function()  -- Update saved item with prompt item
                local  name, texture, _, quality = GetAuctionItemInfo("list", AS.currentresult)
                local link = GetAuctionItemLink("list", AS.currentresult)
                
                if AS.item[AS.currentauction] then

                    AS.item[AS.currentauction].name = name
                    AS.item[AS.currentauction].icon = texture
                    AS.item[AS.currentauction].link = link
                    AS.item[AS.currentauction].rarity = quality
                    AS.currentresult = AS.currentresult - 1  --redo this item :)
                    AS.status = STATE.EVALUATING
                    AS_ScrollbarUpdate()
                    AS_SavedVariables()
                end
        end

        AS[L[10019]] = function()  -- Open manualprompt filters
                ASprint(MSG_C.EVENT.."Opening manual edit filters")
                AS.prompt:Hide()
                AS.optionframe.manualpricebutton:Click()
        end
    end

    ASI.Search.Tracker = {}
    function ASI.Search.Tracker.Create()

        AS.prompt.tracker = CreateFrame("FRAME", nil, AS.prompt)
        AS.prompt.tracker:SetPoint("TOP", AS.prompt, "BOTTOM", 0, -3)
        AS.prompt.tracker:SetWidth(AS.prompt:GetWidth())
        AS.prompt.tracker:SetHeight(35)

        AS.prompt.tracker:SetBackdrop({ bgFile = AS_backdrop,
                                        edgeFile = AS_backdrop,
                                        tile = false, tileSize = 32, edgeSize = 1,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        AS.prompt.tracker:SetBackdropColor(0, 0, 0, 0.8)
        AS.prompt.tracker:SetBackdropBorderColor(0.6, 0.5, 0, 1)

        AS.prompt.tracker:SetScript("OnMouseDown", ASI.Search.Tracker.MouseDown)
        AS.prompt.tracker:SetScript("OnMouseUp", ASI.Search.Tracker.MouseUp)

        ------ ITEM QUANTITY
        AS.prompt.tracker.quantity = AS.prompt.tracker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        AS.prompt.tracker.quantity:SetJustifyH("LEFT")
        AS.prompt.tracker.quantity:SetJustifyV("CENTER")
        AS.prompt.tracker.quantity:SetText("(0)")
        AS.prompt.tracker.quantity:SetPoint("LEFT", AS.prompt.tracker, "LEFT", 10, 0)

        ------ ITEM SPENT
        AS.prompt.tracker.total = AS.prompt.tracker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        AS.prompt.tracker.total:SetJustifyH("RIGHT")
        AS.prompt.tracker.total:SetJustifyV("CENTER")
        AS.prompt.tracker.total:SetText(ASGSC(0))
        AS.prompt.tracker.total:SetPoint("RIGHT", AS.prompt.tracker, "RIGHT", -10, 0)
    end

    function ASI.Search.Tracker:MouseDown(...)

        AS.prompt:StartMoving()
    end

    function ASI.Search.Tracker:MouseUp(...)

        AS.prompt:StopMovingOrSizing()
    end


--[[//////////////////////////////////////////////////

    MASS CANCEL PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.MassCancel = {}
    function ASI.MassCancel.CreateFrame()

        ------ MAIN FRAME
            ASI.MassCancel.Frame.Create()

            ------ ICON
                ASI.MassCancel.Icon.Create()

            ------ ITEM
                ASI.MassCancel.Item.Create()

            ------ BID/BUYOUT FRAME
                ASI.MassCancel.BidBuyoutFrame.Create()

            ------ CANCEL BUTTON
                ASI.MassCancel.CancelButton.Create()

            ------ NEXT BUTTON
                ASI.MassCancel.NextButton.Create()
    end

    ASI.MassCancel.Frame = {}
    function ASI.MassCancel.Frame.Create()

        AS.cancelprompt = CreateFrame("Frame", "AScancelpromptframe", AS.mainframe)
        AS.cancelprompt:SetPoint("TOPLEFT", AS.mainframe, "TOPRIGHT", 3, 0)
        AS.cancelprompt:SetHeight(215)
        AS.cancelprompt:SetWidth(200)
        AS.cancelprompt:SetFrameStrata("DIALOG")
        AS.cancelprompt:Hide()
        ASI.Backdrop(AS.cancelprompt)
        AS.cancelprompt:SetUserPlaced(true)

        AS.cancelprompt:SetScript("OnMouseDown", ASI.MassCancel.Frame.MouseDown)
        AS.cancelprompt:SetScript("OnMouseUp", ASI.MassCancel.Frame.MouseUp)

        ------ CLOSE BUTTON
        AS.cancelprompt.closebutton = ASI.Close.Create(AS.cancelprompt)
        AS.cancelprompt.closebutton:SetScript("OnClick", function(self) AS.cancelprompt:Hide(); AS.CancelStatus = nil end)
    end

    function ASI.MassCancel.Frame:MouseDown(...)

        self:StartMoving()
    end

    function ASI.MassCancel.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    ASI.MassCancel.Icon = {}
    function ASI.MassCancel.Icon.Create()

        AS.cancelprompt.icon = CreateFrame("Button", nil, AS.cancelprompt)
        AS.cancelprompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        AS.cancelprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        AS.cancelprompt.icon:SetPoint("TOPLEFT", AS.cancelprompt, "TOPLEFT", 18, -15)
        AS.cancelprompt.icon:SetHeight(37)
        AS.cancelprompt.icon:SetWidth(37)

        AS.cancelprompt.icon:SetScript("OnEnter", ASI.MassCancel.Icon.Enter)
        AS.cancelprompt.icon:SetScript("OnLeave", ASI.GameTooltip.Leave)
    end

    function ASI.MassCancel.Icon:Enter(...)

        local link = self.link
        if link then
            --if (item.id and item.id > 0) then
            GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
            -- Check the link type:   http://www.wowinterface.com/forums/archive/index.php/t-48939.html
            if strmatch(link, "|Hbattlepet:") then
                -- Battle pet link
                local _, speciesID, level, breedQuality, maxHealth, power, speed, name = strsplit(":", link)
                BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
            else
                -- Other kind of link, OK to use GameTooltip
                GameTooltip:SetHyperlink(link)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.cancelprompt.icon, "TOPLEFT", -10, -20)
            if EnhTooltip then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.cancelprompt.icon, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    ASI.MassCancel.Item = {}
    function ASI.MassCancel.Item.Create()

        ------ ITEM LABEL
            AS.cancelprompt.upperstring = AS.cancelprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.cancelprompt.upperstring:SetJustifyH("CENTER")
            AS.cancelprompt.upperstring:SetWidth(AS.cancelprompt:GetWidth() - (AS.cancelprompt.icon:GetWidth() + (2*AS_FRAMEWHITESPACE)))
            AS.cancelprompt.upperstring:SetHeight(AS.cancelprompt.icon:GetHeight())
            AS.cancelprompt.upperstring:SetPoint("LEFT", AS.cancelprompt.icon, "RIGHT", 7, 0)
            AS.cancelprompt.upperstring:SetPoint("RIGHT", AS.cancelprompt, "RIGHT", -15, 0)

        ------ ITEM QUANTITY
            AS.cancelprompt.quantity = AS.cancelprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local Path = AS.cancelprompt.quantity:GetFont()
            AS.cancelprompt.quantity:SetFont(Path, 26) -- Resize string
            AS.cancelprompt.quantity:SetJustifyH("CENTER")
            AS.cancelprompt.quantity:SetPoint("TOP", AS.cancelprompt, "TOP", 0, -AS.cancelprompt.icon:GetWidth() - 30)

        ------ ITEM LEFT SEPARATOR
            AS.cancelprompt.separator = AS.cancelprompt:CreateTexture()
            AS.cancelprompt.separator:SetColorTexture(r, b, g, 0.3) -- Aurora
            AS.cancelprompt.separator:SetSize((AS.cancelprompt:GetWidth()/2)-20, 1)
            AS.cancelprompt.separator:SetPoint("RIGHT", AS.cancelprompt.quantity, "BOTTOM", 0, -23)

        ------ ITEM RIGHT SEPARATOR
            AS.cancelprompt.rseparator = AS.cancelprompt:CreateTexture()
            AS.cancelprompt.rseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            AS.cancelprompt.rseparator:SetSize((AS.cancelprompt:GetWidth()/2)-20, 1)
            AS.cancelprompt.rseparator:SetPoint("LEFT", AS.cancelprompt.separator, "RIGHT")
    end

    ASI.MassCancel.BidBuyoutFrame = {}
    function ASI.MassCancel.BidBuyoutFrame.Create()

        AS.cancelprompt.bidbuyout = CreateFrame("FRAME", nil, AS.cancelprompt)

        ------ ITEM BID LABEL
            AS.cancelprompt.bidbuyout.bid = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            AS.cancelprompt.bidbuyout.bid:SetJustifyH("CENTER")
            AS.cancelprompt.bidbuyout.bid:SetText(string.upper(L[10042]))
            AS.cancelprompt.bidbuyout.bid:SetPoint("BOTTOM", AS.cancelprompt.separator, "TOP", 0, 2)

        ------ BID AMOUNT EACH
            AS.cancelprompt.bidbuyout.bid.single = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.cancelprompt.bidbuyout.bid.single:SetJustifyH("RIGHT")
            AS.cancelprompt.bidbuyout.bid.single:SetPoint("TOP", AS.cancelprompt.bidbuyout.bid, "BOTTOM", 0, -10)
            AS.cancelprompt.bidbuyout.bid.single:SetTextColor(r, g, b) -- Aurora

        ------ BID AMOUNT TOTAL
            AS.cancelprompt.bidbuyout.bid.total = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.cancelprompt.bidbuyout.bid.total:SetJustifyH("RIGHT")
            AS.cancelprompt.bidbuyout.bid.total:SetPoint("TOP", AS.cancelprompt.bidbuyout.bid.single, "BOTTOM", 0, -16)
            AS.cancelprompt.bidbuyout.bid.total:SetTextColor(r, g, b) -- Aurora

        ------ ITEM BUYOUT LABEL
            AS.cancelprompt.bidbuyout.buyout = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            AS.cancelprompt.bidbuyout.buyout:SetJustifyH("CENTER")
            AS.cancelprompt.bidbuyout.buyout:SetText(string.upper(L[10041]))
            AS.cancelprompt.bidbuyout.buyout:SetPoint("BOTTOM", AS.cancelprompt.rseparator, "TOP", 0, 2)

        ------ BUYOUT AMOUNT EACH
            AS.cancelprompt.bidbuyout.buyout.single = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.cancelprompt.bidbuyout.buyout.single:SetJustifyH("LEFT")
            AS.cancelprompt.bidbuyout.buyout.single:SetPoint("TOP", AS.cancelprompt.bidbuyout.buyout, "BOTTOM", 0, -10)
            AS.cancelprompt.bidbuyout.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            AS.cancelprompt.bidbuyout.buyout.total = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.cancelprompt.bidbuyout.buyout.total:SetJustifyH("LEFT")
            AS.cancelprompt.bidbuyout.buyout.total:SetPoint("TOP", AS.cancelprompt.bidbuyout.buyout.single, "BOTTOM", 0, -16)
            AS.cancelprompt.bidbuyout.buyout.total:SetTextColor(r, g, b) -- Aurora

        ------ MIDDLE SEPARATOR
            AS.cancelprompt.bidbuyout.vseparator = AS.cancelprompt.bidbuyout:CreateTexture()
            AS.cancelprompt.bidbuyout.vseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            AS.cancelprompt.bidbuyout.vseparator:SetSize(1, AS.cancelprompt.bidbuyout.bid:GetHeight() + 17)
            AS.cancelprompt.bidbuyout.vseparator:SetPoint("TOP", AS.cancelprompt.separator, "RIGHT")

            ------ MIDDLE SEPARATOR EACH
                AS.cancelprompt.bidbuyout.each = AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                AS.cancelprompt.bidbuyout.each:SetHeight(AS.cancelprompt.bidbuyout.bid.single:GetHeight() + 10)
                AS.cancelprompt.bidbuyout.each:SetJustifyH("CENTER")
                AS.cancelprompt.bidbuyout.each:SetJustifyV("BOTTOM")
                AS.cancelprompt.bidbuyout.each:SetText(L[10053])
                AS.cancelprompt.bidbuyout.each:SetTextColor(r, g, b, 1) -- Aurora
                AS.cancelprompt.bidbuyout.each:SetPoint("CENTER", AS.cancelprompt.bidbuyout.vseparator)

            ------ MIDDLE HORIZONTAL SEPARATOR
                AS.cancelprompt.bidbuyout.hseparator = AS.cancelprompt:CreateTexture()
                AS.cancelprompt.bidbuyout.hseparator:SetColorTexture(r, b, g, 0.3) -- Aurora
                AS.cancelprompt.bidbuyout.hseparator:SetSize(AS.cancelprompt.separator:GetWidth()+AS.cancelprompt.rseparator:GetWidth(), 1)
                AS.cancelprompt.bidbuyout.hseparator:SetPoint("TOP", AS.cancelprompt.bidbuyout.vseparator, "BOTTOM", 0, -1)
    end

    ASI.MassCancel.CancelButton = {}
    function ASI.MassCancel.CancelButton.Create()

        AS.cancelprompt.bid = CreateFrame("Button", nil, AS.cancelprompt, "UIPanelbuttontemplate")
        AS.cancelprompt.bid:SetText(L[10005])
        AS.cancelprompt.bid:SetWidth((AS.cancelprompt:GetWidth() / 1.5) - (2 * AS_FRAMEWHITESPACE))
        AS.cancelprompt.bid:SetHeight(AS_BUTTON_HEIGHT)
        AS.cancelprompt.bid:SetPoint("TOP", AS.cancelprompt.separator, "BOTTOM", 0, -60)
        AS.cancelprompt.bid:SetPoint("LEFT", AS.cancelprompt.separator, "LEFT")

        AS.cancelprompt.bid:SetScript("OnClick", ASI.MassCancel.CancelButton.Click)

        if AS_SKIN then
            F.Reskin(AS.cancelprompt.bid) -- Aurora
        else
            ASI.GradientButton.Create(AS.cancelprompt.bid, "VERTICAL")
        end
    end

    function ASI.MassCancel.CancelButton:Click(...)

        if CanCancelAuction(GetSelectedAuctionItem("owner")) then
            AO_UntrackCancelledAuction()
            CancelAuction(GetSelectedAuctionItem("owner"))
        end
        AS.cancelprompt:Hide()
        AS.CancelStatus = STATE.BUYING
    end

    ASI.MassCancel.NextButton = {}
    function ASI.MassCancel.NextButton.Create()

        AS.cancelprompt.buyout = CreateFrame("Button", nil, AS.cancelprompt, "UIPanelbuttontemplate")
        AS.cancelprompt.buyout:SetText(L[10088])
        AS.cancelprompt.buyout:SetWidth((AS.cancelprompt:GetWidth() / 3) - (2 * AS_FRAMEWHITESPACE))
        AS.cancelprompt.buyout:SetHeight(AS_BUTTON_HEIGHT)
        AS.cancelprompt.buyout:SetPoint("LEFT", AS.cancelprompt.bid, "RIGHT", 2, 0)

        AS.cancelprompt.buyout:SetScript("OnClick", ASI.MassCancel.NextButton.Click)

        if AS_SKIN then
            F.Reskin(AS.cancelprompt.buyout) -- Aurora
        else
            ASI.GradientButton.Create(AS.cancelprompt.buyout, "VERTICAL")
        end
    end

    function ASI.MassCancel.NextButton:Click(...)
        ASprint(MSG_C.INFO.."Skipping item...")
        AS.CancelStatus = STATE.EVALUATING
    end


--[[//////////////////////////////////////////////////

    FILTERS PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.Filters = {}
    function ASI.Filters.CreateFrame()

        ------ MAIN FRAME
            ASI.Filters.Frame.Create()

            ------ ICON
                ASI.Filters.Icon.Create()

            ------ ITEM LABEL
                AS.manualprompt.upperstring = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.manualprompt.upperstring:SetJustifyH("CENTER")
                AS.manualprompt.upperstring:SetWidth(AS.manualprompt:GetWidth() - (AS.manualprompt.icon:GetWidth() + (2*AS_FRAMEWHITESPACE)))
                AS.manualprompt.upperstring:SetHeight(AS.manualprompt.icon:GetHeight())
                AS.manualprompt.upperstring:SetPoint("LEFT", AS.manualprompt.icon, "RIGHT", 7, 0)
                AS.manualprompt.upperstring:SetPoint("RIGHT", AS.manualprompt, "RIGHT", -15, 0)

            ------ RENAME BOX
                AS.manualprompt.renamebox = CreateFrame("Button", nil, AS.manualprompt)
                AS.manualprompt.renamebox:SetAllPoints(AS.manualprompt.upperstring)
                AS.manualprompt.renamebox:SetScript("OnEnter", function(self) ASshowtooltip(self, L[10089]) end)
                AS.manualprompt.renamebox:SetScript("OnLeave", AShidetooltip)
                AS.manualprompt.renamebox:SetScript("OnDoubleClick", ASI.Options.Rename)

            ------ CUTOFF PRICE LABEL
                AS.manualprompt.lowerstring = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.manualprompt.lowerstring:SetJustifyH("Left")
                AS.manualprompt.lowerstring:SetJustifyV("Top")
                AS.manualprompt.lowerstring:SetWidth(AS.manualprompt:GetWidth() - (2*AS_FRAMEWHITESPACE))
                AS.manualprompt.lowerstring:SetPoint("TOPLEFT", AS.manualprompt.icon, "BOTTOMLEFT", 0, 2)
                AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":")
                AS.manualprompt.lowerstring:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE BUTTON
                ASI.Filters.IgnoreButton.Create()

            ------ SAVE BUTTON
                ASI.Filters.SaveButton.Create()

            ------ CUTOFF INPUT BOX
                ASI.Filters.InputCutoff.Create()

            ------ ILVL INPUT BOX
                ASI.Filters.InputIlvl.Create()

            ------ ILVL LABEL
                AS.manualprompt.ilvllabel = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.manualprompt.ilvllabel:SetJustifyH("Left")
                AS.manualprompt.ilvllabel:SetJustifyV("Top")
                AS.manualprompt.ilvllabel:SetPoint("LEFT", AS.manualprompt.icon, "LEFT", 0, 2)
                AS.manualprompt.ilvllabel:SetPoint("TOP", AS.manualprompt.ilvlinput, "TOP", 0, 2)
                AS.manualprompt.ilvllabel:SetText(L[10026]..":")
                AS.manualprompt.ilvllabel:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE STACK OF 1
                ASI.Filters.CheckIgnoreStack.Create()

            ------ IGNORE STACK OF 1 LABEL
                AS.manualprompt.stackone.label = AS.manualprompt.stackone:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.manualprompt.stackone.label:SetJustifyH("LEFT")
                AS.manualprompt.stackone.label:SetPoint("LEFT", AS.manualprompt.icon, "LEFT")
                AS.manualprompt.stackone.label:SetPoint("TOP", AS.manualprompt.stackone, "TOP", 0, -5)
                AS.manualprompt.stackone.label:SetText(L[10069]..":")
                AS.manualprompt.stackone.label:SetTextColor(r, g, b) -- Aurora

            ------ NOTES
                ASI.Filters.Notes.Create()

            ------ NOTES LABEL
                AS.manualprompt.notes.label = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                AS.manualprompt.notes.label:SetJustifyH("LEFT")
                AS.manualprompt.notes.label:SetPoint("BOTTOMLEFT", AS.manualprompt.notes.bg, "TOPLEFT", 0, 2)
                AS.manualprompt.notes.label:SetText(L[10052])
                AS.manualprompt.notes.label:SetTextColor(r, g, b) -- Aurora
    end

    ASI.Filters.Frame = {}
    function ASI.Filters.Frame.Create()

        AS.manualprompt = CreateFrame("Frame", "ASmanualpromptframe", AS.mainframe)
        AS.manualprompt:SetPoint("TOPLEFT", AS.mainframe, "TOPRIGHT", 3, 0)
        AS.manualprompt:SetHeight(150)  --some addons change font size, so this will be overridden in ASinitialize
        AS.manualprompt:SetWidth(200)
        AS.manualprompt:SetFrameStrata("DIALOG")
        AS.manualprompt:Hide()
        ASI.Backdrop(AS.manualprompt)
        AS.manualprompt:SetUserPlaced(true)

        AS.manualprompt:SetScript("OnMouseDown", ASI.Filters.Frame.MouseDown)
        AS.manualprompt:SetScript("OnMouseUp", ASI.Filters.Frame.MouseUp)
        AS.manualprompt:SetScript("OnShow", ASI.Filters.Frame.Show)

        ------ CLOSE BUTTON
        AS.manualprompt.closebutton = ASI.Close.Create(AS.manualprompt)
        AS.manualprompt.closebutton:SetScript("OnClick", function(self) AS.manualprompt:Hide() end)
    end

    function ASI.Filters.Frame:MouseDown(...)

        self:StartMoving()
    end

    function ASI.Filters.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function ASI.Filters.Frame:Show(...)

        AS.mainframe.headerframe.stopsearchbutton:Click()
        self.priceoverride:SetFocus()
    end

    ASI.Filters.Icon = {}
    function ASI.Filters.Icon.Create()

        AS.manualprompt.icon = CreateFrame("Button", nil, AS.manualprompt)
        AS.manualprompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        AS.manualprompt.icon:SetPoint("TOPLEFT", AS.manualprompt, "TOPLEFT", 18, -15)
        AS.manualprompt.icon:SetHeight(37)
        AS.manualprompt.icon:SetWidth(37)

        AS.manualprompt.icon:SetScript("OnEnter", ASI.Filters.Icon.Enter)
        AS.manualprompt.icon:SetScript("OnLeave", ASI.GameTooltip.Leave)
    end

    function ASI.Filters.Icon:Enter(...)

        local _, item = AS_GetSelected()
        local link = item.link

        if link then
            --if (item.id and item.id > 0) then
            GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
            -- Check the link type:   http://www.wowinterface.com/forums/archive/index.php/t-48939.html
            if strmatch(link, "|Hbattlepet:") then
                -- Battle pet link
                local _, speciesID, level, breedQuality, maxHealth, power, speed, name = strsplit(":", link)
                BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
            else
                -- Other kind of link, OK to use GameTooltip
                GameTooltip:SetHyperlink(link)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.manualprompt.icon, "TOPLEFT", -10, -20)
            if (EnhTooltip) then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", AS.manualprompt.icon, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    ASI.Filters.IgnoreButton = {}
    function ASI.Filters.IgnoreButton.Create()

        AS.manualprompt.ignorebutton = CreateFrame("Button", nil, AS.manualprompt, "UIPanelbuttontemplate")
        AS.manualprompt.ignorebutton:SetText(L[10039])
        AS.manualprompt.ignorebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
        AS.manualprompt.ignorebutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.manualprompt.ignorebutton:SetPoint("TOPLEFT", AS.manualprompt.lowerstring, "BOTTOMLEFT", 0, -80)

        AS.manualprompt.ignorebutton:SetScript("OnClick", ASI.Filters.IgnoreButton.Click)
        AS.manualprompt.ignorebutton:SetScript("OnEnter", ASI.Filters.IgnoreButton.Enter)
        AS.manualprompt.ignorebutton:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.Reskin(AS.manualprompt.ignorebutton) -- Aurora
        else
            ASI.GradientButton.Create(AS.manualprompt.ignorebutton, "VERTICAL")
        end
    end

    function ASI.Filters.IgnoreButton:Click(...)

        local name = AS.item["ASmanualedit"].name
        local listnumber = AS.item['ASmanualedit'].listnumber
        
        if not AS.item[listnumber].ignoretable then
            AS.item[listnumber].ignoretable = {}
        end
        if not AS.item[listnumber].ignoretable[name] then
            AS.item[listnumber].ignoretable[name] = {}
        end

        AS.item[listnumber].ignoretable[name].cutoffprice = 0
        AS.item[listnumber].priceoverride = nil
        AS.item['ASmanualedit'] = nil
        AS_SavedVariables()
        AS.manualprompt:Hide()
    end

    function ASI.Filters.IgnoreButton:Enter(...)

        ASshowtooltip(self, L[10040])
    end

    ASI.Filters.SaveButton = {}
    function ASI.Filters.SaveButton.Create()

        AS.manualprompt.savebutton = CreateFrame("Button", nil, AS.manualprompt, "UIPanelbuttontemplate")
        AS.manualprompt.savebutton:SetText(L[10045])
        AS.manualprompt.savebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
        AS.manualprompt.savebutton:SetHeight(AS_BUTTON_HEIGHT)
        AS.manualprompt.savebutton:SetPoint("LEFT", AS.manualprompt.ignorebutton, "RIGHT", 2, 0)

        AS.manualprompt.savebutton:SetScript("OnClick", ASI.Filters.SaveButton.Click)

        if AS_SKIN then
            F.Reskin(AS.manualprompt.savebutton) -- Aurora
        else
            ASI.GradientButton.Create(AS.manualprompt.savebutton, "VERTICAL")
        end
    end

    function ASI.Filters.SaveButton:Click(...)

        local item = AS.item['ASmanualedit']
        local name = item.name
        local listnumber = item.listnumber

        -- Failsafe for ignoretable
        if not AS.item[listnumber].ignoretable then
            AS.item[listnumber].ignoretable = {}
        end
        if not AS.item[listnumber].ignoretable[name] then
            AS.item[listnumber].ignoretable[name] = {}
        end

        -- Price override
        if item.priceoverride then
            AS.item[listnumber].ignoretable[name].cutoffprice = item.priceoverride
        end
        -- iLvl filter
        if item.ilvl then
            if item.ilvl ~= "" then
                AS.item[listnumber].ignoretable[name].ilvl = tonumber(item.ilvl)
            else
                AS.item[listnumber].ignoretable[name].ilvl = nil
            end
        end
        -- Stack of one filter
        if item.stackone == false then
            AS.item[listnumber].ignoretable[name].stackone = nil
        else
            AS.item[listnumber].ignoretable[name].stackone = item.stackone
        end
        -- Notes
        if item.notes then
            if item.notes ~= "" then
                AS.item[listnumber].notes = item.notes
            else
                AS.item[listnumber].notes = nil
            end
        end

        AS.item[listnumber].priceoverride = nil
        AS.item['ASmanualedit'] = nil
        AS_SavedVariables()
        AS.manualprompt:Hide()
    end

    ASI.Filters.InputCutoff = {}
    function ASI.Filters.InputCutoff.Create()

        AS.manualprompt.priceoverride = CreateFrame("EditBox", nil, AS.manualprompt, "InputBoxTemplate")
        AS.manualprompt.priceoverride:SetPoint("TOP", AS.manualprompt.lowerstring, "TOP", 0, -AS_BUTTON_HEIGHT-7)
        AS.manualprompt.priceoverride:SetPoint("RIGHT", AS.manualprompt.savebutton, "RIGHT")
        AS.manualprompt.priceoverride:SetHeight(AS_BUTTON_HEIGHT)
        AS.manualprompt.priceoverride:SetWidth(65)
        AS.manualprompt.priceoverride:SetNumeric(true)
        AS.manualprompt.priceoverride:SetAutoFocus(false)

        AS.manualprompt.priceoverride:SetScript("OnEnterPressed", ASI.Filters.InputCutoff.EnterPressed)
        AS.manualprompt.priceoverride:SetScript("OnTextChanged", ASI.Filters.InputCutoff.Text)
        AS.manualprompt.priceoverride:SetScript("OnEnter", ASI.Filters.InputCutoff.Enter)
        AS.manualprompt.priceoverride:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.ReskinInput(AS.manualprompt.priceoverride) -- Aurora
        else
            ASI.Input(AS.manualprompt.priceoverride)
        end
    end

    function ASI.Filters.InputCutoff:Enter(...)

        if ASsavedtable and ASsavedtable.copperoverride then
            ASshowtooltip(self, L[10049])
        else
            ASshowtooltip(self, L[10050])
        end
    end

    function ASI.Filters.InputCutoff:Text(...)

        local messagestring

        if self:GetText() == "" then
            AS.item["ASmanualedit"].priceoverride = nil
        elseif ASsavedtable and ASsavedtable.copperoverride then
            AS.item["ASmanualedit"].priceoverride = tonumber(self:GetText())
        else
            AS.item["ASmanualedit"].priceoverride = self:GetText() * COPPER_PER_GOLD
        end

        if AS.item["ASmanualedit"].priceoverride and (tonumber(AS.item["ASmanualedit"].priceoverride) > 0) then
            messagestring = "\n"..L[10038]..":\n"
            messagestring = messagestring..ASGSC(tonumber(AS.item["ASmanualedit"].priceoverride))
            AS.manualprompt.lowerstring:SetText(messagestring)
        end
    end

    function ASI.Filters.InputCutoff:EnterPressed(...)

        AS.manualprompt.savebutton:Click()
    end

    ASI.Filters.InputIlvl = {}
    function ASI.Filters.InputIlvl.Create()

        AS.manualprompt.ilvlinput = CreateFrame("EditBox", nil, AS.manualprompt, "InputBoxTemplate")
        AS.manualprompt.ilvlinput:SetPoint("TOPRIGHT", AS.manualprompt.priceoverride, "BOTTOMRIGHT", 0, -5)
        AS.manualprompt.ilvlinput:SetHeight(AS_BUTTON_HEIGHT)
        AS.manualprompt.ilvlinput:SetWidth(65)
        AS.manualprompt.ilvlinput:SetNumeric(true)
        AS.manualprompt.ilvlinput:SetAutoFocus(false)

        AS.manualprompt.ilvlinput:SetScript("OnEnterPressed", ASI.Filters.InputIlvl.EnterPressed)
        AS.manualprompt.ilvlinput:SetScript("OnTextChanged", ASI.Filters.InputIlvl.Text)
        AS.manualprompt.ilvlinput:SetScript("OnEnter", ASI.Filters.InputIlvl.Enter)
        AS.manualprompt.ilvlinput:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.ReskinInput(AS.manualprompt.ilvlinput) -- Aurora
        else
            ASI.Input(AS.manualprompt.ilvlinput)
        end
    end

    function ASI.Filters.InputIlvl:EnterPressed(...)

        AS.manualprompt.savebutton:Click()
    end

    function ASI.Filters.InputIlvl:Text(userInput)

        local messagestring

        if userInput then
            AS.item["ASmanualedit"].ilvl = AS.manualprompt.ilvlinput:GetText()
            messagestring = L[10026]..":\n"
            messagestring = messagestring.."|cffffffff"..AS.item["ASmanualedit"].ilvl
            AS.manualprompt.ilvllabel:SetText(messagestring)
        end
    end

    function ASI.Filters.InputIlvl:Enter(...)

        ASshowtooltip(self, L[10051])
    end

    ASI.Filters.CheckIgnoreStack = {}
    function ASI.Filters.CheckIgnoreStack.Create()

        AS.manualprompt.stackone = CreateFrame("CheckButton", "AOstackone", AS.manualprompt, "OptionsCheckButtonTemplate")
        AS.manualprompt.stackone:SetPoint("TOPRIGHT", AS.manualprompt.ilvlinput, "BOTTOMRIGHT", 0, -5)

        AS.manualprompt.stackone:SetScript("OnClick", ASI.Filters.CheckIgnoreStack.Click)
        AS.manualprompt.stackone:SetScript("OnEnter", ASI.Filters.CheckIgnoreStack.Enter)
        AS.manualprompt.stackone:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then F.ReskinCheck(AS.manualprompt.stackone) end
    end

    function ASI.Filters.CheckIgnoreStack:Click(...)

        if self:GetChecked() then
            AS.item['ASmanualedit'].stackone = true
        else
            AS.item['ASmanualedit'].stackone = false
        end
    end

    function ASI.Filters.CheckIgnoreStack:Enter(...)

        ASshowtooltip(self, L[10068])
    end

    ASI.Filters.Notes = {}
    function ASI.Filters.Notes.Create()

        AS.manualprompt.notes = CreateFrame("EditBox", "ASnotes", AS.manualprompt)
        AS.manualprompt.notes:SetFontObject("ChatFontNormal")
        AS.manualprompt.notes:SetWidth(500)
        AS.manualprompt.notes:SetMultiLine(true)
        AS.manualprompt.notes:SetAutoFocus(false)

        AS.manualprompt.notes:SetScript("OnTextChanged", ASI.Filters.Notes.Text)
        
        -------------- SCROLLBAR ----------------
        AS.manualprompt.notes.scroll = CreateFrame('ScrollFrame', nil, AS.manualprompt, 'UIPanelScrollFrameTemplate')
        AS.manualprompt.notes.scroll:SetPoint("TOPLEFT", AS.manualprompt.ignorebutton, "BOTTOMLEFT", 2, -20)
        AS.manualprompt.notes.scroll:SetPoint("TOPRIGHT", AS.manualprompt.savebutton, "BOTTOMRIGHT", -5, -15)
        AS.manualprompt.notes.scroll:SetPoint("BOTTOMRIGHT", AS.manualprompt, "BOTTOMRIGHT", 0, 15)

        if AS_SKIN then
            F.ReskinScroll(AS.manualprompt.notes.scroll.ScrollBar)
        end
        AS.manualprompt.notes.scroll:SetScrollChild(AS.manualprompt.notes)
        
        -------------- FAKE BACKDROP ----------------
        AS.manualprompt.notes.bg = CreateFrame("EditBox", nil, AS.manualprompt, "InputBoxTemplate")
        AS.manualprompt.notes.bg:SetPoint("TOPLEFT", AS.manualprompt.ignorebutton, "BOTTOMLEFT", 2, -20)
        AS.manualprompt.notes.bg:SetPoint("TOPRIGHT", AS.manualprompt.savebutton, "BOTTOMRIGHT", 0, -20)
        AS.manualprompt.notes.bg:SetPoint("BOTTOMRIGHT", AS.manualprompt, "BOTTOMRIGHT", 0, 15)
        AS.manualprompt.notes.bg:SetAutoFocus(false)
        -------------- SCRIPT ----------------
        AS.manualprompt.notes.bg:SetScript("OnEditFocusGained", function(self) AS.manualprompt.notes:SetFocus() end)

        if AS_SKIN then
            F.ReskinInput(AS.manualprompt.notes.bg) -- Aurora
        else
            ASI.Input(AS.manualprompt.notes.bg)
        end
    end

    function ASI.Filters.Notes:Text(...)

        AS.item['ASmanualedit'].notes = self:GetText()
    end


--[[//////////////////////////////////////////////////

    INTERFACE HELPER FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    ASI.Close = {}
    function ASI.Close.Create(parent)
        local button

        if AS_SKIN then
            button = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
            button:SetPoint("TOPRIGHT", parent, -2, -2)
            button:SetWidth(14)
            button:SetHeight(14)
            F.ReskinClose(button) -- Aurora
        else
            button = CreateFrame("Button", nil, parent, "UIPanelbuttontemplate")
            button:SetPoint("TOPRIGHT", parent, -2, -2)
            button:SetWidth(23)
            button:SetHeight(20)
            button:SetText("|cffffffffX|r")
            ASI.GradientButton.Create(button, "VERTICAL")
        end

        return button
    end

    ASI.Button = {}
    function ASI.Button.Create(parent, name, tooltip)

        local buttonwidth = (parent:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)
        local button = CreateFrame("Button", nil, parent, "UIPanelbuttontemplate")

        button:SetText(name)
        button:SetWidth(buttonwidth)
        button:SetHeight(AS_BUTTON_HEIGHT)
        button.tooltip = tooltip

        button:SetScript("OnClick", AS[name])
        button:SetScript("OnEnter", ASI.Button.Enter)
        button:SetScript("OnLeave", AShidetooltip)

        if AS_SKIN then
            F.Reskin(button) -- Aurora
        else
            ASI.GradientButton.Create(button, "VERTICAL")
        end

        return button
    end

    function ASI.Button:Enter(...)

        ASshowtooltip(self, self.tooltip)
    end

    ASI.GradientButton = {}
    function ASI.GradientButton.Create(button, orientation)

        button:SetNormalTexture("")
        button:SetHighlightTexture("")
        button:SetPushedTexture("")
        button:SetDisabledTexture("")

        AS_RemoveEdge(button)

        button:SetBackdrop({    bgFile = AS_backdrop,
                                edgeFile = AS_backdrop,
                                edgeSize = 1,
                                insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        button:SetBackdropColor(0, 0, 0, 0)
        button:SetBackdropBorderColor(0, 0, 0, 1)

        local gradient = button:CreateTexture(nil, "BACKGROUND")

        gradient:SetColorTexture(1, 1, 1)
        gradient:SetAllPoints()
        gradient:SetGradient(orientation, 0, 0, 0, 0.15, 0.15, 0.15)

        local highlight = button:CreateTexture(nil, "HIGHLIGHT")
        
        highlight:SetColorTexture(r, g, b, 0.2)
        highlight:SetAllPoints()
        button:SetHighlightTexture(highlight)

        button:HookScript("OnEnter", ASI.GradientButton.Enter)
        button:HookScript("OnLeave", ASI.GradientButton.Leave)
    end

    function ASI.GradientButton:Enter(...)

        self:SetBackdropBorderColor(r, g, b, 1)
    end

    function ASI.GradientButton:Leave(...)

        self:SetBackdropBorderColor(0, 0, 0, 1)
    end

    ASI.PrevButton = {}
    function ASI.PrevButton.Create(frame)

        local button = CreateFrame("Button", nil, frame)
        
        button:SetWidth(24)
        button:SetHeight(24)
        button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
        button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        button:Disable()

        if AS_SKIN then F.ReskinArrow(button, "left") end -- Aurora

        return button
    end

    ASI.NextButton = {}
    function ASI.NextButton.Create(frame)

        local button = CreateFrame("Button", nil, frame)
        
        button:SetWidth(24)
        button:SetHeight(24)
        button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
        button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        button:Disable()

        if AS_SKIN then F.ReskinArrow(button, "right") end -- Aurora

        return button
    end

    function ASI.Backdrop(frame)

        if AS_SKIN then -- Aurora
            frame:SetBackdrop({ bgFile = AS_backdrop,
                                edgeFile = nil,
                                tile = false, tileSize = 32, edgeSize = 32,
                                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
        else
            frame:SetBackdrop({ bgFile = AS_backdrop,
                                edgeFile = AS_backdrop,
                                tile = false, tileSize = 32, edgeSize = 1,
                                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
        end

        frame:SetBackdropBorderColor(0, 0, 0, 1)
        frame:SetBackdropColor(0, 0, 0, 0.85)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
    end

    function ASI.Input(editbox)

        editbox:SetTextColor(1, 1, 1)
        editbox:SetTextInsets(5, 0, 0, 0)

        AS_RemoveEdge(editbox)
        
        editbox:SetBackdrop({   bgFile = AS_backdrop,
                                edgeFile = AS_backdrop,
                                edgeSize = 1,
                                insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        editbox:SetBackdropColor(0, 0, 0, 0.8)
        editbox:SetBackdropBorderColor(1, 1, 1, 0.1)
        editbox:SetFontObject("GameFontNormal")

        editbox:HookScript("OnEscapePressed", function(self) self:ClearFocus() end)
    end

    function ASI.List.Button(index, parent)

        local button = CreateFrame("Button", nil, parent)

        button.buttonnumber = index
        button:SetHeight(AS_BUTTON_HEIGHT)
        button:SetWidth(AS.mainframe:GetWidth() - 58)
        button:SetPoint("TOP")
        button:SetMovable(true)

        local normal = button:CreateTexture(nil, "BACKGROUND")

        normal:SetHeight(AS_BUTTON_HEIGHT)
        normal:SetPoint("LEFT", 30, 0)
        normal:SetPoint("RIGHT", -12, 0)
        normal:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
        normal:SetTexCoord(.75, .75, 0, 0.5)
        button:SetNormalTexture(normal)

        local highlight = button:CreateTexture(nil, "HIGHLIGHT")

        highlight:SetHeight(AS_BUTTON_HEIGHT-1)
        highlight:SetPoint("LEFT", normal, 0, -1)
        highlight:SetPoint("RIGHT", normal)
        highlight:SetTexture(AS_backdrop) -- Aurora
        highlight:SetVertexColor(0.945, 0.847, 0.152, 0.2)
        button:SetHighlightTexture(highlight)

        button.leftstring = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")

        button.leftstring:SetJustifyH("LEFT")
        button.leftstring:SetJustifyV("CENTER")
        button.leftstring:SetWordWrap(false)

        return button
    end

    ASI.List.Icon = {}
    function ASI.List.Icon.Create(parent)

        local icon = CreateFrame("Button", nil, parent)

        icon:SetWidth(AS_BUTTON_HEIGHT)
        icon:SetHeight(AS_BUTTON_HEIGHT)
        icon:SetPoint("TOPLEFT")
        icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

        icon:SetScript("OnEnter", ASI.List.Icon.Enter)
        icon:SetScript("OnLeave", ASI.List.Icon.Leave)
        
        return icon
    end

    function ASI.List.Icon:Enter(...)

        if AOicontooltip and self.link then

            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetHyperlink(self.link)
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    function ASI.List.Icon:Leave(...)

        GameTooltip:Hide()
    end

    function ASI.List.ScrollFrame(parent, name, onUpdate, buttons)

        local scrollframe = ASI.List.Scroll.Create(parent, name, onUpdate)
        local i, currentrow, previousrow

        parent.itembuttons = {}

        for i = 1, ASrowsthatcanfit() do

            parent.itembuttons[i] = buttons(i)
            currentrow = parent.itembuttons[i]
            if i == 1 then
                currentrow:SetPoint("TOP")
            else
                currentrow:SetPoint("TOP", previousrow, "BOTTOM")
            end
            currentrow:Show()
            previousrow = currentrow
        end

        return scrollframe
    end

    ASI.List.Scroll = {}
    function ASI.List.Scroll.Create(parent, name, onUpdate)

        --[[note the anchors: the area of the scrollframe is the scrollable area
            that intercepts mousewheel to scroll. it does not include the scrollbar,
            which is anchored off the right ]]

        local scroll = CreateFrame("ScrollFrame", name, parent, "FauxScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        scroll:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", -40, 38)
        scroll.onUpdate = onUpdate

        scroll:SetScript("OnShow", onUpdate)
        scroll:SetScript("OnVerticalScroll", ASI.List.Scroll.VerticalScroll)

        if AS_SKIN then F.ReskinScroll(scroll.ScrollBar) end -- Aurora

        return scroll
    end

    function ASI.List.Scroll:VerticalScroll(offset)

        FauxScrollFrame_OnVerticalScroll(self, offset, 20, self.onUpdate)
    end

    ASI.GameTooltip = {}
    function ASI.GameTooltip:Leave(...)

        GameTooltip:Hide()
    end

    function AS_RemoveEdge(frame)

        local name = frame:GetName()
        local left = frame.Left or name and _G[name.."Left"] or nil
        local middle = frame.Middle or name and (_G[name.."Middle"] or _G[name.."Mid"]) or nil
        local right = frame.Right or name and _G[name.."Right"] or nil

        if left then left:Hide() end
        if middle then middle:Hide() end
        if right then right:Hide() end
    end

    function AS_CreateAuctionTab() -- Move

        if AuctionFrame then
            -------------- STYLE ----------------
                ASauctiontab = CreateFrame("Button", "ASauctiontab", AuctionFrame, "AuctionTabTemplate")
                ASauctiontab:SetText("AS")
                PanelTemplates_TabResize(ASauctiontab, 50, 70, 70);
                PanelTemplates_DeselectTab(ASauctiontab)
            -------------- SCRIPT ----------------
                ASauctiontab:SetScript("OnClick", function()
                    if AS.mainframe:IsShown() then
                        AS.mainframe:Hide()
                    else
                        ASopenedwithah = true
                        if ASsavedtable.ASautostart then
                            AS.status = STATE.QUERYING
                        end
                        AS_Main()
                    end
                end)
                if AS_SKIN then F.ReskinTab(ASauctiontab) end -- Aurora

            -------------- THANK YOU IGORS MASS AUCTION ----------------
            local index = 1
            -- Find the first unused tab.
            while getglobal("AuctionFrameTab" .. index) do
                index = index + 1;
            end

            -- Make it an alias for our tab
            setglobal("AuctionFrameTab" .. index, ASauctiontab)

            -- Set up tabbing data
            ASauctiontab:SetID(index);
            PanelTemplates_SetNumTabs(AuctionFrame, index);

            -- Set geometry
            ASauctiontab:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(index - 1)), "TOPRIGHT", -8, 0)

            -- Set Event for Owner Auction tab
            AuctionFrameTab3:SetScript("PreClick", function(self, button, down)
                AS_RegisterCancelAction()
                AS_RegisterSearchAction()
            end)
        end
    end
