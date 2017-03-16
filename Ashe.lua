-- Deftsu, janilssonn
--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Ashe" then return end
--          [[ Updater ]]
local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/xuxiaoyi211/GoS/master/Ashe.lua", SCRIPT_PATH .. "Ashe.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/xuxiaoyi211/GoS/master/Version/Ashe.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local AsheMenu = Menu("Ashe", "Ashe")
--          [[ Combo ]]
AsheMenu:SubMenu("Combo", "Combo Settings")
AsheMenu.Combo:Boolean("Q", "Use Q", true)
AsheMenu.Combo:Boolean("W", "Use W", true)
AsheMenu.Combo:Slider("WM", "Use W Mana", 50, 1, 100, 1)
--AsheMenu.Combo:Boolean("E", "Use E", true)
AsheMenu.Combo:Boolean("R", "Use R", true)
--AsheMenu.Combo:Boolean("3ARW", "R + W + 3AA Combo If Can Kill", true)
--AsheMenu.Combo:KeyBinding("AutoR", "Auto R Key", string.byte("T"))
AsheMenu.Combo:Boolean("Items", "Use Items", true)
AsheMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
AsheMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)
AsheMenu.Combo:Boolean("QSS", "Use QSS", true)
AsheMenu.Combo:Slider("QSSHP", "if HP % <", 75, 0, 100, 1)
--          [[ Harass ]]
AsheMenu:SubMenu("Harass", "Harass Settings")
AsheMenu.Harass:Boolean("Q", "Use Q", true)
AsheMenu.Harass:Boolean("W", "Use W", true)
AsheMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
AsheMenu:SubMenu("LC", "LaneClear Settings")
AsheMenu.Farm:Boolean("Q", "Use Q", false)
AsheMenu.Farm:Boolean("W", "Use W", true)
AsheMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
AsheMenu:SubMenu("JC", "Jungle Clear Settings")
AsheMenu.JG:Boolean("Q", "Use Q", true)
AsheMenu.JG:Boolean("W", "Use W", true)
--          [[ KillSteal ]]
AsheMenu:SubMenu("KS", "KillSteal Settings")
AsheMenu.KS:Boolean("W", "Use W", true)
AsheMenu.KS:Boolean("R", "Use R", true)
--          [[ Misc ]]
AsheMenu:SubMenu("Mi", "Misc Settings")
AsheMenu.Mi:Boolean("RGC", "Use R to Gap Close", false)
AsheMenu.Mi:Slider("RHP", "HP To R Gap Close", 45, 1, 100, 1)
AsheMenu.Mi:Boolean("WGC", "Use W On Flee", false)
AsheMenu.Mi:Boolean("Int", "Use R Interrupt", false)
--AsheMenu.Mi:Boolean("AutoE", "Auto E To Bush", false)
--          [[ Draw ]]
AsheMenu:SubMenu("Draw", "Drawing Settings")
AsheMenu.Draw:Boolean("AA", "Draw AA", false)
AsheMenu.Draw:Boolean("W", "Draw W", true)
--          [[ Spell ]]
local Spells = {
 Q = {range = 600 },
 W = {range = 1200, speed = 2000, conewidth = 57.5, width = 20, col = {"minion","champion"}},
 E = {range = 10000, delay = 0.25, speed = 1400, radius = 1000},
 R = {range = 10000, delay = 0.25, speed = 1600, width = 250, col = {"champion"}},
}
--          [[ Orbwalker ]]
function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		return SLW:Mode()
	end
end

--          [[ OnProcess ]]
-- [防突进？gapclose?]
OnProcessSpell(function(unit, spell)
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(myHero) and Ready(_R) then
      if CHANELLING_SPELLS[spell.name] then
        if ValidTarget(unit, 1000) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and AsheMenu.Interrupt[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_R,unit)
        end
      end
    end
end)

--          [[ 发送 ]]
OnTick(function()
	KS()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	    end)  
		
    if IsReady(_R) and ValidTarget(Rtarget, 1200) and AsheMenu.Mi.RGC:Value() and GetPercentHP(myHero) <= AsheMenu.Mi.RHP:Value() then
      local hit, pos = RPred:Predict(Rtarget)
      if hit >= 4 then
      CastSkillShot(_R, pos)
      end
    end
	
--          [[ Q ]]
function AsheQ()	
	if myHero:CanUseSpell(_Q) == READY and ValidTarget(target, range) then
		CastSpell(_Q)
	end	
