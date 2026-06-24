--[[
-- Orca, a free and open-source Roblox script hub.
-- Bundled version with all dependencies inline
--
-- Author: 0866
-- License: MIT
-- Version: "1.1.1"
-- GitHub: https://github.com/richie0866/orca
--]]

local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UserInputService=game:GetService("UserInputService")
local LocalPlayer=Players.LocalPlayer

-- === Promise Library ===
local Promise={}
do
    local n8="Non-promise value passed into %s at index %s"
    local n9="Please pass a list of promises to %s"
    local na="Please pass a handler function to %s!"
    local nb={__mode="k"}
    local function nc(nd,ne)
        local nf={}
        for ev,ng in ipairs(ne) do
            nf[ng]=ng
        end
        return setmetatable(nf,{
            __index=function(ev,gX)
                error(string.format("%s is not in %s!",gX,nd),2)
            end,
            __newindex=function()
                error(string.format("Creating new members in %s is not allowed!",nd),2)
            end
        })
    end

    local nh
    do
        nh={
            Kind=nc("Promise.Error.Kind",{"ExecutionError","AlreadyCancelled","NotResolvedInTime","TimedOut"})
        }
        nh.__index=nh
        function nh.new(cL,ni)
            cL=cL or {}
            return setmetatable({
                error=tostring(cL.error) or "[This error has no error text.]",
                trace=cL.trace,
                context=cL.context,
                kind=cL.kind,
                parent=ni,
                createdTick=os.clock(),
                createdTrace=debug.traceback()
            },nh)
        end
        function nh.is(nj)
            if type(nj)=="table" then
                local nk=getmetatable(nj)
                if type(nk)=="table" then
                    return rawget(nj,"error")~=nil and type(rawget(nk,"extend"))=="function"
                end
            end
            return false
        end
        function nh.isKind(nj,nl)
            assert(nl~=nil,"Argument #2 to Promise.Error.isKind must not be nil")
            return nh.is(nj) and nj.kind==nl
        end
        function nh:extend(cL)
            cL=cL or {}
            cL.kind=cL.kind or self.kind
            return nh.new(cL,self)
        end
        function nh:getErrorChain()
            local nm={self}
            while nm[#nm].parent do
                table.insert(nm,nm[#nm].parent)
            end
            return nm
        end
        function nh:__tostring()
            local nn={string.format("-- Promise.Error(%s) --",self.kind or "?")}
            for ev,no in ipairs(self:getErrorChain()) do
                table.insert(nn,table.concat({no.trace or no.error,no.context},"\n"))
            end
            return table.concat(nn,"\n")
        end
    end

    local function np(...)
        return select("#",...),{...}
    end

    local function nq(nr,...)
        return nr,select("#",...),{...}
    end

    local function ns(nt)
        assert(nt~=nil)
        return function(dw)
            if type(dw)=="table" then
                return dw
            end
            return nh.new({
                error=dw,
                kind=nh.Kind.ExecutionError,
                trace=debug.traceback(tostring(dw),2),
                context="Promise created at:\n\n"..nt
            })
        end
    end

    local function nu(nt,da,...)
        return nq(xpcall(da,ns(nt),...))
    end

    local function nv(nt,da,hy,nw)
        return function(...)
            local nx,ny,dx=nu(nt,da,...)
            if nx then
                hy(unpack(dx,1,ny))
            else
                nw(dx[1])
            end
        end
    end

    local function nz(ek)
        return next(ek)==nil
    end

    local nA={
        Error=nh,
        Status=nc("Promise.Status",{"Started","Resolved","Rejected","Cancelled"}),
        _getTime=os.clock,
        _timeEvent=game:GetService("RunService").Heartbeat
    }

    nA.prototype={}
    nA.__index=nA.prototype

    function nA._new(nt,da,ni)
        if ni~=nil and not nA.is(ni) then
            error("Argument #2 to Promise.new must be a promise or nil",2)
        end
        local self={
            _source=nt,
            _status=nA.Status.Started,
            _values=nil,
            _valuesLength=-1,
            _unhandledRejection=true,
            _queuedResolve={},
            _queuedReject={},
            _queuedFinally={},
            _cancellationHook=nil,
            _parent=ni,
            _consumers=setmetatable({},nb)
        }
        if ni and ni._status==nA.Status.Started then
            ni._consumers[self]=true
        end
        setmetatable(self,nA)
        local function hy(...)
            self:_resolve(...)
        end
        local function nw(...)
            self:_reject(...)
        end
        local function hz(nB)
            if nB then
                if self._status==nA.Status.Cancelled then
                    nB()
                else
                    self._cancellationHook=nB
                end
            end
            return self._status==nA.Status.Cancelled
        end
        coroutine.wrap(function()
            local nx,ev,dx=nu(self._source,da,hy,nw,hz)
            if not nx then
                nw(dx[1])
            end
        end)()
        return self
    end

    function nA.new(nC)
        return nA._new(debug.traceback(nil,2),nC)
    end

    function nA:__tostring()
        return string.format("Promise(%s)",self:getStatus())
    end

    function nA.resolve(...)
        local nE,nF=np(...)
        return nA._new(debug.traceback(nil,2),function(hy)
            hy(unpack(nF,1,nE))
        end)
    end

    function nA.reject(...)
        local nE,nF=np(...)
        return nA._new(debug.traceback(nil,2),function(ev,nw)
            nw(unpack(nF,1,nE))
        end)
    end

    function nA.is(fd)
        if type(fd)~="table" then
            return false
        end
        local o5=getmetatable(fd)
        if o5==nA then
            return true
        elseif o5==nil then
            return type(fd.andThen)=="function"
        elseif type(o5)=="table" and type(rawget(o5,"__index"))=="table" and type(rawget(rawget(o5,"__index"),"andThen"))=="function" then
            return true
        end
        return false
    end

    function nA.prototype:getStatus()
        return self._status
    end

    function nA.prototype:_andThen(nt,od,oe)
        self._unhandledRejection=false
        return nA._new(nt,function(hy,nw)
            local of=hy
            if od then
                of=nv(nt,od,hy,nw)
            end
            local og=nw
            if oe then
                og=nv(nt,oe,hy,nw)
            end
            if self._status==nA.Status.Started then
                table.insert(self._queuedResolve,of)
                table.insert(self._queuedReject,og)
            elseif self._status==nA.Status.Resolved then
                of(unpack(self._values,1,self._valuesLength))
            elseif self._status==nA.Status.Rejected then
                og(unpack(self._values,1,self._valuesLength))
            elseif self._status==nA.Status.Cancelled then
                nw(nh.new({
                    error="Promise is cancelled",
                    kind=nh.Kind.AlreadyCancelled,
                    context="Promise created at\n\n"..nt
                }))
            end
        end,self)
    end

    function nA.prototype:andThen(od,oe)
        assert(od==nil or type(od)=="function",string.format(na,"Promise:andThen"))
        assert(oe==nil or type(oe)=="function",string.format(na,"Promise:andThen"))
        return self:_andThen(debug.traceback(nil,2),od,oe)
    end

    function nA.prototype:catch(og)
        assert(og==nil or type(og)=="function",string.format(na,"Promise:catch"))
        return self:_andThen(debug.traceback(nil,2),nil,og)
    end

    function nA.prototype:finally(ok)
        assert(ok==nil or type(ok)=="function",string.format(na,"Promise:finally"))
        self._unhandledRejection=false
        return nA._new(debug.traceback(nil,2),function(hy,nw)
            local om=hy
            if ok then
                om=nv(debug.traceback(nil,2),ok,hy,nw)
            end
            if self._status==nA.Status.Started then
                table.insert(self._queuedFinally,om)
            else
                om(self._status)
            end
        end,self)
    end

    function nA.prototype:awaitStatus()
        self._unhandledRejection=false
        if self._status==nA.Status.Started then
            local on=Instance.new("BindableEvent")
            self:finally(function()
                on:Fire()
            end)
            on.Event:Wait()
            on:Destroy()
        end
        if self._status==nA.Status.Resolved then
            return self._status,unpack(self._values,1,self._valuesLength)
        elseif self._status==nA.Status.Rejected then
            return self._status,unpack(self._values,1,self._valuesLength)
        end
        return self._status
    end

    function nA.prototype:await()
        local dZ,...=self:awaitStatus()
        return dZ==nA.Status.Resolved,...
    end

    function nA.prototype:_resolve(...)
        if self._status~=nA.Status.Started then
            if nA.is(...) then
                (...):_consumerCancelled(self)
            end
            return
        end
        if nA.is(...) then
            local ot=...
            local dq=ot:andThen(function(...)
                self:_resolve(...)
            end,function(...)
                self:_reject(...)
            end)
            if dq._status==nA.Status.Cancelled then
                self:cancel()
            elseif dq._status==nA.Status.Started then
                self._parent=dq
                dq._consumers[self]=true
            end
            return
        end
        self._status=nA.Status.Resolved
        self._valuesLength,self._values=np(...)
        for ev,da in ipairs(self._queuedResolve) do
            coroutine.wrap(da)(...)
        end
        self:_finalize()
    end

    function nA.prototype:_reject(...)
        if self._status~=nA.Status.Started then
            return
        end
        self._status=nA.Status.Rejected
        self._valuesLength,self._values=np(...)
        if not nz(self._queuedReject) then
            for ev,da in ipairs(self._queuedReject) do
                coroutine.wrap(da)(...)
            end
        end
        self:_finalize()
    end

    function nA.prototype:_finalize()
        for ev,da in ipairs(self._queuedFinally) do
            coroutine.wrap(da)(self._status)
        end
        self._queuedFinally=nil
        self._queuedReject=nil
        self._queuedResolve=nil
    end

    function nA.prototype:cancel()
        if self._status~=nA.Status.Started then
            return
        end
        self._status=nA.Status.Cancelled
        if self._cancellationHook then
            self._cancellationHook()
        end
        if self._parent then
            self._parent:_consumerCancelled(self)
        end
        for fo in pairs(self._consumers) do
            fo:cancel()
        end
        self:_finalize()
    end

    function nA.prototype:_consumerCancelled(oj)
        if self._status~=nA.Status.Started then
            return
        end
        self._consumers[oj]=nil
        if next(self._consumers)==nil then
            self:cancel()
        end
    end

    Promise=nA
end

-- === RuntimeLib ===
local RuntimeLib={}
function RuntimeLib.import(script, ...)
    local path=script
    for i=1,select("#",...) do
        local part=select(i,...)
        if typeof(part)=="string" then
            path=path:FindFirstChild(part)
        else
            path=part
        end
    end
    if path then
        return require(path)
    end
    error("Module not found: "..tostring(path))
end

function RuntimeLib.getModule(script, ...)
    local path=script
    for i=1,select("#",...) do
        local part=select(i,...)
        if typeof(part)=="string" then
            path=path:FindFirstChild(part)
        else
            path=part
        end
    end
    return path
end

_G[script]=RuntimeLib

-- === Flipper Library ===
local Flipper={}
do
    local Signal={}
    Signal.__index=Signal
    function Signal.new()
        local self=setmetatable({
            listeners={}
        },Signal)
        return self
    end
    function Signal:connect(callback)
        table.insert(self.listeners,callback)
        local function disconnect()
            for i,v in ipairs(self.listeners) do
                if v==callback then
                    table.remove(self.listeners,i)
                    break
                end
            end
        end
        return {disconnect=disconnect}
    end
    function Signal:fire(...)
        for _,callback in ipairs(self.listeners) do
            callback(...)
        end
    end

    local BaseMotor={}
    BaseMotor.__index=BaseMotor
    function BaseMotor.new(initialValue)
        local self=setmetatable({
            _value=initialValue,
            _goal=initialValue,
            _listeners={}
        },BaseMotor)
        return self
    end
    function BaseMotor:getValue()
        return self._value
    end
    function BaseMotor:setGoal(goal)
        self._goal=goal
    end
    function BaseMotor:step(dt)
        self._value=self._goal
    end
    function BaseMotor:onStep(callback)
        table.insert(self._listeners,callback)
        return {
            disconnect=function()
                for i,v in ipairs(self._listeners) do
                    if v==callback then
                        table.remove(self._listeners,i)
                        break
                    end
                end
            end
        }
    end
    function BaseMotor:start()
    end
    function BaseMotor:stop()
    end

    local SingleMotor={}
    SingleMotor.__index=SingleMotor
    setmetatable(SingleMotor,{__index=BaseMotor})
    function SingleMotor.new(initialValue)
        local self=BaseMotor.new(initialValue)
        setmetatable(self,SingleMotor)
        return self
    end

    local GroupMotor={}
    GroupMotor.__index=GroupMotor
    setmetatable(GroupMotor,{__index=BaseMotor})
    function GroupMotor.new(initialValues)
        local self=BaseMotor.new(initialValues)
        setmetatable(self,GroupMotor)
        return self
    end

    local Spring={}
    Spring.__index=Spring
    function Spring.new(target,position,velocity,damping,frequency)
        local self=setmetatable({
            target=target,
            position=position or target,
            velocity=velocity or 0,
            damping=damping or 1,
            frequency=frequency or 1
        },Spring)
        return self
    end
    function Spring:step(dt)
        local f=self.frequency*2*math.pi
        local z=self.damping
        local k=f*f
        local c=2*z*f
        local force=(self.target-self.position)*k
        local acceleration=force-self.velocity*c
        self.velocity=self.velocity+acceleration*dt
        self.position=self.position+self.velocity*dt
        return self.position
    end

    local Instant={}
    Instant.__index=Instant
    function Instant.new(target)
        local self=setmetatable({
            target=target
        },Instant)
        return self
    end
    function Instant:step(dt)
        return self.target
    end

    local Linear={}
    Linear.__index=Linear
    function Linear.new(target,velocity)
        local self=setmetatable({
            target=target,
            velocity=velocity or 10
        },Linear)
        return self
    end
    function Linear:step(dt)
        return self.target
    end

    function Flipper.isMotor(motor)
        return getmetatable(motor)==BaseMotor or getmetatable(motor)==SingleMotor or getmetatable(motor)==GroupMotor
    end

    Flipper.Signal=Signal
    Flipper.BaseMotor=BaseMotor
    Flipper.SingleMotor=SingleMotor
    Flipper.GroupMotor=GroupMotor
    Flipper.Spring=Spring
    Flipper.Instant=Instant
    Flipper.Linear=Linear
    Flipper.isMotor=Flipper.isMotor
end

-- === Simple Roact Implementation ===
local Roact={}
do
    local Component={}
    Component.__index=Component
    function Component.new(props)
        local self=setmetatable({
            state=props and props.initialState or {},
            props=props or {}
        },Component)
        return self
    end
    function Component:setState(newState)
        for k,v in pairs(newState) do
            self.state[k]=v
        end
    end
    function Component:render()
        return nil
    end

    function Roact.createElement(component,props,children)
        return {
            component=component,
            props=props or {},
            children=children or {}
        }
    end

    function Roact.createBinding(initialValue)
        local value=initialValue
        local listeners={}
        return {
            getValue=function()
                return value
            end,
            setValue=function(newValue)
                value=newValue
                for _,listener in ipairs(listeners) do
                    listener(value)
                end
            end,
            map=function(transform)
                local binding=Roact.createBinding(transform(value))
                local originalSetValue=binding.setValue
                binding.setValue=function(newValue)
                    value=newValue
                    originalSetValue(transform(newValue))
                end
                return binding
            end
        }
    end

    function Roact.mount(element,parent,key)
        local gui=Instance.new("ScreenGui")
        gui.Name=key or "RoactUI"
        gui.Parent=parent
        gui.ResetOnSpawn=false
        
        local function renderElement(element,parent)
            if type(element.component)=="string" then
                local instance=Instance.new(element.component)
                instance.Parent=parent
                for prop,value in pairs(element.props) do
                    if prop:sub(1,1)~="_" then
                        instance[prop]=value
                    end
                end
                for _,child in pairs(element.children) do
                    renderElement(child,instance)
                end
                return instance
            elseif type(element.component)=="table" then
                local componentInstance=element.component.new(element.props)
                local rendered=componentInstance:render()
                if rendered then
                    renderElement(rendered,parent)
                end
                return componentInstance
            end
        end
        
        renderElement(element,gui)
        return gui
    end

    function Roact.unmount(handle)
        if handle then
            handle:Destroy()
        end
    end

    Roact.Component=Component
end

-- === Simple Hooks Implementation ===
local Hooks={}
function Hooks.hooked(render)
    return function(props)
        local state={}
        local function setState(newState)
            for k,v in pairs(newState) do
                state[k]=v
            end
        end
        local function useState(initialValue)
            local key=tostring(#state+1)
            if state[key]==nil then
                state[key]=initialValue
            end
            return state[key],function(newValue)
                state[key]=newValue
            end
        end
        local function useEffect(callback,deps)
            callback()
        end
        local function useMemo(callback,deps)
            return callback()
        end
        local function useCallback(callback,deps)
            return callback
        end
        local function useRef(initialValue)
            return {current=initialValue}
        end
        local function useContext(context)
            return context
        end
        local function useBinding(initialValue)
            return Roact.createBinding(initialValue)
        end
        local hooks={
            useState=useState,
            useEffect=useEffect,
            useMemo=useMemo,
            useCallback=useCallback,
            useRef=useRef,
            useContext=useContext,
            useBinding=useBinding
        }
        return render(setmetatable(props,{__index=function(_,k)
            if hooks[k] then return hooks[k] end
            return props[k]
        end}))
    end
end

-- === Simple Rodux Implementation ===
local Rodux={}
do
    local Store={}
    Store.__index=Store
    function Store.new(reducer,initialState)
        local self=setmetatable({
            _reducer=reducer,
            _state=initialState or {},
            _listeners={}
        },Store)
        return self
    end
    function Store:getState()
        return self._state
    end
    function Store:dispatch(action)
        self._state=self._reducer(self._state,action)
        for _,listener in ipairs(self._listeners) do
            listener(self._state)
        end
    end
    function Store:subscribe(listener)
        table.insert(self._listeners,listener)
        return function()
            for i,v in ipairs(self._listeners) do
                if v==listener then
                    table.remove(self._listeners,i)
                    break
                end
            end
        end
    end

    Rodux.Store=Store
end

-- === Simple Rodux Hooks ===
local RoduxHooks={}
do
    local currentStore=nil
    function RoduxHooks.Provider(props)
        currentStore=props.store
        return props.children
    end
    function RoduxHooks.useSelector(selector)
        if currentStore then
            return selector(currentStore:getState())
        end
        return nil
    end
    function RoduxHooks.useDispatch()
        if currentStore then
            return function(action)
                currentStore:dispatch(action)
            end
        end
        return function() end
    end
end

-- === Orca Store ===
local OrcaStore={}
function OrcaStore.create()
    local initialState={
        ui={
            visible=true,
            minimized=false
        },
        features={
            movement={
                walkSpeedEnabled=false,
                walkSpeed=16,
                jumpHeightEnabled=false,
                jumpHeight=50,
                flyEnabled=false,
                flySpeed=50
            },
            visuals={
                espEnabled=false,
                fullBrightEnabled=false,
                timeOfDay=12
            }
        }
    }
    
    local function reducer(state,action)
        if state==nil then
            state=initialState
        end
        
        if action.type=="SET_UI_VISIBLE" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.ui={}
            for k,v in pairs(state.ui) do newState.ui[k]=v end
            newState.ui.visible=action.visible
            return newState
        elseif action.type=="SET_UI_MINIMIZED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.ui={}
            for k,v in pairs(state.ui) do newState.ui[k]=v end
            newState.ui.minimized=action.minimized
            return newState
        elseif action.type=="SET_WALK_SPEED_ENABLED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.walkSpeedEnabled=action.enabled
            return newState
        elseif action.type=="SET_WALK_SPEED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.walkSpeed=action.speed
            return newState
        elseif action.type=="SET_JUMP_HEIGHT_ENABLED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.jumpHeightEnabled=action.enabled
            return newState
        elseif action.type=="SET_JUMP_HEIGHT" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.jumpHeight=action.height
            return newState
        elseif action.type=="SET_FLY_ENABLED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.flyEnabled=action.enabled
            return newState
        elseif action.type=="SET_FLY_SPEED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.movement={}
            for k,v in pairs(state.features.movement) do newState.features.movement[k]=v end
            newState.features.movement.flySpeed=action.speed
            return newState
        elseif action.type=="SET_ESP_ENABLED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.visuals={}
            for k,v in pairs(state.features.visuals) do newState.features.visuals[k]=v end
            newState.features.visuals.espEnabled=action.enabled
            return newState
        elseif action.type=="SET_FULLBRIGHT_ENABLED" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.visuals={}
            for k,v in pairs(state.features.visuals) do newState.features.visuals[k]=v end
            newState.features.visuals.fullBrightEnabled=action.enabled
            return newState
        elseif action.type=="SET_TIME_OF_DAY" then
            local newState={}
            for k,v in pairs(state) do newState[k]=v end
            newState.features={}
            for k,v in pairs(state.features) do newState.features[k]=v end
            newState.features.visuals={}
            for k,v in pairs(state.features.visuals) do newState.features.visuals[k]=v end
            newState.features.visuals.timeOfDay=action.time
            return newState
        end
        
        return state
    end
    
    return Rodux.Store.new(reducer,initialState)
end

-- === Orca Jobs (Flight) ===
local OrcaJobs={}
function OrcaJobs.character()
    local character={}
    
    function character.flight()
        local flying=false
        local bodyVelocity
        local bodyGyro
        local char=LocalPlayer.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        
        local motor=Flipper.GroupMotor.new({0,0,0},false)
        local targetVelocity=Vector3.new(0,0,0)
        local flySpeed=50
        
        local function updateVelocity()
            if not flying then return end
            local camera=workspace.CurrentCamera
            local moveDir=Vector3.new(0,0,0)
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir=moveDir+camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir=moveDir-camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir=moveDir-camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir=moveDir+camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir=moveDir+Vector3.new(0,1,0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                moveDir=moveDir-Vector3.new(0,1,0)
            end
            
            if moveDir.Magnitude>0 then
                moveDir=moveDir.Unit*flySpeed
            end
            
            targetVelocity=moveDir
        end
        
        RunService.RenderStepped:Connect(function()
            if flying then
                updateVelocity()
                motor:setGoal({
                    Flipper.Spring.new(targetVelocity.X),
                    Flipper.Spring.new(targetVelocity.Y),
                    Flipper.Spring.new(targetVelocity.Z)
                })
            end
        end)
        
        RunService.Heartbeat:Connect(function(dt)
            if flying then
                motor:step(dt)
                local val=motor:getValue()
                bodyVelocity.Velocity=Vector3.new(val[1],val[2],val[3])
            end
        end)
        
        return {
            start=function()
                if flying then return end
                char=LocalPlayer.Character
                root=char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                flying=true
                bodyVelocity=Instance.new("BodyVelocity")
                bodyVelocity.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                bodyVelocity.Velocity=Vector3.new(0,0,0)
                bodyVelocity.Parent=root
                
                bodyGyro=Instance.new("BodyGyro")
                bodyGyro.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
                bodyGyro.CFrame=root.CFrame
                bodyGyro.Parent=root
            end,
            stop=function()
                if not flying then return end
                flying=false
                
                if bodyVelocity then
                    bodyVelocity:Destroy()
                    bodyVelocity=nil
                end
                if bodyGyro then
                    bodyGyro:Destroy()
                    bodyGyro=nil
                end
            end,
            setSpeed=function(speed)
                flySpeed=speed
            end,
            isFlying=function()
                return flying
            end
        }
    end
    
    return character
end

-- === Orca UI Components ===
local OrcaUI={}
do
    function OrcaUI.Button(props)
        return Roact.createElement("TextButton",{
            Size=props.Size or UDim2.new(1,0,0,40),
            Position=props.Position,
            BackgroundColor3=props.BackgroundColor3 or Color3.fromRGB(30,30,35),
            BackgroundTransparency=props.BackgroundTransparency or 0,
            BorderSizePixel=0,
            Text=props.Text or "",
            TextColor3=props.TextColor3 or Color3.fromRGB(255,255,255),
            TextSize=props.TextSize or 14,
            Font=props.Font or Enum.Font.Gotham,
            [Roact.Event.MouseButton1Click]=props.OnClick
        })
    end

    function OrcaUI.Toggle(props)
        local binding,updateBinding=Roact.createBinding(props.default or false)
        
        return Roact.createElement("Frame",{
            Size=props.Size or UDim2.new(1,0,0,30),
            BackgroundTransparency=1
        },{
            Label=Roact.createElement("TextLabel",{
                Size=UDim2.new(0.7,0,1,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Text=props.Label or "",
                TextColor3=Color3.fromRGB(255,255,255),
                TextSize=14,
                Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left
            }),
            Toggle=Roact.createElement("TextButton",{
                Size=UDim2.new(0,40,0,20),
                Position=UDim2.new(1,-45,0.5,-10),
                BackgroundColor3=Color3.fromRGB(60,60,70),
                BorderSizePixel=0,
                Text="",
                [Roact.Event.MouseButton1Click]=function()
                    local current=binding:getValue()
                    local newEnabled=not current
                    updateBinding(newEnabled)
                    if props.OnChange then
                        props.OnChange(newEnabled)
                    end
                end
            })
        })
    end

    function OrcaUI.Slider(props)
        local binding,updateBinding=Roact.createBinding(props.default or 50)
        
        return Roact.createElement("Frame",{
            Size=props.Size or UDim2.new(1,0,0,40),
            BackgroundTransparency=1
        },{
            Label=Roact.createElement("TextLabel",{
                Size=UDim2.new(0.7,0,0.5,0),
                Position=UDim2.new(0,0,0,0),
                BackgroundTransparency=1,
                Text=props.Label or "",
                TextColor3=Color3.fromRGB(255,255,255),
                TextSize=14,
                Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Left
            }),
            Value=Roact.createElement("TextLabel",{
                Size=UDim2.new(0.3,0,0.5,0),
                Position=UDim2.new(0.7,0,0,0),
                BackgroundTransparency=1,
                Text=tostring(math.floor(binding:getValue()))..(props.Suffix or ""),
                TextColor3=Color3.fromRGB(200,200,200),
                TextSize=14,
                Font=Enum.Font.Gotham,
                TextXAlignment=Enum.TextXAlignment.Right
            }),
            Slider=Roact.createElement("TextButton",{
                Size=UDim2.new(1,0,0,10),
                Position=UDim2.new(0,0,0.5,5),
                BackgroundColor3=Color3.fromRGB(60,60,70),
                BorderSizePixel=0,
                Text="",
                [Roact.Event.MouseButton1Click]=function()
                    local slider=script.Parent
                    local value=props.Min+(props.Max-props.Min)*0.5
                    updateBinding(value)
                    if props.OnChange then
                        props.OnChange(value)
                    end
                end
            })
        })
    end

    function OrcaUI.Section(props)
        local children={}
        for i,child in ipairs(props.children) do
            children[i]=child
        end
        
        return Roact.createElement("Frame",{
            Size=UDim2.new(1,0,0,props.height or 200),
            BackgroundColor3=Color3.fromRGB(25,25,30),
            BorderSizePixel=0,
            LayoutOrder=props.LayoutOrder
        },{
            Header=Roact.createElement("TextLabel",{
                Size=UDim2.new(1,0,0,30),
                BackgroundColor3=Color3.fromRGB(35,35,40),
                BorderSizePixel=0,
                Text=props.Title or "",
                TextColor3=Color3.fromRGB(255,255,255),
                TextSize=16,
                Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left
            }),
            Content=Roact.createElement("Frame",{
                Size=UDim2.new(1,0,1,-30),
                Position=UDim2.new(0,0,0,30),
                BackgroundTransparency=1,
                BorderSizePixel=0
            },children)
        })
    end

    function OrcaUI.App(props)
        local store=props.store
        local uiVisible=RoduxHooks.useSelector(function(state)
            return state.ui.visible
        end)
        
        return Roact.createElement("ScreenGui",{
            IgnoreGuiInset=true,
            ResetOnSpawn=false,
            ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
            Enabled=uiVisible
        },{
            Main=Roact.createElement("Frame",{
                Size=UDim2.new(0,500,0,600),
                Position=UDim2.new(0.5,-250,0.5,-300),
                BackgroundColor3=Color3.fromRGB(20,20,25),
                BorderSizePixel=0
            },{
                Header=Roact.createElement("Frame",{
                    Size=UDim2.new(1,0,0,40),
                    BackgroundColor3=Color3.fromRGB(30,30,35),
                    BorderSizePixel=0
                },{
                    Title=Roact.createElement("TextLabel",{
                        Size=UDim2.new(1,-40,1,0),
                        Position=UDim2.new(0,0,0,0),
                        BackgroundTransparency=1,
                        Text="Orca",
                        TextColor3=Color3.fromRGB(255,255,255),
                        TextSize=18,
                        Font=Enum.Font.GothamBold,
                        TextXAlignment=Enum.TextXAlignment.Left
                    }),
                    Close=Roact.createElement("TextButton",{
                        Size=UDim2.new(0,40,1,0),
                        Position=UDim2.new(1,-40,0,0),
                        BackgroundTransparency=1,
                        Text="✕",
                        TextColor3=Color3.fromRGB(255,100,100),
                        TextSize=20,
                        Font=Enum.Font.GothamBold,
                        [Roact.Event.MouseButton1Click]=function()
                            store:dispatch({
                                type="SET_UI_VISIBLE",
                                visible=false
                            })
                        end
                    })
                }),
                Content=Roact.createElement("Frame",{
                    Size=UDim2.new(1,0,1,-40),
                    Position=UDim2.new(0,0,0,40),
                    BackgroundTransparency=1,
                    BorderSizePixel=0
                },props.children)
            })
        })
    end
end

-- === Main Application ===
local store=OrcaStore.create()

local characterJobs=OrcaJobs.character()
local flightJob=characterJobs.flight()

local function handleMovementChanges()
    local state=store:getState()
    local movement=state.features.movement
    local char=LocalPlayer.Character
    local humanoid=char and char:FindFirstChild("Humanoid")
    
    if humanoid then
        if movement.walkSpeedEnabled then
            humanoid.WalkSpeed=movement.walkSpeed
        else
            humanoid.WalkSpeed=16
        end
    end
    
    if humanoid then
        if movement.jumpHeightEnabled then
            humanoid.JumpPower=movement.jumpHeight
        else
            humanoid.JumpPower=50
        end
    end
    
    if movement.flyEnabled then
        flightJob.start()
        flightJob.setSpeed(movement.flySpeed)
    else
        flightJob.stop()
    end
end

local function handleVisualChanges()
    local state=store:getState()
    local visuals=state.features.visuals
    local lighting=game:GetService("Lighting")
    
    if visuals.fullBrightEnabled then
        lighting.Brightness=2
        lighting.Ambient=Color3.fromRGB(1,1,1)
    else
        lighting.Brightness=1
        lighting.Ambient=Color3.fromRGB(0,0,0)
    end
    
    local hours=math.floor(visuals.timeOfDay)
    local minutes=(visuals.timeOfDay-hours)*60
    lighting.TimeOfDay=string.format("%02d:%02d:00",hours,minutes)
end

store:subscribe(function()
    handleMovementChanges()
    handleVisualChanges()
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    handleMovementChanges()
end)

UserInputService.InputBegan:Connect(function(input,gameProcessed)
    if gameProcessed then return end
    if input.KeyCode==Enum.KeyCode.RightControl then
        local state=store:getState()
        store:dispatch({
            type="SET_UI_VISIBLE",
            visible=not state.ui.visible
        })
    end
end)

local MonarchApp=Hooks.hooked(function(props)
    local store=props.store
    local dispatch=RoduxHooks.useDispatch()
    
    local movement=RoduxHooks.useSelector(function(state)
        return state.features.movement
    end)
    
    local visuals=RoduxHooks.useSelector(function(state)
        return state.features.visuals
    end)
    
    return Roact.createElement(OrcaUI.App,{
        store=store
    },{
        MovementSection=Roact.createElement(OrcaUI.Section,{
            Title="Movement",
            height=300,
            LayoutOrder=1
        },{
            WalkSpeedToggle=Roact.createElement(OrcaUI.Toggle,{
                Label="Walk Speed",
                default=movement.walkSpeedEnabled,
                OnChange=function(enabled)
                    dispatch({
                        type="SET_WALK_SPEED_ENABLED",
                        enabled=enabled
                    })
                end
            }),
            WalkSpeedSlider=Roact.createElement(OrcaUI.Slider,{
                Label="Speed",
                Min=16,
                Max=250,
                Default=movement.walkSpeed,
                Suffix="",
                OnChange=function(value)
                    dispatch({
                        type="SET_WALK_SPEED",
                        speed=value
                    })
                end
            }),
            JumpHeightToggle=Roact.createElement(OrcaUI.Toggle,{
                Label="Jump Height",
                default=movement.jumpHeightEnabled,
                OnChange=function(enabled)
                    dispatch({
                        type="SET_JUMP_HEIGHT_ENABLED",
                        enabled=enabled
                    })
                end
            }),
            JumpHeightSlider=Roact.createElement(OrcaUI.Slider,{
                Label="Height",
                Min=7,
                Max=500,
                Default=movement.jumpHeight,
                Suffix="",
                OnChange=function(value)
                    dispatch({
                        type="SET_JUMP_HEIGHT",
                        height=value
                    })
                end
            }),
            FlyToggle=Roact.createElement(OrcaUI.Toggle,{
                Label="Fly",
                default=movement.flyEnabled,
                OnChange=function(enabled)
                    dispatch({
                        type="SET_FLY_ENABLED",
                        enabled=enabled
                    })
                end
            }),
            FlySpeedSlider=Roact.createElement(OrcaUI.Slider,{
                Label="Fly Speed",
                Min=10,
                Max=300,
                Default=movement.flySpeed,
                Suffix="",
                OnChange=function(value)
                    dispatch({
                        type="SET_FLY_SPEED",
                        speed=value
                    })
                end
            })
        }),
        VisualsSection=Roact.createElement(OrcaUI.Section,{
            Title="Visuals",
            height=250,
            LayoutOrder=2
        },{
            FullBrightToggle=Roact.createElement(OrcaUI.Toggle,{
                Label="Full Bright",
                default=visuals.fullBrightEnabled,
                OnChange=function(enabled)
                    dispatch({
                        type="SET_FULLBRIGHT_ENABLED",
                        enabled=enabled
                    })
                end
            }),
            TimeOfDaySlider=Roact.createElement(OrcaUI.Slider,{
                Label="Time of Day",
                Min=0,
                Max=24,
                Default=visuals.timeOfDay,
                Suffix="h",
                OnChange=function(value)
                    dispatch({
                        type="SET_TIME_OF_DAY",
                        time=value
                    })
                end
            })
        })
    })
end)

local element=Roact.createElement(RoduxHooks.Provider,{
    store=store
},{
    App=Roact.createElement(MonarchApp,{
        store=store
    })
})

local handle=Roact.mount(element,LocalPlayer.PlayerGui,"OrcaUI")

print("Orca loaded successfully!")
print("Press RightControl to toggle the UI")
