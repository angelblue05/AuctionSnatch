local B, L, T = unpack(select(2, ...))

B.I = {['List'] = {}}

--[[//////////////////////////////////////////////////

    MAIN INTERFACE FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.Main = {}
    function B.CreateFrames()

        ----- MAIN FRAME
            B.I.Main.Frame.Create()

        ------ HEADER FRAME
            T.AS.mainframe.headerframe = CreateFrame("Frame", nil, T.AS.mainframe)
            T.AS.mainframe.headerframe:SetPoint("TOPLEFT")
            T.AS.mainframe.headerframe:SetPoint("RIGHT")
            T.AS.mainframe.headerframe:SetHeight(T.HEADERHEIGHT)

            ------ LIST LABEL
                T.AS.mainframe.headerframe.listlabel = T.AS.mainframe.headerframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.mainframe.headerframe.listlabel:SetJustifyH("CENTER")
                T.AS.mainframe.headerframe.listlabel:SetPoint("TOP", T.AS.mainframe.headerframe, "TOP", 0, -12)

            ------ START BUTTON
                B.I.Main.StartButton.Create()

            ------ STOP BUTTON
                B.I.Main.StopButton.Create()

            ------ PREV BUTTON
                B.I.Main.PrevButton.Create()

            ------ NEXT BUTTON
                B.I.Main.NextButton.Create()

            ------ INPUT SEARCH BOX
                B.I.Main.InputSearch.Create()

            ------ INPUT GOLD AUCTIONS SOLD BOX
                B.I.Main.InputGold.Create()

            ------ ADD ITEM BUTTON
                B.I.Main.AddButton.Create()

            ------ SOLD AUCTIONS BUTTON
                B.I.Main.SoldAuctionButton.Create()

            ------ SEARCH LIST FRAME
                B.I.List.Search.Create()

            ------ SOLD AUCTION LIST FRAME
                B.I.List.Sold.Create()

        ------ FOOTER SECTION

            ------ DELETE BUTTON
                B.I.Main.DeleteButton.Create()

            ------ REFRESH SOLD AUCTION BUTTON
                B.I.Main.RefreshButton.Create()

            ------ DROPDOWN MENU
                B.I.Main.OptionsDropDown.Create()

            ------ DROPDOWN MENU LABEL/BUTTON
                B.I.Main.OptionsButton.Create()

        B.I.Options.Create()
        B.I.Search.CreateFrame()
        B.I.MassCancel.CreateFrame()
        B.I.Filters.CreateFrame()
    end

    B.I.Main.Frame = {}
    function B.I.Main.Frame.Create()

        T.AS.mainframe = CreateFrame("Frame", "ASmainframe", UIParent)
        T.AS.mainframe:SetPoint("CENTER", 0, 0)
        T.AS.mainframe:SetHeight(T.GROSSHEIGHT + 6)
        T.AS.mainframe:SetWidth(280)
        T.AS.mainframe:SetToplevel(true)
        T.AS.mainframe:SetFrameStrata("MEDIUM")
        T.AS.mainframe:Hide()

        T.AS.mainframe:SetScript("OnMouseDown", B.I.Main.Frame.MouseDown)
        T.AS.mainframe:SetScript("OnMouseUp", B.I.Main.Frame.MouseUp)
        T.AS.mainframe:SetScript("OnHide", B.I.Main.Frame.Hide)
        T.AS.mainframe:SetScript("OnShow", B.I.Main.Frame.Show)

        B.I.Backdrop(T.AS.mainframe)

        ------ CLOSE BUTTON
        T.AS.mainframe.closebutton = B.I.Close.Create(T.AS.mainframe)
        T.AS.mainframe.closebutton:SetScript("OnClick", function(self)
            T.AS.mainframe:Hide()
        end)
    end

    function B.I.Main.Frame:Show(...)

        if not ASsavedtable.onetimead then StaticPopup_Show("AS_OneTimeAd") end
    end

    function B.I.Main.Frame:MouseDown(...)

        self:StartMoving()
    end

    function B.I.Main.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function B.I.Main.Frame:Hide(...)

        self.headerframe.stopsearchbutton:Click()
        self.headerframe.editbox:SetText("|cff737373"..L[10015])
        self.headerframe.additembutton:Disable()

        B.CloseAllPrompt()
    end

    B.I.Main.StartButton = {}
    function B.I.Main.StartButton.Create()

        T.AS.mainframe.headerframe.startsearchbutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe, "UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.startsearchbutton:SetText(L[10061])
        T.AS.mainframe.headerframe.startsearchbutton:SetWidth(100)
        T.AS.mainframe.headerframe.startsearchbutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.startsearchbutton:SetPoint("TOPLEFT", T.AS.mainframe.headerframe, "TOPLEFT", 17, -45)

        T.AS.mainframe.headerframe.startsearchbutton:SetScript("OnClick", B.I.Main.StartButton.Click)
        T.AS.mainframe.headerframe.startsearchbutton:SetScript("OnEnter", B.I.Main.StartButton.Enter)
        T.AS.mainframe.headerframe.startsearchbutton:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.Reskin(T.AS.mainframe.headerframe.startsearchbutton)
        else
            B.I.GradientButton.Create(T.AS.mainframe.headerframe.startsearchbutton, "VERTICAL")
        end
    end

    function B.I.Main.StartButton:Click(...)

        if T.AS.manualprompt:IsVisible() then T.AS.manualprompt:Hide() end
        if T.AS.mainframe.soldlistframe:IsVisible() then T.AS.mainframe.soldlistframe:Hide() end

        if AuctionFrame and AuctionFrame:IsVisible() then
            AuctionFrameTab1:Click()  -- Focus on search tab
            if AuctionFrameBrowse:IsVisible() then
                BrowseResetButton:Click()
                
                if not IsShiftKeyDown() then T.AS.currentauction = 1 end

                T.AS.mainframe.headerframe.stopsearchbutton:Click()
                T.AS.status = T.STATE.QUERYING
                T.AS.mainframe.headerframe.stopsearchbutton:Enable()
            end
        end

        B.print(T.MSGC.ERROR.."Auction window is not visible")
    end

    function B.I.Main.StartButton:Enter(...)

        B.showtooltip(self, L[10021])
    end

    B.I.Main.StopButton = {}
    function B.I.Main.StopButton.Create()

        T.AS.mainframe.headerframe.stopsearchbutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe, "UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.stopsearchbutton:SetText(L[10060])
        T.AS.mainframe.headerframe.stopsearchbutton:SetWidth(50)
        T.AS.mainframe.headerframe.stopsearchbutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.stopsearchbutton:SetPoint("TOPLEFT", T.AS.mainframe.headerframe.startsearchbutton,"TOPRIGHT", 2, 0)
        T.AS.mainframe.headerframe.stopsearchbutton:Disable()

        T.AS.mainframe.headerframe.stopsearchbutton:SetScript("OnClick", B.I.Main.StopButton.Click)
        T.AS.mainframe.headerframe.stopsearchbutton:SetScript("OnEnter", B.I.Main.StopButton.Enter)
        T.AS.mainframe.headerframe.stopsearchbutton:SetScript("OnLeave", B.hidetooltip)
        T.AS.mainframe.headerframe.stopsearchbutton:SetScript("OnDisable", B.I.Main.StopButton.Disable)

        if T.SKIN then
            F.Reskin(T.AS.mainframe.headerframe.stopsearchbutton)
        else
            B.I.GradientButton.Create(T.AS.mainframe.headerframe.stopsearchbutton, "VERTICAL")
        end
    end

    function B.I.Main.StopButton:Click(...)

        self:Disable()
    end

    function B.I.Main.StopButton:Enter(...)

        B.showtooltip(self, L[10022])
    end

    function B.I.Main.StopButton:Disable(...)

        T.AS.prompt:Hide()
        if T.AS.override then T.AS.currentauction = 1 end

        T.AS.currentresult = 0
        T.AS.status = nil
        T.AS.override = false
        -- set default AH sort (could not achieve the same result using API)
        AuctionFrame_SetSort("list", "quality", false)
    end

    B.I.Main.InputSearch = {}
    function B.I.Main.InputSearch.Create()

        T.AS.mainframe.headerframe.editbox = CreateFrame("EditBox", nil, T.AS.mainframe.headerframe, "InputBoxTemplate")
        T.AS.mainframe.headerframe.editbox:SetPoint("BOTTOMLEFT", T.AS.mainframe.headerframe, "BOTTOMLEFT", 27, 15)
        T.AS.mainframe.headerframe.editbox:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.editbox:SetWidth(T.AS.mainframe.headerframe:GetWidth()-76)
        T.AS.mainframe.headerframe.editbox:SetAutoFocus(false)
        T.AS.mainframe.headerframe.editbox:SetText("|cff737373"..L[10015])

        T.AS.mainframe.headerframe.editbox:HookScript("OnEscapePressed", B.I.Main.InputSearch.Escape)
        T.AS.mainframe.headerframe.editbox:SetScript("OnEnterPressed", B.I.Main.InputSearch.EnterPressed)
        T.AS.mainframe.headerframe.editbox:SetScript("OnEditFocusGained", B.I.Main.InputSearch.FocusGain)
        T.AS.mainframe.headerframe.editbox:SetScript("OnEditFocusLost", B.I.Main.InputSearch.FocusLost)
        T.AS.mainframe.headerframe.editbox:SetScript("OnTextChanged", B.I.Main.InputSearch.Text)

        if T.SKIN then
            F.ReskinInput(T.AS.mainframe.headerframe.editbox) -- Aurora
        else
            B.I.Input(T.AS.mainframe.headerframe.editbox)
            T.AS.mainframe.headerframe.editbox:SetFontObject("ChatFontNormal")
        end
    end

    function B.I.Main.InputSearch:Text(userInput)

        if userInput then

            if self:GetText() == "" then
                T.AS.mainframe.headerframe.additembutton:Disable()
            else
                T.AS.mainframe.headerframe.additembutton:Enable()
            end
        end
    end

    function B.I.Main.InputSearch:FocusGain(...)

        if T.RENAME then B.showtooltip(self, L[10037], nil, true) else B.showtooltip(self, L[10090], nil, true) end
        if self:GetText() == "|cff737373"..L[10015] then self:SetText("") end
    end

    function B.I.Main.InputSearch:FocusLost(...)

        if self:GetText() == "" then self:SetText("|cff737373"..L[10015]) end

        T.RENAME = nil
        B.hidetooltip()
    end

    function B.I.Main.InputSearch:EnterPressed(...)

        T.AS.mainframe.headerframe.additembutton:Click()
    end

    function B.I.Main.InputSearch:Escape(...)

        T.RENAME = nil
    end

    B.I.Main.InputGold = {}
    function B.I.Main.InputGold.Create()

        T.AS.mainframe.headerframe.soldeditbox = CreateFrame("EditBox", nil, T.AS.mainframe.headerframe, "InputBoxTemplate")
        T.AS.mainframe.headerframe.soldeditbox:SetPoint("BOTTOMLEFT", T.AS.mainframe.headerframe, "BOTTOMLEFT", 27, 15)
        T.AS.mainframe.headerframe.soldeditbox:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.soldeditbox:SetWidth(T.AS.mainframe.headerframe:GetWidth()-45)
        T.AS.mainframe.headerframe.soldeditbox:SetJustifyH("CENTER")
        T.AS.mainframe.headerframe.soldeditbox:Hide()
        T.AS.mainframe.headerframe.soldeditbox:Disable()

        if T.SKIN then
            F.ReskinInput(T.AS.mainframe.headerframe.soldeditbox) -- Aurora
        else
            B.I.Input(T.AS.mainframe.headerframe.soldeditbox)
        end
    end

    B.I.Main.AddButton = {}
    function B.I.Main.AddButton.Create()

        T.AS.mainframe.headerframe.additembutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe,"UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.additembutton:SetText("+")
        T.AS.mainframe.headerframe.additembutton:SetWidth(30)
        T.AS.mainframe.headerframe.additembutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.additembutton:Disable()
        T.AS.mainframe.headerframe.additembutton:SetPoint("TOPLEFT", T.AS.mainframe.headerframe.editbox, "TOPRIGHT", 2, 0)

        T.AS.mainframe.headerframe.additembutton:SetScript("OnClick", B.AddItem)
        T.AS.mainframe.headerframe.additembutton:SetScript("OnEnable", B.I.Main.AddButton.Enable)
        T.AS.mainframe.headerframe.additembutton:SetScript("OnDisable", B.I.Main.AddButton.Disable)

        B.I.GradientButton.Create(T.AS.mainframe.headerframe.additembutton, "VERTICAL")
    end

    function B.I.Main.AddButton:Enable(...)

        self:LockHighlight()
    end

    function B.I.Main.AddButton:Disable(...)

        self:UnlockHighlight()
    end

    B.I.Main.DeleteButton = {}
    function B.I.Main.DeleteButton.Create()

        T.AS.mainframe.headerframe.deletelistbutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe, "UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.deletelistbutton:SetText(L[10066])
        T.AS.mainframe.headerframe.deletelistbutton:SetWidth(100)
        T.AS.mainframe.headerframe.deletelistbutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.deletelistbutton:SetPoint("BOTTOMLEFT", T.AS.mainframe, "BOTTOMLEFT", 17, 3)

        T.AS.mainframe.headerframe.deletelistbutton:SetScript("OnClick", B.I.Main.DeleteButton.Click)
        T.AS.mainframe.headerframe.deletelistbutton:SetScript("OnEnter", B.I.Main.DeleteButton.Enter)
        T.AS.mainframe.headerframe.deletelistbutton:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.Reskin(T.AS.mainframe.headerframe.deletelistbutton)
        else
            B.I.GradientButton.Create(T.AS.mainframe.headerframe.deletelistbutton, "VERTICAL")
        end
    end

    function B.I.Main.DeleteButton:Click(...)

        if IsControlKeyDown() then
            -- delete list if not current server name
            if GetRealmName() == T.ACTIVE_TABLE then
                B.print(T.MSGC.EVENT.."[ Resetting server list ]")
                T.AS.item = {}
                B.SavedVariables()
            else
                B.print(T.MSGC.EVENT.."[ Deleting list: "..T.ACTIVE_TABLE.." ]")
                ASsavedtable[T.ACTIVE_TABLE] = nil
                B.LoadTable(GetRealmName())
            end
            B.ScrollbarUpdate()
        end
    end

    function B.I.Main.DeleteButton:Enter(...)

        B.showtooltip(self, L[10058])
    end

    B.I.Main.RefreshButton = {}
    function B.I.Main.RefreshButton.Create()

        T.AS.mainframe.headerframe.refreshlistbutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe, "UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.refreshlistbutton:SetText(L[10083])
        T.AS.mainframe.headerframe.refreshlistbutton:SetWidth(100)
        T.AS.mainframe.headerframe.refreshlistbutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.refreshlistbutton:SetPoint("BOTTOMLEFT", T.AS.mainframe, "BOTTOMLEFT", 17, 3)
        T.AS.mainframe.headerframe.refreshlistbutton:Hide()

        T.AS.mainframe.headerframe.refreshlistbutton:SetScript("OnClick", B.I.Main.RefreshButton.Click)
        T.AS.mainframe.headerframe.refreshlistbutton:SetScript("OnEnter", B.I.Main.RefreshButton.Enter)
        T.AS.mainframe.headerframe.refreshlistbutton:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.Reskin(T.AS.mainframe.headerframe.refreshlistbutton)
        else
            B.I.GradientButton.Create(T.AS.mainframe.headerframe.refreshlistbutton, "VERTICAL")
        end
    end

    function B.I.Main.RefreshButton:Click(...)

        T.FIRSTRUN_AH = false
        B.print(T.MSGC.WARN..L[10075], 1)
    end

    function B.I.Main.RefreshButton:Enter(...)

        B.showtooltip(self, L[10084])
    end

    B.I.Main.PrevButton = {}
    function B.I.Main.PrevButton.Create()

        T.AS.mainframe.headerframe.prevlist = B.I.PrevButton.Create(T.AS.mainframe.headerframe)
        T.AS.mainframe.headerframe.prevlist:SetPoint("LEFT", T.AS.mainframe.headerframe.stopsearchbutton, "RIGHT", 10, 0)
        T.AS.mainframe.headerframe.prevlist:HookScript("OnClick", B.I.Main.PrevButton.Click)
    end

    function B.I.Main.PrevButton:Click(...)

        if ASsavedtable then
            local current = I_LISTNAMES[T.ACTIVE_TABLE]
            if LISTNAMES[current - 1] == nil then -- Go to the end
                B.SwitchTable(LISTNAMES[table.maxn(LISTNAMES)])
            else
                B.SwitchTable(LISTNAMES[current - 1])
            end
        end
    end

    B.I.Main.NextButton = {}
    function B.I.Main.NextButton.Create()

        T.AS.mainframe.headerframe.nextlist = B.I.NextButton.Create(T.AS.mainframe.headerframe)
        T.AS.mainframe.headerframe.nextlist:SetPoint("LEFT", T.AS.mainframe.headerframe.prevlist,"RIGHT", 7, 0)
        T.AS.mainframe.headerframe.nextlist:HookScript("OnClick", B.I.Main.NextButton.Click)
    end

    function B.I.Main.NextButton:Click(...)

        if ASsavedtable then
            local current = I_LISTNAMES[T.ACTIVE_TABLE]
            if LISTNAMES[current + 1] == nil then -- Go back to beginning
                B.SwitchTable(LISTNAMES[1])
            else
                B.SwitchTable(LISTNAMES[current + 1])
            end
        end
    end

    B.I.Main.SoldAuctionButton = {}
    function B.I.Main.SoldAuctionButton.Create()

        T.AS.mainframe.headerframe.soldbutton = CreateFrame("Button", nil, T.AS.mainframe.headerframe, "UIPanelbuttontemplate")
        T.AS.mainframe.headerframe.soldbutton:SetText("|TInterface\\MoneyFrame\\UI-GoldIcon:16:16:2:0|t")
        T.AS.mainframe.headerframe.soldbutton:SetWidth(30)
        T.AS.mainframe.headerframe.soldbutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.mainframe.headerframe.soldbutton:SetPoint("TOP", T.AS.mainframe.headerframe.startsearchbutton, "TOP")
        T.AS.mainframe.headerframe.soldbutton:SetPoint("RIGHT", T.AS.mainframe.headerframe.additembutton, "RIGHT")

        T.AS.mainframe.headerframe.soldbutton:SetScript("OnClick", B.I.Main.SoldAuctionButton.Click)
        T.AS.mainframe.headerframe.soldbutton:SetScript("OnEnter", B.I.Main.SoldAuctionButton.Enter)
        T.AS.mainframe.headerframe.soldbutton:SetScript("OnLeave", B.hidetooltip)

        B.I.GradientButton.Create(T.AS.mainframe.headerframe.soldbutton, "VERTICAL")
    end

    function B.I.Main.SoldAuctionButton:Click(...)

        if T.AS.mainframe.soldlistframe:IsVisible() then -- Toggle off
            T.AS.mainframe.soldlistframe:Hide()
        else -- Toggle on
            T.AS.mainframe.soldlistframe:Show()
        end
    end

    function B.I.Main.SoldAuctionButton:Enter(...)

        B.showtooltip(self, L[10070])
    end

    B.I.Main.OptionsDropDown = {}
    function B.I.Main.OptionsDropDown.Create()

        ASdropDownMenu = CreateFrame("Frame", "ASdropDownMenu", T.AS.mainframe, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(ASdropDownMenu, 130, 4)
        ASdropDownMenu:SetPoint("TOPLEFT", T.AS.mainframe.headerframe.deletelistbutton, "TOPRIGHT", -8, 4)
        UIDropDownMenu_Initialize(ASdropDownMenu, B.I.Main.OptionsDropDown.Initialize) --The virtual

        if T.SKIN then F.ReskinDropDown(ASdropDownMenu) end -- Aurora
    end

    function B.I.Main.OptionsDropDown:Initialize(level)
        --drop down menues can have sub menues. The value of level determines the drop down sub menu tier
        local level = level or 1 

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()

            --- Profile/Server list
            B.I.Main.OptionsDropDown.Menu(info, L[10063], "Import", level)
            --- Edit list options
            B.I.Main.OptionsDropDown.Menu(info, L[10064], "ASlistoptions", level)
            --- Create new list
            B.I.Main.OptionsDropDown.Button(self, info, L[10065], "ASnewlist", false, level)

            if ASsavedtable then
                --- Copper override first
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["copperoverride"], "copperoverride", ASsavedtable.copperoverride, level)
                --- Remember auction price
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["rememberprice"], "rememberprice", ASsavedtable.rememberprice, level)
                --- Cancel auction
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["cancelauction"], "cancelauction", ASsavedtable.cancelauction, level)
                --- Search owned auction
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["searchauction"], "searchauction", ASsavedtable.searchauction, level)
                --- Alerts
                B.I.Main.OptionsDropDown.Menu(info, L[10080], "AOalerts", level)
                --- Auto open
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["ASautoopen"], "ASautoopen", ASsavedtable.ASautoopen, level)
                --- Auto start
                B.I.Main.OptionsDropDown.Button(self, info, T.LABEL["ASautostart"], "ASautostart", ASsavedtable.ASautostart, level)
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "Import" then
            local info = UIDropDownMenu_CreateInfo()

            if ASsavedtable then
                for key, value in pairs(ASsavedtable) do
                    if not T.LABEL[key] and not T.OPTIONS[key] then -- Found a server

                        if key == T.ACTIVE_TABLE then -- indicate which list is being used
                            info.checked = true
                        else
                            info.checked = false
                        end
                        B.I.Main.OptionsDropDown.Button(self, info, key, key, info.checked, level)
                    end
                end
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "ASlistoptions" then
            local info = UIDropDownMenu_CreateInfo()
            --- Rename current list
            B.I.Main.OptionsDropDown.Button(self, info, L[10016], "AOrenamelist", false, level)

            if ASsavedtable then
                for key, value in pairs(ASsavedtable[T.ACTIVE_TABLE]) do
                    if T.LABEL[key] then -- sounds
        
                        if type(value) == "boolean" then
                            info.checked = value
                        else
                            info.checked = false
                        end

                        B.I.Main.OptionsDropDown.Button(self, info, T.LABEL[key], key, info.checked, level)
                    end
                end
            end

        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "AOalerts" then
            local info = UIDropDownMenu_CreateInfo()
            --- Chat options
            B.I.Main.OptionsDropDown.Menu(info, L[10081], "AOchat", level)
            --- Sounds options
            B.I.Main.OptionsDropDown.Menu(info, L[10076], "AOsounds", level)

        elseif level == 3 and UIDROPDOWNMENU_MENU_VALUE == "AOchat" then
            local info = UIDropDownMenu_CreateInfo()
            -- Sold
            B.I.Main.OptionsDropDown.Button(self, info, L[10078], "AOchatsold", ASsavedtable.AOchatsold, level)

        elseif level == 3 and UIDROPDOWNMENU_MENU_VALUE == "AOsounds" then
            local info = UIDropDownMenu_CreateInfo()
            --- Outbid
            B.I.Main.OptionsDropDown.Button(self, info, L[10077], "AOoutbid", ASsavedtable.AOoutbid, level)
            --- Sold
            B.I.Main.OptionsDropDown.Button(self, info, L[10078], "AOsold", ASsavedtable.AOsold, level)
            --- Expired
            B.I.Main.OptionsDropDown.Button(self, info, L[10079], "AOexpired", ASsavedtable.AOexpired, level)

        else
            local info = UIDropDownMenu_CreateInfo()

            info.text = L[10017]
            info.value = nil
            info.hasArrow = false
            info.owner = self:GetParent()
            UIDropDownMenu_AddButton(info, level)
        end
    end

    function B.I.Main.OptionsDropDown.Menu(info, label, value, level)

        info.text = label
        info.value = value
        info.hasArrow = true
        info.checked = false

        UIDropDownMenu_AddButton(info, level)
    end

    function B.I.Main.OptionsDropDown.Button(self, info, label, value, checked, level)

        info.text = label
        info.hasArrow = false
        info.value = value
        info.func = B.dropDownMenuItem_OnClick
        info.owner = self:GetParent()
        info.checked = checked

        UIDropDownMenu_AddButton(info, level)

    end

    B.I.Main.OptionsButton = {}
    function B.I.Main.OptionsButton.Create()

        ASdropdownmenubutton = CreateFrame("Button", nil, ASdropDownMenu)
        ASdropdownmenubutton:SetText(L[10062])
        ASdropdownmenubutton:SetNormalFontObject("GameFontNormal")
        ASdropdownmenubutton:SetPoint("CENTER", ASdropDownMenu, "CENTER", -7, 1)
        ASdropdownmenubutton:SetWidth(80)
        ASdropdownmenubutton:SetHeight(34)

        ASdropdownmenubutton:SetScript("OnClick", B.I.Main.OptionsButton.Click)
    end

    function B.I.Main.OptionsButton:Click(...)

        ASdropDownMenuButton:Click()
    end

