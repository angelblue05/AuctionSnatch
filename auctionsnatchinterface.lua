local FALSE=0
local TRUE=1
local QUERYING=1
local WAITINGFORUPDATE=2
local EVALUATING=3
local WAITINGFORPROMPT=4
local BUYING = 5
local F, C = unpack(Aurora)
local r, g, b = C.r, C.g, C.b

function AScreatemainframe()
-------------------------------------------------------------------------------
   --this is the main listing frame and its children/buttons
   -------------------------------------------------------------------------------
    ASprint("|c00229977 creating mainframe")

----- MAIN FRAME
    -------------- STYLE ----------------
    AS.mainframe = CreateFrame("Frame","ASmainframe", UIParent)
    AS.mainframe:SetPoint("right",-100,0)
    AS.mainframe:SetHeight(AS_GROSSHEIGHT+8)
    AS.mainframe:SetWidth(280)
    AS.mainframe:Hide()
    AS.mainframe:SetBackdrop({  bgFile = "Interface/Tooltips/UI-Background",
                                edgeFile = nil,
                                tile = true, tileSize = 32, edgeSize = 32,
                                insets = { left = 0, right = 0, top = 0, bottom = 0}
    })
    AS.mainframe:SetBackdropColor(0,0,0,.85)
    AS.mainframe:SetMovable(true)
    AS.mainframe:EnableMouse(true)
    -------------- SCRIPT ----------------
    AS.mainframe:SetScript("OnMouseDown", function(self)
        AS.mainframe:StartMoving()
    end)
    AS.mainframe:SetScript("OnMouseUp", function(self)
        AS.mainframe:StopMovingOrSizing()
        ASsavevariables()
    end)
    AS.mainframe:SetScript("OnShow", function(self)
        ASbringtotop()
    end)
    AS.mainframe:SetScript("OnEnter", function(self)
        ASbringtotop()
    end)
    AS.mainframe:SetScript("OnLeave", function(self)
        --check if the mouse actually left the frame
        local x,y = GetCursorScaledPosition()
        --[[ i decided not to check top and bottom because often i accidentaly drift up and down - only left and right seems to be when i actaully want to hide the frame
        if(x<AS.mainframe:GetLeft() or x > AS.mainframe:GetRight() or y > AS.mainframe:GetTop() or y < AS.mainframe:GetBottom()) then ]]
        if (x < AS.mainframe:GetLeft() or x > AS.mainframe:GetRight()) then
            AS.mainframe:SetFrameStrata("LOW")
          --AS.mainframe.headerframe.editbox:ClearFocus()
        end
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
    AS.mainframe.headerframe:SetHeight(AS_HEADERHEIGHT)  --this should be sufficient


    AS.mainframe.listframe = CreateFrame("Frame","FauxScrollFrameTest",AS.mainframe)
    AS.mainframe.listframe:SetPoint("TOPLEFT", AS.mainframe.headerframe,"BOTTOMLEFT",0,6)
    AS.mainframe.listframe:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", 0, 10)


    AS.mainframe.listframe.scrollFrame = CreateFrame("ScrollFrame","FauxScrollFrameTestScrollFrame",AS.mainframe.listframe,"FauxScrollFrameTemplate")
      -- note the anchors: the area of the scrollframe is the scrollable area
      -- (that intercepts mousewheel to scroll). it does not include the scrollbar,
      -- which is anchored off the right (hence the -28 xoffset)
    AS.mainframe.listframe.scrollFrame:SetPoint("TOPLEFT", AS.mainframe.headerframe,"BOTTOMLEFT", 0, 6)
    AS.mainframe.listframe.scrollFrame:SetPoint("BOTTOMRIGHT", AS.mainframe, "BOTTOMRIGHT", -40, 38)
    --AS.mainframe.mainlistframe._scrollframe:SetHeight(AS_LISTHEIGHT)
      -- make sure frame.ScrollFrameUpdate defined early -- and be prepared for
      -- that function to run before the scrollframe has any real data
    F.ReskinScroll(AS.mainframe.listframe.scrollFrame.ScrollBar)
    AS.mainframe.listframe.scrollFrame:SetScript("OnShow",ASscrollbar_Update)
    AS.mainframe.listframe.scrollFrame:SetScript("OnVerticalScroll",function(self,offset)
        FauxScrollFrame_OnVerticalScroll(self,offset,20,ASscrollbar_Update)
    end)

   -- create background frame to contain list
  --AS.mainframe.frame:SetSize(228,256)
  --AS.mainframe.frame:SetPoint("CENTER")
  --AS.mainframe.frame:SetBackdrop({bgFile="Interface\\DialogFrame\\UI-DialogBox-Background", insets={left=4,right=4,top=4,bottom=4}, tileSize=16, tile=true, edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=16})
    -- create list of 12 buttons
    AS.mainframe.listframe['itembutton'] = {}
    for i=1,ASrowsthatcanfit() do
    -- the button itself
        AS.mainframe.listframe.itembutton[i]=AScreatelistbutton(i)
        currentrow=AS.mainframe.listframe.itembutton[i]
        if i==1 then
            currentrow:SetPoint("TOP")
        else
            currentrow:SetPoint("TOP",previousrow,"bottom")
        end
        currentrow:Show()
        previousrow=currentrow
    --[[AS.mainframe.frame.list[i] = CreateFrame("Button",nil,AS.mainframe.frame)
    AS.mainframe.frame.list[i]:SetSize(200,20)
    AS.mainframe.frame.list[i]:SetPoint("TOPLEFT",AS.mainframe.frame,"TOPLEFT",8,(i-1)*-20-8)
    -- the icon
    AS.mainframe.frame.list[i].icon = AS.mainframe.frame.list[i]:CreateTexture(nil,"ARTWORK")
    AS.mainframe.frame.list[i].icon:SetSize(16,16)
    AS.mainframe.frame.list[i].icon:SetPoint("LEFT",4,0)
    -- the text label
    AS.mainframe.frame.list[i].name = AS.mainframe.frame.list[i]:CreateFontString(nil,"ARTWORK","GameFontHighlight")
    AS.mainframe.frame.list[i].name:SetSize(200-16-8,20) -- full width-icon-padding(both sides)
    AS.mainframe.frame.list[i].name:SetJustifyV("CENTER") -- center text vertically
    AS.mainframe.frame.list[i].name:SetJustifyH("LEFT") -- we'll anchor it in update]]
    end

  --AS.mainframe.frame:Hide() -- we'll show it when we open a tradeskill


  --create/find the anchor points to snap the buttons to.   Used for drag moving buttons



   --AScreatescrollbar()

------------------------------------------------------------
------ START BUTTON
    -------------- STYLE ----------------
    AS.mainframe.headerframe.startsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelButtonTemplate")
    AS.mainframe.headerframe.startsearchbutton:SetText(AS_START)
    AS.mainframe.headerframe.startsearchbutton:SetWidth(100)
    AS.mainframe.headerframe.startsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
    AS.mainframe.headerframe.startsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe,"TOPLEFT", 17, -25)
    -------------- SCRIPT ----------------
    AS.mainframe.headerframe.startsearchbutton:SetScript("OnClick",
        function(self)
            if AS.manualprompt then
                AS.manualprompt:Hide()
            end
            if AuctionFrame then
                if (AuctionFrame:IsVisible()) then
                    AuctionFrameTab1:Click()  --??
                    if (AuctionFrameBrowse:IsVisible()) then
                        if not IsShiftKeyDown() then
                            AScurrentauctionsnatchitem = 1
                        end
                        AS.status = QUERYING
                        AS.mainframe.headerframe.stopsearchbutton:Enable()
                        return
                    end
                end
            end
            ASprint("The Auction window is not visible.")
        end)
    AS.mainframe.headerframe.startsearchbutton:SetScript("OnEnter",
        function(self)
            tooltip="Start the search from the top of your list (You can hold 'shift' to continue where you left off from last scan)"
            ASshowtooltip( AS.mainframe.headerframe.startsearchbutton,tooltip)
        end)
    AS.mainframe.headerframe.startsearchbutton:SetScript("OnLeave",
        function(self)
            AShidetooltip()
        end)
    F.Reskin(AS.mainframe.headerframe.startsearchbutton) -- Aurora

------ STOP BUTTON
    -------------- STYLE ----------------
    AS.mainframe.headerframe.stopsearchbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelButtonTemplate")
    AS.mainframe.headerframe.stopsearchbutton:SetText(AS_STOP)
    AS.mainframe.headerframe.stopsearchbutton:SetWidth(50)
    AS.mainframe.headerframe.stopsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
    AS.mainframe.headerframe.stopsearchbutton:Disable()
    AS.mainframe.headerframe.stopsearchbutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.startsearchbutton,"TOPRIGHT", 2, 0)
    -------------- SCRIPT ----------------
    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnClick", function(self)
        if AS.mainframe then
            AS.mainframe.headerframe.stopsearchbutton:Disable()
            AS.prompt:Hide()
            AScurrentahresult = 0
        else
            ASprint("|c00ff0000error.  |r.  mainframe not found.")  --happens sometimes, not sure why
            AS.prompt:Hide()
        end
        AS.status = nil
        --ASprint("The Auction window is not visible.")
    end)
    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnEnter", function(self)
        tooltip = "Stop the current search. It can be resumed by shift-clicking Start Search."
        ASshowtooltip(AS.mainframe.headerframe.stopsearchbutton,tooltip)
    end)
    AS.mainframe.headerframe.stopsearchbutton:SetScript("OnLeave", function(self)
        AShidetooltip()
    end)
    F.Reskin(AS.mainframe.headerframe.stopsearchbutton) -- Aurora

