local FALSE=0
local TRUE=1
local QUERYING=1
local WAITINGFORUPDATE=2
local EVALUATING=3
local WAITINGFORPROMPT=4
local BUYING = 5

function AScreatemainframe()
-------------------------------------------------------------------------------
   --this is the main listing frame and its children/buttons
   -------------------------------------------------------------------------------

    ASprint("|c00229977 creating mainframe")


   --
   AS.mainframe = CreateFrame("Frame","ASmainframe",UIParent)
   AS.mainframe:SetPoint("right",-100,0)
   AS.mainframe:SetHeight(AS_GROSSHEIGHT)
   AS.mainframe:SetWidth(275)
   AS.mainframe:Hide()
   AS.mainframe:SetBackdrop({
				 bgFile = "Interface/Tooltips/UI-Tooltip-Background",
				 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				 tile = true, tileSize = 32, edgeSize = 32,
				 insets = { left = 9, right = 9, top = 9, bottom = 9}
			      })
   AS.mainframe:SetBackdropColor(0,0,0,2)
   AS.mainframe:SetMovable(true)
   AS.mainframe:EnableMouse(true)
   AS.mainframe:SetScript("OnMouseDown",function(self)
					     AS.mainframe:StartMoving()
					  end)
   AS.mainframe:SetScript("OnMouseUp",function(self)
					   AS.mainframe:StopMovingOrSizing()
					   ASsavevariables()
					end)
   AS.mainframe:SetScript("OnShow",function(self)
      ASbringtotop()
   end)
   AS.mainframe:SetScript("OnEnter",function(self)
       ASbringtotop()
      -- AS.mainframe.headerframe.editbox:SetFocus()
   end)
       AS.mainframe:SetScript("OnLeave",function(self)
	--check if the mouse actually left the frame
	   local x,y = GetCursorScaledPosition()
-- i decided not to check top and bottom because often i accidentaly drift up and down - only left and right seems to be when i actaully want to hide the frame
--	if(x<AS.mainframe:GetLeft() or x > AS.mainframe:GetRight() or y > AS.mainframe:GetTop() or y < AS.mainframe:GetBottom()) then
	   if(x<AS.mainframe:GetLeft() or x > AS.mainframe:GetRight()) then
	      AS.mainframe:SetFrameStrata("LOW")
	      --AS.mainframe.headerframe.editbox:ClearFocus()
	   end


   end)


   ----------------------------------------------------------
   ---------------------------------------------------------
   -- Ive decided to make 2 frames within our main frame.
   -- A Header Frame, that holds sorting options/editboxes
   -- and a List frame, that contains the list of items
   ---------------------------------------------------------
   ----------------------------------------------------------

   AS.mainframe.headerframe = CreateFrame("Frame",nil,AS.mainframe)
   AS.mainframe.listframe = CreateFrame("Frame",nil,AS.mainframe)

   AS.mainframe.headerframe:SetPoint("topleft")
   AS.mainframe.headerframe:SetPoint("right")
   AS.mainframe.headerframe:SetHeight(AS_HEADERHEIGHT)  --this should be sufficient
   --   AS.mainframe.listframe:SetAllPoints()
   AS.mainframe.listframe:SetPoint("topleft",AS.mainframe.headerframe,"bottomleft")
   AS.mainframe.listframe:SetPoint("bottomright")
   AS.mainframe.listframe:SetHeight(AS_LISTHEIGHT)


   AS.mainframe.closebutton = CreateFrame("button",nil,AS.mainframe,"UIPanelButtonTemplate")
   AS.mainframe.closebutton:SetWidth(16)
   AS.mainframe.closebutton:SetHeight(20)
   AS.mainframe.closebutton:SetPoint("TopRight",0,0)
   AS.mainframe.closebutton:SetText("x")
   AS.mainframe.closebutton:SetScript("OnClick",    function(self)
							 AS.mainframe:Hide()
							 if(AS.prompt) then
								AS.prompt:Hide()
							end
						      end)



   AS.mainframe.headerframe.additembutton=CreateFrame("Button",nil,AS.mainframe.headerframe,"UIPanelButtonTemplate")
   AS.mainframe.headerframe.additembutton:SetText(AS_ADDITEM)
   --  AS.mainframe.headerframe.additembutton:SetWidth(AS.mainframe.headerframe:GetWidth()-(AS.mainframe.headerframe.editbox:getWidth() + 2*AS_FRAMEWHITSPACE))
   --  AS.mainframe.headerframe.additembutton:SetHeight(AS.mainframe.headerframe:GetHeight())
   AS.mainframe.headerframe.additembutton:SetWidth(100)
   AS.mainframe.headerframe.additembutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.mainframe.headerframe.additembutton:SetPoint("topright",-AS_FRAMEWHITESPACE,-AS_FRAMEWHITESPACE)
   AS.mainframe.headerframe.additembutton:SetScript("OnClick",ASadditem)

   AS.mainframe.headerframe.editbox=CreateFrame("EditBox",nil,AS.mainframe.headerframe,"InputBoxTemplate")
   AS.mainframe.headerframe.editbox:SetPoint("topleft",20,-5)
   AS.mainframe.headerframe.editbox:SetHeight(AS_BUTTON_HEIGHT)
   AS.mainframe.headerframe.editbox:SetWidth(AS.mainframe.headerframe:GetWidth()-100)
   --AS.mainframe.headerframe.editbox:SetFocus()
   AS.mainframe.headerframe.editbox:SetAutoFocus(false)
   AS.mainframe.headerframe.editbox:SetScript("OnEscapePressed",function(self)
								     AS.mainframe.headerframe.editbox:ClearFocus()
								  end)
   AS.mainframe.headerframe.editbox:SetScript("OnEnter",function(self)
     --AS.mainframe.headerframe.editbox:SetFocus()
  end)

   AS.mainframe.headerframe.editbox:SetScript("OnEnterPressed",function(self)
								    AS.mainframe.headerframe.additembutton:Click()
								 end)


