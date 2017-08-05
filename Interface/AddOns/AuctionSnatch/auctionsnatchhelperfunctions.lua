
--[[

    HELPER FUNCTIONS

    Anything that needs repetitive actions or calculations
    Tips: 
        -- Multiplication are faster than division
        -- Local is faster than global. Re-assign global as a new local if used a lot

]]

------ MAIN TABLE

    function AS_template(name)

        ASprint(MSG_C.EVENT.."Generating template: "..name)
        AS.item = {}
        ASautostart = true
        ASautoopen = true
        ASnodoorbell = true
        ASignorebid = false
        ASignorenobuyout = false
        AOicontooltip = true

        local serverName = GetRealmName()
        if serverName == name then
            AOserver = true
        else
            AOserver = false
        end

        ACTIVE_TABLE = name
        AS.mainframe.headerframe.listlabel:SetText(ACTIVE_TABLE)
        AS_SavedVariables()

        LISTNAMES = {}
        I_LISTNAMES = {}
        for key, value in pairs(ASsavedtable) do
            if not OPT_LABEL[key] and not OPT_HIDDEN[key] then-- Found a server
                LISTNAMES[#LISTNAMES + 1] = key
            end
        end
        I_LISTNAMES = table_invert(LISTNAMES)
        
        if #LISTNAMES > 1 then
            AS.mainframe.headerframe.nextlist:Enable()
            AS.mainframe.headerframe.prevlist:Enable()
        else
            AS.mainframe.headerframe.nextlist:Disable()
            AS.mainframe.headerframe.prevlist:Disable()
        end
    end

    function AS_LoadTable(name)

        local serverName = GetRealmName()
        ACTIVE_TABLE = name
        AS.mainframe.headerframe.listlabel:SetText(ACTIVE_TABLE)
        AS.item = {}
        AS_tcopy(AS.item, ASsavedtable[name])

        if ASsavedtable[name]["test"] then
            ASprint("test = "..ASsavedtable[name]["test"])
        end

        if ASsavedtable[name].ASnodoorbell ~= nil then
            ASnodoorbell = ASsavedtable[name].ASnodoorbell
            --ASprint("Doorbell sound = "..MSG_C.BOOL..""..tostring(ASnodoorbell))
        else
            ASnodoorbell = true
            AS_SavedVariables()
        end
        if ASsavedtable[name].ASignorebid ~= nil then
            ASignorebid = ASsavedtable[name].ASignorebid
            --ASprint("Ignore bid = "..MSG_C.BOOL..""..tostring(ASignorebid))
        else
            ASignorebid = false
            AS_SavedVariables()
        end
        if ASsavedtable[name].ASignorenobuyout ~= nil then
            ASignorenobuyout = ASsavedtable[name].ASignorenobuyout
            --ASprint("Ignore no buyout = "..MSG_C.BOOL..""..tostring(ASignorenobuyout))
        else
            ASignorenobuyout = false
            AS_SavedVariables()
        end
        if ASsavedtable[name].AOicontooltip ~= nil then
            AOicontooltip = ASsavedtable[name].AOicontooltip
        else
            AOicontooltip = true
            AS_SavedVariables()
        end
        if serverName == name then
            AOserver = true
            AS_SavedVariables()
        elseif ASsavedtable[name].AOserver ~= nil then
            AOserver = ASsavedtable[name].AOserver
        else
            AOserver = false
            AS_SavedVariables()
        end

        LISTNAMES = {}
        I_LISTNAMES = {}
        for key, value in pairs(ASsavedtable) do
            if not OPT_LABEL[key] and not OPT_HIDDEN[key] then-- Found a list
                LISTNAMES[#LISTNAMES + 1] = key
            end
        end
        I_LISTNAMES = table_invert(LISTNAMES)

        if #LISTNAMES > 1 then
            AS.mainframe.headerframe.nextlist:Enable()
            AS.mainframe.headerframe.prevlist:Enable()
        else
            AS.mainframe.headerframe.nextlist:Disable()
            AS.mainframe.headerframe.prevlist:Disable()
        end

        AS_ScrollbarUpdate()
    end

    function AS_SwitchTable(name)
        AS.mainframe.listframe.scrollFrame:SetVerticalScroll(0)
        AS_LoadTable(name)
    end

------ LOGGING
    local ASprintstack = -1
    local messagestring = ""

    function ASprint(message, level)

        if ASdebug or (level == 1) then

            if ASprintstack == -1 then
                messagestring = MSG_C.DEFAULT.."AuctionSnatch|r: "
            end

            if not message then
                DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
                return false 
            end

            ASprintstack = ASprintstack + 1

            if (type(message) == "table") then
                local filler=string.rep(". . ", ASprintstack)

                DEFAULT_CHAT_FRAME:AddMessage(messagestring.."{table} --> ")
                for k, v in pairs(message) do
                    messagestring = filler.."["..k.."] = "
                    ASprint(v)
                end
            
            elseif (type(message) == "userdata") then

            elseif (type(message) == "function") then
                DEFAULT_CHAT_FRAME:AddMessage(messagestring.." A function(self)")
            elseif (type(message) == "boolean") then
                DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
            else
                DEFAULT_CHAT_FRAME:AddMessage(messagestring..tostring(message))
            end
            
            ASprintstack = ASprintstack - 1
       end
    end

------ GOLD MANAGEMENT

    ASGetGSC = function (money)
            if (money == nil) then money = 0 end
            local g = math.floor(money / 10000)
            local s = math.floor((money - (g*10000)) / 100)
            local c = math.ceil(money - (g*10000) - (s*100))
            return g,s,c
    end

    -- formats money text by color for gold, silver, copper
    function ASGSC(money, exact, dontUseColorCodes, icon, letters)
        -------------- THANK YOU BOTTOMSCANNER ----------------
        --if not (exact) then exact = true end;
        if (type(money) ~= "number") then return end
        if icon == false then
            local TEXT_NONE = "0"
               
            local GSC_GOLD="ffd100"
            local GSC_SILVER="e0e0e0"
            local GSC_COPPER="c8602c"
            local GSC_VALUE = "ffffff"
            local GSC_START="|cff%s%s|r|cff%s%s|r"
            local GSC_PART=".|cff%s%s|r|cff%s%s|r"
            local GSC_NONE="|cffa0a0a0"..TEXT_NONE.."|r"
           
            if (not money) then money = 0 end
            if (not exact) and (money >= 10000) then money = math.floor(money / 100 + 0.5) * 100 end
            local g, s, c = ASGetGSC(money)
           
            local gsc = ""
            local fmt = GSC_START
            if (g > 0) then gsc = gsc..string.format(fmt, GSC_GOLD, g, GSC_GOLD, letters and "g" or "") fmt = GSC_PART end
            if (s > 0) or (c > 0) then gsc = gsc..string.format(fmt, GSC_SILVER, s, GSC_SILVER, letters and "s" or "") fmt = GSC_PART end
            if (c > 0) then gsc = gsc..string.format(fmt, GSC_COPPER, c, GSC_COPPER, letters and "c" or "") end
            if (gsc == "") then gsc = GSC_NONE end

            return gsc
        else
            return "|cffffffff"..GetCoinTextureString(money, 11).."|r"--gsc
        end
    end

------ GAME TOOLTIP
    function ASsettooltip(frame, text)
        if frame then
            if frame:GetRight() >= (GetScreenWidth() * 0.5) then
                GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
            else
                GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            end
            
            if text then -- Title
                GameTooltip:SetText(text)
            end

            GameTooltip:SetBackdropBorderColor(1, 1, 1, 0.5)
            GameTooltip:SetBackdropColor(0, 0, 0, 0.8) -- Make it darker
        end

        return GameTooltip
    end

    local ticker = nil
    function ASshowtooltip(frame, notes, text, always)

        if frame then
            
            tooltip = ASsettooltip(frame, text, fadeout)
            if not always then ticker = C_Timer.NewTicker(3, AShidetooltip, 1) end

            if not notes then
                return tooltip
            else
                tooltip:AddLine(notes, 0, 1, 1, 1, 1)
            end
            tooltip:Show()
       end
    end

    function AShidetooltip()

        if ticker then ticker:Cancel(); ticker = nil end
        GameTooltip:Hide()
    end

------ FILE AND TABLE MANAGEMENT
    -- tcopy: recursively copy contents of one table to another.  from wowwiki
    function AS_tcopy(to, from)
        -- "to" must be a table (possibly empty)
        for k, v in pairs(from) do

            if type(v) == "table" then
                to[k] = {}
                AS_tcopy(to[k], v)
            else
                to[k] = v
            end
        end
    end

    -- tcount: count table members even if they're not indexed by numbers
    function AS_tcount(tab)
        local n = 0
        
        for _ in pairs(tab) do
            n = n + 1
        end
        return n
    end

    function table_invert(t)
        local u = {}
        for k, v in pairs(t) do u[v] = k end
        return u
    end

    function ASremoveduplicates(ASlist)

        local newlist = {}
        local ASexists = false

        for i = 1,#ASlist do
            ASexists = false
            if not (newlist[1]) then
                ASprint("Newlist is empty.")
            end
            
            for j = 1,#newlist do
                ASprint("Does ASlist["..i.."] ("..ASlist[i].." = newlist["..j.."] ("..newlist[j].." ? ")    
                if (ASlist[i] == newlist[j]) then --it exists in the new list already
                    ASexists  = true
                    break
                end
            end
            if(ASexists == false) then
                ASprint("Inserting: "..ASlist[i])
                tinsert(newlist,ASlist[i])
            else
                ASprint("NOT Inserting: "..ASlist[i])
            end
        end

        return newlist
    end

------ VISIBILITY, CURSOR

    function GetCursorScaledPosition()
        local scale, x, y = UIParent:GetScale(), GetCursorPosition()
        return x / scale, y / scale
    end

    function ASrowsthatcanfit()  --i dunno.  i don't see anything wrong with this
        --so, mainframe is 420, right?  header is 120.  300 is the listframe height.  25 is button height  300/25 = 12 - crap, only 11 show?!  why?!
        --lolol on debugging, ourheight is 299.9999999999999552965            thats messed up
        if AS and AS.mainframe and AS.mainframe.listframe then
            local ourheight = math.ceil(AS.mainframe.listframe:GetHeight()) - AS_FRAMEWHITESPACE
            --ASprint("Listframe height = "..ourheight)
            --ASprint("AS_BUTTON_HEIGHT = "..AS_BUTTON_HEIGHT)
            --ASprint("math.floor(ourheight / AS_BUTTON_HEIGHT) = "..math.floor(ourheight / AS_BUTTON_HEIGHT))
            
            --math.floor(ourheight / AS_BUTTON_HEIGHT)
            return math.floor(ourheight / AS_BUTTON_HEIGHT)
        end
        return 10--default
    end

function ASsanitize(str)

    str = string.gsub(str,'|c........',"")
    str = string.gsub(str,'|r',"")
    --str = string.gsub(str,'[^a-z:%p]',"")
    return str
end

function AS_SetSelected(listnumber)

    AS.selected.listnumber = listnumber
    AS.selected.item = AS.item[listnumber]
end

function AS_GetSelected()

    return AS.selected.listnumber, AS.selected.item
end

function AS_CloseAllPrompt()

    if AS.manualprompt:IsVisible() then AS.manualprompt:Hide() end
    if AS.cancelprompt:IsVisible() then AS.cancelprompt:Hide() end
    if AS.prompt:IsVisible() then AS.mainframe.headerframe.stopsearchbutton:Click() end
end

function test_sold()
    --AS.soldauctions = {}
    for x = 1, 1 do
        table.insert(AS.soldauctions, {
                ['name'] = "Obliterum",
                ['quantity'] = 5,
                ['icon'] = 1341656,
                ['price'] = 22500000,
                ['link'] = "|cffa335ee|Hitem:124125::::::::110:102::::::|h[Obliterum]|h|r",
                ['buyer'] = nil,
                ['time'] = GetTime() + 360,
                ['timer'] = C_Timer.After(360, function() table.remove(AS.soldauctions, 1) ; AO_OwnerScrollbarUpdate() end)
        })
        table.insert(AS.soldauctions, {
                ['name'] = "Shal'dorei Silk",
                ['quantity'] = 200,
                ['icon'] = 1379172,
                ['price'] = 110000,
                ['link'] = "|cffffffff|Hitem:124437::::::::110:102::::::|h[Shal'dorei Silk]|h|r",
                ['buyer'] = "Morvevel",
                ['time'] = GetTime() + 360,
                ['timer'] = C_Timer.After(360, function() table.remove(AS.soldauctions, 1) ; AO_OwnerScrollbarUpdate() end)
        })
        table.insert(AS.soldauctions, {
                ['name'] = "Runescale Koi",
                ['quantity'] = 10,
                ['icon'] = 1387371,
                ['price'] = 120000,
                ['link'] = "|cffffffff|Hitem:124111::::::::110:102::::::|h[Runescale Koi]|h|r",
                ['buyer'] = "Morvevel",
                ['time'] = GetTime() + 360,
                ['timer'] = C_Timer.After(360, function() table.remove(AS.soldauctions, 1) ; AO_OwnerScrollbarUpdate() end)
        })
    end
    AO_OwnerScrollbarUpdate()
end
