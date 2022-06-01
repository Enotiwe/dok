-- ���������� � �������
script_name('�Auto-Doklad�') 		                    -- ��������� ��� �������
script_version(0.1) 						                    -- ��������� ������ ������� / FINAL
script_author('Henrich_Rogge', 'Marshall_Milford', 'Andy_Fawkess') 	-- ��������� ��� ������

-- ����������
require 'lib.moonloader'
require 'lib.sampfuncs'

-- ��������
local nicks = { 
  ['Wurn_Linkol'] = '��������',
  ['Kirill_Magomedov'] = '����',
  ['Euro_Dancmenove'] = '�����',
  ['Jey_Apps'] = '������',
  ['Marshall_Milford'] = '������',
  ['Antodoro_Navarrete'] = '�����',
  ['Sonny_Royals'] = '����',
  ['Jo_Bax'] = '����',
  ['Roze_Deadinside'] = '�����',
  ['Till_Cunningham'] = '���',
  ['Rausanary_Royals'] = '�����',
  ['Kennedy_Randall'] = '����',
  ['Jimmy_Roosevelt'] = '������',
  ['Tony_Kartez'] = '����',
  ['Yuito_Navarrete'] = '�����',
  ['Adrian_Roberts'] = '����',
  ['Jason_Bianchii'] = '����',
  ['Andy_Fawkess'] = '����',
  ['Sofia_Murphy'] = '�����',
  ['Henrich_Rogge'] = '�����',
  ['Max_Meow'] = '���',
  ['Sofa_Meow'] = '����',
  ['Rewazzo_Rose'] = '�����',
  ['Hermanni_Virtanen'] = '����',
  ['Tyler_Lance'] = '����',
  ['Paulz_Xzoom'] = '���',
  ['Vlad_Werber'] = '�����',
  ['Reymond_Holiday'] = '����',
  ['Yukio_Matsui'] = '������'
}

function main()
  -- �������� �� ������������.
  -- ��������� �������� �� sampfuncs � SAMP ���� �� ��������� - ������������ � ������
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
  -- ��������� �������� �� SA-MP
	while not isSampAvailable() do wait(100) end
	autoupdate("https://github.com/Enotiwe/dok/blob/main/-version.json", '['..string.upper(thisScript().name)..']: ', "https://github.com/Enotiwe/dok/blob/main/-version.json")
  -- �������� �� �������� �������
  stext('������ ������� ��������!')
  -- ������������ �������
  sampRegisterChatCommand('dok', cmd_dok)
  -- ��������� ����� �� ����� �� ������
	while not sampIsLocalPlayerSpawned() do wait(0) end
  -- ����������� ���� ��� ���������� ������ �������
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
        sampSendChat(string.format('/r [����]: 10-%s, %s.', args, table.concat(info,', ')))
      else
        sampSendChat(string.format('/r [����]: 10-%s, solo.', args))
      end
    else
      atext('�������: /dok [���-���]')
      return
    end
  else
    atext('�� �� � ����������')
    return
  end
end

-- �Auto-Report� text
function stext(text)
  sampAddChatMessage((' %s {FFFFFF}%s'):format(script.this.name, text), 0xABAFDE)
end

-- � text
function atext(text)
	sampAddChatMessage((' � {FFFFFF}%s'):format(text), 0xABAFDE)
end

-- ��� ����������.
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
                sampAddChatMessage((prefix..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion), color)
                wait(250)
                downloadUrlToFile(updatelink, thisScript().path,
                  function(id3, status1, p13, p23)
                    if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                      print(string.format('��������� %d �� %d.', p13, p23))
                    elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                      print('�������� ���������� ���������.')
                      sampAddChatMessage((prefix..'���������� ���������!'), color)
                      goupdatestatus = true
                      lua_thread.create(function() wait(500) thisScript():reload() end)
                    end
                    if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                      if goupdatestatus == nil then
                        sampAddChatMessage((prefix..'���������� ������ ��������. �������� ���������� ������..'), color)
                        update = false
                      end
                    end
                  end
                )
                end, prefix
              )
            else
              update = false
              print('v'..thisScript().version..': ���������� �� ���������.')
            end
          end
        else
          print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..url)
          update = false
        end
      end
    end
  )
  while update ~= false do wait(100) end
end