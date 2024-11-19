
-----------------------------------------------------------------
-- File     :  /cdimage/units/XSL0301/XSL0301_script.lua
-- Author(s):  Jessica St. Croix, Gordon Duclos
-- Summary  :  Seraphim Sub Commander Script
-- Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
-----------------------------------------------------------------

---@alias SeraphimSCUEnhancementBuffType
---| "SCUBUILDRATE"
---| "SCUUPGRADEDMG"

---@alias SeraphimSCUEnhancementBuffName      # BuffType
---| "SeraphimSCUDamageStabilization"         # SCUUPGRADEDMG
---| "SeraphimSCUBuildRate"                   # SCUBUILDRATE


local CommandUnit = import("/lua/defaultunits.lua").CommandUnit
local SWeapons = import("/lua/seraphimweapons.lua")
local Buff = import("/lua/sim/buff.lua")
local SCUDeathWeapon = import("/lua/sim/defaultweapons.lua").SCUDeathWeapon
local EffectUtil = import("/lua/effectutilities.lua")
local SDFLightChronotronCannonWeapon = SWeapons.SDFLightChronotronCannonWeapon
local SDFOverChargeWeapon = SWeapons.SDFLightChronotronCannonOverchargeWeapon
local SIFLaanseTacticalMissileLauncher = SWeapons.SIFLaanseTacticalMissileLauncher

