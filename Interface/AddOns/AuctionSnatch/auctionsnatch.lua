
--[[//////////////////////////////////////////////////

    OG DATA STRUCTURES EXPLAINED

    i'm trying something ambitious.  included in the name of my variables is
    the entire parent/child heirarchy
    every variable will be a child of 'AS' eg AS.mainframe
    anything with its parent being AS.mainframe will be AS.mainframe.whatever
    multiple items, buttons, will be AS.mainframe.button[x]

    so name will be very long, and looking like:
    AS.mainframe.listframe.itembutton[x].lefttexture

    I'm also hoping to not use the 2nd argument of any 'createframe' function
    I don't like all the global variables floating around
    maybe this heirarchial, table-centered structure will help

    (it also might just be a pain in the ass)

    edit.  Its a pain in the ass
    _________________________________________________

    ANGELBLUE05's MODIFICATIONS EXPLAINED

    I'm just trying to clean up and fix certain bugs I came across. I tried not
    to change too much of the structure...

    but was unsucessful. Modified to fit Altz UI (using Aurora)
    http://www.wowinterface.com/downloads/info21263-AltzUIforLegion.html#info

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]


AS_FRAMEWHITESPACE = 10
AS_BUTTON_HEIGHT = 23
AS_GROSSHEIGHT = 420
AS_HEADERHEIGHT = 120
AS_LISTHEIGHT = AS_GROSSHEIGHT - AS_HEADERHEIGHT
AS = {}
AS.elapsed = 0
ASfirsttime = false
ACTIVE_TABLE = nil

STATE = {
    ['QUERYING'] = 1,
    ['WAITINGFORUPDATE'] = 2,
    ['EVALUATING'] = 3,
    ['WAITINGFORPROMPT'] = 4,
    ['BUYING'] = 5
}

MSG_C = {
    ['ERROR'] = "|cffFF00E1",
    ['INFO'] = "|cff35FCB5",--"|cffB5EDFF",
    ['EVENT'] = "|cffFFBF00",--"|cff35FCB5",
    ['DEBUG'] = "|cffE0FC35",
    ['DEFAULT'] = "|cff765EFF",
    ['BOOL'] = "|cff2BED48"
}

OPT_LABEL = {
    ['copperoverride'] = "Copper override",
    ['ASnodoorbell'] = AS_DOORBELLSOUND,
    ['ASignorebid'] = "Ignore bids",
    ['ASignorenobuyout'] = "Ignore no buyout"
}


--[[//////////////////////////////////////////////////

    FUNCTIONS TRIGGERED VIA XML
    auctionsnatch.xml

    AS_OnLoad, AS_OnEvent, AS_OnUpdate

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_OnLoad(self)

        ----- REGISTER FOR EVENTS
            self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
            self:RegisterEvent("AUCTION_HOUSE_SHOW")
            self:RegisterEvent("AUCTION_HOUSE_CLOSED")
            self:RegisterEvent("VARIABLES_LOADED")

        ------ CHAT HOOKS
            -------------- THANK YOU TINY PAD ----------------
            self:RegisterEvent("ADDON_LOADED") -- tradeskill and achievement hooks need to wait for LoD bits
            local old_ChatEdit_InsertLink = ChatEdit_InsertLink
            function ChatEdit_InsertLink(text)

                if AS.mainframe.headerframe.editbox:HasFocus() then
                    AS.mainframe.headerframe.editbox:Insert(text)
                    return true -- prevents the stacksplit frame from showing
                else
                    return old_ChatEdit_InsertLink(text)
                end
            end

        ------ AUCTION HOUSE HOOKS // TODO: Is this necessary?
            if BrowseName then
                local old_BrowseName = BrowseName:GetScript("OnEditFocusGained")
                BrowseName:SetScript("OnEditFocusGained", function()
                    
                    if AS.status == nil then
                        return false  --should catch the infinate loop
                    end

                    AS.status = nil  --else the mod will mess up typing
                    return old_BrowseName() --for some reason this causes an infinate loop :( > Can't seem to trigger infinite loop -AB5
                end)
            end

        ------ STATIC DIALOG // To get new list name
            StaticPopupDialogs["AS_NewList"] = {
                text = "Enter name for the new list",
                button1 = "Create",
                button2 = "Cancel",
                OnShow = function (self, data)
                    --self.editBox:SetText("")
                    self.button1:Disable()
                end,
                OnAccept = function (self, data, data2)
                    AS_NewList(self.editBox:GetText())
                end,
                EditBoxOnTextChanged = function (self, data)
                    text = self:GetParent().editBox:GetText()
                    if text == "" then
                        self:GetParent().button1:Disable()
                    else
                        self:GetParent().button1:Enable()
                    end
                end,
                hasEditBox = true,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }

        DEFAULT_CHAT_FRAME:AddMessage(MSG_C.DEFAULT..AS_LOADTEXT)

        ------ SLASH COMMANDS
            SLASH_AS1 = "/AS";
            SLASH_AS2 = "/as";
            SLASH_AS3 = "/As";
            SLASH_AS4 = "/aS";
            SLASH_AS5 = "/Auctionsnatch";
            SLASH_AS6 = "/AuctionSnatch";
            SLASH_AS7 = "/AUCTIONSNATCH";
            SLASH_AS8 = "/auctionsnatch";

            SlashCmdList["AS"] = AS_Main;

        AS_CreateMainFrame()
        AS_CreatePrompt()
        AS_CreateManualPrompt()

        table.insert(UISpecialFrames, AS.mainframe:GetName())
        table.insert(UISpecialFrames, AS.prompt:GetName())
        table.insert(UISpecialFrames, AS.manualprompt:GetName())

        AS.prompt:Hide()
        AS.manualprompt:Hide()
    end

    function AS_OnEvent(self, event)

        if event == "VARIABLES_LOADED" then
            ASprint(MSG_C.EVENT.."Variables loaded. Initializing.")
            ASprint(MSG_C.INFO.."Running version: "..GetAddOnMetadata("Auctionsnatch", "Version"), 1)
            
            AS_Initialize()

        elseif event == "AUCTION_ITEM_LIST_UPDATE" then
            --ASprint(MSG_C.INFO..event)
            if AS.status == STATE.BUYING then
                AS.status = STATE.EVALUATING
            end

        elseif event == "AUCTION_HOUSE_SHOW" then

            if not ASauctiontab then
                AS_CreateAuctionTab()
            end

            if ASautostart and not ASautoopen then
                -- Do nothing
            elseif ASautostart and not IsShiftKeyDown() then -- Auto start
                AS.status = STATE.QUERYING
                AS_Main()
            elseif IsShiftKeyDown() then -- Auto start
                AS.status = STATE.QUERYING
                AS_Main()
            elseif ASautoopen then
                -- Automatically display frame, just don't auto start
                AS_Main()
            end

        elseif event == "AUCTION_HOUSE_CLOSED" then

            AS.mainframe.headerframe.editbox:SetText("")
            BrowseResetButton:Click()
            AS.prompt:Hide()
            AS.manualprompt:Hide()
            AS.status = nil
            
            if ASopenedwithah then  --in case i do a manual /as prompt for testing purposes
                if AS.mainframe then
                    AS.mainframe:Hide()
                end
                ASopenedwithah = false
            else
                AS.mainframe:Hide()
            end
        
        elseif string.match("AUCTION", event) then
            ASprint(MSG_C.INFO..event)
        end
    end

    function AS_OnUpdate(self, elapsed)
        -- This is the Blizzard Update, called every computer clock cycle ~millisecond
        
        if not elapsed then -- Otherwise it will infinite loop
            return 
        end

        -- This is needed because sometimes a query completes,
        -- and the results are sent back - but the ah will not accept a query right away.
        -- there is no event that fires when a query is possible, so i just have to spam requests

        if AS.status then
            AS.elapsed = AS.elapsed + elapsed

            if AS.elapsed > 0.1 then
                AS.elapsed = 0

                if AS.status == STATE.QUERYING then
                    canQuery, canQueryAll = CanSendAuctionQuery("list")
                    if canQuery then
                        ASprint(MSG_C.EVENT.."[ Start querying ]")
                        AS_QueryAH()
                    end
                
                elseif AS.status == STATE.WAITINGFORUPDATE then
                    ASprint(MSG_C.EVENT.."[ Waiting for update event ]")
                    AS.status = STATE.EVALUATING
                
                elseif AS.status == STATE.EVALUATING then
                    canQuery, canQueryAll = CanSendAuctionQuery("list")
                    if canQuery then
                        ASprint(MSG_C.EVENT.."[ Start evaluating ]")
                        AS_Evaluate()
                    end
                
                elseif AS.status == STATE.WAITINGFORPROMPT then
                    -- The prompt buttons will change the status accordingly
                elseif AS.status == STATE.BUYING then
                    -- Nothing to do
                end
            end
        end
    end

--[[//////////////////////////////////////////////////

    MAIN FUNCTIONS

    AS_Initialize, AS_Main, AS_SavedVariables
    ASdropDownMenu_Initialize,
    ASdropDownMenuItem_OnClick

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_Initialize()
        local playerName = UnitName("player")
        local serverName = GetRealmName()

        hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", AS_ContainerFrameItemButton_OnModifiedClick)
        hooksecurefunc("ChatFrame_OnHyperlinkShow", AS_ChatFrame_OnHyperlinkShow)

        if (playerName == nil) or (playerName == UNKNOWNOBJECT) or (playerName == UNKNOWNBEING) then
            return
        end

        AS.item = {}
        AScurrentauctionsnatchitem = 1
        AScurrentahresult = 0
        AS.status = nil

        if ASsavedtable and ASsavedtable[serverName] then
            AS_LoadTable(serverName)
        else
            ASprint(MSG_C.EVENT.."New server found")
            AS_template(serverName)
        end

        -- Set checkboxes
        if AS.mainframe then
            AS.mainframe.headerframe.autostart:SetChecked(ASautostart)
            AS.mainframe.headerframe.autoopen:SetChecked(ASautoopen)
        end

        -- font size testing and adjuting height of prompt
        local _, height = GameFontNormal:GetFont()
        local new_height = (height * 10) + ((AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE)*6)  -- LINES, 5 BUTTONS + 1 togrow on
        
        ASprint(MSG_C.DEBUG.."Font height:|r "..height)
        ASprint(MSG_C.DEBUG.."New prompt height:|r "..new_height)
        AS.prompt:SetHeight(new_height)
        AS.manualprompt:SetHeight(new_height)

        -- Generate scroll bar items
        AS_ScrollbarUpdate()
    end

    function AS_Main(input)
        -- this is called when we type /AS or clicks the AS tab
        ASprint(MSG_C.INFO.."Excelsior!", 1)
        if input then
            input = string.lower(input)
        end
       
        if AS.mainframe then
            --ASprint(MSG_C.INFO.."Frame layer: "..AS.mainframe:GetFrameLevel())

            if input == "test" then -- TODO: Rework testing to be more readable
                ASdebug = true

                if (not AStesttablenum) then
                    AStesttablenum = 1
                end

                local i,bag,numberofslots,slot,texture,itemCount,locked,quality,readable, link
                local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture
                local canQuery,canQueryAll
                local testtable
                if(not testtable) then

                    testtable = {}

                    for bag = 0,4 do  --loop through each item in each bag
                        numberofslots = GetContainerNumSlots(bag);
                        if (numberofslots > 0) then
                            for slot=1,numberofslots do
                                link = GetContainerItemLink(bag,slot)
                                if(link) then
                                    itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(link)
                                    testtable[#testtable+1] = itemName
                                end

                            end
                        end
                    end
                    testtable = ASremoveduplicates(testtable)
                end

                if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
                    
                    canQuery, canQueryAll = CanSendAuctionQuery()  --check if we can send a query
                    if canQuery and testtable[AStesttablenum] then

                        local name = testtable[AStesttablenum]
                        AStesttablenum = AStesttablenum + 1

                        BrowseName:SetText(name)
                        AuctionFrameBrowse_Search()

                        --AS.status=WAITINGFORUPDATE
                        --return true
                    end
                end

            elseif input == "debug" then
                ASdebug = not ASdebug
                ASprint(MSG_C.BOOL.."Debug: "..tostring(ASdebug), 1)
                return
            elseif input == "copperoverride" then
                ASsavedtable.copperoverride = not ASsavedtable.copperoverride
                ASprint(MSG_C.BOOL.."CopperOverride: "..tostring(ASsavedtable.copperoverride), 1)
                return
            end

        else
            ASprint(MSG_C.ERROR.."Mainframe not found!", 1)
            return false
        end

        AS.mainframe:Show()
        --ASbringtotop() -- TODO: Is it really needed?
    end

    function AS_SavedVariables()
        ASprint(MSG_C.EVENT.."[ Saving changes ]")

        if AS and AS.item then
            if not ASsavedtable then
                ASsavedtable = {}
                ASsavedtable.copperoverride = true
            end

            ASsavedtable[ACTIVE_TABLE] = {}
            AS_tcopy(ASsavedtable[ACTIVE_TABLE], AS.item)
        else
            ASprint(MSG_C.ERROR.."Nothing found to save")
        end

        if AS.mainframe then
            -- check boxes
            ASsavedtable[ACTIVE_TABLE].ASautostart = ASautostart
            ASsavedtable[ACTIVE_TABLE].ASautoopen = ASautoopen
            ASsavedtable[ACTIVE_TABLE].ASnodoorbell = ASnodoorbell
            ASsavedtable[ACTIVE_TABLE].ASignorebid = ASignorebid
            ASsavedtable[ACTIVE_TABLE].ASignorenobuyout = ASignorenobuyout
        else
            ASprint(MSG_C.ERROR.."Checkboxes not found to save")
        end
    end

    function ASdropDownMenu_Initialize(self, level)
        --drop down menues can have sub menues. The value of level determines the drop down sub menu tier
        local level = level or 1 

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo()
            local key, value

            --- Profile/Server list
            info.text = "Import list"
            info.hasArrow = true
            info.value = "Import"
            UIDropDownMenu_AddButton(info, level)

            --- Create new list
            info.text = "Create list"
            info.hasArrow = false
            info.value = "ASnewlist"
            info.func =  ASdropDownMenuItem_OnClick
            info.owner = self:GetParent()
            UIDropDownMenu_AddButton(info, level)

            if ASsavedtable then
                --- Copper override first
                info.text = OPT_LABEL["copperoverride"]
                info.value = "copperoverride"
                info.checked = ASsavedtable.copperoverride
                info.hasArrow = false
                info.func =  ASdropDownMenuItem_OnClick
                info.owner = self:GetParent()
                UIDropDownMenu_AddButton(info,level)
                --- Other settings
                for key, value in pairs(ASsavedtable[ACTIVE_TABLE]) do
                    if OPT_LABEL[key] then -- options
        
                        if type(value) == "boolean" then
                            info.checked = value
                        end

                        info.text = OPT_LABEL[key]
                        info.value = key
                        info.hasArrow = false
                        info.func =  ASdropDownMenuItem_OnClick
                        info.owner = self:GetParent()
                        UIDropDownMenu_AddButton(info,level)
                    end
                end
            end
        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "Import" then
            local info = UIDropDownMenu_CreateInfo()
            local key, value

            if ASsavedtable then
                for key, value in pairs(ASsavedtable) do
                    if not OPT_LABEL[key] then -- Found a server
    
                        if key == ACTIVE_TABLE then -- indicate which list is being used
                            info.checked = true
                        else
                            info.checked = false
                        end

                        info.text = key
                        info.value = key
                        info.hasArrow = false
                        info.func =  ASdropDownMenuItem_OnClick
                        info.owner = self:GetParent()
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        else
            local info = UIDropDownMenu_CreateInfo()
            
            info.text = AS_NODATA
            info.value = nil
            info.hasArrow = false
            info.owner = self:GetParent()
            UIDropDownMenu_AddButton(info,level)
        end
    end

    function ASdropDownMenuItem_OnClick(self)
        -- this is where the actual importing takes place
        ASprint(MSG_C.INFO.."Dropdown selected:|r "..tostring(self.value))

        if self.value == "copperoverride" then
            ASsavedtable.copperoverride = not ASsavedtable.copperoverride
            return
        elseif self.value == "ASnodoorbell" then
            ASnodoorbell = not ASnodoorbell
            AS_SavedVariables()
            return
        elseif self.value == "ASignorebid" then
            ASignorebid = not ASignorebid
            AS_SavedVariables()
            return
        elseif self.value == "ASignorenobuyout" then
            ASignorenobuyout = not ASignorenobuyout
            AS_SavedVariables()
            return
        elseif self.value == "ASnewlist" then
            StaticPopup_Show("AS_NewList")
            return
        end

        if self.value ~= ACTIVE_TABLE then  --dont import ourself
            AS.mainframe.listframe.scrollFrame:SetVerticalScroll(0)
            AS_LoadTable(self.value)
            ASdropDownMenuButton:Click() -- to close the dropdown
        end
    end

--[[//////////////////////////////////////////////////

    SECONDARY FUNCTIONS

    AS_ScrollbarUpdate, AS_CreateButtonHandlers,
    AS_AddItem, AS_MoveListButton,
    AS_ChatFrame_OnHyperlinkShow,
    AS_ContainerFrameItemButton_OnModifiedClick

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_ScrollbarUpdate()
        -- This redraws all the buttons and make sure they're showing the right stuff
        if not AS.item then
            ASprint(MSG_C.ERROR.."AS.item is empty")
            return false
        end

        AS.optionframe:Hide()

        local ASnumberofitems = table.maxn(AS.item)
        local currentscrollbarvalue = FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)

        FauxScrollFrame_Update(AS.mainframe.listframe.scrollFrame, ASnumberofitems, ASrowsthatcanfit(), AS_BUTTON_HEIGHT)

        local x, idx, link, hexcolor, itemRarity

        for x = 1, ASrowsthatcanfit() do --apparently theres a bug here for some screen resolutions?
            -- Get the appropriate item, which will be x + value
            idx = x + currentscrollbarvalue

            if AS.item[idx] and AS.item[idx].name then
                hexcolor = ""

                if AS.item[idx].icon then -- Set the item icon and link
                    AS.mainframe.listframe.itembutton[x].icon:SetNormalTexture(AS.item[idx].icon)
                    AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    link = AS.item[idx].link
                    AS.mainframe.listframe.itembutton[x].link = link
                    if not AS.item[idx].rarity then --updated for 3.1 to include colors
                        _, _, itemRarity = GetItemInfo(link)
                        AS.item[idx].rarity = itemRarity
                    end

                    _,_,_,hexcolor = GetItemQualityColor(AS.item[idx].rarity)
                    hexcolor = "|c"..hexcolor
                else
                    -- clear icon, link
                    AS.mainframe.listframe.itembutton[x].icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
                    AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    AS.mainframe.listframe.itembutton[x].link = nil
                    AS.mainframe.listframe.itembutton[x].rarity = nil
                end

                AS.mainframe.listframe.itembutton[x].leftstring:SetText(hexcolor..tostring(AS.item[idx].name))
                AS.mainframe.listframe.itembutton[x]:Show()

            else
                --ASprint(MSG_C.DEBUG.."No item, hiding button: "..x)
                AS.mainframe.listframe.itembutton[x]:Hide()
            end
        end
    end

    function AS_CreateButtonHandlers()
        ------------------------------------------------------------------
        --  Create all the script handlers for the buttons
        ------------------------------------------------------------------
        AS[AS_BUTTONBUYOUT] = function()  -- Buyout prompt item
                local _, buyout = AS_GetCost()
                selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
                ASprint(MSG_C.DEBUG.."Buying price: "..ASGSC(buyout), 1)
                
                PlaceAuctionBid("list", selected_auction, buyout) -- The actual buying call
                -- The next item will be the same location as what was just bought
                AScurrentahresult = selected_auction - 1
                AS.prompt:Hide()
                AS.status = STATE.BUYING
        end

        AS[AS_BUTTONBID] = function() -- Bid prompt item
                local bid = AS_GetCost()
                selected_auction = GetSelectedAuctionItem("list") -- The only way it works correctly...
                ASprint(MSG_C.DEBUG.."Bidding price: "..ASGSC(bid), 1)

                PlaceAuctionBid("list", selected_auction, bid)  --the actual bidding call.
                AS.prompt:Hide()
                AS.status = STATE.BUYING
        end

        AS[AS_BUTTONNEXTAH] = function()  -- Go to next item in AH
                ASprint(MSG_C.INFO.."Skipping item...")

                AS.prompt:Hide()
                AS.status = STATE.EVALUATING
        end

        AS[AS_BUTTONNEXTLIST] = function()  -- Go to next item in snatch list
                AScurrentauctionsnatchitem = AScurrentauctionsnatchitem + 1
                AScurrentahresult = 0
                AS.prompt:Hide()
                AS.status = STATE.QUERYING
        end

        AS[AS_BUTTONIGNORE] = function()  -- Ignore this item by setting cutoffprice to 0
                local name = AS.item["ASmanualedit"].name
                local listnumber = AS.item['ASmanualedit'].listnumber
                
                if not AS.item[listnumber].ignoretable then
                    AS.item[listnumber].ignoretable = {}
                end
                
                AS.item[listnumber].ignoretable[name] = {}
                AS.item[listnumber].ignoretable[name].cutoffprice = 0
                AS.item[listnumber].ignoretable[name].quality = quality
                AS.item[listnumber].priceoverride = nil
                AS.item['ASmanualedit'] = nil
                AS_SavedVariables()
                AS.manualprompt:Hide()
        end

        AS[AS_BUTTONEXPENSIVE] = function()  -- Save price filter in manualprompt
                local name = AS.item['ASmanualedit'].name
                local listnumber = AS.item['ASmanualedit'].listnumber

                if AS.item['ASmanualedit'].priceoverride == nil then
                    AS.manualprompt:Hide()
                    return
                end

                if not AS.item[listnumber].ignoretable then
                   AS.item[listnumber].ignoretable = {}
                end

                AS.item[listnumber].ignoretable[name] = {}
                AS.item[listnumber].ignoretable[name].cutoffprice = AS.item['ASmanualedit'].priceoverride
                AS.item[listnumber].ignoretable[name].quality = quality
                AS.item[listnumber].priceoverride = nil
                AS.item['ASmanualedit'] = nil
                AS_SavedVariables()
                AS.manualprompt:Hide()
        end

        AS[AS_BUTTONDELETE] = function()  -- Delete item
                table.remove(AS.item, AScurrentauctionsnatchitem)
                AS.status = STATE.QUERYING
                AS_ScrollbarUpdate()
        end

        AS[AS_BUTTONDELETEALL] = function()  -- Delete list
                if IsControlKeyDown() then
                    AS.item = {}
                    AS.status = nil
                    ASsavedtable = nil
                    AS_ScrollbarUpdate()
                end
        end

        AS[AS_BUTTONUPDATE] = function()  -- Update saved item with prompt item
                local  name, texture, _, quality = GetAuctionItemInfo("list", AScurrentahresult);
                local link = GetAuctionItemLink("list", AScurrentahresult)
                
                if AS.item[AScurrentauctionsnatchitem] then

                    AS.item[AScurrentauctionsnatchitem].name = name
                    AS.item[AScurrentauctionsnatchitem].icon = texture
                    AS.item[AScurrentauctionsnatchitem].link = link
                    AS.item[AScurrentauctionsnatchitem].rarity = quality
                    AScurrentahresult = AScurrentahresult - 1  --redo this item :)
                    AS.status = STATE.EVALUATING
                    AS_ScrollbarUpdate()
                end
        end

        AS[AS_BUTTONFILTERS] = function()  -- Open manualprompt filters
                ASprint(MSG_C.EVENT.."Opening manual edit filters")
                AS.prompt:Hide()
                AS.optionframe.manualpricebutton:Click()
        end
    end

    function AS_AddItem()
        --this is when they hit enter and something is in the box
        local item_name = AS.mainframe.headerframe.editbox:GetText()
        
        if not item_name or (string.find(item_name,'achievement:*')) then
            ASprint(MSG_C.ERROR.."There's nothing valid in the editbox")
            AS.mainframe.headerframe.editbox:SetText("")
            return false
        end

        ASprint(MSG_C.INFO.."Item name: "..item_name, 1)

        local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(item_name)
        local new_id = table.maxn(AS.item) + 1
        
        AS.item[new_id] = {}

        if itemLink then
            ASprint(MSG_C.INFO.."New Item name: "..itemName)
            ASprint(MSG_C.INFO.."Link found "..itemLink)
            AS.item[new_id].name = itemName
            AS.item[new_id].icon = itemTexture
            AS.item[new_id].link = itemLink
            AS.item[new_id].rarity = itemRarity
        else
            ASprint(MSG_C.INFO.."nothing found for "..item_name)
            local _, _, itemString = string.find(item_name, "^|c%x+|H(.+)|h%[.*%]")  --see wowwiki, itemlink.  removes brackets and crap
            
            if not itemString then
                itemString = item_name
            end
            AS.item[new_id].name = itemString
        end

        AS.mainframe.headerframe.editbox:SetText("")
        AS_SavedVariables()
        AS_ScrollbarUpdate()
    end

    function AS_MoveListButton(orignumber, insertat)

        if not insertat then
            local mouseoverbutton = GetMouseFocus()
            
            if not mouseoverbutton.buttonnumber then
                ASprint(MSG_C.ERROR.."No item to trade place with")
                return false
            end
            insertat = mouseoverbutton.buttonnumber + FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
        end

        if insertat == orignumber then -- No moving happened
           return false
        end

        ASprint(MSG_C.INFO.."Move from: "..orignumber.." to: "..insertat)
        -- Get the value we want to move
        local ASmoveme = {}
        AS_tcopy(ASmoveme, AS.item[orignumber])

       if insertat > orignumber then  --we moved down the list
          table.insert(AS.item, insertat + 1, ASmoveme)
          table.remove(AS.item, orignumber)
       else -- we moved up the list
           table.remove(AS.item, orignumber)
           table.insert(AS.item, insertat, ASmoveme)
       end

       AShidetooltip()
       AS_ScrollbarUpdate()
       AS_SavedVariables()
       return true
    end

    function AS_ChatFrame_OnHyperlinkShow(self, link, text, button)

        if IsShiftKeyDown() and link then
            ASprint(MSG_C.INFO.."OnHyperLinkShow Called")

            if string.find(link, 'achievement:*') or string.find(link,'spell:*') then
                return false
            end

            ASprint(MSG_C.INFO.."Link for: "..text)

            if AS.mainframe.headerframe.editbox:HasFocus() then
                AS.mainframe.headerframe.editbox:SetText(text)
            end
        end
    end

    function AS_ContainerFrameItemButton_OnModifiedClick(self)

        if IsShiftKeyDown() and AS.mainframe.headerframe.editbox:HasFocus() then
            local bag, item = self:GetParent():GetID(), self:GetID()
            local link = GetContainerItemLink(bag, item)

            ASprint(MSG_C.INFO.."OnModifiedLink Called")
            ASprint(MSG_C.INFO.."Link: "..link)

            AS.mainframe.headerframe.editbox:SetText(link)
            BrowseName:SetText(link)
        elseif IsShiftKeyDown() and AS.manualprompt.notes:HasFocus() then
            local bag, item = self:GetParent():GetID(), self:GetID()
            local link = GetContainerItemLink(bag, item)

            ASprint(MSG_C.INFO.."OnModifiedLink Called")
            ASprint(MSG_C.INFO.."Link: "..link)

            AS.manualprompt.notes:SetText(AS.manualprompt.notes:GetText()..link)
        end
    end

--[[//////////////////////////////////////////////////

    AUCTION HOUSE FUNCTIONS

    AS_QueryAH, AS_Evaluate, AS_IsEndPage,
    AS_IsEndResults, AS_IsShowPrompt, AS_CutoffPrice,
    AS_GetCost, AS_IsAlwaysIgnore

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    -- STATE.QUERYING
    function AS_QueryAH()

        if not AScurrentauctionsnatchitem then
            AScurrentauctionsnatchitem = 1
        end
        
        if (AScurrentauctionsnatchitem > table.maxn(AS.item)) then
            ASprint(MSG_C.INFO.."Nothing to process. Reset", 1)

            AS.status = nil
            AScurrentauctionsnatchitem = 1
            AS.mainframe.headerframe.stopsearchbutton:Disable()
            return false
        end

        local item = AS.item[AScurrentauctionsnatchitem]
        if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
            -- Only proceed if item is not set to ignore. Right click item to bypass the ignore filter.
            if AS.status_override or not item.ignoretable or (item.ignoretable and item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice > 0) then
                ASprint(MSG_C.INFO.."Called query: ("..AScurrentauctionsnatchitem..")|r "..item.name, 1)

                if Auctioneer then
                    ASprint(MSG_C.ERROR.."Auctioneer detected")
                end

                AS.item['LastListButtonClicked'] = AScurrentauctionsnatchitem -- Setup in advanced for manual filters prompt
                AS.mainframe.headerframe.stopsearchbutton:Enable()

                BrowseResetButton:Click()
                BrowseName:SetText(ASsanitize(item.name))
                -- Sort auctions by buyout price, or minimum bid if there's no buyout price
                SortAuctionSetSort("list", "minbidbuyout")
                SortAuctionSetSort("list", "bid")
                SortAuctionSetSort("list", "unitprice")
                AuctionFrameBrowse_Search()

                AScurrentahresult = 0
                AS.status = STATE.WAITINGFORUPDATE
                return true

            else
                ASprint(MSG_C.INFO.."Ignoring query: ("..AScurrentauctionsnatchitem..")|r "..item.name, 1)
                AScurrentauctionsnatchitem = AScurrentauctionsnatchitem + 1
                return AS_QueryAH()
            end
        else
            ASprint(MSG_C.ERROR.."Can't find auction frame object")
        end

        AS.status = nil
        return false
    end

    -- STATE.EVALUATING
    function AS_Evaluate()
        local messagestring
        local showprompt
        local budget, priceperitembid, priceperitembuyout

        if AS.manualprompt:IsVisible() then
            AS.manualprompt:Hide()
        end

        local batch, total = GetNumAuctionItems("list")

        while true do
            
            AScurrentahresult = AScurrentahresult + 1  --next!!

            if AS_IsEndPage(batch, total) then
                ASprint(MSG_C.EVENT.."[ End of page reached ]")
                return false
            elseif AS_IsEndResults(batch, total) then
                ASprint(MSG_C.EVENT.."[ End of AH results: "..total.." ]")
                return false
            end

            -- auction_item:    [1]name, [2]texture, [3]count, [4]quality, [5]canUse, [6]level, [7]levelColHeader,
            --                  [8]minBid, [9]minIncrement, [10]buyoutPrice, [11]bidAmount, [12]highBidder,
            --                  [13]highBidderFullName, [14]owner, [15]ownerFullName, [16]saleStatus, [17]itemId, [18]hasAllInfo
            auction_item = {GetAuctionItemInfo("list", AScurrentahresult)}

            if AS_IsShowPrompt() then
                
                if ASnodoorbell then
                   ASprint(MSG_C.DEBUG.."Attempting to play sound file")
                   PlaySoundFile("Interface\\Addons\\auctionsnatch\\Sounds\\DoorBell.mp3")
                end

                SetSelectedAuctionItem("list", AScurrentahresult)
                --AuctionFrameBrowse_Update()

                AS.status = STATE.WAITINGFORPROMPT
                AS.prompt:Show()
                return true
            end
        end
    end

    function AS_IsEndPage(batch, total)
        -- Stop at the end of page and wait for server to accept a new query
        -- First AuctionFrameBrowse.page = 0
        if AScurrentahresult > batch and total > ((AuctionFrameBrowse.page + 1) * 50) then
            ASprint(MSG_C.INFO.."Current page: "..AuctionFrameBrowse.page.." Current result: "..tostring((AuctionFrameBrowse.page + 1) * 50).."/"..total)
            
            -- BrowseNextPageButton:Click() doesnt work for some reason
            -- so hack into the blizzard ui code to go to the next page
            AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1
            AuctionFrameBrowse_Search()
            --BrowseScrollFrame:SetVerticalScroll(0)

            AScurrentahresult = 0
            AS.status = STATE.WAITINGFORUPDATE
            return true
        end
        return false
    end

    function AS_IsEndResults(batch, total)
        -- End of AH results. Reset and go to the next query
        if not total or AScurrentahresult > batch then

            if AS.status_override then -- Single item search, when right clicking button
                AS.mainframe.headerframe.stopsearchbutton:Click()
                AS.status = nil
                AS.status_override = nil
            else
                AScurrentauctionsnatchitem = AScurrentauctionsnatchitem + 1
                AS.status = STATE.QUERYING
            end
            AScurrentahresult = 0
            return true
        end
        return false
    end

    function AS_IsShowPrompt()
        -- Primary conditional and fill info for prompt if returns true
        local auction_item = auction_item
        local cutoffprice = AS_CutoffPrice(auction_item[1])
        local bid, _, peritembid, peritembuyout = AS_GetCost()

        local buyoutPrice = auction_item[10]
        local minBid = auction_item[8]
        local minIncrement = auction_item[9]
        local name = auction_item[1]
        local count = auction_item[3]
        local owner = auction_item[14]

        -- Filters
        if owner == UnitName('player') then
            ASprint(MSG_C.INFO.."Skipping own auction")
            return false

        elseif cutoffprice == 0 then
            -- 0 is always ignore
            return false

        elseif cutoffprice and ASignorebid and (cutoffprice < peritembuyout) then
            -- Ignore bid, item buyout higher than cutoff price
            return false

        elseif cutoffprice and (cutoffprice <= peritembid) then
            -- Item bid higher than cutoff price
            return false

        elseif AS_IsAlwaysIgnore(name) then
            ASprint(MSG_C.INFO.."Always ignore this name: "..name)
            return false

        elseif buyoutPrice == 0 and (ASignorebid or ASignorenobuyout) then
            -- No buyout, bids disabled or ignore no buyouts enabled
            return false

        elseif auction_item[12] then -- If we are highest bidder
            ASprint(MSG_C.INFO.."We are the high bidder!")
            return false

        elseif AS.item[AScurrentauctionsnatchitem].link and AS.item[AScurrentauctionsnatchitem].name ~= name then
            -- if update was set (A link is provided) then
            -- if the name does NOT match the link, do not show prompt
            return false
        end

        -- Fill prompt info, title, icon, bid or buyout text/buttons
        AS.prompt.quantity:SetText(count)
        AS.prompt.vendor:SetText(AS_BY..": "..(owner or "Unavailable"))
        AS.prompt.icon:SetNormalTexture(auction_item[2])
        if cutoffprice then
            local strcutoffprice = AS_CUTOFF.."\n"..ASGSC(cutoffprice)
            AS.prompt.lowerstring:SetText(strcutoffprice)
        else
            AS.prompt.lowerstring:SetText("")
        end
        -- Set the title
        if quality then
            local _, _, _, hexcolor = GetItemQualityColor(auction_item[4])
            AS.prompt.upperstring:SetText("|c"..hexcolor..name)
        else
            AS.prompt.upperstring:SetText(name)
        end

        -- The buyout button
        if (buyoutPrice == 0) or (cutoffprice and (cutoffprice > peritembid) and (cutoffprice < peritembuyout)) then
            -- Buyout does not exist or cutoff meets bid but not buyout
            AS.prompt[AS_BUTTONBUYOUT]:Disable()
        else
            AS.prompt[AS_BUTTONBUYOUT]:Enable()
        end
        -- The bid button
        if ASignorebid or (peritembid == peritembuyout) then
            -- Ignore bid or bid is the same as buyout
            AS.prompt[AS_BUTTONBID]:Disable()
        else
            AS.prompt[AS_BUTTONBID]:Enable()
        end

        if ASignorebid then -- Show buyout only
            AS.prompt.buyoutonly:Show()

            if AS.prompt.bidbuyout:IsShown() then
                AS.prompt.bidbuyout:Hide()
            end

            if count > 1 then
                AS.prompt.buyoutonly.buyout.single:SetText(ASGSC(peritembuyout).." "..AS_EACH)
                AS.prompt.buyoutonly.buyout.total:SetText(ASGSC(buyoutPrice))
            else
                AS.prompt.buyoutonly.buyout.single:SetText(ASGSC(buyoutPrice))
                AS.prompt.buyoutonly.buyout.total:SetText("")
            end
        else -- Show bid and buyout
            AS.prompt.bidbuyout:Show()

            if AS.prompt.buyoutonly:IsShown() then
                AS.prompt.buyoutonly:Hide()
            end

            if buyoutPrice == 0 or (cutoffprice and (cutoffprice < peritembuyout)) then
                AS.prompt.bidbuyout.bid:SetTextColor(0,1,0,1)
                AS.prompt.bidbuyout.buyout:SetTextColor(1,1,1,1)
            else
                AS.prompt.bidbuyout.buyout:SetTextColor(0,1,0,1)
                AS.prompt.bidbuyout.bid:SetTextColor(1,1,1,1)
            end

            if count > 1 then
                AS.prompt.bidbuyout.each:Show()
                AS.prompt.bidbuyout.bid.single:SetText(ASGSC(peritembid))
                AS.prompt.bidbuyout.bid.total:SetText(ASGSC(bid))
                AS.prompt.bidbuyout.buyout.single:SetText(ASGSC(peritembuyout))
                AS.prompt.bidbuyout.buyout.total:SetText(ASGSC(buyoutPrice))
            else
                AS.prompt.bidbuyout.each:Hide()
                AS.prompt.bidbuyout.bid.single:SetText(ASGSC(bid))
                AS.prompt.bidbuyout.bid.total:SetText("")
                AS.prompt.bidbuyout.buyout.single:SetText(ASGSC(buyoutPrice))
                AS.prompt.bidbuyout.buyout.total:SetText("")
            end
        end

        ASprint(MSG_C.INFO.."Show prompt:|r"..MSG_C.BOOL.." true")
        return true
    end

    function AS_CutoffPrice(name)
        -- Ignore price is the cutoff point where we won't spend more than this price
        local cutoffprice

        if AS.item[AScurrentauctionsnatchitem].ignoretable and AS.item[AScurrentauctionsnatchitem].ignoretable[name] then
            cutoffprice = AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice
            --ASprint(MSG_C.INFO.."Cutoff price "..tostring(name)..": "..tostring(cutoffprice))
        else
            cutoffprice = nil
        end
        return cutoffprice
    end

    function AS_GetCost()
        -- If bidAmount = 0 that means no one ever bid on it
        -- minBid will always contain the original posted price (ignores existing bids)
        local bid, peritembid, peritembuyout
        local auction_item = auction_item
        local count = auction_item[3]
        local minBid = auction_item[8]
        local minIncrement = auction_item[9]
        local buyoutPrice = auction_item[10]
        local bidAmount = auction_item[11]

        bid = minIncrement + math.max(bidAmount, minBid) -- BidAmount or minBid
        peritembid = bid * (1/count)
        peritembuyout = buyoutPrice * (1/count)

        return bid, buyoutPrice, peritembid, peritembuyout
    end

    function AS_IsAlwaysIgnore(name)

        if AS.item[AScurrentauctionsnatchitem].ignoretable and AS.item[AScurrentauctionsnatchitem].ignoretable[name] then
            if AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice == 0 then
                return true
            end
        end
        return false
    end
