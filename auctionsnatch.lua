-- BrowseNextPageButton.
-- AuctionFrameBrowse.page
---------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------- DATA STRUCTURES EXPLAINED ------------------------------
--[[
--i'm trying something ambitious.  included in the name of my variables is
--the entire parent/child heirarchy
--every variable will be a child of 'AS' eg AS.mainframe
--anything with its parent being AS.mainframe will be AS.mainframe.whatever
--multiple items, buttons, will be AS.mainframe.button[x]
--
--so name will be very long, and looking like:
--AS.mainframe.listframe.itembutton[x].lefttexture
--
--I'm also hoping to not use the 2nd argument of any 'createframe' function
--I don't like all the global variables floating around
--maybe this heirarchial, table-centered structure will help
--
--(it also might just be a pain in the ass)
]]
--edit.  Its a pain in the ass


local FALSE=0
local TRUE=1
local QUERYING=1
local WAITINGFORUPDATE=2
local EVALUATING=3
local WAITINGFORPROMPT=4
local BUYING = 5
AS_FRAMEWHITESPACE=10
AS_BUTTON_HEIGHT=23
AS_GROSSHEIGHT = 420
AS_HEADERHEIGHT = 120
AS_LISTHEIGHT = AS_GROSSHEIGHT-AS_HEADERHEIGHT
AS={}
AS.elapsed=0
AS.scrollelapsed=0
ASfirsttime=false

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



