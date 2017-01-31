
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

    \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]


STATE = {
    ['QUERYING'] = 1,
    ['WAITINGFORUPDATE'] = 2,
    ['EVALUATING'] = 3,
    ['WAITINGFORPROMPT'] = 4,
    ['BUYING'] = 5
}

MSG_C = {
    ['ERROR'] = "|cffFC357C",
    ['INFO'] = "|cffB5EDFF",
    ['EVENT'] = "|cff35FCB5",
    ['DEBUG'] = "|cffE0FC35",
    ['DEFAULT'] = "|cff765EFF",
    ['BOOL'] = "|cff2BED48"
}

AS_FRAMEWHITESPACE = 10
AS_BUTTON_HEIGHT = 23
AS_GROSSHEIGHT = 420
AS_HEADERHEIGHT = 120
AS_LISTHEIGHT = AS_GROSSHEIGHT-AS_HEADERHEIGHT
AS = {}
AS.elapsed=0
AS.scrollelapsed=0
ASfirsttime = false

itemRarityColors = {
   [-1] = "|cffffff9a", -- all (ah: -1)
   [0] = "|cff9d9d9d", -- poor (ah: 0)
   [1] = "|cffffffff", -- common (ah: 1)
   [2] = "|cff1eff00", -- uncommon (ah: 2)
   [3] = "|cff0070dd", -- rare (ah: 3)
   [4] = "|cffa335ee"  -- epic (ah: 4)
   --[7] = "|cffff8000", -- legendary (not in ah index)
   --[8] = "|cffe6cc80", -- artifact (not in ah index)
}

dropdown_labels = {
    ["copperoverride"] = "Copper override",
    ["ASnodoorbell"] = AS_DOORBELLSOUND,
    ["ASignorebid"] = "Ignore bids",
    ["ASignorenobuyout"] = "Ignore no buyout"
}

