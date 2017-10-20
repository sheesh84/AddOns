local Addon = Bagnon
local ItemSlot = Addon.ItemSlot
local UpdateBorder = ItemSlot.UpdateBorder
local Search = LibStub('CustomSearch-1.0')
local ItemSearch = LibStub('LibItemSearch-1.2')

-- Creates a list of icons for each item slot which represent the existing equipment sets by
-- their current icons
local function CreateIcons(slot)
  local equipmentSetIcons = {}
  
  for i = 1, GetNumEquipmentSets() do
    local name, iconTexture = GetEquipmentSetInfo(i)
    local icon = slot:CreateTexture(nil, 'OVERLAY')
    icon:SetTexture(iconTexture)
    icon:SetSize(15, 15)
    
    equipmentSetIcons[name] = icon
  end
  
  slot.EquipmentSetIcons = equipmentSetIcons
  return equipmentSetIcons
end

-- Called when the inventory is loaded for each item
function ItemSlot:UpdateBorder()
  local item = self:GetItem()
  local equipmentSetIcons = self.EquipmentSetIcons or CreateIcons(self)
  self:HideBorder()
  
  -- Hide all equipment set icons first
  for curName, _ in pairs(equipmentSetIcons) do
    equipmentSetIcons[curName]:Hide()
  end
  
  -- If this is an equipment set item
  if item then
    if ItemSearch:InSet(item) then
      -- Figure out which ones it belongs to
      local equipmentSets = GetEquipmentSetNames(item)
   
      -- For every equipment set this belongs to:
      local iteration = 0
      for equipmentSetName, _ in pairs(equipmentSets) do        
        -- Set the draw layer (so the icons render over each other properly),
        -- the position, and display the icon
        equipmentSetIcons[equipmentSetName]:SetDrawLayer('OVERLAY', (7 - iteration))
        equipmentSetIcons[equipmentSetName]:SetPoint('TOPLEFT',
          2 + (iteration * (equipmentSetIcons[equipmentSetName]:GetWidth() / 2)),
          -2)
        equipmentSetIcons[equipmentSetName]:SetShown(true)
        
        iteration = iteration + 1
        
        -- Note: Due to inventory item frame size constraints,
        -- the max number of equipment sets we will display for a single item is 3.
        if iteration == 3 then
          break
        end
      end
      
      return true
    end
  end
 
  UpdateBorder(self)
end

-- Gets the equipment set names for a single item
function GetEquipmentSetNames(link, search)
  local equipmentSets = {}

	if IsEquippableItem(link) then
		local id = tonumber(link:match('item:(%-?%d+)'))
		for i = 1, GetNumEquipmentSets() do
			local name = GetEquipmentSetInfo(i)
			if Search:Find((search or ''):lower(), name) then
				local items = GetEquipmentSetItemIDs(name)
				for _, item in pairs(items) do
					if id == item then
						equipmentSets[name] = true
					end
				end
			end
    end
	end
  
  return equipmentSets
end