function ASinitialize()
   ASprint("|c00aaffffvariables loaded.  Initializing.")

    hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", AS_ContainerFrameItemButton_OnModifiedClick)
    hooksecurefunc("ChatFrame_OnHyperlinkShow",AS_ChatFrame_OnHyperlinkShow)
    --ChatFrame_OnHyperlinkShow(self, link, text, button)


   local playerName = UnitName("player");
   local serverName = GetRealmName();
   if (playerName == nil or playerName == UNKNOWNOBJECT or playerName == UNKNOWNBEING) then
      return;
   end

   if (SLsavedtable) then                     --old version
      --sigh.  i had to change all names.  what a pain.
      AS_tcopy(ASsavedtable, SLsavedtable)
   end

   AS.item={}
    if ASsavedtable then
        if(ASsavedtable[serverName]) then
             --ASprint("|c00ff0000 Table found.  Copying.")
             --ASprint(ASsavedtable)
             AS_tcopy(AS.item, ASsavedtable[serverName])
             --check boxes
             if(ASsavedtable[serverName]["test"]) then
                 ASprint("test ="..ASsavedtable[serverName]["test"])
             end

            if ASsavedtable[serverName].ASautostart ~= nil then
                ASautostart = ASsavedtable[serverName].ASautostart
            end
            if ASsavedtable[serverName].ASautoopen ~= nil then
                ASautoopen = ASsavedtable[serverName].ASautoopen
            end
            if ASsavedtable[serverName].ASnodoorbell ~= nil then
                ASnodoorbell = ASsavedtable[serverName].ASnodoorbell
                ASprint("|c00ff0000 Checkbox found, doorbell = "..tostring(ASnodoorbell))
            end
            if ASsavedtable[serverName].ASignorebid ~= nil then
                ASignorebid = ASsavedtable[serverName].ASignorebid
            end
            if ASsavedtable[serverName].ASignorenobuyout ~= nil then
                ASignorenobuyout = ASsavedtable[serverName].ASignorenobuyout
            end


          else
             ASprint("new server found.")
             --the very first time this happens, the old data, from the old version, has all the info stored in the base ASsaved table
             --I want to save that.  but I don't want that old data sticking around forever.
             --so, copy the prior version data into a temporary table, Clear all the data, then copy the data back into the correct data structure

             if not (ASfirsttime) then
                ASfirsttime=true
                --check if there is old data (key of '1' only exists in the old version.)
                if(ASsavedtable[1]) then
                   DEFAULT_CHAT_FRAME:AddMessage(AS_OLDTONEW)
                   local temptable={}
                   AS_tcopy(temptable,ASsavedtable)
                   ASsavedtable={}
                   AS_tcopy(AS.item,temptable)  --hopefully anyone with the old version will get their data copied this way
                end
             end
        end

   else
      ASprint("|c00ff0000nothing  saved  :(")
   end
   --ASprint("attempting to ASprint out loaded table.")
   --ASprint(AS.item)

   AScurrentauctionsnatchitem=1
   AScurrentahresult=0
   AS.queryelapsed = 3 --3 seconds, meaning the first query will happen instantly.
   AS.status=nil

   -- nowhere better to put this
   --browsename is the auction house edit box.  hook it
   if (BrowseName) then
      AS.oldbrowsenamehandler=BrowseName:GetScript("OnEditFocusGained")
      BrowseName:SetScript("OnEditFocusGained",
               function()
                  if (AS.status == nil) then
                    return false  --should catch the infinate loop
                  end
                  AS.status=nil  --else the mod will mess up typing
                  --         ASprint("Custome Onclick handler called.")
                  AS.oldbrowsenamehandler() --for some reason this causes an infinate loop :(
               end)
   end

    -- Verify settings, otherwise set default
    if ASautostart == nil then
        ASprint("|c0055eeaa autostart not found")
        ASautostart = true
    end
    if ASautoopen == nil then
        ASprint("|c0055eeaa autoopen not found")
        ASautoopen = true
    end
    if(AS.mainframe) then
        AS.mainframe.headerframe.autostart:SetChecked(ASautostart)
        AS.mainframe.headerframe.autoopen:SetChecked(ASautoopen)
    end
    -- Other settings
    if ASnodoorbell == nil then
        ASprint("|c0055eeaa doorbell not found")
        ASnodoorbell = true
    end
    if ASignorebid == nil then
        ASprint("|c0055eeaa ignore bid not found")
        ASignorebid = false
    end
    if ASignorenobuyout == nil then
        ASprint("|c0055eeaa ignore buyout not found")
        ASignorenobuyout = false
    end

-- restore positioning data
   if not (ASfirsttime) then
      if (ASsavedposition) then
        ASprint("loading Positiondata.")
        ASprint(ASsavedposition.point)
        ASprint(ASsavedposition.relativePoint)
        ASprint(ASsavedposition.xOfs)
        ASprint(ASsavedposition.yOfs)



         if(ASsavedposition.point and ASsavedposition.relativePoint and ASsavedposition.xOfs and ASsavedposition.yOfs) then
            AS.mainframe:ClearAllPoints()
            AS.mainframe:SetPoint(ASsavedposition.point,UIParent,ASsavedposition.relativePoint,ASsavedposition.xOfs,ASsavedposition.yOfs)
         end
      end
   end




--- font size testing and adjuting height of prompt
   ASprint("font testing.")
   local _,height,_=GameFontNormal:GetFont()
   ASprint("height="..height)
   local newheight=height*10 + (AS_BUTTON_HEIGHT+AS_FRAMEWHITESPACE)*6  -- LINES, 5 BUTTONS + 1 togrow on
   ASprint("new height="..newheight)
   AS.prompt:SetHeight(newheight)

   ASscrollbar_Update()
end

-- ONLOAD, duh
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

    DEFAULT_CHAT_FRAME:AddMessage(AS_LOADTEXT)

    ------ SLASH COMMANDS
        SLASH_AS1 = "/AS";
        SLASH_AS2 = "/as";
        SLASH_AS3 = "/As";
        SLASH_AS4 = "/aS";
        SLASH_AS5 = "/Auctionsnatch";
        SLASH_AS6 = "/AuctionSnatch";
        SLASH_AS7 = "/AUCTIONSNATCH";
        SLASH_AS8 = "/auctionsnatch";

        SlashCmdList["AS"] = ASmain;

    AScreatemainframe()
    AScreateprompt()
    AScreatemanualprompt()
   --   AScreateauctiontab()  --cant.  auction ui doesnt get created until after all mods are created


   ------------------------------------------------------------------------
   --------------------------------- now to make the header region
   ------------------------------------------------------------------------
   --what does a header region need?
   --an edit box to type in queries
   -- an 'add item' button?  ASsavedtable=1
   -- an icon?  right clicking an item/dragging it will make it pop up here?
   -- then maybe one can choose to discard or accept this selection into the list?

   ---------------------------------------create a title frame here
   --   ourtitle=AS.mainframe:CreateTitleRegion() --??
   --   ourtitle:SetAllPoints()
   --make a button or maybe a texture or frame will do?  something clickableon
   --set the width, height
   --center it at the top +30 up or something
   --set the border, the background, the color, the edgefile, the onmousedown handler
   --mousedown on the title will make the mainframe moveable


   tinsert(UISpecialFrames,AS.mainframe:GetName());
   tinsert(UISpecialFrames,AS.prompt:GetName());
   tinsert(UISpecialFrames,AS.manualprompt:GetName());


   ASprint("|c00449955 end onload ")

   AS.prompt:Hide()
   AS.manualprompt:Hide()


end
---------------------------------------------------------------------------

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
        ASsavevariables()
        return
    elseif self.value == "ASignorebid" then
        ASignorebid = not ASignorebid
        ASsavevariables()
        return
    elseif self.value == "ASignorenobuyout" then
        ASignorenobuyout = not ASignorenobuyout
        ASsavevariables()
        return
    end

    if not (self.value == serverName) then  --dont import ourself
      --table.insert doesnt work.. grrrrrr!!!
        local index,temptable
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

    ASscrollbar_Update()
end




--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
function ASscrollbar_Update()
   --this redraws all the buttons and make sure they're showing the right stuff.
   --ASprint("printing sl.item at beginning of update.")
   --ASprint(AS.item)
   local offset = FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
   local ASnumberofitems

   if not (AS) then
      ASprint("error.  AS not found in scrollbarupdate.")
      return false
   end
   if not (AS.item) then
      --      ASprint("error.  ASitem not found in scrollbarupdate.")
      return false
   end
   if not (AS.mainframe) then
      ASprint("error.  AS mainframe not found in scrollbarupdate.")
      return false
   end

   --aight, so what do we have to do
   AS.optionframe:Hide()  --weird bugs if you delete while scrolling

   --get the objects we're working with
   --local ASscrollbar = getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
   --local ASscrollupbutton = getglobal(  AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBarScrollUpButton" );
   --local ASscrolldownbutton = getglobal(  AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBarScrollDownButton" );

   ASnumberofitems = table.maxn(AS.item)
   FauxScrollFrame_Update(AS.mainframe.listframe.scrollFrame, ASnumberofitems, ASrowsthatcanfit(), AS_BUTTON_HEIGHT)


   --[[if ASnumberofitems < ASrowsthatcanfit() then
      --disable the top and bottom buttons

      ASscrollbar:SetMinMaxValues(0,0)
      ASscrollupbutton:Disable()
      ASscrolldownbutton:Disable()

   else
      --else enable them
      --if a row was changed/added/removed we have to do this.  we can call it every time too, that will be fine
      ASscrollbar:SetMinMaxValues(0,ASnumberofitems-ASrowsthatcanfit())  --i think this is the appropriate logic?
      ASscrollupbutton:Enable()
      ASscrolldownbutton:Enable()

   end]]

   --GetValue()
   --value decides which rows to start showing.
   --we show items value to value+getrowsthatcanfit()

   local x,hexcolor,itemRarity
   local ourbutton, currentscrollbarvalue

   currentscrollbarvalue=offset


   ASprint("scrollbarvalue = "..currentscrollbarvalue.."  #of items="..ASnumberofitems)


   if(AS) then
      if (AS.item) then
      for x=1,ASrowsthatcanfit() do --apparently theres a bug here for some screen resolutions
        --get all buttons
        --get the appropriate item, which will be x + value
        if  (AS.item[x+currentscrollbarvalue] and AS.mainframe.listframe.itembutton[x]) then
           if (AS.item[x+currentscrollbarvalue].name) then
           --set the item link
              --set the icon
              hexcolor = ""

              if (AS.item[x+currentscrollbarvalue].icon) then
                 local icon=AS.item[x+currentscrollbarvalue].icon
                 AS.mainframe.listframe.itembutton[x].icon:SetNormalTexture(icon)
                 --AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0,0.640625, 0,0.640625)  --i have no idea how this manages to make the texture bigger, but hallelujah it does
                 AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)

                 --set the item link - if theres an icon, there must be a link
                 local link=AS.item[x+currentscrollbarvalue].link
                 AS.mainframe.listframe.itembutton[x].link = link
                 if not (AS.item[x+currentscrollbarvalue].rarity) then --updated for 3.1 to include colors
                    _, _, itemRarity, _,_,_,_,_,_,_ = GetItemInfo(link)
                    AS.item[x+currentscrollbarvalue].rarity = itemRarity
                 end
                 --ASprint("|c0000eeccIcon was found, attempting to set rarity and get color")
                 --ASprint("Rarity = "..tostring(AS.item[x+currentscrollbarvalue].rarity))
                 if(AS.item[x+currentscrollbarvalue].rarity) then  --sometimes is still nil even after looking at the exact link  :(
                    --ASprint("color = "..GetItemQualityColor(AS.item[x+currentscrollbarvalue].rarity))
                    _,_,_,hexcolor = GetItemQualityColor(AS.item[x+currentscrollbarvalue].rarity)
                    hexcolor = "|c"..hexcolor
                 end
              else
                 -- clear icon, link
                 AS.mainframe.listframe.itembutton[x].icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
                    AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)  --i have no idea how this manages to make the texture bigger, but hallelujah it does
                 AS.mainframe.listframe.itembutton[x].link = nil
                 AS.mainframe.listframe.itembutton[x].rarity = nil

              end





              AS.mainframe.listframe.itembutton[x].leftstring:SetText(hexcolor..tostring(AS.item[x+currentscrollbarvalue].name))
              AS.mainframe.listframe.itembutton[x]:Show()
              --AS.mainframe.listframe.itembutton[x].rightstring:SetText(tostring(x+currentscrollbarvalue))
              --if we have a 'ignore' price  -- doesnt work because every item has lots of ignore prices, one for each different result
    --        if( AS.item[x+currentscrollbarvalue].ignoretable) then
                --AS.mainframe.listframe.itembutton[x].rightstring:SetText(AS.item[x+currentscrollbarvalue].ignoretable[name])
              --end


           else
                 ASprint("|c00ff0000error.  |ritem exists but no name for "..x.. "  Scrollbarvalue ="..currentscrollbarvalue)
                 AS.item[x+currentscrollbarvalue] = nil
                 --ASscrollbar:SetValue(currentscrollbarvalue-1)
                 --ASprint("printing AS.item")
                 --ASprint(AS.item)
                 --table.remove(AS.item,x+currentscrollbarvalue)
                 --ASprint("removed item."..x+currentscrollbarvalue)
                 if(x+currentscrollbarvalue == 1) then
                    AS.item={}
                 end

           end
        else
           ASprint("no .item.  index= "..x)
           --if theres no item, then clear the text
           AS.mainframe.listframe.itembutton[x].leftstring:SetText("")
           -- clear icon, link
           AS.mainframe.listframe.itembutton[x].icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
            AS.mainframe.listframe.itembutton[x].icon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)  --i have no idea how this manages to make the texture bigger, but hallelujah it does
           AS.mainframe.listframe.itembutton[x].link = nil
           AS.mainframe.listframe.itembutton[x].rightstring:SetText("")
           AS.mainframe.listframe.itembutton[x]:Hide()

        end
        --end loop
     end
      end
   else
      ASprint("self |c00ff0000should never be seen>")
   end

   ASsavevariables()

