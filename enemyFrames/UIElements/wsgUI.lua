	-------------------------------------------------------------------------------
	local flagCarriers = {}
	local fcHealth = {}
	local sentAnnoucement, healthWarnings = false, {10, 40}
	local nextAnnouncement = 0
	-------------------------------------------------------------------------------
	local h = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
    h:SetFontObject(GameFontNormalSmall)
    h:SetTextColor(RGB_FACTION_COLORS[EF_L_ALLIANCE2]['r'], RGB_FACTION_COLORS[EF_L_ALLIANCE2]['g'], RGB_FACTION_COLORS[EF_L_ALLIANCE2]['b'])
    h:SetJustifyH'LEFT'
	h:SetText(EF_L_HORDE)
	
	local hb = CreateFrame('Button', nil, WorldStateAlwaysUpFrame)
    hb:SetFrameLevel(2)
    hb:SetAllPoints(h)
    hb:EnableMouse(true)
    
	
	local hh = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
    hh:SetFontObject(GameFontNormalSmall)
	--hh:SetTextColor(.59, .98, .59)
    hh:SetJustifyH'RIGHT'
    hh:SetPoint('LEFT', h, 'RIGHT', 5, 0)

	
    local a = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
    a:SetFontObject(GameFontNormalSmall)
	a:SetTextColor(RGB_FACTION_COLORS[EF_L_HORDE2]['r'], RGB_FACTION_COLORS[EF_L_HORDE2]['g'], RGB_FACTION_COLORS[EF_L_HORDE2]['b'])
    a:SetJustifyH'LEFT'
	a:SetText(EF_L_ALLIANCE)
	
	local ab = CreateFrame('Button', nil, WorldStateAlwaysUpFrame)
    ab:SetFrameLevel(2)
    ab:SetAllPoints(a)
    ab:EnableMouse(true)
    
	
	local ah = WorldStateAlwaysUpFrame:CreateFontString(nil, 'OVERLAY')
    ah:SetFontObject(GameFontNormalSmall)
	--ah:SetTextColor(.59, .98, .59)
    ah:SetJustifyH'RIGHT'
    ah:SetPoint('LEFT', a, 'RIGHT', 5, 0)
	-------------------------------------------------------------------------------
	local OnEnter = function()
		local label = this == hb and h or a
		label:SetTextColor(.9, .9, .4)
		if label:GetText() ~= '' then
			GameTooltip:SetOwner(this, 'ANCHOR_TOPRIGHT', -40, 10)
			GameTooltip:SetText(EF_L_CLICKTOTARGET..label:GetText())
			GameTooltip:Show()
		end
	end
	local OnLeave = function()
		local label = this == hb and h or a
		local f = label == a and EF_L_HORDE2 or EF_L_ALLIANCE2
		label:SetTextColor(RGB_FACTION_COLORS[f]['r'], RGB_FACTION_COLORS[f]['g'], RGB_FACTION_COLORS[f]['b'])
		GameTooltip:Hide()
	end
	local target = function()
        local text = this == hb and h or a
        local t = text:GetText()
        TargetByName(t, true)
    end
	
	
	hb:SetScript('OnClick', target)
	hb:SetScript('OnEnter', OnEnter)
	hb:SetScript('OnLeave', OnLeave)
	
	ab:SetScript('OnClick', target)
	ab:SetScript('OnEnter', OnEnter)
	ab:SetScript('OnLeave', OnLeave)
	-------------------------------------------------------------------------------
	WSGUIupdateFC = function(fc)
		flagCarriers = fc
		
		if flagCarriers[EF_L_ALLIANCE2] then
			a:SetText(flagCarriers[EF_L_ALLIANCE2])
		else
			a:SetText('')
			ah:SetText('')
			fcHealth[EF_L_ALLIANCE2] = nil
		end
		
		if flagCarriers[EF_L_HORDE2] then
			h:SetText(flagCarriers[EF_L_HORDE2])
		else
			h:SetText('')
			hh:SetText('')
			fcHealth[EF_L_HORDE2] = nil
		end
	end
	-------------------------------------------------------------------------------
	local w = 100
	local efcLowHealth = function()
		local f = UnitFactionGroup'player'
		local x = UnitFactionGroup'player' == EF_L_ALLIANCE2 and EF_L_HORDE2 or EF_L_ALLIANCE2

		local now = GetTime()
		if flagCarriers[f] and fcHealth[f]  then
			for i = 1, tlength(healthWarnings) do
				if fcHealth[f] < healthWarnings[i]  then
					if (not sentAnnoucement or healthWarnings[i] < w) and now > nextAnnouncement then
						nextAnnouncement = now + 2
						w = healthWarnings[i]
						--print('EFC has less than '..healthWarnings[i]..'%! Get ready to cap!')
						local msgb = flagCarriers[x] and EF_L_GETREADYTOCAP or ''
						SendChatMessage(EF_L_EFCHASLESSTHAN..healthWarnings[i]..EF_L_PERCHEALTH.. msgb, 'BATTLEGROUND')
						sentAnnoucement = true
					end
					return
				end
			end
		end
		sentAnnoucement = false
	end
	-------------------------------------------------------------------------------
	local function round(num, idp)
		local mult = 10^(idp or 0)
		return math.floor(num * mult + 0.5) / mult
	end
	local getPerc = function(unit)
		return round(((UnitHealth(unit) * 100) / UnitHealthMax(unit)), 1)
	end
	-------------------------------------------------------------------------------
	WSGUIupdateFChealth = function(unit)
		if unit then
			if UnitName(unit) == flagCarriers[EF_L_ALLIANCE2] then
				fcHealth[EF_L_ALLIANCE2] = getPerc(unit)
				ah:SetText(fcHealth[EF_L_ALLIANCE2]..'%')
			end
			if UnitName(unit) == flagCarriers[EF_L_HORDE2] then
				fcHealth[EF_L_HORDE2] = getPerc(unit)
				hh:SetText(fcHealth[EF_L_HORDE2]..'%')
			end
		end
		
		if ENEMYFRAMESPLAYERDATA['efcBGannouncement'] then
			efcLowHealth()
		end
	end
	-------------------------------------------------------------------------------
	WSGUIinit = function(insideBG)
		if insideBG then
			local hdb = _G['AlwaysUpFrame1DynamicIconButton']
			h:SetPoint('LEFT', hdb, 'RIGHT', 4, 2)
			h:Show()
			h:SetText('')
			hh:Show()		
			hh:SetText('')
			
			local adb = _G['AlwaysUpFrame2DynamicIconButton']
			a:SetPoint('LEFT', adb, 'RIGHT', 4, 2)
			a:Show()
			a:SetText('')			
			ah:Show()
			ah:SetText('')
		else
			h:Hide()
			hh:Hide()
			a:Hide()
			ah:Hide()
			flagCarriers = {}
		end
	end
	-------------------------------------------------------------------------------