local addon, s = ...

s[1] = {} -- B, functions, constants, variables
s[2] = {} -- L, localization
s[3] = {} -- T, globals

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

local B, L, T = unpack(select(2, ...))

T.FRAMEWHITESPACE = 10
T.BUTTON_HEIGHT = 23
T.GROSSHEIGHT = 420
T.HEADERHEIGHT = 120
T.LISTHEIGHT = T.GROSSHEIGHT - T.HEADERHEIGHT
T.FIRSTRUN_AH = false
T.ACTIVE_TABLE = nil
T.COPY = nil
T.SKIN = false
T.RENAME = nil

T.AS = { -- Contains everything
    ['item'] = {},
    ['currentauction'] = 1,
    ['currentownerauction'] = 1,
    ['currentauctionitem'] = {},
    ['currentresult'] = 0,
    ['elapsed'] = 0,
    ['selected'] = {},
    ['override'] = false,
    ['soldauctions'] = {},
    ['boughtauctions'] = {},
    ['events'] = {['AUCTIONS'] = {}, ['SOLD'] = {}, ['REMOVE'] = {}}
}

T.MSGC = {
    ['ERROR'] = "|cffFF00E1",
    ['INFO'] = "|cff35FCB5",--"|cffB5EDFF",
    ['EVENT'] = "|cffFFBF00",--"|cff35FCB5",
    ['DEBUG'] = "|cffE0FC35",
    ['DEFAULT'] = "|cff765EFF",
    ['BOOL'] = "|cff2BED48",
    ['WARN'] = "|cffDBD3AF"
}

T.OPTIONS = {
    ['searchoncreate'] = true,
    ['AOoutbid'] = true,
    ['AOsold'] = true,
    ['AOexpired'] = true,
    ['AOchatsold'] = true,
    ['onetimead'] = true
}

T.STATE = {
    ['QUERYING'] = 1,
    ['WAITINGFORUPDATE'] = 2,
    ['EVALUATING'] = 3,
    ['WAITINGFORPROMPT'] = 4,
    ['BUYING'] = 5
}