end





--///////////////////////////////////////////////////////////////////////////
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

function ASmain(input)

   ASprint("someone did a /AS")


   -- this is called when we type /AS
   if AS.mainframe then

      ASprint("frame layer ="..AS.mainframe:GetFrameLevel())




      if (input == "prompt") then
         if (AS.prompt:IsVisible()) then
            AS.prompt:Hide()
         else
            AS.prompt:Show()
         end



      elseif (input == "test") then
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

            if AuctionFrameBrowse then  --some mods change the default AH frame name
                if AuctionFrameBrowse:IsVisible() then  --if we talked to the ah dude
                    canQuery,canQueryAll = CanSendAuctionQuery()  --check if we can send a query
                    if canQuery then
                        if(testtable[AStesttablenum]) then
                            local name = testtable[AStesttablenum]
                            AStesttablenum = AStesttablenum + 1

                            BrowseName:SetText(name)
                            AuctionFrameBrowse_Search()

                            --AS.status=WAITINGFORUPDATE
                            --return true

                        end

                    end

                end

            end



        elseif (input == "debug") then
             if(ASdebug) then
                ASdebug = not (ASdebug)
                DEFAULT_CHAT_FRAME:AddMessage("Debug set to: "..tostring(ASdebug))
             else
                ASdebug = true
                DEFAULT_CHAT_FRAME:AddMessage("Debug turned on")
             end
             return false
        elseif (input == "copperoverride") then
            if(ASsavedtable.copperoverride) then
                ASsavedtable.copperoverride = false
            else
                ASsavedtable.copperoverride = true
            end

        end
   else

      ASprint("mainframe not found???")
    return false

   end

    AS.mainframe:Show()
      ASbringtotop()