------------------------------------------------------------
-- START  BUTTON

   AS.mainframe.headerframe.startsearchbutton=CreateFrame("Button",nil,AS.mainframe.headerframe,"UIPanelButtonTemplate")
   AS.mainframe.headerframe.startsearchbutton:SetText(AS_START)
   --  AS.mainframe.headerframe.startsearchbutton:SetWidth(AS.mainframe.headerframe:GetWidth()-(AS.mainframe.headerframe.editbox:getWidth() + 2*AS_FRAMEWHITSPACE))
   --  AS.mainframe.headerframe.startsearchbutton:SetHeight(AS.mainframe.headerframe:GetHeight())
   AS.mainframe.headerframe.startsearchbutton:SetWidth(100)
   AS.mainframe.headerframe.startsearchbutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.mainframe.headerframe.startsearchbutton:SetPoint("top",0,-(AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE))
   AS.mainframe.headerframe.startsearchbutton:SetScript("OnClick",
      function(self)
	 if (AuctionFrame) then
	    if (AuctionFrame:IsVisible()) then
	       AuctionFrameTab1:Click()  --??
	       if (AuctionFrameBrowse:IsVisible()) then
				if not IsShiftKeyDown() then
					AScurrentauctionsnatchitem = 1
				end

		      AS.status=QUERYING
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

------------------------------------------------------------
-- delete  BUTTON

   AS.mainframe.headerframe.deletelistbutton=CreateFrame("Button",nil,AS.mainframe.headerframe,"UIPanelButtonTemplate")
   AS.mainframe.headerframe.deletelistbutton:SetText("D")
   AS.mainframe.headerframe.deletelistbutton:SetWidth(30)
   AS.mainframe.headerframe.deletelistbutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.mainframe.headerframe.deletelistbutton:SetPoint("topright",-AS_FRAMEWHITESPACE,-(AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE))
    AS.mainframe.headerframe.deletelistbutton:SetScript("OnClick",
      function(self)
	 if(IsControlKeyDown()) then
	    AS.item={}
	    ASscrollbar_Update()
	 end
      end)

  AS.mainframe.headerframe.deletelistbutton:SetScript("OnEnter",
      function(self)
           ASprint("delete button entered")
    	   tooltip=AS_DELETETEXT
	       ASshowtooltip( AS.mainframe.headerframe.deletelistbutton,tooltip)
      end)

  AS.mainframe.headerframe.deletelistbutton:SetScript("OnLeave",
  function(self)
    AShidetooltip()

   end)





-----------------------------------------
-- AUTOSTART CHECK BUTTON
   AS.mainframe.headerframe.autostart = CreateFrame("CheckButton","ASautostartbutton",AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
   AS.mainframe.headerframe.autostart:SetPoint("topleft",AS.mainframe.headerframe,"topleft",10,-60)

   AS.mainframe.headerframe.autostart:SetScript("OnClick",
	  function(self)
	    if(AS.mainframe.headerframe.autostart:GetChecked()) then
            ASautostart = TRUE
        else
            ASautostart = FALSE
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

-----------------------------------------
-- NO DOORBELL CHECK BUTTON
   AS.mainframe.headerframe.nodoorbell = CreateFrame("CheckButton","ASnodoorbellbutton",AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
   AS.mainframe.headerframe.nodoorbell:SetPoint("top",AS.mainframe.headerframe.autostart,"bottom",0,0)

   AS.mainframe.headerframe.nodoorbell:SetScript("OnClick",
	  function(self)

         if(AS.mainframe.headerframe.nodoorbell:GetChecked()) then
            ASnodoorbell = TRUE
        else
            ASnodoorbell = FALSE
         end
	     ASsavevariables()
	  end)
    AS.mainframe.headerframe.nodoorbell:SetScript("OnEnter",
	  function(self)
	     ASshowtooltip(self,AS_DOORBELLTEXT)
	  end)
	  AS.mainframe.headerframe.nodoorbell:SetScript("OnLeave",
	  function(self)
	    AShidetooltip()
	  end)

	   getglobal(AS.mainframe.headerframe.nodoorbell:GetName().."Text"):SetText(AS_DOORBELLSOUND);


-----------------ignore no buyout button
	AS.mainframe.headerframe.ignorenobuyout = CreateFrame("CheckButton","ASignorenobuyoutbutton",AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
   AS.mainframe.headerframe.ignorenobuyout:SetPoint("left",AS.mainframe.headerframe.autostart,"right",90,0)
   AS.mainframe.headerframe.ignorenobuyout:SetScript("OnClick",
	  function(self)
		ASignorenobuyout = not ASignorenobuyout
	     ASsavevariables()
	  end)
    AS.mainframe.headerframe.ignorenobuyout:SetScript("OnEnter",
	  function(self)
	     ASshowtooltip(self,"Ignore all auctions with no buyout set")
	  end)
	  AS.mainframe.headerframe.ignorenobuyout:SetScript("OnLeave",
	  function(self)
	    AShidetooltip()
	  end)

	  getglobal(AS.mainframe.headerframe.ignorenobuyout:GetName().."Text"):SetText("Ignore no buyout");





-----------------ignore bid button
	AS.mainframe.headerframe.ignorebid = CreateFrame("CheckButton","ASignorebidbutton",AS.mainframe.headerframe, "OptionsCheckButtonTemplate")
   AS.mainframe.headerframe.ignorebid:SetPoint("top",ASignorenobuyoutbutton,"bottom",36,0)
   AS.mainframe.headerframe.ignorebid:SetScript("OnClick",
	  function(self)
		ASignorebid = not ASignorebid
	     ASsavevariables()
	  end)
    AS.mainframe.headerframe.ignorebid:SetScript("OnEnter",
	  function(self)
	     ASshowtooltip(self,"Ignore all bid prices")
	  end)
	  AS.mainframe.headerframe.ignorebid:SetScript("OnLeave",
	  function(self)
	    AShidetooltip()
	  end)


	  getglobal(AS.mainframe.headerframe.ignorebid:GetName().."Text"):SetText("Ignore bids");




   AS.mainframe.listframe["itembutton"] = {}


   --------------------------- all the text buttons inside the list frame
   local i,currentrow,previousrow
   for i = 1,ASrowsthatcanfit() do
      AS.mainframe.listframe.itembutton[i]=AScreatelistbutton(i)
      currentrow=AS.mainframe.listframe.itembutton[i]
      if i==1 then
    	 currentrow:SetPoint("TOP")
      else
	    currentrow:SetPoint("TOP",previousrow,"bottom")
      end
      currentrow:Show()
      previousrow=currentrow
   end


  --create/find the anchor points to snap the buttons to.   Used for drag moving buttons



   AScreatescrollbar()


   ------------------------ the dropdown menu to load profiles -------------------------
   ASdropDownMenu = CreateFrame("Frame", "ASdropDownMenu", AS.mainframe, "UIDropDownMenuTemplate");
   UIDropDownMenu_SetWidth(ASdropDownMenu,120,8)
   ASdropDownMenu:SetPoint("Top",AS.mainframe,"bottom",16,0)
   UIDropDownMenu_Initialize(ASdropDownMenu,ASdropDownMenu_Initialise); --The virtual

   --invisible button for text
   ASdropdownmenubutton = CreateFrame("Button",nil,ASdropDownMenu)
   ASdropdownmenubutton:SetText(AS_IMPORT)
   ASdropdownmenubutton:SetNormalFontObject(GameFontNormal)
   ASdropdownmenubutton:SetPoint("topleft",40,0)
   ASdropdownmenubutton:SetWidth(80)
   ASdropdownmenubutton:SetHeight(32)
   ASdropdownmenubutton:Disable()

   AScreateoptionframe()

end

function AScreateoptionframe()

AS.optionframe = CreateFrame("Frame","ASoptionframe",UIParent)
   --AS.optionframe:SetPoint("TOP","$UIparent","Bottomright")
   --AS.optionframe:SetHeight((AS_BUTTON_HEIGHT + AS_FRAMEWHITESPACE )* 4) --4 buttons
   AS.optionframe:SetHeight((AS_BUTTON_HEIGHT* 4) + (AS_FRAMEWHITESPACE * 2))  --4 buttons
   AS.optionframe:SetWidth(200)
   AS.optionframe:Hide()
   AS.optionframe:SetBackdrop({
				 bgFile = "Interface/Tooltips/UI-Tooltip-Background",
				 edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
				 tile = true, tileSize = 32, edgeSize = 32,
				 insets = { left = 9, right = 9, top = 9, bottom = 9}
			      })
   AS.optionframe:SetBackdropColor(0,0,0,2)
   --AS.optionframe:SetMovable(true)
   AS.optionframe:EnableMouse(true)
   AS.optionframe:SetScript("OnMouseDown",function(self)

					  end)
   AS.optionframe:SetScript("OnMouseUp",function(self)

					end)
   AS.optionframe:SetScript("OnShow",function(self)
	  AS.optionframe:SetFrameLevel(AS.optionframe:GetParent():GetFrameLevel()+1)
	  ASprint("Showing the 2 buttons.:?")
      AS.optionframe.resetignorebutton:Show()
	  AS.optionframe.deleterowbutton:Show()
   end)
   --AS.optionframe:SetScript("OnEnter",function(self)     end)
   AS.optionframe:SetScript("OnLeave",function(self)
	   --AS.optionframe:Hide()--bah doesnt work right
	   local x,y = GetCursorScaledPosition()
	   ASprint("Cursor x,y="..x..","..y.."  Left, right, bottom, top="..AS.optionframe:GetLeft()..","..AS.optionframe:GetRight()..","..AS.optionframe:GetBottom()..","..AS.optionframe:GetTop())
	   if(x < AS.optionframe:GetLeft() or x > AS.optionframe:GetRight() or y < AS.optionframe:GetBottom() or y > AS.optionframe:GetTop()) then
			AS.optionframe:Hide()
	   end
   end)

   AS.optionframe.resetignorebutton = CreateFrame("Button",nil,AS.optionframe)
   AS.optionframe.resetignorebutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.optionframe.resetignorebutton:SetWidth(AS.optionframe:GetWidth())
   AS.optionframe.resetignorebutton:SetPoint("top",0,-AS_FRAMEWHITESPACE)
   AS.optionframe.resetignorebutton:SetNormalFontObject("gamefontnormal")
   AS.optionframe.resetignorebutton:SetText("Erase Ignore Conditions?")
   AS.optionframe.resetignorebutton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
   AS.optionframe.resetignorebutton:SetFrameStrata("DIALOG")
   --AS.optionframe.resetignorebutton:SetBackdropColor(0,0,0,.2)
   AS.optionframe.resetignorebutton:SetScript("OnClick",function(self)
	  ASresetignore(self)
   end)
   --AS.optionframe.resetignorebutton:SetMovable(true)


   AS.optionframe.deleterowbutton = CreateFrame("Button",nil,AS.optionframe)
   AS.optionframe.deleterowbutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.optionframe.deleterowbutton:SetWidth(AS.optionframe:GetWidth())
   AS.optionframe.deleterowbutton:SetPoint("top",ASoptionframe.resetignorebutton,"bottom")
   AS.optionframe.deleterowbutton:SetNormalFontObject("gamefontnormal")
   AS.optionframe.deleterowbutton:SetText("Delete Row?")
   AS.optionframe.deleterowbutton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
   AS.optionframe.deleterowbutton:SetFrameStrata("DIALOG")
   --AS.optionframe.deleterowbutton:SetBackdropColor(0,0,0,1)
   AS.optionframe.deleterowbutton:SetScript("OnClick",function(self)
		ASdeleterow(self)
	end)

   AS.optionframe.movetotopbutton = CreateFrame("Button",nil,AS.optionframe)
   AS.optionframe.movetotopbutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.optionframe.movetotopbutton:SetWidth(AS.optionframe:GetWidth())
   AS.optionframe.movetotopbutton:SetPoint("top",ASoptionframe.deleterowbutton,"bottom")
   AS.optionframe.movetotopbutton:SetNormalFontObject("gamefontnormal")
   AS.optionframe.movetotopbutton:SetText("Move to top?")
   AS.optionframe.movetotopbutton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
   AS.optionframe.movetotopbutton:SetFrameStrata("DIALOG")
   --AS.optionframe.movetotopbutton:SetBackdropColor(0,0,0,1)
   AS.optionframe.movetotopbutton:SetScript("OnClick",function(self)
		local listnum = ASbuttontolistnum(self)
		ASmovelistbutton(listnum,1)
	end)

   AS.optionframe.movetobottombutton = CreateFrame("Button",nil,AS.optionframe)
   AS.optionframe.movetobottombutton:SetHeight(AS_BUTTON_HEIGHT)
   AS.optionframe.movetobottombutton:SetWidth(AS.optionframe:GetWidth())
   AS.optionframe.movetobottombutton:SetPoint("top",ASoptionframe.movetotopbutton,"bottom")
   AS.optionframe.movetobottombutton:SetNormalFontObject("gamefontnormal")
   AS.optionframe.movetobottombutton:SetText("Move to bottom?")
   AS.optionframe.movetobottombutton:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight")
   AS.optionframe.movetobottombutton:SetFrameStrata("DIALOG")
   --AS.optionframe.movetobottombutton:SetBackdropColor(0,0,0,1)
   AS.optionframe.movetobottombutton:SetScript("OnClick",function(self)
		local listnum = ASbuttontolistnum(self)
		ASmovelistbutton(listnum,#AS.item + 1)
	end)



end  --end func

function ASresetignore(self)
	ASprint("Click reset")

	local listnum = ASbuttontolistnum(self)
	if(listnum) then
		ASprint("Deleteing table.  Table = ")
		ASprint(AS.item[listnum].ignoretable)
		AS.item[listnum].ignoretable = nil
		AS.item[listnum].priceoverride = nil
		AS.optionframe:Hide()
		ASsavevariables()
	end
end

function ASdeleterow(self)
	local listnum = ASbuttontolistnum(self)
	if(listnum) then
		if(AS.item[listnum]) then
			if(AS.item[listnum].name) then
				table.remove(AS.item,listnum)
				--hide the delete button if theres nothing else to delete
				if(table.maxn(AS.item) < listnum) then
					 AS.optionframe:Hide()

					ASprint("hiding self.  whatever self is.")
				end
				ASscrollbar_Update()
			else
				ASprint("|c00ff0000error.  |ritem.[buttonnumber]name "..listnum.." doesnt exist.")
				table.remove(AS.item,listnum)
				--hide the delete button if theres nothing else to delete
				if(table.maxn(AS.item) < listnum) then
					 AS.optionframe:Hide()

					ASprint("hiding self.  whatever self is.")
				end
			end
		end
	end
	ASscrollbar_Update()
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

      ASprint("|c004499FF creating prompt frame")



   AS.prompt=CreateFrame("Frame","ASpromptframe",UIParent)
   AS.prompt:SetPoint("bottom",0,200)  --its got to be bottom so one can just spam buttons without them moving around
   AS.prompt:SetHeight(420)  --some addons change font size, so this will be overridden in ASinitialize
   AS.prompt:SetWidth(200)
   AS.prompt:SetBackdrop({
			      bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			      tile = false, tileSize = 32, edgeSize = 32,
			      insets = { left = 9, right = 9, top = 9, bottom = 9 }
			   })
   AS.prompt:SetBackdropColor(0,0,0,.8)
   AS.prompt:SetMovable(true)
   AS.prompt:EnableMouse(true)
   AS.prompt:SetFrameStrata("DIALOG")
   AS.prompt:SetScript("OnMouseDown",function(self)
					  AS.prompt:StartMoving()
				       end)
   AS.prompt:SetScript("OnMouseUp",function(self)
					AS.prompt:StopMovingOrSizing()
				     end)

   AS.prompt:SetScript("OnShow",function(self)
      ASprint("|c0055ffffPrompt is shown.  AS.status = "..tostring(AS.status))
   end)
   AS.prompt:SetScript("OnHide",function(self)
      ASprint("|c0055ffffPrompt is Hidden.  AS.status = "..tostring(AS.status))
   end)



   AS.prompt.drag = CreateFrame("Button", nil, AS.prompt)
   AS.prompt.drag:SetPoint("TOPLEFT", AS.prompt, "TOPLEFT", 10,-5)
   AS.prompt.drag:SetPoint("TOPRIGHT", AS.prompt, "TOPRIGHT", -10,-5)
   AS.prompt.drag:SetHeight(6)
   AS.prompt.drag:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar")
   AS.prompt.drag:SetScript("OnMouseDown", function(self) AS.prompt:StartMoving() end)
   AS.prompt.drag:SetScript("OnMouseUp", function(self) AS.prompt:StopMovingOrSizing() end)




   AS.prompt.icon = CreateFrame("Button", nil, AS.prompt)
   AS.prompt.icon:SetNormalTexture("Interface\\Buttons\\UI-Slot-Background")
   AS.prompt.icon:GetNormalTexture():SetTexCoord(0,0.640625, 0,0.640625)
   AS.prompt.icon:SetPoint("TOPLEFT", AS.prompt, "TOPLEFT", AS_FRAMEWHITESPACE, -AS_FRAMEWHITESPACE)
   AS.prompt.icon:SetHeight(37)
   AS.prompt.icon:SetWidth(37)
    AS.prompt.icon:SetScript("OnEnter",
            function(self)
	   local link = GetAuctionItemLink("list", AScurrentahresult)
	   if (link) then
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
	      if (EnhTooltip) then
			EnhTooltip.TooltipCall(GameTooltip, name, link, -1, count, buyout)
	      end
	      GameTooltip:ClearAllPoints()
	      GameTooltip:SetPoint("TOPRIGHT", AS.prompt.icon, "TOPLEFT", -10, -20)
	      GameTooltip:Show()
	      --		end
	   end
	end)
    AS.prompt.icon:SetScript("OnLeave",
            function(self)
	   GameTooltip:Hide()
	end)

   AS.prompt.buttonnames = {AS_BUTTONUPDATE,AS_BUTTONDELETE,AS_BUTTONIGNORE,AS_BUTTONNEXTAH,AS_BUTTONBID,AS_BUTTONCLOSE,AS_BUTTONDELETEALL,AS_BUTTONEXPENSIVE,AS_BUTTONNEXTLIST,AS_BUTTONBUYOUT}
   buttonnames = AS.prompt.buttonnames
   local buttontooltips = {AS_BUTTONTEXT1,AS_BUTTONTEXT2,AS_BUTTONTEXT3,AS_BUTTONTEXT4,AS_BUTTONTEXT5,AS_BUTTONTEXT6,AS_BUTTONTEXT7,AS_BUTTONTEXT8,AS_BUTTONTEXT9,AS_BUTTONTEXT10}

   buttonwidth = (AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)  --basically half its frame size

   AScreatebuttonhandlers()  --as this is logic stuff, it should not go in the interface file


   local i, rowsacross, rowsdown, Xoffset, Yoffset
   rowsdown=5

   for i = 1,table.maxn(buttonnames) do
      AScreatepromptbutton(buttonnames[i],buttontooltips[i])
      --Complicated, i know, but it works
      Xoffset= (math.floor((i-1)/rowsdown)*(buttonwidth+AS_FRAMEWHITESPACE*2)) + (AS_FRAMEWHITESPACE)
      Yoffset=math.floor((i-1)%rowsdown) * AS_BUTTON_HEIGHT
    --  ASprint("x="..Xoffset.."  Y="..Yoffset.."   AS_framewhitespace="..AS_FRAMEWHITESPACE)
      AS.prompt[buttonnames[i]]:SetPoint("bottomleft",Xoffset ,Yoffset+AS_FRAMEWHITESPACE)
   end


   -- these are the two text locations
   AS.prompt.upperstring= AS.prompt:CreateFontString(nil,"OVERLAY","gamefontnormal")
   AS.prompt.upperstring:SetJustifyH("cENTER")
   AS.prompt.upperstring:SetWidth(AS.prompt:GetWidth() - (AS.prompt.icon:GetWidth() + 2*AS_FRAMEWHITESPACE)  )
   AS.prompt.upperstring:SetHeight(AS.prompt.icon:GetHeight())
   AS.prompt.upperstring:SetPoint("LEFT",AS.prompt.icon,"right")

   AS.prompt.lowerstring= AS.prompt:CreateFontString(nil,"OVERLAY","gamefontnormal")
   AS.prompt.lowerstring:SetJustifyH("Left")
   AS.prompt.lowerstring:SetJustifyV("Top")
   AS.prompt.lowerstring:SetWidth(AS.prompt:GetWidth() - (2*AS_FRAMEWHITESPACE))
   --AS.prompt.lowerstring:SetHeight(AS.prompt:GetHeight())
   --AS.prompt:SetAllPoints()
   AS.prompt.lowerstring:SetPoint("topright",AS.prompt.upperstring,"bottomright")
   AS.prompt.lowerstring:SetPoint("bottomright",AS.prompt,"bottomright")

--   AS.prompt.lowerstring:IsMultiLine(true)

	AS.prompt.priceoverride = CreateFrame("EditBox",nil,AS.prompt,"InputBoxTemplate")
	AS.prompt.priceoverride:SetPoint("Right",-AS_FRAMEWHITESPACE,-10)
	AS.prompt.priceoverride:SetHeight(30)
	AS.prompt.priceoverride:SetWidth(40)
	AS.prompt.priceoverride:SetAlpha(.5)
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

	--AS.prompt.priceoverride

   ASprint("Done creating prompt frame.")
end





function AScreatepromptbutton(name,tooltip)

   local buttonwidth
   buttonwidth = (AS.prompt:GetWidth() / 2) - (2 * AS_FRAMEWHITESPACE)

   AS.prompt[name] = CreateFrame("Button", "", AS.prompt, "OptionsButtonTemplate")
   AS.prompt[name]:SetText(name)
 --  AS.prompt[name]:SetPoint("left",AS_FRAMEWHITESPACE,0)  --just something, whatever
   AS.prompt[name]:SetWidth(buttonwidth)
   AS.prompt[name]:SetHeight(AS_BUTTON_HEIGHT)
   AS.prompt[name]:SetScript("OnClick", function(self)
     AS[name]()
     AS.prompt:Hide()
  end)

   AS.prompt[name]:SetScript("OnEnter",function(self)
		ASshowtooltip(AS.prompt[name],tooltip)
					 end)
   AS.prompt[name]:SetScript("OnLeave", AShidetooltip)



end



--&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
---------------------------------------------------------------------------
function AScreatelistbutton(i)
   local buttontemplate,texttexture,ASfontstring,ASicon, ASnormaltexture,AShighlighttexture,buttonnumber

   -------------------------------the actual button
   buttontemplate = CreateFrame("Button",nil,AS.mainframe.listframe)
   buttontemplate:SetHeight(AS_BUTTON_HEIGHT)
   buttontemplate:SetWidth(AS.mainframe:GetWidth() - 40)
   buttontemplate:SetPoint("top")
   buttontemplate:SetNormalFontObject("gamefontnormal")
   buttontemplate.buttonnumber=i
   buttontemplate:SetMovable(true)

   buttontemplate:SetScript("OnMouseDown",
      function(self)
        --compensate for scroll bar
        ASscrollbar = getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
        --allow drag repositioning of buttons
	    ASorignumber = self.buttonnumber+ASscrollbar:GetValue()
      end)


	buttontemplate:SetScript("OnClick",
      function(self)
        ASprint("CLeeekkk!")

		if(IsShiftKeyDown()) then
			--get the link from this row
			ASprint("SHIIIFTTT cleeek")
		else
			if(AS.optionframe:IsVisible()) then
				AS.optionframe:Hide()
			else

				AS.optionframe:Show()
				AS.optionframe:SetParent(self)
				AS.optionframe:SetPoint("Top",self,"bottomright")
			end
		end

      end)

    buttontemplate:SetScript("OnMouseUp",
    	function(self)
         	ASmovelistbutton(ASorignumber)
        	ASscrollbar_Update()
    	end)

   buttontemplate:SetScript("OnEnter",
      function(self)
      local ignoreprice,messagestring,quality
    	 local mainfunc = AS.mainframe:GetScript("OnEnter")
    	 if(buttontemplate.leftstring:GetText()) then
    	   --show tooltip indicating you can double click this

    	      messagestring = AS_INFO
    	      --show all cutoff prices
    	      local scrollvalue=ASscrollbar:GetValue()

			  if (AS and AS.item and AS.item[i+scrollvalue] and AS.item[i+scrollvalue].priceoverride) then
				  messagestring = messagestring.."\nManual Override: "..ASGSC(tonumber(AS.item[i+scrollvalue].priceoverride))
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

   ------------------------------the text
   --cant use button text because button text cant be left justified
   buttontemplate.leftstring = buttontemplate:CreateFontString(nil,"OVERLAY","gamefontnormal")
   buttontemplate.leftstring:SetJustifyH("Left")
   buttontemplate.leftstring:SetPoint("LEFT",ASnormaltexture,5,0)


   ---------------------------------- the quantity
   buttontemplate.rightstring = buttontemplate:CreateFontString(nil,"OVERLAY","gamefontnormal")
   buttontemplate.rightstring:SetJustifyH("Right")
   buttontemplate.rightstring:SetPoint("Right",ASnormaltexture,-5,0)


   ---------------the little icon on the left
   buttontemplate.icon=CreateFrame("Button",nil,buttontemplate)
   buttontemplate.icon:SetWidth(AS_BUTTON_HEIGHT)
   buttontemplate.icon:SetHeight(AS_BUTTON_HEIGHT)
   buttontemplate.icon:SetPoint("TOPLEFT")
   buttontemplate.icon:SetNormalTexture("Interface\\Buttons\\UI-Slot-Background")
   buttontemplate.icon:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
   buttontemplate.icon:GetNormalTexture():SetTexCoord(0,0.640625, 0,0.640625)  --i have no idea how this manages to make the texture bigger, but hallelujah it does
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
   normaltextureleft=ourbutton:CreateTexture()
   normaltextureleft:SetHeight(AS_BUTTON_HEIGHT)
   normaltextureleft:SetWidth(10) --10 is the gap between text and anything else
   normaltextureleft:SetPoint("left",34,0)
   normaltextureleft:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltextureleft:SetTexCoord(0,.07,0,1)
   normaltextureleft:Hide()
   --right
   normaltextureright=ourbutton:CreateTexture()
   normaltextureright:SetHeight(AS_BUTTON_HEIGHT)
   normaltextureright:SetWidth(10)
   normaltextureright:SetPoint("right",-10,0)
   normaltextureright:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltextureright:SetTexCoord(0,.8,0,1)
   normaltextureright:Hide()
   --center?
   normaltexture=ourbutton:CreateTexture()
   normaltexture:SetHeight(AS_BUTTON_HEIGHT)
   normaltexture:SetPoint("left",normaltextureleft,"right")
   normaltexture:SetPoint("right",normaltextureright,"left")
   normaltexture:SetTexture("Interface\\AuctionFrame\\UI-AuctionItemNameFrame")
   normaltexture:SetTexCoord(0,.75,0,1)
   --center highlight
   highlighttexture=ourbutton:CreateTexture()
   highlighttexture:SetHeight(AS_BUTTON_HEIGHT)
   highlighttexture:SetWidth(normaltexture:GetWidth()) --10 is the gap between text and anything else
   highlighttexture:SetPoint("left",normaltexture)
   highlighttexture:SetPoint("right",normaltexture)
   highlighttexture:SetTexture("Interface\\HelpFrame\\HelpFrameButton-Highlight")
   highlighttexture:SetTexCoord(0,1,.1,.1)


   return normaltexture,highlighttexture
end



----------------------------------------------------------------------------------
---------------------------------------------------
-------------------------------------------------------------------------------
function AScreatescrollbar()

   local ourscrollbar
   ---------------------------------- scroll bar (ugh)
   AS.mainframe.listframe["scrollbarframe"] = CreateFrame("ScrollFrame","AS.mainframe.listframe.scrollbarframe",AS.mainframe.listframe,"UIPanelScrollFrameTemplate")
   AS.mainframe.listframe.scrollbarframe:SetPoint("topright",-36,0) --i dont know why, but the defaut UIScrollBarTemplate puts the scroll bar 40 pixels to the right of its parent frame
   AS.mainframe.listframe.scrollbarframe:SetPoint("bottomleft",0,20)


   ASscrollbar = getglobal("AS.mainframe.listframe.scrollbarframe".."ScrollBar")

   local ASscrollupbutton = getglobal(  AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBarScrollUpButton" );
   ASscrollupbutton:SetScript("OnClick",function(self)

					     local ourscrollbar
					     ourscrollbar=getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
					     ourscrollbar:SetValue(ourscrollbar:GetValue() - ((ASrowsthatcanfit()/2))) --have it scroll half the list each scroll
					     --AS.mainframe.listframe.deletebutton:Hide()  --weird bugs if you delete while scrolling
						 --AS.optionframe:Hide()  --weird bugs if you delete while scrolling
					  end)
   ASscrollupbutton:SetScript("OnMouseDown",function(self)
						 --     ASprint("mousdown exists")
						 ASscrollup=true
						 --AS.mainframe.listframe.deletebutton:Hide()  --weird bugs if you delete while scrolling
						 --AS.optionframe:Hide()  --weird bugs if you delete while scrolling
					      end)
   ASscrollupbutton:SetScript("OnMouseUp",function(self)
					       --     ASprint("mouseup exists")
					       ASscrollup=false
					       --AS.mainframe.listframe.deletebutton:Hide()  --weird bugs if you delete while scrolling
						   --AS.optionframe:Hide()  --weird bugs if you delete while scrolling
					    end)


   local ASscrolldownbutton = getglobal(  AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBarScrollDownButton" );
   ASscrolldownbutton:SetScript("OnClick",function(self)
					       local ourscrollbar
					       ourscrollbar=getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
					       ourscrollbar:SetValue(ourscrollbar:GetValue() + (ASrowsthatcanfit()/2)) --have it scroll half the list each scroll
					       --AS.mainframe.listframe.deletebutton:Hide()  --weird bugs if you delete while scrolling
						   --AS.optionframe:Hide()  --weird bugs if you delete while scrolling
					    end)
   ASscrolldownbutton:SetScript("OnMouseDown",function(self)
						   --     ASprint("mousdown exists")
						   ASscrolldown=true

						   AS.optionframe:Hide()  --weird bugs if you delete while scrolling
						end)
   ASscrolldownbutton:SetScript("OnMouseUp",function(self)
						 --     ASprint("mouseup exists")
						 ASscrolldown=false

						 AS.optionframe:Hide()  --weird bugs if you delete while scrolling
					      end)


   AS.mainframe.listframe.scrollbarframe:SetScript("OnVerticalScroll",function(self)

									   ASscrollbar_Update(name);

									   AS.optionframe:Hide()  --weird bugs if you delete while scrolling
									end)

   AS.mainframe.listframe.scrollbarframe:SetScript("OnMouseWheel",function(self,arg1)

								       local ourscrollbar
								       ourscrollbar=getglobal(AS.mainframe.listframe.scrollbarframe:GetName().."ScrollBar")
								       ourscrollbar:SetValue(ourscrollbar:GetValue() - (arg1*(ASrowsthatcanfit()/2))) --have it scroll half the list each scroll

									   AS.optionframe:Hide()  --weird bugs if you delete while scrolling
								    end)

   ASscrollbar:SetScript("OnShow",function(self)
				       ASscrollbar_Update(name)

				    end)

   --   ASscrollbar:SetMinMaxValues(0,ASrowsthatcanfit())
   --	ASscrollbar:SetMinMaxValues(0,(ASnumberofitems-ASrowsthatcanfit())  --i think this is the appropriate logic?
   ASscrollbar:SetValueStep(1)
   AScreatescrollbartemplate()
   ASscrollbar_Update()
end



function AScreatescrollbartemplate()


   -------------------------------------------------------------------------------
   --- this is my attempt to go the extra step and give our scrollbar some texture
   -------------------------------------------------------------------------------
   AStexturetop = AS.mainframe.listframe.scrollbarframe:CreateTexture()
   --   AStexturetop:SetHeight(AS_BUTTON_HEIGHT)
   AStexturetop:SetWidth(31)
   AStexturetop:SetPoint("topright",29,2)
   AStexturetop:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   AStexturetop:SetTexCoord(0,.484375,0,1) --this cuts the texture, taking only the bottomleft part of it, which just happens to fit the top of a scroll bar --thanks to possessions mod for the exact numbers

   AStexturebottom = AS.mainframe.listframe.scrollbarframe:CreateTexture()
   AStexturebottom:SetWidth(30)
   AStexturebottom:SetHeight(106)
   AStexturebottom:SetPoint("bottomright",29,-2)
   AStexturebottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   AStexturebottom:SetTexCoord(.515625,1,0,.4140625) --this cuts the texture, taking only the bottomright part of it, which just happens to fit the bottom of a scroll bar


   AStexture = AS.mainframe.listframe.scrollbarframe:CreateTexture()
   AStexture:SetHeight(AS_BUTTON_HEIGHT)
   --   AStexture:SetWidth(30)
   AStexture:SetAllPoints()
   AStexture:SetPoint("right",29,45)
   AStexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar")
   AStexture:SetTexCoord(0,.4,.8,.8) --this cuts the texture, taking only the left middle part of it
   AStexture:Hide()


end
--=======================================================================
function AScreateauctiontab()


   if (AuctionFrame) then

      ASauctiontab = CreateFrame("Button","ASauctiontab",AuctionFrame,"AuctionTabTemplate")
      ASauctiontab:SetText("AS")
      PanelTemplates_TabResize(ASauctiontab,50,70,70);
      local origfunc = ASauctiontab:GetScript("OnClick")
     ASauctiontab:SetScript("OnClick",function(...)
    	-- origfunc(...)  --hides the browse/bid stuff, sets the ID - nothing important
             ASopenedwithah=true
    	ASmain()
     end)
     ASauctiontab:SetScript("OnMouseDown",function(...)
	   ASmain()
     end)


--**********************************************
      local index =1;
      -- Find the first unused tab.
      while (getglobal("AuctionFrameTab" .. index)) do
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
   else
      --   ASprint ("|c00ff0000error.  |r.  no auctionframe!")
   end
   --------------------------------------------------------------------------------------
   --from igor
--	<Button name="IMA_AuctionFrameTab" inherits="AuctionTabTemplate"  parent="AuctionFrame" text="IMA_MASS_AUCTION">
--		<Scripts>
--			<OnLoad>IMA_InitAuctionFrameTab(this);</OnLoad>
--		</Scripts>
--	</Button>

--from addons/auctionui
--	<Button name="AuctionTabTemplate" inherits="CharacterFrameTabButtonTemplate" virtual="true">
--		<Scripts>
--			<OnClick>
--				AuctionFrameTab_OnClick();
--			</OnClick>
--		</Scripts>
--	</Button>
--------------------------------------------------------------------------------
end



