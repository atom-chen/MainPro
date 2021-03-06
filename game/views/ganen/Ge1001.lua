--
-- Author: Your Name
-- Date: 2018-09-18 14:32:34
--登录有礼
local Ge1001 = class("Ge1001",import("game.base.Ref"))

function Ge1001:ctor(parent,id)
    self.moduleId = id 
    self.parent = parent
    self.view = parent.cacheComponent[self.moduleId]
    self:initView()
end

function Ge1001:onTimer()
    -- body
    if not self.data then return end

end

-- 变量名：reqType 说明：0：显示 1：领取普通奖励 2：领取vip奖励
-- 变量名：normalAwardSign 说明：普通奖励领取标识
-- 变量名：mateAwardSign   说明：伴侣奖励领取标识
-- array<SimpleItemInfo>   变量名：items   说明：奖励
-- 变量名：curDay  说明：当前第几天 从1开始
-- 变量名：actStartTime    说明：活动开始时间
-- 变量名：actEndTime  说明：活动结束时间
function Ge1001:addMsgCallBack(data)
    -- body
    printt("登录驚喜",data)
    if data.items then
        GOpenAlert3(data.items,true)
    end
    self.curDay = data.curDay
    self.normallId = 10000+self.curDay
    local normallData = conf.GanEnConf:getLoginAwardById(self.normallId)
    if normallData then
        self.normallAwards = normallData.items
        self.listView1.numItems = #self.normallAwards
    end
    self.banlvId = 20000+self.curDay
    local banlvData = conf.GanEnConf:getLoginAwardById(self.banlvId)
    if banlvData then
        self.banlvAwards = banlvData.items
        self.listView2.numItems = #self.banlvAwards
    end

    self.timeTxt.text = GToTimeString12(data.actStartTime) .. "-" .. GToTimeString12(data.actEndTime)

    local btn1State = self.getBtn1:GetController("c1")
    local btn2State = self.getBtn2:GetController("c1")
    if data.normalAwardSign == 0 then--可领取
        btn1State.selectedIndex = 0
        self.getBtn1.title = language.friend22
    else--已领取
        btn1State.selectedIndex = 2
        self.getBtn1.title = language.yqs08
    end

    if data.mateAwardSign == 0 then--未领取
        local banlv = cache.PlayerCache:getCoupleName()
        if banlv ~= "" then
            btn2State.selectedIndex = 0
        else
            btn2State.selectedIndex = 1
        end

    else--已领取
        btn2State.selectedIndex = 2
        self.getBtn2.title = language.yqs08
    end

    self.getBtn1.data = {state = btn1State.selectedIndex,reqType = 1}
    self.getBtn2.data = {state = btn2State.selectedIndex,reqType = 2}
    self.getBtn1.onClick:Add(self.onClickGet,self)
    self.getBtn2.onClick:Add(self.onClickGet,self)

end

function Ge1001:onClickGet(context)
    local data = context.sender.data
    local state = data.state
    local reqType = data.reqType
    if state == 1 then
         GComAlter(language.ge03)
        return
    elseif state == 2 then
        GComAlter(language.czccl07)
    end
    proxy.GanEnProxy:sendMsg(1030652,{reqType = reqType})
end

function Ge1001:initView()
    -- body
    local c1 = self.view:GetController("c1")
    c1.selectedIndex = 0
    self.panel = self.view:GetChild("n6")

    self.timeTxt = self.view:GetChild("n4")
    self.decTxt = self.view:GetChild("n5")
    self.decTxt.text = language.ge01
    --今日登录奖励列表
    self.listView1 = self.panel:GetChild("n5")
    self.listView1.numItems = 0
    self.listView1.itemRenderer = function (index,obj)
        self:cell1data(index, obj)
    end
    self.listView1:SetVirtual()
    self.getBtn1 = self.panel:GetChild("n6")

    --伴侣登录奖励列表
    self.listView2 = self.panel:GetChild("n13")
    self.listView2.numItems = 0
    self.listView2.itemRenderer = function (index,obj)
        self:cell2data(index, obj)
    end
    self.listView2:SetVirtual()
    self.getBtn2 = self.panel:GetChild("n14")

end

function Ge1001:cell1data( index,obj )
    local data = self.normallAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

function Ge1001:cell2data( index,obj )
    local data = self.banlvAwards[index+1]
    if data then
        local itemInfo = {mid = data[1],amount = data[2],bind = data[3]}
        GSetItemData(obj,itemInfo,true)
    end
end

return Ge1001