end

------------>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----------<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
function AS_OnEvent(self,event)

   --local timestamp, event, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags = CombatLogGetCurrentEntry()  --for documentation purposes
   if (event == "VARIABLES_LOADED") then

      ASinitialize()

   elseif (event == "AUCTION_ITEM_LIST_UPDATE") then
        ASprint("EVENT |c00ff3333"..event)
      if (AS.status==BUYING) then
         AS.status=EVALUATING
      end

      if (AS.status==WAITINGFORUPDATE) then
         AS.status=EVALUATING
      end

   elseif (event=="AUCTION_HOUSE_SHOW") then
        --AUTO START
        if not (ASauctiontab) then
            AScreateauctiontab()
        end

        if ASautostart == TRUE and not ASautoopen then
            -- do nothing
        elseif ASautostart == TRUE then
            if not IsShiftKeyDown() then  -- do the opposite if shift is held
                AS.status = QUERYING
                ASmain()
            end
        elseif IsShiftKeyDown() then
                AS.status = QUERYING
                ASmain()
        elseif ASautoopen then
            -- Automatically display frame, just don't auto start
            ASmain()
        end

   elseif event=="AUCTION_HOUSE_CLOSED" then

        AS.mainframe.headerframe.editbox:SetText("")
        AS.prompt:Hide()
        AS.manualprompt:Hide()
        
        if ASopenedwithah then  --in case i do a manual /as prompt for testing purposes
            if AS.mainframe then
                AS.mainframe:Hide()
            end
            ASopenedwithah = false
        else
            AS.mainframe:Hide()
        end
        
        AS.status = nil
    
    elseif  (string.match("AUCTION",event)) then
        ASprint(event)
   end
end




function AS_OnUpdate(self,elapsed)
   --this is the Blizzard Update, called every computer clock cycle ~millisecond
   --   ASprint("calling AS update "..elapsed)
   if not elapsed then return end;  --else will infinite loop
   if (AS.mainframe:IsVisible()) then
      if(ASscrollup or ASscrolldown) then
         AS.scrollelapsed=AS.scrollelapsed+elapsed

         if(AS.scrollelapsed > .05) then  --this is the repeat time
            AS.scrollelapsed=0
            -------------------------scrolling while mouse is held down processing
            if (AS and AS.mainframe and AS.mainframe.listframe and AS.mainframe.listframe.scrollbarframe) then
                if ASscrolldown then
                   local ourscrollbar
                   ourscrollbar=getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
                   if(ourscrollbar) then
                        ourscrollbar:SetValue(ourscrollbar:GetValue() + 1)
                    end
                elseif ASscrollup then
                   local ourscrollbar

                   ourscrollbar=getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
                   if(ourscrollbar) then
                        ourscrollbar:SetValue(ourscrollbar:GetValue() - 1)

                   end
                end
            end
         end

      end  --end if scrolling
      --------------------------------------------------
      ----this is needed because sometimes a query completes, and the results are sent back - but the ah will not accept a query right away. there is no event that fires when a query is possible, so i just have to spam requests

     if AS.status then

         AS.elapsed=AS.elapsed+elapsed
         if (AS.elapsed > .1) then     --a tenth of a second?
            AS.elapsed=0

            if( AS.status==QUERYING) then
               --AS.status=WAITINGFORUPDATE
               ASqueryah()
            elseif (AS.status==WAITINGFORUPDATE) then
               --nothing to do
             ASprint("Waiting for Update event....")
             AuctionFrameBrowse_Search()  --spam me and see what happens
            elseif (AS.status==EVALUATING) then
              ASevaluate()
            elseif (AS.status==WAITINGFORPROMPT) then
               --the prompt buttons will change the status accordingly
            elseif (AS.status==BUYING) then

            end
         end --end if elapsed > .5
      end  --end if sl.status
   end
end