------------------------------------------------------------
------ AUTOSTART CHECK BUTTON
    -------------- STYLE ----------------
    AS.mainframe.headerframe.autostart = CreateFrame("CheckButton", "ASautostartbutton", AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
    AS.mainframe.headerframe.autostart:SetPoint("TOPLEFT", AS.mainframe.headerframe.startsearchbutton, "BOTTOMLEFT", -4, -2)
    -------------- SCRIPT ----------------
    AS.mainframe.headerframe.autostart:SetScript("OnClick",
    function(self)
        if AS.mainframe.headerframe.autostart:GetChecked() then
            ASautostart = true
        else
            ASautostart = false
        end
        ASsavevariables()
    end)
    AS.mainframe.headerframe.autostart:SetScript("OnEnter",
    function(self)
        ASshowtooltip(self,AS_SEARCHTEXT)
    end)
    AS.mainframe.headerframe.autostart:SetScript("OnLeave",
    function(self)
        AShidetooltip()
    end)

    getglobal(AS.mainframe.headerframe.autostart:GetName().."Text"):SetText(AS_AUTOSEARCH);
    F.ReskinCheck(AS.mainframe.headerframe.autostart) -- Aurora

------ AUTOOPEN CHECK BUTTON
    -------------- STYLE ----------------
    AS.mainframe.headerframe.autoopen = CreateFrame("CheckButton", "ASautoopenbutton", AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
    AS.mainframe.headerframe.autoopen:SetPoint("TOPLEFT", AS.mainframe.headerframe.autostart, "TOPRIGHT", 90, 0)
    -------------- SCRIPT ----------------
    AS.mainframe.headerframe.autoopen:SetScript("OnClick",
    function(self)
        if AS.mainframe.headerframe.autoopen:GetChecked() then
            ASautoopen = true
        else
            ASautoopen = false
        end
        ASsavevariables()
    end)

    getglobal(AS.mainframe.headerframe.autoopen:GetName().."Text"):SetText(AS_AUTOOPEN);
    F.ReskinCheck(AS.mainframe.headerframe.autoopen) -- Aurora

------------------------------------------------------------
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
    AS.mainframe.headerframe.editbox:SetScript("OnEnter", function(self)
        AS.mainframe.headerframe.editbox:SetFocus()
    end)
    AS.mainframe.headerframe.editbox:SetScript("OnEnterPressed", function(self)
        AS.mainframe.headerframe.additembutton:Click()
    end)
    F.ReskinInput(AS.mainframe.headerframe.editbox) -- Aurora

    ------ ADD ITEM BUTTON
        -------------- STYLE ----------------
            AS.mainframe.headerframe.additembutton = CreateFrame("Button", nil, AS.mainframe.headerframe,"UIPanelButtonTemplate")
            AS.mainframe.headerframe.additembutton:SetText("+")
            AS.mainframe.headerframe.additembutton:SetWidth(30)
            AS.mainframe.headerframe.additembutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.mainframe.headerframe.additembutton:SetPoint("TOPLEFT", AS.mainframe.headerframe.editbox, "TOPRIGHT", 2, 0)
        -------------- SCRIPT ----------------
            AS.mainframe.headerframe.additembutton:SetScript("OnClick", ASadditem)
            
            F.Reskin(AS.mainframe.headerframe.additembutton) -- Aurora

    ------ DELETE BUTTON
        -------------- STYLE ----------------
            AS.mainframe.headerframe.deletelistbutton = CreateFrame("Button", nil, AS.mainframe.headerframe, "UIPanelButtonTemplate")
            AS.mainframe.headerframe.deletelistbutton:SetText("Delete List")
            AS.mainframe.headerframe.deletelistbutton:SetWidth(90)
            AS.mainframe.headerframe.deletelistbutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.mainframe.headerframe.deletelistbutton:SetPoint("BOTTOMLEFT", AS.mainframe,"BOTTOMLEFT", 17, 3)
        -------------- SCRIPT ----------------
            AS.mainframe.headerframe.deletelistbutton:SetScript("OnClick", function(self)
                if IsControlKeyDown() then
                    local x
                    AS.item = {}
                    ASscrollbar_Update()
                end
            end)
            AS.mainframe.headerframe.deletelistbutton:SetScript("OnEnter", function(self)
                ASshowtooltip(AS.mainframe.headerframe.deletelistbutton, AS_DELETETEXT)
            end)
            AS.mainframe.headerframe.deletelistbutton:SetScript("OnLeave", function(self)
                AShidetooltip()
            end)

            F.Reskin(AS.mainframe.headerframe.deletelistbutton) -- Aurora

    ------ DROPDOWN MENU
        -------------- STYLE ----------------
            ASdropDownMenu = CreateFrame("Frame", "ASdropDownMenu", AS.mainframe, "UIDropDownMenuTemplate")
            UIDropDownMenu_SetWidth(ASdropDownMenu, 130, 4)
            ASdropDownMenu:SetPoint("TOPLEFT", AS.mainframe.headerframe.deletelistbutton, "TOPRIGHT", -8, 3)
            UIDropDownMenu_Initialize(ASdropDownMenu, ASdropDownMenu_Initialise); --The virtual
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

    AScreateoptionframe()

end

function AScreateoptionframe(self)

    ------ OPTION FRAME
        -------------- STYLE ----------------
            AS.optionframe = CreateFrame("Frame", "ASoptionframe", UIParent)
            AS.optionframe:SetHeight((AS_BUTTON_HEIGHT* 5) + (AS_FRAMEWHITESPACE * 2))  --5 buttons
            AS.optionframe:SetWidth(200)
            AS.optionframe:SetBackdrop({    bgFile = C.media.backdrop,
                                            edgeFile = C.media.backdrop,--"Interface/Tooltips/UI-Tooltip-Border",
                                            tile = true, tileSize = 32, edgeSize = 1,
                                            insets = { left = 0, right = 0, top = 0, bottom = 1}
            })
            AS.optionframe:SetBackdropColor(0,0,0,0.8)
            AS.optionframe:SetBackdropBorderColor(1,1,1,0.2)
            AS.optionframe:SetToplevel(true)
            AS.optionframe:EnableMouse(true)
        -------------- SCRIPT ----------------
            AS.optionframe:SetScript("OnLeave", function(self)
                --AS.optionframe:Hide()--bah doesnt work right
                local x,y = GetCursorScaledPosition()
                --ASprint("Cursor x,y="..x..","..y.."  Left, right, bottom, top="..AS.optionframe:GetLeft()..","..AS.optionframe:GetRight()..","..AS.optionframe:GetBottom()..","..AS.optionframe:GetTop())
                if(x < AS.optionframe:GetLeft() or x > AS.optionframe:GetRight() or y < AS.optionframe:GetBottom() or y > AS.optionframe:GetTop()) then
                    AS.optionframe:Hide()
                end
            end)

    ------ MANUAL PRICE
        -------------- STYLE ----------------
            AS.optionframe.manualpricebutton = CreateFrame("Button", nil, AS.optionframe)
            AS.optionframe.manualpricebutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.optionframe.manualpricebutton:SetWidth(AS.optionframe:GetWidth())
            AS.optionframe.manualpricebutton:SetPoint("TOP", 0, -AS_FRAMEWHITESPACE)
            AS.optionframe.manualpricebutton:SetNormalFontObject("GameFontNormal")
            AS.optionframe.manualpricebutton:SetText("Modify manual price")
            AS.optionframe.manualpricebutton:SetHighlightTexture(C.media.backdrop)
            AS.optionframe.manualpricebutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)
            AS.optionframe.manualpricebutton:SetFrameStrata("TOOLTIP")
        -------------- SCRIPT ----------------
            AS.optionframe.manualpricebutton:SetScript("OnClick", function(self)
                ASresetpriceignore(self)
            end)

    ------ RESET FILTERS
        -------------- STYLE ----------------
            AS.optionframe.resetignorebutton = CreateFrame("Button", nil, AS.optionframe)
            AS.optionframe.resetignorebutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.optionframe.resetignorebutton:SetWidth(AS.optionframe:GetWidth())
            AS.optionframe.resetignorebutton:SetPoint("TOP", AS.optionframe.manualpricebutton, "BOTTOM")
            AS.optionframe.resetignorebutton:SetNormalFontObject("GameFontNormal")
            AS.optionframe.resetignorebutton:SetText("Erase Ignore Conditions")
            AS.optionframe.resetignorebutton:SetHighlightTexture(C.media.backdrop)
            AS.optionframe.resetignorebutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)
            --AS.optionframe.resetignorebutton:SetFrameStrata("DIALOG")
        -------------- SCRIPT ----------------
            AS.optionframe.resetignorebutton:SetScript("OnClick", function(self)
                ASresetignore(self)
            end)

    ------ DELETE ENTRY
        -------------- STYLE ----------------
            AS.optionframe.deleterowbutton = CreateFrame("Button", nil, AS.optionframe)
            AS.optionframe.deleterowbutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.optionframe.deleterowbutton:SetWidth(AS.optionframe:GetWidth())
            AS.optionframe.deleterowbutton:SetPoint("TOP", AS.optionframe.resetignorebutton, "BOTTOM")
            AS.optionframe.deleterowbutton:SetNormalFontObject("GameFontNormal")
            AS.optionframe.deleterowbutton:SetText("Delete entry")
            AS.optionframe.deleterowbutton:SetHighlightTexture(C.media.backdrop)
            AS.optionframe.deleterowbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)
            --AS.optionframe.deleterowbutton:SetFrameStrata("DIALOG")
        -------------- SCRIPT ----------------
            AS.optionframe.deleterowbutton:SetScript("OnClick", function(self)
                ASdeleterow(self)
            end)

    ------ MOVE ENTRY TO TOP
        -------------- STYLE ----------------
            AS.optionframe.movetotopbutton = CreateFrame("Button", nil, AS.optionframe)
            AS.optionframe.movetotopbutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.optionframe.movetotopbutton:SetWidth(AS.optionframe:GetWidth())
            AS.optionframe.movetotopbutton:SetPoint("TOP",ASoptionframe.deleterowbutton,"BOTTOM")
            AS.optionframe.movetotopbutton:SetNormalFontObject("GameFontNormal")
            AS.optionframe.movetotopbutton:SetText("Move to top")
            AS.optionframe.movetotopbutton:SetHighlightTexture(C.media.backdrop)
            AS.optionframe.movetotopbutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)
            --AS.optionframe.movetotopbutton:SetFrameStrata("DIALOG")
        -------------- SCRIPT ----------------
            AS.optionframe.movetotopbutton:SetScript("OnClick", function(self)
                local listnum = ASbuttontolistnum(self)
                ASmovelistbutton(listnum, 1)
            end)

    ------ MOVE ENTRY TO BOTTOM
        -------------- STYLE ----------------
            AS.optionframe.movetobottombutton = CreateFrame("Button", nil, AS.optionframe)
            AS.optionframe.movetobottombutton:SetHeight(AS_BUTTON_HEIGHT)
            AS.optionframe.movetobottombutton:SetWidth(AS.optionframe:GetWidth())
            AS.optionframe.movetobottombutton:SetPoint("TOP",ASoptionframe.movetotopbutton,"BOTTOM")
            AS.optionframe.movetobottombutton:SetNormalFontObject("GameFontNormal")
            AS.optionframe.movetobottombutton:SetText("Move to bottom")
            AS.optionframe.movetobottombutton:SetHighlightTexture(C.media.backdrop)
            AS.optionframe.movetobottombutton:GetHighlightTexture():SetVertexColor(r, b, g, 0.2)
            --AS.optionframe.movetobottombutton:SetFrameStrata("DIALOG")
        -------------- SCRIPT ----------------
            AS.optionframe.movetobottombutton:SetScript("OnClick", function(self)
                local listnum = ASbuttontolistnum(self)
                ASmovelistbutton(listnum, table.maxn(AS.item))
            end)
