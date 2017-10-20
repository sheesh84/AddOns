--- ============================ HEADER ============================
--- ======= LOCALIZE =======
  -- Addon
  local addonName, AC = ...;
  -- AethysCore
  local Cache, Utils = AethysCache, AC.Utils;
  local Unit = AC.Unit;
  local Player, Pet, Target = Unit.Player, Unit.Pet, Unit.Target;
  local Focus, MouseOver = Unit.Focus, Unit.MouseOver;
  local Arena, Boss, Nameplate = Unit.Arena, Unit.Boss, Unit.Nameplate;
  local Party, Raid = Unit.Party, Unit.Raid;
  local Spell = AC.Spell;
  local Item = AC.Item;
  -- Lua
  local pairs = pairs;
  local select = select;
  local tablesort = table.sort;
  -- File Locals
  


--- ============================ CONTENT ============================
  --------------------------
  --- 0 | Mana Functions ---
  --------------------------
  -- mana.max
  function Player:ManaMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.ManaMax then
        UnitInfo.ManaMax = UnitPowerMax(self.UnitID, Enum.PowerType.Mana);
      end
      return UnitInfo.ManaMax;
    end
  end
  -- Mana
  function Player:Mana ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Mana then
        UnitInfo.Mana = UnitPower(self.UnitID, Enum.PowerType.Mana);
      end
      return UnitInfo.Mana;
    end
  end
  -- Mana.pct
  function Player:ManaPercentage ()
    return (self:Mana() / self:ManaMax()) * 100;
  end
  -- Mana.deficit
  function Player:ManaDeficit ()
    return self:ManaMax() - self:Mana();
  end
  -- "Mana.deficit.pct"
  function Player:ManaDeficitPercentage ()
    return (self:ManaDeficit() / self:ManaMax()) * 100;
  end  
  
  --------------------------
  --- 1 | Rage Functions ---
  --------------------------
  -- rage.max
  function Player:RageMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.RageMax then
        UnitInfo.RageMax = UnitPowerMax(self.UnitID, Enum.PowerType.Rage);
      end
      return UnitInfo.RageMax;
    end
  end
  -- rage
  function Player:Rage ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Rage then
        UnitInfo.Rage = UnitPower(self.UnitID, Enum.PowerType.Rage);
      end
      return UnitInfo.Rage;
    end
  end
  -- rage.pct
  function Player:RagePercentage ()
    return (self:Rage() / self:RageMax()) * 100;
  end
  -- rage.deficit
  function Player:RageDeficit ()
    return self:RageMax() - self:Rage();
  end
  -- "rage.deficit.pct"
  function Player:RageDeficitPercentage ()
    return (self:RageDeficit() / self:RageMax()) * 100;
  end

  ---------------------------
  --- 2 | Focus Functions ---
  ---------------------------
  -- focus.max
  function Player:FocusMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.FocusMax then
        UnitInfo.FocusMax = UnitPowerMax(self.UnitID, Enum.PowerType.Focus);
      end
      return UnitInfo.FocusMax;
    end
  end
  -- focus
  function Player:Focus ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Focus then
        UnitInfo.Focus = UnitPower(self.UnitID, Enum.PowerType.Focus);
      end
      return UnitInfo.Focus;
    end
  end
  -- focus.regen
  function Player:FocusRegen ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.FocusRegen then
        UnitInfo.FocusRegen = select(2, GetPowerRegen(self.UnitID));
      end
      return UnitInfo.FocusRegen;
    end
  end
  -- focus.pct
  function Player:FocusPercentage ()
    return (self:Focus() / self:FocusMax()) * 100;
  end
  -- focus.deficit
  function Player:FocusDeficit ()
    return self:FocusMax() - self:Focus();
  end
  -- "focus.deficit.pct"
  function Player:FocusDeficitPercentage ()
    return (self:FocusDeficit() / self:FocusMax()) * 100;
  end
  -- "focus.regen.pct"
  function Player:FocusRegenPercentage ()
    return (self:FocusRegen() / self:FocusMax()) * 100;
  end
  -- focus.time_to_max
  function Player:FocusTimeToMax ()
    if self:FocusRegen() == 0 then return -1; end
    return self:FocusDeficit() / self:FocusRegen();
  end
  -- "focus.time_to_x"
  function Player:FocusTimeToX (Amount)
    if self:FocusRegen() == 0 then return -1; end
    return Amount > self:Focus() and (Amount - self:Focus()) / self:FocusRegen() or 0;
  end
  -- "focus.time_to_x.pct"
  function Player:FocusTimeToXPercentage (Amount)
    if self:FocusRegen() == 0 then return -1; end
    return Amount > self:FocusPercentage() and (Amount - self:FocusPercentage()) / self:FocusRegenPercentage() or 0;
  end
  -- cast_regen
  function Player:FocusCastRegen (CastTime)
    if self:FocusRegen() == 0 then return -1; end
    return self:FocusRegen() * CastTime;
  end
  -- "remaining_cast_regen"
  function Player:FocusRemainingCastRegen (Offset)
    if self:FocusRegen() == 0 then return -1; end
    -- If we are casting, we check what we will regen until the end of the cast
    if self:IsCasting() then
      return self:FocusRegen() * (self:CastRemains() + (Offset or 0));
    -- Else we'll use the remaining GCD as "CastTime"
    else
      return self:FocusRegen() * (self:GCDRemains() + (Offset or 0));
    end
  end
  -- Get the Focus we will loose when our cast will end, if we cast.
  function Player:FocusLossOnCastEnd ()
    return self:IsCasting() and Spell(self:CastID()):Cost() or 0;
  end
  -- Predict the expected Focus at the end of the Cast/GCD.
  function Player:FocusPredicted (Offset)
    if self:FocusRegen() == 0 then return -1; end
    return self:Focus() + self:FocusRemainingCastRegen(Offset) - self:FocusLossOnCastEnd();
  end

  ----------------------------
  --- 3 | Energy Functions ---
  ----------------------------
  -- energy.max
  function Player:EnergyMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.EnergyMax then
        UnitInfo.EnergyMax = UnitPowerMax(self.UnitID, Enum.PowerType.Energy);
      end
      return UnitInfo.EnergyMax;
    end
  end
  -- energy
  function Player:Energy ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Energy then
        UnitInfo.Energy = UnitPower(self.UnitID, Enum.PowerType.Energy);
      end
      return UnitInfo.Energy;
    end
  end
  -- energy.regen
  function Player:EnergyRegen ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.EnergyRegen then
        UnitInfo.EnergyRegen = select(2, GetPowerRegen(self.UnitID));
      end
      return UnitInfo.EnergyRegen;
    end
  end
  -- energy.pct
  function Player:EnergyPercentage ()
    return (self:Energy() / self:EnergyMax()) * 100;
  end
  -- energy.deficit
  function Player:EnergyDeficit ()
    return self:EnergyMax() - self:Energy();
  end
  -- "energy.deficit.pct"
  function Player:EnergyDeficitPercentage ()
    return (self:EnergyDeficit() / self:EnergyMax()) * 100;
  end
  -- "energy.regen.pct"
  function Player:EnergyRegenPercentage ()
    return (self:EnergyRegen() / self:EnergyMax()) * 100;
  end
  -- energy.time_to_max
  function Player:EnergyTimeToMax ()
    if self:EnergyRegen() == 0 then return -1; end
    return self:EnergyDeficit() / self:EnergyRegen();
  end
  -- "energy.time_to_x"
  function Player:EnergyTimeToX (Amount, Offset)
    if self:EnergyRegen() == 0 then return -1; end
    return Amount > self:Energy() and (Amount - self:Energy()) / (self:EnergyRegen() * (1 - (Offset or 0))) or 0;
  end
  -- "energy.time_to_x.pct"
  function Player:EnergyTimeToXPercentage (Amount)
    if self:EnergyRegen() == 0 then return -1; end
    return Amount > self:EnergyPercentage() and (Amount - self:EnergyPercentage()) / self:EnergyRegenPercentage() or 0;
  end
  -- "energy.cast_regen"
  function Player:EnergyRemainingCastRegen (Offset)
    if self:EnergyRegen() == 0 then return -1; end
    -- If we are casting, we check what we will regen until the end of the cast
    if self:IsCasting() or self:IsChanneling() then
      return self:EnergyRegen() * (self:CastRemains() + (Offset or 0));
    -- Else we'll use the remaining GCD as "CastTime"
    else
      return self:EnergyRegen() * (self:GCDRemains() + (Offset or 0));
    end
  end
  -- Predict the expected Energy at the end of the Cast/GCD.
  function Player:EnergyPredicted (Offset)
    if self:EnergyRegen() == 0 then return -1; end
    return self:Energy() + self:EnergyRemainingCastRegen(Offset);
  end
  -- Predict the expected Energy Deficit at the end of the Cast/GCD.
  function Player:EnergyDeficitPredicted (Offset)
    if self:EnergyRegen() == 0 then return -1; end
    return self:EnergyDeficit() - self:EnergyRemainingCastRegen(Offset);
  end
  -- Predict time to max energy at the end of Cast/GCD
  function Player:EnergyTimeToMaxPredicted ()
  if self:EnergyRegen() == 0 then return -1; end
  return self:EnergyDeficitPredicted()  / self:EnergyRegen();