--*********************************************************************************
function ASqueryah()
        
    if not (AS.item) then
        ASprint("error.  AS.item not found.")
        AS.status = nil
        AS.mainframe.headerframe.stopsearchbutton:Disable()
        return false
    end
    
    if not (AScurrentauctionsnatchitem) then
        AScurrentauctionsnatchitem=1
    end
    
    if (AScurrentauctionsnatchitem > table.maxn(AS.item)) or (AScurrentauctionsnatchitem < 1) then
        ASprint("nothing to process. resetting.")

        AS.status=nil
        AScurrentauctionsnatchitem=1
        AS.mainframe.headerframe.stopsearchbutton:Disable()
        return false
    end


   if AuctionFrameBrowse then  --some mods change the default AH frame name
      if AuctionFrameBrowse:IsVisible() then  --if we talked to the ah dude
         canQuery,canQueryAll = CanSendAuctionQuery()  --check if we can send a query
         if canQuery then
            ASprint("called query "..AScurrentauctionsnatchitem.." = "..AS.item[AScurrentauctionsnatchitem].name)

            if Auctioneer then
               ASprint("auctioneer interfere")
            end

            if (AS.item[AScurrentauctionsnatchitem].name) then
               BrowseName:SetText(ASsanitize(AS.item[AScurrentauctionsnatchitem].name))
               AuctionFrameBrowse_Search()
               AScurrentahresult=0
               AS.status=WAITINGFORUPDATE
               return true
            else
               AS.status=nil
            end
         else
            ASprint("canquery failed.  server not ready to send")
         end
      else
     AS.status=nil
      end
   else
      ASprint("couldn't find the auction frame object")
      AS.status=nil
   end
   return false
end


function ASevaluate()
    local batch,total
    local name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner
    local messagestring,cutoffprice
    local showprompt
    local bid, buyout, cutoffprice, budget, priceperitembid, priceperitembuyout

    ASprint("|c000055ee Evaluate() reached")

    batch,total = GetNumAuctionItems("list")

    if AS.manualprompt:IsShown() then
        AS.manualprompt:Hide()
    end

    while(true) do
        AScurrentahresult=AScurrentahresult+1  --next!!
         --reset stuff
        --processing-wise, this here is a very expensive hit
        --so i'm only gonna do it (and similar stuff) here, ONCE, and pass everything in as parametners
        name, texture, count, quality, canUse, level, levelColHeader, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner=GetAuctionItemInfo("list",AScurrentahresult);



        if (ASisendofpage(total)) then
            return false
        end
        if(ASisendoflist(batch,total)) then
            return false
        end

        if (ASisdoublequery(name)) then
            return false
        end

        if(tonumber(buyoutPrice) == 0) and (ASignorenobuyout) then
            return false
        end

        cutoffprice = ASgetcutoffprice(name,quality,count)
        --ASprint("|c0000aaff ASgetcutoffprice end.  Cutoff returned? = "..tostring(cutoffprice))

        showprompt = ASisshowprompt(cutoffprice,name, texture, count, quality, canUse, level, minBid, minIncrement, buyoutPrice, bidAmount, highBidder, owner,batch,total)

        if showprompt then
            showprompt = false
            if ASnodoorbell then
               ASprint("attempting to play sound file.")
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

            if (AS.item[AScurrentauctionsnatchitem].priceoverride) then
                if(ASsavedtable and ASsavedtable.copperoverride) then
                    AS.prompt.priceoverride:SetText(AS.item[AScurrentauctionsnatchitem].priceoverride)
                else
                    AS.prompt.priceoverride:SetText(AS.item[AScurrentauctionsnatchitem].priceoverride / COPPER_PER_GOLD)
                end
            else
                AS.prompt.priceoverride:SetText("")
            end


            AS.status=WAITINGFORPROMPT
            AS.prompt:Show()
            return true --exit
         end
   end --end loop

   return false  --will never happen, but, /shrug
end


function ASisdoublequery(name)
    if not ((strfind(strlower(name),strlower(AS.item[AScurrentauctionsnatchitem].name))) or (name == AS.item[AScurrentauctionsnatchitem].name )) then
      --[[there is a bug here.  The prompt shows the last window from the last query.  heres how it happens i think:
      Bid on last item in ah.
      check if its the end - it is.  go to next query.
      send query - wait for update.
      Update happens, either from the bid being accepted or query completing!
      Bid accepted, status set to evaluating, This line called - but the old info from the old query is still returned!

      The fix - save the old one, compare it to the new, make sure they dont match if querys are new?
      --no, because what if they put the same name in twice in the list
      --after a bid, do nothing until we get an update.  THEN check if its the end, and go to the next query.
      --edit:still doesnt work!  we're gonna have to disallow double queries
      ]]
        ASprint("|c00ff0000ERROR. |c0000ff00"..strlower(AS.item[AScurrentauctionsnatchitem].name).."|c00ff0000 not found in |c0000ff00"..strlower(name).."|r.  Status set to re query.")
        ASprint("Strfind result = "..tostring(strfind(strlower(name),strlower(AS.item[AScurrentauctionsnatchitem].name))))
        AScurrentahresult=0
        --AS.status = WAITINGFORUPDATE --?
        AS.status=QUERYING
        return true
    end
    return false
end
function ASisendofpage(total)
    --stop at the end of page and wait for.. something
      if(AScurrentahresult > 50 and total > 50) then

         ASprint("currentahresult > 50 (end of page).    page="..AuctionFrameBrowse.page..".  Calling  AuctionFrameBrowse_Search()")

        --BrowseNextPageButton:Click()  --go to the next page --doesnt work for some reason

         --  so hack into the blizzard ui code to go to the next page

         AuctionFrameBrowse.page = AuctionFrameBrowse.page + 1;
         AuctionFrameBrowse_Search();


         AScurrentahresult=0
         AS.status = WAITINGFORUPDATE
         ASprint("Waiting for update")
         return true
      end
      return false
end