--[[//////////////////////////////////////////////////

    SCROLL SEARCH LIST FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.List.Search = {}
    function B.I.List.Search.Create()

        T.AS.mainframe.listframe = CreateFrame("Frame", "FauxScrollFrameTest", T.AS.mainframe)
        T.AS.mainframe.listframe:SetPoint("TOPLEFT", T.AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        T.AS.mainframe.listframe:SetPoint("BOTTOMRIGHT", T.AS.mainframe, "BOTTOMRIGHT", 0, 10)

        T.AS.mainframe.listframe:SetScript("OnShow", function(self)
            T.AS.mainframe.headerframe.refreshlistbutton:Hide()
            T.AS.mainframe.headerframe.deletelistbutton:Show()
        end)

        T.AS.mainframe.listframe.scrollFrame = B.I.List.ScrollFrame(T.AS.mainframe.listframe,
                                             "AS_scrollframe", B.ScrollbarUpdate, B.I.List.Search.Button)
    end

    function B.I.List.Search.Button(index)

        -------------- STYLE ----------------
            local button = B.I.List.Button(index, T.AS.mainframe.listframe)
            button.icon = B.I.List.Icon.Create(button)
            button.leftstring:SetPoint("LEFT", button:GetNormalTexture(), "LEFT", 10, 0)
            button.leftstring:SetPoint("RIGHT", button:GetNormalTexture(), "RIGHT", -2, 0)
        -------------- SCRIPT ----------------
            button:SetScript("OnMouseDown", function(self) -- compensate for scroll bar
                self.originalpos = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
            end)
            button:SetScript("OnClick", B.I.List.Search.Click)
            button:SetScript("OnMouseUp", B.I.List.Search.MouseUp)
            button:SetScript("OnEnter", B.I.List.Search.Enter)
            button:SetScript("OnDoubleClick", B.I.List.Search.DoubleClick)
            button:SetScript("OnLeave", B.hidetooltip)

       return button
    end

    function B.I.List.Search:Click(...)

        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
        local item = T.AS.item[idx]

        if T.AS.optionframe:IsVisible() then T.AS.optionframe:Hide() end
        
        if IsShiftKeyDown() then
            if item.link then
                SetItemRef(item.link, item.link, "LeftButton")
            else
                T.AS.mainframe.headerframe.editbox:SetText(item.name)
            end
        else
            B.SetSelected(idx)
            T.AS.optionframe:SetParent(self)
            T.AS.optionframe:SetPoint("TOP", self, "BOTTOMRIGHT")
            T.AS.optionframe:Show()
        end
    end

    function B.I.List.Search:Enter(...)

        local hexcolor, title
        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
        local item = T.AS.item[idx]

        if item.rarity then
            _, _, _, hexcolor = GetItemQualityColor(item.rarity)
            title = "|c"..hexcolor..item.name
        else
            title = "|cffffffff"..item.name
        end

        local tooltip = B.showtooltip(self, nil, title, true)
        tooltip:AddLine(L[10059], 0, 1, 1, 1, 1) -- Instructions

        if item.ignoretable and item.ignoretable[item.name] then
            local filters = {}

            if item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice > 0 then
                filters["|cff00ffff"..L[10023]..":|r"] = B.ASGSC(tonumber(item.ignoretable[item.name].cutoffprice))
            elseif item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice == 0 then
                filters["|cff00ffff"..L[10024]..":|r"] = "|cff9d9d9d"..L[10025].."|r"
            end

            if item.ignoretable[item.name].ilvl then
                filters["|cff00ffff"..L[10026]..":|r"] = "|cffffffff"..item.ignoretable[item.name].ilvl.."|r"
            end

            if item.ignoretable[item.name].stackone then
                filters['single'] = "|cff00ffff"..L[10069].."|r"
            end
            if item.ignoretable[item.name].exactmatch then
                filters['single2'] = "|cff00ffff"..AH_EXACT_MATCH.."|r"
            end

            if next(filters) then
                local key, value

                tooltip:AddLine(" ")
                tooltip:AddLine(L[10019])

                for key, value in pairs(filters) do
                    if strfind(key, "single") then
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
                tooltip:AddDoubleLine("|cff00ffff"..L[10027]..":|r", B.ASGSC(item.sellbid))
            end
            if item.sellbuyout and item.sellbuyout > 0 then
                tooltip:AddDoubleLine("|cff00ffff"..L[10028]..":|r", B.ASGSC(item.sellbuyout))
            end
        end

        if item.notes then
            tooltip:AddLine(" ")
            tooltip:AddLine("|cff888888-------------------------------|r")
            tooltip:AddLine("|cffffffff"..item.notes.."|r")
        end

        tooltip:Show()
    end

    function B.I.List.Search:MouseUp(button)

        if button == "RightButton" then
            if AuctionFrame and AuctionFrame:IsVisible() then
                local idx = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
                
                AuctionFrameTab1:Click() -- Focus on search tab
                AuctionFrameBrowse.page = 0

                T.AS.override = true
                T.AS.currentauction = idx
                T.AS.status = T.STATE.QUERYING
                return
            end
            B.print(T.MSGC.ERROR.."Auction house is not visible")
        else
            B.MoveListButton(self.originalpos)
            B.ScrollbarUpdate()
        end
    end

    function B.I.List.Search:DoubleClick(...)

        if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then
            BrowseResetButton:Click()
            AuctionFrameBrowse.page = 0

            local idx = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
            local item = T.AS.item[idx]

            BrowseName:SetText(B.sanitize(item.name))
            ExactMatchCheckButton:SetChecked(item.ignoretable and item.ignoretable[item.name] and item.ignoretable[item.name].exactmatch and true or false)

            if AuctionFrame.selectedTab == 3 or AuctionFrame.selectedTab == 2 then
                AuctionFrameTab1:Click()
            end
            AuctionFrameBrowse_Search()
        end
    end


--[[//////////////////////////////////////////////////

    SCROLL SOLD LIST FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.List.Sold = {}
    function B.I.List.Sold.Create()

        T.AS.mainframe.soldlistframe = CreateFrame("Frame", "FauxScrollFrameTest", T.AS.mainframe)
        T.AS.mainframe.soldlistframe:SetPoint("TOPLEFT", T.AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        T.AS.mainframe.soldlistframe:SetPoint("BOTTOMRIGHT", T.AS.mainframe, "BOTTOMRIGHT", 0, 10)
        T.AS.mainframe.soldlistframe:Hide()

        T.AS.mainframe.soldlistframe:SetScript("OnHide", function(self)
            T.AS.mainframe.headerframe.soldeditbox:Hide()
            T.AS.mainframe.headerframe.editbox:Show()
            T.AS.mainframe.headerframe.additembutton:Show()
            T.AS.mainframe.headerframe.soldbutton:UnlockHighlight()
            T.AS.mainframe.listframe:Show()
        end)
        T.AS.mainframe.soldlistframe:SetScript("OnShow", function(self)
            T.AS.mainframe.headerframe.editbox:Hide()
            T.AS.mainframe.headerframe.additembutton:Hide()
            T.AS.mainframe.headerframe.soldbutton:LockHighlight() 
            T.AS.mainframe.headerframe.deletelistbutton:Hide()
            T.AS.mainframe.headerframe.refreshlistbutton:Show()
            T.AS.mainframe.listframe:Hide()
            B.OwnerScrollbarUpdate()
            T.AS.mainframe.headerframe.soldeditbox:Show()
        end)

        T.AS.mainframe.soldlistframe.scrollFrame = B.I.List.ScrollFrame(T.AS.mainframe.soldlistframe, "AS_soldauction_scrollframe", B.OwnerScrollbarUpdate, B.I.List.Sold.Button)
    end

    function B.I.List.Sold.Button(index)

        -------------- STYLE ----------------
            local button = B.I.List.Button(index, T.AS.mainframe.soldlistframe)
            button.icon = B.I.List.Icon.Create(button)
            button.leftstring:SetPoint("LEFT", button:GetNormalTexture(), "LEFT", 10, 0)
            button.rightstring = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            button.rightstring:SetJustifyH("RIGHT")
            button.rightstring:SetJustifyV("CENTER")
            button.rightstring:SetWordWrap(false)
            button.rightstring:SetPoint("RIGHT", button:GetNormalTexture(),"RIGHT", -2, 0)
        -------------- SCRIPT ----------------
            button:SetScript("OnEnter", B.I.List.Sold.Enter)
            button:SetScript("OnLeave", B.hidetooltip)
            button:SetScript("OnDoubleClick", B.I.List.Sold.DoubleClick)

       return button
    end

    function B.I.List.Sold:Enter(...)
        local idx = self.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.soldlistframe.scrollFrame)
        local item = T.AS.soldauctions[idx]

        local tooltip = B.showtooltip(self, nil, L[10071], true)
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

    function B.I.List.Sold:DoubleClick(...)

        BrowseResetButton:Click()
        AuctionFrameBrowse.page = 0
        BrowseName:SetText(B.sanitize(self.leftstring:GetText()))
        AuctionFrameBrowse_Search()
    end


--[[//////////////////////////////////////////////////

    OPTION FRAME FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.Options = {}
    function B.I.Options.Create()

        T.AS.optionframe = CreateFrame("Frame", "ASoptionframe", T.AS.mainframe)
        T.AS.optionframe:SetHeight((T.BUTTON_HEIGHT * 8) + (T.FRAMEWHITESPACE * 2))  -- 8 buttons
        T.AS.optionframe:SetWidth(200)
        T.AS.optionframe:SetToplevel(true)
        
        T.AS.optionframe:SetBackdrop({    bgFile = AS_backdrop,
                                        edgeFile = AS_backdrop,
                                        tile = false, tileSize = 32, edgeSize = 1,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        T.AS.optionframe:SetBackdropColor(0, 0, 0, 0.8)
        T.AS.optionframe:SetBackdropBorderColor(r, g, b, 0.3)

        T.AS.optionframe:SetScript("OnLeave", function(self)
            local x, y = B.GetCursorScaledPosition()
            -- Only hide when cursor exits at the top or bottom of the option menu
            if (x < self:GetLeft()) or (x > self:GetRight()) or (y < self:GetBottom()) or (y > self:GetTop()) then
                self:Hide()
            end
        end)
        T.AS.optionframe:SetScript("OnShow", function(self)
            self:SetFrameStrata("TOOLTIP")
        end)

        ------ SELL ITEM
        T.AS.optionframe.sellbutton = B.I.Options.Button(L[10029])
        T.AS.optionframe.sellbutton:SetPoint("TOP", 0, -T.FRAMEWHITESPACE)
        T.AS.optionframe.sellbutton:SetScript("OnClick", B.I.Options.Sell)

        ------ MASS CANCEL
        T.AS.optionframe.masscancelbutton = B.I.Options.Button(L[10087])
        T.AS.optionframe.masscancelbutton:SetPoint("TOP", T.AS.optionframe.sellbutton, "BOTTOM")
        T.AS.optionframe.masscancelbutton:SetScript("OnClick", B.I.Options.MassCancel)

        ------ MANUAL PRICE
        T.AS.optionframe.manualpricebutton = B.I.Options.Button(L[10030])
        T.AS.optionframe.manualpricebutton:SetPoint("TOP", T.AS.optionframe.masscancelbutton, "BOTTOM")
        T.AS.optionframe.manualpricebutton:SetScript("OnClick", B.I.Options.Filters)

        ------ COPY ENTRY
        T.AS.optionframe.copyrowbutton = B.I.Options.Button(L[10032])
        T.AS.optionframe.copyrowbutton:SetPoint("TOP", T.AS.optionframe.manualpricebutton, "BOTTOM")
        T.AS.optionframe.copyrowbutton:SetScript("OnClick", B.I.Options.Copy)

        ------ RESET FILTERS
        T.AS.optionframe.resetignorebutton = B.I.Options.Button(L[10033])
        T.AS.optionframe.resetignorebutton:SetPoint("TOP", T.AS.optionframe.copyrowbutton, "BOTTOM")
        T.AS.optionframe.resetignorebutton:SetScript("OnClick", B.I.Options.Reset)

        ------ MOVE ENTRY TO TOP
        T.AS.optionframe.movetotopbutton = B.I.Options.Button(L[10034])
        T.AS.optionframe.movetotopbutton:SetPoint("TOP", T.AS.optionframe.resetignorebutton,"BOTTOM")
        T.AS.optionframe.movetotopbutton:SetScript("OnClick", B.I.Options.MoveTop)

        ------ MOVE ENTRY TO BOTTOM
        T.AS.optionframe.movetobottombutton = B.I.Options.Button(L[10035])
        T.AS.optionframe.movetobottombutton:SetPoint("TOP", ASoptionframe.movetotopbutton,"BOTTOM")
        T.AS.optionframe.movetobottombutton:SetScript("OnClick", B.I.Options.MoveBottom)

        ------ DELETE ENTRY
        T.AS.optionframe.deleterowbutton = B.I.Options.Button(L[10036])
        T.AS.optionframe.deleterowbutton:SetPoint("TOP", T.AS.optionframe.movetobottombutton, "BOTTOM")
        T.AS.optionframe.deleterowbutton:SetScript("OnClick", B.I.Options.Delete)
    end

    function B.I.Options.Button(label)
        local button = CreateFrame("Button", nil, T.AS.optionframe)
        
        button:SetHeight(T.BUTTON_HEIGHT)
        button:SetWidth(T.AS.optionframe:GetWidth())
        button:SetNormalFontObject("GameFontNormal")
        button:SetText(label)
        button:SetHighlightTexture(AS_backdrop)
        button:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)

        return button
    end

    function B.I.Options:Sell(...)

        local bag, slot, link, name
        local _, item = B.GetSelected()

        T.AS.optionframe:Hide()
        CancelSell()

        if AuctionFrameAuctions.priceType ~= 1 then
            AuctionFrameAuctions.priceType = 1
            UIDropDownMenu_SetSelectedValue(PriceDropDown, AuctionFrameAuctions.priceType) -- Set to unit price
        end

        for bag = 0, 4 do -- Find item in bags and create auction
            for slot = 1, GetContainerNumSlots(bag) do
                link = GetContainerItemLink(bag, slot)
                if link then
                    name = strfind(link, "|Hbattlepet:") and B.GetPetInfo(link)[1] or GetItemInfo(link)
                    if name and (name == item.name or 
                                (item.link and string.find(item.link, name) and not string.find(item.link, name.."%s")) or 
                                string.find(string.lower(name), string.lower(item.name))) then -- string.find ignores dashes

                        B.print(T.MSGC.INFO.."Setting up sale:|r "..item.name, 1)
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
        B.print(T.MSGC.ERROR.."Item not found in bags")
    end

    function B.I.Options:Filters(...)

        local listnumber, item = B.GetSelected()

        B.CloseAllPrompt()

        T.AS.item['ASmanualedit'] = {}
        T.AS.item['ASmanualedit'].name = item.name
        T.AS.item['ASmanualedit'].listnumber = listnumber

        T.AS.manualprompt.upperstring:SetText(item.name)

        if item.icon then
            T.AS.manualprompt.icon:SetNormalTexture(item.icon)
            T.AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end

        if item.notes then
            T.AS.manualprompt.notes:SetText(item.notes)
        end

        if item.rarity then
            local _, _, _, hexcolor = GetItemQualityColor(item.rarity)
            T.AS.manualprompt.upperstring:SetText("|c"..hexcolor..tostring(item.name))
        end
        
        if item.ignoretable and item.ignoretable[item.name] then
            if item.ignoretable[item.name].cutoffprice then
                T.AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":\n"..B.ASGSC(tonumber(item.ignoretable[item.name].cutoffprice)))
            end
            if item.ignoretable[item.name].ilvl then
                T.AS.manualprompt.ilvllabel:SetText(L[10026]..":\n".."|cffffffff"..item.ignoretable[item.name].ilvl.."|r")
                T.AS.manualprompt.ilvlinput:SetText(item.ignoretable[item.name].ilvl)
            end

            if item.ignoretable[item.name].stackone then
                T.AS.manualprompt.stackone:SetChecked(true)
            end

            if item.ignoretable[item.name].exactmatch then
                T.AS.manualprompt.exactmatch:SetChecked(true)
            end
        end

        T.AS.optionframe:Hide()
        T.AS.manualprompt:Show()
    end

    function B.I.Options:Reset(...)
        local _, item = B.GetSelected()
        B.print(T.MSGC.INFO.."Reset filters for:|r "..item.name, 1)

        item.ignoretable = nil
        item.priceoverride = nil
        B.SavedVariables()
        T.AS.optionframe:Hide()
    end

    function B.I.Options:Delete(...)
        local listnumber, item = B.GetSelected()
        B.print(T.MSGC.INFO.."Removing:|r "..item.name, 1)

        table.remove(T.AS.item, listnumber)
        B.ScrollbarUpdate() -- Necessary to remove empty gap
        B.SavedVariables()
        T.AS.optionframe:Hide()
    end

    function B.I.Options:Rename(...)

        local listnumber = B.GetSelected()
        T.RENAME = listnumber
        T.AS.mainframe.headerframe.editbox:SetFocus()
        T.AS.optionframe:Hide()
    end

    function B.I.Options:Copy(...)

        local _, item = B.GetSelected()
        T.COPY = item

        T.AS.mainframe.headerframe.editbox:SetText(item.name)
        T.AS.mainframe.headerframe.additembutton:Enable()
        T.AS.mainframe.headerframe.additembutton:LockHighlight()
        T.AS.optionframe:Hide()
    end

    function B.I.Options:MoveTop(...)

        B.MoveListButton(B.GetSelected(), 1)
    end

    function B.I.Options:MoveBottom(...)

        B.MoveListButton(B.GetSelected(), table.maxn(T.AS.item))
    end

    function B.I.Options:MassCancel(...)

        local x, auction
        local _, item = B.GetSelected()

        B.CloseAllPrompt()
        T.AS.optionframe:Hide()

        AuctionFrameTab3:Click() -- Focus on auction tab

        if AuctionFrame and AuctionFrame:IsVisible() then
            T.AS.currentownerauctions = B.CurrentOwnedAuctions(item.name)
            if next(T.AS.currentownerauctions) then
                T.AS.CancelStatus = T.STATE.QUERYING
                return
            end
            B.print("No items with that name found in your owned auctions.", 1)
            return
        end
        B.print("Auction House is not visible.", 1)
    end


--[[//////////////////////////////////////////////////

    SEARCH PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.Search = {}
    function B.I.Search.CreateFrame()

        ------ MAIN FRAME
            B.I.Search.Frame.Create()

            ------ ICON
                B.I.Search.Icon.Create()

            ------ ITEM
                B.I.Search.Item.Create()

            ------ BID/BUYOUT FRAME
                B.I.Search.BidBuyoutFrame.Create()

            ------ BUYOUT-ONLY FRAME
                B.I.Search.BuyoutFrame.Create()

            ------ BID BUTTON
                B.I.Search.BidButton.Create()

            ------ BUYOUT BUTTON
                B.I.Search.BuyButton.Create()

            ------ CUTOFF PRICE LABEL
                T.AS.prompt.lowerstring = T.AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.prompt.lowerstring:SetJustifyH("CENTER")
                T.AS.prompt.lowerstring:SetJustifyV("TOP")
                T.AS.prompt.lowerstring:SetWidth(T.AS.prompt.separator:GetWidth() + T.AS.prompt.rseparator:GetWidth())
                T.AS.prompt.lowerstring:SetPoint("TOP", T.AS.prompt.bid, "BOTTOMRIGHT", 1, -7)
                T.AS.prompt.lowerstring:SetSpacing(2)
                T.AS.prompt.lowerstring:SetTextColor(r, g, b) -- Aurora

            ------ EXTRA BUTTONS
                B.I.Search.ExtraButtons.Create()

        ------ TRACKER
            B.I.Search.Tracker.Create()

    end

    B.I.Search.Frame = {}
    function B.I.Search.Frame.Create()

        T.AS.prompt = CreateFrame("Frame", "ASpromptframe", T.AS.mainframe)
        T.AS.prompt:SetPoint("TOPLEFT", T.AS.mainframe, "TOPRIGHT", 3, 0)
        T.AS.prompt:SetHeight(420)
        T.AS.prompt:SetWidth(200)
        T.AS.prompt:SetFrameStrata("DIALOG")
        T.AS.prompt:Hide()
        B.I.Backdrop(T.AS.prompt)
        T.AS.prompt:SetUserPlaced(true)

        T.AS.prompt:SetScript("OnMouseDown", B.I.Search.Frame.MouseDown)
        T.AS.prompt:SetScript("OnMouseUp", B.I.Search.Frame.MouseUp)
        T.AS.prompt:SetScript("OnHide", B.I.Search.Frame.Hide)
        T.AS.prompt:SetScript("OnShow", B.I.Search.Frame.Show)

        ------ CLOSE BUTTON
        T.AS.prompt.closebutton = B.I.Close.Create(T.AS.prompt)
        T.AS.prompt.closebutton:SetScript("OnClick", function(self) T.AS.mainframe.headerframe.stopsearchbutton:Click() end)
    end

    function B.I.Search.Frame:MouseDown(...)

        self:StartMoving()
    end

    function B.I.Search.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function B.I.Search.Frame:Hide(...)

        if T.AS.status == nil then
            T.AS.mainframe.headerframe.stopsearchbutton:Click()
        end
    end

    function B.I.Search.Frame:Show(...)

        local _, item = B.GetSelected()

        if T.AS.boughtauctions[item.name] then
            T.AS.prompt.tracker.quantity:SetText("("..T.AS.boughtauctions[item.name]['buyquantity']..")")
            T.AS.prompt.tracker.total:SetText(B.ASGSC(T.AS.boughtauctions[item.name]['buy']))
        else
            T.AS.prompt.tracker.quantity:SetText("(0)")
            T.AS.prompt.tracker.total:SetText(B.ASGSC(0))
        end
    end

    B.I.Search.Icon = {}
    function B.I.Search.Icon.Create()

        T.AS.prompt.icon = CreateFrame("Button", nil, T.AS.prompt)
        T.AS.prompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        T.AS.prompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        T.AS.prompt.icon:SetPoint("TOPLEFT", T.AS.prompt, "TOPLEFT", 18, -15)
        T.AS.prompt.icon:SetHeight(37)
        T.AS.prompt.icon:SetWidth(37)

        T.AS.prompt.icon:SetScript("OnEnter", B.I.Search.Icon.Enter)
        T.AS.prompt.icon:SetScript("OnLeave", B.I.GameTooltip.Leave)
    end

    function B.I.Search.Icon:Enter(...)

        local link = GetAuctionItemLink("list", T.AS.currentresult)
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
            GameTooltip:SetPoint("TOPRIGHT", T.AS.prompt.icon, "TOPLEFT", -10, -20)
            if EnhTooltip then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", T.AS.prompt.icon, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    B.I.Search.Item = {}
    function B.I.Search.Item.Create()

        ------ ITEM ILVL
            T.AS.prompt.ilvlbg = T.AS.prompt.icon:CreateTexture(nil, "OVERLAY")
            T.AS.prompt.ilvlbg:SetColorTexture(0, 0, 0, 0.80)
            T.AS.prompt.ilvlbg:SetWidth(T.AS.prompt.icon:GetWidth() + 2)
            T.AS.prompt.ilvlbg:SetHeight(15)
            T.AS.prompt.ilvlbg:SetPoint("TOPLEFT", T.AS.prompt.icon, "BOTTOMLEFT")

            T.AS.prompt.ilvl = T.AS.prompt.icon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.ilvl:SetJustifyH("CENTER")
            T.AS.prompt.ilvl:SetWordWrap(false)
            T.AS.prompt.ilvl:SetWidth(T.AS.prompt.icon:GetWidth())
            T.AS.prompt.ilvl:SetTextColor(r, g, b, 1) -- Aurora
            T.AS.prompt.ilvl:SetPoint("BOTTOMLEFT", T.AS.prompt.ilvlbg, "BOTTOMLEFT", 0, 1)

        ------ ITEM LABEL
            T.AS.prompt.upperstring = T.AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.upperstring:SetJustifyH("CENTER")
            T.AS.prompt.upperstring:SetWidth(T.AS.prompt:GetWidth() - (T.AS.prompt.icon:GetWidth() + (2*T.FRAMEWHITESPACE)))
            T.AS.prompt.upperstring:SetHeight(T.AS.prompt.icon:GetHeight())
            T.AS.prompt.upperstring:SetPoint("LEFT", T.AS.prompt.icon, "RIGHT", 7, 0)
            T.AS.prompt.upperstring:SetPoint("RIGHT", T.AS.prompt, "RIGHT", -15, 0)

        ------ ITEM QUANTITY
            T.AS.prompt.quantity = T.AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local Path = T.AS.prompt.quantity:GetFont()
            T.AS.prompt.quantity:SetFont(Path, 30) -- Resize string
            T.AS.prompt.quantity:SetJustifyH("CENTER")
            T.AS.prompt.quantity:SetPoint("TOP", T.AS.prompt, "TOP", 0, -T.AS.prompt.icon:GetWidth() - 30)

        ------ ITEM VENDOR
            T.AS.prompt.vendor = T.AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.vendor:SetJustifyH("CENTER")
            T.AS.prompt.vendor:SetWordWrap(false)
            T.AS.prompt.vendor:SetWidth(T.AS.prompt:GetWidth()-20)
            T.AS.prompt.vendor:SetTextColor(r, g, b, 1) -- Aurora
            T.AS.prompt.vendor:SetPoint("TOP", T.AS.prompt.quantity, "BOTTOM", 0, -4)

        ------ ITEM LEFT SEPARATOR
            T.AS.prompt.separator = T.AS.prompt:CreateTexture()
            T.AS.prompt.separator:SetColorTexture(r, b, g, 0.3) -- Aurora
            T.AS.prompt.separator:SetSize((T.AS.prompt:GetWidth()/2)-20, 1)
            T.AS.prompt.separator:SetPoint("RIGHT", T.AS.prompt.vendor, "BOTTOM", 0, -23)

        ------ ITEM RIGHT SEPARATOR
            T.AS.prompt.rseparator = T.AS.prompt:CreateTexture()
            T.AS.prompt.rseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            T.AS.prompt.rseparator:SetSize((T.AS.prompt:GetWidth()/2)-20, 1)
            T.AS.prompt.rseparator:SetPoint("LEFT", T.AS.prompt.separator, "RIGHT")
    end

    B.I.Search.BidBuyoutFrame = {}
    function B.I.Search.BidBuyoutFrame.Create()

        T.AS.prompt.bidbuyout = CreateFrame("FRAME", nil, T.AS.prompt)

        ------ ITEM BID LABEL
            T.AS.prompt.bidbuyout.bid = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            T.AS.prompt.bidbuyout.bid:SetJustifyH("CENTER")
            T.AS.prompt.bidbuyout.bid:SetText(string.upper(L[10042]))
            T.AS.prompt.bidbuyout.bid:SetPoint("BOTTOM", T.AS.prompt.separator, "TOP", 0, 2)

        ------ BID AMOUNT EACH
            T.AS.prompt.bidbuyout.bid.single = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.bidbuyout.bid.single:SetJustifyH("RIGHT")
            T.AS.prompt.bidbuyout.bid.single:SetPoint("TOP", T.AS.prompt.bidbuyout.bid, "BOTTOM", 0, -10)
            T.AS.prompt.bidbuyout.bid.single:SetTextColor(r, g, b) -- Aurora

        ------ BID AMOUNT TOTAL
            T.AS.prompt.bidbuyout.bid.total = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.bidbuyout.bid.total:SetJustifyH("RIGHT")
            T.AS.prompt.bidbuyout.bid.total:SetPoint("TOP", T.AS.prompt.bidbuyout.bid.single, "BOTTOM", 0, -16)
            T.AS.prompt.bidbuyout.bid.total:SetTextColor(r, g, b) -- Aurora

        ------ ITEM BUYOUT LABEL
            T.AS.prompt.bidbuyout.buyout = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            T.AS.prompt.bidbuyout.buyout:SetJustifyH("CENTER")
            T.AS.prompt.bidbuyout.buyout:SetText(string.upper(L[10041]))
            T.AS.prompt.bidbuyout.buyout:SetPoint("BOTTOM", T.AS.prompt.rseparator, "TOP", 0, 2)

        ------ BUYOUT AMOUNT EACH
            T.AS.prompt.bidbuyout.buyout.single = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.bidbuyout.buyout.single:SetJustifyH("LEFT")
            T.AS.prompt.bidbuyout.buyout.single:SetPoint("TOP", T.AS.prompt.bidbuyout.buyout, "BOTTOM", 0, -10)
            T.AS.prompt.bidbuyout.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            T.AS.prompt.bidbuyout.buyout.total = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.bidbuyout.buyout.total:SetJustifyH("LEFT")
            T.AS.prompt.bidbuyout.buyout.total:SetPoint("TOP", T.AS.prompt.bidbuyout.buyout.single, "BOTTOM", 0, -16)
            T.AS.prompt.bidbuyout.buyout.total:SetTextColor(r, g, b) -- Aurora

        ------ MIDDLE SEPARATOR
            T.AS.prompt.bidbuyout.vseparator = T.AS.prompt.bidbuyout:CreateTexture()
            T.AS.prompt.bidbuyout.vseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            T.AS.prompt.bidbuyout.vseparator:SetSize(1, T.AS.prompt.bidbuyout.bid:GetHeight() + 17)
            T.AS.prompt.bidbuyout.vseparator:SetPoint("TOP", T.AS.prompt.separator, "RIGHT")

            ------ MIDDLE SEPARATOR EACH
                T.AS.prompt.bidbuyout.each = T.AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                T.AS.prompt.bidbuyout.each:SetHeight(T.AS.prompt.bidbuyout.bid.single:GetHeight() + 10)
                T.AS.prompt.bidbuyout.each:SetJustifyH("CENTER")
                T.AS.prompt.bidbuyout.each:SetJustifyV("BOTTOM")
                T.AS.prompt.bidbuyout.each:SetText(L[10053])
                T.AS.prompt.bidbuyout.each:SetTextColor(r, g, b, 1) -- Aurora
                T.AS.prompt.bidbuyout.each:SetPoint("CENTER", T.AS.prompt.bidbuyout.vseparator)

            ------ MIDDLE HORIZONTAL SEPARATOR
                T.AS.prompt.bidbuyout.hseparator = T.AS.prompt:CreateTexture()
                T.AS.prompt.bidbuyout.hseparator:SetColorTexture(r, b, g, 0.3) -- Aurora
                T.AS.prompt.bidbuyout.hseparator:SetSize(T.AS.prompt.separator:GetWidth()+T.AS.prompt.rseparator:GetWidth(), 1)
                T.AS.prompt.bidbuyout.hseparator:SetPoint("TOP", T.AS.prompt.bidbuyout.vseparator, "BOTTOM", 0, -1)
    end

    B.I.Search.BuyoutFrame = {}
    function B.I.Search.BuyoutFrame.Create()

        T.AS.prompt.buyoutonly = CreateFrame("FRAME", nil, T.AS.prompt)

        ------ ITEM BUYOUT LABEL
            T.AS.prompt.buyoutonly.buyout = T.AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            T.AS.prompt.buyoutonly.buyout:SetJustifyH("CENTER")
            T.AS.prompt.buyoutonly.buyout:SetText("|c00ffffff"..string.upper(L[10041]).."|r")
            T.AS.prompt.buyoutonly.buyout:SetPoint("BOTTOM", T.AS.prompt.separator, "TOPRIGHT", 0, 2)

        ------ BUYOUT AMOUNT EACH
            T.AS.prompt.buyoutonly.buyout.single = T.AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.buyoutonly.buyout.single:SetJustifyH("CENTER")
            T.AS.prompt.buyoutonly.buyout.single:SetPoint("TOP", T.AS.prompt.buyoutonly.buyout, "BOTTOM", 0, -10)
            T.AS.prompt.buyoutonly.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            T.AS.prompt.buyoutonly.buyout.total = T.AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.prompt.buyoutonly.buyout.total:SetJustifyH("CENTER")
            T.AS.prompt.buyoutonly.buyout.total:SetPoint("TOP", T.AS.prompt.buyoutonly.buyout.single, "BOTTOM", 0, -16)
            T.AS.prompt.buyoutonly.buyout.total:SetTextColor(r, g, b) -- Aurora
    end

    B.I.Search.BidButton = {}
    function B.I.Search.BidButton.Create()

        T.AS.prompt.bid = CreateFrame("Button", nil, T.AS.prompt, "UIPanelbuttontemplate")
        T.AS.prompt.bid:SetText(L[10042])
        T.AS.prompt.bid:SetWidth((T.AS.prompt:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE))
        T.AS.prompt.bid:SetHeight(T.BUTTON_HEIGHT)
        T.AS.prompt.bid:SetPoint("TOP", T.AS.prompt.separator, "BOTTOM", 0, -60)

        T.AS.prompt.bid:SetScript("OnClick", B.I.Search.BidButton.Click)

        if T.SKIN then
            F.Reskin(T.AS.prompt.bid) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.prompt.bid, "VERTICAL")
        end
    end

    function B.I.Search.BidButton:Click(...)

        local _, item = B.GetSelected()
        local bid = B.GetCost()
        selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
        B.print(T.MSGC.DEBUG.."Bidding price: "..B.ASGSC(bid))

        PlaceAuctionBid("list", selected_auction, bid)  --the actual bidding call.
        B.TrackerUpdate(item.name, T.AS.currentauctionitem[3], bid)
        T.AS.prompt:Hide()
        T.AS.status = T.STATE.BUYING
    end

    B.I.Search.BuyButton = {}
    function B.I.Search.BuyButton.Create()

        T.AS.prompt.buyout = CreateFrame("Button", nil, T.AS.prompt, "UIPanelbuttontemplate")
        T.AS.prompt.buyout:SetText(L[10041])
        T.AS.prompt.buyout:SetWidth((T.AS.prompt:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE))
        T.AS.prompt.buyout:SetHeight(T.BUTTON_HEIGHT)
        T.AS.prompt.buyout:SetPoint("LEFT", T.AS.prompt.bid, "RIGHT", 2, 0)

        T.AS.prompt.buyout:SetScript("OnClick", B.I.Search.BuyButton.Click)

        if T.SKIN then
            F.Reskin(T.AS.prompt.buyout) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.prompt.buyout, "VERTICAL")
        end
    end

    function B.I.Search.BuyButton:Click(...)

        local _, item = B.GetSelected()
        local _, buyout = B.GetCost()
        selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
        B.print(T.MSGC.DEBUG.."Buying price: "..B.ASGSC(buyout))
        
        PlaceAuctionBid("list", selected_auction, buyout) -- The actual buying call
        B.TrackerUpdate(item.name, T.AS.currentauctionitem[3], nil, buyout)
        -- The next item will be the same location as what was just bought
        T.AS.prompt:Hide()
        T.AS.currentresult = selected_auction - 1
        T.AS.status = T.STATE.BUYING
    end

    B.I.Search.ExtraButtons = {}
    function B.I.Search.ExtraButtons.Create()

        B.I.Search.ExtraButtons.CreateHandler()

        T.AS.prompt.buttonnames = {L[10047], L[10019], L[10044], L[10043]}
        local buttontooltips = {L[10056], L[10057], L[10054], L[10055]}
        local buttonnames = T.AS.prompt.buttonnames

        buttonwidth = (T.AS.prompt:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE)  --basically half its frame size

        local columns = 2
        local latest_column = nil
        local latest_row = nil
        local current_column = 1

        for i = 1, table.maxn(T.AS.prompt.buttonnames) do

            T.AS.prompt[T.AS.prompt.buttonnames[i]] = B.I.Button.Create(T.AS.prompt, T.AS.prompt.buttonnames[i], buttontooltips[i])
            current_button = T.AS.prompt[buttonnames[i]]

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

    function B.I.Search.ExtraButtons.CreateHandler()
        ------------------------------------------------------------------
        --  Create all the script handlers for the buttons
        ------------------------------------------------------------------
        T.AS[L[10043]] = function()  -- Go to next item in AH
                B.print(T.MSGC.INFO.."Skipping item...")
                T.AS.status = T.STATE.EVALUATING
        end

        T.AS[L[10044]] = function()  -- Go to next item in snatch list
                T.AS.prompt:Hide()
                T.AS.currentauction = T.AS.currentauction + 1
                T.AS.currentresult = 0
                T.AS.status = T.STATE.QUERYING
        end

        T.AS[L[10036]] = function()  -- Delete item
                table.remove(T.AS.item, T.AS.currentauction)
                T.AS.status = T.STATE.QUERYING
                B.ScrollbarUpdate()
        end

        T.AS[L[10046]] = function()  -- Delete list
                if IsControlKeyDown() then
                    T.AS.item = {}
                    T.AS.status = nil
                    ASsavedtable = nil
                    B.ScrollbarUpdate()
                end
        end

        T.AS[L[10047]] = function()  -- Update saved item with prompt item
                local  name, texture, _, quality = GetAuctionItemInfo("list", T.AS.currentresult)
                local link = GetAuctionItemLink("list", T.AS.currentresult)
                
                if T.AS.item[T.AS.currentauction] then

                    T.AS.item[T.AS.currentauction].name = name
                    T.AS.item[T.AS.currentauction].icon = texture
                    T.AS.item[T.AS.currentauction].link = link
                    T.AS.item[T.AS.currentauction].rarity = quality
                    T.AS.currentresult = T.AS.currentresult - 1  --redo this item :)
                    T.AS.status = T.STATE.EVALUATING
                    B.ScrollbarUpdate()
                    B.SavedVariables()
                end
        end

        T.AS[L[10019]] = function()  -- Open manualprompt filters
                B.print(T.MSGC.EVENT.."Opening manual edit filters")
                T.AS.prompt:Hide()
                T.AS.optionframe.manualpricebutton:Click()
        end
    end

    B.I.Search.Tracker = {}
    function B.I.Search.Tracker.Create()

        T.AS.prompt.tracker = CreateFrame("FRAME", nil, T.AS.prompt)
        T.AS.prompt.tracker:SetPoint("TOP", T.AS.prompt, "BOTTOM", 0, -3)
        T.AS.prompt.tracker:SetWidth(T.AS.prompt:GetWidth())
        T.AS.prompt.tracker:SetHeight(35)

        T.AS.prompt.tracker:SetBackdrop({ bgFile = AS_backdrop,
                                        edgeFile = AS_backdrop,
                                        tile = false, tileSize = 32, edgeSize = 1,
                                        insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        T.AS.prompt.tracker:SetBackdropColor(0, 0, 0, 0.8)
        T.AS.prompt.tracker:SetBackdropBorderColor(0.6, 0.5, 0, 1)

        T.AS.prompt.tracker:SetScript("OnMouseDown", B.I.Search.Tracker.MouseDown)
        T.AS.prompt.tracker:SetScript("OnMouseUp", B.I.Search.Tracker.MouseUp)

        ------ ITEM QUANTITY
        T.AS.prompt.tracker.quantity = T.AS.prompt.tracker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        T.AS.prompt.tracker.quantity:SetJustifyH("LEFT")
        T.AS.prompt.tracker.quantity:SetJustifyV("CENTER")
        T.AS.prompt.tracker.quantity:SetText("(0)")
        T.AS.prompt.tracker.quantity:SetPoint("LEFT", T.AS.prompt.tracker, "LEFT", 10, 0)

        ------ ITEM SPENT
        T.AS.prompt.tracker.total = T.AS.prompt.tracker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        T.AS.prompt.tracker.total:SetJustifyH("RIGHT")
        T.AS.prompt.tracker.total:SetJustifyV("CENTER")
        T.AS.prompt.tracker.total:SetText(B.ASGSC(0))
        T.AS.prompt.tracker.total:SetPoint("RIGHT", T.AS.prompt.tracker, "RIGHT", -10, 0)
    end

    function B.I.Search.Tracker:MouseDown(...)

        T.AS.prompt:StartMoving()
    end

    function B.I.Search.Tracker:MouseUp(...)

        T.AS.prompt:StopMovingOrSizing()
    end


--[[//////////////////////////////////////////////////

    MASS CANCEL PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.MassCancel = {}
    function B.I.MassCancel.CreateFrame()

        ------ MAIN FRAME
            B.I.MassCancel.Frame.Create()

            ------ ICON
                B.I.MassCancel.Icon.Create()

            ------ ITEM
                B.I.MassCancel.Item.Create()

            ------ BID/BUYOUT FRAME
                B.I.MassCancel.BidBuyoutFrame.Create()

            ------ CANCEL BUTTON
                B.I.MassCancel.CancelButton.Create()

            ------ NEXT BUTTON
                B.I.MassCancel.NextButton.Create()
    end

    B.I.MassCancel.Frame = {}
    function B.I.MassCancel.Frame.Create()

        T.AS.cancelprompt = CreateFrame("Frame", "AScancelpromptframe", T.AS.mainframe)
        T.AS.cancelprompt:SetPoint("TOPLEFT", T.AS.mainframe, "TOPRIGHT", 3, 0)
        T.AS.cancelprompt:SetHeight(215)
        T.AS.cancelprompt:SetWidth(200)
        T.AS.cancelprompt:SetFrameStrata("DIALOG")
        T.AS.cancelprompt:Hide()
        B.I.Backdrop(T.AS.cancelprompt)
        T.AS.cancelprompt:SetUserPlaced(true)

        T.AS.cancelprompt:SetScript("OnMouseDown", B.I.MassCancel.Frame.MouseDown)
        T.AS.cancelprompt:SetScript("OnMouseUp", B.I.MassCancel.Frame.MouseUp)

        ------ CLOSE BUTTON
        T.AS.cancelprompt.closebutton = B.I.Close.Create(T.AS.cancelprompt)
        T.AS.cancelprompt.closebutton:SetScript("OnClick", function(self) T.AS.cancelprompt:Hide(); T.AS.CancelStatus = nil end)
    end

    function B.I.MassCancel.Frame:MouseDown(...)

        self:StartMoving()
    end

    function B.I.MassCancel.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    B.I.MassCancel.Icon = {}
    function B.I.MassCancel.Icon.Create()

        T.AS.cancelprompt.icon = CreateFrame("Button", nil, T.AS.cancelprompt)
        T.AS.cancelprompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        T.AS.cancelprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        T.AS.cancelprompt.icon:SetPoint("TOPLEFT", T.AS.cancelprompt, "TOPLEFT", 18, -15)
        T.AS.cancelprompt.icon:SetHeight(37)
        T.AS.cancelprompt.icon:SetWidth(37)

        T.AS.cancelprompt.icon:SetScript("OnEnter", B.I.MassCancel.Icon.Enter)
        T.AS.cancelprompt.icon:SetScript("OnLeave", B.I.GameTooltip.Leave)
    end

    function B.I.MassCancel.Icon:Enter(...)

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
            GameTooltip:SetPoint("TOPRIGHT", T.AS.cancelprompt.icon, "TOPLEFT", -10, -20)
            if EnhTooltip then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", T.AS.cancelprompt.icon, "TOPLEFT", -10, -20)
            GameTooltip:Show()
        end
    end

    B.I.MassCancel.Item = {}
    function B.I.MassCancel.Item.Create()

        ------ ITEM LABEL
            T.AS.cancelprompt.upperstring = T.AS.cancelprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.cancelprompt.upperstring:SetJustifyH("CENTER")
            T.AS.cancelprompt.upperstring:SetWidth(T.AS.cancelprompt:GetWidth() - (T.AS.cancelprompt.icon:GetWidth() + (2*T.FRAMEWHITESPACE)))
            T.AS.cancelprompt.upperstring:SetHeight(T.AS.cancelprompt.icon:GetHeight())
            T.AS.cancelprompt.upperstring:SetPoint("LEFT", T.AS.cancelprompt.icon, "RIGHT", 7, 0)
            T.AS.cancelprompt.upperstring:SetPoint("RIGHT", T.AS.cancelprompt, "RIGHT", -15, 0)

        ------ ITEM QUANTITY
            T.AS.cancelprompt.quantity = T.AS.cancelprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            local Path = T.AS.cancelprompt.quantity:GetFont()
            T.AS.cancelprompt.quantity:SetFont(Path, 26) -- Resize string
            T.AS.cancelprompt.quantity:SetJustifyH("CENTER")
            T.AS.cancelprompt.quantity:SetPoint("TOP", T.AS.cancelprompt, "TOP", 0, -T.AS.cancelprompt.icon:GetWidth() - 30)

        ------ ITEM LEFT SEPARATOR
            T.AS.cancelprompt.separator = T.AS.cancelprompt:CreateTexture()
            T.AS.cancelprompt.separator:SetColorTexture(r, b, g, 0.3) -- Aurora
            T.AS.cancelprompt.separator:SetSize((T.AS.cancelprompt:GetWidth()/2)-20, 1)
            T.AS.cancelprompt.separator:SetPoint("RIGHT", T.AS.cancelprompt.quantity, "BOTTOM", 0, -23)

        ------ ITEM RIGHT SEPARATOR
            T.AS.cancelprompt.rseparator = T.AS.cancelprompt:CreateTexture()
            T.AS.cancelprompt.rseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            T.AS.cancelprompt.rseparator:SetSize((T.AS.cancelprompt:GetWidth()/2)-20, 1)
            T.AS.cancelprompt.rseparator:SetPoint("LEFT", T.AS.cancelprompt.separator, "RIGHT")
    end

    B.I.MassCancel.BidBuyoutFrame = {}
    function B.I.MassCancel.BidBuyoutFrame.Create()

        T.AS.cancelprompt.bidbuyout = CreateFrame("FRAME", nil, T.AS.cancelprompt)

        ------ ITEM BID LABEL
            T.AS.cancelprompt.bidbuyout.bid = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            T.AS.cancelprompt.bidbuyout.bid:SetJustifyH("CENTER")
            T.AS.cancelprompt.bidbuyout.bid:SetText(string.upper(L[10042]))
            T.AS.cancelprompt.bidbuyout.bid:SetPoint("BOTTOM", T.AS.cancelprompt.separator, "TOP", 0, 2)

        ------ BID AMOUNT EACH
            T.AS.cancelprompt.bidbuyout.bid.single = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.cancelprompt.bidbuyout.bid.single:SetJustifyH("RIGHT")
            T.AS.cancelprompt.bidbuyout.bid.single:SetPoint("TOP", T.AS.cancelprompt.bidbuyout.bid, "BOTTOM", 0, -10)
            T.AS.cancelprompt.bidbuyout.bid.single:SetTextColor(r, g, b) -- Aurora

        ------ BID AMOUNT TOTAL
            T.AS.cancelprompt.bidbuyout.bid.total = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.cancelprompt.bidbuyout.bid.total:SetJustifyH("RIGHT")
            T.AS.cancelprompt.bidbuyout.bid.total:SetPoint("TOP", T.AS.cancelprompt.bidbuyout.bid.single, "BOTTOM", 0, -16)
            T.AS.cancelprompt.bidbuyout.bid.total:SetTextColor(r, g, b) -- Aurora

        ------ ITEM BUYOUT LABEL
            T.AS.cancelprompt.bidbuyout.buyout = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            T.AS.cancelprompt.bidbuyout.buyout:SetJustifyH("CENTER")
            T.AS.cancelprompt.bidbuyout.buyout:SetText(string.upper(L[10041]))
            T.AS.cancelprompt.bidbuyout.buyout:SetPoint("BOTTOM", T.AS.cancelprompt.rseparator, "TOP", 0, 2)

        ------ BUYOUT AMOUNT EACH
            T.AS.cancelprompt.bidbuyout.buyout.single = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.cancelprompt.bidbuyout.buyout.single:SetJustifyH("LEFT")
            T.AS.cancelprompt.bidbuyout.buyout.single:SetPoint("TOP", T.AS.cancelprompt.bidbuyout.buyout, "BOTTOM", 0, -10)
            T.AS.cancelprompt.bidbuyout.buyout.single:SetTextColor(r, g, b) -- Aurora

        ------ BUYOUT AMOUNT TOTAL
            T.AS.cancelprompt.bidbuyout.buyout.total = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            T.AS.cancelprompt.bidbuyout.buyout.total:SetJustifyH("LEFT")
            T.AS.cancelprompt.bidbuyout.buyout.total:SetPoint("TOP", T.AS.cancelprompt.bidbuyout.buyout.single, "BOTTOM", 0, -16)
            T.AS.cancelprompt.bidbuyout.buyout.total:SetTextColor(r, g, b) -- Aurora

        ------ MIDDLE SEPARATOR
            T.AS.cancelprompt.bidbuyout.vseparator = T.AS.cancelprompt.bidbuyout:CreateTexture()
            T.AS.cancelprompt.bidbuyout.vseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
            T.AS.cancelprompt.bidbuyout.vseparator:SetSize(1, T.AS.cancelprompt.bidbuyout.bid:GetHeight() + 17)
            T.AS.cancelprompt.bidbuyout.vseparator:SetPoint("TOP", T.AS.cancelprompt.separator, "RIGHT")

            ------ MIDDLE SEPARATOR EACH
                T.AS.cancelprompt.bidbuyout.each = T.AS.cancelprompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                T.AS.cancelprompt.bidbuyout.each:SetHeight(T.AS.cancelprompt.bidbuyout.bid.single:GetHeight() + 10)
                T.AS.cancelprompt.bidbuyout.each:SetJustifyH("CENTER")
                T.AS.cancelprompt.bidbuyout.each:SetJustifyV("BOTTOM")
                T.AS.cancelprompt.bidbuyout.each:SetText(L[10053])
                T.AS.cancelprompt.bidbuyout.each:SetTextColor(r, g, b, 1) -- Aurora
                T.AS.cancelprompt.bidbuyout.each:SetPoint("CENTER", T.AS.cancelprompt.bidbuyout.vseparator)

            ------ MIDDLE HORIZONTAL SEPARATOR
                T.AS.cancelprompt.bidbuyout.hseparator = T.AS.cancelprompt:CreateTexture()
                T.AS.cancelprompt.bidbuyout.hseparator:SetColorTexture(r, b, g, 0.3) -- Aurora
                T.AS.cancelprompt.bidbuyout.hseparator:SetSize(T.AS.cancelprompt.separator:GetWidth()+T.AS.cancelprompt.rseparator:GetWidth(), 1)
                T.AS.cancelprompt.bidbuyout.hseparator:SetPoint("TOP", T.AS.cancelprompt.bidbuyout.vseparator, "BOTTOM", 0, -1)
    end

    B.I.MassCancel.CancelButton = {}
    function B.I.MassCancel.CancelButton.Create()

        T.AS.cancelprompt.bid = CreateFrame("Button", nil, T.AS.cancelprompt, "UIPanelbuttontemplate")
        T.AS.cancelprompt.bid:SetText(L[10005])
        T.AS.cancelprompt.bid:SetWidth((T.AS.cancelprompt:GetWidth() / 1.5) - (2 * T.FRAMEWHITESPACE))
        T.AS.cancelprompt.bid:SetHeight(T.BUTTON_HEIGHT)
        T.AS.cancelprompt.bid:SetPoint("TOP", T.AS.cancelprompt.separator, "BOTTOM", 0, -60)
        T.AS.cancelprompt.bid:SetPoint("LEFT", T.AS.cancelprompt.separator, "LEFT")

        T.AS.cancelprompt.bid:SetScript("OnClick", B.I.MassCancel.CancelButton.Click)

        if T.SKIN then
            F.Reskin(T.AS.cancelprompt.bid) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.cancelprompt.bid, "VERTICAL")
        end
    end

    function B.I.MassCancel.CancelButton:Click(...)

        if CanCancelAuction(GetSelectedAuctionItem("owner")) then
            B.UntrackCancelledAuction()
            CancelAuction(GetSelectedAuctionItem("owner"))
        end
        T.AS.cancelprompt:Hide()
        T.AS.CancelStatus = T.STATE.EVALUATING
    end

    B.I.MassCancel.NextButton = {}
    function B.I.MassCancel.NextButton.Create()

        T.AS.cancelprompt.buyout = CreateFrame("Button", nil, T.AS.cancelprompt, "UIPanelbuttontemplate")
        T.AS.cancelprompt.buyout:SetText(L[10088])
        T.AS.cancelprompt.buyout:SetWidth((T.AS.cancelprompt:GetWidth() / 3) - (2 * T.FRAMEWHITESPACE))
        T.AS.cancelprompt.buyout:SetHeight(T.BUTTON_HEIGHT)
        T.AS.cancelprompt.buyout:SetPoint("LEFT", T.AS.cancelprompt.bid, "RIGHT", 2, 0)

        T.AS.cancelprompt.buyout:SetScript("OnClick", B.I.MassCancel.NextButton.Click)

        if T.SKIN then
            F.Reskin(T.AS.cancelprompt.buyout) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.cancelprompt.buyout, "VERTICAL")
        end
    end

    function B.I.MassCancel.NextButton:Click(...)
        B.print(T.MSGC.INFO.."Skipping item...")
        T.AS.CancelStatus = T.STATE.EVALUATING
    end


--[[//////////////////////////////////////////////////

    FILTERS PROMPT FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.Filters = {}
    function B.I.Filters.CreateFrame()

        ------ MAIN FRAME
            B.I.Filters.Frame.Create()

            ------ ICON
                B.I.Filters.Icon.Create()

            ------ ITEM LABEL
                T.AS.manualprompt.upperstring = T.AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.manualprompt.upperstring:SetJustifyH("CENTER")
                T.AS.manualprompt.upperstring:SetWidth(T.AS.manualprompt:GetWidth() - (T.AS.manualprompt.icon:GetWidth() + (2*T.FRAMEWHITESPACE)))
                T.AS.manualprompt.upperstring:SetHeight(T.AS.manualprompt.icon:GetHeight())
                T.AS.manualprompt.upperstring:SetPoint("LEFT", T.AS.manualprompt.icon, "RIGHT", 7, 0)
                T.AS.manualprompt.upperstring:SetPoint("RIGHT", T.AS.manualprompt, "RIGHT", -15, 0)

            ------ RENAME BOX
                T.AS.manualprompt.renamebox = CreateFrame("Button", nil, T.AS.manualprompt)
                T.AS.manualprompt.renamebox:SetAllPoints(T.AS.manualprompt.upperstring)
                T.AS.manualprompt.renamebox:SetScript("OnEnter", function(self) B.showtooltip(self, L[10089]) end)
                T.AS.manualprompt.renamebox:SetScript("OnLeave", B.hidetooltip)
                T.AS.manualprompt.renamebox:SetScript("OnDoubleClick", B.I.Options.Rename)

            ------ CUTOFF PRICE LABEL
                T.AS.manualprompt.lowerstring = T.AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.manualprompt.lowerstring:SetJustifyH("Left")
                T.AS.manualprompt.lowerstring:SetJustifyV("Top")
                T.AS.manualprompt.lowerstring:SetWidth(T.AS.manualprompt:GetWidth() - (2*T.FRAMEWHITESPACE))
                T.AS.manualprompt.lowerstring:SetPoint("TOPLEFT", T.AS.manualprompt.icon, "BOTTOMLEFT", 0, 2)
                T.AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":")
                T.AS.manualprompt.lowerstring:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE BUTTON
                B.I.Filters.IgnoreButton.Create()

            ------ SAVE BUTTON
                B.I.Filters.SaveButton.Create()

            ------ CUTOFF INPUT BOX
                B.I.Filters.InputCutoff.Create()

            ------ ILVL INPUT BOX
                B.I.Filters.InputIlvl.Create()

            ------ EXACT MATCH INPUT BOX
                B.I.Filters.ExactMatch.Create()

            ------ ILVL LABEL
                T.AS.manualprompt.ilvllabel = T.AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.manualprompt.ilvllabel:SetJustifyH("Left")
                T.AS.manualprompt.ilvllabel:SetJustifyV("Top")
                T.AS.manualprompt.ilvllabel:SetPoint("LEFT", T.AS.manualprompt.icon, "LEFT", 0, 2)
                T.AS.manualprompt.ilvllabel:SetPoint("TOP", T.AS.manualprompt.ilvlinput, "TOP", 0, 2)
                T.AS.manualprompt.ilvllabel:SetText(L[10026]..":")
                T.AS.manualprompt.ilvllabel:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE STACK OF 1
                B.I.Filters.CheckIgnoreStack.Create()

            ------ IGNORE STACK OF 1 LABEL
                T.AS.manualprompt.exactmatch.label = T.AS.manualprompt.exactmatch:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.manualprompt.exactmatch.label:SetJustifyH("LEFT")
                T.AS.manualprompt.exactmatch.label:SetPoint("LEFT", T.AS.manualprompt.icon, "LEFT")
                T.AS.manualprompt.exactmatch.label:SetPoint("TOP", T.AS.manualprompt.exactmatch, "TOP", 0, -5)
                T.AS.manualprompt.exactmatch.label:SetText(AH_EXACT_MATCH..":")
                T.AS.manualprompt.exactmatch.label:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE STACK OF 1 LABEL
                T.AS.manualprompt.stackone.label = T.AS.manualprompt.stackone:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                T.AS.manualprompt.stackone.label:SetJustifyH("LEFT")
                T.AS.manualprompt.stackone.label:SetPoint("LEFT", T.AS.manualprompt.icon, "LEFT")
                T.AS.manualprompt.stackone.label:SetPoint("TOP", T.AS.manualprompt.stackone, "TOP", 0, -5)
                T.AS.manualprompt.stackone.label:SetText(L[10069]..":")
                T.AS.manualprompt.stackone.label:SetTextColor(r, g, b) -- Aurora

            ------ NOTES
                B.I.Filters.Notes.Create()

            ------ NOTES LABEL
                T.AS.manualprompt.notes.label = T.AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                T.AS.manualprompt.notes.label:SetJustifyH("LEFT")
                T.AS.manualprompt.notes.label:SetPoint("BOTTOMLEFT", T.AS.manualprompt.notes.bg, "TOPLEFT", 0, 2)
                T.AS.manualprompt.notes.label:SetText(L[10052])
                T.AS.manualprompt.notes.label:SetTextColor(r, g, b) -- Aurora
    end

    B.I.Filters.Frame = {}
    function B.I.Filters.Frame.Create()

        T.AS.manualprompt = CreateFrame("Frame", "ASmanualpromptframe", T.AS.mainframe)
        T.AS.manualprompt:SetPoint("TOPLEFT", T.AS.mainframe, "TOPRIGHT", 3, 0)
        T.AS.manualprompt:SetHeight(150)  --some addons change font size, so this will be overridden in ASinitialize
        T.AS.manualprompt:SetWidth(200)
        T.AS.manualprompt:SetFrameStrata("DIALOG")
        T.AS.manualprompt:Hide()
        B.I.Backdrop(T.AS.manualprompt)
        T.AS.manualprompt:SetUserPlaced(true)

        T.AS.manualprompt:SetScript("OnMouseDown", B.I.Filters.Frame.MouseDown)
        T.AS.manualprompt:SetScript("OnMouseUp", B.I.Filters.Frame.MouseUp)
        T.AS.manualprompt:SetScript("OnShow", B.I.Filters.Frame.Show)
        T.AS.manualprompt:SetScript("OnHide", B.I.Filters.Frame.Hide)

        ------ CLOSE BUTTON
        T.AS.manualprompt.closebutton = B.I.Close.Create(T.AS.manualprompt)
        T.AS.manualprompt.closebutton:SetScript("OnClick", function(self) T.AS.manualprompt:Hide() end)
    end

    function B.I.Filters.Frame:MouseDown(...)

        self:StartMoving()
    end

    function B.I.Filters.Frame:MouseUp(...)

        self:StopMovingOrSizing()
    end

    function B.I.Filters.Frame:Show(...)

        T.AS.mainframe.headerframe.stopsearchbutton:Click()
        self.priceoverride:SetFocus()
    end

    function B.I.Filters.Frame:Hide(...)

        T.AS.manualprompt.upperstring:SetText("")
        T.AS.manualprompt.stackone:SetChecked(false)
        T.AS.manualprompt.exactmatch:SetChecked(false)
        T.AS.manualprompt.priceoverride:SetText("")
        T.AS.manualprompt.ilvlinput:SetText("")
        T.AS.manualprompt.notes:SetText("")
        T.AS.manualprompt.lowerstring:SetText("\n"..L[10038]..":\n")
        T.AS.manualprompt.ilvllabel:SetText(L[10026]..":\n")

        T.AS.manualprompt.icon:SetNormalTexture("")
        T.AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        T.AS.manualprompt.icon.link = nil
    end

    B.I.Filters.Icon = {}
    function B.I.Filters.Icon.Create()

        T.AS.manualprompt.icon = CreateFrame("Button", nil, T.AS.manualprompt)
        T.AS.manualprompt.icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        T.AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
        T.AS.manualprompt.icon:SetPoint("TOPLEFT", T.AS.manualprompt, "TOPLEFT", 18, -15)
        T.AS.manualprompt.icon:SetHeight(37)
        T.AS.manualprompt.icon:SetWidth(37)

        T.AS.manualprompt.icon:SetScript("OnEnter", B.I.Filters.Icon.Enter)
        T.AS.manualprompt.icon:SetScript("OnLeave", B.I.GameTooltip.Leave)
    end

    function B.I.Filters.Icon:Enter(...)

        local _, item = B.GetSelected()
        local link = item.link

        if link then
            --if (item.id and item.id > 0) then
            GameTooltip:SetOwner(AuctionFrameCloseButton, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", T.AS.manualprompt.icon, "TOPLEFT", -10, -20)
    
            -- Check the link type:   http://www.wowinterface.com/forums/archive/index.php/t-48939.html
            if strmatch(link, "|Hbattlepet:") then
                -- Battle pet link
                local _, speciesID, level, breedQuality, maxHealth, power, speed, name = strsplit(":", link)
                BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
            else
                -- Other kind of link, OK to use GameTooltip
                GameTooltip:SetHyperlink(link)
            end
    
            if (EnhTooltip) then
                EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
            end

            GameTooltip:Show()
        end
    end

    B.I.Filters.IgnoreButton = {}
    function B.I.Filters.IgnoreButton.Create()

        T.AS.manualprompt.ignorebutton = CreateFrame("Button", nil, T.AS.manualprompt, "UIPanelbuttontemplate")
        T.AS.manualprompt.ignorebutton:SetText(L[10039])
        T.AS.manualprompt.ignorebutton:SetWidth((T.AS.manualprompt:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE))
        T.AS.manualprompt.ignorebutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.manualprompt.ignorebutton:SetPoint("TOPLEFT", T.AS.manualprompt.lowerstring, "BOTTOMLEFT", 0, -110)

        T.AS.manualprompt.ignorebutton:SetScript("OnClick", B.I.Filters.IgnoreButton.Click)
        T.AS.manualprompt.ignorebutton:SetScript("OnEnter", B.I.Filters.IgnoreButton.Enter)
        T.AS.manualprompt.ignorebutton:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.Reskin(T.AS.manualprompt.ignorebutton) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.manualprompt.ignorebutton, "VERTICAL")
        end
    end

    function B.I.Filters.IgnoreButton:Click(...)

        local name = T.AS.item["ASmanualedit"].name
        local listnumber = T.AS.item['ASmanualedit'].listnumber
        
        if not T.AS.item[listnumber].ignoretable then
            T.AS.item[listnumber].ignoretable = {}
        end
        if not T.AS.item[listnumber].ignoretable[name] then
            T.AS.item[listnumber].ignoretable[name] = {}
        end

        T.AS.item[listnumber].ignoretable[name].cutoffprice = 0
        T.AS.item[listnumber].priceoverride = nil
        T.AS.item['ASmanualedit'] = nil
        B.SavedVariables()
        T.AS.manualprompt:Hide()
    end

    function B.I.Filters.IgnoreButton:Enter(...)

        B.showtooltip(self, L[10040])
    end

    B.I.Filters.SaveButton = {}
    function B.I.Filters.SaveButton.Create()

        T.AS.manualprompt.savebutton = CreateFrame("Button", nil, T.AS.manualprompt, "UIPanelbuttontemplate")
        T.AS.manualprompt.savebutton:SetText(L[10045])
        T.AS.manualprompt.savebutton:SetWidth((T.AS.manualprompt:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE))
        T.AS.manualprompt.savebutton:SetHeight(T.BUTTON_HEIGHT)
        T.AS.manualprompt.savebutton:SetPoint("LEFT", T.AS.manualprompt.ignorebutton, "RIGHT", 2, 0)

        T.AS.manualprompt.savebutton:SetScript("OnClick", B.I.Filters.SaveButton.Click)

        if T.SKIN then
            F.Reskin(T.AS.manualprompt.savebutton) -- Aurora
        else
            B.I.GradientButton.Create(T.AS.manualprompt.savebutton, "VERTICAL")
        end
    end

    function B.I.Filters.SaveButton:Click(...)

        local item = T.AS.item['ASmanualedit']
        local name = item.name
        local listnumber = item.listnumber

        -- Failsafe for ignoretable
        if not T.AS.item[listnumber].ignoretable then
            T.AS.item[listnumber].ignoretable = {}
        end
        if not T.AS.item[listnumber].ignoretable[name] then
            T.AS.item[listnumber].ignoretable[name] = {}
        end

        -- Price override
        if item.priceoverride then
            T.AS.item[listnumber].ignoretable[name].cutoffprice = item.priceoverride
        end
        -- iLvl filter
        if item.ilvl then
            if item.ilvl ~= "" then
                T.AS.item[listnumber].ignoretable[name].ilvl = tonumber(item.ilvl)
            else
                T.AS.item[listnumber].ignoretable[name].ilvl = nil
            end
        end
        -- Stack of one filter
        if item.stackone == false then
            T.AS.item[listnumber].ignoretable[name].stackone = nil
        else
            T.AS.item[listnumber].ignoretable[name].stackone = item.stackone
        end
        -- Exact match filter
        if item.exactmatch == false then
            T.AS.item[listnumber].ignoretable[name].exactmatch = nil
        else
            T.AS.item[listnumber].ignoretable[name].exactmatch = item.exactmatch
        end

        -- Notes
        if item.notes then
            if item.notes ~= "" then
                T.AS.item[listnumber].notes = item.notes
            else
                T.AS.item[listnumber].notes = nil
            end
        end

        T.AS.item[listnumber].priceoverride = nil
        T.AS.item['ASmanualedit'] = nil
        B.SavedVariables()
        T.AS.manualprompt:Hide()
    end

    B.I.Filters.InputCutoff = {}
    function B.I.Filters.InputCutoff.Create()

        T.AS.manualprompt.priceoverride = CreateFrame("EditBox", nil, T.AS.manualprompt, "InputBoxTemplate")
        T.AS.manualprompt.priceoverride:SetPoint("TOP", T.AS.manualprompt.lowerstring, "TOP", 0, -T.BUTTON_HEIGHT-7)
        T.AS.manualprompt.priceoverride:SetPoint("RIGHT", T.AS.manualprompt.savebutton, "RIGHT")
        T.AS.manualprompt.priceoverride:SetHeight(T.BUTTON_HEIGHT)
        T.AS.manualprompt.priceoverride:SetWidth(65)
        T.AS.manualprompt.priceoverride:SetNumeric(true)
        T.AS.manualprompt.priceoverride:SetAutoFocus(false)

        T.AS.manualprompt.priceoverride:SetScript("OnEnterPressed", B.I.Filters.InputCutoff.EnterPressed)
        T.AS.manualprompt.priceoverride:SetScript("OnTextChanged", B.I.Filters.InputCutoff.Text)
        T.AS.manualprompt.priceoverride:SetScript("OnEnter", B.I.Filters.InputCutoff.Enter)
        T.AS.manualprompt.priceoverride:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.ReskinInput(T.AS.manualprompt.priceoverride) -- Aurora
        else
            B.I.Input(T.AS.manualprompt.priceoverride)
        end
    end

    function B.I.Filters.InputCutoff:Enter(...)

        if ASsavedtable and ASsavedtable.copperoverride then
            B.showtooltip(self, L[10049])
        else
            B.showtooltip(self, L[10050])
        end
    end

    function B.I.Filters.InputCutoff:Text(...)

        local messagestring

        if self:GetText() == "" then
            T.AS.item["ASmanualedit"].priceoverride = nil
        elseif ASsavedtable and ASsavedtable.copperoverride then
            T.AS.item["ASmanualedit"].priceoverride = tonumber(self:GetText())
        else
            T.AS.item["ASmanualedit"].priceoverride = self:GetText() * COPPER_PER_GOLD
        end

        if T.AS.item["ASmanualedit"].priceoverride and (tonumber(T.AS.item["ASmanualedit"].priceoverride) > 0) then
            messagestring = "\n"..L[10038]..":\n"
            messagestring = messagestring..B.ASGSC(tonumber(T.AS.item["ASmanualedit"].priceoverride))
            T.AS.manualprompt.lowerstring:SetText(messagestring)
        end
    end

    function B.I.Filters.InputCutoff:EnterPressed(...)

        T.AS.manualprompt.savebutton:Click()
    end

    B.I.Filters.InputIlvl = {}
    function B.I.Filters.InputIlvl.Create()

        T.AS.manualprompt.ilvlinput = CreateFrame("EditBox", nil, T.AS.manualprompt, "InputBoxTemplate")
        T.AS.manualprompt.ilvlinput:SetPoint("TOPRIGHT", T.AS.manualprompt.priceoverride, "BOTTOMRIGHT", 0, -5)
        T.AS.manualprompt.ilvlinput:SetHeight(T.BUTTON_HEIGHT)
        T.AS.manualprompt.ilvlinput:SetWidth(65)
        T.AS.manualprompt.ilvlinput:SetNumeric(true)
        T.AS.manualprompt.ilvlinput:SetAutoFocus(false)

        T.AS.manualprompt.ilvlinput:SetScript("OnEnterPressed", B.I.Filters.InputIlvl.EnterPressed)
        T.AS.manualprompt.ilvlinput:SetScript("OnTextChanged", B.I.Filters.InputIlvl.Text)
        T.AS.manualprompt.ilvlinput:SetScript("OnEnter", B.I.Filters.InputIlvl.Enter)
        T.AS.manualprompt.ilvlinput:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.ReskinInput(T.AS.manualprompt.ilvlinput) -- Aurora
        else
            B.I.Input(T.AS.manualprompt.ilvlinput)
        end
    end

    function B.I.Filters.InputIlvl:EnterPressed(...)

        T.AS.manualprompt.savebutton:Click()
    end

    function B.I.Filters.InputIlvl:Text(userInput)

        local messagestring

        if userInput then
            T.AS.item["ASmanualedit"].ilvl = T.AS.manualprompt.ilvlinput:GetText()
            messagestring = L[10026]..":\n"
            messagestring = messagestring.."|cffffffff"..T.AS.item["ASmanualedit"].ilvl
            T.AS.manualprompt.ilvllabel:SetText(messagestring)
        end
    end

    function B.I.Filters.InputIlvl:Enter(...)

        B.showtooltip(self, L[10051])
    end

    B.I.Filters.ExactMatch = {}
    function B.I.Filters.ExactMatch.Create()

        T.AS.manualprompt.exactmatch = CreateFrame("CheckButton", "AOexactmatch", T.AS.manualprompt, "OptionsCheckButtonTemplate")
        T.AS.manualprompt.exactmatch:SetPoint("TOPRIGHT", T.AS.manualprompt.ilvlinput, "BOTTOMRIGHT", 0, -5)

        T.AS.manualprompt.exactmatch:SetScript("OnClick", B.I.Filters.ExactMatch.Click)
        T.AS.manualprompt.exactmatch:SetScript("OnEnter", B.I.Filters.ExactMatch.Enter)
        T.AS.manualprompt.exactmatch:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then F.ReskinCheck(T.AS.manualprompt.exactmatch) end
    end

    function B.I.Filters.ExactMatch:Click(...)

        T.AS.item['ASmanualedit'].exactmatch = self:GetChecked()
    end

    function B.I.Filters.ExactMatch:Enter(...)

        B.showtooltip(self, AH_EXACT_MATCH_TOOLTIP)
    end

    B.I.Filters.CheckIgnoreStack = {}
    function B.I.Filters.CheckIgnoreStack.Create()

        T.AS.manualprompt.stackone = CreateFrame("CheckButton", "AOstackone", T.AS.manualprompt, "OptionsCheckButtonTemplate")
        T.AS.manualprompt.stackone:SetPoint("TOPRIGHT", T.AS.manualprompt.exactmatch, "BOTTOMRIGHT", 0, -3)

        T.AS.manualprompt.stackone:SetScript("OnClick", B.I.Filters.CheckIgnoreStack.Click)
        T.AS.manualprompt.stackone:SetScript("OnEnter", B.I.Filters.CheckIgnoreStack.Enter)
        T.AS.manualprompt.stackone:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then F.ReskinCheck(T.AS.manualprompt.stackone) end
    end

    function B.I.Filters.CheckIgnoreStack:Click(...)

        if self:GetChecked() then
            T.AS.item['ASmanualedit'].stackone = true
        else
            T.AS.item['ASmanualedit'].stackone = false
        end
    end

    function B.I.Filters.CheckIgnoreStack:Enter(...)

        B.showtooltip(self, L[10068])
    end

    B.I.Filters.Notes = {}
    function B.I.Filters.Notes.Create()

        T.AS.manualprompt.notes = CreateFrame("EditBox", "ASnotes", T.AS.manualprompt)
        T.AS.manualprompt.notes:SetFontObject("ChatFontNormal")
        T.AS.manualprompt.notes:SetWidth(500)
        T.AS.manualprompt.notes:SetMultiLine(true)
        T.AS.manualprompt.notes:SetAutoFocus(false)

        T.AS.manualprompt.notes:SetScript("OnTextChanged", B.I.Filters.Notes.Text)
        
        -------------- SCROLLBAR ----------------
        T.AS.manualprompt.notes.scroll = CreateFrame('ScrollFrame', nil, T.AS.manualprompt, 'UIPanelScrollFrameTemplate')
        T.AS.manualprompt.notes.scroll:SetPoint("TOPLEFT", T.AS.manualprompt.ignorebutton, "BOTTOMLEFT", 2, -20)
        T.AS.manualprompt.notes.scroll:SetPoint("TOPRIGHT", T.AS.manualprompt.savebutton, "BOTTOMRIGHT", -5, -15)
        T.AS.manualprompt.notes.scroll:SetPoint("BOTTOMRIGHT", T.AS.manualprompt, "BOTTOMRIGHT", 0, 15)

        if T.SKIN then
            F.ReskinScroll(T.AS.manualprompt.notes.scroll.ScrollBar)
        end
        T.AS.manualprompt.notes.scroll:SetScrollChild(T.AS.manualprompt.notes)
        
        -------------- FAKE BACKDROP ----------------
        T.AS.manualprompt.notes.bg = CreateFrame("EditBox", nil, T.AS.manualprompt, "InputBoxTemplate")
        T.AS.manualprompt.notes.bg:SetPoint("TOPLEFT", T.AS.manualprompt.ignorebutton, "BOTTOMLEFT", 2, -20)
        T.AS.manualprompt.notes.bg:SetPoint("TOPRIGHT", T.AS.manualprompt.savebutton, "BOTTOMRIGHT", 0, -20)
        T.AS.manualprompt.notes.bg:SetPoint("BOTTOMRIGHT", T.AS.manualprompt, "BOTTOMRIGHT", 0, 15)
        T.AS.manualprompt.notes.bg:SetAutoFocus(false)
        -------------- SCRIPT ----------------
        T.AS.manualprompt.notes.bg:SetScript("OnEditFocusGained", function(self) T.AS.manualprompt.notes:SetFocus() end)

        if T.SKIN then
            F.ReskinInput(T.AS.manualprompt.notes.bg) -- Aurora
        else
            B.I.Input(T.AS.manualprompt.notes.bg)
        end
    end

    function B.I.Filters.Notes:Text(...)

        T.AS.item['ASmanualedit'].notes = self:GetText()
    end


--[[//////////////////////////////////////////////////

    INTERFACE HELPER FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    B.I.Close = {}
    function B.I.Close.Create(parent)
        local button

        if T.SKIN then
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
            B.I.GradientButton.Create(button, "VERTICAL")
        end

        return button
    end

    B.I.Button = {}
    function B.I.Button.Create(parent, name, tooltip)

        local buttonwidth = (parent:GetWidth() / 2) - (2 * T.FRAMEWHITESPACE)
        local button = CreateFrame("Button", nil, parent, "UIPanelbuttontemplate")

        button:SetText(name)
        button:SetWidth(buttonwidth)
        button:SetHeight(T.BUTTON_HEIGHT)
        button.tooltip = tooltip

        button:SetScript("OnClick", T.AS[name])
        button:SetScript("OnEnter", B.I.Button.Enter)
        button:SetScript("OnLeave", B.hidetooltip)

        if T.SKIN then
            F.Reskin(button) -- Aurora
        else
            B.I.GradientButton.Create(button, "VERTICAL")
        end

        return button
    end

    function B.I.Button:Enter(...)

        B.showtooltip(self, self.tooltip)
    end

    B.I.GradientButton = {}
    function B.I.GradientButton.Create(button, orientation)

        button:SetNormalTexture("")
        button:SetHighlightTexture("")
        button:SetPushedTexture("")
        button:SetDisabledTexture("")

        B.RemoveEdge(button)

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

        button:HookScript("OnEnter", B.I.GradientButton.Enter)
        button:HookScript("OnLeave", B.I.GradientButton.Leave)
    end

    function B.I.GradientButton:Enter(...)

        self:SetBackdropBorderColor(r, g, b, 1)
    end

    function B.I.GradientButton:Leave(...)

        self:SetBackdropBorderColor(0, 0, 0, 1)
    end

    B.I.PrevButton = {}
    function B.I.PrevButton.Create(frame)

        local button = CreateFrame("Button", nil, frame)
        
        button:SetWidth(24)
        button:SetHeight(24)
        button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
        button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
        button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
        button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        button:Disable()

        if T.SKIN then F.ReskinArrow(button, "left") end -- Aurora

        return button
    end

    B.I.NextButton = {}
    function B.I.NextButton.Create(frame)

        local button = CreateFrame("Button", nil, frame)
        
        button:SetWidth(24)
        button:SetHeight(24)
        button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
        button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
        button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
        button:Disable()

        if T.SKIN then F.ReskinArrow(button, "right") end -- Aurora

        return button
    end

    function B.I.Backdrop(frame)

        if T.SKIN then -- Aurora
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

    function B.I.Input(editbox)

        editbox:SetTextColor(1, 1, 1)
        editbox:SetTextInsets(5, 0, 0, 0)

        B.RemoveEdge(editbox)
        
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

    function B.I.List.Button(index, parent)

        local button = CreateFrame("Button", nil, parent)

        button.buttonnumber = index
        button:SetHeight(T.BUTTON_HEIGHT)
        button:SetWidth(T.AS.mainframe:GetWidth() - 58)
        button:SetPoint("TOP")
        button:SetMovable(true)

        local normal = button:CreateTexture(nil, "BACKGROUND")

        normal:SetHeight(T.BUTTON_HEIGHT)
        normal:SetPoint("LEFT", 30, 0)
        normal:SetPoint("RIGHT", -12, 0)
        normal:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
        normal:SetTexCoord(.75, .75, 0, 0.5)
        button:SetNormalTexture(normal)

        local highlight = button:CreateTexture(nil, "HIGHLIGHT")

        highlight:SetHeight(T.BUTTON_HEIGHT-1)
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

    B.I.List.Icon = {}
    function B.I.List.Icon.Create(parent)

        local icon = CreateFrame("Button", nil, parent)

        icon:SetWidth(T.BUTTON_HEIGHT)
        icon:SetHeight(T.BUTTON_HEIGHT)
        icon:SetPoint("TOPLEFT")
        icon:SetNormalTexture("Interface\\AddOns\\AuctionSnatch\\media\\gloss")
        icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
        icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

        icon:SetScript("OnEnter", B.I.List.Icon.Enter)
        icon:SetScript("OnLeave", B.I.List.Icon.Leave)
        
        return icon
    end

    function B.I.List.Icon:Enter(...)

        if AOicontooltip and self.link then

            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -20)

            if strmatch(self.link, "|Hbattlepet:") then
                -- Battle pet link
                local _, speciesID, level, breedQuality, maxHealth, power, speed, name = strsplit(":", self.link)
                BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed), name)
            else
                GameTooltip:SetHyperlink(self.link)
            end

            GameTooltip:Show()
        end
    end

    function B.I.List.Icon:Leave(...)

        GameTooltip:Hide()
    end

    function B.I.List.ScrollFrame(parent, name, onUpdate, buttons)

        local scrollframe = B.I.List.Scroll.Create(parent, name, onUpdate)
        local i, currentrow, previousrow

        parent.itembuttons = {}

        for i = 1, B.rowsthatcanfit() do

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

    B.I.List.Scroll = {}
    function B.I.List.Scroll.Create(parent, name, onUpdate)

        --[[note the anchors: the area of the scrollframe is the scrollable area
            that intercepts mousewheel to scroll. it does not include the scrollbar,
            which is anchored off the right ]]

        local scroll = CreateFrame("ScrollFrame", name, parent, "FauxScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", T.AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
        scroll:SetPoint("BOTTOMRIGHT", T.AS.mainframe, "BOTTOMRIGHT", -40, 38)
        scroll.onUpdate = onUpdate

        scroll:SetScript("OnShow", onUpdate)
        scroll:SetScript("OnVerticalScroll", B.I.List.Scroll.VerticalScroll)

        if T.SKIN then F.ReskinScroll(scroll.ScrollBar) end -- Aurora

        return scroll
    end

    function B.I.List.Scroll:VerticalScroll(offset)

        FauxScrollFrame_OnVerticalScroll(self, offset, T.BUTTON_HEIGHT, self.onUpdate)
    end

    B.I.GameTooltip = {}
    function B.I.GameTooltip:Leave(...)

        GameTooltip:Hide()
    end

    function B.RemoveEdge(frame)

        local name = frame:GetName()
        local left = frame.Left or name and _G[name.."Left"] or nil
        local middle = frame.Middle or name and (_G[name.."Middle"] or _G[name.."Mid"]) or nil
        local right = frame.Right or name and _G[name.."Right"] or nil

        if left then left:Hide() end
        if middle then middle:Hide() end
        if right then right:Hide() end
    end

    function B.CreateAuctionTab() -- Move

        if AuctionFrame then
            -------------- STYLE ----------------
                ASauctiontab = CreateFrame("Button", "ASauctiontab", AuctionFrame, "AuctionTabTemplate")
                ASauctiontab:SetText("AS")
                PanelTemplates_TabResize(ASauctiontab, 50, 70, 70);
                PanelTemplates_DeselectTab(ASauctiontab)
            -------------- SCRIPT ----------------
                ASauctiontab:SetScript("OnClick", function()
                    if T.AS.mainframe:IsShown() then
                        T.AS.mainframe:Hide()
                    else
                        ASopenedwithah = true
                        if ASsavedtable.ASautostart then
                            T.AS.status = T.STATE.QUERYING
                        end
                        B.Main()
                    end
                end)
                if T.SKIN then F.ReskinTab(ASauctiontab) end -- Aurora

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
                B.RegisterCancelAction()
                B.RegisterSearchAction()
            end)
        end
    end