---@class XSL0301 : CommandUnit
XSL0301 = ClassUnit(CommandUnit) {
    Weapons = {
        LightChronatronCannon = ClassWeapon(SDFLightChronotronCannonWeapon) {},
        DeathWeapon = ClassWeapon(SCUDeathWeapon) {},
        OverCharge = ClassWeapon(SDFOverChargeWeapon) {},
        AutoOverCharge = ClassWeapon(SDFOverChargeWeapon) {},
        Missile = ClassWeapon(SIFLaanseTacticalMissileLauncher) {
            OnCreate = function(self)
                SIFLaanseTacticalMissileLauncher.OnCreate(self)
                self:SetWeaponEnabled(false)
            end,
        },
    },

    __init = function(self)
        CommandUnit.__init(self, 'LightChronatronCannon')
    end,

    OnCreate = function(self)
        CommandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Back_Upgrade', true)
        self:SetupBuildBones()
        self:GetWeaponByLabel('OverCharge').NeedsUpgrade = true
        self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = true
    end,

    StartBeingBuiltEffects = function(self, builder, layer)
        CommandUnit.StartBeingBuiltEffects(self, builder, layer)
        self.Trash:Add(ForkThread(EffectUtil.CreateSeraphimBuildThread, self, builder, self.OnBeingBuiltEffectsBag, 2))
    end,

    CreateBuildEffects = function(self, unitBeingBuilt, order)
        EffectUtil.CreateSeraphimUnitEngineerBuildingEffects(self, unitBeingBuilt, self.BuildEffectBones,
            self.BuildEffectsBag)
    end,

    EnhancementUpgrades = {

        Teleport = function (self, bp)
            --TODO: Not Applying Upgrade
            self:AddCommandCap('RULEUCC_Teleport')
        end,

        TeleportRemove = function(self, bp)
            self:RemoveCommandCap('RULEUCC_Teleport')
        end,

        Missile = function(self, bp)
            self:AddCommandCap('RULEUCC_Tactical')
            self:AddCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', true)
        end,

        MissileRemove = function(self, bp)
            self:RemoveCommandCap('RULEUCC_Tactical')
            self:RemoveCommandCap('RULEUCC_SiloBuildTactical')
            self:SetWeaponEnabledByLabel('Missile', false)
        end,

        OverCharge = function(self, bp)
            --TODO: Not Applying Upgrade
            self:AddCommandCap('RULEUCC_Overcharge')
            self:GetWeaponByLabel('OverCharge').NeedsUpgrade = false
            self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = false
        end,

        OverChargeRemove = function(self, bp)
            self:RemoveCommandCap('RULEUCC_Overcharge')
            self:SetWeaponEnabledByLabel('OverCharge', false)
            self:SetWeaponEnabledByLabel('AutoOverCharge', false)
            self:GetWeaponByLabel('OverCharge').NeedsUpgrade = true
            self:GetWeaponByLabel('AutoOverCharge').NeedsUpgrade = true
        end,

        EngineeringThroughput = function (self, bp)
            if not Buffs['SeraphimSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUBuildRate',
                    DisplayName = 'SeraphimSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'ADD',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add = bp.NewBuildRate + self.Blueprint.Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')
        end,

        EngineeringThroughputRemove = function(self, bp)
            if Buff.HasBuff(self, 'SeraphimSCUBuildRate') then
                Buff.RemoveBuff(self, 'SeraphimSCUBuildRate')
            end
        end,

        DamageStabilization = function (self, bp)
            if not Buffs['SeraphimSCUDamageStabilization'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUDamageStabilization',
                    DisplayName = 'SeraphimSCUDamageStabilization',
                    BuffType = 'SCUUPGRADEDMG',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            if Buff.HasBuff(self, 'SeraphimSCUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimSCUDamageStabilization')
            end
            Buff.ApplyBuff(self, 'SeraphimSCUDamageStabilization')
        end,

        DamageStabilizationRemove = function (self, bp)
            if Buff.HasBuff(self, 'SeraphimSCUDamageStabilization') then
                Buff.RemoveBuff(self, 'SeraphimSCUDamageStabilization')
            end
        end,

        EnhancedSensors = function(self, bp)
            self:SetIntelRadius('Vision', bp.NewVisionRadius or 104)
            self:SetIntelRadius('Omni', bp.NewOmniRadius or 104)
            local wepA = self:GetWeaponByLabel('LightChronatronCannon')
            wepA:ChangeMaxRadius(bp.NewMaxRadius or 35)
            local wepB = self:GetWeaponByLabel('OverCharge')
            wepB:ChangeMaxRadius(35)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(35)
        end,

        EnhancedSensorsRemove = function(self, bp)
            local bpIntel = self.Blueprint.Intel
            self:SetIntelRadius('Vision', bpIntel.VisionRadius or 26)
            self:SetIntelRadius('Omni', bpIntel.OmniRadius or 16)
            local wepA = self:GetWeaponByLabel('LightChronatronCannon')
            wepA:ChangeMaxRadius(bp.NewMaxRadius or 25)
            local wepB = self:GetWeaponByLabel('OverCharge')
            wepB:ChangeMaxRadius(25)
            local aoc = self:GetWeaponByLabel('AutoOverCharge')
            aoc:ChangeMaxRadius(25)
        end,

        DamageEnhancement = function(self, bp)
            local wep = self:GetWeaponByLabel('LightChronatronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius)
            wep:ChangeMaxRadius(bp.NewMaxRange or 30)
        end,

        DamageEnhancementRemove = function(self, bp)
            local wep = self:GetWeaponByLabel('LightChronatronCannon')
            wep:AddDamageRadiusMod(bp.NewDamageRadius)
            wep:ChangeMaxRadius(bp.NewMaxRange or 25)
        end,

        ResourceAllocation = function (self,bp)
            local bpEcon = self.Blueprint.Economy
            self:SetProductionPerSecondEnergy((bp.ProductionPerSecondEnergy + bpEcon.ProductionPerSecondEnergy) or 0)
            self:SetProductionPerSecondMass((bp.ProductionPerSecondMass + bpEcon.ProductionPerSecondMass) or 0)

            --TODO: Add Damage Death Weapon

            --TODO: Add Radius to Death Weapon
        end,

        ResourceAllocationRemove = function (self,bp)
            local bpEcon = self.Blueprint.Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)

            --TODO: Add Remove Damage Death Weapon

            --TODO: Add Remove Radius to Death Weapon
        end,

    },

    CreateEnhancement = function(self, enh)
        CommandUnit.CreateEnhancement(self, enh)
        local bp = self.Blueprint.Enhancements[enh]
        if not bp then return end

        if self.EnhancementUpgrades[enh] then
            self.EnhancementUpgrades[enh](self, bp)
        else
            WARN('SCURebalance: Enhancement '..repr(enh)..' failed. Has no Script')
        end
    end,
}

TypeClass = XSL0301