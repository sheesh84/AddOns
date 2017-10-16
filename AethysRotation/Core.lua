--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AR = ...;
  -- AethysCore
  local AC = AethysCore;
  local Cache = AethysCache;
  local Unit = AC.Unit;
  local Player = Unit.Player;
  local Target = Unit.Target;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- Lua
  local mathmin = math.min;
  local print = print;
  local select = select;
  local stringlower = string.lower;
  local strsplit = strsplit;
  local tostring = tostring;
  -- File Locals


--- ======= GLOBALIZE =======
  -- Addon
  AethysRotation = AR;


--- ============================ CONTENT ============================
--- ======= CORE =======
  -- Print with ER Prefix
  function AR.Print (...)
    print("[|cFFFF6600Aethys Rotation|r]", ...);
  end

  -- Defines the APL
  AR.APLs = {};
  function AR.SetAPL (Spec, APL)
    AR.APLs[Spec] = APL;
  end

  -- Get the texture (and cache it until next reload).
  function AR.GetTexture (Object)
    if Object.SpellID then
      if not Cache.Persistent.Texture.Spell[Object.SpellID] then
        -- Check if the SpellID is the one from Custom Textures or a Regular WoW Spell
        if Object.SpellID >= 9999000000 then
          Cache.Persistent.Texture.Spell[Object.SpellID] = "Interface\\Addons\\AethysRotation\\Textures\\"..tostring(Object.SpellID);
        else
          Cache.Persistent.Texture.Spell[Object.SpellID] = GetSpellTexture(Object.SpellID);
        end
      end
      return Cache.Persistent.Texture.Spell[Object.SpellID];
    elseif Object.ItemID then
      if not Cache.Persistent.Texture.Item[Object.ItemID] then
        Cache.Persistent.Texture.Item[Object.ItemID] = ({GetItemInfo(Object.ItemID)})[10];
      end
      return Cache.Persistent.Texture.Item[Object.ItemID];
    end
  end

