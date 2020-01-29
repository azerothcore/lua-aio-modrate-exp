--[[ 

    MOD_EXP REQUIREMENT

]]--
    local m_config = {
        elunaDB = 'ac_eluna',
        creatureEntry = 197;
    };
    local m_exp = {};


--[[ 

    AIO REQUIREMENT

]]--
    local AIO = AIO or require("AIO");
    local h_expmodifier = AIO.AddHandlers("h_expmodifier", {})



    --[[ 

    setRateModifier
    Function for create a link Addon -> Server

    ]]--
        function h_expmodifier.getRateModifier(msg, player)
            local pGuid = player:GetGUIDLow()
            if not(m_exp[pGuid])then
                m_exp[pGuid] = {
                    mod_exp = 1;
                }
            end

            return msg:Add("h_expmodifier", "setMyRate", m_exp[pGuid].mod_exp);
        end
        AIO.AddOnInit(h_expmodifier.getRateModifier)

        function h_expmodifier.update(player)
            h_expmodifier.getRateModifier(AIO.Msg(), player):Send(player);
        end
--[[



]]--
function m_exp.onConnect(event, player)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid])then
        m_exp[pGuid] = {
            mod_exp = 1;
        }
    end
    local GetRateExp = CharDBQuery('SELECT mod_exp FROM '..m_config.elunaDB..'.characters_exp_rates WHERE guid = '..pGuid..';')
    if GetRateExp ~= nil then
        m_exp[pGuid].mod_exp = GetRateExp:GetUInt32(0)
    else
        local AddRateExp = CharDBQuery('INSERT INTO '..m_config.elunaDB..'.characters_exp_rates (guid, mod_exp) VALUES ('..pGuid..', 1);')
        m_exp[pGuid].mod_exp = 1
    end
    h_expmodifier.update(player)
end
RegisterPlayerEvent(3, m_exp.onConnect)


--[[

    

]]--
function m_exp.onDisconnect(event, player)
	local pGuid = player:GetGUIDLow()
	if not(m_exp[pGuid])then
		m_exp[pGuid] = {
			mod_exp = 1;
		}
	end
	local SaveRateExp = CharDBQuery('UPDATE '..m_config.elunaDB..'.characters_exp_rates SET mod_exp = '..m_exp[pGuid].mod_exp..' WHERE guid = '..pGuid..';')
end
RegisterPlayerEvent(4, m_exp.onDisconnect)


--[[

    

]]--
function m_exp.onReceiveExp(event, player, amount, victim)
	local pGuid = player:GetGUIDLow()
	if not(m_exp[pGuid])then
		m_exp[pGuid] = {
			mod_exp = 1;
		}
	end

	return amount * m_exp[pGuid].mod_exp
end
RegisterPlayerEvent(12, m_exp.onReceiveExp)


--[[

    

]]--
function m_exp.getAllPlayerExp(event)
	for i, player in ipairs(GetPlayersInWorld()) do
		m_exp.onConnect(event, player)
	end
end
RegisterServerEvent(33, m_exp.getAllPlayerExp)


--[[

    

]]--
function m_exp.saveAllPlayerExp(event)
	for i, player in ipairs(GetPlayersInWorld()) do
		m_exp.onDisconnect(event, player)
	end
end
RegisterServerEvent(16, m_exp.saveAllPlayerExp)


--[[ 

    setRateModifier
    Function for create a link Addon -> Server

]]--
function h_expmodifier.setRateModifier(player, modifier)
    local pGuid = player:GetGUIDLow()
    if not(m_exp[pGuid])then
		m_exp[pGuid] = {
			mod_exp = 1;
		}
    end
    
    m_exp[pGuid].mod_exp = modifier;
    player:SendNotification('Your experience mutliplicator is now at '..m_exp[pGuid].mod_exp..'!')

    h_expmodifier.update(player, _)
end


function m_exp.onGossipHello(event, player, object)
    player:GossipMenuAddItem(0, "I come here for a certain... service...", 1, 998);
    player:GossipMenuAddItem(0, "No, i've changed my mind...", 1, 999);
    player:GossipSendMenu(1, object)
end
RegisterCreatureGossipEvent(m_config.creatureEntry, 1, m_exp.onGossipHello);

function m_exp.onGossipSelect(event, player, object, sender, intid, code, menuid)
    if(intid == 998)then
        AIO.Handle(player, "h_expmodifier", "ShowFrame")
        player:GossipComplete()
    elseif(intid == 999)then
        player:GossipComplete()
    end
end
RegisterCreatureGossipEvent(m_config.creatureEntry, 2, m_exp.onGossipSelect);