--[[//////////////////////////////////////////////////

    FUNCTIONS TRIGGERED VIA XML
    auctionsnatch.xml

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

        AScreatemainframe()
        AScreateprompt()
        AScreatemanualprompt()

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
            ASprint(MSG_C.INFO..event)

            if AS.status == STATE.BUYING then
                AS.status = STATE.EVALUATING
            end

        elseif event == "AUCTION_HOUSE_SHOW" then

            if not ASauctiontab then
                AScreateauctiontab()
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

        if ASsavedtable then
            if ASsavedtable[serverName] then

                AS_tcopy(AS.item, ASsavedtable[serverName])

                if ASsavedtable[serverName]["test"] then
                    ASprint("test = "..ASsavedtable[serverName]["test"])
                end

                if ASsavedtable[serverName].ASautostart ~= nil then
                    ASautostart = ASsavedtable[serverName].ASautostart
                    --ASprint("Auto start = "..MSG_C.BOOL..""..tostring(ASautostart))
                end
                if ASsavedtable[serverName].ASautoopen ~= nil then
                    ASautoopen = ASsavedtable[serverName].ASautoopen
                    --ASprint("Auto open = "..MSG_C.BOOL..""..tostring(ASautoopen))
                end
                if ASsavedtable[serverName].ASnodoorbell ~= nil then
                    ASnodoorbell = ASsavedtable[serverName].ASnodoorbell
                    --ASprint("Doorbell sound = "..MSG_C.BOOL..""..tostring(ASnodoorbell))
                end
                if ASsavedtable[serverName].ASignorebid ~= nil then
                    ASignorebid = ASsavedtable[serverName].ASignorebid
                    --ASprint("Ignore bid = "..MSG_C.BOOL..""..tostring(ASignorebid))
                end
                if ASsavedtable[serverName].ASignorenobuyout ~= nil then
                    ASignorenobuyout = ASsavedtable[serverName].ASignorenobuyout
                    --ASprint("Ignore no buyout = "..MSG_C.BOOL..""..tostring(ASignorenobuyout))
                end

            else
                ASprint(MSG_C.EVENT.."New server found")

                if not ASfirsttime then
                    ASfirsttime = true
                end
            end

        else
            ASprint(MSG_C.ERROR.."Nothing saved :(")
        end

        -- Verify settings, otherwise set default
        if ASautostart == nil then
            ASprint(MSG_C.EVENT.."Auto start not found")
            ASautostart = true
        end
        if ASautoopen == nil then
            ASprint(MSG_C.EVENT.."Auto open not found")
            ASautoopen = true
        end
        if AS.mainframe then
            AS.mainframe.headerframe.autostart:SetChecked(ASautostart)
            AS.mainframe.headerframe.autoopen:SetChecked(ASautoopen)
        end
        -- Other settings
        if ASnodoorbell == nil then
            ASprint(MSG_C.EVENT.."Doorbell not found")
            ASnodoorbell = true
        end
        if ASignorebid == nil then
            ASprint(MSG_C.EVENT.."Ignore bid not found")
            ASignorebid = false
        end
        if ASignorenobuyout == nil then
            ASprint(MSG_C.EVENT.."Ignore no buyout not found")
            ASignorenobuyout = false
        end

        -- font size testing and adjuting height of prompt
        local _, height = GameFontNormal:GetFont()
        local new_height = (height * 10) + ((AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE)*6)  -- LINES, 5 BUTTONS + 1 togrow on
        
        ASprint(MSG_C.DEBUG.."Font height: "..height)
        ASprint(MSG_C.DEBUG.."New prompt height: "..new_height)
        AS.prompt:SetHeight(new_height)

        -- Generate scroll bar items
        AS_ScrollbarUpdate()
    end

    function AS_Main(input)
        -- this is called when we type /AS or clicks the AS tab
        ASprint(MSG_C.EVENT.."Excelsior!", 1)
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
        local serverName = GetRealmName()

        ASprint(MSG_C.EVENT.."[ Saving changes ]")

        if AS and AS.item then
            if not ASsavedtable then
                ASsavedtable={}
                ASsavedtable.copperoverride = true
            end

            ASsavedtable[serverName]={}
            AS_tcopy(ASsavedtable[serverName], AS.item)
        else
            ASprint(MSG_C.ERROR.."Nothing found to save")
        end

        if AS.mainframe then
            -- check boxes
            ASsavedtable[serverName].ASautostart = ASautostart
            ASsavedtable[serverName].ASautoopen = ASautoopen
            ASsavedtable[serverName].ASnodoorbell = ASnodoorbell
            ASsavedtable[serverName].ASignorebid = ASignorebid
            ASsavedtable[serverName].ASignorenobuyout = ASignorenobuyout
        else
            ASprint(MSG_C.ERROR.."Checkboxes not found to save")
        end
    end

    function ASdropDownMenu_Initialise(self, level)
        --drop down menues can have sub menues. The value of level determines the drop down sub menu tier
        local level = level or 1 
        local serverName = GetRealmName()

        if level == 1 then
            local info = UIDropDownMenu_CreateInfo();
            local key, value

            --- Profile/Server list
            info.text = "Import list"
            info.hasArrow = true
            info.value = "Import"
            UIDropDownMenu_AddButton(info,level)

            if ASsavedtable then
                --- Copper override first
                info.text = dropdown_labels["copperoverride"]
                info.value = "copperoverride"
                info.checked = ASsavedtable.copperoverride
                info.hasArrow = false
                info.func =  ASdropDownMenuItem_OnClick
                info.owner = self:GetParent()
                UIDropDownMenu_AddButton(info,level)
                --- Other settings
                for key, value in pairs(ASsavedtable[serverName]) do
                    if dropdown_labels[key] then -- options
                        info.text = dropdown_labels[key]
                        info.value = key
                        if type(value) == "boolean" then
                            info.checked = value
                        end
                        info.hasArrow = false
                        info.func =  ASdropDownMenuItem_OnClick
                        info.owner = self:GetParent()
                        UIDropDownMenu_AddButton(info,level)
                    end
                end
            end
        elseif level == 2 and UIDROPDOWNMENU_MENU_VALUE == "Import" then
            local info = UIDropDownMenu_CreateInfo();
            local key, value

            if ASsavedtable then
                for key, value in pairs(ASsavedtable) do
                    if not dropdown_labels[key] then -- Found a server

                        info.text = key
                        info.value = key
                        if key == serverName then -- indicate which list is being used
                            info.checked = true
                        else
                            info.checked = false
                        end
                        info.hasArrow = false
                        info.func =  ASdropDownMenuItem_OnClick
                        info.owner = self:GetParent()
                        UIDropDownMenu_AddButton(info, level)
                    end
                end
            end
        else
            local info = UIDropDownMenu_CreateInfo();
            
            info.text = AS_NODATA
            info.value = nil
            info.hasArrow = false
            info.owner = self:GetParent()
            UIDropDownMenu_AddButton(info,level)
        end
    end

    function ASdropDownMenuItem_OnClick(self)
        -- this is where the actual importing takes place
        local serverName = GetRealmName();
        ASprint("self.value: "..tostring(self.value))

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
        end

        if not (self.value == serverName) then  --dont import ourself
          --table.insert doesnt work.. grrrrrr!!!
            local index,temptable -- TODO: To be reviewed to may create more lists and just switch between them (per server).
            for index,temptable in pairs(ASsavedtable[self.value]) do
                if type(temptable) == "table" then
                    if temptable["name"] then  --just some redundancy checking
                        local tablecopy = {}
                        AS_tcopy(tablecopy,temptable) -- this is an unfortunate and slow necessity because table.insert doesnt copy tables.
                        table.insert(AS.item,tablecopy)
                    end
                end
            end
        end

        AS_ScrollbarUpdate()
    end

--[[//////////////////////////////////////////////////

    SECONDARY FUNCTIONS

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
                local bid, buyout
                _, buyout = ASgetcost(AScurrentahresult)
                 selected_auction = GetSelectedAuctionItem("list")
                 ASprint("Index: "..selected_auction)
                 --ASprint("should buy index: "..selected_auction)
                 --ASprint("Buyout: "..buyout.." index: "..AScurrentahresult)
                 PlaceAuctionBid("list",selected_auction,buyout)  --the actual buying call.  Requires a hardware event?
                 --the next item will be the same location as what was just bought, so no need to increment
                 AScurrentahresult = AScurrentahresult - 1
                 ASprint("result index: "..AScurrentahresult)
                 AS.prompt:Hide()
                 AS.status = STATE.BUYING
        end

        AS[AS_BUTTONBID] = function() -- Bid prompt item

                ASprint("AS.bid called.  current ah result="..tostring(AScurrentahresult))
                selected_auction = GetSelectedAuctionItem("list")
                 local bid,buyout
                 bid,_=ASgetcost(selected_auction)

                 PlaceAuctionBid("list",selected_auction,bid)  --the actual buying call.  Requires a hardware event?


                 --AS.status=EVALUATING --OMG here's the bug.  why would this be different from the buying button???!?!?!?   im dumb?
                 AS.prompt:Hide()
                 AS.status=STATE.BUYING
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
                AS.mainframe.headerframe.stopsearchbutton:Click()
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
        end
    end

--[[//////////////////////////////////////////////////

    AUCTION HOUSE FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    -- STATE.QUERYING
    function AS_QueryAH()

        if not AScurrentauctionsnatchitem then
            AScurrentauctionsnatchitem = 1
        end
        
        if (AScurrentauctionsnatchitem > table.maxn(AS.item)) or (AScurrentauctionsnatchitem < 1) then
            ASprint(MSG_C.INFO.."Nothing to process. RESET")

            AS.status = nil
            AScurrentauctionsnatchitem = 1
            AS.mainframe.headerframe.stopsearchbutton:Disable()
            return false
        end

        if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
            ASprint(MSG_C.INFO.."Called query: ("..AScurrentauctionsnatchitem..") "..AS.item[AScurrentauctionsnatchitem].name)

            if Auctioneer then
                ASprint(MSG_C.ERROR.."Auctioneer detected")
            end

            if AS.item[AScurrentauctionsnatchitem].name then
                AS.item['LastListButtonClicked'] = AScurrentauctionsnatchitem -- Setup in advanced for manual filters prompt
                AS.mainframe.headerframe.stopsearchbutton:Enable()
                BrowseResetButton:Click()
                BrowseName:SetText(ASsanitize(AS.item[AScurrentauctionsnatchitem].name))
                AuctionFrameBrowse_Search()

                -- Sort auctions by buyout price, or minimum bid if there's no buyout price
                SortAuctionSetSort("list", "minbidbuyout")
                SortAuctionSetSort("list", "bid")
                SortAuctionSetSort("list", "unitprice")
                SortAuctionApplySort("list")

                AScurrentahresult = 0
                AS.status = STATE.WAITINGFORUPDATE
                return true
            else
                ASprint(MSG_C.ERROR.."Could not find current index in AS.item")
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

            if AS_IsEndPage(total) then
                ASprint(MSG_C.EVENT.."End of page reached")
                return false
            elseif AS_IsEndResults(batch, total) then
                ASprint(MSG_C.EVENT.."End of AH results: "..total)
                return false
            end

            --processing-wise, this here is a very expensive hit
            --so i'm only gonna do it (and similar stuff) here, ONCE, and pass everything in as parametners
            local name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, highBidderFullName, owner, ownerFullName, saleStatus, itemId, hasAllInfo = GetAuctionItemInfo("list", AScurrentahresult)

            if not buyoutPrice and ASignorenobuyout then
                return false
            end

            local cutoffprice = ASgetcutoffprice(name, quality, count)

            showprompt = ASisshowprompt(cutoffprice,name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner,batch,total)

            if showprompt then
                showprompt = false
                
                if ASnodoorbell then
                   ASprint(MSG_C.DEBUG.."Attempting to play sound file")
                   PlaySoundFile("Interface\\Addons\\auctionsnatch\\Sounds\\DoorBell.mp3")
                end

                -- Set the title and icon
                if quality then
                    _,_,_,hexcolor = GetItemQualityColor(quality)
                    AS.prompt.upperstring:SetText("|c"..hexcolor..tostring(name))
                else
                    AS.prompt.upperstring:SetText(name)
                end
                AS.prompt.icon:SetNormalTexture(texture)

                messagestring = AScreatemessagestring(cutoffprice,name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner)
                ASprint("Im through the good ol |c00eeaaff Messagestring |r :(")
                AS.prompt.lowerstring:SetText(messagestring)

                SetSelectedAuctionItem("list", AScurrentahresult)

                AS.status = STATE.WAITINGFORPROMPT
                AS.prompt:Show()
                return true
            end
        end
    end

    function AS_IsEndPage(total)
        -- Stop at the end of page and wait for server to accept a new query
        -- First AuctionFrameBrowse.page = 0
        if AScurrentahresult > 50 and total > ((AuctionFrameBrowse.page + 1) * 50) then
            ASprint(MSG_C.INFO.."Current page: "..AuctionFrameBrowse.page.." Current result: "..tostring((AuctionFrameBrowse.page + 1) * 50).."/"..total)
            
            -- BrowseNextPageButton:Click() doesnt work for some reason
            -- so hack into the blizzard ui code to go to the next page
            AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1
            AuctionFrameBrowse_Search()

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

function ASisshowprompt(cutoffprice,name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner, batch, total)
    --do all the primary conditionals here


    --ASprint("Evaluating Item # |c00ffff00"..AScurrentahresult.."|r, "..name.." x"..count..".  Bid is "..minBid..".  PerItemBuyout is "..math.floor(buyoutPrice/count))


    if not (name) then
        return false
    end

      --if we're allready the highbidder
     if(highBidder) then
        ASprint("WE are the highbidder!  Returning |c00ff0000 false |r")
        return false
     end

     --disable the buyout button if there's no buyout
     if (buyoutPrice > 0) then
        AS.prompt[AS_BUTTONBUYOUT]:Enable()  --enable buyout button
     else
        AS.prompt[AS_BUTTONBUYOUT]:Disable()
    --    ASprint("disabled buyout due to no buyout on ah")
     end

     if (((buyoutPrice > 0) and (minBid + minIncrement >= buyoutPrice)) or (ASignorebid)) then
        AS.prompt[AS_BUTTONBID]:Disable()
      --  ASprint("disabled bid .  bid is same price as buyout")
     else
        AS.prompt[AS_BUTTONBID]:Enable()  --enable buyout button
     end


     if (ASisalwaysignore(name)) then
        ASprint("always ignore this name!  Returning |c00ff0000 false |r")
        return false
     end

     if ((tonumber(buyoutPrice) <= 0) and (ASignorebid)) then  --no buyout.. ignore bid.. nothing to do!
        ASprint("returning false in isshowprompt Buyoutprice = "..buyoutPrice.."     ignorebid = "..tostring(ASignorebid))
        return false
     end


     --get ignore price
     if not (cutoffprice) then  --since getmsassagestring is called from multipla places
        cutoffprice = ASgetcutoffprice(name,quality,count)
    end
     if(cutoffprice) then

         if(cutoffprice == 0) then
            --means always ignore
            return false
         end
         --get cost of current item
        --bid,buyout,peritembid,peritembuyout = ASgetcost(AScurrentahresult)
        bid=minIncrement+math.max(bidAmount,minBid)
        buyout=buyoutPrice
        peritembid = bid/count
        peritembuyout = buyout/count

        if(ASignorebid) then
            if (cutoffprice <= peritembuyout) then
                return false
            end
        else

            --is the buyout price within the cutoff range?
             if (cutoffprice <= peritembid) then
                ASprint("Bid price is higher than cuttof price!  Returning |c00ff0000 false |r")
                return false
             else
                 -- the cutoff price is enough for a bid, but not a buyout
                 --ASprint("|c0000aa00Cutoff price = |c0000aaaa"..cutoffprice.."  peritembid = |c000033da"..peritembid.."  peritembuyout="..peritembuyout)
                  if (cutoffprice > peritembid) and (cutoffprice <= peritembuyout) then
                        AS.prompt[AS_BUTTONBUYOUT]:Disable()
                        --ASprint("disabling buyout button  "..peritembuyout.." above cutoff? of "..cutoffprice)
                  end
             end
        end
     end

     --if update was set (A link is provided) then
     -- if the name does NOT match the link,
     --do not show prompt
     if(AS.item[AScurrentauctionsnatchitem].link) then
        if  not (AS.item[AScurrentauctionsnatchitem].name == name) then
            return false
        end
     end

     --dont show our own auctions
     if(owner == UnitName("player")) then
        ASprint("Its my auction!  Returning |c00ff0000 false |r")
        return false
     end

     ASprint("returning |c0000ff00 true |r from ASisshowprompt()")
     return true


end






function ASgetcutoffprice(name,quality,count)
--ignore price is the cutoff point where we won't spend more than this price
   local cutoffprice
  -- ASprint("|c0000aaff ASgetcutoffprice start.")

     if(AS.item[AScurrentauctionsnatchitem].priceoverride) then  --override has priority
        cutoffprice=tonumber(AS.item[AScurrentauctionsnatchitem].priceoverride)

      --check if this item is on our ignore list
     elseif (AS.item[AScurrentauctionsnatchitem].ignoretable) then
        if(AS.item[AScurrentauctionsnatchitem].ignoretable[name]) then
           --newer versions, this is a table, to hold more data
           if(type(AS.item[AScurrentauctionsnatchitem].ignoretable[name]) == "table") then
               --new version
               cutoffprice=AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice
          --     ASprint("ignore price set "..name.."="..cutoffprice)
           else
              --old version
              cutoffprice = AS.item[AScurrentauctionsnatchitem].ignoretable[name]
           --   ASprint("ignore price set "..name.."="..cutoffprice)
              --update to the new format
              AS.item[AScurrentauctionsnatchitem].ignoretable[name] = {}
              AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice = cutoffprice
              AS.item[AScurrentauctionsnatchitem].ignoretable[name].quality = quality
           end
       end
     else
        --something else is ignored - but not this item
       -- ASprint("No ignore price found on:"..name )
        cutoffprice = nil
     end
   return cutoffprice
end

function AScreatemessagestring(cutoffprice, name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner)

   local bid,buyout,peritembid,peritembuyout
   local messagestring

  -- ASprint("Heading on INto good'ole |c00ffaaee MESsagestring! |r function.   ")

   if not (name) then
        --local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner
        name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner=GetAuctionItemInfo("list",AScurrentahresult);
    end
    if not (cutoffprice) then  --since getmsassagestring is called from multipla places
        cutoffprice = ASgetcutoffprice(name,quality,count)
    end
   bid,buyout,peritembid,peritembuyout = ASgetcost(AScurrentahresult,count, minBid, minIncrement, buyoutPrice, bidAmount)

    -- local lines=6  --cant use lines, because we don't want the buttons to move, so a person can just rapid fire click 'buy' or whatever
    --set the prompt text

    if not (name) then return false end;
    if(quality) then
        ASprint("quality Withinmessagestring= "..quality)
        ASprint("   Itemraritycolors = "..itemRarityColors[quality].."COLOR")
     else
        quality = 1
        ASprint("quality = nonexistent")
     end


    AS.prompt.quantity:SetText(count)
    AS.prompt.vendor:SetText(AS_BY..": "..(owner or "Unavailable"))

    if ASignorebid then
        AS.prompt.buyoutonly:Show()

        if AS.prompt.bidbuyout:IsShown() then
            AS.prompt.bidbuyout:Hide()
        end

        AS.prompt.buyoutonly.buyout.total:SetText(ASGSC(buyout))

        if count > 1 then
            AS.prompt.buyoutonly.buyout.single:SetText(ASGSC(peritembuyout).." "..AS_EACH)
        else
            AS.prompt.buyoutonly.buyout.single:SetText("")
        end
    else
        AS.prompt.bidbuyout:Show()

        if AS.prompt.buyoutonly:IsShown() then
            AS.prompt.buyoutonly:Hide()
        end

        if cutoffprice and tonumber(cutoffprice) < tonumber(peritembuyout) then
            AS.prompt.bidbuyout.bid:SetTextColor(0,1,0,1)
            AS.prompt.bidbuyout.buyout:SetTextColor(1,1,1,1)
        else
            AS.prompt.bidbuyout.buyout:SetTextColor(0,1,0,1)
            AS.prompt.bidbuyout.bid:SetTextColor(1,1,1,1)
        end

        AS.prompt.bidbuyout.bid.total:SetText(ASGSC(bid))
        AS.prompt.bidbuyout.buyout.total:SetText(ASGSC(buyout))

        if count > 1 then
            AS.prompt.bidbuyout.each:Show()
            AS.prompt.bidbuyout.bid.single:SetText(ASGSC(peritembid))
            AS.prompt.bidbuyout.buyout.single:SetText(ASGSC(peritembuyout))
        else
            AS.prompt.bidbuyout.each:Hide()
            AS.prompt.bidbuyout.bid.single:SetText("")
            AS.prompt.bidbuyout.buyout.single:SetText("")
        end
    end


      messagestring=""


    if (cutoffprice and tonumber(cutoffprice) > 0) then

           messagestring=messagestring..""..AS_CUTOFF.."\n"
           messagestring=messagestring..ASGSC(tonumber(cutoffprice))
    else
        ASprint("|c00ffaaaaNo Cutoff price found!")
    end


    return messagestring
end

-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------


function ASgetcost(listing,count, minBid, minIncrement, buyoutPrice, bidAmount)
   --if bidAmount = 0 that means no one ever bid on it
   --minBid will always contain the original posted price.  Ignores bids.
   --so we need to bid minincrement+max(bid,amount)
   local bid,buyout,peritembid,peritembuyout
   if not listing then listing = AScurrentahresult end;
    if not (count or minBid or minIncrement or buyoutPrice or bidAmount) then
        ASprint("|c00ff5500 Small problem in ASgetcost")
        _, _, count, _, _, _, _, minBid, minIncrement, buyoutPrice, bidAmount, _, _=GetAuctionItemInfo("list",listing);
    end
    if not (count or minBid or minIncrement or buyoutPrice or bidAmount) then
        ASprint(count)
        ASprint(minBid)
        ASprint (minIncrement)
        ASprint(buyoutPrice)
        ASprint(bidAmount)
        ASprint("|c00ff0000 HUGE problem in ASgetcost")
        result = {GetAuctionItemInfo("list",listing)}
        ASprint(result)

    end

   bid=minIncrement+math.max(bidAmount,minBid)

   buyout=buyoutPrice
   peritembid = math.floor(bid/count)
   peritembuyout = math.floor(buyout/count)

   ASprint("|c00ff00aa---------------------------math.floor testing-------------------------")
   ASprint("|c00ff00aa ASGSC(buyout) = "..ASGSC(buyout))
   ASprint("|c00ff00aa buyout = "..buyout)
   ASprint("|c00ff00aa count = "..count)
   ASprint("|c00ff00aa  buyout/count = "..buyout/count)
   ASprint("|c00ff00aa  floor(buyout/count) = "..math.floor(buyout/count))

   return bid,buyout,peritembid,peritembuyout
end

function ASisalwaysignore(name)

    local cutoffprice

    if (AS.item[AScurrentauctionsnatchitem].ignoretable) then
        if(AS.item[AScurrentauctionsnatchitem].ignoretable[name]) then
           if(type(AS.item[AScurrentauctionsnatchitem].ignoretable[name]) == "table") then
               cutoffprice=AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice
               --ASprint("ignore price set "..name.."="..cutoffprice)
               if(cutoffprice == 0) then
                    return true
               end
            end
        end
    end

    --if  not (AS.item[AScurrentauctionsnatchitem].name == name) then
    --end


    return false
end
