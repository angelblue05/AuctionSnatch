
--[[//////////////////////////////////////////////////

    OG DATA STRUCTURES EXPLAINED

    i'm trying something ambitious.  included in the name of my variables is
    the entire parent/child heirarchy
    every variable will be a child of 'AS' eg AS.mainframe
    anything with its parent being AS.mainframe will be AS.mainframe.whatever
    multiple items, buttons, will be AS.mainframe.button[x]

    so name will be very long, and looking like:
    AS.mainframe.listframe.itembuttons[x].lefttexture

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
AO_FIRSTRUN_AH = false
ACTIVE_TABLE = nil
AS_COPY = nil
AS_SKIN = false
AO_RENAME = nil

AS = { -- Contains everything
    ['item'] = {},
    ['currentauction'] = 1,
    ['currentauctionitem'] = {},
    ['currentresult'] = 0,
    ['elapsed'] = 0,
    ['selected'] = {},
    ['override'] = false,
    ['soldauctions'] = {},
    ['boughtauctions'] = {},
    ['events'] = {['AUCTIONS'] = {}, ['SOLD'] = {}, ['REMOVE'] = {}}
}

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
    ['BOOL'] = "|cff2BED48",
    ['WARN'] = "|cffDBD3AF"
}

OPT_LABEL = {
    ['copperoverride'] = L[10004],
    ['ASnodoorbell'] = L[10001],
    ['ASignorebid'] = L[10002],
    ['ASignorenobuyout'] = L[10003],
    ['rememberprice'] = L[10006],
    ['ASautostart'] = L[10007],
    ['ASautoopen'] = L[10008],
    ['AOicontooltip'] = L[10009],
    ['cancelauction'] = L[10005],
    ['searchauction'] = L[10082]
}
OPT_HIDDEN = {
    ['searchoncreate'] = "",
    ['AOoutbid'] = "",
    ['AOsold'] = "",
    ['AOexpired'] = "",
    ['AOchatsold'] = ""
}


--[[//////////////////////////////////////////////////

    FUNCTIONS TRIGGERED VIA XML auctionsnatch.xml

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function OnLoad(self)

        ----- REGISTER FOR EVENTS
            self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
            self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
            self:RegisterEvent("AUCTION_HOUSE_SHOW")
            self:RegisterEvent("AUCTION_HOUSE_CLOSED")
            self:RegisterEvent("VARIABLES_LOADED")

        ------ SOLD/CANCELLED AUCTION
            AS.AO_AuctionSoldFrame = CreateFrame("Frame")
            AS.AO_AuctionSoldFrame:RegisterEvent("CHAT_MSG_SYSTEM")
            AS.AO_AuctionSoldFrame:SetScript("OnEvent", AO_AuctionSold)

        ------ STATIC DIALOG // To get new list name
            StaticPopupDialogs["AS_NewList"] = {
                text = L[10010],
                button1 = L[10011],
                button2 = L[10012],
                OnShow = function (self, data)
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
                exclusive = true,
                preferredIndex = 3  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }
            StaticPopupDialogs["AS_RenameList"] = {
                text = L[10013],
                button1 = L[10014],
                button2 = L[10012],
                OnShow = function (self, data)
                    self.button1:Disable()
                end,
                OnAccept = function (self, data, data2)
                    AS_RenameList(self.editBox:GetText())
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
                exclusive = true,
                preferredIndex = 3  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }

        DEFAULT_CHAT_FRAME:AddMessage(MSG_C.DEFAULT..L[10000])

        ------ SLASH COMMANDS
            SLASH_AS1 = "/AS"
            SLASH_AS2 = "/as"
            SLASH_AS3 = "/As"
            SLASH_AS4 = "/aS"
            SLASH_AS5 = "/Auctionsnatch"
            SLASH_AS6 = "/AuctionSnatch"
            SLASH_AS7 = "/AUCTIONSNATCH"
            SLASH_AS8 = "/auctionsnatch"

            SlashCmdList["AS"] = AS_Main

        if IsAddOnLoaded("Aurora") then -- Verify if Aurora is installed/enabled
            DEFAULT_CHAT_FRAME:AddMessage(MSG_C.DEFAULT.."AuctionSnatch|r: Aurora detected")
            F, C = unpack(Aurora) -- Aurora
            r, g, b = C.r, C.g, C.b -- Aurora
            AS_backdrop = C.media.backdrop
            AS_SKIN = true
        else -- default skin
            AS_backdrop = "Interface\\ChatFrame\\ChatFrameBackground"
            r, g, b = 0.035, 1, 0.78 -- TODO: Make a setting?
        end

        AS_CreateFrames()

        table.insert(UISpecialFrames, AS.mainframe:GetName())
        table.insert(UISpecialFrames, AS.prompt:GetName())
        table.insert(UISpecialFrames, AS.manualprompt:GetName())
    end

    function OnEvent(self, event)

        if event == "VARIABLES_LOADED" then
            ASprint(MSG_C.EVENT.."Variables loaded. Initializing.", 2)
            ASprint(MSG_C.INFO.."Running version: "..GetAddOnMetadata("AuctionSnatch", "Version"), 1)
            
            AS_Initialize()

        elseif event == "AUCTION_OWNED_LIST_UPDATE" then
            --ASprint(MSG_C.EVENT..event)
            AS_RegisterCancelAction()
            AS_RegisterSearchAction()
            -- Get current owner auctions
            if not AO_FIRSTRUN_AH then
                AO_FIRSTRUN_AH = true
                AS.events['AUCTIONS'] = {}

                local _, totalAuctions = GetNumAuctionItems("owner")
                local x
                for x = 1, totalAuctions do
                    local auction = {GetAuctionItemInfo("owner", x)}
                    if not AS.events['AUCTIONS'][auction[1]] then
                        AS.events['AUCTIONS'][auction[1]] = {}
                        AS.events['AUCTIONS'][auction[1]]['icon'] = auction[2]
                    end
                    if x == 1 then -- Verification if we should wipe sold auctions
                        AS.soldauctions = {}
                    end

                    if auction[16] == 1 or auction[3] == 0 then
                        table.insert(AS.soldauctions, {
                            ['name'] = auction[1],
                            ['quantity'] = auction[3],
                            ['icon'] = auction[2],
                            ['price'] = auction[10],
                            ['link'] = GetAuctionItemLink("owner", x),
                            ['buyer'] = auction[12],
                            ['time'] = GetTime() + GetAuctionItemTimeLeft("owner", x),
                            ['timer'] = C_Timer.After(GetAuctionItemTimeLeft("owner", x), function() table.remove(AS.soldauctions, 1) ; AO_OwnerScrollbarUpdate() end)
                        })
                    else
                        table.insert(AS.events['AUCTIONS'][auction[1]], {
                            ['quantity'] = auction[3],
                            ['price'] = auction[10],
                            ['link'] = GetAuctionItemLink("owner", x)
                        })
                    end
                end
            end

            if #AS.events['REMOVE'] > 0 then -- REMOVE Auctions
                ASprint(MSG_C.EVENT.."[ Found removed auction(s) ]")
                local remove = {}
                AS_tcopy(remove, AS.events['REMOVE'])
                AS.events['REMOVE'] = {}

                local x, key, key2, value, value2

                for x = 1, #remove do
                    local item = remove[x]
                    local current_auctions = AO_CurrentOwnedAuctions(item)

                    local saved_auctions = {} -- Copy original auctions to compare
                    if AS.events['AUCTIONS'][item] ~= nil then

                        AS_tcopy(saved_auctions, AS.events['AUCTIONS'][item])

                        if current_auctions then
                            AO_CompareAuctionsTable(current_auctions, saved_auctions)
                        end

                        for key, value in pairs(saved_auctions) do
                            for key2, value2 in pairs(AS.events['AUCTIONS'][item]) do -- delete entry since item expired or was cancelled
                                if type(value) == "table" and type(value2) == "table" then
                                    if value.quantity == value2.quantity and value.price == value2.price then
                                        -- Found match
                                        table.remove(AS.events['AUCTIONS'][item], key2)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if #AS.events['SOLD'] > 0 then -- Sold Auctions
                ASprint(MSG_C.EVENT.."[ Found sold auction(s) ]")
                local sold = {}
                AS_tcopy(sold, AS.events['SOLD'])
                AS.events['SOLD'] = {}

                local x, y, key, key2, value, value2

                for x = 1, #sold do
                    local item = sold[x]['name']
                    local time = sold[x]['time']
                    local current_auctions = AO_CurrentOwnedAuctions(item)
                    local saved_auctions = {}

                    AS_tcopy(saved_auctions, AS.events['AUCTIONS'][item])

                    -- Auctions are visible in the auction house
                    local last_auctions

                    for key = #current_auctions, 1, -1 do
                        value = current_auctions[key]
                        if not last_auctions and (value.sold == 1 or value.quantity == 0) then
                            -- Auction sold
                            last_auctions = value
                        end
                        for y = #saved_auctions, 1, -1 do
                            value2 = saved_auctions[y]
                            if type(value) == "table" and type(value2) == "table" then
                                if value.price == value2.price and value.quantity == value2.quantity and value.sold == 0 then
                                    -- Found match, still exists
                                    table.remove(saved_auctions, y)
                                    break
                                end
                            end
                        end
                    end
                    if saved_auctions[1] and last_auctions then
                        saved_auctions[1].buyer = last_auctions.buyer
                        --saved_auctions[1].link = last_auctions.link
                    end

                    for key, value in pairs(saved_auctions) do
                        if type(value) == "table" then

                            if time - GetTime() > 1 then
                                AS.soldauctions[#AS.soldauctions + 1] = {
                                    ['name'] = item,
                                    ['quantity'] = value.quantity,
                                    ['icon'] = saved_auctions.icon,
                                    ['price'] = value.price,
                                    ['buyer'] = value.buyer,
                                    ['link'] = value.link,
                                    ['time'] = time,
                                    ['timer'] = C_Timer.After(time - GetTime(), function() table.remove(AS.soldauctions, 1) ; AO_OwnerScrollbarUpdate() end) -- 60min countdown
                                }
                            end
                            if ASsavedtable.AOchatsold then
                                ASprint(L[10078]..":|T"..saved_auctions.icon..":0|t"..value.link.."x"..value.quantity.."  "..ASGSC(value.price), 1)
                            end
                            for key2, value2 in pairs(AS.events['AUCTIONS'][item]) do -- delete entry since item was sold
                                if type(value) == "table" and type(value2) == "table" then
                                    if value.price == value2.price and value.quantity == value2.quantity then
                                        -- Found match
                                        table.remove(AS.events['AUCTIONS'][item], key2)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if AS.mainframe.soldlistframe:IsVisible() then
                AO_OwnerScrollbarUpdate()
            end

        elseif event == "AUCTION_ITEM_LIST_UPDATE" then
            --ASprint(MSG_C.INFO..event)
            if AS.status == STATE.BUYING then
                AS.status = STATE.EVALUATING
            end

        elseif event == "AUCTION_HOUSE_SHOW" then

            if not ASauctiontab then
                AS_CreateAuctionTab()
            end

            if ASsavedtable.ASautostart and not ASsavedtable.ASautoopen then
                -- Do nothing
            elseif ASsavedtable.ASautostart and not IsShiftKeyDown() then -- Auto start
                AS.status = STATE.QUERYING
                AS_Main()
            elseif IsShiftKeyDown() then -- Auto start
                AS.status = STATE.QUERYING
                AS_Main()
            elseif ASsavedtable.ASautoopen then
                -- Automatically display frame, just don't auto start
                AS_Main()
            end

            ------ AUCTION HOUSE HOOKS
                if BrowseName then
                    BrowseName:HookScript("OnEditFocusGained", function(self)
                        if AS.status == nil then return false end  --should catch the infinate loop
                        AS.mainframe.headerframe.stopsearchbutton:Click()
                    end)
                end
                -- CANCEL AUCTION BUTTON / STATICPOPUP LISTENER
                if AuctionsCancelAuctionButton then
                    AuctionsCancelAuctionButton:HookScript("PostClick", function(self, button)
                        if button == "LeftButton" then
                            local cancel_frame = _G["StaticPopup1"]
                            if cancel_frame and cancel_frame.which == "CANCEL_AUCTION" then

                                local accept_button = _G["StaticPopup1Button1"]
                                accept_button:SetScript("PreClick", function(self, button)
                                    AO_UntrackCancelledAuction()
                                end)
                            end
                        end
                    end)
                end
                if AuctionsCreateAuctionButton then
                    AuctionsCreateAuctionButton:HookScript("PreClick", function(self, button)
                        local _, item = AS_GetSelected()
                        local startPrice = MoneyInputFrame_GetCopper(StartPrice)
                        local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice)
                        local stackSize = AuctionsStackSizeEntry:GetNumber()
                        local stackNum = AuctionsNumStacksEntry:GetNumber()

                        -- Add auctions to our saved list of auctions
                        for x = 1, stackNum do
                            local auction = {GetAuctionSellItemInfo()}
                            local name = auction[1]
                            local _, link = GetItemInfo(name)

                            if not AS.events['AUCTIONS'][name] then
                                AS.events['AUCTIONS'][name] = {}
                                AS.events['AUCTIONS'][name]['icon'] = auction[2]
                            end
                            local auction_info = {
                                ['quantity'] = stackSize,
                                ['price'] = buyoutPrice,
                                ['link'] = link
                            }

                            if stackSize > 1 and AuctionFrameAuctions.priceType == 1 then
                                auction_info['price'] = buyoutPrice * stackSize
                            end
                            table.insert(AS.events['AUCTIONS'][name], auction_info)
                        end

                        if ASsavedtable.rememberprice and item then
                            ASprint(MSG_C.INFO.."StartPrice:|r "..startPrice)
                            ASprint(MSG_C.INFO.."BuyoutPrice:|r "..buyoutPrice)
                            
                            if stackSize > 1 and AuctionFrameAuctions.priceType == 2 then -- Stack price convert to unit price
                                startPrice = startPrice / stackSize
                                buyoutPrice = buyoutPrice / stackSize
                            end

                            local save = false
                            if tonumber(item.sellbid) ~= startPrice then
                                item.sellbid = startPrice
                                save = true
                            end
                            if tonumber(item.sellbuyout) ~= buyoutPrice then
                                item.sellbuyout = buyoutPrice
                                save = true
                            end

                            if save then
                                AS_SavedVariables()
                            end
                        end
                    end)
                    AuctionsCreateAuctionButton:HookScript("PostClick", function(self, button)
                        -- Search item to view new auctions
                        local _, item = AS_GetSelected()
                        if ASsavedtable.searchoncreate and item then

                            AuctionFrameBrowse.page = 0
                            BrowseName:SetText(ASsanitize(item.name))
                            AuctionFrameBrowse_Search()
                        end
                    end)
                end

        elseif event == "AUCTION_HOUSE_CLOSED" then

            AS.currentauction = 1
            BrowseResetButton:Click()
            AS.manualprompt:Hide()
            AS.mainframe.headerframe.stopsearchbutton:Click()
            
            if ASopenedwithah then  --in case i do a manual /as prompt for testing purposes
                if AS.mainframe then
                    AS.mainframe:Hide()
                end
                ASopenedwithah = false
            else
                AS.mainframe:Hide()
            end
        
        elseif string.match("AUCTION", event) then
            ASprint(MSG_C.INFO..event, 2)
        end
    end

    function OnUpdate(self, elapsed)

        -- This is the Blizzard Update, called every computer clock cycle ~millisecond
        if not elapsed then return end -- Otherwise it will infinite loop

        -- This is needed because sometimes a query completes,
        -- and the results are sent back - but the ah will not accept a query right away.
        -- there is no event that fires when a query is possible, so i just have to spam requests

        if AS.status then
            AS.elapsed = AS.elapsed + elapsed

            if AS.elapsed > 0.1 then
                AS.elapsed = 0

                if AS.status == STATE.QUERYING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("list")
                    if canQuery then
                        ASprint(MSG_C.EVENT.."[ Start querying ]")
                        AS_QueryAH()
                    end
                
                elseif AS.status == STATE.WAITINGFORUPDATE then
                    ASprint(MSG_C.EVENT.."[ Waiting for update event ]")
                    AS.status = STATE.EVALUATING
                
                elseif AS.status == STATE.EVALUATING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("list")
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
        hooksecurefunc("ChatEdit_InsertLink", AO_InsertLink)

        if (playerName == nil) or (playerName == UNKNOWNOBJECT) or (playerName == UNKNOWNBEING) then
            return
        end

        if ASsavedtable and ASsavedtable[serverName] then
            AS_LoadTable(serverName)
        else
            ASprint(MSG_C.EVENT.."New server found")
            AS_template(serverName)
        end

        -- font size testing and adjuting height of prompt
        local _, height = GameFontNormal:GetFont()
        local new_height = (height * 10) + ((AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE) * 6)  -- LINES, 5 BUTTONS + 1 togrow on
        
        ASprint(MSG_C.DEBUG.."Font height:|r "..height, 2)
        ASprint(MSG_C.DEBUG.."New prompt height:|r "..new_height, 2)
        AS.prompt:SetHeight(new_height)
        AS.manualprompt:SetHeight(new_height)

        -- Generate scroll bar items
        AS_ScrollbarUpdate()
        -- Clean auction sold list
        AO_OwnerScrollbarUpdate()
    end

    function AS_Main(input)
        -- this is called when we type /AS or clicks the AS tab
        ASprint(MSG_C.INFO.."Excelsior!", 1)
        if input then input = string.lower(input) end
       
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

            elseif input == "soldtest" then
                test_sold()
                ASprint("Generating fake auctions")
                return

            elseif input == "sound outbid" then
                ASsavedtable.AOoutbid = not ASsavedtable.AOoutbid
                ASprint(MSG_C.INFO.."Outbid sound:|r "..MSG_C.BOOL..tostring(ASsavedtable.AOoutbid), 1)
                if ASsavedtable.AOoutbid then
                   ASprint(MSG_C.DEBUG.."Attempting to play 'outbid' sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Outbid.mp3")
                end
                return
            elseif input == "sound sold" then
                ASsavedtable.AOsold = not ASsavedtable.AOsold
                ASprint(MSG_C.INFO.."Sold sound:|r "..MSG_C.BOOL..tostring(ASsavedtable.AOsold), 1)
                if ASsavedtable.AOsold then
                    --PlaySound("LOOTWINDOWCOINSOUND")
                    ASprint(MSG_C.DEBUG.."Attempting to play 'sold' sound file")
                    PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Sold.mp3")
                end
                return
            elseif input == "sound expired" then
                ASsavedtable.AOexpired = not ASsavedtable.AOexpired
                ASprint(MSG_C.INFO.."Expired sound:|r "..MSG_C.BOOL..tostring(ASsavedtable.AOexpired), 1)
                if ASsavedtable.AOexpired then
                   ASprint(MSG_C.DEBUG.."Attempting to play 'expired' sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Expired.mp3")
                end
                return
            elseif input == "chat sold" then
                ASsavedtable.AOchatsold = not ASsavedtable.AOchatsold
                ASprint(MSG_C.INFO.."Chat alert for sold:|r "..MSG_C.BOOL..tostring(ASsavedtable.AOchatsold), 1)
                return
            elseif input == "debug" then
                ASdebug = not ASdebug
                ASprint(MSG_C.INFO.."Debug:|r "..MSG_C.BOOL..tostring(ASdebug), 1)
                return
            elseif input == "copperoverride" then
                ASsavedtable.copperoverride = not ASsavedtable.copperoverride
                ASprint(MSG_C.INFO.."Value in copper:|r "..MSG_C.BOOL..tostring(ASsavedtable.copperoverride), 1)
                return
            elseif input == "searchoncreate" then
                ASsavedtable.searchoncreate = not ASsavedtable.searchoncreate
                ASprint(MSG_C.INFO.."Search on creating auction: "..MSG_C.BOOL..tostring(ASsavedtable.searchoncreate), 1)
                return
            elseif input == "cancelauction" then
                ASsavedtable.cancelauction = not ASsavedtable.cancelauction
                ASprint(MSG_C.INFO.."Cancel auction on right-click: "..MSG_C.BOOL..tostring(ASsavedtable.cancelauction), 1)
                return
            elseif input == "searchauction" then
                ASsavedtable.searchauction = not ASsavedtable.searchauction
                ASprint(MSG_C.INFO.."Search owned auction on double-click: "..MSG_C.BOOL..tostring(ASsavedtable.searchauction), 1)
                return
            end

        else
            ASprint(MSG_C.ERROR.."Mainframe not found!", 1)
            return false
        end

        AS.mainframe:Show()
    end

    function AS_SavedVariables()
        ASprint(MSG_C.EVENT.."[ Saving changes ]")

        if AS and AS.item then
            if not ASsavedtable then
                ASsavedtable = {}
                ASsavedtable.searchoncreate = true
                ASsavedtable.copperoverride = true
                ASsavedtable.cancelauction = true
                ASsavedtable.searchauction = true
                ASsavedtable.rememberprice = true
                ASsavedtable.ASautostart = false
                ASsavedtable.ASautoopen = true
                ASsavedtable.AOoutbid = true
                ASsavedtable.AOsold = true
                ASsavedtable.AOexpired = true
                ASsavedtable.AOchatsold = true
            end
            if ASsavedtable.searchoncreate == nil then -- Option that should be set by default
                ASsavedtable.searchoncreate = true
            end
            if ASsavedtable.AOoutbid == nil then -- Option that should be set by default
                ASsavedtable.AOoutbid = true
            end
            if ASsavedtable.AOsold == nil then -- Option that should be set by default
                ASsavedtable.AOsold = true
            end
            if ASsavedtable.AOexpired == nil then -- Option that should be set by default
                ASsavedtable.AOexpired = true
            end
            if ASsavedtable.AOchatsold == nil then -- Option that should be set by default
                ASsavedtable.AOchatsold = true
            end

            ASsavedtable[ACTIVE_TABLE] = {}
            AS_tcopy(ASsavedtable[ACTIVE_TABLE], AS.item)
        else
            ASprint(MSG_C.ERROR.."Nothing found to save")
        end

        if AS.mainframe then
            -- check boxes
            ASsavedtable[ACTIVE_TABLE].ASnodoorbell = ASnodoorbell
            ASsavedtable[ACTIVE_TABLE].ASignorebid = ASignorebid
            ASsavedtable[ACTIVE_TABLE].ASignorenobuyout = ASignorenobuyout
            ASsavedtable[ACTIVE_TABLE].AOicontooltip = AOicontooltip
            ASsavedtable[ACTIVE_TABLE].AOserver = AOserver
        else
            ASprint(MSG_C.ERROR.."Checkboxes not found to save")
        end
    end

    function ASdropDownMenuItem_OnClick(self)

        action = {
            ['copperoverride'] = function () ASsavedtable.copperoverride = not ASsavedtable.copperoverride end,
            ['rememberprice'] = function () ASsavedtable.rememberprice = not ASsavedtable.rememberprice end,
            ['AOrenamelist'] = function () StaticPopup_Show("AS_RenameList") end,
            ['ASnodoorbell'] = function () ASnodoorbell = not ASnodoorbell; AS_SavedVariables() end,
            ['ASignorebid'] = function () ASignorebid = not ASignorebid; AS_SavedVariables() end,
            ['AOoutbid'] = function () ASsavedtable.AOoutbid = not ASsavedtable.AOoutbid end,
            ['AOchatsold'] = function () ASsavedtable.AOchatsold = not ASsavedtable.AOchatsold end,
            ['AOsold'] = function () ASsavedtable.AOsold = not ASsavedtable.AOsold end,
            ['AOexpired'] = function () ASsavedtable.AOexpired = not ASsavedtable.AOexpired end,
            ['ASignorenobuyout'] = function () ASignorenobuyout = not ASignorenobuyout; AS_SavedVariables() end,
            ['AOicontooltip'] = function () AOicontooltip = not AOicontooltip; AS_SavedVariables() end,
            ['ASautostart'] = function () ASsavedtable.ASautostart = not ASsavedtable.ASautostart end,
            ['ASautoopen'] = function () ASsavedtable.ASautoopen = not ASsavedtable.ASautoopen end,
            ['ASnewlist'] = function () StaticPopup_Show("AS_NewList") end
        }
        if action[self.value] then
            action[self.value]()
        else
            -- Import list
            if self.value == "cancelauction" then
                ASsavedtable.cancelauction = not ASsavedtable.cancelauction
                if not ASsavedtable.cancelauction then ASprint(MSG_C.WARN.."To turn off cancel auction, you will need to reload your UI", 1) end

            elseif self.value == "searchauction" then
                ASsavedtable.searchauction = not ASsavedtable.searchauction
                if not ASsavedtable.cancelauction then ASprint(MSG_C.WARN.."To turn off search owned auction, you will need to reload your UI", 1) end

            elseif self.value ~= ACTIVE_TABLE then  --dont import ourself
                AS_SwitchTable(self.value)
                ASdropDownMenuButton:Click() -- to close the dropdown
            end
        end
    end

    function AS_NewList(listname)

        ASprint(MSG_C.EVENT.."New list created:|r"..listname)
        AS_template(listname)
        AS_ScrollbarUpdate()
    end

    function AS_RenameList(listname)

        ASprint(MSG_C.EVENT.."Renaming list "..ACTIVE_TABLE.." to:|r "..listname)
        for _, v in pairs(LISTNAMES) do
            if v == listname then
                ASprint(MSG_C.ERROR.."List name already in use")
                return
            end
        end

        ASsavedtable[listname] = ASsavedtable[ACTIVE_TABLE]
        ASsavedtable[ACTIVE_TABLE] = nil
        AS_LoadTable(listname)
        AS_SavedVariables()
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

        local idx, link, hexcolor, itemRarity

        for x = 1, ASrowsthatcanfit() do
            -- Get the appropriate item, which will be x + value
            idx = x + currentscrollbarvalue

            if AS.item[idx] and AS.item[idx].name then
                hexcolor = ""

                if AS.item[idx].icon then -- Set the item icon and link
                    AS.mainframe.listframe.itembuttons[x].icon:SetNormalTexture(AS.item[idx].icon)
                    AS.mainframe.listframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    link = AS.item[idx].link
                    AS.mainframe.listframe.itembuttons[x].link = link
                    if not AS.item[idx].rarity then --updated for 3.1 to include colors
                        _, _, itemRarity = GetItemInfo(link)
                        AS.item[idx].rarity = itemRarity
                    end

                    _,_,_,hexcolor = GetItemQualityColor(AS.item[idx].rarity)
                    hexcolor = "|c"..hexcolor
                else
                    -- clear icon, link
                    AS.mainframe.listframe.itembuttons[x].icon:SetNormalTexture("")
                    AS.mainframe.listframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    AS.mainframe.listframe.itembuttons[x].link = nil
                    AS.mainframe.listframe.itembuttons[x].rarity = nil
                end

                AS.mainframe.listframe.itembuttons[x].leftstring:SetText(hexcolor..tostring(AS.item[idx].name))
                AS.mainframe.listframe.itembuttons[x]:Show()

            else
                --ASprint(MSG_C.DEBUG.."No item, hiding button: "..x)
                AS.mainframe.listframe.itembuttons[x]:Hide()
            end
        end
    end

    function AO_OwnerScrollbarUpdate()
        -- This redraws all the buttons and make sure they're showing the right stuff
        local ASnumberofitems = table.maxn(AS.soldauctions)
        local currentscrollbarvalue = FauxScrollFrame_GetOffset(AS.mainframe.soldlistframe.scrollFrame)

        FauxScrollFrame_Update(AS.mainframe.soldlistframe.scrollFrame, ASnumberofitems, ASrowsthatcanfit(), AS_BUTTON_HEIGHT)

        local idx, link, hexcolor, itemRarity
        local total = 0
        for x = 1, ASnumberofitems do -- Calculate total
            total = total + AS.soldauctions[x].price
        end
        for x = 1, ASrowsthatcanfit() do --apparently theres a bug here for some screen resolutions?
            -- Get the appropriate item, which will be x + value
            idx = x + currentscrollbarvalue

            if AS.soldauctions[idx] and AS.soldauctions[idx].name then
                hexcolor = ""

                if AS.soldauctions[idx].icon then -- Set the item icon and link
                    AS.mainframe.soldlistframe.itembuttons[x].icon:SetNormalTexture(AS.soldauctions[idx].icon)
                    AS.mainframe.soldlistframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    AS.mainframe.soldlistframe.itembuttons[x].rightstring:SetText(GetCoinTextureString(AS.soldauctions[idx].price, 10))

                    link = AS.soldauctions[idx].link
                    AS.mainframe.soldlistframe.itembuttons[x].link = link
                    if not AS.soldauctions[idx].rarity then --updated for 3.1 to include colors
                        if link then
                            _, _, itemRarity = GetItemInfo(link)
                            AS.soldauctions[idx].rarity = itemRarity
                        else
                            AS.soldauctions[idx].rarity = 1
                        end
                    end

                    _,_,_,hexcolor = GetItemQualityColor(AS.soldauctions[idx].rarity)
                    hexcolor = "|c"..hexcolor
                else
                    -- clear icon, link
                    AS.mainframe.soldlistframe.itembuttons[x].icon:SetNormalTexture("")
                    AS.mainframe.soldlistframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    AS.mainframe.soldlistframe.itembuttons[x].link = nil
                    AS.mainframe.soldlistframe.itembuttons[x].rarity = nil
                end

                AS.mainframe.soldlistframe.itembuttons[x].leftstring:SetText(hexcolor..tostring(AS.soldauctions[idx].name))
                AS.mainframe.soldlistframe.itembuttons[x]:Show()

            else
                --ASprint(MSG_C.DEBUG.."No item, hiding button: "..x)
                AS.mainframe.soldlistframe.itembuttons[x]:Hide()
            end
        end
        AS.mainframe.headerframe.soldeditbox:SetText("|cff737373("..ASnumberofitems..")|r "..GetCoinTextureString(total, 12))
    end

    function AS_AddItem()
        --this is when they hit enter and something is in the box
        local item_name = AS.mainframe.headerframe.editbox:GetText()
        AS.mainframe.headerframe.additembutton:UnlockHighlight()
        AS.mainframe.headerframe.additembutton:Disable()

        if AS_COPY and AS_COPY.name == item_name then
            ASprint(MSG_C.EVENT.."[ Succesfully copied:|r "..item_name.."]")
            table.insert(AS.item, AS_COPY)
            AS_COPY = nil
            AS.mainframe.headerframe.editbox:SetText("")
            AS_ScrollbarUpdate()
            AS_SavedVariables()
            return
        elseif AS_COPY then
            AS_COPY = nil
        end
        
        if not item_name or (string.find(item_name,'achievement:*')) then
            ASprint(MSG_C.ERROR.."There's nothing valid in the editbox")
            AS.mainframe.headerframe.editbox:SetText("")
            AO_RENAME = nil
            return false
        end

        ASprint(MSG_C.INFO.."Item name: "..item_name, 1)

        local itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(item_name)
        local _, _, itemString = string.find(item_name, "^|c%x+|H(.+)|h%[.*%]")  --see wowwiki, itemlink.  removes brackets and crap
        local new_id = table.maxn(AS.item) + 1
        
        if AO_RENAME then -- Modify search terms via options
            local old_item = AS.item[AO_RENAME]
            new_id = AO_RENAME
            AS.item[new_id] = {}
            AS.item[new_id].notes = old_item.notes
            AS.item[new_id].sellbuyout = old_item.sellbuyout
            AS.item[new_id].sellbid = old_item.sellbid
            -- Transfer filters
            if old_item.ignoretable and old_item.ignoretable[old_item.name] then
                ASprint(MSG_C.EVENT.."[ Modifying Search terms ]")
                AS.item[new_id].ignoretable = {}
                AS.item[new_id].ignoretable[itemName or itemString or item_name] = old_item.ignoretable[old_item.name]
            end
            AO_RENAME = nil
        else
            AS.item[new_id] = {}
        end

        if itemLink then
            ASprint(MSG_C.INFO.."New Item name: "..itemName)
            ASprint(MSG_C.INFO.."Link found "..itemLink)
            AS.item[new_id].name = itemName
            AS.item[new_id].icon = itemTexture
            AS.item[new_id].link = itemLink
            AS.item[new_id].rarity = itemRarity
        else
            ASprint(MSG_C.INFO.."nothing found for "..item_name)
            
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
            if string.find(link, 'achievement:*') or string.find(link,'spell:*') then
                return false
            end

            ASprint(MSG_C.INFO.."Link for: "..text)
            if AS.mainframe.headerframe.editbox:HasFocus() then AS.mainframe.headerframe.editbox:SetText(text) end
        end
    end

    function AS_ContainerFrameItemButton_OnModifiedClick(self)

        if IsShiftKeyDown() then
            local bag, item = self:GetParent():GetID(), self:GetID()
            local link = GetContainerItemLink(bag, item)

            ASprint(MSG_C.INFO.."Link: "..link, 2)

            if AS.mainframe.headerframe.editbox:HasFocus() then
                AS.mainframe.headerframe.editbox:SetText(link)
                BrowseName:SetText(link)
            elseif AS.manualprompt.notes:HasFocus() then
                AS.manualprompt.notes:SetText(AS.manualprompt.notes:GetText()..link)
            end
        end
    end

    function AO_InsertLink(text)

        if IsShiftKeyDown() then
            if AS.mainframe.headerframe.editbox:HasFocus() then
                AS.mainframe.headerframe.editbox:Insert(text)
            end
        end
    end

--[[//////////////////////////////////////////////////

    AUCTION HOUSE FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    -- STATE.QUERYING
    function AS_QueryAH()
        
        if (AS.currentauction > table.maxn(AS.item)) then
            ASprint(MSG_C.INFO.."Nothing to process. Reset", 1)

            AS.status = nil
            AS.currentauction = 1
            AS.mainframe.headerframe.stopsearchbutton:Disable()
            BrowseResetButton:Click()
            return false
        end

        local item = AS.item[AS.currentauction]
        if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
            -- Only proceed if item is not set to ignore. Right click item to bypass the ignore filter.
            if AS.override or not item.ignoretable or not (item.ignoretable[item.name] and item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice == 0) then
                ASprint(MSG_C.INFO.."Called query: ("..AS.currentauction..")|r "..item.name, 1)

                if Auctioneer then
                    ASprint(MSG_C.ERROR.."Auctioneer detected")
                end

                AS_SetSelected(AS.currentauction)
                AS.mainframe.headerframe.stopsearchbutton:Enable()

                BrowseName:SetText(ASsanitize(item.name))
                -- Sort auctions by buyout price, or minimum bid if there's no buyout price
                SortAuctionSetSort("list", "minbidbuyout")
                SortAuctionSetSort("list", "bid")
                SortAuctionSetSort("list", "unitprice")
                AuctionFrameBrowse_Search()

                AS.currentresult = 0
                AS.status = STATE.WAITINGFORUPDATE
                return true

            else
                ASprint(MSG_C.INFO.."Ignoring query: ("..AS.currentauction..")|r "..item.name, 1)
                AS.currentauction = AS.currentauction + 1
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

        if AS.manualprompt:IsVisible() then AS.manualprompt:Hide() end

        local batch, total = GetNumAuctionItems("list")

        while true do
            
            AS.currentresult = AS.currentresult + 1  --next!!

            if AS_IsEndPage(batch, total) then
                ASprint(MSG_C.EVENT.."[ End of page reached ]")
                return false
            elseif AS_IsEndResults(batch, total) then
                ASprint(MSG_C.EVENT.."[ End of AH results: "..total.." ]")
                return false
            end

            AS.currentauctionitem = {GetAuctionItemInfo("list", AS.currentresult)}
            SetSelectedAuctionItem("list", AS.currentresult)

            if AS_IsShowPrompt(AS.currentauctionitem) then
                
                if ASnodoorbell then
                   ASprint(MSG_C.DEBUG.."Attempting to play sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\DoorBell.mp3", "Master")
                end

                AuctionFrameBrowse_Update()

                AS.status = STATE.WAITINGFORPROMPT
                if not AS.prompt:IsVisible() then AS.prompt:Show() end
                return true
            end
        end
    end

    function AS_IsEndPage(batch, total)
        -- Stop at the end of page and wait for server to accept a new query
        -- First AuctionFrameBrowse.page = 0
        if AS.currentresult > batch and total > ((AuctionFrameBrowse.page + 1) * 50) then
            ASprint(MSG_C.INFO.."Current page: "..AuctionFrameBrowse.page.." Current result: "..tostring((AuctionFrameBrowse.page + 1) * 50).."/"..total)
            
            -- BrowseNextPageButton:Click() doesnt work for some reason
            -- so hack into the blizzard ui code to go to the next page
            AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1
            AuctionFrameBrowse_Search()
            BrowseScrollFrameScrollBar:SetValue(0)

            AS.currentresult = 0
            AS.status = STATE.WAITINGFORUPDATE
            return true
        end
        return false
    end

    function AS_IsEndResults(batch, total)
        -- End of AH results. Reset and go to the next query
        if not total or AS.currentresult > batch then

            if AS.override then -- Single item search, when right clicking button
                AS.mainframe.headerframe.stopsearchbutton:Click()
                AS.status = nil
                AS.override = false
            else
                AS.currentauction = AS.currentauction + 1
                AS.status = STATE.QUERYING
            end
            AS.currentresult = 0
            return true
        end
        return false
    end

    function AS_IsShowPrompt(auction)
        -- Primary conditional and fill info for prompt if returns true
        -- [1]name, [2]texture, [3]count, [4]quality, [5]canUse, [6]level, [7]levelColHeader,
        -- [8]minBid, [9]minIncrement, [10]buyoutPrice, [11]bidAmount, [12]highBidder,
        -- [13]highBidderFullName, [14]owner, [15]ownerFullName, [16]saleStatus, [17]itemId, [18]hasAllInfo
        local item = AS.item[AS.currentauction]
        local cutoffprice = AS_CutoffPrice(auction[1])
        local bid, _, peritembid, peritembuyout = AS_GetCost()

        local buyoutPrice = auction[10]
        local minBid = auction[8]
        local minIncrement = auction[9]
        local name = auction[1]
        local count = auction[3]
        local owner = auction[14]

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

        elseif cutoffprice and ((cutoffprice < peritembid) and (cutoffprice < peritembuyout)) then
            -- Item bid and buyout higher than cutoff price
            return false

        elseif AS_IsAlwaysIgnore(name) then
            ASprint(MSG_C.INFO.."Always ignore this name: "..name)
            return false

        elseif buyoutPrice == 0 and (ASignorebid or ASignorenobuyout) then
            -- No buyout, bids disabled or ignore no buyouts enabled
            return false

        elseif auction[12] == true then -- If we are highest bidder
            -- ASprint(MSG_C.INFO.."We are the highest bidder!")
            return false

        elseif item.link and item.name ~= name then
            -- if update was set (A link is provided) then
            -- if the name does NOT match the link, do not show prompt
            return false
        end

        -- Use the actual auction house link to get info, to get proper ilvl and other infos
        auction_iteminfo = {GetItemInfo(GetAuctionItemLink("list", GetSelectedAuctionItem("list")))}
        local ilvl = auction_iteminfo[4]

        if item.ignoretable and item.ignoretable[name] then
            if item.ignoretable[name].ilvl and item.ignoretable[name].ilvl > ilvl then
                -- ilvl item is lower than filter
                return false
            elseif item.ignoretable[name].stackone and count == 1 then
                -- Ignore stacks of 1
                return false
            end
        end

        -- Fill prompt info, title, icon, bid or buyout text/buttons
        AS.prompt.ilvl:SetText(ilvl)
        AS.prompt.quantity:SetText(count)
        AS.prompt.vendor:SetText(L[10067]..": "..(owner or L[10018]))
        AS.prompt.icon:SetNormalTexture(auction[2])
        -- Filter string
        local strcutoffprice = L[10019].."\n"
        if cutoffprice then
            strcutoffprice = strcutoffprice..L[10020]..": "..ASGSC(cutoffprice, nil, nil, false)
        end
        if item.ignoretable and item.ignoretable[name] and item.ignoretable[name].ilvl then
            if cutoffprice then
                strcutoffprice = strcutoffprice.." | iLvl: |cffffffff"..item.ignoretable[name].ilvl
            else
                strcutoffprice = strcutoffprice.."iLvl: |cffffffff"..item.ignoretable[name].ilvl
            end
        end
        AS.prompt.lowerstring:SetText(strcutoffprice)
        -- Set the title
        if quality then
            local _, _, _, hexcolor = GetItemQualityColor(auction[4])
            AS.prompt.upperstring:SetText("|c"..hexcolor..name)
        else
            AS.prompt.upperstring:SetText(name)
        end

        -- The buyout button
        if (buyoutPrice == 0) or (cutoffprice and (cutoffprice > peritembid) and (cutoffprice < peritembuyout)) then
            -- Buyout does not exist or cutoff meets bid but not buyout
            AS.prompt.buyout:Disable()
        else
            AS.prompt.buyout:Enable()
        end
        -- The bid button
        if ASignorebid or (peritembid == peritembuyout) then
            -- Ignore bid or bid is the same as buyout
            AS.prompt.bid:Disable()
        else
            AS.prompt.bid:Enable()
        end

        if ASignorebid then -- Show buyout only
            AS.prompt.buyoutonly:Show()

            if AS.prompt.bidbuyout:IsShown() then
                AS.prompt.bidbuyout:Hide()
            end

            if count > 1 then
                AS.prompt.buyoutonly.buyout.single:SetText(ASGSC(peritembuyout, nil, nil, false).." "..L[10053])
                AS.prompt.buyoutonly.buyout.total:SetText(ASGSC(buyoutPrice, nil, nil, false))
            else
                AS.prompt.buyoutonly.buyout.single:SetText(ASGSC(buyoutPrice, nil, nil, false))
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
                AS.prompt.bidbuyout.bid.single:SetText(ASGSC(peritembid, nil, nil, false))
                AS.prompt.bidbuyout.bid.total:SetText(ASGSC(bid, nil, nil, false))
                AS.prompt.bidbuyout.buyout.single:SetText(ASGSC(peritembuyout, nil, nil, false))
                AS.prompt.bidbuyout.buyout.total:SetText(ASGSC(buyoutPrice, nil, nil, false))
            else
                AS.prompt.bidbuyout.each:Hide()
                AS.prompt.bidbuyout.bid.single:SetText(ASGSC(bid, nil, nil, false))
                AS.prompt.bidbuyout.bid.total:SetText("")
                AS.prompt.bidbuyout.buyout.single:SetText(ASGSC(buyoutPrice, nil, nil, false))
                AS.prompt.bidbuyout.buyout.total:SetText("")
            end
        end

        ASprint(MSG_C.INFO.."Show prompt:|r"..MSG_C.BOOL.." true")
        return true
    end

    function AS_CutoffPrice(name)
        -- Ignore price is the cutoff point where we won't spend more than this price
        local cutoffprice

        if AS.item[AS.currentauction].ignoretable and AS.item[AS.currentauction].ignoretable[name] then
            cutoffprice = AS.item[AS.currentauction].ignoretable[name].cutoffprice
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
        local auction = AS.currentauctionitem
        local count = auction[3]
        local minBid = auction[8]
        local minIncrement = auction[9]
        local buyoutPrice = auction[10]
        local bidAmount = auction[11]

        bid = minIncrement + math.max(bidAmount, minBid) -- BidAmount or minBid
        peritembid = bid * (1/count)
        peritembuyout = buyoutPrice * (1/count)

        return bid, buyoutPrice, peritembid, peritembuyout
    end

    function AS_IsAlwaysIgnore(name)

        if AS.item[AS.currentauction].ignoretable and AS.item[AS.currentauction].ignoretable[name] then
            if AS.item[AS.currentauction].ignoretable[name].cutoffprice == 0 then
                return true
            end
        end
        return false
    end

    function AS_TrackerUpdate(name, quantity, bid, buyout)

        if not AS.boughtauctions[name] then
            AS.boughtauctions[name] = { ['bid'] = 0,
                                        ['buy'] = 0,
                                        ['bidquantity'] = 0,
                                        ['buyquantity'] = 0}
        end

        if bid then
            AS.boughtauctions[name]['bid'] = AS.boughtauctions[name]['bid'] + bid
            AS.boughtauctions[name]['bidquantity'] = AS.boughtauctions[name]['bidquantity'] + quantity
        else
            AS.boughtauctions[name]['buy'] = AS.boughtauctions[name]['buy'] + buyout
            AS.boughtauctions[name]['buyquantity'] = AS.boughtauctions[name]['buyquantity'] + quantity
        end
    end

    function AS_RegisterSearchAction()
        -------------- THANK YOU AUCTIONEER ----------------
        for i = 1, 199 do
            local owner_button = _G["AuctionsButton"..i]
            if not owner_button then break end

            if ASsavedtable.searchauction then
                owner_button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                owner_button:HookScript("OnDoubleClick", function(self)
                    BrowseResetButton:Click()
                    AuctionFrameBrowse.page = 0
                    BrowseName:SetText(ASsanitize(GetAuctionItemInfo("owner", GetSelectedAuctionItem("owner"))))
                    AuctionFrameTab1:Click()
                    AuctionFrameBrowse_Search()
                end)
            end
        end
    end

    function AS_RegisterCancelAction()
        -------------- THANK YOU AUCTIONEER ----------------
        for i = 1, 199 do
            local owner_button = _G["AuctionsButton"..i]
            if not owner_button then break end

            if ASsavedtable.cancelauction then
                owner_button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                owner_button:HookScript("PostClick", AS_CancelAuction)
            end
        end
    end

    function AS_CancelAuction(self, button)

        if button == "RightButton" then
            SetSelectedAuctionItem("owner", self:GetID() + GetEffectiveAuctionsScrollFrameOffset())
            if CanCancelAuction(GetSelectedAuctionItem("owner")) then
                AO_UntrackCancelledAuction()
                CancelAuction(GetSelectedAuctionItem("owner"))
            end
        end
    end

    function AO_UntrackCancelledAuction()

        local auction = {GetAuctionItemInfo("owner", GetSelectedAuctionItem('owner'))}
        AS.events['REMOVE'][#AS.events['REMOVE'] + 1] = auction[1]
    end

    function AO_AuctionSold(self, event, arg1)
        -- Workaround because auction sold doesn't work properly since Cross Server support
        -- We want: ERR_AUCTION_SOLD_S, ERR_AUCTION_EXPIRED_S
        if string.match(arg1, string.gsub(ERR_AUCTION_SOLD_S, "(%%s)", ".+")) ~= nil then
            -- Find sold item name
            local item = string.match(arg1, string.gsub(ERR_AUCTION_SOLD_S, "(%%s)", "(.*)"))
            AS.events['SOLD'][#AS.events['SOLD'] + 1] = {
                ['name'] = item,
                ['time'] = GetTime() + 3600
            }
            -- Play sound
            if ASsavedtable.AOsold then
               PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Sold.mp3", "Master")
            end

        elseif string.match(arg1, string.gsub(ERR_AUCTION_EXPIRED_S, "(%%s)", ".+")) ~= nil then
            -- Find expired item name
            local item = string.match(arg1, string.gsub(ERR_AUCTION_EXPIRED_S, "(%%s)", "(.*)"))
            AS.events['REMOVE'][#AS.events['REMOVE'] + 1] = item

            if ASsavedtable.AOexpired then
               PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Expired.mp3", "SFX")
            end
        
        elseif string.match(arg1, string.gsub(ERR_AUCTION_OUTBID_S, "(%%s)", ".+")) ~= nil then
            -- Outbid
            if ASsavedtable.AOoutbid then
               PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Outbid.mp3", "Master")
            end
        end
    end

    function AO_CurrentOwnedAuctions(name)
        -- If name is nil, return the entire owned auction list
        local current = {}
        local _, totalAuctions = GetNumAuctionItems("owner")

        for x = 1, totalAuctions do
            local auction = {GetAuctionItemInfo("owner", x)}

            if name == auction[1] or not name then
                table.insert(current, {
                    ['quantity'] = auction[3],
                    ['price'] = auction[10],
                    ['sold'] = auction[16],
                    ['buyer'] = auction[12],
                    ['link'] = GetAuctionItemLink("owner", x)
                })
            end
        end
        return current
    end

    function AO_CompareAuctionsTable(newtable, oldtable)
        -- Return old table, but will only contain the difference between new and old
        local y, key, value, value2

        for key, value in pairs(newtable) do
            for y = #oldtable, 1, -1 do -- Go in reverse so we can probably delete tables
                value2 = oldtable[y]
                
                if type(value2) == "table" then
                    if value.quantity == value2.quantity and value.price == value2.price then
                        -- Found match, still exists
                        table.remove(oldtable, y)
                        break
                    end
                end
            end
        end

        return oldtable
    end