function ASisendoflist(batch,total)
    if (AScurrentahresult > batch or total < 1) then
         -- end of ah results.  reset and go to next query.
         ASprint(AScurrentahresult.."|c00eeaa00 = Current result > batch = "..batch.." (or total < 1).  Going to next query after:"..AScurrentauctionsnatchitem)
         AScurrentahresult=0

         if AS.status_override then -- Single item search, when right clicking button
            AS.mainframe.headerframe.stopsearchbutton:Disable()
            AS.status = nil
            AS.status_override = nil
        else
            AScurrentauctionsnatchitem=AScurrentauctionsnatchitem+1
            AS.status=QUERYING
        end
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
        ASprint("returning false in isshowprompt Buyoutpr5ice = "..buyoutPrice.."     ignorebid = "..tostring(ASignorebid))
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

    messagestring="\n"..AS_INTERESTEDIN..":"
    messagestring=messagestring..itemRarityColors[quality]
    messagestring=messagestring.."\n"..name.."|r"
    if ( count > 1) then
       messagestring=messagestring.." x"..count
    end
    if (owner) then
       messagestring=messagestring.."\n"..AS_BY.." "..owner
    end
    messagestring=messagestring.." "..AS_FOR

    ASprint("button "..AS_BUTTONBUYOUT.." is enabled")
      messagestring=messagestring.."\n\n"..ASGSC(buyout).." "..AS_BUYOUT
      if(count>1) then
           messagestring=messagestring.."\n("..ASGSC(peritembuyout).." "..AS_EACH..")"
     end

--check if a buyout is available
    if (AS.prompt[AS_BUTTONBUYOUT]:IsEnabled() == 1) then
       ASprint("button "..AS_BUTTONBUYOUT.." is enabled")
        messagestring=messagestring.."\n\n"..ASGSC(buyout).." "..AS_BUYOUT
        if(count>1) then
             messagestring=messagestring.."\n("..ASGSC(peritembuyout).." "..AS_EACH..")"
       end
    else
       ASprint("button "..AS_BUTTONBUYOUT.." is NOT enabled.  cutoff = "..tostring(cutoffprice))
    end

    if (not ASignorebid) then
        --a bid should always be possible
        messagestring=messagestring.. "\n"..ASGSC(bid).." "..AS_BID
        if(count>1) then
           messagestring=messagestring.."\n            ("..ASGSC(peritembid).." "..AS_EACH..")"
    --             lines=lines+1
        end
    end

    if (cutoffprice and tonumber(cutoffprice) > 0) then

           messagestring=messagestring.."\n\n"..AS_CUTOFF..":\n"
           messagestring=messagestring..ASGSC(tonumber(cutoffprice))
    else
        ASprint("|c00ffaaaaNo Cutoff price found!")
    end


    return messagestring
end

-----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function ASsavevariables()
   local serverName = GetRealmName();
   if (AS) then
      if (AS.item) then
         if not (ASsavedtable) then
            ASsavedtable={}
            ASsavedtable.copperoverride = true
         end
    --   if not (ASsavedtable[serverName]) then
            ASsavedtable[serverName]={}
    --   end
         AS_tcopy(ASsavedtable[serverName],AS.item)
    --[[
         ASprint("saving |c0066aaff"..serverName)
         ASprint("here is sl.item post-save")
         ASprint(AS.item)
         ASprint("here is slsavedtable")
         ASprint(ASsavedtable)
        ]]
      else
         ASprint("Nothing found to save.")
      end

      if (AS.mainframe) then
      --check boxes
         ASsavedtable[serverName].ASautostart = ASautostart
         ASsavedtable[serverName].ASautoopen = ASautoopen
         ASsavedtable[serverName].ASnodoorbell = ASnodoorbell
         ASsavedtable[serverName].ASignorebid = ASignorebid
         ASsavedtable[serverName].ASignorenobuyout = ASignorenobuyout

         --ASsavedtable[serverName]["test"]= tostring(false)

          --ASprint(ASsavedtable[serverName]["test"])
        -- ASprint("|c00ee00eesaving autostart="..tostring(ASautostart))
       -- ASprint("|c00ee00eesaving nodoorbell="..tostring(ASnodoorbell))
        --ASprint("|c00ee00eesaving nodoorbell="..tostring(ASsavedtable[serverName].ASnodoorbell))

         -- save any movement of position :)
         local point, relativeTo, relativePoint, xOfs, yOfs = AS.mainframe:GetPoint(1)
         if not (ASsavedposition) then
            ASsavedposition={}
         end
         ASsavedposition.point=point
         ASsavedposition.relativePoint=relativePoint
         ASsavedposition.xOfs=xOfs
         ASsavedposition.yOfs=yOfs

       else
         ASprint("error.  check box not found to save.")
      end
   end

end


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
   --[[
   ASprint("|c00ff00aa---------------------------math.floor testing-------------------------")
   ASprint("|c00ff00aa ASGSC(buyout) = "..ASGSC(buyout))
   ASprint("|c00ff00aa buyout = "..buyout)
   ASprint("|c00ff00aa count = "..count)
   ASprint("|c00ff00aa  buyout/count = "..buyout/count)
   ASprint("|c00ff00aa  floor(buyout/count) = "..math.floor(buyout/count))
   ]]
   return bid,buyout,peritembid,peritembuyout
end