end

  ----------------------------------
  --- 4 | Combo Points Functions ---
  ----------------------------------
  -- combo_points.max
  function Player:ComboPointsMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.ComboPointsMax then
        UnitInfo.ComboPointsMax = UnitPowerMax(self.UnitID, Enum.PowerType.ComboPoints);
      end
      return UnitInfo.ComboPointsMax;
    end
  end
  -- combo_points
  function Player:ComboPoints ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.ComboPoints then
        UnitInfo.ComboPoints = UnitPower(self.UnitID, Enum.PowerType.ComboPoints);
      end
      return UnitInfo.ComboPoints;
    end
  end
  -- combo_points.deficit
  function Player:ComboPointsDeficit ()
    return self:ComboPointsMax() - self:ComboPoints();
  end

  ---------------------------------
  --- 5 | Runic Power Functions ---
  ---------------------------------
  -- runicpower.max
  function Player:RunicPowerMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.RunicPowerMax then
        UnitInfo.RunicPowerMax = UnitPowerMax(self.UnitID, Enum.PowerType.RunicPower);
      end
      return UnitInfo.RunicPowerMax;
    end
  end
  -- runicpower
  function Player:RunicPower ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.RunicPower then
        UnitInfo.RunicPower = UnitPower(self.UnitID, Enum.PowerType.RunicPower);
      end
      return UnitInfo.RunicPower;
    end
  end
  -- runicpower.pct
  function Player:RunicPowerPercentage ()
    return (self:RunicPower() / self:RunicPowerMax()) * 100;
  end
  -- runicpower.deficit
  function Player:RunicPowerDeficit ()
    return self:RunicPowerMax() - self:RunicPower();
  end
  -- "runicpower.deficit.pct"
  function Player:RunicPowerDeficitPercentage ()
    return (self:RunicPowerDeficit() / self:RunicPowerMax()) * 100;
  end

  ---------------------------
  --- 6 | Runes Functions ---
  ---------------------------
  -- Computes any rune cooldown.
  local function ComputeRuneCooldown (Slot, BypassRecovery)
    -- Get rune cooldown infos
    local CDTime, CDValue = GetRuneCooldown(Slot);
    -- Return 0 if the rune isn't in CD.
    if CDTime == 0 then return 0; end
    -- Compute the CD.
    local CD = CDTime + CDValue - AC.GetTime() - (BypassRecovery and 0 or AC.RecoveryOffset());
    -- Return the Rune CD
    return CD > 0 and CD or 0;
  end
  -- rune
  function Player:Runes ()
    local Count = 0;
    for i = 1, 6 do
      if ComputeRuneCooldown(i) == 0 then
        Count = Count + 1;
      end
    end
    return Count;
  end
  -- rune.time_to_x
  function Player:RuneTimeToX (Value)
    if type(Value) ~= "number" then error("Value must be a number."); end
    if Value < 1 or Value > 6 then error("Value must be a number between 1 and 6."); end
    local Runes = {};
    for i = 1, 6 do
      Runes[i] = ComputeRuneCooldown(i);
    end
    tablesort(Runes, function(a, b) return a < b; end);
    local Count = 1;
    for _, CD in pairs(Runes) do
      if Count == Value then
        return CD;
      end
      Count = Count + 1;
    end
  end


  ------------------------
  --- 7 | Soul Shards  ---
  ------------------------
  -- soul_shard.max
  function Player:SoulShardsMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.SoulShardsMax then
        UnitInfo.SoulShardsMax = UnitPowerMax(self.UnitID, Enum.PowerType.SoulShards);
      end
      return UnitInfo.SoulShardsMax;
    end
  end
  -- soul_shard
  function Player:SoulShards ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.SoulShards then
        UnitInfo.SoulShards = WarlockPowerBar_UnitPower(self.UnitID);
      end
      return UnitInfo.SoulShards;
    end
  end
  -- soul_shard.deficit
  function Player:SoulShardsDeficit ()
    return self:SoulShardsMax() - self:SoulShards();
  end  
  
  ------------------------
  --- 8 | Astral Power ---
  ------------------------
  -- astral_power.max
  function Player:AstralPowerMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.AstralPowerMax then
        UnitInfo.AstralPowerMax = UnitPowerMax(self.UnitID, Enum.PowerType.LunarPower);
      end
      return UnitInfo.AstralPowerMax;
    end
  end
  -- astral_power
  function Player:AstralPower ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.AstralPower then
        UnitInfo.AstralPower = UnitPower(self.UnitID, Enum.PowerType.LunarPower);
      end
      return UnitInfo.AstralPower;
    end
  end
  -- astral_power.pct
  function Player:AstralPowerPercentage ()
    return (self:AstralPower() / self:AstralPowerMax()) * 100;
  end
  -- astral_power.deficit
  function Player:AstralPowerDeficit (overrideFuturAstralPower)
    local AstralPower = self:AstralPower()
    if overrideFuturAstralPower then AstralPower=overrideFuturAstralPower end
    return self:AstralPowerMax() - AstralPower;
  end
  -- "astral_power.deficit.pct"
  function Player:AstralPowerDeficitPercentage ()
    return (self:AstralPowerDeficit() / self:AstralPowerMax()) * 100;
  end

  --------------------------------
  --- 9 | Holy Power Functions ---
  --------------------------------
  -- holy_power.max
  function Player:HolyPowerMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.HolyPowerMax then
        UnitInfo.HolyPowerMax = UnitPowerMax(self.UnitID, Enum.PowerType.HolyPower);
      end
      return UnitInfo.HolyPowerMax;
    end
  end
  -- holy_power
  function Player:HolyPower ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.HolyPower then
        UnitInfo.HolyPower = UnitPower(self.UnitID, Enum.PowerType.HolyPower);
      end
      return UnitInfo.HolyPower;
    end
  end
  -- holy_power.pct
  function Player:HolyPowerPercentage ()
    return (self:HolyPower() / self:HolyPowerMax()) * 100;
  end
  -- holy_power.deficit
  function Player:HolyPowerDeficit ()
    return self:HolyPowerMax() - self:HolyPower();
  end
  -- "holy_power.deficit.pct"
  function Player:HolyPowerDeficitPercentage ()
    return (self:HolyPowerDeficit() / self:HolyPowerMax()) * 100;
  end

  ------------------------------
  -- 11 | Maelstrom Functions --
  ------------------------------
  -- maelstrom.max
  function Player:MaelstromMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.MaelstromMax then
        UnitInfo.MaelstromMax = UnitPowerMax(self.UnitID, Enum.PowerType.Maelstrom);
      end
      return UnitInfo.MaelstromMax;
    end
  end
  -- maelstrom
  function Player:Maelstrom ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Maelstrom then
        UnitInfo.Maelstrom = UnitPower(self.UnitID, Enum.PowerType.Maelstrom);
      end
      return UnitInfo.Maelstrom;
    end
  end
  -- maelstrom.pct
  function Player:MaelstromPercentage ()
    return (self:Maelstrom() / self:MaelstromMax()) * 100;
  end
  -- maelstrom.deficit
  function Player:MaelstromDeficit ()
    return self:MaelstromMax() - self:Maelstrom();
  end
  -- "maelstrom.deficit.pct"
  function Player:MaelstromDeficitPercentage ()
    return (self:MaelstromDeficit() / self:MaelstromMax()) * 100;
  end

  --------------------------------
  --- 12 | Chi Functions ---
  --------------------------------
  -- Chi.max
  function Player:ChiMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.ChiMax then
        UnitInfo.ChiMax = UnitPowerMax(self.UnitID, Enum.PowerType.Chi);
      end
      return UnitInfo.ChiMax;
    end
  end
  -- Chi
  function Player:Chi ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Chi then
        UnitInfo.Chi = UnitPower(self.UnitID, Enum.PowerType.Chi);
      end
      return UnitInfo.Chi;
    end
  end
  -- Chi.pct
  function Player:ChiPercentage ()
    return (self:Chi() / self:ChiMax()) * 100;
  end
  -- Chi.deficit
  function Player:ChiDeficit ()
    return self:ChiMax() - self:Chi();
  end
  -- "Chi.deficit.pct"
  function Player:ChiDeficitPercentage ()
    return (self:ChiDeficit() / self:ChiMax()) * 100;
  end

  ------------------------------
  -- 13 | Insanity Functions ---
  ------------------------------
  -- insanity.max
  function Player:InsanityMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.InsanityMax then
        UnitInfo.InsanityMax = UnitPowerMax(self.UnitID, Enum.PowerType.Insanity);
      end
      return UnitInfo.InsanityMax;
    end
  end
  -- insanity
  function Player:Insanity ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Insanity then
        UnitInfo.Insanity = UnitPower(self.UnitID, Enum.PowerType.Insanity);
      end
      return UnitInfo.Insanity;
    end
  end
  -- insanity.pct
  function Player:InsanityPercentage ()
    return (self:Insanity() / self:InsanityMax()) * 100;
  end
  -- insanity.deficit
  function Player:InsanityDeficit ()
    return self:InsanityMax() - self:Insanity();
  end
  -- "insanity.deficit.pct"
  function Player:InsanityDeficitPercentage ()
    return (self:InsanityDeficit() / self:InsanityMax()) * 100;
  end
  -- Insanity Drain
  function Player:Insanityrain ()
    --TODO : calculate insanitydrain
    return 1;
  end

  ---------------------------
  --- 17 | Fury Functions ---
  ---------------------------
  -- fury.max
  function Player:FuryMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.FuryMax then
        UnitInfo.FuryMax = UnitPowerMax(self.UnitID, Enum.PowerType.Fury);
      end
      return UnitInfo.FuryMax;
    end
  end
  -- fury
  function Player:Fury ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.Fury then
        UnitInfo.Fury = UnitPower(self.UnitID, Enum.PowerType.Fury);
      end
      return UnitInfo.Fury;
    end
  end
  -- fury.pct
  function Player:FuryPercentage ()
    return (self:Fury() / self:FuryMax()) * 100;
  end
  -- fury.deficit
  function Player:FuryDeficit ()
    return self:FuryMax() - self:Fury();
  end
  -- "fury.deficit.pct"
  function Player:FuryDeficitPercentage ()
    return (self:FuryDeficit() / self:FuryMax()) * 100;
  end

  ---------------------------
  --- 18 | Pain Functions ---
  ---------------------------
  -- pain.max
  function Player:PainMax ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.PainMax then
        UnitInfo.PainMax = UnitPowerMax(self.UnitID, Enum.PowerType.Pain);
      end
      return UnitInfo.PainMax;
    end
  end
  -- pain
  function Player:Pain ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.PainMax then
        UnitInfo.PainMax = UnitPower(self.UnitID, Enum.PowerType.Pain);
      end
      return UnitInfo.PainMax;
    end
  end
  -- pain.pct
  function Player:PainPercentage ()
    return (self:Pain() / self:PainMax()) * 100;
  end
  -- pain.deficit
  function Player:PainDeficit ()
    return self:PainMax() - self:Pain();
  end
  -- "pain.deficit.pct"
  function Player:PainDeficitPercentage ()
    return (self:PainDeficit() / self:PainMax()) * 100;
  end
