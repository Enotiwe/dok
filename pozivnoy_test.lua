-- Информация о скрипте
script_name('«Auto-Doklad»') 		                    -- Указываем имя скрипта
script_version(0.1) 						                    -- Указываем версию скрипта / FINAL
script_author('Henrich_Rogge', 'Marshall_Milford', 'Andy_Fawkess') 	-- Указываем имя автора

-- Библиотеки
require 'lib.moonloader'
require 'lib.sampfuncs'

-- Позывные
local nicks = { 
  ['Wurn_Linkol'] = 'Даркхолм',
  ['Kirill_Magomedov'] = 'Мага',
  ['Euro_Dancmenove'] = 'Вампи',
  ['Jey_Apps'] = 'Яблоко',
  ['Marshall_Milford'] = 'Хребет',
  ['Antodoro_Navarrete'] = 'Тунан',
  ['Sonny_Royals'] = 'Пума',
  ['Jo_Bax'] = 'Бакс',
  ['Roze_Deadinside'] = 'Демон',
  ['Till_Cunningham'] = 'Мур',
  ['Rausanary_Royals'] = 'Сокол',
  ['Kennedy_Randall'] = 'Зеро',
  ['Jimmy_Roosevelt'] = 'Беркут',
  ['Tony_Kartez'] = 'Мент',
  ['Yuito_Navarrete'] = 'Арбуз',
  ['Adrian_Roberts'] = 'Алёна',
  ['Jason_Bianchii'] = 'Лось',
  ['Andy_Fawkess'] = 'Енот',
  ['Sofia_Murphy'] = 'Смурф',
  ['Henrich_Rogge'] = 'Рожок',
  ['Max_Meow'] = 'Кот',
  ['Sofa_Meow'] = 'Киса',
  ['Rewazzo_Rose'] = 'Кабан',
  ['Hermanni_Virtanen'] = 'Финн',
  ['Tyler_Lance'] = 'Пиво',
  ['Paulz_Xzoom'] = 'Икс',
  ['Vlad_Werber'] = 'Окунь',
  ['Reymond_Holiday'] = 'Холи',
  ['Yukio_Matsui'] = 'Джусай'
}

function main()
  -- Проверка на автозагрузку.
  -- Проверяем загружен ли sampfuncs и SAMP если не загружены - возвращаемся к началу
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  -- Проверяем загружен ли SA-MP
	while not isSampAvailable() do wait(100) end
	autoupdate("https://github.com/Enotiwe/dok/blob/main/-version.json", '['..string.upper(thisScript().name)..']: ', "https://github.com/Enotiwe/dok/blob/main/-version.json")
  -- Сообщаем об загрузке скрипта
  stext('Скрипт успешно загружен!')
  -- Регистрируем команду
  sampRegisterChatCommand('dok', cmd_dok)
  -- Проверяем зашёл ли игрок на сервер
	while not sampIsLocalPlayerSpawned() do wait(0) end
  -- Бесконечный цикл для постоянной работы скрипта
  while true do
    wait(0)
  end
end

function cmd_dok(args)
  local info = {}
  if isCharInAnyCar(PLAYER_PED) then
    if #args ~= 0 then
      local mycar = storeCarCharIsInNoSave(PLAYER_PED)
      for i = 0, 999 do
        if sampIsPlayerConnected(i) then
          local ichar = select(2, sampGetCharHandleBySampPlayerId(i))
          if doesCharExist(ichar) then
            if isCharInAnyCar(ichar) then
              local icar = storeCarCharIsInNoSave(ichar)
              if mycar == icar then
                local nicktoid = sampGetPlayerNickname(i)
                if nicks[nicktoid] ~= nil then
                  local call = nicks[nicktoid]
                  table.insert(info, call)
                else
                  local nick = string.gsub(sampGetPlayerNickname(i), "(%u+)%l+_(%w+)", "%1.%2")
                  table.insert(info, nick)
                end
              end
            end
          end
        end
      end
      if #info > 0 then
        sampSendChat(string.format('/r [СОБР]: 10-%s, %s.', args, table.concat(info,', ')))
      else
        sampSendChat(string.format('/r [СОБР]: 10-%s, solo.', args))
      end
    else
      atext('Введите: /dok [тен-код]')
      return
    end
  else
    atext('Вы не в автомобиле')
    return
  end
end

-- «Auto-Report» text
function stext(text)
  sampAddChatMessage((' %s {FFFFFF}%s'):format(script.this.name, text), 0xABAFDE)
end

-- » text
function atext(text)
	sampAddChatMessage((' » {FFFFFF}%s'):format(text), 0xABAFDE)
end

-- Сам автоапдейт.
function autoupdate(json_url, prefix, url)
  local dlstatus = require('moonloader').download_status
  local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
  if doesFileExist(json) then os.remove(json) end
  downloadUrlToFile(json_url, json,
    function(id, status, p1, p2)
      if status == dlstatus.STATUSEX_ENDDOWNLOAD then
        if doesFileExist(json) then
          local f = io.open(json, 'r')
          if f then
            local info = decodeJson(f:read('*a'))
            updatelink = info.updateurl
            updateversion = info.latest
            f:close()
            os.remove(json)
            if updateversion ~= thisScript().version then
              lua_thread.create(function(prefix)
                local dlstatus = require('moonloader').download_status
                local color = -1
                sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('Загружено %d из %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('Загрузка обновления завершена.')
                      sampAddChatMessage((prefix..'Обновление завершено!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': Обновление не требуется.')
            end
          end
        else
          print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end