function AScreatebuttonhandlers()
------------------------------------------------------------------
   --create all the script handlers for the buttons
   --------------------------------------------------------------------

   AS[AS_BUTTONBUYOUT] = function()  --buyout
                 local bid,buyout
                 _,buyout=ASgetcost(AScurrentahresult)
                 PlaceAuctionBid("list",AScurrentahresult,buyout)  --the actual buying call.  Requires a hardware event?
                 --the next item will be the same location as what was just bought, so no need to increment
                 AScurrentahresult = AScurrentahresult - 1
                 AS.prompt:Hide()
                 AS.status=BUYING

              end
   AS[AS_BUTTONBID] = function() --bid

                ASprint("AS.bid called.  current ah result="..tostring(AScurrentahresult))

                 local bid,buyout
                 bid,_=ASgetcost(AScurrentahresult)

                 PlaceAuctionBid("list",AScurrentahresult,bid)  --the actual buying call.  Requires a hardware event?


                 --AS.status=EVALUATING --OMG here's the bug.  why would this be different from the buying button???!?!?!?   im dumb?
                 AS.prompt:Hide()
                 AS.status=BUYING

              end
  AS[AS_BUTTONNEXTAH] = function()  --next in ah

                ASprint("you clicked skip.")

                 AS.prompt:Hide()
                 AS.status=EVALUATING
              end
  AS[AS_BUTTONNEXTLIST] = function()  --next in list
                AScurrentauctionsnatchitem=AScurrentauctionsnatchitem+1
                AScurrentahresult=0
                AS.status=QUERYING
                AS.prompt:Hide()
             end
  AS[AS_BUTTONIGNORE] = function()  --ignore this item
                if not (AS.item[AScurrentauctionsnatchitem].ignoretable) then
                  ASprint("creating ignore table for item#"..AScurrentauctionsnatchitem.." ,result#"..AScurrentahresult)
                   AS.item[AScurrentauctionsnatchitem].ignoretable = {}
                end
                local name,_,_,quality=GetAuctionItemInfo("list",AScurrentahresult);
                if not name then return false end
                AS.item[AScurrentauctionsnatchitem].ignoretable[name] = {}
                AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice = 0 --zero, meaning ignore.  >1 means its got a budget
                AS.item[AScurrentauctionsnatchitem].ignoretable[name].quality=quality  --used when showing whats ignored, makes it look better
                AS.status=EVALUATING
                ASsavevariables()
             end

    AS[AS_BUTTONIGNOREMANUAL] = function()  --ignore this item
            local name = AS.item["ASmanualitem"].name
            local listnumber = AS.item['ASmanualitem'].listnumber
            
            if not AS.item[listnumber].ignoretable then
                AS.item[listnumber].ignoretable = {}
            end
            AS.item[listnumber].ignoretable[name] = {}
            AS.item[listnumber].ignoretable[name].cutoffprice = 0
            AS.item[listnumber].ignoretable[name].quality = quality  --used when showing whats ignored, makes it look better
            AS.item[listnumber].priceoverride = nil
            AS.item['ASmanualitem'] = nil
            ASsavevariables()
            AS.manualprompt:Hide()
    end

   AS[AS_BUTTONEXPENSIVE] = function()  --too expensive
                if not (AS.item[AScurrentauctionsnatchitem].ignoretable) then
                   ASprint("creating ignore table for item#"..AScurrentauctionsnatchitem.." ,result#"..AScurrentahresult)
                   AS.item[AScurrentauctionsnatchitem].ignoretable = {}
                end
                local name, count,quality
                name,_,count,quality=GetAuctionItemInfo("list",AScurrentahresult);
                if not name then return false end
                bid,buyout,peritembid,peritembuyout = ASgetcost(AScurrentahresult)
                if (AS.prompt[AS_BUTTONBUYOUT]:IsEnabled() == 0) then
                  peritembuyout=peritembid  --the buyout button was disabled.  use the bid price.
                end

                AS.item[AScurrentauctionsnatchitem].ignoretable[name] = {}
                AS.item[AScurrentauctionsnatchitem].ignoretable[name].cutoffprice = peritembuyout
                AS.item[AScurrentauctionsnatchitem].ignoretable[name].quality=quality  --used when showing whats ignored, makes it look better
                 AS.status=EVALUATING
                ASsavevariables()
                --AScurrentahresult=AScurrentahresult  --redo this item, to bid, this time :)
             end

    AS[AS_BUTTONEXPENSIVEMANUAL] = function()  --too expensive
            local name = AS.item['ASmanualitem'].name
            local listnumber = AS.item['ASmanualitem'].listnumber

            if not AS.item[listnumber].ignoretable then
               AS.item[listnumber].ignoretable = {}
            end

            AS.item[listnumber].ignoretable[name] = {}
            AS.item[listnumber].ignoretable[name].cutoffprice = AS.item['ASmanualitem'].priceoverride
            AS.item[listnumber].ignoretable[name].quality = quality  --used when showing whats ignored, makes it look better
            AS.item[listnumber].priceoverride = nil
            AS.item['ASmanualitem'] = nil
            ASsavevariables()
            AS.manualprompt:Hide()
    end

   AS[AS_BUTTONDELETE] = function()  --delete
                 table.remove(AS.item,AScurrentauctionsnatchitem)
                 AS.status=QUERYING
                 ASscrollbar_Update()
              end
   AS[AS_BUTTONDELETEALL] = function()  --delete all
               if(IsControlKeyDown()) then
                  AS.item={}
                  AS.status=nil
                  ASsavedtable=nil
                  ASscrollbar_Update()
               end
            end

   AS[AS_BUTTONUPDATE] = function()  --update
                 local  name, texture, _, quality, _, _, _, _, _, _, _, _=GetAuctionItemInfo("list",AScurrentahresult);
                 local link = GetAuctionItemLink("list", AScurrentahresult)
                 if(AS.item[AScurrentauctionsnatchitem]) then
                    AS.item[AScurrentauctionsnatchitem].name = name
                    AS.item[AScurrentauctionsnatchitem].icon = texture
                    AS.item[AScurrentauctionsnatchitem].link = link
                    AS.item[AScurrentauctionsnatchitem].rarity = quality
                    AScurrentahresult=AScurrentahresult-1  --redo this item :)
                    AS.status=EVALUATING
                    ASscrollbar_Update()
                 end
              end