end


function ASresetignore(self)
    local listnum = ASbuttontolistnum(self)

    if listnum then
        ASprint("|c00449955 reset filters for")
        ASprint(AS.item[listnum].ignoretable)
        AS.item[listnum].ignoretable = nil
        AS.item[listnum].priceoverride = nil
        AS.optionframe:Hide()
        ASsavevariables()
    end
end


function ASresetpriceignore(self) -- manual price menu option
    local listnum = ASbuttontolistnum(self)

    if listnum then
        ASprint("|c00449955 reset manual price for "..listnum)
        AScreatemanualprompt(AS.item[listnum], listnum)
        AS.optionframe:Hide()
    end
end


function ASdeleterow(self)
    local listnum = ASbuttontolistnum(self)

    if listnum and AS.item[listnum] then
        if not AS.item[listnum].name then
            ASprint("|c00ff0000 error.  |ritem.[buttonnumber]name "..listnum.." doesn't exist.")
        end
        table.remove(AS.item, listnum)
        ASscrollbar_Update()
    end
    AS.optionframe:Hide()
    ASscrollbar_Update() -- Necessary to remove empty gap
end


function AScreatemanualprompt(item, listnumber)
    local buttonnames

    ASprint("|c004499FF creating manual prompt frame")

    if AS.manualprompt then
        AS.manualprompt:Hide()
    end

    if AS.prompt then
        AS.prompt:Hide()
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
                    ASprint("|c0055ffffManual prompt is shown")
                end)
                AS.manualprompt:SetScript("OnHide",function(self)
                    ASprint("|c0055ffffManual prompt is hidden")
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
                --[[if item then
                    AS.manualprompt.icon:SetNormalTexture(item.icon)
                end]]
            -------------- SCRIPT ----------------
                AS.manualprompt.icon:SetScript("OnEnter", function(self)
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
                        --    end
                    end
                end)
                AS.manualprompt.icon:SetScript("OnLeave", function(self)
                    GameTooltip:Hide()
                end)

        ------ ITEM LABEL
            -------------- STYLE ----------------
                AS.manualprompt.upperstring= AS.manualprompt:CreateFontString(nil, "OVERLAY", "gamefontnormal")
                AS.manualprompt.upperstring:SetJustifyH("CENTER")
                AS.manualprompt.upperstring:SetWidth(AS.manualprompt:GetWidth() - (AS.manualprompt.icon:GetWidth() + 2*AS_FRAMEWHITESPACE)  )
                AS.manualprompt.upperstring:SetHeight(AS.manualprompt.icon:GetHeight())
                AS.manualprompt.upperstring:SetPoint("LEFT", AS.manualprompt.icon, "RIGHT")
                --[[if item then
                    _,_,_,hexcolor = GetItemQualityColor(item.rarity)
                    AS.manualprompt.upperstring:SetText("|c"..hexcolor..tostring(item.name))
                end]]

        ------ CUTOFF PRICE
            -------------- STYLE ----------------
                AS.manualprompt.lowerstring= AS.manualprompt:CreateFontString(nil, "OVERLAY","gamefontnormal")
                AS.manualprompt.lowerstring:SetJustifyH("Left")
                AS.manualprompt.lowerstring:SetJustifyV("Top")
                AS.manualprompt.lowerstring:SetWidth(AS.manualprompt:GetWidth() - (2*AS_FRAMEWHITESPACE))
                AS.manualprompt.lowerstring:SetPoint("TOPRIGHT",AS.manualprompt.upperstring,"BOTTOMRIGHT", 2)
                AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":")
                --[[if item and item.ignoretable then
                    AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":\n"..ASGSC(tonumber(item.ignoretable[item.name].cutoffprice)))
                else
                    AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":")
                end]]

        ------ IGNORE BUTTON
            -------------- STYLE ----------------
                AS.manualprompt.ignorebutton = CreateFrame("Button",nil,AS.manualprompt, "UIPanelButtonTemplate")
                AS.manualprompt.ignorebutton:SetText(AS_BUTTONIGNOREMANUAL)
                AS.manualprompt.ignorebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                AS.manualprompt.ignorebutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.manualprompt.ignorebutton:SetPoint("BOTTOMLEFT",AS.manualprompt,"BOTTOMLEFT",18,12)
            -------------- SCRIPT ----------------
                AS.manualprompt.ignorebutton:SetScript("OnClick", function(self)
                    AS[AS_BUTTONIGNOREMANUAL]()
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
                AS.manualprompt.savebutton = CreateFrame("Button", nil, AS.manualprompt, "UIPanelButtonTemplate")
                AS.manualprompt.savebutton:SetText(AS_BUTTONEXPENSIVEMANUAL)
                AS.manualprompt.savebutton:SetWidth((AS.manualprompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE))
                AS.manualprompt.savebutton:SetHeight(AS_BUTTON_HEIGHT)
                AS.manualprompt.savebutton:SetPoint("BOTTOMRIGHT",AS.manualprompt,"BOTTOMRIGHT",-18,12)
            -------------- SCRIPT ----------------
                AS.manualprompt.savebutton:SetScript("OnClick", function(self)
                    AS[AS_BUTTONEXPENSIVEMANUAL]()
                    AS.manualprompt.priceoverride:SetText("")
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
                AS.manualprompt.priceoverride:SetScript("OnTextChanged", function(self)
                    local messagestring

                    if AS.manualprompt.priceoverride:GetText() == "" then
                        AS.item["ASmanualitem"].priceoverride = nil
                    elseif ASsavedtable and ASsavedtable.copperoverride then
                        AS.item["ASmanualitem"].priceoverride = tonumber(AS.manualprompt.priceoverride:GetText())
                    else
                        AS.item["ASmanualitem"].priceoverride = AS.manualprompt.priceoverride:GetText() * COPPER_PER_GOLD
                    end

                    if AS.item["ASmanualitem"].priceoverride and (tonumber(AS.item["ASmanualitem"].priceoverride) > 0) then
                        messagestring = "\n"..AS_CUTOFF..":\n"
                        messagestring = messagestring..ASGSC(tonumber(AS.item["ASmanualitem"].priceoverride))
                        AS.manualprompt.lowerstring:SetText(messagestring)
                    else
                        ASprint("|c00ffaaaaNo Cutoff price found!")
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
    end

    if item then
        AS.item['ASmanualitem'] = {}
        AS.item['ASmanualitem'].name = item.name
        AS.item['ASmanualitem'].listnumber = listnumber

        AS.manualprompt.icon:SetNormalTexture(item.icon)
        _,_,_,hexcolor = GetItemQualityColor(item.rarity)
        AS.manualprompt.upperstring:SetText("|c"..hexcolor..tostring(item.name))
        
        if item.ignoretable then
            AS.manualprompt.lowerstring:SetText("\n"..AS_CUTOFF..":\n"..ASGSC(tonumber(item.ignoretable[item.name].cutoffprice)))
        end
        
        AS.manualprompt:Show()
    end
end

function AScreateprompt()
    local buttonnames

   --i want eight options
   --buyout.  grey when no buyout
   --bid.
   --skip self one
   --skip all, go to next query
   --ignore all of self particular name
   --ignore all of this item at this price (or worse)
   --this is the item we want.  update the name, and add an icon
   --close
   --(and maybe a global 'ignore item' - not specific to any query
   --and a reset
   --and a delete item

   -------------------------------------------------------------------------------
   --this is the prompt frame and its children
   -------------------------------------------------------------------------------

    ASprint("|c004499FFcreating prompt frame")

    ------ MANUAL PROMPT FRAME
        -------------- STYLE ----------------
            AS.prompt = CreateFrame("Frame", "ASpromptframe", UIParent)
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
                ASprint("|c0055ffffPrompt is shown.  AS.status = "..tostring(AS.status))
            end)
            AS.prompt:SetScript("OnHide", function(self)
                ASprint("|c0055ffffPrompt is Hidden.  AS.status = "..tostring(AS.status))
            end)

    ------ DRAG BAR
        -------------- STYLE ----------------
            AS.prompt.drag = CreateFrame("Button", nil, AS.prompt)
            AS.prompt.drag:SetPoint("TOPLEFT", AS.prompt, "TOPLEFT", 10,-5)
            AS.prompt.drag:SetPoint("TOPRIGHT", AS.prompt, "TOPRIGHT", -10,-5)
            AS.prompt.drag:SetHeight(3)
            AS.prompt.drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
        -------------- SCRIPT ----------------
            AS.prompt.drag:SetScript("OnMouseDown", function(self)
                AS.prompt:StartMoving()
            end)
            AS.prompt.drag:SetScript("OnMouseUp", function(self)
                AS.prompt:StopMovingOrSizing()
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

   AS.prompt.buttonnames = {AS_BUTTONUPDATE,AS_BUTTONDELETE,AS_BUTTONIGNORE,AS_BUTTONNEXTAH,AS_BUTTONBID,AS_BUTTONEXPENSIVE,AS_BUTTONNEXTLIST,AS_BUTTONBUYOUT}
   buttonnames = AS.prompt.buttonnames
   local buttontooltips = {AS_BUTTONTEXT1,AS_BUTTONTEXT2,AS_BUTTONTEXT3,AS_BUTTONTEXT4,AS_BUTTONTEXT5,AS_BUTTONTEXT8,AS_BUTTONTEXT9,AS_BUTTONTEXT10}

   buttonwidth = (AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)  --basically half its frame size

   AScreatebuttonhandlers()  --as this is logic stuff, it should not go in the interface file


   local i, rowsacross, rowsdown, Xoffset, Yoffset
   rowsdown=5

   for i = 1,table.maxn(buttonnames) do
      AScreatepromptbutton(AS.prompt,buttonnames[i],buttontooltips[i])
      --Complicated, i know, but it works
      Xoffset= (math.floor((i-1)/rowsdown)*(buttonwidth+AS_FRAMEWHITESPACE*2)) + (AS_FRAMEWHITESPACE)
      Yoffset=math.floor((i-1)%rowsdown) * AS_BUTTON_HEIGHT
    --  ASprint("x="..Xoffset.."  Y="..Yoffset.."   AS_framewhitespace="..AS_FRAMEWHITESPACE)
      AS.prompt[buttonnames[i]]:SetPoint("bottomleft",Xoffset ,Yoffset+AS_FRAMEWHITESPACE)
   end

    ------ ITEM LABEL
        -------------- STYLE ----------------
            AS.prompt.upperstring = AS.prompt:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            AS.prompt.upperstring:SetJustifyH("CENTER")
            AS.prompt.upperstring:SetWidth(AS.prompt:GetWidth() - (AS.prompt.icon:GetWidth() + 2*AS_FRAMEWHITESPACE))
            AS.prompt.upperstring:SetHeight(AS.prompt.icon:GetHeight())
            AS.prompt.upperstring:SetPoint("LEFT", AS.prompt.icon, "RIGHT")

   AS.prompt.lowerstring= AS.prompt:CreateFontString(nil,"OVERLAY","gamefontnormal")
   AS.prompt.lowerstring:SetJustifyH("Left")
   AS.prompt.lowerstring:SetJustifyV("Top")
   AS.prompt.lowerstring:SetWidth(AS.prompt:GetWidth() - (2*AS_FRAMEWHITESPACE))
   --AS.prompt.lowerstring:SetHeight(AS.prompt:GetHeight())
   --AS.prompt:SetAllPoints()
   AS.prompt.lowerstring:SetPoint("topright",AS.prompt.upperstring,"bottomright")
   AS.prompt.lowerstring:SetPoint("bottomright",AS.prompt,"bottomright")

    --   AS.prompt.lowerstring:IsMultiLine(true)
    ------ ICON
        -------------- STYLE ----------------
            AS.prompt.priceoverride = CreateFrame("EditBox", nil, AS.prompt, "InputBoxTemplate")
            AS.prompt.priceoverride:SetPoint("Right",-AS_FRAMEWHITESPACE,-10)
            AS.prompt.priceoverride:SetHeight(25)
            AS.prompt.priceoverride:SetWidth(45)
            AS.prompt.priceoverride:SetNumeric(true)
            AS.prompt.priceoverride:SetAutoFocus(false)

    --AS.prompt.SetFontColor
    AS.prompt.priceoverride:SetScript("OnEscapePressed",function(self)
        AS.prompt.priceoverride:ClearFocus()
    end)
    AS.prompt.priceoverride:SetScript("OnTextChanged",function(self)
        local messagestring
        if (AS.prompt.priceoverride:GetText() == "") then
            AS.item[AScurrentauctionsnatchitem].priceoverride = nil
        else
            if(ASsavedtable and ASsavedtable.copperoverride) then
                AS.item[AScurrentauctionsnatchitem].priceoverride = tonumber(AS.prompt.priceoverride:GetText())
            else
                AS.item[AScurrentauctionsnatchitem].priceoverride = AS.prompt.priceoverride:GetText() * COPPER_PER_GOLD
            end
        end
        --ASprint("Calling CReateMessageString() from within the |c00ee0066priceoverride:OnTextChanged handler.  priceOVERRIDE = "..tostring(AS.item[AScurrentauctionsnatchitem].priceoverride)..   "AScurrentasitem = "..AScurrentauctionsnatchitem)
        messagestring = AScreatemessagestring(AS.item[AScurrentauctionsnatchitem].priceoverride)
        --ASprint("AS.item[AScurrentauctionsnatchitem] = ")
        --ASprint(AS.item[AScurrentauctionsnatchitem])
        AS.prompt.lowerstring:SetText(messagestring)

    end)
    AS.prompt.priceoverride:SetScript("OnEnter",function(self)
        if(ASsavedtable and ASsavedtable.copperoverride) then
            ASshowtooltip(self,"A value here, in COPPER, overrides all other ignore conditions")
        else
            ASshowtooltip(self,"A value here, in gold, overrides all other ignore conditions")
        end
        AS.prompt.priceoverride:SetAlpha(1)
    end)
    AS.prompt.priceoverride:SetScript("OnLeave",function(self)
        AShidetooltip()
        AS.prompt.priceoverride:SetAlpha(.5)
    end)

    F.ReskinInput(AS.prompt.priceoverride) -- Aurora

    --AS.prompt.priceoverride

   ASprint("Done creating prompt frame.")
end





function AScreatepromptbutton(groupname,name,tooltip)

   local buttonwidth
   buttonwidth = (groupname:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)

    groupname[name] = CreateFrame("Button", nil, groupname, "UIPanelButtonTemplate")
    groupname[name]:SetText(name)
 --  AS.prompt[name]:SetPoint("left",AS_FRAMEWHITESPACE,0)  --just something, whatever
   groupname[name]:SetWidth(buttonwidth)
   groupname[name]:SetHeight(AS_BUTTON_HEIGHT)
   groupname[name]:SetScript("OnClick", function(self)
     AS[name]()
     groupname:Hide()
  end)

   groupname[name]:SetScript("OnEnter",function(self)
        ASshowtooltip(groupname[name],tooltip)
                     end)
   groupname[name]:SetScript("OnLeave", function(self)
        AShidetooltip()
                     end)
   F.Reskin(groupname[name]) -- Aurora



end



--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
---------------------------------------------------------------------------
function AScreatelistbutton(i)
   local buttontemplate,texttexture,ASfontstring,ASicon, ASnormaltexture,AShighlighttexture,buttonnumber

   -------------------------------the actual button
   buttontemplate = CreateFrame("Button",nil,AS.mainframe.listframe)
   buttontemplate:SetHeight(AS_BUTTON_HEIGHT)
   buttontemplate:SetWidth(AS.mainframe:GetWidth() - 58)
   buttontemplate:SetPoint("top")
   buttontemplate:SetNormalFontObject("gamefontnormal")
   buttontemplate.buttonnumber=i
   buttontemplate:SetMovable(true)

   buttontemplate:SetScript("OnMouseDown",
      function(self)
        --compensate for scroll bar
        --ASscrollbar = getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
        --allow drag repositioning of buttons
        ASorignumber = self.buttonnumber+FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
      end)


    buttontemplate:SetScript("OnClick",
      function(self, button, down)
        ASprint("CLeeekkk!")

        if(IsShiftKeyDown()) then
            --get the link from this row
            ASprint("SHIIIFTTT cleeek")
        else
            if(AS.optionframe:IsVisible()) then
                AS.optionframe:Hide()
            else
                AS.item['LastListButtonClicked'] = self.buttonnumber+FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                AS.optionframe:SetParent(self)
                AS.optionframe:SetPoint("Top",self,"bottomright")
                AS.optionframe:Show()
            end

            if AS.manualprompt then
                AS.manualprompt:Hide()
            end
        end

      end)

    buttontemplate:SetScript("OnMouseUp",
        function(self, button)
            if button == "RightButton" then
                if AuctionFrame then
                    if (AuctionFrame:IsVisible()) then
                        AuctionFrameTab1:Click()  --??
                        if (AuctionFrameBrowse:IsVisible()) then
                            AScurrentauctionsnatchitem = self.buttonnumber+FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
                            AS.status = QUERYING
                            AS.status_override = true
                            AS.mainframe.headerframe.stopsearchbutton:Enable()
                            return
                        end
                    end
                end
                ASprint("The Auction window is not visible.")
            else
                ASmovelistbutton(ASorignumber)
                ASscrollbar_Update()
            end
        end)

   buttontemplate:SetScript("OnEnter",
      function(self)
      local ignoreprice,messagestring,quality, current_item
         local mainfunc = AS.mainframe:GetScript("OnEnter")
         if(buttontemplate.leftstring:GetText()) then
           --show tooltip indicating you can double click this

              messagestring = AS_INFO
              --show all cutoff prices
              local scrollvalue=FauxScrollFrame_GetOffset(AS.mainframe.listframe.scrollFrame)
              current_item = AS.item[i + scrollvalue]

              if (AS and AS.item and current_item and current_item.ignoretable) then
                  messagestring = messagestring.."\nManual Override: "..ASGSC(tonumber(current_item.ignoretable[current_item.name].cutoffprice))
              elseif (AS and AS.item and AS.item[i+scrollvalue] and AS.item[i+scrollvalue].ignoretable) then
                   --loop through each entry in the ignore list
                    messagestring = messagestring.."\n"..AS_IGNORECONDITIONS..":"
                   for key,value in pairs(AS.item[i+scrollvalue].ignoretable) do
                   --list the name and cutoff price
                       --check if we can make it look prettier because we saved quality
                       --newer versions, this is a table, to hold more data
                       if(type(value) == "table") then
                           --new version
                           quality=value.quality
                           ignoreprice = value.cutoffprice
                       else
                          --old version
                          quality=0
                          ignoreprice=value
                       end

                       key=itemRarityColors[quality]..key.."|r"

                       if (ignoreprice == 0) then
                            messagestring = messagestring.."\n"..key..": |cff9d9d9d"..AS_ALWAYS.."|r"
                       else
                           messagestring = messagestring.."\n"..key..": "..ASGSC(ignoreprice)
                        end
                   end
              else
                 --ASprint("no ignore table")
              end
              ASshowtooltip(self,messagestring)
          else
            AShidetooltip()
          end
           mainfunc()
      end)

   buttontemplate:SetScript("OnLeave",
      function(self)
         local mainfunc = AS.mainframe:GetScript("OnLeave")
         AShidetooltip()
         mainfunc()
      end)


   buttontemplate:SetScript("OnDoubleClick",
      function(self)
            if (BrowseName) then
                 if(buttontemplate.leftstring:GetText()) then
                    BrowseName:SetText(ASsanitize(buttontemplate.leftstring:GetText()))
                    AuctionFrameBrowse_Search()
                  --search for the auction in that box
                end
            end
      end)

   -----------------------------the faint box background
   ASnormaltexture,AShighlighttexture = createAStexture(buttontemplate)
   buttontemplate:SetNormalTexture(ASnormaltexture) --i had to make a custom texture, modifying the AH button frame, because the default AH button template, for unknown reasons, would not fill the button

   ----------------------------- the highlight mouseover
   buttontemplate:SetHighlightTexture(AShighlighttexture)  --this ones a little softer on the eyes

   --F.Reskin(buttontemplate)

   ------------------------------the text
   --cant use button text because button text cant be left justified
   buttontemplate.leftstring = buttontemplate:CreateFontString(nil,"OVERLAY","gamefontnormal")
   buttontemplate.leftstring:SetJustifyH("Left")
   buttontemplate.leftstring:SetWordWrap(false)
   buttontemplate.leftstring:SetPoint("LEFT", ASnormaltexture,"LEFT", 10, 0)
   buttontemplate.leftstring:SetPoint("RIGHT", ASnormaltexture,"RIGHT", -2, 0)


   ---------------------------------- the quantity
   buttontemplate.rightstring = buttontemplate:CreateFontString(nil,"OVERLAY","gamefontnormal")
   buttontemplate.rightstring:SetJustifyH("Right")
   buttontemplate.rightstring:SetPoint("Right",ASnormaltexture,-5,0)


   ---------------the little icon on the left
   buttontemplate.icon=CreateFrame("Button",nil,buttontemplate)
   buttontemplate.icon:SetWidth(AS_BUTTON_HEIGHT)
   buttontemplate.icon:SetHeight(AS_BUTTON_HEIGHT)
   buttontemplate.icon:SetPoint("TOPLEFT")
   buttontemplate.icon:SetNormalTexture("Interface/AddOns/AltzUI/media/gloss") -- Altz UI
    buttontemplate.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
    buttontemplate.icon:GetNormalTexture():SetTexCoord(0.1,0.9,0.1,0.9)  --i have no idea how this manages to make the texture bigger, but hallelujah it does
    buttontemplate.icon:SetScript("OnEnter",function(self)

    if (buttontemplate.link) then
       local link = buttontemplate.link
       GameTooltip:SetOwner(self, "ANCHOR_NONE")
       GameTooltip:SetHyperlink(link)
       GameTooltip:ClearAllPoints()
       GameTooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -20)
       GameTooltip:Show()
       --no enhtootip
    end
     end)
   buttontemplate.icon:SetScript("OnLeave",function(self)
     GameTooltip:Hide()
      end)


   return buttontemplate
end

----------------------------------------------------------------------------
------------------------------------------------------------------------------

function createAStexture(ourbutton)
   local   normaltextureleft,normaltextureright,normaltexture,highlighttexture = nil
   --left
   --[[normaltextureleft=ourbutton:CreateTexture()
   normaltextureleft:SetHeight(AS_BUTTON_HEIGHT)
   normaltextureleft:SetWidth(1) --10 is the gap between text and anything else
   normaltextureleft:SetPoint("left",30,0)
   --normaltextureleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltextureleft:SetTexCoord(0,.07,0,1)
   normaltextureleft:Hide()
   --right
   normaltextureright=ourbutton:CreateTexture()
   normaltextureright:SetHeight(AS_BUTTON_HEIGHT)
   normaltextureright:SetWidth(2)
   normaltextureright:SetPoint("right",-10,0)
   --normaltextureright:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltextureright:SetTexCoord(0,.8,0,1)
   normaltextureright:Hide()]]
   --center?
   normaltexture=ourbutton:CreateTexture()
   normaltexture:SetHeight(AS_BUTTON_HEIGHT)
   normaltexture:SetPoint("left",30,0)
   normaltexture:SetPoint("right",-12,0)
   normaltexture:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltexture:SetTexCoord(.75,.75,0,0.5)

   --center highlight
   highlighttexture=ourbutton:CreateTexture()
   highlighttexture:SetHeight(AS_BUTTON_HEIGHT-1)
   highlighttexture:SetWidth(1) --10 is the gap between text and anything else
   highlighttexture:SetPoint("left",normaltexture,0,-1)
   highlighttexture:SetPoint("right",normaltexture)
   highlighttexture:SetTexture(C.media.backdrop)
   highlighttexture:SetVertexColor(0.945, 0.847, 0.152,0.3)
   --highlighttexture:SetTexCoord(0,1,.1,.1)


   return normaltexture,highlighttexture
end

function AScreateauctiontab()

    if AuctionFrame then
        -------------- STYLE ----------------
        ASauctiontab = CreateFrame("Button","ASauctiontab",AuctionFrame,"AuctionTabTemplate")
        ASauctiontab:SetText("AS")
        PanelTemplates_TabResize(ASauctiontab, 50, 70, 70);
        PanelTemplates_DeselectTab(ASauctiontab)
        -------------- SCRIPT ----------------
        local origfunc = ASauctiontab:GetScript("OnClick")
        ASauctiontab:SetScript("OnClick",
        function(...)
        -- origfunc(...)  --hides the browse/bid stuff, sets the ID - nothing important
            if AS.mainframe:IsShown() then
                AS.mainframe:Hide()
            else
                ASopenedwithah = true
                if ASautostart == true then
                    AS.status = QUERYING
                end
                ASmain()
            end
        end)
        F.ReskinTab(ASauctiontab) -- Aurora

        --*********************************************
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
        ASauctiontab:SetPoint("TOPLEFT", getglobal("AuctionFrameTab"..(index-1)), "TOPRIGHT", -8, 0);
        -- thank you igors mass auction!!
        --**********************************************
    end
   --------------------------------------------------------------------------------------
   --from igor
--  <Button name="IMA_AuctionFrameTab" inherits="AuctionTabTemplate"  parent="AuctionFrame" text="IMA_MASS_AUCTION">
--      <Scripts>
--          <OnLoad>IMA_InitAuctionFrameTab(this);</OnLoad>
--      </Scripts>
--  </Button>

--from addons/auctionui
--  <Button name="AuctionTabTemplate" inherits="CharacterFrameTabButtonTemplate" virtual="true">
--      <Scripts>
--          <OnClick>
--              AuctionFrameTab_OnClick();
--          </OnClick>
--      </Scripts>
--  </Button>
--------------------------------------------------------------------------------
end



