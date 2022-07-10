vkapi = require './vkapi.js'
http = require 'http'
fs = require 'fs'

# https://oauth.vk.com/authorize?client_id=6879470&scope=wall,offline&response_type=token
vk = vkapi process.env.VK_GROUP_STATS_TOKEN
params =
  group_id: +process.env.VK_GROUP_STATS_TARGET_GROUP_ID
  fields: 'sex'
statsId = -process.env.VK_GROUP_STATS_STATS_GROUP_ID
members = []
try members = JSON.parse fs.readFileSync 'members.json'

console.log 'getting members'
vk.get 'groups.getMembers', params, (res) ->
  if members.length
    joined = subtract res.items, members
    joined.title = 'Вступили в группу:'
    left = subtract members, res.items
    left.title = 'Покинули группу:'
    paragraphs = []
    for arr in [joined, left]
      continue unless arr.length
      paragraphs.push arr.title, ("*id#{user.id} (#{fullname user})" for user in arr).join '\n'
    message = paragraphs.join '\n\n'
    console.log(message)
    if paragraphs.length
      vk.post 'wall.post',
        owner_id: statsId
        from_group: 1
        message: message
  members = res.items
  console.log "retrieved #{members.length} members:"
  for member in members
    console.log fullname member
  fs.writeFileSync('members.json', JSON.stringify members)
  fs.writeFileSync('timestamp.txt', String Date.now())
  members

fullname = ({first_name, last_name}) -> "#{first_name} #{last_name}"

subtract = (arr1, arr2) ->
  arr1.filter (item) -> arr2.every ({id}) -> id != item.id
