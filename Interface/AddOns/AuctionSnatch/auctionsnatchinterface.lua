
local F, C = unpack(Aurora) -- Aurora
local r, g, b = C.r, C.g, C.b -- Aurora

--[[//////////////////////////////////////////////////

    MAIN INTERFACE FUNCTIONS

    AS_CreateMainFrame, AS_CreateListButton,
    AS_CreateAuctionTab

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    function AS_CreateMainFrame()

        ----- MAIN FRAME
            -------------- STYLE ----------------
                AS.mainframe = CreateFrame("Frame", "ASmainframe", UIParent)
                AS.mainframe:SetPoint("RIGHT", 0, 0) -- TODO: Can we anchor to the auction house?
                AS.mainframe:SetHeight(AS_GROSSHEIGHT + 8)
                AS.mainframe:SetWidth(280)
                AS.mainframe:Hide()
                AS.mainframe:SetBackdrop({  bgFile = "Interface/Tooltips/UI-Background",
                                            edgeFile = nil,
                                            tile = true, tileSize = 32, edgeSize = 32,
                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }
                })
                AS.mainframe:SetBackdropColor(0, 0, 0, 0.85)
                AS.mainframe:SetMovable(true)
                AS.mainframe:EnableMouse(true)
            -------------- SCRIPT ----------------
                AS.mainframe:SetScript("OnMouseDown", function(self)
                    AS.mainframe:StartMoving()
                end)
                AS.mainframe:SetScript("OnMouseUp", function(self)
                    AS.mainframe:StopMovingOrSizing()
                end)
                AS.mainframe:SetScript("OnShow", function(self)
                    AS.mainframe:SetFrameStrata(AuctionFrameBrowse:GetFrameStrata())
                end)
                AS.mainframe:SetScript("OnHide", function (self)
                    AS.mainframe.headerframe.stopsearchbutton:Click()
                end)

        ------ CLOSE BUTTON
            -------------- STYLE ----------------
                AS.mainframe.closebutton = CreateFrame("button", nil, AS.mainframe)
                AS.mainframe.closebutton:SetWidth(14)
                AS.mainframe.closebutton:SetHeight(14)
                AS.mainframe.closebutton:SetPoint("TOPRIGHT", AS.mainframe, "TOPRIGHT")
            -------------- SCRIPT ----------------
                AS.mainframe.closebutton:SetScript("OnClick", function(self)
                    AS.mainframe:Hide()
                    if AS.prompt then
                        AS.prompt:Hide()
                    end
                    if AS.manualprompt then
                        AS.manualprompt:Hide()
                    end
                end)

                F.ReskinClose(AS.mainframe.closebutton) -- Aurora

        ----------------------------------------------------------
        ---------------------------------------------------------
        -- Ive decided to make 2 frames within our main frame.
        -- A Header Frame, that holds sorting options/editboxes
        -- and a List frame, that contains the list of items
        ---------------------------------------------------------
        ----------------------------------------------------------

        ------ HEADER FRAME
            -------------- STYLE ----------------
                AS.mainframe.headerframe = CreateFrame("Frame", nil, AS.mainframe)
                AS.mainframe.headerframe:SetPoint("TOPLEFT")
                AS.mainframe.headerframe:SetPoint("RIGHT")
                AS.mainframe.headerframe:SetHeight(AS_HEADERHEIGHT)

            ------ LIST LABEL
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.listlabel = AS.mainframe.headerframe:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.mainframe.headerframe.listlabel:SetJustifyH("CENTER")
                    AS.mainframe.headerframe.listlabel:SetPoint("TOP", AS.mainframe.headerframe, "TOP", 0, -12)

            ------ START BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.startsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
                    AS.mainframe.headerframe.startsearchbutton:SetText(AS_START)
                    AS.mainframe.headerframe.startsearchbutton:SetWidth(100)
                    AS.mainframe.headerframe.startsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.mainframe.headerframe.startsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe, "TOPLEFT", 17, -45)
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.startsearchbutton:SetScript("OnClick", function(self)
                        if AS.manualprompt then
                            AS.manualprompt:Hide()
                        end
                        if AuctionFrame and AuctionFrame:IsVisible() then
                            AuctionFrameTab1:Click()  -- Focus on search tab
                            if AuctionFrameBrowse:IsVisible() then
                                
                                if not IsShiftKeyDown() then
                                    AScurrentauctionsnatchitem = 1
                                end
                                AS.status = STATE.QUERYING
                                AS.mainframe.headerframe.stopsearchbutton:Enable()
                                return
                            end
                        end
                        ASprint(MSG_C.ERROR.."Auction window is not visible")
                    end)
                    AS.mainframe.headerframe.startsearchbutton:SetScript("OnEnter", function(self)
                        tooltip = "Start the search from the top of your list (You can hold 'shift' to continue where you left off from last scan)"
                        ASshowtooltip( AS.mainframe.headerframe.startsearchbutton,tooltip)
                    end)
                    AS.mainframe.headerframe.startsearchbutton:SetScript("OnLeave", function(self)
                        AShidetooltip()
                    end)

                    F.Reskin(AS.mainframe.headerframe.startsearchbutton) -- Aurora

            ------ STOP BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.stopsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
                    AS.mainframe.headerframe.stopsearchbutton:SetText(AS_STOP)
                    AS.mainframe.headerframe.stopsearchbutton:SetWidth(50)
                    AS.mainframe.headerframe.stopsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.mainframe.headerframe.stopsearchbutton:Disable()
                    AS.mainframe.headerframe.stopsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.startsearchbutton,"TOPRIGHT", 2, 0)
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnClick", function(self)
                        AS.mainframe.headerframe.stopsearchbutton:Disable()
                        AS.prompt:Hide()

                        AScurrentahresult = 0
                        AS.status = nil
                        AS.status_override = nil
                        -- set default AH sort (could not achieve the same result using API)
                        AuctionFrame_SetSort("list", "quality", false)
                    end)
                    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnEnter", function(self)
                        tooltip = "Stop the current search. It can be resumed by shift-clicking Start Search."
                        ASshowtooltip(AS.mainframe.headerframe.stopsearchbutton, tooltip)
                    end)
                    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnLeave", function(self)
                        AShidetooltip()
                    end)

                    F.Reskin(AS.mainframe.headerframe.stopsearchbutton) -- Aurora

            ------ INPUT SEARCH BOX
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.editbox = CreateFrame("EditBox", nil, AS.mainframe.headerframe, "InputBoxTemplate")
                    AS.mainframe.headerframe.editbox:SetPoint("BOTTOMLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 27, 15)
                    AS.mainframe.headerframe.editbox:SetHeight(AS_BUTTON_HEIGHT)
                    AS.mainframe.headerframe.editbox:SetWidth(AS.mainframe.headerframe:GetWidth()-76)
                    AS.mainframe.headerframe.editbox:SetAutoFocus(false)
                    AS.mainframe.headerframe.editbox:SetToplevel(true)
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.editbox:SetScript("OnEscapePressed", function(self)
                        AS.mainframe.headerframe.editbox:ClearFocus()
                    end)
                    AS.mainframe.headerframe.editbox:SetScript("OnEnterPressed", function(self)
                        AS.mainframe.headerframe.additembutton:Click()
                    end)

                    F.ReskinInput(AS.mainframe.headerframe.editbox) -- Aurora

            ------ ADD ITEM BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.additembutton = CreateFrame("Button", nil, AS.mainframe.headerframe,"UIPanelbuttontemplate")
                    AS.mainframe.headerframe.additembutton:SetText("+")
                    AS.mainframe.headerframe.additembutton:SetWidth(30)
                    AS.mainframe.headerframe.additembutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.mainframe.headerframe.additembutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.editbox, "TOPRIGHT", 2, 0)
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.additembutton:SetScript("OnClick", AS_AddItem)
                    
                    F.Reskin(AS.mainframe.headerframe.additembutton) -- Aurora

            ------ DELETE BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.deletelistbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelbuttontemplate")
                    AS.mainframe.headerframe.deletelistbutton:SetText("Delete List")
                    AS.mainframe.headerframe.deletelistbutton:SetWidth(90)
                    AS.mainframe.headerframe.deletelistbutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.mainframe.headerframe.deletelistbutton:SetPoint("BOTTOMLEFT", AS.mainframe,"BOTTOMLEFT", 17, 3)
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.deletelistbutton:SetScript("OnClick", function(self)
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
                    end)
                    AS.mainframe.headerframe.deletelistbutton:SetScript("OnEnter", function(self)
                        ASshowtooltip(AS.mainframe.headerframe.deletelistbutton, AS_DELETETEXT)
                    end)
                    AS.mainframe.headerframe.deletelistbutton:SetScript("OnLeave", function(self)
                        AShidetooltip()
                    end)

                    F.Reskin(AS.mainframe.headerframe.deletelistbutton) -- Aurora

            ------ PREV BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.prevlist = CreateFrame("Button", nil, AS.mainframe.headerframe)
                    AS.mainframe.headerframe.prevlist:SetWidth(24)
                    AS.mainframe.headerframe.prevlist:SetHeight(24)
                    AS.mainframe.headerframe.prevlist:SetPoint("LEFT", AS.mainframe.headerframe.stopsearchbutton,"RIGHT", 10, 0)
                    AS.mainframe.headerframe.prevlist:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
                    AS.mainframe.headerframe.prevlist:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
                    AS.mainframe.headerframe.prevlist:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
                    AS.mainframe.headerframe.prevlist:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    AS.mainframe.headerframe.prevlist:Disable()
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.prevlist:SetScript("OnClick", function()
                        if ASsavedtable then
                            local current = I_LISTNAMES[ACTIVE_TABLE]
                            if LISTNAMES[current - 1] == nil then -- Go to the end
                                AS_SwitchTable(LISTNAMES[table.maxn(LISTNAMES)])
                            else
                                AS_SwitchTable(LISTNAMES[current - 1])
                            end
                        end
                    end)
                    F.ReskinArrow(AS.mainframe.headerframe.prevlist, "left") -- Aurora

            ------ NEXT BUTTON
                -------------- STYLE ----------------
                    AS.mainframe.headerframe.nextlist = CreateFrame("Button", nil, AS.mainframe.headerframe)
                    AS.mainframe.headerframe.nextlist:SetWidth(24)
                    AS.mainframe.headerframe.nextlist:SetHeight(24)
                    AS.mainframe.headerframe.nextlist:SetPoint("LEFT", AS.mainframe.headerframe.prevlist,"RIGHT", 7, 0)
                    AS.mainframe.headerframe.nextlist:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
                    AS.mainframe.headerframe.nextlist:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
                    AS.mainframe.headerframe.nextlist:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
                    AS.mainframe.headerframe.nextlist:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                    AS.mainframe.headerframe.nextlist:Disable()
                -------------- SCRIPT ----------------
                    AS.mainframe.headerframe.nextlist:SetScript("OnClick", function()
                        if ASsavedtable then
                            local current = I_LISTNAMES[ACTIVE_TABLE]
                            if LISTNAMES[current + 1] == nil then -- Go back to beginning
                                AS_SwitchTable(LISTNAMES[1])
                            else
                                AS_SwitchTable(LISTNAMES[current + 1])
                            end
                        end
                    end)
                    F.ReskinArrow(AS.mainframe.headerframe.nextlist, "right") -- Aurora


        ------ LIST FRAME
            -------------- STYLE ----------------
                AS.mainframe.listframe = CreateFrame("Frame", "FauxScrollFrameTest", AS.mainframe)
                AS.mainframe.listframe:SetPoint("TOPLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
                AS.mainframe.listframe:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", 0, 10)

            ------ SCROLL FRAME
                -------------- STYLE ----------------
                    AS.mainframe.listframe.scrollFrame = CreateFrame("ScrollFrame", "AS_scrollframe", AS.mainframe.listframe, "FauxScrollFrameTemplate")
                    -- note the anchors: the area of the scrollframe is the scrollable area
                    -- (that intercepts mousewheel to scroll). it does not include the scrollbar,
                    -- which is anchored off the right
                    AS.mainframe.listframe.scrollFrame:SetPoint("TOPLEFT", AS.mainframe.headerframe, "BOTTOMLEFT", 0, 6)
                    AS.mainframe.listframe.scrollFrame:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", -40, 38)
                -------------- SCRIPT ----------------
                    AS.mainframe.listframe.scrollFrame:SetScript("OnShow", AS_ScrollbarUpdate)
                    AS.mainframe.listframe.scrollFrame:SetScript("OnVerticalScroll", function(self, offset)
                        FauxScrollFrame_OnVerticalScroll(self, offset, 20, AS_ScrollbarUpdate)
                    end)

                    F.ReskinScroll(AS.mainframe.listframe.scrollFrame.ScrollBar) -- Aurora

            ------ LIST OF BUTTONS
                local currentrow, previousrow
                AS.mainframe.listframe['itembutton'] = {}

                for i = 1, ASrowsthatcanfit() do

                    AS.mainframe.listframe.itembutton[i] = AS_CreateListButton(i)
                    currentrow = AS.mainframe.listframe.itembutton[i]
                    if i == 1 then
                        currentrow:SetPoint("TOP")
                    else
                        currentrow:SetPoint("TOP", previousrow, "BOTTOM")
                    end
                    currentrow:Show()
                    previousrow = currentrow
                end

        ------ DROPDOWN MENU
            -------------- STYLE ----------------
                ASdropDownMenu = CreateFrame("Frame", "ASdropDownMenu", AS.mainframe, "UIDropDownMenuTemplate")
                UIDropDownMenu_SetWidth(ASdropDownMenu, 130, 4)
                ASdropDownMenu:SetPoint("TOPLEFT", AS.mainframe.headerframe.deletelistbutton, "TOPRIGHT", -8, 4)
                UIDropDownMenu_Initialize(ASdropDownMenu, ASdropDownMenu_Initialize) --The virtual
                F.ReskinDropDown(ASdropDownMenu) -- Aurora

        ------ DROPDOWN MENU LABEL
            -------------- STYLE ----------------
                ASdropdownmenubutton = CreateFrame("Button", nil, ASdropDownMenu)
                ASdropdownmenubutton:SetText(AS_IMPORT)
                ASdropdownmenubutton:SetNormalFontObject("GameFontNormal")
                ASdropdownmenubutton:SetPoint("CENTER", ASdropDownMenu, "CENTER", -7, 1)
                ASdropdownmenubutton:SetWidth(80)
                ASdropdownmenubutton:SetHeight(34)
            -------------- SCRIPT ----------------
                ASdropdownmenubutton:SetScript("OnClick", function(self)
                    ASdropDownMenuButton:Click()
                end)

        AS_CreateOptionFrame()
    end

    function AS_CreateListButton(i)

        ------ LIST BUTTON
            -------------- STYLE ----------------
                local button_tmp = CreateFrame("Button", nil, AS.mainframe.listframe)
                button_tmp:SetHeight(AS_BUTTON_HEIGHT)
                button_tmp:SetWidth(AS.mainframe:GetWidth() - 58)
                button_tmp:SetPoint("TOP")
                button_tmp.buttonnumber = i
                button_tmp:SetMovable(true)
                -- Create button texture
                local normal_tex = button_tmp:CreateTexture()
                normal_tex:SetHeight(AS_BUTTON_HEIGHT)
                normal_tex:SetPoint("left",30,0)
                normal_tex:SetPoint("right",-12,0)
                normal_tex:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
                normal_tex:SetTexCoord(.75,.75,0,0.5)
                button_tmp:SetNormalTexture(normal_tex)
                -- Create button highlight
                local high_tex = button_tmp:CreateTexture()
                high_tex:SetHeight(AS_BUTTON_HEIGHT-1)
                high_tex:SetPoint("LEFT", normal_tex, 0, -1)
                high_tex:SetPoint("RIGHT",normal_tex)
                high_tex:SetTexture(C.media.backdrop) -- Aurora
                high_tex:SetVertexColor(0.945, 0.847, 0.152,0.3)
                button_tmp:SetHighlightTexture(high_tex)
            -------------- SCRIPT ----------------
                button_tmp:SetScript("OnMouseDown", function(self) -- compensate for scroll bar
                    ASorignumber = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                end)
                button_tmp:SetScript("OnClick", function(self, button, down)
                    ASprint("CLeeekkk!")
                    current_scroll = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)

                    if AS.optionframe:IsVisible() then
                        AS.optionframe:Hide()
                    end
                    if IsShiftKeyDown() then
                        if AS.item[current_scroll].link then
                            AS.mainframe.headerframe.editbox:SetText(AS.item[current_scroll].link)
                        else
                            AS.mainframe.headerframe.editbox:SetText(AS.item[current_scroll].name)
                        end
                    else
                        AS.item['LastListButtonClicked'] = current_scroll
                        AS.optionframe:SetParent(self)
                        AS.optionframe:SetPoint("TOP", self, "BOTTOMRIGHT")
                        AS.optionframe:Show()
                    end
                end)
                button_tmp:SetScript("OnMouseUp", function(self, button)
                    
                    if button == "RightButton" then
                        if AuctionFrame and AuctionFrame:IsVisible() then
                            
                            AuctionFrameTab1:Click() -- Focus on search tab
                            AS.prompt:Hide()
                            AuctionFrameBrowse.page = 0
                            
                            AS.item['LastListButtonClicked'] = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                            AScurrentauctionsnatchitem = self.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                            AS.status = STATE.QUERYING
                            AS.status_override = true
                            return
                        end
                        ASprint(MSG_C.ERROR.."Auction house is not visible")
                    else
                        AS_MoveListButton(ASorignumber)
                        AS_ScrollbarUpdate()
                    end
                end)
                button_tmp:SetScript("OnEnter", function(self)
                    local scrollvalue = FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                    local idx = AS.item[self.buttonnumber + scrollvalue]

                    strmsg = AS_INFO

                    if idx.ignoretable and idx.ignoretable[idx.name] then
                        if idx.ignoretable[idx.name].cutoffprice > 0 then
                            strmsg = strmsg.."\nCutoff price: "..ASGSC(tonumber(idx.ignoretable[idx.name].cutoffprice))
                        else
                            strmsg = strmsg.."\n"..AS_IGNORECONDITIONS..": "
                            strmsg = strmsg.."|cff9d9d9d"..AS_ALWAYS.."|r"
                        end
                    end

                    if idx.notes then
                        strmsg = strmsg.."|cff888888\n\n---------------------|r\n"..idx.notes
                    end
                    if idx.sellbid or idx.sellbuyout then
                        strmsg = strmsg.."|cff888888\n\n---------------------|r"
                        if idx.sellbid then
                            strmsg = strmsg.."\nBid price (unit): "..ASGSC(idx.sellbid)
                        end
                        if idx.sellbuyout and idx.sellbuyout > 0 then
                            strmsg = strmsg.."\nBuyout price (unit): "..ASGSC(idx.sellbuyout)
                        end
                    end
                    ASshowtooltip(self, strmsg)
                end)
                button_tmp:SetScript("OnLeave", AShidetooltip)
                button_tmp:SetScript("OnDoubleClick", function(self)
                    BrowseResetButton:Click()
                    AuctionFrameBrowse.page = 0
                    BrowseName:SetText(ASsanitize(self.leftstring:GetText()))
                    AuctionFrameBrowse_Search()
                end)

        ------ BUTTON LABEL
            -------------- STYLE ----------------
                button_tmp.leftstring = button_tmp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                button_tmp.leftstring:SetJustifyH("LEFT")
                button_tmp.leftstring:SetJustifyV("CENTER")
                button_tmp.leftstring:SetWordWrap(false)
                button_tmp.leftstring:SetPoint("LEFT", normal_tex,"LEFT", 10, 0)
                button_tmp.leftstring:SetPoint("RIGHT", normal_tex,"RIGHT", -2, 0)

        ------ BUTTON ICON
            -------------- STYLE ----------------
                button_tmp.icon = CreateFrame("Button", nil, button_tmp)
                button_tmp.icon:SetWidth(AS_BUTTON_HEIGHT)
                button_tmp.icon:SetHeight(AS_BUTTON_HEIGHT)
                button_tmp.icon:SetPoint("TOPLEFT")
                button_tmp.icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
                button_tmp.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
                button_tmp.icon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)
            -------------- SCRIPT ----------------
                button_tmp.icon:SetScript("OnEnter", function(self)
                    if button_tmp.link then
                        local link = button_tmp.link
                        GameTooltip:SetOwner(self, "ANCHOR_NONE")
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:ClearAllPoints()
                        GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -20)
                        GameTooltip:Show()
                    end
                end)
                button_tmp.icon:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)

       return button_tmp
    end

    function AS_CreateAuctionTab()

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
                F.ReskinTab(ASauctiontab) -- Aurora

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
        end
    end

