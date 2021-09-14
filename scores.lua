
--when creating a class
local  scores = {}


 scores.json             = require("json")
 scores.pfClient         = require("plugin.playfab.client")
 scores.doLogin          = false
 scores.getRemoteOK      = nil
 scores.getRemoteFail    = nil
 scores.updateRemoteOK   = nil
 scores.updateRemoteFail = nil
 scores.lastScore        = 0
 scores.scoresTable = {}
 --api wrapper for underlying resources
 scores.filePath                          = system.pathForFile("scores.json",system.DocumentsDirectory)
 scores.PlayFabClientApi                  = scores.pfClient.PlayFabClientApi
 scores.PlayFabClientApi.settings.titleId = "4F8B4"

function scores:setGetRemoteOK(cb)
 scores.getRemoteOK = cb
end

function scores:setGetRemoteFail(cb)
 scores.getRemoteFail = cb
end

function scores:setUpdateRemoteOK(cb)
 scores.updateRemoteOK = cb
end

function scores:setUpdateRemoteFail(cb)
 scores.updateRemoteFail = cb
end

function scores:updateLocal(score)
   scores.loadLocal()
   table.insert( scores.scoresTable, score )
   scores.saveLocal()
end

function scores:updateRemote(score)


local function errorHandler(error)
	if scores.updateRemoteFail
	 then 
	 scores.doLogin = false
     scores.updateRemoteFail(error)
    end
end
local function succesHandler(sc)
   if scores.updateRemoteOK
   	then
       scores.updateRemoteOK(sc)
   	end

end

local function succesLoginHandler(result)
	print("Login Successful: " .. result.PlayFabId)
    scores.updateRemote(scores.lastScore)
end

if(scores.doLogin == false)
	then
	  scores.lastScore = score
	  scores.doLogin   = true

      local loginRequest = 
       {
        -- https://api.playfab.com/Documentation/Client/method/LoginWithCustomID
        CustomId      = system.getInfo("deviceID"),
        CreateAccount = true
       }

           scores.PlayFabClientApi.LoginWithCustomID(loginRequest,function(result) succesLoginHandler(result) end, 
                                                                  function(error) errorHandler(error) end)
      return
     end

    scores.doLogin   = false
    score            = scores.lastScore
    scores.lastScore = 0

    local request = 
       {
        Statistics =
         {
           { StatisticName = "HighScore", Value = score }
         }
       }

  scores.PlayFabClientApi.UpdatePlayerStatistics(request, function(result) succesHandler(score) end,
                                                          function(error) errorHandler(error) end)
end


function scores:loadLocal()
   
   local file = io.open( scores.filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scores.scoresTable = scores.json.decode( contents )
    end
 
    if ( scores.scoresTable == nil or #scores.scoresTable == 0 ) then
        scores.scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end


function scores:loadRemote()

local function errorHandler(error)
	print("Login Failed: " .. error.errorMessage) 
	if (scores.getRemoteFail) 
	 then scores.doLogin = false 
	  scores.getRemoteFail(error) 
     end
end

if(scores.doLogin == false)
	then
	  scores.doLogin = true
      local loginRequest = 
       {
        -- https://api.playfab.com/Documentation/Client/method/LoginWithCustomID
        CustomId      = system.getInfo("deviceID"),
        CreateAccount = true
       }

           scores.PlayFabClientApi.LoginWithCustomID(loginRequest,function(result) print("Login Successful: " .. result.PlayFabId) scores.loadRemote() end, 
                                                                  function(error) errorHandler(error) end)
      return
     end

    scores.doLogin = false

 scores.scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

 local request = 
            {
                StatisticName   = "HighScore",
                StartPosition   = 0,
                MaxResultsCount = 10
            }

   local function successFunction(result)

       -- print("Leaderboard pulled")

        local rows = #result.Leaderboard

        for i = 1, rows, 1 
          do
            local res = result.Leaderboard[i]
            table.insert(scores.scoresTable,res.StatValue)
        end

       local function compare( a, b )
        return a > b
       end

       table.sort( scores.scoresTable, compare )
    
       for i = #scores.scoresTable, 11, -1 do
        table.remove( scores.scoresTable, i )
       end


        if (scores.getRemoteOK)
        	 then
                scores.getRemoteOK()
        	 end
    end

    local function errorHandler(err)
    	if (scores.getRemoteFail)
    	 then scores.getRemoteFail(err)
        end 
    end

    scores.PlayFabClientApi.GetLeaderboard(request, successFunction,
                                                    function(err) errorHandler(err) end)
   
end

function scores:getLocal()
   
    return scores.scoresTable

end

function scores:saveLocal()
   
    local function compare( a, b )
        return a > b
    end

	table.sort( scores.scoresTable, compare )
	
   for i = #scores.scoresTable, 11, -1 do
        table.remove( scores.scoresTable, i )
    end
 
    local file = io.open( scores.filePath, "w" )
 
    if file then
        file:write( scores.json.encode( scores.scoresTable ) )
        io.close( file )
    end
    
end

function scores:getRemote()
    return scores.scoresTable
end

return scores