end   
--          [[ W ]]
function AsheW()	
	local WPred = GetPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		CastSkillShot(_W, WPred.castPos)
	end	
end   
--          [[ E ]]
--[[function AsheE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  ]]
--          [[ R ]]
function AsheR()
	local RPred = GetPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end  

--          [[ 连招 ]]
function Combo()

    local target = GetCurrentTarget()
    local QSS = GetItemSlot(myHero,3140) > 0 and GetItemSlot(myHero,3140) or GetItemSlot(myHero,3139) > 0 and GetItemSlot(myHero,3139) or nil
    local BRK = GetItemSlot(myHero,3153) > 0 and GetItemSlot(myHero,3153) or GetItemSlot(myHero,3144) > 0 and GetItemSlot(myHero,3144) or nil
    local YMG = GetItemSlot(myHero,3142) > 0 and GetItemSlot(myHero,3142) or nil
    local MS = GetItemSlot(myHero,3139) > 0 and GetItemSlot(myHero,3139) or nil
	
	if Mode() == "Combo" then
--		[[ 连招 Q ]]
		if AsheMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			AsheQ()
		end	
--		[[ 连招 W ]]
		if Ready(_W) and GetPercentMP(myHero) >= AsheMenu.Combo.WM:Value() and AsheMenu.Combo.W:Value() then
			AsheW()
			end
-- 	[[ 连招 E ]]
		--[[if AsheMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			AsheE()
		end]]
 --	[[ 连招 R ]]
		if AsheMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) then
			AsheR()
		end

--		[[]3AA连招]]
--		[[]草丛E]]

--		[[ 物品 ]]
		if QSS and IsReady(QSS) and AsheMenu.Combo.QSS:Value() and IsImmobile(myHero) or IsSlowed(myHero) or toQSS and GetPercentHP(myHero) < AsheMenu.Combo.QSSHP:Value() then
        CastSpell(QSS)
		end
		
		if BRK and IsReady(BRK) and AsheMenu.Combo.Items:Value() and ValidTarget(enemy, 550) and GetPercentHP(myHero) < AsheMenu.Combo.myHP:Value() and GetPercentHP(enemy) > AsheMenu.Combo.targetHP:Value() then
        CastTargetSpell(enemy, BRK)
        end

        if YMG and IsReady(YMG) and AsheMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
        CastSpell(YMG)
        end	
		
		if MS and IsReady(MS) and AsheMenu.Combo.Items:Value() and ValidTarget(enemy, 600) then
        CastSpell(MS)
        end	
	end
end

--          [[ 骚扰 ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= AsheMenu.Harass.Mana:Value() /100) then
-- 			[[ 骚扰 Q ]]
			if AsheMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				AsheQ()
			end
-- 			[[ 骚扰 W ]]
			if AsheMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
				AsheW()
			end
		end
	end
end

function Farm()
	if (Mode() == "LaneClear" then 
		if(myHero.mana/myHero.maxMana >= AsheMenu.Farm.Mana:Value() /100) then
-- 			[[ 清线 ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ 清线 Q ]]
					if AsheMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSpell(_Q)
					    end
-- 					[[ 清线 W ]]
					if AsheMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, Spells.W.range) then
							CastSkillShot(_W, minion)
						end	
					end
				end	
-- 			[[ 清野 ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ 清野 Q ]]
					if AsheMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSpell(_Q)
						end
-- 					[[ 清野 W ]]
					if AsheMenu.JG.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) then
							CastSkillShot(_W, mob)
						end	
					end
				end
			end
		end
	end

--          [[ 抢头 ]]
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do

-- 		[[ 抢头 W ]]
		if AsheMenu.KS.W:Value() and Ready(_W) and ValidTarget(enemy, Spells.W.range) then
			if GetCurrentHP(enemy) < getdmg("W", enemy, myHero) then
				AsheW()
				end
			end

--		[[ 抢头 R ]]
		if AsheMenu.KS.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					AsheR()
				end
			end
		end
	end
					
-- [[逃跑]]

--          [[ 线圈 ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if AsheMenu.Draw.AA:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Blue) end
--  [[ Draw W ]]
	if AsheMenu.Draw.W:Value() and Ready(_W) then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Green) end
end)			



				
EnemiesAround(myHero, Spells.W.range) >= LuxMenu.Combo.WMA:Value() 


















