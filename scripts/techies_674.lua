require("libs.ScriptConfig")
require("libs.Utils684")

local config = ScriptConfig.new()
config:Load()
local loadedMines = {}
local minesDamage = {300,450,600}
local minesDamageScepter = {450,600,750}

function MinesTick(tick)
if not SleepCheck() then return end Sleep(200)
local me = entityList:GetMyHero()
if not me then return end
local ID = me.classId
if ID ~= myhero then GameClose() end
if not ID == CDOTA_Unit_Hero_Techies then scriptisable() end

local enemies = entityList:GetEntities({type=LuaEntity.TYPE_HERO,v isible = true, alive = true, team = me:GetEnemyTeam(),illusion=false})
local mins = entityList:GetEntities({classId=CDOTA_NPC_TechiesM ines})
local spell = me:GetAbility(6)

if spell.level > 0 then
for i,v in ipairs(mins) do
if v.alive and not loadedMines[v.handle] and isValidMine(v) then
loadedMines[v.handle] = getMineDmg(me, spell.level)
end
end
end

local totalMineDmg = 0
local minesToExplode = {}
for i,v in ipairs(enemies) do
if v.healthbarOffset ~= -1 and not v:IsIllusion() and v.alive and v.health > 1 then
local mines = entityList:GetEntities(function (m) return m.classId == CDOTA_NPC_TechiesMines and m.alive and m.GetDistance2D(m,v) < 425 end)
for k,j in ipairs(mines) do
if isValidMine(j) then
totalMineDmg = totalMineDmg + (loadedMines[j.handle] or getMineDmg(me, spell.level))
minesToExplode[j.handle] = j
local dmgM = math.floor(vamageTaken(totalMineDmg,DAMAGE_MAGC, me))
local remaingHealth = math.floor(v.health - dmgM + v.healthRegen)
if remaingHealth < 0 and CanDie(v) then
for n,m in pairs(minesToExplode) do
local boom = m:GetAbility(1)
if boom:CanBeCasted() then
m:SafeCastAbility(boom)
loadedMines[m.handle] = nil
end
end
break
end
end
end

end
totalMineDmg = 0
minesToExplode = {}
end
end

function isValidMine(mine)
if mine:GetAbility(1) then
return true
else
return false
end
end

function getMineDmg(me, ultLevel)
if not me:AghanimState() then
return minesDamage[ultLevel]
else
return minesDamageScepter[ultLevel]
end
end

function CanDie(enemy)
if enemy:CanDie() and not enemy:IsMagicDmgImmune() then
return true
else
return false
end
end

function Load()
if PlayingGame() then
local me = entityList:GetMyHero()
reg = true
save1,save2 = nil,nil
myhero = me.classId

script:RegisterEvent(EVENT_TICK,MinesTick)
script:UnregisterEvent(Load)
end
end

function GameClose()
myhero = nil
needmana = nil
needmeka = nil
onlyitems = false
if reg then
script:UnregisterEvent(MinesTick)
script:RegisterEvent(EVENT_TICK,Load)
reg = false
end
end

script:RegisterEvent(EVENT_CLOSE,GameClose)
script:RegisterEvent(EVENT_TICK,Load)
