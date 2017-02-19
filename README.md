![Auction One](http://i.imgur.com/Ot8cCbM.jpg)

# Auction One: 
Fully based on [Auction Snatch](https://wow.curseforge.com/projects/auctionsnatch) by daxdax -- custom features, bug fixes and reskin for altz ui/aurora

### New and Custom features
* **Track sold auctions** while they are pending
* Start/stop query (for the list and invdividual item)
* Create as many lists as you want
* Copy entries from list to list
* Remember prices for auctions (via the sell option)
* Cancel auction on right-click
* Create shortcut to edit entry and add notes
* Add an auto-open option
* iLvl filter
* Stacks of 1 filter
* Reskin to match [Altz UI/Aurora skin UI](http://www.wowinterface.com/downloads/fileinfo.php?id=21263#info) (optional)

Auction One keeps a saved list of items you want to buy from the Auction House, and automatically scans the Auction House for every item on your list. It's very fast and will happen before you even have time to type anything in. If an auction is found, a prompt will appear to ask you what you want to do. The selections in the Prompt are self-explanatory.

Many mods keep track of items you want to remember or search for - but I found it tedious to keep selecting items in the list.  Shopping List automates that process. I no longer worry about missing the rare Hyacinth Macaw in the auction house!

#### Directions
A new tab will appear on the Auction House Frame. Clicking that will bring up the interface. Type in your search queries, hit enter, and then when your list is complete, click 'Start Search'.

### Sold auctions: very cool feature
Due to cross-server zones in major cities, sold auctions that are pending do not always show up in the auctions tab. To work around this Blizzard limitation, I built an internal tracker that will keep a list of your sold auctions with their remaining time while your character is logged in. You can view your sold auctions that are pending by clicking the gold icon in the main Auction One window. The data persists between sessions. *If you like this feature and find it useful, please consider donating to the project: [Curse donation (paypal)](https://www.paypal.com/cgi-bin/webscr?return=%2f%2fwww.curse.com%2fproject%2f259146&cn=Add+special+instructions+to+the+addon+author()&business=dthompson011%40hotmail.com&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted&cancel_return=%2f%2fwww.curse.com%2fproject%2f259146&lc=US&item_name=Auction+One+(from+curseforge.com)&cmd=_donations&rm=1&no_shipping=1&currency_code=USD)*  
**Due to Blizzard server limitations**, the Auction House needs to be opened once per session to start recording sells. Sold auctions can't be tracked when your character is logged out.

### Options:
* **[ Import list ]** Select which list you want to view
* **[ List options ]** Per list options
  * **[ Rename list ]** Rename the currently loaded list
  * **[ Doorbell sound ]** Fun sound when prompt for buying shows
  * **[ Ignore bids ]** Ignore bidding price, only consider the buyout price
  * **[ Ignore no buyouts ]** Ignore items without a buyout price
  * **[ Icon tooltip ]** Enable tooltip on mouseover for icons in the list
* **[ Create list ]** Create a new list
* **[ Value in copper ]** Changes the value, at the time of input, between copper or gold-only
* **[ Remember price ]** When using the sell option, remember the unit price from previous auction
* **[ Auto-open ]** Open Auction One automatically when opening the Auction House
* **[ Auto-start ]** Once the Auction One window is open, start searching automatically the default list

### Other features:
* 'Esc' will always close any open frames
* Shift-click the start search button to start where you left off
* Double-click the item in list will search the Auction House
* Right-click the item in list will auto-search the Auction House for the item
* Shift-click on any item in your bags, auction listing or in chat links to add that item to your list while Auction One is open.
* When opening the Auction House, holding shift will reverse the auto-search feature.
* Re-order or Ignore items in the list
* Set maximum buyout price per item. Auction One will not prompt your for items above that price.
* Localization available: English, French, Russian

### Slash commands: *(example: /ao debug)* 
**debug**: Toggle debug  
**cancelauction**: Toggle Cancel auction on right-click in the auctions tab  
**searchoncreate**: Toggle Search the item in the Auction House after creating the auction in our list  
**reloadcancelauction**: Force refresh the list of owned auctions. Requires re-opening the Auction House to take effect
