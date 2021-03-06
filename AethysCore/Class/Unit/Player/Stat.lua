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
  
  -- File Locals
  


--- ============================ CONTENT ============================
  -- gcd
  local GCD_OneSecond = {
    [103] = true,   -- Feral
    [259] = true,   -- Assassination
    [260] = true,   -- Outlaw
    [261] = true,   -- Subtlety
    [268] = true,   -- Brewmaster
    [269] = true    -- Windwalker
  };
  local GCD_Value = 1.5;
  function Player:GCD ()
    local GUID = self:GUID()
    if GUID then
      local UnitInfo = Cache.UnitInfo[GUID] if not UnitInfo then UnitInfo = {} Cache.UnitInfo[GUID] = UnitInfo end
      if not UnitInfo.GCD then
        if GCD_OneSecond[Cache.Persistent.Player.Spec[1]] then
          UnitInfo.GCD = 1;
        else
          GCD_Value = 1.5/(1+self:HastePct()/100);
          UnitInfo.GCD = GCD_Value > 0.75 and GCD_Value or 0.75;
        end
      end
      return UnitInfo.GCD;
    end
  end
  
  -- gcd.remains
  local GCDSpell = Spell(61304);
  function Player:GCDRemains ()
    return GCDSpell:CooldownRemains(true);
  end

  -- attack_power
  -- TODO : Use Cache
  function Player:AttackPower ()
    return UnitAttackPower(self.UnitID);
  end

  -- crit_chance
  -- TODO : Use Cache
  function Player:CritChancePct ()
    return GetCritChance();
  end

  -- haste
  -- TODO : Use Cache
  function Player:HastePct ()
    return GetHaste();
  end
  
  function Player:SpellHaste()
    return (1 + (Player:HastePct() / 100));
  end

  -- mastery
  -- TODO : Use Cache
  function Player:MasteryPct ()
    return GetMasteryEffect();
  end

  -- versatility
  -- TODO : Use Cache
  function Player:VersatilityDmgPct ()
    return GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) + GetVersatilityBonus(CR_VERSATILITY_DAMAGE_DONE);
  end