--[[//////////////////////////////////////////////////

    OPTION FRAME FUNCTIONS

    AS_CreateOptionFrame, AS_ResetIgnore,
    AS_ManualIgnore, AS_DeleteRow

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_CreateOptionFrame(self)

        ------ OPTION FRAME
            -------------- STYLE ----------------
                AS.optionframe = CreateFrame("Frame", "ASoptionframe", UIParent)
                AS.optionframe:SetHeight((AS_BUTTON_HEIGHT * 7) + (AS_FRAMEWHITESPACE * 2))  --7 buttons
                AS.optionframe:SetWidth(200)
                AS.optionframe:SetBackdrop({    bgFile = C.media.backdrop, -- Aurora
                                                edgeFile = C.media.backdrop, -- Aurora
                                                tile = true, tileSize = 32, edgeSize = 1,
                                                insets = { left = 0, right = 0, top = 0, bottom = 1}
                })
                AS.optionframe:SetBackdropColor(0, 0, 0, 0.8)
                AS.optionframe:SetBackdropBorderColor(1, 1, 1, 0.2)
                AS.optionframe:SetToplevel(true)
                AS.optionframe:EnableMouse(true)
            -------------- SCRIPT ----------------
                AS.optionframe:SetScript("OnLeave", function(self) -- TODO: To review
                    --AS.optionframe:Hide()--bah doesnt work right
                    local x,y = GetCursorScaledPosition()
                    --ASprint("Cursor x,y="..x..","..y.."  Left, right, bottom, top="..AS.optionframe:GetLeft()..","..AS.optionframe:GetRight()..","..AS.optionframe:GetBottom()..","..AS.optionframe:GetTop())
                    if(x < AS.optionframe:GetLeft() or x > AS.optionframe:GetRight() or y < AS.optionframe:GetBottom() or y > AS.optionframe:GetTop()) then
                        AS.optionframe:Hide()
                    end
                end)

        ------ SELL ITEM
            -------------- STYLE ----------------
                AS.optionframe.sellbutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.sellbutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.sellbutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.sellbutton:SetPoint("TOP", 0, -AS_FRAMEWHITESPACE)
                AS.optionframe.sellbutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.sellbutton:SetText("Sell")
                AS.optionframe.sellbutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.sellbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
                AS.optionframe.sellbutton:SetFrameStrata("TOOLTIP")
            -------------- SCRIPT ----------------
                AS.optionframe.sellbutton:SetScript("OnClick", function(self)
                    AS_SellItem(self)
                end)

        ------ MANUAL PRICE
            -------------- STYLE ----------------
                AS.optionframe.manualpricebutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.manualpricebutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.manualpricebutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.manualpricebutton:SetPoint("TOP", AS.optionframe.sellbutton, "BOTTOM")
                AS.optionframe.manualpricebutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.manualpricebutton:SetText("Edit entry")
                AS.optionframe.manualpricebutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.manualpricebutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
                AS.optionframe.manualpricebutton:SetFrameStrata("TOOLTIP")
            -------------- SCRIPT ----------------
                AS.optionframe.manualpricebutton:SetScript("OnClick", function(self)
                    AS_ManualIgnore(self)
                end)

        ------ RESET FILTERS
            -------------- STYLE ----------------
                AS.optionframe.resetignorebutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.resetignorebutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.resetignorebutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.resetignorebutton:SetPoint("TOP", AS.optionframe.manualpricebutton, "BOTTOM")
                AS.optionframe.resetignorebutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.resetignorebutton:SetText("Erase Ignore Conditions")
                AS.optionframe.resetignorebutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.resetignorebutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
            -------------- SCRIPT ----------------
                AS.optionframe.resetignorebutton:SetScript("OnClick", function(self)
                    AS_ResetIgnore(self)
                end)

        ------ MOVE ENTRY TO TOP
            -------------- STYLE ----------------
                AS.optionframe.movetotopbutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.movetotopbutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.movetotopbutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.movetotopbutton:SetPoint("TOP", AS.optionframe.resetignorebutton,"BOTTOM")
                AS.optionframe.movetotopbutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.movetotopbutton:SetText("Move to top")
                AS.optionframe.movetotopbutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.movetotopbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
            -------------- SCRIPT ----------------
                AS.optionframe.movetotopbutton:SetScript("OnClick", function(self)
                    local listnum = ASbuttontolistnum(self)
                    AS_MoveListButton(listnum, 1)
                end)

        ------ MOVE ENTRY TO BOTTOM
            -------------- STYLE ----------------
                AS.optionframe.movetobottombutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.movetobottombutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.movetobottombutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.movetobottombutton:SetPoint("TOP", ASoptionframe.movetotopbutton,"BOTTOM")
                AS.optionframe.movetobottombutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.movetobottombutton:SetText("Move to bottom")
                AS.optionframe.movetobottombutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.movetobottombutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
            -------------- SCRIPT ----------------
                AS.optionframe.movetobottombutton:SetScript("OnClick", function(self)
                    local listnum = ASbuttontolistnum(self)
                    AS_MoveListButton(listnum, table.maxn(AS.item))
                end)

        ------ COPY ENTRY
            -------------- STYLE ----------------
                AS.optionframe.copyrowbutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.copyrowbutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.copyrowbutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.copyrowbutton:SetPoint("TOP", AS.optionframe.movetobottombutton, "BOTTOM")
                AS.optionframe.copyrowbutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.copyrowbutton:SetText("Copy entry")
                AS.optionframe.copyrowbutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.copyrowbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
            -------------- SCRIPT ----------------
                AS.optionframe.copyrowbutton:SetScript("OnClick", function(self)
                    local listnum = ASbuttontolistnum(self)
                    AS_COPY = AS.item[listnum]
                    AS.mainframe.headerframe.editbox:SetText(AS.item[listnum].name)
                end)

        ------ DELETE ENTRY
            -------------- STYLE ----------------
                AS.optionframe.deleterowbutton = CreateFrame("Button", nil, AS.optionframe)
                AS.optionframe.deleterowbutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.optionframe.deleterowbutton:SetWidth(AS.optionframe:GetWidth())
                AS.optionframe.deleterowbutton:SetPoint("TOP", AS.optionframe.copyrowbutton, "BOTTOM")
                AS.optionframe.deleterowbutton:SetNormalFontObject("GameFontNormal")
                AS.optionframe.deleterowbutton:SetText(AS_BUTTONDELETE)
                AS.optionframe.deleterowbutton:SetHighlightTexture(C.media.backdrop) -- Aurora
                AS.optionframe.deleterowbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2) -- Aurora
            -------------- SCRIPT ----------------
                AS.optionframe.deleterowbutton:SetScript("OnClick", function(self)
                    AS_DeleteRow(self)
                end)
    end

    function AS_SellItem(self)
        local listnum = ASbuttontolistnum(self)
        local found = false

        AS.optionframe:Hide()
        if AuctionFrameAuctions.priceType ~= 1 then
            AuctionFrameAuctions.priceType = 1
            UIDropDownMenu_SetSelectedValue(PriceDropDown, AuctionFrameAuctions.priceType) -- Set to unit price
        end

        if not AS.item['LastAuctionSetup'] or (listnum ~= AS.item['LastAuctionSetup']) then

            AS.item['LastAuctionSetup'] = listnum
            ASprint(MSG_C.INFO.."Setting up sale:|r "..AS.item[listnum].name, 1)

            for bag = 0,4,1 do -- Find item in bags and create auction
                for slot = 1, GetContainerNumSlots(bag), 1 do
                    local name = GetContainerItemLink(bag, slot)
                    if name and string.find(name, AS.item[listnum].name) then
                        found = true
                        AuctionFrameTab3:Click()
                        PickupContainerItem(bag, slot)
                        ClickAuctionSellItemButton()
                        ClearCursor()
                        break
                    end
                end
            end
        else -- Same item is already selected
            found = true
            AuctionFrameTab3:Click()
        end

        if found then
            if ASsavedtable.rememberprice then
                if AS.item[listnum].sellbid then -- Set to unit price, since we do not set stack size
                    MoneyInputFrame_SetCopper(StartPrice, AS.item[listnum].sellbid)
                end
                if AS.item[listnum].sellbuyout then
                    MoneyInputFrame_SetCopper(BuyoutPrice, AS.item[listnum].sellbuyout)
                end
            end
        else
            ASprint(MSG_C.ERROR.."Item not found in bags")
        end
    end

    function AS_ResetIgnore(self)
        local listnum = ASbuttontolistnum(self)

        if listnum then
            ASprint(MSG_C.INFO.."Reset filters for:|r "..AS.item[listnum].name, 1)
            AS.item[listnum].ignoretable = nil
            AS.item[listnum].priceoverride = nil
            AS.optionframe:Hide()
            AS_SavedVariables()
        end
    end

    function AS_ManualIgnore(self) -- manual price menu option
        local listnum = ASbuttontolistnum(self)

        if listnum then
            AS_CreateManualPrompt(AS.item[listnum], listnum)
            AS.optionframe:Hide()
        end
    end

    function AS_DeleteRow(self)
        local listnum = ASbuttontolistnum(self)

        if listnum and AS.item[listnum] then
            ASprint(MSG_C.INFO.."Removing:|r "..AS.item[listnum].name, 1)
            table.remove(AS.item, listnum)
        end
        AS.optionframe:Hide()
        AS_ScrollbarUpdate() -- Necessary to remove empty gap
        AS_SavedVariables()
    end

--[[//////////////////////////////////////////////////

    PROMPTS FUNCTIONS

    AS_CreateManualPrompt, AS_CreatePrompt,
    AS_CreatePromptbutton, AS_NewList

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_CreateManualPrompt(item, listnumber)

        if AS.manualprompt then
            AS.manualprompt:Hide()
        end

        if AS.prompt then
            AS.prompt:Hide()
        end

        if item then
            AS.item['ASmanualedit'] = {}
            AS.item['ASmanualedit'].name = item.name
            AS.item['ASmanualedit'].listnumber = listnumber
        end

        if AS.manualprompt == nil then

            ------ MANUAL PROMPT FRAME
                -------------- STYLE ----------------
                    AS.manualprompt = CreateFrame("Frame", "ASmanualpromptframe", UIParent)
                    AS.manualprompt:SetPoint("TOPLEFT", AS.mainframe, "TOPRIGHT", 3,0)
                    AS.manualprompt:SetHeight(150)  --some addons change font size, so this will be overridden in ASinitialize
                    AS.manualprompt:SetWidth(200)
                    AS.manualprompt:SetBackdrop({   bgFile = "Interface/Tooltips/UI-Background",
                                                    edgeFile = nil,
                                                    tile = false, tileSize = 32, edgeSize = 32,
                                                    insets = { left = 0, right = 0, top = 0, bottom = 0 }
                    })
                    AS.manualprompt:SetBackdropColor(0,0,0,0.85)
                    AS.manualprompt:SetMovable(true)
                    AS.manualprompt:EnableMouse(true)
                -------------- SCRIPT ----------------
                    AS.manualprompt:SetScript("OnMouseDown", function(self)
                        AS.manualprompt:StartMoving()
                    end)
                    AS.manualprompt:SetScript("OnMouseUp", function(self)
                        AS.manualprompt:StopMovingOrSizing()
                    end)
                    AS.manualprompt:SetScript("OnShow",function(self)
                        ASprint(MSG_C.INFO.."Manual prompt is shown")
                        AS.mainframe.headerframe.stopsearchbutton:Click()
                        AS.manualprompt.priceoverride:SetFocus()
                    end)
                    AS.manualprompt:SetScript("OnHide",function(self)
                        ASprint(MSG_C.INFO.."Manual prompt is hidden")
                        if AS.save then
                            AS.save = nil
                            AS_SavedVariables()
                        end
                    end)

            ------ CLOSE BUTTON
                -------------- STYLE ----------------
                    AS.manualprompt.closebutton = CreateFrame("Button", nil, AS.manualprompt)
                    AS.manualprompt.closebutton:SetWidth(15)
                    AS.manualprompt.closebutton:SetHeight(15)
                    AS.manualprompt.closebutton:SetPoint("TOPRIGHT", AS.manualprompt, -2, -2)
                -------------- SCRIPT ----------------
                    AS.manualprompt.closebutton:SetScript("OnClick", function(self)
                        AS.manualprompt:Hide()
                    end)
                    F.ReskinClose(AS.manualprompt.closebutton) -- Aurora

            ------ ICON
                -------------- STYLE ----------------
                    AS.manualprompt.icon = CreateFrame("Button", nil, AS.manualprompt)
                    AS.manualprompt.icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
                    AS.manualprompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    AS.manualprompt.icon:SetPoint("TOPLEFT", AS.manualprompt, "TOPLEFT", 18, -15)
                    AS.manualprompt.icon:SetHeight(37)
                    AS.manualprompt.icon:SetWidth(37)
                -------------- SCRIPT ----------------
                    AS.manualprompt.icon:SetScript("OnEnter", function(self)
                        local link = AS.item[AS.item.LastListButtonClicked].link

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
                            --    end
                        end
                    end)
                    AS.manualprompt.icon:SetScript("OnLeave", function(self)
                        GameTooltip:Hide()
                    end)

            ------ ITEM LABEL
                -------------- STYLE ----------------
                    AS.manualprompt.upperstring = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.manualprompt.upperstring:SetJustifyH("CENTER")
                    AS.manualprompt.upperstring:SetWidth(AS.manualprompt:GetWidth() - (AS.manualprompt.icon:GetWidth() + (2*AS_FRAMEWHITESPACE)))
                    AS.manualprompt.upperstring:SetHeight(AS.manualprompt.icon:GetHeight())
                    AS.manualprompt.upperstring:SetPoint("LEFT", AS.manualprompt.icon, "RIGHT", 7, 0)
                    AS.manualprompt.upperstring:SetPoint("RIGHT", AS.manualprompt, "RIGHT", -15, 0)

            ------ CUTOFF PRICE
                -------------- STYLE ----------------
                    AS.manualprompt.lowerstring = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.manualprompt.lowerstring:SetJustifyH("Left")
                    AS.manualprompt.lowerstring:SetJustifyV("Top")
                    AS.manualprompt.lowerstring:SetWidth(AS.manualprompt:GetWidth() - (2*AS_FRAMEWHITESPACE))
                    AS.manualprompt.lowerstring:SetPoint("TOPLEFT", AS.manualprompt.icon, "BOTTOMLEFT", 0, 2)
                    AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":")
                    AS.manualprompt.lowerstring:SetTextColor(r, g, b) -- Aurora

            ------ IGNORE BUTTON
                -------------- STYLE ----------------
                    AS.manualprompt.ignorebutton = CreateFrame("Button", nil, AS.manualprompt, "UIPanelbuttontemplate")
                    AS.manualprompt.ignorebutton:SetText(AS_BUTTONIGNORE)
                    AS.manualprompt.ignorebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                    AS.manualprompt.ignorebutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.manualprompt.ignorebutton:SetPoint("TOPLEFT", AS.manualprompt.lowerstring, "BOTTOMLEFT", 0, -30)
                -------------- SCRIPT ----------------
                    AS.manualprompt.ignorebutton:SetScript("OnClick", function(self)
                        AS[AS_BUTTONIGNORE]()
                    end)
                    AS.manualprompt.ignorebutton:SetScript("OnEnter",function(self)
                        ASshowtooltip(AS.manualprompt.ignorebutton, AS_BUTTONTEXT3)
                    end)
                    AS.manualprompt.ignorebutton:SetScript("OnLeave",function(self)
                        AShidetooltip()
                    end)

                    F.Reskin(AS.manualprompt.ignorebutton) -- Aurora

            ------ SAVE BUTTON
                -------------- STYLE ----------------
                    AS.manualprompt.savebutton = CreateFrame("Button", nil, AS.manualprompt, "UIPanelbuttontemplate")
                    AS.manualprompt.savebutton:SetText(AS_BUTTONEXPENSIVE)
                    AS.manualprompt.savebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                    AS.manualprompt.savebutton:SetHeight(AS_BUTTON_HEIGHT)
                    AS.manualprompt.savebutton:SetPoint("LEFT", AS.manualprompt.ignorebutton, "RIGHT", 2, 0)
                -------------- SCRIPT ----------------
                    AS.manualprompt.savebutton:SetScript("OnClick", function(self)
                        AS[AS_BUTTONEXPENSIVE]()
                    end)
                    AS.manualprompt.savebutton:SetScript("OnEnter",function(self)
                        ASshowtooltip(AS.manualprompt.savebutton, AS_BUTTONTEXT8)
                    end)
                    AS.manualprompt.savebutton:SetScript("OnLeave", function(self)
                        AShidetooltip()
                    end)

                    F.Reskin(AS.manualprompt.savebutton) -- Aurora

            ------ INPUT BOX
                -------------- STYLE ----------------
                    AS.manualprompt.priceoverride = CreateFrame("EditBox", nil, AS.manualprompt, "InputBoxTemplate")
                    AS.manualprompt.priceoverride:SetPoint("BOTTOMRIGHT", AS.manualprompt.savebutton, "TOPRIGHT", 0, 5)
                    AS.manualprompt.priceoverride:SetHeight(25)
                    AS.manualprompt.priceoverride:SetWidth(45)
                    AS.manualprompt.priceoverride:SetNumeric(true)
                    AS.manualprompt.priceoverride:SetAutoFocus(false)
                -------------- SCRIPT ----------------
                    AS.manualprompt.priceoverride:SetScript("OnEscapePressed", function(self)
                        AS.manualprompt.priceoverride:ClearFocus()
                    end)
                    AS.manualprompt.priceoverride:SetScript("OnEnterPressed", function(self)
                        AS.manualprompt.savebutton:Click()
                    end)
                    AS.manualprompt.priceoverride:SetScript("OnTextChanged", function(self)
                        local messagestring

                        if AS.manualprompt.priceoverride:GetText() == "" then
                            AS.item["ASmanualedit"].priceoverride = nil
                        elseif ASsavedtable and ASsavedtable.copperoverride then
                            AS.item["ASmanualedit"].priceoverride = tonumber(AS.manualprompt.priceoverride:GetText())
                        else
                            AS.item["ASmanualedit"].priceoverride = AS.manualprompt.priceoverride:GetText() * COPPER_PER_GOLD
                        end

                        if AS.item["ASmanualedit"].priceoverride and (tonumber(AS.item["ASmanualedit"].priceoverride) > 0) then
                            messagestring = "\n"..AS_CUTOFF..":\n"
                            messagestring = messagestring..ASGSC(tonumber(AS.item["ASmanualedit"].priceoverride))
                            AS.manualprompt.lowerstring:SetText(messagestring)
                        end
                    end)
                    AS.manualprompt.priceoverride:SetScript("OnEnter", function(self)
                        if ASsavedtable and ASsavedtable.copperoverride then
                            ASshowtooltip(self,"A value here, in COPPER, overrides all other ignore conditions")
                        else
                            ASshowtooltip(self,"A value here, in gold, overrides all other ignore conditions")
                        end
                    end)
                    AS.manualprompt.priceoverride:SetScript("OnLeave", function(self)
                        AShidetooltip()
                    end)

                    F.ReskinInput(AS.manualprompt.priceoverride) -- Aurora

            ------ NOTES BOX
                -------------- STYLE ----------------
                    AS.manualprompt.notes = CreateFrame("EditBox", nil, AS.manualprompt, "InputBoxTemplate")
                    AS.manualprompt.notes:SetPoint("TOPLEFT", AS.manualprompt.ignorebutton, "BOTTOMLEFT", 2, -20)
                    AS.manualprompt.notes:SetPoint("TOPRIGHT", AS.manualprompt.savebutton, "BOTTOMRIGHT", 0, -15)
                    AS.manualprompt.notes:SetPoint("BOTTOMRIGHT", AS.manualprompt, "BOTTOMRIGHT", 0, 15)
                    AS.manualprompt.notes:SetMultiLine(true)
                    AS.manualprompt.notes:SetMaxLetters(300)
                -------------- SCRIPT ----------------
                    AS.manualprompt.notes:SetScript("OnEscapePressed", function(self)
                        AS.manualprompt.notes:ClearFocus()
                    end)
                    AS.manualprompt.notes:SetScript("OnTextChanged", function(self)

                        if AS.manualprompt.notes:GetText() == "" then
                            AS.save = true
                            AS.item[AS.item['ASmanualedit'].listnumber].notes = nil
                        elseif AS.manualprompt.notes:GetText() ~= AS.item[AS.item['ASmanualedit'].listnumber].notes then
                            AS.save = true
                            AS.item[AS.item['ASmanualedit'].listnumber].notes = AS.manualprompt.notes:GetText()
                        end
                    end)

                    F.ReskinInput(AS.manualprompt.notes) -- Aurora

            ------ NOTES LABEL
                -------------- STYLE ----------------
                    AS.manualprompt.notes.label = AS.manualprompt:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    AS.manualprompt.notes.label:SetJustifyH("LEFT")
                    AS.manualprompt.notes.label:SetPoint("BOTTOMLEFT", AS.manualprompt.notes, "TOPLEFT", 0, 2)
                    AS.manualprompt.notes.label:SetText("Notes")
                    AS.manualprompt.notes.label:SetTextColor(r, g, b) -- Aurora
        end

        if item then
            AS.manualprompt.icon:SetNormalTexture(item.icon)

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
            
            if item.ignoretable then
                AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":\n"..ASGSC(tonumber(item.ignoretable[item.name].cutoffprice)))
            else
                AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":\n")
            end

            AS.manualprompt.priceoverride:SetText("")
            AS.manualprompt:Show()
        end
    end

    function AS_CreatePrompt()

        ------ PROMPT FRAME
            -------------- STYLE ----------------
                AS.prompt = CreateFrame("Frame", "ASpromptframe", AS.mainframe)
                AS.prompt:SetPoint("TOPLEFT", AS.mainframe, "TOPRIGHT", 3,0)
                AS.prompt:SetHeight(420)  --some addons change font size, so this will be overridden in ASinitialize
                AS.prompt:SetWidth(200)
                AS.prompt:SetBackdrop({     bgFile = "Interface/Tooltips/UI-Background",
                                            edgeFile = nil,
                                            tile = false, tileSize = 32, edgeSize = 32,
                                            insets = { left = 0, right = 0, top = 0, bottom = 0 }
                })
                AS.prompt:SetBackdropColor(0,0,0,0.85)
                AS.prompt:SetMovable(true)
                AS.prompt:EnableMouse(true)
            -------------- SCRIPT ----------------
                AS.prompt:SetScript("OnMouseDown", function(self)
                    AS.prompt:StartMoving()
                end)
                AS.prompt:SetScript("OnMouseUp", function(self)
                    AS.prompt:StopMovingOrSizing()
                end)
                AS.prompt:SetScript("OnShow", function(self)
                    ASprint(MSG_C.INFO.."Prompt is shown")
                end)
                AS.prompt:SetScript("OnHide", function(self)
                    ASprint(MSG_C.INFO.."Prompt is hidden")

                    if AS.status == nil then
                        AS.mainframe.headerframe.stopsearchbutton:Click()
                    end
                end)

        ------ CLOSE BUTTON
            -------------- STYLE ----------------
                AS.prompt.closebutton = CreateFrame("Button", nil, AS.prompt)
                AS.prompt.closebutton:SetWidth(15)
                AS.prompt.closebutton:SetHeight(15)
                AS.prompt.closebutton:SetPoint("TOPRIGHT", AS.prompt, -2, -2)
            -------------- SCRIPT ----------------
                AS.prompt.closebutton:SetScript("OnClick", function(self)
                    AS.mainframe.headerframe.stopsearchbutton:Disable()
                    AS.prompt:Hide()
                end)

                F.ReskinClose(AS.prompt.closebutton) -- Aurora

        ------ ICON
            -------------- STYLE ----------------
                AS.prompt.icon = CreateFrame("Button", nil, AS.prompt)
                AS.prompt.icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
                AS.prompt.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                AS.prompt.icon:SetPoint("TOPLEFT", AS.prompt, "TOPLEFT", 18, -15)
                AS.prompt.icon:SetHeight(37)
                AS.prompt.icon:SetWidth(37)
            -------------- SCRIPT ----------------
                AS.prompt.icon:SetScript("OnEnter", function(self)
                    local link = GetAuctionItemLink("list", AScurrentahresult)
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
                end)
                AS.prompt.icon:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)

        ------ ITEM LABEL
            -------------- STYLE ----------------
                AS.prompt.upperstring = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.prompt.upperstring:SetJustifyH("CENTER")
                AS.prompt.upperstring:SetWidth(AS.prompt:GetWidth() - (AS.prompt.icon:GetWidth() + (2*AS_FRAMEWHITESPACE)))
                AS.prompt.upperstring:SetHeight(AS.prompt.icon:GetHeight())
                AS.prompt.upperstring:SetPoint("LEFT", AS.prompt.icon, "RIGHT", 7, 0)
                AS.prompt.upperstring:SetPoint("RIGHT", AS.prompt, "RIGHT", -15, 0)

        ------ ITEM QUANTITY
            -------------- STYLE ----------------
                AS.prompt.quantity = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.prompt.quantity:SetFont("Interface\\Addons\\Aurora\\media\\font.ttf", 30) --Aurora
                AS.prompt.quantity:SetJustifyH("CENTER")
                AS.prompt.quantity:SetPoint("TOP", AS.prompt, "TOP", 0, -AS.prompt.icon:GetWidth()-30)

        ------ ITEM VENDOR
            -------------- STYLE ----------------
                AS.prompt.vendor = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.prompt.vendor:SetJustifyH("CENTER")
                AS.prompt.vendor:SetWordWrap(false)
                AS.prompt.vendor:SetWidth(AS.prompt:GetWidth()-20)
                AS.prompt.vendor:SetTextColor(r, g, b, 1) -- Aurora
                AS.prompt.vendor:SetPoint("TOP", AS.prompt.quantity, "BOTTOM", 0, -5)

        ------ ITEM LEFT SEPARATOR
            -------------- STYLE ----------------
                AS.prompt.separator = AS.prompt:CreateTexture()
                AS.prompt.separator:SetColorTexture(r, b, g, 0.3) -- Aurora
                AS.prompt.separator:SetSize((AS.prompt:GetWidth()/2)-20, 1)
                AS.prompt.separator:SetPoint("RIGHT", AS.prompt.vendor, "BOTTOM", 0, -22)

        ------ ITEM RIGHT SEPARATOR
            -------------- STYLE ----------------
                AS.prompt.rseparator = AS.prompt:CreateTexture()
                AS.prompt.rseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
                AS.prompt.rseparator:SetSize((AS.prompt:GetWidth()/2)-20, 1)
                AS.prompt.rseparator:SetPoint("LEFT", AS.prompt.separator, "RIGHT")

        ------ BID/BUYOUT FRAME
            -------------- STYLE ----------------
                AS.prompt.bidbuyout = CreateFrame("FRAME", nil, AS.prompt)

            ------ ITEM BID LABEL
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.bid = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    AS.prompt.bidbuyout.bid:SetJustifyH("CENTER")
                    AS.prompt.bidbuyout.bid:SetText(string.upper("Bid"))
                    AS.prompt.bidbuyout.bid:SetPoint("BOTTOM", AS.prompt.separator, "TOP", 0, 2)

            ------ BID AMOUNT EACH
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.bid.single = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.bidbuyout.bid.single:SetJustifyH("RIGHT")
                    AS.prompt.bidbuyout.bid.single:SetPoint("TOP", AS.prompt.bidbuyout.bid, "BOTTOM", 0, -10)
                    AS.prompt.bidbuyout.bid.single:SetTextColor(r, g, b) -- Aurora

            ------ BID AMOUNT TOTAL
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.bid.total = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.bidbuyout.bid.total:SetJustifyH("RIGHT")
                    AS.prompt.bidbuyout.bid.total:SetPoint("TOP", AS.prompt.bidbuyout.bid.single, "BOTTOM", 0, -16)
                    AS.prompt.bidbuyout.bid.total:SetTextColor(r, g, b) -- Aurora

            ------ ITEM BUYOUT LABEL
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.buyout = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    AS.prompt.bidbuyout.buyout:SetJustifyH("CENTER")
                    AS.prompt.bidbuyout.buyout:SetText(string.upper("Buyout"))
                    AS.prompt.bidbuyout.buyout:SetPoint("BOTTOM", AS.prompt.rseparator, "TOP", 0, 2)

            ------ BUYOUT AMOUNT EACH
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.buyout.single = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.bidbuyout.buyout.single:SetJustifyH("LEFT")
                    AS.prompt.bidbuyout.buyout.single:SetPoint("TOP", AS.prompt.bidbuyout.buyout, "BOTTOM", 0, -10)
                    AS.prompt.bidbuyout.buyout.single:SetTextColor(r, g, b) -- Aurora

            ------ BUYOUT AMOUNT TOTAL
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.buyout.total = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.bidbuyout.buyout.total:SetJustifyH("LEFT")
                    AS.prompt.bidbuyout.buyout.total:SetPoint("TOP", AS.prompt.bidbuyout.buyout.single, "BOTTOM", 0, -16)
                    AS.prompt.bidbuyout.buyout.total:SetTextColor(r, g, b) -- Aurora

            ------ MIDDLE SEPARATOR
                -------------- STYLE ----------------
                    AS.prompt.bidbuyout.vseparator = AS.prompt.bidbuyout:CreateTexture()
                    AS.prompt.bidbuyout.vseparator:SetColorTexture(r, g, b, 0.3) -- Aurora
                    AS.prompt.bidbuyout.vseparator:SetSize(1, AS.prompt.bidbuyout.bid:GetHeight() + 17)
                    AS.prompt.bidbuyout.vseparator:SetPoint("TOP", AS.prompt.separator, "RIGHT")

                ------ MIDDLE SEPARATOR EACH
                    -------------- STYLE ----------------
                        AS.prompt.bidbuyout.each = AS.prompt.bidbuyout:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        AS.prompt.bidbuyout.each:SetHeight(AS.prompt.bidbuyout.bid.single:GetHeight() + 10)
                        AS.prompt.bidbuyout.each:SetJustifyH("CENTER")
                        AS.prompt.bidbuyout.each:SetJustifyV("BOTTOM")
                        AS.prompt.bidbuyout.each:SetText(AS_EACH)
                        AS.prompt.bidbuyout.each:SetTextColor(r, g, b, 1) -- Aurora
                        AS.prompt.bidbuyout.each:SetPoint("CENTER", AS.prompt.bidbuyout.vseparator)
                        --AS.prompt.bidbuyout.each:SetPoint("BOTTOM", AS.prompt.bidbuyout.bid.single, "BOTTOM")

                ------ MIDDLE HORIZONTAL SEPARATOR
                    -------------- STYLE ----------------
                        AS.prompt.bidbuyout.hseparator = AS.prompt:CreateTexture()
                        AS.prompt.bidbuyout.hseparator:SetColorTexture(r, b, g, 0.3) -- Aurora
                        AS.prompt.bidbuyout.hseparator:SetSize(AS.prompt.separator:GetWidth()+AS.prompt.rseparator:GetWidth(), 1)
                        AS.prompt.bidbuyout.hseparator:SetPoint("TOP", AS.prompt.bidbuyout.vseparator, "BOTTOM")

        ------ BUYOUT-ONLY FRAME
            -------------- STYLE ----------------
                AS.prompt.buyoutonly = CreateFrame("FRAME", nil, AS.prompt)

            ------ ITEM BUYOUT LABEL
                -------------- STYLE ----------------
                    AS.prompt.buyoutonly.buyout = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    AS.prompt.buyoutonly.buyout:SetJustifyH("CENTER")
                    AS.prompt.buyoutonly.buyout:SetText("|c00ffffff"..string.upper("Buyout").."|r")
                    AS.prompt.buyoutonly.buyout:SetPoint("BOTTOM", AS.prompt.separator, "TOPRIGHT", 0, 2)

            ------ BUYOUT AMOUNT EACH
                -------------- STYLE ----------------
                    AS.prompt.buyoutonly.buyout.single = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.buyoutonly.buyout.single:SetJustifyH("CENTER")
                    AS.prompt.buyoutonly.buyout.single:SetPoint("TOP", AS.prompt.buyoutonly.buyout, "BOTTOM", 0, -10)
                    AS.prompt.buyoutonly.buyout.single:SetTextColor(r, g, b) -- Aurora

            ------ BUYOUT AMOUNT TOTAL
                -------------- STYLE ----------------
                    AS.prompt.buyoutonly.buyout.total = AS.prompt.buyoutonly:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    AS.prompt.buyoutonly.buyout.total:SetJustifyH("CENTER")
                    AS.prompt.buyoutonly.buyout.total:SetPoint("TOP", AS.prompt.buyoutonly.buyout.single, "BOTTOM", 0, -16)
                    AS.prompt.buyoutonly.buyout.total:SetTextColor(r, g, b) -- Aurora

        ------ BID BUTTON
            -------------- STYLE ----------------
                AS.prompt[AS_BUTTONBID] = CreateFrame("Button", nil, AS.prompt, "UIPanelbuttontemplate")
                AS.prompt[AS_BUTTONBID]:SetText(AS_BUTTONBID)
                AS.prompt[AS_BUTTONBID]:SetWidth((AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                AS.prompt[AS_BUTTONBID]:SetHeight(AS_BUTTON_HEIGHT)
                AS.prompt[AS_BUTTONBID]:SetPoint("TOP", AS.prompt.separator, "BOTTOM", 0, -60)
            -------------- SCRIPT ----------------
                AS.prompt[AS_BUTTONBID]:SetScript("OnClick", function(self)
                    AS[AS_BUTTONBID]()
                end)

                F.Reskin(AS.prompt[AS_BUTTONBID]) -- Aurora

        ------ BUYOUT BUTTON
            -------------- STYLE ----------------
                AS.prompt[AS_BUTTONBUYOUT] = CreateFrame("Button", nil, AS.prompt, "UIPanelbuttontemplate")
                AS.prompt[AS_BUTTONBUYOUT]:SetText(AS_BUTTONBUYOUT)
                AS.prompt[AS_BUTTONBUYOUT]:SetWidth((AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                AS.prompt[AS_BUTTONBUYOUT]:SetHeight(AS_BUTTON_HEIGHT)
                AS.prompt[AS_BUTTONBUYOUT]:SetPoint("LEFT", AS.prompt[AS_BUTTONBID], "RIGHT")
            -------------- SCRIPT ----------------
                AS.prompt[AS_BUTTONBUYOUT]:SetScript("OnClick", function(self)
                    AS[AS_BUTTONBUYOUT]()
                end)

                F.Reskin(AS.prompt[AS_BUTTONBUYOUT]) -- Aurora

        ------ CUTOFF PRICE LABEL
            -------------- STYLE ----------------
                AS.prompt.lowerstring= AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                AS.prompt.lowerstring:SetJustifyH("CENTER")
                AS.prompt.lowerstring:SetWidth(AS.prompt.separator:GetWidth() + AS.prompt.rseparator:GetWidth())
                AS.prompt.lowerstring:SetPoint("TOP", AS.prompt[AS_BUTTONBID], "BOTTOMRIGHT", 1, -7)
                AS.prompt.lowerstring:SetSpacing(2)
                AS.prompt.lowerstring:SetTextColor(r, g, b) -- Aurora

        ------ EXTRA BUTTONS
            AS_CreateButtonHandlers()

            local buttonnames
            local buttontooltips = {AS_BUTTONTEXT9, AS_BUTTONTEXT4, AS_BUTTONTEXT1, AS_BUTTONTEXT11}
            AS.prompt.buttonnames = {AS_BUTTONNEXTLIST, AS_BUTTONNEXTAH, AS_BUTTONUPDATE, AS_BUTTONFILTERS}
            buttonnames = AS.prompt.buttonnames

            buttonwidth = (AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)  --basically half its frame size

            local columns = 2
            local latest_column = nil
            local latest_row = nil
            local current_column = 1

            for i = 1, table.maxn(AS.prompt.buttonnames) do

                AS_CreatePromptbutton(AS.prompt, AS.prompt.buttonnames[i], buttontooltips[i])
                current_button = AS.prompt[buttonnames[i]]

                if i == 1 then -- Very first button
                    current_button:SetPoint("BOTTOMLEFT", 20, 10)
                    latest_row = current_button
                elseif current_column == 1 then -- Grow to the top
                    current_button:SetPoint("BOTTOM", latest_row, "TOP", 0, 1)
                    latest_row = current_button
                else -- Grow to the right
                    current_button:SetPoint("LEFT", latest_column, "RIGHT")
                end

                latest_column = current_button
                if current_column == columns then -- End of columns, start from column 1
                    current_column = 1
                else
                    current_column = current_column + 1
                end
            end
    end

    function AS_CreatePromptbutton(parent, name, tooltip)
        local buttonwidth = (parent:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)
        -------------- STYLE ----------------
            parent[name] = CreateFrame("Button", nil, parent, "UIPanelbuttontemplate")
            parent[name]:SetText(name)
            parent[name]:SetWidth(buttonwidth)
            parent[name]:SetHeight(AS_BUTTON_HEIGHT)
        -------------- SCRIPT ----------------
            parent[name]:SetScript("OnClick", function(self)
                AS[name]()
                parent:Hide()
            end)
            parent[name]:SetScript("OnEnter", function(self)
                ASshowtooltip(parent[name],tooltip)
            end)
            parent[name]:SetScript("OnLeave", function(self)
                AShidetooltip()
            end)
           
            F.Reskin(parent[name]) -- Aurora
    end

    function AS_NewList(listname)
        ASprint(MSG_C.EVENT.."New list created:|r"..listname)
        AS_template(listname)
        AS_ScrollbarUpdate()
    end
