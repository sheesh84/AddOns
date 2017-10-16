--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- AethysRotation
local AR = AethysRotation;
-- Lua
local pairs = pairs;


-- APL Local Vars
-- Spell
  if not Spell.DemonHunter then Spell.DemonHunter = {}; end
  Spell.DemonHunter.Vengeance = {
    -- Abilities
    Felblade = Spell(232893),
    FelDevastation = Spell(212084),
    ImmolationAura = Spell(178740),
    Shear = Spell(203782),
    SigilofFlame = Spell(204596),
    SoulCleave = Spell(228477),
    ThrowGlaive = Spell(204157),
    -- Offensive
    SoulCarver = Spell(207407),
    -- Defensive
    DemonSpikes = Spell(203720),
    DemonSpikesBuff = Spell(203819),
    -- Utility
    ConsumeMagic = Spell(183752),
    InfernalStrike = Spell(189110)
  };
  local S = Spell.DemonHunter.Vengeance;
-- Rotation Var
  local EnemiesCount = {
    [15] = 1,
    [8] = 1
  };
-- GUI Settings
  local Settings = {
    General = AR.GUISettings.General,
    Vengeance = AR.GUISettings.APL.DemonHunter.Vengeance
  };

-- APL Main
local function APL ()
  --- Out of Combat
  if not Player:AffectingCombat() then
    -- Flask
    -- Food
    -- Rune
    -- PrePot w/ DBM Count
    -- Opener (Shear)
    if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() and Target:IsInRange(5) and S.Shear:IsCastable() then
      if AR.Cast(S.Shear) then return "Cast Shear"; end
    end
    return;
  end
  -- In Combat
    AC.GetEnemies(15); -- Fel Devastation (I think it's 20 thp)
    AC.GetEnemies(8); -- Sigil of Flamme
    AC.GetEnemies(5); -- Melee
    if AR.AoEON() then
      for Key, Value in pairs(EnemiesCount) do
        EnemiesCount[Key] = #Cache.Enemies[Key];
      end
    else
      for Key, Value in pairs(EnemiesCount) do
        EnemiesCount[Key] = 1;
      end
    end
    -- Demon Spikes
    if S.DemonSpikes:IsCastable() and Player:HealthPercentage() <= 70 and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) then
      if AR.Cast(S.DemonSpikes, Settings.Vengeance.OffGCDasOffGCD.DemonSpikes) then return "Cast Demon Spikes"; end
    end
    if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
      -- Consume Magic
      if Settings.General.InterruptEnabled and Target:IsInRange(20) and S.ConsumeMagic:IsCastable() and Target:IsInterruptible() then
        if AR.Cast(S.ConsumeMagic, Settings.Vengeance.OffGCDasOffGCD.ConsumeMagic) then return "Cast Consume Magic"; end
      end
      -- actions+=/soul_carver
      if AR.CDsON() and Target:IsInRange(5) and S.SoulCarver:IsCastable() then
        if AR.Cast(S.SoulCarver) then return "Cast Soul Carver"; end
      end
      -- actions+=/immolation_aura,if=pain<=80
      if Target:IsInRange(8) and S.ImmolationAura:IsCastable() and not Player:Buff(S.ImmolationAura) then
        if AR.Cast(S.ImmolationAura) then return "Cast Immolation Aura"; end
      end
      -- actions+=/felblade,if=pain<=70
      if Target:IsInRange(15) and S.Felblade:IsCastable() then
        if AR.Cast(S.Felblade) then return "Cast Felblade"; end
      end
      -- actions+=/fel_devastation
      if AR.CDsON() and AR.AoEON() and Target:IsInRange(15) and S.FelDevastation:IsCastable() and GetUnitSpeed("player") == 0 and Player:Pain() >= 30 then
        if AR.Cast(S.FelDevastation) then return "Cast Fel Devastation"; end
      end
      -- actions+=/sigil_of_flame
      if AR.AoEON() and Target:IsInRange(8) and S.SigilofFlame:IsCastable() then
        if AR.Cast(S.SigilofFlame) then return "Cast Sigil of Flame"; end
      end
      if Target:IsInRange(5) then
        -- actions+=/soul_cleave,if=pain>=80
        if S.SoulCleave:IsCastable() and Player:Pain() >= 60 then
          if AR.Cast(S.SoulCleave) then return "Cast Soul Cleave"; end
        end
        -- Infernal Strike Charges Dump
        if S.InfernalStrike:IsCastable() and S.InfernalStrike:Charges() > 1 then
          if AR.Cast(S.InfernalStrike, Settings.Vengeance.OffGCDasOffGCD.InfernalStrike) then return "Cast Infernal Strike"; end
        end
        -- actions+=/shear
        if S.Shear:IsCastable() then
          if AR.Cast(S.Shear) then return "Cast Shear"; end
        end
      end
      if Target:IsInRange(30) and S.ThrowGlaive:IsCastable() then
        if AR.Cast(S.ThrowGlaive) then return "Cast Throw Glaive (OoR)"; end
      end
    end
end

AR.SetAPL(581, APL);
