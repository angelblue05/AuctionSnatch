local B, L, T = unpack(select(2, ...))

T.LABEL = {
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


--[[//////////////////////////////////////////////////

    FUNCTIONS TRIGGERED VIA XML auctionsnatch.xml

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function AS_OnLoad(self)

        ----- REGISTER FOR EVENTS
            self:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
            self:RegisterEvent("AUCTION_OWNED_LIST_UPDATE")
            self:RegisterEvent("AUCTION_HOUSE_SHOW")
            self:RegisterEvent("AUCTION_HOUSE_CLOSED")
            self:RegisterEvent("VARIABLES_LOADED")

        ------ SOLD/CANCELLED AUCTION
            T.AS.AuctionSoldFrame = CreateFrame("Frame")
            T.AS.AuctionSoldFrame:RegisterEvent("CHAT_MSG_SYSTEM")
            T.AS.AuctionSoldFrame:SetScript("OnEvent", B.AuctionSold)

        ------ STATIC DIALOG // To get new list name
            StaticPopupDialogs["B.NewList"] = {
                text = L[10010],
                button1 = L[10011],
                button2 = L[10012],
                OnShow = function (self, data)
                    self.button1:Disable()
                end,
                OnAccept = function (self, data, data2)
                    B.NewList(self.editBox:GetText())
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
            StaticPopupDialogs["B.RenameList"] = {
                text = L[10013],
                button1 = L[10014],
                button2 = L[10012],
                OnShow = function (self, data)
                    self.button1:Disable()
                end,
                OnAccept = function (self, data, data2)
                    B.RenameList(self.editBox:GetText())
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
            StaticPopupDialogs["AS_OneTimeAd"] = {
                text = "Thank you for using Auction Snatch. \n Support the project, spread the word!",
                button1 = OKAY,
                OnAccept = function (self, data, data2)
                    ASsavedtable.onetimead = true
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                exclusive = true,
                preferredIndex = 3  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
            }

        DEFAULT_CHAT_FRAME:AddMessage(T.MSGC.DEFAULT..L[10000])

        ------ SLASH COMMANDS
            SLASH_AS1 = "/AS"
            SLASH_AS2 = "/as"
            SLASH_AS3 = "/As"
            SLASH_AS4 = "/aS"
            SLASH_AS5 = "/Auctionsnatch"
            SLASH_AS6 = "/AuctionSnatch"
            SLASH_AS7 = "/AUCTIONSNATCH"
            SLASH_AS8 = "/auctionsnatch"

            SlashCmdList["AS"] = B.Main

        if IsAddOnLoaded("Aurora") then -- Verify if Aurora is installed/enabled
            DEFAULT_CHAT_FRAME:AddMessage(T.MSGC.DEFAULT.."AuctionSnatch|r: Aurora detected")
            F, C = unpack(Aurora) -- Aurora
            r, g, b = C.r, C.g, C.b -- Aurora
            AS_backdrop = C.media.backdrop
            T.SKIN = true
        else -- default skin
            AS_backdrop = "Interface\\ChatFrame\\ChatFrameBackground"
            r, g, b = 0.035, 1, 0.78 -- TODO: Make a setting?
        end

        B.CreateFrames()

        table.insert(UISpecialFrames, T.AS.mainframe:GetName())
        table.insert(UISpecialFrames, T.AS.prompt:GetName())
        table.insert(UISpecialFrames, T.AS.cancelprompt:GetName())
        table.insert(UISpecialFrames, T.AS.manualprompt:GetName())
    end

    function AS_OnEvent(self, event)

        if event == "VARIABLES_LOADED" then
            B.print(T.MSGC.EVENT.."Variables loaded. Initializing.", 2)
            B.print(T.MSGC.INFO.."Running version: "..GetAddOnMetadata("AuctionSnatch", "Version"), 1)
            
            B.Initialize()

        elseif event == "AUCTION_OWNED_LIST_UPDATE" then
            --B.print(T.MSGC.EVENT..event)
            B.RegisterCancelAction()
            B.RegisterSearchAction()
            -- Get current owner auctions
            if not T.FIRSTRUN_AH then
                T.FIRSTRUN_AH = true
                T.AS.events['AUCTIONS'] = {}

                local _, totalAuctions = GetNumAuctionItems("owner")
                local x
                for x = 1, totalAuctions do
                    local auction = {GetAuctionItemInfo("owner", x)}
                    if not T.AS.events['AUCTIONS'][auction[1]] then
                        T.AS.events['AUCTIONS'][auction[1]] = {}
                        T.AS.events['AUCTIONS'][auction[1]]['icon'] = auction[2]
                    end
                    if x == 1 then -- Verification if we should wipe sold auctions
                        T.AS.soldauctions = {}
                    end

                    if auction[16] == 1 or auction[3] == 0 then
                        table.insert(T.AS.soldauctions, {
                            ['name'] = auction[1],
                            ['quantity'] = auction[3],
                            ['icon'] = auction[2],
                            ['price'] = auction[10],
                            ['link'] = GetAuctionItemLink("owner", x),
                            ['buyer'] = auction[12],
                            ['time'] = GetTime() + GetAuctionItemTimeLeft("owner", x),
                            ['timer'] = C_Timer.After(GetAuctionItemTimeLeft("owner", x), function() table.remove(T.AS.soldauctions, 1) ; B.OwnerScrollbarUpdate() end)
                        })
                    else
                        table.insert(T.AS.events['AUCTIONS'][auction[1]], {
                            ['quantity'] = auction[3],
                            ['price'] = auction[10],
                            ['link'] = GetAuctionItemLink("owner", x)
                        })
                    end
                end
            end

            if #T.AS.events['REMOVE'] > 0 then -- REMOVE Auctions
                B.print(T.MSGC.EVENT.."[ Found removed auction(s) ]")
                local remove = {}
                B.tcopy(remove, T.AS.events['REMOVE'])
                T.AS.events['REMOVE'] = {}

                local x, key, key2, value, value2

                for x = 1, #remove do
                    local item = remove[x]
                    local current_auctions = B.CurrentOwnedAuctions(item)

                    local saved_auctions = {} -- Copy original auctions to compare
                    if T.AS.events['AUCTIONS'][item] ~= nil then

                        B.tcopy(saved_auctions, T.AS.events['AUCTIONS'][item])

                        if current_auctions then
                            B.CompareAuctionsTable(current_auctions, saved_auctions)
                        end

                        for key, value in pairs(saved_auctions) do
                            for key2, value2 in pairs(T.AS.events['AUCTIONS'][item]) do -- delete entry since item expired or was cancelled
                                if type(value) == "table" and type(value2) == "table" then
                                    if value.quantity == value2.quantity and value.price == value2.price then
                                        -- Found match
                                        table.remove(T.AS.events['AUCTIONS'][item], key2)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if #T.AS.events['SOLD'] > 0 then -- Sold Auctions
                B.print(T.MSGC.EVENT.."[ Found sold auction(s) ]")
                local sold = {}
                B.tcopy(sold, T.AS.events['SOLD'])
                T.AS.events['SOLD'] = {}

                local x, y, key, key2, value, value2

                for x = 1, #sold do
                    local item = sold[x]['name']
                    local time = sold[x]['time']
                    local current_auctions = B.CurrentOwnedAuctions(item)
                    local saved_auctions = {}

                    B.tcopy(saved_auctions, T.AS.events['AUCTIONS'][item])

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
                                T.AS.soldauctions[#T.AS.soldauctions + 1] = {
                                    ['name'] = item,
                                    ['quantity'] = value.quantity,
                                    ['icon'] = saved_auctions.icon,
                                    ['price'] = value.price,
                                    ['buyer'] = value.buyer,
                                    ['link'] = value.link,
                                    ['time'] = time,
                                    ['timer'] = C_Timer.After(time - GetTime(), function() table.remove(T.AS.soldauctions, 1) ; B.OwnerScrollbarUpdate() end) -- 60min countdown
                                }
                            end
                            if ASsavedtable.AOchatsold then
                                B.print(L[10078]..":|T"..saved_auctions.icon..":0|t"..value.link.."x"..value.quantity.."  "..B.ASGSC(value.price), 1)
                            end
                            for key2, value2 in pairs(T.AS.events['AUCTIONS'][item]) do -- delete entry since item was sold
                                if type(value) == "table" and type(value2) == "table" then
                                    if value.price == value2.price and value.quantity == value2.quantity then
                                        -- Found match
                                        table.remove(T.AS.events['AUCTIONS'][item], key2)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if T.AS.mainframe.soldlistframe:IsVisible() then
                B.OwnerScrollbarUpdate()
            end

        elseif event == "AUCTION_ITEM_LIST_UPDATE" then
            --B.print(T.MSGC.INFO..event)
            if T.AS.status == T.STATE.BUYING then
                T.AS.status = T.STATE.EVALUATING
            end

        elseif event == "AUCTION_HOUSE_SHOW" then

            if not ASauctiontab then
                B.CreateAuctionTab()
            end

            if ASsavedtable.ASautostart and not ASsavedtable.ASautoopen then
                -- Do nothing
            elseif ASsavedtable.ASautostart and not IsShiftKeyDown() then -- Auto start
                T.AS.status = T.STATE.QUERYING
                B.Main()
            elseif IsShiftKeyDown() then -- Auto start
                T.AS.status = T.STATE.QUERYING
                B.Main()
            elseif ASsavedtable.ASautoopen then
                -- Automatically display frame, just don't auto start
                B.Main()
            end

            ------ AUCTION HOUSE HOOKS
                if BrowseName then
                    BrowseName:HookScript("OnEditFocusGained", function(self)
                        if T.AS.status == nil then return false end  --should catch the infinate loop
                        T.AS.mainframe.headerframe.stopsearchbutton:Click()
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
                                    B.UntrackCancelledAuction()
                                end)
                            end
                        end
                    end)
                end
                if AuctionsCreateAuctionButton then
                    AuctionsCreateAuctionButton:HookScript("PreClick", function(self, button)
                        local _, item = B.GetSelected()
                        local startPrice = MoneyInputFrame_GetCopper(StartPrice)
                        local buyoutPrice = MoneyInputFrame_GetCopper(BuyoutPrice)
                        local stackSize = AuctionsStackSizeEntry:GetNumber()
                        local stackNum = AuctionsNumStacksEntry:GetNumber()

                        -- Add auctions to our saved list of auctions
                        for x = 1, stackNum do
                            local auction = {GetAuctionSellItemInfo()}
                            local name = auction[1]
                            local _, link = GetItemInfo(name)

                            if not T.AS.events['AUCTIONS'][name] then
                                T.AS.events['AUCTIONS'][name] = {}
                                T.AS.events['AUCTIONS'][name]['icon'] = auction[2]
                            end
                            local auction_info = {
                                ['quantity'] = stackSize,
                                ['price'] = buyoutPrice,
                                ['link'] = link
                            }

                            if stackSize > 1 and AuctionFrameAuctions.priceType == 1 then
                                auction_info['price'] = buyoutPrice * stackSize
                            end
                            table.insert(T.AS.events['AUCTIONS'][name], auction_info)
                        end

                        if ASsavedtable.rememberprice and item then
                            B.print(T.MSGC.INFO.."StartPrice:|r "..startPrice)
                            B.print(T.MSGC.INFO.."BuyoutPrice:|r "..buyoutPrice)
                            
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
                                B.SavedVariables()
                            end
                        end
                    end)
                    AuctionsCreateAuctionButton:HookScript("PostClick", function(self, button)
                        -- Search item to view new auctions
                        local _, item = B.GetSelected()
                        if ASsavedtable.searchoncreate and item then

                            AuctionFrameBrowse.page = 0
                            BrowseName:SetText(B.sanitize(item.name))
                            AuctionFrameBrowse_Search()
                        end
                    end)
                end

        elseif event == "AUCTION_HOUSE_CLOSED" then

            T.AS.currentauction = 1
            BrowseResetButton:Click()
            T.AS.manualprompt:Hide()
            T.AS.mainframe.headerframe.stopsearchbutton:Click()
            
            if ASopenedwithah then  --in case i do a manual /as prompt for testing purposes
                if T.AS.mainframe then
                    T.AS.mainframe:Hide()
                end
                ASopenedwithah = false
            else
                T.AS.mainframe:Hide()
            end
        
        elseif string.match("AUCTION", event) then
            B.print(T.MSGC.INFO..event, 2)
        end
    end

    function AS_OnUpdate(self, elapsed)

        -- This is the Blizzard Update, called every computer clock cycle ~millisecond
        if not elapsed then return end -- Otherwise it will infinite loop

        -- This is needed because sometimes a query completes,
        -- and the results are sent back - but the ah will not accept a query right away.
        -- there is no event that fires when a query is possible, so i just have to spam requests

        if T.AS.status then
            T.AS.elapsed = T.AS.elapsed + elapsed

            if T.AS.elapsed > 0.1 then
                T.AS.elapsed = 0

                if T.AS.status == T.STATE.QUERYING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("list")
                    if canQuery then
                        B.print(T.MSGC.EVENT.."[ Start querying ]")
                        B.QueryAH()
                    end
                
                elseif T.AS.status == T.STATE.WAITINGFORUPDATE then
                    B.print(T.MSGC.EVENT.."[ Waiting for update event ]")
                    T.AS.status = T.STATE.EVALUATING
                
                elseif T.AS.status == T.STATE.EVALUATING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("list")
                    if canQuery then
                        B.print(T.MSGC.EVENT.."[ Start evaluating ]")
                        B.Evaluate()
                    end
                
                elseif T.AS.status == T.STATE.WAITINGFORPROMPT then
                    -- The prompt buttons will change the status accordingly
                elseif T.AS.status == T.STATE.BUYING then
                    -- Nothing to do
                end
            end
        end

        if T.AS.CancelStatus then
            T.AS.elapsed = T.AS.elapsed + elapsed

            if T.AS.elapsed > 0.1 then
                T.AS.elapsed = 0

                if T.AS.CancelStatus == T.STATE.QUERYING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("owner")
                    if canQuery then
                        B.print(T.MSGC.EVENT.."[ Start querying ]")
                        B.QueryCancelOwnerAH()
                    end
                
                elseif T.AS.CancelStatus == T.STATE.WAITINGFORUPDATE then
                    B.print(T.MSGC.EVENT.."[ Waiting for update event ]")
                    T.AS.CancelStatus = T.STATE.EVALUATING
                
                elseif T.AS.CancelStatus == T.STATE.EVALUATING then
                    local canQuery, canQueryAll = CanSendAuctionQuery("owner")
                    if canQuery then
                        B.print(T.MSGC.EVENT.."[ Start evaluating ]")
                        B.EvaluateCancelOwner()
                    end
                
                elseif T.AS.CancelStatus == T.STATE.WAITINGFORPROMPT then
                    -- The prompt buttons will change the status accordingly
                end
            end
        end
    end

--[[//////////////////////////////////////////////////

    MAIN FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function B.Initialize()

        local playerName = UnitName("player")
        local serverName = GetRealmName()

        hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", B.ContainerFrameItemButton_OnModifiedClick)
        hooksecurefunc("ChatFrame_OnHyperlinkShow", B.ChatFrame_OnHyperlinkShow)
        hooksecurefunc("ChatEdit_InsertLink", B.InsertLink)

        if (playerName == nil) or (playerName == UNKNOWNOBJECT) or (playerName == UNKNOWNBEING) then
            return
        end

        if ASsavedtable and ASsavedtable[serverName] then
            B.LoadTable(serverName)
        else
            B.print(T.MSGC.EVENT.."New server found")
            B.template(serverName)
        end

        -- font size testing and adjuting height of prompt
        local _, height = GameFontNormal:GetFont()
        local new_height = (height * 10) + ((T.BUTTON_HEIGHT + T.FRAMEWHITESPACE) * 6)  -- LINES, 5 BUTTONS + 1 togrow on
        
        B.print(T.MSGC.DEBUG.."Font height:|r "..height, 2)
        B.print(T.MSGC.DEBUG.."New prompt height:|r "..new_height, 2)
        T.AS.prompt:SetHeight(new_height)
        T.AS.manualprompt:SetHeight(new_height)

        -- Generate scroll bar items
        B.ScrollbarUpdate()
        -- Clean auction sold list
        B.OwnerScrollbarUpdate()
    end

    function B.Main(input)
        -- this is called when we type /AS or clicks the AS tab
        B.print(T.MSGC.INFO.."Excelsior!", 1)
        if input then input = string.lower(input) end
       
        if T.AS.mainframe then
            --B.print(T.MSGC.INFO.."Frame layer: "..T.AS.mainframe:GetFrameLevel())

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
                    testtable = B.removeduplicates(testtable)
                end

                if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
                    
                    canQuery, canQueryAll = CanSendAuctionQuery()  --check if we can send a query
                    if canQuery and testtable[AStesttablenum] then

                        local name = testtable[AStesttablenum]
                        AStesttablenum = AStesttablenum + 1

                        BrowseName:SetText(name)
                        AuctionFrameBrowse_Search()

                        --T.AS.status=WAITINGFORUPDATE
                        --return true
                    end
                end

            elseif input == "soldtest" then
                test_sold()
                B.print("Generating fake auctions")
                return

            elseif input == "sound outbid" then
                ASsavedtable.AOoutbid = not ASsavedtable.AOoutbid
                B.print(T.MSGC.INFO.."Outbid sound:|r "..T.MSGC.BOOL..tostring(ASsavedtable.AOoutbid), 1)
                if ASsavedtable.AOoutbid then
                   B.print(T.MSGC.DEBUG.."Attempting to play 'outbid' sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Outbid.mp3")
                end
                return
            elseif input == "sound sold" then
                ASsavedtable.AOsold = not ASsavedtable.AOsold
                B.print(T.MSGC.INFO.."Sold sound:|r "..T.MSGC.BOOL..tostring(ASsavedtable.AOsold), 1)
                if ASsavedtable.AOsold then
                    --PlaySound("LOOTWINDOWCOINSOUND")
                    B.print(T.MSGC.DEBUG.."Attempting to play 'sold' sound file")
                    PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Sold.mp3")
                end
                return
            elseif input == "sound expired" then
                ASsavedtable.AOexpired = not ASsavedtable.AOexpired
                B.print(T.MSGC.INFO.."Expired sound:|r "..T.MSGC.BOOL..tostring(ASsavedtable.AOexpired), 1)
                if ASsavedtable.AOexpired then
                   B.print(T.MSGC.DEBUG.."Attempting to play 'expired' sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\Expired.mp3")
                end
                return
            elseif input == "chat sold" then
                ASsavedtable.AOchatsold = not ASsavedtable.AOchatsold
                B.print(T.MSGC.INFO.."Chat alert for sold:|r "..T.MSGC.BOOL..tostring(ASsavedtable.AOchatsold), 1)
                return
            elseif input == "debug" then
                ASdebug = not ASdebug
                B.print(T.MSGC.INFO.."Debug:|r "..T.MSGC.BOOL..tostring(ASdebug), 1)
                return
            elseif input == "copperoverride" then
                ASsavedtable.copperoverride = not ASsavedtable.copperoverride
                B.print(T.MSGC.INFO.."Value in copper:|r "..T.MSGC.BOOL..tostring(ASsavedtable.copperoverride), 1)
                return
            elseif input == "searchoncreate" then
                ASsavedtable.searchoncreate = not ASsavedtable.searchoncreate
                B.print(T.MSGC.INFO.."Search on creating auction: "..T.MSGC.BOOL..tostring(ASsavedtable.searchoncreate), 1)
                return
            elseif input == "cancelauction" then
                ASsavedtable.cancelauction = not ASsavedtable.cancelauction
                B.print(T.MSGC.INFO.."Cancel auction on right-click: "..T.MSGC.BOOL..tostring(ASsavedtable.cancelauction), 1)
                return
            elseif input == "searchauction" then
                ASsavedtable.searchauction = not ASsavedtable.searchauction
                B.print(T.MSGC.INFO.."Search owned auction on double-click: "..T.MSGC.BOOL..tostring(ASsavedtable.searchauction), 1)
                return
            end

        else
            B.print(T.MSGC.ERROR.."Mainframe not found!", 1)
            return false
        end

        T.AS.mainframe:Show()
    end

    function B.SavedVariables()
        B.print(T.MSGC.EVENT.."[ Saving changes ]")

        if T.AS and T.AS.item then
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

            ASsavedtable[T.ACTIVE_TABLE] = {}
            B.tcopy(ASsavedtable[T.ACTIVE_TABLE], T.AS.item)
        else
            B.print(T.MSGC.ERROR.."Nothing found to save")
        end

        if T.AS.mainframe then
            -- check boxes
            ASsavedtable[T.ACTIVE_TABLE].ASnodoorbell = ASnodoorbell
            ASsavedtable[T.ACTIVE_TABLE].ASignorebid = ASignorebid
            ASsavedtable[T.ACTIVE_TABLE].ASignorenobuyout = ASignorenobuyout
            ASsavedtable[T.ACTIVE_TABLE].AOicontooltip = AOicontooltip
            ASsavedtable[T.ACTIVE_TABLE].AOserver = AOserver
        else
            B.print(T.MSGC.ERROR.."Checkboxes not found to save")
        end
    end

    function B.dropDownMenuItem_OnClick(self)

        action = {
            ['copperoverride'] = function () ASsavedtable.copperoverride = not ASsavedtable.copperoverride end,
            ['rememberprice'] = function () ASsavedtable.rememberprice = not ASsavedtable.rememberprice end,
            ['AOrenamelist'] = function () StaticPopup_Show("B.RenameList") end,
            ['ASnodoorbell'] = function () ASnodoorbell = not ASnodoorbell; B.SavedVariables() end,
            ['ASignorebid'] = function () ASignorebid = not ASignorebid; B.SavedVariables() end,
            ['AOoutbid'] = function () ASsavedtable.AOoutbid = not ASsavedtable.AOoutbid end,
            ['AOchatsold'] = function () ASsavedtable.AOchatsold = not ASsavedtable.AOchatsold end,
            ['AOsold'] = function () ASsavedtable.AOsold = not ASsavedtable.AOsold end,
            ['AOexpired'] = function () ASsavedtable.AOexpired = not ASsavedtable.AOexpired end,
            ['ASignorenobuyout'] = function () ASignorenobuyout = not ASignorenobuyout; B.SavedVariables() end,
            ['AOicontooltip'] = function () AOicontooltip = not AOicontooltip; B.SavedVariables() end,
            ['ASautostart'] = function () ASsavedtable.ASautostart = not ASsavedtable.ASautostart end,
            ['ASautoopen'] = function () ASsavedtable.ASautoopen = not ASsavedtable.ASautoopen end,
            ['ASnewlist'] = function () StaticPopup_Show("B.NewList") end
        }
        if action[self.value] then
            action[self.value]()
        else
            -- Import list
            if self.value == "cancelauction" then
                ASsavedtable.cancelauction = not ASsavedtable.cancelauction
                if not ASsavedtable.cancelauction then B.print(T.MSGC.WARN.."To turn off cancel auction, you will need to reload your UI", 1) end

            elseif self.value == "searchauction" then
                ASsavedtable.searchauction = not ASsavedtable.searchauction
                if not ASsavedtable.cancelauction then B.print(T.MSGC.WARN.."To turn off search owned auction, you will need to reload your UI", 1) end

            elseif self.value ~= T.ACTIVE_TABLE then  --dont import ourself
                B.SwitchTable(self.value)
                ASdropDownMenuButton:Click() -- to close the dropdown
            end
        end
    end

    function B.NewList(listname)

        B.print(T.MSGC.EVENT.."New list created:|r"..listname)
        B.template(listname)
        B.ScrollbarUpdate()
    end

    function B.RenameList(listname)

        B.print(T.MSGC.EVENT.."Renaming list "..T.ACTIVE_TABLE.." to:|r "..listname)
        for _, v in pairs(LISTNAMES) do
            if v == listname then
                B.print(T.MSGC.ERROR.."List name already in use")
                return
            end
        end

        ASsavedtable[listname] = ASsavedtable[T.ACTIVE_TABLE]
        ASsavedtable[T.ACTIVE_TABLE] = nil
        B.LoadTable(listname)
        B.SavedVariables()
    end

--[[//////////////////////////////////////////////////

    SECONDARY FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

    function B.ScrollbarUpdate()
        -- This redraws all the buttons and make sure they're showing the right stuff
        if not T.AS.item then
            B.print(T.MSGC.ERROR.."T.AS.item is empty")
            return false
        end

        T.AS.optionframe:Hide()

        local ASnumberofitems = table.maxn(T.AS.item)
        local currentscrollbarvalue = FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)

        FauxScrollFrame_Update(T.AS.mainframe.listframe.scrollFrame, ASnumberofitems, B.rowsthatcanfit(), T.BUTTON_HEIGHT)

        local idx, link, hexcolor, itemRarity

        for x = 1, B.rowsthatcanfit() do
            -- Get the appropriate item, which will be x + value
            idx = x + currentscrollbarvalue

            if T.AS.item[idx] and T.AS.item[idx].name then
                hexcolor = ""

                if T.AS.item[idx].icon then -- Set the item icon and link
                    T.AS.mainframe.listframe.itembuttons[x].icon:SetNormalTexture(T.AS.item[idx].icon)
                    T.AS.mainframe.listframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

                    link = T.AS.item[idx].link
                    T.AS.mainframe.listframe.itembuttons[x].icon.link = link
                    T.AS.mainframe.listframe.itembuttons[x].link = link
                    if not T.AS.item[idx].rarity then --updated for 3.1 to include colors
                        _, _, itemRarity = GetItemInfo(link)
                        T.AS.item[idx].rarity = itemRarity
                    end

                    _,_,_,hexcolor = GetItemQualityColor(T.AS.item[idx].rarity)
                    hexcolor = "|c"..hexcolor
                else
                    -- clear icon, link
                    T.AS.mainframe.listframe.itembuttons[x].icon:SetNormalTexture("")
                    T.AS.mainframe.listframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    T.AS.mainframe.listframe.itembuttons[x].link = nil
                    T.AS.mainframe.listframe.itembuttons[x].icon.link = nil
                    T.AS.mainframe.listframe.itembuttons[x].rarity = nil
                end

                T.AS.mainframe.listframe.itembuttons[x].leftstring:SetText(hexcolor..tostring(T.AS.item[idx].name))
                T.AS.mainframe.listframe.itembuttons[x]:Show()

            else
                --B.print(T.MSGC.DEBUG.."No item, hiding button: "..x)
                T.AS.mainframe.listframe.itembuttons[x]:Hide()
            end
        end
    end

    function B.OwnerScrollbarUpdate()
        -- This redraws all the buttons and make sure they're showing the right stuff
        local ASnumberofitems = table.maxn(T.AS.soldauctions)
        local currentscrollbarvalue = FauxScrollFrame_GetOffset(T.AS.mainframe.soldlistframe.scrollFrame)

        FauxScrollFrame_Update(T.AS.mainframe.soldlistframe.scrollFrame, ASnumberofitems, B.rowsthatcanfit(), T.BUTTON_HEIGHT)

        local idx, link, hexcolor, itemRarity
        local total = 0
        for x = 1, ASnumberofitems do -- Calculate total
            total = total + T.AS.soldauctions[x].price
        end
        for x = 1, B.rowsthatcanfit() do --apparently theres a bug here for some screen resolutions?
            -- Get the appropriate item, which will be x + value
            idx = x + currentscrollbarvalue

            if T.AS.soldauctions[idx] and T.AS.soldauctions[idx].name then
                hexcolor = ""

                if T.AS.soldauctions[idx].icon then -- Set the item icon and link
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon:SetNormalTexture(T.AS.soldauctions[idx].icon)
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    T.AS.mainframe.soldlistframe.itembuttons[x].rightstring:SetText(GetCoinTextureString(T.AS.soldauctions[idx].price, 10))

                    link = T.AS.soldauctions[idx].link
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon.link = link
                    T.AS.mainframe.soldlistframe.itembuttons[x].link = link
                    if not T.AS.soldauctions[idx].rarity then --updated for 3.1 to include colors
                        if link then
                            _, _, itemRarity = GetItemInfo(link)
                            T.AS.soldauctions[idx].rarity = itemRarity
                        else
                            T.AS.soldauctions[idx].rarity = 1
                        end
                    end

                    _,_,_,hexcolor = GetItemQualityColor(T.AS.soldauctions[idx].rarity)
                    hexcolor = "|c"..hexcolor
                else
                    -- clear icon, link
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon:SetNormalTexture("")
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
                    T.AS.mainframe.soldlistframe.itembuttons[x].link = nil
                    T.AS.mainframe.soldlistframe.itembuttons[x].icon.link = nil
                    T.AS.mainframe.soldlistframe.itembuttons[x].rarity = nil
                end

                T.AS.mainframe.soldlistframe.itembuttons[x].leftstring:SetText(hexcolor..tostring(T.AS.soldauctions[idx].name))
                T.AS.mainframe.soldlistframe.itembuttons[x]:Show()

            else
                --B.print(T.MSGC.DEBUG.."No item, hiding button: "..x)
                T.AS.mainframe.soldlistframe.itembuttons[x]:Hide()
            end
        end
        T.AS.mainframe.headerframe.soldeditbox:SetText("|cff737373("..ASnumberofitems..")|r "..GetCoinTextureString(total, 12))
    end

    function B.AddItem()
        local itemName, itemLink, itemRarity, itemTexture
        --this is when they hit enter and something is in the box
        local item_name = T.AS.mainframe.headerframe.editbox:GetText()
        T.AS.mainframe.headerframe.additembutton:UnlockHighlight()
        T.AS.mainframe.headerframe.additembutton:Disable()

        if T.COPY and T.COPY.name == item_name then
            B.print(T.MSGC.EVENT.."[ Succesfully copied:|r "..item_name.."]")
            table.insert(T.AS.item, T.COPY)
            T.COPY = nil
            T.AS.mainframe.headerframe.editbox:SetText("")
            B.ScrollbarUpdate()
            B.SavedVariables()
            return
        elseif T.COPY then
            T.COPY = nil
        end
        
        if not item_name or (string.find(item_name,'achievement:*')) then
            B.print(T.MSGC.ERROR.."There's nothing valid in the editbox")
            T.AS.mainframe.headerframe.editbox:SetText("")
            T.RENAME = nil
            return false
        end

        B.print(T.MSGC.INFO.."Item name: "..item_name, 1)

        if strmatch(item_name, "|Hbattlepet:") then
            local petitem = B.GetPetInfo(item_name)
            itemName = petitem[1]
            itemLink = petitem[2]
            itemRarity = petitem[3]
            itemTexture = petitem[10]
        else
            itemName, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(item_name)
        end

        local _, _, itemString = string.find(item_name, "^|c%x+|H(.+)|h%[.*%]")  --see wowwiki, itemlink.  removes brackets and crap
        local new_id = table.maxn(T.AS.item) + 1
        
        if T.RENAME then -- Modify search terms via options
            local old_item = T.AS.item[T.RENAME]
            new_id = T.RENAME
            T.AS.item[new_id] = {}
            T.AS.item[new_id].notes = old_item.notes
            T.AS.item[new_id].sellbuyout = old_item.sellbuyout
            T.AS.item[new_id].sellbid = old_item.sellbid
            -- Transfer filters
            if old_item.ignoretable and old_item.ignoretable[old_item.name] then
                B.print(T.MSGC.EVENT.."[ Modifying Search terms ]")
                T.AS.item[new_id].ignoretable = {}
                T.AS.item[new_id].ignoretable[itemName or itemString or item_name] = old_item.ignoretable[old_item.name]
            end
        else
            T.AS.item[new_id] = {}
        end


        if itemLink then
            B.print(T.MSGC.INFO.."New Item name: "..itemName)
            B.print(T.MSGC.INFO.."Link found "..itemLink)
            T.AS.item[new_id].name = itemName
            T.AS.item[new_id].icon = itemTexture
            T.AS.item[new_id].link = itemLink
            T.AS.item[new_id].rarity = itemRarity
        else
            B.print(T.MSGC.INFO.."nothing found for "..item_name)
            
            if not itemString then
                itemString = item_name
            end
            T.AS.item[new_id].name = itemString
        end

        T.AS.mainframe.headerframe.editbox:SetText("")
        B.SavedVariables()
        B.ScrollbarUpdate()
        
        B.SetSelected(B.GetSelected())
        if T.RENAME then T.AS.optionframe.manualpricebutton:Click(); T.RENAME = nil end -- reopen frame to update name
    end

    function B.MoveListButton(orignumber, insertat)

        if not insertat then
            local mouseoverbutton = GetMouseFocus()
            
            if not mouseoverbutton.buttonnumber then
                B.print(T.MSGC.ERROR.."No item to trade place with")
                return false
            end
            insertat = mouseoverbutton.buttonnumber + FauxScrollFrame_GetOffset(T.AS.mainframe.listframe.scrollFrame)
        end

        if insertat == orignumber then -- No moving happened
           return false
        end

        B.print(T.MSGC.INFO.."Move from: "..orignumber.." to: "..insertat)
        -- Get the value we want to move
        local ASmoveme = {}
        B.tcopy(ASmoveme, T.AS.item[orignumber])

       if insertat > orignumber then  --we moved down the list
          table.insert(T.AS.item, insertat + 1, ASmoveme)
          table.remove(T.AS.item, orignumber)
       else -- we moved up the list
           table.remove(T.AS.item, orignumber)
           table.insert(T.AS.item, insertat, ASmoveme)
       end

       B.hidetooltip()
       B.ScrollbarUpdate()
       B.SavedVariables()
       return true
    end

    function B.ChatFrame_OnHyperlinkShow(self, link, text, button)

        if IsShiftKeyDown() and link then
            if string.find(link, 'achievement:*') or string.find(link,'spell:*') then
                return false
            end

            B.print(T.MSGC.INFO.."Link for: "..text)
            if T.AS.mainframe.headerframe.editbox:HasFocus() then T.AS.mainframe.headerframe.editbox:SetText(text) end
        end
    end

    function B.ContainerFrameItemButton_OnModifiedClick(self)

        if IsShiftKeyDown() then
            local bag, item = self:GetParent():GetID(), self:GetID()
            local link = GetContainerItemLink(bag, item)

            B.print(T.MSGC.INFO.."Link: "..link, 2)

            if T.AS.mainframe.headerframe.editbox:HasFocus() then
                T.AS.mainframe.headerframe.editbox:SetText(link)
                BrowseName:SetText(link)
            elseif T.AS.manualprompt.notes:HasFocus() then
                T.AS.manualprompt.notes:SetText(T.AS.manualprompt.notes:GetText()..link)
            end
        end
    end

    function B.InsertLink(text)

        if IsShiftKeyDown() then
            if T.AS.mainframe.headerframe.editbox:HasFocus() then
                T.AS.mainframe.headerframe.editbox:Insert(text)
            end
        end
    end

--[[//////////////////////////////////////////////////

    AUCTION HOUSE FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]
    
    -- T.STATE.QUERYING
    function B.QueryAH()
        B.CloseAllPrompt()

        if (T.AS.currentauction > table.maxn(T.AS.item)) then
            B.print(T.MSGC.INFO.."Nothing to process. Reset", 1)

            T.AS.status = nil
            T.AS.currentauction = 1
            T.AS.mainframe.headerframe.stopsearchbutton:Disable()
            BrowseResetButton:Click()
            return false
        end

        local item = T.AS.item[T.AS.currentauction]
        if AuctionFrameBrowse and AuctionFrameBrowse:IsVisible() then  --some mods change the default AH frame name
            -- Only proceed if item is not set to ignore. Right click item to bypass the ignore filter.
            if T.AS.override or not item.ignoretable or not (item.ignoretable[item.name] and item.ignoretable[item.name].cutoffprice and item.ignoretable[item.name].cutoffprice == 0) then
                B.print(T.MSGC.INFO.."Called query: ("..T.AS.currentauction..")|r "..item.name, 1)

                if Auctioneer then
                    B.print(T.MSGC.ERROR.."Auctioneer detected")
                end

                B.SetSelected(T.AS.currentauction)
                T.AS.mainframe.headerframe.stopsearchbutton:Enable()

                BrowseName:SetText(B.sanitize(item.name))
                ExactMatchCheckButton:SetChecked(item.ignoretable and item.ignoretable[item.name] and item.ignoretable[item.name].exactmatch and true or false)
                -- Sort auctions by buyout price, or minimum bid if there's no buyout price
                SortAuctionSetSort("list", "minbidbuyout")
                SortAuctionSetSort("list", "bid")
                SortAuctionSetSort("list", "unitprice")
                AuctionFrameBrowse_Search()

                T.AS.currentresult = 0
                T.AS.status = T.STATE.WAITINGFORUPDATE
                return true

            else
                B.print(T.MSGC.INFO.."Ignoring query: ("..T.AS.currentauction..")|r "..item.name, 1)
                T.AS.currentauction = T.AS.currentauction + 1
                return B.QueryAH()
            end
        else
            B.print(T.MSGC.ERROR.."Can't find auction frame object")
        end

        T.AS.status = nil
        return false
    end

    -- T.STATE.EVALUATING
    function B.Evaluate()

        if T.AS.manualprompt:IsVisible() then T.AS.manualprompt:Hide() end

        local batch, total = GetNumAuctionItems("list")

        while true do
            
            T.AS.currentresult = T.AS.currentresult + 1  --next!!

            if B.IsEndPage(batch, total) then
                B.print(T.MSGC.EVENT.."[ End of page reached ]")
                return false
            elseif B.IsEndResults(batch, total) then
                B.print(T.MSGC.EVENT.."[ End of AH results: "..total.." ]")
                return false
            end

            T.AS.currentauctionitem = {GetAuctionItemInfo("list", T.AS.currentresult)}
            SetSelectedAuctionItem("list", T.AS.currentresult)

            if B.IsShowPrompt(T.AS.currentauctionitem) then
                
                if ASnodoorbell then
                   B.print(T.MSGC.DEBUG.."Attempting to play sound file")
                   PlaySoundFile("Interface\\Addons\\AuctionSnatch\\Sounds\\DoorBell.mp3", "Master")
                end

                AuctionFrameBrowse_Update()

                T.AS.status = T.STATE.WAITINGFORPROMPT
                if not T.AS.prompt:IsVisible() then T.AS.prompt:Show() end
                return true
            end
        end
    end

    function B.IsEndPage(batch, total)
        -- Stop at the end of page and wait for server to accept a new query
        -- First AuctionFrameBrowse.page = 0
        if T.AS.currentresult > batch and total > ((AuctionFrameBrowse.page + 1) * 50) then
            B.print(T.MSGC.INFO.."Current page: "..AuctionFrameBrowse.page.." Current result: "..tostring((AuctionFrameBrowse.page + 1) * 50).."/"..total)
            
            -- BrowseNextPageButton:Click() doesnt work for some reason
            -- so hack into the blizzard ui code to go to the next page
            AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1
            AuctionFrameBrowse_Search()
            BrowseScrollFrameScrollBar:SetValue(0)

            T.AS.currentresult = 0
            T.AS.status = T.STATE.WAITINGFORUPDATE
            return true
        end
        return false
    end

    function B.IsEndResults(batch, total)
        -- End of AH results. Reset and go to the next query
        if not total or T.AS.currentresult > batch then

            if T.AS.override then -- Single item search, when right clicking button
                T.AS.mainframe.headerframe.stopsearchbutton:Click()
                T.AS.status = nil
                T.AS.override = false
            else
                T.AS.currentauction = T.AS.currentauction + 1
                T.AS.status = T.STATE.QUERYING
            end
            T.AS.currentresult = 0
            T.AS.prompt:Hide()
            return true
        end
        return false
    end

    function B.IsShowPrompt(auction)
        -- Primary conditional and fill info for prompt if returns true
        -- [1]name, [2]texture, [3]count, [4]quality, [5]canUse, [6]level, [7]levelColHeader,
        -- [8]minBid, [9]minIncrement, [10]buyoutPrice, [11]bidAmount, [12]highBidder,
        -- [13]highBidderFullName, [14]owner, [15]ownerFullName, [16]saleStatus, [17]itemId, [18]hasAllInfo
        local item = T.AS.item[T.AS.currentauction]
        local cutoffprice = B.CutoffPrice(auction[1])
        local bid, _, peritembid, peritembuyout = B.GetCost()

        local buyoutPrice = auction[10]
        local minBid = auction[8]
        local minIncrement = auction[9]
        local name = auction[1]
        local count = auction[3]
        local owner = auction[14]

        -- Filters
        if owner == UnitName('player') then
            B.print(T.MSGC.INFO.."Skipping own auction")
            return false

        elseif cutoffprice == 0 then
            -- 0 is always ignore
            return false

        elseif cutoffprice and ASignorebid and (cutoffprice < peritembuyout) then
            -- Ignore bid, item buyout higher than cutoff price
            return false

        elseif cutoffprice and (cutoffprice < peritembid) and buyoutPrice == 0 and not ASignorenobuyout then
            return false

        elseif cutoffprice and ((cutoffprice < peritembid) and (cutoffprice < peritembuyout)) then
            -- Item bid and buyout higher than cutoff price
            return false

        elseif B.IsAlwaysIgnore(name) then
            B.print(T.MSGC.INFO.."Always ignore this name: "..name)
            return false

        elseif buyoutPrice == 0 and (ASignorebid or ASignorenobuyout) then
            -- No buyout, bids disabled or ignore no buyouts enabled
            return false

        elseif auction[12] == true then -- If we are highest bidder
            -- B.print(T.MSGC.INFO.."We are the highest bidder!")
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
        T.AS.prompt.ilvl:SetText(ilvl)
        T.AS.prompt.quantity:SetText(count)
        T.AS.prompt.vendor:SetText(L[10067]..": "..(owner or L[10018]))
        T.AS.prompt.icon:SetNormalTexture(auction[2])
        -- Filter string
        local strcutoffprice = L[10019].."\n"
        if cutoffprice then
            strcutoffprice = strcutoffprice..L[10020]..": "..B.ASGSC(cutoffprice, nil, nil, false, true)
        end
        if item.ignoretable and item.ignoretable[name] and item.ignoretable[name].ilvl then
            if cutoffprice then
                strcutoffprice = strcutoffprice.." | iLvl: |cffffffff"..item.ignoretable[name].ilvl
            else
                strcutoffprice = strcutoffprice.."iLvl: |cffffffff"..item.ignoretable[name].ilvl
            end
        end
        T.AS.prompt.lowerstring:SetText(strcutoffprice)
        -- Set the title
        if quality then
            local _, _, _, hexcolor = GetItemQualityColor(auction[4])
            T.AS.prompt.upperstring:SetText("|c"..hexcolor..name)
        else
            T.AS.prompt.upperstring:SetText(name)
        end

        -- The buyout button
        if (buyoutPrice == 0) or (cutoffprice and (cutoffprice > peritembid) and (cutoffprice < peritembuyout)) then
            -- Buyout does not exist or cutoff meets bid but not buyout
            T.AS.prompt.buyout:Disable()
        else
            T.AS.prompt.buyout:Enable()
        end
        -- The bid button
        if ASignorebid or (peritembid == peritembuyout) then
            -- Ignore bid or bid is the same as buyout
            T.AS.prompt.bid:Disable()
        else
            T.AS.prompt.bid:Enable()
        end

        if ASignorebid then -- Show buyout only
            T.AS.prompt.buyoutonly:Show()

            if T.AS.prompt.bidbuyout:IsShown() then
                T.AS.prompt.bidbuyout:Hide()
            end

            if count > 1 then
                T.AS.prompt.buyoutonly.buyout.single:SetText(B.ASGSC(peritembuyout, nil, nil, false).." "..L[10053])
                T.AS.prompt.buyoutonly.buyout.total:SetText(B.ASGSC(buyoutPrice, nil, nil, false))
            else
                T.AS.prompt.buyoutonly.buyout.single:SetText(B.ASGSC(buyoutPrice, nil, nil, false))
                T.AS.prompt.buyoutonly.buyout.total:SetText("")
            end
        else -- Show bid and buyout
            T.AS.prompt.bidbuyout:Show()

            if T.AS.prompt.buyoutonly:IsShown() then
                T.AS.prompt.buyoutonly:Hide()
            end

            if buyoutPrice == 0 or (cutoffprice and (cutoffprice < peritembuyout)) then
                T.AS.prompt.bidbuyout.bid:SetTextColor(0,1,0,1)
                T.AS.prompt.bidbuyout.buyout:SetTextColor(1,1,1,1)
            else
                T.AS.prompt.bidbuyout.buyout:SetTextColor(0,1,0,1)
                T.AS.prompt.bidbuyout.bid:SetTextColor(1,1,1,1)
            end

            if count > 1 then
                T.AS.prompt.bidbuyout.each:Show()
                T.AS.prompt.bidbuyout.bid.single:SetText(B.ASGSC(peritembid, nil, nil, false))
                T.AS.prompt.bidbuyout.bid.total:SetText(B.ASGSC(bid, nil, nil, false))
                T.AS.prompt.bidbuyout.buyout.single:SetText(B.ASGSC(peritembuyout, nil, nil, false))
                T.AS.prompt.bidbuyout.buyout.total:SetText(B.ASGSC(buyoutPrice, nil, nil, false))
            else
                T.AS.prompt.bidbuyout.each:Hide()
                T.AS.prompt.bidbuyout.bid.single:SetText(B.ASGSC(bid, nil, nil, false))
                T.AS.prompt.bidbuyout.bid.total:SetText("")
                T.AS.prompt.bidbuyout.buyout.single:SetText(B.ASGSC(buyoutPrice, nil, nil, false))
                T.AS.prompt.bidbuyout.buyout.total:SetText("")
            end
        end

        B.print(T.MSGC.INFO.."Show prompt:|r"..T.MSGC.BOOL.." true")
        return true
    end

    function B.CutoffPrice(name)
        -- Ignore price is the cutoff point where we won't spend more than this price
        local cutoffprice

        if T.AS.item[T.AS.currentauction].ignoretable and T.AS.item[T.AS.currentauction].ignoretable[name] then
            cutoffprice = T.AS.item[T.AS.currentauction].ignoretable[name].cutoffprice
            --B.print(T.MSGC.INFO.."Cutoff price "..tostring(name)..": "..tostring(cutoffprice))
        else
            cutoffprice = nil
        end
        return cutoffprice
    end

    function B.GetCost()
        -- If bidAmount = 0 that means no one ever bid on it
        -- minBid will always contain the original posted price (ignores existing bids)
        local bid, peritembid, peritembuyout
        local auction = T.AS.currentauctionitem
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

    function B.IsAlwaysIgnore(name)

        if T.AS.item[T.AS.currentauction].ignoretable and T.AS.item[T.AS.currentauction].ignoretable[name] then
            if T.AS.item[T.AS.currentauction].ignoretable[name].cutoffprice == 0 then
                return true
            end
        end
        return false
    end

    function B.TrackerUpdate(name, quantity, bid, buyout)

        if not T.AS.boughtauctions[name] then
            T.AS.boughtauctions[name] = { ['bid'] = 0,
                                        ['buy'] = 0,
                                        ['bidquantity'] = 0,
                                        ['buyquantity'] = 0}
        end

        if bid then
            T.AS.boughtauctions[name]['bid'] = T.AS.boughtauctions[name]['bid'] + bid
            T.AS.boughtauctions[name]['bidquantity'] = T.AS.boughtauctions[name]['bidquantity'] + quantity
        else
            T.AS.boughtauctions[name]['buy'] = T.AS.boughtauctions[name]['buy'] + buyout
            T.AS.boughtauctions[name]['buyquantity'] = T.AS.boughtauctions[name]['buyquantity'] + quantity
        end
    end

    function B.RegisterSearchAction()
        -------------- THANK YOU AUCTIONEER ----------------
        for i = 1, 199 do
            local owner_button = _G["AuctionsButton"..i]
            if not owner_button then break end

            if ASsavedtable.searchauction then
                owner_button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                owner_button:HookScript("OnDoubleClick", function(self)
                    BrowseResetButton:Click()
                    AuctionFrameBrowse.page = 0
                    BrowseName:SetText(B.sanitize(GetAuctionItemInfo("owner", GetSelectedAuctionItem("owner"))))
                    AuctionFrameTab1:Click()
                    AuctionFrameBrowse_Search()
                end)
            end
        end
    end

    function B.RegisterCancelAction()
        -------------- THANK YOU AUCTIONEER ----------------
        for i = 1, 199 do
            local owner_button = _G["AuctionsButton"..i]
            if not owner_button then break end

            if ASsavedtable.cancelauction then
                owner_button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
                owner_button:HookScript("PostClick", B.CancelAuction)
            end
        end
    end

    function B.CancelAuction(self, button)

        if button == "RightButton" then
            SetSelectedAuctionItem("owner", self:GetID() + GetEffectiveAuctionsScrollFrameOffset())
            if CanCancelAuction(GetSelectedAuctionItem("owner")) then
                B.UntrackCancelledAuction()
                CancelAuction(GetSelectedAuctionItem("owner"))
            end
        end
    end

    function B.UntrackCancelledAuction()

        local auction = {GetAuctionItemInfo("owner", GetSelectedAuctionItem('owner'))}
        T.AS.events['REMOVE'][#T.AS.events['REMOVE'] + 1] = auction[1]
    end

    function B.AuctionSold(self, event, arg1)
        -- Workaround because auction sold doesn't work properly since Cross Server support
        -- We want: ERR_AUCTION_SOLD_S, ERR_AUCTION_EXPIRED_S
        if string.match(arg1, string.gsub(ERR_AUCTION_SOLD_S, "(%%s)", ".+")) ~= nil then
            -- Find sold item name
            local item = string.match(arg1, string.gsub(ERR_AUCTION_SOLD_S, "(%%s)", "(.*)"))
            T.AS.events['SOLD'][#T.AS.events['SOLD'] + 1] = {
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
            T.AS.events['REMOVE'][#T.AS.events['REMOVE'] + 1] = item

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

    function B.CurrentOwnedAuctions(name)
        -- If name is nil, return the entire owned auction list
        local current = {}
        local _, totalAuctions = GetNumAuctionItems("owner")

        for x = 1, totalAuctions do
            local auction = {GetAuctionItemInfo("owner", x)}

            if name == auction[1] or not name then
                current[#current + 1] = {
                    ['index'] = x,
                    ['icon'] = auction[2],
                    ['quantity'] = auction[3],
                    ['quality'] = auction[4],
                    ['bidprice'] = auction[8],
                    ['price'] = auction[10],
                    ['sold'] = auction[16],
                    ['buyer'] = auction[12],
                    ['link'] = GetAuctionItemLink("owner", x)
                }
            end
        end
        return current
    end

    function B.CompareAuctionsTable(newtable, oldtable)
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


--[[//////////////////////////////////////////////////

    MASS CANCEL FUNCTIONS

----\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\]]

-- T.STATE.QUERYING
    function B.QueryCancelOwnerAH()
        B.CloseAllPrompt()

        if AuctionFrameAuctions and AuctionFrameAuctions:IsVisible() then

            T.AS.CancelStatus = T.STATE.WAITINGFORUPDATE
            T.AS.currentownerresult = 0
            if not T.AS.cancelprompt:IsVisible() then T.AS.cancelprompt:Show() end
            return true
        else
            B.print(T.MSGC.ERROR.."Can't find auction frame object")
        end

        T.AS.CancelStatus = nil
        return false
    end

    -- T.STATE.EVALUATING
    function B.EvaluateCancelOwner()

        while true do
            
            T.AS.currentownerresult = T.AS.currentownerresult + 1  --next!!
            auction = T.AS.currentownerauctions[(#T.AS.currentownerauctions + 1) - T.AS.currentownerresult]
            if auction then

                SetSelectedAuctionItem("owner", auction.index)

                if B.IsShowCancelOwnerPrompt(auction) then -- always true

                    AuctionFrameAuctions_Update()

                    T.AS.CancelStatus = T.STATE.WAITINGFORPROMPT
                    if not T.AS.cancelprompt:IsVisible() then T.AS.cancelprompt:Show() end
                    return true
                end
            end

            B.print(T.MSGC.INFO.."Nothing to process. Reset", 1)

            T.AS.CancelStatus = nil
            T.AS.currentownerauction = 1
            T.AS.cancelprompt:Hide()
            return false
        end
    end

    function B.IsShowCancelOwnerPrompt(auction)

        local _, item = B.GetSelected()
        local peritembid, peritembuyout
        T.AS.cancelprompt.icon:SetNormalTexture(auction.icon)
        T.AS.cancelprompt.icon.link = auction.link
        T.AS.cancelprompt.quantity:SetText(auction.quantity)

        -- Fill prompt info, title, icon, bid or buyout text/buttons
        -- Set the title
        if auction.quality then
            local _, _, _, hexcolor = GetItemQualityColor(auction.quality)
            T.AS.cancelprompt.upperstring:SetText("|c"..hexcolor..item.name)
        else
            T.AS.cancelprompt.upperstring:SetText(item.name)
        end

        if auction.quantity > 1 then
            T.AS.cancelprompt.bidbuyout.each:Show()
            T.AS.cancelprompt.bidbuyout.bid.single:SetText(B.ASGSC(auction.bidprice * (1/auction.quantity), nil, nil, false))
            T.AS.cancelprompt.bidbuyout.bid.total:SetText(B.ASGSC(auction.bidprice, nil, nil, false))
            T.AS.cancelprompt.bidbuyout.buyout.single:SetText(B.ASGSC(auction.price * (1/auction.quantity), nil, nil, false))
            T.AS.cancelprompt.bidbuyout.buyout.total:SetText(B.ASGSC(auction.price, nil, nil, false))
        else
            T.AS.cancelprompt.bidbuyout.each:Hide()
            T.AS.cancelprompt.bidbuyout.bid.single:SetText(B.ASGSC(auction.bidprice, nil, nil, false))
            T.AS.cancelprompt.bidbuyout.bid.total:SetText("")
            T.AS.cancelprompt.bidbuyout.buyout.single:SetText(B.ASGSC(auction.price, nil, nil, false))
            T.AS.cancelprompt.bidbuyout.buyout.total:SetText("")
        end

        B.print(T.MSGC.INFO.."Show cancel prompt:|r"..T.MSGC.BOOL.." true", 2)
        return true
    end
