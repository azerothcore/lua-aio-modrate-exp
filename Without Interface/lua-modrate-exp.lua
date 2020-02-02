local m_config = {
  
  --[[ 
  
      CONFIG | Max Rate Exp
        If you want your player up Exp Rate to 25 just set ... 25!
    
  ]]--
  maxExpRates = 5,
  
  elunaDB = 'ac_eluna',
  
  --[[ 
  
      CONFIG | Creature Entry
        Just your creature entry
  
  ]]--
  creatureEntry = 197,
  
  --[[ DON'T TOUCH THIS ]]--
    -- counter for display menu
    counter = 0,
};

--[[ DON'T TOUCH THIS ]]--
  function m_config.resetCounter()
    m_config.counter = 0;
  end
  
--[[ DON'T TOUCH THIS ]]--
  CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..m_config.elunaDB..'`;');
  CharDBQuery('CREATE TABLE IF NOT EXISTS `'..m_config.elunaDB..'`.`characters_exp_rates` (`guid` int(10) NOT NULL, `mod_exp` INT(2) NOT NULL DEFAULT 1, PRIMARY KEY (`guid`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;');

local m_exp = {};


--[[ Load player exp rates after connect ]]--
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
end
RegisterPlayerEvent(3, m_exp.onConnect)


--[[ Save player exp rates before disconnect ]]--
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


--[[ Add amount of experience multiply by Rate ]]--
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


--[[ Load All Players Exp Rates After Reloading ]]--
function m_exp.getAllPlayerExp(event)
	for i, player in ipairs(GetPlayersInWorld()) do
		m_exp.onConnect(event, player)
	end
end
RegisterServerEvent(33, m_exp.getAllPlayerExp)


--[[ Save All Players Exp Rates Before Reloading ]]--
function m_exp.saveAllPlayerExp(event)
	for i, player in ipairs(GetPlayersInWorld()) do
		m_exp.onDisconnect(event, player)
	end
end
RegisterServerEvent(16, m_exp.saveAllPlayerExp)



function m_exp.onGossipHello(event, player, object)
  repeat
    m_config.counter = m_config.counter +1;
    player:GossipMenuAddItem(0, "Set my Exp Rate to "..m_config.counter, 1, m_config.counter);
  until m_config.counter == m_config.maxExpRates;
  
  player:GossipMenuAddItem(0, "GoodBye", 1, 999);
  player:GossipSendMenu(1, object)
end
RegisterCreatureGossipEvent(m_config.creatureEntry, 1, m_exp.onGossipHello);



function m_exp.onGossipSelect(event, player, object, sender, intid, code, menuid)
  local pGuid = player:GetGUIDLow()
	if not(m_exp[pGuid])then
		m_exp[pGuid] = {
			mod_exp = 1;
		}
	end
  
  m_config.resetCounter()
  
  if (intid == 999)then
    player:GossipComplete();
    
  else
    m_exp[pGuid].mod_exp = intid;
		player:SendNotification('Your experience rate is now set to '..m_exp[pGuid].mod_exp..'!')
    m_exp.onGossipHello(event, player, object);
    
  end
end
RegisterCreatureGossipEvent(197, 2, m_exp.onGossipSelect);