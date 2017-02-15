
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
            if not OPT_LABEL[key] then-- Found a server
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
        AS.item['LastAuctionSetup'] = nil
        AS.item['LastListButtonClicked'] = nil

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
                messagestring = MSG_C.DEFAULT.."AuctionOne|r: "
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
    function ASGSC(money, exact, dontUseColorCodes)
        -------------- THANK YOU BOTTOMSCANNER ----------------
       --if not (exact) then exact = true end;
       if (type(money) ~= "number") then return end
       
       local TEXT_NONE = "0"
       
       local GSC_GOLD="ffd100"
       local GSC_SILVER="999999"
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
       if (g > 0) then gsc = gsc..string.format(fmt, GSC_VALUE, g, GSC_GOLD, 'g') fmt = GSC_PART end
       if (s > 0) or (c > 0) then gsc = gsc..string.format(fmt, GSC_VALUE, s, GSC_SILVER, 's') fmt = GSC_PART end
       if (c > 0) then gsc = gsc..string.format(fmt, GSC_VALUE, c, GSC_COPPER, 'c') end
       if (gsc == "") then gsc = GSC_NONE end
       
       return gsc
    end

------ GAME TOOLTIP

    function ASshowtooltip(frame, notes)
        
        if frame then
            
            if frame:GetRight() >= (GetScreenWidth() * 0.5) then
                GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
            else
                GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
            end
            
            if notes then
                GameTooltip:SetText(notes, 0, 1, 1, 1, 1)
                GameTooltip:SetBackdropColor(0, 0, 0, 0.9) -- Make it darker
                GameTooltip:SetBackdropBorderColor(1, 1, 1, 0.5)
                GameTooltip:Show()
            end
       end
    end

    function AShidetooltip()
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
        local u = { }
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

    function ASvisibility(compared_to)
        local x,y = GetCursorScaledPosition()
        --ASprint("Cursor x,y="..x..","..y.."  Left, right, bottom, top="..compared_to:GetLeft()..","..compared_to:GetRight()..","..compared_to:GetBottom()..","..compared_to:GetTop())
        
        if(x < compared_to:GetLeft() or x > compared_to:GetRight() or y < compared_to:GetBottom() or y > compared_to:GetTop()) then
            return false
        end
        return true
    end

    function ASrowsthatcanfit()  --i dunno.  i don't see anything wrong with this
        --so, mainframe is 420, right?  header is 120.  300 is the listframe height.  25 is button height  300/25 = 12 - crap, only 11 show?!  why?!
        --lolol on debugging, ourheight is 299.9999999999999552965            thats messed up
        if(AS) then
            if AS.mainframe then
                if AS.mainframe.listframe then
                    local ourheight = math.ceil(AS.mainframe.listframe:GetHeight()) - AS_FRAMEWHITESPACE
                    --ASprint("Listframe height = "..ourheight)
                    --ASprint("AS_BUTTON_HEIGHT = "..AS_BUTTON_HEIGHT)
                    --ASprint("math.floor(ourheight / AS_BUTTON_HEIGHT) = "..math.floor(ourheight / AS_BUTTON_HEIGHT))
                    
                    --math.floor(ourheight / AS_BUTTON_HEIGHT)
                    return math.floor(ourheight / AS_BUTTON_HEIGHT)
                end
            end
        end
        return 10--default
    end

function ASsanitize(str)

    str = string.lower(str)
    str = string.gsub(str,'|c........',"")
    str = string.gsub(str,'|r',"")
    --str = string.gsub(str,'[^a-z:%p]',"")
    return str
end

function ASbuttontolistnum(button)
    if AS.item.LastListButtonClicked then
        ASprint(MSG_C.INFO.."Activated button:|r "..AS.item.LastListButtonClicked)
        return AS.item.LastListButtonClicked
    end
end