end

function AS_ContainerFrameItemButton_OnModifiedClick(self)
    ASprint("Modifier click")
    --first check if shift (maybe alt?) key is down
    --does our edit box have focus
    --is the cursor over an item
    --get the bag,id -->get the link
    --put link in editbox

    if(IsShiftKeyDown()) then
        ASprint("ShiftModifier click")
        if (AS.mainframe.headerframe.editbox:HasFocus()) then --?

            local bag, item = self:GetParent():GetID(), self:GetID()
            ASprint("bag = "..bag.."  item="..item)
            local link = GetContainerItemLink(bag,item)
            ASprint(link)
            AS.mainframe.headerframe.editbox:SetText(link)
        end
    end
end

function ASadditem()  --this is when they hit enter and something is in the box
    local itemname = AS.mainframe.headerframe.editbox:GetText()
    ASprint("itemname=")
    ASprint(itemname)

    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemCount, itemEquipLoc, itemTexture = GetItemInfo(itemname)

    if(type(itemname) == "table") then  --why the heck does this return a table?  its text!  text!
        ASprint("PROBMEL!  Its a table?!?!?")
        itemname = itemname[1]
    end

    if((not itemname) or (itemname == "")  or (string.find(itemname,'achievement:*'))) then
        ASprint("there is nothing (valid) in the editbox!")
        AS.mainframe.headerframe.editbox:SetText("")
        return false
    end



    ASprint("newitemname = "..tostring(itemname))
    local max=table.maxn(AS.item)
    AS.item[max+1]={}

    if(itemLink) then
        ASprint("a link was found "..itemLink)
        AS.item[max+1].name=itemName
        AS.item[max+1].icon=itemTexture
        AS.item[max+1].link=itemLink
        AS.item[max+1].rarity=itemRarity
    else

        ASprint("nothing found for "..itemname)
        --itemname=ASsanitize(itemname)
        --ASprint("sanitized:   "..itemname)
        local found, _, itemString = string.find(itemname, "^|c%x+|H(.+)|h%[.*%]")  --see wowwiki, itemlink.  removes brackets and crap
        ASprint("No ItemLink found for "..tostring(itemname)..".  setting .name to = "..tostring(itemString))
        if (not itemString) then itemString = itemname; end
        AS.item[max+1].name=itemString
    end

    AS.mainframe.headerframe.editbox:SetText("")
    ASscrollbar_Update()
end
function AS_ChatFrame_OnHyperlinkShow(self, link, text, button)

    ASprint("OnHyperLinkShow Called>")
    if(IsShiftKeyDown() )then


        ASprint("link:")
        ASprint(link)
        if(not link) then
            return false
        end
        if(string.find(link,'achievement:*') or (string.find(link,'spell:*'))) then
            return false
        end
        ASprint("text")
        ASprint(text)

        if (AS.mainframe.headerframe.editbox:HasFocus()) then --?
            AS.mainframe.headerframe.editbox:SetText(text)
        end

    end

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
function ASmovelistbutton(orignumber,insertat)
    ASprint("|c00aaffffSTART of function MOVELISTBUTTON().  Insertat = "..tostring(insertat).."  orignumber = "..tostring(orignumber))
    if not (AS.item) then
       return false
    end
    local mouseoverbutton,ourmax
    --find the button the mouse is on - that is the destination, unless one was explicitly passed in as a parameter
    if(not insertat) then
        mouseoverbutton = GetMouseFocus()
        if(mouseoverbutton.buttonnumber) then

           --ASscrollbar = AS.mainframe.listframe.scrollbarframe
           insertat = mouseoverbutton.buttonnumber+ FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)---1-- + ASscrollbar:GetValue()
           ASprint("Insertat needs to be created. = "..tostring(insertat).."  orignumber = "..tostring(orignumber))
        else
            ASprint("No insertat passed in.   No mouseoverfocus() found.  error i think.")
           return false
        end
    else
        ASprint("passed in Insertat = "..tostring(insertat).."  orignumber = "..tostring(orignumber))
    end

    --if no moving happened
    if(insertat == orignumber) then
       return false
    end




    ourmax = table.maxn(AS.item)
    if (insertat > ourmax) then
        insertat = ourmax+1
    end
    --get the value we want to move
    ASmoveme={}
    if(AS.item[orignumber]) then  -- nil when you try to drag an empty box
        AS_tcopy(ASmoveme,AS.item[orignumber])
    else
       return false
    end

    --now, if we moved a button up (backwards, lower numbers), we have to delete the original first, then insert
    -- if we moved a button down (below), we insert first, delete second

   if (insertat > orignumber) then  --we moved down the list
      table.insert(AS.item,insertat+1,ASmoveme)
      table.remove(AS.item, orignumber)
   else
       table.remove(AS.item, orignumber)
       table.insert(AS.item,insertat,ASmoveme)
   end

   AShidetooltip()
   ASscrollbar_Update()
   return true
end