--- ======= CASTS =======
  local GCDSpell = Spell(61304);
  local function GCDDisplay ()
    if Player:IsCasting() or Player:IsChanneling() then
      AR.MainIconFrame:SetCooldown(Player:CastStart(), Player:CastDuration());
    else
      AR.MainIconFrame:SetCooldown(GCDSpell:CooldownInfo());
    end
  end
  -- Main Cast
  AR.CastOffGCDOffset = 1;
  function AR.Cast (Object, OffGCD)
    if OffGCD and OffGCD[1] then
      if AR.CastOffGCDOffset <= 2 then
        AR.SmallIconFrame:ChangeIcon(AR.CastOffGCDOffset, AR.GetTexture(Object));
        AR.CastOffGCDOffset = AR.CastOffGCDOffset + 1;
        Object.LastDisplayTime = AC.GetTime();
        return OffGCD[2] and "Should Return" or false;
      end
    else
      AR.MainIconFrame:ChangeIcon(AR.GetTexture(Object));
      GCDDisplay();
      Object.LastDisplayTime = AC.GetTime();
      return "Should Return";
    end
    return false;
  end
  -- Main Cast Queue
  local QueueSpellTable, QueueLength, QueueTextureTable;
  AR.MaxQueuedCasts = 3;
  function AR.CastQueue (...)
    QueueSpellTable = {...};
    QueueLength = mathmin(#QueueSpellTable, AR.MaxQueuedCasts);
    QueueTextureTable = {};
    for i = 1, QueueLength do
      QueueTextureTable[i] = AR.GetTexture(QueueSpellTable[i]);
      QueueSpellTable[i].LastDisplayTime = AC.GetTime();
    end
    AR.MainIconFrame:SetupParts(QueueTextureTable);
    GCDDisplay();
    return "Should Return";
  end

  -- Left (+ Nameplate) Cast
  AR.CastLeftOffset = 1;
  function AR.CastLeftCommon (Object)
    AR.LeftIconFrame:ChangeIcon(AR.GetTexture(Object));
    AR.CastLeftOffset = AR.CastLeftOffset + 1;
    Object.LastDisplayTime = AC.GetTime();
  end
  function AR.CastLeft (Object)
    if AR.CastLeftOffset == 1 then
      AR.CastLeftCommon(Object);
    end
    return false;
  end
  function AR.CastLeftNameplate (ThisUnit, Object)
    if AR.CastLeftOffset == 1 and AR.Nameplate.AddIcon(ThisUnit, Object) then
      AR.CastLeftCommon(Object);
    end
    return false;
  end

  -- Suggested Icon Cast
  AR.CastSuggestedOffset = 1;
  function AR.CastSuggested (Object)
    if AR.CastSuggestedOffset == 1 then
      AR.SuggestedIconFrame:ChangeIcon(AR.GetTexture(Object));
      AR.CastSuggestedOffset = AR.CastSuggestedOffset + 1;
      Object.LastDisplayTime = AC.GetTime();
    end
    return false;
  end

--- ======= COMMANDS =======
  -- Command Handler
  local Argument1, Argument2, Argument3;
  function AR.CmdHandler (Message)
    Argument1, Argument2, Argument3 = strsplit(" ", stringlower(Message));
    if Argument1 == "cds" then
      AethysRotationDB.Toggles[1] = not AethysRotationDB.Toggles[1];
      AR.ToggleIconFrame:UpdateButtonText(1);
      AR.Print("CDs are now "..(AethysRotationDB.Toggles[1] and "|cff00ff00enabled|r." or "|cffff0000disabled|r."));
    elseif Argument1 == "aoe" then
      AethysRotationDB.Toggles[2] = not AethysRotationDB.Toggles[2];
      AR.ToggleIconFrame:UpdateButtonText(2);
      AR.Print("AoE is now "..(AethysRotationDB.Toggles[2] and "|cff00ff00enabled|r." or "|cffff0000disabled|r."));
    elseif Argument1 == "toggle" then
      AethysRotationDB.Toggles[3] = not AethysRotationDB.Toggles[3];
      AR.ToggleIconFrame:UpdateButtonText(3);
      AR.Print("AethysRotation is now "..(AethysRotationDB.Toggles[3] and "|cff00ff00enabled|r." or "|cffff0000disabled|r."));
    elseif Argument1 == "unlock" then
      AR.MainFrame:Unlock();
      AR.Print("AethysRotation UI is now |cff00ff00unlocked|r.");
    elseif Argument1 == "lock" then
      AR.MainFrame:Lock();
      AR.Print("AethysRotation UI is now |cffff0000locked|r.");
    elseif Argument1 == "scale" then
      if Argument2 and Argument3 then
        Argument3 = tonumber(Argument3);
        if Argument3 and type(Argument3) == "number" and Argument3 > 0 and Argument3 <= 10 then
          if Argument2 == "ui" then
            AR.MainFrame:ResizeUI(Argument3);
          elseif Argument2 == "buttons" then
            AR.MainFrame:ResizeButtons(Argument3);
          elseif Argument2 == "all" then
            AR.MainFrame:ResizeUI(Argument3);
            AR.MainFrame:ResizeButtons(Argument3);
          else
            AR.Print("Invalid |cff88ff88[Type]|r for Scale.");
            AR.Print("Should be |cff8888ff/aer scale|r |cff88ff88[Type]|r |cffff8888[Size]|r.");
            AR.Print("Type accepted are |cff88ff88ui|r, |cff88ff88buttons|r, |cff88ff88all|r.");
          end
        else
          AR.Print("Invalid |cffff8888[Size]|r for Scale.");
          AR.Print("Should be |cff8888ff/aer scale|r |cff88ff88[Type]|r |cffff8888[Size]|r.");
          AR.Print("Size accepted are |cffff8888number > 0 and <= 10|r.");
        end
      else
        AR.Print("Invalid arguments for Scale.");
        AR.Print("Should be |cff8888ff/aer scale|r |cff88ff88[Type]|r |cffff8888[Size]|r.");
        AR.Print("Type accepted are |cff88ff88ui|r, |cff88ff88buttons|r, |cff88ff88all|r.");
        AR.Print("Size accepted are |cffff8888number > 0 and <= 10|r.");
      end
    elseif Argument1 == "resetbuttons" then
      AR.ToggleIconFrame:ResetAnchor();
    elseif Argument1 == "help" then
      AR.Print("|cffffff00--[Toggles]--|r");
      AR.Print("  On/Off: |cff8888ff/aer toggle|r");
      AR.Print("  CDs: |cff8888ff/aer cds|r");
      AR.Print("  AoE: |cff8888ff/aer aoe|r");
      AR.Print("|cffffff00--[User Interface]--|r");
      AR.Print("  UI Lock: |cff8888ff/aer lock|r");
      AR.Print("  UI Unlock: |cff8888ff/aer unlock|r");
      AR.Print("  UI Scale: |cff8888ff/aer scale|r |cff88ff88[Type]|r |cffff8888[Size]|r");
      AR.Print("    [Type]: |cff88ff88ui|r, |cff88ff88buttons|r, |cff88ff88all|r");
      AR.Print("    [Size]: |cffff8888number > 0 and <= 10|r");
      AR.Print("  Button Anchor Reset : |cff8888ff/aer resetbuttons|r");
    else
      AR.Print("Invalid arguments.");
      AR.Print("Type |cff8888ff/aer help|r for more infos.");
    end
  end
  SLASH_AETHYSROTATION1 = "/aer"
  SLASH_AETHYSROTATION2 = "/ar"
  SlashCmdList["AETHYSROTATION"] = AR.CmdHandler;

  -- Get if the CDs are enabled.
  function AR.CDsON ()
    return AethysRotationDB.Toggles[1];
  end

  -- Get if the AoE is enabled.
  function AR.AoEON ()
    return AethysRotationDB.Toggles[2];
  end

  -- Get if the main toggle is on.
  function AR.ON ()
    return AethysRotationDB.Toggles[3];
  end

  -- Get if the UI is locked.
  function AR.Locked ()
    return AethysRotationDB.Locked;
  end
